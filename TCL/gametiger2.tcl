#
# gametiger2.tcl par Ibu <ibu_lordaeron@yahoo.fr>
# 

#
# ATTENTION !! CE TCL REQUIERT HTTP.TCL 
#



#################
# Configuration #
#################

# aucune



########
# Motd #
########

putlog "\002gametiger2.tcl\002 par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"
putlog "   Tapez: .ip ou !ip (channel)"



##############
# sous-procs #
##############

proc gettext { data start end } {
    set index0 [string first $start $data]
    set index1 [expr $index0 + [string length $start]]
    set index2 [string first $end $data]
    set index2 [expr $index2 - 1]
    set index  [expr $index2 + [string length $end]]

    return [string range $data $index1 $index2]
}

proc nojoinhtml { text } {
  regsub -all -- {\\} $text {\\\\} text
  regsub -all -- {\{} $text {\{} text
  regsub -all -- {\}} $text {\}} text
  regsub -all -- {\[} $text {\[} text
  regsub -all -- {\]} $text {\]} text
  regsub -all -- {\"} $text {\"} text
  return "$text"
}



################################
# Vérifier une ip sur un salon #
################################

bind pub - !ip gametiger:pub:testip

proc gametiger:pub:testip { nick uhost handle channel arg } {
  global encorebis gametiger

  set encore [unixtime]
  if {[info exists encorebis]} {
    set trop [expr $encore - $encorebis]
    if { $trop < 5 } {
      putserv "PRIVMSG $channel :Désolé $nick, une demande d'IP toutes les 5 secondes"
      return 0
    } else {
      set encorebis $encore
    }
  } else {
    set encorebis $encore
  }

  set AddrIp [lindex $arg 0]
  if { $AddrIp == "" } {
    putserv "PRIVMSG $channel :Commande : \002!ip\002 <ip>"
    return 0
  } else {
    set gametiger(channel) $channel
    set gametiger(i) [connect 209.196.48.26 80]
    putdcc $gametiger(i) "GET http://www.gametiger.net/search?address=$AddrIp"
    control $gametiger(i) gametiger:pub:ctrl
    return 0
  }
}

proc gametiger:pub:ctrl { idx arg } {
  global gametiger gt

  if { $arg != "" } {
    set LectureTexteLu [nojoinhtml $arg]

    if { [string match "*Server&nbsp;Name*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 340 end]"
      set gt(server) "[join [gettext $i "><b>" "&nbsp;</b></td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Status<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 180 end]"
      set gt(status) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>IP:Port<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 90 end]"
      set gt(ip) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*>Engine</td>*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 100 end]"
      set gt(engine) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Game<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 100 end]"
      set gt(game) "[join [gettext $i "\">" "&nbsp;</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Map<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 100 end]"
      set gt(map) "[join [gettext $i "\">" "&nbsp;</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Last&nbsp;Map&nbsp;Change<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 130 end]"
      set gt(lastmapchange) "[join [gettext $i "\">" "&nbsp;ago</td></tr>"]] ago"
      return 0
    } elseif { [string match "*<b>Protocol&nbsp;Version<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 130 end]"
      set gt(protocol) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Type&nbsp;of&nbsp;Server<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 130 end]"
      set gt(type) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>OS<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 110 end]"
      set gt(os) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Password&nbsp;required<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 130 end]"
      set gt(password) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Active*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 240 end]"
      set gt(players) "[join [gettext $i "\">" "</td></tr>"]]"
      set i [string first "/" $gt(players)]
      set i1 [string range $gt(players) 0 [expr $i-1]]
      set i2 [string range $gt(players) [expr $i+1] end]
      if { $i1 == $i2 } {
        set gt(players) "4$i1/$i2 (FULL)"
      } else {
        set gt(players) "3$i1/$i2"
      }
    } elseif { [string match "*<b>Last&nbsp;Check<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 130 end]"
      set gt(lastcheck) "[join [gettext $i "\">" "&nbsp;ago</td></tr>"]] ago"
      return 0
    } elseif { [string match "*<b>Bogo&nbsp;Ping<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 120 end]"
      set gt(ping) "[join [gettext $i "\">" "</td></tr>"]]"
      putserv "PRIVMSG $gametiger(channel) :\[ [b][u]Server Name[u][b]: 7[b]$gt(server) \] \[ [b][u]OS[u][b]: $gt(os) \] \[ [b][u]Type Server[u][b]: $gt(type) \]  \[ [b][u]IP[u][b]: 10$gt(ip) \] \[ [b][u]Password Required[u][b]: $gt(password) \] \[ [b][u]Engine[u][b]: $gt(engine) \] \[ [b][u]Game[u][b]: $gt(game) \] \[ [b][u]Bogo Ping[u][b]: $gt(ping) \] \[ [b][u]Map[u][b]: 5[b]$gt(map) ($gt(lastmapchange)) \] \[ [b][u]Players[u][b]: [b]$gt(players)[b] (last check $gt(lastcheck)) \]"
    }
  }

  return 0
}




################################
# Vérifier une ip en partyline #
################################

bind dcc - ip gametiger:dcc:testip

proc gametiger:dcc:testip { hand idx arg } {
  global encorebis gametiger

  set encore [unixtime]

  if {[info exists encorebis]} {
    set trop [expr $encore - $encorebis]
    if { $trop < 5 } {
      putdcc $idx "Désolé $hand, une demande d'IP toutes les 5 secondes"
      return 0
    } else {
      set encorebis $encore
    }
  } else {
    set encorebis $encore
  }

  set AddrIp [lindex $arg 0]
  if { $AddrIp == "" } {
    putdcc $idx "Commande : \002.ip\002 <ip>"
    return 0
  } else {
    set gametiger(i) [connect 209.196.48.26 80]
    putdcc $gametiger(i) "GET http://www.gametiger.net/search?address=$AddrIp"
    control $gametiger(i) gametiger:dcc:ctrl
    return 0
  }
}

proc gametiger:dcc:ctrl { idx arg } {
  global gametiger gt

  if { $arg != "" } {
    set LectureTexteLu [nojoinhtml $arg]

    if { [string match "*Server&nbsp;Name*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 340 end]"
      set gt(server) "[join [gettext $i "><b>" "&nbsp;</b></td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Status<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 180 end]"
      set gt(status) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>IP:Port<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 90 end]"
      set gt(ip) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*>Engine</td>*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 100 end]"
      set gt(engine) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Game<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 100 end]"
      set gt(game) "[join [gettext $i "\">" "&nbsp;</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Map<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 100 end]"
      set gt(map) "[join [gettext $i "\">" "&nbsp;</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Last&nbsp;Map&nbsp;Change<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 130 end]"
      set gt(lastmapchange) "[join [gettext $i "\">" "&nbsp;ago</td></tr>"]] ago"
      return 0
    } elseif { [string match "*<b>Protocol&nbsp;Version<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 130 end]"
      set gt(protocol) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Type&nbsp;of&nbsp;Server<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 130 end]"
      set gt(type) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>OS<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 110 end]"
      set gt(os) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Password&nbsp;required<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 130 end]"
      set gt(password) "[join [gettext $i "\">" "</td></tr>"]]"
      return 0
    } elseif { [string match "*<b>Active*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 240 end]"
      set gt(players) "[join [gettext $i "\">" "</td></tr>"]]"
      set i [string first "/" $gt(players)]
      set i1 [string range $gt(players) 0 [expr $i-1]]
      set i2 [string range $gt(players) [expr $i+1] end]
      if { $i1 == $i2 } {
        set gt(players) "4$i1/$i2 (FULL)"
      } else {
        set gt(players) "3$i1/$i2"
      }
    } elseif { [string match "*<b>Last&nbsp;Check<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 130 end]"
      set gt(lastcheck) "[join [gettext $i "\">" "&nbsp;ago</td></tr>"]] ago"
      return 0
    } elseif { [string match "*<b>Bogo&nbsp;Ping<*" "$LectureTexteLu"] } {
      set i [string range "$LectureTexteLu" 120 end]"
      set gt(ping) "[join [gettext $i "\">" "</td></tr>"]]"

      putlog " "
      putlog "[b][u]Server Name[u][b]: 7[b]$gt(server)     [b][u]OS[u][b]: $gt(os)     [b][u]Type Server[u][b]: $gt(type)"
      putlog "[b][u]IP[u][b]: 10$gt(ip)     [b][u]Password Required[u][b]: $gt(password)"
      putlog "[b][u]Engine[u][b]: $gt(engine)     [b][u]Game[u][b]: $gt(game)     [b][u]Bogo Ping[u][b]: $gt(ping)"
      putlog "[b][u]Map[u][b]: 5[b]$gt(map) ($gt(lastmapchange))     [b][u]Players[u][b]: [b]$gt(players)[b] (last check $gt(lastcheck))"
      putlog " "
    }
  }

  return 0
}



#######
# !nt #
#######

bind pub - !nt gametiger:pub:nt

proc gametiger:pub:nt { nick uhost handle channel arg } {
  gametiger:pub:testip $nick $uhost $handle $channel 62.212.75.78:27015
}



