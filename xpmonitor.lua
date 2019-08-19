xpmonitor_history = {}
xpmonitor_startTime = 0
xpmonitor_startXP = 0
xpmonitor_lastXP = 0
xpmonitor_lastMaxXP = 0
xpmonitor_gainedXPAllTime = 0
xpmonitor_xpPerMin = 0
xpmonitor_perSecondXP = 0
xpmonitor_updateInterval = 1.0
xpmonitor_isTimerStarted = false
xpmonitor_playedTimeAllTime = 0
xpmonitor_stopTime = 0
xpmonitor_hasPausedOnce = false
xpmonitor_lastNeedleDegree = 27

function xpmonitor_onLoad(self)
    self.timeSinceLastUpdate = 0

    xpmonitor_changeSize()
    xpmonitor_mainFrame:RegisterEvent("PLAYER_MONEY")
    xpmonitor_mainFrame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
    xpmonitor_mainFrame:RegisterEvent("TIME_PLAYED_MSG")

    xpmonitor_rotateTexture(xpmonitor_mainFrame_nadelTexture, xpmonitor_lastNeedleDegree)
end

function xpmonitor_onMouseDown()
    xpmonitor_mainFrame:StartMoving()
end

function xpmonitor_onMouseUp()
    xpmonitor_mainFrame:StopMovingOrSizing()
end

function xpmonitor_changeSize()
    local width = 155
    local height = 55

    -- width = width + xpmonitor_mainFrame_expPerMinuteLabel:GetStringWidth()

    xpmonitor_mainFrame:SetWidth(width)
    xpmonitor_mainFrame:SetHeight(height)
end

function xpmonitor_buttonStartMonitor_onClick()
    if not xpmonitor_isTimerStarted then
        xpmonitor_startTime = GetTime()
        xpmonitor_startXP = UnitXP("player")
        xpmonitor_lastXP = UnitXP("player")
        xpmonitor_lastMaxXP = UnitXPMax("player")
        xpmonitor_isTimerStarted = true
        xpmonitor_mainFrame_expPerMinuteLabel:SetTextColor(0,1,0,1)
        xpmonitor_mainFrame_expPerMinuteLabel:SetFont("GameFontNormal", 100)
        DEFAULT_CHAT_FRAME:AddMessage("Timer started")
        -- DEFAULT_CHAT_FRAME:AddMessage("Greetings from |cFFFF0000Totem|r|cFF00FF00Planter|r")
    end
end

function xpmonitor_buttonStopMonitor_onClick()
    if xpmonitor_isTimerStarted then
        xpmonitor_playedTimeAllTime = xpmonitor_playedTimeAllTime + (GetTime() - xpmonitor_startTime)
        local playedTimeHours = floor(xpmonitor_playedTimeAllTime / 3600)
        local playedTimeMinutes = floor((xpmonitor_playedTimeAllTime - (playedTimeHours * 3600)) / 60)
        local playedTimeSeconds = xpmonitor_playedTimeAllTime - (playedTimeHours * 3600) -  (playedTimeMinutes * 60)

        DEFAULT_CHAT_FRAME:AddMessage("You played: " .. playedTimeHours .. " h "
                                                     .. playedTimeMinutes .. " min "
                                                     .. playedTimeSeconds .. " sec")
        DEFAULT_CHAT_FRAME:AddMessage("You gained: " .. xpmonitor_gainedXPAllTime .. " EXP")

        xpmonitor_isTimerStarted = false
        xpmonitor_mainFrame_expPerMinuteLabel:SetTextColor(1,0,0,1)
        xpmonitor_hasPausedOnce = true
        DEFAULT_CHAT_FRAME:AddMessage("Timer stoped")
    end
end

function xpmonitor_buttonResetMonitor_onClick()
    xpmonitor_startTime = 0
    xpmonitor_startXP = 0
    xpmonitor_lastXP = 0
    xpmonitor_lastMaxXP = 0
    xpmonitor_gainedXPAllTime = 0
    xpmonitor_perSecondXP = 0
    xpmonitor_updateInterval = 1.0
    xpmonitor_isTimerStarted = false
    xpmonitor_playedTimeAllTime = 0
    xpmonitor_stopTime = 0
    xpmonitor_hasPausedOnce = false
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Data reseted!|r")

    xpmonitor_mainFrame_expPerMinuteLabel:SetText("XP/Min: 0")
    xpmonitor_mainFrame_expPerMinuteLabel:SetTextColor(1,0,0,1)
    xpmonitor_rotateTexture(xpmonitor_mainFrame_nadelTexture, 27)
    xpmonitor_changeSize()
end

function xpmonitor_onEvent(self, event, ...)
    if event == "PLAYER_MONEY" then
        DEFAULT_CHAT_FRAME:AddMessage("bla:")
    elseif event == "CURRENT_SPELL_CAST_CHANGED" then
    elseif event == "TIME_PLAYED_MSG" then
        DEFAULT_CHAT_FRAME:AddMessage("played-all: " .. (arg1 / 60 / 60))
        DEFAULT_CHAT_FRAME:AddMessage("played-level: " .. arg2)
    end
end

function xpmonitor_onUpdate(self, ...)
    self.timeSinceLastUpdate = self.timeSinceLastUpdate + arg1
    if (self.timeSinceLastUpdate > xpmonitor_updateInterval) then
        self.gainedXP = 0
        if (xpmonitor_isTimerStarted) then
            -- true if still same level --
            if (xpmonitor_lastMaxXP == UnitXPMax("player")) then
                self.gainedXP = UnitXP("player") - xpmonitor_lastXP
            elseif (xpmonitor_lastMaxXP < UnitXPMax("player")) then
                local diffToLevelUp = xpmonitor_lastMaxXP - xpmonitor_lastXP
                self.gainedXP = diffToLevelUp + (UnitXP("player"))
            end

            xpmonitor_lastMaxXP = UnitXPMax("player")
            xpmonitor_lastXP = UnitXP("player")
            xpmonitor_gainedXPAllTime = xpmonitor_gainedXPAllTime + self.gainedXP

            if not (xpmonitor_hasPausedOnce) then
                xpmonitor_xpPerMin = xpmonitor_gainedXPAllTime / ((GetTime() - xpmonitor_startTime) / 60)
            else
                xpmonitor_xpPerMin = xpmonitor_gainedXPAllTime / (((GetTime() - xpmonitor_startTime) + xpmonitor_playedTimeAllTime) / 60)
            end
            xpmonitor_mainFrame_expPerMinuteLabel:SetText("XP/Min: " .. xpmonitor_roundValue(xpmonitor_xpPerMin, 2))
            xpmonitor_changeSize()
        else

        end
        self.timeSinceLastUpdate = 0
    end
    if (xpmonitor_isTimerStarted) then
        xpmonitor_lastNeedleDegree = ((xpmonitor_xpPerMin / 4.27) * -1) + 27
        xpmonitor_rotateTexture(xpmonitor_mainFrame_nadelTexture, xpmonitor_lastNeedleDegree)
    end
end

function xpmonitor_roundValue(num, numDecimals)
    local mult = 10^(numDecimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function xpmonitor_calculateCorner(angle)
    local s2 = sqrt(2);
    local cos, sin, rad = math.cos, math.sin, math.rad;
	local r = rad(angle);
	return 0.5 + cos(r) / s2, 0.5 + sin(r) / s2;
end

function xpmonitor_rotateTexture(texture, angle)
	local LRx, LRy = xpmonitor_calculateCorner(angle + 45);
	local LLx, LLy = xpmonitor_calculateCorner(angle + 135);
	local ULx, ULy = xpmonitor_calculateCorner(angle + 225);
	local URx, URy = xpmonitor_calculateCorner(angle - 45);
	
	texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

