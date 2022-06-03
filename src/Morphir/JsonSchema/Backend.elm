{-
   Copyright 2020 Morgan Stanley

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-}


module Morphir.JsonSchema.Backend exposing (..)

{-| This module encapsulates the JSON Schema backend. It takes the Morphir IR as the input and returns an in-memory
representation of files generated. The consumer is responsible for getting the input IR and saving the output
to the file-system.
-}

import Dict exposing (Dict)
import Morphir.File.FileMap exposing (FileMap)
import Morphir.IR.AccessControlled exposing (AccessControlled)
import Morphir.IR.Distribution as Distribution exposing (Distribution)
import Morphir.IR.Module as Module exposing (ModuleName)
import Morphir.IR.Name as Name exposing (Name)
import Morphir.IR.Package as Package exposing (PackageName)
import Morphir.IR.Path as Path exposing (Path)
import Morphir.IR.Type as Type exposing (Type)
import Morphir.JsonSchema.AST exposing (QualifiedName, Schema, SchemaType)
import Morphir.JsonSchema.PrettyPrinter exposing (encodeSchema)


type alias Options =
    {}


type Error
    = Error


{-| Entry point for the JSON Schema backend. It takes the Morphir IR as the input and returns an in-memory
representation of files generated.
-}
mapDistribution : Options -> Distribution -> FileMap
mapDistribution opt distro =
    case distro of
        Distribution.Library packageName _ packageDef ->
            mapPackageDefinition packageName packageDef


mapPackageDefinition : PackageName -> Package.Definition ta (Type ()) -> FileMap
mapPackageDefinition packageName packageDefinition =
    packageDefinition
        |> generateSchema packageName
        |> encodeSchema
        |> Dict.singleton ( [], Path.toString Name.toTitleCase "." packageName ++ ".json" )


generateSchema : PackageName -> Package.Definition ta (Type ()) -> Schema
generateSchema packageName packageDefinition =
    let
        schemaTypeDefinitions =
            packageDefinition.modules
                |> Dict.foldl
                    (\modName modDef listSoFar ->
                        extractTypes modName modDef.value
                            |> List.map
                                (\( qualifiedName, typeDef ) ->
                                    mapType qualifiedName typeDef
                                )
                            |> (\lst -> listSoFar ++ lst)
                    )
                    []
                |> Dict.fromList
    in
    { dirPath = []
    , fileName = ""
    , id = "https://example.com/" ++ Path.toString Name.toSnakeCase "-" packageName ++ ".schema.json"
    , schemaVersion = "https://json-schema.org/draft/2020-12/schema"
    , definitions = schemaTypeDefinitions
    }


extractTypes : ModuleName -> Module.Definition ta (Type ()) -> List ( QualifiedName, Type.Definition ta )
extractTypes modName definition =
    definition.types
        |> Dict.toList
        |> List.map
            (\( name, accessControlled ) ->
                ( ( modName, name ), accessControlled.value.value )
            )


mapType : QualifiedName -> Type.Definition ta -> ( QualifiedName, SchemaType )
mapType qualifiedName definition =
    ( qualifiedName, {} )
