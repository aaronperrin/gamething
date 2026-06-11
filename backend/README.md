# Backend

Haskell backend for the authoritative deterministic simulation.

## Purpose

The backend owns all authoritative simulation state and rules. The core must remain mostly pure and deterministic; effects are injected at the boundary.

## Intended structure

backend/app/Main.hs
backend/src/Core
backend/src/Server
backend/src/Infrastructure
backend/test
backend/stack.yaml
backend/package.yaml

## Core rule

Core modules should be importable and testable without starting a server or touching IO.

Preferred pure functions:

stepSimulation :: Config -> State -> BotChoices -> State

tick :: Config -> State -> State

## Stack setup note

Use Stack for the backend workflow. Prefer a stable resolver that works on the local Windows 11 development machine. If the newest resolver cannot be confirmed from local tooling, choose a conservative supported resolver and document that assumption.

## Windows commands

Document local commands as single-line Windows Command Prompt examples.

Example: cd backend && stack build

Example: cd backend && stack test

## First backend campaign

1. Initialize Stack project.
2. Define exact quantity representation.
3. Define core domain types.
4. Add deterministic seed state.
5. Add market matching tests.
