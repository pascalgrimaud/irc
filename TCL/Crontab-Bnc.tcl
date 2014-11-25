#
# Crontab-Bnc.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#



#################
# Configuration #
#################

# nick pour le service
set testbnc(nick) "testing-ibu"

# identd
set testbnc(user) "Ibu"

# realname
set testbnc(realname) "Ghost Test"

# server et port
set testbnc(server) "Irc.Voila.Fr"
set testbnc(port) "6667"

# server et port du Bnc
set testbnc(bncserver) "Webs8.x-echo.com"
set testbnc(bncport) "1111"
set testbnc(bncpass) "b0unc3r"

# temps en minute pour le controle
set testbnc(timer) 3

# temp en seconde pour l'acceptation du Bnc
set testbnc(timerok) 30

# nombre d'essaie impossible avant de kill les bots
set testbnc(nbessai) 3

# répertoire racine
set DefaultCd "/home/Ibu/Robots/U"

# liste des eggs à restart/killer
set PidFileList {
   "/home/Ibu/Robots/OperServ operserv.conf pid.OperServ 0"
   "/home/Ibu/Robots/C c.conf pid.C 0"
   "/home/Ibu/Robots/N n.conf pid.N 0"
   "/home/Ibu/Robots/KheldAr kheldar.conf pid.KheldAr 0"
   "/home/Ibu/Robots/indispensable indispensable.conf pid.InDiSpEnSaBle 0"
   "/home/Ibu/Robots/ntbot ntbot.conf pid.NT`Bot 1"
   "/home/Ibu/Robots/NickServ nickserv.conf pid.NickServ 0"
   "/home/Ibu/Robots/P p.conf pid.P 0"
   "/home/Ibu/Robots/ChanServ chanserv.conf pid.ChanServ 0"
   "/home/Ibu/Robots/akbot akbot.conf pid.aK-Bot- 1"
   "/home/Ibu/Robots/K k.conf pid.K 0"
}



########
# Motd #
########

putlog "Crontab-Bnc.tcl par NitrO - radium@iquebec.com et Ibu - ibu_lordaeron@yahoo.fr"
putlog "     Aide/Info --> .crontab"



##################
# initialisation #
##################

set testbnc(cpte) 0



#####################
### Aide en ligne ###
#####################

bind dcc -|- crontab nitro:dcc:crontab

proc nitro:dcc:crontab { hand idx arg } {

  putdcc $idx " "
  putdcc $idx "     Crontab-Bnc.tcl - Info     "
  putdcc $idx " "
  putdcc $idx " "
  putdcc $idx "Description :"
  putdcc $idx " "
  putdcc $idx "   Ce script permet d'exécuter des commandes directement sur le shell."
  putdcc $idx "   Utile pour repartir un autre egg sans entrer sur le shell account..."
  putdcc $idx " "
  putdcc $idx "Commandes :"
  putdcc $idx " "
  putdcc $idx "   .startbot \[-f\] (Test la présence des autres eggdrops du shell et les restart au besoin (-f pour forcer))"
  putdcc $idx "   .killbot (Kill le process des autres eggdrops du shell)"
  putdcc $idx " "
  putdcc $idx "   .shellusage (Permet de visualiser les process actifs du shell avec leurs statistiques)"
  putdcc $idx "   .killprocess (Kill un process en particulier -> Pour voir les process, tapez .shellusage)"
  putdcc $idx " "

  return 1

}



####################################
### Relancement des eggs par DCC ###
####################################

bind dcc n startbot nitro:dcc:startbot

proc nitro:dcc:startbot { hand idx arg } {
  if { [string tolower $arg] == "-f" } {
    testbnc:killbot
    testbnc:startbotforce
    putlog "#$hand# startbot -f -> redémarrage en force des bots"
  } else {
    testbnc:startbot
    putlog "#$hand# startbot -> redémarrage des bots"
  }
  return
}

proc testbnc:startbot { } {
  global PidFileList DefaultCd

  set TempExecFile ""

  foreach i $PidFileList {
    if { [file exist [lindex $i 0]/[lindex $i 1]] } {
      if { [file exist [lindex $i 0]/[lindex $i 2]] == 0 } {
        cd [lindex $i 0]
        putloglev 7 * "\[StartBot\] -> [lindex $i 1] lancement..."
        catch { exec ./eggdrop [lindex $i 1] } temp
        cd $DefaultCd
      } else {
        putloglev 7 * "\[StartBot\] -> [lindex $i 2] existe... bot déjà lancé!"
      }
    } else {
      putloglev 7 * "\[StartBot\] -> Fichier exécutable inexistant... Vérifier le chemin entré dans le script!"
    }
  }
  putloglev 8 * "(DEBUG) redémarrage des bots -> cd $DefaultCd"
  cd $DefaultCd

  return 1
}

proc testbnc:startbotforce { } {
  global PidFileList DefaultCd

  set TempExecFile ""

  foreach i $PidFileList {
    if { [file exist [lindex $i 0]/[lindex $i 1]] } {
      if { [file exist [lindex $i 0]/[lindex $i 2]] == 1 } {
        catch { exec rm [file exist [lindex $i 0]/[lindex $i 2]] } temp
      }
      cd [lindex $i 0]
      putloglev 7 * "\[StartBot\] -> [lindex $i 1] lancement..."
      catch { exec ./eggdrop [lindex $i 1] } temp
      cd $DefaultCd
    } else {
      putloglev 7 * "\[StartBot\] -> Fichier exécutable inexistant... Vérifier le chemin entré dans le script!"
    }
  }
  putloglev 8 * "(DEBUG) redémarrage des bots -> cd $DefaultCd"
  cd $DefaultCd

  return 1
}


##########################################
### Arrêt des process eggdrops par DCC ###
##########################################

bind dcc n killbot nitro:dcc:killbot

proc nitro:dcc:killbot { hand idx arg } {
   testbnc:killbot
}

proc testbnc:killbot { } {
 global PidFileList

	set PidFile ""

	foreach i $PidFileList {
		set PidFile [lindex $i 2]
		if {[file exist [lindex $i 0]/$PidFile]} {
                    if { [lindex $i 3] == 1 } {
			set PidFileLecture "[open [lindex $i 0]/$PidFile r]"
			set PidNumber [gets $PidFileLecture]

			catch { exec kill -9 $PidNumber } temp
			catch { exec rm [lindex $i 0]/$PidFile } temp
			putloglev 7 * "\[KillBot\] -> Arrêt du process pour l'eggdrop identifié par $PidNumber ([lindex $i 1])"
			close $PidFileLecture
                    } else {
			putloglev 7 * "\[KillBot\] -> non arrêt du process pour l'eggdrop identifié par $PidNumber ([lindex $i 1])"
                    }

		} else {
			putloglev 7 * "\[KillBot\] -> $PidFile est introuvable ou alors le process du egg a déjà été arrêté!"
		}

	}

	return 1

}




#################################################
### Arrêt d'un process en particulier par DCC ###
#################################################

bind dcc n killprocess nitro:dcc:killprocess

proc nitro:dcc:killprocess { hand idx vars } {

	set PidNumber [lindex $vars 0]
	set Raison [lrange $vars 1 end]

	if { ($PidNumber != "") && ($PidNumber > 0) && ($PidNumber < 32768) } {

		exec kill -9 $PidNumber
		putdcc $idx "\[KillProcess\] -> Process arrêté avec succès!"

	} else {
		putdcc $idx "\[KillProcess\] -> Erreur! Le PID est d'un format invalide!"
		return 0
	}

	return 1

}



######################################################################################
### Liste des process lancés sur le shell avec les ressources utilisées par chacun ###
######################################################################################
bind dcc n shellusage nitro:dcc:psux

proc nitro:dcc:psux { hand idx arg } {

#	rehash
	ProcessCheck $idx
	return 1

}

proc ProcessCheck { Handidx } {

	dccsimul $Handidx ".tcl exec ps ux"
	return "ProcessCheck $Handidx"

}



##################
# Lancer le test #
##################

proc testbncsock {hand idx text} {
    global testbnc
    if { [info exists testbnc(idx)] } {
        if { [valididx $testbnc(idx)] } {
            killdcc $testbnc(idx)
        }
    }
    testbnc:connect
    return 1
}

proc testbnc:timeout { } {
    global testbnc

    if { $testbnc(ok) == 0 } {
	testbnc:killco
        incr testbnc(cpte)
	putloglev 7 * "\[\002Connex Bnc Echo\002\] [b][4]Bounce Echo offline![o] (essai n°$testbnc(cpte))"
        if { $testbnc(cpte) >= $testbnc(nbessai) } {
          testbnc:killbot
        }
    }    
}

proc testbnc:connect { } {
    global testbnc

    if { [testbnc:test] == 0 } {
        set testbnc(ok) 0

        utimer $testbnc(timerok) testbnc:timeout

        if { ![catch {connect $testbnc(bncserver) $testbnc(bncport) } testbnc(idx)]} {
            putloglev 7 * "\[\002Connex Bnc Echo\002\] Tentative de connexion..."
            putdcc $testbnc(idx) "USER $testbnc(user) $testbnc(user) $testbnc(user) :$testbnc(realname)"
            putdcc $testbnc(idx) "NICK $testbnc(nick) localhost r :$testbnc(realname)"
            control $testbnc(idx) testbnc:event
        } else {
            putloglev 7 * "\[\002Connex Bnc Echo\002\] Connexion impossible..."
        }
    } else {
	testbnc:killco
    }

    timer $testbnc(timer) testbnc:connect
    return 0
}

proc testbnc:event { idx arg } {
    global testbnc

    set arg [nojoin $arg]

    if { [lindex $arg 0] == "PING" } {
        putdcc $idx "PONG [lindex $arg 1]"
    }
    if { [join $arg] == "NOTICE AUTH :You need to say /quote PASS <password>" } {
        set testbnc(ok) 1
        set testbnc(cpte) 0
	putloglev 7 * "\[\002Connex Bnc Echo\002\] [b][3]Bounce Echo en ligne!"
	testbnc:killco
	testbnc:killtime

	testbnc:startbot
    }

    return 0
}



################################################
# Procédure de test si ya connexion du service #
################################################

proc testbnc:test { } {
    global testbnc

    set testbnc(existidx) 0
    foreach i [dcclist] {
        if { "[lindex $i 4]" == "scri  testbnc:event" } {
            incr testbnc(existidx)
        }
    }
    return $testbnc(existidx)
}




#######################
# Procédures diverses #
#######################

proc testbnc:killco { } {
        foreach i [dcclist] {
            if { "[lindex $i 4]" == "scri  testbnc:event" } {
                putloglev 7 * "\[\002Connex Bnc Echo\002\] Déconnexion... (Idx = [lindex $i 0])" 
                killdcc [lindex $i 0]
            }
        }
}

proc testbnc:killtime { } {
	foreach t [utimers] {
		if { [string match *testbnc:timeout* [lindex $t 1]] } {
			killutimer [lindex $t 2]
		}
	}
}

proc testbnc:killtimeco { } {
	foreach t [timers] {
		if { [string match *testbnc:connect* [lindex $t 1]] } {
			killtimer [lindex $t 2]
		}
	}
}



####################
# Lancement du TCL #
####################

testbnc:killco
testbnc:killtime
testbnc:killtimeco
testbnc:connect

