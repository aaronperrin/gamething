# ADR 0001: Initial architecture principles

## Status

Accepted.

## Context

The project is a deterministic multiplayer economic simulation. The first goal is to discover whether interesting economic/mechanical behavior emerges from bots, clocks, resources, factories, fungible items, and a real market.

The project does not yet need scale-oriented infrastructure. It does need correctness, determinism, replayability, and inspectability.

## Decision

Use a modular monolith with a pure deterministic Haskell simulation core, a thin Haskell HTTP server shell, injected infrastructure effects, and a plain HTML/CSS/JavaScript frontend inspector.

Dependency direction:

```text
Frontend -> HTTP API -> Server / Infrastructure -> Core
```

The `Core` layer owns all authoritative state transitions and must not depend on `IO`, server modules, browser code, persistence, logging, or wall-clock time.

## Consequences

Positive:

- Fastest path to a working deterministic vertical slice.
- Core rules are easy to test.
- Deterministic replay remains tractable.
- Future architecture changes remain reversible.

Negative:

- Single-process simulation may eventually become a bottleneck.
- Persistence and replay strategy may need redesign after product learning.
- Module boundaries require discipline because the repository is not split into runtime services.

## Alternatives considered

### Service-oriented backend from the start

Rejected for now. It increases operational burden and makes deterministic semantics harder before the core model is validated.

### Frontend framework from the start

Rejected for now. The frontend is an inspector first, and plain browser code is sufficient for early controls and rendering.

### Event sourcing from the start

Rejected for now. Events are required for observability, but the authoritative model can start with explicit state transitions plus event logs. Revisit if deterministic replay or audit needs outgrow snapshots.

## Rollback trigger

Revisit this decision if:

- the single-process backend cannot support required learning experiments
- multiple developers need independent runtime ownership boundaries
- replay/debugging requires event-sourced persistence
- frontend inspector complexity exceeds maintainable plain JavaScript
