#
# glob.tcl (v1.2) par Ibu <ibu_lordaeron@yahoo.fr>
#



#################
# Configuration #
#################

# répertoire de sauvegarde des fichiers de config
set rep_system "system"

# chan à scanner
set GlobChan "#soho"



##################
# Initialisation #
##################

# Initialisation des Hosts
#
#   --> GlobChainHost
#
proc Glob:host:init { } {
    global rep_system GlobChainHost

    set GlobChainHost ""

    if {[file exists $rep_system/Glob-Hosts.conf] == 0} {
        set LectureFichierTemp [open $rep_system/Glob-Hosts.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/Glob-Hosts.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierHostLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierHostInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierHostLu != ""} {

            lappend GlobChainHost $LectureFichierHostLu
            set GlobChainHost [join $GlobChainHost]
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierHostLu
    unset LectureFichierHostInfo

    return
}

Glob:host:init

# Initialisation
set GlobRequest ""
set GlobRequestIdx ""
set GlobResultDispo ""
set GlobResultAway ""



########
# Motd #
########

putlog "\002glob.tcl\002 par (v1.2) par \002Ibu\002 14<ibu_lordaeron@yahoo.fr> -> \002.globhelp\002"



###########
# ChkChan #
###########

bind msg - chkchan chkchan
bind msg - stat chkchan
bind msg - stats chkchan

proc chkchan { nick uhost handle arg } {
    global chkchan GlobChan
    set arg [string tolower $arg]
    if { [onchan $nick $GlobChan] && [IsGlob $uhost] } {
        if { $arg != "" } {
            if { [validchan $arg] } {
                if { ![botonchan $arg] } {
                    putloglev 4 * "($nick!$uhost) stats $arg"
                    set chkchan($arg) $nick
                    putserv "PRIVMSG $nick :\002\[Stats\]\002 : $arg -> en cours..."
                    channel set $arg -inactive
                } else {
                    putloglev 4 * "($nick!$uhost) stats $arg"
                    putserv "PRIVMSG $nick :\002\[Stats\]\002 : $arg -> Invalid channel!"
                }
            } else {
                putloglev 4 * "($nick!$uhost) stats $arg"
                putserv "PRIVMSG $nick :\002\[Stats\]\002 : $arg -> Invalid channel!"
            }
        } else {
            putloglev 4 * "($nick!$uhost) stats $arg"
            putserv "PRIVMSG $nick :\002Syntaxe\002 : stats <#channel>"
        }
    } else {
        putlog "($nick!$uhost) won't to stats channel..."
    }
}

#bind raw - "352" chklist
bind raw - "315" chklist

proc chklist { from key text } {
    global botnick chkchan
    set ChkChannel [string tolower [lindex $text 1]]

    if { [info exists chkchan($ChkChannel)] } {

        set NbOps($ChkChannel) 0
        set NbVoices($ChkChannel) 0
        set NbUsers($ChkChannel) 0
        set NbTotal($ChkChannel) [llength [chanlist $ChkChannel]]

        foreach i [chanlist [lindex $text 1]] {
            if { [isop $i [lindex $text 1]] } {
                incr NbOps($ChkChannel)
            } elseif { [isvoice $i [lindex $text 1]] } {
                incr NbVoices($ChkChannel)
            } else {
                incr NbUsers($ChkChannel)
            }
        }
        putserv "PRIVMSG $chkchan($ChkChannel) :\002\[Stats\]\002 : [lindex $text 1] -> Ops($NbOps($ChkChannel)) Voices($NbVoices($ChkChannel)) Users($NbUsers($ChkChannel)) Total($NbTotal($ChkChannel))"

        unset NbOps($ChkChannel)
        unset NbVoices($ChkChannel)
        unset NbUsers($ChkChannel)
        unset NbTotal($ChkChannel)
        unset chkchan($ChkChannel)
        unset ChkChannel

        channel set [lindex $text 1] +inactive
    }
    return
}



#########
# .glob #
#########

proc IsGlob { hostmask } {
    global GlobChainHost

    set hostmask [string tolower $hostmask]
    foreach i $GlobChainHost {
        set i [string tolower $i]
        if { [string match $i $hostmask] } {
            return 1
        }
    }
    return 0
}


# .glob en Partyline
bind dcc -|- glob GlobExe:dcc:Find

proc GlobExe:dcc:Find {hand idx arg} {
    global GlobRequest GlobRequestIdx GlobChan GlobResultDispo GlobResultAway GlobList
    set GlobRequestIdx $idx
    set GlobRequest ""

    set GlobResultDispo ""
    set GlobResultAway ""
    putserv "WHO $GlobChan"
    putlog "#$hand# glob"
}

# .glob sur #soho
bind pub - .glob GlobExe:Find

proc GlobExe:Find { nick uhost handle channel arg } {
    global GlobRequest GlobRequestIdx GlobChan GlobResultDispo GlobResultAway GlobList
    if { [string tolower $channel] == "#soho" || [string tolower $channel] == "#riva" } {
        set GlobRequestIdx ""
        set GlobRequest $nick

        set GlobResultDispo ""
        set GlobResultAway ""
        putserv "WHO $GlobChan"
    }
}

bind raw - "352" GlobWhoCheck

proc GlobWhoCheck {from key text} {
    global GlobRequest GlobRequestIdx GlobChan GlobResultDispo GlobResultAway GlobChainHost

    if { [info exists GlobRequestIdx] || [info exists GlobRequest] } {
    if { $GlobRequestIdx != "" || $GlobRequest != "" } {
        regsub -all {\\} $text {\\\\} text
        regsub -all {\{} $text {\{} text
        regsub -all {\}} $text {\}} text
        regsub -all {\]} $text {\]} text
        regsub -all {\[} $text {\[} text
        regsub -all {\"} $text {\"} text

        set GlobIdent [string tolower [lindex $text 2]]
        set GlobHost [lindex $text 3]
        set GlobNick [lindex $text 5]
        set GlobStatus [lindex $text 6]
        set GlobMask $GlobIdent@$GlobHost

        if { [IsGlob $GlobMask] } {
            if {[string match "*G*" $GlobStatus]} {
                lappend GlobResultAway $GlobNick
            } else {
                lappend GlobResultDispo $GlobNick
            }
        }
    }
    }
}

bind raw - "315" GlobWhoEnd

proc GlobWhoEnd {from key text} {
    global GlobRequest GlobRequestIdx GlobChan GlobResultDispo GlobResultAway GlobList
    if { $GlobRequestIdx != "" } {
        putdcc $GlobRequestIdx "Liste des Globaux :"
        putdcc $GlobRequestIdx "   Dispo : [join $GlobResultDispo]"
        putdcc $GlobRequestIdx "   Away : [join $GlobResultAway]"
    } else {
        putserv "NOTICE $GlobRequest :Liste des Globaux :"
        putserv "NOTICE $GlobRequest :   Dispo : [join $GlobResultDispo]"
        putserv "NOTICE $GlobRequest :   Away : [join $GlobResultAway]"
    }
    set GlobRequest ""
    set GlobRequestIdx ""
    set GlobResultDispo ""
    set GlobResultAway ""
}



########
# Aide #
########
bind dcc -|- globhelp Glob:help

proc Glob:help {hand idx arg} {
    global NS
    putdcc $idx " "
    putdcc $idx "     Glob.tcl (v1.2) - Aide     "
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Script permettant:"
    putdcc $idx "    - d'avoir la liste des Globaux présent sur #soho"
    putdcc $idx "    - obtenir les stats d'un salon"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .glob 14(obtenir la liste des Globaux)"
    putdcc $idx "  .globlist 14(lister les masks des Globaux)"
    putdcc $idx "  .\[+/-\]glob <user@host> 14(ajouter/retirer les masks des Globaux)"
    putdcc $idx " "
    putdcc $idx "  .globhelp <-- Aide, vous êtes ici!"
    putdcc $idx " "
    return 1
}



###################
# Ajouter un Host #
###################
bind dcc o +glob Glob:host:add

proc Glob:host:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Glob:FichierAddInfo $rep_system/Glob-Hosts.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[Glob: Add Hosts\]\002 ::: $tempnick a été modifié!"
        } else {
            putdcc $idx "\002\[Glob: Add Hosts\]\002 ::: $tempnick a été ajouté!"
        }
        Glob:host:init
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+glob <user@host>"
        return 0
    }
}



###################
# Retirer un Host #
###################
bind dcc o -glob Glob:host:del

proc Glob:host:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Glob:FichierRemInfo $rep_system/Glob-Hosts.conf $tempnick] == 1 } {
            putdcc $idx "\002\[Glob: Del Hosts\]\002 ::: $tempnick a été effacé!"
            Glob:host:init
            return 1
        } else {
            putdcc $idx "\002\[Glob: Del Hosts\]\002 ::: $tempnick n'a pas été trouvé!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-glob <user@host>"
        return 0
    }
}

###################
# Liste les Hosts #
###################
bind dcc - globlist Glob:host:list

proc Glob:host:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Hosts des Globaux\002:"
    Glob:FichierLecture $idx $rep_system/Glob-Hosts.conf
    putdcc $idx " "
    return 1
}



##############
# Procédures #
##############

proc Glob:FichierAddInfo { AddInfoFichier AddInfoNick AddInfoInfo } {
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

    Glob:FichierCopy "$rep_system/temp.txt" $AddInfoFichierAcces

    unset AddInfoTexteLu
    unset AddInfoNickLu
    unset AddInfoInfoLu
    
    return $AddInfoNickTrouve
}

proc Glob:FichierRemInfo { RemInfoFichier RemInfoNick } {
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

    Glob:FichierCopy "$rep_system/temp.txt" $RemInfoFichierAcces 

    unset RemInfoTexteLu
    unset RemInfoNickLu
    unset RemInfoInfoLu

    return $RemInfoNickTrouve
}

proc Glob:FichierCopy { CopyFichierAcces CopyFichierAcces2 } {
    file copy -force $CopyFichierAcces $CopyFichierAcces2
    return
}

proc Glob:FichierLecture { LectureIdx LectureFichierAcces } {

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
