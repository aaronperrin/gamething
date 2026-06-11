# Operator Market Simulation Specification

## Summary

This project is a deterministic multiplayer economic simulation built around clocks, resources, factories, fungible items, and a real market.

Players are initially controlled only by bots. They buy resources and operators, connect clocks to extract resources, build factories from parts and resources, produce fungible items, and attempt to sell those items back into the market.

This is not initially a win/loss game. It is a simulation sandbox for discovering whether interesting economic/mechanical behavior emerges from operators, production, and markets.

Core model:

```text
Bots buy resources.
Bots connect clocks to resources.
Clock ticks extract fractional resource units.
Bots combine resources and parts to build factories.
Factories produce fungible items.
Bots sell fungible items on a real market.
The market evolves from supply, demand, bids, asks, and trades.
```

## Implementation Requirements

### Backend

The backend must be written in Haskell.

Requirements:

```text
- latest stable Haskell/GHC supported by Stack at implementation time
- Stack project, not Cabal-only workflow
- functional programming idioms
- pure deterministic simulation core
- dependency injection for external services, randomness, persistence, logging, clock, and configuration
- explicit state transitions
- no hidden global mutable state
```

Preferred architecture:

```text
backend/
  app/
    Main.hs
  src/
    Core/
      Types.hs
      Tick.hs
      Market.hs
      Operators.hs
      Resources.hs
      Factories.hs
      Bots.hs
      Simulation.hs
      Visibility.hs
    Server/
      Api.hs
      Handlers.hs
      AppEnv.hs
    Infrastructure/
      Random.hs
      Logging.hs
      Persistence.hs
      Time.hs
  test/
  stack.yaml
  package.yaml
```

The core simulation should be mostly pure:

```haskell
stepSimulation :: Config -> State -> BotChoices -> State
tick :: Config -> State -> State
```

Effects should be pushed to the boundary.

Use dependency injection through records of functions or typeclasses.

Example shape:

```haskell
data AppEnv = AppEnv
  { envLoadConfig :: IO Config
  , envSaveState  :: State -> IO ()
  , envLoadState  :: IO State
  , envLog        :: LogEvent -> IO ()
  , envRng        :: RngService
  }
```

The simulation core should not directly depend on IO.

### Frontend

The frontend must use HTML, CSS, and JavaScript.

Requirements:

```text
- latest stable HTML standard features available in modern browsers
- latest stable JavaScript syntax supported by current evergreen browsers
- no frontend framework unless explicitly justified later
- browser UI for inspecting simulation state
- manual controls for stepping ticks and running bot simulations
```

Preferred frontend structure:

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

The frontend is an inspector first, not a full game client.

## Core Concepts

### Game / Simulation

```text
Simulation =
  {
    config,
    state,
    operatorLibrary,
    marketPlugins,
    botPolicies
  }
```

### State

```text
State =
  {
    tick,
    players,
    market,
    resources,
    factories,
    operators,
    events,
    logs,
    terminal
  }
```

### Player

```text
Player =
  {
    id,
    controller,
    wallet,
    inventory,
    installedOperators,
    ownedResources,
    ownedFactories,
    openOrders,
    memory,
    metrics
  }
```

Initial controller type:

```text
bot
```

Human control may be added later, but first implementation should be bot-only.

## Required Invariants

```text
I1. N > 2.
I2. Backend authoritative state is Haskell.
I3. Stack is used for Haskell project workflow.
I4. Simulation core is deterministic and mostly pure.
I5. External effects are injected.
I6. Market is order-based, not a static shop.
I7. Resource units support exact fractional quantities.
I8. A clock connection is required for extraction.
I9. Fungible items are interchangeable by item type.
I10. Fungible items must originate from factories.
I11. Factories require resources and/or parts to build.
I12. Market plugins can add available asset types/listings.
I13. Bots initially control all players.
I14. Bots can only apply legal choices.
```

## Compact Definition

```text
A deterministic Haskell backend simulates bots participating in a real market.

The market starts with Red, Yellow, and Blue resource sources.
Bots buy sources, connect clocks, extract fractional resources, buy parts, build factories, produce fungible items, and sell those items back into the market.

The frontend is a modern HTML/JavaScript inspector for ticks, bots, inventories, factories, trades, and market behavior.

The market is pluggable so new resources, parts, factories, operators, and fungible items can be introduced without rewriting the core simulation.
```

## Source note

This document is a curated repository copy of the initial project specification. When implementation details diverge, update this document or add an architecture decision record explaining the change.
