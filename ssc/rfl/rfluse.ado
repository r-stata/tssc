*! rfluse.ado version 3.6, 29 Nov 2005, Dankwart Plattner,  dankwart.plattner@web.de

program rfluse
version 8.2

// wrapper for rflbdlg.ado

syntax [anything (name=dta)][, log(string) cmdlog(string) desc(string) mem(integer -1) l(numlist integer min=1 max=1 >=1 <=3) ds dc lc cc from(string)]

// Never specify the from option in the command line
if ~ missing("`from'") {
	if "`from'" ~= "rfl.menu" {
		local from rfluse
	}
}
if missing("`from'") {
	local from rfluse
}

local maxlenstrinwindow 250
if `=c(SE)' == 1 | c(stata_version)>=9.1 {
	local maxlengthstring 244
	// must be shorter than smallest maxlengthstr
	// tests obtain a max for piecelen of 127 in SE
	local piecelen = 90
}
else {
	local maxlengthstring 80
	local piecelen = 79		// must be shorter than smallest maxlengthstr, in order to apply string function to the Teilpieces
}
local maxleninlist 80

// if dta is not provided, attempt to start with the last dta used
if missing(`"`dta'"') {
	local set 1
}
else {
	if ~ missing(real(`"`dta'"')) {
		// if dta is provided as a number, attempt to start with the appropriate dta
		local set = `dta'
	}
	else {
		local set 0
	}
}

quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
if _rc == 0 {
	capture copy `"`:sysdir PERSONAL'rfl.log"' `"`:sysdir PERSONAL'rfl.bkp"', replace
}
else {
	capture window stopbox stop "rfl.log not found. At least one dataset should have been opened with rfl for rfluse to work as desired. Type rfl into the command window."
	exit
}

local dtanum 0
local strucversion version 3.6				// this denotes the version of rfl whose log structure should be used (=expected version)
tempname rfllog
file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
file read `rfllog' line
// Read the 1st 15 lines with general settings
// Look whether rfl.log needs to get version-updated
if `"`line'"' ~= "`strucversion'" {
	file close `rfllog'
	rflbdlg, action(rflupdatelog) strucversion(`"`strucversion'"')
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
	file read `rfllog' line
}
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
if "`from'" == "rfl.menu" {
	local loadlastlog `line'
}
else {
	// loadlastlog: 0 default log 1 last log 2 no logs
	if missing(`"`log'"') & missing(`"`cmdlog'"') {
		if missing("`l'") {
			local loadlastlog `line'
		}
		else {
			local loadlastlog = `l'-1
		}
	}
	else {
		local loadlastlog 2
	}
}
forvalues i = 6(1)10 {
	file read `rfllog' line
}
local minmem `line'
file read `rfllog' line
local maxmem `line'
file read `rfllog' line
local memmult `line'
forvalues i = 13(1)16 {
	file read `rfllog' line
}
forvalues i = 1(1)`=`set'-1' {
	if r(eof) == 0 {
		local dtanum = `dtanum' + 1
		forvalues j = 2(1)3 {
			file read `rfllog' line
		}
		local dtakurz`dtanum' `line'
		forvalues j = 4(1)16 {
			file read `rfllog' line
		}
	}
}
if `set' > 0 {
	if r(eof) == 0 {
		local dtanum = `dtanum' + 1
		forvalues j = 2(1)3 {
			file read `rfllog' line
		}
		local dtakurz`dtanum' `line'
		file read `rfllog' line
		local dta `line'
		file read `rfllog' line
		if missing(`"`cmdlog'"') & `loadlastlog' == 1 {
			local cmdlog `line'
		}
		file read `rfllog' line
		if missing(`"`log'"') & `loadlastlog' == 1 {
			local log `line'
		}
		file read `rfllog' line
		file read `rfllog' line
		if missing(`"`desc'"') {
			local desc `line'
		}
		if $rfl_SETMENU == 1 | `rewritemenu' == 1 {
			forvalues j = 9(1)16 {
				file read `rfllog' line
			}
			while r(eof) == 0 & `dtanum' < `recentno' {
				local dtanum = `dtanum' + 1
				forvalues j = 2(1)3 {
					file read `rfllog' line
				}
				local dtakurz`dtanum' `line'
				forvalues j = 4(1)16 {
					file read `rfllog' line
				}
			}
		}
	}
}
else {
	local found 0
	local readfordlglist 1
	while r(eof) == 0 {
		local dtanum = `dtanum' + 1
		forvalues j = 2(1)3 {
			file read `rfllog' line
		}
		local dtakurz`dtanum' `line'
		if "`from'" == "rfl.menu" & `found' == 0 {
			// dta comes as dtakurz from rfl.menu: don't do anything, but catch up later
		}
		else {
			file read `rfllog' line
		}
		if `found' == 0 {
			if `:length local dta' == `:length local line' {
				if `:length local dta' <= `maxlengthstring' {
					local found = `"`dta'"' == `"`line'"'
				}
				else {
					local found 1
					local i 0
					while ~ missing(`"`:piece `=`i'+1' `piecelen' of "`dta'"'"') & `found' == 1 {
						local i = `i' + 1
						if `found' == 1 {
							local found = `"`:piece `i' `piecelen' of "`dta'"'"' == `"`:piece `i' `piecelen' of "`line'"'"'
						}
					}
				}
			}
			if "`from'" == "rfl.menu" {
				// dta comes as dtakurz from rfl.menu: read another line to catch up
				file read `rfllog' line
				if `found' == 1 {
					// change dta from dtakurz to dtalang
					local dta `line'
				}
			}
		}
		if `found' == 1 & `readfordlglist' == 1 {
			file read `rfllog' line
			if missing(`"`cmdlog'"') & `loadlastlog' == 1 {
				local cmdlog `line'
			}
			file read `rfllog' line
			if missing(`"`log'"') & `loadlastlog' == 1 {
				local log `line'
			}
			file read `rfllog' line
			file read `rfllog' line
			if missing(`"`desc'"') {
				local desc `line'
			}
			if ($rfl_SETMENU ~= 1 & `rewritemenu' == 0) | `hidemenu' == 1 {
				file seek `rfllog' eof
			}
			else {
				forvalues j = 9(1)15 {
					file read `rfllog' line
				}
			}
			local readfordlglist 0
		}
		else {
			forvalues j = 5(1)15 {
				file read `rfllog' line
			}
		}
		if `found' == 1 & `readfordlglist' == 0 & `dtanum' >= `recentno' {
			file seek `rfllog' eof
		}
		file read `rfllog' line
	}
}
file close `rfllog'

quietly capture confirm file `"`dta'"'
if _rc ~= 0 {
	// no string > 255 chars. Less then some 500 chars in total
	capture window stopbox stop "An error occured. Please read the message in the results window."
	disp " "
	if "`from'" ~= "rfl.menu" {
		disp `"Dataset `dta' not found. Either it doesn't exist or there is no list entry pointing to it. Please try to load the file from rfl's dialog (type rfl in the command window)."'
	}
	else {
		disp `"Dataset `dta' does not exist. You must specify a valid dataset."'
	}
	exit
}

// make log files, if required
if `loadlastlog' == 0 {
	rflbdlg , dta(`"`dta'"') action("makelogfiles")
	if "`r(done)'" == "0" | missing("`r(done)'") {
		disp as error "While building the log file names, an error occurred. " as result `"`dta'"' as text " can't be loaded."
		exit
	}
	local lhelp3
	forvalues i = 1(1)`r(logstrparts)' {
		if substr(`"`r(logstr`=`i'-1')'"',-1,1) == "\" {
			local lhelp3 `lhelp3'\`r(logstr`i')'
		}
		else {
			local lhelp3 `lhelp3'`r(logstr`i')'
		}
	}
	if ~ missing("`r(zzdta)'") {
		if c(logtype) == "smcl" {
			local log `:subinstr local lhelp3 "`r(zzdta)'" " ", all'.smcl
		}
		else {
			local log `:subinstr local lhelp3 "`r(zzdta)'" " ", all'.log
		}
		local cmdlog `:subinstr local lhelp3 "`r(zzdta)'" " ", all'.txt
	}
	else {
		if c(logtype) == "smcl" {
			local log `lhelp3'.smcl
		}
		else {
			local log `lhelp3'.log
		}
		local cmdlog `lhelp3'.txt
	}
}

// Install menu
if `hidemenu' == 0 & ($rfl_SETMENU == 1 | `rewritemenu' == 1) {
	if `rewritemenu' == 1 {
		window menu clear
	}
	global rfl_SETMENU_no 0
	rflsetmenu `recentno' `rewritemenu' `dtanum' `"`dtakurz1'"' `"`dtakurz2'"' `"`dtakurz3'"' `"`dtakurz4'"' `"`dtakurz5'"' `"`dtakurz6'"' `"`dtakurz7'"' `"`dtakurz8'"' `"`dtakurz9'"' `"`dtakurz10'"' `"`dtakurz11'"' `"`dtakurz12'"' `"`dtakurz13'"' `"`dtakurz14'"' `"`dtakurz15'"' `"`dtakurz16'"' `"`dtakurz17'"' `"`dtakurz18'"' `"`dtakurz19'"' `"`dtakurz20'"' `"`dtakurz21'"' `"`dtakurz22'"' `"`dtakurz23'"' `"`dtakurz24'"' `"`dtakurz25'"' `"`dtakurz26'"' `"`dtakurz27'"' `"`dtakurz28'"' `"`dtakurz29'"' `"`dtakurz30'"'
}

// Check for open files
rflbdlg, action(checkopenfiles) from(rfluse_chkopenfiles)
if `r(filesinmemory)' == 1 {
	capture db rflCM
	rflbdlg, action(checkopenfiles) from(rfluse_chkopenfiles_showdlg)
	.rflCM_dlg.main.tx_file.setlabel `"`dta'"'
	.rflCM_dlg.main.ed_file.setvalue `"`dta'"'
	.rflCM_dlg.main.tx_desc.setlabel `"`desc'"'
	.rflCM_dlg.main.ed_desc.setvalue `"`desc'"'
	.rflCM_dlg.main.tx_log.setlabel `"`log'"'
	.rflCM_dlg.main.ed_log.setvalue `"`log'"'
	.rflCM_dlg.main.tx_cmdlog.setlabel `"`cmdlog'"'
	.rflCM_dlg.main.ed_cmdlog.setvalue `"`cmdlog'"'

	.rflCM_dlg.main.ed_minmem.setvalue `"`minmem'"'
	.rflCM_dlg.main.ed_maxmem.setvalue `"`maxmem'"'
	.rflCM_dlg.main.ed_memmult.setvalue `"`memmult'"'

	exit
}

if missing("`ds'") {
	local saved 0
}
else {
	local saved 1
}
if missing("`dc'") {
	local closed 0
}
else {
	local closed 1
}
if missing("`lc'") {
	local closel 0
}
else {
	local closel 1
}
if missing("`cc'") {
	local closec 0
}
else {
	local closec 1
}

// set trace off
// loadlastlog is not passed - otherwise a user input would become the default
// value. This is not desired - default values are set only from the dialog window
rflbdlg , dta(`"`dta'"') desc(`"`desc'"') log(`"`log'"') cmdlog(`"`cmdlog'"') mem(`"`mem'"') action(openfiles) from(`"`from'"') saved(`saved') closed(`closed') closel(`closel') closec(`closec') minmem(`minmem') maxmem(`maxmem') memmult(`memmult')
end



