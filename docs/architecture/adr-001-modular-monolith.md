# ADR-001: Modular Monolith First

## Status
Accepted

## Context
TripSplit is still early-stage but planned to grow with many features. Current codebase is flat and hard to evolve safely.

## Decision
Start with a modular monolith architecture:
- one deployable backend service
- strict internal module boundaries
- versioned API contracts (`/api/v1`)

## Why
- faster than microservices for current stage
- easier local development and deployment
- enables clear migration path if one module must be split later

## Consequences
- enforce module ownership
- avoid shared global helpers except in `core`
- keep migration notes and contracts up to date
