#
# Cx-Geofront.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# TCL de Gestion des connexions Serveurs
# Console +1/+2 pour les Connexions
# Console +6 pour la console Geofront
#
# Aidé par Connex.tcl <X.TrenT@Noos.Fr>
#



#################
# Configuration #
#################

# login pour Geofront
set xgeo(nick) "RelayS"

# pass pour Geofront
set xgeo(pass) "9jKf0ld4!F3r4"

# message away
set xgeo(away) "Connexions Service (-> /whois C)"



########
# Motd #
########

putlog "\002Cx-Geofront.tcl\002 - Connexions Service (console +1/+2/+6)"
putlog "   Helped by Connex.tcl <X.TrenT@Noos.Fr>"



####################################
# procédure de débug nick Geofront #
####################################

proc geo:debug { text } {
    return [replace $text "\\\{" "\{"]
}

proc geo:join { arg } {

  set text_length [expr [llength [split $arg]] -1]
  set text_string ""
  set i 0

  while { $i <= $text_length } {
    set j [lindex [split $arg] $i]
    if { [string index $j 0] == "\{" && [string index $j end] == "\}" } {
        set j "[string range $j 1 [expr [string length $j] -2]]"
    } else {
        set j [join $j]
    }
    lappend text_string $j
    incr i
  }
  return [join $text_string]
}



###########################
# Auto Connect à Geofront #
###########################
# bind raw - "005" AutoSocks

proc AutoSocks { from key text } {
    xgeo
    return 1
}



###############################
# Connexion Telnet à Geofront #
###############################

bind dcc n xsocks xsocks

proc xsocks {hand idx text} {
    xgeo:connect
    return 1
}

proc xgeo:connect { } {
    global xgeo

    if { [xgeo:test] == 0 } {
        if { ![catch {connect chat6.x-echo.com 6667 } xgeo(idx)]} {
            putloglev 7 * "\[\002Connex Geofront\002\] Relié à Geofront (Nerv Terminal) (Idx = $xgeo(idx))" 
            control $xgeo(idx) xgeo:event
        } else {
            putloglev 7 * "\[\002Connex Geofront\002\] Connexion impossible à Geofront" 
        }
    } elseif { [xgeo:test] > 1 } {
        foreach i [dcclist] {
            if { "[lindex $i 4]" == "scri  xgeo:event" } {
                putloglev 7 * "\[\002Connex Geofront\002\] Déconnexion à Geofront (Idx = [lindex $i 0])" 
                killdcc [lindex $i 0]
            }
        }
    }

    timer 1 xgeo:connect
    return 0
}

proc xgeo:event { idx arg } {
    global xgeo CX

  # debug les messages reçus via Geofront

    set arg [split [geo:debug $arg]]

    if { [lindex $arg 0] == "Nickname." } {
        putdcc $xgeo(idx) "$xgeo(nick)"
        putloglev 7 * "\[\002Connex Geofront\002\] Authentification à Geofront -> Pseudo : $xgeo(nick)"
        return 0
    }
    if { [lindex $arg 2] == "password." } {
        putdcc $xgeo(idx) "$xgeo(pass)"
        putdcc $xgeo(idx) ".away $xgeo(away)"
        putloglev 7 * "\[\002Connex Geofront\002\] Authentification à Geofront -> Pass : *****" 
        return 0
    }

    if { [string match *:* [lindex $arg 0]] } {
        set arg [join [lrange $arg 1 end]]
        set arg [split $arg]

        set argnick [lindex $arg 1]
        set argnicklower [string tolower [lindex $arg 1]]

        if { [lindex $arg 0] == "User" } {
            set CX($argnicklower) [lindex $arg 2]
#            putallbots "CX:user $argnick $CX($argnicklower) [lindex $arg 4]"
            putloglev 1 * "User $argnick $CX($argnicklower) [lindex $arg 4]"
            putloglev 4 * "6User $argnick $CX($argnicklower) [lindex $arg 4]"

        } elseif { [lindex $arg 0] == "Quit" && [lindex $arg 2] != "Local" } {
            if { ![info exists CX($argnicklower)] } { set CX($argnicklower) "user@host" }
#            putallbots "CX:quit $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
            putloglev 1 * "Quit $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
            putloglev 4 * "12Quit $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
            unset CX($argnicklower)

        } elseif { [lindex $arg 0] == "Quit" && [lindex $arg 2] == "Local" } {
            if { ![info exists CX($argnicklower)] } { set CX($argnicklower) "user@host" }
#            putallbots "CX:kill $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
            putloglev 1 * "Kill $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
            putloglev 4 * "8Kill Local $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
            putloglev 8 * "8Kill Local $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
            unset CX($argnicklower)

        } elseif { [lindex $arg 0] == "Kill" } {
            if { ![info exists CX($argnicklower)] } { set CX($argnicklower) "user@host" }
#            putallbots "CX:kill $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
            putloglev 1 * "Kill $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
            putloglev 4 * "8Kill $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
#            putloglev 8 * "8Kill $argnick $CX($argnicklower) [geo:debug [geo:join [join [lrange $arg 2 end]]]]"
            putloglev 8 * "8Kill $argnick $CX($argnicklower) Killed ([lindex [split [lindex $arg 2] !] 2] [geo:debug [geo:join [join [lrange $arg 3 end]]]])"
            unset CX($argnicklower)

        } elseif { [lindex $arg 0] == "Nick" && [lindex $arg 1] != "change:" } {
            if { ![info exists CX($argnicklower)] } { set CX($argnicklower) "user@host" }
            set CX([string tolower [lindex $arg 3]]) $CX($argnicklower)
#            putallbots "CX:nick $argnick [lindex $arg 3] $CX($argnicklower)"
            putloglev 1 * "Nick $argnick -> [lindex $arg 3] $CX($argnicklower)"
            putloglev 4 * "2Nick $argnick -> [lindex $arg 3] $CX($argnicklower)"
            unset CX($argnicklower)

        } elseif { [lindex $arg 0] == "Join" } {
            if { ![info exists CX($argnicklower)] } { set CX($argnicklower) "user@host" }
#            putallbots "CX:join [lindex $arg 1] $CX($argnicklower) [join [lrange $arg 2 end]]"
            putloglev 2 * "Join [lindex $arg 1] $CX($argnicklower) [join [lrange $arg 2 end]]"
            putloglev 5 * "3Join [lindex $arg 1] $CX($argnicklower) [join [lrange $arg 2 end]]"

        } elseif { [lindex $arg 0] == "Part" } {
            if { ![info exists CX($argnicklower)] } { set CX($argnicklower) "user@host" }
#            putallbots "CX:part [lindex $arg 1] $CX($argnicklower) [join [lrange $arg 2 end]]"
            putloglev 2 * "Part [lindex $arg 1] $CX($argnicklower) [join [lrange $arg 2 end]]"
            putloglev 5 * "10Part [lindex $arg 1] $CX($argnicklower) [join [lrange $arg 2 end]]"

        } elseif { [lindex $arg 0] == "Oper" } {
            if { ![info exists CX($argnicklower)] } { set CX($argnicklower) "user@host" }
#            putallbots "CX:oper [lindex $arg 1] $CX($argnicklower) [join [lrange $arg 2 end]]"
            putloglev 1 * "Oper [lindex $arg 1] $CX($argnicklower) [join [lrange $arg 2 end]]"
            putloglev 4 * "11Oper [lindex $arg 1] $CX($argnicklower) [join [lrange $arg 2 end]]"

        }
    } else {
#        putloglev 6 * "<Geofront> [join $arg]"
    }

    return 0
}



################################################
# Procédure de test si ya connexion à Geofront #
################################################

proc xgeo:test { } {
    global xgeo

    set xgeo(existidx) 0
    foreach i [dcclist] {
        if { "[lindex $i 4]" == "scri  xgeo:event" } {
            incr xgeo(existidx)
        }
    }
    return $xgeo(existidx)
}



##########################
# Commande pour Geofront #
##########################

bind dcc n xgeo xgeocommande

proc xgeocommande { hand idx text } {
    global xgeo

    set text [nojoin $text]
    if { [info exists xgeo(idx)] } {
        if { [valididx $xgeo(idx)] } {
            putdcc $xgeo(idx) "[join $text]"
        }
    }
    return
}



##################
# Connexion Oper #
##################

# -irc.voila.fr- *** Notice -- from Ibu: (Ibu!Ibu@1667194866.com) is now operator (O) using the o-line: Ibu

bind raw - NOTICE CX:oper

proc CX:oper {from keyword arg}  {
    set arg [nojoin $arg]

    if { ![string match *@* $from] } {
        if { [join [lrange $arg 7 10]] == "is now operator (O)" } {
            set i [string range [lindex $arg 6] 1 [expr [string length [lindex $arg 6]] -2]]
            set argnicklower [string tolower [Xnick $i]]

            if { ![info exists CX($argnicklower)] } { set CX($argnicklower) "user@host" }

#            putallbots "CX:oper [lindex $arg 1] $CX($argnicklower) using the o-line: [lindex $arg 14]"
#            putloglev 1 * "Oper [lindex $arg 1] $CX($argnicklower) using the o-line: [lindex $arg 14]"
#            putlog "11Oper [Xnick $i] $CX($argnicklower) using the o-line: [lindex $arg 14]"
        }
    }
    return
}



####################
# Lancement du TCL #
####################

foreach t [timers] {
  if { [string match *xgeo:connect* [lindex $t 1]] } {
    killtimer [lindex $t 2]
  }
}

xgeo:connect
