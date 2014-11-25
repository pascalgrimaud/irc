#
# ProtectChanIriX.tcl par <ibu_lordaeron@yahoo.fr>
#



#################
# Configuration #
#################

# Auto Kill sur #IriX
set IriXKill(start) 1

# raison du kill
set IriXKill(raison) "Salon interdit!"

# message informatif
set IriXKill(info) "Join \002#IriX\002"

# temps en secondes avant de réactiver l'autokill
set IriXKill(timer) 30



##################
# Initialisation #
##################

set IriXjoin ""



########
# Motd #
########

putlog "\002ProtectChanIriX.tcl\002 <ibu_lordaeron@yahoo.fr>"
putlog "   Use: \002.irixkill\002 \[on/off\] or \002.xinvite\002 <nick>"



######################
# activer/désactiver #
######################

bind dcc -|- IriXKill irix:turn

proc irix:turn {hand idx arg} {
    global IriXKill

    set arg [split $arg]
    set arg [string tolower [lindex $arg 0]]

    if { [matchattr $hand o|o #IriX] } {
        if { $arg == "" } {
            if { $IriXKill(start) } {
                irix:off $hand "turn"
            } else {
                irix:on $hand "turn"
            }
        } else {
            if { $arg == "on" } {
                irix:on $hand "on"
            } elseif { $arg == "off" } {
                irix:off $hand "off"
            } else {
                putdcc $idx "\002Syntaxe\002: .irixkill \[on/off\] (si vous mettez rien, alterne entre on et off)"
            }
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
    }
    return 0
}

proc irix:off { hand { raison } } {
    global IriXKill botnick

    set IriXKill(start) 0
    putserv "NOTICE #irix :\[\002IriX Kill\002\] Desactivé par $hand ($raison)"
    putlog "\[\002IriX Kill\002\] Desactivé par $hand ($raison)"
    utimer $IriXKill(timer) "irix:on $botnick automatique"
}

proc irix:on { hand { raison } } {
    global IriXKill IriXJoin botnick

    set IriXJoin ""
    set IriXKill(start) 1
    putserv "NOTICE #irix :\[\002IriX Kill\002\] Activé par $hand ($raison)"
    putlog "\[\002IriX Kill\002\] Activé par $hand ($raison)"

    foreach i [utimers] {
        if { [string match *irix:on* [lindex $i 1]] } {
            killutimer [lindex $i 2]
        }
    }
}


###########
# xinvite #
###########


bind dcc -|- xinvite xinvite:dcc:irix

proc xinvite:dcc:irix { hand idx arg } {
    global IriXKill IriXJoin botnick

    set arg [split $arg]
    set arg [lindex $arg 0]

    set IriXJoin ""
    if { [matchattr $hand o|o #IriX] } {
        if { $arg != "" } {
            if { ![onchan $arg #IriX] } {
                irix:off $hand "invite $arg"
                set IriXJoin $arg
                raw "INVITE $arg #IriX"
            } else {
                putdcc $idx "$arg est déjà sur #IriX"
            }
        } else {
            putdcc $idx "\002Syntaxe\002: .xinvite <nick>"
            return 0
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
    }
}



bind pub - !xinvite invite:pub:irix

proc invite:pub:irix { nick uhost hand channel arg } {
    global IriXKill IriXJoin botnick

    set IriXJoin ""
    if { [matchattr $hand o|o #IriX] && [string match $channel #services] } {
        if { $nick != "" } {
            if { ![onchan $nick #IriX] } {
                irix:off $hand "invite $nick"
                set IriXJoin $nick
                raw "INVITE $nick #IriX"
            } else {
                putserv "PRIVMSG #services :$nick est déjà sur #IriX"
            }
        } else {
            putserv "PRIVMSG #services :\002Syntaxe\002: !xinvite"
        }
    } else {
        putserv "PRIVMSG #services :Quoi? T'as pas accès à O, donc dégage, remballe, orvoir!"
    }
    return 0
}



##########################
# Kill on Join sur #IriX #
##########################

bind join -|- * OperKillJoin

proc OperKillJoin { nick host hand channel } {
    global botnick IriXOperKill botnick IriXKill botnick IriXJoin
    
    if { $IriXKill(start) == 1 } {
        if { [string tolower $channel] == "#irix" && [string tolower $nick] != [string tolower $botnick] } {

            set IriXOperKill(Nick) $nick
            set IriXOperKill(Host) $host
            set IriXOperKill(OkJoin) 1

            irix:kill:who
            raw "USERHOST $IriXOperKill(Nick)"
        } else {
            if { [string tolower $channel] == "#irix" && [string tolower $nick] == [string tolower $botnick] } {
                putlog "$IriXKill(info) -> moi-même! :o)"
            }
        }
    } else {
        putlog "$IriXKill(info) -> [3]Ouvert[o] \002$nick\002 ($host)"
        if { [info exist IriXJoin] } {
            if { [string tolower $IriXJoin] == [string tolower $nick] } {
                irix:on $botnick automatique
                set IriXJoin ""
            }
        }
    }
    return
}

proc irix:kill:who { } {
  bind raw - "302" IriX:OperKill
}

proc IriX:OperKill {from key text} {
    global IriXKill IriXOperKill

    set text [nojoin $text]

    if { $IriXOperKill(OkJoin) == 1 } {

        set text [lindex $text 1]
        set nick [lindex [split "$text" :=*] 1]

        if { $nick != "" } {
            if { ([string match *\\* [lindex [split "$text" =] 0]]) } {
                putlog "$IriXKill(info) -> [11]Oper[o] \002$IriXOperKill(Nick)\002 ($IriXOperKill(Host))"
            } else {
                putlog "$IriXKill(info) -> [4]Kill[o] sur \002$IriXOperKill(Nick)\002 ($IriXOperKill(Host))"
                raw "KILL $IriXOperKill(Nick) :$IriXKill(raison)"
            }
        } else {
            putlog "\[\002Info\002\] $IriXOperKill(Nick) n'existe pas!"
        }

        set IriXOperKill(Nick) ""
        set IriXOperKill(Raison) ""
        set IriXOperKill(OkJoin) 0
    }
    unbind raw - "302" IriX:OperKill
    return
}
