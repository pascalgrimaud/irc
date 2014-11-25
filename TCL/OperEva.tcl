#
# OperEva.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Tcl qui crée un Socket Service qui permet de gérer les commandes
# xclose et xpart.
#



#################
# Configuration #
#################

# nick pour le service
set xeva(nick) "E"

# identd
set xeva(user) "evaserv"

# realname
set xeva(realname) "Eva Service"

# server et port
set xeva(server) "chat4.x-echo.com"
set xeva(port) "6664"

# server et port du Bnc
set xeva(bncserver) "Webs8-0-0.x-echo.com"
set xeva(bncport) "1111"
set xeva(bncpass) "b0unc3r"

# NickServ
set xeva(nickservnick) "N"
set xeva(nickservmsg) ":N!nickserv@1667194866.com NOTICE E :Ce pseudo appartient à une autre personne. Merci de bien vouloir en choisir un autre en tapant /nick <pseudo>. Si c'est votre nick, tapez: /msg N IDENTIFY <password>"
# set xeva(nickservmsg) ":N!nickserv@318282940.fr NOTICE E :Ce pseudo appartient à une autre personne. Merci de bien vouloir en choisir un autre en tapant /nick <pseudo>. Si c'est votre nick, tapez: /msg N IDENTIFY <password>"
set xeva(nickservpass) "k!ssN!ckS3rV"

# Oper
set xeva(OperMode) "+wa"
set xeva(UnOperMode) "-agswo"



########
# Motd #
########

putlog "\002OperEva.tcl\002"



##############
# Lancer Eva #
##############

bind dcc -|- xevaconnect xevasock
bind dcc -|- xevasock xevasock

proc xevasock {hand idx text} {
    global xeva
    if { [info exists xeva(idx)] } {
        if { [valididx $xeva(idx)] } {
            killdcc $xeva(idx)
        }
    }
    foreach i [dcclist] {
        if { [lindex $i 4] == "scri  xeva:event" } {
            killdcc [lindex $i 0]
        }
    }
    xeva:connect
    return 1
}

proc xeva:connect { } {
    global xeva

    if { [xeva:test] == 0 } {
        if { ![catch {connect $xeva(bncserver) $xeva(bncport) } xeva(idx)]} {
            set xeva(nickpris) 0
            set xeva(oper) 0
            set xeva(xclosechan) ""
            set xeva(xwhoidx) ""
            set xeva(xwhoarg) ""

            putloglev 7 * "\[\002Connex Eva\002\] Lancement de $xeva(nick) ($xeva(realname)) (Idx = $xeva(idx))" 
            putdcc $xeva(idx) "USER $xeva(user) $xeva(user) $xeva(user) :$xeva(realname)"
            putdcc $xeva(idx) "NICK $xeva(nick) localhost r :$xeva(realname)"

            control $xeva(idx) xeva:event
        } else {
            putloglev 7 * "\[\002Connex Eva\002\] Connexion impossible" 
        }
    } elseif { [xeva:test] > 1 } {
        foreach i [dcclist] {
            if { "[lindex $i 4]" == "scri  xeva:event" } {
                putloglev 7 * "\[\002Connex Eva\002\] Déconnexion de $xeva(nick) (Idx = [lindex $i 0])" 
                killdcc [lindex $i 0]
            }
        }
    }

    timer 1 xeva:connect
    return 0
}

proc xeva:event { idx arg } {
    global xeva CX botnick amount amountircop wlistnick wlistircop

    set arg [split $arg]

    putloglev 8 * "\[IN\] [join $arg]"

    if { [lindex $arg 0] == "PING" } {
        putdcc $idx "PONG [lindex $arg 1]"
        putdcc $idx "NICK $xeva(nick)"
    }
    if { [join $arg] == "NOTICE AUTH :You need to say /quote PASS <password>" } {
        putdcc $idx "PASS $xeva(bncpass)"
    }
    if { [join $arg] == "NOTICE AUTH :type /quote help for basic list of commands and usage" } {
        putdcc $idx "CONN $xeva(server) $xeva(port)"
    }
    if { [lindex $arg 1] == "001" } {
        set xeva(oper) 0 
    }
    if { [lindex $arg 1] == "002" } {
        if { [string match "*Your host is $xeva(server)*" [join $arg]] } {
            set temp [file:get "../TCL/Ibu/OperInit.conf"]
            putdcc $idx "OPER [decrypt f8gKRaDlF0:F8jGK3fCnDe3 [lindex [split $temp] 0]] [decrypt k3jfCnV_Fh30rkFl2rkFdEr [lindex [split $temp] 1]]"
            if { $xeva(nickpris) == 0 } { putdcc $idx "MODE E $xeva(OperMode)" }
            unset temp
        }
    }

    if { [lindex $arg 1] == "381" } {
        set xeva(oper) 1
        if { $xeva(nickpris) == 1 } {
          putdcc $idx "KILL E :nick!"
          putdcc $idx "NICK E"
          putdcc $idx "MODE E $xeva(OperMode)"
        }
        set xeva(nickpris) 0
        putlog "\002Starting Eva Service...\002"
    }
    if { [lindex $arg 1] == "433" } {
        set xeva(nickpris) 1
        putdcc $idx "NICK $xeva(nick)[expr [rand 899]+100]"
    }
    if { [string match "[string tolower [join $arg]]" "[string tolower $xeva(nickservmsg)]"] } {
        putdcc $idx "PRIVMSG $xeva(nickservnick) :IDENTIFY $xeva(nickservpass)"
    }

    if { [lindex $arg 1] == "353" } {
        putdcc $idx "SAMODE [lindex $arg 4] +o [lindex $arg 2]"
    }

    if { [lindex $arg 1] == "352" } {

        # --- Xclose --- #
        if { $xeva(xclosechan) != "" } {

            if { [string match *\\* [lindex [split [lindex $arg 8] @+diwg] 0]] != 1
              && [string tolower [lindex $arg 2]] != [string tolower [lindex $arg 7]] } {
               lappend xeva(nicklist) [lindex $arg 7]
            }
            if { [llength $xeva(nicklist)] == 4 } {
                putdcc $idx "KICK [lindex $arg 3] [join $xeva(nicklist) ,] :$xeva(raison)"
                set xeva(nicklist) ""
            }

        # --- Xwho --- #
        } elseif { $xeva(xwhoidx) != "" } {

            set arg [lrange $arg 2 end]
            if { $arg != "" } {

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

                if { [expr $amount + $amountircop] == 0 } { putdcc $xeva(xwhoidx) " " }
                putdcc $xeva(xwhoidx) " \002$WhoX(nick)\002 $WhoX(user)@$WhoX(host) ($WhoX(server)) $WhoX(name)"

                incr amount

                if { $WhoX(ircop) } {
                    incr amountircop
                    lappend wlistircop $WhoX(nick)
                } else {
                    lappend wlistnick $WhoX(nick)
                }
            }
        }

    }

    if { [lindex $arg 1] == "315" } {

        # --- Xclose --- #
        if { $xeva(xclosechan) != "" } {
            if { $xeva(nicklist) != "" } {
                putdcc $idx "KICK [lindex $arg 3] [join $xeva(nicklist) ,] :$xeva(raison)"
                set xeva(nicklist) ""
            }
            set xeva(xclosechan) ""

        # --- Xwho --- #
        } elseif { $xeva(xwhoidx) != "" } {
            putdcc $xeva(xwhoidx) " "
            if { $amountircop == 0 } {
                putdcc $xeva(xwhoidx) "* Il y a $amount usagers correspondant à la recherche."
            } elseif { $amountircop == 1 } {
                putdcc $xeva(xwhoidx) "* Il y a $amount usagers correspondant à la recherche dont \002$amountircop\002 IRCop"
            } else {
                putdcc $xeva(xwhoidx) "* Il y a $amount usagers correspondant à la recherche dont \002$amountircop\002 IRCops"
            }

            if { $wlistircop != "" } { putdcc $xeva(xwhoidx) "* liste des Opers: [join $wlistircop]" }
            if { $wlistnick != "" } { putdcc $xeva(xwhoidx) "* liste des nicks: [join $wlistnick]" }

            putdcc $xeva(xwhoidx) " "
            putlog "#[idx2hand $xeva(xwhoidx)]# xwho $xeva(xwhoarg)"
            set xeva(xwhoidx) ""
            set xeva(xwhoarg) ""
        }
    }

    if { [lindex $arg 1] == "403" } {

        if { $xeva(xwhoidx) != "" } {
            putdcc $xeva(xwhoidx) "Channel inexistant."
            putlog "#[idx2hand $xeva(xwhoidx)]# xwho $xeva(xwhoarg)"
            set xeva(xwhoidx) ""
            set xeva(xwhoarg) ""
        }
    }

    if { [lindex $arg 1] == "522" } {

        if { $xeva(xwhoidx) != "" } {
            putdcc $xeva(xwhoidx) "Requête refusée: [string trimleft [join [lrange [split $arg] 1 end]] :] (ou E non authé IRCop -> essayez .xevaco)"
            putlog "#[idx2hand $xeva(xwhoidx)]# xwho $xeva(xwhoarg)"
            set xeva(xwhoidx) ""
            set xeva(xwhoarg) ""
        }
    }
    return 0
}



################################################
# Procédure de test si ya connexion du service #
################################################

proc xeva:test { } {
    global xeva

    set xeva(existidx) 0
    foreach i [dcclist] {
        if { "[lindex $i 4]" == "scri  xeva:event" } {
            incr xeva(existidx)
        }
    }
    return $xeva(existidx)
}



###################
# xeva <commande> #
###################

bind dcc n xeva xevacommande

proc xevacommande { hand idx text } {
    global xeva

    set text [split $text]
    if { [info exists xeva(idx)] } {
        if { [valididx $xeva(idx)] } {
            putdcc $xeva(idx) "[join $text]"
        }
    }
    return
}


############
# xevaoper #
############

bind dcc n xevaoper xeva:oper

proc xeva:oper { hand idx text } {
    global xeva

    set text [split $text]

    set username [lindex $text 0]
    set password [lindex $text 1]

    if { [info exists xeva(idx)] } {
        if { [valididx $xeva(idx)] } {
            if { $username != "" } {
                if { $password != "" } {
                    putlog "#$hand# xevaoper $xeva(nick)"
                    putdcc $xeva(idx) "OPER $username $password"
                    putdcc $xeva(idx) "MODE $xeva(nick) $xeva(OperMode)"
                } else {
                    putdcc $idx "\002Syntaxe\002: .xevaoper <username> <password>"
                    putdcc $idx "T'as oublié le mot de passe?"
                }
            } else {
                putdcc $idx "\002Syntaxe\002: .xevaoper <username> <password>"
                putdcc $idx "T'as oublié le username?"
            }
        } else {
            putdcc $idx "Idx d'Eva invalide"
        }
    } else {
        putdcc $idx "Idx d'Eva inexistant"
    }
    unset username
    unset password

    return 0
}



###############
# xeva:xclose #
###############

proc xeva:xclose { channel raison } {
    global xeva

    if { [info exists xeva(idx)] } {
        if { [valididx $xeva(idx)] } {
            set xeva(raison) $raison
            set xeva(xclosechan) $channel

            putdcc $xeva(idx) "JOIN $channel x"
            putdcc $xeva(idx) "SAMODE $channel +imnst"
            putdcc $xeva(idx) "WHO $channel x"
        }
    }
    return
}



############
# xeva:who #
############

proc xeva:xwho { idx arg } {
    global xeva amount amountircop wlistnick wlistircop

    if { [info exists xeva(idx)] } {
        if { [valididx $xeva(idx)] } {
            set xeva(xwhoidx) $idx
            set xeva(xwhoarg) "$arg"

            set amount 0
            set amountircop 0
            set wlistnick ""
            set wlistircop ""

            putdcc $xeva(idx) "WHO $arg x"
        }
    }
    return
}



##############
# xeva:xpart #
##############

proc xeva:xpart { channel } {
    global xeva

    if { [info exists xeva(idx)] } {
        if { [valididx $xeva(idx)] } {
            putdcc $xeva(idx) "PART $channel"
        }
    }
    return
}


####################
# Lancement du TCL #
####################

foreach t [timers] {
  if { [string match *xeva:connect* [lindex $t 1]] } {
    killtimer [lindex $t 2]
  }
}

if { [info exists xeva(idx)] } {
  if { [valididx $xeva(idx)] } {
    killdcc $xeva(idx)
  }
}
xeva:connect

