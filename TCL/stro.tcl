#
# stro.tcl - Ibu <ibu@belgariade.com>
#



#################
# Configuration #
#################



##################
# Initialisation #
##################

set strofile "system/stro.txt"
set strochan "#stro-caserne"


########
# Motd #
########

putlog "\002stro.tcl\002 par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"
putlog "     Aide --> \002.stro\002"




########
# Help #
########

bind dcc S stro stro:help

proc stro:help { hand idx text } {
    global strofile

    putdcc $idx " "
    putdcc $idx "     stro.tcl - Info     "
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   database de stro"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .strolist 14(voir la liste des stro)"
    putdcc $idx "  .+stro <nom> <ip> <port> <login> <pass> \[description\] 14(ajouter un stro)"
    putdcc $idx "  .-stro <nom> 14(effacer un stro)"
    putdcc $idx " "
    putdcc $idx "  .strotest <nom> 14(tester la validité d'un stro à partir de son nom)"
    putdcc $idx "  .stroview <ip> <port> 14(tester la validité d'un stro)"
    putdcc $idx " "
    putdcc $idx ".stro <-- Aide, vous êtes ici!"
    putdcc $idx " "
    putdcc $idx "Informations :"
    putdcc $idx "  console +4: pour voir les tests et views des stro"
    putdcc $idx " "
    return 1
}


#########
# +stro #
#########

bind dcc S +stro stro:add

proc stro:add { hand idx arg } {
    global strofile

    set arg [split $arg]

    if { [lindex $arg 4] == "" } {
        putdcc $idx "Usage: .+stro <nom> <ip> <port> <login> <pass> \[description\]"
        return 0
    } else {
        set stro(nom) [lindex $arg 0]
        set stro(ip) [lindex $arg 1]
        set stro(port) [lindex $arg 2]
        set stro(login) [lindex $arg 3]
        set stro(pass) [lindex $arg 4]
        set stro(info) [join [lrange $arg 5 end]]
        
        putdcc $idx "\[STRO\] Ancienne info:"
        file:search $strofile $idx $stro(nom)*
        file:addid $strofile "$stro(nom) $stro(ip) $stro(port) $stro(login) $stro(pass) $stro(info)"

        putdcc $idx "\[STRO\] \002$stro(nom)\002 ajouté avec succès!"
        putlog "#$hand# +stro $stro(nom) $stro(ip) $stro(port) \[login\] \[pass\] $stro(info)"
        return 0
    }
}



#########
# -stro #
#########

bind dcc S -stro stro:rem

proc stro:rem { hand idx arg } {
    global strofile

    set arg [split $arg]

    if { [lindex $arg 0] == "" } {
        putdcc $idx "Usage: .+stro <nom>"
        return 0
    } else {
        set stro(nom) [lindex $arg 0]
        
        putdcc $idx "\[STRO\] Ancienne info:"
        file:search $strofile $idx $stro(nom)*
        if { [file:rem $strofile $stro(nom)] == 1 } {
            putdcc $idx "\[STRO\] \002$stro(nom)\002 effacé avec succès!"
        } else {
            putdcc $idx "\[STRO\] \002ERREUR!\002 \002$stro(nom)\002 n'existe pas!"
        }

        putlog "#$hand# -stro $stro(nom)"
        return 0
    }
}

########
# stro #
########

bind dcc S strolist stro:list

proc stro:list { hand idx arg } {
    global strofile

    if {[file exists $strofile] == 0} {
        set openAcces [open $strofile w+]
        close $openAcces
    }

    putdcc $idx "\002[u]Liste des stro[u] :\002"
    putdcc $idx " "
    set openAcces "[open $strofile r]"
    while { ![eof $openAcces] } {
        set texteLu [gets $openAcces]
        set texteLu [split $texteLu]
        if { $texteLu != "" } {
            set stro(nom) [lindex $texteLu 0]
            set stro(ip) [lindex $texteLu 1]
            set stro(port) [lindex $texteLu 2]
            set stro(login) [lindex $texteLu 3]
            set stro(pass) [lindex $texteLu 4]
            set stro(info) [join [lrange $texteLu 5 end]]

            putdcc $idx "   \002$stro(nom)\002 $stro(ip) $stro(port) $stro(login) $stro(pass) $stro(info)"
        }
    }
    close $openAcces
    unset texteLu
    putdcc $idx " "
    return 1
}



############
# stroview #
############

bind dcc S strotest stro:test
bind dcc S stroview stro:view

proc strlwr {string} {
    return [string tolower $string]
}

proc cf {x {y ""} } {
    for {set i 0} {$i < [string length $x]} {incr i} {
        switch -- [string index $x $i] {
            "\"" {append y "\\\""}
            "\\" {append y "\\\\"}
            "\[" {append y "\\\["}
            "\]" {append y "\\\]"}
            "\} " {append y "\\\} "}
            "\{" {append y "\\\{"}
            default {append y [string index $x $i]}
        }
    }
    return $y
}



proc stro:test { hand idx arg } {
    global strofile

    set arg [split $arg]

    if { [llength $arg] != 1 } {
        putdcc $idx "\002Syntaxe :\002 .strotest <nom>"
    } else {

        set strogetinfo ""
        set stro(nom) [lindex $arg 0]

        set fichier $strofile
        set SearchString $stro(nom)*
        set SearchString [string tolower $SearchString]
        if { [file exists $fichier] == 0 } {
            set openAcces [open $fichier w+]
            close $openAcces
        }
        set openAcces "[open $fichier r]"
        while { ![eof $openAcces] } {

            set texteLu [gets $openAcces]
            set texteLu [split $texteLu]

            if { $texteLu != "" } {
                set LowerNick [string tolower [lindex $texteLu 0]]

                if { [string match $SearchString $LowerNick] } {
                    set strogetinfo $texteLu
                }
            }
        }
        close $openAcces
        unset texteLu

        if { $strogetinfo != "" } {
            set stro(host) [lindex $strogetinfo 1]
            set stro(port) [lindex $strogetinfo 2]
            stro:view:check $stro(host) $stro(port)
            putlog "#$hand# strotest $stro(nom) -> $stro(host) $stro(port)"
        } else {
            putdcc $idx "\[STRO\] \002ERREUR!\002 \002$stro(nom)\002 n'existe pas!"
        }
    }
    return 0
}


proc stro:view { hand idx arg } {
    set arg [split $arg]

    if { [llength $arg] != 2 } {
        putdcc $idx "\002Syntaxe :\002 .stroview <host> <port>"
    } else {
        stro:view:check [lindex $arg 0] [lindex $arg 1] 
    }
    putlog "#$hand# stroview $arg"
    return 0
}


proc stro:view:check { host port } {
    global stroip stroport  strotimeout stroidx stroinfo

    if { ![catch {connect $host $port} stroidx]} {
        set strotimeout($stroidx) "$stroidx"
        set stroip($stroidx) $host
        set stroport($stroidx) $port
        set stroinfo($stroidx) ""
        utimer 15 "stro:view:timeout $stroidx"

        control $stroidx stro:view:ctrl
    } else {
        putloglev 4 * "\[STRO\] \002ERREUR\002! connection impossible: $host $port"
        killdcc $stroidx
    }

}


proc stro:view:ctrl { idx text } {
    global stroip stroport strotimeout stroinfo

    set text [strlwr [cf $text]]

    set stroinfo($idx) "\[STRO\] [u]IP[u]: $stroip($idx) $stroport($idx) - [u]STATUT[u]: [k][4]connexion refusée"

#    putloglev 8 * "\[STRO\] (DEBUG) stro:view:ctrl $idx --> [k]10 $text"

    if { [llength $text] != 0 } {
        if { [info exists strotimeout($idx)] } {
            unset strotimeout($idx)
            foreach t [utimers] {
                if { [lindex $t 1] == "stro:view:timeout $idx" } {
                    killutimer [lindex $t 2]
                }
	    }
    	}
    }


    if { [string match *bienvenu*stro* *$text*] } {
        set stroinfo($idx) "\[STRO\] [u]IP[u]: $stroip($idx) $stroport($idx) - [u]STATUT[u]: [k][3]en ligne"
        putloglev 4 * "$stroinfo($idx)"
    }
    if { [string match *espace*restant* *$text*] } {
        putloglev 4 * "\[STRO\] [u]INFO[u]: [join [lrange $text 1 end]]"
        killdcc $idx
    }

    if { [string match *230*login*successful*have*fun* *$text*] } {
        putdcc $idx "SYST"
        putdcc $idx "FEAT"
	putdcc $idx "REST 100"
	putdcc $idx "REST 0"
	putdcc $idx "PWD"
	putdcc $idx "TYPE A"
	putdcc $idx "PASV"
	putdcc $idx "LIST"
    }

}

proc stro:view:timeout { idx } {
    global stroip stroport strotimeout stroinfo

#    putloglev 8 * "\[STRO\] (DEBUG) stro:view:timeout HOPHOP"

    if {[info exists strotimeout($idx)]} {
        if { $stroinfo($idx) == "" } {
            set stroinfo($idx) "\[STRO\] [u]IP[u]: $stroip($idx) $stroport($idx) - [u]STATUT[u]: [k][4]ping timeout"
        }
        putloglev 4 * "$stroinfo($idx)"
        unset strotimeout($idx)
        if {[valididx $idx]} { killdcc $idx }
        if {[info exists stroip($idx)]} {
            unset stroip($idx)
        }
    }
}


#############
# !strolist #
#############

bind pub - !strolist stro2:list

proc stro2:list { nick uhost handle channel arg } {
    global strofile strochan

    set listestro [file:tostring $strofile]
    putserv "PRIVMSG $strochan :[u]Liste des stro[u]:"
    putserv "PRIVMSG $strochan :$listestro"
    return 0
}



############
# !srotest #
############


bind pub - !strotest stro2:pub:test

proc stro2:pub:test { nick uhost handle channel arg } {
    global strofile strochan

    set arg [split $arg]

    if { [llength $arg] != 1 } {
        putserv "PRIVMSG $strochan :\002Syntaxe :\002 !strotest <nom>"
    } else {

        set strogetinfo ""
        set stro(nom) [lindex $arg 0]

        set fichier $strofile
        set SearchString $stro(nom)*
        set SearchString [string tolower $SearchString]
        if { [file exists $fichier] == 0 } {
            set openAcces [open $fichier w+]
            close $openAcces
        }
        set openAcces "[open $fichier r]"
        while { ![eof $openAcces] } {

            set texteLu [gets $openAcces]
            set texteLu [split $texteLu]

            if { $texteLu != "" } {
                set LowerNick [string tolower [lindex $texteLu 0]]

                if { [string match $SearchString $LowerNick] } {
                    set strogetinfo $texteLu
                }
            }
        }
        close $openAcces
        unset texteLu

        if { $strogetinfo != "" } {
            set stro(host) [lindex $strogetinfo 1]
            set stro(port) [lindex $strogetinfo 2]
            stro2:view:check $stro(host) $stro(port)
            putserv "PRIVMSG $strochan :\[STRO\] $stro(nom) -> $stro(host) $stro(port)"
        } else {
            putserv "PRIVMSG $strochan :\[STRO\] \002ERREUR\002! \002$stro(nom)\002 n'existe pas!"
        }
    }
    return 0


}
proc stro2:view:check { host port } {
    global stroip stroport  strotimeout stroidx stroinfo strochan

    if { ![catch {connect $host $port} stroidx]} {
        set strotimeout($stroidx) "$stroidx"
        set stroip($stroidx) $host
        set stroport($stroidx) $port
        set stroinfo($stroidx) ""
        utimer 15 "stro2:view:timeout $stroidx"

        control $stroidx stro2:view:ctrl
    } else {
        putserv "PRIVMSG $strochan :\[STRO\] \002ERREUR\002! connection impossible: $host $port"
        killdcc $stroidx
    }

}


proc stro2:view:ctrl { idx text } {
    global stroip stroport strotimeout stroinfo strochan

    set text [strlwr [cf $text]]

    set stroinfo($idx) "\[STRO\] [u]IP[u]: $stroip($idx) $stroport($idx) - [u]STATUT[u]: [k][4]connexion refusée"

#    putloglev 8 * "\[STRO\] (DEBUG) stro2:view:ctrl $idx --> [k]10 $text"

    if { [llength $text] != 0 } {
        if { [info exists strotimeout($idx)] } {
            unset strotimeout($idx)
            foreach t [utimers] {
                if { [lindex $t 1] == "stro2:view:timeout $idx" } {
                    killutimer [lindex $t 2]
                }
	    }
    	}
    }


    if { [string match *bienvenu*stro* *$text*] } {
        set stroinfo($idx) "\[STRO\] [u]IP[u]: $stroip($idx) $stroport($idx) - [u]STATUT[u]: [k][3]en ligne"
        putserv "PRIVMSG $strochan :$stroinfo($idx)"
    }
    if { [string match *espace*restant* *$text*] } {
        putserv "PRIVMSG $strochan :\[STRO\] [u]INFO[u]: [join [lrange $text 1 end]]"
        killdcc $idx
    }

    if { [string match *230*login*successful*have*fun* *$text*] } {
        putdcc $idx "SYST"
        putdcc $idx "FEAT"
	putdcc $idx "REST 100"
	putdcc $idx "REST 0"
	putdcc $idx "PWD"
	putdcc $idx "TYPE A"
	putdcc $idx "PASV"
	putdcc $idx "LIST"
    }

}

proc stro2:view:timeout { idx } {
    global stroip stroport strotimeout stroinfo strochan

#    putloglev 8 * "\[STRO\] (DEBUG) stro2:view:timeout HOPHOP"

    if {[info exists strotimeout($idx)]} {
        if { $stroinfo($idx) == "" } {
            set stroinfo($idx) "\[STRO\] [u]IP[u]: $stroip($idx) $stroport($idx) - [u]STATUT[u]: [k][4]ping timeout"
        }
        putserv "PRIVMSG $strochan :$stroinfo($idx)"
        unset strotimeout($idx)
        if {[valididx $idx]} { killdcc $idx }
        if {[info exists stroip($idx)]} {
            unset stroip($idx)
        }
    }
}
