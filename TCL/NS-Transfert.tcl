#
# NS-Transfert.tcl
#

putlog "\002NS-Transfert.tcl\002"


# fichier où sera stocké les pseudos protégés
set NSfile "system/NS-Nicks.conf"

proc NST:nick:initlist { } {
    global NSfile NSListeNick

    set NSListeNick(@debug) "debug"
    unset NSListeNick

    if {[file exists $NSfile] == 0} {
        set fichierAcces [open $NSfile w+]
        close $fichierAcces
    }

    set fichierAcces "[open $NSfile r]"

    while { ![eof $fichierAcces] } {
        set texteLu [gets $fichierAcces]
        set texteLu [split $texteLu]
        set texteLuId [lindex $texteLu 0]

        if { $texteLu != "" } {
            set NSListeNick([string tolower $texteLuId]) "[lindex $texteLu 0] [lindex $texteLu 1] [lindex $texteLu 2]"
        }
    }

    close $fichierAcces
    unset texteLu
    unset texteLuId
    return
}



############
# REGISTER #
############
#
# REGISTER <login> <pass> <email>
#

bind msg - register NS:register

proc NS:register { nick uhost handle arg } {
  global NSfile NSListeNick

  set arg [split $arg]
  set templogin [lindex $arg 0]
  set temploginlw [string tolower $templogin]
  set temppass [lindex $arg 1]
  set tempemail [lindex $arg 2]

  if { $tempemail == "" } {
    putloglev 3 * "\[Transf NS\] \002$nick\002 ($uhost) -> Syntaxe!"
  } elseif { ![info exist NSListeNick($temploginlw)] } {
    putloglev 3 * "\[Transf NS\] \002$nick\002 ($uhost) REGISTER -> $templogin inexistant"
  } else {
    set tmp $NSListeNick($temploginlw)
    set tmplogin [lindex [split $tmp] 0]
    set tmploginlw [string tolower $tmplogin]
    set tmppass [lindex [split $tmp] 1]
    set tmpemail [lindex [split $tmp] 2]

    if { [string tolower $tmplogin] == [string tolower $templogin]
      && [string tolower $tmplogin] == [decrypt $temppass $tmppass]
      && [string tolower $tmpemail] == [string tolower $tempemail] } {

      putloglev 3 * "\[Trans NS\] \002$nick\002 ($uhost) REGISTER -> $templogin \[something\] $tempemail"
    } else {
      putloglev 3 * "\[Trans NS\] \002$nick\002 ($uhost) REGISTER -> Mauvaise info"
    }
  }
  return 0
}