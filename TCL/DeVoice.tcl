#
# DeVoice.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Script permettant de gérer une liste de Non-Voices
#



#################
# Configuration #
#################

# répertoire de sauvegarde des fichiers de config
set rep_system "system"

# chan à scanner
set DeVoiceChan "#!40-50ans!"



##################
# Initialisation #
##################

# Initialisation des Hosts
#
#   --> DeVoiceChainHost
#
proc DeVoice:host:init { } {
    global rep_system DeVoiceChainHost

    set DeVoiceChainHost ""

    if {[file exists $rep_system/DeVoice.conf] == 0} {
        set LectureFichierTemp [open $rep_system/DeVoice.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/DeVoice.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierHostLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierHostInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierHostLu != ""} {

            lappend DeVoiceChainHost $LectureFichierHostLu
            set DeVoiceChainHost [join $DeVoiceChainHost]
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierHostLu
    unset LectureFichierHostInfo

    return
}

DeVoice:host:init



########
# Motd #
########

putlog "\002DeVoice.tcl\002 par \002Ibu\002 14<ibu_lordaeron@yahoo.fr> -> \002.xdevoice\002"



####
#  #
####
bind mode - "#* +v" DeVoice:chk

proc DeVoice:chk { nick uhost handle channel mode-change victim } {
    global DeVoiceChan
    if { [botisop $channel] && [string match *$channel* $DeVoiceChan] } {
        foreach i $victim {
            if { [XIsDeVoice $i] } {
                putserv "MODE $channel -v $i"
                putlog "\002\[NoVoice\]\002 $i (voicé par $nick!$uhost)"
            }
       }
    }
}

proc XIsDeVoice { chknick } {
    global DeVoiceChainHost

    set chknick [string tolower $chknick]
    foreach i $DeVoiceChainHost {
        set i [string tolower $i]
        if { [string match $i $chknick] } {
            return 1
        }
    }
    return 0
}



########
# Aide #
########
bind dcc -|- xdevoice DeVoice:help

proc DeVoice:help {hand idx arg} {
    global botnick DeVoiceChan
    putdcc $idx " "
    putdcc $idx "     DeVoice.tcl - Aide     "
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Script permettant de gérer une liste de Non-Voices"
    putdcc $idx " "
    putdcc $idx "Commandes Partyline :"
    putdcc $idx "  .novoice 14(lister les masks des DeVoices)"
    putdcc $idx "  .\[+/-\]novoice <string nick> 14(ajouter/retirer les masks des DeVoices)"
    putdcc $idx " "
    putdcc $idx "  .xdevoice <-- Aide, vous êtes ici!"
    putdcc $idx " "
    return 1
}



###################
# Ajouter un Host #
###################
bind dcc o +novoice novoice:host:add

proc novoice:host:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [novoice:FichierAddInfo $rep_system/DeVoice.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[DeVoice: Add\]\002 ::: $tempnick a été modifié!"
        } else {
            putdcc $idx "\002\[DeVoice: Add\]\002 ::: $tempnick a été ajouté!"
        }
        DeVoice:host:init
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+novoice <user@host>"
        return 0
    }
}



###################
# Retirer un Host #
###################
bind dcc o -novoice novoice:host:del

proc novoice:host:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [novoice:FichierRemInfo $rep_system/DeVoice.conf $tempnick] == 1 } {
            putdcc $idx "\002\[DeVoice: Del\]\002 ::: $tempnick a été effacé!"
            DeVoice:host:init
            return 1
        } else {
            putdcc $idx "\002\[DeVoice: Del\]\002 ::: $tempnick n'a pas été trouvé!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-novoice <user@host>"
        return 0
    }
}

###################
# Liste les Hosts #
###################
bind dcc - novoice novoice:host:list

proc novoice:host:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Hosts des DeVoices\002:"
    novoice:FichierLecture $idx $rep_system/DeVoice.conf
    putdcc $idx " "
    return 1
}



##############
# Procédures #
##############

proc novoice:FichierAddInfo { AddInfoFichier AddInfoNick AddInfoInfo } {
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

    novoice:FichierCopy "$rep_system/temp.txt" $AddInfoFichierAcces

    unset AddInfoTexteLu
    unset AddInfoNickLu
    unset AddInfoInfoLu
    
    return $AddInfoNickTrouve
}

proc novoice:FichierRemInfo { RemInfoFichier RemInfoNick } {
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

    novoice:FichierCopy "$rep_system/temp.txt" $RemInfoFichierAcces 

    unset RemInfoTexteLu
    unset RemInfoNickLu
    unset RemInfoInfoLu

    return $RemInfoNickTrouve
}

proc novoice:FichierCopy { CopyFichierAcces CopyFichierAcces2 } {
    file copy -force $CopyFichierAcces $CopyFichierAcces2
    return
}

proc novoice:FichierLecture { LectureIdx LectureFichierAcces } {

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
