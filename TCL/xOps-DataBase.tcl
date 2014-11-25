#
# xOps.tcl par NitrO <radium@iquebec.com> & Ibu <ibu_lordaeron@yahoo.fr>
#
# TCL permettant à un eggdrop de gérer une base de données des Xops.
# Ces fichiers se trouvent ds le répertoire désiré.
#
# Dernières modifs faites le 01/01/02 par Ibu :O)
# - ajout du .[+/-]xunlimit
#


### Flags ###
#
# +G (global) : accès à la gestion des fichiers
#
# +o (global) : permet de consulter n'importe quel listes
# +m (global) : permet de modifier n'importe quel listes
#
# +o (local)  : permet de consulter une liste spécifique
# +m (local)  : permet de modifier une liste spécifique
#
# +n (global) : permet de créer le répertoire données
#               permet de supprimer n'importe quel fichier
#               permet d'ajouter et de retirer les salons
#
# +n #ircop : permet de modifier n'importe quelle liste!
#             Un +n sur #ircop n'est pas forcément IRCop du réseau
#             Il lui permet just' de modifier toutes les listes.
#             Utile pour un xOpeur régulier
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
# Paramètres à modifier
#
#================================================================================

# Entrez le répertoire de stockage des donnees. (Sans de / à la fin! :O))
set datadir "system"


# Entrez la liste des salons de base.
# (Là où seront mis les flags par défaut selon le niveau -> CM ou Geo)
set chanlist {  "#n.t" }





#######################
# Section Chanmasters #
#######################

# Flags globaux à mettre aux ChanMasters.
set cmglobalflags "fhpG"

# Flags locaux à mettre aux ChanMasters sur les salons de base.
set cmlocalflags "fo"

# Entrez le flag qu'ont les ChanMasters sur leur salon respectif de plus que les autres.
set cmflag "fmo"

# Entrez le salon où se tiendra la liste des Chanmasters de tous les salons enregistrés.
set defsaloncm "#n.t"


#########################
# Section Geofrontistes #
#########################

# Flags globaux à mettre aux Geofrontistes.
set geoglobalflags "fhopG"

# Flags locaux à mettre aux Geofrontistes sur les salons de base. (sauf le salon des IRCops)
set geolocalflags "fmo"


##################
# Section IRCops #
##################

# Entrez le salon par défaut contenant la liste des IRCops.
# (À mettre dans la liste de salons de base aussi!)
set chanircop "#n.t"

# Flags globaux à mettre aux IRCops.
set ircopglobalflags "fhopG"

# Flags locaux à mettre aux IRCops sur les salons de base énumérés ci-dessus.
set ircoplocalflags "fmno"


#################
# Section ADMIN #
#################

# Flags globaux à mettre aux Admins
set adminglobalflags "fhjmoptxG"

# Flags locaux à mettre aux Admins sur les salons de base
set adminlocalflags "fmno"


#################
# Section Owner #
#################

# Flags globaux à mettre aux owners du bot
set ownerglobalflags "fhjmnoptxG"


##################
# Autres Options #
##################

# Entre les salons où vous ne voulez pas que la date et le nom du créateur soit affichée
# (Peut être laissée vide)
set NoCreateInfoChan { "#n.t" }

# Limite d'xOps
set LimitexOps 999



#================================================================================
#
# Début du script! Ne pas toucher à ce qui suit sauf si vous savez ce que vous
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


proc xops:dcc:xopshelp {hand idx arg} {
    if { [matchattr $hand G] } {
        putdcc $idx "     xOps - Help     "
        putdcc $idx " "
        putdcc $idx "Pour ChanMasters & Geofrontistes:"
        putdcc $idx "   xchan \[channel\] 14(voir ou vérifier la liste des chans de la base de donnée)"
        putdcc $idx "   xunlimit \[channel\] 14(voir ou vérifier la liste des chans illimités en xOps)"
        putdcc $idx "   xops <channel> \[nick|string\] 14(voir la liste des xops ou vérifie un nick)"
        putdcc $idx "   xinfo <channel> <string> 14(Recherche d'une Info ds la liste du salon)"
        putdcc $idx "   xsearch <string> 14(Recherche d'un xopé ds la base de donnée en entière)"
        putdcc $idx " "
        putdcc $idx "Pour ChanMasters:"
        putdcc $idx "   +xops <channel> <nick> \[info\] 14(ajoute un xop ou une info)"
        putdcc $idx "   -xops <channel> <nick> \[info\] 14(retire un xop ou une info)"
        putdcc $idx " "
        if { [matchattr $hand m] } {
            putdcc $idx "Pour Masters du bot:"
#            putdcc $idx "   xaddowner <pseudo> 14(Ajoute un Owner avec les flags par défaut -> +n seulement)"
            putdcc $idx "   xaddadmin <pseudo> 14(Ajoute un Admin avec les flags par défaut -> +n seulement)"
            putdcc $idx "   xaddircop <pseudo> 14(Ajoute un IRCop avec les flags par défaut)"
            putdcc $idx "   xaddgeo <pseudo> 14(Ajoute un géofrontiste avec les flags par défaut)"
            putdcc $idx "   xaddcm <pseudo> <salon> 14(Ajoute un CM sur un salon spécifique)"
            putdcc $idx " "
        }
        if { [matchattr $hand n] } {
            putdcc $idx "Pour Owners du bot:"
            putdcc $idx "   +xchan <channel> 14(ajouter un chan autorisé)"
            putdcc $idx "   -xchan <channel> 14(effacer un chan autorisé)"
            putdcc $idx "   +xunlimit <channel> 14(ajouter un chan illimité niveau des xOps)"
            putdcc $idx "   -xunlimit <channel> 14(effacer un chan illimité niveau des xOps)"
            putdcc $idx "   xdonnees 14(crée le répertoire donnees s'il n'existe pas)"
            putdcc $idx " "
        }
        putdcc $idx "NB: un +n sur #ircop peut modifier n'importe quelle liste"
        putdcc $idx "      Un +n sur #ircop n'est pas forcément IRCop du réseau!"
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


#################
# Ajout d'un CM #
#################

proc xops:dcc:xaddcm { hand idx vars } {
  global cmglobalflags cmlocalflags cmflag chanlist defsaloncm

    set pseudo [lindex $vars 0]
    set cmchan [lindex $vars 1]
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

                putdcc $idx "\[XAddCM\] -> Succès!"
                putdcc $idx "            $pseudo est maintenant enregistré(e) comme Chanmaster de $cmchan"
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


###########################
# Ajout d'un Geofrontiste #
###########################

proc xops:dcc:xaddgeo { hand idx vars } {
  global geoglobalflags geolocalflags chanlist chanircop

    set pseudo [lindex $vars 0]
    set salon ""

    if { $pseudo != "" } {
        if {[validuser $pseudo]} {
            chattr $pseudo -fhjmoptxvG
            chattr $pseudo +$geoglobalflags
            foreach salon $chanlist {
                chattr $pseudo -|-fmnovadkG $salon
                if {![string match $salon $chanircop]} {         # Pour éviter de mettre le +m sur le chan IRCop!
                    chattr $pseudo -|+$geolocalflags $salon
                }
            }
            putdcc $idx "\[XAddGeo\] -> Succès!"
            putdcc $idx "             $pseudo est maintenant enregistré(e) comme Geofrontiste"
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

proc xops:dcc:xaddircop { hand idx vars } {
  global chanlist chanircop ircoplocalflags ircopglobalflags

    set pseudo [lindex $vars 0]
    set salon ""

    if { $pseudo != "" } {
        if {[validuser $pseudo]} {
            chattr $pseudo -fhjmoptxvG
            chattr $pseudo +$ircopglobalflags
            foreach salon $chanlist {
                chattr $pseudo -|-fmnovadkG $salon
                chattr $pseudo -|+$ircoplocalflags $salon
            }
            putdcc $idx "\[XAddIRCop\] -> Succès!"
            putdcc $idx "               $pseudo est maintenant enregistré(e) comme IRCop"
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

proc xops:dcc:xaddadmin { hand idx vars } {
  global adminglobalflags adminlocalflags chanlist

    set pseudo [lindex $vars 0]
    set salon ""

    if { $pseudo != "" } {
        if {[validuser $pseudo]} {
            chattr $pseudo -fhjmoptxvG
            chattr $pseudo +$adminglobalflags
            foreach salon $chanlist {
                chattr $pseudo -|-fmnovadkG $salon
                chattr $pseudo -|+$adminlocalflags $salon
            }
            putdcc $idx "\[XAddAdmin\] -> Succès!"
            putdcc $idx "               $pseudo est maintenant enregistré(e) comme Admin"
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

proc xops:dcc:xaddowner { hand idx vars } {



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
proc xops:dcc:xops {hand idx vars} {
    global datadir 

    set XopsChannel [string tolower [lindex $vars 0]]
    set SearchString [string tolower [lindex $vars 1]]
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
                        set LectureNickLu [join [lrange $LectureTexteLu 0 0]]
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
                        putdcc $idx "-=- Fin des résultats. Trouvés \[ $NbResults \] -=-"
                    } else {
                        putdcc $idx "-=- Aucun résultat correspondant à $SearchString n'a été trouvé -=-"
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
                        set LectureNickLu [join [lrange $LectureTexteLu 0 0]]
                        set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]
                        if {$LectureNickLu != ""} {
                            set LowerNick [string tolower $LectureNickLu]
                            set LowerInfo [string tolower $LectureNickInfo]
                            if {[string match $SearchString $LowerNick]} {
                               putdcc $idx "   $LectureNickLu - \[Infos masquées\]"
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
                        putdcc $idx "-=- Fin des résultats. Trouvés \[ $NbResults \] -=-"
                    } else {
                        putdcc $idx "-=- Aucun résultat correspondant à $SearchString n'a été trouvé -=-"
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
    if { [matchattr $hand G] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { ![string length $XopsChannel] } {
            putdcc $idx "-=-  Liste des Salons Autorisés  -=-"
            putdcc $idx " "
            FichierLecture $idx "channel"
            putdcc $idx " "
            putdcc $idx "-=- Fin de la Liste -=-"
            return 1
        } else {
            if { [FichierVerif "channel" $XopsChannel] } {
                putdcc $idx "\[Trouvé\] : Le chan $XopsChannel est autorisé"
                return 1
            } else {
                putdcc $idx "\[Non-Trouvé\] : Le chan $XopsChannel n'est pas autorisé"
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
    if { [matchattr $hand G] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { ![string length $XopsChannel] } {
            putdcc $idx "-=-  Liste des Salons non limités  -=-"
            putdcc $idx " "
            FichierLecture $idx "channel-exc"
            putdcc $idx " "
            putdcc $idx "-=- Fin de la Liste -=-"
            return 1
        } else {
            if { [FichierVerif "channel" $XopsChannel] } {
                putdcc $idx "\[Trouvé\] : Le chan $XopsChannel est illimité en nombre d'xOps"
                return 1
            } else {
                putdcc $idx "\[Non-Trouvé\] : Le chan $XopsChannel n'est pas illimité en nombre d'xOps"
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
proc xops:dcc:xsearch {hand idx vars} {
    global datadir

    set SearchNick [string tolower [lindex $vars 0]]
    set NbResults 0

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
                set LectureNickLu [join [lrange $LectureTexteLu 0 0]]
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
            putdcc $idx "-=- Fin des résultats -=-"
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
proc xops:dcc:xinfo {hand idx vars} {
    global datadir

    set XopsChannel [string tolower [lindex $vars 0]]
    set SearchString [string tolower [lindex $vars 1]]
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
                        putdcc $idx "-=- Fin des résultats. Trouvés \[ $NbResults \] -=-"
                    } else {
                        putdcc $idx "-=- Aucun résultat correspondant à $SearchString n'a été trouvé -=-"
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
    global chanircop NoCreateInfoChan LimitexOps NoLimitexOps

    set salon ""
    set temoin 1

    if { [matchattr $hand G] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { [XopsChan $XopsChannel] } {
            if ![string length $XopsChannel] {
                putdcc $idx "Usage: .+xops <channel> <nick> \[info\]"
                return 0
            } else {
                if { [matchattr $hand m] || [matchattr $hand |m $XopsChannel] || [matchattr $hand |n $chanircop] } {
                    set XopsNick [lindex $arg 1]
                    if { ![string length $XopsNick] } {
                        putdcc $idx "Usage: .+xops <channel> <nick> \[info\]"
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
                            if { [FichierAddInfo $hand $temoin $XopsChannel $XopsNick $XopsInfo] } {
                                putdcc $idx "\[Mod\] : $XopsNick a été modifié de la liste des Xops de $XopsChannel" 
                            } else {
                                putdcc $idx "\[Add\] : $XopsNick a été ajouté à la liste des Xops de $XopsChannel" 
                            }
                            putlog "#$hand# +xops $XopsChannel $XopsNick \[Info\]"
                            return
                        } else {
                            putdcc $idx "\[Erreur\] : Limite du nombre d'xOps dépassés! (Max autorisés: $LimitexOps)" 
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


#
# -Xops <channel> <nick>
#
proc xops:dcc:remnick {hand idx arg} {
    global chanircop
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
                            putdcc $idx "\[Rem\] : $XopsNick a été retiré de la liste des Xops de $XopsChannel" 
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
    if { [matchattr $hand G] && [matchattr $hand n] } {
        file mkdir $datadir
        putdcc $idx "\[Add\] : répertoire donnees crée dans le filesystem!" 
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

    if { [matchattr $hand G] && [matchattr $hand n] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if ![string length $XopsChannel] {
            putdcc $idx "Usage: .+xchan <channel> \[info\]"
            return 0
        } else {
            set XopsInfo [join [lrange $arg 1 end]]
            if { [FichierAddInfo $hand 0 "channel" $XopsChannel $XopsInfo] } {
                putdcc $idx "\[Mod\] : $XopsChannel existe déja ds la liste des salons autorisés"
                return 0
            } else {
                putdcc $idx "\[Add\] : $XopsChannel a été ajouté à la liste des salons autorisés" 
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
    if { [matchattr $hand G] && [matchattr $hand n] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { ![string length $XopsChannel] } {
            putdcc $idx "Usage: .-xchan <channel>"
            return 0
        } else {
            if { [FichierRemInfo "channel" $XopsChannel] } {
                putdcc $idx "\[Rem\] : $XopsChannel a été retiré de la liste des salons autorisés"
                return 1
            } else {
                putdcc $idx "\[Erreur\] : $XopsChannel n'existe pas ds la liste des salons autorisés"
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
    if { [matchattr $hand G] && [matchattr $hand n] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if ![string length $XopsChannel] {
            putdcc $idx "Usage: .+xunlimit <channel> \[info\]"
            return 0
        } else {
            set XopsInfo [join [lrange $arg 1 end]]
            if { [FichierAddInfo $hand 0 "channel-exc" $XopsChannel $XopsInfo] } {
                putdcc $idx "\[xOps Mod\] : $XopsChannel existe déja ds la liste des salons illimité en nombre d'xOps"
                return 0
            } else {
                putdcc $idx "\[xOps Add\] : $XopsChannel a été ajouté à la liste des salons illimité en nombre d'xOps" 
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
    if { [matchattr $hand G] && [matchattr $hand n] } {
        set XopsChannel [string tolower [lindex $arg 0]]
        if { ![string length $XopsChannel] } {
            putdcc $idx "Usage: .-xunlimit <channel>"
            return 0
        } else {
            if { [FichierRemInfo "channel-exc" $XopsChannel] } {
                putdcc $idx "\[xOps Rem\] : $XopsChannel a été retiré de la liste des salons illimité en nombre d'xOps"
                return 1
            } else {
                putdcc $idx "\[xOps Erreur\] : $XopsChannel n'existe pas ds la liste des salons illimité en nombre d'xOps"
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
# Section PROCEDURES : commentaires à améliorer :)
#
#================================================================================



#--------------------------------------------------------------------------------
#
# Procédure qui retourne 1 si le chan donné en paramètre est valide, càd, qu'il
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
# Procédure qui lit le fichier donné en paramètre et en donne le contenu à
#  l'auteur repéré par l'idx, donné en paramètre.
# Si le fichier n'existe pas, le crée (vide).
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
        set LectureNickLu [join [lrange $LectureTexteLu 0 0]]
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
        set LectureNickLu [join [lrange $LectureTexteLu 0 0]]
        set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]
        if {$LectureNickLu != ""} {
            putdcc $IdxNickname "   $LectureNickLu \[Infos masquées\]"
        }
    }
    close $LectureTemp

    unset LectureTexteLu
    unset LectureNickLu
    unset LectureNickInfo
}

#--------------------------------------------------------------------------------
#
# Procédure qui lit le fichier donné en paramètre et retourne le nb de lignes
# Si le fichier n'existe pas, le crée (vide).
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
        set LectureNickLu [join [lrange $LectureTexteLu 0 0]]
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
# Procédure qui retourne 1 si on trouve une ligne du fichier commençant par "info"
#  donné en paramètre. Sinon, retourne 0
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
        set VerifInfoLue [join [lrange $VerifTexteLu 0 0]]

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
# Procédure qui retourne l'info complète si on trouve une ligne du fichier commençant
#  par "info" donné en paramètre. Sinon, retourne rien.
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
        set InfoInfoLue [join [lrange $InfoTexteLu 0 0]]
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
# Procédure qui affiche l'ens des Strings si elle est trouvée ds le fichier
#
#--------------------------------------------------------------------------------

proc FichierXSearch { IdxNickname XopsChannel SearchString } {
    global datadir

    set LectureFichierAcces "$datadir/$XopsChannel.txt"

    if { [file exists $LectureFichierAcces] == 0 } {
        set LectureTemp [open $LectureFichierAcces w+]
        close $LectureTemp
    }
    set LectureTemp "[open $LectureFichierAcces r]"
    while {![eof $LectureTemp]} {
        set LectureTexteLu [gets $LectureTemp]
        set LectureNickLu [join [lrange $LectureTexteLu 0 0]]
        set LectureNickInfo [join [lrange $LectureTexteLu 1 end]]
        if {$LectureNickLu != ""} {
            set LowerNick [string tolower $LectureNickLu]
            set LowerInfo [string tolower $LectureNickInfo]
            if {[string match $SearchString $LowerNick]} {
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
# Procédure qui ajoute le Nick & l'Info au fichier, donnés en paramètre, et
#  retourne 1 si le nick a été trouvé, sinon 0
#
# L'ajout ds le fichier sera de la forme:
#  <nick> <info> (par Handle)
#
# Si le nick existe déjà, remplace l'info.
# Sinon l'ajoute à la fin du fichier.
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

    set AddInfoNick [join $AddInfoNick]
    set AddInfoInfo [join $AddInfoInfo]

    if {[file exists $AddInfoFichierAcces] == 0} {
        set AddInfoTemp [open $AddInfoFichierAcces w+]
        close $AddInfoTemp
    }

    set AddInfoTemp "[open $AddInfoFichierAcces r+]"
    set AddInfoTemp2 "[open $AddInfoFichierAcces2 w+]"
    while {![eof $AddInfoTemp]} {
        set AddInfoTexteLu [gets $AddInfoTemp]

        set AddInfoNickLu [join [lrange $AddInfoTexteLu 0 0]]
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
# Procédure qui retire le Nick du fichier, donnés en paramètre, et
#  retourne 1 si le nick a été trouvé, sinon 0
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
        set RemInfoNickLu [join [lrange $RemInfoTexteLu 0 0]]
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
# Procédure qui copie FichierAcces2 ds FichierAcces (donnés en paramètre)
#  Fichier1 <=== Fichier2
#
# Utilisation:
#  FichierCopy "<repertoire_1>/<nom_1>.txt" "<repertoire_2>/<nom_2>.txt"
#
# Rq: N'écrit pas les lignes blanches
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
