#https://raw.githubusercontent.com/Ranks/emojione/master/lib/python/emojipy/ruleset.py
import ruleset
import operator

f=open('EmojiTable.lua','w')
f.write("SHORTCODE_REPLACE = {")
for key, value in sorted(ruleset.shortcode_replace.items(), key=operator.itemgetter(0)):
	f.write("['"+key[1:-1]+"'] = '"+value+"',\n")
f.write("}\n")
f.close()
'''
SHORTCODE_REPLACE = {
['stopwatch'] = '23f1',
.
.
.
}
'''
