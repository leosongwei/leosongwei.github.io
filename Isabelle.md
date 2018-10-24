Isabelle Tips
=============

tags: theorem-prover; Isabelle

* defer an subgoal, to deal with it later:

``` Isabelle
  ...
  apply auto (* Have 2 subgoals, prove the second first. *)
  defer
  apply force
  ...
```

## rule_tac

## OF WHERE THEN

'5.15.1 Modifying a Theorem using of, where and THEN' (tutorial.pdf)

* `[OF ...]`
* `[where ...]`
  - `thm list_push[where a="1::nat"]`
      - `[1::nat] @ [?b::nat] = [1::nat, ?b]`

## induction

* `apply (induct xs arbitrary:a rule: pal_lists.induct)`

## definition

``` Isabelle
definition duplist :: "'a list ⇒ 'a list"
  where "duplist xs ≡ xs @ xs"
```

## substitution

* apply subst

``` Isabelle
lemma list_push: "[a]@[b] = a # [b]"
  by simp

lemma "[x]@[y]@[z] = x # (y # [z])"
  (* [x] @ [y] @ [z] = [x, y, z] *)
  apply (subst list_push)
  (* [x] @ [y, z] = [x, y, z] *)
  by simp
```

* rule (ssbust ...)

``` Isabelle
thm ssbust (* ?t = ?s ⟹ ?P ?s ⟹ ?P ?t *)
thm ssubst[OF list_push] (* (?P::?'a1 List.list ⇒ bool) [?a1::?'a1, ?b1::?'a1] ⟹ ?P ([?a1] @ [?b1]) *)
```
