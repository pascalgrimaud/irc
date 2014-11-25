#
# delire.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#


########
# motd #
########

putlog "\002delire.tcl\002 <ibu_lordaeron@yahoo.fr>"


##################
# initialisation #
##################

set delire(gay) 0
set delire(lovah) 0
set delire(slaps) 0



#########
# procs #
#########

proc random:couleur { } { return [rand 16] }



########
# !gay #
########

bind pub - !gay delire:gay

proc delire:gay { nick uhost handle channel arg } {
  global delire
  
  if { $delire(gay) == 0 } {
    set delire(gay) 1
    putserv "PRIVMSG $channel :Détection de [b]GAY[b] en cours..."
    utimer 5 "delire:gay:say $channel"
  }
}

proc delire:gay:say { channel } {
  global delire botnick

  set string [chanlist $channel]

  set tempnick [lindex $string [rand [llength $string]]]
  while { [string tolower $tempnick] == [string tolower $botnick]
       || [string tolower $tempnick] == "q" } {
    set tempnick [lindex $string [rand [llength $string]]]  
  }
#  set tempnick "Bl1nD"
  putserv "PRIVMSG $channel :[b][4]Un GAY trouvé !!![o] ----->[b][random:couleur]@[random:couleur]@[random:couleur]@[random:couleur]@[13] $tempnick [random:couleur]@[random:couleur]@[random:couleur]@[random:couleur]@"
  set delire(gay) 0
}



##########
# !lovah #
##########

bind pub - !lovah delire:lovah

proc delire:lovah { nick uhost handle channel arg } {
  global delire
  
  if { $delire(lovah) == 0 } {
    set delire(lovah) 1
    putserv "PRIVMSG $channel :Détection de [b]LOVAH[b] en cours..."
    utimer 5 "delire:lovah:say $channel"
  }
}

proc delire:lovah:say { channel } {
  global delire botnick

  set string [chanlist $channel]

  set tempnick [lindex $string [rand [llength $string]]]
  while { [string tolower $tempnick] == [string tolower $botnick]
       || [string tolower $tempnick] == "q" } {
    set tempnick [lindex $string [rand [llength $string]]]  
  }
  putserv "PRIVMSG $channel :[b][4]Un Lovah trouvé !!![o] [random:couleur]@[3]\}--`,---- [random:couleur]@[3]\}--`,---- [random:couleur]@[3]\}--`,---- 4,1 $tempnick [o] [random:couleur]@[3]\}--`,---- [random:couleur]@[3]\}--`,---- [random:couleur]@[3]\}--`,----"
  set delire(lovah) 0
}



#########
# !slap #
#########

bind pub - !slap delire:slaps
bind pub - !slaps delire:slaps

proc delire:slaps { nick uhost handle channel arg } {
  global delire
  
  if { $delire(slaps) == 0 } {
    set delire(slaps) 1
    delire:slaps:say $channel
  }
}

proc delire:slaps:say { channel } {
  global delire botnick

  set string [chanlist $channel]

  set tempnick [lindex $string [rand [llength $string]]]
  while { [string tolower $tempnick] == [string tolower $botnick]
       || [string tolower $tempnick] == "q" } {
    set tempnick [lindex $string [rand [llength $string]]]  
  }
  putserv "PRIVMSG $channel :ACTION slaps $tempnick around a bit with a large trout"
  set delire(slaps) 0
}