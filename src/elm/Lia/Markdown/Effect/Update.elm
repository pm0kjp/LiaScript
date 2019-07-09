module Lia.Markdown.Effect.Update exposing
    ( Msg(..)
    , has_next
    , has_previous
    , init
    , next
    , previous
    , soundEvent
    , update
    )

import Browser.Dom as Dom
import Json.Encode as JE
import Lia.Event.Base as Event exposing (Event)
import Lia.Markdown.Effect.Model exposing (Model, current_comment, get_all_javascript, get_javascript)
import Task


type Msg
    = Init Bool
    | Next
    | Previous
    | Send (List Event)
    | Rendered Bool Dom.Viewport


update : Bool -> Msg -> Model -> ( Model, Cmd Msg, List Event )
update sound msg model =
    case msg of
        Init run_all_javascript ->
            ( model
            , Task.perform (Rendered run_all_javascript) Dom.getViewport
            , []
            )

        Next ->
            if has_next model then
                { model | visible = model.visible + 1 }
                    |> execute sound False 0

            else
                ( model, Cmd.none, [] )

        Previous ->
            if has_previous model then
                { model | visible = model.visible - 1 }
                    |> execute sound False 0

            else
                ( model, Cmd.none, [] )

        Send event ->
            let
                events =
                    ("focused"
                        |> JE.string
                        |> Event "scrollTo" -1
                    )
                        :: event
            in
            case ( sound, current_comment model ) of
                ( True, Just ( comment, narrator ) ) ->
                    ( model
                    , Cmd.none
                    , (Event "speak" -1 <| JE.list JE.string [ narrator, comment ]) :: events
                    )

                _ ->
                    speak_stop events model

        Rendered run_all_javascript _ ->
            execute sound run_all_javascript 0 model


speak_stop : List Event -> Model -> ( Model, Cmd Msg, List Event )
speak_stop events model =
    ( model
    , Cmd.none
    , (Event "speak" -1 <| JE.string "cancel") :: events
    )


executeEvent : Int -> String -> Event
executeEvent delay code =
    Event "execute" -1 <|
        JE.object
            [ ( "delay", JE.int delay )
            , ( "code", JE.string code )
            ]


execute : Bool -> Bool -> Int -> Model -> ( Model, Cmd Msg, List Event )
execute sound run_all delay model =
    let
        javascript =
            if run_all then
                get_all_javascript model

            else
                get_javascript model
    in
    update sound
        (javascript
            |> List.map (executeEvent delay)
            |> (::) (Event "persistent" -1 (JE.string "load"))
            |> Send
        )
        model


has_next : Model -> Bool
has_next model =
    model.visible < model.effects


has_previous : Model -> Bool
has_previous model =
    model.visible > 0


init : Bool -> Msg
init run_all_javascript =
    Init run_all_javascript


next : Msg
next =
    Next


previous : Msg
previous =
    Previous


soundEvent : Bool -> Event
soundEvent on =
    (if on then
        "repeat"

     else
        "cancel"
    )
        |> JE.string
        |> Event "speak" -1
        |> Event.toJson
        |> Event "effect" -1
