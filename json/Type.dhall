-- vim: ft=dhall
let u/ = ../libxs/util/...

let json/ = u/.json/

let show/ = ../show/...

let fun/ = ../fun/...

let Show = show/.Show

let Json = json/.Type

let Map = u/.Map Text

let ToJson
    : Type → Type
    = λ(a : Type) → a → Json

let T =
      { ToJson : Type → Type
      , Map : Type → Type
      , Json : Type
      , string : fun/.make/ Show ToJson
      , list : fun/.fog/ ToJson List
      , map : fun/.fog/ ToJson Map
      }

in  { Map, Json, json/, u/, ToJson, Type = T }
