#################################################################################
########## NitrO, ################################################
########## Powered by radium #######################
############################################ - Crontab.tcl
########## nitro@radium-x.org ######################
########## http://www.radium-x.org ###############################
#################################################################################



#======================================================
#
# Paramètres
#
#======================================================

# Entrez l'accès au fichier exécutable de tous les autres eggdrops. (Ex.: /home/nitro/botchk)
set ExecFileList {

      "/home/tittof/robots/bbnibu/botchk"

}

# Entrez la liste des PID file des autres eggs (L'ordre n'a pas d'importance)
set PidFileList {

   "/home/tittof/robots/bbnibu/pid.BBnibu"

}




#------------------------------------------------------
#
# Script
#
#------------------------------------------------------


putlog "Crontab.tcl par NitrO - nitro@radium-x.org"
putlog "     Aide/Info --> .crontab"
putlog " "


#############
### Binds ###
#############

bind dcc -|- crontab nitro:dcc:crontab
bind dcc n startbot nitro:dcc:startbot

bind dcc n killbot nitro:dcc:killbot
bind dcc n killbnc nitro:dcc:killbnc

bind dcc n killprocess nitro:dcc:killprocess
bind dcc n shellusage nitro:dcc:psux


#####################
### Aide en ligne ###
#####################

proc nitro:dcc:crontab { hand idx arg } {
 global BncExecFile

	putdcc $idx " "
	putdcc $idx "     Crontab.tcl - Info     "
	putdcc $idx " "
	putdcc $idx " "
	putdcc $idx "Description :"
	putdcc $idx " "
	putdcc $idx "   Ce script permet d'exécuter des commandes directement sur le shell."
	putdcc $idx "   Utile poue repartir un autre egg, un bounce sans entrer sur le shell account..."
	putdcc $idx " "
	putdcc $idx " "
	putdcc $idx "Paramètres présents :"
	putdcc $idx " "
	putdcc $idx "  Exécutable du BNC : $BncExecFile"
	putdcc $idx " "
	putdcc $idx " "
	putdcc $idx "Commandes :"
	putdcc $idx " "
	putdcc $idx "   .startbot (Test la présence des autres eggdrops du shell et les restart au besoin)"
	putdcc $idx "   .startbnc (Test la présence d'un bounce sur le shell et le restart au besoin)"
	putdcc $idx "   .killbot (Kill le process des autres eggdrops du shell)"
	putdcc $idx "   .killbnc (Kill le process d'un bounce sur le shell)"
	putdcc $idx " "
	putdcc $idx "   .shellusage (Permet de visualiser les process actifs du shell avec leurs statistiques)"
	putdcc $idx "   .killprocess (Kill un process en particulier -> Pour voir les process, tapez .shellusage)"
	putdcc $idx " "

	return 1

}


####################################
### Relancement des eggs par DCC ###
####################################

proc nitro:dcc:startbot { hand idx arg } {
 global ExecFileList

	set TempExecFile ""

	foreach TempExecFile $ExecFileList {

		if {[file exist $TempExecFile]} {

			putdcc $idx "\[StartBot\] -> Démarrage des autres robots présents sur le shell..."
			putlog "#$hand# startbot"
			exec chmod u+x $TempExecFile
			exec $TempExecFile

		} else {
			putdcc $idx "\[StartBot\] -> Fichier exécutable inexistant... Vérifier le chemin entré dans le script!"
			return 0
		}

	}

	return

}





##########################################
### Arrêt des process eggdrops par DCC ###
##########################################

proc nitro:dcc:killbot { hand idx arg } {
 global PidFileList

	set PidFile ""

	foreach PidFile $PidFileList {
		if {[file exist $PidFile]} {

			set PidFileLecture "[open $PidFile r]"
			set PidNumber [gets $PidFileLecture]

			exec kill -9 $PidNumber

			putdcc $idx "\[KillBot\] -> Arrêt du process pour le eggdrop identifié par $PidNumber"
			close $PidFileLecture

		} else {
			putdcc $idx "\[KillBot\] -> $PidFile est introuvable ou alors le process du egg a déjà été arrêté!"
			return 0
		}

	}

	return 1

}




##########################################
### Arrêt du process du bounce par DCC ###
##########################################

proc nitro:dcc:killbnc { hand idx arg } {
 global BncPidFile

	if {[file exist $BncPidFile]} {

		set LecturePidFile "[open $BncPidFile r]"
		set PidNumber [gets $BncPidFile]

		if { $PidNumber != "" } {

			exec kill -9 $PidNumber
			putdcc $idx "\[KillBNC\] -> Arrêt du process pour le bounce identifié par $PidNumber"

		} else {
			putdcc $idx "\[KillBNC\] -> Le process du bounce a déjà été arrêté!"
			return 0
		}
		close $LecturePidFile

	} else {
		putdcc $idx "\[KillBNC\] -> $BncPidFile est introuvable ou alors le process du bounce a déjà été arrêté!"
		return 0
	}

	return 1

}




######################################################################################
### Liste des process lancés sur le shell avec les ressources utilisées par chacun ###
######################################################################################

proc nitro:dcc:psux { hand idx arg } {

	rehash
	utimer 5 [ProcessCheck $idx]
	return 1

}

proc ProcessCheck { Handidx } {

	dccsimul $Handidx ".tcl exec ps ux"
	return "ProcessCheck $Handidx"

}



#################################################
### Arrêt d'un process en particulier par DCC ###
#################################################

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



######################################
### Relancement automatique du egg ###
######################################

proc AutoRestartBot {} {




}










