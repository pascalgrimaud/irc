#               ***********************************************                         
#
#                       ___  ___   ______    _______                                    #
#                      |MMM\/MMM| /AAAAAA\  /SSSSSSS|                                   #
#                      |M|\MM/|M| |A|¯¯|A|  |S|¯¯¯¯¯                                    #
#                      |M| \/ |M| |A|__|A|  |S|______                                   #
#                      |M|    |M| |A|AA|A|  |SSSSSSSS\                                  #
#                      |M|    |M| |A|¯¯|A|   ______|SS|                                 #
#                      |M|    |M| |A|  |A|  |SSSSSSSS/                                  #
#                       ¯      ¯   ¯    ¯    ¯¯¯¯¯¯¯                                    #
#                   _____    _____    _____   _         ______                          #
#                  |TTTTT|  /OOOOO\  /OOOOO\ |L|       |ZZZZZZ|                         #
#                   ¯|T|    |O|¯|O|  |O|¯|O| |L|        ¯¯¯/Z/                          #
#                    |T|    |O| |O|  |O| |O| |L|          /Z/                           #
#                    |T|    |O| |O|  |O| |O| |L|         /Z/                            #
#                    |T|    |O|_|O|  |O|_|O| |L|_____   /Z/___                          #
#                    |T|    \OOOOO/  \OOOOO/ \LLLLLLL| |ZZZZZZ|                         #
#                     ¯      ¯¯¯¯¯    ¯¯¯¯¯   ¯¯¯¯¯¯¯   ¯¯¯¯¯¯                          #
#                 ************************************************                      #
#                               MaSRouT@yahoo.fr                                        #
#                            © MaSTooLZ SCRiPTinG ©                                     #
#                              $ IRC  & Services $                                      #
#                              ******************                                       #
#                                                                                       #
#                         ***  [ M a S T o o L Z ]  ***                                 #
#                                                                                       #
#########################################################################################
# [M a S T o o L Z]                                                                     #
#                       W a N a D o o   -   S C R i P T i n G                           #
#########################################################################################
#
#  Auteur : 
#    MaSrOuT    : MaSrOuT@Yahoo.fr
#    IRC NETWORK: Wanadoo/Voila
#    IRC Server : Chat.wanadoo.ma
#

#
proc strlwr {string} {
    return [string tolower $string]
}

#
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


# bind bot - CX:user p23:user

proc p23:user {bot cmd arg} {

    set arg [nojoin $arg]
    set arg1 [lindex $arg 0]
    set arg1lower [string tolower $arg1]
    set arg2 [lindex $arg 1]
    set arg3 [join [lrange $arg 2 end]]

    if { ![string match "*wanadoo.fr" $arg2]
      && ![string match "*echo.com" $arg2]
      && ![string match "*aol.com" $arg2]
      && ![string match "*@*liberty*" $arg2]
    } {
     putloglev 8 * "(HOST) $arg2"
    }
}




bind dcc - p23 p23:xverif

proc p23:xverif { hand idx arg } {
    set arg [split $arg]

    if { [llength $arg] != 1 } {
        putdcc $idx "\002Syntaxe :\002 .p23 <host|ip>"
    } else {
        p23:check [lindex $arg 0]
    }
    putloglev 8 * "[3]#[o]$hand[3]#[o] p23 $arg"
    return 
}


proc p23:check { host } {
    global p23ip p23timeout p23idx

    if { ![catch {connect $host 23 } p23idx]} {
        set p23timeout($p23idx) "$p23idx"
        set p23ip($p23idx) $host
        utimer 15 "p23:timeout $p23idx"
        putdcc $p23idx "cisco"
        putdcc $p23idx "masrout"
        control $p23idx p23:ctrl
    } else {
        putloglev 4 * "\002ProxyCheck23 Error\002: $host"
    }

}

proc p23:verif {n i a} {

    global p23ip p23timeout

    set a [cf $a]

    if {[llength $a] != 1} {
        putdcc $i "\002Syntaxe :\002 .p23 <host|ip>"
        return 0
    }

    if { [catch {set sock [socket -async [lindex $a 0] 23]}] } {
        putloglev 4 * "\002ProxyCheck23 Error\002: [lindex $a 0]"
        return 0
    } else {
        set idx [connect [lindex $a 0] 23]
        set p23timeout($idx) "$idx"
        set p23ip($idx) [lindex $a 0]
#        putloglev 8 * "(DEBUG) Connect $idx : $idx [k]$idx $p23ip($idx)"

        utimer 30 "p23:timeout $idx"

        putdcc $idx "cisco"
        putdcc $idx "masrout"
        control $idx p23:ctrl

        putlog "#$n# p23 $a"
    }
}

proc p23:ctrl { idx text } {
    global p23ip p23timeout

    set text [strlwr [cf $text]]

    putloglev 8 * "(DEBUG) p23:ctrl $idx --> [k]$idx $text"

    if { [info exists p23timeout($idx)] } {
        unset p23timeout($idx)
        foreach t [utimers] {
            if { [lindex $t 1] == "p23:timeout $idx" } {
                killutimer [lindex $t 2]
            }
        }
    }

#    if { $text == "user access verification" } { putdcc $idx "cisco" }
#    if { $text == "password" } { putdcc $idx "masrout" }

    if { [string match *bad* *[lindex $text 1]*]
        && [string match *passwords* *[lindex $text 2]*]} {

        putloglev 4 * "\002ProxyCheck23 Error\002: $p23ip($idx)"
        return 0
    }
    if { [lindex $text 0] == "translating" } {
        putloglev 4 * "\002[4]ProxyCheck23 valide\002[o]: $p23ip($idx)"
        killdcc $idx
        if {[info exists p23ip($idx)]} { unset p23ip($idx) }
        return 0
    }
}

proc p23:timeout { idx } {
    global p23ip p23timeout

    if {[info exists p23timeout($idx)]} {
        unset p23timeout($idx)
        if {[valididx $idx]} { killdcc $idx }
        putloglev 4 * "\002ProxyCheck23 Timeout\002: $p23ip($idx)"
        if {[info exists p23ip($idx)]} {
            unset p23ip($idx)
        }
    }
}


