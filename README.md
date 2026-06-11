# gamething

Deterministic multiplayer economic simulation sandbox.

The project models bot-controlled players participating in an order-based market. Bots acquire resource sources, connect clocks, extract exact fractional resources, buy parts, build factories, produce fungible items, and sell those items back into the market.

## Current status

This repository has been initialized with project instructions and architecture guidance for ChatGPT Codex and human contributors. The first implementation campaign is to build an executable deterministic Haskell backend core plus enough API/frontend surface to inspect the simulation loop.

## Non-negotiable requirements

- Backend authoritative state is Haskell.
- Use Stack for the Haskell workflow.
- Keep the simulation core pure and deterministic.
- Inject external effects: randomness, persistence, logging, wall-clock time, configuration, and services.
- Use exact rational or fixed-precision decimal arithmetic for authoritative balances.
- The market is order-based, not a static shop.
- Bots must only apply legal choices.
- A clock connection is required before resource extraction.
- Fungible items must originate from factory production or explicitly seeded test inventory.

## Repository layout

```text
.
├── AGENTS.md                         # Primary Codex / agent instructions
├── docs/
│   ├── PROJECT_SPEC.md               # Product and simulation specification
│   ├── ARCHITECTURE.md               # Architecture, boundaries, invariants
│   ├── API.md                        # Initial HTTP API contract
│   ├── CODEX_TASKS.md                # Ambitious PR campaign backlog for Codex
│   ├── TEST_PLAN.md                  # Required validation strategy
│   └── decisions/
│       └── 0001-architecture-principles.md
├── backend/
│   ├── README.md
│   ├── app/
│   ├── src/
│   │   ├── Core/
│   │   ├── Server/
│   │   └── Infrastructure/
│   └── test/
└── frontend/
    ├── README.md
    └── src/
```

## First implementation campaign

Deliver a coherent deterministic vertical slice:

1. Define core IDs, quantities, assets, players, orders, trades, events, and state.
2. Seed a world with more than two bot players and Red/Yellow/Blue resource-source listings.
3. Let bots buy resource sources, connect clocks, and extract fractional resources.
4. Match buy/sell orders deterministically with partial fills.
5. Expose `/api/state`, `/api/market`, `/api/tick`, `/api/run`, and `/api/reset`.
6. Render an inspector UI showing ticks, bots, inventories, order book, trades, and events.

## For Codex

Start with `AGENTS.md`, then read `docs/PROJECT_SPEC.md`, `docs/ARCHITECTURE.md`, and `docs/CODEX_TASKS.md`.

Codex should prefer ambitious, coherent PR campaigns with tests, docs, and stakeholder checkpoints. Do not block solely because external search is unavailable; use pinned repo versions or local tool output, and document assumptions when freshness cannot be verified.

All documented local commands should be single-line Windows Command Prompt commands, for example:

```cmd
cd backend && stack test
```
