*! China mirror of SSC 
*! version 1.07a
*! Update: 20210616
*! Codes from -ssc.ado- have been incorporated

* 2021/6/12 10:15       add cnssc get
*                       view file [lall]
* 2021/6/16 09:45       add cnssc install pkg, lianxh // lianxh option 

program define cnssc, rclass
	version 11
	gettoken cmd 0 : 0, parse(" ,")

    local update = 20210604        //current version 

	di as txt "" _c		/* work around for net display problem */

    *-check update
    preserve
        local from "https://file.lianxh.cn/StataCMD/_update"
        use "`from'/cnssc_update.dta", clear 
        local lversion: dis update[1]
        *dis "`lversion'" 
        if "`update'" != "`lversion'"{
            di as txt "NOTE: Do you like to update {bf:cnssc} package to new version {bf:`lversion'} ?" 
            di as txt "      (type/click {stata cnssc install cnssc, replace} to update)" _n
        }
    restore

    *-blank
	if `"`cmd'"'=="" {
		di as txt "cnssc commands are"
 		di as txt "    {cmd:cnssc new}"
 		di as txt "    {cmd:cnssc hot}"
		di
		di as txt "    {cmd:cnssc describe}  {it:pkgname}"
 		di as txt "    {cmd:cnssc describe}  {it:letter}"
		di
		di as txt "    {cmd:cnssc install}   {it:pkgname}"
		di as txt "    {cmd:cnssc uninstall} {it:pkgname}"
		di 
		di as txt "    {cmd:cnssc get}  {it:pkgname}"	 /* New, 2021.6.8 */
		di
		di as txt "    {cmd:cnssc type}      {it:filename}  (less used)"
		di as txt "    {cmd:cnssc copy}      {it:filename}  (less used)"
        di
		di as txt "see help {help cnssc:cnssc}"
        di
		exit //198
	}


	local l = length(`"`cmd'"')
	if `"`cmd'"' == bsubstr("update",1,max(4,`l')) {
		ret scalar update = `update'
		exit
	}
	if `"`cmd'"' == bsubstr("whatsnew",1,max(4,`l')) {
		cnsscwhatsnew `0'
		exit
	}
	if `"`cmd'"' == "new" { 
		cnsscwhatsnew `0'
		exit
	}
	if `"`cmd'"' == bsubstr("whatshot",1,max(6,`l')) {
		ssc_whatshot `0'
		exit
	}
	if `"`cmd'"' == "hot" { 
		ssc_whatshot `0'
		exit
	}

* ssc describe
	if `"`cmd'"' == bsubstr("describe",1,max(1,`l')) {
        tokenize `"`0'"', parse(" ,")
	    local pkgname `1'
        if `"`pkgname'"' == "" {
		    di as err `"cnssc des: nothing found where package name expected"'
		    exit 198
	    }
        CheckSSCpkg `pkgname'     // Check whether the pkg exist in SSC 
        if s(isSSCpkg)=="1"{
            cnsscdescribe `0'     //  SSC package
        }
        else{
            dis as text `"Note: "`pkgname'" not found at SSC, now turn to {browse "https://www.lianxh.cn":lianxh.cn} server ..."'            
            CheckLXHpkg `pkgname'
            if s(isLXHpkg)=="1"{
                cndescribe_others `0' // other package, eg. Lianxh.cn, Github etc.
            }
            else{
	            pkgNotFound `pkgname'
		        exit 198
            }
        }
		exit
	}


* ssc install
	if `"`cmd'"' == bsubstr("install",1,max(1,`l')) {
        tokenize `"`0'"', parse(" ,")
	    local pkgname `1'
        if `"`pkgname'"' == "" {
		    di as err `"cnssc install: nothing found where package name expected"'
		    exit 198
	    }
        local lianxhOnly = strpos("`0'","li")>0  // Lianx.cn server only
        if `lianxhOnly' == 1{   
                CheckLXHpkg `pkgname'
                if s(isLXHpkg)=="1"{
                    dis as text `"Installing "`pkgname'" from {browse "https://www.lianxh.cn":lianxh.cn} server ..."'
                    cninstall_others `0' // other package
                }
                else{
                    CheckSSCpkg `pkgname'
                    if s(isSSCpkg)=="1"{
	                    di as err /*
*/`"cnssc: "`pkgname'" not found at {browse "https://www.lianxh.cn":lianxh.cn}."'
                        dis as txt `"to install `pkgname' from SSC, type {stata cnssc install `pkgname'}"'
		                exit 198
                    }  
                    else{
	                    di as err /*
*/`"cnssc: "`pkgname'" not found at SSC and {browse "https://www.lianxh.cn":lianxh.cn}, type {stata search `pkgname'}"'
		                exit 198
                    }
                }
        }    
        else{
            CheckSSCpkg `pkgname'
            if s(isSSCpkg)=="1"{
                cnsscinstall `0'     //  SSC package
            }
            else{
                dis as text `"Note: "`pkgname'" not found at SSC, now turn to {browse "https://www.lianxh.cn":lianxh.cn} server ..."'            
                CheckLXHpkg `pkgname'
                if s(isLXHpkg)=="1"{
                    cninstall_others `0' // other package
                }
                else{
	                pkgNotFound `pkgname'
		            exit 198
                }
            }
        }
		exit
	}

// uninstall 
// ---------	
	if `"`cmd'"' == "uninstall" {
		cnsscuninstall `0'
		exit
	}
	
	if `"`cmd'"'=="copy" | `"`cmd'"'=="cp" {
		cnssccopy `0'
		exit
	}

//  ssc get 
// ---------
	if `"`cmd'"' == bsubstr("get",1,max(3,`l')) {
        tokenize `"`0'"', parse(" ,")
	    local pkgname `1'
        if `"`pkgname'"' == "" {
		    di as err `"cnssc get: nothing found where package name expected"'
		    exit 198
	    }
        local lianxhOnly = strpos("`0'","li")>0  // Lianx.cn server only
        if `lianxhOnly' == 1{   
                CheckLXHpkg `pkgname'
                if s(isLXHpkg)=="1"{
                    dis as text `"Copying ancillary files of "`pkgname'" from {browse "https://www.lianxh.cn":lianxh.cn} server ..."'
                    cnget_others `0' // other package
                }
                else{
                    CheckSSCpkg `pkgname'
                    if s(isSSCpkg)=="1"{
	                    di as err /*
*/`"cnssc: "`pkgname'" not found at {browse "https://www.lianxh.cn":lianxh.cn}."'
                        dis as txt `"to get files from SSC, type {stata cnssc get `pkgname'}"'
		                exit 198
                    }  
                    else{
	                    di as err /*
*/`"cnssc: "`pkgname'" not found at SSC and {browse "https://www.lianxh.cn":lianxh.cn}, type {stata search `pkgname'}"'
		                exit 198
                    }
                }
        }   
        else{
            CheckSSCpkg `pkgname'
            if s(isSSCpkg)=="1"{
                cnsscget `0'     //  SSC package
            }
            else{
                dis as text `"Note: "`pkgname'" not found at SSC, now turn to {browse "https://www.lianxh.cn":lianxh.cn} server ..."'            
                CheckLXHpkg `pkgname'
                if s(isLXHpkg)=="1"{
                    cnget_others `0' // other package
                }
                else{
	                pkgNotFound `pkgname'
		            exit 198
                }
            }
        }                
		exit
	}

// ssc type 
// ---------
	if `"`cmd'"'=="type" | `"`cmd'"'=="cat" {
		ssctype `0'
		exit
	}
	di as err `"ssc: `cmd': invalid subcommand"'
	exit 198
end


*===================================
*=========== SUB programs ==========
*===================================

program define cnsscwhatsnew
	syntax [, SAVing(string asis) TYPE]

	if `"`saving'"' != "" {
		ProcSaving `saving'
		local fn `"`r(fn)'"'
		local replace `"`r(replace)'"'
		SuffixFilename `"`fn'"'
		local fn `"`r(fn)'"'
		if "`replace'"!="" {
			capture erase "`fn'"
		}
		else {
			confirm new file "`fn'"
		}
	}
	else {
		local fn "ssc_results.smcl"
		capture erase "`fn'"
	}

	di in gr "(contacting http://repec.org)"
	copy http://repec.org/docs/smcl.php "`fn'", text 

	if "$S_CONSOLE"!="" | "`type'"!="" {
		type "`fn'"
	}
	else	view "`fn'", smcl
end
	


program define SuffixFilename, rclass
	args fn
	local lp = index("`fn'", ".")
	if index(`"`fn'"', ".")==0 {
		ret local fn `"`fn'.smcl"'
	}
	else	ret local fn `"`fn'"'
end
	
		

program define ProcSaving, rclass
	local saving `"`0'"'
	gettoken fn saving : saving, parse(" ,")
	gettoken comma saving : saving, parse(" ,")
	gettoken replace saving : saving, parse(" ,")
	gettoken nothing saving : saving, parse(" ,")

	if "`fn'"=="" {
		InvalidSaving `0'
	}
	ret local fn "`fn'"
	if "`comma'"=="" {
		exit
	}
	if "`comma'"!="," {
		InvalidSaving `0'
	}
	if "`replace'"!="replace" {
		InvalidSaving `0'
	}
	if "`nothing'"!="" {
		InvalidSaving `0'
	}
	ret local replace "replace"
end
	

program define InvalidSaving
	di as err `"saving(`0'):  invalid syntax"'
	exit 198
end
		

* ssc describe
program define cnsscdescribe
	* cnssc describe <package>|<ltr> [, saving(<filename>[,replace]) ]
	gettoken pkgname 0 : 0, parse(" ,")
	if length(`"`pkgname'"')==1 {
		local pkgname = lower(`"`pkgname'"')
		if !index("abcdefghijklmnopqrstuvwxyz_",`"`pkgname'"') {
			di as err "cnssc describe: letter must be a-z or _"
			exit 198
		}
	}
	else {
		CheckPkgname "cnssc describe" `"`pkgname'"'
		local pkgname `"`s(pkgname)'"'
	}
	syntax [, SAVING(string asis)]
	LogOutput `"`saving'"' cnsscdescribe_u `"`pkgname'"'
	if `"`s(loggedfn)'"' != "" {
		di as txt `"(output saved in `s(loggedfn)')"'
	}
end

program define cnsscdescribe_u
	args pkgname
	local ltr = bsubstr(`"`pkgname'"',1,1)
	if length(`"`pkgname'"')==1 {
		net from https://file.lianxh.cn/Scode/`ltr'
		di as txt /*
*/ "(type {cmd:cnssc describe} {it:pkgname} for more information on {it:pkgname})"
	}
	else {
			net describe `pkgname'
			di as txt /*
			*/ "(type/click {stata cnssc install `pkgname'} to install)"
            qui cnget_FileList `pkgname'
            if r(NumFiles)>0{
                di as txt /*
			    */ "(type/click {stata cnssc get `pkgname'} to get ancillary files)"
            }
	}
    exit
end


*-New: Packages not listed in SSC
*      but appears at Github, lianxh.cn and users' personal website
*      They are stored at:
*      https://file.lianxh.cn/StataCMD
program define cndescribe_others 
	gettoken pkgname 0 : 0, parse(" ,")
	qui net from https://file.lianxh.cn/StataCMD/`pkgname'
	net describe `pkgname'
	di as txt "(type/click {stata cnssc install `pkgname'} to install)"
    qui cnget_FileList `pkgname'
    if r(NumFiles)>0{
        di as txt /*
	    */ "(type/click {stata cnssc get `pkgname'} to get ancillary files)"
    }    
	exit
end


* cnssc install
program define cnsscinstall
	* cnssc install <package> [, <net_install_options>]
	gettoken pkgname 0 : 0, parse(" ,")
	CheckPkgname "cnssc install" `"`pkgname'"'
	local pkgname `"`s(pkgname)'"'
	syntax [, ALL REPLACE]
	local ltr = bsubstr("`pkgname'",1,1)
	qui net from https://file.lianxh.cn/Scode/`ltr'
	capture noi net install `pkgname', `all' `replace'
	local rc = _rc
	if _rc==601 | _rc==661 {
		di
		di as err /*
*/ `"{p}cnssc install: apparent error in package file for `pkgname'; please notify {browse "mailto:repec@repec.org":repec@repec.org}, providing package name{p_end}"'
	}
	if `rc'==0{
	    dis _col(4) `"{stata help `pkgname'}"'
        qui cnget_FileList `pkgname'
        if r(NumFiles)>0 & "`all'"==""{
            di as txt /*
	        */ "Note: `r(NumFiles)' ancillary files found, {stata cnssc des `pkgname':view}  {stata cnssc get `pkgname':get}"
        }         
	}
	exit `rc'
end


*-New: Packages not listed in SSC
*      but appears at Github, lianxh.cn and users' personal website
*      They are stored at:
*      https://file.lianxh.cn/StataCMD
* eg.
*   https://file.lianxh.cn/StataCMD/imusic/stata.toc      
program define cninstall_others
	* cnssc install <package> [, <net_install_options>]
	gettoken pkgname 0 : 0, parse(" ,")
	CheckPkgname "cnssc install" `"`pkgname'"'
	local pkgname `"`s(pkgname)'"'
	syntax [, ALL REPLACE LIanxh]
	*local ltr = bsubstr("`pkgname'",1,1)
	qui net from https://file.lianxh.cn/StataCMD/`pkgname'
	capture noi net install `pkgname', `all' `replace'
	local rc = _rc
	if `rc'==0{
	    dis _col(4) `"{stata help `pkgname'}"'
        qui cnget_FileList `pkgname'
        if r(NumFiles)>0 & "`all'"==""{
            di as txt /*
	        */ "Note: `r(NumFiles)' ancillary files found, {stata cnssc des `pkgname':view}  {stata cnssc get `pkgname':get}"
        }                 
	}	
	if _rc==601 | _rc==661 {
		di
		di as err /*
*/ `"{p}cnssc install: apparent error in package file for `pkgname'; please notify {browse "mailto:StataChina@163.com":StataChina@163.com}, providing package name{p_end}"'
	}
	exit `rc'
end


program define cnsscuninstall
	* cnssc uninstall <package>
	gettoken pkgname 0 : 0, parse(" ,")
	CheckPkgname "cnssc install" `"`pkgname'"'
	local pkgname `"`s(pkgname)'"'
	if trim(`"`0'"')!="" {
		exit 198
	}
	ado uninstall `pkgname'
end


program define cnssccopy
	* cnssc copy <filename> [, plus personal <copy_options>]
	*
	* backwards compatibility: sjplus and stbplus are synonyms for plus

	gettoken fn 0 : 0, parse(" ,")
	CheckFilename "cnssc copy" `"`fn'"'
	*local fn `"`s(fn)'"'                // otherwise, cnssc copy File.do will report error
	syntax [, PUBlic BINary REPLACE STBplus SJplus PLus Personal]

	local text = cond("`binary'"=="","text","")

	local op "stbplus"
	if "`sjplus'" != "" {
		local stbplus stbplus
		local op "sjplus"
	}
	if "`plus'" != "" {
		local stbplus stbplus
		local op "plus"
	}
	if "`stbplus'"!="" & "`personal'"!="" {
		di as err "may not specify both -`op'- and -personal- options"
		exit 198
	}
	local ltr = bsubstr(`"`fn'"',1,1)


	if "`stbplus'"!="" {
		local dir : sysdir STBPLUS
		local dirsep : dirsep
		local dir `"`dir'`ltr'`dirsep'"'
		local dfn `"`dir'`fn'"'
	}
	else if "`personal'" != "" {
		local dir : sysdir PERSONAL
		local dfn `"`dir'`fn'"'
	}
	else {
		local dir "current directory"
		local dfn `"`fn'"'
	}

	capture copy `"https://file.lianxh.cn/Scode/`ltr'/`fn'"' /*
		*/ `"`dfn'"' , `public' `text' `replace'
	local rc = _rc
	if _rc==601 | _rc==661 {
		di as err /*
	*/ `"cnssc copy: "`fn'" not found at SSC, type {stata search `fn'}"'
		exit `rc'
	}
	if _rc {
		error `rc'
	}
	di as txt "(file `fn' copied to `dir')"
end


*------------cnssc get pkgname -------NEW-2021/6/8 15:31
* cnssc get: Install ancillary files from a package
program define cnsscget
	* cnssc get <package> [, <net_get_options>]
	gettoken pkgname 0 : 0, parse(" ,")
	CheckPkgname "cnssc get" `"`pkgname'"'
	local pkgname `"`s(pkgname)'"'
	syntax [, ALL REPLACE FORCE]
	local ltr = bsubstr("`pkgname'",1,1)
    cnget_FileList `pkgname'
    if r(NumFiles) !=0{
        dis as txt `"copying into current directory ..."' 
    	qui net from https://file.lianxh.cn/Scode/`ltr'
    	capture noi net get `pkgname', `all' `replace' `force'   /*cap noi*/
    	local rc = _rc
    	if _rc==601 | _rc==661 {
    		di
    		di as err /*
    */ `"{p}cnssc get: apparent error in package file for `pkgname'; please notify {browse "mailto:repec@repec.org":repec@repec.org}, providing package name{p_end}"'
    	}
    	if `rc'==0{
            cnget_FileList `pkgname'
            ClickOutFile `"`r(Filelist)'"'
            dis as txt `"`r(NumFiles)' files successfully copied.  {browse `"`c(pwd)'"': dir}  {stata help `pkgname'}"' 
    	}
	}
    exit `rc'
end

*-New: This package is similar to -cninstall_others-
*      copy ancillary files of Packages not listed in SSC
*      but appears at Github, lianxh.cn and users' personal website
*      They are stored at:
*      https://file.lianxh.cn/StataCMD
* eg.
*   https://file.lianxh.cn/StataCMD/imusic/stata.toc      
program define cnget_others
	* cnssc get <package> [, <net_get_options>]
	gettoken pkgname 0 : 0, parse(" ,")
	CheckPkgname "cnssc get" `"`pkgname'"'
	local pkgname `"`s(pkgname)'"'
	syntax [, ALL REPLACE FORCE LIanxh]
	*local ltr = bsubstr("`pkgname'",1,1)
    cnget_FileList `pkgname'
    if r(NumFiles) !=0{
        dis as txt `"copying into current directory ..."' 
    	qui net from https://file.lianxh.cn/StataCMD/`pkgname'
    	capture noi net get `pkgname', `all' `replace' `force'   /*cap noi*/
    	local rc = _rc
    	if _rc==601 | _rc==661 {
    		di
    		di as err /*
*/ `"{p}cnssc get: apparent error in package file for `pkgname'; please notify {browse "mailto:StataChina@163.com":StataChina@163.com}, providing package name{p_end}"'
	}
    	if `rc'==0{
            cnget_FileList `pkgname'
            ClickOutFile `"`r(Filelist)'"'
            dis as txt `"`r(NumFiles)' files successfully copied.  {browse `"`c(pwd)'"': dir}  {stata help `pkgname'}"' 
    	}
	}
    exit `rc'
end


// ssn get filelist

program define cnget_FileList, rclass
    * cnget_FileList <package>
	* 1. copy pkgname.pkg
	* 2. get filelist other than .ado, .sthlp, and return to
    *    r(Filelist): files downloaded
	
    args pkgname

	local ltr = bsubstr(`"`pkgname'"',1,1)
	local fn "`pkgname'.pkg"
	cap confirm file "`fn'"
	local rc = _rc
	if _rc{
		capture copy `"https://file.lianxh.cn/Scode/`ltr'/`fn'"' .
        if _rc{
            capture copy `"https://file.lianxh.cn/StataCMD/`pkgname'/`fn'"' .
        }
	}
	
    preserve       /* preserve begin */
    qui{
  	    infix strL v 1-1000 using "`fn'", clear
  	    keep if substr(v,1,1)=="f"
  	    replace v = subinstr(v,"f ","",1)
		local unuseList ".ado .sthlp .hlp .toc .pkg .mlib .mata .mo .dlg .idlg .style .m .ihlp .plugin .style .scheme .mtx .mac .jar .win32 .win64 .class .prg .smcl .ico .c .def .dll .lin32 .lin64 .log .bmp .eps .gph"
		foreach type of local unuseList {
			drop if strpos(v,"`type'")
		}
		*-no ancillary files
		local N = _N
		if `N'==0{
			noi dis as txt "cnssc get: there is no ancillary files with `pkgname'"
			noi dis as txt /*
			*/ "(type/click {stata cnssc des `pkgname'} to check)"
			ret scalar NumFiles = `N'
			exit 
		}
  	    gen fn_reverse = strreverse(v)   //reverse folder/fn.suffix
  	    split fn_reverse, parse(/ \) limit(1)
		gen fn = strreverse(fn_reverse1)
		*keep fn 
    }
	global Filelist ""
	local N = _N
	forvalues i = 1/`N'{
	    local vs = fn[`i']
		global Filelist `"$Filelist `vs'"'
	}
    restore		    /* preserve over */
	
	ret local Filelist `"$Filelist"'
    ret scalar NumFiles = `N'
	if `rc'{
		qui erase `fn'
	}
	
end


program define ClickOutFile
	args Filelist
	tokenize `"`Filelist'"'
    local num 1
    while `"``num''"'~="" {
    	local cl_text `"{browse `"``num''"'}"'
    	noi di as txt _col(6) `"`cl_text'"'
    	local num=`num'+1
    }
end


// ssc type
program define ssctype
	gettoken fn 0 : 0, parse(" ,")
	syntax [, ASIS]
	CheckFilename "ssc type" `"`fn'"'
	local fn `"`s(fn)'"'
	local ltr = bsubstr(`"`fn'"',1,1)
	capture type `"https://file.lianxh.cn/Scode/`ltr'/`fn'"'
	local rc = _rc
	if _rc==601 | _rc==661 {
		di as err /*
	*/ `"ssc type: "`fn'" not found at SSC, type {stata search `fn'}"'
		exit `rc'
	}
	if _rc {
		error `rc'
	}
	type `"https://file.lianxh.cn/Scode/`ltr'/`fn'"', `asis'
end


// Check Pkg name
program define CheckPkgname, sclass
	args id pkgname
	sret clear
	if `"`pkgname'"' == "" {
		di as err `"`id': nothing found where package name expected"'
		exit 198
	}
	if length(`"`pkgname'"')==1 {
		di as err `"`id': "`pkgname'" invalid SSC/lianxh.cn package name"'
		exit 198
	}
	local pkgname = lower(`"`pkgname'"')
	if !index("abcdefghijklmnopqrstuvwxyz_",bsubstr(`"`pkgname'"',1,1)) {
		di as err `"`id': "`pkgname'" invalid SSC/lianxn.cn package name"'
		exit 198
	}
	sret local pkgname `"`pkgname'"'
end


// Check Filename
program define CheckFilename, sclass
	args id fn
	sret clear
	if `"`fn'"'=="" {
		di as err `"`id': nothing found where filename expected"'
		exit 198
	}
	if length(`"`fn'"')==1 {
		di as err `"`id': "`fn'" invalid SSC/lianxh.cn filename"'
		exit 198
	}
	local fn = lower(`"`fn'"')
	if !index("abcdefghijklmnopqrstuvwxyz_",bsubstr(`"`fn'"',1,1)) {
		di as err `"`id': "`fn'" invalid SSC/lianxh.cn filename"'
		exit 198
	}
	sret local fn `"`fn'"'
end

// Log Output
program define LogOutput, sclass
	gettoken saving 0 : 0

	sret clear
	ParseSaving `saving'
	local fn      `"`s(fn)'"'
	local replace  "`s(replace)'"
	sret clear

	if `"`fn'"'=="" {
		`0'
		exit
	}

	quietly log
	local logtype   `"`r(type)'"'
	local logstatus `"`r(status)'"'
	local logfn     `"`r(filename)'"'

	nobreak {
		if `"`logtype'"' != "" {
			qui log close
		}
		capture break {
			capture log using `"`fn'"' , `replace'
			if _rc {
				noisily log using `"`fn'"', `replace'
				/*NOTREACHED*/
			}
			local loggedfn `"`r(filename)'"'
			noisily `0'
		}
		local rc = _rc
		capture log close
		if "`logtype'" != "" {
			qui log using `"`logfn'"', append `logtype'
			if "`logstatus'" != "on" {
				qui log off
			}
		}
	}
	sret local loggedfn `"`loggedfn'"'
	exit `rc'
end


program define ParseSaving, sclass
	* fn[,replace]
	sret clear
	if `"`0'"' == "" {
		exit
	}
	gettoken fn      0 : 0, parse(", ")
	gettoken comma   0 : 0
	gettoken replace 0 : 0

	if `"`fn'"'!="" & `"`0'"'=="" {
		if `"`comma'"'=="" | (`"`comma'"'=="," & `"`replace'"'=="") {
			sret local fn `"`fn'"'
			exit
		}
		if `"`comma'"'=="," & `"`replace'"'=="replace" {
			sret local fn `"`fn'"'
			sret local replace "replace"
			exit
		}
	}
	di as err "option saving() misspecified"
	exit 198
end


// package not found
program define pkgNotFound
	args pkgname
    local ltr = bsubstr("`pkgname'",1,1)
	di as err /*
*/`"cnssc: "`pkgname'" not found at SSC and {browse "https://www.lianxh.cn":lianxh.cn}, type {stata search `pkgname'}"'
	di as err /*
*/ "(To find all packages at SSC that start with `ltr', type {stata cnssc describe `ltr'})"    
end


*======CheckSSCpkg
*-New 2021/6/9 14:21
*-to check whether a pckage is listed in [SSC]  
program define CheckSSCpkg, sclass
	args pkgname
	sret clear
    if length(`"`pkgname'"')==1 {
        sret local isSSCpkg = 1
        exit
    }
	local ltr = bsubstr(`"`pkgname'"',1,1)
	qui net from https://file.lianxh.cn/Scode/`ltr'
	capture net describe `pkgname'
	if _rc==0 {
		sret local isSSCpkg = 1
	}
    else {
        sret local isSSCpkg = 0
        *dis as error `"`pkgname' is not found at SSC."'
        *exit 198
    }
	sret local pkgname `"`pkgname'"'
end

*======CheckLXHpkg
*-New 2021/6/9 14:43
*-to check whether a pckage is listed in [lianxh.cn server] 
program define CheckLXHpkg, sclass
    args pkgname
	sret clear
	cap qui net from https://file.lianxh.cn/StataCMD/`pkgname'
    if _rc{
        sret local isLXHpkg = 0
        *exit 198   
    }
    else{
  	    capture net describe `pkgname'
	    if _rc==0 {
		    sret local isLXHpkg = 1
	    }
        else {
            sret local isLXHpkg = 0
            *dis as error `"`pkgname' is not found at [lianixh.cn]"'
            *exit 198        
        }
    }
	sret local pkgname `"`pkgname'"'
end
