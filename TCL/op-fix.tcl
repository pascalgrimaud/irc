#
# op-fix.tcl
#

########
# motd #
########

putlog "\002op-fix.tcl\002"



##########
# msg op #
##########

bind msg o|o op opfix:msg:op

proc opfix:msg:op { nick uhost hand arg } {

  set arg [split $arg]
  set opfix(pass) [lindex $arg 0]
  set opfix(chan) [lindex $arg 1]

  if { $opfix(pass) == "" } {
    putlog "($nick!$uhost) !*! failed OP"
  } elseif { ![passwdok $hand $opfix(pass)] } {
    putlog "($nick!$uhost) !*! failed OP"
  } elseif { $opfix(chan) == "" } {
    putlog "($nick!$uhost) !$hand! OP"
    foreach i [channels] {
      if { [matchattr $hand o|o $i] && [onchan $nick $i] } {
        putserv "MODE $i +o $nick"          
      }
    }
  } else {
    if { [matchattr $hand o|o $opfix(chan)] && [onchan $nick $opfix(chan)] } {
      putlog "($nick!$uhost) !$hand! OP $opfix(chan)"
      putserv "MODE $opfix(chan) +o $nick"
    } else {
      putlog "($nick!$uhost) !*! failed OP $opfix(chan)"
    }
  }
  return 0
}

##########
# dcc op #
##########

bind dcc o|o op opfix:dcc:op

proc opfix:dcc:op { hand idx arg } {

  set arg [split $arg]
  set opfix(nick) [lindex $arg 0]
  set opfix(chan) [lindex $arg 1]

  if { $opfix(chan) == "" } { set opfix(chan) [lindex [split [console $idx]] 0] }
  if { $opfix(nick) == "" } { set opfix(nick) $hand }

  if { $opfix(chan) == "*" } {
    putdcc $idx "Invalid console channel."
  } elseif { ![matchattr $hand o|o $opfix(chan)] } {
    putdcc $idx "You are not a channel op on $opfix(chan)."
  } elseif { ![onchan $hand $opfix(chan)] } {
    putlog "#$hand# ($opfix(chan)) op $opfix(nick)"
    putdcc $idx "$opfix(nick) is not on $opfix(chan)."
    return 0
  } else {
    putlog "#$hand# ($opfix(chan)) op $opfix(nick)"
    putdcc $idx "Gave op to $opfix(nick) on $opfix(chan)"
    putserv "MODE $opfix(chan) +o $opfix(nick)"
  }
  return 0
}
