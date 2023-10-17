import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.BigOperators.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Init.Data.Nat.Basic
import SymmetricProject.attainable

-- hack to avoid the real powers bug
local macro_rules | `($x ^ $y)   => `(HPow.hPow $x $y)

/-- The purpose of this file is to prove the Newton identity

$$ s_{n,k}(x) s_{n,k+2}(x) ≤ s_{n,k+1}(x)^2.$$

This turns out to be straightforward with the tools from the attainable file. 
-/

lemma cancel (a b c : ℝ) (h : a > 0) (k: b ≤ c) : a * b ≤ a * c := by
  nlinarith

theorem newton_identity (n k : ℕ) (h: k+2 ≤ n) : ∀ s : ℕ → ℝ, attainable n s → s k * s (k+2) ≤ s (k+1)^2 := by
  intro s ha

  -- first step: reduce to (n,k) = (k+2,k)

  have h1 : attainable (k+2) s := attainable_truncate n (k+2) s h ha
  clear ha h n
  -- second step: reduce to (n,k) = (k+2,0)

  suffices : ∀ s : ℕ → ℝ, attainable (k+2) s → s 0 * s 2 ≤ s 1^2
  . rcases em (s (k+2) = 0) with vanish | non_vanish
    . rw [vanish]
      simp
      nlinarith
    let s' := fun (m:ℕ) => s (k+2-m) / s (k+2)
    have h2 : attainable (k+2) s' := by
      apply attainable_reflect (k+2) s h1 non_vanish
    have h3 := this s' h2
    have hs': ∀ m : ℕ, s' m = s (k+2-m) / s (k+2) := by 
      intro m
      rfl
    rw [hs' 0, hs' 1, hs' 2] at h3
    contrapose! h3
    field_simp
    contrapose! h3
    have h4 : s (k+2)^2 > 0 := by 
      have h5 : s (k+2)^2 = (s (k+2)) * (s (k+2)) := by ring
      rw [h5]
      replace non_vanish : (s (k+2) ≠ 0) := by apply non_vanish 
      rw [<- mul_self_pos] at non_vanish
      assumption

    have h5 : s (k + 2) ^ 2 * (s k / s (k+2)) ≤ s (k+2)^2 * (s (k+1)^2 / s (k+2)^2) := by
      apply cancel _ _ _ h4 h3
    contrapose! h5
    have h6 : s (k+2)^2 * (s (k+1)^2 / s (k+2)^2) = s (k+1)^2 := by 
      field_simp [h4]
      ring
    have h7 : s (k + 2) ^ 2 * (s k / s (k + 2)) = s k * s (k+2) := by 
      field_simp [h4]
      ring
    rw [h6, h7] 
    assumption

  -- third step: reduce to (n,k)=(2,0)
  clear s h1
  suffices : ∀ s : ℕ → ℝ, attainable 2 s → s 0 * s 2 ≤ s 1^2
  . intro s ha
    have h1 : attainable 2 s := attainable_truncate (k+2) 2 s (show 2 ≤ k+2 by linarith) ha
    clear ha 
    exact this s h1

  intro s ha
  simp [attainable] at ha
  rcases ha with ⟨ x, hx ⟩
  have h0 := hx 0 (show 0 ≤ 2 by norm_num)
  have h1 := hx 1 (show 1 ≤ 2 by norm_num)
  have h2 := hx 2 (show 2 ≤ 2 by norm_num)
  rw [esymm_zero_eq_one] at h0
  rw [esymm_sum] at h1
  rw [esymm_prod] at h2
  simp at h0
  simp at h1
  simp at h2
  have r : Finset.range 2 = {0,1} := by
    ext a
    simp
    constructor
    . intro ha
      have ha' : a ≤ 1 := by linarith [ha]
      rcases a with a | a 
      . norm_num
      rw [Nat.succ_eq_add_one] 
      rw [Nat.succ_eq_add_one] at ha'
      have ha'' : a = 0 := by linarith
      right
      rw [ha'']
    intro ha
    rcases ha with h | h
    . norm_num [h]
    norm_num [h]
  rw [r, Finset.sum_pair] at h1
  rw [r, Finset.prod_pair] at h2
  rw [<- h0, <- h2]
  have h1' : s 1 = (x 0 + x 1)/2 := by
    field_simp [h1]
    left
    norm_num
  rw [h1']
  clear k hx h0 h1 h2 r h1'
  field_simp
  rw [<- sub_nonneg]
  field_simp
  have h : (2:ℝ) ^ 2 = 4 := by norm_num
  rw [h]  
  have h' : (x 0 + x 1) ^ 2 - 4 * (x 0 * x 1) = (x 0 - x 1) * (x 0 - x 1) := by ring
  rw [h']
  nlinarith
  norm_num
  norm_num
