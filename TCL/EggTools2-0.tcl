#
# EggTools2-0.tcl par Ibu <ibu_lordaeron@yahoo.fr>
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

# Port de connexion telnet pour les users (Lors de la connexion avec /msg EggNick ...)
set MsgTelnetPort 11520

# Mot à envoyer en privé
set MsgTelnetWord "Link02"

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

putlog "\002EggTools2-0.tcl\002 - Aide : \002.eggtools\002"



########
# Help #
########

bind dcc o eggtools eggtools:help

proc eggtools:help { hand idx text } {
    global MsgTelnetWord MsgTelnetPort botnick

    putdcc $idx " "
    putdcc $idx "     EggTools2-0.tcl - Info     "
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



####################################################################################################
####################################################################################################
####################################################################################################
###
### PROCEDURES DIVERSES 
###
####################################################################################################
####################################################################################################
####################################################################################################

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
proc NickIsBugByGeo { text } {
    set text1 $text
    set text [replace $text "\\\{" "\{"]
    if { $text == $text1 } {
        return 0
    } else {
        return 1
    }
}

proc geodebug { text } {
    return [replace $text "\\\{" "\{"]
}



####################################
# Procédures de Gestion de Fichier #
####################################

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

proc file:copy { CopyFichierAcces CopyFichierAcces2 } {
    file copy -force $CopyFichierAcces $CopyFichierAcces2
    return
}

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

#--------------------------------------------------------------------------------
#
# Procédure qui retourne une ligne aléatoire du fichier
#
# -- SYNTAXE:
#  file:random <repertoire>/<fichier>.<txt>
#
#
#--------------------------------------------------------------------------------
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

#--------------------------------------------------------------------------------
#
# Procédure qui affecte ds une variable string les 1ers mots de chaque ligne
# du fichier et retourne cette variable
#
# -- SYNTAXE:
#  file:tostring <repertoire>/<fichier>.<txt>
#
#
#--------------------------------------------------------------------------------

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


#--------------------------------------------------------------------------------
#
# Procédure qui affecte à chaque ligne du fichier, chaque mot de string
#
# -- SYNTAXE:
#  file:stringto <repertoire>/<fichier>.<txt> <string>
#
#
#--------------------------------------------------------------------------------

proc file:stringto { fichier StringLecture } {
    set openAcces "[open $fichier w+]"
    foreach i StringLecture {
        puts $openAcces "$i"
    }
    close $openAcces

    return
}


#--------------------------------------------------------------------------------
#
# Procédure qui affiche l'ens des Strings si elle est trouvée ds le fichier
#
#--------------------------------------------------------------------------------

proc file:search { fichier idx SearchString } {
    global datadir

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
    global datadir

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
    global datadir

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

