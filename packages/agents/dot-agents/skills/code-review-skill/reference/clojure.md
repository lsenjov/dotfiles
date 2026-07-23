# Clojure Code Review Guide

> Review framework for Clojure and ClojureScript changes. Detailed guidance and examples can be added incrementally.

## Table of Contents

- [Data and Sequences](#data-and-sequences)
- [State and Concurrency](#state-and-concurrency)
- [Functions, Macros, and Abstractions](#functions-macros-and-abstractions)
- [JavaScript and Java Interop](#javascript-and-java-interop)
- [Error Handling](#error-handling)
- [Performance](#performance)
- [Security](#security)
- [Testing and Tooling](#testing-and-tooling)
- [Review Checklist](#review-checklist)

---

Read any STYLE_GUIDE_CLJ.md and CODE_STRUCTURE.md in the repo.

## Data and Sequences

Review immutable data transformations, collection semantics, laziness, and boundary validation.

## State and Concurrency

Review the choice and lifecycle of Vars, atoms, refs, agents, futures, and asynchronous processes.

## Functions, Macros, and Abstractions

Review function boundaries, namespace design, protocols, multimethods, and whether macros are justified.

## JavaScript and Java Interop

Review host-platform boundaries, type assumptions, resource ownership, and exception behavior.

## Error Handling

Review failure representation, exception context, cleanup, and caller-visible behavior.

## Performance

Review sequence realization, allocation, reflection, transients, and workload-specific bottlenecks.

## Security

Review reader and evaluation boundaries, input handling, dependency risk, secrets, and injection surfaces.

## Testing and Tooling

Review behavioral coverage, property-based tests where appropriate, linting, formatting, and dependency configuration.

## Review Checklist

### Correctness

- [ ] Data shapes and boundary assumptions are explicit.
- [ ] Lazy work is realized at the intended time and within the intended resource scope.
- [ ] State and concurrency primitives match the required coordination semantics.

### Design

- [ ] Namespaces and public APIs have clear responsibilities.
- [ ] Macros and polymorphic abstractions are warranted by the problem.
- [ ] Host interop is isolated behind clear boundaries.

### Reliability

- [ ] Failures retain useful context and resources are released safely.
- [ ] Security-sensitive reader, evaluator, and input paths are constrained.
- [ ] Tests cover important behavior and concurrency boundaries.
