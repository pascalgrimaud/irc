#
# NS2.tcl (v2.1) par Ibu <ibu_lordaeron@yahoo.fr>
#
# Ce script sert de NickServ.
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

# répertoire de sauvegarde des fichiers de config
set rep_system "system"

# Temps minimum autorisé à rester connecté sans etre killé
# PS: ce tps peut largement être dépassé selon la liste du USERHOST
set NS(Temps) 20

# Message d'avertos
set NS(Avertos) "\[Information\] Ce pseudo appartient a un Operateur -ou bien- ne correspond pas aux pseudos toleres ici. Merci de bien vouloir changer de pseudo, en tapant: /nick nouveau_pseudo"

# Le NickServ est lancé dès le rehash
# il est conseillé de le mettre à 0, car lors d'un restart, l'egg rejoint une liste de salon
# et risque de scanner toul monde. S'il n'est pas authé IRCopérateur... ca va le faire ramer
set NS(start) 1

# Message de changement de nick
set NS(result) "\[Information\] Ce pseudo appartient a un Operateur -ou bien- ne correspond pas aux pseudos toleres ici. Par consequent, votre pseudo vient d'etre modifie. Merci de votre comprehension."

# avertir en globops
set NS(globops) 1



##################
# Initialisation #
##################

# Initialisation des Nicks à protéger
#
#   --> NSChainNick
#   --> NSListeNick
#
proc NS:nick:init { } {
    global rep_system NSChainNick NSListeNick

    set NSChainNick ""

    if {[file exists $rep_system/NS-Nicks.conf] == 0} {
        set LectureFichierTemp [open $rep_system/NS-Nicks.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/NS-Nicks.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierNickLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierNickInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierNickLu != ""} {

            lappend NSChainNick $LectureFichierNickLu
            set NSChainNick [join $NSChainNick]
            set NSListeNick([string tolower $LectureFichierNickLu]) "$LectureFichierNickLu $LectureFichierNickInfo"
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierNickLu
    unset LectureFichierNickInfo

    return
}


# Initialisation des Hosts à protéger
#
#   --> NSChainHost
#
proc NS:host:init { } {
    global rep_system NSChainHost

    set NSChainHost ""

    if {[file exists $rep_system/NS-Hosts.conf] == 0} {
        set LectureFichierTemp [open $rep_system/NS-Hosts.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/NS-Hosts.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierHostLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierHostInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierHostLu != ""} {

            lappend NSChainHost $LectureFichierHostLu
            set NSChainHost [join $NSChainHost]
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierHostLu
    unset LectureFichierHostInfo

    return
}

# Initialisation des Channels sur lesquels il faut être
#
#   --> NSChainChan
#
proc NS:chan:init { } {
    global rep_system NSChainChan

    set NSChainChan ""

    if {[file exists $rep_system/NS-Chans.conf] == 0} {
        set LectureFichierTemp [open $rep_system/NS-Chans.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/NS-Chans.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierChanLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierChanInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierChanLu != ""} {

            lappend NSChainChan $LectureFichierChanLu
            set NSChainChan [join $NSChainChan]
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierChanLu
    unset LectureFichierChanInfo

    return
}

proc NS:scancpt:init { } {
    global NSNickMax NSListCpt NSChainNick

    set i 0
    set NSNickMax 0

    set maxi [expr "[llength $NSChainNick] / 5"]

    while { $i < $maxi } {
        incr NSNickMax
        set NSListCpt($NSNickMax) "[lrange $NSChainNick [expr "$i * 5"] [expr "( $i + 1 ) * 5-1"]]"
        incr i
    }
    if { [lrange $NSChainNick [expr "$i * 5"] end] != "" } {
        incr NSNickMax
        set NSListCpt($NSNickMax) "[lrange $NSChainNick [expr "$i * 5"] end]"
    }
    return
}


proc NS:massinit {} {
    global NSNickCpt

    NS:nick:init
    NS:host:init
    NS:chan:init
    NS:scancpt:init
    set NSNickCpt 1
}

NS:massinit


########
# Motd #
########

putlog "\002NS2.tcl\002 (v2.1) par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"

if {$NS(start)} {
    putlog "   Aide --> .ns -- \[Status\] -> NickServ Active"
} else {
    putlog "   Aide --> .ns -- \[Status\] -> NickServ DesActive"
}



#################
# Bind de Debug #
#################
bind dcc n nschk NS:chk

proc NS:chk { hand idx arg } {
    global NSChainNick NSChainScan NSChainHost NSNickMax NSListCpt NSChainChan
    putlog "\002Nicks:\002 $NSChainNick"
    putlog "\002Scans:\002 $NSChainScan"
    putlog "\002Hosts:\002 $NSChainHost"
    putlog "\002Chans:\002 $NSChainChan"

    set i 1
    putlog "\002Liste ScanHosts:\002"
    while { $i <= $NSNickMax } {
        putlog "$NSListCpt($i)"
        incr i
    }
    return
}



########
# Aide #
########
bind dcc -|- ns NS:help

proc NS:help {hand idx arg} {
    global NS
    putdcc $idx " "
    putdcc $idx "     NS2.tcl (v2.1) - Aide     "
    putdcc $idx " "
    putdcc $idx " Flag +S = pour utiliser le NickServ"
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Script utilise en tant que NickServ :"
    putdcc $idx "   - verifie par USERHOST x5 une liste de nicks"
    putdcc $idx "   - verifie les nicks & leur identite"
    putdcc $idx "   - change les nicks si necessaire"
    putdcc $idx " "
    putdcc $idx "   Mode console +3 pour voir l'evolution du NS."
    putdcc $idx " "
    putdcc $idx "   NOTE: L'Eggdrop doit etre authe IRCop"
    putdcc $idx "   ( .xoper & .xunoper -> cf .xoperhelp ds EggOper.tcl )"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .\[+/-\]nsnick <nick> <status: 0/1> 14(ajouter/retirer un nick a proteger)"
    putdcc $idx "  .nsnick 14(lister les nicks proteges (liste courte))"
    putdcc $idx "  .nsnick2 14(lister les nicks proteges (liste complete))"
    putdcc $idx "  .\[+/-\]nshost <user@host> 14(ajouter/retirer/lister les Hosts proteges)"
    putdcc $idx "  .\[+/-\]nschan <#channel> 14(ajouter/retirer/lister un chan protecteur)"
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
bind dcc S|- nickserv NS:dcc:act

proc NS:dcc:act {hand idx args} {
    global NS

    if {$NS(start)} {
        set NS(start) 0
        putlog "#$hand# NickServ -> DesActive"
    } else {
        set NS(start) 1
        putlog "#$hand# NickServ -> Active"
        NS:CheckWho
    }
    return 0
}


###################
# Ajouter un Nick #
###################
bind dcc S +nsnick NS:nick:add

proc NS:nick:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]
    set tempstatus [join [lrange $arg 1 1]]
    if { $tempstatus != "" } {
        if { [NS:FichierAddInfo $rep_system/NS-Nicks.conf $tempnick $tempstatus] == 1 } {
            putdcc $idx "\002\[NS: Add Nicks\]\002 ::: $tempnick a ete modifie! - Status: $tempstatus"
        } else {
            putdcc $idx "\002\[NS: Add Nicks\]\002 ::: $tempnick a ete ajoute! - Status: $tempstatus"
        }
        NS:massinit
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+nsnick <nick> <status: 0/1>"
        return 0
    }

}


###################
# Retirer un Nick #
###################
bind dcc S -nsnick NS:nick:del

proc NS:nick:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierRemInfo $rep_system/NS-Nicks.conf $tempnick] == 1 } {
            putdcc $idx "\002\[NS: Del Nicks\]\002 ::: $tempnick a ete efface!"
            NS:massinit
            return 1
        } else {
            putdcc $idx "\002\[NS: Del Nicks\]\002 ::: $tempnick n'a pas ete trouve!"
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
bind dcc S nsnick NS:nick:list

proc NS:nick:list { hand idx arg } {
    global NSChainNick NSChainScan NSChainHost NSNickMax NSListCpt NSChainChan
    set i 1
    putlog "\002Liste des Nicks proteges\002:"
    while { $i <= $NSNickMax } {
        putlog "$NSListCpt($i)"
        incr i
    }
    return 1
}


bind dcc S nsnick2 NS:nick:list2

proc NS:nick:list2 { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Nicks proteges\002:"
    NS:FichierLecture $idx $rep_system/NS-Nicks.conf
    putdcc $idx " "
    return 1
}


###################
# Ajouter un Host #
###################
bind dcc S +nshost NS:host:add

proc NS:host:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierAddInfo $rep_system/NS-Hosts.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[NS: Add Hosts\]\002 ::: $tempnick a ete modifie!"
        } else {
            putdcc $idx "\002\[NS: Add Hosts\]\002 ::: $tempnick a ete ajoute!"
        }
        NS:massinit
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+nshost <user@host>"
        return 0
    }
}


###################
# Retirer un Host #
###################
bind dcc S -nshost NS:host:del

proc NS:host:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierRemInfo $rep_system/NS-Hosts.conf $tempnick] == 1 } {
            putdcc $idx "\002\[NS: Del Hosts\]\002 ::: $tempnick a ete efface!"
            NS:massinit
            return 1
        } else {
            putdcc $idx "\002\[NS: Del Hosts\]\002 ::: $tempnick n'a pas ete trouve!"
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
bind dcc S nshost NS:host:list

proc NS:host:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Hosts proteges\002:"
    NS:FichierLecture $idx $rep_system/NS-Hosts.conf
    putdcc $idx " "
    return 1
}


###################
# Ajouter un Chan #
###################
bind dcc S +nschan NS:chan:add

proc NS:chan:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierAddInfo $rep_system/NS-Chans.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[NS: Add Chans\]\002 ::: $tempnick a ete modifie!"
        } else {
            putdcc $idx "\002\[NS: Add Chans\]\002 ::: $tempnick a ete ajoute!"
        }
        NS:massinit
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+nschan <#channel>"
        return 0
    }
}


###################
# Retirer un Chan #
###################
bind dcc S -nschan NS:chan:del

proc NS:chan:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierRemInfo $rep_system/NS-Chans.conf $tempnick] == 1 } {
            putdcc $idx "\002\[NS: Del Chans\]\002 ::: $tempnick a ete efface!"
            NS:massinit
            return 1
        } else {
            putdcc $idx "\002\[NS: Del Chans\]\002 ::: $tempnick n'a pas ete trouve!"
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
bind dcc S nschan NS:chan:list

proc NS:chan:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Chans Protecteurs\002:"
    NS:FichierLecture $idx $rep_system/NS-Chans.conf
    putdcc $idx " "
    return 1
}

##############
# Procédures #
##############

proc NS:FichierAddInfo { AddInfoFichier AddInfoNick AddInfoInfo } {
    global rep_system

    set AddInfoNickTrouve 0

    set AddInfoFichierAcces "$AddInfoFichier"
    set AddInfoFichierAcces2 "$rep_system/temp.txt"

    set AddInfoNick [join $AddInfoNick]
    set AddInfoInfo [join $AddInfoInfo]

    if {[file exists $AddInfoFichierAcces] == 0} {
        set AddInfoTemp [open $AddInfoFichierAcces w+]
        close $AddInfoTemp
    }

    set AddInfoTemp "[open $AddInfoFichierAcces r+]"
    set AddInfoTemp2 "[open $AddInfoFichierAcces2 w+]"
    while {![eof $AddInfoTemp]} {
        set AddInfoTexteLu [gets $AddInfoTemp]

        set AddInfoNickLu [join [lrange $AddInfoTexteLu 0 0]]
        set AddInfoInfoLu [join [lrange $AddInfoTexteLu 1 end]]
        if {[string tolower $AddInfoNickLu] == [string tolower $AddInfoNick]} {
            if { $AddInfoNick != "" } {
                puts $AddInfoTemp2 "$AddInfoNick $AddInfoInfo"
                set AddInfoNickTrouve 1
            }
        } else {
            if { $AddInfoNickLu != "" } { puts $AddInfoTemp2 "$AddInfoNickLu $AddInfoInfoLu" }
        }
    }

    if {$AddInfoNickTrouve == 0 && $AddInfoNick != "" } {
        puts $AddInfoTemp2 "$AddInfoNick $AddInfoInfo"
    }
    close $AddInfoTemp
    close $AddInfoTemp2

    NS:FichierCopy "$rep_system/temp.txt" $AddInfoFichierAcces

    unset AddInfoTexteLu
    unset AddInfoNickLu
    unset AddInfoInfoLu
    
    return $AddInfoNickTrouve
}

proc NS:FichierRemInfo { RemInfoFichier RemInfoNick } {
    global rep_system

    set RemInfoNickTrouve 0

    set RemInfoFichierAcces "$RemInfoFichier"
    set RemInfoFichierAcces2 "$rep_system/temp.txt"

    if {[file exists $RemInfoFichierAcces] == 0} {
        set RemInfoTemp [open $RemInfoFichierAcces w+]
        close $RemInfoTemp
    }

    set RemInfoTemp "[open $RemInfoFichierAcces r+]"
    set RemInfoTemp2 "[open $RemInfoFichierAcces2 w+]"
    while {![eof $RemInfoTemp]} {
        set RemInfoTexteLu [gets $RemInfoTemp]
        set RemInfoNickLu [join [lrange $RemInfoTexteLu 0 0]]
        set RemInfoInfoLu [join [lrange $RemInfoTexteLu 1 end]]
        if {[string tolower $RemInfoNickLu] != [string tolower $RemInfoNick]} {
            if {$RemInfoNickLu != ""} {puts $RemInfoTemp2 "$RemInfoNickLu $RemInfoInfoLu"}
        } else {
            set RemInfoNickTrouve 1
        }
    } 

    close $RemInfoTemp
    close $RemInfoTemp2

    NS:FichierCopy "$rep_system/temp.txt" $RemInfoFichierAcces 

    unset RemInfoTexteLu
    unset RemInfoNickLu
    unset RemInfoInfoLu

    return $RemInfoNickTrouve
}

proc NS:FichierCopy { CopyFichierAcces CopyFichierAcces2 } {
    file copy -force $CopyFichierAcces $CopyFichierAcces2
    return
}

proc NS:FichierLecture { LectureIdx LectureFichierAcces } {

    if {[file exists $LectureFichierAcces] == 0} {
        set LectureFichierTemp [open $LectureFichierAcces w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $LectureFichierAcces r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierNickLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierNickInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierNickLu != ""} {
            putdcc $LectureIdx "$LectureFichierNickLu $LectureFichierNickInfo"
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierNickLu
    unset LectureFichierNickInfo

    return
}


###################
# Gestion du Scan #
###################

set NS(ok) 0
set NSNickBeNotice ""
set NSNickBeKill ""

#--------------------------------------------------------------------------------
#
# Scan par WHO des nicks protégés - Gestion des RAWS
#
#--------------------------------------------------------------------------------
proc NS:CheckWho { } {
    global NS NSListCpt NSNickCpt

    if { $NS(start) } {
        putloglev 3 * "\[NickServ\] (CTRL) [join $NSListCpt($NSNickCpt)]"
        putserv "USERHOST [join $NSListCpt($NSNickCpt)]"
    }
}

#
# RAW -> (481)
#
bind raw - "481" NSKillImpossible

proc NSKillImpossible {from key text} {
    putlog "\[\002Info\002\] [lrange $text 1 end]"
}


bind raw - "302" NSWhoCheck

proc NSWhoCheck {from key text} {

    global NS NSListeNick NSNickCpt NSNickMax

    if { $NS(start) && $text != "" } {

        regsub -all {\\} $text {\\\\} text
        regsub -all {\{} $text {\{} text
        regsub -all {\}} $text {\}} text
        regsub -all {\]} $text {\]} text
        regsub -all {\[} $text {\[} text
        regsub -all {\"} $text {\"} text
        set textsave $text

        set textsave [string range [lrange $textsave 1 end] 1 end]

        # initialisation des variables: nick, identd, host, etc.. pour pouvoir les tester

        set i 0
        set text [join [lrange $textsave $i $i]]

        while { $text != "" } {

            set NSNick [lindex [split $text :*=] 0]
            set NSIdent [lindex [split $text +@] 1]
            set NSMask [lindex [split $text @] 1]

            set NSIRCop [string match *\\* [lindex [split "$text" =] 0]]

            # test du nick, si c un nick protégé, si c un mask protégé, etc..
            set NSonQG [IsOnChannel $NSNick]
            set NSonmask [NSMaskIsOnList $NSIdent@$NSMask]

            if { [info exists NSListeNick([string tolower $NSNick])] } {
                if { $NSIRCop == 1 } {
                    putloglev 3 * "\[NickServ\] (4IRCop) $NSNick ($NSIdent@$NSMask)"
                    set NSListeNick([string tolower $NSNick]) "[lindex $NSListeNick([string tolower $NSNick]) 0] [lindex $NSListeNick([string tolower $NSNick]) 1]"
                } elseif { $NSonmask == 1 } {
                    putloglev 3 * "\[NickServ\] (4Mask Protected) $NSNick ($NSIdent@$NSMask)"
                    set NSListeNick([string tolower $NSNick]) "[lindex $NSListeNick([string tolower $NSNick]) 0] [lindex $NSListeNick([string tolower $NSNick]) 1]"
                } elseif { $NSonQG == 1 } {
                    putloglev 3 * "\[NickServ\] (4Chan Protect) $NSNick ($NSIdent@$NSMask)"
                    set NSListeNick([string tolower $NSNick]) "[lindex $NSListeNick([string tolower $NSNick]) 0] [lindex $NSListeNick([string tolower $NSNick]) 1]"
                } else {
                    NSCheck $NSNick $NSIdent@$NSMask
                }
            }

            incr i
            set text [join [lrange $textsave $i $i]]
        }

        set NSNickCpt [expr $NSNickCpt +1]
        if { $NSNickCpt > $NSNickMax } {
            set NSNickCpt 1
        }
        utimer 1 NS:CheckWho
    }
}



#--------------------------------------------------------------------------------
#
# Controle le nick. Le kill si nécessaire, ou ajoute le tps
#
#--------------------------------------------------------------------------------
proc NSCheck { NSCheckNick NSCheckUserhost } {
    global NS NSNickBeKill NSNickBeNotice NSListeNick

    set NSCheckResult $NSListeNick([string tolower $NSCheckNick])
    set NSCheckNickModif $NSCheckNick[expr [rand 899]+100]
    if { [lindex $NSCheckResult 1] == 1 } {
        set NSNickBeKill [join $NSNickBeKill]
        set NSListeNick([string tolower $NSCheckNick]) "[lindex $NSCheckResult 0] [lindex $NSCheckResult 1]"
        putloglev 3 * "\[NickServ\] (3CHANGE nick) $NSCheckNick -> $NSCheckNickModif ($NSCheckUserhost)"
        putserv "NOTICE $NSCheckNick :$NS(result)"
        putserv "NICK $NSCheckNick $NSCheckNickModif"
        if { $NS(globops) } { putserv "GLOBOPS :\[NickServ\] $NSCheckNick -> $NSCheckNickModif ($NSCheckUserhost)" }

    } elseif { [lindex $NSCheckResult 2] == "" } {
        set NSNickBeNotice [join $NSNickBeNotice]
        set NSListeNick([string tolower $NSCheckNick]) "$NSCheckResult [expr [clock seconds] + $NS(Temps)]"
        putloglev 3 * "\[NickServ\] (6Add Time) $NSCheckNick ($NSCheckUserhost)"
        putserv "NOTICE $NSCheckNick :$NS(avertos)"

    } elseif { [clock seconds] > [lindex $NSCheckResult 2] } {
        set NSNickBeKill [join $NSNickBeKill]
        set NSListeNick([string tolower $NSCheckNick]) "[lindex $NSCheckResult 0] [lindex $NSCheckResult 1]"
        putloglev 3 * "\[NickServ\] (3CHANGE nick) $NSCheckNick -> $NSCheckNickModif ($NSCheckUserhost)"
        putserv "NOTICE $NSCheckNick :$NS(result)"
        putserv "NICK $NSCheckNick $NSCheckNickModif"
        if { $NS(globops) } { putserv "GLOBOPS :\[NickServ\] $NSCheckNick -> $NSCheckNickModif ($NSCheckUserhost)" }

    } else {
        putloglev 3 * "\[NickServ\] (7Waiting [expr [lindex $NSCheckResult 2] - [clock seconds]]/$NS(Temps) s) $NSCheckNick ($NSCheckUserhost)"
    }
}




#--------------------------------------------------------------------------------
#
# Utilisation [NSNickIsOnList <nick_désiré>]
# Procédure permettant de vérifier si ce nick est un nick à protéger
#
#--------------------------------------------------------------------------------

proc NSNickIsOnList { NSTestNick } {
    global NSChainNick

    set NSTestNick [string tolower $NSTestNick]

    foreach i $NSChainNick {
        set i [string tolower $i]
        if { $i == $NSTestNick } {
            return 1
        }
    }
    return 0
}


#--------------------------------------------------------------------------------
#
# Utilisation [NSMaskIsOnList <host_désiré>]
# Procédure permettant de vérifier si ce mask est ds la liste des AntiKills
#
#--------------------------------------------------------------------------------

proc NSMaskIsOnList { NSTestMask } {

    global NSChainHost

    set NSTestMask [string tolower $NSTestMask]

    foreach i $NSChainHost {
        set i [string tolower $i]
        if { [string match $i $NSTestMask] } {
            return 1
        }
    }
    return 0

}



#--------------------------------------------------------------------------------
#
# Utilisation [IsOnChannel <nick> <channel>]
# Procédure permettant de vérifier si le nick se trouve sur tel salon
#
#--------------------------------------------------------------------------------
proc nojoin { text } {
  regsub -all -- {\\} $text {\\\\} text
  regsub -all -- {\{} $text {\{} text
  regsub -all -- {\}} $text {\}} text
  regsub -all -- {\[} $text {\[} text
  regsub -all -- {\]} $text {\]} text
  return "$text"
}

proc IsOnChannel { IsOnChannelNick } {
    global NSChainChan

    set IsOnChannelNick [string tolower $IsOnChannelNick]

    foreach i $NSChainChan {
        if { [validchan $i] } {
            if { [botonchan $i] && [onchan $IsOnChannelNick $i] } {
               return 1
            }
        }
    }
    return 0
}



#--------------------------------------------------------------------------------
#
# Auto lancement du NickServ
#
#--------------------------------------------------------------------------------

proc NS:execNickServ { } {
    global NS
    if { $NS(start) } {
        if { $NS(globops) } { putserv "GLOBOPS :\[NickServ\] Lancement du NickServ! (NS2.tcl)" }
        utimer 10 NS:CheckWho
    }
}


NS:execNickServ
