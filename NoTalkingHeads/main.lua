local NoTalkingHeadFrame = CreateFrame("FRAME", "NTHF")
local TALKINGHEAD_OPEN = "TALKINGHEAD_REQUESTED"

local debugmode = 0

local function CloseTalkingHead(self, evt, text, source)
  --- close the talking head frame
  if debugmode == 1 then
    local displayInfo, cameraID, vo, duration, lineNumber, numLines, name, text, isNewTalkingHead, textureKit = C_TalkingHead.GetCurrentLineInfo()
    DEFAULT_CHAT_FRAME:AddMessage(string.format("Closing chat %s: %s", name, text))
  end
  C_TalkingHead.IgnoreCurrentTalkingHead()
end

NoTalkingHeadFrame:RegisterEvent(TALKINGHEAD_OPEN)
NoTalkingHeadFrame:SetScript("OnEvent", CloseTalkingHead)
