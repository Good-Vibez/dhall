-- vim: ft=dhall
let T = ./Type.dhall

let u/ = ../libxs/util/...

let json/ = u/.json/

let Json = json/.Type

let Map = T.Map

let ToJson
    : Type → Type
    = λ(a : Type) → a → Json

let list =
      λ(a : Type) →
      λ(to_json : a → Json) →
      λ(la : List a) →
        json/.array (u/.list/map a Json to_json la)

let map =
      λ(a : Type) →
      λ(to_json : a → Json) →
      λ(ma : Map a) →
        json/.object (u/.map/map Text a Json to_json ma)

let string =
      λ(a : Type) →
      λ(show : a → Text) →
        u/.fun/compose a Text Json show json/.string

in  ({ ToJson, Json, Map, string, map, list } : T.Type) ∧ { json/ }
