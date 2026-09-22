#!/usr/bin/env bash

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
packages_root=${DOTFILES_PACKAGES_ROOT:-"$repo_root/packages"}
managed_paths_file=${DOTFILES_MANAGED_PATHS_FILE:-"$repo_root/config/managed-paths.tsv"}
state_root=${DOTFILES_STATE_ROOT:-"${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"}

info() {
  printf '==> %s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

version_at_least() {
  local actual=$1
  local required=$2

  [[ "$(printf '%s\n%s\n' "$required" "$actual" | sort -V | head -n 1)" == "$required" ]]
}

stow_version() {
  stow --version 2>/dev/null | sed -n '1s/.* \([0-9][0-9.]*\)$/\1/p'
}

require_stow() {
  local version

  command -v stow >/dev/null 2>&1 || die "GNU Stow 2.4.0 or newer is required"
  version=$(stow_version)
  [[ -n "$version" ]] || die "unable to determine the GNU Stow version"
  version_at_least "$version" "2.4.0" ||
    die "GNU Stow $version is too old; version 2.4.0 or newer is required"
}

validate_relative_path() {
  local value=$1

  [[ -n "$value" && "$value" != /* ]] || return 1
  [[ "/$value/" != *"/../"* && "/$value/" != *"/./"* ]] || return 1
  [[ "$value" != "." && "$value" != ".." ]]
}

path_kind() {
  local item=$1

  if [[ -L "$item" ]]; then
    printf 'symlink\n'
  elif [[ -f "$item" ]]; then
    printf 'file\n'
  elif [[ -d "$item" ]]; then
    printf 'directory\n'
  elif [[ -e "$item" ]]; then
    printf 'other\n'
  else
    printf 'absent\n'
  fi
}

path_matches_copy() {
  local item=$1
  local copy=$2
  local kind=$3
  local mode=$4

  [[ "$(stat -c '%a' -- "$item" 2>/dev/null)" == "$mode" ]] || return 1
  [[ "$(stat -c '%a' -- "$copy" 2>/dev/null)" == "$mode" ]] || return 1
  case "$kind" in
    symlink)
      [[ -L "$item" && -L "$copy" ]] &&
        [[ "$(readlink -- "$item")" == "$(readlink -- "$copy")" ]]
      ;;
    file)
      [[ -f "$item" && -f "$copy" ]] && cmp -s -- "$item" "$copy"
      ;;
    directory)
      [[ -d "$item" && ! -L "$item" && -d "$copy" && ! -L "$copy" ]] &&
        diff -qr --no-dereference -- "$item" "$copy" >/dev/null
      ;;
    other)
      [[ -e "$item" && ! -L "$item" && -e "$copy" && ! -L "$copy" ]] &&
        [[ "$(stat -c '%F' -- "$item")" == "$(stat -c '%F' -- "$copy")" ]]
      ;;
    *)
      return 1
      ;;
  esac
}

link_points_to() {
  local item=$1
  local source=$2

  [[ -L "$item" ]] || return 1
  [[ "$(readlink -m -- "$item")" == "$(readlink -m -- "$source")" ]]
}

canonical_target_root() {
  local target_root=$1
  local canonical

  [[ -n "$target_root" && -d "$target_root" ]] ||
    die "target root does not exist: ${target_root:-<empty>}"
  canonical=$(readlink -e -- "$target_root") ||
    die "unable to resolve target root: $target_root"
  [[ "$canonical" != / ]] || die "refusing unsafe target root: $target_root"
  printf '%s\n' "$canonical"
}

package_is_selected() {
  local package=$1
  shift
  local selected

  for selected in "$@"; do
    [[ "$package" == "$selected" ]] && return 0
  done
  return 1
}

load_default_packages() {
  awk -F '\t' '!/^[[:space:]]*(#|$)/ { print $1 }' "$managed_paths_file" |
    LC_ALL=C sort -u
}

validate_packages() {
  local package

  (($# > 0)) || die "no managed packages are configured"
  for package in "$@"; do
    [[ "$package" =~ ^[a-z0-9][a-z0-9._-]*$ ]] ||
      die "invalid package name: $package"
    [[ -d "$packages_root/$package" ]] ||
      die "package directory does not exist: $packages_root/$package"
    awk -F '\t' -v package="$package" \
      '$0 !~ /^[[:space:]]*(#|$)/ && $1 == package { found=1 } END { exit !found }' \
      "$managed_paths_file" ||
      die "package has no managed-path entries: $package"
  done
}

for_each_managed_path() {
  local callback=$1
  shift
  local package source_relative target_relative extra

  while IFS=$'\t' read -r package source_relative target_relative extra; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    [[ -z "$extra" ]] || die "managed-path entry has too many fields for $package"
    package_is_selected "$package" "$@" || continue
    validate_relative_path "$source_relative" ||
      die "unsafe source path in managed-paths.tsv: $source_relative"
    validate_relative_path "$target_relative" ||
      die "unsafe target path in managed-paths.tsv: $target_relative"
    [[ -e "$packages_root/$package/$source_relative" ||
      -L "$packages_root/$package/$source_relative" ]] ||
      die "managed source does not exist: $package/$source_relative"
    [[ ! -L "$packages_root/$package/$source_relative" ||
      -e "$packages_root/$package/$source_relative" ]] ||
      die "managed source is a dangling symlink: $package/$source_relative"
    "$callback" "$package" "$source_relative" "$target_relative"
  done <"$managed_paths_file"
}

print_managed_target() {
  printf '%s\n' "$3"
}

verify_package_coverage() (
  set -euo pipefail

  local coverage_root
  local actual_target_list
  local expected_target_list

  coverage_root=$(mktemp -d)
  trap 'rm -rf -- "$coverage_root"' EXIT

  expected_target_list=$(
    for_each_managed_path print_managed_target "$@" | LC_ALL=C sort
  )
  ensure_target_containers "$coverage_root" "$@"
  run_stow "$coverage_root" --stow "$@"
  actual_target_list=$(
    find "$coverage_root" -type l -printf '%P\n' | LC_ALL=C sort
  )

  if [[ "$actual_target_list" != "$expected_target_list" ]]; then
    warn "managed-path allowlist does not match Stow output"
    diff -u \
      <(printf '%s\n' "$expected_target_list") \
      <(printf '%s\n' "$actual_target_list") >&2 || true
    exit 1
  fi
)

validate_target_ancestor_path() {
  local target_root=$1
  local target_relative=$2
  local ancestor_relative ancestor_path
  local component
  local -a components

  ancestor_relative=$(dirname -- "$target_relative")
  [[ "$ancestor_relative" != . ]] || return 0

  ancestor_path=$target_root
  IFS=/ read -ra components <<<"$ancestor_relative"
  for component in "${components[@]}"; do
    ancestor_path=$ancestor_path/$component
    [[ ! -L "$ancestor_path" ]] ||
      die "managed target has a symlinked ancestor: $target_relative"
    [[ ! -e "$ancestor_path" || -d "$ancestor_path" ]] ||
      die "managed target has a non-directory ancestor: $target_relative"
  done
}

validate_target_ancestors() {
  local target_root=$1
  shift

  inspect_target() {
    validate_target_ancestor_path "$target_root" "$3"
  }

  for_each_managed_path inspect_target "$@"
  unset -f inspect_target
}

ensure_real_directory() {
  local directory=$1

  [[ ! -L "$directory" ]] || die "refusing symlinked target container: $directory"
  if [[ -e "$directory" ]]; then
    [[ -d "$directory" ]] || die "target container is not a directory: $directory"
  else
    mkdir -- "$directory"
  fi
}

ensure_target_containers() {
  local target_root=$1
  shift

  if package_is_selected nvim "$@" || package_is_selected kitty "$@"; then
    ensure_real_directory "$target_root/.config"
  fi
  if package_is_selected kitty "$@"; then
    ensure_real_directory "$target_root/.config/kitty"
  fi
  if package_is_selected codex "$@"; then
    ensure_real_directory "$target_root/.codex"
  fi
  if package_is_selected agents "$@"; then
    ensure_real_directory "$target_root/.agents"
    ensure_real_directory "$target_root/.agents/skills"
  fi
}

run_stow() {
  local target_root=$1
  local action=$2
  shift 2

  stow --dir="$packages_root" --target="$target_root" --dotfiles "$action" "$@"
}
