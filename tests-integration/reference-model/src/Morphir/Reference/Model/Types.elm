module Morphir.Reference.Model.Types exposing (..)

{-| Various examples of types for testing.
-}


{-| Alias referring to another type using a reference.
-}
type alias Quantity =
    Int


type alias Cart =
    List { title : String, productQuantity : Quantity }


type Custom
    = CustomNoArg
    | CustomOneArg Bool
    | CustomTwoArg String Quantity


type CustomOne
    = CustomOneNoArg
    | CustomOneOneArg (Maybe Bool)
    | CustomOneTwoArg String Quantity


type Maybe a
    = Just a
    | Nothing


{-| Value type example
-}
type Email
    = Email String


type FirstName
    = FirstName String


type LastName
    = LastName String


type FullName
    = FullName FirstName LastName


customToInt : Custom -> Int
customToInt custom =
    case custom of
        CustomNoArg ->
            0

        CustomOneArg bool ->
            1

        CustomTwoArg string quantity ->
            quantity


customToInt2 : Bool -> Custom -> Int
customToInt2 b custom =
    case custom of
        CustomNoArg ->
            0

        CustomOneArg bool ->
            1

        CustomTwoArg string quantity ->
            quantity


type alias FooBarBazRecord =
    { foo : String
    , bar : Bool
    , baz : Int
    }


fooBarBazToString : FooBarBazRecord -> String
fooBarBazToString fbb =
    fbb.foo
