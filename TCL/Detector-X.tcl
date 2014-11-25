#
# Detector-X.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#




########
# Motd #
########

putlog "\002Detector-X.tcl\002 (v1.0) par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"
putlog "   Use .scanport"



###################
# Scanner un Host #
###################

# set v4port "2[rand 9][rand 9][rand 9]"
set v4port "11534"

bind dcc S scanport scanport:chk

proc scanport:chk { hand idx arg } {

    set arg [nojoin $arg]
    set host [lindex $arg 0]
    set port [lindex $arg 1]
    set iden [join [lrange $arg 2 end]]

    if { $port == "" } { set port 1080 }
    if { $iden == "" } { set iden "test" }
    if { $host != "" } {
        sock:wscan $host $port $iden
    } else {
        putdcc $idx "\002Syntaxe\002: .scanport <host> \[port\]"
    }

    return 0
}

proc sock:wscan { host port arg } {
    global timeout

    set arg [split $arg]

    putloglev 4 * "10\002Sock$port Control\002 $host $port ([join $arg])"

    if { $host != "" && $port != "" } {
        if { [catch { socket -async $host $port } sock] } {
            putloglev 4 * "4\002Sock$port Error\002 $host ([join $arg])"
            return
        } else {
            fconfigure $sock -buffering line -blocking 0
            fileevent $sock writable [list sock:wnew $sock $host $port [join $arg]]
            set timeout($sock) ""
            utimer 15 "sock:wkill $sock $host $port [join $arg]"
        }
    }
}


proc sock:wnew {sock host port arg } {
    global v4port username

    set arg [split $arg]

    putloglev 4 * "3\002Sock$port New\002 $host $port ([join $arg])"

    fconfigure $sock -translation binary -buffering none -blocking 1
    fileevent $sock writable {}

    if { $port == 3128 || [lindex $arg end] == "none" } {
        putloglev 4 * "3\002Sock$port New\002 Binary die"
        set data "die"
    } elseif {[lindex $arg end] == "v4"} {
        putloglev 4 * "3\002Sock$port New\002 Binary ccSI 4 1 $v4port [myip]"
        set data "[binary format "ccSI" 4 1 $v4port [myip]][exec whoami][binary format c 0]"
    } else {
        putloglev 4 * "3\002Sock$port New\002 Binary ccc 5 1 0"
        set data "[binary format ccc 5 1 0]"
    }

    if { [catch {puts $sock $data}] } {
        sock:wkill $sock $host $port [join $arg]
        return
    }
    fileevent $sock readable [list sock:wget $sock $host $port [join $arg]]
}

proc sock:wget {sock host port arg} {
    global timeout

    set arg [split $arg]

    putloglev 4 * "12\002Sock$port Get\002 $host $port ([join $arg])"

    if {[info exists timeout($sock)]} {unset timeout($sock)}
    foreach timer [utimers] {
        if {([lindex [lindex $timer 1] 0] == "sock:wkill" && [lindex [lindex $timer 1] 1] == $sock)} {
            killutimer [lindex $timer 2]
        }
    }

    catch {binary scan [read $sock 2] cc reply reply2} d
    fileevent $sock readable {}
    catch {close $sock}

    putloglev 4 * "Reply: $reply --- $reply2"

    if {([info exists reply] && [info exists reply2])} {
        if {$reply == 0} { set reply 4 }

        if {$reply == 4 || $reply == 5} {
            if {$reply == 4 && $reply2 == 91} {
                if {[lindex $arg end] != "v4"} {
                    set lastv4time [unixtime] ; set lastv4host $host
                    sock:wscan $host $port "$arg v4"
                    return 0
                }
            }
            if {($reply == 4 && $reply2 == 90 || $reply == 5 && $reply2 == 0)} {
                putlog "\[\002Proxy\002\] \002$host\002 $port ($reply) ($reply2) ([join $arg])"
            }
        }
        # 60 --- 33 (8080)
        if { ($reply == 60 && $reply2 == 72) || ($reply == 72 && $reply2 == 84) } {
            putlog "\[\002Proxy\002\] \002$host\002 $port ($reply) ($reply2) ([join $arg])"
        }
    }
}

proc sock:wkill { sock host port arg {er ""} } {
    set arg [split $arg]
    foreach timer [utimers] {
        if {([lindex [lindex $timer 1] 0] == "sock:wkill" && [lindex [lindex $timer 1] 1] == $sock)} {
            killutimer [lindex $timer 2]
        }
    }
    if { $er == "" } { catch {set er [fconfigure $sock -error]} }
    if { ![catch {close $sock} x] } {
        putloglev 4 * "5\002Sock$port Block\002 $host $port ([join $arg])"
    } else {
        putloglev 4 * "5\002Sock$port Error\002 $host ([join $arg]) ($x)"
    }
}

