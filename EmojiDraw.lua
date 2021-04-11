require "EmojiTable"

local shortcode_regexp = ':([-+%w_]+):'
local emoji_reg = "("..shortcode_regexp..")" --missing ignore case

function drawTextWithEmojis(x,y,text)
	if string.len(text)==0 then return end 
	match_start,match_end=string.find(string.lower(text),shortcode_regexp)
	if match_start==nil then
		--consolePrint(text)
		nvgText(x,y,text)
		return
	end
	filename = SHORTCODE_REPLACE[string.sub(text,match_start+1,match_end-1)]
	--consolePrint(string.sub(text,match_start+1,match_end-1))
	if filename==nil then
		--consolePrint("no match")
		print_text=string.sub(text,0,match_end)
		--consolePrint(print_text)
		nvgText(x,y,print_text)
		x=x+nvgTextWidth(print_text)
	else
		print_text=string.sub(text,0,match_start-1)
		--consolePrint(nvgTextWidth(print_text))
		nvgText(x,y,print_text)
		--consolePrint(string.sub(text,match_start,match_end)..' -> '..filename)
		x=x+nvgTextWidth(print_text..'  ')
		size=FONT_SIZE_DEFAULT/2
		--rect=nvgTextBounds(print_text)
		--size=(rect.maxy-rect.miny)/2
		nvgSvg(emoji_path..filename, x+size/2, y, size)
		x=x+size*1.5
	end
	drawTextWithEmojis(x,y,string.sub(text,match_end+1,-1))
end
