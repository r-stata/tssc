*! version 2.1.1 21may2018 daniel klein
program pathutil , sclass
	version 11.2
	
	gettoken subcmd 0 : 0
	if (!inlist(`"`subcmd'"', 	///
		"split", 				///
		"pieces", 				///
		"of", 					///
		"to", /// is synonym for of
		"join", 				///
		"confirm")) 			///
	{
		sreturn clear
		display as err `"invalid subcommand `subcmd'"'
		exit 198
	}
	
	if ("`subcmd'" == "to") {
		local subcmd of
	}
	
	if ("`subcmd'" == "confirm") {
		gettoken what : 0 , qed(quotes)
		if (!`quotes') {
			path_confirm_what , `what'
		}
		else {
			local what // void
		}
		if (`"`what'"' != "") {
			gettoken dump 0 : 0
		}
	}
	else {
		sreturn clear
	}
	
	gettoken path 0 : 0 , qed(quotes)
	if mi(`"`path'"') {
		if ("`subcmd'" == "confirm") {
			local rc 7
		}
		else {
			local rc = ((!`quotes') * ("`subcmd'" != "of") * 198)
		}
		path_expected `rc'
	}
	
	if ("`subcmd'" == "join") {
		gettoken path2 0 : 0 , qed(quotes)
		local rc = (((!`quotes') & mi(`"`path2'"')) * 198)
		path_expected `rc'
	}
	
	gettoken void : 0
	if (`"`void'"' != "") {
		display as err `"invalid `void'"'
		exit 198
	}
	
	mata : path`subcmd'_ado()
end

program path_confirm_what
	version 11.2
	
	capture syntax 	///
	[ , 			///
		NEW 		///
		URL 		///
		ISURL 		/// not documented
		ABSolute 	///
		ISABSolute 	/// not documented
		* 	/// rest
	]
	
	if ("`new'" != "") {
		local what new
	}
	else if ("`url'`isurl'" != "") {
		local what url
	}
	else if ("`absolute'`isabsolute'" != "") {
		local what abs
	}
	
	c_local what : copy local what
end

program path_expected
	version 11.2
	args rc
	if (!`rc') {
		exit 0
	}
	display as err "'' found where path expected"
	exit `rc'
end

version 11.2
set matastrict on

mata :

void pathsplit_ado()
{
	string scalar path, directory, filename, suffix
	
	path 	= st_local("path")
	suffix 	= pathsuffix(path)
	path 	= pathrmsuffix(path)
	
	if ((filename = pathbasename(path)) == "") {
		directory = path
	}
	else {
		pragma unset directory
		pathsplit(path, directory, filename)
	}
	
	st_global("s(directory)", directory)
	st_global("s(suffix)", suffix)
	st_global("s(extension)", suffix)
	st_global("s(filename)", filename)
}

void pathpieces_ado()
{
	string scalar path, piece
	real scalar i
	
	path = st_local("path")
	
	pragma unset piece
	
	i = 0
	while (path != "") {
		pathsplit(path, path, piece)
		if (anyof(("/", "\"), piece)) {
			continue
		}
		st_global("s(piece" + strofreal(++i) + ")", piece)
	}
	
	st_global("s(pieces)", strofreal(i))
}

void pathof_ado()
{
	string scalar path, pwd, piece
	
	path 	= st_local("path")
	pwd 	= c("pwd")
	
	pragma unset piece
	
	while (pwd != "") {
		pathsplit(pwd, pwd, piece)
		if (anyof((piece, pwd), path)) {
			st_global("s(path)", pathjoin(pwd, piece))
			return
		}
	}
	
	errprintf("%s not found in current working directory\n", path)
	exit(601)
}

void pathjoin_ado()
{
	st_global("s(path)", pathjoin(st_local("path"), st_local("path2")))
}

void pathconfirm_ado()
{
	string scalar path, what, msg
	real scalar rc
	
	path = st_local("path")
	what = st_local("what")
	
	if (anyof(("", "new"), what)) {
		if (pathsuffix(path) != "") {
			rc 	= 698
			msg = sprintf("%s not a directory\n", path)
		}
		else if (what == "") {
			rc 	= direxists(path) ? 0 : 601
			msg = sprintf("directory %s not found\n", path)
		}
		else if (what == "new") {
			rc 	= direxists(path) ? 602 : 0
			msg = sprintf("directory %s already exists\n", path)
		}
		else {
			// this should not happen
			rc 	= 9
			msg = "internal error\n"
		}
	}
	else if (what == "url") {
		rc 	= pathisurl(path) ? 0 : 669
		msg = sprintf("%s not URL\n", path)
	}
	else if (what == "abs") {
		rc 	= pathisabs(path) ? 0 : 698
		msg = sprintf("%s not absolute path\n", path)
	}
	else {
		// this should not happen
		rc 	= 9
		msg = "internal error\n"
	}
	
	if (rc) {
		errprintf(msg)
	}
	
	exit(rc)
}

end
exit

2.1.1	21may2018	renamed pathutil
					code polish
2.1.0	03aug2016	new subcommands pieces and of
2.0.0	03aug2016	improved code subcommand split
					omitting path is now an error
					new subcommand confirm (nclass)
					released on SSC
1.0.0	06apr2016	initial version (not released)
