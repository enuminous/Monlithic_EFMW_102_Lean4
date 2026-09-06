import Mathlib

/-!
# ME-036 / ME-037 operator repair candidate

Status: compile candidate, not yet counted as a kernel-checked theorem tranche.

Purpose:
1. Preserve the already-proved fact that a symmetric pairing collapses the
   written `(α, β)` cross-gradient pair to the single coefficient `κ = α + β`.
2. Freeze the least-invasive repaired operator.
3. Represent a genuinely directional alternative with distinct typed
   operators rather than two names attached to a symmetric dot product.
4. State a sufficient two-probe identifiability condition for the directional
   coefficient pair.

This file intentionally stops at the operator layer. It does not invent the
spatial domain, boundary conditions, regularity class, physical units, or
scientific interpretation needed for a PDE well-posedness theorem.
-/

namespace Monolithic102
namespace ME036_037Repair

/-- The two-coefficient coupling exactly as written before imposing symmetry. -/
def originalCoupling {V : Type*}
    (pair : V → V → ℝ) (α β : ℝ) (s o : V) : ℝ :=
  α * pair s o + β * pair o s

/-- Conservative repaired coupling for a symmetric pairing. -/
def symmetricCoupling {V : Type*}
    (pair : V → V → ℝ) (κ : ℝ) (s o : V) : ℝ :=
  κ * pair s o

/-- Under symmetry, the original ME-036/037 cross term is exactly the
single-parameter repair with `κ = α + β`. -/
theorem original_eq_symmetricRepair {V : Type*}
    (pair : V → V → ℝ) (α β : ℝ) (s o : V)
    (hSymm : ∀ x y, pair x y = pair y x) :
    originalCoupling pair α β s o =
      symmetricCoupling pair (α + β) s o := by
  simp [originalCoupling, symmetricCoupling, hSymm o s]
  ring

/-- Any shift `(α,β) ↦ (α+δ,β-δ)` leaves the symmetric coupling unchanged. -/
theorem symmetric_shift_invariant {V : Type*}
    (pair : V → V → ℝ) (α β δ : ℝ) (s o : V)
    (hSymm : ∀ x y, pair x y = pair y x) :
    originalCoupling pair (α + δ) (β - δ) s o =
      originalCoupling pair α β s o := by
  simp [originalCoupling, hSymm o s]
  ring

/-- For a symmetric pairing the coupling depends only on the sum of the two
written coefficients. -/
theorem symmetric_depends_only_on_sum {V : Type*}
    (pair : V → V → ℝ)
    (α β α' β' : ℝ) (s o : V)
    (hSymm : ∀ x y, pair x y = pair y x)
    (hSum : α + β = α' + β') :
    originalCoupling pair α β s o =
      originalCoupling pair α' β' s o := by
  calc
    originalCoupling pair α β s o =
        symmetricCoupling pair (α + β) s o :=
      original_eq_symmetricRepair pair α β s o hSymm
    _ = symmetricCoupling pair (α' + β') s o := by rw [hSum]
    _ = originalCoupling pair α' β' s o :=
      (original_eq_symmetricRepair pair α' β' s o hSymm).symm

/-- A genuinely directional model uses two differently typed operators. -/
def directionalCoupling {GradS GradO : Type*}
    (B_SO : GradS → GradO → ℝ)
    (B_OS : GradO → GradS → ℝ)
    (α β : ℝ) (s : GradS) (o : GradO) : ℝ :=
  α * B_SO s o + β * B_OS o s

/-- If the two directional operator responses happen to agree at a state,
the directional expression locally collapses to the same single coefficient. -/
theorem directional_collapses_when_outputs_agree
    {GradS GradO : Type*}
    (B_SO : GradS → GradO → ℝ)
    (B_OS : GradO → GradS → ℝ)
    (α β : ℝ) (s : GradS) (o : GradO)
    (hAgree : B_SO s o = B_OS o s) :
    directionalCoupling B_SO B_OS α β s o =
      (α + β) * B_SO s o := by
  simp [directionalCoupling, ← hAgree]
  ring

/-- Algebraic core of directional coefficient identifiability.
Two probes identify `(α,β)` when their response vectors are linearly
independent, expressed by a nonzero 2×2 determinant. -/
theorem twoProbe_identifiability
    (a₁ b₁ a₂ b₂ α β α' β' : ℝ)
    (hdet : a₁ * b₂ - a₂ * b₁ ≠ 0)
    (h₁ : α * a₁ + β * b₁ = α' * a₁ + β' * b₁)
    (h₂ : α * a₂ + β * b₂ = α' * a₂ + β' * b₂) :
    α = α' ∧ β = β' := by
  have hαprod :
      (α - α') * (a₁ * b₂ - a₂ * b₁) = 0 := by
    linear_combination b₂ * h₁ - b₁ * h₂
  have hβprod :
      (β - β') * (a₁ * b₂ - a₂ * b₁) = 0 := by
    linear_combination a₁ * h₂ - a₂ * h₁
  have hαzero : α - α' = 0 :=
    (mul_eq_zero.mp hαprod).resolve_right hdet
  have hβzero : β - β' = 0 :=
    (mul_eq_zero.mp hβprod).resolve_right hdet
  exact ⟨sub_eq_zero.mp hαzero, sub_eq_zero.mp hβzero⟩

/-- Instantiation of the determinant criterion for two directional
ME-036/037-style probes. -/
theorem directional_twoProbe_identifiable
    {GradS GradO : Type*}
    (B_SO : GradS → GradO → ℝ)
    (B_OS : GradO → GradS → ℝ)
    (s₁ s₂ : GradS) (o₁ o₂ : GradO)
    (α β α' β' : ℝ)
    (hdet :
      B_SO s₁ o₁ * B_OS o₂ s₂ -
        B_SO s₂ o₂ * B_OS o₁ s₁ ≠ 0)
    (h₁ :
      directionalCoupling B_SO B_OS α β s₁ o₁ =
        directionalCoupling B_SO B_OS α' β' s₁ o₁)
    (h₂ :
      directionalCoupling B_SO B_OS α β s₂ o₂ =
        directionalCoupling B_SO B_OS α' β' s₂ o₂) :
    α = α' ∧ β = β' := by
  apply twoProbe_identifiability
      (B_SO s₁ o₁) (B_OS o₁ s₁)
      (B_SO s₂ o₂) (B_OS o₂ s₂)
      α β α' β' hdet
  · simpa [directionalCoupling] using h₁
  · simpa [directionalCoupling] using h₂

/-- Pointwise RHS shell for the ME-036 system equation.
Non-coupling terms are kept abstract so this theorem does not pretend that
the PDE layer has already been specified. -/
def systemRHSOriginal {V : Type*}
    (pair : V → V → ℝ) (α β : ℝ) (gradS gradO : V)
    (lapS reactionS pressureS forcingS : ℝ) : ℝ :=
  lapS + originalCoupling pair α β gradS gradO
    - reactionS - pressureS + forcingS

/-- Pointwise RHS shell after the conservative single-κ repair. -/
def systemRHSRepaired {V : Type*}
    (pair : V → V → ℝ) (κ : ℝ) (gradS gradO : V)
    (lapS reactionS pressureS forcingS : ℝ) : ℝ :=
  lapS + symmetricCoupling pair κ gradS gradO
    - reactionS - pressureS + forcingS

/-- The conservative repaired ME-036 RHS is pointwise identical to the
original RHS whenever the gradient pairing is symmetric and `κ = α + β`. -/
theorem ME036_pointwise_repair_equiv {V : Type*}
    (pair : V → V → ℝ) (α β : ℝ) (gradS gradO : V)
    (lapS reactionS pressureS forcingS : ℝ)
    (hSymm : ∀ x y, pair x y = pair y x) :
    systemRHSOriginal pair α β gradS gradO
        lapS reactionS pressureS forcingS =
      systemRHSRepaired pair (α + β) gradS gradO
        lapS reactionS pressureS forcingS := by
  rw [systemRHSOriginal, systemRHSRepaired,
      original_eq_symmetricRepair pair α β gradS gradO hSymm]

/-- ME-037 has the same pointwise repair after exchanging observer/system
gradient order. -/
theorem ME037_pointwise_repair_equiv {V : Type*}
    (pair : V → V → ℝ) (α β : ℝ) (gradO gradS : V)
    (lapO reactionO pressureO forcingO : ℝ)
    (hSymm : ∀ x y, pair x y = pair y x) :
    systemRHSOriginal pair α β gradO gradS
        lapO reactionO pressureO forcingO =
      systemRHSRepaired pair (α + β) gradO gradS
        lapO reactionO pressureO forcingO := by
  rw [systemRHSOriginal, systemRHSRepaired,
      original_eq_symmetricRepair pair α β gradO gradS hSymm]

end ME036_037Repair
end Monolithic102
