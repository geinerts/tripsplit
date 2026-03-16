# Architecture Overview

## Goal
Build a scalable TripSplit platform where new features can be added without turning code into a monolith blob.

## Strategy
- Mobile app: Flutter, feature-first structure with clean layers.
- Backend: versioned API (`v1`) organized by domain modules.
- Process: every feature follows the same Definition of Done and contract-first API workflow.

## Module Boundaries
- `auth`
- `trips`
- `expenses`
- `balances`
- `random`
- `admin`

Each module owns:
- data model and validation
- business rules
- endpoint contract
- tests

## Rules
1. No direct cross-feature imports in presentation layer.
2. Domain layer has no Flutter UI dependency.
3. API changes require contract update in `docs/api/` first.
4. Every change includes tests and migration notes.
