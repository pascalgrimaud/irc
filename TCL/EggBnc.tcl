#
# EggBnc.tcl by Ibu <ibu_lordaeron@yahoo.fr>
#
# This TCL is use for connecting your Egg on a Bouncer
#



#################
# Configuration #
#################

# bounce debug
set bncmsg(debug) 0

# put bnc pass here
set bnc(pass) "b0unc3r"

#
set bnc(info) "[file:get "system/BncEchoSvr.conf"]"

# userid
set bnc(username) [lindex [split $bnc(info)] 0]

# irc server
set bnc(server) [join [lrange [split $bnc(info)] 1 end]]

# message
set bncmsg(auth) "AUTH"
#set bncmsg(auth) $botnick
set bncmsg(pass) ":You need to say /quote PASS <password>"
set bncmsg(conn) ":Level two, lets connect to something real now"
#set bncmsg(vhost) "INTERFACE lordaeron.org"
set bncmsg(vhost) ""



########
# Motd #
########

putlog "\002EggBnc.tcl\002 - by <ibu_lordaeron@yahoo.fr>"



###############
# Binds+Procs #
###############

bind raw - NOTICE BncChkNot

proc BncChkNot {from keyword arg}  {
    global bnc bncmsg

    set arg [nojoin $arg]

    if { $bncmsg(debug) == 1 } {
        putlog "(DEBUG) bncmsg(auth) --> [lindex $arg 0]"
        putlog "(DEBUG) bncmsg(pass) --> [join [lrange $arg 1 end]]"
    }

    if { [lindex $arg 0] == $bncmsg(auth) && [join [lrange $arg 1 end]] == $bncmsg(pass) } {
        putloglev 7 * "\[EggBnc\] PASS *****"
        putserv "PASS $bnc(pass)"
        return
    }
    if { [lindex $arg 0] == $bncmsg(auth) && [join [lrange $arg 1 end]] == $bncmsg(conn) } {
        if { $bncmsg(vhost) != "" } {
            putloglev 7 * "\[EggBnc\] $bncmsg(vhost)"
            putserv "$bncmsg(vhost)"
        }
        putloglev 7 * "\[EggBnc\] IDENT $bnc(username)"
        putserv "IDENT $bnc(username)"
        putloglev 7 * "\[EggBnc\] CONN $bnc(server)"
        putserv "CONN $bnc(server)"
        return
    }
}
