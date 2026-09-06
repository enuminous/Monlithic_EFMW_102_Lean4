import Monolithic102.Catalog

namespace Monolithic102.ME033

def spec : EquationSpec := catalog[32]!

/- Canonical source expression:
λ\_max = lim(t→∞) (1/t) ln(||δX(t)|| / ||δX(0)||)

Descriptor:
Stable attractor behavior generally requires λ\_max < 0 locally.
-/

end Monolithic102.ME033
