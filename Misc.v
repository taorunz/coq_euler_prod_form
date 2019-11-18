(* Theorems of general usage, which could be (or not) in Coq library *)

Set Nested Proofs Allowed.
Require Import Utf8 Arith Psatz Sorted Permutation.
Import List List.ListNotations.

(* "fast" lia, to improve compilation speed *)
Tactic Notation "flia" hyp_list(Hs) := clear - Hs; lia.

Notation "x ≤ y ≤ z" := (x <= y ∧ y <= z)%nat (at level 70, y at next level).
Notation "x < y ≤ z" := (x < y ∧ y <= z)%nat (at level 70, y at next level).
Notation "x ≤ y < z" := (x ≤ y ∧ y < z)%nat (at level 70, y at next level).
Notation "x < y < z" := (x < y ∧ y < z)%nat (at level 70, y at next level).

Definition List_combine_all {A} (l1 l2 : list A) (d : A) :=
  let '(l'1, l'2) :=
    match List.length l1 ?= List.length l2 with
    | Eq => (l1, l2)
    | Lt => (l1 ++ List.repeat d (List.length l2 - List.length l1), l2)
    | Gt => (l1, l2 ++ List.repeat d (List.length l1 - List.length l2))
    end
  in
  List.combine l'1 l'2.

(* summations *)

Notation "'Σ' ( i = b , e ) , g" :=
  (fold_left (λ c i, c + g) (seq b (S e - b)) 0)
  (at level 45, i at level 0, b at level 60, e at level 60).

Theorem fold_left_add_fun_from_0 {A} : ∀ a l (f : A → nat),
  fold_left (λ c i, c + f i) l a =
  a + fold_left (λ c i, c + f i) l 0.
Proof.
intros.
revert a.
induction l as [| x l]; intros; [ symmetry; apply Nat.add_0_r | cbn ].
rewrite IHl; symmetry; rewrite IHl.
apply Nat.add_assoc.
Qed.

Theorem fold_left_mul_fun_from_1 {A} : ∀ a l (f : A → nat),
  fold_left (λ c i, c * f i) l a =
  a * fold_left (λ c i, c * f i) l 1.
Proof.
intros.
revert a.
induction l as [| x l]; intros; [ symmetry; apply Nat.mul_1_r | cbn ].
rewrite IHl; symmetry; rewrite IHl.
rewrite Nat.add_0_r.
apply Nat.mul_assoc.
Qed.

Theorem fold_left_mul_from_1 : ∀ a l,
  fold_left Nat.mul l a = a * fold_left Nat.mul l 1.
Proof.
intros.
revert a.
induction l as [| x l]; intros; [ symmetry; apply Nat.mul_1_r | cbn ].
rewrite IHl; symmetry; rewrite IHl.
rewrite Nat.add_0_r.
apply Nat.mul_assoc.
Qed.

Theorem summation_split_first : ∀ b e f,
  b ≤ e
  → Σ (i = b, e), f i = f b + Σ (i = S b, e), f i.
Proof.
intros * Hbe.
rewrite Nat.sub_succ.
replace (S e - b) with (S (e - b)) by flia Hbe.
cbn.
apply fold_left_add_fun_from_0.
Qed.

Theorem summation_split_last : ∀ b e f,
  b ≤ e
  → 1 ≤ e
  → Σ (i = b, e), f i = Σ (i = b, e - 1), f i + f e.
Proof.
intros * Hbe He.
destruct e; [ flia He | clear He ].
rewrite Nat.sub_succ, Nat.sub_0_r.
replace (S (S e) - b) with (S (S e - b)) by flia Hbe.
remember (S e - b) as n eqn:Hn.
revert b Hbe Hn.
induction n; intros. {
  now replace (S e) with b by flia Hbe Hn.
}
remember (S n) as sn; cbn; subst sn.
rewrite fold_left_add_fun_from_0.
rewrite IHn; [ | flia Hn | flia Hn ].
rewrite Nat.add_assoc; f_equal; cbn.
now rewrite (fold_left_add_fun_from_0 (f b)).
Qed.

Theorem all_0_summation_0 : ∀ b e f,
  (∀ i, b ≤ i ≤ e → f i = 0)
  → Σ (i = b, e), f i = 0.
Proof.
intros * Hz.
remember (S e - b) as n eqn:Hn.
revert b Hz Hn.
induction n; intros; [ easy | cbn ].
rewrite fold_left_add_fun_from_0.
rewrite IHn; [ | | flia Hn ]. {
  rewrite Hz; [ easy | flia Hn ].
}
intros i Hi.
apply Hz; flia Hi.
Qed.

Ltac rewrite_in_summation th :=
  let b := fresh "b" in
  let e := fresh "e" in
  let a := fresh "a" in
  intros b e;
  remember (S e - b) as n eqn:Hn;
  remember 0 as a eqn:Ha; clear Ha;
  revert e a b Hn;
  induction n as [| n IHn]; intros; [ easy | cbn ];
  rewrite th;
  apply (IHn e); flia Hn.

Theorem summation_eq_compat : ∀ b e g h,
  (∀ i, b ≤ i ≤ e → g i = h i)
  → Σ (i = b, e), g i = Σ (i = b, e), h i.
Proof.
intros * Hgh.
remember (S e - b) as n eqn:Hn.
remember 0 as a eqn:Ha; clear Ha.
revert e a b Hn Hgh.
induction n as [| n IHn]; intros; [ easy | cbn ].
rewrite Hgh; [ | flia Hn ].
rewrite (IHn e); [ easy | flia Hn | ].
intros i Hbie.
apply Hgh; flia Hbie.
Qed.

Theorem mul_add_distr_r_in_summation : ∀ b e f g h,
  Σ (i = b, e), (f i + g i) * h i =
  Σ (i = b, e), (f i * h i + g i * h i).
Proof.
intros; revert b e.
rewrite_in_summation Nat.mul_add_distr_r.
Qed.

Theorem double_mul_assoc_in_summation : ∀ b e f g h k,
  Σ (i = b, e), f i * g i * h i * k i = Σ (i = b, e), f i * (g i * h i * k i).
Proof.
intros.
assert (H : ∀ a b c d, a * b * c * d = a * (b * c * d)) by flia.
revert b e.
rewrite_in_summation H.
Qed.

Theorem mul_assoc_in_summation : ∀ b e f g h,
  Σ (i = b, e), f i * g i * h i = Σ (i = b, e), f i * (g i * h i).
Proof.
intros.
assert (H : ∀ a b c, a * b * c = a * (b * c)) by flia.
revert b e.
rewrite_in_summation H.
Qed.

Theorem mul_comm_in_summation : ∀ b e f g,
  Σ (i = b, e), f i * g i = Σ (i = b, e), g i * f i.
Proof.
intros.
assert (H : ∀ a b, a * b = b * a) by flia.
revert b e.
rewrite_in_summation H.
Qed.

Theorem mul_summation_distr_l : ∀ a b e f,
  a * (Σ (i = b, e), f i) = Σ (i = b, e), a * f i.
Proof.
intros.
remember (S e - b) as n eqn:Hn.
revert e a b Hn.
induction n; intros; [ apply Nat.mul_0_r | cbn ].
rewrite fold_left_add_fun_from_0.
rewrite Nat.mul_add_distr_l.
rewrite (IHn e); [ | flia Hn ].
symmetry.
apply fold_left_add_fun_from_0.
Qed.

Theorem mul_summation_distr_r : ∀ a b e f,
  (Σ (i = b, e), f i) * a = Σ (i = b, e), f i * a.
Proof.
intros.
rewrite Nat.mul_comm.
rewrite mul_summation_distr_l.
now rewrite mul_comm_in_summation.
Qed.

Theorem power_shuffle1_in_summation : ∀ b e a f g,
  Σ (i = b, e), a * f i * a ^ (e - i) * g i =
  Σ (i = b, e), f i * a ^ (S e - i) * g i.
Proof.
intros.
(* failed to be able to use "rewrite_in_summation" here *)
assert
  (H : ∀ i e,
   a * f i * a ^ (e - i) * g i = f i * a ^ (S (e - i)) * g i). {
  clear e; intros; f_equal.
  rewrite <- Nat.mul_assoc, Nat.mul_comm, <- Nat.mul_assoc.
  f_equal.
  rewrite Nat.mul_comm.
  replace a with (a ^ 1) at 1 by apply Nat.pow_1_r.
  now rewrite <- Nat.pow_add_r.
}
remember (S e - b) as n eqn:Hn.
remember 0 as z eqn:Hz; clear Hz.
revert e z b Hn.
induction n as [| n IHn]; intros; [ easy | ].
cbn - [ "-" ].
rewrite IHn; [ | flia Hn ].
f_equal; f_equal; rewrite H.
f_equal; f_equal; f_equal; flia Hn.
Qed.

Theorem power_shuffle2_in_summation : ∀ b e a c f,
  Σ (i = b, e), c * f i * a ^ (e - i) * c ^ i =
  Σ (i = b, e), f i * a ^ (e - i) * c ^ S i.
Proof.
intros.
remember (S e - b) as n eqn:Hn.
remember 0 as z eqn:Hz; clear Hz.
revert e z b Hn.
induction n as [| n IHn]; intros; [ easy | ].
cbn.
rewrite IHn; [ | flia Hn ].
f_equal; f_equal.
do 2 rewrite <- Nat.mul_assoc.
rewrite Nat.mul_comm.
do 3 rewrite <- Nat.mul_assoc.
f_equal; f_equal.
apply Nat.mul_comm.
Qed.

Theorem summation_add : ∀ b e f g,
  Σ (i = b, e), (f i + g i) = Σ (i = b, e), f i + Σ (i = b, e), g i.
Proof.
intros.
remember (S e - b) as n eqn:Hn.
revert b Hn.
induction n; intros; [ easy | cbn ].
rewrite fold_left_add_fun_from_0.
rewrite IHn; [ | flia Hn ].
rewrite (fold_left_add_fun_from_0 (f b)).
rewrite (fold_left_add_fun_from_0 (g b)).
flia.
Qed.

Theorem summation_shift : ∀ b e f,
  Σ (i = S b, S e), f i = Σ (i = b, e), f (S i).
Proof.
intros.
rewrite Nat.sub_succ.
remember (S e - b) as n eqn:Hn.
revert b Hn.
induction n; intros; [ easy | cbn ].
setoid_rewrite fold_left_add_fun_from_0.
rewrite IHn; [ easy | flia Hn ].
Qed.

Theorem summation_mod_idemp : ∀ b e f n,
  (Σ (i = b, e), f i) mod n = (Σ (i = b, e), f i mod n) mod n.
Proof.
intros.
destruct (Nat.eq_dec n 0) as [Hnz| Hnz]; [ now subst n | ].
remember (S e - b) as m eqn:Hm.
revert b Hm.
induction m; intros; [ easy | cbn ].
rewrite (fold_left_add_fun_from_0 (f b)).
rewrite (fold_left_add_fun_from_0 (f b mod n)).
rewrite Nat.add_mod_idemp_l; [ | easy ].
rewrite <- Nat.add_mod_idemp_r; [ symmetry | easy ].
rewrite <- Nat.add_mod_idemp_r; [ symmetry | easy ].
f_equal; f_equal.
apply IHm; flia Hm.
Qed.

(* *)

Theorem Nat_add_div_same : ∀ a b c,
  Nat.divide c a
  → a / c + b / c = (a + b) / c.
Proof.
intros * Hca.
destruct (Nat.eq_dec c 0) as [Hcz| Hcz]; [ now subst c | ].
destruct Hca as (d, Hd).
rewrite Hd, Nat.div_mul; [ | easy ].
rewrite Nat.add_comm, (Nat.add_comm _ b).
now rewrite Nat.div_add.
Qed.

Theorem Nat_sub_succ_1 : ∀ n, S n - 1 = n.
Proof. now intros; rewrite Nat.sub_succ, Nat.sub_0_r. Qed.

Theorem Nat_eq_mod_sub_0 : ∀ a b c,
  b ≤ a → a mod c = b mod c → (a - b) mod c = 0.
Proof.
intros * Hba Hab.
destruct (Nat.eq_dec c 0) as [Hcz| Hcz]; [ now subst c | ].
specialize (Nat.div_mod a c Hcz) as H1.
specialize (Nat.div_mod b c Hcz) as H2.
rewrite H1, H2, Hab.
rewrite (Nat.add_comm (c * (b / c))).
rewrite Nat.sub_add_distr, Nat.add_sub.
rewrite <- Nat.mul_sub_distr_l, Nat.mul_comm.
now apply Nat.mod_mul.
Qed.

Theorem Nat_mod_0_mod_div : ∀ a b,
  0 < b ≤ a → a mod b = 0 → a mod (a / b) = 0.
Proof.
intros * Hba Ha.
assert (Hbz : b ≠ 0) by flia Hba.
assert (Habz : a / b ≠ 0). {
  intros H.
  apply Nat.div_small_iff in H; [ | flia Hba ].
  now apply Nat.nle_gt in H.
}
specialize (Nat.div_mod a (a / b) Habz) as H1.
specialize (Nat.div_mod a b Hbz) as H2.
rewrite Ha, Nat.add_0_r in H2.
rewrite H2 in H1 at 3.
rewrite Nat.div_mul in H1; [ | easy ].
rewrite Nat.mul_comm in H1.
flia H1 H2.
Qed.

Theorem Nat_mod_0_div_div : ∀ a b,
  0 < b ≤ a → a mod b = 0 → a / (a / b) = b.
Proof.
intros * Hba Ha.
assert (Hbz : b ≠ 0) by flia Hba.
assert (Habz : a / b ≠ 0). {
  intros H.
  apply Nat.div_small_iff in H; [ | easy ].
  now apply Nat.nle_gt in H.
}
specialize (Nat.div_mod a (a / b) Habz) as H1.
rewrite Nat_mod_0_mod_div in H1; [ | easy | easy ].
rewrite Nat.add_0_r in H1.
apply (Nat.mul_cancel_l _ _ (a / b)); [ easy | ].
rewrite <- H1; symmetry.
rewrite Nat.mul_comm.
apply Nat.mod_divide in Ha; [ | easy ].
rewrite <- Nat.divide_div_mul_exact; [ | easy | easy ].
now rewrite Nat.mul_comm, Nat.div_mul.
Qed.

Theorem Nat_fact_succ : ∀ n, fact (S n) = S n * fact n.
Proof. easy. Qed.

Theorem Nat_divide_fact_fact : ∀ n d, Nat.divide (fact (n - d)) (fact n).
Proof.
intros *.
revert n.
induction d; intros; [ rewrite Nat.sub_0_r; apply Nat.divide_refl | ].
destruct n; [ apply Nat.divide_refl | ].
rewrite Nat.sub_succ.
apply (Nat.divide_trans _ (fact n)); [ apply IHd | ].
rewrite Nat_fact_succ.
now exists (S n).
Qed.

Theorem Nat_divide_small_fact : ∀ n k, 0 < k ≤ n → Nat.divide k (fact n).
Proof.
intros * Hkn.
revert k Hkn.
induction n; intros; [ flia Hkn | ].
rewrite Nat_fact_succ.
destruct (Nat.eq_dec k (S n)) as [Hksn| Hksn]. {
  rewrite Hksn.
  apply Nat.divide_factor_l.
}
apply (Nat.divide_trans _ (fact n)). {
  apply IHn; flia Hkn Hksn.
}
apply Nat.divide_factor_r.
Qed.

Theorem Nat_divide_mul_fact : ∀ n a b,
  0 < a ≤ n
  → 0 < b ≤ n
  → a < b
  → Nat.divide (a * b) (fact n).
Proof.
intros * Han Hbn Hab.
exists (fact (a - 1) * (fact (b - 1) / fact a) * (fact n / fact b)).
rewrite Nat.mul_comm.
rewrite (Nat.mul_shuffle0 _ b).
do 2 rewrite Nat.mul_assoc.
replace (a * fact (a - 1)) with (fact a). 2: {
  destruct a; [ flia Han | ].
  rewrite Nat_fact_succ.
  now rewrite Nat.sub_succ, Nat.sub_0_r.
}
replace (fact a * (fact (b - 1) / fact a)) with (fact (b - 1)). 2: {
  specialize (Nat_divide_fact_fact (b - 1) (b - 1 - a)) as H1.
  replace (b - 1 - (b - 1 - a)) with a in H1 by flia Hab.
  destruct H1 as (c, Hc).
  rewrite Hc, Nat.div_mul; [ | apply fact_neq_0 ].
  apply Nat.mul_comm.
}
rewrite Nat.mul_comm, Nat.mul_assoc.
replace (b * fact (b - 1)) with (fact b). 2: {
  destruct b; [ flia Hbn | ].
  rewrite Nat_fact_succ.
  now rewrite Nat.sub_succ, Nat.sub_0_r.
}
replace (fact b * (fact n / fact b)) with (fact n). 2: {
  specialize (Nat_divide_fact_fact n (n - b)) as H1.
  replace (n - (n - b)) with b in H1 by flia Hbn.
  destruct H1 as (c, Hc).
  rewrite Hc, Nat.div_mul; [ | apply fact_neq_0 ].
  apply Nat.mul_comm.
}
easy.
Qed.

Theorem Nat_bezout_comm : ∀ a b g,
  b ≠ 0
  → Nat.Bezout a b g → Nat.Bezout b a g.
Proof.
intros * Hbz (u & v & Huv).
destruct (Nat.eq_dec a 0) as [Haz| Haz]. {
  subst a.
  rewrite Nat.mul_0_r in Huv; symmetry in Huv.
  apply Nat.eq_add_0 in Huv.
  rewrite (proj1 Huv).
  now exists 0, 0.
}
remember (max (u / b + 1) (v / a + 1)) as k eqn:Hk.
exists (k * a - v), (k * b - u).
do 2 rewrite Nat.mul_sub_distr_r.
rewrite Huv.
rewrite (Nat.add_comm _ (v * b)).
rewrite Nat.sub_add_distr.
rewrite Nat.add_sub_assoc. 2: {
  apply (Nat.add_le_mono_r _ _ (v * b)).
  rewrite <- Huv.
  rewrite Nat.sub_add. 2: {
    rewrite Nat.mul_shuffle0.
    apply Nat.mul_le_mono_r.
    rewrite Hk.
    rewrite <- Nat.mul_max_distr_r.
    etransitivity; [ | apply Nat.le_max_r ].
    specialize (Nat.div_mod v a) as H1.
    specialize (H1 Haz).
    rewrite Nat.mul_add_distr_r, Nat.mul_1_l, Nat.mul_comm.
    rewrite H1 at 1.
    apply Nat.add_le_mono_l.
    now apply Nat.lt_le_incl, Nat.mod_upper_bound.
  }
  apply Nat.mul_le_mono_r.
  rewrite Hk.
  rewrite <- Nat.mul_max_distr_r.
  etransitivity; [ | apply Nat.le_max_l ].
  specialize (Nat.div_mod u b) as H1.
  specialize (H1 Hbz).
  rewrite Nat.mul_add_distr_r, Nat.mul_1_l, Nat.mul_comm.
  rewrite H1 at 1.
  apply Nat.add_le_mono_l.
  now apply Nat.lt_le_incl, Nat.mod_upper_bound.
}
rewrite Nat.add_comm, Nat.add_sub.
now rewrite Nat.mul_shuffle0.
Qed.

Theorem Nat_bezout_mul : ∀ a b c,
  Nat.Bezout a c 1
  → Nat.Bezout b c 1
  → Nat.Bezout (a * b) c 1.
Proof.
intros * (ua & uc & Hu) (vb & vc & Hv).
exists (ua * vb).
replace (ua * vb * (a * b)) with ((ua * a) * (vb * b)) by flia.
rewrite Hu, Hv.
exists (uc * vc * c + uc + vc).
ring.
Qed.

Theorem Nat_gcd_1_mul_r : ∀ a b c,
  Nat.gcd a b = 1
  → Nat.gcd a c = 1
  → Nat.gcd a (b * c) = 1.
Proof.
intros * Hab Hac.
destruct (Nat.eq_dec a 0) as [Haz| Haz]. {
  now subst a; cbn in Hab, Hac; subst b c.
}
destruct (Nat.eq_dec b 0) as [Hbz| Hbz]; [ now subst b | ].
destruct (Nat.eq_dec c 0) as [Hcz| Hcz]. {
  now subst c; rewrite Nat.mul_0_r.
}
apply Nat.bezout_1_gcd.
apply Nat_bezout_comm; [ easy | ].
apply Nat_bezout_mul. {
  rewrite <- Hab, Nat.gcd_comm.
  apply Nat.gcd_bezout_pos.
  flia Hbz.
} {
  rewrite <- Hac, Nat.gcd_comm.
  apply Nat.gcd_bezout_pos.
  flia Hcz.
}
Qed.

Theorem Nat_pow_sub_pow : ∀ a b n,
  n ≠ 0
  → b ≤ a
  → a ^ n - b ^ n =
     (a - b) * Σ (i = 0, n - 1), a ^ (n - i - 1) * b ^ i.
Proof.
intros * Hnz Hba.
destruct n; [ easy | clear Hnz ].
induction n; [ now cbn; do 3 rewrite Nat.mul_1_r | ].
remember (S n) as sn; cbn - [ "-" ]; subst sn.
rewrite <- (Nat.sub_add (a * b ^ S n) (a * a ^ S n)). 2: {
  apply Nat.mul_le_mono_l.
  now apply Nat.pow_le_mono_l.
}
rewrite <- Nat.mul_sub_distr_l.
rewrite <- Nat.add_sub_assoc; [ | now apply Nat.mul_le_mono_r ].
rewrite <- Nat.mul_sub_distr_r.
rewrite (Nat.mul_comm a).
rewrite IHn, <- Nat.mul_assoc.
rewrite <- Nat.mul_add_distr_l; f_equal.
do 2 rewrite Nat.sub_succ.
replace (n - 0) with n by now rewrite Nat.sub_0_r.
replace (S n - 0) with (S n) at 2 by now rewrite Nat.sub_0_r.
rewrite (summation_split_last _ (S n)); [ | flia | flia ].
rewrite Nat.sub_succ.
replace (n - 0) with n by now rewrite Nat.sub_0_r.
replace (S (S n) - S n - 1) with 0 by flia.
rewrite Nat.pow_0_r, Nat.mul_1_l.
f_equal.
rewrite mul_summation_distr_r.
apply summation_eq_compat.
intros i Hi.
rewrite Nat.mul_shuffle0; f_equal.
rewrite <- (Nat.pow_1_r a) at 2.
rewrite <- Nat.pow_add_r.
f_equal; flia Hi.
Qed.

(* could be a corollary of Nat_pow_sub_pow *)
Theorem Nat_sqr_sub_1 : ∀ a, a ^ 2 - 1 = (a + 1) * (a - 1).
Proof.
intros.
destruct (Nat.eq_dec a 0) as [Haz| Haz]; [ now subst a | ].
rewrite Nat.mul_add_distr_r, Nat.mul_1_l.
rewrite Nat.mul_sub_distr_l, Nat.mul_1_r.
rewrite Nat.add_sub_assoc; [ | flia Haz ].
rewrite Nat.pow_2_r.
rewrite Nat.sub_add; [ easy | ].
destruct a; [ easy | ].
cbn; remember (_ * _); flia.
Qed.

Theorem Nat_sub_sub_assoc : ∀ a b c,
  c ≤ b ≤ a + c
  → a - (b - c) = a + c - b.
Proof.
intros * (Hcb, Hba).
revert a c Hcb Hba.
induction b; intros.
-apply Nat.le_0_r in Hcb; subst c.
 now rewrite Nat.add_0_r.
-destruct c; [ now rewrite Nat.add_0_r | ].
 apply Nat.succ_le_mono in Hcb.
 rewrite Nat.add_succ_r in Hba.
 apply Nat.succ_le_mono in Hba.
 specialize (IHb a c Hcb Hba) as H1.
 rewrite Nat.sub_succ, H1.
 rewrite Nat.add_succ_r.
 now rewrite Nat.sub_succ.
Qed.

Theorem Nat_sub_sub_distr : ∀ a b c, c ≤ b ≤ a → a - (b - c) = a - b + c.
Proof.
intros.
rewrite <- Nat.add_sub_swap; [ | easy ].
apply Nat_sub_sub_assoc.
split; [ easy | ].
apply (Nat.le_trans _ a); [ easy | ].
apply Nat.le_add_r.
Qed.

Theorem Nat_mod_pow_mod : ∀ a b c, (a mod b) ^ c mod b = a ^ c mod b.
Proof.
intros.
destruct (Nat.eq_dec b 0) as [Hbz| Hbz]; [ now subst b | ].
revert a b Hbz.
induction c; intros; [ easy | cbn ].
rewrite Nat.mul_mod_idemp_l; [ | easy ].
rewrite <- Nat.mul_mod_idemp_r; [ | easy ].
rewrite IHc; [ | easy ].
now rewrite Nat.mul_mod_idemp_r.
Qed.

Theorem List_hd_nth_0 {A} : ∀ l (d : A), hd d l = nth 0 l d.
Proof. intros; now destruct l. Qed.

Theorem List_map_map_map {A B C D} : ∀ (f : A → B → C) (g : A → D → B) h l,
  map (λ d, map (f d) (map (g d) (h d))) l =
  map (λ d, map (λ x, (f d (g d x))) (h d)) l.
Proof.
intros.
induction l as [| a l]; [ easy | cbn ].
now rewrite List.map_map, IHl.
Qed.

Theorem List_flat_map_length {A B} : ∀ (l : list A) (f : _ → list B),
  length (flat_map f l) =
    List.fold_right Nat.add 0 (map (@length B) (map f l)).
Proof.
intros.
induction l as [| a l]; [ easy | cbn ].
now rewrite app_length, IHl.
Qed.

Theorem List_last_seq : ∀ i n, n ≠ 0 → last (seq i n) 0 = i + n - 1.
Proof.
intros * Hn.
destruct n; [ easy | clear Hn ].
revert i; induction n; intros. {
  cbn; symmetry.
  apply Nat.add_sub.
}
remember (S n) as sn; cbn; subst sn.
remember (seq (S i) (S n)) as l eqn:Hl.
destruct l; [ easy | ].
rewrite Hl.
replace (i + S (S n)) with (S i + S n) by flia.
apply IHn.
Qed.

Theorem List_last_In {A} : ∀ (d : A) l, l ≠ [] → In (last l d) l.
Proof.
intros * Hl.
destruct l as [| a l]; [ easy | clear Hl ].
revert a.
induction l as [| b l]; intros; [ now left | ].
remember (b :: l) as l'; cbn; subst l'.
right; apply IHl.
Qed.

Theorem List_last_app {A} : ∀ l (d a : A), List.last (l ++ [a]) d = a.
Proof.
intros.
induction l; [ easy | ].
cbn.
remember (l ++ [a]) as l' eqn:Hl'.
destruct l'; [ now destruct l | apply IHl ].
Qed.

Theorem not_equiv_imp_False : ∀ P : Prop, (P → False) ↔ ¬ P.
Proof. easy. Qed.

Theorem Sorted_Sorted_seq : ∀ start len, Sorted.Sorted lt (seq start len).
Proof.
intros.
revert start.
induction len; intros; [ apply Sorted.Sorted_nil | ].
cbn; apply Sorted.Sorted_cons; [ apply IHlen | ].
clear IHlen.
induction len; [ apply Sorted.HdRel_nil | ].
cbn. apply Sorted.HdRel_cons.
apply Nat.lt_succ_diag_r.
Qed.

Theorem Forall_inv_tail {A} : ∀ P (a : A) l, Forall P (a :: l) → Forall P l.
Proof.
intros * HF.
now inversion HF.
Qed.

Theorem NoDup_app_comm {A} : ∀ l l' : list A,
  NoDup (l ++ l') → NoDup (l' ++ l).
Proof.
intros * Hll.
revert l Hll.
induction l' as [| a l']; intros; [ now rewrite app_nil_r in Hll | ].
cbn; constructor. {
  intros Ha.
  apply NoDup_remove_2 in Hll; apply Hll.
  apply in_app_or in Ha.
  apply in_or_app.
  now destruct Ha; [ right | left ].
}
apply IHl'.
now apply NoDup_remove_1 in Hll.
Qed.

Theorem List_in_app_app_swap {A} : ∀ (a : A) l1 l2 l3,
  In a (l1 ++ l3 ++ l2)
  → In a (l1 ++ l2 ++ l3).
Proof.
intros * Hin.
revert l2 l3 Hin.
induction l1 as [| a2 l1]; intros. {
  cbn in Hin; cbn.
  apply in_app_or in Hin.
  apply in_or_app.
  now destruct Hin; [ right | left ].
}
cbn in Hin; cbn.
destruct Hin as [Hin| Hin]; [ now left | right ].
now apply IHl1.
Qed.

Theorem List_fold_left_mul_assoc : ∀ a b l,
  fold_left Nat.mul l a * b = fold_left Nat.mul l (a * b).
Proof.
intros.
revert a b.
induction l as [| c l]; intros; [ easy | ].
cbn; rewrite IHl.
now rewrite Nat.mul_shuffle0.
Qed.

Theorem NoDup_app_app_swap {A} : ∀ l1 l2 l3 : list A,
  NoDup (l1 ++ l2 ++ l3) → NoDup (l1 ++ l3 ++ l2).
Proof.
intros * Hlll.
revert l2 l3 Hlll.
induction l1 as [| a1 l1]; intros; [ now cbn; apply NoDup_app_comm | ].
cbn; constructor. {
  intros Hin.
  cbn in Hlll.
  apply NoDup_cons_iff in Hlll.
  destruct Hlll as (Hin2, Hlll).
  apply Hin2; clear Hin2.
  now apply List_in_app_app_swap.
}
apply IHl1.
cbn in Hlll.
now apply NoDup_cons_iff in Hlll.
Qed.

Theorem NoDup_concat_rev {A} : ∀ (ll : list (list A)),
  NoDup (concat (rev ll)) → NoDup (concat ll).
Proof.
intros * Hll.
destruct ll as [| l ll]; [ easy | ].
cbn; cbn in Hll.
rewrite concat_app in Hll; cbn in Hll.
rewrite app_nil_r in Hll.
apply NoDup_app_comm.
revert l Hll.
induction ll as [| l' ll]; intros; [ easy | ].
cbn in Hll; cbn.
rewrite concat_app in Hll; cbn in Hll.
rewrite app_nil_r, <- app_assoc in Hll.
rewrite <- app_assoc.
apply NoDup_app_app_swap.
rewrite app_assoc.
apply NoDup_app_comm.
now apply IHll.
Qed.

Theorem NoDup_filter {A} : ∀ (f : A → _) l, NoDup l → NoDup (filter f l).
Proof.
intros * Hnd.
induction l as [| a l]; [ easy | cbn ].
remember (f a) as b eqn:Hb; symmetry in Hb.
apply NoDup_cons_iff in Hnd.
destruct Hnd as (Hal, Hl).
destruct b. {
  constructor; [ | now apply IHl ].
  intros H; apply Hal.
  now apply filter_In in H.
}
now apply IHl.
Qed.

Theorem Permutation_fold_mul : ∀ l1 l2 a,
  Permutation l1 l2 → fold_left Nat.mul l1 a = fold_left Nat.mul l2 a.
Proof.
intros * Hperm.
induction Hperm using Permutation_ind; [ easy | | | ]. {
  cbn; do 2 rewrite <- List_fold_left_mul_assoc.
  now rewrite IHHperm.
} {
  now cbn; rewrite Nat.mul_shuffle0.
}
etransitivity; [ apply IHHperm1 | apply IHHperm2 ].
Qed.
