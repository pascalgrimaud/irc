#
# SpyLog.tcl - Ibu <ibu_lordaeron@yahoo.fr>
#
# TCL utilisé en tant que Loggueur
#



#################
# Configuration #
#################

# répertoire system
set rep_system "system"

# Entrez le répertoire où seront stockés les logs (chemin complet) sans / à la fin
set DossierDesLogs "logs"

# mode debug
set Spy(debug) 0



##################
# Initialisation #
##################

# Initialisation des Hosts
#
#   --> SpyChainHost
#
proc Spy:host:init { } {
    global rep_system SpyChainHost

    set SpyChainHost ""

    if {[file exists $rep_system/Spy-Hosts.conf] == 0} {
        set LectureFichierTemp [open $rep_system/Spy-Hosts.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/Spy-Hosts.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierHostLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierHostInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierHostLu != ""} {

            lappend SpyChainHost $LectureFichierHostLu
            set SpyChainHost [join $SpyChainHost]
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierHostLu
    unset LectureFichierHostInfo

    return
}


# Initialisation des Channels
#
#   --> SpyChainChan
#
proc Spy:chan:init { } {
    global rep_system SpyChainChan

    set SpyChainChan ""

    if {[file exists $rep_system/Spy-Chans.conf] == 0} {
        set LectureFichierTemp [open $rep_system/Spy-Chans.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/Spy-Chans.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierChanLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierChanInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierChanLu != ""} {

            lappend SpyChainChan $LectureFichierChanLu
            set SpyChainChan [join $SpyChainChan]
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierChanLu
    unset LectureFichierChanInfo

    return
}


Spy:host:init
Spy:chan:init 



########
# Motd #
########

putlog "SpyLog.tcl - Use .spyhelp"



########
# Logs #
########

# Join
bind join - * Spy:PubChkJoin
proc Spy:PubChkJoin {nick uhost handle channel} {
    spy:pub $nick $uhost JOIN $channel aucun
}

# Part
bind part - * Spy:PubChkPart
proc Spy:PubChkPart {nick uhost handle channel msg} {
    spy:pub $nick $uhost PART $channel $msg
}

# Sign
bind sign - * Spy:PubChkSign
proc Spy:PubChkSign {nick uhost handle channel msg} {
    spy:pub $nick $uhost QUIT $channel $msg
}

# Notice
bind raw - NOTICE Spy:PubChkNOT
proc Spy:PubChkNOT {from keyword arg} {
    set from [split $from !]
    spy:pub [lindex $from 0] [lindex $from 1] NOTICE [lindex $arg 0] [lrange $arg 1 end]
}

# action
bind ctcp - ACTION Spy:PubChkACTSND
proc Spy:PubChkACTSND {nick uhost hand dest keyword text} {
    if {[string match &* $dest] || [string match #* $dest]} {
        spy:pub $nick $uhost ACTION $dest $text
    }
}

# message
bind pubm -|- * spy:pub
proc spy:pub { nick host hand channel text } {
    global DossierDesLogs Spy

    if { [IsOnChanSpy $channel] && [validchan $channel] } {
        if { [IsSpy $host] } {
            if { $hand == "JOIN" } {
                FichierAddInfoForce "$DossierDesLogs/$channel.[clock format [clock seconds] -format "%d%m%y"]" "[clock format [clock seconds] -format "\[%H:%M:%S\]"]" "*** (Join) $nick ($host)"
            } elseif { $hand == "PART" } {
                FichierAddInfoForce "$DossierDesLogs/$channel.[clock format [clock seconds] -format "%d%m%y"]" "[clock format [clock seconds] -format "\[%H:%M:%S\]"]" "*** (Part) $nick ($host)"
            } elseif { $hand == "QUIT" } {
                FichierAddInfoForce "$DossierDesLogs/$channel.[clock format [clock seconds] -format "%d%m%y"]" "[clock format [clock seconds] -format "\[%H:%M:%S\]"]" "*** (Quit) $nick ($host) ($text)"
            } elseif { $hand == "ACTION" } {
                FichierAddInfoForce "$DossierDesLogs/$channel.[clock format [clock seconds] -format "%d%m%y"]" "[clock format [clock seconds] -format "\[%H:%M:%S\]"]" "* $nick ($host) $text"
            } elseif { $hand == "NOTICE" } {
                FichierAddInfoForce "$DossierDesLogs/$channel.[clock format [clock seconds] -format "%d%m%y"]" "[clock format [clock seconds] -format "\[%H:%M:%S\]"]" "-$nick ($host)- $text"
            } else {
                FichierAddInfoForce "$DossierDesLogs/$channel.[clock format [clock seconds] -format "%d%m%y"]" "[clock format [clock seconds] -format "\[%H:%M:%S\]"]" "<$nick ($host)> $text"
            }
            if { $Spy(debug) == 1 } { putlog "(DEBUG) Ajout ds Fichier" }
        } else {
            if { $Spy(debug) == 1 } { putlog "(DEBUG) Mask non correspondant" }
        }
    } else {
        if { $Spy(debug) == 1 } { putlog "(DEBUG) Chan Invalid" }
    }
    
    return 1
}



########
# Aide #
########
bind dcc -|- spyhelp Spy:help

proc Spy:help {hand idx arg} {
    putdcc $idx " "
    putdcc $idx "     SpyLog.tcl (v1.1) - Aide     "
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Utilisé en tant que Loggueur:"
    putdcc $idx "   - Join/Part/Quit/Mess/Action/Notice"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .\[+/-\]spy <user@host> 14(ajouter/retirer les masks des loggués)"
    putdcc $idx "  .\[+/-\]spychan <#channel> 14(ajouter/retirer un channel à logguer)"
    putdcc $idx " "
    putdcc $idx ".spyhelp <-- Aide, vous êtes ici!"
    putdcc $idx " "
    return 1
}



###################
# Ajouter un Host #
###################
bind dcc o +spy Spy:host:add

proc Spy:host:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Spy:FichierAddInfo $rep_system/Spy-Hosts.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[Spy: Add Hosts\]\002 ::: $tempnick a été modifié!"
        } else {
            putdcc $idx "\002\[Spy: Add Hosts\]\002 ::: $tempnick a été ajouté!"
        }
        Spy:host:init
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+spy <user@host>"
        return 0
    }
}

###################
# Retirer un Host #
###################
bind dcc o -spy Spy:host:del

proc Spy:host:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Spy:FichierRemInfo $rep_system/Spy-Hosts.conf $tempnick] == 1 } {
            putdcc $idx "\002\[Spy: Del Hosts\]\002 ::: $tempnick a été effacé!"
            Spy:host:init
            return 1
        } else {
            putdcc $idx "\002\[Spy: Del Hosts\]\002 ::: $tempnick n'a pas été trouvé!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-spy <user@host>"
        return 0
    }
}

###################
# Liste les Hosts #
###################
bind dcc - spy Spy:host:list

proc Spy:host:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Hosts des Hosts Spys\002:"
    Spy:FichierLecture $idx $rep_system/Spy-Hosts.conf
    putdcc $idx " "
    return 1
}



###################
# Ajouter un Chan #
###################
bind dcc n +spychan Spy:chan:add

proc Spy:chan:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Spy:FichierAddInfo $rep_system/Spy-Chans.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[Spy: Add Chans\]\002 ::: $tempnick a été modifié!"
        } else {
            putdcc $idx "\002\[Spy: Add Chans\]\002 ::: $tempnick a été ajouté!"
        }
        Spy:chan:init
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+spychan <#channel>"
        return 0
    }
}

###################
# Retirer un Chan #
###################
bind dcc n -spychan Spy:chan:del

proc Spy:chan:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Spy:FichierRemInfo $rep_system/Spy-Chans.conf $tempnick] == 1 } {
            putdcc $idx "\002\[Spy: Del Chans\]\002 ::: $tempnick a été effacé!"
            Spy:chan:init
            return 1
        } else {
            putdcc $idx "\002\[Spy: Del Chans\]\002 ::: $tempnick n'a pas été trouvé!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-spychan <#channel>"
        return 0
    }
}

###################
# Liste les Chans #
###################
bind dcc n spychan Spy:chan:list

proc Spy:chan:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Chans Spys\002:"
    Spy:FichierLecture $idx $rep_system/Spy-Chans.conf
    putdcc $idx " "
    return 1
}



##############
# Procédures #
##############

proc IsSpy { hostmask } {
    global SpyChainHost

    set hostmask [string tolower $hostmask]
    foreach i $SpyChainHost {
        set i [string tolower $i]
        if { [string match $i $hostmask] } {
            return 1
        }
    }
    return 0
}

proc IsOnChanSpy { channel } {
    global SpyChainChan

    set channel [string tolower $channel]
    foreach i $SpyChainChan {
        set i [string tolower $i]
        if { [string match $i $channel] } {
            return 1
        }
    }
    return 0
}

proc Spy:FichierAddInfo { AddInfoFichier AddInfoNick AddInfoInfo } {
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

    Spy:FichierCopy "$rep_system/temp.txt" $AddInfoFichierAcces

    unset AddInfoTexteLu
    unset AddInfoNickLu
    unset AddInfoInfoLu
    
    return $AddInfoNickTrouve
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

proc Spy:FichierRemInfo { RemInfoFichier RemInfoNick } {
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

    Spy:FichierCopy "$rep_system/temp.txt" $RemInfoFichierAcces 

    unset RemInfoTexteLu
    unset RemInfoNickLu
    unset RemInfoInfoLu

    return $RemInfoNickTrouve
}

proc Spy:FichierCopy { CopyFichierAcces CopyFichierAcces2 } {
    file copy -force $CopyFichierAcces $CopyFichierAcces2
    return
}

proc Spy:FichierLecture { LectureIdx LectureFichierAcces } {

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
