module TestModel.AdvancedTypes exposing (..)

import Morphir.SDK.Decimal exposing (..)
import Morphir.SDK.LocalDate exposing (LocalDate)
import Morphir.SDK.LocalTime exposing (LocalTime)
import Morphir.SDK.Month exposing (Month)

import TestModel.BasicTypes exposing (..)


type alias Score =
    Decimal


type alias AcquisitionDate =
    LocalDate


type alias EntryTime =
    LocalTime


type alias StartMonth =
    Month

type alias Exam =
    Grade
