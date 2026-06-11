# Backend

Haskell backend for the authoritative deterministic simulation.

## Purpose

The backend owns all authoritative simulation state and rules. The core must remain mostly pure and deterministic; effects are injected at the boundary.

## Intended structure

```text
backend/
  app/
    Main.hs
  src/
    Core/
      Types.hs
      Quantity.hs
      Tick.hs
      Market.hs
      Operators.hs
      Resources.hs
      Factories.hs
      Bots.hs
      Simulation.hs
      Visibility.hs
      LegalChoices.hs
      Events.hs
      Seed.hs
    Server/
      Api.hs
      Handlers.hs
      AppEnv.hs
      Json.hs
    Infrastructure/
      Random.hs
      Logging.hs
      Persistence.hs
      Time.hs
      Config.hs
  test/
  stack.yaml
  package.yaml
```

## Core rule

`Core` modules should be importable and testable without starting a server or touching `IO`.

Preferred shape:

```haskell
stepSimulation :: Config -> State -> BotChoices -> State
tick :: Config -> State -> State
```

## Stack setup note

Do not guess the resolver. Before creating `stack.yaml`, verify the latest stable GHC resolver supported by Stack in the implementation environment. Then document the resolver choice in this README.

## First backend tasks

1. Initialize Stack project.
2. Define exact quantity representation.
3. Define core domain types.
4. Add deterministic seed state.
5. Add market matching tests.
