-- vim: ft=dhall
let Show
    : Type → Type
    = λ(a : Type) → a → Text

in  { Show }
