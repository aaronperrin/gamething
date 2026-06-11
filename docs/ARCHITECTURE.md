# Architecture

## Recommendation

Start with a modular monolith:

```text
Plain JS frontend -> HTTP API -> Haskell server shell -> pure deterministic simulation core
```

Do not split into services. Do not introduce a database yet. Keep in-memory state with explicit persistence boundaries until the core model is validated.

## Facts

- The backend must be Haskell and Stack-based.
- The authoritative simulation state lives in the backend.
- The frontend is an inspector, not an authoritative game client.
- Bots are the only initial player controllers.
- The market must be order-based with deterministic matching.
- Resource and item quantities must not use floating-point arithmetic.

## Assumptions

- The first useful milestone is a deterministic vertical slice, not feature completeness.
- In-memory state is sufficient for early simulation development.
- A simple HTTP API is enough for frontend inspection and manual ticking.
- Bot policies can start rule-based and deterministic.

## Domain model

Core nouns:

- `Config`
- `State`
- `Player`
- `BotMemory`
- `ResourceType`
- `ResourceSource`
- `Quantity`
- `Clock`
- `Connection`
- `Operator`
- `FactoryRecipe`
- `Factory`
- `Asset`
- `Order`
- `Trade`
- `Market`
- `Event`
- `Choice`
- `VisibleState`
- `LegalChoices`
- `MarketPlugin`

## Module boundaries

### Core

Pure simulation logic.

Expected modules:

```text
Core.Types
Core.Quantity
Core.Tick
Core.Market
Core.Operators
Core.Resources
Core.Factories
Core.Bots
Core.Simulation
Core.Visibility
Core.LegalChoices
Core.Events
Core.Seed
```

Rules:

- No `IO` in core transition functions.
- No imports from `Server` or `Infrastructure`.
- Deterministic ordering must be explicit.
- Prefer `Map`/`Set` structures with stable keys over hash iteration for authoritative behavior.

### Server

HTTP boundary and API serialization.

Expected modules:

```text
Server.Api
Server.Handlers
Server.AppEnv
Server.Json
```

Rules:

- Server may call pure core transitions.
- Server owns request parsing, response encoding, and state lifecycle.
- Server should not duplicate simulation rules.

### Infrastructure

External effects.

Expected modules:

```text
Infrastructure.Random
Infrastructure.Logging
Infrastructure.Persistence
Infrastructure.Time
Infrastructure.Config
```

Rules:

- Effects are injected through `AppEnv` or explicit services.
- Infrastructure must not mutate core state implicitly.

### Frontend

Plain browser inspector.

Expected modules:

```text
frontend/index.html
frontend/styles.css
frontend/src/api.js
frontend/src/render.js
frontend/src/controls.js
frontend/src/state.js
```

Rules:

- Frontend displays backend state.
- Frontend sends control commands: reset, step, run, pause.
- Frontend must not be relied on for authoritative rule validation.

## Data flow

One tick should conceptually flow as:

```text
request POST /api/tick
  -> Server loads current State
  -> Core receives Config + State
  -> Plugins provide deterministic listings
  -> Bots observe VisibleState and LegalChoices
  -> Legal choices are applied
  -> Operators fire
  -> Clocks extract resources
  -> Factories produce items
  -> Market matches orders
  -> Events and metrics are emitted
  -> Server stores new State
  -> Server returns new State summary
```

## Trust boundaries

- Browser input is untrusted.
- Bot choices are untrusted until checked against `LegalChoices`.
- Plugin listings are untrusted until validated against asset and order rules.
- Persistence input is untrusted until decoded and validated.
- The simulation core is the source of truth.

## Latency requirements

Prototype target: interactive manual stepping. Optimize for correctness and inspectability before throughput.

Initial expectation: hundreds to thousands of ticks in local development should be easy to run, but no scale commitment is made yet.

## Operational constraints

- Determinism is more important than throughput.
- State inspection is more important than compact storage.
- Logs and events should support debugging of surprising simulation behavior.
- Every major transition should be explainable from previous state plus config plus selected choices.

## Contracts and invariants

### Quantity

- No floating point for authoritative balances.
- Addition and subtraction must be exact.
- Negative balances are invalid unless explicitly modeled as debt.

### Market

- Buy orders match compatible sell orders only.
- Matching priority:
  1. best price
  2. earliest created tick
  3. lowest order id
- Partial fills are allowed.
- Initial clearing rule: trade price equals resting order price.

### Bots

- Bots receive only visible state.
- Bots propose choices.
- The core validates choices against legal choices before applying them.

### Factories

- Factory build consumes required resources and parts.
- Factory production consumes input resources and produces fungible items.
- Fungible items cannot enter the world except through factories or explicit seeded test inventory.

### Visibility

Visible state must not expose:

- other bots' private memory
- hidden plugin internals
- unrevealed private listings
- internal RNG state

## Schema evolution

Early-stage schema changes may be direct. Once saved-state compatibility matters, add explicit versioning:

```text
StateEnvelope = { schemaVersion, state }
```

Before that point, favor readable JSON for debugging.

## Observability

Track at minimum:

- tick number
- event log
- trades per tick
- market volume by asset
- average price by asset
- bid/ask spread
- unsold inventory
- bot wallet value
- bot resource balances
- factory utilization
- resource extraction per tick
- item production per tick
- order fill time

## Options considered

### Option A: Modular monolith with pure core

Pros:

- Fastest route to deterministic behavior.
- Easy to test.
- Small operational surface.
- Highly reversible.

Cons:

- May need later refactoring if simulation scale grows significantly.

### Option B: Service-oriented backend from the start

Pros:

- Clear runtime separation.
- Could scale isolated components independently later.

Cons:

- Slower delivery.
- Higher operational burden.
- Harder to preserve determinism.
- Premature for the first learning milestone.

## Decision

Use Option A.

## Rollback trigger

Revisit architecture if one of these becomes true:

- single-process simulation cannot run the target number of bots/ticks needed for product learning
- persistence requirements become incompatible with simple state snapshots
- independent teams need hard ownership boundaries across runtime services
- deterministic replay becomes too expensive without a more specialized event log
