#
# ibu.tcl
#

package require http



#################
# Configuration #
#################

set sms(syntaxe) "\002Syntaxe\002:"
set sms(erreur) "\002Erreur\002:"
set sms(envoi) "\[\002SMS\002\]"

set smsname(0613467770) "ibu"



########
# motd #
########

putlog "\002ibu.tcl\002 - Pour les messages importants: 14.ibu <message>"



########
# .ibu #
########

bind dcc - ibu sms:dcc:toibu

proc sms:dcc:toibu {hand idx text} {
    set text [nojoin $text]

    if { [string length $hand] <= 10 } {
        if { [join $text] != "" } {
            if { [string length [join $text]] <= 120 } {
                sms:dcc:send $hand $idx 1 "0613467770 [join $text]"
            } else {
                putdcc $idx "\002Syntaxe\002 : .ibu <message important> (message inf�rieur � 120 caract�res -> en faire plusieurs sinon)"
            }
        } else {
            putdcc $idx "\002Syntaxe\002 : .ibu <message important> (message inf�rieur � 120 caract�res -> en faire plusieurs sinon)"
        }
    } else {
        putdcc $idx "\002Erreur\002 : votre handle est trop long... il doit �tre inf�rieur ou �gal � 10 caract�res"
    }
    return 0
}



########
# .sms #
########

bind dcc - sms sms:dcc:toall

proc sms:dcc:toall {hand idx text} {
    set text [nojoin $text]

    if { [string length $hand] <= 10 } {
        if { [join $text] != "" } {
            if { [string length [join $text]] <= 120 } {
                sms:dcc:send $hand $idx 0 "[lindex $text 0] [join [lrange $text 1 end]]"
            } else {
                putdcc $idx "\002Syntaxe\002 : .sms <numero/username> <message> (message inf�rieur � 120 caract�res -> en faire plusieurs sinon)"
            }
        } else {
            putdcc $idx "\002Syntaxe\002 : .sms <numero/username> <message> (message inf�rieur � 120 caract�res -> en faire plusieurs sinon)"
        }
    } else {
        putdcc $idx "\002Erreur\002 : votre handle est trop long... il doit �tre inf�rieur ou �gal � 10 caract�res"
    }
    return 0
}



##########################
# procedure d envoie SMS #
##########################

proc sms:dcc:send { hand idx withbotnick arg } {
    global sms botnick smsname

    set arg [split $arg]

    set sms(num) [lindex $arg 0]
    set sms(msg) [lrange $arg 1 end]
    set sms(origin) $sms(msg)
    set sms(exp) $idx
    set sms(handle) ""

    if { [llength $arg] < 2 } {
        putdcc $idx "$sms(syntaxe) .sms <numero/username> <message> "
        return 0
    }
    if { [string length $sms(msg)] > 120 } {
        putdcc $idx "$sms(erreur) message inf�rieur � 120 caract�res -> en faire plusieurs sinon"
	return 0
    }
    if { $withbotnick == 1 } {
        set sms(msg) "($botnick) [lrange $arg 1 end]"
    }
    if { [string length $sms(num)] > 10 || [string range $sms(num) 0 1] != "06" } {
        if { [sms:dcc:testnum $sms(num)] } {
            putdcc $idx "$sms(erreur) num�ro invalide"
            return 0
        }
    }

    if { ![sms:dcc:testnum $sms(num)] } {
        if { ![validuser $sms(num)] } {
            putdcc $idx "$sms(erreur) username invalide: $sms(num)"
            return 0
        }
        if { [getuser $sms(num) xtra PHONE] == "" } {
            putdcc $idx "$sms(erreur) aucun num�ro correspondant � \002$sms(num)\002"
            return 0
        }
        set sms(handle) $sms(num)
        set sms(num) [getuser $sms(num) xtra PHONE]
    }

    regsub -all " " $sms(msg) "+" sms(msg)
    regsub -all "`" $sms(msg) "_" sms(msg)

    set jour [clock format [clock seconds] -format "%d"]
    set mois [sms:dcc:mois]
    set annee [clock format [clock seconds] -format "%Y"]
    set heure [clock format [clock seconds] -format "%H"]
    set heure [expr $heure]
    set minute [clock format [clock seconds] -format "%M"]
    set minute [expr $minute]
    set tpsunix [unixtime]
    set tpsunix "[string range $tpsunix 0 [expr [string length $tpsunix] -2]]0000"
    set longueur [expr 120 - [string length $sms(msg)]]

#    set sms(idx) [connect 213.186.33.4 80]
#    putdcc $sms(idx) "GET http://www.oz-warez.com/sms.php?numero=$sms(num)&texte=$sms(msg)"

#    set sms(idx) [connect 160.92.109.161 80]
#    putdcc $sms(idx) "GET http://services.sfr.fr/FormulaireSMSSfrPageFind.servlet?PAGE_COURANTE=%2Ftextoweb%2FsaisieTextoSfr.jsp&PAGE_SUIVANTE=%2Ftextoweb%2FconfirmationEnvoiTextoSfr.jsp&NOTIFICATION_FLAG=false&LANGUAGE=FR&NETWORK=smsc1&DELIVERY_TIME=1042100520000&VALIDITY_PERIOD=72&DELIVERY_DATE=$jour&DELIVERY_MONTH=$mois&DELIVERY_YEAR=$annee&DELIVERY_HOUR=$heure&DELIVERY_MIN=$minute&NOTIFICATION_ADDRESS=&SENDER=$hand&NUM_SENDER=$sms(num)&RECIPIENT=&MINI_TEXTO=0&SHORT_MESSAGE=$sms(msg)&caracteres=102"

#    set sms(idx) [connect 160.92.109.161 80]
#    putdcc $sms(idx) "GET http://services.vizzavi.fr/FormulaireSMSVizzaviPageFind.servlet?PAGE_COURANTE=%2Ftextoweb%2FsaisieTextoVizzavi.jsp&PAGE_SUIVANTE=%2Ftextoweb%2FconfirmationEnvoiTextoVizzavi.jsp&NOTIFICATION_FLAG=false&LANGUAGE=FR&NETWORK=smsc1&DELIVERY_TIME=1042105440000&VALIDITY_PERIOD=72&DELIVERY_DATE=$jour&DELIVERY_MONTH=$mois&DELIVERY_YEAR=$annee&DELIVERY_HOUR=$heure&DELIVERY_MIN=$minute&NOTIFICATION_ADDRESS=&SENDER=$hand&NUM_SENDER=&RECIPIENT=$sms(num)&MINI_TEXTO=0&SHORT_MESSAGE=$sms(msg)&caracteres=102"
#    control $sms(idx) sms:ibu:ctrl

    putdcc $sms(exp) "$sms(envoi) En cours d'envoi..."
#    putdcc $sms(exp) "http://services.vizzavi.fr/FormulaireSMSVizzaviPageFind.servlet?PAGE_COURANTE=%2Ftextoweb%2FsaisieTextoVizzavi.jsp&PAGE_SUIVANTE=%2Ftextoweb%2FconfirmationEnvoiTextoVizzavi.jsp&NOTIFICATION_FLAG=false&LANGUAGE=FR&NETWORK=smsc1&DELIVERY_TIME=$tpsunix&VALIDITY_PERIOD=72&DELIVERY_DATE=$jour&DELIVERY_MONTH=$mois&DELIVERY_YEAR=$annee&DELIVERY_HOUR=$heure&DELIVERY_MIN=$minute&NOTIFICATION_ADDRESS=&SENDER=$hand&NUM_SENDER=&RECIPIENT=$sms(num)&MINI_TEXTO=0&SHORT_MESSAGE=$sms(msg)&caracteres=$longueur"

    set token [http::geturl "http://services.vizzavi.fr/index.jsp?service=textoweb"]
    set fv [open scripts/sms.txt w+] 
    puts $fv [http::data $token]
    close $fv
    http::Finish $token

    set token [http::geturl "http://services.vizzavi.fr/FormulaireSMSVizzaviPageFind.servlet?PAGE_COURANTE=%2Ftextoweb%2FsaisieTextoVizzavi.jsp&PAGE_SUIVANTE=%2Ftextoweb%2FconfirmationEnvoiTextoVizzavi.jsp&NOTIFICATION_FLAG=false&LANGUAGE=FR&NETWORK=smsc1&DELIVERY_TIME=$tpsunix&VALIDITY_PERIOD=72&DELIVERY_DATE=$jour&DELIVERY_MONTH=$mois&DELIVERY_YEAR=$annee&DELIVERY_HOUR=$heure&DELIVERY_MIN=$minute&NOTIFICATION_ADDRESS=&SENDER=$hand&NUM_SENDER=&RECIPIENT=$sms(num)&MINI_TEXTO=0&SHORT_MESSAGE=$sms(msg)&caracteres=$longueur"]
    set fv [open scripts/sms.txt w+] 
    puts $fv [http::data $token]
    close $fv
    http::Finish $token

    set openAcces "[open scripts/sms.txt r]"
    while { ![eof $openAcces] } {
        set texteLu [gets $openAcces]

        regsub -all "�" $texteLu "e" texteLu
        regsub -all "�" $texteLu "e" texteLu
        regsub -all "�" $texteLu "E" texteLu
        regsub -all "�" $texteLu "o" texteLu
        regsub -all "�" $texteLu "a" texteLu

        if {[string match "*Votre message a bien ete envoye*" $texteLu]} {
            if { [info exists smsname($sms(num))] } {
                putdcc $sms(exp) "$sms(envoi) Message envoy� �\002 $smsname($sms(num))\002 !"
                putlog "#$hand# $smsname($sms(num)) $sms(origin)"
            } elseif { $sms(handle) != "" } {
                putdcc $sms(exp) "$sms(envoi) Message envoy� �\002 $sms(handle)\002 !"
                putlog "#$hand# sms $sms(handle) \[message\]"
            } else {
                putdcc $sms(exp) "$sms(envoi) Message envoy� au\002 $sms(num)\002 !"
                putlog "#$hand# sms \[numero\] \[message\]"
            }
        }
        if { [string match "*Le service est momentanement sature*" $texteLu] } {
            putdcc $sms(exp) "$sms(envoi) Le service est momentanement satur�"
        }
        if { [string match "*Error report*" $texteLu] } {
            putdcc $sms(exp) "$sms(envoi) Error report"
        }
        if { [string match "*Votre destinataire n'est pas un abonne SFR*" $texteLu] } {
            putdcc $sms(exp) "$sms(envoi) Votre destinataire n'est pas un abonn� SFR."
        }
        if { [string match "*maximum*" $texteLu] } {
            putdcc $sms(exp) "$sms(envoi) Nombre de SMS d�pass�s"
        }
        if { [string match "*probleme est survenu*" $texteLu] } {
            putdcc $sms(exp) "$sms(envoi) Un probl�me est survenu lors de l'envoi de votre texto"
        }
        if { [string match "*ne pouvez pas envoyer plus de trois textos par*" $texteLu] } {
            putdcc $sms(exp) "$sms(envoi) Vous ne pouvez pas envoyer plus de trois textos par jour"
        }

    }
    close $openAcces
}



##############################
# test de validit� du num�ro #
##############################

proc sms:dcc:testnum {mas} {
    foreach i [split $mas {}] {
        if ![string match \[0-9\] $i] {
            return 0
        }
    }
    return 1
}

proc sms:dcc:mois { } {
  set string [clock format [clock seconds] -format "%m"]
  switch -exact $string {
    "01" { return 0 }
    "02" { return 1 }
    "03" { return 2 }
    "04" { return 3 }
    "05" { return 4 }
    "06" { return 5 }
    "07" { return 6 }
    "08" { return 7 }
    "09" { return 8 }
    "10" { return 9 }
    "11" { return 10 }
    "12" { return 11 }
  }
}
