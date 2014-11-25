#
# Detector-Scan.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Anti proxy sur n'importe quel port
#
# --- Principe ---
# L'eggdrop se contente de savoir si le port est ouvert ou pas,
# et ne tente pas de tester si le port est accessible en "proxy"
# ou non.
# Il est donc conseillé de ne pas appliquer "trop" ce scan, vu qu'il
# ne donne pas forcément de bons résultats. Il peut y avoir ce qu'on 
# appelle des "dommages" collatéraux, lorsque ce tcl est utilisé
# en tant qu'Anti Proxy
#
# Console +4 pour voir l'évaluation des ScanPorts
#



########
# Motd #
########

putlog "\002Detector-Scan.tcl\002 (v1.0) par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"
putlog "   Use .scanport"



###################
# Scanner un Host #
###################

bind dcc S scanport scanport:chk

proc scanport:chk { hand idx arg } {

    set arg [nojoin $arg]
    set sock_test_host [lindex $arg 0]
    set sock_test_port [lindex $arg 1]
    set sock_test_iden [lindex $arg 2]

    if { $sock_test_port == "" } { set sock_test_port 1080 }
    if { $sock_test_iden == "" } { set sock_test_iden "test" }
    if { $sock_test_host != "" } {
        sock_wscan_chk $sock_test_host $sock_test_port $sock_test_iden
    } else {
        putdcc $idx "\002Syntaxe\002: .scanport <host> \[port\]"
    }

    return 0
}

proc sock_wscan_chk { host port args } {
    set args [nojoin [join $args]]

    putloglev 4 * "10\002Sock$port Control\002 $host ([lindex $args 0])"

    if { $host != "" && $port != "" } {
        if { [catch {socket -async $host $port} sock] } {
            putloglev 4 * "4\002Sock$port Error\002 $host ([lindex $args 0])"
        } else {
            fconfigure $sock -buffering line -blocking 0
            fileevent $sock writable [list sock_wnew_chk $sock $host $port [join $args]]
        }
    }
}

proc sock_wkill_chk { sock host port args {er ""} } {

    set args [nojoin $args]

    if { $er == "" } {
        catch {set er [fconfigure $sock -error]}
    }
    if { ![catch {close $sock} x] } {
        putloglev 4 * "5\002Sock$port Block\002 $host ([lindex $args 0])"
    } else {
        putloglev 4 * "5\002Sock$port Error\002 $host ([lindex $args 0]) ($x)"
    }
}

proc sock_wnew_chk {sock host port args } {
    global AntiSocks

    set args [nojoin [join $args]]

    fileevent $sock writable {}

    putdcc $sock "USER Lordaeron"
    putdcc $sock "PASS frerr007"

    if { [eof $sock] || [catch {puts $sock die}] } {
        sock_wkill_chk $sock $host $port [join $args]
        return
    }

    putloglev 4 * "3\002Sock$port Open\002 $host ([lindex $args 0])"
    set args "[join $args]"
    fileevent $sock readable [list sock_wget_chk $sock $host $port $args [after 5000 [list sock_wkill_chk $sock $host $port $args]]]
}

proc sock_wget_chk {sock host port args after} {
    global AntiSocks

    set args [nojoin [join $args]]

    after cancel $after

    if { [eof $sock] || [catch {gets $sock in}] } {
        sock_wkill_chk $sock $host $port
        return
    }

    putloglev 4 * "12\002Sock$port Found\002 ---12 $host ([lindex $args 0])"

    close $sock

    return
}
