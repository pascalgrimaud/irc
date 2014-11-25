#
# bio.tcl
#

putlog "\002bio.tcl\002"

bind dcc - bio bio:lin

proc bio:lin { hand idx arg } {
# A = U
# T = A
# C = G
# G = C
  set arg [string toupper $arg]
  set argsave $arg
  regsub -all "A" $arg "U" arg
  regsub -all "T" $arg "A" arg
  regsub -all "C" $arg "1" arg
  regsub -all "G" $arg "2" arg
  regsub -all "1" $arg "G" arg
  regsub -all "2" $arg "C" arg
  putdcc $idx "\002BIO\002: $argsave"
  putdcc $idx "\002BIO\002: $arg"
  return 1
}
