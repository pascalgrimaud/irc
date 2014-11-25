#
# CServ.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Aidé par :
#   Auto Auth on CServ Bot  (see www.ircore.com)
#   _]NiX[_ <nix@valium.org>  http://www.valium.org
#
# Console +7 pour voir les messages envoyés
#



#################
# Configuration #
#################

# répertoire
set rep_system "system"

# Nombre de secs à attendre pour chaque controle
set cservauth(chktime) 3

# Nick du Channel Service
set cservauth(cserv) "IriX@Salons.Entrechat.Net"

# ID-Nick de votre EggDrop
set cservauth(idnick) [file:get "system/CServID.conf"]

if { $cservauth(idnick) == "" } {
  file:add "system/CServID.conf" $botnick
  set cservauth(idnick) $botnick
}

# Variable de opage par Défaut
set cservauth(opingdefault) 0

# Auto Auth au démarrage
set cservauth(start) 1 



########
# Motd #
########

putlog "\002CServ.tcl\002 - par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"
putlog "   Aide -> \002.auth\002"



###############
# Binds+Procs #
###############

#
# auth : Aide
#
bind dcc m auth cservauth
proc cservauth {hand idx text} {
    global cservchan cservauth

    putdcc $idx " "
    putdcc $idx "      CServ.tcl      "
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .+auth <#channel> <password> \[0/1/2\]"
    putdcc $idx "    Note: 0: présence / 1: présence+@ / 2: inactif"
    putdcc $idx "  .-auth <#channel>"
    putdcc $idx "  .authme (pour lancer le auth)"
    putdcc $idx "  .deauth <#channel> (pour se deauth)"
    putdcc $idx "  .authturn (pour activer/desactiver l'auto auth)"
    putdcc $idx "    Actuellement à --> $cservauth(start)"
    putdcc $idx " "
    putdcc $idx "Configuration :"
    putdcc $idx "  CServ  : $cservauth(cserv)"
    putdcc $idx "  IdNick : $cservauth(idnick)"
    putdcc $idx " "
    putdcc $idx "Listes :"
    if { [matchattr $hand n] } {
        putdcc $idx "channel       password       oping"
    } else {
        putdcc $idx "channel"
    }
    foreach a [array name cservchan] {
        if { [matchattr $hand n] } {
            putdcc $idx "[lrange $cservchan($a) 0 0]   ([lrange $cservchan($a) 1 1])   \[[lrange $cservchan($a) 2 2]\]"
        } else {
            putdcc $idx "[lindex $cservchan($a) 0]"
        }
    }
    putdcc $idx " "
}

#
# +auth : pour ajouter un salon à Auth
#
bind dcc m +auth +cservauth
proc +cservauth {hand idx text} {
    global cservchan cservauth

    set CSchan [lrange $text 0 0]
    set CSpass [lrange $text 1 1]
    set CSoping [lrange $text 2 2]
    if { $CSoping == "" } {
        set CSoping $cservauth(opingdefault)
    }

    if { $CSpass == "" } {
        putdcc $idx "Usage : .+auth <#channel> <password> \[oping? 0/1\]"
        putdcc $idx "        Default for Oping: $cservauth(opingdefault)"

        unset CSchan
        unset CSpass
        unset CSoping

        return 0
    } elseif { ![string match #* $CSchan] } {
        putdcc $idx "[lindex $text 0] is not a valid channel"

        unset CSchan
        unset CSpass
        unset CSoping

        return 0
    } else {
        set cservchan($CSchan) "$CSchan $CSpass $CSoping"
        SaveCServ
        putlog "#$hand# +auth $CSchan \[something\]"

        unset CSchan
        unset CSpass
        unset CSoping

        return 0
    }
}

#
# -auth : pour retirer un salon à Auth
#
bind dcc m -auth -cservauth
proc -cservauth {hand idx text} {
    global cservchan
    set chan [lrange $text 0 0]
    if {![info exists cservchan($chan)]} {
        putdcc $idx "[lindex $text 0] is not a valid channel"
        return 0
    } else {
        unset cservchan($chan)
        SaveCServ
        return 1
    }
}

#
# deauth : demander au bot de se deauther
#
bind dcc m deauth cservdeauth
proc cservdeauth {hand idx text} {
    global cservchan cservauth

    set chan [lrange $text 0 0]
    if { $chan != "" } {
        if {![info exists chan]} {
            putdcc $idx "[lindex $text 0] is not a valid channel"
            return 0
        } else {
            putloglev 2 * "PRIVMSG $cservauth(cserv) :DEAUTH $chan $cservauth(idnick)"
            putserv "PRIVMSG $cservauth(cserv) :DEAUTH $chan $cservauth(idnick)"
            return 1
        }
    } else {
        putdcc $idx "Usage : .deauth <#channel>"
        return 0
    }
}

#
# authme : pour lancer le Auth
#
bind dcc m authme cservauthme
proc cservauthme {hand idx text} {
    CServSendPass
    return 1
}

#
# authturn : pour activer/desactiver l'auto Auth
#
bind dcc m authturn CServ:turn
proc CServ:turn { hand idx text } {
    global cservauth

    if { $cservauth(start) } {
        set cservauth(start) 0
        putdcc $idx "\[CServAuth\] ::: deactivated"
        putlog "#$hand# authturn -> (off)"
    } {
        set cservauth(start) 1
        putdcc $idx "\[CServAuth\] ::: activated"
        putlog "#$hand# authturn -> (on)"
    }
    return 0
}



##############
# Procédures #
##############

proc SaveCServ {} {
    global cservchan rep_system
    set f [open $rep_system/CServAuth.conf w]
    foreach c [array name cservchan] {
        puts $f "$cservchan($c)"
    }
    close $f
}
if {[file exists "$rep_system/CServAuth.conf"]} {
    set f [open $rep_system/CServAuth.conf r]
    while {[gets $f line] >= 0} {
        set cservchan([string tolower [lrange $line 0 0]]) $line
    }
    close $f
}

proc CServAuth {} {
    global cservauth cservchan botnick

    timer $cservauth(chktime) CServSendPass
}

proc CServSendPass { } {
    global cservauth cservchan botnick

    if { $cservauth(start) } {
        foreach a [array name cservchan] {
            set CSChkchan [lrange $cservchan($a) 0 0]
            set CSChkpass [lrange $cservchan($a) 1 1]
            set CSChkoping [lrange $cservchan($a) 2 2]
            if { [validchan $CSChkchan] && $CSChkoping != 2 } {
                if { [botonchan $CSChkchan] } {
                    if { ![botisop $CSChkchan] && $CSChkoping == 1 } {
                        putloglev 7 * "PRIVMSG $cservauth(cserv) :AUTH $CSChkchan $cservauth(idnick) \[something\]"
                        putloglev 7 * "PRIVMSG $cservauth(cserv) :OP $CSChkchan $botnick"
                        putserv "PRIVMSG $cservauth(cserv) :AUTH $CSChkchan $cservauth(idnick) $CSChkpass"
                        putserv "PRIVMSG $cservauth(cserv) :OP $CSChkchan $botnick"
                    }
                } else {
                    putloglev 7 * "PRIVMSG $cservauth(cserv) :AUTH $CSChkchan $cservauth(idnick) \[something\]"
                    putloglev 7 * "PRIVMSG $cservauth(cserv) :INVITE $CSChkchan $botnick"
                    putserv "PRIVMSG $cservauth(cserv) :AUTH $CSChkchan $cservauth(idnick) $CSChkpass"
                    putserv "PRIVMSG $cservauth(cserv) :INVITE $CSChkchan $botnick"
                }
            }
            unset CSChkchan
            unset CSChkpass
            unset CSChkoping
        }
    }
    timer $cservauth(chktime) CServSendPass
}


foreach t [timers] {
  if { [string match *CServSendPass* [lindex $t 1]] } {
    killtimer [lindex $t 2]
  }
}

CServSendPass
