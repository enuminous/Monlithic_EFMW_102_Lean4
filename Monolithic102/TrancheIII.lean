import Mathlib
import Monolithic102.TrancheI
import Monolithic102.TrancheII

/-!
# Tranche III — forensic source reconstruction

The retained Tranche III paper was a frozen prospective docket.  A later
Tranche IV inventory records ten checked declarations from this tranche, but
the original compiled Git object is unavailable.  The ten recorded target
names are reconstructed here with proof statements faithful to the frozen
mathematical claims.  These are recovery proofs and are not reverified until
the pinned CI gate accepts them.
-/

namespace Monolithic102

namespace ME036

theorem crossGradientCollapse {V : Type*}
    (dot : V → V → ℝ) (alpha beta : ℝ) (gradS gradO : V)
    (hSymm : ∀ x y, dot x y = dot y x) :
    crossGradientCoupling dot alpha beta gradS gradO =
      (alpha + beta) * dot gradS gradO :=
  crossGradientCoupling_collapse dot alpha beta gradS gradO hSymm

end ME036

namespace ME037

theorem effectiveCoefficientAgreement {V : Type*}
    (dot : V → V → ℝ) (alpha beta : ℝ) (gradS gradO : V)
    (hSymm : ∀ x y, dot x y = dot y x) :
    ME036.crossGradientCoupling dot alpha beta gradS gradO =
      observerCrossGradientCoupling dot alpha beta gradO gradS :=
  system_observer_effectiveCoefficient_agree dot alpha beta gradS gradO hSymm

end ME037

namespace ME096

theorem summableIncrements_convergent
    {E : Type*} [NormedAddCommGroup E] [CompleteSpace E]
    (x : Nat → E)
    (hSummable : Summable (fun n => ‖x (n + 1) - x n‖)) :
    ∃ limit : E, Tendsto x atTop (nhds limit) := by
  let d : Nat → E := fun n => x (n + 1) - x n
  have hd : Summable d := by
    apply Summable.of_norm
    simpa [d] using hSummable
  have hTel : ∀ n : Nat,
      x n = x 0 + ∑ k in Finset.range n, d k := by
    intro n
    induction n with
    | zero => simp
    | succ n ih =>
        rw [Finset.sum_range_succ, ← ih]
        simp [d]
  have hSeries :
      Tendsto (fun n => ∑ k in Finset.range n, d k)
        atTop (nhds (∑' k, d k)) :=
    hd.hasSum.tendsto_sum_nat
  have hShift :
      Tendsto (fun n => x 0 + ∑ k in Finset.range n, d k)
        atTop (nhds (x 0 + ∑' k, d k)) :=
    tendsto_const_nhds.add hSeries
  refine ⟨x 0 + ∑' k, d k, ?_⟩
  exact Tendsto.congr'
    (Filter.Eventually.of_forall fun n => (hTel n).symm) hShift

end ME096

namespace ME101

def affineTrajectory (a b x0 : ℝ) : Nat → ℝ
  | 0 => x0
  | n + 1 => a * affineTrajectory a b x0 n + b

theorem affineClosedForm (a b x0 : ℝ) (ha : a ≠ 1) (n : Nat) :
    affineTrajectory a b x0 n =
      a ^ n * x0 + b * ((a ^ n - 1) / (a - 1)) := by
  induction n with
  | zero => simp [affineTrajectory, ha]
  | succ n ih =>
      rw [affineTrajectory, ih, pow_succ]
      field_simp [ha]
      ring

theorem positiveGainDiverges (a b x0 : ℝ)
    (ha : 1 < a)
    (hCoeff : 0 < x0 + b / (a - 1)) :
    Tendsto (affineTrajectory a b x0) atTop atTop := by
  have hane : a ≠ 1 := ne_of_gt ha
  have hPow : Tendsto (fun n : Nat => a ^ n) atTop atTop :=
    tendsto_pow_atTop_atTop_of_one_lt ha
  have hMul :
      Tendsto (fun n : Nat => a ^ n * (x0 + b / (a - 1))) atTop atTop :=
    hPow.atTop_mul_const hCoeff
  have hSub :
      Tendsto (fun n : Nat =>
        a ^ n * (x0 + b / (a - 1)) - b / (a - 1)) atTop atTop :=
    tendsto_atTop_add_const_right atTop (-b / (a - 1)) hMul
  apply Tendsto.congr' ?_ hSub
  filter_upwards [] with n
  rw [affineClosedForm a b x0 hane n]
  field_simp [hane]
  ring

end ME101

namespace ME082

noncomputable def relaxationSolution
    (etaEq eta0 tau t : ℝ) : ℝ :=
  etaEq + (eta0 - etaEq) * Real.exp (-t / tau)

theorem constantEquilibrium_solution
    (etaEq eta0 tau t : ℝ) (hTau : 0 < tau) :
    relaxationSolution etaEq eta0 tau 0 = eta0 ∧
    HasDerivAt (fun s : ℝ => relaxationSolution etaEq eta0 tau s)
      (thixotropicRelaxationRHS etaEq
        (relaxationSolution etaEq eta0 tau t) tau) t := by
  constructor
  · simp [relaxationSolution]
  · have hInner : HasDerivAt (fun s : ℝ => -s / tau) (-1 / tau) t := by
      convert (hasDerivAt_id t).neg.div_const tau using 1 <;> ring
    have hExp : HasDerivAt (fun s : ℝ => Real.exp (-s / tau))
        (Real.exp (-t / tau) * (-1 / tau)) t :=
      (Real.hasDerivAt_exp (-t / tau)).comp t hInner
    have hScaled : HasDerivAt
        (fun s : ℝ => (eta0 - etaEq) * Real.exp (-s / tau))
        ((eta0 - etaEq) * (Real.exp (-t / tau) * (-1 / tau))) t :=
      hExp.const_mul (eta0 - etaEq)
    have hRaw : HasDerivAt
        (fun s : ℝ => relaxationSolution etaEq eta0 tau s)
        ((eta0 - etaEq) * (Real.exp (-t / tau) * (-1 / tau))) t := by
      simpa [relaxationSolution] using hScaled.const_add etaEq
    convert hRaw using 1
    unfold thixotropicRelaxationRHS relaxationSolution
    field_simp [ne_of_gt hTau]
    ring

end ME082

namespace ME078

theorem zeroInitial_specialization (etaBar tau t : ℝ) :
    ME082.relaxationSolution etaBar 0 tau t =
      thixotropicViscosity etaBar t tau := by
  unfold ME082.relaxationSolution thixotropicViscosity
  ring

end ME078

namespace ME066

noncomputable def directSumNorm
    {S O : Type*} [NormedAddCommGroup S] [NormedAddCommGroup O]
    (x : S × O) : ℝ :=
  Real.sqrt (‖x.1‖ ^ 2 + ‖x.2‖ ^ 2)

def embedS
    {S O : Type*} [NormedAddCommGroup S] [NormedAddCommGroup O]
    (s : S) : S × O := (s, 0)

def embedO
    {S O : Type*} [NormedAddCommGroup S] [NormedAddCommGroup O]
    (o : O) : S × O := (0, o)

theorem embedS_isometry
    {S O : Type*} [NormedAddCommGroup S] [NormedAddCommGroup O]
    (s : S) :
    directSumNorm (embedS (O := O) s) = ‖s‖ := by
  simp [directSumNorm, embedS, Real.sqrt_sq_eq_abs, abs_of_nonneg (norm_nonneg s)]

theorem embedO_isometry
    {S O : Type*} [NormedAddCommGroup S] [NormedAddCommGroup O]
    (o : O) :
    directSumNorm (embedO (S := S) o) = ‖o‖ := by
  simp [directSumNorm, embedO, Real.sqrt_sq_eq_abs, abs_of_nonneg (norm_nonneg o)]

theorem directSumNormSq
    {S O : Type*} [NormedAddCommGroup S] [NormedAddCommGroup O]
    (s : S) (o : O) :
    directSumNorm (s, o) ^ 2 = ‖s‖ ^ 2 + ‖o‖ ^ 2 := by
  unfold directSumNorm
  rw [Real.sq_sqrt]
  positivity

end ME066

end Monolithic102
