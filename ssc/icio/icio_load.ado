
*! version 1.2.4  27may2020
*! author: Federico Belotti, Michele Mancini and Alessandro Borin
*! see end of file for version comments

program define icio_load, sclass
    syntax, [ICIOTable(string) Year(string) INFO ]

version 11

*** This is for us: Set this to 0 for distributed version
loc working_version 0

*** Get the right sysdir
loc sysdir_plus `"`c(sysdir_plus)'i/"'

*** Parsing iciotable() suboptions
gettoken iciotable opt_iciotable: iciotable, parse(",")
local iciotable = rtrim(ltrim("`iciotable'"))
local opt_iciotable = rtrim(ltrim(regexr(`"`opt_iciotable'"', ",", "")))

*** Parsing ICIOTable
ParseICIOTable iciotable : `"`iciotable'"'
if `"`opt_iciotable'"'!="" {
	ParseICIOTableUser, `opt_iciotable'
	loc user_defi_table 1
}
else loc user_defi_table 0

if "`iciotable'"=="tivao" & "`year'"=="" loc year 2011
if "`iciotable'"=="tivan" & "`year'"=="" loc year 2015
if "`iciotable'"=="wiodo" & "`year'"=="" loc year 2011
if "`iciotable'"=="wiodn" & "`year'"=="" loc year 2014
if "`iciotable'"=="eora" & "`year'"=="" loc year 2015
if "`iciotable'"=="adb" & "`year'"=="" loc year 2018

// Here we need to create an ado file for icio_table_releases
// Brute force fix: just copy and past the content of icio_table_releases.do below
*qui include "`path4include'/icio_table_releases.do"
/* TIVA OLD */
local tivao "2016"
/* TIVA NEW */
local tivan "2018"
/* WIOD OLD */
local wiodo "2013"
/* WIOD NEW */
local wiodn "2016"
/* EORA */
local eora "199.82"
local eora_rel "199.82"
/* ADB */
local adb "2019"
local adb_rel "2019"

// Here display the table releases and exit
if "`info'"!="" {
qui {
	mat _tab_rels = `wiodn', 2000, 2014 \ `tivan', 2005, 2015 \ `eora' , 1990, 2015 \ `adb', 2000, 2018 \ `wiodo', 1995, 2011 \ `tivao', 1995, 2011
	mat rownames _tab_rels = "wiodn" "tivan" "eora" "adb" "wiodo" "tivao"
	mat colnames _tab_rels = "version" "from" "to"
	noi matlist _tab_rels, row(table_name) cspec(|%5s|%9.0g|%9.0g|%9.0g|) rspec(--&&&&&-)
	cap mat drop _tab_rels
	sret clear
	exit
}

}


if "`iciotable'" == "wiodn" local filename "icio_`wiodn'_wiod"
if "`iciotable'" == "wiodo" local filename "icio_`wiodo'_wiod"
if "`iciotable'" == "tivan" local filename "icio_`tivan'_tiva"
if "`iciotable'" == "tivao" local filename "icio_`tivao'_tiva"
if "`iciotable'" == "eora" local filename "icio_eora"
if "`iciotable'" == "adb" local filename "icio_adb"


*** Check if year has 4 digits
if "`user_defi_table'"=="0" {
	loc check_year = length("`year'")
	if "`check_year'"!="4" {
		di as error "-year()- incorrectly specified. It must be yyyy, e.g. 2011."
		exit 198
	}
}

*** Parsing year for finding files (keep only the last 2 digits)
local yy = substr("`year'",3,2)

if `user_defi_table'==0 {
	*** Check if the specified year is in the list
	if "`iciotable'" == "wiodn" & (`year'<2000 | `year'>2014) {
		di as error "Year `year' is not available for the WIOD `wiodn' release."
		error 198
	}
	if "`iciotable'" == "wiodo" & (`year'<1995 | `year'>2011) {
		di as error "Year `year' is not available for the WIOD `wiodo' release."
		error 198
	}
	if "`iciotable'" == "tivan" & (`year'<2005 | `year'>2015) {
		di as error "Year `year' is not available for the TiVA `tivan' release."
		error 198
	}
	if "`iciotable'" == "tivao" & (`year'<1995 | `year'>2011) {
		di as error "Year `year' is not available for the TiVA `tivao' release."
		error 198
	}
	if "`iciotable'" == "eora" & (`year'<1990 | `year'>2015) {
		di as error "Year `year' is not available for the EORA `eora' release."
		error 198
	}
	if "`iciotable'" == "adb" & inlist("`year'","2000","2007","2008","2009","2010","2011","2012")==0 & inlist("`year'","2013","2014","2015","2016","2017","2018")==0 {
		di as error "Year `year' is not available for the ADB `adb' release."
		error 198
	}
}

*** Load country list
preserve
if regexm("`iciotable'","^wi") {
	if "`iciotable'" == "wiodo" local wiod_rel `wiodo'
	if "`iciotable'" == "wiodn" local wiod_rel `wiodn'
	cap findfile wiod_`wiod_rel'_countrylist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
	if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/wiod
		qui insheet using "http://www.tradeconomics.com/icio/data/`iciotable'/wiod_`wiod_rel'_countrylist.csv", c clear
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using `"`path4save'/wiod_`wiod_rel'_countrylist.csv"', c nonames noquote
	}
	else {
		qui insheet using `"`r(fn)'"', c clear
	}
	qui levelsof v1, l(wiod_`wiod_rel'_countrylist) clean
	qui putmata _countryacr=v1 _areeacr=v1, replace
}
if regexm("`iciotable'","^ti") {
	if "`iciotable'" == "tivao" local tiva_rel `tivao'
	if "`iciotable'" == "tivan" local tiva_rel `tivan'
	cap findfile tiva_`tiva_rel'_countrylist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
		if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/tiva
		qui insheet using "http://www.tradeconomics.com/icio/data/`iciotable'/tiva_`tiva_rel'_countrylist.csv", c clear
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using "`path4save'/tiva_`tiva_rel'_countrylist.csv", c nonames noquote
	}
	else {
		qui insheet using `"`r(fn)'"', c clear
	}
	qui levelsof v2, l(tiva_`tiva_rel'_countrylist) clean
	qui putmata _countryacr=v1 _areeacr=v2, replace
}
if "`iciotable'"=="eora" {
	cap findfile eora_countrylist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
		if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/eora
		qui insheet using "http://www.tradeconomics.com/icio/data/`iciotable'/eora_countrylist.csv", c clear
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using "`path4save'/eora_countrylist.csv", c nonames noquote
	}
	else {
		qui insheet using `"`r(fn)'"', c clear
	}
	qui levelsof v1, l(eora_countrylist) clean
	qui putmata _countryacr=v1 _areeacr=v1, replace
}
if "`iciotable'"=="adb" {
	cap findfile adb_countrylist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
		if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/adb
		qui insheet using "http://www.tradeconomics.com/icio/data/`iciotable'/adb_countrylist.csv", c clear
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using "`path4save'/adb_countrylist.csv", c nonames noquote
	}
	else {
		qui insheet using `"`r(fn)'"', c clear
	}
	qui levelsof v1, l(adb_countrylist) clean
	qui putmata _countryacr=v1 _areeacr=v1, replace
}
if "`iciotable'"=="user" {
	qui insheet using `"`s(icioclist_user)'"', c clear
	qui ds, has(type str#)
	loc wc: word count `r(varlist)'
	if `wc'> 2 {
		di as error "The country list file `s(icioclistname_user)' has more than 2 columns."
		exit 198
	}
    loc var1: word 1 of `r(varlist)'
	loc var2: word 2 of `r(varlist)'
	if "`var1'"!="" & "`var2'"=="" {
		qui levelsof `var1', l(user_countrylist) clean
		qui putmata _countryacr=`var1' _areeacr=`var1', replace
	}
	else if "`var1'"!="" & "`var2'"!="" {
		qui levelsof `var2', l(user_countrylist) clean
		qui putmata _countryacr=`var1' _areeacr=`var2', replace
	}
}
restore

if `user_defi_table'==0 {
	cap findfile `filename'`yy'.mmat , path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
	if _rc {
		noi di as result "Download `iciotable' `year' table..."
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		copy "http://www.tradeconomics.com/icio/data/`iciotable'/`filename'`yy'.mmat.zip" "`path4save'/"
		loc getwd2reset "`c(pwd)'"
		qui cd "`path4save'"
		cap unzipfile "`filename'`yy'.mmat.zip"
		qui cd "`getwd2reset'"
		erase "`path4save'/`filename'`yy'.mmat.zip"
		//noi di as text "`iciotable' `year' table loaded."
		m __fh = fopen(`"`path4save'/`filename'`yy'.mmat"', "r")
		m io = fgetmatrix(__fh)
		m fclose(__fh)
		if "`c(os)'" != "MacOSX" cap rmdir "`path4save'/__MACOSX"

	}
	else {
		m __fh = fopen(`"`r(fn)'"', "r")
		m io = fgetmatrix(__fh)
		m fclose(__fh)
		//noi di as text "Loading table `iciotable' `year'...", _cont
	}
}
else if `user_defi_table'==1 {


/* check why _icio_insheet fails
the following fails because the eora file is too characters long.
The only solution is to interact with the OS
*/

/*
	! awk '{ print length($0); }' `s(iciotable_user)' > butta.txt

	capture noi mata: io = strtoreal(_icio_insheet(`"`s(iciotable_user)'"', ",",1,3))
	mata: rows(io),cols(io)


	if _rc == 0 noi di as result `"`s(iciotable_user)'"' as text " loaded"
	else {
		noi di as result `"`s(iciotable_user)'"' as error " not loaded"
		noi di as error "Check the path, the name and the format of the table."
		error 198
	}
	m _editmissing(io, 0)

*/

	preserve
	cap qui insheet using `"`s(iciotable_user)'"', c clear
	if _rc == 0 noi di as result `"Loading `s(iciotable_user)'..."', _cont
	else {
		noi di as result `"`s(iciotable_user)'"' as error " not loaded"
		noi di as error "Check the path, the name and the format of the table."
		error 198
	}

	qui ds
	loc allvars  "`r(varlist)'"
	m io = st_data(., st_local("allvars"))
	// check for missing vales and recode them = 0
	m _editmissing(io, 0)
	//m rows(io),cols(io)
	restore
}

// Fix parsing after the update on the possibility to use different versions of tiva and wiod
if inlist("`iciotable'", "wiodn", "wiodo") local iciotable "wiod"
if inlist("`iciotable'", "tivan", "tivao") local iciotable "tiva"

// This adds table release into the structure _in passing through the _icio_load() function
if inlist("`iciotable'", "tiva") local _trel "`tiva_rel'"
if inlist("`iciotable'", "wiod") local _trel "`wiod_rel'"
if inlist("`iciotable'", "eora") local _trel "`eora_rel'"
if inlist("`iciotable'", "adb") local _trel "`adb_rel'"

if "`iciotable'"!="user" {
	if inlist("`iciotable'", "wiod") local _countrylist "`wiod_`wiod_rel'_countrylist'"
	if inlist("`iciotable'", "tiva") local _countrylist "`tiva_`tiva_rel'_countrylist'"
	if inlist("`iciotable'", "eora") local _countrylist "`eora_countrylist'"
	if inlist("`iciotable'", "adb") local _countrylist "`adb_countrylist'"
}
else local _countrylist "`user_countrylist'"

if `user_defi_table'==0 di as text "Loading table `iciotable' `year'...", _cont
m _icio_in_ = _icio_load(io, _countryacr, "`iciotable'", "`_trel'", "`year'", "`_countrylist'", "`s(icioclist_user)'")
di in yel " loaded"
** get number of countries and sectors
m st_local("_icio_nr_countries", strofreal(_icio_in_.nr_pae))
m st_local("_icio_nr_sectors", strofreal(_icio_in_.nr_sett))

loc mobjlist io __fh _areeacr _countryacr
foreach mo of local mobjlist {
	cap m mata drop `mo'
}


end



/* ----------------------------------------------------------------- */

program define ParseICIOTable
	args returmac colon table

	local 0 ", `table'"
	syntax [, WIODO WIODN TIVAO TIVAN EORA ADB USER]

	local wc : word count `wiodo' `wiodn' `tivao' `tivan' `eora' `adb' `user'

	if `wc' > 1 {
		di as error "iciotable() invalid, only " /*
			*/ "one table type can be specified"
		exit 198
	}
	if `wc' == 0 {
		c_local `returmac' wiodn
	}
	else {
		if ("`wiodn'"=="wiodn") local iotable wiodn
		if ("`tivan'"=="tivan") local iotable tivan
		if ("`wiodo'"=="wiodo") local iotable wiodo
		if ("`tivao'"=="tivao") local iotable tivao
		if ("`eora'"=="eora") local iotable eora
		if ("`adb'"=="adb") local iotable adb
		if ("`user'"=="user") local iotable user
		c_local `returmac' `iotable'
	}

end


program define ParseICIOTableUser, sclass
	syntax, USERPath(string) TABLEName(string) COUNTRYListname(string)

	loc tablename = regexr("`tablename'",".csv$","")
	loc countrylistname = regexr("`countrylistname'",".csv$","")

	** check for double slash
	loc iciotable_user = subinstr(`"`userpath'/`tablename'.csv"',"//","/",.)
	loc icioclist_user = subinstr(`"`userpath'/`countrylistname'.csv"',"//","/",.)

	sreturn local iciotable `"`tablename'"'
	sreturn local iciotable_user `"`iciotable_user'"'
	sreturn local icioclist_user `"`icioclist_user'"'
	sreturn local icioclistname_user `"`countrylistname'.csv"'


end


/**** Versioning

* version 1.0.0  25mar2016 - First version
* version 1.0.1  10jun2017 - Country list loaded here now
* version 1.0.2  13sep2017 - User defined table can now be loaded
* version 1.1.0  23oct2017 - Country list is now endogenized and is loaded by the ado to parse the origin() destination() exporter() and importer() options
* version 1.1.1  4dec2018 - Fixed a bug preventing to load tables correctly
* version 1.1.2  23feb2019 - Fixed a bug preventing to load user-provided tables correctly
* version 1.2.0  1aug2019 - This version allows for two different releases of "wiod" and "tiva" and add "eora" as a new preloaded iotable in icio
* version 1.2.1  2aug2019 - Now _icio_load() has three arguments. this allows to transform eora in millions from the beginning
* version 1.2.2  10sep2019 - Fixed a bug preventing the download and load of the variuos vintages
* version 1.2.3  2oct2019 - Added -info- option and updated to work with tradeconomics.com
* version 1.2.4  27may2020 - Added ADB tables

*/
