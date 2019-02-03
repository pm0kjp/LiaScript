module Lia.Script exposing
    ( Model
    , Msg
    , add_template
    , get_title
    , init_presentation
    , init_slides
    , init_textbook
    , load_slide
    , plain_mode
    , set_script
    , slide_mode
    , subscriptions
    , switch_mode
    , update
    , view
    )

import Array
import Dict
import Html exposing (Html)
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition)
import Lia.Event exposing (Event)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Model exposing (load_src)
import Lia.Parser.Parser as Parser
import Lia.Settings.Model exposing (Mode(..))
import Lia.Types exposing (Sections, init_section)
import Lia.Update exposing (Msg(..))
import Lia.View
import Translations


type alias Model =
    Lia.Model.Model


type alias Msg =
    Lia.Update.Msg


load_slide : Int -> Model -> ( Model, Cmd Msg )
load_slide idx model =
    Lia.Update.update (Load idx) model


add_template : Model -> String -> Model
add_template model template =
    case Parser.parse_defintion model.url template of
        Ok ( definition, _ ) ->
            add_todos definition model

        Err info ->
            Debug.log info model


add_todos : Definition -> Model -> Model
add_todos definition model =
    let
        def =
            model.definition

        ( res, events ) =
            load_src model.resource definition.resources
    in
    { model
        | definition =
            { def
                | macro =
                    Dict.toList definition.macro
                        |> List.append (Dict.toList def.macro)
                        |> Dict.fromList
            }
        , resource = res
        , to_do =
            events
                |> List.reverse
                |> List.append model.to_do
    }


set_script : Model -> String -> ( Model, List String )
set_script model script =
    case Parser.parse_defintion model.url script of
        Ok ( definition, code ) ->
            case Parser.parse_titles definition code of
                Ok title_sections ->
                    let
                        sections =
                            title_sections
                                |> Array.fromList
                                |> Array.indexedMap init_section

                        section_active =
                            if Array.length sections > model.section_active then
                                model.section_active

                            else
                                0
                    in
                    ( { model
                        | definition = { definition | resources = [], borrowed = [] }
                        , sections = sections
                        , section_active = section_active
                        , translation = Translations.getLnFromCode definition.language
                        , to_do =
                            [ [ get_title sections
                              , model.readme
                              , definition.onload
                              ]
                                |> JE.list JE.string
                                |> Event "init" section_active
                            ]
                      }
                        |> add_todos { definition | onload = "" }
                    , definition.borrowed
                    )

                Err msg ->
                    ( { model | error = Just msg }, [] )

        Err msg ->
            ( { model | error = Just msg }, [] )


get_title : Sections -> String
get_title sections =
    sections
        |> Array.get 0
        |> Maybe.map .title
        |> Maybe.map stringify
        |> Maybe.withDefault "Lia"
        |> String.trim
        |> (++) "Lia: "


init_textbook : String -> String -> String -> Maybe Int -> Model
init_textbook url readme origin slide_number =
    Lia.Model.init Textbook url readme origin slide_number


init_slides : String -> String -> String -> Maybe Int -> Model
init_slides url readme origin slide_number =
    Lia.Model.init Slides url readme origin slide_number


init_presentation : String -> String -> String -> Maybe Int -> Model
init_presentation url readme origin slide_number =
    Lia.Model.init Presentation url readme origin slide_number


view : Model -> Html Msg
view model =
    Lia.View.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    Lia.Update.subscriptions model


update : Msg -> Model -> ( Model, Cmd Msg )
update =
    Lia.Update.update


switch_mode : Mode -> Model -> Model
switch_mode mode model =
    let
        settings =
            model.settings
    in
    { model | settings = { settings | mode = mode } }


plain_mode : Model -> Model
plain_mode =
    switch_mode Textbook


slide_mode : Model -> Model
slide_mode =
    switch_mode Slides
