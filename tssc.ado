*! Install Stata modules from RStata Statistical Software Components Archive 
*! 微信公众号：RStata
*! 14 May 2020
*! version 0.0.0.9999
program define tssc
	version 7
	gettoken cmd 0 : 0, parse(" ,")
	if `"`cmd'"'=="" {
		di as txt "tssc commands are"
		di as txt "    {cmd:tssc list}"
		di 
		di as txt "    {cmd:tssc install}   {it:pkgname}"
		di 
		di as txt "see help {help tssc##|_new:tssc}"
		exit 198
	}

	if `"`cmd'"' == "list" {
		tssclist
		exit
	}
	if `"`cmd'"' == "install" {
		tsscinstall `0'
		exit
	}
	di as err `"tssc: `cmd': invalid subcommand"'
	exit 198
end

program define tssclist
	di as txt `"{browse "https://r-stata.github.io/tssc/cmdlist.html": tssc Stata Modules List}"'
end 

program define tsscinstall
	* tssc install <package> [, <net_install_options>]
	gettoken pkgname 0 : 0, parse(" ,")
	CheckPkgname "tssc install" `"`pkgname'"'
	local pkgname `"`s(pkgname)'"'
	syntax [, ALL REPLACE]
	di as txt "Trying to install `pkgname' from GitHub ..."
	qui cap net install `pkgname'.pkg, from("https://r-stata.github.io/tssc/ssc/`pkgname'/") `all' `replace'
	local rc _rc
	if _rc != 0 {
		di as err `"Failed!"'
		exit `rc'
	}
	if _rc == 0 {
		di in green "Succeeded!"
	}
end

program define CheckPkgname, sclass
	args id pkgname
	sret clear
	if `"`pkgname'"' == "" {
		di as err `"`id': nothing found where package name expected"'
		exit 198
	}
	if length(`"`pkgname'"') == 1 {
		di as err `"`id': "`pkgname'" invalid tssc package name"'
		exit 198
	}
	local pkgname = lower(`"`pkgname'"')
	if !index("abcdefghijklmnopqrstuvwxyz_", bsubstr(`"`pkgname'"',1,1)) {
		di as err `"`id': "`pkgname'" invalid tssc package name"'
		exit 198
	}
	sret local pkgname `"`pkgname'"'
end
