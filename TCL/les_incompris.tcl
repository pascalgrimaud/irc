#
# les_incompris.tcl
#


#########
# .kill #
#########
bind pub I .kill les_incompris:pub:kill

proc les_incompris:pub:kill { nick uhost hand channel arg } {
  global botnick EggOper OperKill

  if { [string tolower $channel] == "#les_incompris"
    && [isop $nick $channel] } {

    set arg [split $arg]
    set XkillNick [lindex $arg 0]
    set XkillRaison [join [lrange $arg 1 end]]

    if { $XkillRaison == "" } {
      set XkillRaison "Gros vilain!"
    }

    if { $XkillNick != "" } {
      les_incompris:OperKill $XkillNick $XkillRaison
    } else {
      putserv "PRIVMSG #les_incompris :.xkill <nick> \[raison\]"
    }
  }
  return 0
}

proc les_incompris:kill:who { } {
  bind raw - "302" les_incompris:OperKillTest
}

proc les_incompris:OperKill { XOperKillNick XOperKillRaison } {
  global les_incompris_OperKill

  set les_incompris_OperKill(Nick) $XOperKillNick
  set les_incompris_OperKill(Raison) $XOperKillRaison
  set les_incompris_OperKill(Ok) 1

  les_incompris:kill:who
  raw "USERHOST $les_incompris_OperKill(Nick)"
  return
}

proc les_incompris:OperKillTest {from key text} {
  global les_incompris_OperKill

  set text [split $text]

  if { $les_incompris_OperKill(Ok) == 1 } {
    set text [lindex $text 1]
    set nick [lindex [split "$text" :=*] 1]
    if { $nick != "" } {
      if { ([string match *\\* [lindex [split "$text" =] 0]]) } {
        putserv "PRIVMSG #les_incompris :\[\002Info\002\] $les_incompris_OperKill(Nick) est un IRCop - Impossibilité de Killer!"
      } else {
        raw "KILL $les_incompris_OperKill(Nick) :$les_incompris_OperKill(Raison)"
      }
    } else {
      putserv "PRIVMSG #les_incompris :\[\002Info\002\] $les_incompris_OperKill(Nick) n'existe pas!"
    }

    set les_incompris_OperKill(Hand) ""
    set les_incompris_OperKill(Nick) ""
    set les_incompris_OperKill(Raison) ""
    set les_incompris_OperKill(Ok) 0
  }
  unbind raw - "302" les_incompris:OperKillTest
  return
}





#######
# .op #
#######
bind pub I .op les_incompris:pub:op

proc les_incompris:pub:op { nick uhost hand channel arg } {
  global botnick

  if { [string tolower $channel] == "#les_incompris"
    && [isop $nick $channel] } {

    set arg [split $arg]
    set chan [lindex $arg 0]
    set listnick [join [lrange $arg 1 7]]

    if { $listnick == "" || ![ischannel $chan] } {
      putserv "PRIVMSG #les_incompris :.op <channel> <liste nicks>"
    } else {
      raw "SAMODE $chan +oooooo $listnick"
    }
  }
  return 0
}


#########
# .kick #
#########
bind pub I .kick les_incompris:pub:kick

proc les_incompris:pub:kick { nick uhost hand channel arg } {
  global botnick

  if { [string tolower $channel] == "#les_incompris"
    && [isop $nick $channel] } {

    set arg [split $arg]
    set chan [lindex $arg 0]
    set nickkick [lindex $arg 1]
    set raison "[join [lrange $arg 2 7]]"

    if { $nickkick == "" || ![ischannel $chan] } {
      putserv "PRIVMSG #les_incompris :.xkick <channel> <nick> \[raison\]"
    } else {
      if { $raison == "" } { set raison "Gros vilain!" }
      raw "KICK $chan $nickkick :$raison"
    }
  }
  return 0
}

########
# .ban #
########
bind pub I .ban les_incompris:pub:ban

proc les_incompris:pub:ban { nick uhost hand channel arg } {
  global botnick

  if { [string tolower $channel] == "#les_incompris"
    && [isop $nick $channel] } {

    set arg [split $arg]
    set chan [lindex $arg 0]
    set listnick [lindex $arg 1]

    if { $listnick == "" || ![ischannel $chan] } {
      putserv "PRIVMSG #les_incompris :.ban <channel> <host>"
    } else {
      raw "SAMODE $chan +b $listnick"
    }
  }
  return 0
}