module Lia.Types exposing (Section, Sections, init_section)

import Array exposing (Array)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Types as Code
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Footnote.Model as Footnote
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Survey.Types as Survey
import Lia.Markdown.Types exposing (Markdown)


type alias Section =
    { code : String
    , title : Inlines
    , visited : Bool
    , indentation : Int
    , visible : Bool
    , idx : Int
    , body : List Markdown
    , parsed : Bool
    , error : Maybe String
    , code_vector : Code.Vector
    , quiz_vector : Quiz.Vector
    , survey_vector : Survey.Vector
    , effect_model : Effect.Model
    , definition : Maybe Definition
    , footnotes : Footnote.Model
    , footnote2show : Maybe String
    }


type alias Sections =
    Array Section


init_section : Int -> ( Int, Inlines, String ) -> Section
init_section idx ( identation, title, code ) =
    { code = code
    , title = title
    , visited = True
    , indentation = identation
    , visible = True
    , idx = idx
    , parsed = False
    , body = []
    , error = Nothing
    , code_vector = Array.empty
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    , effect_model = Effect.init
    , definition = Nothing
    , footnotes = Footnote.init
    , footnote2show = Nothing
    }