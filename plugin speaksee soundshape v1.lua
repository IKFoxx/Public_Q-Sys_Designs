--========================================
-- SpeakSee / SoundShape Q-SYS Plugin
-- Single File Version v1.0  IKeuken
--========================================

PluginInfo = {
    Name = "SpeakSee Controller",
    Version = "1.0.0",
    Id = "com.soundshape.speaksee",
    Author = "Custom Integration"
}

--------------------------------------------------
-- Properties
--------------------------------------------------

Properties = {

    {
        Name = "Host",
        Type = "String",
        Value = "192.168.1.100"
    },

    {
        Name = "Port",
        Type = "Integer",
        Value = 80
    },

    {
        Name = "Username",
        Type = "String",
        Value = ""
    },

    {
        Name = "Password",
        Type = "String",
        Value = ""
    },

    {
        Name = "Polling Interval",
        Type = "Integer",
        Value = 10
    }
}

--------------------------------------------------
-- Controls
--------------------------------------------------

Controls = {

    {
        Name = "Connect",
        ControlType = "Button",
        Count = 1
    },

    {
        Name = "Disconnect",
        ControlType = "Button",
        Count = 1
    },

    {
        Name = "Status",
        ControlType = "Indicator",
        Count = 1
    },

    {
        Name = "StartSession",
        ControlType = "Button",
        Count = 1
    },

    {
        Name = "StopSession",
        ControlType = "Button",
        Count = 1
    },

    {
        Name = "EnableTranslation",
        ControlType = "Button",
        Count = 1
    },

    {
        Name = "DisableTranslation",
        ControlType = "Button",
        Count = 1
    },

    {
        Name = "Language",
        ControlType = "Text",
        Count = 1
    },

    {
        Name = "ActiveSpeakers",
        ControlType = "Text",
        Count = 1
    },

    {
        Name = "Mic1Battery",
        ControlType = "Knob",
        Count = 1
    },

    {
        Name = "Mic2Battery",
        ControlType = "Knob",
        Count = 1
    },

    {
        Name = "Mic3Battery",
        ControlType = "Knob",
        Count = 1
    },

    {
        Name = "LastError",
        ControlType = "Text",
        Count = 1
    }
}

--------------------------------------------------
-- Configuration
--------------------------------------------------

local HOST
local PORT

function LoadProperties()

    HOST = Properties["Host"].Value
    PORT = Properties["Port"].Value

end

LoadProperties()

--------------------------------------------------
-- Logging
--------------------------------------------------

function Debug(msg)
    print("[SpeakSee] " .. tostring(msg))
end

--------------------------------------------------
-- HTTP Helper
--------------------------------------------------

function BuildURL(path)

    return "http://" ..
           HOST ..
           ":" ..
           tostring(PORT) ..
           path

end

--------------------------------------------------
-- Status Polling
--------------------------------------------------

function GetStatus()

    HttpClient.Get {

        Url = BuildURL("/api/status"),

        Timeout = 10,

        EventHandler = function(tbl, code, data)

            if code == 200 then

                Controls.Status.Boolean = true
                Controls.LastError.String = ""

                local success, json =
                    pcall(RapidJSON.Decode, data)

                if success and json then

                    if json.activeSpeakers then
                        Controls.ActiveSpeakers.String =
                            tostring(json.activeSpeakers)
                    end

                    if json.language then
                        Controls.Language.String =
                            tostring(json.language)
                    end

                    if json.microphones then

                        if json.microphones[1] then
                            Controls.Mic1Battery.Value =
                                json.microphones[1].battery or 0
                        end

                        if json.microphones[2] then
                            Controls.Mic2Battery.Value =
                                json.microphones[2].battery or 0
                        end

                        if json.microphones[3] then
                            Controls.Mic3Battery.Value =
                                json.microphones[3].battery or 0
                        end

                    end

                end

            else

                Controls.Status.Boolean = false

                Controls.LastError.String =
                    "Status request failed (" ..
                    tostring(code) ..
                    ")"

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

                Debug("Session Started")

            else

                Controls.LastError.String =
                    "Start failed (" ..
                    tostring(code) ..
                    ")"

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

                Debug("Session Stopped")

            else

                Controls.LastError.String =
                    "Stop failed (" ..
                    tostring(code) ..
                    ")"

            end
        end
    }
end

--------------------------------------------------
-- Translation ON
--------------------------------------------------

function EnableTranslation()

    HttpClient.Post {

        Url = BuildURL("/api/translation/enable"),

        Headers = {
            ["Content-Type"] = "application/json"
        },

        Data = "{}",

        EventHandler = function(tbl, code, data)

            if code == 200 then

                Debug("Translation