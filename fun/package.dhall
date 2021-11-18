-- vim: ft=dhall
let Typ = ./Type.dhall

let F = Typ.F

let T = Typ.T

let make/ = λ(f : F) → λ(g : F) → ∀(x : T) → f x → g x

let fog/ = λ(f : F) → λ(g : F) → ∀(x : T) → f x → f (g x)

in  { make/, fog/ } : Typ.Type
