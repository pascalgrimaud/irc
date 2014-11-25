#
# EggTools.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#
# Aidé par nix-egg.tcl - nix@valium.org
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

# Port de connexion telnet pour les users
# (Lors de la connexion avec /msg EggNick ...)
set MsgTelnetPort 6666

# Mot à envoyer en privé
set MsgTelnetWord "chat"

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

putlog "\002EggTools.tcl\002 - Aide : \002.eggtools\002"



########
# Help #
########

bind dcc -|- eggtools eggtools:help

proc eggtools:help { hand idx text } {
    global MsgTelnetWord MsgTelnetPort botnick

    putdcc $idx " "
    putdcc $idx "     EggTools.tcl - Info     "
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
    putdcc $idx "Telnet :"
    putdcc $idx "  /msg $botnick $MsgTelnetWord"
    putdcc $idx "  Port : $MsgTelnetPort"
    putdcc $idx " "
    putdcc $idx "Procédures : (pour le need-op & need-invite)"
    putdcc $idx "  EggOp <nom eggdrop> <pass> <channel> \[user@host\] 14(requête d'op)"
    putdcc $idx "  EggInvite <nom eggdrop> <pass> <channel> \[user@host\] 14(requête d'invitation)"
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
    set targ [lindex $text 0]
    if {[lindex $text 1] == ""} {putdcc $idx "Usage: .ctcp <target> <type> <arg(optional)>"; return 0
    } else {set type [string toupper [lindex $text 1]]}
    if {$type == "PING"} {set param [unixtime]
    } elseif {[lindex $text 2] != ""} {set param [join [lrange $text 2 end]]
    } else {set param ""}
    putserv "PRIVMSG $targ :\x01$type $param\x01"
    putdcc $idx "4-> \[$targ\] $type $param"
    return 1
}

bind dcc o ping ping

proc ping { hand idx text } {
    if {[lindex $text 0] == ""} {putdcc $idx "Usage: .ping <target>"; return 0}
    putserv "PRIVMSG [lindex $text 0] :\x01PING [unixtime]\x01"
    putdcc $idx "-> \[[lindex $text 0]\] PING"
    return 1
}

bind ctcr - "PING" ctcr

proc ctcr {nick uhost hand dest key arg} {
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
    set text [nojoin $text]
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
    set text [nojoin $text]
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
    if {[string match #* [lindex $text 0]]} {set chan [lindex $text 0]; set text [lrange $text 1 end]
    } else {set chan [lindex [console $idx] 0]}
    if {![matchchanattr $hand o $chan] && ![matchattr $hand o]} {putdcc $idx "You don't have access for $chan"; return 0}
    if {![onchan $botnick $chan]} {putdcc $idx "I m not in $chan."; return 0}
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
    if {[lindex $text 0] == ""} {
        putdcc $idx "Usage: .cycle <channel>"
        return 0
    }
    set chan [lindex $text 0]
    if {![matchchanattr $hand n $chan] && ![matchattr $hand n]} {putdcc $idx "Acces denied"; return 0}
    if {![onchan $botnick $chan]} {putdcc $idx "I m not in $chan."; return 0}
    if {[string match *k* [lindex [getchanmode $chan] 0]]} {set key [lindex [getchanmode $chan] 1]
    } else {set key ""}
    putserv "PART $chan"
    putserv "JOIN $chan $key"
    putdcc $idx "Cycling $chan $key"
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
        if {([llength [chanbans $c]] >= $maxban) && ([botisop $c])} {
            set totban [llength [chanbans $c]]
            putlog "the ban list is full on $c ($totban)"
            set unbanlist ""
            foreach ub [lrange [chanbans $c] $keepban end] {lappend unbanlist [lindex $ub 0]}
            for {set i 0} {$i < [llength $unbanlist]} {incr i +6} {
                putserv "MODE $c -bbbbbb [join [lrange $unbanlist $i [expr $i + 5]]]"
            }
        }
    }
    timer 3 MaxBan
}
foreach b [timers] {if {[lindex $b 1] == "MaxBan"} {killtimer [lindex $b 2]}}
timer 3 MaxBan



###############
# Invite & Op #
###############

bind dcc n setchan setchan

proc setchan { hand idx text } {
    set text [nojoin $text]
    putlog "#$hand# setchan [lindex $text 0] \[modes\]"
    channel set [lindex $text 0] [lindex $text 1] [join [lrange $text 2 end]]
    savechannels
}

set EggInviteRaw ""
set EggOpRaw ""
set EggInviteInfo ""
set EggOpInfo ""

proc EggInvite { EggInviteBot EggInvitePass EggInviteChan {EggInviteUserhost ""} } {
    global EggInviteInfo EggInviteRaw

    set EggInviteRaw 1
    set EggInviteInfo "$EggInviteBot $EggInvitePass $EggInviteChan $EggInviteUserhost"
    putserv "USERHOST $EggInviteBot"
}

proc EggOp { EggOpBot EggOpPass EggOpChan {EggOpUserhost ""} } {
    global EggOpInfo EggOpRaw

    set EggOpRaw 1
    set EggOpInfo "$EggOpBot $EggOpPass $EggOpChan $EggOpUserhost"
    putserv "USERHOST $EggOpBot"
} 

bind raw - "302" EggCheck
proc EggCheck {from key text} {
    global EggInviteInfo EggInviteRaw
    global EggOpInfo EggOpRaw 

    if { [info exists EggInviteRaw] && [info exists EggInviteInfo] } {
        set TempEggNick [lrange $EggInviteInfo 0 0]
        set TempEggPass [lrange $EggInviteInfo 1 1]
        set TempEggChan [lrange $EggInviteInfo 2 2]
        set TempEggText [lrange $EggInviteInfo 3 3]

        if { [validchan $TempEggChan] && ![botonchan $TempEggChan] } {             
            set text [lrange [split $text +] end end]
            if { $TempEggText != "" } {
                if { [string match [string tolower $TempEggText] [string tolower $text]] } {
                    putloglev 2 * "PRIVMSG $TempEggNick :INVITE \[something\] $TempEggChan"
                    putserv "PRIVMSG $TempEggNick :INVITE $TempEggPass $TempEggChan"
                } else {
                    putlog "\[EggInvite\]: Erreur d'identification -> $TempEggNick"
                    putlog "\[EggInvite\]: $TempEggText <-> $text"
                }
            } else {
                putloglev 2 * "PRIVMSG $TempEggNick :INVITE \[something\] $TempEggChan"
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
        set TempEggNick [lrange $EggOpInfo 0 0]
        set TempEggPass [lrange $EggOpInfo 1 1]
        set TempEggChan [lrange $EggOpInfo 2 2]
        set TempEggText [lrange $EggOpInfo 3 3]

        if { [validchan $TempEggChan] && ![botisop $TempEggChan] } {             
            set text [lrange [split $text +] end end]
            if { $TempEggText != "" } {
                if { [string match $TempEggText $text] } {
                    putloglev 2 * "PRIVMSG $TempEggNick :OP \[something\] $TempEggChan"
                    putserv "PRIVMSG $TempEggNick :OP $TempEggPass $TempEggChan"
                } else {
                    putlog "\[EggOp\]: Erreur d'identification -> $TempEggNick"
                    putlog "\[EggOp\]: $TempEggText <-> $text"
                }
            } else {
                putloglev 2 * "PRIVMSG $TempEggNick :OP \[something\] $TempEggChan"
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
} 


##############
# Procédures #
##############

#
# le reverse du [join <string>]
#
proc nojoin { text } {
  regsub -all -- {\\} $text {\\\\} text
  regsub -all -- {\{} $text {\{} text
  regsub -all -- {\}} $text {\}} text
  regsub -all -- {\[} $text {\[} text
  regsub -all -- {\]} $text {\]} text
  return "$text"
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
# Rq:
#  Une modification a été apportée en retirant le dernier \.([0-9]+) car sur le
#  serveur Wanadoo/Voila, les Ips st cryptés ;)
#  Remplaçant: return [regexp {([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)} $addr]
#
# Ajout du test avec infosources.fr, vu que leur host st composés ds la sorte:
#  *.*.*.infosources.fr
#
# -- SYNTAXE:
#  is_ip_addr <ip/mask>
#
proc is_ip_addr { addr } {
    if { [string match *infosources.fr $addr] } {
        return 0
    } else {
        return [regexp {([0-9]+)\.([0-9]+)\.([0-9]+)} $addr]
    }
}

proc is_ip_norm { addr } {
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



####################################
# Procédures de Gestion de Fichier #
####################################

proc FichierAddInfo { AddInfoFichier AddInfoNick AddInfoInfo } {
    global rep_system

    set AddInfoNickTrouve 0

    set AddInfoFichierAcces "$AddInfoFichier"
    set AddInfoFichierAcces2 "$rep_system/temp.txt"

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
                puts $AddInfoTemp2 "$AddInfoNick $AddInfoInfo"
                set AddInfoNickTrouve 1
            }
        } else {
            if { $AddInfoNickLu != "" } { puts $AddInfoTemp2 "$AddInfoNickLu $AddInfoInfoLu" }
        }
    }

    if {$AddInfoNickTrouve == 0 && $AddInfoNick != "" } {
        puts $AddInfoTemp2 "$AddInfoNick $AddInfoInfo"
    }
    close $AddInfoTemp
    close $AddInfoTemp2

    FichierCopy "$rep_system/temp.txt" $AddInfoFichierAcces

    unset AddInfoTexteLu
    unset AddInfoNickLu
    unset AddInfoInfoLu
    
    return $AddInfoNickTrouve
}

proc FichierAddInfoForce { AddInfoFichier AddInfoInfo } {

    if { [file exists $AddInfoFichier] == 0 } {
        set AddInfoTemp [open $AddInfoFichier w+]
        puts $AddInfoTemp "$AddInfoInfo"
        close $AddInfoTemp
    } else {
        set AddInfoTemp [open $AddInfoFichier a+]
        puts $AddInfoTemp "$AddInfoInfo"
        close $AddInfoTemp
    }
    return
}

proc FichierRemInfo { RemInfoFichier RemInfoNick } {
    global rep_system

    set RemInfoNickTrouve 0

    set RemInfoFichierAcces "$RemInfoFichier"
    set RemInfoFichierAcces2 "$rep_system/temp.txt"

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

    FichierCopy "$rep_system/temp.txt" $RemInfoFichierAcces 

    unset RemInfoTexteLu
    unset RemInfoNickLu
    unset RemInfoInfoLu

    return $RemInfoNickTrouve
}

proc FichierCopy { CopyFichierAcces CopyFichierAcces2 } {
    file copy -force $CopyFichierAcces $CopyFichierAcces2
    return
}

proc FichierLecture { LectureIdx LectureFichierAcces } {

    if {[file exists $LectureFichierAcces] == 0} {
        set LectureFichierTemp [open $LectureFichierAcces w+]
        close $LectureFichierTemp
    }

    set LectureFichierTemp "[open $LectureFichierAcces r]"

    while {![eof $LectureFichierTemp]} {
        set LectureFichierTexteLu [gets $LectureFichierTemp]

        set LectureFichierNickLu [join [lrange $LectureFichierTexteLu 0 0]]
        set LectureFichierNickInfo [join [lrange $LectureFichierTexteLu 1 end]]

        if {$LectureFichierNickLu != ""} {
            putdcc $LectureIdx "$LectureFichierNickLu $LectureFichierNickInfo"
        }
    }

    close $LectureFichierTemp
    unset LectureFichierTexteLu
    unset LectureFichierNickLu
    unset LectureFichierNickInfo

    return
}
