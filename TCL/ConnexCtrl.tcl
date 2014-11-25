#
# ConnexCtrl.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#



#################
# Configuration #
#################

# --- général ---

# Egg à qui on donne les infos
set Fl(eggoper) "OperServ"

# répertoire où sera stocké les hosts spy
set spy(file) "system/spy.txt"

# répertoire où sera stocké les hosts non spy
set spy(excfile) "system/excspy.txt"


# --- Flood Connexion --- #

# répertoire où sera stocké les hosts protégés
# contre les floods connex + flood failed oper
set Fl(xexc) "system/xexc.txt"

# bot de connexions
set Fl(botlink) "C"

# nombre de connexions autorisés (vision)
set Fl(nbconnex) 8

# par secondes:
set Fl(tps) 8

# nombre de connexions à partir duquel on Kline
set Fl(nbkline) 12

# nombre de clones à partir duquel il est visible dans la console +5
set Fl(nbclones) 2

# raison du Kline pour Flood Connexion
set Fl(klineraison) "Connexion/Déconnexion trop rapide!"

# tps du Kline en minutes
set Fl(klinetps) 30


# --- Failed Oper ---

# nb autorisé
set Failed_Oper(nb) 5

# par secondes:
set Failed_Oper(tps) 30

# raison du kline
set Failed_Oper(klineraison) "Abus de failed Oper!"

# durée du kline
set Failed_Oper(klinetps) 15



########
# Init #
########

proc Fl:massinit { } {
  global Fl spy

  set Fl(xexclist) "[file:tostring $Fl(xexc)]"
  set spy(list) "[file:tostring $spy(file)]"
  set spy(exclist) "[file:tostring $spy(excfile)]"
}

Fl:massinit

foreach t [utimers] {
  if { [string match *FlDelUser* [lindex $t 1]] } {
    killutimer [lindex $t 2]
  }
  if { [string match *FailedOper:del* [lindex $t 1]] } {
    killutimer [lindex $t 2]
  }
}



########
# Motd #
########

putlog "\002ConnexCtrl.tcl\002 - par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"



#########
# Procs #
#########

proc putoperserv { console string } {
  global Fl

  putbot $Fl(eggoper) "EggOper:console $console $string"
  return
}



#########
# +xexc #
#########
bind dcc A +xexc Fl:dcc:addxexc

proc Fl:dcc:addxexc { hand idx arg } {
    global Fl

    set arg [split $arg]
    set arg [lindex $arg 0]

    if { $arg != "" && ![string match *@* $arg] } {
        file:addid $Fl(xexc) $arg
        Fl:massinit
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+xexc <host>"
        return 0
    }
}


#########
# -xexc #
#########
bind dcc A -xexc Fl:dcc:delxexc

proc Fl:dcc:delxexc { hand idx arg } {
    global Fl

    set arg [split $arg]
    set arg [lindex $arg 0]

    if { $arg != "" } {
        if { [file:rem $Fl(xexc) $arg] == 1 } {
            Fl:massinit
            return 1
        } else {
            putdcc $idx "$arg n'existe pas"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-xexc <host>"
        return 0
    }
}



########
# xexc #
########
bind dcc A xexc Fl:dcc:listxexc

proc Fl:dcc:listxexc { hand idx arg } {
    global Fl

    putdcc $idx "\002-- Liste des Hosts protegés\002:"
    putdcc $idx "$Fl(xexclist)"
    putdcc $idx " "
    return 1
}



#############################
# Test de Protection d'Host #
#############################
proc Fl:test:xexc { host } {
    global Fl

    set host [split $host]
    set host [string tolower [join $host]]
    foreach i $Fl(xexclist) {
        set i [string tolower $i]
        if { [string match $i $host] } {
            return 1    
        }
    }
    return 0
}




########
# +spy #
########
bind dcc A +spy Fl:dcc:addspy

proc Fl:dcc:addspy { hand idx arg } {
    global spy

    set arg [split $arg]
    set arg [lindex $arg 0]

    if { $arg != "" } {
        file:addid $spy(file) $arg
        Fl:massinit
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+spy <host>"
        return 0
    }
}


########
# -spy #
########
bind dcc A -spy Fl:dcc:delspy

proc Fl:dcc:delspy { hand idx arg } {
    global spy

    set arg [split $arg]
    set arg [lindex $arg 0]

    if { $arg != "" } {
        if { [file:rem $spy(file) $arg] == 1 } {
            Fl:massinit
            return 1
        } else {
            putdcc $idx "$arg n'existe pas"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-spy <host>"
        return 0
    }
}



#######
# spy #
#######
bind dcc A spy Fl:dcc:listspy

proc Fl:dcc:listspy { hand idx arg } {
    global spy

    putdcc $idx "\002-- Liste des Hosts en Spy\002:"
    putdcc $idx "$spy(list)"
    putdcc $idx " "
    return 1
}



###############
# Test de Spy #
###############
proc spy:test { host } {
    global spy

    set host [split $host]
    set host [string tolower [join $host]]
    foreach i $spy(list) {
        set i [string tolower $i]
        if { [string match $i $host] } {
            return 1    
        }
    }
    return 0
}



###########
# +excspy #
###########
bind dcc A +excspy Fl:dcc:addexcspy

proc Fl:dcc:addexcspy { hand idx arg } {
    global spy

    set arg [split $arg]
    set arg [lindex $arg 0]

    if { $arg != "" } {
        file:addid $spy(excfile) $arg
        Fl:massinit
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+excspy <host>"
        return 0
    }
}


###########
# -excspy #
###########
bind dcc A -excspy Fl:dcc:delexcspy

proc Fl:dcc:delexcspy { hand idx arg } {
    global spy

    set arg [split $arg]
    set arg [lindex $arg 0]

    if { $arg != "" } {
        if { [file:rem $spy(excfile) $arg] == 1 } {
            Fl:massinit
            return 1
        } else {
            putdcc $idx "$arg n'existe pas"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-excspy <host>"
        return 0
    }
}



##########
# excspy #
##########
bind dcc A excspy Fl:dcc:listexcspy

proc Fl:dcc:listexcspy { hand idx arg } {
    global spy

    putdcc $idx "\002-- Liste des Hosts en ExcSpy\002:"
    putdcc $idx "$spy(exclist)"
    putdcc $idx " "
    return 1
}



###############
# Test de Spy #
###############
proc excspy:test { host } {
    global spy

    set host [split $host]
    set host [string tolower [join $host]]
    foreach i $spy(exclist) {
        set i [string tolower $i]
        if { [string match $i $host] } {
            return 1    
        }
    }
    return 0
}



##########################
# Link Eva.Entrechat.Net #
##########################
bind raw - NOTICE Fl:EvaLink

proc Fl:EvaLink {from keyword arg}  {
    global Fl FlUser FlNb botnick Failed_Oper failed_host

    set arg [split $arg]

    if { ![string match *@* $from] } {

        #-----
        # init des variables qd Eva restart
        #-----
        if { [string match "[join $arg]" "$botnick :*** Notice -- chat-hub.voila.fr introducing U:lined server Eva.Entrechat.Net"] } {
            putlog "[b]Starting Flood-Connexions Detector...[b] (Link Server Eva.Entrechat.Net)"
            set FlUser(0) 0 ; unset FlUser
            set FlNb(0) 0 ; unset FlNb

            set failed_host(0) 0 ; unset failed_host

        #-----
        # Controle des Failed Opers
        #-----
        } elseif { [string match "*Failed OPER*" "[join $arg]"] && "$botnick :*** Notice -- from" == [join [lrange $arg 0 4]] } {

            if { [lindex $arg 6] == "" } {
              set arg "[split "[join [lrange $arg 0 5]] [join [lrange $arg 7 end]]"]"
            }

            set fl_login [string trimright [string trimlef [lindex $arg 8] "("] ")"]
            set fl_nick [lindex $arg 11]
            set fl_uhost [string trimright [string trimlef [lindex $arg 12] "("] ")"]

            set fl_user [Xuser $fl_login!$fl_uhost]
            set fl_host [Xhost $fl_login!$fl_uhost]
            set fl_hostlw [string tolower $fl_host]

            if { ![info exist failed_host($fl_hostlw)] } { set failed_host($fl_hostlw) 0 }
            incr failed_host($fl_hostlw)

            utimer $Failed_Oper(tps) "FailedOper:del $fl_hostlw"

            if { [Fl:test:xexc $fl_hostlw] } {
#              putlog "Failed Oper Protect -> $fl_login <-> $fl_nick $fl_host"

            } elseif { $failed_host($fl_hostlw) == $Failed_Oper(nb) } {
              putlog "K-line \002*@$fl_host\002 \[\002$FlNb($fl_hostlw)\002\] $Failed_Oper(klineraison), expire dans [duration [expr $Failed_Oper(klinetps)*60]] - $botnick"
              putoperserv 0 "K-line \002*@$fl_host\002 \[\002$FlNb($fl_hostlw)\002\] $Failed_Oper(klineraison), expire dans [duration [expr $Failed_Oper(klinetps)*60]] - $botnick"
              raw "GLOBOPS :K-line \002*@$fl_host\002 \[\002$FlNb($fl_hostlw)\002\] $Failed_Oper(klineraison), expire dans [duration [expr $Failed_Oper(klinetps)*60]] - $botnick"
              raw "KLINE $Failed_Oper(klinetps) *@$fl_host :\[\002$FlNb($fl_hostlw)\002\] $Failed_Oper(klineraison), expire dans [duration [expr $Failed_Oper(klinetps)*60]] - $botnick"

            } else {
              putlog "[10]Failed Oper[o] -> \002$fl_nick\002 $fl_uhost using o-line: $fl_login"
              putoperserv 5 "[10]Failed Oper[o] -> \002$fl_nick\002 $fl_uhost using o-line: $fl_login"
            }

        }
    }
    return

}

proc FailedOper:del { host } {
    global failed_host

    set hostlw [string tolower $host]
    if { [info exist failed_host($hostlw)] } { unset failed_host($hostlw) }
    return
}



########################################
# Link/Unlink avec le Bot de Connexion #
########################################

bind link -|- * Fl:BotLink

proc Fl:BotLink { botname via } {
    global Fl botnick
    if { [string tolower $botname] == [string tolower $Fl(botlink)] } {
        putlog "\[Flood-Connexions Detector\] Connexion avec $Fl(botlink)..."
        set FlUser(0) 0 ; unset FlUser
        set FlNb(0) 0 ; unset FlNb
    }
    return
}


bind disc -|- * Fl:BotUnLink

proc Fl:BotUnLink { botname } {
    global Fl botnick
    if { [string tolower $botname] == [string tolower $Fl(botlink)] } {
        putlog "\[Flood-Connexions Detector\] Deconnexion avec $Fl(botlink)..."
        set FlUser(0) 0 ; unset FlUser
        set FlNb(0) 0 ; unset FlNb
    }
    return
}



##############################
# Connexions et Deconnexions #
##############################

bind bot - CX:user Fl:user

proc Fl:user {bot cmd arg} {
  global Fl FlUser FlNb botnick

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

    if { ![info exist FlNb($hosttw)] } { set FlNb($hosttw) 0 }
    if { ![info exist FlUser($hosttw)] } { set FlUser($hosttw) 0 }

    incr FlNb($hosttw)
    incr FlUser($hosttw)
    utimer $Fl(tps) "FlDelUser $hosttw"

    if { ![Fl:test:xexc $hosttw] && $FlUser($hosttw) == $Fl(nbkline) } {
      putlog "K-line \002*@$host\002 \[\002$FlNb($hosttw)\002\] $Fl(klineraison), expire dans [duration [expr $Fl(klinetps)*60]] - $botnick"
      putoperserv 0 "K-line \002*@$host\002 \[\002$FlNb($hosttw)\002\] $Fl(klineraison), expire dans [duration [expr $Fl(klinetps)*60]] - $botnick"
      raw "KLINE $Fl(klinetps) *@$host :\[$FlNb($hosttw)\] $Fl(klineraison), expire dans [duration [expr $Fl(klinetps)*60]] - $botnick"
      raw "GLOBOPS :K-line \002*@$host\002 \[\002$FlNb($hosttw)\002\] $Fl(klineraison), expire dans [duration [expr $Fl(klinetps)*60]] - $botnick"

    } elseif { ![Fl:test:xexc $hosttw] && $FlUser($hosttw) >= $Fl(nbconnex) } {
      putlog "[5]Flood Connexion[o] \[[b]$FlNb($hosttw)[b]\] $host -> $arg1!$user ($FlUser($hosttw))"
      putoperserv 5 "[5]Flood Connexion[o] \[[b]$FlNb($hosttw)[b]\] $host -> $arg1!$user ($FlUser($hosttw))"

    }

    if { [spy:test $hosttw] && ![excspy:test $hosttw] } {
      putloglev 6 * "[7]Spy Host[o] \[[b]$FlNb($hosttw)[b]\] $host -> $arg1!$user"
      putoperserv 6 "[7]Spy Host[o] \[[b]$FlNb($hosttw)[b]\] $host -> $arg1!$user"

    }
  }
  return
}


bind bot - CX:quit Fl:quit
proc Fl:quit {bot cmd arg} {
  global Fl FlUser FlNb

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
    if { [info exist FlNb($hosttw)] } {
      set FlNb($hosttw) [expr $FlNb($hosttw) - 1]
      if { $FlNb($hosttw) <= 0 } { unset FlNb($hosttw) }
    }
  }

  return
}


bind bot - CX:kill Fl:kill
proc Fl:kill {bot cmd arg} {
  global Fl FlUser FlNb

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
    if { [info exist FlNb($hosttw)] } {
      set FlNb($hosttw) [expr $FlNb($hosttw) - 1]
      if { $FlNb($hosttw) <= 0 } { unset FlNb($hosttw) }
    }
  }

  return
}

proc FlDelUser { host } {
  global Fl FlUser FlQuit
  if { [info exist FlUser($host)] } { unset FlUser($host) }
  return
}



##################################
# Supplément de la console +1/+2 #
##################################

# bind bot - CX:nick Fl:nick
proc Fl:nick {bot cmd arg} {
  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]
  putloglev 1 * "Nick $arg1 -> $arg2 $arg3"
  putloglev 2 * "2Nick $arg1 -> $arg2 $arg3"
}


# bind bot - CX:join Fl:join
proc Fl:join {bot cmd arg} {
  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]
  putloglev 1 * "Join $arg1 $arg2 $arg3"
  putloglev 2 * "3Join $arg1 $arg2 $arg3"
}


# bind bot - CX:part Fl:part
proc Fl:part {bot cmd arg} {
  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]
  putloglev 1 * "Part $arg1 $arg2 $arg3"
  putloglev 2 * "10Part $arg1 $arg2 $arg3"
}
