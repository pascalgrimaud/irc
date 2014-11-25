#
# tittof.tcl
#


putlog "\002tittof.tcl\002 - Pour les messages importants: 14.tittof <message>"


bind dcc - tittof tittof:dcc:important

proc tittof:dcc:important {hand idx text} {
    set text [nojoin $text]

    if { [join $text] != "" } {
        if { [string length [join $text]] <= 130 } {
            sms:tittof:dcc $hand $idx "0664675010 [join $text]"
            return 1
        } else {
            putdcc $idx "\002Syntaxe\002 : .tittof <message important> (message inférieur à 130 caractères -> en faire plusieurs sinon)"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002 : .tittof <message important> (message inférieur à 130 caractères -> en faire plusieurs sinon)"
        return 0
    }
}





set sms(syntaxe) "\002Syntaxe\002:"
set sms(erreur) "\002Erreur\002:" 
#
proc cf {x {y ""} } {
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
proc mastittofnum {mas} {
    foreach i [split $mas {}] {
        if ![string match \[0-9\] $i] {
            return 0
        }
    }
    return 1
}

# .sms :
proc sms:tittof:dcc {n i a} {
    global sms botnick

    set a [cf $a]
    set sms(num) [lindex $a 0]
    set sms(msg) [lrange $a 1 end]
    set sms(msg2) [lrange $a 1 end]
    set sms(exp) "$i"

    if { [llength $a] < 2 } {
        putdcc $i "$sms(syntaxe) .sms <numero/username> <message> "
        return 0
    }
    if { [string length $sms(msg)] > 130 } {
        putdcc $i "$sms(erreur) message inférieur à 130 caractères -> en faire plusieurs sinon"
	return 0
    }

    set sms(msg) "$n@$botnick: [lrange $a 1 end]"
    if { [string length $sms(num)] > 10 || [string range $sms(num) 0 1] != "06" } {
        if { [mastittofnum $sms(num)] } {
            putdcc $i "$sms(erreur) numéro invalide"
            return 0
        }
    }

    if { ![mastittofnum $sms(num)] } {
        if { ![validuser $sms(num)] } {
            putdcc $i "$sms(erreur) username invalide: $sms(num)"
            return 0
        }
        if { [getuser $sms(num) xtra PHONE] == "" } {
            putdcc $i "$sms(erreur) aucun numéro correspondant à \002$sms(num)\002"
            return 0
        }
        set sms(num) [getuser $sms(num) xtra PHONE]
    }
    regsub -all " " $sms(msg) "+" sms(msg)
    set sms(i) [connect 213.186.33.4 80]
    putdcc $sms(i) "GET http://www.oz-warez.com/sms.php?numero=$sms(num)&texte=$sms(msg)"
    control $sms(i) sms:tittof:ctrl
}

#
proc sms:tittof:ctrl {i a} {
    global sms
    if {[string match *envoyé* *$a*]} {
        putdcc $sms(exp) "Message envoyé à Tittof"
        killdcc $i
    }
}