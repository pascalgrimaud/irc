#
# test.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#



########
# Motd #
########

putlog "\002test.tcl\002"



########
# test #
########

bind dcc - xtest xtest:dcc

proc xtest:dcc { hand idx arg } {
  set arg [split $arg]
  set arg0 [lindex $arg 0]
  set arg1 [lindex $arg 1]
  putlog "$arg0 <---> $arg1"
  putlog "[string match "$arg0" "$arg1"]"
  putlog "[wmatch $arg0 $arg1]"
  return 1
}

proc wmatch { arg0 arg1 } {
  regsub -all {\\} $arg0 {\\\\} arg0
  regsub -all {\[} $arg0 {\[} arg0
  return [string match $arg0 $arg1]
}
