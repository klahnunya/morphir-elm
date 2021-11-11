module Morphir.Web.MultiaryDecisionTreeTest exposing (..)

import Browser
import Dict exposing (Dict, values)
import Html exposing (Html, a, button, label, map, option, select)
import Html.Attributes exposing (class, disabled, for, id, selected, value)
import Html.Events exposing (onClick, onInput)
import List exposing (drop, head, tail, take)
import Maybe exposing (withDefault)
import Morphir.IR.Literal as Literal exposing (Literal(..))
import Morphir.IR.Name as Name exposing (Name)
import Morphir.IR.Value as Value exposing (Pattern(..), RawValue, Value(..), ifThenElse, patternMatch, toString, unit, variable)
import Morphir.SDK.Bool exposing (false, true)
import Morphir.Value.Interpreter as Interpreter exposing (matchPattern)
import Morphir.Visual.ViewPattern as ViewPattern
import String exposing (fromInt, join, length, split)
import Tree as Tree
import TreeView as TreeView


type alias NodeData =
    { uid : String
    , subject : String
    , pattern : Maybe (Pattern ())
    , highlight : Bool
    }


getLabel : Maybe (Pattern ()) -> String
getLabel maybeLabel =
    case maybeLabel of
        Just label ->
            ViewPattern.patternAsText label ++ " - "

        Nothing ->
            ""


evaluateHighlight : Dict Name RawValue -> String -> Pattern () -> Bool
evaluateHighlight variables value pattern =
    let
        evaluation : Maybe.Maybe RawValue
        evaluation =
            variables |> Dict.get (Name.fromString value)
    in
    case evaluation of
        Just val ->
            case Interpreter.matchPattern pattern val of
                Ok _ ->
                    True

                Err _ ->
                    False

        Nothing ->
            False


nodeLabel : Tree.Node NodeData -> String
nodeLabel n =
    case n of
        Tree.Node node ->
            getLabel node.data.pattern ++ node.data.subject


initialModel : () -> ( Model, Cmd Msg )
initialModel () =
    let
        originalIR =
            --listToNode
            Value.patternMatch ()
                (Value.Variable () (Name.fromString "Classify By Position Type"))
                [ ( Value.LiteralPattern () (StringLiteral "Cash")
                  , Value.IfThenElse ()
                        (Value.Variable () (Name.fromString "Is Central Bank"))
                        (Value.IfThenElse ()
                            (Value.Variable () (Name.fromString "Is Segregated Cash"))
                            (Value.PatternMatch ()
                                (Value.Variable () (Name.fromString "Classify By Counter Party ID"))
                                [ ( Value.LiteralPattern () (StringLiteral "FRD"), Value.Variable () [ "1.A.4.1" ] )
                                , ( Value.LiteralPattern () (StringLiteral "BOE"), Value.Variable () [ "1.A.4.2" ] )
                                , ( Value.LiteralPattern () (StringLiteral "SNB"), Value.Variable () [ "1.A.4.3" ] )
                                , ( Value.LiteralPattern () (StringLiteral "ECB"), Value.Variable () [ "1.A.4.4" ] )
                                , ( Value.LiteralPattern () (StringLiteral "BOI"), Value.Variable () [ "1.A.4.5" ] )
                                , ( Value.LiteralPattern () (StringLiteral "RBA"), Value.Variable () [ "1.A.4.6" ] )
                                , ( Value.LiteralPattern () (StringLiteral "BOC"), Value.Variable () [ "1.A.4.7" ] )
                                , ( Value.LiteralPattern () (StringLiteral "Others"), Value.Variable () [ "1.A.4.8" ] )
                                ]
                            )
                            (Value.PatternMatch ()
                                (Value.Variable () (Name.fromString "Classify By Counter Party ID"))
                                [ ( Value.LiteralPattern () (StringLiteral "FRD"), Value.Variable () [ "1.A.3.1" ] )
                                , ( Value.LiteralPattern () (StringLiteral "BOE"), Value.Variable () [ "1.A.3.2" ] )
                                , ( Value.LiteralPattern () (StringLiteral "SNB"), Value.Variable () [ "1.A.3.3" ] )
                                , ( Value.LiteralPattern () (StringLiteral "ECB"), Value.Variable () [ "1.A.3.4" ] )
                                , ( Value.LiteralPattern () (StringLiteral "BOI"), Value.Variable () [ "1.A.3.5" ] )
                                , ( Value.LiteralPattern () (StringLiteral "RBA"), Value.Variable () [ "1.A.3.6" ] )
                                , ( Value.LiteralPattern () (StringLiteral "BOC"), Value.Variable () [ "1.A.3.7" ] )
                                , ( Value.LiteralPattern () (StringLiteral "Others"), Value.Variable () [ "1.A.3.8" ] )
                                ]
                            )
                        )
                        (Value.IfThenElse ()
                            (Value.Variable () (Name.fromString "Is On Shore"))
                            (Value.IfThenElse ()
                                (Value.Variable () [ "Is NetUsd Amount Negative" ])
                                (Value.Variable () [ "O.W.9" ])
                                (Value.IfThenElse ()
                                    (Value.Variable () [ "Is Feed44 and CostCenter Not 5C55" ])
                                    (Value.Variable () [ "1.U.1" ])
                                    (Value.Variable () [ "1.U.4" ])
                                )
                            )
                            (Value.IfThenElse ()
                                (Value.Variable () [ "Is NetUsd Amount Negative" ])
                                (Value.Variable () [ "O.W.10" ])
                                --
                                (Value.IfThenElse ()
                                    (Value.Variable () [ "Is Feed44 and CostCenter Not 5C55" ])
                                    (Value.Variable () [ "1.U.2" ])
                                    (Value.Variable () [ "1.U.4" ])
                                )
                             --
                            )
                        )
                  )
                , ( Value.LiteralPattern () (StringLiteral "Inventory"), Value.Unit () )
                , ( Value.LiteralPattern () (StringLiteral "Pending Trades"), Value.Unit () )
                ]
    in
    ( { rootNodes = listToNode [ originalIR ]
      , dict = Dict.empty
      , treeModel = TreeView.initializeModel2 configuration (listToNode [ originalIR ])
      , selectedNode = Nothing
      , originalIR = originalIR
      }
    , Cmd.none
    )



-- initialize the TreeView model


type alias Model =
    { rootNodes : List (Tree.Node NodeData)
    , treeModel : TreeView.Model NodeData String NodeDataMsg (Maybe NodeData)
    , selectedNode : Maybe NodeData
    , dict : Dict String String
    , originalIR : Value () ()
    }


nodeUidOf : Tree.Node NodeData -> TreeView.NodeUid String
nodeUidOf n =
    case n of
        Tree.Node node ->
            TreeView.NodeUid node.data.uid



--construct a configuration for your tree view


configuration : TreeView.Configuration2 NodeData String NodeDataMsg (Maybe NodeData)
configuration =
    TreeView.Configuration2 nodeUidOf viewNodeData TreeView.defaultCssClasses



-- otherwise interact with your tree view in the usual TEA manner


type Msg
    = TreeViewMsg (TreeView.Msg2 String NodeDataMsg)
    | SetDictValueRoot String
    | SetDictValueBank String
    | SetDictValueSegCash String
    | SetDictValueCode String
    | SetDictValueShore String
    | SetDictValueNegative String
    | SetDictValueFeed String
    | RedoTree


setNodeContent : String -> String -> TreeView.Model NodeData String NodeDataMsg (Maybe NodeData) -> TreeView.Model NodeData String NodeDataMsg (Maybe NodeData)
setNodeContent nodeUid subject treeModel =
    TreeView.updateNodeData
        (\nodeData -> nodeData.uid == nodeUid)
        (\nodeData -> { nodeData | subject = subject })
        treeModel


setNodeHighlight : String -> Bool -> TreeView.Model NodeData String NodeDataMsg (Maybe NodeData) -> TreeView.Model NodeData String NodeDataMsg (Maybe NodeData)
setNodeHighlight nodeUid highlight treeModel =
    TreeView.updateNodeData
        (\nodeData -> nodeData.uid == nodeUid)
        (\nodeData -> { nodeData | highlight = highlight })
        treeModel


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        SetDictValueRoot s1 ->
            let
                newDict1 =
                    Dict.insert "classifyByPositionType" s1 Dict.empty
            in
            ( { model
                | dict = newDict1
                , treeModel = TreeView.initializeModel2 (configuration2 model newDict1) (listToNode [ model.originalIR ])
              }
            , Cmd.none
            )

        SetDictValueBank s1 ->
            --should unset everything except for classifyByPositionType
            let
                newDict1 =
                    Dict.insert "classifyByPositionType"
                        (withDefault
                            "isCentralBank/Cash"
                            (Dict.get "classifyByPositionType" model.dict)
                        )
                        Dict.empty
                        |> Dict.insert "isCentralBank" s1
            in
            ( { model
                | dict = newDict1
                , treeModel = TreeView.initializeModel2 (configuration2 model newDict1) (listToNode [ model.originalIR ])
              }
            , Cmd.none
            )

        SetDictValueSegCash s1 ->
            let
                newDict1 =
                    Dict.remove "classifyByCounterPartyID" model.dict
                        |> Dict.insert "isSegregatedCash" s1
            in
            ( { model
                | dict = newDict1
                , treeModel = TreeView.initializeModel2 (configuration2 model newDict1) (listToNode [ model.originalIR ])
              }
            , Cmd.none
            )

        SetDictValueCode s1 ->
            let
                newDict1 =
                    Dict.insert "classifyByCounterPartyID" s1 model.dict
            in
            ( { model
                | dict = newDict1
                , treeModel = TreeView.initializeModel2 (configuration2 model newDict1) (listToNode [ model.originalIR ])
              }
            , Cmd.none
            )

        SetDictValueShore s1 ->
            --needs to unset isNetUsdAmountNegative & isFeed44andCostCenterNot5C55
            let
                newDict1 =
                    Dict.remove "isNetUsdAmountNegative" model.dict
                        |> Dict.remove "isFeed44andCostCenterNot5C55"
                        |> Dict.insert "isOnShore" s1

                --newDict2 =
                --    Dict.remove "isFeed44andCostCenterNot5C55" newDict1
                --
                --newDict3 =
                --    Dict.insert "isOnShore" s1 newDict2
            in
            ( { model
                | dict = newDict1
                , treeModel = TreeView.initializeModel2 (configuration2 model newDict1) (listToNode [ model.originalIR ])
              }
            , Cmd.none
            )

        SetDictValueNegative s1 ->
            --needs to unset isFeed44andCostCenterNot5C55
            let
                newDict1 =
                    Dict.remove "isFeed44andCostCenterNot5C55" model.dict
                        |> Dict.insert "isNetUsdAmountNegative" s1
            in
            ( { model
                | dict = newDict1
                , treeModel = TreeView.initializeModel2 (configuration2 model newDict1) (listToNode [ model.originalIR ])
              }
            , Cmd.none
            )

        SetDictValueFeed s1 ->
            let
                newDict1 =
                    Dict.insert "isFeed44andCostCenterNot5C55" s1 model.dict
            in
            ( { model | dict = newDict1, treeModel = TreeView.initializeModel2 (configuration2 model newDict1) (listToNode [ model.originalIR ]) }, Cmd.none )

        RedoTree ->
            ( { model | treeModel = TreeView.initializeModel2 (configuration2 model model.dict) (listToNode [ model.originalIR ]) }, Cmd.none )

        _ ->
            let
                treeModel =
                    case message of
                        TreeViewMsg (TreeView.CustomMsg nodeDataMsg) ->
                            case nodeDataMsg of
                                EditContent nodeUid content ->
                                    setNodeHighlight nodeUid True model.treeModel

                        TreeViewMsg tvMsg ->
                            TreeView.update2 tvMsg model.treeModel

                        _ ->
                            model.treeModel

                selectedNode =
                    TreeView.getSelected treeModel |> Maybe.map .node |> Maybe.map Tree.dataOf
            in
            ( { model
                | treeModel = treeModel
                , selectedNode = selectedNode
              }
            , Cmd.none
            )


selectedNodeDetails : Model -> Html Msg
selectedNodeDetails model =
    let
        selectedDetails =
            Maybe.map (\nodeData -> nodeData.uid ++ ": " ++ nodeData.subject) model.selectedNode
                |> Maybe.withDefault "(nothing selected)"
    in
    Html.div
        []
        [ Html.text selectedDetails
        ]


view : Model -> Html.Html Msg
view model =
    --layout [] dropdown
    Html.div
        [ id "top-level" ]
        [ dropdowns model
        , selectedNodeDetails model
        , map TreeViewMsg (TreeView.view2 model.selectedNode model.treeModel)
        ]


main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


dropdowns : Model -> Html.Html Msg
dropdowns model =
    Html.div []
        [ Html.text (join "--------------" (List.map2 (\x y -> x ++ ":" ++ y) (Dict.keys model.dict) (Dict.values model.dict)))
        , Html.div [ id "all-dropdowns" ]
            [ label [ id "cash-select-label", for "cash-select" ] [ Html.text "Choose a type: " ]
            , select [ id "cash-select", onInput SetDictValueRoot, class "dropdown" ]
                [ option [ value "", disabled True, selected True ] [ Html.text "Type" ]
                , option [ value "Is Central Bank/Cash" ] [ Html.text "Cash" ]
                , option [ value "/Inventory" ] [ Html.text "Inventory" ]
                , option [ value "/Pending Trades" ] [ Html.text "Pending Trades" ]
                ]

            --, Html.div [ id "cash-child" ] [
            , label [ id "central-bank-select-label", for "central-bank-select", class "l-d" ] [ Html.text "Choose a bank: " ]
            , select [ id "central-bank-select", onInput SetDictValueBank, class "dropdown" ]
                [ option [ value "", disabled True, selected True ] [ Html.text "Is Central Bank" ]
                , option [ value "Is Segregated Cash/True" ] [ Html.text "Yes" ]
                , option [ value "Is On Shore/False" ] [ Html.text "No" ]
                ]
            , Html.div [ id "central-bank-yes-child" ]
                [ label [ id "seg-cash-select-label", for "seg-cash-select", class "l-d" ] [ Html.text "Choose T/F: " ]
                , select [ id "seg-cash-select", onInput SetDictValueSegCash, class "dropdown" ]
                    [ option [ value "", disabled True, selected True ] [ Html.text "Is Segregated Cash" ]
                    , option [ value "Classify By Counter Party ID/True" ] [ Html.text "Yes" ]
                    , option [ value "Classify By Counter Party ID/False" ] [ Html.text "No" ]
                    ]

                --will have to add another dropdown here for the other codes, based on answer of previous
                , label [ id "code-select-1-label", for "code-select-1", class "l-d" ] [ Html.text "Choose a code " ]
                , select [ id "code-select-1", onInput SetDictValueCode, class "dropdown" ]
                    [ option [ value "", disabled True, selected True ] [ Html.text "Classify By Counter Party ID" ]
                    , option [ value "1.A.4.1/FRD" ] [ Html.text "FRD" ]
                    , option [ value "1.A.4.2/BOE" ] [ Html.text "BOE" ]
                    , option [ value "1.A.4.3/SNB" ] [ Html.text "SNB" ]
                    , option [ value "1.A.4.4/ECB" ] [ Html.text "ECB" ]
                    , option [ value "1.A.4.5/BOI" ] [ Html.text "BOJ" ]
                    , option [ value "1.A.4.6/RBA" ] [ Html.text "RBA" ]
                    , option [ value "1.A.4.7/BOC" ] [ Html.text "BOC" ]
                    , option [ value "1.A.4.8/other" ] [ Html.text "other" ]
                    ]
                , label [ id "code-select-2-label", for "code-select-2", class "l-d" ] [ Html.text "Choose a code " ]
                , select [ id "code-select-2", onInput SetDictValueCode, class "dropdown" ]
                    [ option [ value "", disabled True, selected True ] [ Html.text "Classify By Counter Party ID" ]
                    , option [ value "1.A.3.1/FRD" ] [ Html.text "FRD" ]
                    , option [ value "1.A.3.2/BOE" ] [ Html.text "BOE" ]
                    , option [ value "1.A.3.3/SNB" ] [ Html.text "SNB" ]
                    , option [ value "1.A.3.4/ECB" ] [ Html.text "ECB" ]
                    , option [ value "1.A.3.5/BOI" ] [ Html.text "BOJ" ]
                    , option [ value "1.A.3.6/RBA" ] [ Html.text "RBA" ]
                    , option [ value "1.A.3.7/BOC" ] [ Html.text "BOC" ]
                    , option [ value "1.A.3.8/other" ] [ Html.text "other" ]
                    ]
                ]
            , Html.div [ id "central-bank-no-child" ]
                [ label [ id "on-shore-select-label", for "on-shore-select", class "l-d" ] [ Html.text "Choose T/F: " ]
                , select [ id "on-shore-select", onInput SetDictValueShore, class "dropdown" ]
                    [ option [ value "", disabled True, selected True ] [ Html.text "Is On Shore" ]
                    , option [ value "Is NetUsd Amount Negative/True" ] [ Html.text "Yes" ]
                    , option [ value "Is NetUsd Amount Negative/False" ] [ Html.text "No" ]
                    ]

                --need another branch here
                , label [ id "negative-select-label", for "negative-select", class "l-d" ] [ Html.text "Choose T/F: " ]
                , select [ id "negative-select", onInput SetDictValueNegative, class "dropdown" ]
                    [ option [ value "", disabled True, selected True ] [ Html.text "Is NetUsd Amount Negative" ]
                    , option [ value "O.W.9/True" ] [ Html.text "Yes" ]
                    , option [ value "Is Feed44 and CostCenter Not 5C55/False" ] [ Html.text "No" ]
                    ]
                , Html.div [ id "negative-no-child" ]
                    [ label [ id "negative-no-child-select-label", for "negative-no-child-select", class "l-d" ] [ Html.text "Choose T/F: " ]
                    , select [ id "negative-no-child-select", onInput SetDictValueFeed, class "dropdown" ]
                        [ option [ value "", disabled True, selected True ] [ Html.text "Is Feed44 and CostCenter Not 5C55" ]
                        , option [ value "1.U.1/True" ] [ Html.text "Yes" ]
                        , option [ value "1.U.4/False" ] [ Html.text "No" ]
                        ]
                    ]
                , label [ id "negative-select-2-label", for "negative-select-2", class "l-d" ] [ Html.text "Choose T/F: " ]
                , select [ id "negative-select-2", onInput SetDictValueNegative, class "dropdown" ]
                    [ option [ value "", disabled True, selected True ] [ Html.text "Is NetUsd Amount Negative" ]
                    , option [ value "O.W.10/True" ] [ Html.text "Yes" ]
                    , option [ value "Is Feed44 and CostCenter Not 5C55/False" ] [ Html.text "No" ]
                    ]
                , Html.div [ id "negative-no-child-2" ]
                    [ label [ id "negative-no-child-select-2-label", for "negative-no-child-select-2", class "l-d" ] [ Html.text "Choose T/F: " ]
                    , select [ id "negative-no-child-select-2", onInput SetDictValueFeed, class "dropdown" ]
                        [ option [ value "", disabled True, selected True ] [ Html.text "Is Feed44 and CostCenter Not 5C55" ]
                        , option [ value "1.U.2/True" ] [ Html.text "Yes" ]
                        , option [ value "1.U.4/False" ] [ Html.text "No" ]
                        ]
                    ]
                ]

            --]
            ]
        , button [ id "hide-button" ] [ Html.text "Hide Selections " ]
        , button [ id "tree-button", onClick RedoTree ] [ Html.text "highlight" ]
        , button [ id "show-button" ] [ Html.text "Show me the world" ]
        ]



--construct a configuration for your tree view
-- if (or when) you want the tree view to navigate up/down between visible nodes and expand/collapse nodes on arrow key presse


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map TreeViewMsg (TreeView.subscriptions2 model.treeModel)


toMaybeList : List ( Pattern (), Value () () ) -> List ( Maybe (Pattern ()), Value () () )
toMaybeList list =
    let
        patterns =
            List.map Tuple.first list

        maybePatterns =
            List.map Just patterns

        values =
            List.map Tuple.second list
    in
    List.map2 Tuple.pair maybePatterns values


listToNode : List (Value () ()) -> List (Tree.Node NodeData)
listToNode values =
    let
        uids =
            List.range 1 (List.length values)
    in
    List.map2 toTranslate values uids


toTranslate : Value () () -> Int -> Tree.Node NodeData
toTranslate value uid =
    translation2 ( Nothing, value ) (fromInt uid)


translation2 : ( Maybe (Pattern ()), Value () () ) -> String -> Tree.Node NodeData
translation2 ( pattern, value ) uid =
    case value of
        Value.IfThenElse _ condition thenBranch elseBranch ->
            let
                data =
                    NodeData uid (Value.toString condition) pattern false

                uids =
                    createUIDS 2 uid

                list =
                    [ ( Just (Value.LiteralPattern () (BoolLiteral True)), thenBranch ), ( Just (Value.LiteralPattern () (BoolLiteral False)), elseBranch ) ]

                children : List (Tree.Node NodeData)
                children =
                    List.map2 translation2 list uids
            in
            Tree.Node
                { data = data
                , children = children
                }

        Value.PatternMatch tpe param patterns ->
            let
                data =
                    NodeData uid (Value.toString param) pattern false

                maybePatterns =
                    toMaybeList patterns

                uids =
                    createUIDS (List.length maybePatterns) uid

                children : List (Tree.Node NodeData)
                children =
                    List.map2 translation2 maybePatterns uids
            in
            Tree.Node
                { data = data
                , children = children
                }

        _ ->
            --Value.toString value ++ (fromInt uid) ++ " ------ "
            Tree.Node { data = NodeData uid (Value.toString value) pattern false, children = [] }


createUIDS : Int -> String -> List String
createUIDS range currentUID =
    let
        intRange =
            List.range 1 range

        stringRange =
            List.map fromInt intRange

        appender int =
            String.append (currentUID ++ ".") int
    in
    List.map appender stringRange


type NodeDataMsg
    = EditContent String String -- uid content


convertToDict : Dict String String -> Dict Name (Value ta ())
convertToDict dict =
    let
        dictList =
            Dict.toList dict
    in
    Dict.fromList (List.map convertToDictHelper dictList)


convertToDictHelper : ( String, String ) -> ( Name, Value ta () )
convertToDictHelper ( k, v ) =
    case v of
        "True" ->
            ( Name.fromString k, Value.Literal () (BoolLiteral True) )

        "False" ->
            ( Name.fromString k, Value.Literal () (BoolLiteral False) )

        _ ->
            ( Name.fromString k, Value.Literal () (StringLiteral v) )


viewNodeData : Maybe NodeData -> Tree.Node NodeData -> Html.Html NodeDataMsg
viewNodeData selectedNode node =
    let
        nodeData =
            Tree.dataOf node

        dict2 =
            convertToDict
                (Dict.fromList
                    []
                )

        --[]
        selected =
            selectedNode
                |> Maybe.map (\sN -> nodeData.uid == sN.uid)
                |> Maybe.withDefault False

        highlight =
            evaluateHighlight dict2
                nodeData.subject
                --correctPath
                (withDefault (WildcardPattern ()) nodeData.pattern)
    in
    if highlight then
        Html.text (getLabel nodeData.pattern ++ nodeData.subject ++ "  Highlight")

    else
        Html.text (getLabel nodeData.pattern ++ nodeData.subject)


helper : List String -> ( String, String )
helper l =
    case l of
        [ s1, s2 ] ->
            ( s1, s2 )

        _ ->
            ( "oh", "no" )


viewNodeData2 : Model -> Dict String String -> Maybe NodeData -> Tree.Node NodeData -> Html.Html NodeDataMsg
viewNodeData2 model myDict selectedNode node =
    let
        nodeData =
            Tree.dataOf node

        --dict =
        --    Dict.fromList
        --        [ ( Name.fromString "Classify By Position Type", Value.Literal () (StringLiteral "Cash") )
        --        , ( Name.fromString "Is Central Bank", Value.Literal () (BoolLiteral True) )
        --        , ( Name.fromString "Is Segregated Cash", Value.Literal () (BoolLiteral True) )
        --        , ( Name.fromString "Classify By Counter Party ID", Value.Literal () (StringLiteral "FRD") )
        --        ]
        dict2 =
            --pass in my dict, changes it to tuples i guess
            convertToDict
                (Dict.fromList
                    --subject, pattern
                    --[ ( "Classify By Position Type", "sakdnajdbaj" )
                    --, ( "Is Central Bank", "Cash" )
                    --, ( "Is Segregated Cash", "True" )
                    --, ( "Classify By Counter Party ID", "True" )
                    --, ( "1.A.4.1", "FRD" )
                    --]
                    (List.append
                        [ ( "Classify By Position Type", "" ) ]
                        --(List.map2 Tuple.pair (Dict.keys model.dict) (Dict.values model.dict))
                        (List.map helper (List.map (split "/") (Dict.values myDict)))
                        |> Debug.log "Stuff: "
                    )
                )

        selected =
            selectedNode
                |> Maybe.map (\sN -> nodeData.uid == sN.uid)
                |> Maybe.withDefault False

        highlight =
            evaluateHighlight dict2
                nodeData.subject
                --correctPath
                (withDefault (WildcardPattern ()) nodeData.pattern)
    in
    if highlight then
        Html.text (getLabel nodeData.pattern ++ nodeData.subject ++ "  Highlight")

    else
        Html.text (getLabel nodeData.pattern ++ nodeData.subject)


configuration2 : Model -> Dict String String -> TreeView.Configuration2 NodeData String NodeDataMsg (Maybe NodeData)
configuration2 model myDict =
    TreeView.Configuration2 nodeUidOf (viewNodeData2 model myDict) TreeView.defaultCssClasses
