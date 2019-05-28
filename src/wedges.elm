import Browser
import Browser.Dom exposing (..)
import Task exposing (..)
import Browser.Navigation exposing (Key(..), load)
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Url
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http
import Json.Decode as JDecode
import Json.Encode as JEncode
import String

--Root for serving the backend
rootUrl =
    "https://mac1xa3.ca/e/bhavsd1/"

-- Main
main : AppWithTick () Model Msg
main =
    appWithTick Tick
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = MakeRequest
        , onUrlChange = UrlChange
        }


type Msg
 =     Tick Float GetKeyState
     | MakeRequest Browser.UrlRequest
     | UrlChange Url.Url
     | Show Page -- Change Pages
     | LogOut
     | GetResponse (Result Http.Error String) -- Response for Auth 
     | UserInfoResponse (Result Http.Error UserInfo) -- Response for UserInfo
     | GetSize (Viewport) -- To get the Screen Size
     | NewLA String -- Loan Value Change
     | NewLT String -- Loan Type Change
     | NewLP String -- Loan Period Change
     | NewLI String -- Loan Rate Change
     | NewEA String -- Expense Value Change
     | NewET String -- Expense Type Change
     | NewI String -- Income Change
     | AddButton 
     | RefreshButton


type alias Model =  
    { pageL : Page, error : String, userInfo: UserInfo, sendUserInfo: SendUserInfo, size: {x : Float, y : Float}
    }
-- Different Pages on Site
type Page = Dashboard
    | ExpenseTracker
    | LoanTracker

-- Fields for Recieving Info
type alias UserInfo = {
        income            : Float, 
        groceries         : Float,
        entertainment     : Float,
        otherE            : Float,
        resL              : Float,
        resLI             : Float,
        otherL            : Float,
        otherLI           : Float
    }
-- Fields for Sending Info
type alias SendUserInfo = {
        income       : String,
        expenseVal   : String,
        expenseType  : String,
        loanVal      : String,
        loanPeriod   : String,
        loanInterest : String,
        loanType     : String
                          }


init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key = ( { pageL = Dashboard -- Default Main Page
      , error = ""
      , userInfo  = { income = 15043, groceries = 3300, entertainment = 290, otherE = 58, resL = 10000, resLI = 3000, otherL = 5000, otherLI = 550 } 
      , sendUserInfo = { income = "", expenseVal = "", expenseType = "", loanVal = "", loanPeriod = "", loanInterest = "", loanType = "" }
      , size = {x = 10, y = 10}
      }
    , getSize -- Cmd Msg for Getting User's Screen Size
    )

-- Function for Getting Screen Size
getSize : Cmd Msg
getSize = Task.perform GetSize getViewport


-- Main View Function
view : Model -> { title : String, body : Collage Msg }
view model = 
  let 
      title = "FinTrack" 
        
      body = collage model.size.x model.size.y  -- Same Size as user's screen
                        ([GraphicSVG.html model.size.x model.size.y (htmlView model)
                             |> move (-model.size.x/2, model.size.y/2)] ++ graphs model ++
                         (case model.pageL of -- Change Views based on user's navigation
                            Dashboard -> [GraphicSVG.html (model.size.x - 250) model.size.y (dashboardView model) |> move ((-model.size.x/2 + 230), (model.size.y/2 - 72 ))] -- Movement adjustment
                            LoanTracker -> [GraphicSVG.html (model.size.x - 250) model.size.y (loantrackerView model) |> move ((-model.size.x/2 + 230), (model.size.y/2 - 72 ))]
                            ExpenseTracker -> [GraphicSVG.html (model.size.x - 250) model.size.y (expensetrackerView model) |> move ((-model.size.x/2 + 230), (model.size.y/2 - 72 ))] ))

                              
                              
  in { title = title , body = body }


-- Function for rendering graphs for each page
graphs : Model -> List (Shape Msg)
graphs model =     case model.pageL of 
                 Dashboard -> [union (circle (150)
                                 |> filled orange
                                 |> move (400,50))
                            (GraphicSVG.text ("Total Income" ++ ": $" ++ String.fromFloat(model.userInfo.income))
                             |> GraphicSVG.size 15
                             |> filled orange
                             |> move (300,-120))
                            ,  union (wedge 150 (model.userInfo.groceries / model.userInfo.income)
                                 |> filled red 
                                 |> rotate (degrees 90)  
                                 |> move (400,50))
                            (GraphicSVG.text ("Grocery Expense" ++ ": $" ++ String.fromFloat(model.userInfo.groceries))
                             |> GraphicSVG.size 15
                             |> filled red
                             |> move (300,-135))
                            ,  union (wedge 150 (model.userInfo.entertainment / model.userInfo.income)
                                 |> filled blue
                                 |> rotate (degrees (((model.userInfo.groceries / model.userInfo.income) + (model.userInfo.entertainment / model.userInfo.income)/2) * 360))
                                 |> move (400,50))
                            (GraphicSVG.text ("Entertainment Expenses" ++ ": $" ++ String.fromFloat(model.userInfo.entertainment))
                             |> GraphicSVG.size 15
                             |> filled blue
                             |> move (300,-150))
                            ,  union (wedge 150 (model.userInfo.otherE / model.userInfo.income)
                                 |> filled yellow
                                 |> rotate (degrees (((model.userInfo.groceries / model.userInfo.income) + (model.userInfo.entertainment / model.userInfo.income) + (model.userInfo.otherE / model.userInfo.income) / 2) * 360)) 
                                 |> move (400,50))
                            (GraphicSVG.text ("Other Expenses" ++ ": $" ++ String.fromFloat(model.userInfo.otherE))
                             |> GraphicSVG.size 15
                             |> filled yellow
                             |> move (300,-165))
                             
                            ,  union (rect 75 (model.userInfo.resL / 100)
                                 |> filled red 
                                 |> move (-275, -35))
                            (GraphicSVG.text ("Residential Loan Amount: $" ++ String.fromFloat(model.userInfo.resL))
                             |> GraphicSVG.size 15
                             |> filled red
                             |> move (-475, -150))
                            
                            ,  union (rect 75 (model.userInfo.resLI / 100)
                                 |> filled blue
                                 |> move (-275, (model.userInfo.resL / 100)))
                            (GraphicSVG.text ("Other Loan Amount: $" ++ String.fromFloat(model.userInfo.resLI))
                             |> GraphicSVG.size 15
                             |> filled red
                             |> move (-125, -75))

                            ,  union (rect 75 (model.userInfo.otherL / 100)
                                 |> filled red 
                                 |> move (-175, -10))
                            (GraphicSVG.text ("Other Interest Amount: $" ++ String.fromFloat(model.userInfo.otherL))
                             |> GraphicSVG.size 15
                             |> filled blue
                             |> move (-125, 100))
                            
                            ,  union (rect 75 (model.userInfo.otherLI / 100)
                                 |> filled blue 
                                 |> move (-175, 140))
                            (GraphicSVG.text ("Residential Interest Amount: $" ++ String.fromFloat(model.userInfo.otherLI))
                             |> GraphicSVG.size 15
                             |> filled blue
                             |> move (-487, 150))

                            , GraphicSVG.text (model.error)
                             |> GraphicSVG.size 15
                             |> filled black
                             |> move (0, 265)

                              ]
                 LoanTracker -> [union (rect 75 (model.userInfo.resL / 100)
                                 |> filled red 
                                 |> move (225, -35))
                            (GraphicSVG.text ("Residential Loan Amount: $" ++ String.fromFloat(model.userInfo.resL))
                             |> GraphicSVG.size 15
                             |> filled red
                             |> move (-50, -75))
                            
                            ,  union (rect 75 (model.userInfo.resLI / 100)
                                 |> filled blue
                                 |> move (225, 65))
                            (GraphicSVG.text ("Other Loan Amount: $" ++ String.fromFloat(model.userInfo.resLI))
                             |> GraphicSVG.size 15
                             |> filled red
                             |> move (380, -75))

                            ,  union (rect 75 (model.userInfo.otherL / 100)
                                 |> filled red 
                                 |> move (325, -10))
                            (GraphicSVG.text ("Other Interest Amount: $" ++ String.fromFloat(model.userInfo.otherL))
                             |> GraphicSVG.size 15
                             |> filled blue
                             |> move (380, 100))
                            
                            ,  union (rect 75 (model.userInfo.otherLI / 100)
                                 |> filled blue 
                                 |> move (325, 140))
                            (GraphicSVG.text ("Residential Interest Amount: $" ++ String.fromFloat(model.userInfo.otherLI))
                             |> GraphicSVG.size 15
                             |> filled blue
                             |> move (-50, 100))
                            , GraphicSVG.text (model.error)
                             |> GraphicSVG.size 15
                             |> filled black
                             |> move (10, 270) ]
                 ExpenseTracker -> [union (circle (150)
                                 |> filled orange
                                 |> move (400,50))
                            (GraphicSVG.text ("Total Income" ++ ": $" ++ String.fromFloat(model.userInfo.income))
                             |> GraphicSVG.size 15
                             |> filled orange
                             |> move (300,-120))
                            ,  union (wedge 150 (model.userInfo.groceries / model.userInfo.income)
                                 |> filled red 
                                 |> rotate (degrees 90)  
                                 |> move (400,50))
                            (GraphicSVG.text ("Grocery Expense" ++ ": $" ++ String.fromFloat(model.userInfo.groceries))
                             |> GraphicSVG.size 15
                             |> filled red
                             |> move (300,-135))
                            ,  union (wedge 150 (model.userInfo.entertainment / model.userInfo.income)
                                 |> filled blue
                                 |> rotate (degrees (((model.userInfo.groceries / model.userInfo.income) + (model.userInfo.entertainment / model.userInfo.income)/2) * 360))
                                 |> move (400,50))
                            (GraphicSVG.text ("Entertainment Expenses" ++ ": $" ++ String.fromFloat(model.userInfo.entertainment))
                             |> GraphicSVG.size 15
                             |> filled blue
                             |> move (300,-150))
                            ,  union (wedge 150 (model.userInfo.otherE / model.userInfo.income)
                                 |> filled yellow
                                 |> rotate (degrees (((model.userInfo.groceries / model.userInfo.income) + (model.userInfo.entertainment / model.userInfo.income) + (model.userInfo.otherE / model.userInfo.income) / 2) * 360)) 
                                 |> move (400,50))
                            (GraphicSVG.text ("Other Expenses" ++ ": $" ++ String.fromFloat(model.userInfo.otherE))
                             |> GraphicSVG.size 15
                             |> filled yellow
                             |> move (300,-165))
                             , GraphicSVG.text (model.error)
                             |> GraphicSVG.size 15
                             |> filled black
                             |> move (10, 270)
                             ]

-- Decoding the JSON Recieved from Django
uinfoJsonD : JDecode.Decoder UserInfo  
uinfoJsonD = 
    JDecode.map8 UserInfo  
        (JDecode.field "income" JDecode.float)
        (JDecode.field "groceries" JDecode.float)
        (JDecode.field "entertainment" JDecode.float)
        (JDecode.field "otherE" JDecode.float)
        (JDecode.field "resL" JDecode.float)
        (JDecode.field "resLI" JDecode.float)
        (JDecode.field "otL" JDecode.float)
        (JDecode.field "otLI" JDecode.float)

-- Encoding the JSON to send to Database
uinfoJsonE : Model -> JEncode.Value
uinfoJsonE model = JEncode.object [
        ( "Income" , JEncode.string model.sendUserInfo.income ),
        ( "ExpenseVal" , JEncode.string model.sendUserInfo.expenseVal ),
        ( "ExpenseType" , JEncode.string model.sendUserInfo.expenseType ),
        ( "LoanVal" , JEncode.string model.sendUserInfo.loanVal ),
        ( "LoanPeriod" , JEncode.string model.sendUserInfo.loanPeriod ),
        ( "LoanInterest" , JEncode.string model.sendUserInfo.loanInterest ),
        ( "LoanType" , JEncode.string model.sendUserInfo.loanType )
    ]

-- Function to Send Info
saveUserInfo : Model ->  Cmd Msg
saveUserInfo model = Http.post {
        url = rootUrl ++ "userauth/saveuserinfo/",
        body = Http.jsonBody <| uinfoJsonE model,
        expect = Http.expectString GetResponse 
    }

-- Function to get Info
getUserInfo : Cmd Msg
getUserInfo =
    Http.get 
        { url = rootUrl ++ "userauth/getuserinfo/"
        , expect = Http.expectJson UserInfoResponse uinfoJsonD
        }

-- Function to Check Authentication
getAuth : Cmd Msg
getAuth =
    Http.get
        { url = rootUrl ++ "userauth/isauth/"
        , expect = Http.expectString GetResponse
        }
-- Function to Logout
doLogOut : Cmd Msg
doLogOut =
    Http.get
        { url = rootUrl ++ "userauth/logoutuser/"
        , expect = Http.expectString GetResponse
        }



-- Function to Handle Errors
handleError : Model -> Http.Error -> Model
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | error = "Bad URL: " ++ url }

        Http.Timeout ->
            { model | error = "Timeout" }

        Http.NetworkError ->
            { model | error = "Network Error" }

        Http.BadStatus i ->
            { model | error = "Bad Status " ++ String.fromInt i }

        Http.BadBody body ->
            { model | error = "Bad Body " ++ body }


-- Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
   case msg of
        Tick time getKeyState ->
           ( model , Cmd.none )

        MakeRequest req ->
           ( model, Cmd.none ) -- do nothing

        UrlChange url ->
           ( model, Cmd.none ) -- do nothing

        AddButton ->
           ( model, saveUserInfo model)
        
        RefreshButton ->
           ( model, getUserInfo)

        -- Updating the SendUserInfo in model
        NewI income -> 
           ( { model | sendUserInfo = {income = income, loanVal = model.sendUserInfo.loanVal, expenseVal = model.sendUserInfo.expenseVal, 
           expenseType = model.sendUserInfo.expenseType, loanPeriod = model.sendUserInfo.loanPeriod, 
           loanInterest = model.sendUserInfo.loanInterest, loanType = model.sendUserInfo.loanType }}, Cmd.none)

        NewLA amount -> 
           ( { model | sendUserInfo = {loanVal = amount, income = model.sendUserInfo.income, expenseVal = model.sendUserInfo.expenseVal, 
           expenseType = model.sendUserInfo.expenseType, loanPeriod = model.sendUserInfo.loanPeriod, 
           loanInterest = model.sendUserInfo.loanInterest, loanType = model.sendUserInfo.loanType }}, Cmd.none)
        
        NewLP period ->
           ( { model | sendUserInfo = {loanPeriod = period, income = model.sendUserInfo.income, expenseVal = model.sendUserInfo.expenseVal, 
           expenseType = model.sendUserInfo.expenseType, loanVal = model.sendUserInfo.loanVal,  
           loanInterest = model.sendUserInfo.loanInterest, loanType = model.sendUserInfo.loanType }}, Cmd.none)

        NewLT ty ->
           ( { model | sendUserInfo = {loanType = ty, income = model.sendUserInfo.income, expenseVal = model.sendUserInfo.expenseVal, 
           expenseType = model.sendUserInfo.expenseType, loanVal = model.sendUserInfo.loanVal, loanPeriod = model.sendUserInfo.loanPeriod, 
           loanInterest = model.sendUserInfo.loanInterest}}, Cmd.none)
        
        NewLI rate ->
           ( { model | sendUserInfo = {loanInterest = rate, income = model.sendUserInfo.income, expenseVal = model.sendUserInfo.expenseVal, 
           expenseType = model.sendUserInfo.expenseType, loanVal = model.sendUserInfo.loanVal, loanPeriod = model.sendUserInfo.loanPeriod, 
           loanType = model.sendUserInfo.loanType}}, Cmd.none)

        NewEA amount ->
           ( { model | sendUserInfo = {expenseVal = amount, income = model.sendUserInfo.income, 
           expenseType = model.sendUserInfo.expenseType, loanVal = model.sendUserInfo.loanVal, loanPeriod = model.sendUserInfo.loanPeriod, 
           loanInterest = model.sendUserInfo.loanInterest, loanType = model.sendUserInfo.loanType }}, Cmd.none)
        
        NewET ty ->
           ( { model | sendUserInfo = {expenseType = ty, income = model.sendUserInfo.income, expenseVal = model.sendUserInfo.expenseVal, 
           loanVal = model.sendUserInfo.income, loanPeriod = model.sendUserInfo.loanPeriod, 
           loanInterest = model.sendUserInfo.loanInterest, loanType = model.sendUserInfo.loanType }}, Cmd.none)
       -- Change Pages
        Show page ->
            ( { model | pageL = page }, Cmd.none )
        
        LogOut ->
            (model, doLogOut)
        
        GetSize x ->
            ( { model | size = { x = x.viewport.width, y = x.viewport.height } }, getAuth )
        -- Putting the recievedInfo into model userInfo
        UserInfoResponse result ->
            case result of 
                 Ok recievedInfo -> 
                    ({ model | userInfo = recievedInfo }, Cmd.none )

                 Err error -> 
                    ( handleError model error , Cmd.none )

        GetResponse result ->
            case result of
                Ok "NotAuth" ->
                    ( { model | error = "Not Authenticated" }, load "project03.html")
                
                Ok "LoggedOut" ->
                    ( { model | error = "Logged Out"}, load "project03.html")

                Ok "IsAuth" ->
                    ( model, getUserInfo )
                
                Ok "InformationUpdated" ->
                    ( { model | error = "Information Updated" }, Cmd.none)
                
                Ok _ ->
                    ( model, getUserInfo )

                Err error ->
                    ( handleError model error, Cmd.none )



-- Dashboard Page View
dashboardView : Model -> Html Msg 
dashboardView model = div [] 
    [ ol [ class "breadcrumb" ]
    [ li [ class "breadcrumb-item" ]
                        [ a [ ]
                            [ Html.text "Dashboard" ]
                        ]
                        
                    ]
                    , div []
                        [Html.text "Please enter Income first then press Update"]
                     ,div [ ]
                        [ input [ id "inputExp", placeholder "Income", attribute "required" "required", type_ "text", Events.onInput NewI ]
                                []
                        ]
                    , button [ class "", Events.onClick AddButton ]
                        [ Html.text "Update" ]
                    , button [ class "", Events.onClick RefreshButton ]
                        [ Html.text "Refresh" ]
    ]
 
-- Loan Tracker Page View
loantrackerView : Model -> Html Msg 
loantrackerView model = div [] 
    [ ol [ class "breadcrumb" ]
    [ li [ class "breadcrumb-item" ]
                        [ a [ ]
                            [ Html.text "Loan Tracker" ]
                        ]
                    ]
                    , div []
                        [Html.text "Please enter Loan Amount"]
                    , div [ class "inputLoan" ]
                        [ input [ id "inputLoan", placeholder "Loan Amount", attribute "required" "required", type_ "text", Events.onInput NewLA ]
                                []
                        ]
                    , div []
                        [Html.text ""]
                    , div []
                        [Html.text "Please enter either Residential or Other"]
                    , div [ class "inputLoan" ]
                        [ input [ id "inputLoan", placeholder "Loan Type", attribute "required" "required", type_ "text", Events.onInput NewLT ]
                                []
                        ]
                    , div []
                        []
                    , div []
                        [Html.text "Please enter in Number of Years (Integer)"]
                    , div [ class "inputLoan" ]
                        [ input [ id "inputLoan", placeholder "Loan Period", attribute "required" "required", type_ "text", Events.onInput NewLP ]
                                []
                        ]
                    , div []
                        []
                    , div []
                        [Html.text "Please enter Interest Rate"]
                    , div [ class "inputLoan" ]
                        [ input [ id "inputLoan", placeholder "Loan Interest Rate", attribute "required" "required", type_ "text", Events.onInput NewLI ]
                                []
                        ]
                    , button [ class "", Events.onClick AddButton ]
                        [ Html.text "Add" ]
                    , button [ class "", Events.onClick RefreshButton ]
                        [ Html.text "Refresh" ]
                      
    ]
-- Expense Tracker Page View
expensetrackerView : Model -> Html Msg 
expensetrackerView model = div [] 
    [ ol [ class "breadcrumb" ]
    [ li [ class "breadcrumb-item" ]
                        [ a [ ]
                            [ Html.text "Expense Tracker" ]
                        ]
    ]               , div []
                        [Html.text "Please enter Expense Amount"]
                    , div [ ]
                        [ input [ id "inputExp", placeholder "Expense Amount", attribute "required" "required", type_ "text", Events.onInput NewEA ]
                                []
                        ]
                    , div []
                        [Html.text "Please enter either Groceries or Entertainment or Other"]
                    , div [ class "inputLoan" ]
                        [ input [ id "inputLoan", placeholder "Expense Type", attribute "required" "required", type_ "text", Events.onInput NewET ]
                                []
                        ]
                    , button [ class "", Events.onClick AddButton ]
                        [ Html.text "Add" ]
                    , button [ class "", Events.onClick RefreshButton ]
                        [ Html.text "Refresh" ]
                     
    
    ]

-- Rendering the Website 
htmlView : Model -> Html Msg
htmlView model = div []
    [ node "link" [ href "SiteFiles/vendor/fontawesome-free/css/all.min.css", rel "stylesheet", type_ "text/css" ]
        []
    , node "link" [ href "SiteFiles/vendor/datatables/dataTables.bootstrap4.css", rel "stylesheet" ]
        []
    , node "link" [ href "SiteFiles/css/sb-admin.css", rel "stylesheet" ]
        []
    , nav [ class "navbar navbar-expand navbar-dark bg-dark static-top" ]
        [ a [ class "navbar-brand mr-1", href "" ]
            [ Html.text "FinTrack" ]
        , ul [ class "navbar-nav ml-auto ml-md-0" ]
            [ li [ class "nav-item no-arrow" ]
                [ a [ attribute "aria-expanded" "false", class "nav-link ",  attribute "role" "button", Events.onClick LogOut]
                    [ Html.text "Log Out"]
                    
                ]
            ]
        ]
    , div [ id "wrapper" ]
        [ ul [ class "sidebar navbar-nav" ]
            [ li [ class "nav-item " ]
                [ a [ class "nav-link", Events.onClick (Show Dashboard) ]
                    [ i [ class "fas fa-fw fa-tachometer-alt"]
                        []
                    , span []
                        [ Html.text " Dashboard" ]
                    ]
                ]
            , li [ class "nav-item dropdown" ]
                [ a [ class "nav-link", Events.onClick (Show ExpenseTracker) ]
                    [ i [ class "fas fa-fw fa-folder" ]
                        []
                    , span []
                        [ Html.text " Expense Tracker" ]
                    ]
                ]
            , li [ class "nav-item" ]
                [ a [ class "nav-link" , Events.onClick (Show LoanTracker) ]
                    [ i [ class "fas fa-fw fa-chart-area" ]
                        []
                    , span []
                        [ Html.text " Loan Tracker" ]
                    ]
                ]
            ]
        , div [ id "content-wrapper" ]
            [ div [ class "container-fluid" ]
                [ 
          
                ]
            , Html.text "      "
            , footer [ class "sticky-footer" ]
                [ div [ class "container my-auto" ]
                    [ div [ class "copyright text-center my-auto" ]
                        [ span []
                            [  ]
                        ]
                    ]
                ]
            ]
        , Html.text "  "
        ]
    , Html.text "  "
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
 Sub.none
