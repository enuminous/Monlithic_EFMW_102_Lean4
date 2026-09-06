# Forensic recovery of the September 5, 2026 Lean tree

This branch repairs the namespace/package layout that existed in the post-Tranche-IV local working tree without rewriting `main`.

## Exact recovered material

- `Monolithic102/Schema.lean` is the surviving blob `8cb8d59cde5c75e4e30efb50ed0094e5c1ae34b7`.
- `Monolithic102/Catalog.lean` is the surviving blob `d75f6d28e111070e758b5f4ae11b12ab52ff0886`.
- `Monolithic102/Formalized.lean` is the surviving blob `96d683d29ff097bd8d04d52351077830b6ec4952`.
- `Monolithic102/All.lean` and all 102 `ME###.lean` modules are surviving blobs from the old flat public tree, reattached at the namespace paths their imports require. Their blob identities are unchanged.
- `lean-toolchain` remains Lean 4.19.0.

## Lost Git object

The local Tranche IV commit recorded in the September 5 verification paper,
`301a95ef94ba8888f62fb39a9df2e3533041dd9a`, was not pushed and is not addressable in the connected public repository. Earlier tranche commit objects recorded in the papers are likewise unavailable.

Therefore this branch is a **forensic recovery**, not a byte-for-byte recreation of that lost commit. It receives its own recovery SHA.

## Historical verification record

Retained project records state that the lost local tree contained 63 checked declarations (12 + 18 + 10 + 21 tranche declarations plus 2 infrastructure results), and that a full `lake build` passed 2,073 targets under Lean 4.19.0 with Mathlib commit `c44e0c8ee63ca166450922a373c7409c5d26b00b`, with no `sorry`, `admit`, or explicit project axiom declarations.

That remains a historical verification record. This recovered branch does **not** claim to reproduce the 63-declaration kernel result until the retained/reconstructed tranche sources are restored and a new clean build passes.

## Dependency pin

The recovery `lakefile.lean` pins Mathlib directly to `c44e0c8ee63ca166450922a373c7409c5d26b00b`. `lake update` is expected to regenerate the corresponding manifest before the clean build.

## Rule

No theorem count is increased and no lost SHA is impersonated. Recovered source and reconstructed source are labeled separately.
