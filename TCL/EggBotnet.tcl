#
# EggBotnet.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Permet de manipuler les commandes groupés via la Botnet
#



########
# Motd #
########

putlog "\002EggBotnet.tcl\002 Usage: .mb help"



#########
# Procs #
#########

bind bot - botnet botnet_proc

bind dcc n mb botnetmsg_proc

proc botnetmsg_proc { handle idx arg } {

    set arg [nojoin $arg]
    set whattodo [string tolower [lindex $arg 0]]

    switch -exact $whattodo {
        "help" {
            putdcc $idx " Usage : .mb <command> <arg> <arg>..."
            putdcc $idx "         aivailable commands are :"
            putdcc $idx "         join part chanset chansave save msg notice rehash restart die"
        }
        "join" {
            set channame [lindex $arg 1]
            putallbots "botnet $handle [join $arg]"
            channel add $channame
            putlog "#\002$handle\002# MassBot \[join $channame\]"
        }
        "part" {
            set channame [lindex $arg 1]
            putallbots "botnet $handle [join $arg]"
            channel remove $channame
            putlog "#\002$handle\002# MassBot \[part $channame\]"
        }
        "chanset" {
            set channame [lindex $arg 1]
            set settings [join [lrange $arg 2 end]]
            putallbots "botnet $handle [join $arg]"
            channel set $channame $settings
            savechannels
            putlog "#\002$handle\002# MassBot \[chanset $channame $settings\]"
        }
        "chansave" {
            putallbots "botnet $handle [join $arg]"
            savechannels
            putlog "#\002$handle\002# MassBot \[chansave\]"
        }
        "save" {
            putallbots "botnet $handle [join $arg]"
            save
            putlog "#\002$handle\002# MassBot \[save\]"
        }
        "msg" {
            set channame [lindex $arg 1]
            set themsg [join [lrange $arg 2 end]]
            putallbots "botnet $handle [join $arg]"
            putserv "PRIVMSG $channame :$themsg"
            putlog "#\002$handle\002# MassBot \[msg $channame $themsg\]"
        }
        "notice" {
	    putlog "ici..."
            set channame [lindex $arg 1]
            set themsg [join [lrange $arg 2 end]]
            putallbots "botnet $handle [join $arg]"
            putserv "NOTICE $channame :$themsg"
            putlog "#\002$handle\002# MassBot \[notice $channame $themsg\]"
        }
        "topic" {
            set thetopic [join [lrange $arg 1 end]]
            putallbots "botnet $handle [join $arg]"
            foreach i [channels] {
                putserv "TOPIC $i :$thetopic"
            }
            putlog "#\002$handle\002# MassBot \[topic $thetopic\]"
        }
        "rehash" {
            putallbots "botnet $handle [join $arg]"
            rehash
            putlog "#\002$handle\002# MassBot \[rehash\]"
        }
        "restart" {
            putallbots "botnet $handle [join $arg]"
            restart
            putlog "#\002$handle\002# MassBot \[restart\]"
        }
        "die" {
            putallbots "botnet $handle [join $arg]"
            putlog "#\002$handle\002# MassBot \[die\]"
            die [join [lrange $arg 1 end]]
        }
    }
    return 0
}

proc botnet_proc {bot cmd arg} {

    set arg [nojoin $arg]
    set handle [lindex $arg 0]
    set arg [lrange $arg 1 end]
    set whattodo [string tolower [lindex $arg 0]]

    switch -exact $whattodo {
        "join" {
            set channame [lindex $arg 1]
            channel add $channame
            putlog "#\002$handle\002# MassBot \[join $channame\]"
        }
        "part" {
            set channame [lindex $arg 1]
            channel remove $channame
            putlog "#\002$handle\002# MassBot \[part $channame\]"
        }
        "chanset" {
            set channame [lindex $arg 1]
            set settings [join [lrange $arg 2 end]]
            channel set $channame $settings
            savechannels
            putlog "#\002$handle\002# MassBot \[chanset $channame $settings\]"
        }
        "chansave" {
            savechannels
            putlog "#\002$handle\002# MassBot \[chansave\]"
        }
        "save" {
            save
            putlog "#\002$handle\002# MassBot \[save\]"
        }
        "msg" {
            set channame [lindex $arg 1]
            set themsg [join [lrange $arg 2 end]]
            putserv "PRIVMSG $channame :$themsg"
            putlog "#\002$handle\002# MassBot \[msg $channame $themsg\]"
        }
        "notice" {
            set channame [lindex $arg 1]
            set themsg [join [lrange $arg 2 end]]
            putserv "NOTICE $channame :$themsg"
            putlog "#\002$handle\002# MassBot \[notice $channame $themsg\]"
        }
        "topic" {
            set thetopic [join [lrange $arg 1 end]]
            foreach i [channels] {
                putserv "TOPIC $i :$thetopic"
            }
            putlog "#\002$handle\002# MassBot \[topic $thetopic\]"
        }
        "rehash" {
            rehash
            putlog "#\002$handle\002# MassBot \[rehash\]"
        }
        "restart" {
            restart
            putlog "#\002$handle\002# MassBot \[restart\]"
        }
        "die" {
            putlog "#\002$handle\002# MassBot \[die\]"
            die [join [lrange $arg 1 end]]
        }
    }
    return 0
}
