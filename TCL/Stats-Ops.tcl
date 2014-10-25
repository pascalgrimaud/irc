#
# Stats-Ops.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Tcl donnant le tps de modération (en min) de l'ensemble des Opérateurs du salon
# Stats regroupés par semaine
#



#################
# Configuration #
#################

# répertoire system
set rep_system "system"

# fichier de log
set statsops(logfile) "logs/stats"

# salon à stats
set statsops(channel) "#!40-50ans!"

# debug
set statsops(debug) 0



########
# Motd #
########

putlog "\002Stats-Ops.tcl\002 par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"
putlog "   Aide -> \002.sthelp\002"



##################
# Initialisation #
##################

# Initialisation des Nicks à protéger
#
#   --> StatsOpsChainNick
#   --> StatsOpsListeNick
#
proc statsops:init { } {
    global rep_system StatsOpsChainNick StatsOpsListeNick

    set StatsOpsChainNick ""

    if {[file exists $rep_system/StatsOps-Nicks.conf] == 0} {
        set LectureFichierTemp [open $rep_system/StatsOps-Nicks.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/StatsOps-Nicks.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierNickLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierNickInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierNickLu != ""} {

            lappend StatsOpsChainNick $LectureFichierNickLu
            set StatsOpsChainNick [join $StatsOpsChainNick]
            set StatsOpsListeNick([string tolower $LectureFichierNickLu]) "$LectureFichierNickLu $LectureFichierNickInfo"
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierNickLu
    unset LectureFichierNickInfo

    return
}

statsops:init


##################################
# Timer de controle : par minute #
##################################

proc statsops:autochk { } {
    global statsops

    if { [botonchan $statsops(channel)] } {
        statsops:eval $statsops(channel)
    }
    timer 1 statsops:autochk
    return
}

timer 1 statsops:autochk


##############
# Evaluation #
##############

proc statsops:eval { evalchannel } {
    global statsops StatsOpsChainNick StatsOpsListeNick

    if { $statsops(debug) } { putlog "(Debug) statsops:eval lancé!" }

    if { [string match *$evalchannel* $statsops(channel)] } {

        if { $statsops(debug) } { putlog "(Debug) test salon passé!" }

        foreach j [chanlist $evalchannel] {
            if { [isop $j $evalchannel] } {
                if { $statsops(debug) } { putlog "(Debug) $j est opé sur $evalchannel" }

                foreach k $StatsOpsChainNick {
                    if { $statsops(debug) } { putlog "(Debug) parcours de la liste des Hosts : $k" }

                    set StatsOpsIdfile [lrange $StatsOpsListeNick([string tolower $k]) 0 0]
                    set StatsOpsMask [lrange $StatsOpsListeNick([string tolower $k]) 1 1]
                    if { [string match [string tolower $StatsOpsMask] [string tolower [getchanhost $j]]] } {
                        if { $statsops(debug) } { putlog "(Debug) mask reconnu! $StatsOpsMask [getchanhost $j]" }
                        set logfile $statsops(logfile)-[clock format [clock seconds] -format "%U"].log
                        statsops:FichierAddInfo:Stats $logfile $StatsOpsIdfile
                    } else {
                        if { $statsops(debug) } { putlog "(Debug) mask inconnu! $StatsOpsMask [getchanhost $j]" }
                    }
                }
            }
        }
    }
}



########
# Aide #
########
bind dcc -|- sthelp statsops:help

proc statsops:help {hand idx arg} {
    putdcc $idx " "
    putdcc $idx "     Stats-Ops.tcl - Aide     "
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Log les Stats de Modérations des Opérateurs"
    putdcc $idx "   regroupé par semaine et en minutes"
    putdcc $idx "   Un timer regarde toutes les minutes, et évalue les opérateurs"
    putdcc $idx "   présent sur le salon, selon leur Host"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .\[+/-\]sthost <IdNick> <user@host> 14(ajouter/retirer les masks pour les Stats)"
    putdcc $idx " "
    putdcc $idx ".sthelp <-- Aide, vous êtes ici!"
    putdcc $idx " "
    return 1
}



###################
# Ajouter un Host #
###################
bind dcc o +sthost statsops:host:add

proc statsops:host:add { hand idx arg } {
    global rep_system

    set arg [nojoin $arg]
    set tempnick [lindex $arg 0]
    set tempinfo [join [lrange $arg 1 end]]

    if { $tempnick != "" } {
        if { [statsops:FichierAddInfo $rep_system/StatsOps-Nicks.conf $tempnick $tempinfo] == 1 } {
            putdcc $idx "\002\[StatsOps: Add Hosts\]\002 ::: $tempnick a été modifié!"
        } else {
            putdcc $idx "\002\[StatsOps: Add Hosts\]\002 ::: $tempnick a été ajouté!"
        }
        statsops:init
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+sthost <idnick> <user@host>"
        return 0
    }
}

###################
# Retirer un Host #
###################
bind dcc o -sthost statsops:host:del

proc statsops:host:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [statsops:FichierRemInfo $rep_system/StatsOps-Nicks.conf $tempnick] == 1 } {
            putdcc $idx "\002\[StatsOps: Del Hosts\]\002 ::: $tempnick a été effacé!"
            statsops:init
            return 1
        } else {
            putdcc $idx "\002\[StatsOps: Del Hosts\]\002 ::: $tempnick n'a pas été trouvé!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-sthost <idnick>"
        return 0
    }
}

###################
# Liste les Hosts #
###################
bind dcc - sthost statsops:host:list

proc statsops:host:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des StatsOps\002:"
    statsops:FichierLecture $idx $rep_system/StatsOps-Nicks.conf
    putdcc $idx " "
    return 1
}



#####################################
# Procédures de gestion de fichiers #
#####################################

proc statsops:FichierAddInfo { AddInfoFichier AddInfoNick AddInfoInfo } {
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

    statsops:FichierCopy "$rep_system/temp.txt" $AddInfoFichierAcces

    unset AddInfoTexteLu
    unset AddInfoNickLu
    unset AddInfoInfoLu
    
    return $AddInfoNickTrouve
}

proc statsops:FichierAddInfo:Stats { AddInfoFichier AddInfoNick } {
    global rep_system

    set AddInfoNickTrouve 0

    set AddInfoFichierAcces "$AddInfoFichier"
    set AddInfoFichierAcces2 "$rep_system/temp.txt"

    set AddInfoNick [join $AddInfoNick]

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
                puts $AddInfoTemp2 "$AddInfoNick [expr $AddInfoInfoLu + 1]"
                set AddInfoNickTrouve 1
            }
        } else {
            if { $AddInfoNickLu != "" } { puts $AddInfoTemp2 "$AddInfoNickLu $AddInfoInfoLu" }
        }
    }

    if {$AddInfoNickTrouve == 0 && $AddInfoNick != "" } {
        puts $AddInfoTemp2 "$AddInfoNick 1"
    }
    close $AddInfoTemp
    close $AddInfoTemp2

    statsops:FichierCopy "$rep_system/temp.txt" $AddInfoFichierAcces

    unset AddInfoTexteLu
    unset AddInfoNickLu
    unset AddInfoInfoLu
}

proc FichierAddInfoForce { AddInfoFichier AddInfoNick AddInfoInfo } {

    if { [file exists $AddInfoFichier] == 0 } {
        set AddInfoTemp [open $AddInfoFichier w+]
        puts $AddInfoTemp "$AddInfoNick $AddInfoInfo"
        close $AddInfoTemp
    } else {
        set AddInfoTemp [open $AddInfoFichier a+]
        puts $AddInfoTemp "$AddInfoNick $AddInfoInfo"
        close $AddInfoTemp
    }
    return
}

proc statsops:FichierRemInfo { RemInfoFichier RemInfoNick } {
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

    statsops:FichierCopy "$rep_system/temp.txt" $RemInfoFichierAcces 

    unset RemInfoTexteLu
    unset RemInfoNickLu
    unset RemInfoInfoLu

    return $RemInfoNickTrouve
}

proc statsops:FichierCopy { CopyFichierAcces CopyFichierAcces2 } {
    file copy -force $CopyFichierAcces $CopyFichierAcces2
    return
}

proc statsops:FichierLecture { LectureIdx LectureFichierAcces } {

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


#--------------------------------------------------------------------------------
#
# Procédure qui retourne l'info complète si on trouve une ligne du fichier commençant
#  par "info" donné en paramètre. Sinon, retourne rien.
#
# Utilisation:
#  FichierInfo <fichier> <info>
#
#--------------------------------------------------------------------------------

proc statsops:FichierInfo { InfoFichier InfoInfo } {
  global system
    set InfoInfoTrouvee 0

    set InfoFichierAcces "$system/$InfoFichier.txt"
    if {[file exists $InfoFichierAcces] == 0} {
        set InfoTemp [open $InfoFichierAcces w+]
        close $InfoTemp
    }

    set InfoTemp "[open $InfoFichierAcces r+]"
    while {![eof $InfoTemp]} {
        set InfoTexteLu [gets $InfoTemp]
        set InfoInfoLue [join [lrange $InfoTexteLu 0 0]]
        set InfoInfoComplete [join [lrange $InfoTexteLu 1 end]]
        if {[string tolower $InfoInfoLue] == [string tolower $InfoInfo]} {
            set InfoInfoTrouvee 1
            set InfoInfoComplete2 $InfoInfoComplete
        }
    } 
    close $InfoTemp

    unset InfoTexteLu
    unset InfoInfoLue

    if { $InfoInfoTrouvee == 0 } {
        return ""
    } else {
        return $InfoInfoComplete2
    }
    complete
}