#
# OperInit-Lv1.tcl
#



########
# Motd #
########

# putlog "\002OperInit-Lv1.tcl\002"



#########
# binds #
#########

bind dcc n dump block:commande
bind dcc n jump block:commande
bind dcc - nick block:commande
bind dcc - handle block:commande

proc block:commande { hand idx arg } {
  putdcc $idx "Quoi? Essayez '.help'"
  return 0
}



############
# OperInit #
############

bind raw - "002" OperInitLv1

proc OperInitLv1 { from key text } {
    global botnick

    if { [string match "*Your host is irc.voila.fr*" $text]
      || [string match "*Your host is chat1.voila.fr*" $text]
      || [string match "*Your host is chat4.x-echo.com*" $text]
      || [string match "*Your host is chat5.x-echo.com*" $text]
      || [string match "*Your host is chat7.x-echo.com*" $text]
      || [string match "*Your host is chat9.x-echo.com*" $text]
      || [string match "*Your host is chat14.x-echo.com*" $text] } {
        set temp [file:get "../TCL/Ibu/OperInit.conf"]
        raw "OPER [decrypt f8gKRaDlF0:F8jGK3fCnDe3 [lindex [split $temp] 0]] [decrypt k3jfCnV_Fh30rkFl2rkFdEr [lindex [split $temp] 1]]"
#        raw "MODE $botnick +a"
        unset temp
    }
    return 0
}

bind raw - "381" OperAuth
proc OperAuth { from key text } {
  global botnick Oper nick
  if { $botnick != $nick } {
    raw "KILL $nick :nick!"
    raw "NICK $nick" 
  }
}


bind raw - "432" OperQline
proc OperQline { from key text } {
  global botnick nick altnick
  raw "NICK $altnick"
}

