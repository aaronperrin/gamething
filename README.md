# gamething

Deterministic multiplayer economic simulation sandbox.

The project models bot-controlled players participating in an order-based market. Bots acquire resource sources, connect clocks, extract exact fractional resources, buy parts, build factories, produce fungible items, and sell those items back into the market.

## Current status

This repository has been initialized with project instructions and architecture guidance for ChatGPT Codex and human contributors. The first implementation milestone is to build a small deterministic Haskell backend core and a plain HTML/CSS/JavaScript inspector frontend.

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
│   ├── CODEX_TASKS.md                # Ordered work packets for Codex
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

## First milestone

Implement a deterministic vertical slice:

1. Define core IDs, quantities, assets, players, orders, trades, events, and state.
2. Seed a world with more than two bot players and Red/Yellow/Blue resource-source listings.
3. Let bots buy resource sources, connect clocks, and extract fractional resources.
4. Match buy/sell orders deterministically with partial fills.
5. Expose `/api/state`, `/api/market`, `/api/tick`, `/api/run`, and `/api/reset`.
6. Render an inspector UI showing ticks, bots, inventories, order book, trades, and events.

## For Codex

Start with `AGENTS.md`, then read `docs/PROJECT_SPEC.md`, `docs/ARCHITECTURE.md`, and `docs/CODEX_TASKS.md`. Do not begin large implementation changes before confirming the intended work packet and adding tests for the affected invariant.
