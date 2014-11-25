
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


# bind bot - CX:user p21:user

proc p21:user {bot cmd arg} {

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




bind dcc - p21 p21:xverif

proc p21:xverif { hand idx arg } {
    set arg [split $arg]

    if { [llength $arg] != 1 } {
        putdcc $idx "\002Syntaxe :\002 .p21 <host|ip>"
    } else {
        p21:check [lindex $arg 0]
    }
    putloglev 8 * "[3]#[o]$hand[3]#[o] p21 $arg"
    return 
}


proc p21:check { host } {
    global p21ip p21timeout p21idx

    if { ![catch {connect $host 21 } p21idx]} {
        set p21timeout($p21idx) "$p21idx"
        set p21ip($p21idx) $host
        utimer 15 "p21:timeout $p21idx"

#        putdcc $p21idx "USER leech"
#        putdcc $p21idx "PASS y€pdl"


        control $p21idx p21:ctrl
    } else {
        putloglev 4 * "\002ProxyCheck21 Error\002: $host"
    }

}

proc p21:verif {n i a} {

    global p21ip p21timeout

    set a [cf $a]

    if {[llength $a] != 1} {
        putdcc $i "\002Syntaxe :\002 .p21 <host|ip>"
        return 0
    }

    if { [catch {set sock [socket -async [lindex $a 0] 21]}] } {
        putloglev 4 * "\002ProxyCheck21 Error\002: [lindex $a 0]"
        return 0
    } else {
        set idx [connect [lindex $a 0] 21]
        set p21timeout($idx) "$idx"
        set p21ip($idx) [lindex $a 0]
#        putloglev 8 * "(DEBUG) Connect $idx : $idx [k]$idx $p21ip($idx)"

        utimer 30 "p21:timeout $idx"

#        putdcc $p21idx "USER leech"
#        putdcc $p21idx "PASS y€pdl"

        control $idx p21:ctrl

        putlog "#$n# p21 $a"
    }
}

proc p21:ctrl { idx text } {
    global p21ip p21timeout

    set text [strlwr [cf $text]]

    putloglev 8 * "(DEBUG) p21:ctrl $idx --> [k]10 $text"


    if { [info exists p21timeout($idx)] } {
        unset p21timeout($idx)
        foreach t [utimers] {
            if { [lindex $t 1] == "p21:timeout $idx" } {
                killutimer [lindex $t 2]
            }
        }
    }
#    putdcc $idx "USER leech"
    if { [string match *331* *[lindex $text 1]*] } {
      putdcc $idx "PASS y€pdl"
    }


    if { [string match *bad* *[lindex $text 1]*]
        && [string match *passwords* *[lindex $text 2]*]} {

        putloglev 4 * "\002ProxyCheck21 Error\002: $p21ip($idx)"
        return 0
    }
    if { [lindex $text 0] == "translating" } {
        putloglev 4 * "\002[4]ProxyCheck21 valide\002[o]: $p21ip($idx)"
        killdcc $idx
        if {[info exists p21ip($idx)]} { unset p21ip($idx) }
        return 0
    }
}

proc p21:timeout { idx } {
    global p21ip p21timeout

    if {[info exists p21timeout($idx)]} {
        unset p21timeout($idx)
        if {[valididx $idx]} { killdcc $idx }
        putloglev 4 * "\002ProxyCheck21 Timeout\002: $p21ip($idx)"
        if {[info exists p21ip($idx)]} {
            unset p21ip($idx)
        }
    }
}


