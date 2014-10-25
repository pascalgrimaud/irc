#
# EggTools2-1.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Aidé par nix-egg.tcl - nix@valium.org
# Console +7 : pour voir les messages envoyés par l'eggdrop
#
# ----
# 08/12/02:
#   modification totale de procédure de fichiers
#   débuggage des [,],{,}
#
# -----
# 04/11/02:
#   retrait des host-x inutiles
#
# -----
# 03/02/02:
#   ajout de la commande .setchan
#   ajout de la procédure strip
#   ajout de la proc nojoin
#



#################
# Configuration #
#################

file mkdir system

# info TelnetPort
set MsgTelnetInfo [file:get "system/ListenPortUser.conf"]

if { $MsgTelnetInfo == "" } {
  file:add "system/ListenPortUser.conf" "chat 6000"
  set MsgTelnetInfo "chat 6000"
}

# Mot à envoyer en privé
set MsgTelnetWord [lindex [split $MsgTelnetInfo] 0]

# Port de connexion telnet pour les users (Lors de la connexion avec /msg EggNick ...)
set MsgTelnetPort [lindex [split $MsgTelnetInfo] 1]

# Mode quand l'Egg devient IRCop
set EggTools(OperMode) "+wa"

# Mode quand l'Egg est dé-IRCopé lol ;)
set EggTools(UnOperMode) "-agswo"

# ctcp reply
set ctcp-version    ""
set ctcp-finger     ""
set ctcp-userinfo   ""
set ctcp-clientinfo ""
set ctcp-time       ""



##################
# Initialisation #
##################

unbind msg - rehash *msg:rehash
unbind msg - jump   *msg:jump
unbind msg - die    *msg:die
unbind msg - hello  *msg:hello
unbind msg - status *msg:status
unbind msg - who    *msg:who
unbind msg - whois  *msg:whois
unbind msg - memory *msg:memory
unbind msg - ident  *msg:ident



########
# Motd #
########

putlog "\002EggTools2-1.tcl\002 - Aide : \002.eggtools\002"



########
# Help #
########

bind dcc o eggtools eggtools:help

proc eggtools:help { hand idx text } {
    global MsgTelnetWord MsgTelnetPort botnick

    putdcc $idx " "
    putdcc $idx "     EggTools2-1.tcl - Info     "
    putdcc $idx " "
    putdcc $idx "Description :"
    putdcc $idx "   Qques commandes complémentaires de bases pour les Eggdrops"
    putdcc $idx " "
    putdcc $idx "Commandes :"
    putdcc $idx "  .ping <nick|channel> 14(envoyer un ctcp-ping)"
    putdcc $idx "  .ctcp <nick|channel> <type> 14(envoyer un ctcp)"
    putdcc $idx "  .xmsg <nick|channel> <message> 14(envoyer un message masqué)"
    putdcc $idx "  .notice <nick|channel> <message> 14(envoyer une notice)"
    putdcc $idx "  .wallchops <message> 14(envoyer un wallchops sur le salon où est mis votre console)"
    putdcc $idx "  .cycle <channel> 14(part/join)"
    putdcc $idx " "
    putdcc $idx "  .xoper <username> <password> 14(Rendre le robot IRCop avec une Oline existante)"
    putdcc $idx "  .xunoper 14(Retire les privilèges d'IRCop du robot)"
    putdcc $idx " "
    putdcc $idx "Telnet :"
    putdcc $idx "  /msg $botnick $MsgTelnetWord"
    putdcc $idx "  Port : $MsgTelnetPort"
    putdcc $idx " "
    putdcc $idx "Procédures : (à mettre ds le need-op & need-invite si nécessaire)"
    putdcc $idx "  EggOp <nom eggdrop> <pass> <channel> \[user@host\]"
    putdcc $idx "  EggInvite <nom eggdrop> <pass> <channel> \[user@host\]"
    putdcc $idx "  EggOper:op <channel"
    putdcc $idx "  EggOper:joinx <channel>"
    putdcc $idx " "
    putdcc $idx "Set Channel : "
    putdcc $idx "  .setchan <channel> <option> \[modes\]"
    putdcc $idx " "
    putdcc $idx ".eggtools <-- Aide, vous êtes ici!"
    putdcc $idx " "
    return 1
}



#########################
# /msg <botnick> <word> #
#########################

bind msg p $MsgTelnetWord msg_chat

proc msg_chat {nick uhost hand arg} {
    global MsgTelnetPort

    set userport $MsgTelnetPort
    listen $userport users
    putserv "PRIVMSG $nick :\001DCC CHAT chat [myip] $userport\001"
    return 1
}



########
# CTCP #
########

bind dcc o ctcp ctcp

proc ctcp { hand idx text } {
    set text [split $text]

    set targ [lindex $text 0]
    if { [lindex $text 1] == "" } {
        putdcc $idx "Usage: .ctcp <target> <type> <arg(optional)>"
        return 0
    } else {
        set type [string toupper [lindex $text 1]]
    }
    if { $type == "PING" } {
        set param [unixtime]
    } elseif { [lindex $text 2] != "" } {
        set param [join [lrange $text 2 end]]
    } else {
        set param ""
    }
    putserv "PRIVMSG $targ :\x01$type $param\x01"
    putdcc $idx "4-> \[$targ\] $type $param"
    return 1
}


bind dcc o ping ping

proc ping { hand idx text } {
    set text [split $text]

    if { [lindex $text 0] == "" } {
        putdcc $idx "Usage: .ping <target>"
        return 0
    }
    putserv "PRIVMSG [lindex $text 0] :\x01PING [unixtime]\x01"
    putdcc $idx "4-> \[[lindex $text 0]\] PING"
    return 1
}


bind ctcr - "PING" ctcr

proc ctcr { nick uhost hand dest key arg } {
    set pingrep "[expr [clock seconds]-$arg]"
    if {$pingrep > 1} {putlog "\[$key Reply\] [duration $pingrep] from $uhost"
    } else {putlog "\[$key Reply\] 0 sec from $uhost"}
}



############
# Messages #
############

bind dcc o xmsg xmsg

proc xmsg { hand idx text } {
    global botnick
    set text [split $text]

    if {[lindex $text 1] == ""} {
        putdcc $idx "Usage: .xmsg <nick | #channel> <text>"
        return 0
    }
    putdcc $idx "PRIVMSG to [lindex $text 0] : [join [lrange $text 1 end]]"
    putserv "PRIVMSG [lindex $text 0] :[join [lrange $text 1 end]]"
    putlog "#$hand# xmsg [lindex $text 0] \[something\]"
    return 0
}



###########
# Notices #
###########

bind dcc o notice notice

proc notice { hand idx text } {
    global botnick
    set text [split $text]

    if {[lindex $text 1] == ""} {
        putdcc $idx "Usage: .notice <target> <text>"
        return 0
    }
    putserv "NOTICE [lindex $text 0] :[join [lrange $text 1 end]]"
    putdcc $idx "NOTICE to [lindex $text 0] : [join [lrange $text 1 end]]"
    return 1
}

bind dcc - wallchops wallchops

proc wallchops { hand idx text } {
    global botnick
    set text [lindex $text 0]

    if {[lindex $text 0] == ""} {
        putdcc $idx "Usage: .wallchops <text>"
        return 0
    }
    if { [string match #* [lindex $text 0]] } {
        set chan [lindex $text 0]
        set text [join [lrange $text 1 end]]
    } else {
        set chan [lindex [console $idx] 0]
    }
    if { ![matchchanattr $hand o $chan] && ![matchattr $hand o] } {
        putdcc $idx "You don't have access for $chan"
        return 0
    }
    if { ![onchan $botnick $chan] } {
        putdcc $idx "I m not in $chan."
        return 0
    }
    putserv "WALLCHOPS $chan :$text"
    putdcc $idx "WALLCHOPS to $chan : $text"
    return 1
}



###############
# Joins/Parts #
###############

bind dcc n cycle cycle

proc cycle { hand idx text } {
    global botnick
    set text [split $text]

    if {[lindex $text 0] == ""} {
        putdcc $idx "Usage: .cycle <channel>"
        return 0
    }
    set chan [lindex $text 0]
    if { ![matchchanattr $hand n $chan] && ![matchattr $hand n] } {
        putdcc $idx "Acces denied"
        return 0
    }
    if { ![onchan $botnick $chan] } {
        putdcc $idx "I m not in $chan."
        return 0
    }
    if { [string match *k* [lindex [getchanmode $chan] 0]] } {
        set key [lindex [getchanmode $chan] 1]
    } else {
        set key ""
    }
    putserv "PART $chan"
    putserv "JOIN $chan $key"
    putdcc $idx "Cycling $chan $key"
    return 1
}



#########
# xoper #
#########
bind dcc -|- xoper EggTools:dcc:xoper

proc EggTools:dcc:xoper { hand idx vars } {
    global botnick EggTools

    set vars [split $vars]
    set username [lindex $vars 0]
    set password [lindex $vars 1]

    if { $username != "" } {
        if { $password != "" } {
            putserv "OPER $username $password"
            putserv "MODE $botnick $EggTools(OperMode)"
            putlog "#$hand# xoper $botnick"
        } else {
            putdcc $idx "\002Syntaxe\002: .xoper <username> <password>"
            putdcc $idx "T'as oublié le mot de passe?"
            return 0
        }
    } else {
        putdcc $idx "\002Syntaxe\002: .xoper <username> <password>"
        putdcc $idx "T'as oublié le username?"
        return 0
    }

    unset username
    unset password

    return 0
}



###########
# xunoper #
###########
bind dcc -|- xunoper EggTools:dcc:xunoper

proc EggTools:dcc:xunoper { hand idx arg } {
    global botnick EggTools

    putserv "MODE $botnick $EggTools(UnOperMode)"
    putlog "#$hand# xunoper $botnick"

    return
}



##########
# chanop #
##########

bind dcc n chanop channel:chanop

proc channel:chanop { hand idx arg } {
  set arg [lindex [split $arg] 0]

  if { ![validchan $arg] } { channel add $arg }
  set tempop "EggOper:op $arg"
  set tempjoin "EggOper:joinx $arg"
  channel set $arg need-op $tempop need-invite $tempjoin need-key $tempjoin need-unban $tempjoin need-limit $tempjoin
  channel set $arg flood-chan 1:0 flood-ctcp 3:60 flood-join 1:0 flood-kick 1:0 flood-deop 1:0 flood-nick 1:0
  savechannels
  return 1
}



############
# Info Bot #
############

bind chon m * botuptime

proc botuptime { hand idx } {
    global uptime
    putdcc $idx "\[Up time: ([ctime $uptime])\]"
    putdcc $idx "\[Bots Net: ([bots])\]"
}



########
# Bans #
########

set maxban 30
set keepban 20

proc MaxBan {} {
    global maxban keepban
    foreach c [channels] {
        if { ([llength [chanbans $c]] >= $maxban ) && ([botisop $c]) } {
            set totban [llength [chanbans $c]]
            putlog "the ban list is full on $c ($totban)"
            set unbanlist ""
            foreach ub [lrange [chanbans $c] $keepban end] {lappend unbanlist [lindex $ub 0]}
            for { set i 0 } { $i < [llength $unbanlist] } { incr i +6 } {
                putserv "MODE $c -bbbbbb [join [lrange $unbanlist $i [expr $i + 5]]]"
            }
        }
    }
    timer 3 MaxBan
}
foreach b [timers] {
  if { [string match *MaxBan* [lindex $b 1]] } {
    killtimer [lindex $b 2]
  }
}
timer 3 MaxBan



###########
# setchan #
###########

bind dcc n setchan setchan

proc setchan { hand idx text } {
    set text [split $text]
    putlog "#$hand# setchan [lindex $text 0] \[modes\]"
    channel set [lindex $text 0] [lindex $text 1] [join [lrange $text 2 end]]
    savechannels
}


###########################
# seetimers et seeutimers #
###########################

bind dcc n seetimers seetimers

proc seetimers { hand idx text } {
    foreach t [timers] { putdcc $idx "timers> $t" }
    return 1
}

bind dcc n seeutimers seeutimers

proc seeutimers { hand idx text } {
    foreach t [utimers] { putdcc $idx "utimers> $t" }
    return 1
}

###############
# Invite & Op #
###############

set EggInviteRaw ""
set EggOpRaw ""
set EggInviteInfo ""
set EggOpInfo ""

proc EggInvite { EggInviteBot EggInvitePass EggInviteChan { EggInviteUserhost "" } } {
    global EggInviteInfo EggInviteRaw

    set EggInviteRaw 1
    set EggInviteInfo "$EggInviteBot $EggInvitePass $EggInviteChan $EggInviteUserhost"

    bind raw - "302" EggCheck
    putserv "USERHOST $EggInviteBot"
}

proc EggOp { EggOpBot EggOpPass EggOpChan { EggOpUserhost "" } } {
    global EggOpInfo EggOpRaw

    set EggOpRaw 1
    set EggOpInfo "$EggOpBot $EggOpPass $EggOpChan $EggOpUserhost"

    bind raw - "302" EggCheck
    putserv "USERHOST $EggOpBot"
} 

proc EggCheck { from key text } {
    global EggInviteInfo EggInviteRaw
    global EggOpInfo EggOpRaw 
    set text [split $text]

    if { [info exists EggInviteRaw] && [info exists EggInviteInfo] } {
        set EggInviteInfo [split $EggInviteInfo]
        set TempEggNick [lindex $EggInviteInfo 0]
        set TempEggPass [lindex $EggInviteInfo 1]
        set TempEggChan [lindex $EggInviteInfo 2]
        set TempEggText [lindex $EggInviteInfo 3]

        if { [validchan $TempEggChan] && ![botonchan $TempEggChan] } {             
            set text [lrange [split $text +] end end]
            if { $TempEggText != "" } {
                if { [string match $TempEggText $text] } {
                    putloglev 7 * "\[\002EggInvite\002\] PRIVMSG $TempEggNick :INVITE \[something\] $TempEggChan"
                    putserv "PRIVMSG $TempEggNick :INVITE $TempEggPass $TempEggChan"
                } else {
                    putloglev 7 * "\[\002EggInvite\002\] Erreur d'identification -> $TempEggNick"
                    putloglev 7 * "\[\002EggInvite\002\] $TempEggText <-> $text"
                }
            } else {
                putloglev 7 * "\[\002EggInvite\002\] PRIVMSG $TempEggNick :INVITE \[something\] $TempEggChan"
                putserv "PRIVMSG $TempEggNick :INVITE $TempEggPass $TempEggChan"
            }
        }

        unset TempEggNick
        unset TempEggPass
        unset TempEggChan
        unset TempEggText

        unset EggInviteRaw
        unset EggInviteInfo
    } 
    if { [info exists EggOpRaw] && [info exists EggOpInfo] } {
        set EggOpInfo [split $EggOpInfo]
        set TempEggNick [lindex $EggOpInfo 0]
        set TempEggPass [lindex $EggOpInfo 1]
        set TempEggChan [lindex $EggOpInfo 2]
        set TempEggText [lindex $EggOpInfo 3]

        if { [validchan $TempEggChan] && ![botisop $TempEggChan] } {             
            set text [lrange [split $text +] end end]
            if { $TempEggText != "" } {
                if { [string match $TempEggText $text] } {
                    putloglev 7 * "\[\002EggOp\002\] PRIVMSG $TempEggNick :OP \[something\] $TempEggChan"
                    putserv "PRIVMSG $TempEggNick :OP $TempEggPass $TempEggChan"
                } else {
                    putloglev 7 * "\[\002EggOp\002\] Erreur d'identification -> $TempEggNick"
                    putloglev 7 * "\[\002EggOp\002\] $TempEggText <-> $text"
                }
            } else {
                putloglev 7 * "\[\002EggOp\002\] PRIVMSG $TempEggNick :OP \[something\] $TempEggChan"
                putserv "PRIVMSG $TempEggNick :OP $TempEggPass $TempEggChan"
            }
        }

        unset TempEggNick
        unset TempEggPass
        unset TempEggChan
        unset TempEggText

        unset EggOpRaw
        unset EggOpInfo
    }
    unbind raw - "302" EggCheck
}



###############################
# EggOper:op et EggOper:joinx #
###############################

proc EggOper:op { chan } {
    global botnick

    putserv "SAMODE $chan +o $botnick"
    return
}

proc EggOper:join { chan } {
    global botnick

    putserv "JOIN $chan x"
    return
}

proc EggOper:joinx { chan } {
    global botnick

    putserv "JOIN $chan x"
    return
}
