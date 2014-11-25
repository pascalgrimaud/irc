#
# ibu-msg.tcl
#
# used with eNote.tcl
#

putlog "\002ibu-msg.tcl\002"


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


bind pubm - *!scalou* scalou:pubm:important
proc scalou:pubm:important { nick userhost hand channel text } {
    set text [strip $text]
    if { [string tolower $channel] == "#riva" && [string index $text 0] == "!" } {
       if { [lrange $text 1 end] != "" } {
            if { [string length $text] < 60 } {
                eNoteSendChannel $nick ibu@vizzavi.net #riva "[lrange $text 1 end]"
                putserv "PRIVMSG #riva :Message #riva de \002$nick\002 envoyé à \002Scalou\002 !"
                return 0
            } else {
                putserv "PRIVMSG #riva :\002Syntaxe\002 : !scalou <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
                return 0
            }
        } else {
            putserv "PRIVMSG #riva :\002Syntaxe\002 : !scalou <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
            return 0
        }
    }
}


bind pubm - *!desi* desi:pubm:important
proc desi:pubm:important { nick userhost hand channel text } {
    set text [strip $text]
    if { [string tolower $channel] == "#riva" && [string index $text 0] == "!" } {
       if { [lrange $text 1 end] != "" } {
            if { [string length $text] < 60 } {
                eNoteSendChannel $nick didibu@vizzavi.net #riva(desi) "[lrange $text 1 end]"
                putserv "PRIVMSG #riva :Message #riva de \002$nick\002 envoyé à \002desi\002 !"
                return 0
            } else {
                putserv "PRIVMSG #riva :\002Syntaxe\002 : !desi <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
                return 0
            }
        } else {
            putserv "PRIVMSG #riva :\002Syntaxe\002 : !desi <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
            return 0
        }
    }
}

bind pubm - *!jo* jo:pubm:important
proc jo:pubm:important { nick userhost hand channel text } {
    set text [strip $text]
    if { [string tolower $channel] == "#riva" && [string index $text 0] == "!" } {
       if { [lrange $text 1 end] != "" } {
            if { [string length $text] < 60 } {
                eNoteSendChannel $nick didibu@vizzavi.net #riva(jo) "[lrange $text 1 end]"
                putserv "PRIVMSG #riva :Message #riva de \002$nick\002 envoyé à \002Jo\002 !"
                return 0
            } else {
                putserv "PRIVMSG #riva :\002Syntaxe\002 : !jo <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
                return 0
            }
        } else {
            putserv "PRIVMSG #riva :\002Syntaxe\002 : !jo <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
            return 0
        }
    }
}

bind pubm - *!sergou* sergou:pubm:important
proc sergou:pubm:important { nick userhost hand channel text } {
    set text [strip $text]
    if { [string tolower $channel] == "#riva" && [string index $text 0] == "!" } {
       if { [lrange $text 1 end] != "" } {
            if { [string length $text] < 60 } {
                eNoteSendChannel $nick rockwilder@vizzavi.net #riva "[lrange $text 1 end]"
                putserv "PRIVMSG #riva :Message #riva de \002$nick\002 envoyé à \002Sergou\002 !"
                return 0
            } else {
                putserv "PRIVMSG #riva :\002Syntaxe\002 : !sergou <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
                return 0
            }
        } else {
            putserv "PRIVMSG #riva :\002Syntaxe\002 : !sergou <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
            return 0
        }
    }
}


bind pubm - *!nico* nico:pubm:important
proc nico:pubm:important { nick userhost hand channel text } {
    set text [strip $text]
    if { [string tolower $channel] == "#riva" && [string index $text 0] == "!" } {
       if { [lrange $text 1 end] != "" } {
            if { [string length $text] < 60 } {
                eNoteSendChannel $nick winzeep@vizzavi.net #riva "[lrange $text 1 end]"
                putserv "PRIVMSG #riva :Message #riva de \002$nick\002 envoyé à \002Nico\002 !"
                return 0
            } else {
                putserv "PRIVMSG #riva :\002Syntaxe\002 : !nico <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
                return 0
            }
        } else {
            putserv "PRIVMSG #riva :\002Syntaxe\002 : !nico <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
            return 0
        }
    }
}



bind pubm - *!clem* clem:pubm:important
proc clem:pubm:important { nick userhost hand channel text } {
    set text [strip $text]
    if { [string tolower $channel] == "#riva" && [string index $text 0] == "!" } {
       if { [lrange $text 1 end] != "" } {
            if { [string length $text] < 60 } {
                eNoteSendChannel $nick shark_jedi@vizzavi.net #riva "[lrange $text 1 end]"
                putserv "PRIVMSG #riva :Message #riva de \002$nick\002 envoyé à \002Clem\002 !"
                return 0
            } else {
                putserv "PRIVMSG #riva :\002Syntaxe\002 : !clem <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
                return 0
            }
        } else {
            putserv "PRIVMSG #riva :\002Syntaxe\002 : !clem <message important> (message inférieur à 60 caractères -> en faire plusieurs sinon)"
            return 0
        }
    }
}
