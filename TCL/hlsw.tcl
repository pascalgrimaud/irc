#
# hlsw.tcl
#
#
# Permet de faire gérer le hlsw au travers d'un egg, évitant ainsi de partir en
# excess flood.
#
# Dans la case "channel" de votre hlsw, mettre: =NomDuBot .hlsw
#



#################
# configuration #
#################

# salon où sera annoncé le début/fin hlsw
set hlsw(chan) "#n.t-strats"



########
# motd #
########

putlog "\002hlsw.tcl\002 <ibu_lordaeron@yahoo.fr>"
putlog "   Use \002.hlsw\002 <message> to send message on \002$hlsw(chan)\002"



############
# dcc hlsw #
############

bind dcc -|- hlsw hlsw:msg

proc hlsw:msg { hand idx arg } {
  global hlsw

  set arg [split $arg]
  putserv "PRIVMSG $hlsw(chan) :[join $arg]"
  return 0
}
