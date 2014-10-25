#
# Xbug.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#

putlog "Xbug.tcl - Use .xbug or .xdebug"

bind dcc -|- xbug xbug
bind dcc -|- xdebug xdebug
bind dcc -|- xtest xtest

proc test:debug { text } {
    return [replace $text "\\\{" "\{"]
}

proc xtest { hand idx arg } {
  set arg [test:debug [split $arg]]

  putdcc $idx "> [join $arg]"
  putdcc $idx "> [test:debug [join $arg]]"
  return 1
}



proc xbug { hand idx arg } {
    if { $arg != "" } {
        putdcc $idx "\[Xbug\]  $arg"
        putdcc $idx "\[Xbug\]  [join $arg]"
        return 1
    } else {
        putdcc $idx "USAGE: .xbug <string>"
        return 0
    }
}

proc xdebug { hand idx arg } {
    if { $arg != "" } {
        putdcc $idx "\[Xdebug\]  $arg"
        putdcc $idx "\[Xdebug\]  [nojoin $arg]"
        return 1
    } else {
        putdcc $idx "USAGE: .xdebug <string>"
        return 0
    }
}

proc nojoin { text } {
  regsub -all -- {\\} $text {\\\\} text
  regsub -all -- {\{} $text {\{} text
  regsub -all -- {\}} $text {\}} text
  regsub -all -- {\[} $text {\[} text
  regsub -all -- {\]} $text {\]} text
  return "$text"
}