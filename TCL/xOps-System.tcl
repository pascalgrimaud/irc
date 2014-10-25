#
# xOps.tcl par NitrO <radium@iquebec.com> & Ibu <ibu_lordaeron@yahoo.fr>
#
# TCL permettant a un eggdrop de gerer une base de donnees des Xops.
# Ces fichiers se trouvent ds le repertoire desire.
#
# Dernieres modifs faites le 01/01/02 par Ibu :O)
# - ajout du .[+/-]xunlimit
#
# Modif: systeme d'auth pour le xopage par kaworu
#

### Flags ###
#
# +G (global) : acces a la gestion des fichiers
#
# +o (global) : permet de consulter n'importe quel listes
# +m (global) : permet de modifier n'importe quel listes
#
# +o (local)  : permet de consulter une liste specifique
# +m (local)  : permet de modifier une liste specifique
#
# +n (global) : permet de creer le repertoire donnees
#               permet de supprimer n'importe quel fichier
#               permet d'ajouter et de retirer les salons
#
# +n #ircop : permet de modifier n'importe quelle liste!
#             Un +n sur #ircop n'est pas forcement IRCop du reseau
#             Il lui permet just' de modifier toutes les listes.
#             Utile pour un xOpeur regulier
#
# --- Modification du 20/04 ---
#   Un +G peut consulter n'importe quel liste, mais s'il n'a pas le
#   +o sur le chan, il ne pourra pas consulter les infos.
#
#############





#================================================================================
#
# Motd
#
#================================================================================

putlog "\002xOps.tcl\002 par \002NitrO\002 <radium@iquebec.com> & \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"
putlog "     Aide --> \002.xopshelp\002"





#================================================================================
#
# Parametres a modifier
#
#================================================================================

# Entrez le repertoire de stockage des donnees. (Sans de / a la fin! :O))
#set datadir "/home/elorie/robots/fichiers/donnees"
set datadir "/home/tittof/robots/fichiers/donnees"


# Entrez la liste des salons de base.
# (La où seront mis les flags par defaut selon le niveau -> CM ou Geo)
set chanlist {  "#mls" 
                "#cms"
                "#geofront"
                "#globaux"
                "#ircop"                
		"#chan_admin" }





#######################
# Section Chanmasters #
#######################

# Flags globaux a mettre aux ChanMasters.
set cmglobalflags "fhpG"

# Flags locaux a mettre aux ChanMasters sur les salons de base.
set cmlocalflags "fo"

# Entrez le flag qu'ont les ChanMasters sur leur salon respectif de plus que les autres.
set cmflag "fmo"

# Entrez le salon où se tiendra la liste des Chanmasters de tous les salons enregistres.
set defsaloncm "#cms"


#########################
# Section Geofrontistes #
#########################

# Flags globaux a mettre aux Geofrontistes.
set geoglobalflags "fhopG"

# Flags locaux a mettre aux Geofrontistes sur les salons de base. (sauf le salon des IRCops)
set geolocalflags "fmo"


##################
# Section IRCops #
##################

# Entrez le salon par defaut contenant la liste des IRCops.
# (a mettre dans la liste de salons de base aussi!)
set chanircop "#ircop"

# Flags globaux a mettre aux IRCops.
set ircopglobalflags "fhopG"

# Flags locaux a mettre aux IRCops sur les salons de base enumeres ci-dessus.
set ircoplocalflags "fmno"


#################
# Section ADMIN #
#################

# Flags globaux a mettre aux Admins
set adminglobalflags "fhjmoptxG"

# Flags locaux a mettre aux Admins sur les salons de base
set adminlocalflags "fmno"


#################
# Section Owner #
#################

# Flags globaux a mettre aux owners du bot
set ownerglobalflags "fhjmnoptxG"


##################
# Autres Options #
##################

# Entre les salons où vous ne voulez pas que la date et le nom du createur soit affichee
# (Peut être laissee vide)
set NoCreateInfoChan { "#geofront" 
                       "#globaux" 
                       "#ircop"
                       "#url" }

# Limite d'xOps
set LimitexOps 5



#================================================================================
#
# Debut du script! Ne pas toucher a ce qui suit sauf si vous savez ce que vous
#  faites!
# Binds
#
#================================================================================

bind dcc -|- xopshelp xops:dcc:xopshelp
bind dcc -|- xchan xops:dcc:xchan
bind dcc -|- xunlimit xops:dcc:xunlimit
bind dcc -|- xops xops:dcc:xops
bind dcc -|- xsearch xops:dcc:xsearch
bind dcc -|- xinfo xops:dcc:xinfo

bind dcc -|- +xops xops:dcc:addnick
bind dcc -|- -xops xops:dcc:remnick

bind dcc -|- +xchan xops:dcc:addchan
bind dcc -|- -xchan xops:dcc:remchan
bind dcc -|- +xunlimit xops:dcc:addunlimit
bind dcc -|- -xunlimit xops:dcc:remunlimit
bind dcc -|- xdonnees xops:dcc:donnees

bind msg -|- auth fo_auth
bind part - * fo_partdeauth
bind dcc o|- verify xops:dcc:verify
bind msg Z|Z xop xops:msg:ask

proc xops:dcc:xopshelp {hand idx arg} {

    set arg [split $arg]

    if { [matchattr $hand G] } {
        putdcc $idx "     xOps - Help     "
        putdcc $idx " "
        putdcc $idx "Pour ChanMasters & Geofrontistes:"
        putdcc $idx "   xchan \[channel\] 14(voir ou verifier la liste des chans de la base de donnee)"
        putdcc $idx "   xunlimit \[channel\] 14(voir ou verifier la liste des chans illimites en xOps)"
        putdcc $idx "   xops <channel> \[nick|string\] 14(voir la liste des xops ou verifie un nick)"
        putdcc $idx "   xinfo <channel> <string> 14(Recherche d'une Info ds la liste du salon)"
        putdcc $idx "   xsearch <string> 14(Recherche d'un xope ds la base de donnee en entiere)"
        putdcc $idx " "
        putdcc $idx "Pour ChanMasters:"
        putdcc $idx "   +xops <channel> <nick> <host> <password> \[info\] 14(ajoute un xop ou une info)"
        putdcc $idx "   -xops <channel> <nick> \[info\] 14(retire un xop ou une info)"
        putdcc $idx " "
        if { [matchattr $hand m] } {
            putdcc $idx "Pour Masters du bot:"
#            putdcc $idx "   xaddowner <pseudo> 14(Ajoute un Owner avec les flags par defaut -> +n seulement)"
            putdcc $idx "   xaddadmin <pseudo> 14(Ajoute un Admin avec les flags par defaut -> +n seulement)"
            putdcc $idx "   xaddircop <pseudo> 14(Ajoute un IRCop avec les flags par defaut)"
            putdcc $idx "   xaddgeo <pseudo> 14(Ajoute un geofrontiste avec les flags par defaut)"
            putdcc $idx "   xaddcm <pseudo> <salon> 14(Ajoute un CM sur un salon specifique)"
            putdcc $idx " "
            putdcc $idx "   +xchan <channel> 14(ajouter un chan autorise)"
            putdcc $idx "   -xchan <channel> 14(effacer un chan autorise)"
            putdcc $idx "   +xunlimit <channel> 14(ajouter un chan illimite niveau des xOps)"
            putdcc $idx "   -xunlimit <channel> 14(effacer un chan illimite niveau des xOps)"
            putdcc $idx "   xdonnees 14(cree le repertoire donnees s'il n'existe pas)"
            putdcc $idx " "
        }
        putdcc $idx "NB: un +n sur #ircop peut modifier n'importe quelle liste"
        putdcc $idx "      Un +n sur #ircop n'est pas forcement IRCop du reseau!"
        putdcc $idx " "
        putdcc $idx "xopshelp <-- aide, vs êtes ici!"
        putdcc $idx " "
        return 1
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}





#================================================================================*/
#
# Raccourcis party-line par NitrO@radium-x.org
#
#================================================================================*/

bind dcc m|- xaddcm xops:dcc:xaddcm
bind dcc m|- xaddgeo xops:dcc:xaddgeo
bind dcc m|- xaddircop xops:dcc:xaddircop
bind dcc n|- xaddadmin xops:dcc:xaddadmin
bind dcc n|- xaddowner xops:dcc:xaddowner

bind dcc -|- xdelcm xops:dcc:xdelcm

#################
# Ajout d'un CM #
#################

proc xops:dcc:xaddcm { hand idx arg } {
  global cmglobalflags cmlocalflags cmflag chanlist defsaloncm

    set arg [split $arg]
    set pseudo [lindex $arg 0]
    set cmchan [lindex $arg 1]
    set salon ""

    if { $pseudo != "" && $cmchan != "" } {
        if {[validuser $pseudo]} {
            if {[validchan $cmchan]} {
                chattr $pseudo -fhjmoptxv
                chattr $pseudo +$cmglobalflags
                foreach salon $chanlist {
                    chattr $pseudo -|-fmnovadkG $salon
                    chattr $pseudo -|+$cmlocalflags $salon
                }
                chattr $pseudo -|+$cmflag $cmchan
                chattr $pseudo -|+$cmflag $defsaloncm
                chattr $pseudo -|+$cmflag #mls

                putdcc $idx "\[XAddCM\] -> Succes!"
                putdcc $idx "            $pseudo est maintenant enregistre(e) comme Chanmaster de $cmchan"
                setuser $pseudo comment "Ajout comme Chanmaster par $hand"
                save

            } else {
                putdcc $idx "\[XAddCM\] -> Erreur! $cmchan n'est pas un salon valide!"
                return 0
            }
        } else {
            putdcc $idx "\[XAddCM\] -> Erreur! $pseudo n'existe pas!"
            return 0
        }
    } else {
        putdcc $idx "\[XAddCM\] -> Erreur! Usage : .xaddcm <pseudo> <#salon>"
    }

    return 1
}

###################
# Retrait d'un CM #
###################

proc xops:dcc:xdelcm { hand idx arg } {
  global chanircop cmglobalflags cmlocalflags cmflag chanlist defsaloncm

   if { [matchattr $hand |n $chanircop] || [matchattr $hand +m] } {
 
    set arg [split $arg]
    set pseudo [lindex $arg 0]
    set cmchan [lindex $arg 1]
    set salon ""

    if { $pseudo != "" && $cmchan != "" } {
        if {[validuser $pseudo]} {
            if {[validchan $cmchan]} {
                chattr $pseudo -fhjmoptxv
                chattr $pseudo -$cmglobalflags
                foreach salon $chanlist {
                    chattr $pseudo -|-fmnovadkG $salon
                    chattr $pseudo -|-$cmlocalflags $salon
                }
                chattr $pseudo -|-$cmflag $cmchan
                chattr $pseudo -|-$cmflag $defsaloncm
                chattr $pseudo -|-$cmflag #mls

                putdcc $idx "\[XDelCM\] -> Succes!"
                putdcc $idx "            $pseudo n'est plus enregistre(e) comme Chanmaster de $cmchan"
                save

            } else {
                putdcc $idx "\[XDelCM\] -> Erreur! $cmchan n'est pas un salon valide!"
                return 0
            }
        } else {
            putdcc $idx "\[XDelCM\] -> Erreur! $pseudo n'existe pas!"
            return 0
        }
    } else {
        putdcc $idx "\[XDelCM\] -> Erreur! Usage : .xdelcm <pseudo> <#salon>"
    }
    return 1

  } else {
    putdcc $idx "Quoi? Essayez '.help'"
    return 0
  }
}

###########################
# Ajout d'un Geofrontiste #
###########################

proc xops:dcc:xaddgeo { hand idx arg } {
  global geoglobalflags geolocalflags chanlist chanircop

    set arg [split $arg]
    set pseudo [lindex $arg 0]
    set salon ""

    if { $pseudo != "" } {
        if {[validuser $pseudo]} {
            chattr $pseudo -fhjmoptxvG
            chattr $pseudo +$geoglobalflags
            foreach salon $chanlist {
                chattr $pseudo -|-fmnovadkG $salon
                if {![string match $salon $chanircop]} {
                    # Pour eviter de mettre le +m sur le chan IRCop!
                    chattr $pseudo -|+$geolocalflags $salon
                }
            }
            putdcc $idx "\[XAddGeo\] -> Succes!"
            putdcc $idx "             $pseudo est maintenant enregistre(e) comme Geofrontiste"
            setuser $pseudo comment "Ajout comme Geofrontiste par $hand"
            save

        } else {
            putdcc $idx "\[XAddGeo\] -> Erreur! $pseudo n'existe pas!"
            return 0
        }
    } else {
        putdcc $idx "\[XAddGeo\] -> Erreur! Usage : .xaddgeo <pseudo>"
        return 0
    }
    
    return 1
}


####################
# Ajout d'un IRCop #
####################

proc xops:dcc:xaddircop { hand idx arg } {
  global chanlist chanircop ircoplocalflags ircopglobalflags

    set arg [split $arg]
    set pseudo [lindex $arg 0]
    set salon ""

    if { $pseudo != "" } {
        if {[validuser $pseudo]} {
            chattr $pseudo -fhjmoptxvG
            chattr $pseudo +$ircopglobalflags
            foreach salon $chanlist {
                chattr $pseudo -|-fmnovadkG $salon
                chattr $pseudo -|+$ircoplocalflags $salon
            }
            putdcc $idx "\[XAddIRCop\] -> Succes!"
            putdcc $idx "               $pseudo est maintenant enregistre(e) comme IRCop"
            setuser $pseudo comment "Ajout comme IRCop par $hand"
            save

        } else {
            putdcc $idx "\[XAddIRCop\] -> Erreur! $pseudo n'existe pas!"
            return 0
        }
    } else {
        putdcc $idx "\[XAddIRCop\] -> Erreur!"
        putdcc $idx "\[XAddIRCop\] -> Commande : .xaddircop <pseudo>"
        return 0
    }
    
    return 1
}


####################
# Ajout d'un Admin #
####################

proc xops:dcc:xaddadmin { hand idx arg } {
  global adminglobalflags adminlocalflags chanlist

    set arg [split $arg]
    set pseudo [lindex $arg 0]
    set salon ""

    if { $pseudo != "" } {
        if {[validuser $pseudo]} {
            chattr $pseudo -fhjmoptxvG
            chattr $pseudo +$adminglobalflags
            foreach salon $chanlist {
                chattr $pseudo -|-fmnovadkG $salon
                chattr $pseudo -|+$adminlocalflags $salon
            }
            putdcc $idx "\[XAddAdmin\] -> Succes!"
            putdcc $idx "               $pseudo est maintenant enregistre(e) comme Admin"
            setuser $pseudo comment "Ajout comme Admin par $hand"
            save

        } else {
            putdcc $idx "\[XAddAdmin\] -> Erreur! $pseudo n'existe pas!"
            return 0
        }

    } else {
        putdcc $idx "\[XAddAdmin\] -> Erreur! Usage : .xaddadmin <pseudo>"
        return 0
    }

    return 1

}


####################
# Ajout d'un Owner #
####################

proc xops:dcc:xaddowner { hand idx arg } {



}





#================================================================================
#
# Debut du script. Gestion des commandes de l'Eggdrop
#
#
#================================================================================

#
# Xops <channel> [string]
#
proc xops:dcc:xops {hand idx arg} {
    global datadir 

    set arg [split $arg]
    set XopsChannel [string tolower [lindex $arg 0]]
    set SearchString [string tolower [lindex $arg 1]]
    set NbResults 0

    if { [matchattr $hand G] } {
        if { [XopsChan $XopsChannel] } {
            if { ![string length $XopsChannel] } {
                putdcc $idx "Usage: .xops <channel> \[string\]"
                return 0
            } else {
                if { [matchattr $hand o] || [matchattr $hand |o $XopsChannel] } {

                    if  { $SearchString == "" } {
                        set SearchString "*"
                    }
                    putdcc $idx "-=-  Liste de $XopsChannel  -=-"
                    putdcc $idx " "

                    set LectureFichierAcces "$datadir/$XopsChannel.txt"
                    if { [file exists $LectureFichierAcces] == 0 } {
                        set LectureTemp [open $LectureFichierAcces w+]
                        close $LectureTemp
                    }
                    set LectureTemp "[open $LectureFichierAcces r]"
                    while {![eof $LectureTemp]} {
                        set LectureTexteLu [gets $LectureTemp]
                        set LectureTexteLu [split $LectureTexteLu]

                        set LectureNickLu [lindex $LectureTexteLu 0]
                        set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]

                        if {$LectureNickLu != ""} {
                            set LowerNick [string tolower $LectureNickLu]
                            set LowerInfo [string tolower $LectureNickInfo]
                            if {[string match $SearchString $LowerNick]} {
                               putdcc $idx "   $LectureNickLu $LectureNickInfo"
                               set NbResults [expr $NbResults + 1]
                            }
                        }
                    }
                    close $LectureTemp
                    unset LectureTexteLu
                    unset LectureNickLu
                    unset LectureNickInfo

                    putdcc $idx " "
                    if { $NbResults != 0 } {
                        putdcc $idx "-=- Fin des resultats. Trouves \[ $NbResults \] -=-"
                    } else {
                        putdcc $idx "-=- Aucun resultat correspondant a $SearchString n'a ete trouve -=-"
                    }
                    return 1
                } else {
                    if  { $SearchString == "" } {
                        set SearchString "*"
                    }

                    putdcc $idx "-=-  Liste de $XopsChannel  -=-"
                    putdcc $idx " "

                    set LectureFichierAcces "$datadir/$XopsChannel.txt"
                    if { [file exists $LectureFichierAcces] == 0 } {
                        set LectureTemp [open $LectureFichierAcces w+]
                        close $LectureTemp
                    }
                    set LectureTemp "[open $LectureFichierAcces r]"
                    while {![eof $LectureTemp]} {
                        set LectureTexteLu [gets $LectureTemp]
                        set LectureTexteLu [split $LectureTexteLu]

                        set LectureNickLu [lindex $LectureTexteLu 0]
                        set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]

                        if {$LectureNickLu != ""} {
                            set LowerNick [string tolower $LectureNickLu]
                            set LowerInfo [string tolower $LectureNickInfo]
                            if {[string match $SearchString $LowerNick]} {
                               putdcc $idx "   $LectureNickLu - \[Infos masquees\]"
                               set NbResults [expr $NbResults + 1]
                            }
                        }
                    }
                    close $LectureTemp
                    unset LectureTexteLu
                    unset LectureNickLu
                    unset LectureNickInfo

                    putdcc $idx " "
                    if { $NbResults != 0 } {
                        putdcc $idx "-=- Fin des resultats. Trouves \[ $NbResults \] -=-"
                    } else {
                        putdcc $idx "-=- Aucun resultat correspondant a $SearchString n'a ete trouve -=-"
                    }
                    return 1
                }
            }
        } else {
            putdcc $idx "\[Erreur\] : $XopsChannel n'est pas un salon valide"
            return 0
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}


#
# Xchan [channel]
#
proc xops:dcc:xchan {hand idx arg} {

    set arg [split $arg]

    if { [matchattr $hand G] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { ![string length $XopsChannel] } {
            putdcc $idx "-=-  Liste des Salons Autorises  -=-"
            putdcc $idx " "
            FichierLecture $idx "channel"
            putdcc $idx " "
            putdcc $idx "-=- Fin de la Liste -=-"
            return 1
        } else {
            if { [FichierVerif "channel" $XopsChannel] } {
                putdcc $idx "\[Trouve\] : Le chan $XopsChannel est autorise"
                return 1
            } else {
                putdcc $idx "\[Non-Trouve\] : Le chan $XopsChannel n'est pas autorise"
                return 1
            }
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}


#
# Xunlimit [channel]
#
proc xops:dcc:xunlimit {hand idx arg} {

    set arg [split $arg]

    if { [matchattr $hand G] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { ![string length $XopsChannel] } {
            putdcc $idx "-=-  Liste des Salons non limites  -=-"
            putdcc $idx " "
            FichierLecture $idx "channel-exc"
            putdcc $idx " "
            putdcc $idx "-=- Fin de la Liste -=-"
            return 1
        } else {
            if { [FichierVerif "channel" $XopsChannel] } {
                putdcc $idx "\[Trouve\] : Le chan $XopsChannel est illimite en nombre d'xOps"
                return 1
            } else {
                putdcc $idx "\[Non-Trouve\] : Le chan $XopsChannel n'est pas illimite en nombre d'xOps"
                return 1
            }
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}


#
# Xsearch <string>
#
proc xops:dcc:xsearch {hand idx arg} {
    global datadir xhand

    set arg [split $arg]

    set SearchNick [string tolower [lindex $arg 0]]
    set NbResults 0
    set xhand $hand

    if { [matchattr $hand G] } {
        if { ![string length $SearchNick] || $SearchNick == "*" } {
            if { ![string length $SearchNick] } {
                putdcc $idx "Usage: .xsearch <string>"
                return 0
            } else {
                putdcc $idx "Usage: .xsearch <string> (attention de ne pas mettre une *)"
                return 0
            }                
        } else {
            putdcc $idx "-=-  Recherche sur $SearchNick  -=-"
            putdcc $idx " "

            set LectureFichierAcces "$datadir/channel.txt"
            if { [file exists $LectureFichierAcces] == 0 } {
                set LectureTemp [open $LectureFichierAcces w+]
                close $LectureTemp
            }
            set LectureTemp "[open $LectureFichierAcces r]"

            while {![eof $LectureTemp]} {
                set LectureTexteLu [gets $LectureTemp]
                set LectureTexteLu [split $LectureTexteLu]

                set LectureNickLu [lindex $LectureTexteLu 0]
                set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]
                if { $LectureNickLu != "" } {
                    set LowerNick [string tolower $LectureNickLu]
                    set LowerInfo [string tolower $LectureNickInfo]
                    FichierXSearch $idx $LowerNick $SearchNick
                }
            }

            close $LectureTemp
            unset LectureTexteLu
            unset LectureNickLu
            unset LectureNickInfo

            putdcc $idx " "
            putdcc $idx "-=- Fin des resultats -=-"
            putdcc $idx " "

            return 1
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}


#
# Xinfo <channel> <string>
#
proc xops:dcc:xinfo {hand idx arg} {
    global datadir

    set arg [split $arg]

    set XopsChannel [string tolower [lindex $arg 0]]
    set SearchString [string tolower [lindex $arg 1]]
    set NbResults 0

    if { [matchattr $hand G] } {
        if { [XopsChan $XopsChannel] } {
            if { ![string length $XopsChannel] } {
                putdcc $idx "Usage: .xinfo <channel> \[string\]"
                return 0
            } else {
                if { [matchattr $hand o] || [matchattr $hand |o $XopsChannel] } {

                    if  { $SearchString == "" } {
                        set SearchString "*"
                    }
                    putdcc $idx "-=-  Liste de $XopsChannel  -=-"
                    putdcc $idx " "

                    set LectureFichierAcces "$datadir/$XopsChannel.txt"
                    if { [file exists $LectureFichierAcces] == 0 } {
                        set LectureTemp [open $LectureFichierAcces w+]
                        close $LectureTemp
                    }
                    set LectureTemp "[open $LectureFichierAcces r]"
                    while {![eof $LectureTemp]} {
                        set LectureTexteLu [gets $LectureTemp]
                        set LectureTexteLu [split $LectureTexteLu]

                        set LectureNickLu [join [lrange $LectureTexteLu 0 0]]
                        set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]

                        if {$LectureNickLu != ""} {
                            set LowerNick [string tolower $LectureNickLu]
                            set LowerInfo [string tolower $LectureNickInfo]
                            if {[string match $SearchString $LowerInfo]} {
                               putdcc $idx "   $LectureNickLu $LectureNickInfo"
                               set NbResults [expr $NbResults + 1]
                            }
                        }
                    }
                    close $LectureTemp
                    unset LectureTexteLu
                    unset LectureNickLu
                    unset LectureNickInfo

                    putdcc $idx " "
                    if { $NbResults != 0 } {
                        putdcc $idx "-=- Fin des resultats. Trouves \[ $NbResults \] -=-"
                    } else {
                        putdcc $idx "-=- Aucun resultat correspondant a $SearchString n'a ete trouve -=-"
                    }
                    return 1
                } else {
                    putdcc $idx "\[Erreur\] : Vous n'êtes ni Geofrontiste, ni ChanMaster du salon $XopsChannel"
                    return 0
                }
            }
        } else {
            putdcc $idx "\[Erreur\] : $XopsChannel n'est pas un salon valide"
            return 0
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}


#
# +Xops <channel> <nick> [info]
#
proc xops:dcc:addnick {hand idx arg} {
    global chanircop NoCreateInfoChan LimitexOps NoLimitexOps XopsNick XopsHost XopsPass XopsChannel

    set salon ""
    set temoin 1
    set arg [split $arg]

    if { [matchattr $hand G] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { [XopsChan $XopsChannel] } {
            if ![string length $XopsChannel] {
                putdcc $idx "Usage: .+xops <channel> <nick> <host> <password> \[info\]"
                return 0
            } else {
                if { [matchattr $hand m] || [matchattr $hand |m $XopsChannel] || [matchattr $hand |n $chanircop] } {
                    set XopsNick [lindex $arg 1]
                    if { ![string length $XopsNick] } {
                        putdcc $idx "Usage: .+xops <channel> <nick> <host> <password> \[info\]"
                        putdcc $idx "L'host doit etre de ce format *nick*!*ident@* SVP!!!"
                        return 0
                    } else {

                        foreach salon $NoCreateInfoChan {
                            set salon [string tolower $salon]
                            if { [string match $salon $XopsChannel] } {
                                set temoin 0
                            }
                        }

                        if { [XopsChanUnlimit $XopsChannel] } {
                            set CheckNbxOps 0
                        } elseif { [FichierVerif $XopsChannel $XopsNick] == 1 } {
                            set CheckNbxOps 0
                        } else {
                            set CheckNbxOps [FichierCpt $XopsChannel]
                        }

                        if { $CheckNbxOps < $LimitexOps } {

                            set XopsInfo [join [lrange $arg 2 end]]
                            set XopsHost [lindex [split $XopsInfo] 0]
                            set XopsPass [lindex [split $XopsInfo] 1]
                            if {![string match *@* $XopsHost] && ![XopsChanUnlimit $XopsChannel]} { putdcc $idx "\[Add\] :L'host DOIT être du type *nick*!*ident@*" ; return 0 }
                            if {[string length $XopsPass] < 6 && ![XopsChanUnlimit $XopsChannel]} { putdcc $idx "\[Add\] :Le pass DOIT faire au moins 6 caracteres" ; return 0 }
                            if { [FichierAddInfo $hand $temoin $XopsChannel $XopsNick $XopsInfo]} {
                                putdcc $idx "\[Mod\] : $XopsNick a ete modifie de la liste des Xops de $XopsChannel" 
                            } else {
                                putdcc $idx "\[Add\] : $XopsNick a ete ajoute a la liste des Xops de $XopsChannel" 
                                if {![XopsChanUnlimit $XopsChannel]} { adduser $XopsNick $XopsHost ; chattr $XopsNick -|+fX $XopsChannel ;  setuser $XopsNick pass $XopsPass ; setuser $XopsNick comment "ajout comme xop pour $XopsChannel par $hand" }
                            }
                            putlog "#$hand# +xops $XopsChannel $XopsNick \[Info\]"
                            return
                        } else {
                            putdcc $idx "\[Erreur\] : Limite du nombre d'xOps depasses! (Max autorises: $LimitexOps)" 
                            return
                        }
                    }
                } else {
                    putdcc $idx "\[Erreur\] : Vous n'êtes pas ChanMaster du salon $XopsChannel"
                    return 0
                }
            }
        } else {
            putdcc $idx "\[Erreur\] : $XopsChannel n'est pas un salon valide"
            return 0
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}
##new proc

proc fo_auth {nick uhost hand rest} {
   global fo_authnick botnick

   set rest [split $rest]
   set pw [lindex $rest 0]
   set givenick [lindex $rest 1]

   if [string length $givenick] {
      set hand $givenick
   } else {
      # si l'user est reconnu par le bot
      if ![string compare $hand "*"] {
         putserv "NOTICE $nick :Je ne parle pas aux etrangers"
         return 0
      }
   }
   # si n'a pas le flag +X
   if [lsearch -exact [userlist -|fX] $hand]==-1 {
      putserv "NOTICE $nick :Tu es reconnu, mais tu n'as pas le flag +X. Contacte le possesseur du bot. L'handle sous lequel je te connais : $hand"
      return 0
   }
   # est deja authentifie
   if [info exists fo_authnick($nick)] {
      putserv "NOTICE $nick :Vous êtes deja identifie sous le nick: $fo_authnick($nick)."
      return 0
   }
   # le mot de passe n'est pas donne
   if ![string length $pw] {
      putserv "NOTICE $nick :Veuillez entrer votre mot de passe! => /msg $botnick auth <password>"
      return 0
   }
   # test du mot de passe
   if [passwdok $hand $pw] {
      # correct
      chattr $hand +Z
      set fo_authnick($nick) $hand
      putserv "NOTICE $nick :Authentication reussie!"
      putserv "NOTICE $nick :tapez /msg $botnick xop #salon pour demander votre xopage"
      putcmdlog "($nick!$uhost) !$hand! auth ..."
   } else {
      # incorrect
      putserv "NOTICE $nick :Authentication ratee... essai loggue"
      putcmdlog "($nick!$uhost) !$hand! FAILED auth"
   }
}

proc fo_partdeauth {nick uhost hand chan {msg ""}} {
   global fo_authnick

   if ![info exists fo_authnick($nick)] {
      return 0
   }
   if ![matchattr $fo_authnick($nick) Z] {
      return 0
   }
   foreach channel [channels] {
      if ![fo_strcomp $chan $channel]&&[onchan $nick $channel] {
         return 0
      }
   }
   chattr $fo_authnick($nick) -Z
   unset fo_authnick($nick)
   putserv "NOTICE $nick :DeAuthentication apres un depart d'un channel !"
   return 0
}

proc fo_strcomp { str1 str2 } {
  return ![string compare [string tolower $str1] [string tolower $str2]]
}

proc fo_isauth { nick chan } {
   global fo_authnick

   if ![info exists fo_authnick($nick)] { return "" }
   if [matchattr $fo_authnick($nick) -|X $chan] {
      if [matchattr $fo_authnick($nick) Z] {
         return $fo_authnick($nick)
      }
   }
   return ""
}

proc xops:dcc:verify {hand idx arg} {
  global fo_authnick

  set arg [split $arg]

  if [info exists fo_authnick([lindex $arg 0])] { 
    putdcc $idx "[lindex $arg 0] est authentifie(e) sous l'idnick: $fo_authnick([lindex $arg 0])" ; return 1 
  } else {
    putdcc $idx "[lindex $arg 0] n'est pas authentifie(e)" ; return 1 
  }
}

proc xops:msg:ask {nick uhost hand rest} {
  global fo_authnick datadir xhand

  set rest [split $rest]

  if {![string match *#* [lindex $rest 0]] && [info exists fo_authnick($nick)]} {
    putserv "NOTICE $nick :Veuillez specifier un chan..."
    putcmdlog "($nick!$uhost) !$hand! FAILED xop"
    return 0
  }
  if {[string match *#* [lindex $rest 0]] && [info exists fo_authnick($nick)] && [matchattr $fo_authnick($nick) -|X [lindex $rest 0]]} {
    foreach i [dcclist chat] {
      set xidx [lindex $i 0]
      set xhand [lindex $i 1]
      set type [lindex $i 3]
      if {$type != "BOT" && $type != "DNS" && $type != "TELNET" && $type != "SERVER"} {
        if {[matchattr $xhand o|-]} { 
          set searchfile "[string tolower [lindex $rest 0]]"
          set searchnick "[string tolower $fo_authnick($nick)]"
          putdcc $xidx "\[XOP\] $nick demande un xop sur [lindex $rest 0],son idnick $fo_authnick($nick) => .xop [lindex $rest 0] $nick" 
          FichierXSearch $xidx $searchfile $searchnick 
         
        }
      }
    }  
    putserv "NOTICE $nick :Votre demande d'xop a ete prise en compte, patientez svp..."
    utimer 1 "chattr $fo_authnick($nick) -Z"
    utimer 1 "unset fo_authnick($nick)"    
    return 0
  } else {
    putcmdlog "($nick!$uhost) !$hand! FAILED xop"
    return 0
  }
}     

#
# -Xops <channel> <nick>
#
proc xops:dcc:remnick {hand idx arg} {
    global chanircop

    set arg [split $arg]

    if { [matchattr $hand G] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { [XopsChan $XopsChannel] } {
            if { ![string length $XopsChannel] } {
                putdcc $idx "Usage: .-xops <channel> <nick>"
                return 0
            } else {
                if { [matchattr $hand m] || [matchattr $hand |m $XopsChannel] || [matchattr $hand |n $chanircop] } {
                    set XopsNick [lindex $arg 1]
                    if { ![string length $XopsNick] } {
                        putdcc $idx "Usage: .-xops <channel> <nick>"
                        return 0
                    } else {
                        if { [FichierRemInfo $XopsChannel $XopsNick] } {
                            putdcc $idx "\[Rem\] : $XopsNick a ete retire de la liste des Xops de $XopsChannel"
                            if {[matchattr $XopsNick |X $XopsChannel] && ![matchattr $XopsNick G]} { deluser $XopsNick }
                        } else {
                            putdcc $idx "\[Erreur\] : $XopsNick n'existe pas ds la liste des Xops de $XopsChannel" 
                        }
                        return 1
                    }
                } else {
                    putdcc $idx "\[Erreur\] : Vous n'êtes pas ChanMaster du salon $XopsChannel"
                    return 0
                }
            }
        } else {
            putdcc $idx "\[Erreur\] : $XopsChannel n'est pas un salon valide"
            return 0
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}


#
# Xdonnees
#
proc xops:dcc:donnees {hand idx arg} {
 global datadir
    if { [matchattr $hand G] && [matchattr $hand m] } {
        file mkdir $datadir
        putdcc $idx "\[Add\] : repertoire donnees cree dans le filesystem!" 
        return 1
        complete
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}


#
# +Xchan <channel> [info]
#
proc xops:dcc:addchan {hand idx arg} {
    global botnick

    set arg [split $arg]

    if { [matchattr $hand G] && [matchattr $hand m] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if ![string length $XopsChannel] {
            putdcc $idx "Usage: .+xchan <channel> \[info\]"
            return 0
        } else {
            set XopsInfo [join [lrange $arg 1 end]]
            if { [FichierAddInfo $hand 0 "channel" $XopsChannel $XopsInfo] } {
                putdcc $idx "\[Mod\] : $XopsChannel existe deja ds la liste des salons autorises"
                return 0
            } else {
                putdcc $idx "\[Add\] : $XopsChannel a ete ajoute a la liste des salons autorises" 
                if { ![validchan $XopsChannel] } {
                    channel add $XopsChannel
                    channel set $XopsChannel +inactive
                    savechannels
                }
                return 1
            }
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}


#
# -Xchan <channel>
#
proc xops:dcc:remchan {hand idx arg} {

    set arg [split $arg]

    if { [matchattr $hand G] && [matchattr $hand m] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { ![string length $XopsChannel] } {
            putdcc $idx "Usage: .-xchan <channel>"
            return 0
        } else {
            if { [FichierRemInfo "channel" $XopsChannel] } {
                putdcc $idx "\[Rem\] : $XopsChannel a ete retire de la liste des salons autorises"
                return 1
            } else {
                putdcc $idx "\[Erreur\] : $XopsChannel n'existe pas ds la liste des salons autorises"
                return 0
            }
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}


#
# +xunlimit <channel> [info]
#
proc xops:dcc:addunlimit {hand idx arg} {

    set arg [split $arg]

    if { [matchattr $hand G] && [matchattr $hand m] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if ![string length $XopsChannel] {
            putdcc $idx "Usage: .+xunlimit <channel> \[info\]"
            return 0
        } else {
            set XopsInfo [join [lrange $arg 1 end]]
            if { [FichierAddInfo $hand 0 "channel-exc" $XopsChannel $XopsInfo] } {
                putdcc $idx "\[xOps Mod\] : $XopsChannel existe deja ds la liste des salons illimite en nombre d'xOps"
                return 0
            } else {
                putdcc $idx "\[xOps Add\] : $XopsChannel a ete ajoute a la liste des salons illimite en nombre d'xOps" 
                return 1
            }
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}


#
# -xunlimit <channel>
#
proc xops:dcc:remunlimit {hand idx arg} {
    if { [matchattr $hand G] && [matchattr $hand m] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { ![string length $XopsChannel] } {
            putdcc $idx "Usage: .-xunlimit <channel>"
            return 0
        } else {
            if { [FichierRemInfo "channel-exc" $XopsChannel] } {
                putdcc $idx "\[xOps Rem\] : $XopsChannel a ete retire de la liste des salons illimite en nombre d'xOps"
                return 1
            } else {
                putdcc $idx "\[xOps Erreur\] : $XopsChannel n'existe pas ds la liste des salons illimite en nombre d'xOps"
                return 0
            }
        }
    } else {
        putdcc $idx "Quoi? Essayez '.help'"
        return 0
    }
}



#================================================================================
#
# Section PROCEDURES : commentaires a ameliorer :)
#
#================================================================================



#--------------------------------------------------------------------------------
#
# Procedure qui retourne 1 si le chan donne en parametre est valide, cad, qu'il
#  se trouve ds le fichier donnees/channel.txt
# Sinon, retourne 0
#
# Utilisation:
#  XopsChan <salon>
#
#--------------------------------------------------------------------------------

proc XopsChan { XopsChannel } {
  global datadir
    set XopsChanFichierAcces "$datadir/channel.txt"
    if { [file exists $XopsChanFichierAcces] == 0 } {
        set XopsChanTemp [open $XopsChanFichierAcces w+]
        close $XopsChanTemp
    }
    return [FichierVerif "channel" $XopsChannel]
}

proc XopsChanUnlimit { XopsChannel } {
  global datadir
    set XopsChanFichierAcces "$datadir/channel-exc.txt"
    if { [file exists $XopsChanFichierAcces] == 0 } {
        set XopsChanTemp [open $XopsChanFichierAcces w+]
        close $XopsChanTemp
    }
    return [FichierVerif "channel-exc" $XopsChannel]
}


#--------------------------------------------------------------------------------
#
# Procedure qui lit le fichier donne en parametre et en donne le contenu a
#  l'auteur repere par l'idx, donne en parametre.
# Si le fichier n'existe pas, le cree (vide).
#
# Utilisation:
#  FichierLecture <idx> <fichier>
#
# Rq:
#  Ne lis pas les lignes blanches
#  Le fichier sera : donnees/<fichier>.txt
#
#--------------------------------------------------------------------------------

proc FichierLecture { IdxNickname LectureFichier } {
  global datadir

    set LectureFichierAcces "$datadir/$LectureFichier.txt"
    if { [file exists $LectureFichierAcces] == 0 } {
        set LectureTemp [open $LectureFichierAcces w+]
        close $LectureTemp
    }

    set LectureTemp "[open $LectureFichierAcces r]"
    while {![eof $LectureTemp]} {
        set LectureTexteLu [gets $LectureTemp]
        set LectureTexteLu [split $LectureTexteLu]

        set LectureNickLu [lindex $LectureTexteLu 0]
        set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]
        if {$LectureNickLu != ""} {
            putdcc $IdxNickname "   $LectureNickLu $LectureNickInfo"
        }
    }
    close $LectureTemp

    unset LectureTexteLu
    unset LectureNickLu
    unset LectureNickInfo
}

proc FichierLecture2 { IdxNickname LectureFichier } {
  global datadir

    set LectureFichierAcces "$datadir/$LectureFichier.txt"
    if { [file exists $LectureFichierAcces] == 0 } {
        set LectureTemp [open $LectureFichierAcces w+]
        close $LectureTemp
    }

    set LectureTemp "[open $LectureFichierAcces r]"
    while {![eof $LectureTemp]} {
        set LectureTexteLu [gets $LectureTemp]
        set LectureTexteLu [split $LectureTexteLu]

        set LectureNickLu [lindex $LectureTexteLu 0]
        set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]
        if {$LectureNickLu != ""} {
            putdcc $IdxNickname "   $LectureNickLu \[Infos masquees\]"
        }
    }
    close $LectureTemp

    unset LectureTexteLu
    unset LectureNickLu
    unset LectureNickInfo
}

#--------------------------------------------------------------------------------
#
# Procedure qui lit le fichier donne en parametre et retourne le nb de lignes
# Si le fichier n'existe pas, le cree (vide).
#
# Utilisation:
#  FichierCpt <fichier>
#
# Rq:
#  Ne lis pas les lignes blanches
#  Le fichier sera : donnees/<fichier>.txt
#
#--------------------------------------------------------------------------------

proc FichierCpt { LectureFichier } {
  global datadir

    set NbLignes 0
    set LectureFichierAcces "$datadir/$LectureFichier.txt"
    if { [file exists $LectureFichierAcces] == 0 } {
        set LectureTemp [open $LectureFichierAcces w+]
        close $LectureTemp
    }

    set LectureTemp "[open $LectureFichierAcces r]"
    while {![eof $LectureTemp]} {
        set LectureTexteLu [gets $LectureTemp]
        set LectureTexteLu [split $LectureTexteLu]

        set LectureNickLu [lindex $LectureTexteLu 0]
        set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]
        if {$LectureNickLu != ""} {
            set NbLignes [expr $NbLignes + 1]
        }
    }
    close $LectureTemp

    unset LectureTexteLu
    unset LectureNickLu
    unset LectureNickInfo

    return $NbLignes
}

#--------------------------------------------------------------------------------
#
# Procedure qui retourne 1 si on trouve une ligne du fichier commençant par "info"
#  donne en parametre. Sinon, retourne 0
#
# Utilisation:
#  FichierVerif <fichier> <info>
#
#--------------------------------------------------------------------------------

proc FichierVerif { VerifFichier VerifInfo } {
  global datadir
    set VerifInfoTrouvee 0

    set VerifFichierAcces "$datadir/$VerifFichier.txt"
    if {[file exists $VerifFichierAcces] == 0} {
        set VerifTemp [open $VerifFichierAcces w+]
        close $VerifTemp
    }

    set VerifTemp "[open $VerifFichierAcces r+]"
    while {![eof $VerifTemp]} {
        set VerifTexteLu [gets $VerifTemp]
        set VerifTexteLu [split $VerifTexteLu]

        set VerifInfoLue [lindex $VerifTexteLu 0]

        if {[string tolower $VerifInfoLue] == [string tolower $VerifInfo]} {
            set VerifInfoTrouvee 1
        }
    } 
    close $VerifTemp

    unset VerifTexteLu
    unset VerifInfoLue

    return $VerifInfoTrouvee
}



#--------------------------------------------------------------------------------
#
# Procedure qui retourne l'info complete si on trouve une ligne du fichier commençant
#  par "info" donne en parametre. Sinon, retourne rien.
#
# Utilisation:
#  FichierInfo <fichier> <info>
#
#--------------------------------------------------------------------------------

proc FichierInfo { InfoFichier InfoInfo } {
  global datadir
    set InfoInfoTrouvee 0

    set InfoFichierAcces "$datadir/$InfoFichier.txt"
    if {[file exists $InfoFichierAcces] == 0} {
        set InfoTemp [open $InfoFichierAcces w+]
        close $InfoTemp
    }

    set InfoTemp "[open $InfoFichierAcces r+]"
    while {![eof $InfoTemp]} {
        set InfoTexteLu [gets $InfoTemp]
        set InfoTexteLu [split $InfoTexteLu]

        set InfoInfoLue [lindex $InfoTexteLu 0]
        set InfoInfoComplete [join [lrange $InfoTexteLu 1 end]]

        if {[string tolower $InfoInfoLue] == [string tolower $InfoInfo]} {
            set InfoInfoTrouvee 1
            set InfoInfoComplete2 $InfoInfoComplete
        }
    } 
    close $InfoTemp

    unset InfoTexteLu
    unset InfoInfoLue

    if { $InfoInfoTrouvee == 0 } {
        return ""
    } else {
        return $InfoInfoComplete2
    }
    complete
}


#--------------------------------------------------------------------------------
#
# Procedure qui affiche l'ens des Strings si elle est trouvee ds le fichier
#
#--------------------------------------------------------------------------------

proc FichierXSearch { IdxNickname XopsChannel SearchString } {
    global datadir fo_authnick xhand

    set LectureFichierAcces "$datadir/$XopsChannel.txt"

    if { [file exists $LectureFichierAcces] == 0 } {
        set LectureTemp [open $LectureFichierAcces w+]
        close $LectureTemp
    }
    set LectureTemp "[open $LectureFichierAcces r]"
    while {![eof $LectureTemp]} {
        set LectureTexteLu [gets $LectureTemp]
        set LectureTexteLu [split $LectureTexteLu]

        set LectureNickLu [lindex $LectureTexteLu 0]
        set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]
        if {$LectureNickLu != ""} {
            set LowerNick [string tolower $LectureNickLu]
            set LowerInfo [string tolower $LectureNickInfo]
            if {[string match $SearchString $LowerNick] && [matchattr $xhand o]} {
              putdcc $IdxNickname "   $XopsChannel : $LectureNickLu $LowerInfo"
            }
            if {[string match $SearchString $LowerNick] && ![matchattr $xhand o]} {
              putdcc $IdxNickname "   $XopsChannel : $LectureNickLu"
            }
        }
    }
    close $LectureTemp
    unset LectureTexteLu
    unset LectureNickLu
    unset LectureNickInfo
}



#--------------------------------------------------------------------------------
#
# Procedure qui ajoute le Nick & l'Info au fichier, donnes en parametre, et
#  retourne 1 si le nick a ete trouve, sinon 0
#
# L'ajout ds le fichier sera de la forme:
#  <nick> <info> (par Handle)
#
# Si le nick existe deja, remplace l'info.
# Sinon l'ajoute a la fin du fichier.
#
# Option:
#  0 = rien
#  1 = ajout du nick et du temps en commentaire
#
# Utilisation:
#  FichierAddInfo <handle> <option> <fichier> <nick> [info]
#
#--------------------------------------------------------------------------------

proc FichierAddInfo { HandNickname Temoin AddInfoFichier AddInfoNick AddInfoInfo } {
    global datadir

    set AddInfoNickTrouve 0

    set AddInfoFichierAcces "$datadir/$AddInfoFichier.txt"
    set AddInfoFichierAcces2 "$datadir/temp.txt"

#    set AddInfoNick [join $AddInfoNick]
#    set AddInfoInfo [join $AddInfoInfo]

    if {[file exists $AddInfoFichierAcces] == 0} {
        set AddInfoTemp [open $AddInfoFichierAcces w+]
        close $AddInfoTemp
    }

    set AddInfoTemp "[open $AddInfoFichierAcces r+]"
    set AddInfoTemp2 "[open $AddInfoFichierAcces2 w+]"
    while {![eof $AddInfoTemp]} {
        set AddInfoTexteLu [gets $AddInfoTemp]
	set AddInfoTexteLu [split $AddInfoTexteLu]

        set AddInfoNickLu [lindex $AddInfoTexteLu 0]
        set AddInfoInfoLu [join [lrange $AddInfoTexteLu 1 end]]

        if {[string tolower $AddInfoNickLu] == [string tolower $AddInfoNick]} {
            if { $AddInfoNick != "" } {
                if { $Temoin != 0 } {
                    puts $AddInfoTemp2 "$AddInfoNick $AddInfoInfo ([clock format [clock seconds] -format "%d/%m/%y - %H:%M:%S"] - par $HandNickname)"
                    set AddInfoNickTrouve 1
                } else {
                    puts $AddInfoTemp2 "$AddInfoNick $AddInfoInfo"
                    set AddInfoNickTrouve 1
                }
            }
        } else {
            if { $AddInfoNickLu != "" } { puts $AddInfoTemp2 "$AddInfoNickLu $AddInfoInfoLu" }
        }
    }

    if {$AddInfoNickTrouve == 0} {
        if { $AddInfoNick != "" } {
            if { $Temoin != 0 } {
                puts $AddInfoTemp2 "$AddInfoNick $AddInfoInfo ([clock format [clock seconds] -format "%d/%m/%y - %H:%M:%S"] - par $HandNickname)"
            } else {
                puts $AddInfoTemp2 "$AddInfoNick $AddInfoInfo"
            }
        }
    }
    close $AddInfoTemp
    close $AddInfoTemp2

    FichierCopy $AddInfoFichierAcces "$datadir/temp.txt"

    unset AddInfoTexteLu
    unset AddInfoNickLu
    unset AddInfoInfoLu
    
    return $AddInfoNickTrouve
}



#--------------------------------------------------------------------------------
#
# Procedure qui retire le Nick du fichier, donnes en parametre, et
#  retourne 1 si le nick a ete trouve, sinon 0
#
# Utilisation:
#  FichierRemInfo <fichier> <nick>
#
#--------------------------------------------------------------------------------

proc FichierRemInfo { RemInfoFichier RemInfoNick} {
    global datadir

    set RemInfoNickTrouve 0

    set RemInfoFichierAcces "$datadir/$RemInfoFichier.txt"
    set RemInfoFichierAcces2 "$datadir/temp.txt"

    if {[file exists $RemInfoFichierAcces] == 0} {
        set RemInfoTemp [open $RemInfoFichierAcces w+]
        close $RemInfoTemp
    }

    set RemInfoTemp "[open $RemInfoFichierAcces r+]"
    set RemInfoTemp2 "[open $RemInfoFichierAcces2 w+]"
    while {![eof $RemInfoTemp]} {
        set RemInfoTexteLu [gets $RemInfoTemp]
	set RemInfoTexteLu [split $RemInfoTexteLu]

        set RemInfoNickLu [lindex $RemInfoTexteLu 0]
        set RemInfoInfoLu [join [lrange $RemInfoTexteLu 1 end]]

        if {[string tolower $RemInfoNickLu] != [string tolower $RemInfoNick]} {
            if {$RemInfoNickLu != ""} {puts $RemInfoTemp2 "$RemInfoNickLu $RemInfoInfoLu"}
        } else {
            set RemInfoNickTrouve 1
        }
    } 

    close $RemInfoTemp
    close $RemInfoTemp2

    FichierCopy $RemInfoFichierAcces "$datadir/temp.txt"

    unset RemInfoTexteLu
    unset RemInfoNickLu
    unset RemInfoInfoLu

    return $RemInfoNickTrouve
}



#--------------------------------------------------------------------------------
#
# Procedure qui copie FichierAcces2 ds FichierAcces (donnes en parametre)
#  Fichier1 <=== Fichier2
#
# Utilisation:
#  FichierCopy "<repertoire_1>/<nom_1>.txt" "<repertoire_2>/<nom_2>.txt"
#
# Rq: N'ecrit pas les lignes blanches
#
#--------------------------------------------------------------------------------

proc FichierCopy { CopyFichierAcces CopyFichierAcces2 } {
    file copy -force $CopyFichierAcces2 $CopyFichierAcces
    return
}

proc FichierCopy2 {CopyFichierAcces CopyFichierAcces2} {
    if {[file exists $CopyFichierAcces2] == 0} {
        set CopyFichiersTemp [open $CopyFichierAcces2 w+]
        close $CopyTemp
    }
    set CopyTemp "[open $CopyFichierAcces w+]"
    set CopyTemp2 "[open $CopyFichierAcces2 r]"
    while {![eof $CopyTemp2]} {
        set CopyTexteLu [gets $CopyTemp2]
        if {$CopyTexteLu != ""} {puts $CopyTemp "$CopyTexteLu"}
    }
    close $CopyTemp
    close $CopyTemp2
    unset CopyTexteLu
}
