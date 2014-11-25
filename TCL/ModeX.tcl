#
# ModeX.tcl par Ibu <ibu_lordaeron@yahoo.fr>
#



####################
# Sources/Sous-TCL #
####################

# source falc_151.tcl
# source procs.tcl



########
# Motd #
########

putlog "\002ModeX.tcl\002 - Procs de Cryptage/Decryptage des Hosts"


#########
# Procs #
#########

# --------------------------

# -
# ibutest1 is zombie@abcdefghijklmnopqrstuvwxyz.org * test
# ibutest1 is using Eva.Entrechat.Net [195.101.94.157] Link Connect Liquid
# ibutest1 has host protection enabled (9nvfrgGjokZmwQ7-FyWMibxcuT.org)
# -

# -
# ibutest2 is zombie@ABCDEFGHIJKLMNOPQRSTUVWXYZ.org * test
# ibutest2 is using Eva.Entrechat.Net [195.101.94.157] Link Connect Liquid
# ibutest2 has host protection enabled (EYVqRHh.CKLtXaPD12Ne6Sd5Ol.org)
# -

# --------------------------

# abcdefghijklmnopqrstuvwxyz
# 9nvfrgGjokZmwQ7-FyWMibxcuT

# ABCDEFGHIJKLMNOPQRSTUVWXYZ
# EYVqRHh.CKLtXaPD12Ne6Sd5Ol

# -0123456789
# sA3B4UI8p0z

# Note: la lettre manquante est le J

# --------------------------



#--------------------------------------------------------------------------------
#
# Procédures:
#   host-x <host>
#   host+x <host>
#
# NB: le host peut se composer avec l'identd ou sans
#
#--------------------------------------------------------------------------------

proc host-x { chaine } {
    set result ""
    if { [string range $chaine 0 [string first @ $chaine]] != "" } {
        lappend result [string range $chaine 0 [string first @ $chaine]]
    }
    lappend result [uncrypt [string range $chaine [expr [string first @ $chaine] + 1] [string length $chaine]]]
    set result [replace $result " " ""]
    return $result
}

proc host+x { chaine } {
    set result ""
    if { [string range $chaine 0 [string first @ $chaine]] != "" } {
        lappend result [string range $chaine 0 [string first @ $chaine]]
    }
    lappend result [crypt [string range $chaine [expr [string first @ $chaine] + 1] [string length $chaine]]]
    set result [replace $result " " ""]
    return $result
}



#--------------------------------------------------------------------------------
#
# Procédures de cryptage/décryptage
#
# - crypt <host> --> retourne le host en crypté
# - uncrypt <host> --> retourne le host en décrypté
#
#--------------------------------------------------------------------------------
proc crypt { chaine } {
    set a $chaine
    if { [is_ip_addr $a] } {
        set a [split $a .]
        set a [lreplace $a end end [crypt+x [lrange $a end end]]]
    } else {
        set a [split $a .]
        set a [lreplace $a 0 0 [crypt+x [lrange $a 0 0]]]
    }
    set result [join $a .]
    return $result
}

proc uncrypt { chaine } {
    set a $chaine
    if { [is_ip_addr $a] } {
        set a [split $a .]
        set a [lreplace $a end end [crypt-x [lrange $a end end]]]
    } else {
        if { [string index $a 0] == "." } {
            set a [split [string range $a 1 end] .]
            set a "H[lreplace $a 0 0 [crypt-x [lrange $a 0 0]]]"
        } else {
            set a [split $a .]
            set a [lreplace $a 0 0 [crypt-x [lrange $a 0 0]]]
        }
    }
    set result [join $a .]
    return $result
}

proc crypt+x { chaine } {
    set TmpCrypt ""
    set i 0
#    set xkey1 "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789"
#    set xkey2 "9nvfrgGjokZmwQ7-FyWMibxcuTEYVqRHhJCKLtXaPD12Ne6Sd5OlsA3B4UI8p0z"
    set xkey1 "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789"
    set xkey2 "9nvfrgGjokZmwQ7-FyWMibxcuTEYVqRHh.CKLtXaPD12Ne6Sd5OlsA3B4UI8p0z"
    while { $i < [string length $chaine] } {
        if { [string index $chaine $i] != "" } {
            set j 0
            set k 0
            while { $j < [string length $xkey1] && $k != 1 } {
                if { [string index $chaine $i] == [string index $xkey1 $j] } {
                    lappend TmpCrypt [string index $xkey2 $j]
                    set k 1
                }
                set j [expr $j + 1]
            }
            set i [expr $i + 1]
      }
    }
    regsub -all -- " " $TmpCrypt "" TmpCrypt
    return $TmpCrypt
}

proc crypt-x { chaine } {
    set TmpCrypt ""
    set i 0
#    set xkey2 "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789"
#    set xkey1 "9nvfrgGjokZmwQ7-FyWMibxcuTEYVqRHhJCKLtXaPD12Ne6Sd5OlsA3B4UI8p0z"
    set xkey2 "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789"
    set xkey1 "9nvfrgGjokZmwQ7-FyWMibxcuTEYVqRHh.CKLtXaPD12Ne6Sd5OlsA3B4UI8p0z"

    while { $i < [string length $chaine] } {
        if { [string index $chaine $i] != "" } {
            set j 0
            set k 0
            while { $j < [string length $xkey1] && $k != 1 } {
                if { [string index $chaine $i] == [string index $xkey1 $j] } {
                    lappend TmpCrypt [string index $xkey2 $j]
                    set k 1
                }
                set j [expr $j + 1]
            }
            set i [expr $i + 1]
      }
    }
    regsub -all -- " " $TmpCrypt "" TmpCrypt
    return $TmpCrypt
}
