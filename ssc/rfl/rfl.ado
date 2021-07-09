* rfl.ado version 3.6, 29 Nov 2005, Dankwart Plattner,  dankwart.plattner@web.de
*! Keywords: file management; file open; recent files list; data file handling; dialog

program rfl
version 8.2
args test

// Reads rfl.log, deletes entries marked for deletion, renames entries marked for renaming
// Builts *.idlg files to fill the combo boxes in the dialog window

// Structure of rfl.log
// Line 1-15: general settings,
// Line 1: version
//	Line 2: hidemenu (default 0)
// Line 3: rewrite menu (default 0)
// Line 4: entries in recent file list (default 9)
// Line 5: Always load last log, if called from menu or from rfluse (default 1)
// Line 6: cmdlog selection follows log selection (default 1)
// Line 7: replace log (default 0)
// Line 8: replace cmdlog (default 0)
// Line 9: don't warn before replacing log and cmdlog (default 0)
// Line 10: Minimum memory allocated to Stata when opening a data file (default 10)
// Line 11: Maximum memory allocated to Stata when opening a data file (default 450)
// Line 12: multiply file size by this factor (default 1.5 [=15 in the dialog control)]
// Line 13: make backup of log files before overwriting (default 0)
// Line 14: Number of cmdlog commands from last log to push into review window
// Lines 15: empty

// then for the entries:
// Line 1: How many times opened
// Line 2: Last opened (5 last, 4 last but one, etc.)
// Line 3: short data file name
// Line 4: long data file name
// Line 5: long cmdlog file name
// Line 6: long log file name
// Line 7: short description
// Line 8: long description
// Lines 9-13: empty
// Line 14: newdta long
// Line 15: 1 to be deleted 2 to be renamed, 0 otherwise

local dtanum 0
local rewritelog 0
local renamelog 0
local korr 0
local maxleninlist 80
local maxlenstrinwindow 254
local rfl_setmenu_korr 0

// Default general settings
local strucversion version 3.6				// expected version of rfl.log
local hidemenu 0
local rewritemenu 0
local recentno 9
local loadlastlog 0
local treatcmdlogpar 1
local replacelog 0
local replacecmdlog 0
local dontwarnlogreplace 0
local logbackup 0

local minmem 10
local maxmem 450
local memmult 15
local lastcmds 0

quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
if _rc == 0 {
	capture copy `"`:sysdir PERSONAL'rfl.log"' `"`:sysdir PERSONAL'rfl.bkp"', replace
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
	file read `rfllog' line
	// Read the 1st 15 lines with general settings
	// Look whether rfl.log needs to get version-updated
	if `"`line'"' ~= "`strucversion'" {
		file close `rfllog'
		rflbdlg, action(rflupdatelog) strucversion(`"`strucversion'"')
		if "`r(done)'" == "0" | missing("`r(done)'") {
			capture window stopbox note `"Conversion of rfl.log was not successful. Please notify the author of rfl."'
			exit
		}
		tempname rfllog
		file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
		file read `rfllog' line
	}
	// Read general settings (15 lines)
	local strucversion `line'
	file read `rfllog' line
	local hidemenu `line'
	file read `rfllog' line
	local rewritemenu `line'
	if `hidemenu' == 0 {
		if missing("$rfl_SETMENU") | `rewritemenu' == 1 {
			global rfl_SETMENU 1
		}
	}
	else {
		if missing("$rfl_SETMENU") {
			global rfl_SETMENU 0
		}
	}
	file read `rfllog' line
	local recentno `line'
	file read `rfllog' line
	local loadlastlog `line'
	file read `rfllog' line
	local treatcmdlogpar `line'
	file read `rfllog' line
	local replacelog `line'
	file read `rfllog' line
	local replacecmdlog `line'
	file read `rfllog' line
	local dontwarnlogreplace `line'
	file read `rfllog' line
	local minmem `line'
	file read `rfllog' line
	local maxmem `line'
	file read `rfllog' line
	local memmult `line'
	file read `rfllog' line
	local logbackup `line'
	file read `rfllog' line
	if ~ missing("`line'") {
		local lastcmds `line'
	}
	forvalues i = 15(1)16 {
		file read `rfllog' line
	}

	while r(eof)==0 {
		// Read list entries (line 16-end)
		local dtanum = `dtanum' + 1
		local anzopen`dtanum' `line'
		file read `rfllog' line
		local lastopen`dtanum' `line'
		if `line' > 0 {
			local lop`line' `dtanum'
		}
		file read `rfllog' line
		local dtakurz`dtanum' `line'
		file read `rfllog' line
		local dtalang`dtanum' `line'
		file read `rfllog' line
		local cmdloglang`dtanum' `line'
		file read `rfllog' line
		local loglang`dtanum' `line'
		file read `rfllog' line
		local desckurz`dtanum' `line'
		file read `rfllog' line
		local desclang`dtanum' `line'
		forvalues i = 9(1)14 {
			file read `rfllog' line
		}
		local newdta`dtanum' `line'
		file read `rfllog' line
		local del`dtanum' `line'
		if `line' == 1 {
			local rewritelog 1
			if ~ missing("$rfl_SETMENU") {
				if $rfl_SETMENU > 0 {
					if ~ missing("$rfl_SETMENU_no") {
						if `dtanum' <= $rfl_SETMENU_no {
							local rfl_setmenu_korr = `rfl_setmenu_korr' + 1
						}
					}
				}
			}
		}
		if `line' == 2 {
			local renamelog 1
		}
		file read `rfllog' line
	}
	file close `rfllog'
	if ~ missing("$rfl_SETMENU") {
		if $rfl_SETMENU > 0 {
			if ~ missing("$rfl_SETMENU_no") {
				global rfl_SETMENU_no = $rfl_SETMENU_no - `rfl_setmenu_korr'
			}
		}
	}
}

// Rewrite the list, if any entry is marked for deletion or for renaming
// Assign new values to the variables
// 1) Delete entries marked for deletion in the variable list
if `rewritelog' == 1 {
	forvalues i = 1 2 to `dtanum' {
		if `korr' > 0 {
			local anzopen`=`i'-`korr''  `anzopen`i''
			local lastopen`=`i'-`korr'' `=`lastopen`i''+`korr''
			local dtakurz`=`i'-`korr''  `dtakurz`i''
			local dtalang`=`i'-`korr''  `dtalang`i''
			local cmdloglang`=`i'-`korr''  `cmdloglang`i''
			local loglang`=`i'-`korr''  `loglang`i''
			local desckurz`=`i'-`korr'' `desckurz`i''
			local desclang`=`i'-`korr'' `desclang`i''
			local newdta`=`i'-`korr''   `newdta`i''
			local del`=`i'-`korr''      `del`i''
		}
		if `del`i'' == 1 {
			local korr = `korr' + 1
		}
	}
	forvalues i = `=`dtanum'-`korr'+1'(1)`dtanum' {
		local anzopen`i'
		local lastopen`i'
		local dtakurz`i'
		local dtalang`i'
		local cmdloglang`i'
		local loglang`i'
		local desckurz`i'
		local desclang`i'
		local newdta`i'
		local del`i'
	}
	local dtanum =`dtanum' - `korr'
}
else {
	if missing("$rfl_SETMENU") {
		global rfl_SETMENU 1
	}
}
// 2) Entries marked for renaming: Rename entries
if `renamelog' == 1 {
	forvalues i = 1 2 to `dtanum' {
		if `del`i'' == 2 {
//			if `:length local newdta`i'' > `maxleninlist' {
				// Make short form of newdta. `mem' is misused here to pass the desired string length
				local strpart
				rflbdlg, dta(`"`newdta`i''"') action(makeshortdta)
				if ~ missing("`r(zzdta)'") {
					local zzdta `r(zzdta)'
					local filesave `r(filesave)'
					local pathsave `r(pathsave)'
					local dtakurz `"`filesave' (`pathsave')"'
					// Look whether short form already exists in the list, find unique short form
					local exitloop 0
					local j 1
					while `exitloop' == 0 {
						local k 1
						local exitloop 1
						while `k' <= `dtanum' {
							if `"`dtakurz`k''"' == `"`dtakurz'"' & `k' ~= `i' {
								// short form already exists
								rflbdlg, dta(`"`pathsave'"') action(shortenpath) mem(`=`:length local pathsave'-length("* [`j']")')
								local strpart
								forvalues m = 1(1)`r(strparts)' {
									if substr(`"`r(str`=`m'-1')'"',-1,1) == "\" {
										local strpart `strpart'\`r(str`m')'
									}
									else {
										local strpart `strpart'`r(str`m')'
									}
								}
								local newpathsave `:subinstr local strpart "`zzdta'" " ", all'* [`j']
								local dtakurz `filesave' (`newpathsave')
								local k `dtanum'
								local j = `j' + 1
								local exitloop 0
							}
							local k = `k' + 1
						}
					}
					local dtakurz`i' `"`dtakurz'"'
				}
				else {
					// File can't be renamed. Error msg has already been displayed
					local newdta`i'
					local del`i' 0
				}
//			}
//			else {
//				local dtakurz`i' `newdta`i''
//			}
			local dtalang`i' `newdta`i''
			if ~ missing("$rfl_SETMENU") {
				if $rfl_SETMENU == 2 {
					if ~ missing("$rfl_SETMENU_no") {
						if `dtanum' <= $rfl_SETMENU_no {
							if `rewritemenu' == 0 {
								window menu append item "rfl..." `"`dtakurz`i''"' `"rfluse `dtakurz`i'', from(rfl.menu)"'
							}
						}
					}
				}
			}
		}
	}
}

if "`test'" == "test" {
	local i 1
	while ~ missing("`anzopen`i''") {
		if `i' > `dtanum' {
			disp "*** This record has been deleted"
		}
		disp "anzopen`i':  `anzopen`i''"
		disp "lastopen`i': `=`lastopen`i''+`korr''"
		disp "dtakurz`i':  `dtakurz`i''"
		disp "dtalang`i':  `dtalang`i''"
		disp "cmdloglang`i':  `cmdloglang`i''"
		disp "loglang`i':  `loglang`i''"
		disp "desckurz`i': `desckurz`i''"
		disp "desclang`i': `desclang`i''"
		disp "newdta`i':   `newdta`i''"
		disp "del`i':      `del`i''"
		local i = `i' + 1
	}
	exit
}

// Finally, rewrite rfl.log, if necessary
if `rewritelog' == 1 | `renamelog' == 1 {
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', write text replace
	file write `rfllog' "`strucversion'" _n
	file write `rfllog' "`hidemenu'" _n
	file write `rfllog' "`rewritemenu'" _n
	file write `rfllog' "`recentno'" _n
	file write `rfllog' "`loadlastlog'" _n
	file write `rfllog' "`treatcmdlogpar'" _n
	file write `rfllog' "`replacelog'" _n
	file write `rfllog' "`replacecmdlog'" _n
	file write `rfllog' "`dontwarnlogreplace'" _n
	file write `rfllog' "`minmem'" _n
	file write `rfllog' "`maxmem'" _n
	file write `rfllog' "`memmult'" _n
	file write `rfllog' "`logbackup'" _n
	file write `rfllog' "`lastcmds'" _n
	forvalues i = 15(1)15 {
		file write `rfllog' "" _n
	}
	forvalues i = 1 2 to `dtanum' {
		file write `rfllog' "`anzopen`i''" _n
		file write `rfllog' "`=`lastopen`i'''" _n
		file write `rfllog' `"`dtakurz`i''"' _n
		file write `rfllog' `"`dtalang`i''"' _n
		file write `rfllog' "`cmdloglang`i''" _n
		file write `rfllog' "`loglang`i''" _n
		file write `rfllog' `"`desckurz`i''"' _n
		file write `rfllog' `"`desclang`i''"' _n
		forvalues i = 9(1)14 {
			file write `rfllog' "" _n
		}
		file write `rfllog' "0" _n
	}
	file close `rfllog'
}

// Install menu
if `hidemenu' == 0 & ($rfl_SETMENU == 1 | `rewritemenu' == 1) {
	if `rewritemenu' == 1 {
		window menu clear
	}
	global rfl_SETMENU_no 0
	rflsetmenu `recentno' `rewritemenu' `dtanum' `"`dtakurz1'"' `"`dtakurz2'"' `"`dtakurz3'"' `"`dtakurz4'"' `"`dtakurz5'"' `"`dtakurz6'"' `"`dtakurz7'"' `"`dtakurz8'"' `"`dtakurz9'"' `"`dtakurz10'"' `"`dtakurz11'"' `"`dtakurz12'"' `"`dtakurz13'"' `"`dtakurz14'"' `"`dtakurz15'"' `"`dtakurz16'"' `"`dtakurz17'"' `"`dtakurz18'"' `"`dtakurz19'"' `"`dtakurz20'"' `"`dtakurz21'"' `"`dtakurz22'"' `"`dtakurz23'"' `"`dtakurz24'"' `"`dtakurz25'"' `"`dtakurz26'"' `"`dtakurz27'"' `"`dtakurz28'"' `"`dtakurz29'"' `"`dtakurz30'"'
}

// Make lists to be displayed in the combo boxes of the dialog
// List most recently used files list
tempname lstlast5
file open `lstlast5' using `"`:sysdir PERSONAL'rfllast5.idlg"', write text replace
file write `lstlast5' "LIST lstlast5" _n
file write `lstlast5' "BEGIN" _n
if `dtanum' > 0 {
	local firstdtainlist `dtakurz1'
	local lastforvalue `recentno'
	if `dtanum' < `recentno' {
		local lastforvalue `dtanum'
	}
	forvalues i = 1 2 to `lastforvalue' {
		file write `lstlast5'  `"`dtakurz`i''"' _n
	}
}
else {
	file write `lstlast5' "<no files>" _n
	local firstdtainlist <no files>
}
file write `lstlast5' "END" _n
file close `lstlast5'

// Liste All (and 9 most popular), sorted alphabetically
tempname listall
file open `listall' using `"`:sysdir PERSONAL'rflliall.idlg"', write text replace
file write `listall'  "LIST listall" _n
file write `listall'  "BEGIN" _n

// Sort by dtakurz alphabetically
local listwritten 0
local korr 0

local dtakfilled 0
if `dtanum' > 0 {
	forvalues i = 1 2 to `=`dtanum' - 1' {
		local k 0
		local aktdta `dtakurz`i''
		local aktdel `del`i''
		forvalues j = `=`i'+1' `=`i'+2' to `dtanum' {
			if upper(`"`dtakurz`j''"') < upper(`"`aktdta'"') {
				local aktdta `dtakurz`j''
				local aktdel `del`j''
				local k `j'
			}
		}
		if `k' > 0 {
			local dtakurz`k' `dtakurz`i''
			local dtakurz`i' `aktdta'
			local del`k' `del`i''
			local del`i' `aktdel'
		}
	}
	forvalues i = 1 2 to `dtanum' {
		if ~ missing(`"`dtakurz`i''"') {
			file write `listall'  `"`dtakurz`i''"' _n
			local dtakfilled 1
		}
	}
}
if `dtakfilled' == 0 {
	file write `listall' "<no files>" _n
}
file write `listall'  "END" _n
file close `listall'

// list descriptions
tempname lstdesc
file open `lstdesc' using `"`:sysdir PERSONAL'rflldesc.idlg"', write text replace
file write `lstdesc' "LIST lstdesc" _n
file write `lstdesc' "BEGIN" _n

// Sortiere desc. Hier muß nur desc sortiert werden, weil nachher nichts mehr zu sortieren ist
// local k 0    // Für meine Begriffe muß k nach unten
local descfilled 0
if `dtanum' > 0 {
	forvalues i = 1 2 to `=`dtanum' - 1' {
		local k 0
		local aktdesc `desckurz`i''
		local aktdel `del`i''
		forvalues j = `=`i'+1' `=`i'+2' to `dtanum' {
			if upper(`"`desckurz`j''"') < upper(`"`aktdesc'"') {
				local aktdesc `desckurz`j''
				local aktdel `del`j''
				local k `j'
			}
		}
		if `k' > 0 {
			local desckurz`k' `desckurz`i''
			local desckurz`i' `aktdesc'
			local del`k' `del`i''
			local del`i' `aktdel'
		}
	}
	forvalues i = 1 2 to `dtanum' {
		if ~ missing(`"`desckurz`i''"') {
			file write `lstdesc'  `"`desckurz`i''"' _n
			local descfilled 1
		}
	}
}
if `descfilled' == 0 {
	file write `lstdesc' "<no descriptions>" _n
}
file write `lstdesc' "END" _n
file close `lstdesc'

// open dialog window
capture db rfl
if `treatcmdlogpar' == 0 {
	.rfl_dlg.second.cb_logsparallel.setoff
}
else {
	.rfl_dlg.second.cb_logsparallel.seton
}
.rfl_dlg.main.cb_runstata.seton
rflbdlg, action(checkopenfiles) from(rfl.ado)
rflbdlg, dta(`"`firstdtainlist'"') action(setlogdesc) from(rfl.ado) minmem(`minmem') maxmem(`maxmem') memmult(`memmult')
// settings on second tab
if `hidemenu' == 1 {
	.rfl_dlg.second.cb_nomenu.seton
}
else {
	.rfl_dlg.second.cb_nomenu.setoff
}
if `rewritemenu' == 1 {
	.rfl_dlg.second.cb_rewritemenu.seton
}
else {
	.rfl_dlg.second.cb_rewritemenu.setoff
}
.rfl_dlg.second.sp_numfiles.setvalue `recentno'
if `loadlastlog' == 1 {
	.rfl_dlg.second.cb_loadlastlog.seton
}
else {
	.rfl_dlg.second.cb_loadlastlog.setoff
}
.rfl_dlg.second.sp_cmd.setvalue `lastcmds'
if `replacelog' == 1 {
	.rfl_dlg.second.cb_logreplace.seton
}
else {
	.rfl_dlg.second.cb_logreplace.setoff
}
if `replacecmdlog' == 1 {
	.rfl_dlg.second.cb_cmdlogreplace.seton
}
else {
	.rfl_dlg.second.cb_cmdlogreplace.setoff
}
if `dontwarnlogreplace' == 1 {
	.rfl_dlg.second.cb_logrepldontwarn.seton
}
else {
	.rfl_dlg.second.cb_logrepldontwarn.setoff
}
if `logbackup' == 1 {
	.rfl_dlg.second.cb_logbackup.seton
}
else {
	.rfl_dlg.second.cb_logbackup.setoff
}
.rfl_dlg.second.sp_memmult.setvalue `memmult'

.rfl_dlg.second.sp_minmem.setvalue `minmem'
.rfl_dlg.second.sp_maxmem.setvalue `maxmem'
if c(os) == "MacOSX" {
	.rfl_dlg.second.bu_resetwindowtitle.disable
}
// If first invocation of rfl
if `"`firstdtainlist'"' == `"<no files>"' {
	.rfl_dlg.main.cb_otherDB.seton
}
.rfl_dlg.second.bu_setdefault.disable
end




