# Test Plan

Testing should protect determinism, economic correctness, and invariant preservation.

## Strategy

Prioritize pure core tests. Server and frontend tests can remain thin until the core behavior stabilizes.

Test layers:

1. Unit tests for pure functions.
2. Integration tests for complete tick transitions.
3. Property-style tests for conservation and determinism where practical.
4. API tests for endpoint contract and safe quantity serialization.
5. Minimal frontend smoke tests after the inspector exists.

## Core invariant tests

### Determinism

- Same config + same seed + same plugin set + same bot policies produces same state sequence.
- Bot iteration order is stable.
- Plugin listing order is stable.
- Market matching order is stable.

### Quantity arithmetic

- Exact representation of `0.25`, `1.50`, and `3.00`.
- Addition and subtraction preserve exactness.
- Invalid negative balances are rejected unless explicitly modeled.
- JSON serialization does not lose precision.

### Market

- Compatible bid and ask match.
- Incompatible asset orders do not match.
- Best price wins.
- Earlier created tick wins ties.
- Lowest order id wins remaining ties.
- Partial fills leave correct remaining quantity.
- Filled orders are not matched again.
- Trade price equals resting order price for the initial clearing rule.

### Resource extraction

- Unconnected resource source extracts nothing.
- Connected clock extracts the configured rate each tick.
- Multiple ticks accumulate exact fractional balances.
- Extraction events are emitted in deterministic order.

### Factories

- Build requires required resources and parts.
- Build consumes exact inputs.
- `buildTicks = 0` installs immediately.
- Delayed build model remains representable.
- Production consumes inputs and creates output.
- Production does not run when inputs are missing.
- Fungible items merge by owner and item type.
- Fungible items cannot appear except through production or explicit seeded fixture.

### Bots and choices

- `LegalChoices` never includes choices the player cannot afford or apply.
- Bots only apply choices present in `LegalChoices`.
- Illegal choices are rejected or produce explicit no-op/error semantics.
- Visible state excludes other bots' private memory.

### Plugins

- Basic resource plugin lists RedSource, YellowSource, and BlueSource.
- Basic part plugin lists basic parts.
- Basic factory plugin exposes recipes deterministically.
- Plugin-provided orders are validated before insertion.

## Integration scenarios

### Scenario A: Resource collector

Initial world with three bots and resource-source listings.

Expected:

1. Bot buys a resource source.
2. Bot connects a clock.
3. Bot accumulates exact resource quantity after ticks.
4. Events explain purchase, connection, and extraction.

### Scenario B: Market partial fill

Initial order book:

```text
Sell 10 Red at 2
Buy 3 Red at 3
```

Expected:

- One trade for quantity 3.
- Sell order remains open or partially filled with quantity 7.
- Buy order is filled.
- Trade price uses resting order price.

### Scenario C: Factory production

Initial player inventory contains required resources and parts for `OrangeMixer`.

Expected:

1. Build consumes Red, Yellow, and Frame.
2. Factory is installed.
3. Production consumes Red and Yellow.
4. `OrangeUnit` balance increases.

### Scenario D: Replay

Run 100 ticks twice with same config and seed.

Expected:

- Final states are equal.
- Event sequences are equal.
- Trade sequences are equal.

## API tests

- `GET /api/state` returns current tick and public state.
- `POST /api/tick` advances exactly one tick.
- `POST /api/run` advances exactly requested bounded count.
- `POST /api/reset` returns deterministic initial state.
- Invalid request bodies return the standard error envelope.

## Frontend tests

Minimal early checks:

- Page loads without build tooling.
- Controls call expected API endpoints.
- Render functions tolerate empty market, empty trades, and empty events.
- Quantity display is consistent with API serialization.

## Definition of done for core changes

A core behavior change is done only when:

- affected invariant tests pass
- deterministic replay is not broken
- event output explains the mutation
- docs are updated if contracts changed
