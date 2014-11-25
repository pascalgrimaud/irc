#
# NS.tcl (v1.21) par Ibu <ibu_lordaeron@yahoo.fr>
#
# Ce script sert de NickServ.
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
# PS: ce tps peut largement être dépassé selon la liste du WHO
set NS(Temps) 30

# Message d'avertos
set NS(Avertos) "\[Information\] Ce pseudo appartient à un Opérateur -ou bien- ne correspond pas aux pseudos tolérés ici. Merci de bien vouloir changer de pseudo, en tapant: /nick nouveau_pseudo"

# Raison du kill
set NS(KillRaison) "Nick refusé!"


# Le NickServ est lancé dès le rehash
# il est conseillé de le mettre à 0, car lors d'un restart, l'egg rejoint une liste de salon
# et risque de scanner toul monde. S'il n'est pas authé IRCopérateur... ca va le faire ramer
set NS(start) 1



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

# Initialisation des Scans Host
#
#   --> NSChainScan
#
proc NS:scan:init { } {
    global rep_system NSChainScan

    set NSChainScan ""

    if {[file exists $rep_system/NS-Scans.conf] == 0} {
        set LectureFichierTemp [open $rep_system/NS-Scans.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/NS-Scans.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierScanLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierScanInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierScanLu != ""} {

            lappend NSChainScan $LectureFichierScanLu
            set NSChainScan [join $NSChainScan]
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierScanLu
    unset LectureFichierScanInfo

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
    global NSNickMax NSListCpt NSChainScan
    set NSNickMax 0

    foreach i $NSChainScan {
        set NSNickMax [expr $NSNickMax + 1]
        set NSListCpt($NSNickMax) "$i"
    }
    return
}

NS:nick:init
NS:scan:init
NS:host:init
NS:chan:init
NS:scancpt:init

set NSNickCpt 1



########
# Motd #
########

putlog "\002NS.tcl\002 (v1.21) par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"

if {$NS(start)} {
    putlog "   Aide --> .ns -- \[Status\] -> NickServ Activaté"
} else {
    putlog "   Aide --> .ns -- \[Status\] -> NickServ DesActivé"
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
    putdcc $idx "     NS.tcl (v1.21) - Aide     "
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Script utilisé en tant que NickServ :"
    putdcc $idx "   - vérifie par WHO une liste de Hosts"
    putdcc $idx "   - vérifie les nicks & leur identité"
    putdcc $idx "   - kill les nicks si nécessaire"
    putdcc $idx " "
    putdcc $idx "   Mode console +3 pour voir l'évolution du NS."
    putdcc $idx " "
    putdcc $idx "   NOTE: L'Eggdrop doit être authé IRCop"
    putdcc $idx "   ( .xoper & .xunoper -> cf .xoperhelp ds EggOper.tcl )"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .\[+/-\]nsnick <nick> <status: 0/1> 14(ajouter/retirer/lister un nick à protéger)"
    putdcc $idx "  .\[+/-\]nsscan <mask> 14(ajouter/retirer/lister les masks à scanner)"
    putdcc $idx "  .\[+/-\]nshost <user@host> 14(ajouter/retirer/lister les Hosts protégés)"
    putdcc $idx "  .\[+/-\]nschan <#channel> 14(ajouter/retirer/lister un chan protecteur)"
    putdcc $idx "  .nickserv 14(activer/desactiver le NickServ)"
    if {$NS(start)} {
        putdcc $idx "      \[Status\] -> NickServ Activaté"
    } else {
        putdcc $idx "      \[Status\] -> NickServ DesActivé"
    }
    putdcc $idx " "
    putdcc $idx "  .ns <-- Aide, vous êtes ici!"
    putdcc $idx " "
    return 1
}


####################
# Active/Desactive #
####################
bind dcc m|- nickserv NS:dcc:act

proc NS:dcc:act {hand idx args} {
    global NS

    if {$NS(start)} {
        set NS(start) 0
        putlog "#$hand# NickServ -> DesActivé"
    } else {
        set NS(start) 1
        putlog "#$hand# NickServ -> Activé"
        NS:CheckWho
    }
    return 0
}


###################
# Ajouter un Nick #
###################
bind dcc n +nsnick NS:nick:add

proc NS:nick:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]
    set tempstatus [join [lrange $arg 1 1]]
    if { $tempstatus != "" } {
        if { [NS:FichierAddInfo $rep_system/NS-Nicks.conf $tempnick $tempstatus] == 1 } {
            putdcc $idx "\002\[NS: Add Nicks\]\002 ::: $tempnick a été modifié! - Status: $tempstatus"
        } else {
            putdcc $idx "\002\[NS: Add Nicks\]\002 ::: $tempnick a été ajouté! - Status: $tempstatus"
        }
        NS:nick:init
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+nsnick <nick> <status: 0/1>"
        return 0
    }

}


###################
# Retirer un Nick #
###################
bind dcc n -nsnick NS:nick:del

proc NS:nick:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierRemInfo $rep_system/NS-Nicks.conf $tempnick] == 1 } {
            putdcc $idx "\002\[NS: Del Nicks\]\002 ::: $tempnick a été effacé!"
            NS:nick:init
            return 1
        } else {
            putdcc $idx "\002\[NS: Del Nicks\]\002 ::: $tempnick n'a pas été trouvé!"
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
bind dcc n nsnick NS:nick:list

proc NS:nick:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Nicks protégés\002:"
    NS:FichierLecture $idx $rep_system/NS-Nicks.conf
    putdcc $idx " "
    return 1
}


###################
# Ajouter un Scan #
###################
bind dcc n +nsscan NS:scan:add

proc NS:scan:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierAddInfo $rep_system/NS-Scans.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[NS: Add Scans\]\002 ::: $tempnick a été modifié!"
        } else {
            putdcc $idx "\002\[NS: Add Scans\]\002 ::: $tempnick a été ajouté!"
        }
        NS:scan:init
        NS:scancpt:init
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+nsscan <host>"
        return 0
    }
}


###################
# Retirer un Scan #
###################
bind dcc n -nsscan NS:scan:del

proc NS:scan:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierRemInfo $rep_system/NS-Scans.conf $tempnick] == 1 } {
            putdcc $idx "\002\[NS: Del Scans\]\002 ::: $tempnick a été effacé!"
            NS:scan:init
            NS:scancpt:init
            return 1
        } else {
            putdcc $idx "\002\[NS: Del Scans\]\002 ::: $tempnick n'a pas été trouvé!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-nsscan <host>"
        return 0
    }
}

###################
# Liste les Scans #
###################
bind dcc n nsscan NS:scan:list

proc NS:scan:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Hosts scannés\002:"
    NS:FichierLecture $idx $rep_system/NS-Scans.conf
    putdcc $idx " "
    return 1
}


###################
# Ajouter un Host #
###################
bind dcc n +nshost NS:host:add

proc NS:host:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierAddInfo $rep_system/NS-Hosts.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[NS: Add Hosts\]\002 ::: $tempnick a été modifié!"
        } else {
            putdcc $idx "\002\[NS: Add Hosts\]\002 ::: $tempnick a été ajouté!"
        }
        NS:host:init
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+nshost <user@host>"
        return 0
    }
}


###################
# Retirer un Host #
###################
bind dcc n -nshost NS:host:del

proc NS:host:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierRemInfo $rep_system/NS-Hosts.conf $tempnick] == 1 } {
            putdcc $idx "\002\[NS: Del Hosts\]\002 ::: $tempnick a été effacé!"
            NS:host:init
            return 1
        } else {
            putdcc $idx "\002\[NS: Del Hosts\]\002 ::: $tempnick n'a pas été trouvé!"
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
bind dcc n nshost NS:host:list

proc NS:host:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Hosts protégés\002:"
    NS:FichierLecture $idx $rep_system/NS-Hosts.conf
    putdcc $idx " "
    return 1
}


###################
# Ajouter un Chan #
###################
bind dcc n +nschan NS:chan:add

proc NS:chan:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierAddInfo $rep_system/NS-Chans.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[NS: Add Chans\]\002 ::: $tempnick a été modifié!"
        } else {
            putdcc $idx "\002\[NS: Add Chans\]\002 ::: $tempnick a été ajouté!"
        }
        NS:chan:init
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+nschan <#channel>"
        return 0
    }
}


###################
# Retirer un Chan #
###################
bind dcc n -nschan NS:chan:del

proc NS:chan:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [NS:FichierRemInfo $rep_system/NS-Chans.conf $tempnick] == 1 } {
            putdcc $idx "\002\[NS: Del Chans\]\002 ::: $tempnick a été effacé!"
            NS:chan:init
            return 1
        } else {
            putdcc $idx "\002\[NS: Del Chans\]\002 ::: $tempnick n'a pas été trouvé!"
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
bind dcc n nschan NS:chan:list

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

set NSNickBeNotice ""
set NSNickBeKill ""

#--------------------------------------------------------------------------------
#
# Scan par WHO des nicks protégés - Gestion des RAWS
#
#--------------------------------------------------------------------------------
proc NS:CheckWho { } {
    global NS NSListCpt NSNickCpt

    if { $NS(start) && [info exists NSListCpt($NSNickCpt)] } {
        putserv "WHO $NSListCpt($NSNickCpt) x"
    }
}


#
# RAW -> (481)
#
bind raw - "481" NSKillImpossible

proc NSKillImpossible {from key text} {
    putlog "\[\002Info\002\] [lrange $text 1 end]"
}

#
# RAW -> (352)
#
bind raw - "352" NSWhoCheck

proc NSWhoCheck {from key text} {
    global NS NSListeNick

    if {$NS(start) && $text != ""} {

        regsub -all {\\} $text {\\\\} text
        regsub -all {\{} $text {\{} text
        regsub -all {\}} $text {\}} text
        regsub -all {\]} $text {\]} text
        regsub -all {\[} $text {\[} text
        regsub -all {\"} $text {\"} text

        # initialisation des variables: nick, identd, host, etc.. pour pouvoir les tester
        set NSIdent [string tolower [lindex $text 2]]
        set NSNick [lindex $text 5]
        set NSMask [lindex $text 3]
        set NSStatus [lindex $text 6]
        set NSIRCop [lindex [split "$NSStatus" @+diwg] 0]
        if { [string match *\\* $NSIRCop] } {
            set NSIRCop 1
        } else {
            set NSIRCop 0
        }

        # test du nick, si c un nick protégé, si c un mask protégé, etc..
        set NSonQG [IsOnChannel $NSNick]
        set NSonlist [NSNickIsOnList $NSNick]
        set NSonmask [NSMaskIsOnList $NSIdent@$NSMask]
  
        if { $NSonmask == 0 } {
            set NSonmask [NSMaskIsOnList $NSIdent@[host-x $NSMask]]
        }

        if { $NSonlist == 1 } {
            if { $NSonmask == 1 } {
                putloglev 3 * "  (4Mask Protected) [lindex $text 5] ([lindex $text 2]@[lindex $text 3])"
                set NSListeNick([string tolower $NSNick]) "[lindex $NSListeNick([string tolower $NSNick]) 0] [lindex $NSListeNick([string tolower $NSNick]) 1]"
            } elseif { $NSIRCop == 1 } {
                putloglev 3 * "  (4IRCop) [lindex $text 5] ([lindex $text 2]@[lindex $text 3])"
                set NSListeNick([string tolower $NSNick]) "[lindex $NSListeNick([string tolower $NSNick]) 0] [lindex $NSListeNick([string tolower $NSNick]) 1]"
            } elseif { $NSonQG == 1 } {
                putloglev 3 * "  (4Chan Protect) [lindex $text 5] ([lindex $text 2]@[lindex $text 3])"
                set NSListeNick([string tolower $NSNick]) "[lindex $NSListeNick([string tolower $NSNick]) 0] [lindex $NSListeNick([string tolower $NSNick]) 1]"
            } else {
                NSCheck $NSNick [lindex $text 2]@[lindex $text 3]
            }
        } else {
            putloglev 3 * "  (14Not on List) [lindex $text 5] ([lindex $text 2]@[lindex $text 3])"
        }
    }
}


#
# RAW -> (315)
#
bind raw - "315" NSWhoEnd

proc NSWhoEnd {from key text} {
    global NS NSNickBeNotice NSNickBeKill NSNickCpt NSNickMax

    if {$NS(start)} {
        NoticeNick $NSNickBeNotice
        set NSNickBeNotice ""
        KillNick $NSNickBeKill
        set NSNickBeKill ""
        putloglev 3 * "10--- End Who on: [lrange $text 1 1]"

        set NSNickCpt [expr $NSNickCpt +1]
        if { $NSNickCpt > $NSNickMax } { set NSNickCpt 1 }

#        utimer 1 NS:CheckWho
        NS:CheckWho
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

    if { [lindex $NSCheckResult 1] == 1 } {
        putloglev 3 * "  (3KILL on) $NSCheckNick ($NSCheckUserhost)"
        lappend NSNickBeKill $NSCheckNick
        set NSNickBeKill [join $NSNickBeKill]
        set NSListeNick([string tolower $NSCheckNick]) "[lindex $NSCheckResult 0] [lindex $NSCheckResult 1]"
    } elseif { [lindex $NSCheckResult 2] == "" } {
        putloglev 3 * "  (6Add Time) $NSCheckNick ($NSCheckUserhost)"
        lappend NSNickBeNotice $NSCheckNick
        set NSNickBeNotice [join $NSNickBeNotice]
        set NSListeNick([string tolower $NSCheckNick]) "$NSCheckResult [expr [clock seconds] + $NS(Temps)]"
    } elseif { [clock seconds] > [lindex $NSCheckResult 2] } {
        putloglev 3 * "  (3KILL on) $NSCheckNick ($NSCheckUserhost)"
        lappend NSNickBeKill $NSCheckNick
        set NSNickBeKill [join $NSNickBeKill]
        set NSListeNick([string tolower $NSCheckNick]) "[lindex $NSCheckResult 0] [lindex $NSCheckResult 1]"
    } else {
        putloglev 3 * "  (7Waiting [expr [lindex $NSCheckResult 2] - [clock seconds]]/$NS(Temps) s) $NSCheckNick ($NSCheckUserhost)"
    }
}




#--------------------------------------------------------------------------------
#
# Procédure de kill
#
#--------------------------------------------------------------------------------

proc KillNick { NickKilled } {
    global NS

    foreach i $NickKilled {
        putserv "NOTICE $i :$NS(Avertos)"
        putserv "KILL $i :$NS(KillRaison)"
    }
    return
}

#--------------------------------------------------------------------------------
#
# Procédure de notice
#
#--------------------------------------------------------------------------------

proc NoticeNick { NickNotice } {
    global NS

    foreach i $NickNotice {
        putserv "NOTICE $i :$NS(Avertos)"
    }
    return
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

NS:CheckWho
