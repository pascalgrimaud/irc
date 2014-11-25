#
# Limit-Repere.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Permet à un egg de s'oper, de retirer le +l, et de se déoper
#



#################
# Configuration #
#################

# bot à repérer
set limitrep(bot) "Planete_40-50"

# list des salons à repérer
set limitrep(listchan) "#!40-50ans!"

# Pass
set limitrep(pass) "XyZzXxyZXyZx"

# UserHost
set limitrep(host) "*Robot@*"


########
# Motd #
########

putlog "\002Limit-Repere.tcl\002 par 14<ibu_lordaeron@yahoo.fr>"



##################################################
# Retrait du +l lorsque le bot de repère s'en va #
##################################################

bind sign - * limitrep:sign
bind part - * limitrep:part
bind kick - * limitrep:kick
bind mode - "#* +o" limitrep:op

proc limitrep:part { nick uhost handle chan {msg ""} } {
    global limitrep
    if { [string match *$chan* $limitrep(listchan)] } {
        if { [string tolower $nick] == [string tolower $limitrep(bot)] } {
            if { [string match *l* [getchanmode $chan]] } {
                set RobotLimit [find:robot $chan]
                if { $RobotLimit != 0 } {
                    putlog "\002\[Limit-01\]\002 $limitrep(bot) est sorti de $chan (je m'ope)" 
                    EggOp $RobotLimit $limitrep(pass) $chan $limitrep(host)
                }
            }
        }
    }
    return
}

proc limitrep:sign { nick uhost handle chan {msg ""} } {
    global limitrep
    foreach i [channels] {
        if { [string match *$i* $limitrep(listchan)] && [onchan $nick $i] } {
            if { [string tolower $nick] == [string tolower $limitrep(bot)] } {
                if { [string match *l* [getchanmode $chan]] } {
                    set RobotLimit [find:robot $chan]
                    if { $RobotLimit != 0 } {
                        putlog "\002\[Limit-01\]\002 $limitrep(bot) a quitté l'IRC - $chan (je m'ope)" 
                        EggOp $RobotLimit $limitrep(pass) $chan $limitrep(host)
                    }
                }
            }
        }
    }
    return
}

proc limitrep:kick { nick uhost handle chan target reason } {
    global limitrep
    if { [string match *$chan* $limitrep(listchan)] } {
        if { [string tolower $target] == [string tolower $limitrep(bot)] } {
            if { [string match *l* [getchanmode $chan]] } {
                set RobotLimit [find:robot $chan]
                if { $RobotLimit != 0 } {
                    putlog "\002\[Limit-01\]\002 $limitrep(bot) a été kické de $chan (je m'ope)"
                    EggOp $RobotLimit $limitrep(pass) $chan $limitrep(host)
                }
            }
        }
    }
    return
}

proc limitrep:op { nick uhost handle channel mode-change victim } {
    global botnick limitrep
    if { [string match *$channel* $limitrep(listchan)] } {
        foreach i $victim {
            if { [string tolower $i] == [string tolower $botnick] } {
                putlog "\002\[Limit-01\]\002 je retire le +l sur $channel"
                putserv "MODE $channel -lo $botnick"
            }
        }
    }
    return
}

proc find:robot { channel } {
    set ListRobot "Robot Robot00 Robot01 Robot02 Robot03 Robot04 Robot05 Robot06 Robot07 Robot08 Robot09 Robot10 Robot11 Robot12 Robot13 Robot14 Robot15 Thema Thema01 Thema02 Thema03 Thema04 Thema05"
    foreach i $ListRobot {
        if { [onchan $i $channel] } {
            return $i
        }
    }
    return 0
}