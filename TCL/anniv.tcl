#
# anniv.tcl
#


proc file:exist { fichier SearchString } {

    set SearchString [string tolower $SearchString]
    if { [file exists $fichier] == 0 } {
        set openAcces [open $fichier w+]
        close $openAcces
    }
    set openAcces "[open $fichier r]"
    while { ![eof $openAcces] } {

        set texteLu [gets $openAcces]
        set texteLu [split $texteLu]

        if { $texteLu != "" } {
            set LowerNick [string tolower [lindex $texteLu 0]]

            if { [string match $SearchString $LowerNick] } {
                set 
            }
        }
    }
    close $openAcces
    unset texteLu
}

### /msg lebot monanniv <jj/mm/aaaa>
bind msg - monanniv monanniv:msg
proc monanniv:msg {nick host hand arg} {
  global botnick
  if {($arg == "") || ([string length $arg] != 10)} {
    puthelp "notice $nick :Commande : \002/msg $botnick monanniv <jj/mm/aaaa>\002"
    puthelp "notice $nick :Tapez : \002/msg $botnick finanniv\002 pour que votre date d'anniversaire soit supprimé de la mémoire du bot."
    return 0
  } else {
    file:addid "$nick" "$arg"
  }
}

### !anniv <handle>
bind pub - !anniv anniv:pub
proc anniv:pub {nick host hand chan arg} {


}