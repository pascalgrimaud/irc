#
# Zombie.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#



#################
# Configuration #
#################

# Bounce
set zombie(bncserver) "lordaeron"
set zombie(bncport) "1111"
set zombie(bncpass) "aucun"



########
# Motd #
########

putlog "\002zombie.tcl\002 - par \002Ibu\002 14<ibu_lordaeron@yahoo.fr>"



########
# Aide #
########
bind dcc Z xzhelp zombie:dcc:help

proc zombie:dcc:help { hand idx arg } {
    global xeva
    putdcc $idx " "
    putdcc $idx "     Zombie Generator - Aide     "
    putdcc $idx " "
#    putdcc $idx " xzombie <server> <port> <console> <nick> <user> <realname> 14(créer un zombie avec bnc echo)"
    putdcc $idx " xzombie <server> <port> <console> <nick> <user> <console> <realname> 14(créer un zombie avec host local)"
    putdcc $idx " xunzombie <nick> 14(supprimer un zombie)"
    putdcc $idx " xzlist 14(lister les zombies)"
    putdcc $idx " xzconsole <zombie/idx> <console> 14(attribue une nouvelle console au zombie)"
    putdcc $idx " xznick <zombie/idx> <nouveau nick>"
    putdcc $idx " xzjoin <zombie/idx> <channel>"
    putdcc $idx " xzpart <zombie/idx> <channel>"
    putdcc $idx " xzmsg <zombie/idx> <nick/channel> <message>"
    putdcc $idx " xznotice <zombie/idx> <nick/channel> <message>"
    putdcc $idx " "
    putdcc $idx " xzhelp <-- Vous êtes ici!"
    putdcc $idx " "
    putlog "#$hand# xzhelp"
    return 0
}


#
# ! commande
#

bind pub - !aladin zombie:excla

proc zombie:excla { nick uhost handle channel arg } {
    global xzombieid

    if { [string tolower $channel] == "#sesame" } {
        set xznick "aladin"
        set xzto "#pre"
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            putdcc $xzidx "PRIVMSG $xzto :$arg"
        } else {
            putserv "PRIVMSG #sesame :\[ERREUR\] Message non envoyé car IDX inexistant!"
        }
    }

    return 0
}


bind pub - !pre zombie:exclapre

proc zombie:exclapre { nick uhost handle channel arg } {
    global xzombieid

    if { [string tolower $channel] == "#sesame" } {
        set xznick "aladin"
        set xzto "#pre"
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            putdcc $xzidx "PRIVMSG $xzto :!pre $arg"
        } else {
            putserv "PRIVMSG #sesame :\[ERREUR\] Message non envoyé car IDX inexistant!"
        }
    }

    return 0
}


bind pub - !lastfr zombie:exclalastfr
proc zombie:exclalastfr { nick uhost handle channel arg } {
    global xzombieid

    if { [string tolower $channel] == "#sesame" } {
        set xznick "aladin"
        set xzto "#pre"
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            putdcc $xzidx "PRIVMSG $xzto :!lastfr"
        } else {
            putserv "PRIVMSG #sesame :\[ERREUR\] Message non envoyé car IDX inexistant!"
        }
    }

    return 0
}

bind pub - !lastdvdrfr zombie:exclalastdvdrfr
proc zombie:exclalastdvdrfr { nick uhost handle channel arg } {
    global xzombieid

    if { [string tolower $channel] == "#sesame" } {
        set xznick "aladin"
        set xzto "#pre"
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            putdcc $xzidx "PRIVMSG $xzto :!lastdvdrfr"
        } else {
            putserv "PRIVMSG #sesame :\[ERREUR\] Message non envoyé car IDX inexistant!"
        }
    }

    return 0
}


bind pub - !lastnuke zombie:exclalastnuke
proc zombie:exclalastnuke { nick uhost handle channel arg } {
    global xzombieid

    if { [string tolower $channel] == "#sesame" } {
        set xznick "aladin"
        set xzto "#pre"
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            putdcc $xzidx "PRIVMSG $xzto :!lastnuke"
        } else {
            putserv "PRIVMSG #sesame :\[ERREUR\] Message non envoyé car IDX inexistant!"
        }
    }

    return 0
}


bind pub - !nfo zombie:exclanfo

proc zombie:exclanfo { nick uhost handle channel arg } {
    global xzombieid

    if { [string tolower $channel] == "#sesame" } {
        set xznick "aladin"
        set xzto "#pre"
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            putdcc $xzidx "PRIVMSG $xzto :!nfo $arg"
        } else {
            putserv "PRIVMSG #sesame :\[ERREUR\] Message non envoyé car IDX inexistant!"
        }
    }

    return 0
}



###############
# xzombielist #
###############
bind dcc Z xzlist zombie:dcc:xzombielist
bind dcc Z xzombielist zombie:dcc:xzombielist

proc zombie:dcc:xzombielist { hand idx arg } {
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    putdcc $idx "\002Liste des Zombies\002"
    foreach i [dcclist] {
        if { [lindex $i 4] == "scri  xzombie:event" } {
            set xzidx [lindex $i 0]
            putdcc $idx "\[\002idx\002\] $xzidx \[\002serveur\002\] $xzombieserver($xzidx):$xzombieport($xzidx) \[\002console\002\] $xzombieconsole($xzidx) \[\002pseudo\002\] $xzombienick($xzidx) \[\002userid\002\] $xzombieuser($xzidx) \[\002realname\002\] $xzombierealname($xzidx)"
        }
    }
    putdcc $idx " "
    return 1
}



####################
# xzombie/xzombie2 #
####################

#
# modification 12/11: zombie devient zombielocal
#

bind dcc Z xzombie zombie:dcc:xzombielocal
bind dcc Z xzombielocal zombie:dcc:xzombielocal

proc zombie:dcc:xzombie { hand idx arg } {
    global zombie
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set arg [split $arg]

    set xzserver [lindex $arg 0]
    set xzport [lindex $arg 1]

    if { [lindex $arg 5] != "" } {
        if { ![catch {connect $zombie(bncserver) $zombie(bncport) } xzidx]} {
            set xzombieserver($xzidx) [lindex $arg 0]
            set xzombieport($xzidx) [lindex $arg 1]
            set xzombieconsole($xzidx) [lindex $arg 2]
            set xzombienick($xzidx) [lindex $arg 3]
            set xzombieuser($xzidx) [lindex $arg 4]
            set xzombierealname($xzidx) [join [lrange $arg 5 end]]

            set xzombieid([string tolower $xzombienick($xzidx)]) $xzidx

            putlog "\002\[xZombie\]\002 xZombie Bnc-Echo sur $xzserver:$xzport (Idx = $xzidx)" 

            putdcc $xzidx "USER $xzombieuser($xzidx) $xzombieuser($xzidx) $xzombieuser($xzidx) :$xzombierealname($xzidx)"
            putdcc $xzidx "NICK $xzombienick($xzidx) localhost r :$xzombierealname($xzidx)"

            control $xzidx xzombie:event
            return 1
        } else {
            putlog "\002\[xZombie\]\002 xZombie Bnc-Echo impossible sur $xzserver:$xzport" 
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .xzombie <server> <port> <console> <nick> <user> <realname>"
        putdcc $idx "   Console:"
        putdcc $idx "       m=display private msgs to the zombie"
        putdcc $idx "       p=display public talk on the channel"
        putdcc $idx "       j=display joins/parts/nick changes/signoffs/etc on the channel"
        putdcc $idx "       k=display kicks/bans/mode changes on the channel"
        putdcc $idx " "
        return 0
    }
}

proc zombie:dcc:xzombielocal { hand idx arg } {
    global zombie
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set arg [split $arg]

    set xzserver [lindex $arg 0]
    set xzport [lindex $arg 1]

    if { [lindex $arg 5] != "" } {
        if { ![catch {connect $xzserver $xzport } xzidx]} {
            set xzombieserver($xzidx) [lindex $arg 0]
            set xzombieport($xzidx) [lindex $arg 1]
            set xzombieconsole($xzidx) [lindex $arg 2]
            set xzombienick($xzidx) [lindex $arg 3]
            set xzombieuser($xzidx) [lindex $arg 4]
            set xzombierealname($xzidx) [join [lrange $arg 5 end]]

            set xzombieid([string tolower $xzombienick($xzidx)]) $xzidx

            putlog "\002\[xZombie\]\002 xZombie sur $xzserver:$xzport (Idx = $xzidx)" 

            putdcc $xzidx "USER $xzombieuser($xzidx) $xzombieuser($xzidx) $xzombieuser($xzidx) :$xzombierealname($xzidx)"
            putdcc $xzidx "NICK $xzombienick($xzidx) localhost r :$xzombierealname($xzidx)"

            control $xzidx xzombie:event
            return 1
        } else {
            putlog "\002\[xZombie\]\002 xZombie impossible sur $xzserver:$xzport" 
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .xzombielocal <server> <port> <console> <nick> <user> <realname>"
        putdcc $idx "   Console:"
        putdcc $idx "       m=display private msgs to the zombie"
        putdcc $idx "       p=display public talk on the channel"
        putdcc $idx "       j=display joins/parts/nick changes/signoffs/etc on the channel"
        putdcc $idx "       k=display kicks/bans/mode changes on the channel"
        putdcc $idx " "
        return 0
    }
}

proc xzombie:event { idx arg } {
    global zombie
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set arg [split $arg]
    putloglev 8 * "(DEBUG) xZombie ( $xzombienick($idx) ): [join $arg]"

    if { [lindex $arg 0] == "PING" } {
#        putloglev 8 * "(DEBUG) xZombie ( $xzombienick($idx) ) --> PONG [lindex $arg 1]"
        putdcc $idx "PONG [lindex $arg 1]"
    }
    if { [join $arg] == "NOTICE AUTH :You need to say /quote PASS <password>" } {
        putdcc $idx "PASS $zombie(bncpass)"
    }
    if { [join $arg] == "NOTICE AUTH :type /quote help for basic list of commands and usage" } {
        putdcc $idx "CONN $xzombieserver($idx) $xzombieport($idx)"
    }

    #--------------------------------------------------------------------------------
    if { [lindex $arg 1] == "PRIVMSG" } {
        set xzfrom [string range [lindex $arg 0] 1 end]
        set xzto [lindex $arg 2]
        set xzmsg [string range [join [lrange $arg 3 end]] 1 end]
        set xzmsg2 [join [lrange $arg 4 end]]

        if { [ischannel $xzto] } {
          if { [string match *p* $xzombieconsole($idx)] } {
            if { [lindex [split $xzmsg] 0] == "ACTION" } {
              putloglev 6 * "\002\[xZ\]\002 [lindex $arg 2] [6]* [Xnick $xzfrom] [string trim $xzmsg2 \001]"

              putserv "PRIVMSG #sesame :[string trim $xzmsg2 \001]"

            } else {
              putloglev 6 * "\002\[xZ\]\002 [lindex $arg 2] <[Xnick $xzfrom]> $xzmsg"

              putserv "PRIVMSG #sesame :$xzmsg"
            }
          }

        } elseif { [string match *m* $xzombieconsole($idx)] } {
          if { [lindex [split $xzmsg] 0] == "ACTION" } {
              putloglev 6 * "\002\[xZ\]\002 [6]* [Xnick $xzfrom] [string trim $xzmsg2 \001]"
          } else {
            putloglev 6 * "\002\[xZ\]\002 <[Xnick $xzfrom]> $xzmsg"

            putserv "PRIVMSG #sesame :$xzmsg"

          }
        }
    }

   #--------------------------------------------------------------------------------
    if { [lindex $arg 1] == "NOTICE" } {
        set xzfrom [string range [lindex $arg 0] 1 end]
        set xzto [lindex $arg 2]
        set xzmsg [string range [join [lrange $arg 3 end]] 1 end]

        if { [ischannel $xzto] } {
          if { [string match *p* $xzombieconsole($idx)] } {
            putloglev 6 * "\002\[xZ\]\002 [lindex $arg 2] [5]-[Xnick $xzfrom]:[lindex $arg 2]- $xzmsg"

            putserv "PRIVMSG #sesame :$xzmsg"
          }

        } elseif { [string match *m* $xzombieconsole($idx)] } {
          putloglev 6 * "\002\[xZ\]\002 [5]-[Xnick $xzfrom]- $xzmsg"
        }
    }

    #--------------------------------------------------------------------------------
    if { [lindex $arg 1] == "433" } {
        putloglev 6 * "\002\[xZ\]\002 Le pseudo \002$xzombienick($idx)\002 est déjà utilisé"
    }
    if { [lindex $arg 1] == "NICK" } {
        set xzfrom [string range [lindex $arg 0] 1 end]
        set xzfromnick [Xnick $xzfrom]
        set xzfromuserhost [Xuser $xzfrom]@[Xhost $xzfrom]
        set xzdestnick [string range [lindex $arg 2] 1 end]

        if { [string tolower $xzfromnick] == [string tolower $xzombienick($idx)] } {
            set xzombieid([string tolower $xzdestnick]) $idx
            unset xzombieid([string tolower $xzfromnick])
            set xzombienick($idx) [string range [lindex $arg 2] 1 end]
            putloglev 6 * "\002\[xZ\]\002 [7]=== (Nick) $xzfromnick ->[o] $xzdestnick [7]($xzfromuserhost)"
        } elseif { [string match *j* $xzombieconsole($idx)] } {
            putloglev 6 * "\002\[xZ\]\002 [7]=== (Nick) $xzfromnick ->[o] $xzdestnick [7]($xzfromuserhost)"
        }
    }


    #--------------------------------------------------------------------------------
    if { [lindex $arg 1] == "QUIT" } {
        set xzfrom [string range [lindex $arg 0] 1 end]
        set xzfromnick [Xnick $xzfrom]
        set xzfromuserhost [Xuser $xzfrom]@[Xhost $xzfrom]
        set xzraison [string range [join [lrange $arg 2 end]] 1 end]

        if { [string match *j* $xzombieconsole($idx)] } {
            putloglev 6 * "\002\[xZ\]\002 [2]<== (Quit)[o] $xzfromnick [2]($xzfromuserhost) ($xzraison[o][2])"
        }
    }

    #--------------------------------------------------------------------------------
    if { [lindex $arg 1] == "JOIN" } {
        set xzfrom [string range [lindex $arg 0] 1 end]
        set xzfromnick [Xnick $xzfrom]
        set xzfromuserhost [Xuser $xzfrom]@[Xhost $xzfrom]
        set xzchannel [string range [lindex $arg 2] 1 end]

        if { [string tolower $xzfromnick] == [string tolower $xzombienick($idx)] } {
            putloglev 6 * "\002\[xZ\]\002 $xzchannel [3]==> (Join)[o] $xzfromnick [3]($xzfromuserhost)"

            if { [string tolower $xzchannel] == "#pre" && [string tolower $xzfromnick] == "aladin" } {
              set aladinnick "aladin"
              set aladinidx $xzombieid($aladinnick)
              putdcc $aladinidx "PRIVMSG ``-P-r-3-`` :!voice aladin bot"
            }

        } elseif { [string match *j* $xzombieconsole($idx)] } {
            putloglev 6 * "\002\[xZ\]\002 $xzchannel [3]==> (Join)[o] $xzfromnick [3]($xzfromuserhost)"
        }

    }

    #--------------------------------------------------------------------------------
    if { [lindex $arg 1] == "PART" } {
        set xzfrom [string range [lindex $arg 0] 1 end]
        set xzfromnick [Xnick $xzfrom]
        set xzfromuserhost [Xuser $xzfrom]@[Xhost $xzfrom]
        set xzchannel [lindex $arg 2]
        set xzraison [string range [join [lrange $arg 3 end]] 1 end]

        if { [string tolower $xzfromnick] == [string tolower $xzombienick($idx)] } {
            if { $xzraison == "" } {
                putloglev 6 * "\002\[xZ\]\002 $xzchannel [10]<== (Part)[o] $xzfromnick [10]($xzfromuserhost)"
            } else {
                putloglev 6 * "\002\[xZ\]\002 $xzchannel [10]<== (Part)[o] $xzfromnick [10]($xzfromuserhost) ($xzraison[o][10])"
            }
        } elseif { [string match *j* $xzombieconsole($idx)] } {
            if { $xzraison == "" } {
                putloglev 6 * "\002\[xZ\]\002 $xzchannel [10]<== (Part)[o] $xzfromnick [10]($xzfromuserhost)"
            } else {
                putloglev 6 * "\002\[xZ\]\002 $xzchannel [10]<== (Part)[o] $xzfromnick [10]($xzfromuserhost) ($xzraison[o][10])"
            }
        }
    }

    #--------------------------------------------------------------------------------
    if { [lindex $arg 1] == "MODE" } {
        set xzfrom [string range [lindex $arg 0] 1 end]
        set xzfromnick [Xnick $xzfrom]
        set xzfromuserhost [Xuser $xzfrom]@[Xhost $xzfrom]
        set xzchannel [lindex $arg 2]

        if { [string match $xzchannel $xzfrom] } {
            set xzmode [string range [join [lrange $arg 3 end]] 1 end]
            putloglev 6 * "\002\[xZ\]\002 [4]=== (Mode)[o] $xzfromnick [4]sets mode: $xzmode"

            if { $xzmode == "+iwx" } {
              set aladinxznick "aladin"
              set aladinxzto "#pre"
              if { [valididx $xzombieid($aladinxznick)] } {
                set aladinxzidx $xzombieid($aladinxznick)
                putdcc $aladinxzidx "JOIN $aladinxzto"
              }
            }
                
        } else {
            set xzmode [join [lrange $arg 3 end]]
            if { [string match *k* $xzombieconsole($idx)] } {
                putloglev 6 * "\002\[xZ\]\002 $xzchannel [4]=== (Mode)[o] $xzfromnick [4]($xzfromuserhost) sets mode: $xzmode"
            }
        }

    }

    #--------------------------------------------------------------------------------
    if { [lindex $arg 1] == "KICK" } {
        set xzfrom [string range [lindex $arg 0] 1 end]
        set xzfromnick [Xnick $xzfrom]
        set xzfromuserhost [Xuser $xzfrom]@[Xhost $xzfrom]
        set xzchannel [lindex $arg 2]
        set xzvictime [lindex $arg 3]
        set xzraison [string range [join [lrange $arg 4 end]] 1 end]
        if { [string tolower $xzfromnick] == [string tolower $xzombienick($idx)] } {
            putloglev 6 * "\002\[xZ\]\002 $xzchannel [4]<== (Kick)[o] $xzvictime [4]was kicked by $xzfromnick ($xzfromuserhost) ($xzraison[o][4])"
        } elseif { [string match *k* $xzombieconsole($idx)] } {
            putloglev 6 * "\002\[xZ\]\002 $xzchannel [4]<== (Kick)[o] $xzvictime [4]was kicked by $xzfromnick ($xzfromuserhost) ($xzraison[o][4])"
        }
    }
}



#############
# xunzombie #
#############
bind dcc Z xunzombie zombie:dcc:xunzombie

proc zombie:dcc:xunzombie { hand idx arg } {
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set arg [split $arg]
    set xznick [string tolower [lindex $arg 0]]

    if { $xznick == "" } {
        putdcc $idx "\002Syntaxe\002: .xunzombie <zombie/idx> (.xzlist pour voir la liste des zombies)"
        return 0
    } elseif { [isnumber $xznick] } {

        if { ![info exist xzombienick($xznick)] } {
            putdcc $idx "\002\[xUnZombie\]\002 Zombie inexistant, impossible de supprimer: [lindex $arg 0]"
            return 0
        } elseif { ![valididx $xznick] } {
            putdcc $idx "\002\[xUnZombie\]\002 Zombie inexistant, impossible de supprimer: [lindex $arg 0]"
            return 0
        } else {
            set xzidx $xznick
            set xznick $xzombienick($xzidx)]
            killdcc $xzidx

            putdcc $idx "\002\[xUnZombie\]\002 xUnZombie sur $xzombienick($xzidx) (idx = $xzidx)"

            if { [info exist xzombieid($xznick)] } { unset xzombieid($xznick) }
            if { [info exist xzombieserver($xzidx)] } { unset xzombieserver($xzidx) }
            if { [info exist xzombieport($xzidx)] } { unset xzombieport($xzidx) }
            if { [info exist xzombieconsole($xzidx)] } { unset xzombieconsole($xzidx) }
            if { [info exist xzombienick($xzidx] } {) unset xzombienick($xzidx) }
            if { [info exist xzombieuser($xzidx)] } { unset xzombieuser($xzidx) }
            if { [info exist xzombierealname($xzidx)] } { unset xzombierealname($xzidx) }

            return 1
        }

    } else {
        if { ![info exist xzombieid($xznick)] } {
            putdcc $idx "\002\[xUnZombie\]\002 Zombie inexistant, impossible de supprimer: [lindex $arg 0]"
            return 0
        } elseif { ![valididx $xzombieid($xznick)] } {
            putdcc $idx "\002\[xUnZombie\]\002 Zombie inexistant, impossible de supprimer: [lindex $arg 0]"
            return 0
        } else {
            set xzidx $xzombieid($xznick)
            killdcc $xzidx

            putdcc $idx "\002\[xUnZombie\]\002 xUnZombie sur $xzombienick($xzidx) (idx = $xzidx)"

            if { [info exist xzombieid($xznick)] } { unset xzombieid($xznick) }
            if { [info exist xzombieserver($xzidx)] } { unset xzombieserver($xzidx) }
            if { [info exist xzombieport($xzidx)] } { unset xzombieport($xzidx) }
            if { [info exist xzombieconsole($xzidx)] } { unset xzombieconsole($xzidx) }
            if { [info exist xzombienick($xzidx] } {) unset xzombienick($xzidx) }
            if { [info exist xzombieuser($xzidx)] } { unset xzombieuser($xzidx) }
            if { [info exist xzombierealname($xzidx)] } { unset xzombierealname($xzidx) }

            return 1
        }
    }
}



#############
# xzconsole #
#############
bind dcc Z xzconsole zombie:dcc:xzconsole

proc zombie:dcc:xzconsole { hand idx arg } {
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set arg [split $arg]
    set xznick [string tolower [lindex $arg 0]]
    set xzconsole [lindex $arg 1]

    if { $xzconsole == "" || $xznick == "" } {
        putdcc $idx "\002Syntaxe\002: .xzconsole <nick/idx> <console>"
        putdcc $idx "   Console:"
        putdcc $idx "       m=display private msgs to the zombie"
        putdcc $idx "       p=display public talk on the channel"
        putdcc $idx "       j=display joins/parts/nick changes/signoffs/etc on the channel"
        putdcc $idx "       k=display kicks/bans/mode changes on the channel"
        putdcc $idx " "
        return 0
    } elseif { [isnumber $xznick] } {
        if { ![info exists xzombienick($xznick)] } {
            putdcc $idx "\002\[xZconsole\]\002 Zombie inexistant - pas de zombie correspondant à l'idx: $xznick"
            return 0
        } else {
            set xzombieconsole($xznick) $xzconsole
            return 1
        }
    } elseif { [info exist xzombieid($xznick)] } {
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            set xzombieconsole($xzidx) $xzconsole
            putdcc $idx "\002\[xZconsole\]\002 [12][lindex $arg 0][o] --> CONSOLE $xzconsole"
            return 0
        } else {
            putdcc $idx "\002\[xZconsole\]\002 Zombie inexistant: [lindex $arg 0]"
            return 0
        }
    } else {
        putdcc $idx "\002\[xZconsole\]\002 Zombie inexistant: [lindex $arg 0]"
        return 0
    }
}



##########
# xzjoin #
##########
bind dcc Z xzjoin zombie:dcc:xzjoin

proc zombie:dcc:xzjoin { hand idx arg } {
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set arg [split $arg]
    set xznick [string tolower [lindex $arg 0]]
    set xzchannel [join [lrange $arg 1 end]]

    if { $xzchannel == "" || $xznick == "" } {
        putdcc $idx "\002Syntaxe\002: .xzjoin <nick/idx> <channel>"
        return 0
    } elseif { [isnumber $xznick] } {
        if { ![info exists xzombienick($xznick)] } {
            putdcc $idx "\002\[xZjoin\]\002 Zombie inexistant - pas de zombie correspondant à l'idx: $xznick"
            return 0
        } else {
            putdcc $xznick "JOIN $xzchannel"
            return 1
        }
    } elseif { [info exist xzombieid($xznick)] } {
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            putdcc $xzidx "JOIN $xzchannel"
            return 1
        } else {
            putdcc $idx "\002\[xZjoin\]\002 Zombie inexistant: [lindex $arg 0]"
            return 0
        }
    } else {
        putdcc $idx "\002\[xZjoin\]\002 Zombie inexistant: [lindex $arg 0]"
        return 0
    }
}



##########
# xzpart #
##########
bind dcc Z xzpart zombie:dcc:xzpart

proc zombie:dcc:xzpart { hand idx arg } {
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set arg [split $arg]
    set xznick [string tolower [lindex $arg 0]]
    set xzchannel [join [lrange $arg 1 end]]

    if { $xzchannel == "" || $xznick == "" } {
        putdcc $idx "\002Syntaxe\002: .xzpart <nick/idx> <channel>"
        return 0
    } elseif { [isnumber $xznick] } {
        if { ![info exists xzombienick($xznick)] } {
            putdcc $idx "\002\[xZpart\]\002 Zombie inexistant - pas de zombie correspondant à l'idx: $xznick"
            return 0
        } else {
            putdcc $xznick "PART $xzchannel"
            return 1
        }
    } elseif { [info exist xzombieid($xznick)] } {
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)

            putdcc $xzidx "PART $xzchannel"
            return 1
        } else {
            putdcc $idx "\002\[xZpart\]\002 Zombie inexistant: [lindex $arg 0]"
            return 0
        }
    } else {
        putdcc $idx "\002\[xZpart\]\002 Zombie inexistant: [lindex $arg 0]"
        return 0
    }
}



#########
# xzmsg #
#########
bind dcc Z xzmsg zombie:dcc:xzmsg

proc zombie:dcc:xzmsg { hand idx arg } {
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set arg [split $arg]
    set xznick [string tolower [lindex $arg 0]]
    set xzto [lindex $arg 1]
    set xzmessage [join [lrange $arg 2 end]]

    if { $xznick == "" || $xzto == "" || $xzmessage == "" } {
        putdcc $idx "\002Syntaxe\002: .xzmsg <nick/idx> <channel/pseudo> <message>"
        return 0
    } elseif { [isnumber $xznick] } {
        if { ![info exists xzombienick($xznick)] } {
            putdcc $idx "\002\[xZmsg\]\002 Zombie inexistant - pas de zombie correspondant à l'idx: $xznick"
            return 0
        } else {
            putdcc $xznick "PRIVMSG $xzto :$xzmessage"
            putloglev 6 * "\002\[xZmsg\]\002 $xzombienick($xznick) -> *$xzto* $xzmessage"
            return 0
        }
    } elseif { [info exist xzombieid($xznick)] } {
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            putdcc $xzidx "PRIVMSG $xzto :$xzmessage"
            putloglev 6 * "\002\[xZmsg\]\002 [lindex $arg 0] -> *$xzto* $xzmessage"
            return 0
        } else {
            putdcc $idx "\002\[xZmsg\]\002 Zombie inexistant: [lindex $arg 0]"
            return 0
        }
    } else {
        putdcc $idx "\002\[xZmsg\]\002 Zombie inexistant: [lindex $arg 0]"
        return 0
    }
}



############
# xznotice #
############
bind dcc Z xznotice zombie:dcc:xznotice

proc zombie:dcc:xznotice { hand idx arg } {
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set arg [split $arg]
    set xznick [string tolower [lindex $arg 0]]
    set xzto [lindex $arg 1]
    set xzmessage [join [lrange $arg 2 end]]

    if { $xznick == "" || $xzto == "" || $xzmessage == "" } {
        putdcc $idx "\002Syntaxe\002: .xznotice <nick/idx> <channel/pseudo> <message>"
        return 0
    } elseif { [isnumber $xznick] } {
        if { ![info exists xzombienick($xznick)] } {
            putdcc $idx "\002\[xZnotice\]\002 Zombie inexistant - pas de zombie correspondant à l'idx: $xznick"
            return 0
        } else {
            putdcc $xznick "NOTICE $xzto :$xzmessage"
            putloglev 6 * "\002\[xZnotice\]\002 $xzombienick($xznick) -> -$xzto- $xzmessage"
            return 0
        }
    } elseif { [info exist xzombieid($xznick)] } {
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            putdcc $xzidx "NOTICE $xzto :$xzmessage"
            putloglev 6 * "\002\[xZnotice\]\002 [lindex $arg 0] -> -$xzto- $xzmessage"
            return 0
        } else {
            putdcc $idx "\002\[xZnotice\]\002 Zombie inexistant: [lindex $arg 0]"
            return 0
        }
    } else {
        putdcc $idx "\002\[xZnotice\]\002 Zombie inexistant: [lindex $arg 0]"
        return 0
    }
}



##########
# xznick #
##########
bind dcc Z xznick zombie:dcc:xznick

proc zombie:dcc:xznick { hand idx arg } {
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set arg [split $arg]
    set xznick [string tolower [lindex $arg 0]]
    set xznewnick [lindex $arg 1]

    if { $xznewnick == "" || $xznick == "" } {
        putdcc $idx "\002Syntaxe\002: .xznick <nick/idx> <nouveau nick>"
        return 0
    } elseif { [isnumber $xznick] } {
        if { ![info exists xzombienick($xznick)] } {
            putdcc $idx "\002\[xZnick\]\002 Zombie inexistant - pas de zombie correspondant à l'idx: $xznick"
            return 0
        } else {
            putdcc $xznick "NICK $xznewnick"
            return 1
        }
    } elseif { [info exist xzombieid($xznick)] } {
        if { [valididx $xzombieid($xznick)] } {
            set xzidx $xzombieid($xznick)
            putdcc $xzidx "NICK $xznewnick"
            return 1
        } else {
            putdcc $idx "\002\[xZnick\]\002 Zombie inexistant: [lindex $arg 0]"
            return 0
        }
    } else {
        putdcc $idx "\002\[xZnick\]\002 Zombie inexistant: [lindex $arg 0]"
        return 0
    }
}




proc zombie:autocreate:aladin { } {
    global zombie
    global xzombie xzombieid xzombieserver xzombieport xzombieconsole xzombienick xzombieuser xzombierealname

    set xznick "aladin"
    set xzto "#pre"
    if { [info exists xzombieid($xznick)] } {
      if { [valididx $xzombieid($xznick)] } {
        killdcc $xzombieid($xznick)
      }
    }

    set arg "irc.recycled-irc.org 6667 pm Aladin aladin Bot echo"
    set arg [split $arg]

    set xzserver [lindex $arg 0]
    set xzport [lindex $arg 1]

    if { [lindex $arg 5] != "" } {
        if { ![catch {connect $xzserver $xzport } xzidx]} {
            set xzombieserver($xzidx) [lindex $arg 0]
            set xzombieport($xzidx) [lindex $arg 1]
            set xzombieconsole($xzidx) [lindex $arg 2]
            set xzombienick($xzidx) [lindex $arg 3]
            set xzombieuser($xzidx) [lindex $arg 4]
            set xzombierealname($xzidx) [join [lrange $arg 5 end]]

            set xzombieid([string tolower $xzombienick($xzidx)]) $xzidx

            putlog "\002\[xZombie\]\002 xZombie sur $xzserver:$xzport (Idx = $xzidx)" 

            putdcc $xzidx "USER $xzombieuser($xzidx) $xzombieuser($xzidx) $xzombieuser($xzidx) :$xzombierealname($xzidx)"
            putdcc $xzidx "NICK $xzombienick($xzidx) localhost r :$xzombierealname($xzidx)"

            control $xzidx xzombie:event

            return 1
        } else {
            putlog "\002\[xZombie\]\002 xZombie impossible sur $xzserver:$xzport" 
            return 0
        }
    }
}

zombie:autocreate:aladin