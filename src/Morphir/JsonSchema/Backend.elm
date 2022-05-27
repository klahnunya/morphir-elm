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

{-| This module encapsulates the JSON Schema backend. It takes the Morphir IR as the input and returns an in-memory
    representation of files generated. The consumer is responsible for getting the input IR and saving the output
    to the file-system.
-}
module Morphir.JsonSchema.Backend exposing (..)


import Morphir.File.FileMap exposing (FileMap)
import Morphir.IR.Distribution as Distribution exposing (Distribution)
import Morphir.IR.Package as Package


type alias Options = {}


{-| Entry point for the JSON Schema backend. It takes the Morphir IR as the input and returns an in-memory
representation of files generated.
-}

mapDistribution : Options -> Distribution -> FileMap
mapDistribution opt distro =
    case distro of
        Distribution.Library packageName dependencies packageDef ->
            case opt.limitToModules of
                Just modulesToInclude ->
                    mapPackageDefinition opt distro packageName (Package.selectModules modulesToInclude packageName packageDef)

                Nothing ->
                    mapPackageDefinition opt distro packageName packageDef
