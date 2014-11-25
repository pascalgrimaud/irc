#
# EggOper.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Tcl utilisé en tant qu'OperServ
# à utiliser avec le OperEva.tcl
#



#################
# Configuration #
#################

# Raison de base du Kick/Kill/Kline
set EggOper(raison) "Gros vilain!"

# nb de clones à partir duquel c visible
set EggOper(nbclones) 2

# fichier ou se trouve la liste des hosts à exclure des clones
set EggOper(xexc) "system/xexc.txt"



##################
# Initialisation #
##################

set OperKill(Idx) ""
set OperKill(Hand) ""
set OperKill(Nick) ""
set OperKill(Raison) ""
set OperKill(Ok) 0

if { [info exist widx] } { unset widx }
if { [info exist xkillchan(idx)] } { unset xkillchan(idx) }

proc EggOper:massinit { } {
  global EggOper
  set EggOper(xexclist) "[file:tostring $EggOper(xexc)]"
}

EggOper:massinit



########
# Motd #
########

putlog "\002EggOper.tcl\002 - par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"
putlog "   Aide -> \002.xhelp\002"



########
# Aide #
########
bind dcc -|- xhelp EggOper:dcc:help

proc EggOper:dcc:help { hand idx arg } {
  global botnick

  putdcc $idx " "
  putdcc $idx "     EggOper.tcl - Aide     "
  putdcc $idx " "
  if { [matchattr $hand A] } {
    putdcc $idx "  Level A "
    putdcc $idx " xop/xdeop/xvoice/xdevoice <channel> <liste nicks>"
    putdcc $idx " xmode <#channel> <mode(s)> 14(mettre les modes désirés)"
    putdcc $idx " xseemode <#channel> 14(voir les modes)"
    putdcc $idx " xclearchan <#channel> 14(effacer les modes d'un salon, sauf +nt)"
    putdcc $idx " xclearban <#channel> 14(effacer les bans d'un salon)"
    putdcc $idx " xkick <channel> <nick> \[raison\]"
    putdcc $idx " xkill <nick> \[raison\] 14(Killer un pseudo)"
    putdcc $idx " xlist <string> 14(donne la liste des salons sous le string -> ceux avec Eva n'y sont pas)"
    putdcc $idx " xclose <channel> \[raison\] 14(ferme un channel)"
    putdcc $idx " xpart <channel>"
    putdcc $idx " xkillchan <channel> \[raison\] 14(Killer un salon \[actuellement désactivé\])"
    putdcc $idx " xwho \[+/-\]\[acghmnsu\] <argument> 14(affiche les usagers correspondant aux flags donnés)"
    putdcc $idx " \[+/-\]xexc <host> 14(lister/ajouter/retirer un Host protégé contre les Klines)"
    putdcc $idx " xclone 14(voir le nombre de clones)"
#    putdcc $idx " xkline \[argument\] <nick/hostmask> \[durée\] \[raison\] 14(taper .xkline pour l'aide)"
#    putdcc $idx " xunkline <hostmask> 14(pb...)"
    putdcc $idx " xrestart 14(permet de restarter $botnick -> ne l'utiliser qu'en cas de SendQ Excess)"
    putdcc $idx " xevaco 14(permet de restarter E)"
  }
  if { [matchattr $hand B] } {
    putdcc $idx "  Level B "
    putdcc $idx " xwallops <message> 14(Envoyer un Wallops)"
    putdcc $idx " xnotserv <message> 14(Envoyer une Notice au serveur tt entier ($*.*))"
  }
  if { [matchattr $hand n] } {
    putdcc $idx "  Level n (owners) "
    putdcc $idx " xnick <ancien nick> <nouveau nick> 14(changer le pseudo de qqu'un)"
  }
  putdcc $idx " "
  putdcc $idx " xhelp <-- Vous êtes !"
  putdcc $idx " "
  putdcc $idx " xconsole +1 = user/quit/kill/nick/join/part"
  putdcc $idx " xconsole +2 = user/quit/kill/nick/join/part *in color*"
  putdcc $idx " xconsole +3 = java clones"
  putdcc $idx " xconsole +4 = non-java clones"
  putdcc $idx " xconsole +5 = Flood Connexions & Failed Oper (par K)"
  putdcc $idx " xconsole +6 = Spy Host (par K)"
  putdcc $idx " "
  putlog "#$hand# xhelp"

  return 0
}



############
# xrestart #
############
bind dcc A xrestart EggOper:dcc:xrestart

proc EggOper:dcc:xrestart { hand idx arg } {
  global botnick

  putlog "#$hand# xrestart"
  restart
}



#######
# xop #
#######
bind dcc A xop EggOper:dcc:xop

proc EggOper:dcc:xop { hand idx arg } {
  global botnick

  set arg [split $arg]
  set channel [lindex $arg 0]
  set listnick [join [lrange $arg 1 7]]

  if { $listnick == "" || ![ischannel $channel] } {
    syntaxe $idx ".xop <channel> <liste nicks>"
    return 0
  } else {
    raw "SAMODE $channel +oooooo $listnick"
    return 1
  }
}



#########
# xdeop #
#########
bind dcc A xdeop EggOper:dcc:xdeop

proc EggOper:dcc:xdeop { hand idx arg } {
  global botnick

  set arg [split $arg]
  set channel [lindex $arg 0]
  set listnick [join [lrange $arg 1 7]]

  if { $listnick == "" || ![ischannel $channel] } {
    syntaxe $idx ".xdeop <channel> <liste nicks>"
    return 0
  } else {
    raw "SAMODE $channel -oooooo $listnick"
    return 1
  }
}



##########
# xvoice #
##########
bind dcc A xvoice EggOper:dcc:xvoice

proc EggOper:dcc:xvoice { hand idx arg } {
  global botnick

  set arg [split $arg]
  set channel [lindex $arg 0]
  set listnick [join [lrange $arg 1 7]]

  if { $listnick == "" || ![ischannel $channel] } {
    syntaxe $idx ".xvoice <channel> <liste nicks>"
    return 0
  } else {
    raw "SAMODE $channel +vvvvvv $listnick"
    return 1
  }
}



############
# xdevoice #
############
bind dcc A xdevoice EggOper:dcc:xdevoice

proc EggOper:dcc:xdevoice { hand idx arg } {
  global botnick

  set arg [split $arg]
  set channel [lindex $arg 0]
  set listnick [join [lrange $arg 1 7]]

  if { $listnick == "" || ![ischannel $channel] } {
    syntaxe $idx ".xdevoice <channel> <liste nicks>"
    return 0
  } else {
    raw "SAMODE $channel -vvvvvv $listnick"
    return 1
  }
}



#########
# xmode #
#########
bind dcc A xmode EggOper:dcc:xmode

proc EggOper:dcc:xmode { hand idx arg } {
  global botnick

  set arg [split $arg]

  if { $arg == "" || ![ischannel [lindex $arg 0]] } {
    syntaxe $idx ".xmode <#channel> <mode(s)>"
    return 0
  } else {
    raw "SAMODE [join $arg]"
    return 1
  }
}



##############
# xclearchan #
##############
bind dcc A xclearmode EggOper:dcc:xclearchan
bind dcc A xclearchan EggOper:dcc:xclearchan

proc EggOper:dcc:xclearchan { hand idx arg } {
  global botnick

  set arg [split $arg]

  if { $arg == "" || ![ischannel [lindex $arg 0]] } {
    syntaxe $idx ".xclearchan/.xclearmode <#channel>"
    return 0
  } else {
    raw "SAMODE [lindex $arg 0] +nt"
    raw "SAMODE [lindex $arg 0] -psmilk *"
    return 1
  }
}



#############
# xclearban #
#############
bind dcc A xclearban EggOper:dcc:xclearban

proc EggOper:dcc:xclearban {hand idx arg} {
  global xclearban

  set arg [split $arg]
  set xclearban(hand) $hand
  set xclearban(idx) $idx
  set xclearban(chan) [lindex $arg 0]
  set xclearban(list) ""

  if { $xclearban(chan) == "" || ![ischannel $xclearban(chan)] } {
    syntaxe $idx ".xclearban <#channel>"
    unset xclearban
  } else {
    bind:xclearban
    raw "MODE $xclearban(chan) +b"
  }
  return 0
}

proc bind:xclearban { } { 
  bind raw - "403" xclearban:stop
  bind raw - "367" xclearban:result
  bind raw - "368" xclearban:end
}

proc xclearban:stop {from key arg} {
  global xclearban

  putdcc $xclearban(idx) "Channel inexistant"

  unbind raw - "403" xclearban:stop
  unbind raw - "367" xclearban:result
  unbind raw - "368" xclearban:end
  unset xclearban
}

proc xclearban:result {from key arg} {
  global xclearban

  set arg [split $arg]

  lappend xclearban(list) [lindex $arg 2]
  if { [llength $xclearban(list)] >= 4 } {
    putdcc $xclearban(idx) "UnBan: [join $xclearban(list)]"
    raw "SAMODE $xclearban(chan) -bbbb [join $xclearban(list)]"
    set xclearban(list) ""
  }
}

proc xclearban:end {from key arg} {
  global xclearban

  set arg [split $arg]

  if { $xclearban(list) != "" } {
    putdcc $xclearban(idx) "UnBan: [join $xclearban(list)]"
    raw "SAMODE $xclearban(chan) -bbbb [join $xclearban(list)]"
  }
  putlog "#$xclearban(hand)# xclearban $xclearban(chan)"

  unbind raw - "403" xclearban:stop
  unbind raw - "367" xclearban:result
  unbind raw - "368" xclearban:end
  unset xclearban
}



############
# xseemode #
############
bind dcc A xnoseemode EggOper:dcc:xnoseemode

proc EggOper:dcc:xnoseemode {hand idx arg} {
  global xseemode

  set xseemode(0) 0
  unset xseemode
  return 1
}

bind dcc A xseemode EggOper:dcc:xseemode

proc EggOper:dcc:xseemode {hand idx arg} {
  global xseemode

  if { ![info exists xseemode(idx)] } {
    set arg [split $arg]
    set xseemode(hand) $hand
    set xseemode(idx) $idx
    set xseemode(chan) [lindex $arg 0]

    if { $xseemode(chan) == "" || ![ischannel $xseemode(chan)] } {
      syntaxe $idx ".xseemode <#channel>"
      unset xseemode
    } else {
      bind:xseemode
      raw "MODE $xseemode(chan)"
      raw "MODE $xseemode(chan) +b"
    }
  } else {
    putdcc $idx "Requête refusée: une autre requête est déjà en cours... (s'il est bloqué, essayez le .xnoseemode)"
  }

  return 0
}



proc bind:xseemode { } { 
  bind raw - "403" xseemode:stop
  bind raw - "324" xseemode:result
  bind raw - "329" xseemode:end
  bind raw - "367" xseemode:result2
  bind raw - "368" xseemode:end2
}

proc xseemode:stop {from key arg} {
  global xseemode

  putdcc $xseemode(idx) "Channel inexistant"

  unbind raw - "403" xseemode:stop
  unbind raw - "324" xseemode:result
  unbind raw - "329" xseemode:end
  unbind raw - "367" xseemode:result2
  unbind raw - "368" xseemode:end2
  unset xseemode 
}

proc xseemode:result {from key arg} {
  global xseemode

  set arg [split $arg]

  if { [valididx $xseemode(idx)] } {
    putdcc $xseemode(idx) "\[\002Salon\002\] [lindex $arg 1] \[\002Modes\002\] [join [lrange $arg 2 end]]"
  }
}

proc xseemode:result2 {from key arg} {
  global xseemode

  set arg [split $arg]

  if { [valididx $xseemode(idx)] } {
    putdcc $xseemode(idx) "\[\002Bans\002\] [lindex $arg 2] \[\002Auteur\002\] [lindex $arg 3] \[\002Date\002\] [ctime  [lindex $arg 4]]"
  }
}

proc xseemode:end {from key arg} {
  global xseemode

  set arg [split $arg]
}

proc xseemode:end2 {from key arg} {
  global xseemode

  set arg [split $arg]

  putlog "#$xseemode(hand)# xseemode $xseemode(chan)"

  unbind raw - "403" xseemode:stop
  unbind raw - "324" xseemode:result
  unbind raw - "329" xseemode:end
  unbind raw - "367" xseemode:result2
  unbind raw - "368" xseemode:end2
  unset xseemode
}



#########
# xkick #
#########
bind dcc A xkick EggOper:dcc:xkick

proc EggOper:dcc:xkick { hand idx arg } {
  global botnick EggOper

  set arg [split $arg]
  set channel [lindex $arg 0]
  set nickkick [lindex $arg 1]
  set raison "[join [lrange $arg 2 7]] ($hand)"

  if { $nickkick == "" || ![ischannel $channel] } {
    syntaxe $idx ".xkick <channel> <nick> \[raison\]"
    return 0
  } else {
    if { $raison == "" } { set raison "$EggOper(raison) ($hand)" }
    raw "KICK $channel $nickkick :$raison"
    return 1
  }
}



#########
# xkill #
#########
bind dcc A xkill EggOper:dcc:xkill

proc EggOper:dcc:xkill { hand idx arg } {
  global botnick EggOper OperKill

  set arg [split $arg]
  set XkillNick [lindex $arg 0]
  set XkillRaison [join [lrange $arg 1 end]]

  if { $XkillRaison != "" } {
    set XkillRaison "$XkillRaison ($hand)"
  } else {
    set XkillRaison "$EggOper(raison) ($hand)"
  }

  if { $XkillNick != "" } {
    OperKill $idx $hand $XkillNick $XkillRaison
    return 0
  } else {
    syntaxe $idx ".xkill <nick> \[raison\]"
    return 0
  }
}

proc kill:who { } {
  bind raw - "302" OperKillTest
}

proc OperKill { XOperKillIdx XOperKillHand XOperKillNick XOperKillRaison } {
  global OperKill

  set OperKill(Idx) $XOperKillIdx
  set OperKill(Hand) $XOperKillHand
  set OperKill(Nick) $XOperKillNick
  set OperKill(Raison) $XOperKillRaison
  set OperKill(Ok) 1

  kill:who
  raw "USERHOST $OperKill(Nick)"
  return
}

proc OperKillTest {from key text} {
  global OperKill

  set text [split $text]

  if { $OperKill(Ok) == 1 } {
    set text [lindex $text 1]
    set nick [lindex [split "$text" :=*] 1]
    if { $nick != "" } {
      if { ([string match *\\* [lindex [split "$text" =] 0]]) } {
        raw "GLOBOPS :$OperKill(Hand) tente de killer un IRCop: $OperKill(Nick) ($OperKill(Raison))"
        putdcc $OperKill(Idx) "\[\002Info\002\] $OperKill(Nick) est un IRCop - Impossibilité de Killer!"
      } else {
        putlog "#$OperKill(Hand)# xkill $OperKill(Nick) $OperKill(Raison)"
        raw "KILL $OperKill(Nick) :$OperKill(Raison)"
      }
    } else {
      putdcc $OperKill(Idx) "\[\002Info\002\] $OperKill(Nick) n'existe pas!"
    }

    set OperKill(Idx) ""
    set OperKill(Hand) ""
    set OperKill(Nick) ""
    set OperKill(Raison) ""
    set OperKill(Ok) 0
  }
  unbind raw - "302" OperKillTest
  return
}



##########
# xclear #
##########

bind dcc A xclear EggOper:dcc:xclear

proc EggOper:dcc:xclear {hand idx arg} {
  global widx xkillchan(idx)

  if { [info exist widx] } { unset widx }
  if { [info exist xkillchan(idx)] } { unset xkillchan(idx) }

  return 1
}



#########
# xlist #
#########

bind dcc A xnolist EggOper:dcc:xnolist

proc EggOper:dcc:xnolist {hand idx arg} {
  global xlist

  set xlist(0) 0
  unset xlist
  return 1
}

bind dcc A xlist EggOper:dcc:xlist

proc EggOper:dcc:xlist {hand idx arg} {
  global xlist

  if { ![info exists xlist(idx)] } {
    set arg [split $arg]
    set xlist(hand) $hand
    set xlist(idx) $idx
    set xlist(cpte) 0
    set xlist(string) [lindex $arg 0]

    if { $xlist(string) == "" } {
      syntaxe $idx ".xlist <string>"
      unset xlist
    } else {
      bind:xlist
      putdcc $xlist(idx) "\002Channels list:\002"
      raw "LIST :$xlist(string)"
    }
  } else {
    putdcc $idx "Requête refusée: une autre requête est déjà en cours... (s'il est bloqué, essayez le .xnolist)"
  }
  return 0
}

proc bind:xlist { } { 
  bind raw - "322" xlist:result
  bind raw - "323" xlist:end
}

proc xlist:result {from key arg} {
  global xlist

  set arg [split $arg]
  if { [valididx $xlist(idx)] } {
    putdcc $xlist(idx) " [lindex $arg 1] \[\002[lindex $arg 2]\002\] \[\002Topic\002\]: [string trimleft [join [lrange $arg 3 end]] :]"
  }
  incr xlist(cpte)
}

proc xlist:end {from key arg} {
  global xlist

  set arg [split $arg]
  if { [valididx $xlist(idx)] } {
    putdcc $xlist(idx) "Total \002$xlist(cpte)\002 salons -> \002$xlist(string)\002"
    putlog "#$xlist(hand)# xlist $xlist(string) -> \[\002$xlist(cpte)\002\]"
  }
  unbind raw - "322" xlist:result
  unbind raw - "323" xlist:end
  unset xlist
}



########
# xwho #
########

bind dcc A xwho EggOper:dcc:xwho

proc EggOper:dcc:xwho {hand idx arg} {
  global EggOper xeva

  set arg [split $arg]

  if { [join $arg] == "" } {
    syntaxe $idx ".xwho \[+/-\]\[acghmnsu\] <argument>"
  } else {
    if { [info exists xeva(idx)] && $xeva(oper) } {
      if { [valididx $xeva(idx)] } {
        xeva:xwho $idx [join $arg]
      } else {
        putdcc $idx "Commande Xwho actuellement indisponible... Idx invalide -> .xevaco"
      }
    } else {
      putdcc $idx "Commande Xwho actuellement indisponible... Idx inexistant -> .xevaco"
    }
  }    
  return 0
}



#############
# xkillchan #
#############

bind dcc A xkillchan EggOper:dcc:xkillchan

proc EggOper:dcc:xkillchan {hand idx arg} {
  global EggOper xkillchan

  if { ![info exists xkillchan(idx)] } {
    set arg [split $arg]
    set xkillchan(idx) $idx
    set xkillchan(nb) 0
    set xkillchan(listnick) ""
    set xkillchan(channel) [lindex $arg 0]
    set xkillchan(raison) "[join [lrange $arg 1 end]]"
    if { $xkillchan(raison) == "" } { set xkillchan(raison) "$EggOper(raison)" }

    if { [string index $xkillchan(channel) 0] != "#" } {
      syntaxe $idx ".xkillchan <channel> \[raison\]"
      unset xkillchan(idx)
    } else {
      xkillchan:who
      raw "WHO $xkillchan(channel) x"
    }
  } else {
    putdcc $idx "Requête refusée: une autre requête est déjà en cours... (s'il est bloqué, essayer le .xclear)"
  }
}

proc xkillchan:who { } { 
  bind raw - "403" xkillchan:stopchan
  bind raw - "352" xkillchan:verif
  bind raw - "315" xkillchan:end 
  bind raw - "522" xkillchan:stop
}

proc xkillchan:stopchan {from key arg} {
  global EggOper xkillchan

  putdcc $xkillchan(idx) "Channel inexistant."
  unbind raw - "403" xkillchan:stopchan
  unbind raw - "352" xkillchan:verif
  unbind raw - "315" xkillchan:end
  unbind raw - "522" xkillchan:stop
  putlog "#[idx2hand $xkillchan(idx)]# xkillchan $xkillchan(channel) $xkillchan(raison) \[0\]"
  unset xkillchan(idx)
}

proc xkillchan:verif {from key arg} {
  global EggOper xkillchan

  if { $arg != "" } {
    set arg [split $arg]
    set WhoX(nick) [lindex $arg 5]
    set WhoX(user) [lindex $arg 2]
    set WhoX(mode) [lindex $arg 6]
    set WhoX(host) [lindex $arg 3]
    set WhoX(server) [lindex $arg 4]
    set WhoX(name) [join [lrange $arg 8 end]]

    set WhoX(ircop) [lindex [split $WhoX(mode) @+diwg] 0]
    if { [string match *\\* $WhoX(ircop)] } {
      set WhoX(ircop) 1
    } else {
      set WhoX(ircop) 0
    }

    if { $WhoX(ircop) == 0 } {
      incr xkillchan(nb)
      lappend xkillchan(listnick) $WhoX(nick)
    }
    if { [llength [join $xkillchan(listnick)]] == 18 } {
      putlog "KILL [join $xkillchan(listnick) ,] $xkillchan(raison) ([idx2hand $xkillchan(idx)])"
      set xkillchan(listnick) ""
    }
  }
}

proc xkillchan:end {from key arg} {
  global EggOper xkillchan

  if { $xkillchan(listnick) != "" } {
    putlog "KILL [join $xkillchan(listnick) ,] $xkillchan(raison) ([idx2hand $xkillchan(idx)])"
  }
  unbind raw - "403" xkillchan:stopchan
  unbind raw - "352" xkillchan:verif
  unbind raw - "315" xkillchan:end
  unbind raw - "522" xkillchan:stop
  putlog "#[idx2hand $xkillchan(idx)]# xkillchan $xkillchan(channel) $xkillchan(raison) \[$xkillchan(nb)\]"
  unset xkillchan(idx)
}

proc xkillchan:stop {from key arg} {
  global EggOper xkillchan

  putdcc $widx "Requête refusée: [string trimleft [join [lrange [split $arg] 1 end]] :] (ou bot non authé IRCop)"
  unset widx
}



##########
# xclose #
##########

bind dcc A xclose EggOper:dcc:xclose

proc EggOper:dcc:xclose { hand idx arg } {
  global EggOper xkillchan xeva

  set arg [split $arg]

  set xclose(channel) [lindex $arg 0]
  set xclose(raison) "[join [lrange $arg 1 end]]"
  if { $xclose(raison) == "" } {
    set xclose(raison) "$EggOper(raison)"
  }
  if { [string index $xclose(channel) 0] != "#" } {
    syntaxe $idx ".xclose <channel> \[raison\]"
    return 0
  } else {
    if { [info exists xeva(idx)] && $xeva(oper) } {
      if { [valididx $xeva(idx)] } {
        set xeva(nicklist) ""
        xeva:xclose $xclose(channel) $xclose(raison)
        return 1
      } else {
        putdcc $idx "Commande xclose actuellement indisponible..."
      }
    } else {
      putdcc $idx "Commande xclose actuellement indisponible..."
    }
  }
}


#########
# xpart #
#########

bind dcc A xpart EggOper:dcc:xpart

proc EggOper:dcc:xpart { hand idx arg } {
    global EggOper xkillchan xeva

    set arg [split $arg]

    set xclose(channel) [lindex $arg 0]

    if { [string index $xclose(channel) 0] != "#" } {
        syntaxe $idx ".xpart <channel>"
    } else {
        if { [info exists xeva(idx)] } {
            if { [valididx $xeva(idx)] } {
                xeva:xpart $xclose(channel)
                putlog "#$hand# xpart $xclose(channel)"
            } else {
                putdcc $idx "Commande xpart actuellement indisponible... Idx inexistant -> .xevaco"
            }
        } else {
            putdcc $idx "Commande xpart actuellement indisponible... Idx inexistant -> .xevaco"
        }
    }
    return 0
}



##########
# xclone #
##########

bind dcc A xclone EggOper:dcc:xclone

proc EggOper:dcc:xclone { hand idx arg } {
  global EggOper ial_nb

  set arg [split $arg]
  set arg [lindex $arg 0]

  set operation [string index $arg 0]
  set nombre [string range $arg 1 end]
  set compte 0
  if { [catch {expr $nombre - $nombre} ] } {
    set isnombre 0
  } else {
    set isnombre 1
  }

  if { $isnombre == 1 && ( $nombre >= 2 ) && ( $operation == ">"  || $operation == "=" || $operation == "<" ) } {
    putdcc $idx "\002Clone list:\002"
    foreach i [array names ial_nb] {
      if { $ial_nb($i) >= 2 } {
        if { $operation == "<" } {
          if { $ial_nb($i) < $nombre } {
            putdcc $idx "\[\002$ial_nb($i)\002\] -> $i"
            incr compte
          }
        } elseif { $operation == "=" } {
          if { $ial_nb($i) == $nombre } {
            putdcc $idx "\[\002$ial_nb($i)\002\] -> $i"
            incr compte
          }
        } elseif { $operation == ">" } {
          if { $ial_nb($i) > $nombre } {
            putdcc $idx "\[\002$ial_nb($i)\002\] -> $i"
            incr compte
          }
        }
      }
    }
    putdcc $idx "Total \002$compte\002 hosts."
    return 1
  } else {
    syntaxe $idx "xclone 14<12<14/12>14/12=14><12nombre supérieur à 214>"
    putdcc $idx "   Exemples:"
    putdcc $idx "      .xclone <5 (affiche tous les hosts ayant moins de 5 clones)"
    putdcc $idx "      .xclone =7 (affiche tous les hosts ayant exactement de 7 clones)"
    return 0
  }
}



#########
# +xexc #
#########
bind dcc A +xexc EggOper:dcc:addxexc

proc EggOper:dcc:addxexc { hand idx arg } {
  global EggOper

  set arg [split $arg]
  set arg [lindex $arg 0]

  if { $arg != "" && ![string match *@* $arg] } {
    file:addid $EggOper(xexc) $arg
    EggOper:massinit
    return 1
  } else {
    syntaxe $idx ".+xexc <host>"
    return 0
  }
}


#########
# -xexc #
#########
bind dcc A -xexc EggOper:dcc:delxexc

proc EggOper:dcc:delxexc { hand idx arg } {
  global EggOper

  set arg [split $arg]
  set arg [lindex $arg 0]

  if { $arg != "" } {
    if { [file:rem $EggOper(xexc) $arg] == 1 } {
      EggOper:massinit
      return 1
    } else {
      putdcc $idx "$arg n'existe pas"
      return 0
    }
  } else {
    syntaxe $idx ".-xexc <host>"
    return 0
  }
}



########
# xexc #
########
bind dcc A xexc EggOper:dcc:listxexc

proc EggOper:dcc:listxexc { hand idx arg } {
  global EggOper

  putdcc $idx "\002-- Liste des Hosts protegés\002:"
  putdcc $idx "$EggOper(xexclist)"
  putdcc $idx " "
  return 1
}



#############################
# Test de Protection d'Host #
#############################
proc EggOper:test:xexc { host } {
  global EggOper

  set host [split $host]
  set host [string tolower [join $host]]
  foreach i $EggOper(xexclist) {
    set i [string tolower $i]
    if { [string match $i $host] } {
      return 1    
    }
  }
  return 0
}



###########
# Wallops #
###########
bind dcc B xwallops EggOper:dcc:xwallops

proc EggOper:dcc:xwallops { hand idx arg } {
  global botnick EggOper

  if { $arg != "" } {
    putserv "WALLOPS :[join [split $arg]]"
    return 1
  } else {
    syntaxe $idx ".xwallops <message>"
    return 0
  }
}



###############
# Notice Serv #
###############
bind dcc B xnotserv EggOper:dcc:xnotserv

proc EggOper:dcc:xnotserv { hand idx arg } {
  global botnick EggOper

  if { $arg != "" } {
    putserv "NOTICE $*.* :[join [split $arg]]"
    return 1
  } else {
    syntaxe $idx ".xnotserv <message>"
    return 0
  }
}



#########
# xnick #
#########
bind dcc n xnick EggOper:dcc:xnick

proc EggOper:dcc:xnick { hand idx arg } {
  set arg [split $arg]
    
  if { [lindex $arg 1] != "" && [lindex $arg 2] == "" } {
    raw "NICK [lindex $arg 0] [lindex $arg 1]"
    return 1
  } else {
    syntaxe $idx ".xnick <ancien nick> <nouveau nick>"
    return 0
  }
}



#######
# Raw #
#######
bind raw - "491" Oper:raw

proc Oper:raw {from key text} {
  set text [split $text]
  putlog "\[\002Info\002\] [join [lrange $text 1 end]]"
  return 0
}



###########
# Console #
###########

bind bot - CX:user EggOper:user
proc EggOper:user {bot cmd arg} {
  global EggOper ial_nb

  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]
  putloglev 1 * "User $arg1 $arg2 $arg3"
  putloglev 2 * "6User $arg1 $arg2 $arg3"

  set user [Xuser ibu![lindex $arg 1]]
  set host [Xhost ibu![lindex $arg 1]]
  set hosttw [string tolower $host]

  if { $hosttw != "host" } {

    if { ![info exist ial_nb($hosttw)] } { set ial_nb($hosttw) 0 }
    incr ial_nb($hosttw)

    if { ![EggOper:test:xexc $hosttw] && $ial_nb($hosttw) >= $EggOper(nbclones) } {
      if { [UserJava $user] } {
        putloglev 3 * "Java Clones \[[b]$ial_nb($hosttw)[b]\] $host -> $arg1!$user"
      } else {
        putloglev 4 * "Non-Java Clones \[[b]$ial_nb($hosttw)[b]\] $host -> $arg1!$user"
      }
    }
  }
}


bind bot - CX:quit EggOper:quit
proc EggOper:quit {bot cmd arg} {
  global EggOper ial_nb

  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]
  putloglev 1 * "Quit $arg1 $arg2 $arg3"
  putloglev 2 * "12Quit $arg1 $arg2 $arg3"

  set user [Xuser ibu![lindex $arg 1]]
  set host [Xhost ibu![lindex $arg 1]]
  set hosttw [string tolower $host]

  if { $hosttw != "host" } {
    if { [info exist ial_nb($hosttw)] } {
      set ial_nb($hosttw) [expr $ial_nb($hosttw) - 1]
      if { $ial_nb($hosttw) <= 0 } { unset ial_nb($hosttw) }
    }
  }
}


bind bot - CX:oper listen:oper
proc listen:oper {bot cmd arg} {
  set arg [split $arg]
  putlog "11Oper [lindex $arg 0] [lindex $arg 1]"
  return
}


bind bot - CX:kill EggOper:kill
proc EggOper:kill {bot cmd arg} {
  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]
  putloglev 1 * "Kill $arg1 $arg2 $arg3"
  putloglev 2 * "8Kill $arg1 $arg2 $arg3"

  set user [Xuser ibu![lindex $arg 1]]
  set host [Xhost ibu![lindex $arg 1]]
  set hosttw [string tolower $host]

  if { $hosttw != "host" } {
    if { [info exist ial_nb($hosttw)] } {
      set ial_nb($hosttw) [expr $ial_nb($hosttw) - 1]
      if { $ial_nb($hosttw) <= 0 } { unset ial_nb($hosttw) }
    }
  }
}


bind bot - CX:nick EggOper:nick
proc EggOper:nick {bot cmd arg} {
  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]
  putloglev 1 * "Nick $arg1 -> $arg2 $arg3"
  putloglev 2 * "2Nick $arg1 -> $arg2 $arg3"
}


bind bot - CX:join EggOper:join
proc EggOper:join {bot cmd arg} {
  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]
  putloglev 1 * "Join $arg1 $arg2 $arg3"
  putloglev 2 * "3Join $arg1 $arg2 $arg3"
}


bind bot - CX:part EggOper:part
proc EggOper:part {bot cmd arg} {
  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]
  putloglev 1 * "Part $arg1 $arg2 $arg3"
  putloglev 2 * "10Part $arg1 $arg2 $arg3"
}


bind bot - EggOper:console EggOper:console
proc EggOper:console {bot cmd arg} {
  set arg [split $arg]

  set num_console [lindex $arg 0]
  set arg [join [lrange $arg 1 end]]  
  if { $num_console == "0" } {
    putlog "$arg"
  } else {
    putloglev $num_console * "$arg"
  }
}


bind raw - NOTICE EggOper:EvaLink
proc EggOper:EvaLink {from keyword arg}  {
  global botnick ial_nb

  set arg [split $arg]

  if { ![string match *@* $from] } {

    #-----
    # init des variables qd Eva restart
    #-----
    if { [string match "[join $arg]" "$botnick :*** Notice -- chat-hub.voila.fr introducing U:lined server Eva.Entrechat.Net"] } {
      putlog "[b]Eva restart...[b] (Link Server Eva.Entrechat.Net)"
      set ial_nb(0) 0 ; unset ial_nb
    }
  }
}