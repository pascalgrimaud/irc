#
# procs.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#


########
# motd #
########

putlog "\002procs.tcl\002 <ibu_lordaeron@yahoo.fr>"



#######################
# diverses procédures #
#######################


#
# le reverse du [join <string>]
#
proc nojoin { text } {
    return [split $text]
}

proc nojoin2 { text } {
  regsub -all -- {\\} $text {\\\\} text
  regsub -all -- {\{} $text {\{} text
  regsub -all -- {\}} $text {\}} text
  regsub -all -- {\[} $text {\[} text
  regsub -all -- {\]} $text {\]} text
  regsub -all -- {\"} $text {\"} text
  return $text
}

proc nojoin3 {x {y ""} } {
    for {set i 0} {$i < [string length $x]} {incr i} {
        switch -- [string index $x $i] {
            "\"" {append y "\\\""}
            "\\" {append y "\\\\"}
            "\[" {append y "\\\["}
            "\]" {append y "\\\]"}
            "\} " {append y "\\\} "}
            "\{" {append y "\\\{"}
            default {append y [string index $x $i]}
        }
    }
    return $y
}



#
# raw <commande>
#
# commande semblable aux puthelp, putserv, putquick mais ne prend plu en compte
# la gestion en QUEUE des commandes envoyées au serveur
# (risque de partir en Excess Flood...)
#
proc raw { data } {
    set length [expr [string length $data] + 1]
    putdccraw idxbyibu $length "$data\n"
    return
}



#
# un meilleur string match? car le [ pose pb...
#
proc wmatch { arg0 arg1 } {
  regsub -all {\\} $arg0 {\\\\} arg0
  regsub -all {\[} $arg0 {\[} arg0
  return [string match $arg0 $arg1]
}



#
# affichage de la syntaxe
#
proc syntaxe { idx string } {
  if { [valididx $idx] } {
    putdcc $idx "\002Syntaxe\002: $string"
  }
  return
}



#
# proc duration from Synch.tcl 2.2b for XiRCON by echo@wizard.net
#
proc duration {s} {
    if {$s <= 59} { return "${s} secs" }
    set returnstr ""
    set m [expr $s / 60]; set s [expr $s % 60]
    set h [expr $m / 60]; set m [expr $m % 60]
    set d [expr $h / 24]; set h [expr $h % 24]
    set y [expr $d / 365]; set d [expr $d % 365]
    if {$y > 0} {set returnstr "$y years"}
    if {$d > 0} {set returnstr "$returnstr $d days"}
    if {$h > 0} {set returnstr "$returnstr $h hours"}
    if {$m > 0} {set returnstr "$returnstr $m mins"}
    if {$s > 0} {set returnstr "$returnstr $s secs"}
    return "[string trimleft $returnstr " "]"
}



#
# Procs de Couleurs par NiX
#
proc 0 {} {return "00"} 
proc 1 {} {return "01"}
proc 2 {} {return "02"}
proc 3 {} {return "03"}
proc 4 {} {return "04"}
proc 5 {} {return "05"}
proc 6 {} {return "06"}
proc 7 {} {return "07"}
proc 8 {} {return "08"}
proc 9 {} {return "09"}
proc 10 {} {return "10"}
proc 11 {} {return "11"}
proc 12 {} {return "12"}
proc 13 {} {return "13"}
proc 14 {} {return "14"}
proc 15 {} {return "15"}
proc 16 {} {return "16"}
proc k {} {return ""}
proc b {} {return ""}
proc u {} {return ""}
proc o {} {return ""}



#
# procédure de retrait de couleurs
#
proc strip {str {type orubcg}} {
    set type [string tolower $type]
    if {[string first b $type] != -1} {regsub -all  $str "" str}
    if {[string first u $type] != -1} {regsub -all  $str "" str}
    if {[string match {*[rv]*} $type]} {regsub -all  $str "" str}
    if {[string first o $type] != -1} {regsub -all  $str "" str}

    if {[string first c $type] != -1} {
        regsub -all {(([0-9])?([0-9])?(,([0-9])?([0-9])?)?)?} $str "" str
    }

    if {[string first g $type] != -1} {
        regsub -all -nocase {([0-9A-F][0-9A-F])?} $str "" str
    }
    return $str
}



#
# Mask sous le type désiré 
#
# Les Types st:
#  0: *!user@host.domain
#  1: *!*user@host.domain
#  2: *!*@host.domain
#  3: *!*user@*.domain
#  4: *!*@*.domain
#  5: nick!user@host.domain
#  6: nick!*user@host.domain
#  7: nick!*@host.domain
#  8: nick!*user@*.domain
#  9: nick!*@*.domain
#
# -- SYNTAXE:
#  mask <type> <mask>
#
proc mask { type mask } {
    set n "*"
    set u "*"
    set a "*"
    scan $mask "%\[^!\]!%\[^@\]@%s" n u a
    set n [join [string trimleft $n "@+"]]
    set u [join [string trimleft $u "~"]]
    set h $a
    set d ""
    if { [is_ip_addr $a] } {
        set a [split $a .]
        set a [lreplace $a end end *]
    } else {
        set a [split $a .]
        if { [llength $a] > 2 } { set a [lreplace $a 0 0 *] }
    }
    set d [join $a .]
    switch "$type" {
        "0" { return "*!$u@$h" }
        "1" { return "*!*$u@$h" }
        "2" { return "*!*@$h" }
        "3" { return "*!*$u@$d" }
        "4" { return "*!*@$d" }
        "5" { return "$n!$u@$h" }
        "6" { return "$n!*$u@$h" }
        "7" { return "$n!*@$h" }
        "8" { return "$n!*$u@$d" }
        "9" { return "$n!*@$d" }
    }
    return "$n!$u@$h"
}


#
# Procédure qui retourne 1 si le string donné est un salon
# sinon, retourne 0
#
proc ischannel { string } {
  if { [string index $string 0] == "#" || [string index $string 0] == "&" } {
    return 1
  } else {
    return 0
  }
}


#
# Procédure qui retourne 1 si l'identd est de type java
# sinon, retourne 0
#
proc UserJava { identd } {
  if { [string tolower $identd] == "visio" } {
    return 1
  } else {
    if { [string match v??? $identd] || [string match w??? $identd] } {
      if { 99 < [string range $identd 1 3] && [string range $identd 1 3] < 1000 } {
        return 1
      } else {
        return 0
      }
    } else {
      return 0
    }
  }
}


#
# Procédure qui retourne 1 si l'adresse donnée en paramètre est une IP.
# Retourne 0 si c un mask.
#
proc is_ip_addr { addr } {
    return [regexp {([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)} $addr]
}



#
# Procédure qui retourne l'adresse donnée en paramètre sous la forme
#  <nick|*>!<user|*>@<host-domain|*>
#
# Utilisation:
#  addrfill <mask>
#
proc addrfill { addr } { 
    set addr [string trimleft [string tolower $addr] "!@"]
    if {![string length $addr]} { 
        set addr "*!*@*"
    } elseif {![string match *@* $addr]} { 
        set addr "*!*@$addr" 
      } elseif {![string match *!* $addr]} { 
            set addr "*!$addr" 
        } else { 
            set addr "$addr" 
          }
    return $addr
}



#
# Procédure qui à partir d'un mask, retourne le nick
# Mask du type: nick!user@host.domain
#
# -- SYNTAXE:
#  Xnick <mask>
#
proc Xnick { mask } {
    return [lindex [split $mask !] 0]
}

proc Xnick2 { mask } {
# return [lindex [split $mask !] 0]
    set n "*"
    set u "*"
    set a "*"
    scan $mask "%\[^!\]!%\[^@\]@%s" n u a
    set n [join [string trimleft $n "@+"]]
    set u [join [string trimleft $u "~"]]
    set h $a
    set d ""
    if { [is_ip_addr $a] } {
        set a [split $a .]
        set a [lreplace $a end end *]
    } else {
        set a [split $a .]
        if { [llength $a] > 2 } { set a [lreplace $a 0 0 *] }
    }
    return "$n"
}



#
# Procédure qui à partir d'un mask, retourne le UserId
# Mask du type: nick!user@host.domain
#
# -- SYNTAXE:
#  Xuser <mask>
#
proc Xuser { mask } {
    set userhost [lindex [split $mask !] 1]
    return [lindex [split $userhost @] 0]
}

proc Xuser2 { mask } {
    set n "*"
    set u "*"
    set a "*"
    scan $mask "%\[^!\]!%\[^@\]@%s" n u a
    set n [join [string trimleft $n "@+"]]
    set u [join [string trimleft $u "~"]]
    set h $a
    set d ""
    if { [is_ip_addr $a] } {
        set a [split $a .]
        set a [lreplace $a end end *]
    } else {
        set a [split $a .]
        if { [llength $a] > 2 } { set a [lreplace $a 0 0 *] }
    }
    return "$u"
}



#
# Procédure qui à partir d'un mask, retourne le Host
# Mask du type: nick!user@host.domain
#
# -- SYNTAXE:
#  Xhost <mask>
#
proc Xhost { mask } {
    set userhost [lindex [split $mask !] 1]
    return [lindex [split $userhost @] 1]
}

proc Xhost2 { mask } {
    set n "*"
    set u "*"
    set a "*"
    scan $mask "%\[^!\]!%\[^@\]@%s" n u a
    set n [join [string trimleft $n "@+"]]
    set u [join [string trimleft $u "~"]]
    set h $a
    set d ""
    if { [is_ip_addr $a] } {
        set a [split $a .]
        set a [lreplace $a end end *]
    } else {
        set a [split $a .]
        if { [llength $a] > 2 } { set a [lreplace $a 0 0 *] }
    }
    return "$h"
}



#
# Procédure qui remplace "replace" par "replacewith" ds la chaine de caractère string
#
# Utilisation:
#  replace <string> <motif à remplacer> <motif qui va remplacer>
#
proc replace { string replace replacewith } {
  regsub -all -- {\\} $replacewith {\\\\} replacewith
  regsub -all -- "&" $replacewith {\\\&} replacewith
  regsub -all -- {\\} $replace {\\\\} replace
  regsub -all -- {\[} $replace {\[} replace
  regsub -all -- {\]} $replace {\]} replace
  regsub -all -- {\(} $replace {\(} replace
  regsub -all -- {\)} $replace {\)} replace
  regsub -all -- {\*} $replace {\*} replace
  regsub -all -- {\+} $replace {\+} replace
  regsub -all -- {\?} $replace {\?} replace
  regsub -all -nocase $replace $string $replacewith string
  return $string
}



#
# Procédure de débuguage des Nicks dans Geofront
#
proc geo:isbug { text } {
    set text1 $text
    set text [replace $text "\\\{" "\{"]
    if { $text == $text1 } {
        return 0
    } else {
        return 1
    }
}

proc geo:debug { text } {
    return [replace $text "\\\{" "\{"]
}

proc geo:join { arg } {

  set text_length [expr [llength [split $arg]] -1]
  set text_string ""
  set i 0

  while { $i <= $text_length } {
    set j [lindex [split $arg] $i]
    if { [string index $j 0] == "\{" && [string index $j end] == "\}" } {
        set j "[string range $j 1 [expr [string length $j] -2]]"
    } else {
        set j [join $j]
    }
    lappend text_string $j
    incr i
  }
  return [join $text_string]
}


####################################
# Procédures de Gestion de Fichier #
####################################

#
# ajouter une ligne à la suite du fichier
#
proc file:add { fichier info } {

    if { [file exists $fichier] == 0 } {
        set openAcces [open $fichier w+]
    } else {
        set openAcces [open $fichier a+]
    }
    puts $openAcces "$info"
    close $openAcces
    return
}

#
# ajouter/remplacer une ligne repéré par le 1er mot
#
proc file:addid { fichier info } {
    global rep_system

    set idFind 0

    set fichierAcces1 "$fichier"
    set fichierAcces2 "$rep_system/temp.txt"

    set info [split $info]

    if { [file exists $fichierAcces1] == 0 } {
        set openAcces1 [open $fichierAcces1 w+]
        close $openAcces1
    }

    set openAcces1 "[open $fichierAcces1 r+]"
    set openAcces2 "[open $fichierAcces2 w+]"
    while { ![eof $openAcces1] } {

        set texteLu [gets $openAcces1]
        set texteLu [split $texteLu]

        if { $info != "" && [string tolower [lindex $texteLu 0]] == [string tolower [lindex $info 0]] } {
            puts $openAcces2 "[join $info]"
            set idFind 1
        } elseif { $texteLu != "" } {
            puts $openAcces2 "[join $texteLu]"
        }
    }

    if { $idFind == 0 && $info != "" } {
        puts $openAcces2 "[join $info]"
    }

    close $openAcces1
    close $openAcces2

    file:copy "$rep_system/temp.txt" $fichier
    unset texteLu
    
    return $idFind
}

#
# effacer une ligne repéré par le 1er mot
#
proc file:rem { fichier info } {
    global rep_system

    set idFind 0

    set fichierAcces1 "$fichier"
    set fichierAcces2 "$rep_system/temp.txt"

    set info [split $info]

    if {[file exists $fichierAcces1] == 0} {
        set openAcces1 [open $fichierAcces1 w+]
        close $openAcces1
    }

    set openAcces1 "[open $fichierAcces1 r+]"
    set openAcces2 "[open $fichierAcces2 w+]"

    while { ![eof $openAcces1] } {

        set texteLu [gets $openAcces1]
        set texteLu [split $texteLu]

        if { [string tolower [lindex $texteLu 0]] != [string tolower [lindex $info 0]] } {
            if { $texteLu != "" } { puts $openAcces2 "[join $texteLu]" }
        } else {
            set idFind 1
        }
    } 

    close $openAcces1
    close $openAcces2

    file:copy "$rep_system/temp.txt" $fichier 

    unset texteLu

    return $idFind
}

#
# copie un fichier
#
proc file:copy { CopyFichierAcces CopyFichierAcces2 } {
    file copy -force $CopyFichierAcces $CopyFichierAcces2
    return
}

#
# lis un fichier
#
proc file:read { fichier idx } {
    if {[file exists $fichier] == 0} {
        set openAcces [open $fichier w+]
        close $openAcces
    }

    set openAcces "[open $fichier r]"
    set nblignes 0

    while { ![eof $openAcces] } {
        set texteLu [gets $openAcces]
        if { $texteLu != "" } {
            if { [valididx $idx] } { putdcc $idx "$texteLu" }
            incr nblignes
        }
    }
    close $openAcces
    unset texteLu
    return $nblignes
}

proc file:read:espace { fichier idx } {
    if {[file exists $fichier] == 0} {
        set openAcces [open $fichier w+]
        close $openAcces
    }

    set openAcces "[open $fichier r]"

    while { ![eof $openAcces] } {
        set texteLu [gets $openAcces]
        if { $texteLu != "" } { putdcc $idx "   $texteLu" }
    }
    close $openAcces
    unset texteLu
    return
}

proc file:read:espacegras { fichier idx } {
    if {[file exists $fichier] == 0} {
        set openAcces [open $fichier w+]
        close $openAcces
    }

    set openAcces "[open $fichier r]"

    while { ![eof $openAcces] } {
        set texteLu [gets $openAcces]
        set texteLu [split $texteLu]
        if { $texteLu != "" } { putdcc $idx "   \002[lindex $texteLu 0]\002 [join [lrange $texteLu 1 end]]" }
    }
    close $openAcces
    unset texteLu
    return
}

#
# retourne une ligne aléatoire du fichier
#
proc file:random { fichier } {
    set ResultString ""
    if {[file exists $fichier] == 0} {
        set openAcces [open $fichier w+]
        close $openAcces
    }
    set openAcces "[open $fichier r]"
    while {![eof $openAcces]} {
        set texteLu [gets $openAcces]
        if { $texteLu != "" } { lappend ResultString $texteLu }
    }
    close $openAcces ; unset texteLu
    return "[lindex $ResultString [rand [llength $ResultString]]]"
}

#
# affecte ds une variable string les 1ers mots de chaque ligne
# du fichier et retourne cette variable
#
proc file:tostring { fichier } {

    set ResultString ""

    if {[file exists $fichier] == 0} {
        set openAcces [open $fichier w+]
        close $openAcces
    }

    set openAcces "[open $fichier r]"

    while {![eof $openAcces]} {
        set texteLu [gets $openAcces]
        set texteID [lindex [split $texteLu] 0]
        if { $texteID != "" } { lappend ResultString $texteID }
    }

    close $openAcces
    unset texteLu
    unset texteID

    return [join $ResultString]
}

#
# affecte à chaque ligne du fichier, chaque mot de string
#
proc file:stringto { fichier StringLecture } {
    set openAcces "[open $fichier w+]"
    foreach i StringLecture {
        puts $openAcces "$i"
    }
    close $openAcces

    return
}

#
# affiche l'ens des strings si elle est trouvée ds le fichier
#
proc file:search { fichier idx SearchString } {

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
                putdcc $idx "[join $texteLu]"
            }
        }
    }
    close $openAcces
    unset texteLu
}

proc file:search:espacegras { fichier idx SearchString } {

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
                putdcc $idx "   $texteLu"
            }
        }
    }
    close $openAcces
    unset texteLu
}

proc file:search:espacegras { fichier idx SearchString } {

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
                putdcc $idx "   \002[lindex $texteLu 0]\002 [join [lrange $texteLu 1 end]]"
            }
        }
    }
    close $openAcces
    unset texteLu
}

#
# récupère la 1ere ligne non vide d'un fichier, et la retourne en string
#
proc file:get { fichier } {
    if { [file exists $fichier] == 0 } {
        set openAcces [open $fichier w+]
        close $openAcces
    }
    set openAcces "[open $fichier r]"
    set getInfo ""
    while { ![eof $openAcces] } {
        set texteLu [gets $openAcces]
        if { $getInfo == "" } {
            set getInfo $texteLu
        }
    }
    close $openAcces
    unset texteLu
    return $getInfo
}

