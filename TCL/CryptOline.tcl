#
# CryptOline.tcl
#

bind msg -|- yoper crypt:yoper

proc crypt:yoper { nick uhost hand arg } {
    global botnick

    set vars [split $arg]
    set username [lindex $vars 0]
    set password [lindex $vars 1]

    if { $username != "" } {
        if { $password != "" } {
            putser "PRIVMSG $nick :[encrypt f8gKRaDlF0:F8jGK3fCnDe3 $username] [encrypt k3jfCnV_Fh30rkFl2rkFdEr $password]"
        } else {
            putser "PRIVMSG $nick :\002Syntaxe\002: .yoper <username> <password>"
            putser "PRIVMSG $nick :T'as oublié le mot de passe?"
            return 0
        }
    } else {
        putser "PRIVMSG $nick :\002Syntaxe\002: .yoper <username> <password>"
        putser "PRIVMSG $nick :T'as oublié le username?"
        return 0
    }

    unset username
    unset password

    return 0
}