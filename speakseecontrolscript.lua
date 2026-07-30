--------------------------------------------------
-- SoundShape / SpeakSee Controller
-- Q-SYS Custom Control Script
--------------------------------------------------

IPAddress = "192.168.1.100"
Port = 80

--------------------------------------------------
-- Helpers
--------------------------------------------------

function BuildURL(Path)
    return "http://" ..
           tostring(IPAddress) ..
           ":" ..
           tostring(Port) ..
           Path
end

function SetStatus(Text)
    Controls.StatusText.String = Text
end

function SetError(Text)
    Controls.ErrorText.String = Text
end

--------------------------------------------------
-- HTTP GET
--------------------------------------------------

function GetStatus()

    HttpClient.Get {

        Url = BuildURL("/api/status"),

        Timeout = 10,

        EventHandler = function(tbl, code, data)

            if code == 200 then

                Controls.Connected.Value = 1
                SetStatus("Connected")

                print(data)

            else

                Controls.Connected.Value = 0

                SetError(
                    "HTTP Error " ..
                    tostring(code)
                )

            end

        end

    }

end

--------------------------------------------------
-- Start Session
--------------------------------------------------

function StartSession()

    HttpClient.Post {

        Url = BuildURL("/api/session/start"),

        Headers = {
            ["Content-Type"] = "application/json"
        },

        Data = "{}",

        EventHandler = function(tbl, code, data)

            if code == 200 then

                SetStatus(
                    "Session Started"
                )

            else

                SetError(
                    "Start Failed: " ..
                    tostring(code)
                )

            end

        end

    }

end

--------------------------------------------------
-- Stop Session
--------------------------------------------------

function StopSession()

    HttpClient.Post {

        Url = BuildURL("/api/session/stop"),

        Headers = {
            ["Content-Type"] = "application/json"
        },

        Data = "{}",

        EventHandler = function(tbl, code, data)

            if code == 200 then

                SetStatus(
                    "Session Stopped"
                )

            else

                SetError(
                    "Stop Failed"
                )

            end

        end

    }

end

--------------------------------------------------
-- Enable Translation
--------------------------------------------------

function EnableTranslation()

    HttpClient.Post {

        Url = BuildURL(
            "/api/translation/enable"
        ),

        Headers = {
            ["Content-Type"] =
            "application/json"
        },

        Data = "{}",

        EventHandler = function(tbl, code)

            if code == 200 then

                SetStatus(
                    "Translation Enabled"
                )

            else

                SetError(
                    "Translation Error"
                )

            end

        end

    }

end

--------------------------------------------------
-- Event Handlers
--------------------------------------------------

Controls.Connect.EventHandler =
function()

    GetStatus()

end

Controls.StartSession.EventHandler =
function()

    StartSession()

end

Controls.StopSession.EventHandler =
function()

    StopSession()

end

Controls.EnableTranslation.EventHandler =
function()

    EnableTranslation()

end

Controls.PollNow.EventHandler =
function()

    GetStatus()

end

--------------------------------------------------
-- Polling Timer
--------------------------------------------------

PollTimer = Timer.New()

PollTimer.EventHandler = function()

    GetStatus()

end

PollTimer:Start(10)

--------------------------------------------------
-- Startup
--------------------------------------------------

Controls.Connected.Value = 0

SetStatus("Starting...")
SetError("")

GetStatus()