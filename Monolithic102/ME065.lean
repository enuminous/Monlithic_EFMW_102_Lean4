import Monolithic102.Catalog

namespace Monolithic102.ME065

def spec : EquationSpec := catalog[64]!

/- Canonical source expression:
O\_(n+1) = O\_n ∘ S\_n
S\_(n+1) = S\_n ∘ O\_(n+1)

Descriptor:
Observer and system recursively modify one another rather than remaining externally separable.
-/

end Monolithic102.ME065
