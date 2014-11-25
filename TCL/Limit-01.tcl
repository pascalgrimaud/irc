#
# Limit v1.0 by MC_8 (Carl M. Gregory) <gregory@worldinter.net>
#  for eggdrop 1.5.0 and greater
#
# Modifié par Ibu <ibu_lordaeron@yahoo.fr>
#



#################
# Configuration #
#################

# flags des personnes autorisées à changer la limite
set mc_limit(reeval) "bm|m"

# bot servant de repère
set limit(bot) "KheldAr"

if { $limit(bot) == "" } { set limit(bot) $botnick }



##################
# Initialisation #
##################

set mc_limit(version) v1.0
set mc_limit(svs:script) "limit 001000000000"
set mc_limit(svs:server) "mc.purehype.net 8085"

if {$numversion < "1050000"} {
 putlog "\002Limit\002 $mc_limit(version) by MC_8 is for eggdrop 1.5+ series only."
 putlog "\002Limit\002 $mc_limit(version) will not work with eggdrop $version."
 putlog "\002Limit\002 $mc_limit(version) not loaded."
 return 1
}

# initialise les valeurs du chaninfo
setudef int limit_users
setudef int limit_grace
setudef int limit_time



########
# Motd #
########

putlog "\002Limit-01.tcl\002 $mc_limit(version) by MC_8 loaded."
putlog "   Aide -> \002.limit\002 - Modifié par 14<ibu_lordaeron@yahoo.fr>"



##################################################
# Retrait du +l lorsque le bot de repère s'en va #
##################################################

# bind sign - * limit:sign
bind part - * limit:part
bind kick - * limit:kick

proc limit:part { nick uhost handle chan {msg ""} } {
    global limit
    if { [string tolower $nick] == [string tolower $limit(bot)] } {
        if { [string match *l* [getchanmode $chan]] } {
            putlog "\002\[Limit-01\]\002 $limit(bot) est sorti de $chan (retrait du +l)" 
            putserv "MODE $chan -l"
        }
    }
    return
}

proc limit:sign { nick uhost handle channel {msg ""} } {
    global limit
    if { [string tolower $nick] == [string tolower $limit(bot)] } {
        foreach chan [channels] {
            if { [string match *l* [getchanmode $chan]] } {
                putlog "\002\[Limit-01\]\002 $limit(bot) a quitté l'IRC - $chan (retrait du +l)" 
                putserv "MODE $chan -l"
            }
        }
    }   
    return
}

proc limit:kick { nick uhost handle chan target reason } {
    global limit
    if { [string tolower $target] == [string tolower $limit(bot)] } {
        if { [string match *l* [getchanmode $chan]] } {
            putlog "\002\[Limit-01\]\002 $limit(bot) a été kické de $chan (retrait du +l)" 
            putserv "MODE $chan -l"
        }
    }
    return
}



#################
# Gestion du +l #
#################

proc mc:limit:eval { chan } {
    global botnick limit


    mc:limit:resettimer $chan
    set limit_users [mc:limit:chanintinfo $chan limit_users]

    if {($limit_users == "0") || (![onchan $botnick $chan]) || (![isop $botnick $chan])} {
        return 0
    }

    set current_limit [mc:limit:sindex [getchanmode $chan] e]
    if { [catch {expr $current_limit+1}] } {
        set current_limit 0
    }
    set users [mc:limit:slength [chanlist $chan]]
    set grace [mc:limit:chanintinfo $chan limit_grace]
    if { ([expr $users+$limit_users] == $current_limit) ||
     ([string trimleft [expr ($users+$limit_users) - $current_limit] "-"] <= $grace)} {
        return 0
    }
    if { [onchan $limit(bot) $chan] } {
        putserv "MODE $chan +l [expr $users+$limit_users]"
    } elseif { [string match *l* [getchanmode $chan]] } {
        putserv "MODE $chan -l"
    }
}

proc mc:limit:chanintinfo { chan flag } {
    foreach info [string tolower [channel info $chan]] {
        if {[lindex $info 0] == [string tolower $flag]} {
            return [mc:limit:srange $info 1 e]
        }
    }
}

bind mode - "*+l*" mc:limit:eval:pipe
bind mode - "*-l*" mc:limit:eval:pipe

proc mc:limit:eval:pipe {nick uhost hand chan mc victim} {
    global mc_limit botnick

    if { [string tolower $nick] != [string tolower $botnick] } {
        if {[matchattr $hand $mc_limit(reeval) $chan] && $mc_limit(reeval) != "-|-"} {
            mc:limit:resettimer $chan
            return 0
        }
    mc:limit:eval $chan
    }
}

## sindex procedures (by MC_8 & guppy)
proc mc:limit:slength {str} {return [llength $str]}
proc mc:limit:sindex {str index} {return [lindex [split $str] $index]}
proc mc:limit:srange {str s e} {return [lrange [split $str] $s $e]}
proc mc:limit:filt {data} {
 return [join [split [join [split [join [split [join [split [join [split [join [split $data \\] \\\\] \[] \\\[] \]] \\\]] \}] \\\}] \{] \\\{] \"] \\\"]
}
proc mc:limit:unfilt {data} {
 regsub -all -- \\\\\\\[ $data \[ data;regsub -all -- \\\\\\\] $data \] data;regsub -all -- \\\\\\\} $data \} data
 regsub -all -- \\\\\\\{ $data \{ data;regsub -all -- \\\\\\\" $data \" data;regsub -all -- \\\\\\\\ $data \\ data;return $data
}

proc mc:limit:resettimer { chan } {
    if {[string match "*mc:limit:eval [string tolower $chan]*" [string tolower [timers]]]} {
        foreach timer [timers] {
            if {![string match "*mc:limit:eval [string tolower $chan]*" [string tolower $timer]]} {
                continue
            }
            killtimer [lindex $timer 2]
        }
    }
    set time [mc:limit:chanintinfo $chan limit_time]
    if {($time == "") || (!$time)} {
        set time 0
    }
    timer $time "mc:limit:eval [mc:limit:filt $chan]"
    return 1
}

# foreach chan [string tolower [channels]] { mc:limit:eval $chan }



###############################################
# auto check par Ibu <ibu_lordaeron@yahoo.fr> #
###############################################

proc mc:limit:exeautochk { } {
    timer 1 mc:limit:autochk
    return
}

proc mc:limit:autochk { } {
    foreach i [string tolower [channels]] {
        mc:limit:eval $i
    }
    mc:limit:exeautochk
    return
}

mc:limit:exeautochk



########
# Aide #
########

bind dcc -|- limit Limit:help

# This script will keep the limit above the number of users, changing the limit
# every (x) min's (you set the x below).  This makes the channel more secure in
# such an instance of stopping a large floodnet from join'n at once.


proc Limit:help {hand idx arg} {
    global limit
    putdcc $idx " "
    putdcc $idx "     Limit-01.tcl - Aide     "
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Ce script permet d'obtenir et de maintenir une limite (mode +l)"
    putdcc $idx "   en fonction des utilisateurs présents sur le salons, en changeant"
    putdcc $idx "   toutes les (x) minutes le mode (+l). On obtient donc un (+l)"
    putdcc $idx "   dynamique, ce qui permet de sécuriser davantage les salons en"
    putdcc $idx "   empêchant les flood en Mass Joins."
    putdcc $idx " "
    putdcc $idx "Configuration :"
    putdcc $idx "  Bot de repère : $limit(bot)"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .chanset <#channel> <limit_users> <nombre>"
    putdcc $idx "  .chanset <#channel> <limit_grace> <nombre>"
    putdcc $idx "  .chanset <#channel> <limit_time> <nombre (en min)>"
    putdcc $idx " "
    putdcc $idx "  .limit <-- Aide, vous êtes ici!"
    putdcc $idx " "
    return 1
}



