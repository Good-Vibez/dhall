{- vim: set ft=dhall : -}
let T
    : Type → Type → Type
    = λ(h : Type) → λ(t : Type) → { head : h, tail : t }

let Nil = < nil >

let t = λ(h : Type) → λ(t : Type) → λ(head : h) → λ(tail : t) → { head, tail }

let nil = Nil.nil

in  { T, Nil, nil, t }
