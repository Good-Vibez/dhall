let u/ = ../libxs/util/...

let show/ = ../show/...

let to_json/ = ../json/...

let Show = show/.Show

let ToJson = to_json/.ToJson

let Json = to_json/.Json

let Map = to_json/.Map

let Path = List Text

let Capability
    : Type
    = < create | read | update | list | delete | sudo | deny >

let AllowedParams
    : Type
    = List Text

let Entry
    : Type
    = { path : Path
      , capabilities : List Capability
      , allowed_parameters : Map AllowedParams
      }

let Param
    : Type
    = { identity :
          { entity :
              { id : Text
              , name : Text
              , metadata : Text → Text
              , aliases :
                  Text → { id : Text, name : Text, metadata : Text → Text }
              }
          , groups :
              { ids : Text → { name : Text, metadata : Text → Text }
              , names : Text → { id : Text, metadata : Text → Text }
              }
          }
      }

in  { Type =
        { to_json : ToJson Entry
        , to_hcl : Show Entry
        , param : Param
        , Capability/show : Show Capability
        , Capability/to_json : ToJson Capability
        , Capabilities/to_json : ToJson (List Capability)
        , AllowedParamsList/to_json : ToJson AllowedParams
        , AllowedParams/to_json : ToJson (Map AllowedParams)
        }
    , Capability
    , ToJson
    , Map
    , Show
    , AllowedParams
    , Entry
    , Json
    , u/
    , to_json/
    }
