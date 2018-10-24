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

* subst

``` Isabelle
lemma list_push: "[a]@[b] = a # [b]"
  by simp

lemma "[x]@[y]@[z] = x # (y # [z])"
  (* [x] @ [y] @ [z] = [x, y, z] *)
  apply (subst list_push)
  (* [x] @ [y, z] = [x, y, z] *)
  by simp
```
