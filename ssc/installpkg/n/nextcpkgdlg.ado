
program define nextcpkgdlg

syntax, [CINST]

if "`cinst'"!=""{
	global reinstall 0
	global reinstallforce 0

	if strpos("$file_path_rnew","replace") global reinstall=1
	if strpos("$file_path_rnew","force")   global reinstallforce=1

	db createpkg 

}
else{

	di "no pkg information created, installation exits..."
}


end
