# Frontend

Plain HTML/CSS/JavaScript inspector for the simulation.

## Purpose

The frontend is not an authoritative game client. It exists to inspect backend state and manually control simulation ticks.

## Intended structure

```text
frontend/
  index.html
  styles.css
  src/
    api.js
    render.js
    controls.js
    state.js
```

## Initial UI requirements

Display:

- current tick
- bot list
- bot wallets
- bot inventories
- owned resource sources
- clock connections
- factories
- public market order book
- recent trades
- event log
- metrics

Controls:

- reset simulation
- step one tick
- run N ticks
- pause run

## Rules

- Use plain modern browser APIs.
- Do not introduce a frontend framework without an accepted architecture decision record.
- Do not duplicate authoritative simulation rules in JavaScript.
- Treat all API responses as display data.
