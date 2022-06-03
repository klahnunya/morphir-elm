module Morphir.JsonSchema.AST exposing (..)

import Dict exposing (Dict)
import Morphir.IR.Name exposing (Name)
import Morphir.IR.Path exposing (Path)


type alias QualifiedName =
    ( Path, Name )


type alias Schema =
    { dirPath : List String
    , fileName : String
    , id : String
    , schemaVersion : String
    , definitions : Dict QualifiedName SchemaType
    }


type alias SchemaType =
    {}
