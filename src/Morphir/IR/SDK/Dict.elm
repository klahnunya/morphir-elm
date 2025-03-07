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


module Morphir.IR.SDK.Dict exposing (dictType, fromListValue, moduleName, moduleSpec, nativeFunctions, typeSpec)

import Dict
import Morphir.IR.Documented exposing (Documented)
import Morphir.IR.Literal exposing (Literal(..))
import Morphir.IR.Module as Module exposing (ModuleName)
import Morphir.IR.Name as Name
import Morphir.IR.Path as Path
import Morphir.IR.SDK.Basics exposing (boolType, intType)
import Morphir.IR.SDK.Common exposing (tFun, tVar, toFQName, vSpec)
import Morphir.IR.SDK.List exposing (listType)
import Morphir.IR.SDK.Maybe exposing (just, maybeType, nothing)
import Morphir.IR.Type as Type exposing (Specification(..), Type(..))
import Morphir.IR.Value as Value exposing (RawValue, Value)
import Morphir.Value.Error exposing (Error(..))
import Morphir.Value.Native as Native
import Morphir.Value.Native.Comparable exposing (compareValue)


moduleName : ModuleName
moduleName =
    Path.fromString "Dict"


typeSpec : Specification ()
typeSpec =
    DerivedTypeSpecification [["comparable"], ["v"] ]
        { baseType = listType () (Type.Tuple () [ tVar "comparable", tVar "v" ])
        , toBaseType = toFQName moduleName "toList"
        , fromBaseType = toFQName moduleName "fromList"
        }


moduleSpec : Module.Specification ()
moduleSpec =
    { types =
        Dict.fromList
            [ ( Name.fromString "Dict", typeSpec |> Documented "Type that represents a dictionary of key-value pairs." )
            ]
    , values =
        Dict.fromList
            [ vSpec "empty" [] (dictType () (tVar "k") (tVar "v"))
            , vSpec "singleton" [ ( "key", tVar "comparable" ), ( "value", tVar "v" ) ] (dictType () (tVar "comparable") (tVar "v"))
            , vSpec "insert"
                [ ( "key", tVar "comparable" )
                , ( "value", tVar "v" )
                , ( "dict", dictType () (tVar "comparable") (tVar "v") )
                ]
                (dictType () (tVar "comparable") (tVar "v"))
            , vSpec "update"
                [ ( "key", tVar "comparable" )
                , ( "f", tFun [ maybeType () (tVar "v") ] (maybeType () (tVar "v")) )
                , ( "dict", dictType () (tVar "comparable") (tVar "v") )
                ]
                (dictType () (tVar "comparable") (tVar "v"))
            , vSpec "remove"
                [ ( "key", tVar "comparable" )
                , ( "dict", dictType () (tVar "comparable") (tVar "v") )
                ]
                (dictType () (tVar "comparable") (tVar "v"))
            , vSpec "isEmpty" [ ( "dict", dictType () (tVar "comparable") (tVar "v") ) ] (boolType ())
            , vSpec "member" [ ( "key", tVar "comparable" ), ( "dict", dictType () (tVar "comparable") (tVar "v") ) ] (boolType ())
            , vSpec "get" [ ( "key", tVar "comparable" ), ( "dict", dictType () (tVar "comparable") (tVar "v") ) ] (maybeType () (tVar "v"))
            , vSpec "size" [ ( "dict", dictType () (tVar "comparable") (tVar "v") ) ] (intType ())
            , vSpec "keys" [ ( "dict", dictType () (tVar "k") (tVar "v") ) ] (listType () (tVar "k"))
            , vSpec "values" [ ( "dict", dictType () (tVar "k") (tVar "v") ) ] (listType () (tVar "v"))
            , vSpec "toList" [ ( "dict", dictType () (tVar "k") (tVar "v") ) ] (listType () (Type.Tuple () [ tVar "k", tVar "v" ]))
            , vSpec "fromList" [ ( "list", listType () (Type.Tuple () [ tVar "comparable", tVar "v" ]) ) ] (dictType () (tVar "comparable") (tVar "v"))
            , vSpec "map"
                [ ( "f", tFun [ tVar "k", tVar "a" ] (tVar "b") )
                , ( "dict", dictType () (tVar "k") (tVar "a") )
                ]
                (dictType () (tVar "k") (tVar "b"))
            , vSpec "foldl"
                [ ( "f", tFun [ tVar "k", tVar "v", tVar "b" ] (tVar "b") )
                , ( "z", tVar "b" )
                , ( "list", dictType () (tVar "k") (tVar "v") )
                ]
                (tVar "b")
            , vSpec "foldr"
                [ ( "f", tFun [ tVar "k", tVar "v", tVar "b" ] (tVar "b") )
                , ( "z", tVar "b" )
                , ( "list", dictType () (tVar "k") (tVar "v") )
                ]
                (tVar "b")
            , vSpec "filter"
                [ ( "f", tFun [ tVar "comparable", tVar "v" ] (boolType ()) )
                , ( "dict", dictType () (tVar "comparable") (tVar "v") )
                ]
                (dictType () (tVar "comparable") (tVar "v"))
            , vSpec "partition"
                [ ( "f", tFun [ tVar "comparable", tVar "v" ] (boolType ()) )
                , ( "dict", dictType () (tVar "comparable") (tVar "v") )
                ]
                (Type.Tuple () [ dictType () (tVar "comparable") (tVar "v"), dictType () (tVar "comparable") (tVar "v") ])
            , vSpec "union"
                [ ( "dict1", dictType () (tVar "comparable") (tVar "v") )
                , ( "dict2", dictType () (tVar "comparable") (tVar "v") )
                ]
                (dictType () (tVar "comparable") (tVar "v"))
            , vSpec "intersect"
                [ ( "dict1", dictType () (tVar "comparable") (tVar "v") )
                , ( "dict2", dictType () (tVar "comparable") (tVar "v") )
                ]
                (dictType () (tVar "comparable") (tVar "v"))
            , vSpec "diff"
                [ ( "dict1", dictType () (tVar "comparable") (tVar "v") )
                , ( "dict2", dictType () (tVar "comparable") (tVar "v") )
                ]
                (dictType () (tVar "comparable") (tVar "v"))
            , vSpec "merge"
                [ ( "leftOnly", tFun [ tVar "comparable", tVar "a", tVar "result" ] (tVar "result") )
                , ( "both", tFun [ tVar "comparable", tVar "a", tVar "b", tVar "result" ] (tVar "result") )
                , ( "rightOnly", tFun [ tVar "comparable", tVar "b", tVar "result" ] (tVar "result") )
                , ( "dictLeft", dictType () (tVar "comparable") (tVar "a") )
                , ( "dictRight", dictType () (tVar "comparable") (tVar "b") )
                , ( "input", tVar "result" )
                ]
                (tVar "result")
            ]
    , doc = Just "Contains Dict (representing a collection of key-value pairs, where the key is a comparable value), and associated functions. "
    }


dictType : a -> Type a -> Type a -> Type a
dictType attributes keyType valueType =
    Reference attributes (toFQName moduleName "dict") [ keyType, valueType ]


fromListValue : va -> Value ta va -> Value ta va
fromListValue a list =
    Value.Apply a (Value.Reference a ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) list



nativeFunctions : List ( String, Native.Function )
nativeFunctions =
    [ ( "empty"
      , \eval args ->
            Ok (Value.Apply () (Value.Reference () ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) (Value.List () []))
      )
    , ( "singleton"
      , Native.binaryStrict
            (\key value ->
                Ok
                    (Value.Apply ()
                        (Value.Reference ()
                            ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )
                        )
                        (Value.List () [ Value.Tuple () [ key, value ] ])
                    )
            )
      )

    {- update -}
    , ( "insert"
      , Native.trinaryStrict
            (\keyToAdd valueToAdd dict ->
                case dict of
                    Value.Apply _ (Value.Reference _ ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) arg ->
                        case arg of
                            Value.List _ list ->
                                let
                                    find initList updatedList =
                                        case initList of
                                            [] ->
                                                Ok (updatedList ++ [ Value.Tuple () [ keyToAdd, valueToAdd ] ])

                                            head :: tail ->
                                                case head of
                                                    Value.Tuple _ [ key, _ ] ->
                                                        case compareValue key keyToAdd of
                                                            Ok LT ->
                                                                find tail (List.concat [ updatedList, [ head ] ])

                                                            Ok GT ->
                                                                Ok (List.concat [ updatedList, [ Value.Tuple () [ keyToAdd, valueToAdd ], head ], tail ])

                                                            Ok EQ ->
                                                                Ok (List.concat [ updatedList, [ Value.Tuple () [ keyToAdd, valueToAdd ] ], tail ])

                                                            Err error ->
                                                                Err error

                                                    _ ->
                                                        Err TupleExpected
                                in
                                find list [] |> Result.map (\updatedList -> Value.List () updatedList |> Value.Apply () (Value.Reference () ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )))

                            _ ->
                                Err (ExpectedList arg)

                    _ ->
                        Err (UnexpectedArguments [ dict ])
            )
      )
    , ( "update"
      , \eval args ->
            case args of
                [ arg1, fun, arg2 ] ->
                    Result.map2
                        (\keyToUpdate dict ->
                            case dict of
                                Value.Apply _ (Value.Reference _ ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) arg ->
                                    case arg of
                                        Value.List _ list ->
                                            let
                                                find : List RawValue -> List RawValue -> Result Error (List RawValue)
                                                find initList updatedList =
                                                    case initList of
                                                        [] ->
                                                            Ok updatedList

                                                        head :: tail ->
                                                            case head of
                                                                Value.Tuple _ [ key, value ] ->
                                                                    case compareValue key keyToUpdate of
                                                                        Ok LT ->
                                                                            find tail (List.append updatedList [ head ])

                                                                        Ok GT ->
                                                                            find [] (List.append updatedList tail)

                                                                        Ok EQ ->
                                                                            eval (Value.Apply () fun value)
                                                                                |> Result.andThen
                                                                                    (\updatedValue ->
                                                                                        find [] (List.concat [ updatedList, [ Value.Tuple () [ keyToUpdate, updatedValue ] ], tail ])
                                                                                    )

                                                                        Err error ->
                                                                            Err error

                                                                _ ->
                                                                    Err TupleExpected
                                            in
                                            find list [] |> Result.map (\updatedList -> Value.List () updatedList |> Value.Apply () (Value.Reference () ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )))

                                        _ ->
                                            Err (ExpectedList arg)

                                _ ->
                                    Err (UnexpectedArguments [ dict ])
                        )
                        (eval arg1)
                        (eval arg2)
                        |> Result.andThen identity

                _ ->
                    Err (UnexpectedArguments args)
      )
    , ( "remove"
      , Native.binaryStrict
            (\keyToRemove dict ->
                case dict of
                    Value.Apply _ (Value.Reference _ ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) arg ->
                        case arg of
                            Value.List _ list ->
                                let
                                    find l ans =
                                        case l of
                                            [] ->
                                                Ok ans

                                            head :: tail ->
                                                case head of
                                                    Value.Tuple _ [ key, _ ] ->
                                                        if key == keyToRemove then
                                                            find tail ans

                                                        else
                                                            find tail (List.append ans [ head ])

                                                    _ ->
                                                        Err TupleExpected
                                in
                                find list [] |> Result.map (\updatedList -> Value.List () updatedList |> Value.Apply () (Value.Reference () ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )))

                            _ ->
                                Err (ExpectedList arg)

                    _ ->
                        Err (UnexpectedArguments [ dict ])
            )
      )
    , ( "isEmpty"
      , Native.unaryStrict
            (\_ dict ->
                case dict of
                    Value.Apply _ (Value.Reference _ ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) arg ->
                        case arg of
                            Value.List _ list ->
                                let
                                    find l =
                                        case l of
                                            [] ->
                                                Ok (Value.Literal () (BoolLiteral True))

                                            head :: tail ->
                                                case head of
                                                    Value.Tuple _ [ key, value ] ->
                                                        Ok (Value.Literal () (BoolLiteral False))

                                                    _ ->
                                                        Err TupleExpected
                                in
                                find list

                            _ ->
                                Err (ExpectedList arg)

                    _ ->
                        Err (UnexpectedArguments [ dict ])
            )
      )
    , ( "member"
      , Native.binaryStrict
            (\keyToGet dict ->
                case dict of
                    Value.Apply _ (Value.Reference _ ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) arg ->
                        case arg of
                            Value.List _ list ->
                                let
                                    find l =
                                        case l of
                                            [] ->
                                                Ok (Value.Literal () (BoolLiteral False))

                                            head :: tail ->
                                                case head of
                                                    Value.Tuple _ [ key, value ] ->
                                                        if key == keyToGet then
                                                            Ok (Value.Literal () (BoolLiteral True))

                                                        else
                                                            find tail

                                                    _ ->
                                                        Err TupleExpected
                                in
                                find list

                            _ ->
                                Err (ExpectedList arg)

                    _ ->
                        Err (UnexpectedArguments [ dict ])
            )
      )
    , ( "get"
      , Native.binaryStrict
            (\keyToGet dict ->
                case dict of
                    Value.Apply _ (Value.Reference _ ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) arg ->
                        case arg of
                            Value.List _ list ->
                                let
                                    find l =
                                        case l of
                                            [] ->
                                                Ok (nothing ())

                                            head :: tail ->
                                                case head of
                                                    Value.Tuple _ [ key, value ] ->
                                                        if key == keyToGet then
                                                            Ok (just () value)

                                                        else
                                                            find tail

                                                    _ ->
                                                        Err TupleExpected
                                in
                                find list

                            _ ->
                                Err (ExpectedList arg)

                    _ ->
                        Err (UnexpectedArguments [ dict ])
            )
      )
    , ( "size"
      , Native.unaryStrict
            (\_ dict ->
                case dict of
                    Value.Apply _ (Value.Reference _ ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) arg ->
                        case arg of
                            Value.List _ list ->
                                let
                                    find l length =
                                        case l of
                                            [] ->
                                                Ok length

                                            head :: tail ->
                                                case head of
                                                    Value.Tuple _ [ _, _ ] ->
                                                        find tail (length + 1)

                                                    _ ->
                                                        Err TupleExpected
                                in
                                find list 0 |> Result.map (\len -> Value.Literal () (WholeNumberLiteral len))

                            _ ->
                                Err (ExpectedList arg)

                    _ ->
                        Err (UnexpectedArguments [ dict ])
            )
      )
    , ( "keys"
      , Native.unaryStrict
            (\_ dict ->
                case dict of
                    Value.Apply _ (Value.Reference _ ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) arg ->
                        case arg of
                            Value.List _ list ->
                                let
                                    find l keysList =
                                        case l of
                                            [] ->
                                                Ok keysList

                                            head :: tail ->
                                                case head of
                                                    Value.Tuple _ [ key, _ ] ->
                                                        find tail (List.append keysList [ key ])

                                                    _ ->
                                                        Err TupleExpected
                                in
                                find list [] |> Result.map (\keyList -> Value.List () keyList)

                            _ ->
                                Err (ExpectedList arg)

                    _ ->
                        Err (UnexpectedArguments [ dict ])
            )
      )
    , ( "value"
      , Native.unaryStrict
            (\_ dict ->
                case dict of
                    Value.Apply _ (Value.Reference _ ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) arg ->
                        case arg of
                            Value.List _ list ->
                                let
                                    find l valuesList =
                                        case l of
                                            [] ->
                                                Ok valuesList

                                            head :: tail ->
                                                case head of
                                                    Value.Tuple _ [ _, value ] ->
                                                        find tail (List.append valuesList [ value ])

                                                    _ ->
                                                        Err TupleExpected
                                in
                                find list [] |> Result.map (\valueList -> Value.List () valueList)

                            _ ->
                                Err (ExpectedList arg)

                    _ ->
                        Err (UnexpectedArguments [ dict ])
            )
      )
    , ( "toList", Native.unaryStrict (\_ arg -> 
        case arg of
            Value.Apply _ (Value.Reference _ ( [ [ "morphir" ], [ "s", "d", "k" ] ], [ [ "dict" ] ], [ "from", "list" ] )) list ->
                Ok list
            _ ->
                Err (UnexpectedArguments [ arg ])
        ))
    , ( "fromList", Native.unaryStrict (\_ arg -> Ok (fromListValue () arg)) )
    ]
