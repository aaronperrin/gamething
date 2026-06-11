# API Contract

Initial backend API for the browser inspector and manual simulation controls.

This contract is intentionally small. Expand it only when the frontend or tests need more information.

## Principles

- Backend is authoritative.
- API responses should be deterministic for a given state.
- IDs and quantities should serialize as strings when needed to avoid precision loss.
- The frontend must not rely on private/internal state.
- Mutation endpoints return the resulting visible or public state needed by the inspector.

## Endpoints

### `GET /api/state`

Returns a simulation state summary suitable for the inspector.

Include:

- current tick
- players summary
- public market summary
- recent trades
- recent events
- metrics summary

Do not include:

- internal RNG state
- hidden plugin internals
- other bots' private memory unless intentionally exposed as public debug state

### `GET /api/market`

Returns public market state.

Include:

- open bids
- open asks
- recent trades
- public asset metadata
- current spread / volume metrics where available

### `GET /api/players`

Returns public or debug-visible player summaries.

Include for each bot:

- player id
- controller type
- wallet
- inventory
- owned resource sources
- owned factories
- open orders
- high-level metrics

### `GET /api/events`

Returns recent events in deterministic order.

Query parameters may be added later:

- `sinceTick`
- `limit`
- `type`

### `POST /api/tick`

Advances the simulation by exactly one tick.

Request body may be empty for bot-only simulation.

Response:

- resulting state summary
- events emitted during the tick

### `POST /api/run`

Advances the simulation by `n` ticks synchronously.

Request body:

```json
{ "ticks": 100 }
```

Rules:

- `ticks` must be positive.
- Server should enforce a maximum per request.
- Response should include final state summary and aggregate run metrics.

### `POST /api/reset`

Resets the simulation to configured initial state.

Request body may optionally include a seed later:

```json
{ "seed": "example-seed" }
```

Response:

- fresh state summary

## Optional later endpoints

### `GET /api/metrics`

Returns detailed metrics history.

### `GET /api/plugins`

Returns public plugin metadata.

## Quantity serialization

Do not serialize authoritative quantities as JSON numbers unless the representation is known to be safe for all clients.

Recommended initial representation:

```json
{ "numerator": 1, "denominator": 4 }
```

or a fixed-precision string:

```json
"0.25"
```

The chosen representation must be documented in code and tests.

## Error shape

Use a consistent error envelope:

```json
{
  "error": {
    "code": "invalid_tick_count",
    "message": "ticks must be positive",
    "details": {}
  }
}
```

## API implementation order

1. `GET /api/state`
2. `POST /api/tick`
3. `POST /api/reset`
4. `GET /api/market`
5. `GET /api/players`
6. `GET /api/events`
7. `POST /api/run`
