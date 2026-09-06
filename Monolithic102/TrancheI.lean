import Mathlib
import Monolithic102.Formalized

/-!
# Tranche I — forensic source reconstruction

The original Git object for this tranche is no longer addressable.  The theorem
names and signatures below are reconstructed from the retained formal
verification paper.  Proof bodies are new recovery proofs of those recorded
statements and must pass the pinned Lean gate before this file is treated as a
reverified replacement.
-/

namespace Monolithic102

namespace ME036

def crossGradientCoupling {V : Type*}
    (dot : V → V → ℝ) (alpha beta : ℝ) (gradS gradO : V) : ℝ :=
  alpha * dot gradS gradO + beta * dot gradO gradS

theorem crossGradientCoupling_collapse {V : Type*}
    (dot : V → V → ℝ) (alpha beta : ℝ) (gradS gradO : V)
    (hSymm : ∀ x y, dot x y = dot y x) :
    crossGradientCoupling dot alpha beta gradS gradO =
      (alpha + beta) * dot gradS gradO := by
  simp [crossGradientCoupling, hSymm gradO gradS]
  ring

theorem crossGradientCoupling_nonidentifiable {V : Type*}
    (dot : V → V → ℝ) (alpha beta alpha' beta' : ℝ) (gradS gradO : V)
    (hSymm : ∀ x y, dot x y = dot y x)
    (hSum : alpha + beta = alpha' + beta') :
    crossGradientCoupling dot alpha beta gradS gradO =
      crossGradientCoupling dot alpha' beta' gradS gradO := by
  rw [crossGradientCoupling_collapse dot alpha beta gradS gradO hSymm,
      crossGradientCoupling_collapse dot alpha' beta' gradS gradO hSymm,
      hSum]

end ME036

namespace ME037

def observerCrossGradientCoupling {V : Type*}
    (dot : V → V → ℝ) (alpha beta : ℝ) (gradO gradS : V) : ℝ :=
  alpha * dot gradO gradS + beta * dot gradS gradO

theorem observerCrossGradientCoupling_collapse {V : Type*}
    (dot : V → V → ℝ) (alpha beta : ℝ) (gradO gradS : V)
    (hSymm : ∀ x y, dot x y = dot y x) :
    observerCrossGradientCoupling dot alpha beta gradO gradS =
      (alpha + beta) * dot gradO gradS := by
  simp [observerCrossGradientCoupling, hSymm gradS gradO]
  ring

theorem system_observer_effectiveCoefficient_agree {V : Type*}
    (dot : V → V → ℝ) (alpha beta : ℝ) (gradS gradO : V)
    (hSymm : ∀ x y, dot x y = dot y x) :
    ME036.crossGradientCoupling dot alpha beta gradS gradO =
      observerCrossGradientCoupling dot alpha beta gradO gradS := by
  rw [ME036.crossGradientCoupling_collapse dot alpha beta gradS gradO hSymm,
      observerCrossGradientCoupling_collapse dot alpha beta gradO gradS hSymm]
  rw [hSymm gradO gradS]

end ME037

namespace ME088

noncomputable def rebirth (nullOperator : ℝ → ℝ) (x : ℝ) : ℝ :=
  ME041.phi ^ (23 : Nat) * nullOperator x

theorem null_rebirth_no_go
    (nullOperator : ℝ → ℝ) (x : ℝ)
    (hNull : nullOperator x = 0) :
    rebirth nullOperator x = 0 := by
  simp [rebirth, hNull]

end ME088

namespace ME096

noncomputable def harmonicTrajectory (n : Nat) : ℝ :=
  ∑ k in Finset.range n, 1 / ((k : ℝ) + 1)

theorem harmonicTrajectory_increment (n : Nat) :
    harmonicTrajectory (n + 1) - harmonicTrajectory n =
      1 / ((n : ℝ) + 1) := by
  simp [harmonicTrajectory, Finset.sum_range_succ]

theorem harmonicTrajectory_increments_tend_to_zero :
    Tendsto (fun n => abs (harmonicTrajectory (n + 1) - harmonicTrajectory n))
      atTop (nhds 0) := by
  have hfun :
      (fun n => abs (harmonicTrajectory (n + 1) - harmonicTrajectory n)) =
        (fun n : Nat => 1 / ((n : ℝ) + 1)) := by
    funext n
    rw [harmonicTrajectory_increment]
    rw [abs_of_pos]
    positivity
  rw [hfun]
  exact tendsto_one_div_add_atTop_nhds_zero_nat

theorem harmonicTrajectory_not_convergent :
    ¬ ∃ limit : ℝ, Tendsto harmonicTrajectory atTop (nhds limit) := by
  have hTop : Tendsto harmonicTrajectory atTop atTop := by
    simpa [harmonicTrajectory, Nat.cast_add, Nat.cast_one] using
      Real.tendsto_sum_range_one_div_nat_succ_atTop
  rintro ⟨limit, hlim⟩
  exact not_tendsto_atTop_of_tendsto_nhds hlim hTop

theorem vanishing_increments_do_not_imply_convergence :
    ∃ trajectory : Nat → ℝ,
      Tendsto (fun n => abs (trajectory (n + 1) - trajectory n)) atTop (nhds 0) ∧
      ¬ ∃ limit : ℝ, Tendsto trajectory atTop (nhds limit) := by
  exact ⟨harmonicTrajectory,
    harmonicTrajectory_increments_tend_to_zero,
    harmonicTrajectory_not_convergent⟩

end ME096

namespace ME101

def identityTrajectory (initial lambda coherence : ℝ) : Nat → ℝ
  | 0 => initial
  | n + 1 => identityTrajectory initial lambda coherence n + lambda * coherence

theorem identityTrajectory_closedForm
    (initial lambda coherence : ℝ) (n : Nat) :
    identityTrajectory initial lambda coherence n =
      initial + (n : ℝ) * (lambda * coherence) := by
  induction n with
  | zero => simp [identityTrajectory]
  | succ n ih =>
      rw [identityTrajectory, ih]
      push_cast
      ring

theorem identityTrajectory_strictMono
    (initial lambda coherence : ℝ)
    (hGain : 0 < lambda * coherence) :
    StrictMono (identityTrajectory initial lambda coherence) := by
  refine strictMono_nat_of_lt_succ fun n => ?_
  rw [identityTrajectory_closedForm, identityTrajectory_closedForm]
  push_cast
  linarith

theorem identityTrajectory_tendsto_atTop
    (initial lambda coherence : ℝ)
    (hGain : 0 < lambda * coherence) :
    Tendsto (identityTrajectory initial lambda coherence) atTop atTop := by
  have hmul : Tendsto (fun n : Nat => (n : ℝ) * (lambda * coherence)) atTop atTop :=
    tendsto_natCast_atTop_atTop.atTop_mul_const hGain
  have hadd : Tendsto (fun n : Nat => initial + (n : ℝ) * (lambda * coherence)) atTop atTop :=
    tendsto_atTop_add_const_left atTop initial hmul
  exact hadd.congr' (Filter.Eventually.of_forall fun n =>
    (identityTrajectory_closedForm initial lambda coherence n).symm)

end ME101

end Monolithic102
