import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Browser.Navigation exposing (load)
import Html.Events as Events
import Http
import Json.Decode as JDecode
import Json.Encode as JEncode
import String


main = Browser.element { init = init
                       , update = update
                       , subscriptions = \_ -> Sub.none
                       , view = view
                       }

rootUrl =
    "https://mac1xa3.ca/e/bhavsd1/"

-- Model 
type alias Model =  
    { name : String, password : String, passwordC : String, error : String }


type Msg = NewUser String -- Name text field changed
    | NewPassword String -- Password text field changed
    | NewPasswordC String -- Confirm Password field
    | GotRegisterResponse (Result Http.Error String) -- Http Post Response Received
    | RegisterButton -- Register Button Pressed


init : () -> ( Model, Cmd Msg )
init _ =
    ( { name = ""
      , password = ""
      , passwordC = ""
      , error = ""
      }
    , Cmd.none
    )

-- View
view : Model -> Html Msg
view model = div []
    [ node "link" [ rel "icon", type_ "image/png", href "LoginFiles/images/icons/favicon.ico" ]
        []
    , node "link" [ rel "stylesheet", type_ "text/css", href "LoginFiles/vendor/bootstrap/css/bootstrap.min.css" ]
        []
    , node "link" [ rel "stylesheet", type_ "text/css", href "LoginFiles/fonts/font-awesome-4.7.0/css/font-awesome.min.css" ]
        []
    , node "link" [ rel "stylesheet", type_ "text/css", href "LoginFiles/fonts/iconic/css/material-design-iconic-font.min.css" ]
        []
    , node "link" [ rel "stylesheet", type_ "text/css", href "LoginFiles/vendor/animate/animate.css" ]
        []
    , node "link" [ rel "stylesheet", type_ "text/css", href "LoginFiles/vendor/css-hamburgers/hamburgers.min.css" ]
        []
    , node "link" [ rel "stylesheet", type_ "text/css", href "LoginFiles/vendor/animsition/css/animsition.min.css" ]
        []
    , node "link" [ rel "stylesheet", type_ "text/css", href "LoginFiles/css/util.css" ]
        []
    , node "link" [ rel "stylesheet", type_ "text/css", href "LoginFiles/css/main.css" ]
        []
    , div [ class "limiter" ]
         [ div [ class "container-login100" ]
            [ div [ class "wrap-login100" ]
                 [ div [ class "login100-form validate-form" ]
                     [ span [ class "login100-form-title p-b-26" ]
                        [ text "Register" ]
                        , span [ class "login100-form-title p-b-48" ]
                        [ p []
                        [ text model.error ]
                        ]
                        , div [ class "wrap-input100 validate-input" ]
                        [ input [ id "inputUser", placeholder "Username", attribute "required" "required", type_ "text", Events.onInput NewUser ]
                                []                           
                        ] 
                        
                        , div [ class "wrap-input100 validate-input" ]
                        [ input [ id "inputPassword", placeholder "Enter Password", attribute "required" "required", type_ "password", Events.onInput NewPassword ]
                                []
                        ] 

                        , div [ class "wrap-input100 validate-input" ]
                        [ input [ id "inputPassword", placeholder "Confirm Password", attribute "required" "required", type_ "password", Events.onInput NewPasswordC ]
                                []
                        ]

                        , div [ class "container-login100-form-btn" ]
                        
                        [ div [ class "wrap-login100-form-btn" ]
                        [ div [ class "login100-form-bgbtn" ]
                        []
                        , button [ class "login100-form-btn", Events.onClick RegisterButton ]
                        [ text "Register" ]
                        ]
                        ]
                        , div [ class "text-center p-t-115" ]
                        [ span [ class "txt1" ]
                        [ text "Already have an account?" ]
                        , a [ class "txt2", href "project03.html" ]
                        [ text " Log In" ]
                        ]
                    ]
                ]
            ]
        ]
    ]

-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewUser name ->
            ( { model | name = name }, Cmd.none )

        NewPassword password ->
            ( { model | password = password }, Cmd.none )
        
        NewPasswordC password ->
            ( { model | passwordC = password }, Cmd.none )

        RegisterButton ->
            if model.password == model.passwordC && model.password /= "" then
                    ( model, loginPost model )
            else if model.name == "" then
                    ( { model | error = "Please enter in an Username" }, Cmd.none)
            else if model.password == "" then
                    ( { model | error = "Please enter in a Password" }, Cmd.none)
            else
                    ( { model | error = "Passwords don't Match" }, Cmd.none)

        GotRegisterResponse result ->
            case result of
                Ok "Exists" ->
                    ( { model | error = "Username Already Exists" }, Cmd.none )

                Ok _ ->
                    ( model, load ("project03.html") )

                Err error ->
                    ( handleError model error, Cmd.none )


-- Encoder for register credentials
passwordEncoder : Model -> JEncode.Value
passwordEncoder model =
    JEncode.object
        [ ( "username"
          , JEncode.string model.name
          )
        , ( "password"
          , JEncode.string model.password
          )
        ]


-- Function to Send encoded object
loginPost : Model -> Cmd Msg
loginPost model =
    Http.post
        { url = rootUrl ++ "userauth/adduser/"
        , body = Http.jsonBody <| passwordEncoder model
        , expect = Http.expectString GotRegisterResponse
        }


-- Function to Handle Error
handleError : Model -> Http.Error -> Model
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | error = "bad url: " ++ url }

        Http.Timeout ->
            { model | error = "timeout" }

        Http.NetworkError ->
            { model | error = "network error" }

        Http.BadStatus i ->
            { model | error = "bad status " ++ String.fromInt i }

        Http.BadBody body ->
            { model | error = "bad body " ++ body }
