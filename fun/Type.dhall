-- vim: ft=dhall
let F
    : Kind
    = Type -> Type

let T
    : Kind
    = Type

in  { F, T, Type = { make/ : F -> F -> T, fog/ : F -> F -> T } }
