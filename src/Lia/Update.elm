module Lia.Update exposing (Msg(..), update)

import Array
import Json.Encode as JE
import Lia.Code.Update as Code
import Lia.Effect.Model as EffectModel
import Lia.Effect.Update as Effect
import Lia.Helper exposing (get_slide)
import Lia.Index.Update as Index
import Lia.Model exposing (..)
import Lia.Quiz.Update as Quiz
import Lia.Survey.Update as Survey
import Lia.Types exposing (Mode(..))
import Lia.Utils exposing (set_local)


type Msg
    = Load Int
    | PrevSlide Int
    | NextSlide Int
    | ToggleLOC
    | UpdateIndex Index.Msg



--    | UpdateQuiz Quiz.Msg
--    | UpdateCode Code.Msg
--    | UpdateSurvey Survey.Msg
--    | UpdateEffect Effect.Msg
--    | Theme String
--    | ThemeLight
--    | ToggleSpeech
--    | SwitchMode


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ( String, JE.Value ) )
update msg model =
    case msg of
        ToggleLOC ->
            ( { model | loc = not model.loc }, Cmd.none, Nothing )

        UpdateIndex childMsg ->
            let
                index =
                    model.slides
                        |> Array.map .code
                        |> Array.toIndexedList
                        |> Index.update childMsg model.model_index
            in
            ( { model | model_index = index }, Cmd.none, Nothing )

        _ ->
            ( model, Cmd.none, Nothing )



-- case msg of
--     Load int ->
--         if (-1 < int) && (int < List.length model.slides) then
--             let
--                 ( effect_model, cmd, _ ) =
--                     get_slide int model.slides
--                         |> EffectModel.init model.narrator
--                         |> Effect.init model.silent
--
--                 x =
--                     model.uid
--                         |> Maybe.map (\uid -> set_local uid (toString int))
--             in
--             ( { model
--                 | current_slide = int
--                 , effect_model = effect_model
--               }
--             , Cmd.map UpdateEffect cmd
--             , Nothing
--             )
--         else
--             ( model, Cmd.none, Nothing )
--
--     Theme theme ->
--         let
--             x =
--                 set_local "theme" theme
--         in
--         ( { model | theme = theme }, Cmd.none, Nothing )
--
--     ThemeLight ->
--         let
--             x =
--                 set_local "theme_light"
--                     (if not model.theme_light then
--                         "on"
--                      else
--                         "off"
--                     )
--         in
--         ( { model | theme_light = not model.theme_light }, Cmd.none, Nothing )
--
--     ToggleSpeech ->
--         if model.silent then
--             let
--                 ( effect_model, cmd, _ ) =
--                     Effect.repeat False model.effect_model
--
--                 x =
--                     set_local "silent" "false"
--             in
--             ( { model | silent = False, effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )
--         else
--             let
--                 x =
--                     if not model.silent then
--                         Effect.silence ()
--                     else
--                         False
--
--                 y =
--                     set_local "silent" "true"
--             in
--             ( { model | silent = True }, Cmd.none, Nothing )
--
--     SwitchMode ->
--         case model.mode of
--             Slides ->
--                 let
--                     x =
--                         Effect.silence ()
--
--                     y =
--                         set_local "mode" "Slides_only"
--                 in
--                 ( { model | mode = Slides_only, silent = True }, Cmd.none, Nothing )
--
--             _ ->
--                 let
--                     x =
--                         set_local "mode" "Slides"
--                 in
--                 update ToggleSpeech { model | mode = Slides, silent = True }
--
--     PrevSlide hidden_effects ->
--         let
--             effect_model =
--                 model.effect_model
--         in
--         case ( model.mode, Effect.previous model.silent { effect_model | effects = effect_model.effects - hidden_effects } ) of
--             ( Slides, ( effect_model, cmd, False ) ) ->
--                 ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )
--
--             _ ->
--                 update (Load (model.current_slide - 1)) model
--
--     NextSlide hidden_effects ->
--         let
--             effect_model =
--                 model.effect_model
--         in
--         case ( model.mode, Effect.next model.silent { effect_model | effects = effect_model.effects - hidden_effects } ) of
--             ( Slides, ( effect_model, cmd, False ) ) ->
--                 ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )
--
--             _ ->
--                 update (Load (model.current_slide + 1)) model
--
--     UpdateIndex childMsg ->
--         let
--             index_model =
--                 Index.update childMsg model.index_model
--         in
--         ( { model | index_model = index_model }, Cmd.none, Nothing )
--
--     UpdateSurvey childMsg ->
--         let
--             ( model_, info ) =
--                 Survey.update childMsg model.survey_model
--         in
--         ( { model | survey_model = model_ }, Cmd.none, log "survey" info )
--
--     UpdateCode childMsg ->
--         let
--             ( code_model, cmd ) =
--                 Code.update childMsg model.code_model
--         in
--         ( { model | code_model = code_model }, Cmd.map UpdateCode cmd, Nothing )
--
--     UpdateEffect childMsg ->
--         let
--             ( effect_model, cmd, _ ) =
--                 Effect.update childMsg model.effect_model
--         in
--         ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )
--
--     ToggleContentsTable ->
--         ( { model | show_contents = not model.show_contents }, Cmd.none, Nothing )
--
--     UpdateQuiz quiz_msg ->
--         let
--             ( quiz_model, info ) =
--                 Quiz.update quiz_msg model.quiz_model
--         in
--         ( { model | quiz_model = quiz_model }, Cmd.none, log "quiz" info )


log : String -> Maybe JE.Value -> Maybe ( String, JE.Value )
log topic msg =
    case msg of
        Just m ->
            Just ( topic, m )

        _ ->
            Nothing
