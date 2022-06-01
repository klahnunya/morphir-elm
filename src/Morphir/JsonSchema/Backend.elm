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
import Morphir.IR.FQName exposing (FQName)
import Morphir.IR.Module as Module exposing (ModuleName)
import Morphir.IR.Name exposing (Name)
import Morphir.IR.Package as Package
import Morphir.IR.Type as Type exposing (Type)
import Set exposing (Set)


type alias Options =
    {}


type alias Schema =
    { id : String
    , schema : String
    , definitions : Dict FQName Definition
    }


type alias CompilationUnit =
    { dirPath : List String
    , fileName : String
    , fileContent : String
    }


type alias Definition =
    {}


type Error
    = Error


{-| Entry point for the JSON Schema backend. It takes the Morphir IR as the input and returns an in-memory
representation of files generated.
-}
mapDistribution : Options -> Distribution -> FileMap
mapDistribution opt distro =
    case distro of
        Distribution.Library packageName dependencies packageDef ->
            mapPackageDefinition opt distro packageName packageDef


mapPackageDefinition : Options -> Distribution -> Package.PackageName -> Package.Definition ta (Type ()) -> FileMap
mapPackageDefinition opt distribution packagePath packageDef =
    Dict.toList packageDef.modules
        |> List.map
            (\( modulePath, moduleImpl ) ->
                moduleImpl.value.types
                    |> Dict.toList
                    |> List.map
                        (\( name, accessDocumentedTypeDef ) ->
                            let
                                fqName =
                                    ( packagePath, modulePath, name )
                            in
                            mapType fqName accessDocumentedTypeDef.value.value
                        )
            )
        |> Dict.fromList


extractTypes : Module.Definition ta (Type ()) -> List ( Name, Type.Definition ta )
extractTypes definition =
    definition.types
        |> Dict.toList
        |> List.map


mapType : FQName -> Type.Definition ta -> ( FQName, Definition )
mapType typ =
    Debug.todo "Todo"
