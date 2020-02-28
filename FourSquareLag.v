(* Lagrange's four-square theorem *)

Set Nested Proofs Allowed.
Require Import Utf8 Arith.
Import List List.ListNotations.
Require Import Misc Primes.

Lemma le_half_prime_square_diff : ∀ p a a',
   prime p
   → p mod 2 = 1
   → a ≤ (p - 1) / 2
   → a' ≤ (p - 1) / 2
   → a' < a
   → a ^ 2 ≢  a' ^ 2 mod p.
Proof.
intros * Hp Hp2 Ha Ha' Haa.
intros H1.
apply Nat_eq_mod_sub_0 in H1.
rewrite Nat_sqr_sub_sqr, Nat.mul_comm in H1.
apply Nat.mod_divide in H1; [ | now intros H2; subst p ].
specialize (Nat.gauss _ _ _ H1) as H2.
apply (Nat.mul_le_mono_l _ _ 2) in Ha.
apply (Nat.mul_le_mono_l _ _ 2) in Ha'.
rewrite <- Nat.divide_div_mul_exact in Ha; [ | easy | ]. 2: {
  specialize (Nat.div_mod p 2 (Nat.neq_succ_0 _)) as H3.
  rewrite Hp2 in H3.
  rewrite H3, Nat.add_sub.
  apply Nat.divide_factor_l.
}
rewrite (Nat.mul_comm _ (p - 1)), Nat.div_mul in Ha; [ | easy ].
rewrite <- Nat.divide_div_mul_exact in Ha'; [ | easy | ]. 2: {
  specialize (Nat.div_mod p 2 (Nat.neq_succ_0 _)) as H3.
  rewrite Hp2 in H3.
  rewrite H3, Nat.add_sub.
  apply Nat.divide_factor_l.
}
rewrite (Nat.mul_comm _ (p - 1)), Nat.div_mul in Ha'; [ | easy ].
assert (H : Nat.gcd p (a - a') = 1). {
  apply eq_gcd_prime_small_1; [ easy | ].
  split; [ flia Haa | ].
  flia Ha Ha' Haa.
}
specialize (H2 H); clear H.
destruct H2 as (k, Hk).
destruct k. {
  apply Nat.eq_add_0 in Hk.
  now destruct Hk; subst a a'.
}
cbn in Hk.
apply (f_equal (Nat.mul 2)) in Hk.
do 2 rewrite Nat.mul_add_distr_l in Hk.
specialize (prime_ge_2 _ Hp) as Hpge2.
flia Ha Ha' Hk Hpge2.
Qed.

Lemma le_half_prime_succ_square_diff : ∀ p b b',
  prime p
  → p mod 2 = 1
  → b ≤ (p - 1) / 2
  → b' ≤ (p - 1) / 2
  → b < b'
  → b' ^ 2 + 1 ≢ (b ^ 2 + 1) mod p.
Proof.
intros * Hp Hp2 Hb Hb' Hbb' Hb1.
assert (Hpz : p ≠ 0) by now intros H; subst p.
apply Nat_eq_mod_sub_0 in Hb1.
replace (b' ^ 2 + 1 - (b ^ 2 + 1)) with (b' ^ 2 - b ^ 2) in Hb1 by flia.
rewrite Nat_sqr_sub_sqr, Nat.mul_comm in Hb1.
apply Nat.mod_divide in Hb1; [ | easy ].
specialize (Nat.gauss _ _ _ Hb1) as H2.
apply (Nat.mul_le_mono_l _ _ 2) in Hb.
apply (Nat.mul_le_mono_l _ _ 2) in Hb'.
rewrite <- Nat.divide_div_mul_exact in Hb; [ | easy | ]. 2: {
  specialize (Nat.div_mod p 2 (Nat.neq_succ_0 _)) as H3.
  rewrite Hp2 in H3.
  rewrite H3, Nat.add_sub.
  apply Nat.divide_factor_l.
}
rewrite (Nat.mul_comm _ (p - 1)), Nat.div_mul in Hb; [ | easy ].
rewrite <- Nat.divide_div_mul_exact in Hb'; [ | easy | ]. 2: {
  specialize (Nat.div_mod p 2 (Nat.neq_succ_0 _)) as H3.
  rewrite Hp2 in H3.
  rewrite H3, Nat.add_sub.
  apply Nat.divide_factor_l.
}
rewrite (Nat.mul_comm _ (p - 1)), Nat.div_mul in Hb'; [ | easy ].
assert (H : Nat.gcd p (b' - b) = 1). {
  apply eq_gcd_prime_small_1; [ easy | ].
  split; [ flia Hbb' | ].
  flia Hb Hb' Hbb'.
}
specialize (H2 H); clear H.
destruct H2 as (k, Hk).
destruct k. {
  apply Nat.eq_add_0 in Hk.
  now destruct Hk; subst b b'.
}
cbn in Hk.
apply (f_equal (Nat.mul 2)) in Hk.
do 2 rewrite Nat.mul_add_distr_l in Hk.
specialize (prime_ge_2 _ Hp) as Hpge2.
flia Hb Hb' Hk Hpge2.
Qed.

(* pigeonhole *)

Fixpoint find_dup (la : list (nat * nat)) :=
  match la with
  | [] => None
  | (n, a) :: la' =>
      match find (λ nb, snd nb =? a) la' with
      | None => find_dup la'
      | Some (n', _) => Some (n, n')
      end
  end.

Definition pigeonhole_fun a (f : nat → nat) :=
  match find_dup (List.map (λ n, (n, f n)) (seq 0 a)) with
  | Some (n, n') => (n, n')
  | None => (0, 0)
  end.

Theorem find_dup_some : ∀ x x' la,
  find_dup la = Some (x, x')
  → ∃ y la1 la2 la3,
     la = la1 ++ (x, y) :: la2 ++ (x', y) :: la3.
Proof.
intros * Hfd.
induction la as [| a]; [ easy | ].
cbn in Hfd.
destruct a as (n, a).
remember (find (λ nb, snd nb =? a) la) as r eqn:Hr.
symmetry in Hr.
destruct r as [(n', b)| ]. {
  injection Hfd; clear Hfd; intros; subst n n'.
  exists b, []; cbn.
  apply find_some in Hr; cbn in Hr.
  destruct Hr as (Hx'la, Hba).
  apply Nat.eqb_eq in Hba; subst b.
  apply in_split in Hx'la.
  destruct Hx'la as (l1 & l2 & Hll).
  exists l1, l2.
  now rewrite Hll.
} {
  specialize (IHla Hfd).
  destruct IHla as (y & la1 & la2 & la3 & Hll).
  now exists y, ((n, a) :: la1), la2, la3; rewrite Hll.
}
Qed.

Theorem find_dup_none : ∀ la,
  find_dup la = None → NoDup (map snd la).
Proof.
intros * Hnd.
induction la as [| a]; [ constructor | cbn ].
constructor. {
  cbn in Hnd.
  destruct a as (n, a).
  remember (find _ _) as b eqn:Hb; symmetry in Hb.
  destruct b; [ now destruct p | ].
  specialize (find_none _ _ Hb) as H1; cbn in H1; cbn.
  intros Ha.
  specialize (IHla Hnd).
  clear - IHla H1 Ha.
  induction la as [ | b]; [ easy | ].
  cbn in Ha.
  cbn in IHla.
  destruct Ha as [Ha| Ha]. {
    subst a.
    specialize (H1 b (or_introl eq_refl)).
    now apply Nat.eqb_neq in H1.
  } {
    apply NoDup_cons_iff in IHla.
    destruct IHla as (Hn, Hnd).
    specialize (IHla0 Hnd).
    apply IHla0; [ | easy ].
    intros x Hx.
    now apply H1; right.
  }
} {
  apply IHla.
  cbn in Hnd.
  destruct a as (n, a).
  remember (find _ _) as b eqn:Hb; symmetry in Hb.
  destruct b; [ now destruct p | easy ].
}
Qed.

Theorem pigeonhole : ∀ a b f x x',
  b < a
  → (∀ x, x < a → f x < b)
  → pigeonhole_fun a f = (x, x')
  → x < a ∧ x' < a ∧ x ≠ x' ∧ f x = f x'.
Proof.
intros * Hba Hf Hpf.
unfold pigeonhole_fun in Hpf.
remember (find_dup _) as fd eqn:Hfd.
symmetry in Hfd.
destruct fd as [(n, n') |]. {
  injection Hpf; clear Hpf; intros; subst n n'.
  specialize (find_dup_some _ _ _ Hfd) as (y & la1 & la2 & la3 & Hll).
  assert (Hxy : (x, y) ∈ map (λ n, (n, f n)) (seq 0 a)). {
    rewrite Hll.
    apply in_app_iff.
    now right; left.
  }
  apply in_map_iff in Hxy.
  destruct Hxy as (z & Hxy & Hz).
  injection Hxy; clear Hxy; intros; subst z y.
  assert (Hxy : (x', f x) ∈ map (λ n, (n, f n)) (seq 0 a)). {
    rewrite Hll.
    apply in_app_iff.
    right; right.
    apply in_app_iff.
    now right; left.
  }
  apply in_map_iff in Hxy.
  destruct Hxy as (z & Hxy & Hz').
  injection Hxy; clear Hxy; intros Hff H1; subst z.
  apply in_seq in Hz.
  apply in_seq in Hz'.
  split; [ easy | ].
  split; [ easy | ].
  split; [ | easy ].
  clear - Hll.
  assert (H : NoDup (map (λ n, (n, f n)) (seq 0 a))). {
    apply FinFun.Injective_map_NoDup; [ | apply seq_NoDup ].
    intros b c Hbc.
    now injection Hbc.
  }
  rewrite Hll in H.
  apply NoDup_remove_2 in H.
  intros Hxx; apply H; subst x'.
  apply in_app_iff; right.
  now apply in_app_iff; right; left.
} {
  apply find_dup_none in Hfd.
  rewrite map_map in Hfd.
  cbn in Hfd.
  exfalso; clear x x' Hpf.
  revert a f Hba Hf Hfd.
  induction b; intros; [ now specialize (Hf _ Hba) | ].
  destruct a; [ flia Hba | ].
  apply Nat.succ_lt_mono in Hba.
  remember (filter (λ i, f i =? b) (seq 0 (S a))) as la eqn:Hla.
  symmetry in Hla.
  destruct la as [| x1]. {
    assert (H : ∀ x, x < a → f x < b). {
      intros x Hx.
      destruct (Nat.eq_dec (f x) b) as [Hfxb| Hfxb]. {
        specialize (List_filter_nil _ _ Hla x) as H1.
        assert (H : x ∈ seq 0 (S a)). {
          apply in_seq.
          flia Hx.
        }
        specialize (H1 H); clear H; cbn in H1.
        now apply Nat.eqb_neq in H1.
      }
      assert (H : x < S a) by flia Hx.
      specialize (Hf x H); clear H.
      flia Hf Hfxb.
    }
    specialize (IHb a f Hba H); clear H.
    rewrite <- Nat.add_1_r in Hfd.
    rewrite seq_app in Hfd; cbn in Hfd.
    rewrite map_app in Hfd; cbn in Hfd.
    specialize (NoDup_remove_1 _ _ _ Hfd) as H1.
    now rewrite app_nil_r in H1.
  }
  destruct (Nat.eq_dec b 0) as [Hbz| Hbz]. {
    subst b.
    destruct a; [ flia Hba | ].
    specialize (Hf a) as H1.
    assert (H : a < S (S a)) by flia.
    specialize (H1 H); clear H.
    specialize (Hf (S a) (Nat.lt_succ_diag_r _)) as H2.
    apply Nat.lt_1_r in H1.
    apply Nat.lt_1_r in H2.
    do 2 rewrite <- Nat.add_1_r in Hfd.
    do 2 rewrite seq_app in Hfd; cbn in Hfd.
    rewrite <- app_assoc in Hfd.
    do 2 rewrite map_app in Hfd.
    cbn in Hfd.
    apply NoDup_remove_2 in Hfd.
    apply Hfd.
    apply in_app_iff; right.
    now rewrite H1, Nat.add_1_r, H2; left.
  }
  destruct la as [| x2]. {
    specialize (IHb a (λ i, if lt_dec i x1 then f i else f (i + 1)) Hba).
    cbn in IHb.
    assert (H : ∀ x, x < a → (if lt_dec x x1 then f x else f (x + 1)) < b). {
      intros x Hx.
      destruct (lt_dec x x1) as [Hxx| Hxx]. {
        assert (Hxb : f x ≠ b). {
          intros Hxb.
          assert (H : x ∈ filter (λ i, f i =? b) (seq 0 (S a))). {
            apply filter_In.
            split; [ apply in_seq; cbn; flia Hx | ].
            now apply Nat.eqb_eq.
          }
          rewrite Hla in H.
          destruct H as [H| H]; [ flia Hxx H| easy ].
        }
      specialize (Hf x).
        assert (H : x < S a) by flia Hx.
        specialize (Hf H); clear H.
        flia Hf Hxb.
      }
      apply Nat.nlt_ge in Hxx.
      specialize (Hf (x + 1)).
      assert (H : x + 1 < S a) by flia Hx.
      specialize (Hf H); clear H.
      assert (Hxb : f (x + 1) ≠ b). {
        intros Hxb.
        assert (H : x + 1 ∈ filter (λ i, f i =? b) (seq 0 (S a))). {
          apply filter_In.
          split; [ apply in_seq; cbn; flia Hx | ].
          now apply Nat.eqb_eq.
        }
        rewrite Hla in H.
        destruct H as [H| H]; [ flia Hxx H| easy ].
      }
      flia Hf Hxb.
    }
    specialize (IHb H); clear H.
    apply IHb; clear - Hfd.
    specialize (proj1 (NoDup_map_iff 0 _ _) Hfd) as H1.
    apply (NoDup_map_iff 0).
    intros x x' Hx Hx' Hxx.
    rewrite seq_length in Hx, Hx', H1.
    rewrite seq_nth in Hxx; [ | easy ].
    rewrite seq_nth in Hxx; [ cbn | easy ].
    cbn in Hxx.
    destruct (lt_dec x x1) as [Hxx1| Hxx1]. {
      destruct (lt_dec x' x1) as [Hx'x1| Hx'x1]. {
        apply H1; [ flia Hx | flia Hx' | ].
        rewrite seq_nth; [ | flia Hx ].
        rewrite seq_nth; [ easy | flia Hx' ].
      } {
        apply Nat.nlt_ge in Hx'x1.
        assert (H : x = x' + 1). {
          apply H1; [ flia Hx | flia Hx' | ].
          rewrite seq_nth; [ | flia Hx ].
          rewrite seq_nth; [ easy | flia Hx' ].
        }
        flia Hxx1 Hx'x1 H.
      }
    }
    apply Nat.nlt_ge in Hxx1.
    destruct (lt_dec x' x1) as [Hx'x1| Hx'x1]. {
      assert (H : x + 1 = x'). {
        apply H1; [ flia Hx | flia Hx' | ].
        rewrite seq_nth; [ | flia Hx ].
        rewrite seq_nth; [ easy | flia Hx' ].
      }
      flia Hxx1 Hx'x1 H.
    } {
      apply Nat.nlt_ge in Hx'x1.
      apply (Nat.add_cancel_r _ _ 1).
      apply H1; [ flia Hx | flia Hx' | ].
      rewrite seq_nth; [ | flia Hx ].
      rewrite seq_nth; [ easy | flia Hx' ].
    }
  }
  assert (Hx1 : x1 ∈ x1 :: x2 :: la) by now left.
  assert (Hx2 : x2 ∈ x1 :: x2 :: la) by now right; left.
  rewrite <- Hla in Hx1.
  rewrite <- Hla in Hx2.
  apply filter_In in Hx1.
  apply filter_In in Hx2.
  destruct Hx1 as (Hx1, Hfx1).
  destruct Hx2 as (Hx2, Hfx2).
  apply Nat.eqb_eq in Hfx1.
  apply Nat.eqb_eq in Hfx2.
  assert (H : x1 ≠ x2). {
    intros H; subst x2.
    clear - Hla.
    specialize (seq_NoDup (S a) 0) as H1.
    specialize (NoDup_filter (λ i, f i =? b) _ H1) as H2.
    rewrite Hla in H2.
    apply NoDup_cons_iff in H2.
    destruct H2 as (H2, _); apply H2.
    now left.
  }
  clear - Hfd Hx1 Hx2 H Hfx1 Hfx2.
  remember (seq 0 (S a)) as l; clear a Heql.
  apply H; clear H.
  specialize (proj1 (NoDup_map_iff 0 l (λ x, f x)) Hfd) as H1.
  cbn in H1.
  apply (In_nth _ _ 0) in Hx1.
  apply (In_nth _ _ 0) in Hx2.
  destruct Hx1 as (n1 & Hn1 & Hx1).
  destruct Hx2 as (n2 & Hn2 & Hx2).
  specialize (H1 _ _ Hn1 Hn2) as H2.
  rewrite Hx1, Hx2, Hfx1, Hfx2 in H2.
  rewrite <- Hx1, <- Hx2.
  f_equal.
  now apply H2.
}
Qed.

Theorem Nat_eq_mod_divide_sum : ∀ n a b,
  n ≠ 0
  → a ≡ (n - b mod n) mod n
  → Nat.divide n (a + b).
Proof.
intros * Hnz Hab.
destruct (le_dec n (a + b mod n)) as [Hpx| Hpx]. {
  apply Nat_eq_mod_sub_0 in Hab.
  rewrite Nat_sub_sub_assoc in Hab. 2: {
    split; [ | easy ].
    now apply Nat.lt_le_incl, Nat.mod_upper_bound.
  }
  rewrite <- (Nat.mod_add _ 1) in Hab; [ | easy ].
  rewrite Nat.mul_1_l in Hab.
  rewrite Nat.sub_add in Hab; [ | easy ].
  rewrite Nat.add_mod_idemp_r in Hab; [ | easy ].
  now apply Nat.mod_divide in Hab.
} {
  apply Nat.nle_gt in Hpx.
  symmetry in Hab.
  apply Nat_eq_mod_sub_0 in Hab.
  rewrite Nat_sub_sub_swap, <- Nat.sub_add_distr in Hab.
  remember (a + b mod n) as v eqn:Hv.
  move Hab at bottom.
  destruct (Nat.eq_dec v 0) as [Hvz| Hvz]. 2: {
    destruct v; [ easy | ].
    rewrite Nat.mod_small in Hab; [ | flia Hpx ].
    flia Hpx Hab.
  }
  move Hvz at top; subst v.
  symmetry in Hv.
  apply Nat.eq_add_0 in Hv.
  destruct Hv as (Hxz, Hx'uz).
  subst a; cbn.
  now apply Nat.mod_divide in Hx'uz.
}
Qed.

Lemma odd_prime_divides_sum_two_squares_plus_one : ∀ p,
  prime p → p mod 2 = 1 → ∃ a b n, n < p ∧ a ^ 2 + b ^ 2 + 1 = n * p.
Proof.
intros * Hp Hp2.
assert
  (Ha :
   ∀ a a',
   a ≤ (p - 1) / 2
   → a' ≤ (p - 1) / 2
   → a ≠ a'
   → a ^ 2 ≢ a' ^ 2 mod p). {
  intros * Ha Ha' Haa.
  destruct (lt_dec a' a) as [Haa'| Haa']. {
    now apply le_half_prime_square_diff.
  } {
    assert (H : a < a') by flia Haa Haa'.
    intros H1.
    symmetry in H1.
    revert H1.
    now apply le_half_prime_square_diff.
  }
}
assert
  (Hb :
   ∀ b b',
   b ≤ (p - 1) / 2
   → b' ≤ (p - 1) / 2
   → b ≠ b'
   → (p - (b ^ 2 + 1) mod p) ≢ (p - (b' ^ 2 + 1) mod p) mod p). {
  intros * Hb Hb' Hbb H.
  assert (Hpz : p ≠ 0) by now (intros H1; subst p).
  remember ((b ^ 2 + 1) mod p) as b1 eqn:Hb1.
  remember ((b' ^ 2 + 1) mod p) as b'1 eqn:Hb'1.
  destruct (lt_dec b1 b'1) as [Hbb'| Hbb']. {
    apply Nat_eq_mod_sub_0 in H.
    replace (p - b1 - (p - b'1)) with (b'1 - b1) in H. 2: {
      specialize (Nat.mod_upper_bound (b' ^ 2 + 1) p Hpz) as H1.
      rewrite <- Hb'1 in H1.
      flia Hbb' H1.
    }
    apply Nat.mod_divide in H; [ | easy ].
    destruct H as (k, Hk).
    destruct k; [ flia Hk Hbb' | ].
    apply Nat.add_sub_eq_nz in Hk. 2: {
      now apply Nat.neq_mul_0.
    }
    specialize (Nat.mod_upper_bound (b' ^ 2 + 1) p Hpz) as H1.
    rewrite <- Hb'1, <- Hk in H1.
    flia H1.
  }
  destruct (lt_dec b'1 b1) as [Hbb'1| Hbb'1]. {
    symmetry in H.
    apply Nat_eq_mod_sub_0 in H.
    replace (p - b'1 - (p - b1)) with (b1 - b'1) in H. 2: {
      specialize (Nat.mod_upper_bound (b ^ 2 + 1) p Hpz) as H1.
      rewrite <- Hb1 in H1.
      flia Hbb' H1.
    }
    apply Nat.mod_divide in H; [ | easy ].
    destruct H as (k, Hk).
    destruct k; [ flia Hk Hbb'1 | ].
    apply Nat.add_sub_eq_nz in Hk. 2: {
      now apply Nat.neq_mul_0.
    }
    specialize (Nat.mod_upper_bound (b ^ 2 + 1) p Hpz) as H1.
    rewrite <- Hb1, <- Hk in H1.
    flia H1.
  }
  replace b'1 with b1 in * by flia Hbb' Hbb'1.
  clear Hbb' Hbb'1 H.
  rewrite Hb'1 in Hb1.
  destruct (lt_dec b b') as [Hbb'| Hbb']. {
    revert Hb1.
    now apply le_half_prime_succ_square_diff.
  } {
    symmetry in Hb1.
    revert Hb1.
    apply le_half_prime_succ_square_diff; try easy.
    apply Nat.nlt_ge in Hbb'.
    flia Hbb Hbb'.
  }
}
(* pigeonhole *)
assert (Hpz : p ≠ 0) by now (intros H1; subst p).
specialize (pigeonhole (p + 1) p) as H1.
set (u := (p - 1) / 2) in *.
set
  (f i :=
     if le_dec i u then (i ^ 2) mod p
     else (p - ((i - (u + 1)) ^ 2 + 1) mod p) mod p).
specialize (H1 f).
remember (pigeonhole_fun (p + 1) f) as xx eqn:Hxx.
symmetry in Hxx.
destruct xx as (x, x').
assert (H : p < p + 1) by flia.
specialize (H1 x x' H); clear H.
assert (H : ∀ x, x < p + 1 → f x < p). {
  intros x1 Hx.
  unfold f; cbn - [ "/" ].
  destruct (le_dec x1 u); now apply Nat.mod_upper_bound.
}
specialize (H1 H eq_refl); clear H.
destruct H1 as (Hxp & Hx'p & Hxx' & Hfxx).
unfold f in Hfxx.
destruct (le_dec x u) as [Hxu| Hxu]. {
  destruct (le_dec x' u) as [Hx'u| Hx'u]. {
    now specialize (Ha x x' Hxu Hx'u Hxx') as H1.
  }
  apply Nat.nle_gt in Hx'u.
  specialize (Nat_eq_mod_divide_sum p _ _ Hpz Hfxx) as H1.
  rewrite Nat.add_assoc in H1.
  destruct H1 as (k, Hk).
  exists x, (x' - (u + 1)), k.
  split; [ | easy ].
  apply (Nat.mul_lt_mono_pos_r p); [ flia Hpz | ].
  rewrite <- Hk.
  apply (le_lt_trans _ (u ^ 2 + u ^ 2 + 1)). {
    apply Nat.add_le_mono_r.
    apply Nat.add_le_mono; [ now apply Nat.pow_le_mono_l | ].
    apply Nat.pow_le_mono_l.
    apply (Nat.add_le_mono_r _ _ (u + 1)).
    rewrite Nat.sub_add; [ | flia Hx'u ].
    rewrite Nat.add_assoc.
    replace (u + u) with (2 * u) by flia.
    unfold u.
    rewrite <- Nat.divide_div_mul_exact; [ | easy | ]. 2: {
      apply Nat.mod_divide; [ easy | ].
      specialize (Nat.div_mod p 2 (Nat.neq_succ_0 _)) as H2.
      rewrite Hp2 in H2.
      rewrite H2, Nat.add_sub, Nat.mul_comm.
      now apply Nat.mod_mul.
    }
    rewrite Nat.mul_comm, Nat.div_mul; [ | easy ].
    flia Hx'p.
  } {
...
    replace (u ^ 2 + u ^ 2) with (2 * u ^ 2) by flia.
    unfold u.
    specialize (Nat.div_mod (p - 1) 2 (Nat.neq_succ_0 _)) as H1.
    assert (H : (p - 1) mod 2 = 0). {
      specialize (Nat.div_mod p 2 (Nat.neq_succ_0 _)) as H.
      rewrite H, Hp2, Nat.add_sub, Nat.mul_comm.
      now apply Nat.mod_mul.
    }
    rewrite H, Nat.add_0_r in H1; clear H.
    rewrite Nat.pow_2_r, Nat.mul_assoc.
    rewrite <- H1, Nat.mul_comm.
    rewrite H1 at 1.
    rewrite (Nat.mul_comm 2).
    rewrite Nat.div_mul; [ | easy ].
    specialize (prime_ge_2 p Hp) as H2p.
    apply (lt_trans _ ((p - 1) * (p - 1) + 1)). {
      apply Nat.add_lt_mono_r.
      apply Nat.mul_lt_mono_pos_r; [ flia H2p | ].
      apply (Nat.mul_lt_mono_pos_l 2); [ flia | ].
      rewrite <- H1.
      flia H2p.
    } {
      rewrite Nat.mul_sub_distr_l, Nat.mul_1_r.
      rewrite Nat.mul_sub_distr_r, Nat.mul_1_l.
      rewrite Nat_sub_sub_assoc. 2: {
        split; [ flia H2p | ].
        etransitivity; [ | apply Nat.le_add_r ].
        apply Nat.le_add_le_sub_r.
        now apply Nat.add_le_mul.
      }
      rewrite <- Nat_sub_sub_distr.
...
        rewrite <- Nat.add_sub_swap.
        replace p with (p * 1) at 4 by apply Nat.mul_1_r.
        rewrite <- Nat.mul_sub_distr_l.
...
  now exists x, (x' - (u + 1)).
}
apply Nat.nle_gt in Hxu.
destruct (le_dec x' u) as [Hx'u| Hx'u]. {
  symmetry in Hfxx.
  specialize (Nat_eq_mod_divide_sum p _ _ Hpz Hfxx) as H1.
  rewrite Nat.add_assoc in H1.
  now exists x', (x - (u + 1)).
}
apply Nat.nle_gt in Hx'u.
specialize (Hb (x - (u + 1)) (x' - (u + 1))) as H1.
exfalso; apply H1; [ | | | easy ]. {
  apply (Nat.add_le_mono_r _ _ (u + 1)).
  rewrite Nat.sub_add; [ | flia Hxu ].
  replace (u + (u + 1)) with (2 * u + 1) by flia.
  unfold u.
  rewrite <- Nat.divide_div_mul_exact; [ | easy | ]. 2: {
    apply Nat.mod_divide; [ easy | ].
    specialize (Nat.div_mod p 2 (Nat.neq_succ_0 _)) as H2.
    rewrite Hp2 in H2.
    rewrite H2, Nat.add_sub, Nat.mul_comm.
    now apply Nat.mod_mul.
  }
  rewrite Nat.mul_comm, Nat.div_mul; [ | easy ].
  flia Hxp.
} {
  apply (Nat.add_le_mono_r _ _ (u + 1)).
  rewrite Nat.sub_add; [ | flia Hx'u ].
  replace (u + (u + 1)) with (2 * u + 1) by flia.
  unfold u.
  rewrite <- Nat.divide_div_mul_exact; [ | easy | ]. 2: {
    apply Nat.mod_divide; [ easy | ].
    specialize (Nat.div_mod p 2 (Nat.neq_succ_0 _)) as H2.
    rewrite Hp2 in H2.
    rewrite H2, Nat.add_sub, Nat.mul_comm.
    now apply Nat.mod_mul.
  }
  rewrite Nat.mul_comm, Nat.div_mul; [ | easy ].
  flia Hx'p.
} {
  intros H; apply Hxx'.
  apply (Nat.add_cancel_r _ _ (u + 1)) in H.
  rewrite Nat.sub_add in H; [ | flia Hxu ].
  rewrite Nat.sub_add in H; [ | flia Hx'u ].
  easy.
}
Qed.

Inspect 1.
