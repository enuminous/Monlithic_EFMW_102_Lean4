import Mathlib
import Monolithic102.TrancheIII

/-!
# Tranche IV — recovered physical-test development

The measurement/falsification development in this file is adapted directly
from the retained September 5 Lean source.  The original source imported an
external RequestProject namespace that is no longer part of this repository;
the final Tranche IV paper records three connective lemmas that made the
Monolithic102 version self-contained.  Those bridges are included here:
`ME002_005.phaseSpeed_satisfies_homogeneous_relation`,
`ME002_005.phaseSpeed_unique_nonneg`, and `ME056.friedmann_deviation`.

As in the historical paper, these are conditional mathematical consequences,
not observations or proof that the source equations describe nature.
-/

namespace Monolithic102

open Real Filter Topology

structure Measurement where
  observable : ℝ → ℝ
  reading : ℝ
  precision : ℝ

def Measurement.Compatible (m : Measurement) (theta : ℝ) : Prop :=
  |m.observable theta - m.reading| ≤ m.precision

def Measurement.StrictlyCompatible (m : Measurement) (theta : ℝ) : Prop :=
  |m.observable theta - m.reading| < m.precision

theorem Measurement.Compatible_of_strict {m : Measurement} {theta : ℝ}
    (h : m.StrictlyCompatible theta) : m.Compatible theta := le_of_lt h

def DataCompatible (D : List Measurement) (theta : ℝ) : Prop :=
  ∀ m ∈ D, m.Compatible theta

def DataStrictlyCompatible (D : List Measurement) (theta : ℝ) : Prop :=
  ∀ m ∈ D, m.StrictlyCompatible theta

theorem eventually_strictlyCompatible {D : List Measurement} {theta0 : ℝ}
    (hcont : ∀ m ∈ D, ContinuousAt m.observable theta0)
    (hD : DataStrictlyCompatible D theta0) :
    ∀ᶠ theta in nhds theta0, DataStrictlyCompatible D theta := by
  induction D with
  | nil => filter_upwards with theta; intro m hm; simp at hm
  | cons m D ih =>
      have hm : ∀ᶠ theta in nhds theta0, m.StrictlyCompatible theta := by
        have hc : ContinuousAt (fun theta => |m.observable theta - m.reading|) theta0 :=
          ((hcont m (by simp)).sub continuousAt_const).abs
        exact hc.eventually_lt_const (hD m (by simp))
      have hrest : ∀ᶠ theta in nhds theta0, DataStrictlyCompatible D theta :=
        ih (fun m' hm' => hcont m' (by simp [hm']))
          (fun m' hm' => hD m' (by simp [hm']))
      filter_upwards [hm, hrest] with theta h1 h2
      intro m' hm'
      rcases List.mem_cons.mp hm' with rfl | hmem
      · exact h1
      · exact h2 m' hmem

theorem no_exact_parameter_verification {D : List Measurement} {theta0 : ℝ}
    (hcont : ∀ m ∈ D, ContinuousAt m.observable theta0)
    (hD : DataStrictlyCompatible D theta0) :
    ∃ theta, theta ≠ theta0 ∧ DataCompatible D theta := by
  have h : ∀ᶠ theta in nhdsWithin theta0 {theta0}ᶜ, DataStrictlyCompatible D theta :=
    (eventually_strictlyCompatible hcont hD).filter_mono nhdsWithin_le_nhds
  obtain ⟨theta, htheta, hne⟩ := (h.and self_mem_nhdsWithin).exists
  exact ⟨theta, hne, fun m hm => (htheta m hm).le⟩

theorem measurement_discriminates (m : Measurement) {theta1 theta2 : ℝ}
    (h : 2 * m.precision < |m.observable theta1 - m.observable theta2|) :
    ¬ (m.Compatible theta1 ∧ m.Compatible theta2) := by
  rintro ⟨h1, h2⟩
  simp only [Measurement.Compatible] at h1 h2
  have htri : |m.observable theta1 - m.observable theta2|
      ≤ |m.observable theta1 - m.reading| + |m.observable theta2 - m.reading| := by
    have heq : m.observable theta1 - m.observable theta2 =
        (m.observable theta1 - m.reading) - (m.observable theta2 - m.reading) := by
      ring
    rw [heq]
    exact abs_sub _ _
  linarith

theorem falsification_by_measurement :
    ¬ (Measurement.Compatible ⟨fun theta => theta, 0, 1⟩ 5) := by
  norm_num [Measurement.Compatible]

noncomputable def phaseSpeed (c alpha : ℝ) : ℝ :=
  c / Real.sqrt (1 - alpha ^ 2)

@[simp] theorem phaseSpeed_zero (c : ℝ) : phaseSpeed c 0 = c := by
  simp [phaseSpeed]

theorem sqrt_one_sub_sq_pos {alpha : ℝ} (h : alpha ^ 2 < 1) :
    0 < Real.sqrt (1 - alpha ^ 2) :=
  Real.sqrt_pos.mpr (by linarith)

theorem sqrt_one_sub_sq_le_one {alpha : ℝ} :
    Real.sqrt (1 - alpha ^ 2) ≤ 1 := by
  have h : Real.sqrt (1 - alpha ^ 2) ≤ Real.sqrt 1 :=
    Real.sqrt_le_sqrt (by nlinarith [sq_nonneg alpha])
  simpa using h

namespace ME002_005

def homogeneousPhaseRelation (c alpha v : ℝ) : Prop :=
  (1 - alpha ^ 2) * v ^ 2 = c ^ 2

theorem phaseSpeed_satisfies_homogeneous_relation
    {c alpha : ℝ} (h : alpha ^ 2 < 1) :
    homogeneousPhaseRelation c alpha (phaseSpeed c alpha) := by
  have hs : 0 < Real.sqrt (1 - alpha ^ 2) := sqrt_one_sub_sq_pos h
  have hsne : Real.sqrt (1 - alpha ^ 2) ≠ 0 := ne_of_gt hs
  have hsq : Real.sqrt (1 - alpha ^ 2) ^ 2 = 1 - alpha ^ 2 :=
    Real.sq_sqrt (by linarith)
  unfold homogeneousPhaseRelation phaseSpeed
  field_simp [hsne]
  nlinarith

theorem phaseSpeed_unique_nonneg
    {c alpha v : ℝ} (hc : 0 ≤ c) (hv : 0 ≤ v)
    (h : alpha ^ 2 < 1)
    (hrel : homogeneousPhaseRelation c alpha v) :
    v = phaseSpeed c alpha := by
  have hs : 0 < Real.sqrt (1 - alpha ^ 2) := sqrt_one_sub_sq_pos h
  have hsne : Real.sqrt (1 - alpha ^ 2) ≠ 0 := ne_of_gt hs
  have hsq : Real.sqrt (1 - alpha ^ 2) ^ 2 = 1 - alpha ^ 2 :=
    Real.sq_sqrt (by linarith)
  have hsqeq :
      (Real.sqrt (1 - alpha ^ 2) * v) ^ 2 = c ^ 2 := by
    unfold homogeneousPhaseRelation at hrel
    nlinarith [hsq]
  have hprod : Real.sqrt (1 - alpha ^ 2) * v = c := by
    rcases sq_eq_sq_iff_eq_or_eq_neg.mp hsqeq with heq | hneg
    · exact heq
    · have hp : 0 ≤ Real.sqrt (1 - alpha ^ 2) * v := mul_nonneg hs.le hv
      linarith
  unfold phaseSpeed
  exact (eq_div_iff hsne).2 hprod

end ME002_005

theorem le_phaseSpeed {c alpha : ℝ} (hc : 0 < c) (h : alpha ^ 2 < 1) :
    c ≤ phaseSpeed c alpha := by
  have hs := sqrt_one_sub_sq_pos h
  rw [phaseSpeed, le_div_iff₀ hs]
  nlinarith [sqrt_one_sub_sq_le_one (alpha := alpha)]

theorem lt_phaseSpeed {c alpha : ℝ} (hc : 0 < c)
    (h : alpha ^ 2 < 1) (hne : alpha ≠ 0) :
    c < phaseSpeed c alpha := by
  have hs := sqrt_one_sub_sq_pos h
  have hlt : Real.sqrt (1 - alpha ^ 2) < 1 := by
    have hpos : 0 < alpha ^ 2 := by positivity
    have hsq : Real.sqrt (1 - alpha ^ 2) ^ 2 = 1 - alpha ^ 2 :=
      Real.sq_sqrt (by linarith)
    nlinarith [sqrt_one_sub_sq_le_one (alpha := alpha)]
  rw [phaseSpeed, lt_div_iff₀ hs]
  nlinarith

theorem alpha_sq_le_of_speed_measurement {c alpha p : ℝ}
    (hc : 0 < c) (h1 : alpha ^ 2 < 1)
    (h : |phaseSpeed c alpha - c| ≤ p) :
    alpha ^ 2 * (c + p) ^ 2 ≤ p ^ 2 + 2 * p * c := by
  have hs := sqrt_one_sub_sq_pos h1
  have hsq : Real.sqrt (1 - alpha ^ 2) ^ 2 = 1 - alpha ^ 2 :=
    Real.sq_sqrt (by linarith)
  have hge : c ≤ phaseSpeed c alpha := le_phaseSpeed hc h1
  have hp : phaseSpeed c alpha - c ≤ p := (abs_le.mp h).2
  have hp0 : 0 ≤ p := by linarith
  have hkey : c ≤ (c + p) * Real.sqrt (1 - alpha ^ 2) := by
    have hupper : phaseSpeed c alpha ≤ c + p := by linarith
    rw [phaseSpeed, div_le_iff₀ hs] at hupper
    linarith [hupper]
  nlinarith [hkey, hsq, hs, mul_pos hc hs]

theorem alpha_eq_zero_of_exact_lightspeed {c alpha : ℝ}
    (hc : 0 < c) (h1 : alpha ^ 2 < 1)
    (h : phaseSpeed c alpha = c) : alpha = 0 := by
  by_contra hne
  exact (lt_phaseSpeed hc h1 hne).ne' h

theorem phaseSpeed_gap {c eps alpha : ℝ}
    (hc : 0 < c) (heps : 0 < eps)
    (h1 : alpha ^ 2 < 1) (hle : eps ≤ |alpha|) :
    phaseSpeed c eps - c ≤ phaseSpeed c alpha - c := by
  have habs : |alpha| ^ 2 = alpha ^ 2 := sq_abs alpha
  have heps1 : eps ^ 2 < 1 := by nlinarith [abs_nonneg alpha]
  have hs1 := sqrt_one_sub_sq_pos heps1
  have hs2 := sqrt_one_sub_sq_pos h1
  have hmono : Real.sqrt (1 - alpha ^ 2) ≤ Real.sqrt (1 - eps ^ 2) :=
    Real.sqrt_le_sqrt (by nlinarith [abs_nonneg alpha])
  have hdiv : c / Real.sqrt (1 - eps ^ 2) ≤
      c / Real.sqrt (1 - alpha ^ 2) :=
    div_le_div_of_nonneg_left hc.le hs2 hmono
  simp only [phaseSpeed]
  linarith

theorem speed_experiment_discriminates
    {c eps alpha p r : ℝ} (hc : 0 < c) (heps : 0 < eps)
    (h1 : alpha ^ 2 < 1) (hle : eps ≤ |alpha|)
    (hp : 2 * p < phaseSpeed c eps - c) :
    ¬ ((Measurement.mk (phaseSpeed c) r p).Compatible 0 ∧
       (Measurement.mk (phaseSpeed c) r p).Compatible alpha) := by
  refine measurement_discriminates _ ?_
  have hgap : phaseSpeed c eps - c ≤ phaseSpeed c alpha - c :=
    phaseSpeed_gap hc heps h1 hle
  have hb : |phaseSpeed c 0 - phaseSpeed c alpha| =
      phaseSpeed c alpha - c := by
    rw [phaseSpeed_zero, abs_sub_comm, abs_of_nonneg]
    linarith [le_phaseSpeed hc h1]
  rw [hb]
  linarith

theorem decisive_precision_exists {c eps alpha : ℝ}
    (hc : 0 < c) (heps : 0 < eps)
    (heps1 : eps ^ 2 < 1) (h1 : alpha ^ 2 < 1)
    (hle : eps ≤ |alpha|) :
    ∃ p > 0, ∀ r : ℝ,
      ¬ ((Measurement.mk (phaseSpeed c) r p).Compatible 0 ∧
         (Measurement.mk (phaseSpeed c) r p).Compatible alpha) := by
  have hgap : 0 < phaseSpeed c eps - c := by
    have hne : eps ≠ 0 := ne_of_gt heps
    linarith [lt_phaseSpeed hc heps1 hne]
  refine ⟨(phaseSpeed c eps - c) / 4, by positivity, fun r => ?_⟩
  exact speed_experiment_discriminates hc heps h1 hle (by linarith)

namespace ME056

noncomputable def friedmannLCDM
    (Gnewton rho Lam k a : ℝ) : ℝ :=
  (8 * Real.pi * Gnewton / 3) * rho + Lam / 3 - k / a ^ 2

noncomputable def friedmannEFMW
    (Gnewton rho Lam k a OmegaU : ℝ) : ℝ :=
  friedmannLCDM Gnewton rho Lam k a + OmegaU ^ 2 / a ^ 2

theorem friedmann_deviation
    (Gnewton rho Lam k a OmegaU : ℝ) :
    friedmannEFMW Gnewton rho Lam k a OmegaU -
      friedmannLCDM Gnewton rho Lam k a = OmegaU ^ 2 / a ^ 2 := by
  simp [friedmannEFMW]

theorem OmegaU_sq_le_of_hubble_measurement
    {Gnewton rho Lam k a OmegaU delta : ℝ}
    (ha : a ≠ 0)
    (h : |friedmannEFMW Gnewton rho Lam k a OmegaU -
      friedmannLCDM Gnewton rho Lam k a| ≤ delta) :
    OmegaU ^ 2 ≤ delta * a ^ 2 := by
  rw [friedmann_deviation] at h
  have ha2 : (0 : ℝ) < a ^ 2 := by positivity
  have hle : OmegaU ^ 2 / a ^ 2 ≤ delta := (abs_le.mp h).2
  rw [div_le_iff₀ ha2] at hle
  exact hle

theorem OmegaU_eq_zero_of_exact_hubble
    {Gnewton rho Lam k a OmegaU : ℝ} (ha : a ≠ 0)
    (h : friedmannEFMW Gnewton rho Lam k a OmegaU =
      friedmannLCDM Gnewton rho Lam k a) :
    OmegaU = 0 := by
  have h0 : OmegaU ^ 2 ≤ 0 * a ^ 2 :=
    OmegaU_sq_le_of_hubble_measurement ha (by rw [h]; simp)
  have hz : OmegaU ^ 2 ≤ 0 := by simpa using h0
  nlinarith [sq_nonneg OmegaU]

end ME056

theorem physical_test_asymmetry
    {c eps alpha : ℝ} (hc : 0 < c) (heps : 0 < eps)
    (heps1 : eps ^ 2 < 1) (h1 : alpha ^ 2 < 1)
    (hle : eps ≤ |alpha|) :
    (∃ p > 0, ∀ r : ℝ,
        ¬ ((Measurement.mk (phaseSpeed c) r p).Compatible 0 ∧
           (Measurement.mk (phaseSpeed c) r p).Compatible alpha)) ∧
    (∀ (D : List Measurement) (theta0 : ℝ),
        (∀ m ∈ D, ContinuousAt m.observable theta0) →
        DataStrictlyCompatible D theta0 →
        ∃ theta, theta ≠ theta0 ∧ DataCompatible D theta) :=
  ⟨decisive_precision_exists hc heps heps1 h1 hle,
    fun _ _ hcont hD => no_exact_parameter_verification hcont hD⟩

end Monolithic102
