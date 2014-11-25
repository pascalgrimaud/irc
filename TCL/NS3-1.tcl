#
# NS3-1.tcl (v3.1) par Ibu <ibu_lordaeron@yahoo.fr>
#
# Ce script sert de NickServ.
#
# Modification relative à la (v3.0):
# - gestion des Users via la database des Users et non des fichiers
# - flag +R = nick réservé
#
# Modification relative à la (v2.1):
# - system complètement revu... travaillant directement les connexions reçues
#   Il y a donc 2 possibilités:
#     1) recevoir les connexions via le flag +c lorsque l'egg est authé IRCop
#        il faut donc une botnet avec un bot authé ircop sur chaque serveur de l'IRC
#     2) recevoir les connexions via un OperServ (sur Entrechat -> Eva/Geofront)
# - system de demande d'Auth avec vérification des pass (cryptés)
# - flag +N (à la place du +S...)
#
# Modification relative à la (v2.0):
# - flag +S : utiliser les commandes propres au NickServ
# - débug le UserHost, uniquement pris en compte lors du scan NickServ
#
# Modification relative à la (v1.21):
# - utilisation du USERHOST à la place d'une succession de /WHO
#   Scan par liste de 5 nicks - Résultats récupérés via le raw 302
#   Avantages
#    - bcp + de nicks protégés
#    - gain de tps considérables
#   Inconvénients
#    - l'utilisation d'un ISON aurait été mieux (bcp + de nick), mais on aurait pas eu le host
#      ou bien sinon.. utiliser le ISON avec un système de demande d'autorisation comme un ChanServ... à méditer
# - remplacement du KILL par un changement de nick
#
# Modification relative à la (v1.2):
# - modification de la console +3, une ligne pour chaque nick
# - optimisation des returns ds les diverses procédures
#
# Modification relative à la (v1.1):
#  - ajout/retrait possibles des Nicks, Scans, Hosts protégés via la PL
#  - liste de chans protecteurs
#


#################
# Configuration #
#################

# nick de l'egg
set NS(mynick) "NickServ"

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
set NS(check) "\[Info\] Ce pseudo appartient à une autre personne. Merci de bien vouloir en choisir un autre en tapant /nick <pseudo>. Si c'est votre nick, tapez: /msg NickServ IDENTIFY <password>"
set NS(inforestart) "\[Info: restart du NickServ\]"
set NS(autoauth) "Votre host correspond aux hosts protégés. Vous êtes autorisé à utiliser ce pseudo."
set NS(autochan) "Vous êtes sur un salon protégé. Vous êtes autorisé à utiliser ce pseudo."
set NS(authed) "Vous êtes déjà authentifié."
set NS(accepted) "Password accepté pour"
set NS(accepted2) "Tapez: /msg NickServ HELP pour voir la liste des commandes disponibles."
set NS(wrongpass1) "Le pass entré pour"
set NS(wrongpass2) "est incorrect."
set NS(mustauthed) "Vous devez être authentifié. Tapez: /msg NickServ IDENTIFY <password>"
set NS(drop) "a été effacé!"
set NS(passoldwrong) "Votre ancien pass est incorrect."
set NS(passnewwrong) "Votre nouveau pass doit contenir + de 6 lettres/chiffres."
set NS(passchanged) "Password changé..."
set NS(ghostdone) "Demande de \002Ghost\002 en cours..."

set NS(help01) "Liste des commandes: ( /msg NickServ HELP <commande> pour en savoir davantage)"
set NS(help02) " \002IDENTIFY\002 - \002AUTH\002 - \002PASSWORD\002 - \002DROP\002 - \002GHOST\002 - \002VERSION\002"

set NS(syntaxeidentify) "Syntaxe: IDENTIFY <password>"
set NS(usageidentify) "Usage: permet de s'authentifier auprès du NickServ (même fonction que AUTH)."
set NS(syntaxeauth) "Syntaxe: AUTH <password>"
set NS(usageauth) "Usage: permet de s'authentifier auprès du NickServ (même fonction que IDENTIFY)."
set NS(syntaxepassword) "Syntaxe: PASSWORD <ancien pass> <nouveau pass> <nouveau pass>"
set NS(usagepassword) "Usage: permet de changer son password."
set NS(syntaxedrop) "Syntaxe: DROP <password> 4- Non Dispo -"
set NS(usagedrop) "Usage: permet de s'effacer du NickServ (attention, cette commande est irréversible)."
set NS(syntaxeghost) "Syntaxe: GHOST <login> <password>"
set NS(usageghost) "Usage: demande au NickServ de forcer l'authentification sur une personne (utile quand on a un Ghost qui traine sur le serveur)"
set NS(syntaxeversion) "Syntaxe: VERSION"
set NS(usageversion) "Usage: affiche la version du NickServ"
set NS(version1) "\002Nickname Service\002 v3.1"
set NS(version2) "Entrechat Network - \002Ibu\002 <ibu_lordaeron@yahoo.fr>"
set NS(ns) "\[NS\]"



########
# Motd #
########

putlog "\002NS3-1.tcl\002 - Nickname Service"
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

  foreach t [utimers] {
    if { [string match *NS:massinit* [lindex $t 1]] } {
      killutimer [lindex $t 2]
    }
  }
  NS:massinit
  putlog "[b]Nickname Service will start...[b]"

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
    global NS botnick NSChk

    set NSChk(@debug) 0
    unset NSChk

    foreach i [userlist +R] {
        set NSChk([string tolower $i]) 0
    }

    NS:host:initchain
    NS:chan:initchain

    foreach t [utimers] {
       if { [string match *NS:CheckWho* [lindex $t 1]] } {
           killutimer [lindex $t 2]
       }
    }

    putquick "MODE $botnick"
}



########
# Aide #
########
bind dcc -|- ns NS:dcc:help

proc NS:dcc:help { hand idx arg } {
    global NS botnick

    putdcc $idx " "
    putdcc $idx "     NS3-1.tcl (v3.1) - Aide     "
    putdcc $idx " "
    putdcc $idx " Flag +N = pour utiliser le NickServ"
    putdcc $idx " Flag +R = nick réservé"
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
    putdcc $idx "  .+nsnick <nick> <pass> <nick!user@host> <email> <info> 14(ajoute un pseudo à protéger)"
    putdcc $idx "  .-nsnick <nick> 14(retire un pseudo)"
    putdcc $idx "  .nsnick <string> 14(lister la liste des pseudos protégés)"
    putdcc $idx "  .<+/->nsprotect <nick> 14(protège/déprotège un pseudo)"
    putdcc $idx "  .nshandle <ancien nick> <nouveau nick> 14(change le nick d'un utilisateur)"
    putdcc $idx "  .nspass <nick> <nouveau pass> 14(change le pass d'un utilisateur)"
    putdcc $idx "  .nsinfo <string> 14(lister les infos des nicks protégés)"
    putdcc $idx "  .nsauth 14(lister les nicks authés)"
    putdcc $idx "  .\[+/-\]nshost \[user@host\] 14(ajouter/retirer/lister un user@host protégé)"
    putdcc $idx "  .\[+/-\]nschan \[#channel\] 14(ajouter/retirer/lister un channel protégé)"
    putdcc $idx "  .nswallops <message> 14(envoie un message à tous ceux authés)"
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
    if { [matchattr $tempnick R] } {
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
    chattr $tempnick -hp+R
    save

    set NSChk([string tolower $tempnick]) 0

    if { $NS(exe) && $NS(start) } {
      bind raw - "303" CheckIsOn
      raw "ISON $tempnick"
    }
    set i $tempnick
    putdcc $idx "Ajout: \002$i\002 <[getuser $i XTRA EMAIL]> - [u]Last Auth[u]: [ctime [lindex [split [getuser $i LASTON]] 0]] - [u]Info[u]: [getuser $i COMMENT]"
    putlog "#$hand# +nsnick $tempnick \[something\]"
  }

  return 0
}



###################
# Retirer un Nick #
###################
bind dcc N|- -nsnick NS:nick:del

proc NS:nick:del { hand idx arg } {
  global NS NSChk

  set arg [lindex [split $arg] 0]
  set arglw [string tolower $arg]

  if { $arg == "" } {
    putdcc $idx "\002Syntaxe\002: .-nsnick <nick>"

  } elseif { ![validuser $arg] } {
    putdcc $idx "Nick invalide!"

  } elseif { [matchattr $arg +p] } {
    putdcc $idx "Vous ne pouvez pas retirer un utilisateur de la partyline."

  } elseif { ![matchattr $arg +R] } {
    putdcc $idx "Cet utilisateur n'est pas un nick protégé ou bien est suspendu."

  } else {
    if { [info exist NSChk($arglw)] } { unset NSChk($arglw) }
    deluser $arg
    NS:killutimer $arg
    putdcc $idx "Done."

    putlog "#$hand# -nsnick $arg"
  }

  return 0
}


##############
# +nsprotect #
##############
bind dcc N|- +nsprotect NS:nick:addprotect

proc NS:nick:addprotect { hand idx arg } {
  global NS NSChk

  set arg [lindex [split $arg] 0]
  set arglw [string tolower $arg]

  if { $arg == "" } {
    putdcc $idx "\002Syntaxe\002: .+nsprotect <nick>"
    return 0

  } elseif { ![validuser $arg] } {
    putdcc $idx "Nick invalide!"
    return 0

  } elseif { [matchattr $arg +R] } {
    putdcc $idx "Cet utilisateur est déjà protégé."
    return 0

  } elseif { ![matchattr $hand +n] && [matchattr $arg +p] && $arglw != [string tolower $hand] } {
    putdcc $idx "Vous ne pouvez pas protéger le pseudo d'un utilisateur de la partyline."
    return 0

  } else {
    chattr $arg +R
    putdcc $idx "Done."

    set NSChk($arglw) 0
    if { $NS(exe) && $NS(start) } {
      bind raw - "303" CheckIsOn
      raw "ISON $arg"
    }

    return 1
  }
}



##############
# -nsprotect #
##############
bind dcc N|- -nsprotect NS:nick:delprotect

proc NS:nick:delprotect { hand idx arg } {
  global NS NSChk

  set arg [lindex [split $arg] 0]
  set arglw [string tolower $arg]

  if { $arg == "" } {
    putdcc $idx "\002Syntaxe\002: .-nsprotect <nick>"
    return 0

  } elseif { ![validuser $arg] } {
    putdcc $idx "Nick invalide!"
    return 0

  } elseif { ![matchattr $arg +R] } {
    putdcc $idx "Cet utilisateur n'est pas protégé."
    return 0

  } elseif { ![matchattr $hand +n] && [matchattr $arg +p] && $arglw != [string tolower $hand] } {
    putdcc $idx "Vous ne pouvez pas déprotéger le pseudo d'un utilisateur de la partyline."
    return 0

  } else {
    if { [info exist NSChk($arglw)] } { unset NSChk($arglw) }
    chattr $arg -R
    putdcc $idx "Done."

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
            putdcc $idx "\002$i\002 <[getuser $i XTRA EMAIL]> - [u]Last Auth[u]: [ctime [lindex [split [getuser $i LASTON]] 0]] - [u]Info[u]: [getuser $i COMMENT]"
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
          if { [string match "[string tolower [join $arg]]" "[string tolower [getuser $i COMMENT]]"] } {
            incr compte
            putdcc $idx "\002$i\002 <[getuser $i XTRA EMAIL]> - [u]Last Auth[u]: [ctime [lindex [split [getuser $i LASTON]] 0]] - [u]Info[u]: [getuser $i COMMENT]"
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
    global NS NSChk

    set arg [split $arg]
    set compte 0

    putdcc $idx "\002-- Liste des Nicks authés\002:"

    foreach i [userlist +R] {
      if { $NSChk([string tolower $i]) == 1 } {
        incr compte
        putdcc $idx "\002$i\002 <[getuser $i XTRA EMAIL]> - [u]Last Auth[u]: [ctime [lindex [split [getuser $i LASTON]] 0]] - [u]Info[u]: [getuser $i COMMENT]"
      }
    }
    putdcc $idx " "
    putdcc $idx "\002-- Nombre\002: $compte"
    putdcc $idx " "
    return 1
}




###################
# Changer le Nick #
###################
bind dcc N|- nshandle NS:nick:handle

proc NS:nick:handle { hand idx text } {
  global NS NSChk

  set arg [lindex [split $text] 0]
  set arglw [string tolower $arg]
  set argnew [lindex [split $text] 1]
  set argnewlw [string tolower $argnew]

  if { $arg == "" } {
    putdcc $idx "\002Syntaxe\002: .nshandle <ancien nick> <nouveau nick>"
    return 0

  } elseif { ![validuser $arg] } {
    putdcc $idx "Nick invalide!"
    return 0

  } elseif { [validuser $argnew] } {
    putdcc $idx "Nouveau nick déjà existant!"
    return 0

  } elseif { ![matchattr $arg +R] } {
    putdcc $idx "Cet utilisateur n'est pas protégé."
    return 0

  } elseif { ![matchattr $hand +n] && [matchattr $arg +p] && $arglw != [string tolower $hand] } {
    putdcc $idx "Vous ne pouvez pas changer le pseudo d'un utilisateur de la partyline."
    return 0

  } else {
    chhandle $arg $argnew
    putdcc $idx "Done."
    putlog "#$hand# nshandle $arg $argnew"

    if { [info exist NSChk($arglw)] } { unset NSChk($arglw) }
    set NSChk($argnewlw) 0
    if { $NS(exe) && $NS(start) } {
      bind raw - "303" CheckIsOn
      raw "ISON $argnew"
    }

  }
}



###################
# Changer le Pass #
###################
bind dcc N|- nspass NS:nick:pass

proc NS:nick:pass { hand idx text } {
  global NS NSChk

  set arg [lindex [split $text] 0]
  set arglw [string tolower $arg]
  set argpass [lindex [split $text] 1]

  if { $arg == "" } {
    putdcc $idx "\002Syntaxe\002: .nspass <nick> <nouveau pass>"
    return 0

  } elseif { ![validuser $arg] } {
    putdcc $idx "Nick invalide!"
    return 0

  } elseif { ![matchattr $arg +R] } {
    putdcc $idx "Cet utilisateur n'est pas protégé."
    return 0

  } elseif { [string length $argpass] < 6 } {
    putdcc $idx "Le pass doit contenir 6 caractères ou plus."
    return 0

  } elseif { ![matchattr $hand +n] && [matchattr $arg +p] && $arglw != [string tolower $hand] } {
    putdcc $idx "Vous ne pouvez pas changer le pass d'un utilisateur de la partyline."
    return 0

  } else {
    setuser $arg PASS $argpass
    putdcc $idx "Done."
    putlog "#$hand# nspass $arg \[something\]"

  }
}



###################
# Ajouter un Host #
###################
bind dcc N|- +nshost NS:host:add

proc NS:host:add { hand idx arg } {
    global NS NSChainHost

    set arg [lindex [split $arg] 0]

    if { $arg != "" && [string match *@* $arg] } {

        if { [file:addid $NS(filehost) "$arg"] == 1 } {
            putdcc $idx "$arg existe déjà!"
        } else {
            NS:host:initchain
            putlog "#$hand# +nshost $arg"
        }

    } else {
        putdcc $idx "\002Syntaxe\002: .+nshost <user@host>"
    }
    return 0
}



###################
# Retirer un Host #
###################
bind dcc N|- -nshost NS:host:del

proc NS:host:del { hand idx arg } {
    global NS NSChainHost

    set arg [lindex [split $arg] 0]

    if { $arg != "" } {
        if { [file:rem $NS(filehost) $arg] == 1 } {
            NS:host:initchain
            putlog "#$hand# -nshost $arg"
        } else {
            putdcc $idx "$arg n'existe pas!"
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-nshost <user@host>"
    }
    return 0
}



###################
# Liste les Hosts #
###################
bind dcc N|- nshost NS:host:list

proc NS:host:list { hand idx arg } {
    global NS NSChainHost

    putdcc $idx "\002-- Liste des Hosts protégés\002:"
    putdcc $idx "$NSChainHost"
    putdcc $idx " "
    return 1
}



##################
# Test des Hosts #
##################
proc NS:test:host { host } {
    global NS NSChainHost

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
    global NS NSChainChan

    set arg [lindex [split $arg] 0]

    if { $arg != "" && [string index $arg 0] == "#" } {
        if { [validchan $arg] } {
            if { [file:addid $NS(filechan) "$arg"] == 1 } {
                putdcc $idx "$arg existe déjà!"
            } else {
                NS:chan:initchain
                putlog "#$hand# +nschan $arg"
            }
            return 0
        } else {
            putdcc $idx "$arg n'est pas un salon valide!"
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
    global NS NSChainChan

    set arg [lindex [split $arg] 0]

    if { $arg != "" && [string index $arg 0] == "#" } {
        if { [file:rem $NS(filechan) $arg] == 1 } {
            putlog "#$hand# -nschan $arg"
            NS:chan:initchain
        } else {
            putdcc $idx "\002\[NS: Del Chans\]\002 ::: $arg n'existe pas!"
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-nschan <#channel>"
    }
    return 0
}



###################
# Liste les Chans #
###################
bind dcc N|- nschan NS:chan:list

proc NS:chan:list { hand idx arg } {
    global NS NSChainChan

    putdcc $idx "\002-- Liste des Chans protégés\002:"
    putdcc $idx "$NSChainChan"
    putdcc $idx " "
    return 1
}



##############################
# Test de Protection de Chan #
##############################
proc NS:test:chan { nick } {
    global NS NSChainChan

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



#############
# nswallops #
#############
bind dcc N|- nswallops NS:dcc:wallops

proc NS:dcc:wallops { hand idx arg } {
  global NS NSChk botnick

  if { $arg == "" } {
    syntaxe $idx ".nswallops <message>"
    return 0
  } else {

    set stringnotice ""
    foreach i [userlist +R] {
      if { $NSChk([string tolower $i]) == 1 } {
        lappend stringnotice $i
      }
      if { [llength [join $stringnotice]] >= 19 } {
        set stringnotice [join $stringnotice]
        putloglev 8 * "(DEBUG) \002NOTICE\002 [join [split $stringnotice] ,] :<\002$hand\002@\002$botnick\002> $arg"
        raw "NOTICE [join [split $stringnotice] ,] :<\002$hand\002@\002$botnick\002> $arg"
        set stringnotice ""
      }
    }

    if { $stringnotice != "" } {
      set stringnotice [join $stringnotice]
      putloglev 8 * "(DEBUG) \002NOTICE\002 [join [split $stringnotice] ,] :<\002$hand\002@\002$botnick\002> $arg"
      raw "NOTICE [join [split $stringnotice] ,] :<\002$hand\002@\002$botnick\002> $arg"
    }

    return 1
  }
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
    putlog "$NS(ns) Non démarré... (config)"

  } elseif { $botlinkpresent == 0 } {
    putlog "$NS(ns) Non démarré... (bot de Link non trouvé --> $NS(botlink))"

  } elseif { ![string match *o* [lindex $text 1]] || ![string match *a* [lindex $text 1]] } {
    putlog "$NS(ns) Non démarré... (non IRCop lev2)"

  } else {
    set NS(start) 1
    putlog "[b]Starting Nickname Service...[b]"

    set arg [userlist +R]
    set i 0
    set NS(mustbechk) ""

    bind raw - "303" CheckMassIsOn

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
    putloglev 8 * "(DEBUG) \002ISON\002 $NS(mynick)"
    raw "ISON $NS(mynick)"
  }

  return 0
}

proc CheckIsOn { from key text } {
    global botnick NS NSChk

    set text [split $text]
    set text1 [string range [join [lrange $text 1 end]] 1 end]

    putloglev 8 * "(DEBUG) \002Résultat ISON\002: [join $text1]"

    set arg [lindex [split $text1] 0]

    unbind raw - "303" CheckIsOn
    if { $arg != "" } { NS:check $arg }
    
    return 0
}

proc CheckMassIsOn { from key text } {
    global botnick NS NSChk

    set text [split $text]
    set text1 [string range [join [lrange $text 1 end]] 1 end]

    putloglev 8 * "(DEBUG) \002Résultat ISON\002: [join $text1]"

    if { [string match [string tolower $botnick] [string tolower [join $text1]]] } {
      unbind raw - "303" CheckMassIsOn
      set NS(mustbechk) [join $NS(mustbechk)]
      if { $NS(mustbechk) != "" } { NS:masscheck [join $NS(mustbechk)] }
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
        putlog "$NS(ns) Connexion avec $NS(botlink)..."
        NS:massinit
        putserv "MODE $botnick"
    }
    return
}


bind disc -|- * NS:BotUnLink

proc NS:BotUnLink { botname } {
    global NS botnick
    if { [string tolower $botname] == [string tolower $NS(botlink)] } {
        putlog "$NS(ns) Deconnexion avec $NS(botlink)..."
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
  global NS CX NSChk

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
      if { [NS:var:status $arg1] == 1 } {
        putloglev 3 * "$NS(ns) (12Quit/Deauth) $arg1 $CX($arg1lower)"
      } else {
        putloglev 3 * "$NS(ns) (12Quit/Unchk) $arg1 $CX($arg1lower)"
      }
      NS:killutimer $arg1
      NS:modif:status $arg1 0
    }
  }

  unset CX($arg1lower)

  return
}


bind bot - CX:kill NSConnexion:kill

proc NSConnexion:kill {bot cmd arg} {
  global NS CX NSChk

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
      NS:killutimer $arg1
      NS:modif:status $arg1 0
      putloglev 3 * "$NS(ns) (8Kill) $arg1 $CX($arg1lower)"
    }
  }
  unset CX($arg1lower)

  return
}


bind bot - CX:nick NSConnexion:nick

proc NSConnexion:nick {bot cmd arg} {
  global NS CX NSChk

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
    if { $arg1lower == $arg2lower } {

    #-----
    # si le nouveau nick n'est pas un pseudo à protéger
    #-----
    } else {
      if { [NS:var:status $arg1] > 0 } {
        if { [NS:var:status $arg1] != 3 } {
          putloglev 3 * "$NS(ns) (2ChNick) $arg1 -> $arg2 ($CX($arg2lower))"
        } else {
          putloglev 3 * "$NS(ns) (4SvNick) $arg1 -> $arg2 ($CX($arg2lower))"
        }
        NS:modif:status $arg1 0
        NS:killutimer $arg1
      }
      NS:check $arg2
    }
  }

  return 0
}



####################
# Ctrl d'un pseudo #
####################

proc NS:check { NSNick } {
  global NS CX NSChk

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
    # si le NSChk est à 1, c qu'il est déjà authé
    #-----
    if { $NSChk($NSNickLower) == 1 } {
        putloglev 3 * "$NS(ns) (10Already authed) $NSNick ($CX($NSNickLower))"

    #-----
    # sinon, s'il possède un host protégé
    #-----
    } elseif { [NS:test:host $CX($NSNickLower)] } {
      NS:modif:status $NSNick 1
      NS:killutimer $NSNick

      putloglev 3 * "$NS(ns) (10Auth by host) $NSNick ($CX($NSNickLower))"
      raw "NOTICE $NSNick :$NS(autoauth)"

    #-----
    # sinon, s'il est sur un chan autorisé
    #-----
    } elseif { [NS:test:chan $NSNick] } {
      NS:modif:status $NSNick 1
      NS:killutimer $NSNick

      putloglev 3 * "$NS(ns) (10Auth by chan) $NSNick ($CX($NSNickLower))"
      raw "NOTICE $NSNick :$NS(autochan)"

    #-----
    # sinon... on lui accorde X sec pour changer de pseudo
    #-----
    } else {
      putloglev 3 * "$NS(ns) (7Check) $NSNick ($CX($NSNickLower)) ([getuser $NSNick COMMENT])"
      raw "NOTICE $NSNick :$NS(check)"

      NS:modif:status $NSNick 2
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
  global NS CX NSChk

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
    NS:givehost $NSNick

    #-----
    # on ne démarre que si le pseudo est à protéger!
    #-----
    if { [NS:validuser $NSNick] } {

      #-----
      # si le NSChk est à 1, c qu'il est déjà authé
      #-----
      if { $NSChk($NSNickLower) == 1 } {
        putloglev 3 * "$NS(ns) (10Already authed) $NSNick ($CX($NSNickLower))"

      #-----
      # sinon, s'il possède un host protégé
      #-----
      } elseif { [NS:test:host $CX($NSNickLower)] } {
        NS:modif:status $NSNick 1
        NS:killutimer $NSNick

        putloglev 3 * "$NS(ns) (10Auth by host) $NSNick ($CX($NSNickLower))"
        raw "NOTICE $NSNick :$NS(inforestart) $NS(autoauth)"

      #-----
      # sinon, s'il est sur un chan autorisé
      #-----
      } elseif { [NS:test:chan $NSNick] } {
        NS:modif:status $NSNick 1
        NS:killutimer $NSNick

        putloglev 3 * "$NS(ns) (10Auth by chan) $NSNick ($CX($NSNickLower))"
        raw "NOTICE $NSNick :$NS(inforestart)$NS(autochan)"
 
      #-----
      # sinon... on lui accorde X sec pour changer de pseudo
      #-----
      } else {
        putloglev 3 * "$NS(ns) (7Check) $NSNick ($CX($NSNickLower)) ([getuser $NSNick COMMENT])"

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
      putloglev 8 * "(DEBUG) \002NOTICE\002 [join [split $stringnotice] ,] $NS(inforestart) $NS(check)"
      raw "NOTICE [join [split $stringnotice] ,] :$NS(inforestart) $NS(check)"
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
    putloglev 8 * "(DEBUG) \002NOTICE\002 [join [split $stringnotice] ,] :$NS(inforestart) $NS(check)"
    raw "NOTICE [join [split $stringnotice] ,] :$NS(inforestart) $NS(check)"
  }

  return 0
}



######################
# Fin du tps de CTRL #
######################

proc NS:CheckWho { NSCheckNick } {
  global NS CX NSChk

  set NSCheckNickLower [string tolower $NSCheckNick]
  NS:givehost $NSCheckNick

  #-----
  # on ne démarre que si le pseudo est à protéger!
  #-----
  if { ![NS:validuser $NSCheckNick] } {
    putloglev 3 * "$NS(ns) (14Bug) $NSCheckNickLower ($CX($NSCheckNickLower)) -> Ctrl sur un nick inexistant!"

  } elseif { [NS:var:status $NSCheckNick] == 2 } {
      NS:modif:status $NSCheckNick 3
      set NSCheckNickModif [string range $NSCheckNick 0 26][expr [rand 899]+100]
#      putloglev 3 * "$NS(ns) (4SvNick) $NSCheckNick -> $NSCheckNickModif ($CX($NSCheckNickLower))"
      raw "NICK $NSCheckNick $NSCheckNickModif"

  } elseif { [NS:var:status $NSCheckNick] == 1 } {
    putloglev 3 * "$NS(ns) (10Already authed) $NSCheckNick ($CX($NSCheckNickLower))"

  } else {
    putloglev 3 * "$NS(ns) (12Out) $NSCheckNick ($CX($NSCheckNickLower))"
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
  global NS CX NSChk

  #-----
  # si le NickServ est actif, on autorise le IDENTIFY et le AUTH
  #-----
  if { $NS(exe) && $NS(start) } {

    set arg [split $arg]

    set nicklower [string tolower $nick]
    set templogin $nick
    set temploginlw [string tolower $nick]
    set temppass [lindex $arg 0]

    NS:givehost $nick

    #-----
    # si ya un pb de syntaxe
    #-----
    if { $temppass == "" } {
#      putloglev 3 * "$NS(ns) (5Wrong syntaxe) $nick ($CX($nicklower)) IDENTIFY..."
#      raw "NOTICE $nick :$NS(syntaxeidentify)"

    #-----
    # sinon, on teste sur le Login entré est valide ou pas
    #-----
    } elseif { ![NS:validuser $templogin] } {
#      putloglev 3 * "$NS(ns) (5No access) $nick ($CX($nicklower)) IDENTIFY..."

    #-----
    # sinon, on teste voir si la personne est déjà authé ou pas
    #-----
    } elseif { [NS:isauth $nick] } {
      putloglev 3 * "$NS(ns) (10Already authed) $nick ($CX($nicklower)) IDENTIFY..."
      raw "NOTICE $nick :$NS(authed)"

    #-----
    # sinon, on teste si le pass est valide
    #-----
    } elseif { ![passwdok $templogin $temppass] } {
      putloglev 3 * "$NS(ns) (4Wrong pass) $nick ($CX($nicklower)) IDENTIFY..."
      raw "NOTICE $nick :$NS(wrongpass1) $nick $NS(wrongpass2)"

    #-----
    # sinon, on accepte le pass -> IDENTIFY ok!
    #-----
    } else {
      NS:modif:status $templogin 1
      NS:killutimer $templogin
      putloglev 3 * "$NS(ns) (3Auth) $nick ($CX($nicklower)) IDENTIFY..."

      setuser $templogin LASTON [unixtime] auth

      raw "NOTICE $nick :$NS(accepted) $nick. $NS(accepted2)"

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
  global NS CX NSChk

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
      putloglev 3 * "$NS(ns) (5wrong syntaxe) $nick ($CX($nicklower)) GHOST..."
#      raw "NOTICE $nick :$NS(syntaxeghost)"

    #-----
    # sinon, on teste sur le Login entré est valide ou pas
    #-----
    } elseif { ![NS:validuser $templogin] } {
      putloglev 3 * "$NS(ns) (5No access) $nick ($CX($nicklower)) GHOST $templogin..."

    #-----
    # sinon, on teste si le pass est valide
    #-----
    } elseif { ![passwdok $templogin $temppass] } {
      putloglev 3 * "$NS(ns) (4Wrong pass) $nick ($CX($nicklower)) GHOST $templogin..."
      raw "NOTICE $nick :$NS(wrongpass1) $templogin $NS(wrongpass2)"

    #-----
    # sinon, on accepte le pass -> GHOST ok!
    #-----
    } else {
      putloglev 3 * "$NS(ns) (3Ghost) $nick ($CX($nicklower)) GHOST $templogin..."
      raw "NOTICE $nick :$NS(ghostdone)"

      NS:killutimer $templogin
      set NSChk([string tolower $templogin]) 0
      bind raw - "303" CheckIsOn
      raw "ISON $templogin"

    }
  }

  return 0
}



######################
# Commande: PASSWORD #
######################
#
# PASSWORD <ancien pass> <nouveau pass> <nouveau pass>
#

bind msg - password NS:password

proc NS:password { nick uhost handle arg } {
  global NS CX

  #-----
  # si le NickServ est actif, on autorise le GHOST
  #-----
  if { $NS(exe) && $NS(start) } {
    set arg [split $arg]

    set nicklower [string tolower $nick]
    set templogin $nick
    set temploginlw [string tolower $nick]
    set temppass [lindex $arg 0]
    set tempnewpass [lindex $arg 1]
    set tempnewpass2 [lindex $arg 2]

    NS:givehost $nick

    #-----
    # si le nick n'est pas authé
    #-----
    if { ![NS:isauth $nick] } {
      putloglev 3 * "$NS(ns) (5Not authed) $nick ($CX($nicklower)) PASSWORD..."

    #-----
    # sinon, si la syntaxe n'est pas bonne
    #-----
    } elseif { $tempnewpass2 == "" } {
      putloglev 3 * "$NS(ns) (5wrong syntaxe) $nick ($CX($nicklower)) PASSWORD..."
      raw "NOTICE $nick :$NS(syntaxepassword)"
      raw "NOTICE $nick :$NS(usagepassword)"

    #-----
    # sinon, si le pass n'est pas bon
    #-----
    } elseif { ![passwdok $templogin $temppass] } {
      putloglev 3 * "$NS(ns) (4Wrong oldpass) $nick ($CX($nicklower)) PASSWORD..."
      raw "NOTICE $nick :$NS(passoldwrong)"

    #-----
    # sinon, si le nouveau pass est trop court
    #-----
    } elseif { [string length $tempnewpass] < 6 || $tempnewpass != $tempnewpass2 } {
      putloglev 3 * "$NS(ns) (4Wrong newpass) $nick ($CX($nicklower)) PASSWORD..."
      raw "NOTICE $nick :$NS(passnewwrong)"

    #-----
    # sinon, on change le pass
    #-----
    } else {
      putloglev 3 * "$NS(ns) (3Pass Changed) $nick ($CX($nicklower)) PASSWORD..."
      setuser $templogin PASS $tempnewpass
      setuser $templogin LASTON [unixtime] auth
      raw "NOTICE $nick :$NS(passchanged)"

    }
  }

  return 0
}



##################
# Commande: HELP #
##################
#
# HELP \[commande\]
#

bind msg - help NS:help

proc NS:help { nick uhost handle arg } {
  global NS CX

  #-----
  # si le NickServ est actif, on autorise le GHOST
  #-----
  if { $NS(exe) && $NS(start) } {

    set nicklower [string tolower $nick]
    set temp [string tolower [lindex [split $arg] 0]]

    NS:givehost $nick

    #-----
    # si nick n'est pas auth
    #-----
    if { ![NS:isauth $nick] } {
      putloglev 3 * "$NS(ns) (5Not Authed) $nick ($CX($nicklower)) HELP..."

    #-----
    # sinon.. il est auth, donc on affiche l'aide :)
    #-----
    } elseif { $temp == "" } {
        putloglev 3 * "$NS(ns) (3Help) $nick ($CX($nicklower)) HELP..."
        if { [info exist NS(help01)] } { raw "NOTICE $nick :$NS(help01)" }
        if { [info exist NS(help02)] } { raw "NOTICE $nick :$NS(help02)" }
        if { [info exist NS(help03)] } { raw "NOTICE $nick :$NS(help03)" }
        if { [info exist NS(help04)] } { raw "NOTICE $nick :$NS(help04)" }
        if { [info exist NS(help05)] } { raw "NOTICE $nick :$NS(help05)" }

    } elseif { [info exist NS(syntaxe$temp)] } {
        putloglev 3 * "$NS(ns) (3Help) $nick ($CX($nicklower)) HELP $temp..."
        raw "NOTICE $nick :$NS(syntaxe$temp)"
        raw "NOTICE $nick :$NS(usage$temp)"
    }
  }

  return 0
}



#####################
# Commande: VERSION #
#####################
#
# VERSION
#

bind msg - version NS:version

proc NS:version { nick uhost handle arg } {
  global NS CX

  #-----
  # si le NickServ est actif, on autorise le GHOST
  #-----
  if { $NS(exe) && $NS(start) } {

    set nicklower [string tolower $nick]
    set temp [string tolower [lindex [split $arg] 0]]

    NS:givehost $nick

    #-----
    # si nick n'est pas auth
    #-----
    if { ![NS:isauth $nick] } {
      putloglev 3 * "$NS(ns) (5Not Authed) $nick ($CX($nicklower)) VERSION..."

    #-----
    # sinon.. il est auth, donc on affiche l'aide :)
    #-----
    } else {
        putloglev 3 * "$NS(ns) (3Version) $nick ($CX($nicklower)) VERSION..."
        if { [info exist NS(version1)] } { raw "NOTICE $nick :$NS(version1)" }
        if { [info exist NS(version2)] } { raw "NOTICE $nick :$NS(version2)" }

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

proc NS:validuser { nick } {
  if { ![validuser $nick] } {
    return 0
  } elseif { ![matchattr $nick +R] } {
    return 0
  } else {
    return 1
  }
}


proc NS:givehost { nick } {
  global CX

  set nicklw [string tolower $nick]
  if { ![info exists CX($nicklw)] } {
    set CX($nicklw) "user@host"
  }
}

proc NS:isauth { nick } {
  global NSChk
  set nicklw [string tolower $nick]

  if { [info exists NSChk($nicklw)] } {
    if { $NSChk($nicklw) == 1 } {
      return 1
    } else {
      return 0
    }
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