#
# connect.tcl
#

putlog "\002connect.tcl\002"



bind dcc -|- connect connect:dcc
proc connect:dcc { hand idx arg } {
    global cnt    

    set arg [split $arg]

    if { ![catch {connect [lindex $arg 0] [lindex $arg 1]} cnt(idx)]} {
        control $cnt(idx) connect:event
        return 1
    } else {
        putdcc $idx "\002Connect\002 impossible..."
        return 0
    }
}
proc connect:event { idx arg } {
    putloglev 8 * "\[IN Connect\] $arg"
    return 0
}



bind dcc -|- test connect:user

proc connect:user { hand idx arg } {
    global cnt
    putdcc $cnt(idx) "$arg"
    return 1
}


bind dcc -|- open open:dcc
proc open:dcc { hand idx arg } {
    global cnt    

    set arg [split $arg]

    # make sure it's chmod u+x ;-)
    set rcon_path     "/home/NT"
    # rcon password of the server
    set rcon_password "zent12"
    # IP address of the server
    set rcon_address  "62.212.75.78"
    # port the gameserver runs on
    set rcon_port     "27015"
    # channel to listen for rcon commands, or leave empty to listen in all channels
    set chan          "#slags.priv"
    
    set param "status"

    set rcon [open "|$rcon_path/rcon $rcon_password $rcon_address $rcon_port \"$param\"" r]

    while { ![eof $rcon] } {
        set texteLu [gets $rcon]
        if { [valididx $idx] } { putdcc $idx ">> $texteLu" }
    }
    close $rcon

    return 1
}


#=-----------------------=
# procs
#=-----------------------=

bind dcc - mydetector mydetector:wingate

proc mydetector:wingate { hand idx arg } {
    DetectorEvent $idx $arg
    return
}

proc Detector {} {
    global xdetect servlink

    if {![catch {connect $xdetect(link) $xdetect(port)} servlink]} {
        putlog "Starting $xdetect(serv)..."
        send "PASS :$xdetect(pass)"
        send "SERVER $xdetect(serv) 1 [clock seconds] [clock seconds] P09 :$xdetect(sinfo)"
        control $servlink DetectorEvent
    } else {putlog "Error: ($servlink)"}
}

proc DetectorEvent {idx arg} {
    global xdetect

    set arg [split $arg]
    wingate [join $arg] JOIN test!test@test.com
    return 1
}

proc send {datasend} {
    global servlink xdetect
    putdcc $servlink "$datasend"
    if {$xdetect(debug)} {putlog "\[OUT\] $datasend"}
}

set v4port "2[rand 9][rand 9][rand 9]"

proc wingate {host type args} {
    global timeout
    set args [join $args " "]
    putlog "(WINGATE) $host $type $args"

    if { [catch {[socket -async $host 1080]} sock] } {
      putlog "(WINGATE) error"
      return 0
    } else {

      fconfigure $sock -buffering line -blocking 0
      fileevent $sock writable [list gotconnect $sock $host $type $args]
      putlog "(WINGATE) fileevent $sock writable [list gotconnect $sock $host $type $args]"

#    fileevent $sock readable [list gotread $sock $host $type $args]
#    putlog "(WINGATE) fileevent $sock readable [list gotread $sock $host $type $args]"

#      set timeout($sock) ""
#      utimer 30 "timeout $sock $host $type $args"
    }
}

proc timeout {sock host type args} {
    global timeout

    putlog "(Timeout) $sock $host $type $args"

    if {[info exists timeout($sock)]} {
        unset timeout($sock)
        fileevent $sock writable {}
        fileevent $sock readable {}
        close $sock
    }
    return 0
}

proc gotconnect {sock host type args} {
    global botname timeout v4port
    set args [join $args " "]

    putlog "(GOTCONNECT) $sock $host $type $arg"

    fconfigure $sock -translation binary -buffering none -blocking 1
    fileevent $sock writable {}
    if {[lindex $args end] == "v4"} {
        set data "[binary format "ccSI" 4 1 $v4port [myip]][exec whoami][binary format c 0]"
    } else {
        set data "[binary format ccc 5 1 0]"
    }
    if {[catch {puts $sock $data}]} {
        if {[info exists timeout($sock)]} {unset timeout($sock)}
        catch {close $sock}
    }
}

proc gotread {sock host type args} {
    global botnick timeout xdetect
    set args [join $args " "]

    putlog "(GOTREAD) $sock $host $type $arg"

    if {[info exists timeout($sock)]} {unset timeout($sock)}
    foreach timer [utimers] {
        if {([lindex [lindex $timer 1] 0] == "timeout" && [lindex [lindex $timer 1] 1] == $sock)} {
            killutimer [lindex $timer 2]
        }
    }
    catch {binary scan [read $sock 2] cc reply reply2} d
    fileevent $sock readable {}
    catch {close $sock}
    if {([info exists reply] && [info exists reply2])} {
        if {$reply == 0} {set reply 4}
        if {$reply == 4 || $reply == 5} {
            if {$reply == 4 && $reply2 == 91} {
                if {[lindex $args end] != "v4"} {
                    set lastv4time [unixtime]; set lastv4host $host
                    wingate $host $type $args v4
                    return 0
                }
            }
            if {($reply == 4 && $reply2 == 90 || $reply == 5 && $reply2 == 0)} {
                if {$xdetect(debug)} {putlog "\[Gline\] $host ([lindex $args 1])"}
                putlog "\[Proxy\] $host ([lindex $args 1])"
#                send ":$xdetect(serv) GLINE * +*@$host $xdetect(glinetime) :$xdetect(glinereason) ([lindex $args 1])"
#                if {$xdetect(log)} {exec echo \[Proxy\] $host ([lindex $args 1]) >> $xdetect(logname) &}
                if {$xdetect(debug)} {putlog "\[Proxy\] $host ([lindex $args 1])"}
            }
        }
    } else {if {$xdetect(debug)} {putlog "\[Debug\] $args"}}
}

#=-----------------------=
# start server
#=-----------------------=

# foreach d [dcclist] { if {[lindex [lindex $d 4] 1] == "DetectorEvent"} {killdcc [lindex $d 0]} }
# Detector

#=-----------------------=
# EOF
#=-----------------------=

putlog "Detector.tcl"