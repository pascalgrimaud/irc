#
# Xconsole.tcl by <ibu_lordaeron@yahoo.fr>
#

putlog "Xconsole.tcl par <ibu_lordaeron@yahoo.fr> --> .xconsole"

bind dcc -|- xconsole xconsole

proc xconsole { hand idx arg } {
    if { $arg != "" } {
        if { ( [string index $arg 1] == "1" || [string index $arg 1] == "2" || [string index $arg 1] == "3" || [string index $arg 1] == "4" || [string index $arg 1] == "5" || [string index $arg 1] == "6" || [string index $arg 1] == "7" || [string index $arg 1] == "8" ) && ( [string index $arg 2] == "" ) } {
            if { [string index $arg 0] == "-" } {
                console $idx [lindex [console $idx] 1]-[string index $arg 1]
            } else {
                if { [string index $arg 0] == "+" } {
                    console $idx [lindex [console $idx] 1][string index $arg 1]
                } else {
                    putdcc $idx "Usage: .xconsole <-/+><1,2,3,4,5,6,7 ou 8>"
                    return 0
                }
            }
            putdcc $idx "Your console is [lindex [console $idx] 0]: [lindex [console $idx] 1]"
            return 1
        } else {
            putdcc $idx "Usage: .xconsole <-/+><1,2,3,4,5,6,7 ou 8>"
            return 0
        }
    } else {
        putdcc $idx " "
        putdcc $idx "     Xconsole - Help     "
        putdcc $idx " "
        putdcc $idx "  Ce script permet de modifier les consoles 1 à 8"
        putdcc $idx "  sans obligation d'être Master du Robot"
        putdcc $idx " "
        putdcc $idx " .xconsole <-/+><1,2,3,4,5,6,7 ou 8>"
        putdcc $idx " "
        putdcc $idx " "
        return 1
    }
}