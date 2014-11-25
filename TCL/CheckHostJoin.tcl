#
# CheckHostJoin.tcl par Ibu <ibu_lordaeron@yahoo.fr>
# 

#
# Aide au service AntiSpam d'Entrechat
#


#################
# Configuration #
#################

# répertoire de sauvegarde des fichiers de config
set rep_system "System/Bot"



########
# Motd #
########

putlog "\002CheckHostJoin.tcl\002 by \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"
putlog "   Used for AntiSpam Service - Use \002.chj\002 for help"



##################
# Initialisation #
##################

# Initialisation des Nicks à protéger
#
#   --> ChjChainNick
#   --> ChjListeNick
#
proc Chj:nick:init { } {
    global rep_system ChjChainNick ChjListeNick

    set ChjChainNick ""

    if {[file exists $rep_system/Chj-Nicks.conf] == 0} {
        set LectureFichierTemp [open $rep_system/Chj-Nicks.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/Chj-Nicks.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierNickLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierNickInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierNickLu != ""} {

            lappend ChjChainNick $LectureFichierNickLu
            set ChjChainNick [join $ChjChainNick]
            set ChjListeNick([string tolower $LectureFichierNickLu]) "$LectureFichierNickLu $LectureFichierNickInfo"
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierNickLu
    unset LectureFichierNickInfo

    return
}

# Initialisation des Hosts à "travailler" lors du Join
#
#   --> ChjChainHost
#
proc Chj:host:init { } {
    global rep_system ChjChainHost

    set ChjChainHost ""

    if {[file exists $rep_system/Chj-Hosts.conf] == 0} {
        set LectureFichierTemp [open $rep_system/Chj-Hosts.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/Chj-Hosts.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierHostLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierHostInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierHostLu != ""} {

            lappend ChjChainHost $LectureFichierHostLu
            set ChjChainHost [join $ChjChainHost]
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierHostLu
    unset LectureFichierHostInfo

    return
}

# Initialisation des Channels sur lesquels controler
#
#   --> ChjChainChan
#
proc Chj:chan:init { } {
    global rep_system ChjChainChan

    set ChjChainChan ""

    if {[file exists $rep_system/Chj-Chans.conf] == 0} {
        set LectureFichierTemp [open $rep_system/Chj-Chans.conf w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $rep_system/Chj-Chans.conf r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierChanLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierChanInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierChanLu != ""} {

            lappend ChjChainChan $LectureFichierChanLu
            set ChjChainChan [join $ChjChainChan]
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierChanLu
    unset LectureFichierChanInfo

    return
}

proc Chj:massinit {} {

    Chj:nick:init
    Chj:host:init
    Chj:chan:init
}

Chj:massinit



########
# Aide #
########
bind dcc -|- chj Chj:help

proc Chj:help {hand idx arg} {
    putdcc $idx " "
    putdcc $idx "     CheckHostJoin.tcl - Aide     "
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Aide au service AntiSpam d'Entrechat"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .\[+/-\]chjnick <nick> 14(ajouter/retirer/lister un nick protege)"
    putdcc $idx "  .\[+/-\]chjhost <user@host> 14(ajouter/retirer/lister les Hosts sur lequels intervenir)"
    putdcc $idx "  .\[+/-\]chjchan <#channel> 14(ajouter/retirer/lister un chan ou l eggdrop travaillera)"
    putdcc $idx " "
    putdcc $idx "  .chj <-- Aide, vous êtes ici!"
    putdcc $idx " "
    return 1
}



###################
# Ajouter un Nick #
###################
bind dcc - +chjnick Chj:nick:add

proc Chj:nick:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]
    if { $tempnick != "" } {
        if { [Chj:FichierAddInfo $rep_system/Chj-Nicks.conf $tempnick $tempstatus] == 1 } {
            putdcc $idx "\002\[Chj: Add Nicks\]\002 ::: $tempnick a ete modifie! - Status: $tempstatus"
        } else {
            putdcc $idx "\002\[Chj: Add Nicks\]\002 ::: $tempnick a ete ajoute! - Status: $tempstatus"
        }
        Chj:massinit
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+chjnick <nick>"
        return 0
    }

}


###################
# Retirer un Nick #
###################
bind dcc - -chjnick Chj:nick:del

proc Chj:nick:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Chj:FichierRemInfo $rep_system/Chj-Nicks.conf $tempnick] == 1 } {
            putdcc $idx "\002\[Chj: Del Nicks\]\002 ::: $tempnick a ete efface!"
            Chj:massinit
            return 1
        } else {
            putdcc $idx "\002\[Chj: Del Nicks\]\002 ::: $tempnick n'a pas ete trouve!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-chjnick <nick>"
        return 0
    }
}


###################
# Liste les Nicks #
###################
bind dcc - Chjnick Chj:nick:list

proc Chj:nick:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Nicks proteges\002:"
    Chj:FichierLecture $idx $rep_system/Chj-Nicks.conf
    putdcc $idx " "
    return 1
}


###################
# Ajouter un Host #
###################
bind dcc - +Chjhost Chj:host:add

proc Chj:host:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Chj:FichierAddInfo $rep_system/Chj-Hosts.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[Chj: Add Hosts\]\002 ::: $tempnick a ete modifie!"
        } else {
            putdcc $idx "\002\[Chj: Add Hosts\]\002 ::: $tempnick a ete ajoute!"
        }
        Chj:massinit
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+chjhost <user@host>"
        return 0
    }
}


###################
# Retirer un Host #
###################
bind dcc - -Chjhost Chj:host:del

proc Chj:host:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Chj:FichierRemInfo $rep_system/Chj-Hosts.conf $tempnick] == 1 } {
            putdcc $idx "\002\[Chj: Del Hosts\]\002 ::: $tempnick a ete efface!"
            Chj:massinit
            return 1
        } else {
            putdcc $idx "\002\[Chj: Del Hosts\]\002 ::: $tempnick n'a pas ete trouve!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-chjhost <user@host>"
        return 0
    }
}

###################
# Liste les Hosts #
###################
bind dcc - Chjhost Chj:host:list

proc Chj:host:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Hosts\002:"
    Chj:FichierLecture $idx $rep_system/Chj-Hosts.conf
    putdcc $idx " "
    return 1
}


###################
# Ajouter un Chan #
###################
bind dcc - +Chjchan Chj:chan:add

proc Chj:chan:add { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Chj:FichierAddInfo $rep_system/Chj-Chans.conf $tempnick ""] == 1 } {
            putdcc $idx "\002\[Chj: Add Chans\]\002 ::: $tempnick a ete modifie!"
        } else {
            putdcc $idx "\002\[Chj: Add Chans\]\002 ::: $tempnick a ete ajoute!"
        }
        Chj:massinit
        return 1
    } else {
        putdcc $idx "\002Syntaxe\002: .+chjchan <#channel>"
        return 0
    }
}


###################
# Retirer un Chan #
###################
bind dcc - -Chjchan Chj:chan:del

proc Chj:chan:del { hand idx arg } {
    global rep_system

    set tempnick [join [lrange $arg 0 0]]

    if { $tempnick != "" } {
        if { [Chj:FichierRemInfo $rep_system/Chj-Chans.conf $tempnick] == 1 } {
            putdcc $idx "\002\[Chj: Del Chans\]\002 ::: $tempnick a ete efface!"
            Chj:massinit
            return 1
        } else {
            putdcc $idx "\002\[Chj: Del Chans\]\002 ::: $tempnick n'a pas ete trouve!"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .-chjchan <#channel>"
        return 0
    }
}

###################
# Liste les Chans #
###################
bind dcc - Chjchan Chj:chan:list

proc Chj:chan:list { hand idx arg } {
    global rep_system
    putdcc $idx "\002-- Liste des Chans a controler\002:"
    Chj:FichierLecture $idx $rep_system/Chj-Chans.conf
    putdcc $idx " "
    return 1
}



###########################
# Controle lors d'un Join #
###########################
bind join -|- * chj:join

proc chj:join { nick uh hand chan } {
    if { [ChjIsOnChannel $nick] } {
        if { [ChjMaskIsOnList $uh] } {
        # intervenir ici...
            putloglev 8 * "(CHJ) \002Floodeur\002 $nick $uh (appartenance Mask)"
        } else {
            set stop 0
            if { [ChjNickIsOnList $nick] } { set stop 1 }
            if { ![string match v???@*.fr $uh] && ![string match w???@*.fr $uh] } { set stop 2 }
            if { [string match *_* $nick] || [string match *-* $nick] } { set stop 3 }
            if { [cptemaj $nick] < 2 } { set stop 4 }
            if { [string length $nick] != 4 && [string length $nick] != 8 && [string length $nick] != 12 && [string length $nick] != 16 } { set stop 5 }
            if { $stop == 0 } { putloglev 8 * "(CHJ) \002Floodeur\002 : $nick $uh" }
            if { $stop == 1 } { putloglev 8 * "(CHJ) 14Non-Floodeur $nick $uh (nick protégé)" }
            if { $stop == 2 } { putloglev 8 * "(CHJ) 14Non-Floodeur $nick $uh (UserID non Java)" }
            if { $stop == 3 } { putloglev 8 * "(CHJ) 14Non-Floodeur $nick $uh (Pseudo contenant _ ou -)" }
            if { $stop == 4 } { putloglev 8 * "(CHJ) 14Non-Floodeur $nick $uh (Pseudo contenant moins de 2 majuscules)" }
            if { $stop == 5 } { putloglev 8 * "(CHJ) 14Non-Floodeur $nick $uh (Pseudo de longueur <> a 4,8,12 ou 16)" }
        }
    }
}



##############
# Procédures #
##############

proc Chj:FichierAddInfo { AddInfoFichier AddInfoNick AddInfoInfo } {
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

    Chj:FichierCopy "$rep_system/temp.txt" $AddInfoFichierAcces

    unset AddInfoTexteLu
    unset AddInfoNickLu
    unset AddInfoInfoLu
    
    return $AddInfoNickTrouve
}

proc Chj:FichierRemInfo { RemInfoFichier RemInfoNick } {
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

    Chj:FichierCopy "$rep_system/temp.txt" $RemInfoFichierAcces 

    unset RemInfoTexteLu
    unset RemInfoNickLu
    unset RemInfoInfoLu

    return $RemInfoNickTrouve
}

proc Chj:FichierCopy { CopyFichierAcces CopyFichierAcces2 } {
    file copy -force $CopyFichierAcces $CopyFichierAcces2
    return
}

proc Chj:FichierLecture { LectureIdx LectureFichierAcces } {

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
# Procédure permettant de compter le nombre de majuscule dans un string
#
#--------------------------------------------------------------------------------

proc cptemaj { string } {
    set i 0
    set j [string length $string]
    set cpte 0
    set stringUpper [string toupper $string]
    while { $i < $j } {
        set i1 [string index $string $i]
        set i2 [string index $stringUpper $i]
        if { [string match *[string tolower $i1]* abcdefghijklmnopqrsuvwyxz]
             && [string match *[string tolower $i2]* abcdefghijklmnopqrsuvwyxz]
             && $i1 == $i2 } {
            incr cpte
        }
        incr i
    }
    return $cpte
}



#--------------------------------------------------------------------------------
#
# Utilisation [ChjNickIsOnList <nick_désiré>]
# Procédure permettant de vérifier si ce nick est un nick à protéger
#
#--------------------------------------------------------------------------------

proc ChjNickIsOnList { ChjTestNick } {
    global ChjChainNick

    set ChjTestNick [string tolower $ChjTestNick]

    foreach i $ChjChainNick {
        set i [string tolower $i]
        if { $i == $ChjTestNick } {
            return 1
        }
    }
    return 0
}


#--------------------------------------------------------------------------------
#
# Utilisation [ChjMaskIsOnList <host_désiré>]
# Procédure permettant de vérifier si ce mask est ds la liste des AntiKills
#
#--------------------------------------------------------------------------------

proc ChjMaskIsOnList { ChjTestMask } {

    global ChjChainHost

    set ChjTestMask [string tolower $ChjTestMask]

    foreach i $ChjChainHost {
        set i [string tolower $i]
        if { [string match $i $ChjTestMask] } {
            return 1
        }
    }
    return 0

}



#--------------------------------------------------------------------------------
#
# Utilisation [ChjIsOnChannel <nick>]
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

proc ChjIsOnChannel { IsOnChannelNick } {
    global ChjChainChan

    set IsOnChannelNick [string tolower $IsOnChannelNick]

    foreach i $ChjChainChan {
        if { [validchan $i] } {
            if { [botonchan $i] && [onchan $IsOnChannelNick $i] } {
               return 1
            }
        }
    }
    return 0
}
