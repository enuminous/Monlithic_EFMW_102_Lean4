# Monolithic 102 — Lean 4 Formalization

This repository is a Lean 4 companion to the canonical Monolithic 102 equation corpus.
It preserves **ME-001 through ME-102** as one indexed set and begins theorem-assistant
formalization without confusing a typed declaration with a scientific proof.

## What is here

- `Monolithic102/Catalog.lean` — all 102 canonical IDs, titles, source expressions, descriptors, and formalization status.
- `Monolithic102/ME001.lean` … `ME102.lean` — one stable Lean namespace per equation.
- `Monolithic102/Formalized.lean` — typed Lean definitions for equations that can already be represented cleanly.
- `Monolithic102/All.lean` — imports the entire 102-equation set.
- `source/MONOLITHIC_102_SOURCE.md` — preserved source corpus.
- `equation-map.json` — machine-readable crosswalk.

## Formalization policy

A Lean file existing for an equation does **not** mean Lean has proved the physical claim.
The project separates:

1. **Canonical preservation** — what the equation says.
2. **Typing/formalization** — whether its symbols have precise mathematical domains.
3. **Derivation/proof** — whether a proposition follows from explicit assumptions.
4. **Scientific validation** — whether the model matches the world.

Undefined constructs are deliberately not filled in by guesswork. They remain marked as needing specification until their domains, units, operators, boundary conditions, and assumptions are frozen.

## Build

```bash
lake update
lake build
```

The project uses Mathlib.

## Useful AI prompt

> Load the Monolithic 102 Lean project. Preserve ME-001 through ME-102 identifiers. For the requested equation, distinguish canonical source, Lean typing, derivation status, and empirical status. Do not convert an axiom or placeholder into a claimed proof. Identify every missing definition required to move the equation from `needsSpecification` to a theorem-level formalization.

## Next formalization pass

The most useful next step is to freeze a shared type-and-units layer for spacetime fields, tensors, derivatives, state vectors, probability distributions, control-system histories, recursive operators, and coherence metrics. Once those primitives are fixed, many equations currently represented only in the catalog can be promoted into typed definitions and propositions.
