#
# Detector-Leaf.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Anti proxy sur le port 1080 - (Leaf)
#
# --- Principe ---
# L'eggdrop ne pouvant scanner lui mm "trop" de host en mm tps,
# une répartition du scan est davantage efficace.
# Ici, via la Botnet, le Hub demande à chacun des Leafs de scanner
# à tour de rôle les hosts désirés, et réenvoie la réponse du Scan.
# On obtient donc un control sur le port 1080 des hosts demandés, de
# façon réparti.
# Biensur, des Proxys arrivent à passer au travers, aucun AntiSocks
# ne marche à 100%
#
# Console +4 pour voir l'évaluation des ScanPorts
#

#=------------------------------------------------=
#
# CREDIT FOR THE PROXY SCANNER:
# Anti-Socks v1.1
# by Cashflo
# Cashflo@GalaxyNet.Org
# http://www.galaxynet.org/ircops/cashflo.html
# Copyright (c) 1999 Cashflo All Rights Reserved.
#
#=------------------------------------------------=


#################
# Configuration #
#################

# Robot Hub (nom Botnet)
set Detector(hub) "ASocks"



##################
# Initialisation #
##################

set v4port "2[rand 9][rand 9][rand 9]"



########
# Motd #
########

putlog "\002Detector-Leaf.tcl\002 (v1.0) par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"



###################
# Scanner un Host #
###################

bind bot - Detector Detector:requete
proc Detector:requete {bot cmd arg} {

    set arg [nojoin $arg]

    set sock_test_idx [lindex $arg 0]
    set sock_test_host [lindex $arg 1]
    set sock_test_info [lindex $arg 2]

    if { $sock_test_host != "" } {
        wingate $sock_test_host $sock_test_idx $sock_test_info
    }
    return 0
}



##############
# Sock Gline #
##############

proc wingate {host idx args} {
    global timeout Detector

    set args [nojoin [join $args]]

    if {[catch {set sock [socket -async $host 1080]}]} {
        putloglev 4 * "\002Proxy1080 Error\002 $host ([lindex $args 0])"
        putbot $Detector(hub) "DetectorAnswer $idx \002Proxy1080 Error\002 $host ([lindex $args 0])"
        return 0
    }
    fileevent $sock writable [list gotconnect $sock $host $idx [join $args]]
    fileevent $sock readable [list gotread $sock $host $idx [join $args]]

    set timeout($sock) ""
    utimer 15 "timeout $sock $host $idx $args"
}

proc timeout {sock host idx args} {
    global timeout Detector

    set args [nojoin [join $args]]

    if {[info exists timeout($sock)]} {
        unset timeout($sock)
        fileevent $sock writable {}
        fileevent $sock readable {}
        close $sock
        putloglev 4 * "\002Proxy1080 Timeout\002 $host ([lindex $args 0])"
        putbot $Detector(hub) "DetectorAnswer $idx \002Proxy1080 Timeout\002 $host ([lindex $args 0])"
    }

    return 0
}

proc gotconnect {sock host idx args} {
    global botname timeout v4port Detector
    
    set args [nojoin [join $args]]

#    putbot $Detector(hub) "DetectorAnswer $idx \002Proxy1080 GotConnect\002 $host ([lindex $args 0])"

    fconfigure $sock -translation binary -buffering none -blocking 1
    fileevent $sock writable {}
    if {[lindex $args end] == "v4"} {
        set data "[binary format "ccSI" 4 1 $v4port [myip]][exec whoami][binary format c 0]"
    } else {
        set data "[binary format ccc 5 1 0]"
    }
    if {[catch {puts $sock $data}]} {
        putloglev 4 * "\002Proxy1080 NoData\002 $host ([lindex $args 0])"
        putbot $Detector(hub) "DetectorAnswer $idx \002Proxy1080 NoData\002 $host ([lindex $args 0])"
        if {[info exists timeout($sock)]} {unset timeout($sock)}
        catch {close $sock}
    }
}

proc gotread {sock host idx args} {
    global botnick timeout xdetect Detector

    set args [nojoin [join $args]]

#    putbot $Detector(hub) "DetectorAnswer $idx \002Proxy1080 GotRead\002 $host ([lindex $args 0])"

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
#        putbot $Detector(hub) "DetectorAnswer $idx \002Proxy1080 Reply\002 $reply $reply2"
        if {$reply == 0} {set reply 4}
        if {$reply == 4 || $reply == 5} {
            if {$reply == 4 && $reply2 == 91} {
                if {[lindex $args end] != "v4"} {
                    set lastv4time [unixtime]; set lastv4host $host
                    wingate $host $idx $args v4
                    return 0
                }
            }
            if {($reply == 4 && $reply2 == 90 || $reply == 5 && $reply2 == 0)} {
                putloglev 4 * "\002Proxy1080 Found\002 ---12 $host ([lindex $args 0]) ($reply $reply2)"
                putbot $Detector(hub) "DetectorAnswer $idx \002Proxy1080 Found\002 ---12 $host ([lindex $args 0]) ($reply $reply2)"
#                putlog "\[Proxy1080\] $host ([lindex $args 0])"
#                send ":$xdetect(serv) GLINE * +*@$host $xdetect(glinetime) :$xdetect(glinereason) ([lindex $args 0])"
#                if {$xdetect(log)} {exec echo \[Proxy1080\] $host ([lindex $args 0]) >> $xdetect(logname) &}
            } else {
                putloglev 4 * "\002Proxy1080 Secure\002 $host ([lindex $args 0]) ($reply $reply2)"
                putbot $Detector(hub) "DetectorAnswer $idx \002Proxy1080 Secure\002 $host ([lindex $args 0]) ($reply $reply2)"
            }
        } else {
            putloglev 4 * "\002Proxy1080 Unknown\002 $host ([lindex $args 0])  ($reply $reply2)"
            putbot $Detector(hub) "DetectorAnswer $idx \002Proxy1080 Unknown\002 $host ([lindex $args 0])  ($reply $reply2)"
        }
    } else {
        putloglev 4 * "\002Proxy1080 Blocked\002 $host ([lindex $args 0])  ($reply $reply2)"
        putbot $Detector(hub) "DetectorAnswer $idx \002Proxy1080 Blocked\002 $host ([lindex $args 0])  ($reply $reply2)"
    }
}



##############
# Procédures #
##############

proc nojoin { text } {
  regsub -all -- {\\} $text {\\\\} text
  regsub -all -- {\{} $text {\{} text
  regsub -all -- {\}} $text {\}} text
  regsub -all -- {\[} $text {\[} text
  regsub -all -- {\]} $text {\]} text
  return "$text"
}

