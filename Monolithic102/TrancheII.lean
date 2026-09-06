import Mathlib
import Monolithic102.Formalized

/-!
# Tranche II — forensic source reconstruction

The original Git object for this tranche is unavailable.  Definitions and
exact theorem names are reconstructed from the retained Tranche II formal
paper.  Proof bodies are recovery proofs and require the pinned clean-build
CI gate before this source is counted as reverified.
-/

namespace Monolithic102

namespace ME047

theorem coherenceDenominator_pos (x m epsilon : ℝ)
    (hEps : 0 < epsilon) :
    0 < |x| + |m| + epsilon := by
  positivity

theorem recursiveCoherence_le_one (x m epsilon : ℝ)
    (hEps : 0 < epsilon) :
    recursiveCoherence x m epsilon ≤ 1 := by
  have hDen : 0 < |x| + |m| + epsilon :=
    coherenceDenominator_pos x m epsilon hEps
  have hDiv : 0 ≤ |x - m| / (|x| + |m| + epsilon) :=
    div_nonneg (abs_nonneg _) hDen.le
  unfold recursiveCoherence
  linarith

theorem recursiveCoherence_pos (x m epsilon : ℝ)
    (hEps : 0 < epsilon) :
    0 < recursiveCoherence x m epsilon := by
  have hDen : 0 < |x| + |m| + epsilon :=
    coherenceDenominator_pos x m epsilon hEps
  have hTri : |x - m| ≤ |x| + |m| := by
    simpa [sub_eq_add_neg] using (abs_add x (-m))
  have hNum : |x - m| < |x| + |m| + epsilon := by
    linarith
  have hDiv : |x - m| / (|x| + |m| + epsilon) < 1 :=
    (div_lt_one hDen).2 hNum
  unfold recursiveCoherence
  linarith

theorem recursiveCoherence_eq_one_iff (x m epsilon : ℝ)
    (hEps : 0 < epsilon) :
    recursiveCoherence x m epsilon = 1 ↔ x = m := by
  have hDen : 0 < |x| + |m| + epsilon :=
    coherenceDenominator_pos x m epsilon hEps
  constructor
  · intro h
    have hQ : |x - m| / (|x| + |m| + epsilon) = 0 := by
      unfold recursiveCoherence at h
      linarith
    have hNum : |x - m| = 0 := by
      rcases (div_eq_zero_iff.mp hQ) with h | h
      · exact h
      · exact False.elim (hDen.ne' h)
    exact sub_eq_zero.mp (abs_eq_zero.mp hNum)
  · intro h
    subst m
    simp [recursiveCoherence]

end ME047

namespace ME066

open TensorProduct

structure DyadComponents (V : Type*) [AddCommGroup V] [Module ℝ V] where
  human : V
  ai : V
  coupling : TensorProduct ℝ V V

def typedDyad {V : Type*} [AddCommGroup V] [Module ℝ V]
    (lambda : ℝ) (human ai : V) : DyadComponents V :=
  { human := human
    ai := ai
    coupling := lambda • (human ⊗ₜ[ℝ] ai) }

theorem typedDyad_human {V : Type*} [AddCommGroup V] [Module ℝ V]
    (lambda : ℝ) (human ai : V) :
    (typedDyad lambda human ai).human = human := by
  rfl

theorem typedDyad_ai {V : Type*} [AddCommGroup V] [Module ℝ V]
    (lambda : ℝ) (human ai : V) :
    (typedDyad lambda human ai).ai = ai := by
  rfl

theorem typedDyad_coupling {V : Type*} [AddCommGroup V] [Module ℝ V]
    (lambda : ℝ) (human ai : V) :
    (typedDyad lambda human ai).coupling =
      lambda • (human ⊗ₜ[ℝ] ai) := by
  rfl

theorem typedDyad_zero_gain {V : Type*} [AddCommGroup V] [Module ℝ V]
    (human ai : V) :
    (typedDyad 0 human ai).coupling = 0 := by
  simp [typedDyad]

theorem typedDyad_zero_human {V : Type*} [AddCommGroup V] [Module ℝ V]
    (lambda : ℝ) (ai : V) :
    (typedDyad lambda 0 ai).coupling = 0 := by
  simp [typedDyad]

theorem typedDyad_zero_ai {V : Type*} [AddCommGroup V] [Module ℝ V]
    (lambda : ℝ) (human : V) :
    (typedDyad lambda human 0).coupling = 0 := by
  simp [typedDyad]

theorem typedDyad_eq_iff {V : Type*} [AddCommGroup V] [Module ℝ V]
    (lambda lambda' : ℝ) (human human' ai ai' : V) :
    typedDyad lambda human ai = typedDyad lambda' human' ai' ↔
      human = human' ∧ ai = ai' ∧
      lambda • (human ⊗ₜ[ℝ] ai) =
        lambda' • (human' ⊗ₜ[ℝ] ai') := by
  constructor
  · intro h
    exact ⟨congrArg DyadComponents.human h,
      congrArg DyadComponents.ai h,
      congrArg DyadComponents.coupling h⟩
  · rintro ⟨hHuman, hAI, hCoupling⟩
    subst human'
    subst ai'
    apply DyadComponents.ext
    · rfl
    · rfl
    · simpa [typedDyad] using hCoupling

end ME066

namespace ME078

theorem thixotropicViscosity_initial (eta0 tau : ℝ) :
    thixotropicViscosity eta0 0 tau = 0 := by
  simp [thixotropicViscosity]

theorem thixotropicViscosity_gap (eta0 t tau : ℝ) :
    eta0 - thixotropicViscosity eta0 t tau =
      eta0 * Real.exp (-t / tau) := by
  unfold thixotropicViscosity
  ring

theorem thixotropicViscosity_rate_eq_relaxationRHS
    (eta0 t tau : ℝ) :
    (eta0 / tau) * Real.exp (-t / tau) =
      ME082.thixotropicRelaxationRHS eta0
        (thixotropicViscosity eta0 t tau) tau := by
  rw [ME082.thixotropicRelaxationRHS, thixotropicViscosity_gap]
  ring

theorem thixotropicViscosity_hasDerivAt
    (eta0 t tau : ℝ) :
    HasDerivAt (fun s : ℝ => thixotropicViscosity eta0 s tau)
      (ME082.thixotropicRelaxationRHS eta0
        (thixotropicViscosity eta0 t tau) tau) t := by
  have hInner : HasDerivAt (fun s : ℝ => -s / tau) (-1 / tau) t := by
    convert (hasDerivAt_id t).neg.div_const tau using 1 <;> ring
  have hExp : HasDerivAt (fun s : ℝ => Real.exp (-s / tau))
      (Real.exp (-t / tau) * (-1 / tau)) t :=
    (Real.hasDerivAt_exp (-t / tau)).comp t hInner
  have hOneSub : HasDerivAt (fun s : ℝ => 1 - Real.exp (-s / tau))
      (0 - Real.exp (-t / tau) * (-1 / tau)) t :=
    (hasDerivAt_const t 1).sub hExp
  have hRaw : HasDerivAt (fun s : ℝ => thixotropicViscosity eta0 s tau)
      ((eta0 / tau) * Real.exp (-t / tau)) t := by
    have hMul := hOneSub.const_mul eta0
    convert hMul using 1 <;> simp [thixotropicViscosity] <;> ring
  rw [thixotropicViscosity_rate_eq_relaxationRHS eta0 t tau] at hRaw
  exact hRaw

end ME078

namespace ME082

theorem equilibrium_is_fixed (etaEq tau : ℝ) :
    thixotropicRelaxationRHS etaEq etaEq tau = 0 := by
  simp [thixotropicRelaxationRHS]

theorem relaxation_positive_below_equilibrium
    (etaEq eta tau : ℝ)
    (hEta : eta < etaEq) (hTau : 0 < tau) :
    0 < thixotropicRelaxationRHS etaEq eta tau := by
  unfold thixotropicRelaxationRHS
  exact div_pos (sub_pos.mpr hEta) hTau

theorem relaxation_negative_above_equilibrium
    (etaEq eta tau : ℝ)
    (hEta : etaEq < eta) (hTau : 0 < tau) :
    thixotropicRelaxationRHS etaEq eta tau < 0 := by
  unfold thixotropicRelaxationRHS
  exact div_neg_of_neg_of_pos (sub_neg.mpr hEta) hTau

end ME082

end Monolithic102
