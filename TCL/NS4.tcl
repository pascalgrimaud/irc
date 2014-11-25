#
# NS4.tcl (v4.0) par Ibu <ibu_lordaeron@yahoo.fr>
#




proc rawx { string } {
  putdcc [hand2idx Ibu] "\[\002OUT\002\] $string"
  return 0
}


#################
# Configuration #
#################

# fichier où sera stocké les hosts protégés
set NS(filehost) "system/NS-Hosts.conf"

# fichier où sera stocké les chans protégés
set NS(filechan) "system/NS-Chans.conf"

# Temps minimum autorisé à rester connecté sans etre SvNick
set NS(temps) 30

# Le NickServ sera exécuté ou pas...
set NS(exe) 1

# bot de connexions
set NS(botlink) "C"

# message d'aide
set NS(check) "Ce pseudo appartient à une autre personne. Merci de bien vouloir en choisir un autre en tapant /nick <pseudo>. Si c'est votre nick, tapez: /msg N IDENTIFY <password>"
set NS(autoauth) "Votre host correspond aux hosts protégés. Vous êtes autorisé à utiliser ce pseudo."
set NS(autochan) "Vous êtes sur un salon protégé. Vous êtes autorisé à utiliser ce pseudo."
set NS(authed) "Vous êtes déjà authentifié."
set NS(accepted) "Password accepté pour"
set NS(accepted2) "Tapez: /msg N HELP pour voir la liste des commandes disponibles."
set NS(help) "Liste des commandes: \[ s'identifier: /msg N IDENTIFY <pass> \] \[ changer son pass: /msg N PASSWORD <nouveau pass> <nouveau pass> \] \[ se supprimer: /msg N DROP <pass> \] \[ forcer le SvNick: /msg N GHOST <login> <pass> (30s d'attente)\] Pour toute information/bugs/suggestions, mailer à <ibu_lordaeron@yahoo.fr>"
set NS(wrongpass1) "Le pass entré pour"
set NS(wrongpass2) "est incorrect."
set NS(identifysyntaxe) "Syntaxe: IDENTIFY <login> <password>"
set NS(mustauthed) "Vous devez être authentifié. Tapez: /msg N IDENTIFY <password>"
set NS(drop) "a été effacé!"
set NS(dropsyntaxe) "Syntaxe: DROP <password>"
set NS(passwordsyntaxe) "Syntaxe: PASSWORD <password> <password>"
set NS(passchanged) "Password changé..."
set NS(ghostsyntaxe) "Syntaxe: GHOST <login> <password>"
set NS(ghostdone) "Demande de Ghost en cours..."



########
# Motd #
########

putlog "\002NS4.tcl\002 - Nickname Service"
putlog "   Use .ns for help"



##################
# Initialisation #
##################

set NS(start) 0

# Starting NickServ...
bind raw - "005" NS:starting

proc NS:starting { from key text } {
    global NS
    set NS(start) 0
    return 1
}


# Initialisation des hosts protégés
#   --> NSChainHost
#
proc NS:host:initchain { } {
    global NS NSChainHost

    set NSChainHost [file:tostring $NS(filehost)]
    return
}

# Initialisation des chans protégés
#   --> NSChainChan
#
proc NS:chan:initchain { } {
    global NS NSChainChan

    set NSChainChan [file:tostring $NS(filechan)]
    return
}

# Initialisation générale
#
proc NS:massinit { } {
    global NSNickCpt NSAuth NSChk

    set NSAuth(@debug) 0 ; unset NSAuth
    set NSChk(@debug) 0 ; unset NSChk

    foreach i [userlist +R] {
      if { [getuser $i XTRA LOGIN] != "" } {
        setuser $i XTRA LOGIN ""
        set NSChk([string tolower $i]) 0
      }
    }
    save

    NS:host:initchain
    NS:chan:initchain

    foreach t [utimers] {
       if { [string match *NS:CheckWho* [lindex $t 1]] } {
           killutimer [lindex $t 2]
       }
   }
}



##########################
# au lancement du TCL... #
##########################

NS:massinit

global botnick
putquick "MODE $botnick"



########
# Aide #
########
bind dcc -|- ns NS:dcc:help

proc NS:dcc:help { hand idx arg } {
    global NS botnick

    putdcc $idx " "
    putdcc $idx "     NS4.tcl (v4.0) - Aide     "
    putdcc $idx " "
    putdcc $idx " Flag +N = pour utiliser le NickServ"
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Script utilisé en tant que NickServ"
    putdcc $idx "   $botnick <--> $NS(botlink)"
    putdcc $idx " "
    putdcc $idx "   Mode console +3 pour voir l'évolution du NS."
    putdcc $idx " "
    putdcc $idx "   NOTE: L'eggdrop doit etre authé IRCop"
    putdcc $idx "   ( .xoper & .xunoper -> cf .eggtools ds EggTools2-0.tcl )"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .nsnick <string> 14(lister la liste des pseudos protégés)"
    putdcc $idx "  .+nsnick <nick> <pass> <nick!user@host> <email> <info> 14(ajoute un pseudo à protéger)"
    putdcc $idx "  .-user <nick> 14(retire un pseudo)"
    putdcc $idx " "
    putdcc $idx "  .nsinfo <string> 14(lister les infos des nicks protégés)"
    putdcc $idx "  .nsauth 14(lister les nicks authés)"
    putdcc $idx " "
    putdcc $idx "  .\[+/-\]nshost \[user@host\] 14(ajouter/retirer/lister un user@host protégé)"
    putdcc $idx "  .\[+/-\]nschan \[#channel\] 14(ajouter/retirer/lister un channel protégé)"
    putdcc $idx "  .\[+/-\]nssuspend \[nick\] 14(ajouter/retirer/lister un nick suspendu)"
    putdcc $idx " "
    putdcc $idx " "
    putdcc $idx "  .nickserv 14(activer/desactiver le NickServ)"
    if {$NS(start)} {
        putdcc $idx "      \[Status\] -> NickServ Active"
    } else {
        putdcc $idx "      \[Status\] -> NickServ DesActive"
    }
    putdcc $idx " "
    putdcc $idx "  .ns <-- Aide, vous êtes ici!"
    putdcc $idx " "
    return 1
}



####################
# Active/Desactive #
####################
bind dcc N|- nickserv NS:dcc:act

proc NS:dcc:act { hand idx args } {
    global NS botnick

    if { $NS(exe) } {
        set NS(exe) 0
        set NS(start) 0
        putlog "#$hand# NickServ -> DesActivé"
    } else {
        set NS(exe) 1
        putlog "#$hand# NickServ -> Activé"
        putquick "MODE $botnick"
    }
    return 0
}



###################
# Ajouter un Nick #
###################
bind dcc N|- +nsnick NS:nick:add

proc NS:nick:add { hand idx arg } {
  global NS NSChk

  set arg [split $arg]

  set tempnick [lindex $arg 0]
  set temppass [lindex $arg 1]
  set temphost [lindex $arg 2]
  set tempemail [lindex $arg 3]
  set tempinfo [join [lrange $arg 4 end]]

  if { $tempinfo == "" } {
    putdcc $idx "\002Syntaxe\002: .+nsnick <nick> <pass> <host> <email> <info>"
    putdcc $idx "   Info manquante."
    return 0

  } elseif { ![string match *@*.* $tempemail] } {
    putdcc $idx "\002Syntaxe\002: .+nsnick <nick> <pass> <host> <email> <info>"
    putdcc $idx "   Le format de l'email ne correspond pas."

  } elseif { ![string match *!*@* $temphost] } {
    putdcc $idx "\002Syntaxe\002: .+nsnick <nick> <pass> <host> <email> <info>"
    putdcc $idx "   Le format du host ne correspond pas."

  } elseif { [string length $temppass] < 6 } {
    putdcc $idx "\002Syntaxe\002: .+nsnick <nick> <pass> <host> <email> <info>"
    putdcc $idx "   Le pass doit contenir 6 caractères ou plus."

  } elseif { [validuser $tempnick] } {
    if { [matchattr $tempnick P] } {
      putdcc $idx "Ce pseudo est déjà protégé."
    } else {
      putdcc $idx "Pour protéger ce pseudo, utilisez: .+nsprotect"
    }

  } else {
    adduser $tempnick $temphost
    setuser $tempnick PASS $temppass
    setuser $tempnick COMMENT $tempinfo
    setuser $tempnick XTRA EMAIL $tempemail
    setuser $tempnick LASTON never
    setuser $tempnick XTRA LOGIN ""
    chattr $tempnick -hp+R
    save

    set NSChk([string tolower $tempnick]) 0

    if { $NS(exe) && $NS(start) } { raw "ISON $tempnick" }
    
    putlog "#$hand# +nsnick $tempnick \[something\]"
  }

  return 0
}



###################
# Retirer un Nick #
###################
bind dcc N|- -nsnick NS:nick:del

proc NS:nick:del { hand idx arg } {
  global NS NSAuth NSChk

  set arg [lindex [split $arg] 0]
  set arglw [string tolower $arg]

  if { $arg == "" } {
    putdcc $idx "\002Syntaxe\002: .-nsnick <nick>"
    return 0

  } elseif { ![validuser $arg] } {
    putdcc $idx "Nick invalide!"
    return 0

  } elseif { [matchattr $arg +p] } {
    putdcc $idx "Vous ne pouvez pas retirer un utilisateur de la partyline."
    return 0

  } elseif { ![matchattr $arg +R] } {
    putdcc $idx "Cet utilisateur n'est pas un nick protégé."
    return 0

  } else {
    putdcc $idx "Done."
    if { [info exist NSAuth($arglw)] } { unset NSAuth($arglw) }
    if { [info exist NSChk($arglw)] } { unset NSChk($arglw) }
    deluser $arg

    return 1
  }
}



###################
# Liste les Nicks #
###################
bind dcc N|- nsnick NS:nick:list

proc NS:nick:list { hand idx arg } {
    global NS

    set arg [split $arg]
    set compte 0

    if { $arg == "" } {
        putdcc $idx "\002Syntaxe\002: .nsnick <string>"
        return 0
    } else {
        putdcc $idx "\002-- Liste des Nicks protégés\002 (nick: $arg):"

        foreach i [userlist +R] {
          if { [string match [string tolower [lindex $arg 0]] [string tolower $i]] } {
            incr compte
            putlog "\002$i\002 [u]nick[u]: [getuser $i XTRA LOGIN] <[getuser $i XTRA EMAIL]> - [u]Last Auth[u]: [getuser $i LASTON] - [u]Info[u]: [getuser $i COMMENT]"
          }
        }
        putdcc $idx " "
        putdcc $idx "\002-- Nombre\002: $compte"
        putdcc $idx " "
        return 1
    }
}



###################
# Liste les Infos #
###################
bind dcc N|- nsinfo NS:nick:info

proc NS:nick:info { hand idx arg } {
    global NS

    set arg [split $arg]
    set compte 0

    if { $arg == "" } {
        putdcc $idx "\002Syntaxe\002: .nsnick <string>"
        return 0
    } else {
        putdcc $idx "\002-- Liste des Nicks protégés\002 (info: $arg):"

        foreach i [userlist +R] {
          if { [string match "[string tolower [join $arg]]" "[getuser $i COMMENT]"] } {
            incr compte
            putlog "\002$i\002 [u]nick[u]: [getuser $i XTRA LOGIN] <[getuser $i XTRA EMAIL]> - [u]Last Auth[u]: [getuser $i LASTON] - [u]Info[u]: [getuser $i COMMENT]"
          }
        }
        putdcc $idx " "
        putdcc $idx "\002-- Nombre\002: $compte"
        putdcc $idx " "
        return 1
    }
}



####################
# Liste des Authés #
####################
bind dcc N|- nsauth NS:nick:listauth

proc NS:nick:listauth { hand idx arg } {
    global NS

    set arg [split $arg]
    set compte 0

    putdcc $idx "\002-- Liste des Nicks authés\002:"

    foreach i [userlist +R] {
      if { [getuser $i XTRA LOGIN] != "" && [getuser $i XTRA LOGIN] != "-" } {
        incr compte
        putlog "\002$i\002 [u]nick[u]: [getuser $i XTRA LOGIN] <[getuser $i XTRA EMAIL]> - [u]Last Auth[u]: [getuser $i LASTON] - [u]Info[u]: [getuser $i COMMENT]"
      }
    }
    putdcc $idx " "
    putdcc $idx "\002-- Nombre\002: $compte"
    putdcc $idx " "
    return 1
}



###################
# Ajouter un Host #
###################
bind dcc N|- +nshost NS:host:add

proc NS:host:add { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set arg [lindex [split $arg] 0]

    if { $arg != "" && [string match *@* $arg] } {

        if { [file:addid $NS(filehost) "$arg"] == 1 } {
            putdcc $idx "\002\[NS: Add Hosts\]\002 ::: $arg existe déjà!"
        } else {
            putdcc $idx "\002\[NS: Add Hosts\]\002 ::: $arg a été ajouté!"
        }

        NS:host:initchain

        putlog "#$hand# +nshost $arg"
        return 0
    } else {
        putdcc $idx "\002Syntaxe\002: .+nshost <user@host>"
        return 0
    }
}



###################
# Retirer un Host #
###################
bind dcc N|- -nshost NS:host:del

proc NS:host:del { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set arg [lindex [split $arg] 0]

    if { $arg != "" } {
        if { [file:rem $NS(filehost) $arg] == 1 } {
            putdcc $idx "\002\[NS: Del Hosts\]\002 ::: $arg a été effacé!"
            NS:host:initchain
            return 1
        } else {
            putdcc $idx "\002\[NS: Del Hosts\]\002 ::: $arg n'existe pas!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-nshost <user@host>"
        return 0
    }
}



###################
# Liste les Hosts #
###################
bind dcc N|- nshost NS:host:list

proc NS:host:list { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    putdcc $idx "\002-- Liste des Hosts protégés\002:"
    putdcc $idx "$NSChainHost"
    putdcc $idx " "
    return 1
}



##################
# Test des Hosts #
##################
proc NS:test:host { host } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set host [string tolower $host]

    foreach i $NSChainHost {
        set i [string tolower $i]
        if { [string match $i $host] } { return 1 }
    }
    return 0
}



###################
# Ajouter un Chan #
###################
bind dcc N|- +nschan NS:chan:add

proc NS:chan:add { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set arg [lindex [split $arg] 0]

    if { $arg != "" && [string index $arg 0] == "#" } {
        if { [validchan $arg] } {
            if { [file:addid $NS(filechan) "$arg"] == 1 } {
                putdcc $idx "\002\[NS: Add Chans\]\002 ::: $arg existe déjà!"
            } else {
                putdcc $idx "\002\[NS: Add Chans\]\002 ::: $arg a été ajouté!"
            }
            NS:chan:initchain
            putlog "#$hand# +nschan $arg"
            return 0
        } else {
            putdcc $idx "\002\[NS: Add Chans\]\002 ::: erreur... $arg n'est pas un salon valide!"
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .+nschan <#channel>"
        return 0
    }
}



###################
# Retirer un Chan #
###################
bind dcc N|- -nschan NS:chan:del

proc NS:chan:del { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set arg [lindex [split $arg] 0]

    if { $arg != "" && [string index $arg 0] == "#" } {
        if { [file:rem $NS(filechan) $arg] == 1 } {
            putdcc $idx "\002\[NS: Del Chans\]\002 ::: $arg a été effacé!"
            NS:chan:initchain
            return 1
        } else {
            putdcc $idx "\002\[NS: Del Chans\]\002 ::: $arg n'existe pas!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-nschan <#channel>"
        return 0
    }
}



###################
# Liste les Chans #
###################
bind dcc N|- nschan NS:chan:list

proc NS:chan:list { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    putdcc $idx "\002-- Liste des Chans protégés\002:"
    putdcc $idx "$NSChainChan"
    putdcc $idx " "
    return 1
}



##############################
# Test de Protection de Chan #
##############################
proc NS:test:chan { nick } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set nick [string tolower $nick]

    foreach i $NSChainChan {
        if { [validchan $i] } {
            if { [botonchan $i] && [onchan $nick $i] } {
               return 1
            }
        }
    }
    return 0
}



#########################
# Lancement du NickServ #
#########################

bind raw - "381" CheckOper

proc CheckOper { from key text } {
  global botnick
  putserv "MODE $botnick"
}


bind raw - "221" CheckMode

proc CheckMode { from key text } {
  global botnick NS

  set text [split $text]

  set botlinkpresent 0
  foreach i [bots] {
    if { [string match [string tolower $i] [string tolower $NS(botlink)]] } {
      set botlinkpresent 1
    }
  }

  if { $NS(exe) == 0 } {
    putlog "\[NickServ\] Non démarré... (config)"

  } elseif { $botlinkpresent == 0 } {
    putlog "\[NickServ\] Non démarré... (bot de Link non trouvé --> $NS(botlink))"

  } elseif { ![string match *o* [lindex $text 1]] || ![string match *a* [lindex $text 1]] } {
    putlog "\[NickServ\] Non démarré... (non IRCop lev2)"

  } else {
    set NS(start) 1
    putlog "[b]Starting Nickname Service...[b]"

    set arg [userlist +R]
    set i 0
    set NS(mustbechk) ""

    while { $i < [llength [join $arg]] } {
      set j 1
      while { [string length [join [lrange $arg $i [expr $i + $j]]]] <= 485 && [expr $i + $j] < [llength [join $arg]] } {
        incr j
      }
      set j [expr $j -1]
      putloglev 8 * "(DEBUG) \002ISON\002 [join [lrange $arg $i [expr $i + $j]]]"
      raw "ISON [join [lrange $arg $i [expr $i + $j]]]"
      set i [expr $i + $j + 1]
    }
    putloglev 8 * "(DEBUG) \002ISON\002 $botnick"
    raw "ISON $botnick"
  }

  return 0
}


bind raw - "303" CheckIsOn

proc CheckIsOn { from key text } {
    global botnick NS

    set text [split $text]
    set text1 [string range [join [lrange $text 1 end]] 1 end]

    putloglev 8 * "(DEBUG) \002Résultat ISON\002: [join $text1]"

    if { [string match [string tolower $botnick] [string tolower [join $text1]]] } {
      NS:masscheck [join $NS(mustbechk)]
    } else {
      lappend NS(mustbechk) $text1
    }
    
    return 0
}



##############################
# Rehash de Eva: info putlog #
##############################

# -irc.voila.fr- *** Routing -- from chat-hub.voila.fr: Server Eva.Entrechat.Net[unknown@0.0.0.0] closed the connection
# -irc.voila.fr- *** Routing -- from chat-hub.voila.fr: Link with Eva.Entrechat.Net[unknown@0.0.0.0] established: TS link
# -irc.voila.fr- *** Notice -- chat-hub.voila.fr introducing U:lined server Eva.Entrechat.Net

bind raw - NOTICE NS:EvaLink

proc NS:EvaLink {from keyword arg}  {
    global NS botnick

    set arg [split $arg]
    if { $NS(exe) && $NS(start) && ![string match *@* $from] } {
        if { [string match "[join $arg]" "$botnick :*** Notice -- chat-hub.voila.fr introducing U:lined server Eva.Entrechat.Net"] } {
            putlog "[b]Mass Nicknames Ctrl...[b] (Link Server Eva.Entrechat.Net)"
        }
    }
    return
}



########################################
# Link/Unlink avec le Bot de Connexion #
########################################

bind link -|- * NS:BotLink

proc NS:BotLink { botname via } {
    global NS botnick
    if { [string tolower $botname] == [string tolower $NS(botlink)] } {
        putlog "\[NickServ\] Connexion avec $NS(botlink)..."
        NS:massinit
        putserv "MODE $botnick"
    }
    return
}


bind disc -|- * NS:BotUnLink

proc NS:BotUnLink { botname } {
    global NS botnick
    if { [string tolower $botname] == [string tolower $NS(botlink)] } {
        putlog "\[NickServ\] Deconnexion avec $NS(botlink)..."
        set NS(start) 0
    }
    return
}



##########
# Listen #
##########

bind bot - CX:user NSConnexion:user

proc NSConnexion:user { bot cmd arg } {
    global NS CX

    set arg [split $arg]
    set arg1 [lindex $arg 0]
    set arg1lower [string tolower $arg1]
    set arg2 [lindex $arg 1]
    set arg3 [join [lrange $arg 2 end]]

    if { ![info exist CX($arg1lower)] } {
      set CX($arg1lower) $arg2
    } elseif { $CX($arg1lower) == "user@host" } {
      set CX($arg1lower) $arg2
    }

    if { $NS(start) } { NS:check $arg1 }

    return
}


bind bot - CX:quit NSConnexion:quit

proc NSConnexion:quit {bot cmd arg} {
  global NS CX NSAuth NSChk

  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]

  if { ![info exist CX($arg1lower)] } {
    set CX($arg1lower) $arg2
  } elseif { $CX($arg1lower) == "user@host" } {
    set CX($arg1lower) $arg2
  }

  if { $NS(start) } {
    if { [NS:var:status $arg1] > 0 } {
      if { [NS:isauth $arg1] } {
        set hand $NSAuth($arg1lower)
        unset NSAuth($arg1lower)
        setuser $hand XTRA LOGIN ""
      }

      NS:killutimer $arg1
      NS:modif:status $arg1 0
      putloglev 3 * "\[NickServ\] (12Quit) $arg1 $CX($arg1lower)"
    }
  }

  unset CX($arg1lower)

  return
}


bind bot - CX:kill NSConnexion:kill

proc NSConnexion:kill {bot cmd arg} {
  global NS CX NSAuth NSChk

  set arg [split $arg]
  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg3 [join [lrange $arg 2 end]]

  if { ![info exist CX($arg1lower)] } {
    set CX($arg1lower) $arg2
  } elseif { $CX($arg1lower) == "user@host" } {
    set CX($arg1lower) $arg2
  }

  if { $NS(start) } {
    if { [NS:var:status $arg1] > 0  } {
      if { [NS:isauth $arg1] } {
        set hand $NSAuth($arg1lower)
        unset NSAuth($arg1lower)
        setuser $hand XTRA LOGIN ""
      }

      NS:killutimer $arg1
      NS:modif:status $arg1 0
      putloglev 3 * "\[NickServ\] (12Quit) $arg1 $CX($arg1lower)"
    }
  }
  unset CX($arg1lower)

  return
}


bind bot - CX:nick NSConnexion:nick

proc NSConnexion:nick {bot cmd arg} {
  global NS CX NSAuth NSChk

  set arg [split $arg]

  set arg1 [lindex $arg 0]
  set arg1lower [string tolower $arg1]
  set arg2 [lindex $arg 1]
  set arg2lower [string tolower $arg2]
  set arg3 [join [lrange $arg 2 end]]

#  putloglev 1 * "nick $arg1 -> $arg2 $arg3"
#  putloglev 2 * "2Nick $arg1 -> $arg2 $arg3"

  if { ![info exist CX($arg1lower)] } {
    set CX($arg1lower) $arg3
  } elseif { $CX($arg1lower) == "user@host" } {
    set CX($arg1lower) $arg3
  }
  set CX($arg2lower) $CX($arg1lower)
  unset CX($arg1lower)

  if { $NS(start) } {

    #-----
    # si le pseudo entame juste un changement de casse
    #-----
    if { [string match $arg1lower $arg2lower] } {

    #-----
    # si le nouveau nick n'est pas un pseudo à protéger
    #-----
    } elseif { ![NS:validuser $arg2] } {

      #-----
      # si l'ancien nick était un pseudo authé sur un login...
      # on tranfère le login
      #-----
      if { [NS:isauth $arg1] } {
        NS:modif:status $arg1 0
        NS:killutimer $arg1

        putloglev 3 * "\[NickServ\] (14Trace) $arg1 -> $arg2 ($CX($arg2lower))"
        NS:changeauth $arg1 $arg2
      } elseif { [NS:validuser $arg1] } {

        putlog ">> [NS:var:status $arg1]"

        if { [NS:var:status $arg1] != 3 } {
          putloglev 3 * "\[NickServ\] (2ChNick) $arg1 -> $arg2 ($CX($arg2lower))"
        } else {
          putloglev 3 * "\[NickServ\] (4SvNick) $arg1 -> $arg2 ($CX($arg2lower))"
        }

        NS:modif:status $arg1 0
        NS:killutimer $arg1

      }
    } else {

      #-----
      # si l'ancien nick est authé, et change vers un nick protégé
      # on le déauth avant tt
      #-----
      if { [NS:isauth $arg1] && [string tolower $NSAuth($arg1lower)] != [string tolower $arg2] } {
        putlog ">>> je vire les info de l user..."
        set hand $NSAuth($arg1lower)
        unset NSAuth($arg1lower)
        setuser $hand XTRA LOGIN ""

      } else {
        putlog ">>> $arg1 -> $arg2"
        NS:changeauth $arg1 $arg2
      }

      NS:modif:status $arg1 0
      NS:killutimer $arg1
      NS:check $arg2
    }
  }

  return 0
}



####################
# Ctrl d'un pseudo #
####################

proc NS:check { NSNick } {
  global NS CX NSAuth NSChk

  set NSNickLower [string tolower $NSNick]

  #-----
  # si ya pas de mask attribué, j'en attribue un
  #-----
  NS:givehost $NSNick

  #-----
  # on ne démarre que si le pseudo est à protéger!
  #-----
  if { [NS:validuser $NSNick] } {

    #-----
    # si le Login est le mm que le pseudo actuellement utilisé,
    # c qu'il vient de changer de nick, et qu'il s'est déjà authé auparavant
    #-----
    if { [string tolower $NSNick] == [string tolower [getuser $NSNick XTRA LOGIN]] } {
        putloglev 3 * "\[NickServ\] (10Already Auth) $NSNick ($CX($NSNickLower))"

    #-----
    # sinon, s'il possède un host protégé
    #-----
    } elseif { [NS:test:host $CX($NSNickLower)] } {
      putloglev 3 * "\[NickServ\] (10Auth by Host) $NSNick ($CX($NSNickLower))"
      rawx "NOTICE $NSNick :$NS(autoauth)"

    #-----
    # sinon, s'il est sur un chan autorisé
    #-----
    } elseif { [NS:test:chan $NSNick] } {
      putloglev 3 * "\[NickServ\] (10Auth by Chan) $NSNick ($CX($NSNickLower))"
      rawx "NOTICE $NSNick :$NS(autochan)"

    #-----
    # sinon, s'il est suspendu
    #-----
    } elseif { [NS:test:suspend $NSNick] } {
      putloglev 3 * "\[NickServ\] (5Suspended) $NSNick ($CX($NSNickLower))"
 
    #-----
    # sinon... on lui accorde X sec pour changer de pseudo
    #-----
    } else {
      putloglev 3 * "\[NickServ\] (7Check) $NSNick ($CX($NSNickLower)) ([getuser $NSNick COMMENT])"
      rawx "NOTICE $NSNick :$NS(check)"

      NS:modif:status $NSNick 2
      putlog ">> [NS:var:status $NSNick]"
      NS:killutimer $NSNick
      utimer $NS(temps) "NS:CheckWho [split $NSNickLower]"
    }
  }

  return 0
}



########################
# Mass Ctrl de pseudos #
########################

proc NS:masscheck { NSMassNick } {
  global NS CX NSAuth

  putloglev 8 * "(DEBUG) NS:masscheck $NSMassNick"

  set NSMassNick [split $NSMassNick]

  set i 0
  set j 0
  set NSNickMax 0
  set maxi [expr [llength [join $NSMassNick]] -1]
  set stringnotice ""
  
  while { $i <= $maxi } {

    set NSNick [lindex $NSMassNick $i]
    set NSNickLower [string tolower $NSNick]

    #-----
    # si ya pas de mask attribué, j'en attribue un
    #-----
    rawx "NS:givehost $NSNick"
    NS:givehost $NSNick

    #-----
    # on ne démarre que si le pseudo est à protéger!
    #-----
    if { [NS:validuser $NSNick] } {

      #-----
      # si le Login est le mm que le pseudo actuellement utilisé,
      # c qu'il vient de changer de nick, et qu'il s'est déjà authé auparavant
      #-----
      if { [string match $NSNick [getuser $NSNick XTRA LOGIN]] } {
        putloglev 3 * "\[NickServ\] (10Already Auth) $NSNick ($CX($NSNickLower))"

      #-----
      # sinon, s'il possède un host protégé
      #-----
      } elseif { [NS:test:host $CX($NSNickLower)] } {
        putloglev 3 * "\[NickServ\] (10Auth by Host) $NSNick ($CX($NSNickLower))"
        rawx "NOTICE $NSNick :$NS(autoauth)"

      #-----
      # sinon, s'il est sur un chan autorisé
      #-----
      } elseif { [NS:test:chan $NSNick] } {
        putloglev 3 * "\[NickServ\] (10Auth by Chan) $NSNick ($CX($NSNickLower))"
        rawx "NOTICE $NSNick :$NS(autochan)"

      #-----
      # sinon, s'il est suspendu
      #-----
      } elseif { [NS:test:suspend $NSNick] } {
        putloglev 3 * "\[NickServ\] (5Suspended) $NSNick ($CX($NSNickLower))"
 
      #-----
      # sinon... on lui accorde X sec pour changer de pseudo
      #-----
      } else {
        putloglev 3 * "\[NickServ\] (7Check) $NSNick ($CX($NSNickLower)) ([getuser $NSNick COMMENT])"

        lappend stringnotice $NSNickLower 

        NS:modif:status $NSNick 2
        NS:killutimer $NSNick
        utimer $NS(temps) "NS:CheckWho [split $NSNickLower]"

        incr j
      }
    }

    #-----
    # si on a trouvé 20 nicks à qui envoyer la notice de changement de nick
    #-----
    if { $j >= 19 } {
      set stringnotice [join $stringnotice]
      putloglev 8 * "(DEBUG) \002NOTICE\002 [join [split $stringnotice] ,] :$NS(check)"
      rawx "NOTICE [join [split $stringnotice] ,] :$NS(check)"
      set stringnotice ""
      set j 0
    }

    incr i
  }

  #-----
  # s'il reste des nicks à qui faut envoyer la notice
  #-----
  if { $stringnotice != "" } {
    set stringnotice [join $stringnotice]
    putloglev 8 * "(DEBUG) \002NOTICE\002 [join [split $stringnotice] ,] :$NS(check)"
    rawx "NOTICE [join [split $stringnotice] ,] :$NS(check)"
  }

  return 0
}



######################
# Fin du tps de CTRL #
######################

proc NS:CheckWho { NSCheckNick } {
  global NS CX NSAuth NSChk

  set NSCheckNickLower [string tolower $NSCheckNick]
  NS:givehost $NSCheckNick

  #-----
  # on ne démarre que si le pseudo est à protéger!
  #-----
  if { ![NS:validuser $NSCheckNick] } {
    putloglev 3 * "\[NickServ\] (14Bug) $NSCheckNickLower ($CX($NSCheckNickLower)) -> Ctrl sur un nick inexistant!"

  } elseif { [NS:var:status $NSCheckNick] == 2 } {
      NS:modif:status $NSCheckNick 3
      set NSCheckNickModif [string range $NSCheckNick 0 26][expr [rand 899]+100]
      putloglev 3 * "\[NickServ\] (4SvNick) $NSCheckNick -> $NSCheckNickModif ($CX($NSCheckNickLower))"
      rawx "NICK $NSCheckNick $NSCheckNickModif"
      set NSChk([string tolower $NSCheckNick]) 1

  } elseif { [NS:var:status $NSCheckNick] == 1 } {
    putloglev 3 * "\[NickServ\] (12Quit) $NSCheckNick ($CX($NSCheckNickLower))"

  } else {
    putloglev 3 * "\[NickServ\] (12Quit) $NSCheckNick ($CX($NSCheckNickLower))"
  }

}



######################
# Commande: IDENTIFY #
######################
#
# IDENTIFY <login> <pass>
# AUTH <login> <pass>
#

bind msg - identify NS:identify
bind msg - auth NS:identify

proc NS:identify { nick uhost handle arg } {
  global NS CX NSAuth NSChk

  #-----
  # si le NickServ est actif, on autorise le IDENTIFY et le AUTH
  #-----
  if { $NS(exe) && $NS(start) } {

    set arg [split $arg]

    set nicklower [string tolower $nick]
    set templogin [lindex $arg 0]
    set temploginlw [string tolower [lindex $arg 0]]
    set temppass [lindex $arg 1]

    NS:givehost $nick

    #-----
    # si ya un pb de syntaxe
    #-----
    if { $temppass == "" } {
#      putloglev 3 * "\[NickServ\] (5Wrong Syntaxe) $nick ($CX($nicklower)) IDENTIFY..."
#      rawx "NOTICE $nick :$NS(identifysyntaxe)"

    #-----
    # sinon, on teste sur le Login entré est valide ou pas
    #-----
    } elseif { ![NS:validuser $templogin] } {
      putloglev 3 * "\[NickServ\] (5No Access) $nick ($CX($nicklower)) IDENTIFY..."

    #-----
    # sinon, on teste voir si la personne est déjà authé ou pas
    #-----
    } elseif { [NS:isauth $nick] } {
      putloglev 3 * "\[NickServ\] (10Already Authed) $nick ($CX($nicklower)) IDENTIFY..."
      rawx "NOTICE $nick :$NS(authed)"

    #-----
    # sinon, on teste si le pass est valide
    #-----
    } elseif { ![passwdok $templogin $temppass] } {
      putloglev 3 * "\[NickServ\] (4Wrong Pass) $nick ($CX($nicklower)) IDENTIFY..."
      rawx "NOTICE $nick :$NS(wrongpass1) $nick $NS(wrongpass2)"

    #-----
    # sinon, on accepte le pass -> IDENTIFY ok!
    #-----
    } else {
      NS:modif:status $templogin 1
      putloglev 3 * "\[NickServ\] (3Auth) $nick ($CX($nicklower)) IDENTIFY $templogin..."
      NS:killutimer $templogin

      setuser $templogin XTRA LOGIN $nick
      setuser $templogin LASTON [unixtime] Auth
      set NSAuth([string tolower $nick]) $templogin

      rawx "NOTICE $nick :$NS(accepted) $nick. $NS(accepted2)"

    }
  }

  return 0
}


###################
# Commande: GHOST #
###################
#
# GHOST <login> <pass>
#

bind msg - ghost NS:ghost

proc NS:ghost { nick uhost handle arg } {
  global NS NSChainNick NSListeNick CX NSAuth

  #-----
  # si le NickServ est actif, on autorise le GHOST
  #-----
  if { $NS(exe) && $NS(start) } {

    set arg [split $arg]

    set nicklower [string tolower $nick]
    set templogin [lindex $arg 0]
    set temploginlw [string tolower [lindex $arg 0]]
    set temppass [lindex $arg 1]

    NS:givehost $nick

    #-----
    # si ya un pb de syntaxe
    #-----
    if { $temppass == "" } {
      putloglev 3 * "\[NickServ\] (5wrong syntaxe) $nick ($CX($nicklower)) GHOST..."
#      rawx "NOTICE $nick :$NS(ghostsyntaxe)"

    #-----
    # sinon, on teste sur le Login entré est valide ou pas
    #-----
    } elseif { ![NS:validuser $templogin] } {
      putloglev 3 * "\[NickServ\] (5No Access) $nick ($CX($nicklower)) GHOST..."

    #-----
    # sinon, on teste si le pass est valide
    #-----
    } elseif { ![passwdok $templogin $temppass] } {
      putloglev 3 * "\[NickServ\] (4Wrong Pass) $nick ($CX($nicklower)) GHOST..."
      rawx "NOTICE $nick :$NS(wrongpass1) $nick $NS(wrongpass2)"

    #-----
    # sinon, on accepte le pass -> GHOST ok!
    #-----
    } else {
      putloglev 3 * "\[NickServ\] (3Ghost) $nick ($CX($nicklower)) GHOST $templogin..."
      rawx "NOTICE $nick :$NS(accepted) $nick. $NS(accepted2)"
      NS:killutimer $nick

      set temp [getuser $templogin XTRA LOGIN]

      if { [info exists NSAuth([string tolower $temp])] } { unset NSAuth([string tolower $temp]) }
      setuser $templogin XTRA LOGIN ""

      rawx "NOTICE $nick :$NS(ghostdone)"
      raw "ISON $arg1"

    }
  }

  return 0
}



######################
# Commande: PASSWORD #
######################
#
# PASSWORD <login> <ancien pass> <nouveau pass>
#

bind msg - password NS:password

proc NS:password { nick uhost handle arg } {
  global NS NSChainNick NSListeNick CX NSAuth

  #-----
  # si le NickServ est actif, on autorise le GHOST
  #-----
  if { $NS(exe) && $NS(start) } {
    set arg [split $arg]

    set nicklower [string tolower $nick]
    set templogin [lindex $arg 0]
    set temppass [lindex $arg 1]
    set tempnewpass [lindex $arg 2]

    NS:givehost $nick

    #-----
    # si le nick n'est pas authé
    #-----
    if { ![NS:isauth $nick] } {
      putloglev 3 * "\[NickServ\] (5not authed) $nick ($CX($nicklower)) PASSWORD..."

    #-----
    # sinon, si la syntaxe n'est pas bonne
    #-----
    } elseif { $tempnewpass == "" } {
      putloglev 3 * "\[NickServ\] (5wrong syntaxe) $nick ($CX($nicklower)) PASSWORD..."
      rawx "NOTICE $nick :$NS(passwordsyntaxe)"

    #-----
    # sinon, si nick demande une modif de pass pour un autre login
    #-----
    } elseif { ![string match $templogin [getuser $templogin XTRA LOGIN]] } {
      putloglev 3 * "\[NickServ\] (5wrong Login) $nick ($CX($nicklower)) PASSWORD..."

    #-----
    # sinon, si le pass n'est pas bon
    #-----
    } elseif { ![passwdok $templogin $temppass] } {


    #-----
    # sinon, on change le pass
    #-----
    } else {
      putloglev 3 * "\[NickServ\] (3Pass Changed) $nick ($CX($nicklower)) PASSWORD..."
      setuser $templogin PASS $tempnewpass
      setuser $templogin LASTON [unixtime] auth
      rawx "NOTICE $nick :$NS(passchanged)"

    }
  }

  return 0
}



##################
# Commande: HELP #
##################
#
# HELP
#

bind msg - help NS:help

proc NS:help { nick uhost handle arg } {
  global NS NSChainNick NSListeNick CX

  #-----
  # si le NickServ est actif, on autorise le GHOST
  #-----
  if { $NS(exe) && $NS(start) } {

    set nicklower [string tolower $nick]

    NS:givehost $nick

    #-----
    # si nick n'est pas auth
    #-----
    if { ![NS:isauth $nick] } {
      putloglev 3 * "\[NickServ\] (5Not Authed) $nick ($CX($nicklower)) HELP..."

    #-----
    # sinon.. il est auth, donc on affiche l'aide :)
    #-----
    } else {
        putloglev 3 * "\[NickServ\] (3Help) $nick ($CX($nicklower)) !$NSAuth($nick)! HELP..."
        rawx "NOTICE $nick :$NS(help)"
    }
  }

  return 0
}



#######################
# Diverses procédures #
#######################

proc NS:killutimer { nick } {
    global NS NSChainNick NSListeNick

    set nicklower [string tolower $nick]
    foreach t [utimers] {
        if {[join [lindex $t 1]] == "NS:CheckWho $nicklower"} {
            killutimer [lindex $t 2]
        }
    }
}


#
# permet de savoir si c un nick dont le pseudo est à protéger
#
proc NS:validuser { nick } {
  if { ![validuser $nick] } {
    return 0
  } elseif { ![matchattr $nick +R] } {
    return 0
  } else {
    return 1
  }
}

#
# permet de savoir si c un nick est suspendu ou pas
#
proc NS:test:suspend { nick } {
  if { ![validuser $nick] } {
    return 0
  } elseif { ![matchattr $nick +S] } {
    return 0
  } else {
    return 1
  }
}

proc NS:validauth { nick } {
  global NSAuth
  return [info exists NSAuth([string tolower $nick])]
}

proc NS:changeauth { nick1 nick2 } {
  global NSAuth

  set nick1 [string tolower $nick1]
  
  if { [info exist NSAuth($nick1)] } {
    set hand $NSAuth($nick1)
    unset NSAuth($nick1)

    setuser $hand XTRA LOGIN $nick2
    set NSAuth([string tolower $nick2]) $hand  
  }
  return
}

proc NS:givehost { nick } {
  global CX

  set nicklw [string tolower $nick]
  if { ![info exists CX($nicklw)] } {
    set CX($nicklw) "user@host"
  }
}

proc NS:isauth { nick } {
  global NSAuth

  set nicklw [string tolower $nick]
  if { [info exists NSAuth($nicklw)] } {
    return 1
  } else {
    return 0
  }
}

proc NS:modif:status { nick var } {
    global NS NSChk

    set nicklw [string tolower $nick]
    if { [NS:validuser $nick] } { set NSChk($nicklw) $var }
    return
}

proc NS:var:status { nick } {
  global NSChk
  if { [info exist NSChk([string tolower $nick])] } {
    return $NSChk([string tolower $nick])
  } else {
    return 0
  }
}