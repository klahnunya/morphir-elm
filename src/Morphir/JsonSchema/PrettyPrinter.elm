module Morphir.JsonSchema.PrettyPrinter exposing (..)

import Dict exposing (Dict)
import Json.Encode as Encode
import Morphir.IR.Name as Name
import Morphir.IR.Path as Path
import Morphir.JsonSchema.AST exposing (QualifiedName, Schema, SchemaType)


encodeSchema : Schema -> String
encodeSchema schema =
    Encode.object
        [ ( "$id", Encode.string schema.id )
        , ( "$schema", Encode.string schema.schemaVersion )
        , ( "$defs", encodeDefinitions schema.definitions )
        ]
        |> Encode.encode 4


encodeDefinitions : Dict QualifiedName SchemaType -> Encode.Value
encodeDefinitions schemaTypeByQualifiedName =
    let
        qualifiedNameToString ( path, name ) =
            String.join "." [ Path.toString Name.toTitleCase "." path, Name.toTitleCase name ]

        schemaTypeToString schemaType =
            Encode.object []
    in
    Encode.dict qualifiedNameToString schemaTypeToString schemaTypeByQualifiedName
