module Lia.Markdown.Inline.Config exposing
    ( Config
    , init
    , setViewer
    )

import Html exposing (Html)
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.Effect.Script.Update exposing (Msg)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Section exposing (SubSection)
import Lia.Settings.Model exposing (Mode(..))
import Translations exposing (Lang)


type alias Config =
    { view : Maybe (SubSection -> List (Html Msg))
    , slide : Int
    , visible : Maybe Int
    , speaking : Maybe Int
    , lang : Lang
    , theme : Maybe String
    , scripts : Scripts SubSection
    }


init :
    Int
    -> Mode
    -> Int
    -> Maybe Int
    -> Scripts SubSection
    -> Lang
    -> Maybe String
    -> Config
init slide mode visible speaking effects theme lang =
    Config
        Nothing
        slide
        (if mode == Textbook then
            Nothing

         else
            Just visible
        )
        speaking
        theme
        lang
        effects


setViewer : (SubSection -> List (Html Msg)) -> Config -> Config
setViewer fn config =
    { config | view = Just fn }
