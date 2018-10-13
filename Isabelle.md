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
