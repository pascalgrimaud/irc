#
# NS3.tcl (v3.0) par Ibu <ibu_lordaeron@yahoo.fr>
#
# Ce script sert de NickServ.
#
# Modification relative � la (v2.1):
# - system compl�tement revu... travaillant directement les connexions re�ues
#   Il y a donc 2 possibilit�s:
#     1) recevoir les connexions via le flag +c lorsque l'egg est auth� IRCop
#        il faut donc une botnet avec un bot auth� ircop sur chaque serveur de l'IRC
#     2) recevoir les connexions via un OperServ (sur Entrechat -> Eva/Geofront)
# - system de demande d'Auth avec v�rification des pass (crypt�s)
# - flag +N (� la place du +S...)
#
# Modification relative � la (v2.0):
# - flag +S : utiliser les commandes propres au NickServ
# - d�bug le UserHost, uniquement pris en compte lors du scan NickServ
#
# Modification relative � la (v1.21):
# - utilisation du USERHOST � la place d'une succession de /WHO
#   Scan par liste de 5 nicks - R�sultats r�cup�r�s via le raw 302
#   Avantages
#    - bcp + de nicks prot�g�s
#    - gain de tps consid�rables
#   Inconv�nients
#    - l'utilisation d'un ISON aurait �t� mieux (bcp + de nick), mais on aurait pas eu le host
#      ou bien sinon.. utiliser le ISON avec un syst�me de demande d'autorisation comme un ChanServ... � m�diter
# - remplacement du KILL par un changement de nick
#
# Modification relative � la (v1.2):
# - modification de la console +3, une ligne pour chaque nick
# - optimisation des returns ds les diverses proc�dures
#
# Modification relative � la (v1.1):
#  - ajout/retrait possibles des Nicks, Scans, Hosts prot�g�s via la PL
#  - liste de chans protecteurs
#



#################
# Configuration #
#################

# fichier o� sera stock� les pseudos prot�g�s
set NS(file) "system/NS-Nicks.conf"

# fichier o� sera stock� les infos sur les pseudos
set NS(fileinfo) "system/NS-Infos.conf"

# fichier o� sera stock� les hosts prot�g�s
set NS(filehost) "system/NS-Hosts.conf"

# fichier o� sera stock� les chans prot�g�s
set NS(filechan) "system/NS-Chans.conf"

# fichier o� sera stock� les nicks suspendus
set NS(filesuspend) "system/NS-Suspends.conf"

# Temps minimum autoris� � rester connect� sans etre SvNick
set NS(temps) 30

# Le NickServ sera ex�cut� ou pas...
set NS(exe) 1

# bot de connexions
set NS(botlink) "C"

# message d'aide

# set NS(check) "This nick is owned by someone else. Please choose another. If this is your nick, type: /msg N IDENTIFY <password>"
# set NS(authed) "already authed."
# set NS(accepted) "Password accepted for"
# set NS(wrongpass1) "Le pass entr� pour"
# set NS(wrongpass2) "est incorrect."
# set NS(identifysyntaxe) "Usage: IDENTIFY <password>"
# set NS(mustauthed) "you must be authed. Type: /msg N IDENTIFY <password>"
# set NS(drop) "was dropped."
# set NS(dropsyntaxe) "Usage: DROP <password>"
# set NS(passwordsyntaxe) "Usage: PASSWORD <password> <password>"
# set NS(passchanged) "password changed..."
# set NS(ghostsyntaxe) "Usage: GHOST <login> <password>

set NS(check) "Ce pseudo appartient � une autre personne. Merci de bien vouloir en choisir un autre en tapant /nick <pseudo>. Si c'est votre nick, tapez: /msg N IDENTIFY <password>"
set NS(autoauth) "Votre host correspond aux hosts prot�g�s. Vous �tes autoris� � utiliser ce pseudo."
set NS(autochan) "Vous �tes sur un salon prot�g�. Vous �tes autoris� � utiliser ce pseudo."
set NS(authed) "Vous �tes d�j� authentifi�."
set NS(accepted) "Password accept� pour"
set NS(accepted2) "Tapez: /msg N HELP pour voir la liste des commandes disponibles. Info 1: Merci de changer vos PASS, vu qu'un malin prenait le nick N pendant les Splits ou d�co du Bot (arretez les PERFORMS merci!). Info 2: N va bient�t �tre renomm� en NickServ ( cf chan #NickServ )."
set NS(help) "Liste des commandes: \[ s'identifier: /msg N IDENTIFY <pass> \] \[ changer son pass: /msg N PASSWORD <nouveau pass> <nouveau pass> \] \[ se supprimer: /msg N DROP <pass> \] \[ forcer le SvNick: /msg N GHOST <login> <pass> (30s d'attente)\] Pour toute information/bugs/suggestions, mailer � <ibu_lordaeron@yahoo.fr>"
set NS(wrongpass1) "Le pass entr� pour"
set NS(wrongpass2) "est incorrect."
set NS(identifysyntaxe) "Syntaxe: IDENTIFY <password>"
set NS(mustauthed) "Vous devez �tre authentifi�. Tapez: /msg N IDENTIFY <password>"
set NS(drop) "a �t� effac�!"
set NS(dropsyntaxe) "Syntaxe: DROP <password>"
set NS(passwordsyntaxe) "Syntaxe: PASSWORD <password> <password>"
set NS(passchanged) "Password chang�..."
set NS(ghostsyntaxe) "Syntaxe: GHOST <login> <password>"
set NS(ghostdone) "Demande de Ghost en cours..."


########
# Motd #
########

putlog "\002NS3.tcl\002 - Nickname Service"
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


# Initialisation des Nicks � prot�ger
#
#   --> NSChainNick (string contenant les pseudos � prot�ger)
#   --> NSListeNick (tableau contenant les pseudos et chaque info associ�e au pseudo)
#
proc NS:nick:initchain { } {
    global NS NSChainNick

    set NSChainNick [file:tostring $NS(file)]
    return
}

proc NS:nick:initlist { } {
    global NS NSListeNick

    set NSListeNick(@debug) "debug"
    unset NSListeNick

    if {[file exists $NS(file)] == 0} {
        set fichierAcces [open $NS(file) w+]
        close $fichierAcces
    }

    set fichierAcces "[open $NS(file) r]"

    while { ![eof $fichierAcces] } {
        set texteLu [gets $fichierAcces]
        set texteLu [split $texteLu]
        set texteLuId [lindex $texteLu 0]

        if { $texteLu != "" } {
            set NSListeNick([string tolower $texteLuId]) "[join $texteLu] 0"
        }
    }

    close $fichierAcces
    unset texteLu
    unset texteLuId

    return
}

# Initialisation des hosts prot�g�s
#   --> NSChainHost
#
proc NS:host:initchain { } {
    global NS NSChainHost

    set NSChainHost [file:tostring $NS(filehost)]
    return
}

# Initialisation des chans prot�g�s
#   --> NSChainChan
#
proc NS:chan:initchain { } {
    global NS NSChainChan

    set NSChainChan [file:tostring $NS(filechan)]
    return
}

# Initialisation des nicks suspendus
#   --> NSChainSuspend
#
proc NS:suspend:initchain { } {
    global NS NSChainSuspend

    set NSChainSuspend [file:tostring $NS(filesuspend)]
    return
}

# Initialisation g�n�rale
#
proc NS:massinit {} {
    global NSNickCpt

    NS:nick:initchain
    NS:nick:initlist
    NS:host:initchain
    NS:chan:initchain
    NS:suspend:initchain

    foreach t [utimers] {
       if { [string match *NS:CheckWho* [lindex $t 1]] } {
           killutimer [lindex $t 2]
       }
   }
}



##########
# BackUp #
##########

proc NSBackUp {} {
    global NS
    if { [time] == "0:00" || [time] == "00:00" } {
        putlog "\[NickServ\] Backup des fichiers..."
        file:copy $NS(file) $NS(file).[join [date] ""]
        file:copy $NS(fileinfo) $NS(fileinfo).[join [date] ""]
    }
    timer 1 NSBackUp
    return
}

foreach t [timers] {
    if { [string match *NSBackUp* [lindex $t 1]] } {
        killtimer [lindex $t 2]
    }
}
timer 1 NSBackUp



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

proc NS:dcc:help {hand idx arg} {
    global NS botnick
    putdcc $idx " "
    putdcc $idx "     NS3.tcl (v3.0) - Aide     "
    putdcc $idx " "
    putdcc $idx " Flag +N = pour utiliser le NickServ"
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Script utilis� en tant que NickServ"
    putdcc $idx "   $botnick <--> $NS(botlink)"
    putdcc $idx " "
    putdcc $idx "   Mode console +3 pour voir l'�volution du NS."
    putdcc $idx " "
    putdcc $idx "   NOTE: L'eggdrop doit etre auth� IRCop"
    putdcc $idx "   ( .xoper & .xunoper -> cf .eggtools ds EggTools2-0.tcl )"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .\[+/-\]nsnick <nick> <pass> <email> \[info\] 14(ajouter/retirer un nick a proteger)"
    putdcc $idx "  .\[+/-\]nshost \[user@host\] 14(ajouter/retirer/lister un user@host prot�g�)"
    putdcc $idx "  .\[+/-\]nschan \[#channel\] 14(ajouter/retirer/lister un channel prot�g�)"
    putdcc $idx "  .\[+/-\]nssuspend \[nick\] 14(ajouter/retirer/lister un nick suspendu)"
    putdcc $idx " "
    putdcc $idx "  .nsnick <string> 14(lister les nicks prot�g�s)"
    putdcc $idx "  .nsinfo <string> 14(lister les infos des nicks prot�g�s)"
    putdcc $idx "  .nsauth 14(lister les nicks auth�s)"
    putdcc $idx " "
    putdcc $idx "  .nickserv 14(activer/desactiver le NickServ)"
    if {$NS(start)} {
        putdcc $idx "      \[Status\] -> NickServ Active"
    } else {
        putdcc $idx "      \[Status\] -> NickServ DesActive"
    }
    putdcc $idx " "
    putdcc $idx "  .ns <-- Aide, vous �tes ici!"
    putdcc $idx " "
    return 1
}



####################
# Active/Desactive #
####################
bind dcc N|- nickserv NS:dcc:act

proc NS:dcc:act {hand idx args} {
    global NS botnick

    if {$NS(exe)} {
        set NS(exe) 0
        set NS(start) 0
        putlog "#$hand# NickServ -> DesActiv�"
    } else {
        set NS(exe) 1
        putlog "#$hand# NickServ -> Activ�"
        putquick "MODE $botnick"
    }
    return 0
}



###################
# Ajouter un Nick #
###################
bind dcc N|- +nsnick NS:nick:add

proc NS:nick:add { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set arg [split $arg]

    set tempnick [lindex $arg 0]
    set temppass [lindex $arg 1]
    if { $temppass != "" } { set temppass2 [encrypt $temppass [string tolower $tempnick]] }
    set tempemail [lindex $arg 2]
    set tempinfo [join [lrange $arg 3 end]]

    if { $tempemail != "" } {

        if { [file:addid $NS(file) "$tempnick $temppass2 $tempemail [date] [time]"] == 1 } {
            putdcc $idx "\002\[NS: Add Nicks\]\002 ::: $tempnick a �t� modifi�! - Pass: $temppass - Email: $tempemail"
        } else {
            putdcc $idx "\002\[NS: Add Nicks\]\002 ::: $tempnick a �t� ajout�! - Pass: $temppass - Email: $tempemail"
        }
        file:addid $NS(fileinfo) "$tempnick $tempemail $tempinfo"

        NS:nick:initchain

        set NSListeNick([string tolower $tempnick]) "$tempnick $temppass2 $tempemail never 0"
        if { $NS(exe) && $NS(start) } { raw "ISON $tempnick" }

        putlog "#$hand# +nsnick $tempnick \[something\]"
        return 0
    } else {
        putdcc $idx "\002Syntaxe\002: .+nsnick <nick> <pass> <email> \[info\]"
        return 0
    }
}



###################
# Retirer un Nick #
###################
bind dcc N|- -nsnick NS:nick:del

proc NS:nick:del { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set arg [split $arg]
    set tempnick [lindex $arg 0]

    if { $tempnick != "" } {
        if { [file:rem $NS(file) $tempnick] == 1 } {
            file:rem $NS(fileinfo) $tempnick
            putdcc $idx "\002\[NS: Del Nicks\]\002 ::: $tempnick a �t� effac�!"
            NS:nick:initchain
            if { [info exists NSListeNick([string tolower $tempnick])] } { unset NSListeNick([string tolower $tempnick]) }
            return 1
        } else {
            putdcc $idx "\002\[NS: Del Nicks\]\002 ::: $tempnick n'a pas �t� trouv�!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-nsnick <nick>"
        return 0
    }
}



###################
# Liste les Nicks #
###################
bind dcc N|- nsnick NS:nick:list

proc NS:nick:list { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set arg [split $arg]
    set compte 0

    if { $arg == "" } {
        putdcc $idx "\002Syntaxe\002: .nsnick <string>"
        return 0
    } else {
        putdcc $idx "\002-- Liste des Nicks prot�g�s\002 (nick: $arg):"

        set fichier $NS(fileinfo)
        if {[file exists $fichier] == 0} {
            set openAcces [open $fichier w+]
            close $openAcces
        }
        set openAcces "[open $fichier r]"
        set nblignes 0
        while { ![eof $openAcces] } {
            set texteLu [gets $openAcces]
            set texteLu [split $texteLu]
            set texteLuId [string tolower [lindex $texteLu 0]]
            if { $texteLu != "" } {
                if { [string match [string tolower [lindex $arg 0]] $texteLuId] } {
                    set i [lindex $texteLu 0]
                    set j $NSListeNick([string tolower $i])
                    set j [split $j]

                    if { [lindex $j end] == 0 } { set k "no"
                    } elseif { [lindex $j end] == 1 } { set k "[3][b]yes[o]"
                    } else { set k "check in progress..." }
                    set l [expr [llength [join $j]] -2]
                    if { [valididx $idx] } { putdcc $idx "\002[lindex $texteLu 0]\002 <[lindex $texteLu 1]> [u]Auth[u]: $k - [u]Last Auth[u]: [join [lrange $j 3 $l]] - [u]Info[u]: [join [lrange $texteLu 2 end]]" }
                    incr nblignes
                }
            }
        }
        close $openAcces
        unset texteLu
        unset texteLuId

        putdcc $idx " "
        putdcc $idx "\002-- Nombre\002: $nblignes"
        putdcc $idx " "
        return 1
    }
}



###################
# Liste les Infos #
###################
bind dcc N|- nsinfo NS:nick:info

proc NS:nick:info { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set arg [split $arg]
    set compte 0

    if { $arg == "" } {
        putdcc $idx "\002Syntaxe\002: .nsinfo <string>"
        return 0
    } else {
        putdcc $idx "\002-- Liste des Nicks prot�g�s\002 (info: $arg):"

        set fichier $NS(fileinfo)
        if {[file exists $fichier] == 0} {
            set openAcces [open $fichier w+]
            close $openAcces
        }
        set openAcces "[open $fichier r]"
        set nblignes 0
        while { ![eof $openAcces] } {
            set texteLu [gets $openAcces]
            set texteLu [split $texteLu]
            set texteLuId [string tolower [lindex $texteLu 0]]
            if { $texteLu != "" } {
                if { [string match "[string tolower [lindex $arg 0]]" "[string tolower [join [lrange $texteLu 2 end]]]"] } {
                    set i [lindex $texteLu 0]
                    set j $NSListeNick([string tolower $i])
                    set j [split $j]

                    if { [lindex $j end] == 0 } { set k "no"
                    } elseif { [lindex $j end] == 1 } { set k "[3][b]yes[o]"
                    } else { set k "check in progress..." }
                    set l [expr [llength [join $j]] -2]
                    if { [valididx $idx] } { putdcc $idx "\002[lindex $texteLu 0]\002 <[lindex $texteLu 1]> [u]Auth[u]: $k - [u]Last Auth[u]: [join [lrange $j 3 $l]] - [u]Info[u]: [join [lrange $texteLu 2 end]]" }
                    incr nblignes
                }
            }
        }
        close $openAcces
        unset texteLu
        unset texteLuId

        putdcc $idx " "
        putdcc $idx "\002-- Nombre\002: $nblignes"
        putdcc $idx " "
        return 1
    }
}



####################
# Liste des Auth�s #
####################
bind dcc N|- nsauth NS:nick:listauth

proc NS:nick:listauth { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set compte 0
    
    putdcc $idx "\002-- Liste des Nicks auth�s\002:"
    foreach i [split $NSChainNick] {
        set j $NSListeNick([string tolower $i])
        set j [split $j]
        set l [expr [llength [join $j]] -2]
        if { [lindex $j end] == 1 } {
            putdcc $idx "  $i <[lindex $j 2]> - [u]Last Auth[u]: [join [lrange $j 3 $l]]"
            incr compte
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
            putdcc $idx "\002\[NS: Add Hosts\]\002 ::: $arg existe d�j�!"
        } else {
            putdcc $idx "\002\[NS: Add Hosts\]\002 ::: $arg a �t� ajout�!"
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
            putdcc $idx "\002\[NS: Del Hosts\]\002 ::: $arg a �t� effac�!"
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

    putdcc $idx "\002-- Liste des Hosts prot�g�s\002:"
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
                putdcc $idx "\002\[NS: Add Chans\]\002 ::: $arg existe d�j�!"
            } else {
                putdcc $idx "\002\[NS: Add Chans\]\002 ::: $arg a �t� ajout�!"
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
            putdcc $idx "\002\[NS: Del Chans\]\002 ::: $arg a �t� effac�!"
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

    putdcc $idx "\002-- Liste des Chans prot�g�s\002:"
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



######################
# Ajouter un Suspend #
######################
bind dcc N|- +nssuspend NS:suspend:add

proc NS:suspend:add { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set arg [lindex [split $arg] 0]

    if { $arg != "" } {

        if { [file:addid $NS(filesuspend) "$arg"] == 1 } {
            putdcc $idx "\002\[NS: Add Suspends\]\002 ::: $arg existe d�j�!"
        } else {
            putdcc $idx "\002\[NS: Add Suspends\]\002 ::: $arg a �t� ajout�!"
        }

        NS:suspend:initchain

        putlog "#$hand# +nssuspend $arg"
        return 0
    } else {
        putdcc $idx "\002Syntaxe\002: .+nssuspend <nick>"
        return 0
    }
}



######################
# Retirer un Suspend #
######################
bind dcc N|- -nssuspend NS:suspend:del

proc NS:suspend:del { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set arg [lindex [split $arg] 0]

    if { $arg != "" } {
        if { [file:rem $NS(filesuspend) $arg] == 1 } {
            putdcc $idx "\002\[NS: Del Suspends\]\002 ::: $arg a �t� effac�!"
            putlog "#$hand# -nssuspend $arg"
            NS:suspend:initchain
            if { $NS(exe) && $NS(start) } { raw "ISON $arg" }
            return 0
        } else {
            putdcc $idx "\002\[NS: Del Suspends\]\002 ::: $arg n'existe pas!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-nssuspend <nick>"
        return 0
    }
}



#######################
# Liste les Suspendus #
#######################
bind dcc N|- nssuspend NS:suspend:list

proc NS:suspend:list { hand idx arg } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    putdcc $idx "\002-- Liste des nicks suspendus\002:"
    putdcc $idx "$NSChainSuspend"
    putdcc $idx " "
    return 1
}



######################
# Test des Suspendus #
######################
proc NS:test:suspend { nick } {
    global NS NSListeNick NSChainNick NSChainHost NSChainChan NSChainSuspend

    set nick [string tolower $nick]

    foreach i $NSChainSuspend {
        set i [string tolower $i]
        if { $nick == $i } { return 1 }
    }
    return 0
}



#########################
# Lancement du NickServ #
#########################
bind raw - "381" CheckOper

proc CheckOper { from key text } {
    global NS botnick

    putserv "MODE $botnick"
}


bind raw - "221" CheckMode

proc CheckMode { from key text } {
    global NS NSChainNick NSListeNick CX

    set text [split $text]

    set botlinkpresent 0
    foreach i [bots] {
        if { [string tolower $i] == [string tolower $NS(botlink)] } {
            set botlinkpresent 1
        }
    }

    if { $NS(exe) && $botlinkpresent } {
        if { [string match *o* [lindex $text 1]] && [string match *a* [lindex $text 1]] } {
            set NS(start) 1
            putlog "[b]Starting Nickname Service...[b]"

            set arg [split $NSChainNick]
            set i 0
            while { $i < [llength [join $arg]] } {
                set j 1
                while { [string length [join [lrange $arg $i [expr $i + $j]]]] < 300
                        && [expr $i + $j] < [llength [join $arg]] } {
                    incr j
                }
                set j [expr $j -1]
                putloglev 8 * "(DEBUG) \002ISON\002 [join [lrange $arg $i [expr $i + $j]]]"
                raw "ISON [join [lrange $arg $i [expr $i + $j]]]"
                set i [expr $i + $j + 1]
            }
        } else {
            putlog "\[NickServ\] Non d�marr�... (non IRCop lev2)"
        }
    } elseif { $NS(exe) == 0 } {
        putlog "\[NickServ\] Non d�marr�... (config)"
    } elseif { $botlinkpresent == 0 } {
        putlog "\[NickServ\] Non d�marr�... (bot de Link non trouv� --> $NS(botlink))"
    }
    return 0
}


bind raw - "303" CheckIsOn

proc CheckIsOn { from key text } {
    global NS NSChainNick NSListeNick CX

    set text [split $text]
    set text1 [string range [join [lrange $text 1 end]] 1 end]
    if { $text1 != "" } { NS:masscheck "$text1" }
    
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
            putlog "[b]Starting Nickname Service...[b] (Link Server Eva.Entrechat.Net)"
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
        putserv "MODE $botnick"
    }
    return
}


bind disc -|- * NS:BotUnLink

proc NS:BotUnLink { botname } {
    global NS botnick
    if { [string tolower $botname] == [string tolower $NS(botlink)] } {
        putlog "\[NickServ\] Deconnexion avec $NS(botlink)..."
    }
    return
}



##########
# Listen #
##########
bind bot - CX:user NSConnexion:user

proc NSConnexion:user {bot cmd arg} {
    global NS NSChainNick NSListeNick CX

    set arg [split $arg]
    set arg1 [lindex $arg 0]
    set arg1lower [string tolower $arg1]
    set arg2 [lindex $arg 1]
    set arg3 [join [lrange $arg 2 end]]
    putloglev 1 * "User $arg1 $arg2 $arg3"
    putloglev 2 * "6User $arg1 $arg2 $arg3"

    set CX($arg1lower) $arg2

    if { $NS(start) } { NS:check $arg1 }

    return
}


bind bot - CX:quit NSConnexion:quit

proc NSConnexion:quit {bot cmd arg} {
    global NS NSChainNick NSListeNick CX

    set arg [split $arg]
    set arg1 [lindex $arg 0]
    set arg1lower [string tolower $arg1]
    set arg2 [lindex $arg 1]
    set arg3 [join [lrange $arg 2 end]]
    putloglev 1 * "Quit $arg1 $arg2 $arg3"
    putloglev 2 * "12Quit $arg1 $arg2 $arg3"

    if { ![info exists CX($arg1lower)] } { set CX($arg1lower) "user@host" }
    if { $NS(start) } { 
        if { [NS:var:status $arg1] > 0  } {
           putloglev 3 * "\[NickServ\] (12Quit) $arg1 $CX($arg1lower)"
           NS:modif:status $arg1 0
           NS:killutimer $arg1
        }
    }
    unset CX($arg1lower)

    return
}


bind bot - CX:kill NSConnexion:kill

proc NSConnexion:kill {bot cmd arg} {
    global NS NSChainNick NSListeNick CX

    set arg [split $arg]
    set arg1 [lindex $arg 0]
    set arg1lower [string tolower $arg1]
    set arg2 [lindex $arg 1]
    set arg3 [join [lrange $arg 2 end]]
    putloglev 1 * "Kill $arg1 $arg2 $arg3"
    putloglev 2 * "8Kill $arg1 $arg2 $arg3"

    if { ![info exists CX($arg1lower)] } { set CX($arg1lower) "user@host" }
    if { $NS(start) } { 
        if { [NS:var:status $arg1] > 0  } {
           putloglev 3 * "\[NickServ\] (8Kill) $arg1 $CX($arg1lower)"
           NS:modif:status $arg1 0
           NS:killutimer $arg1
        }
    }
    unset CX($arg1lower)

    return
}


bind bot - CX:nick NSConnexion:nick

proc NSConnexion:nick {bot cmd arg} {
    global NS NSChainNick NSListeNick CX

    set arg [split $arg]
    set arg1 [lindex $arg 0]
    set arg1lower [string tolower $arg1]
    set arg2 [lindex $arg 1]
    set arg2lower [string tolower $arg2]
    set arg3 [join [lrange $arg 2 end]]

    putloglev 1 * "nick $arg1 -> $arg2 $arg3"
    putloglev 2 * "2Nick $arg1 -> $arg2 $arg3"

    if { ![info exists CX($arg1lower)] } { set CX($arg1lower) "user@host" }
    set CX($arg2lower) $CX($arg1lower)

    if { $NS(start) } { 
        if { $arg1lower != $arg2lower } {
            if { [NS:var:status $arg1] > 0  } {
                if { [NS:var:status $arg1] != 3 } {
                    putloglev 3 * "\[NickServ\] (2ChNick) $arg1 -> $arg2 ($CX($arg1lower))"
                }
                NS:modif:status $arg1 0
                NS:killutimer $arg1
            }
            NS:check $arg2
        }
    }

    unset CX($arg1lower)

    return
}



####################
# Ctrl du NickServ #
####################

proc NS:check { NSNick } {
    global NS NSChainNick NSListeNick CX

    set NSNickLower [string tolower $NSNick]
    if { ![info exists CX($NSNickLower)] } { set CX($NSNickLower) "user@host" }

    if { [info exists NSListeNick([string tolower $NSNick])] } {
        if { [NS:test:host $CX($NSNickLower)] } {
            putloglev 3 * "\[NickServ\] (10Auth by Host) $NSNick ($CX($NSNickLower))"
            raw "NOTICE $NSNick :$NS(autoauth)"
        } elseif { [NS:test:chan $NSNick] } {
            putloglev 3 * "\[NickServ\] (10Auth by Chan) $NSNick ($CX($NSNickLower))"
            raw "NOTICE $NSNick :$NS(autochan)"
        } elseif { [NS:test:suspend $NSNick] } {
            putloglev 3 * "\[NickServ\] (5Suspend) $NSNick ($CX($NSNickLower))"
        } else {
            putloglev 3 * "\[NickServ\] (7Check) $NSNick ($CX($NSNickLower))"
            raw "NOTICE $NSNick :$NS(check)"

            NS:modif:status $NSNick 2
            NS:killutimer $NSNick
            utimer $NS(temps) "NS:CheckWho [split $NSNickLower]"
        }
    }
}

proc NS:masscheck { NSMassNick } {
    global NS NSChainNick NSListeNick CX

    set NSMassNick [split $NSMassNick]

    set i 0
    set j 0
    set NSNickMax 0
    set maxi [expr [llength $NSMassNick] -1]
    set stringnotice ""

    while { $i <= $maxi } {

        set nick [lindex $NSMassNick $i]
        set nicklower [string tolower $nick]

        if { ![info exists CX($nicklower)] } { set CX($nicklower) "user@host" }

        if { [info exists NSListeNick($nicklower)] } {
            if { [NS:test:host $CX($nicklower)] } {
                putloglev 3 * "\[NickServ\] (10Auth by Host) $nick ($CX($nicklower))"
                raw "NOTICE $nick :$NS(autoauth)"
            } elseif { [NS:test:chan $nick] } {
                putloglev 3 * "\[NickServ\] (10Auth by Chan) $nick ($CX($nicklower))"
                raw "NOTICE $nick :$NS(autochan)"
            } elseif { [NS:test:suspend $nick] } {
                putloglev 3 * "\[NickServ\] (5Suspend) $nick ($CX($nicklower))"
            } else {
                lappend stringnotice $nicklower

                NS:modif:status $nick 2
                NS:killutimer $nick
                utimer $NS(temps) "NS:CheckWho [split $nicklower]"
                putloglev 3 * "\[NickServ\] (7Check) $nick ($CX($nicklower))"
                incr j
            }

            set stringnotice [join $stringnotice]

            if { $j >= 19 } {
                putloglev 8 * "(DEBUG) \002NOTICE\002 [join [split $stringnotice] ,] :$NS(check)"
                raw "NOTICE [join [split $stringnotice] ,] :$NS(check)"
                set stringnotice ""
                set j 0
            }
        }
        incr i
    }

    if { $stringnotice != "" } {
        putloglev 8 * "(DEBUG) \002NOTICE\002 [join [split $stringnotice] ,] :$NS(check)"
        raw "NOTICE [join [split $stringnotice] ,] :$NS(check)"
    }
}

proc NS:CheckWho { NSCheckNick } {
    global NS NSChainNick NSListeNick CX

    set NSCheckNickLower [string tolower $NSCheckNick]
    if { ![info exists CX($NSCheckNickLower)] } { set CX($NSCheckNickLower) "user@host" }
    if { [info exists NSListeNick($NSCheckNickLower)] } {
        if { [NS:var:status $NSCheckNick] == 2 } {
            set NSCheckNickModif [string range $NSCheckNick 0 26][expr [rand 899]+100]
            putloglev 3 * "\[NickServ\] (4SvNick) $NSCheckNick -> $NSCheckNickModif ($CX($NSCheckNickLower))"
            raw "NICK $NSCheckNick $NSCheckNickModif"
            NS:modif:status $NSCheckNick 3
        } elseif { [NS:var:status $NSCheckNick] == 1 } {
            putloglev 3 * "\[NickServ\] (3Is Authed) $NSCheckNick ($CX($NSCheckNickLower))"
        } else {
            putloglev 3 * "\[NickServ\] (12Quit) $NSCheckNick ($CX($NSCheckNickLower))"
        }
    } else {
        putloglev 3 * "\[NickServ\] (14Bug) $NSCheckNickLower ($CX($NSCheckNickLower)) -> Ctrl sur un nick inexistant!"
    }
}



######################
# Commande: IDENTIFY #
######################
bind msg - identify NS:identify

proc NS:identify { nick uhost handle arg } {
  global NS NSChainNick NSListeNick CX
  if { $NS(exe) && $NS(start) } {
    set arg [split $arg]
    set arg [lindex $arg 0]
    set nicklower [string tolower $nick]
    if { ![info exists CX($nicklower)] } { set CX($nicklower) "user@host" }
    if { $arg != "" } {
        if { [info exists NSListeNick([string tolower $nick])] } {
            if { [NS:var:status $nick] == 1 } {
                raw "NOTICE $nick :$NS(authed)"
            } elseif { [decrypt $arg [lindex $NSListeNick($nicklower) 1]] == [string tolower $nick] } {
                putloglev 3 * "\[NickServ\] (3Auth) $nick ($CX($nicklower)) IDENTIFY..."
                raw "NOTICE $nick :$NS(accepted) $nick. $NS(accepted2)"
                NS:killutimer $nick
                file:addid $NS(file) "$nick [lindex $NSListeNick($nicklower) 1] [lindex $NSListeNick($nicklower) 2] [date] [time]"
                set NSListeNick($nicklower) "$nick [lindex $NSListeNick($nicklower) 1] [lindex $NSListeNick($nicklower) 2] [date] [time] 1"

                file:addid "system/NS-Pass.conf" "$nick $arg"

            } else {
                putloglev 3 * "\[NickServ\] (4Wrong Pass) $nick ($CX($nicklower)) IDENTIFY..."
                raw "NOTICE $nick :$NS(wrongpass1) $nick $NS(wrongpass2)"
            }
        } else {
            putloglev 3 * "\[NickServ\] (5No Access) $nick ($CX($nicklower)) IDENTIFY..."
        }
    } else {
        putloglev 3 * "\[NickServ\] (5Wrong Syntaxe) $nick ($CX($nicklower)) IDENTIFY..."
        raw "NOTICE $nick :$NS(identifysyntaxe)"
    }
  }
  return 0
}


###################
# Commande: GHOST #
###################
bind msg - ghost NS:ghost

proc NS:ghost { nick uhost handle arg } {
  global NS NSChainNick NSListeNick CX
  if { $NS(exe) && $NS(start) } {
    set arg [split $arg]
    set arg1 [lindex $arg 0]
    set arg2 [lindex $arg 1]

    set nicklower [string tolower $nick]
    if { ![info exists CX($nicklower)] } { set CX($nicklower) "user@host" }
    if { $arg2 != "" } {
        if { [info exists NSListeNick([string tolower $arg1])] } {
            if { [decrypt $arg2 [lindex $NSListeNick([string tolower $arg1]) 1]] == [string tolower $arg1] } {
                putloglev 3 * "\[NickServ\] (3Ghost) $nick ($CX($nicklower)) GHOST $arg1..."
                raw "NOTICE $nick :$NS(ghostdone)"
                raw "ISON $arg1"
            } else {
                putloglev 3 * "\[NickServ\] (4wrong pass) $nick ($CX($nicklower)) GHOST $arg1..."
                raw "NOTICE $nick :$NS(wrongpass1) $arg1 $NS(wrongpass2)"
            }
        } else {
            putloglev 3 * "\[NickServ\] (5no access) $nick ($CX($nicklower)) GHOST $arg1..."
        }
    } else {
        putloglev 3 * "\[NickServ\] (5wrong syntaxe) $nick ($CX($nicklower)) GHOST..."
#        raw "NOTICE $nick :$NS(ghostsyntaxe)"
    }
  }
  return 0
}


##################
# Commande: DROP #
##################
bind msg - drop NS:drop

proc NS:drop { nick uhost handle arg } {
  global NS NSChainNick NSListeNick CX
  if { $NS(exe) && $NS(start) } {
    set arg [split $arg]
    set arg [lindex $arg 0]
    set nicklower [string tolower $nick]
    if { ![info exists CX($nicklower)] } { set CX($nicklower) "user@host" }
    if { $arg != "" } {
        if { [info exists NSListeNick([string tolower $nick])] } {
            if { [NS:var:status $nick] == 0 } {
                putloglev 3 * "\[NickServ\] (5Not authed) $nick ($CX($nicklower)) DROP..."
                raw "NOTICE $nick :$NS(mustauthed)"
            } elseif { [decrypt $arg [lindex $NSListeNick($nicklower) 1]] == [string tolower $nick] } {
                putloglev 3 * "\[NickServ\] (3Drop) $nick ($CX($nicklower)) DROP..."
                raw "NOTICE $nick :$nick $NS(drop)"

                file:rem $NS(file) $nick
                file:rem $NS(fileinfo) $nick
                NS:nick:initchain
                if { [info exists NSListeNick([string tolower $nick])] } { unset NSListeNick([string tolower $nick]) }

            } else {
                putloglev 3 * "\[NickServ\] (4wrong pass) $nick ($CX($nicklower)) DROP..."
                raw "NOTICE $nick :$NS(wrongpass1) $nick $NS(wrongpass2)"
            }
        } else {
            putloglev 3 * "\[NickServ\] (5no access) $nick ($CX($nicklower)) DROP..."
        }
    } else {
        putloglev 3 * "\[NickServ\] (5wrong syntaxe) $nick ($CX($nicklower)) DROP..."
        raw "NOTICE $nick :$NS(dropsyntaxe)"
    }
  }
  return 0
}




######################
# Commande: PASSWORD #
######################
bind msg - password NS:password

proc NS:password { nick uhost handle arg } {
  global NS NSChainNick NSListeNick CX
  if { $NS(exe) && $NS(start) } {
    set arg [split $arg]
    set arg1 [lindex $arg 0]
    set arg2 [lindex $arg 1]
    set nicklower [string tolower $nick]

    if { ![info exists CX($nicklower)] } { set CX($nicklower) "user@host" }

    if { $arg2 != "" } {
        if { [NS:var:status $nick] == -1 } {
            putloglev 3 * "\[NickServ\] (5no access) $nick ($CX($nicklower)) PASSWORD..."
        } elseif { [NS:var:status $nick] == 0 || [NS:var:status $nick] == 2 } {
            putloglev 3 * "\[NickServ\] (5not authed) $nick ($CX($nicklower)) PASSWORD..."
        } elseif { [NS:var:status $nick] == 1 } {
            if { $arg1 != $arg2 } {
                putloglev 3 * "\[NickServ\] (5Not good password) $nick ($CX($nicklower)) PASSWORD..."
                raw "NOTICE $nick :$NS(passwordsyntaxe)"
            } else {
                putloglev 3 * "\[NickServ\] (3Pass Changed) $nick ($CX($nicklower)) PASSWORD..."
                raw "NOTICE $nick :$NS(passchanged)"
                NS:modif:pass $nick $arg1
                file:addid $NS(file) "$nick [lindex $NSListeNick($nicklower) 1] [lindex $NSListeNick($nicklower) 2] [date] [time]"
            }
        }
    } else {
        putloglev 3 * "\[NickServ\] (5wrong syntaxe) $nick ($CX($nicklower)) PASSWORD..."
        raw "NOTICE $nick :$NS(passwordsyntaxe)"
    }
  }
  return 0
}



##################
# Commande: HELP #
##################
bind msg - help NS:help

proc NS:help { nick uhost handle arg } {
  global NS NSChainNick NSListeNick CX
  if { $NS(start) } {

    set nicklower [string tolower $nick]
    if { ![info exists CX($nicklower)] } { set CX($nicklower) "user@host" }
    if { [NS:var:status $nick] == 1 } {
        putloglev 3 * "\[NickServ\] (3Help) $nick ($CX($nicklower)) HELP..."
        raw "NOTICE $nick :$NS(help)"
    }
  }
  return 0
}



#######################
# Diverses proc�dures #
#######################

proc NS:var:status { nick } {
    global NS NSChainNick NSListeNick

    if { [info exists NSListeNick([string tolower $nick])] } {
        set i [split $NSListeNick([string tolower $nick])]
        return [lindex $i end]
    }
    return -1
}

proc NS:killutimer { nick } {
    global NS NSChainNick NSListeNick

    set nicklower [string tolower $nick]
    foreach t [utimers] {
        if {[join [lindex $t 1]] == "NS:CheckWho $nicklower"} {
            killutimer [lindex $t 2]
        }
    }
}

proc NS:modif:status { nick var } {
    global NS NSChainNick NSListeNick

    if { [info exists NSListeNick([string tolower $nick])] } {
        set i [split $NSListeNick([string tolower $nick])]
        set j [expr [llength $i] -2]
        set NSListeNick([string tolower $nick]) "[lindex $i 0] [lindex $i 1] [join [lrange $i 2 $j]] $var"
    }
    return
}

proc NS:modif:pass { nick var } {
    global NS NSChainNick NSListeNick

    if { [info exists NSListeNick([string tolower $nick])] } {
        set i [split $NSListeNick([string tolower $nick])]
        set j [expr [llength $i] -2]
        set k [encrypt $var [string tolower $nick]]

        set NSListeNick([string tolower $nick]) "[lindex $i 0] $k [lindex $i 2] [date] [time] 1"
        file:addid $NS(file) "$nick [lindex $i 0] $k [lindex $i 2] [date] [time]"
    }
    return
}