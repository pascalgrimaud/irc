#
# Opless-Hub.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Tcl qui controle les Opless, et les affiche sur un salon donné.
# Opless = chan dont seul l'opérateur est l'eggdrop.
#
# Commande:
# /msg <#channel principal> .opless
# /msg <bot> opless (être @ sur un chan)
# .opless (en partyline)
#
# Ici, c le Opless-Hub.tcl, tcl devant être chargé ds le Robot principal, celui
# qui va recevoir les Opless des autres Robots connectés en Botnet
#
# NB: Le robot se doit d'être @. S'il ne sert just' qu'à controler les Opless
#     en tant que Users, faire varier les nombres en bas.
#



#################
# Configuration #
#################

# salon où sera signalé l'opless
set Opless(chan) "#riva"



########
# Motd #
########

putlog "\002Opless-Hub.tcl\002 par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"



#############
# Commandes #
#############

bind dcc -|- opless opless:dcc:list
bind pub -|- .opless opless:pub:list
bind msg -|- opless opless:msg:list

proc opless:dcc:list {hand idx arg} {
    putlog "#$hand# opless"
    putallbots "oplessrequete $idx"
    putdcc $idx "[opless:givelist]"
}

proc opless:pub:list { nick uhost handle channel arg } {
    putallbots "oplessnotice $nick"
    putserv "NOTICE $nick :[opless:givelist]"
}

proc opless:msg:list { nick uhost handle arg } {
    foreach i [channels] {
        if { [isop $nick $i] && [botisop $i] } {
            putallbots "oplessnotice $nick"
            putserv "NOTICE $nick :[opless:givelist]"
        }
    }
}



########
# Raws #
########

bind sign - * opless:sign
bind part - * opless:part
bind mode - "#* -o" opless:deop
bind kick - * opless:kick

proc opless:sign { nick uhost handle channel {msg ""} } {
    global botnick
    if { [botisop $channel] && [string tolower $nick] != [string tolower $botnick] } {
        if { [wasop $nick $channel] } {
            if { [NbOp $channel] < 3 } {
                IsOpless $channel "$nick vient de quitter"
            }
        }
    }
}

proc opless:part { nick uhost handle channel {msg ""} } {
    global botnick
    if { [botisop $channel] && [string tolower $nick] != [string tolower $botnick] } {
        if { [wasop $nick $channel] } {
            if { [NbOp $channel] < 3 } {
                IsOpless $channel "$nick vient de sortir"
            }
        }
    }
}

proc opless:deop { nick uhost handle channel mode-change victim } {
    if { [botisop $channel] } {
        if { [NbOp $channel] < 2 } {
            foreach i $victim {
                if { [wasop $i $channel] } {
                    IsOpless $channel "$i vient de se déoper"
                }
            }
        }
    }
}

proc opless:kick { nick uhost handle channel target reason } {
    global botnick
    if { [botisop $channel] && [string tolower $target] != [string tolower $botnick] } {
        if { [wasop $target $channel] } {
            if { [NbOp $channel] == 2 } {
                IsOpless $channel "$target vient de se faire kické"
            }
        }
    }
}



#####################
# Evenements ecoute #
#####################

# réception des opless de la part des autres eggs
# envoie de la réponse à l'idx approprié
bind bot - oplessreponse opless:bot:reponse
proc opless:bot:reponse {bot cmd arg} {
    if { [lrange $arg 1 end] != "" } {
        putdcc [lindex $arg 0] "[lrange $arg 1 end]"
    }
}

# réception d'une requete d'opless en PL
bind bot - oplessrequete opless:bot:requete
proc opless:bot:requete {bot cmd arg} {
    putbot $bot "oplessreponse $arg [opless:givelist]"
}

# réception d'une requete d'opless par notice
bind bot - oplessnotice opless:bot:notice
proc opless:bot:notice {bot cmd arg} {
    putserv "NOTICE [lindex $arg 0] :[opless:givelist]"
}

# réception d'un nouveau opless
bind bot - oplessnew opless:bot:new
proc opless:bot:new {bot cmd arg} {
    global Opless
    putlog "*** ($bot) [strip $arg]"
    putserv "PRIVMSG $Opless(chan) :$arg"
}



################
# Autres procs #
################

proc NbOp { channel } {

    set NbOps($channel) 0
    foreach i [chanlist $channel] {
        if { [isop $i $channel] } {
            incr NbOps($channel)
        }
    }
    return $NbOps($channel)
}

proc IsOpless { channel text } {
    global Opless
    putlog "*** Plus d'op sur $channel ($text)"
    putallbots "oplessnew Plus d'op sur $channel ($text)"
    putserv "PRIVMSG $Opless(chan) :\002Plus d'op sur $channel\002 ($text)"
    return
}

proc opless:givelist { } {
    set list_opless ""
    foreach i [channels] {
        if { [botonchan $i] } {
            if { [NbOp $i] < 2 } {
                lappend list_opless $i
            }
        }
    }
    return [join $list_opless]
}

#--------------------------------------------------------------------------------
#
# Procédure qui retire tout code couleur
#
# -- SYNTAXE:
#  strip <string> [orubcg]
#
#--------------------------------------------------------------------------------

proc strip {str {type orubcg}} {
    set type [string tolower $type]
    if {[string first b $type] != -1} {regsub -all  $str "" str}
    if {[string first u $type] != -1} {regsub -all  $str "" str}
    if {[string match {*[rv]*} $type]} {regsub -all  $str "" str}
    if {[string first o $type] != -1} {regsub -all  $str "" str}

    if {[string first c $type] != -1} {
        regsub -all {(([0-9])?([0-9])?(,([0-9])?([0-9])?)?)?} $str "" str
    }

    if {[string first g $type] != -1} {
        regsub -all -nocase {([0-9A-F][0-9A-F])?} $str "" str
    }
    return $str
}