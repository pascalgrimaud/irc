#
# OpChkOpless.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Tcl permettant à l'eggdrop de se oper en cas de présence d'un autre op,
# et de se déoper lorsqu'il n'y a plu d'op l'accompagnant.
# Utilise la procédure EggOp se trouvant ds EggTools.tcl
#



#################
# Configuration #
#################

# Bot
set OpChkOpless(bot) "Robot10"

# Pass
set OpChkOpless(pass) "YzXyyZxyzZ"

# Chan
set OpChkOpless(chan) "#!40-50ans!"

# UserHost
set OpChkOpless(host) "*Robot@chat3.voila.fr"



########
# Motd #
########

putlog "\002OpChkOpless.tcl\002 par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"



########
# Raws #
########

bind join - * OpChkOpless:join
bind sign - * OpChkOpless:raw:sign
bind part - * OpChkOpless:raw:part
bind mode - "#* -o" OpChkOpless:raw:deop
bind mode - "#* +o" OpChkOpless:raw:op
bind kick - * OpChkOpless:raw:kick


proc OpChkOpless:join { nick userhost handle channel } {
    global botnick
    if { [string tolower $botnick] == [string tolower $nick] } {
        timer 1 "OpChkOpless:OpMe $channel"
    }
    return
}
proc OpChkOpless:OpMe { channel } {
    global OpChkOpless

    if { [string tolower $channel] == [string tolower $OpChkOpless(chan)] && ![botisop $channel] } {
        if { [NbOp $channel] > 1 } {
            OpChkOpless:op $channel
        }
    }
    return
}

proc OpChkOpless:raw:sign { nick uhost handle channel {msg ""} } {
    global botnick OpChkOpless
    if { [string tolower $channel] == [string tolower $OpChkOpless(chan)] \
     && [botisop $channel] && [string tolower $nick] != [string tolower $botnick] } {
        if { [wasop $nick $channel] } {
            if { [NbOp $channel] < 4 } {
                OpChkOpless:deop $channel "$nick vient de quitter"
            }
        }
    }
}

proc OpChkOpless:raw:part { nick uhost handle channel {msg ""} } {
    global botnick OpChkOpless
    if { [string tolower $channel] == [string tolower $OpChkOpless(chan)] \
     && [botisop $channel] && [string tolower $nick] != [string tolower $botnick] } {
        if { [wasop $nick $channel] } {
            if { [NbOp $channel] < 4 } {
                OpChkOpless:deop $channel "$nick vient de sortir"
            }
        }
    }
}

proc OpChkOpless:raw:deop { nick uhost handle channel mode-change victim } {
    global botnick OpChkOpless
    if { [string tolower $channel] == [string tolower $OpChkOpless(chan)] && [botisop $channel] } {
        if { [NbOp $channel] < 3 } {
            foreach i $victim {
                if { [wasop $i $channel] } {
                    OpChkOpless:deop $channel "$i vient de se déoper"
                }
            }
        }
    }
}

proc OpChkOpless:raw:kick { nick uhost handle channel target reason } {
    global botnick OpChkOpless
    if { [string tolower $channel] == [string tolower $OpChkOpless(chan)] \
     && [botisop $channel] && [string tolower $target] != [string tolower $botnick] } {
        if { [wasop $target $channel] } {
            if { [NbOp $channel] == 3 } {
                OpChkOpless:deop $channel "$target vient de se faire kické"
            }
        }
    }
}

proc OpChkOpless:raw:op { nick uhost handle channel mode-change victim } {
    global botnick OpChkOpless
    if { [string tolower $channel] == [string tolower $OpChkOpless(chan)] && ![botisop $channel] } {
        if { [NbOp $channel] > 1 } {
            OpChkOpless:op $channel
        }
    }
}


################
# Autres procs #
################

proc NbOp { channel } {

    set NbOps($channel) 0
    foreach i [chanlist $channel] {
        if { [isop $i $channel] } {
            incr NbOps($channel)
        }
    }
    return $NbOps($channel)
}

proc OpChkOpless:op { channel } {
    global botnick OpChkOpless

    putlog "*** \[ \002Je m'op!\002 \] Fin d'opless $channel"
    # Utilise la procédure ds EggTools.tcl
    EggOp $OpChkOpless(bot) $OpChkOpless(pass) $OpChkOpless(chan) $OpChkOpless(host)
    return
}

proc OpChkOpless:deop { channel text } {
    global botnick
    putlog "*** \[ \002Je me déop!\002 \] Plus d'op sur $channel ($text)"
    putserv "MODE $channel -o $botnick"
    return
}



#--------------------------------------------------------------------------------
#
# Procédure qui retire tout code couleur
#
# -- SYNTAXE:
#  strip <string> [orubcg]
#
#--------------------------------------------------------------------------------

proc strip {str {type orubcg}} {
    set type [string tolower $type]
    if {[string first b $type] != -1} {regsub -all  $str "" str}
    if {[string first u $type] != -1} {regsub -all  $str "" str}
    if {[string match {*[rv]*} $type]} {regsub -all  $str "" str}
    if {[string first o $type] != -1} {regsub -all  $str "" str}

    if {[string first c $type] != -1} {
        regsub -all {(([0-9])?([0-9])?(,([0-9])?([0-9])?)?)?} $str "" str
    }

    if {[string first g $type] != -1} {
        regsub -all -nocase {([0-9A-F][0-9A-F])?} $str "" str
    }
    return $str
}