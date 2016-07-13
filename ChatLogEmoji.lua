--------------------------------------------------------------------------------
-- modification of official reflex chatlog (04.07.2016)
-- by Kimi https://github.com/mittermichal/reflex-chatlog-emoji-widget
--------------------------------------------------------------------------------

require "base/internal/ui/reflexcore"
require "EmojiDraw"

ChatLogEmoji =
{
	--canHide = false;
	canPosition = true;

	cursorFlash = 0;
	entryOffsetX = 0;
};
registerWidget("ChatLogEmoji");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function formatRaceMessage(logEntry)
	
	-- is this event for the player we're watching?
	local isLocal = logEntry.racePlayerIndex == playerIndexCameraAttachedTo;

	-- find topscore
	local topScore = 0;
	for k, v in pairs(players) do
		if v.connected and v.score ~= 0 then
			if topScore == 0 then
				topScore = v.score;
			else
				topScore = math.min(topScore, v.score);
			end
		end
	end

	if logEntry.raceEvent == RACE_EVENT_FINISH or logEntry.raceEvent == RACE_EVENT_FINISHANDWASRECORD then
		local formattedTime = FormatTimeToDecimalTime(logEntry.raceTime);

		-- fixme: if players draw, if someone finishes in EXACTLY the same time, we can't tell the difference here
		local optText = "";
		if topScore == logEntry.raceTime and logEntry.raceEvent == RACE_EVENT_FINISHANDWASRECORD then
			optText = ", and is in the lead!";
		end

		return string.format("%s finished race in %s%s", logEntry.raceName, formattedTime, optText);
	end

	return nil;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function pullWord(text)
	local space = string.find(text, "%s");
	if space == nil then
		return text, "";
	else
		--consolePrint(text .. " -> " .. string.sub(text, 0, space-1) .. ", " .. string.sub(text, space+1));
		return string.sub(text, 0, space-1), string.sub(text, space+1);
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function splitTextToMultipleLines(text, w)
	local lines = {};
	local lineCount = 0;
	local newLine = "";
	
	while string.len(text) > 0 do
		local newWord;

		newWord, text = pullWord(text);

		-- spit out new line
		if nvgTextWidth(newLine .. " " .. newWord) > w then
			lineCount = lineCount + 1;
			lines[lineCount] = newLine;
			newLine = "";
		end

		-- append new word
		if string.len(newLine) > 0 then
			newLine = newLine .. " " .. newWord;
		else
			newLine = newWord;
		end
	end

	-- if there's left-overs, it goes on new line
	if string.len(newLine) > 0 then
		lineCount = lineCount + 1;
		lines[lineCount] = newLine;
	end

	return lines, lineCount;
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local lastBeepId = 0;
function ChatLogEmoji:draw()
	local localPlayer = getLocalPlayer();
	local shouldBeep = false;
	local cursorFlashPeriod = 0.25;
	
	local col = Color(230, 230, 230);
	local colTeam = Color(126, 204, 255);
	local colSpec = Color(255, 204, 126);
	local borderPad = 10;
	local logCount = 0;
	local x = 0;
	local y = 0;
	local w = 800;
	local h = 196;
	local bordery = y+12;

	for k, v in pairs(log) do
		logCount = logCount + 1;
	end

	-- no chatlog in menu replay
	if replayName == "menu" then
		return false;
	end
	
	-- prep
	nvgFontSize(FONT_SIZE_DEFAULT);
	nvgFontFace(FONT_TEXT);
	nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
	
	-- read input
	local say = sayRegion();
	
	-- if cursor moves, restart flash
	self.cursorFlash = self.cursorFlash + deltaTimeRaw;
	if say.cursorChanged then
		self.cursorFlash = 0;
	end

	-- when typing draw border
	if say.hoverAmount > 0 then
		local intensity = say.hoverAmount;
		local borderCol = Color(150, 150, 150, 150 * intensity);
		local bgCol = Color(34+10, 36+10, 40+10, 150 * intensity);

		-- draw bg
		nvgBeginPath();
		nvgRoundedRect(x - borderPad, bordery - h - borderPad, w + borderPad * 2, h + borderPad * 2, 10);
		nvgFillColor(bgCol);
		nvgFill();
		nvgStrokeColor(borderCol);
		nvgStroke();

		-- draw separator
		nvgBeginPath();
		nvgMoveTo(x - borderPad, y - 15);
		nvgLineTo(x + w + borderPad, y - 15);
		nvgStroke(borderCol);

		--nvgBeginPath();
		--nvgRect(x, bordery - h, w, h);
		--nvgFillColor(Color(255, 0, 0));
		--nvgFill();

		-- prepare "player: " 
		local entryTextStart = localPlayer.name;
		local entryCol = Color(col.r, col.g, col.b, 255 * intensity);
		if say.sayTeam then
			entryCol.r = colTeam.r;
			entryCol.g = colTeam.g;
			entryCol.b = colTeam.b;
			entryTextStart = entryTextStart .. " (team)";
		elseif say.saySpec then
			entryCol.r = colSpec.r;
			entryCol.g = colSpec.g;
			entryCol.b = colSpec.b;
			entryTextStart = entryTextStart .. " (spec)";
		end
		entryTextStart = entryTextStart .. ": ";
		local entryTextStartLen = string.len(entryTextStart);

		-- draw "player: "
		nvgFontBlur(2);
		nvgFillColor(Color(0, 0, 0, intensity*255));
		nvgText(x, y + 1, entryTextStart);
		nvgFontBlur(0);
		nvgFillColor(entryCol);
		nvgText(x, y, entryTextStart);
		local entryTextStartWidth = nvgTextWidth(entryTextStart);
		
		-- prepare actual say text
		local entryText = say.text;
		local entryLen = string.len(entryText);
		local tx = x + entryTextStartWidth+self.entryOffsetX;
		local textUntilCursor = string.sub(entryText, 0, say.cursor);
		local textWidthAtCursor = nvgTextWidth(textUntilCursor);
		
		-- handle scrolling back/forward with a large buffer!
		local cursorx = tx + textWidthAtCursor;
		local endx = (x+w);
		local cursorpast = cursorx - endx;
		if cursorpast > 0 then
			self.entryOffsetX = self.entryOffsetX - cursorpast;
		end
		local startx = x + entryTextStartWidth;
		local cursorearly = startx - cursorx;
		if cursorearly > 0 then
			self.entryOffsetX = self.entryOffsetX + cursorearly;
		end
		tx = x + entryTextStartWidth+self.entryOffsetX; -- update now, so we're not a frame late
		
		-- clip actual text
		nvgSave();
		nvgIntersectScissor(x+entryTextStartWidth, y-50, w-entryTextStartWidth, h);
		
		-- draw actual text
		nvgFontBlur(2);
		nvgFillColor(Color(0, 0, 0, intensity*255));
		nvgText(tx, y + 1, entryText);
		nvgFontBlur(0);
		nvgFillColor(entryCol);
		nvgText(tx, y, entryText);

		-- multiple selection, draw selection field
		if say.cursor ~= say.cursorStart then
			local textUntilCursorStart = string.sub(entryText, 0, say.cursorStart);
			local textWidthAtCursorStart = nvgTextWidth(textUntilCursorStart);
		
			local selx = math.min(textWidthAtCursor, textWidthAtCursorStart);
			local selw = math.abs(textWidthAtCursor - textWidthAtCursorStart);
			nvgBeginPath();
			nvgRect(tx + selx, y - 10, selw, 22);
			nvgFillColor(Color(255, 192, 192, 128));
			nvgFill();	
		end

		-- remove clip
		nvgRestore();

		-- flashing cursor
		if self.cursorFlash < cursorFlashPeriod then
			nvgBeginPath();
			nvgMoveTo(tx + textWidthAtCursor, y - 10);
			nvgLineTo(tx + textWidthAtCursor, y + 12);
			nvgStrokeColor(Color(col.r,col.g,col.b,128*intensity));
			nvgStroke();
		else
			if self.cursorFlash > cursorFlashPeriod*2 then
				self.cursorFlash = 0;
			end
		end
	end
			
	y = y - 34;
	nvgScissor(x, bordery - h, w, h);
	
	-- history
	for i = 1, logCount do
		local logEntry = log[i];
		local intensity = clamp(1 - (logEntry.age - 9), 0, 1); -- fade out from 9->10 seconds

		local text = nil;

		if logEntry.type == LOG_TYPE_CHATMESSAGE then
			local mod = "";

			col = Color(239, 237, 255, 255*intensity);
			if logEntry.chatType == LOG_CHATTYPE_TEAM then
				col = Color(126, 204, 255);
				mod = " (team)";
			end
			if logEntry.chatType == LOG_CHATTYPE_SPECTATOR then
				col = Color(255, 204, 126);
				mod = " (spec)";
			end

			text = logEntry.chatPlayer .. mod .. ": " .. logEntry.chatMessage;

			local id = logEntry.id;
			if id > lastBeepId then
				lastBeepId = id;
				shouldBeep = true;
			end

		elseif logEntry.type == LOG_TYPE_NOTIFICATION then
			col = Color(255, 288, 0);
			text = logEntry.notification;
		elseif logEntry.type == LOG_TYPE_RACEEVENT then
			col = Color(255, 30, 30);
			text = formatRaceMessage(logEntry);			
		end

		if text ~= nil then
			local lines, lineCount = splitTextToMultipleLines(text, w);
			
			for line = lineCount, 1, -1 do
				local lineText = lines[line];

				-- bg
				nvgFontBlur(2);
				nvgFillColor(Color(0, 0, 0, 255*intensity));
				--nvgText(x, y + 1, lineText);
				drawTextWithEmojis(x, y+ 1, lineText)
				-- foreground
				nvgFontBlur(0);
				nvgFillColor(col);
				--nvgText(x, y, lineText);
				drawTextWithEmojis(x, y, lineText)
				
				y = y - 24;
			end
		end
	end
	
	if shouldBeep then playSound("internal/misc/chat") end
end
