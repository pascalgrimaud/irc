#
# N-Auth.tcl <ibu_lordaeron@yahoo.fr>
#



#################
# Configuration #
#################

# pseudo du NickServ
set nauth(nick) "N"

# host du NickServ
set nauth(host) "nickserv@1667194866.com"

# Pass pour le NickServ
set nauth(pass) "passnickserv"

# Message d'identification
set nauth(auth) "Ce pseudo appartient à une autre personne. Merci de bien vouloir en choisir un autre en tapant /nick <pseudo>. Si c'est votre nick, tapez: /msg N IDENTIFY <password>"

# Message d'acceptation ---> ajouter son pseudo
set nauth(authed) "Password accepté pour T. Tapez: /msg N HELP pour voir la liste des commandes disponibles."



########
# Motd #
########

putlog "\002N-Auth.tcl\002 - by <ibu_lordaeron@yahoo.fr>"



###############
# Binds+Procs #
###############

bind notc -|- * NAuthNotice

proc NAuthNotice { nick userhost handle text dest } {
    global nauth botnick

    set text [string tolower [split $text]]

    if { [string tolower $nick] == [string tolower $nauth(nick)]
      && [string tolower $userhost] == [string tolower $nauth(host)] } {
        if { [string match [join $text] [string tolower $nauth(auth)]] } {
            raw "PRIVMSG $nauth(nick) :IDENTIFY $nauth(pass)"
            putloglev 7 * "\[Auth NickServ\] PRIVMSG $nauth(nick) :IDENTIFY *****"
        } elseif { [strip [join $text]] == [string tolower $nauth(authed)] } {
            putloglev 7 * "\[Auth NickServ\] Auth accepté!"
        }
    }    
}


