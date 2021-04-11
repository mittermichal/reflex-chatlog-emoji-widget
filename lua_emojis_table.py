#https://raw.githubusercontent.com/Ranks/emojione/master/lib/python/emojipy/ruleset.py
import ruleset
import operator

icons=[
'arena',
'armor',
'bigHead',
'bronze',
'buttonRightArrow',
'carnage',
'circleSplat',
'comboBoxArrow',
'CTFflag',
'dedicatedServer',
'download',
'drown',
'falling',
'favourite',
'forfeit',
'gold',
'grunge-edge',
'health',
'hostile',
'checkBoxTick',
'infinite',
'info_alert',
'info_questionmark',
'instagib',
'keyBack',
'keyCrouch',
'keyForward',
'keyJump',
'keyLeft',
'keyRight',
'lag',
'lava',
'listenServer',
'lowGrav',
'menuSelected',
'minus',
'passwordedServer',
'plus',
'quit',
'rank1Simple',
'rank2Simple',
'rank3Simple',
'rank4Simple',
'rank5Simple',
'rank6Simple',
'rank7Simple',
'reflexlogo',
'reflexlogo_high',
'refresh',
'replayForward',
'replayPause',
'replayPlay',
'replayReset',
'replayRewind',
'resist',
'searchIcon',
'silver',
'skull',
'socialDiscord',
'socialFacebook',
'socialReddit',
'socialTwitter',
'socialYoutube',
'star',
'strikeThrough',
'strikeThroughLong',
'strikeThroughShort',
'subscribe',
'teleporter',
'thumbsdown',
'thumbsup',
'tick',
'tooltipIcon',
'turret',
'upArrow',
'url',
'vampire',
'warmup',
'weapon1',
'weapon2',
'weapon3',
'weapon4',
'weapon5',
'weapon6',
'weapon7',
'weapon8',
'weapon9'
]


f=open('EmojiTable.lua','w')
f.write('require "base/internal/ui/reflexcore"\n')
f.write("SHORTCODE_REPLACE = {")
for key, value in sorted(ruleset.shortcode_replace.items(), key=operator.itemgetter(0)):
	f.write("['"+key[1:-1]+"'] = '"+value+"',\n")
f.write("['locktarparse'] = 'locktar',\n")
f.write("}\n")
f.write("ICONS = {")
for icon in icons:
	f.write("['" +icon+ "']  = Color(255,201,50,255),\n")
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
