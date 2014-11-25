#
# Sendftp-Win v1.0 (5-Oct-2000) by Ernst <ernst@baschny.de>
# Ernst's eggdrop page:  http://www.baschny.de/eggdrop/
# =============================================================================

# !!! This is the Windows version of sendftp !!!

# Configure here the full path of your FTP.EXE program:
set progftp "C:/Windows/ftp.exe"

# This is a proc to send a file via FTP to another server. Useful in many
# situations, for example to upload a HTML file generated by eggdrop to your
# www server if it is not the same as your eggdrops machine.

# Include it with 'source scripts/sendftp.tcl'.  Call it with all parameters:
#
#   sendftp <localfile> <server> <user> <password> <remotefile>
#
# 'localfile' and 'remotefile' *must* both be given as FULL paths to the
# filenames, the first on the local, the second	on the remote server.
#
# For example:
#
# sendftp /home/bill/stats.htm www.ms.com bill secret /bgates/WWW/stats.htm
#             (local-file       server    user  pass       remote-file)


proc sendftp { localfile server user pass remotefile } {
	global progftp
	if {![file exist $localfile]} {
		return "sendftp: File $localfile does not exist."
	}
	set pipe [open "|$progftp -n $server" w]
	puts $pipe "user $user $pass"
	puts $pipe "bin"
	puts $pipe "put $localfile $remotefile"
	puts $pipe "quit"
	close $pipe
	return 1
}
