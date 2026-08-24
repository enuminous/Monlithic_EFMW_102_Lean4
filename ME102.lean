import Monolithic102.Catalog

namespace Monolithic102.ME102

def spec : EquationSpec := catalog[101]!

/- Canonical source expression:
Accept EFMW only if
ΔtEFMW > Δtbaseline
FAR ≤ FARmax
Ccompute ≤ Cmax
Replication = True
Accept the EFMW hypothesis only if:
- Mean warning lead time is greater than the chosen baseline.
- False-alarm rate remains within the predefined limit.
- Computational cost remains within the predefined budget.
- Results replicate across independent datasets and trials.

Descriptor:
Primary experimental benchmark for validating or falsifying the proposed EFMW control-monitoring framework.
-/

end Monolithic102.ME102
