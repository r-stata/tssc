*! rflbdlg.ado version 3.6, 29 Nov 2005, Dankwart Plattner,  dankwart.plattner@web.de
*! Keywords: file management; file open; recent files list; data file handling; dialog

// zztaken nur bei Bedarf einlesen (Derzeit: standardmäßig für jede Datei)

// Datei existiert nicht mehr, ohne daß der Nutzer das bemerkt hat: Nur bei Dateien, die aus file
// open kommen, oder bei Dateien, die nicht zum Löschen markiert sind, beachten

// Wenn ein string ohne ersetzte Leerzeichen getrennt wird, ist nicht sicher, daß sich "dta" tatsächlich
// im letzten piece findet. Kontrollieren und mit reverselongstr arbeiten!

// Log: File extension für log und cmdlog freigeben

* ---------------------------------------
program rflbdlg, rclass
* ---------------------------------------
version 8.2
syntax , [dta(string) newdta(string) desc(string) log(string) cmdlog(string)] action(string) [saved(string) closed(string) closel(string) closec(string) from(string) mem(string) size(string) scr(string) dtaisdesc(integer 0) test(integer 0) strucversion(string) hidemenu(numlist integer min=1 max=1 >=0 <=1) rewritemenu(numlist integer min=1 max=1 >=0 <=1) recentno(numlist integer min=1 max=1 >=1 <=30) loadlastlog(numlist integer min=1 max=1 >=-1 <=1) treatcmdlogpar(numlist integer min=1 max=1 >=0 <=1) replacelog(numlist integer min=1 max=1 >=0 <=1) replacecmdlog(numlist integer min=1 max=1 >=0 <=1) dontwarnlogreplace(numlist integer min=1 max=1 >=0 <=1) logbackup(numlist integer min=1 max=1 >=0 <=1) lastcmds(numlist integer min=1 max=1 >=0 <=9999) minmem(numlist integer min=1 max=1 >=1) maxmem(numlist integer min=1 max=1 >=1) memmult(numlist integer min=1 max=1 >=10)]
//	noi disp `"dta: `dta', newdta: `newdta', desc: `desc', log: `log', cmdlog: `cmdlog', action: `action', saved: `saved', closed: `closed', closel: `closel', closec: `closec', from: `from', mem: `mem', size: `size', scr: `scr', dtaisdesc: `dtaisdesc', test: `test', strucversion: `strucversion', hidemenu: `hidemenu', rewritemenu: `rewritemenu', recentno: `recentno', loadlastlog: `loadlastlog', treatcmdlogpar: `treatcmdlogpar', replacelog: `replacelog', replacecmdlog: `replacecmdlog', dontwarnlogreplace: `dontwarnlogreplace', logbackup: `logbackup', lastcmds: `lastcmds', minmem: `minmem', maxmem: `maxmem', memmult: `memmult', logfile: `logfile', cmd: `cmd' "'

/*
if "`action'" == "exitstata" {
	// Stata schließen, funktioniert aber nicht
	// noi disp "exit erreicht"
	capture window stopbox rusure `"Are you sure you want to exit Stata?"' `"Press CANCEL if you don't want to exit."' `"Press OK if you want to exit. In addition, type anything in the command window and press RETURN on your keyboard."'
	if _rc == 0 {
		class exit .rfl_dlg
		exit, STATA
	}
}
*/

// Erst die actions, für die dta nicht benötigt wird
// Reset Stata window title
if "`action'" == "resetwindowtitle" {
	if c(os) ~= "MacOSX" {
		window manage maintitle reset
	}
	exit
}

// Constants
// Diese Unterscheidung ist ab Version 9.1 nicht mehr nötig: Sowohl Intercooled als auch SE können strings mit 244 Zeichen Länge verarbeiten
if `=c(SE)' == 1 | c(stata_version)>=9.1 {
	local maxlengthstring 244
	// must be shorter than smallest maxlengthstr
	// tests obtain a max for piecelen of 127 in SE, otherwise Stata crashes
	local piecelen = 90
}
else {
	local maxlengthstring 80
	local piecelen = 79		// must be shorter than smallest maxlengthstr, in order to apply string function to the string pieces
}
local maxlengthfilename 259
local listentrydeleted 0		// was macht das hier?
local ndtateilzahl 0
local maxlenstrinwindow 250
local maxlenwindow 500
local maxleninlist 80

// Check whether desc contains ", ', or `. dta, log, cmdlog, newdta are tested further down
foreach filetype in desc {
	checkquotes `"``filetype''"' `piecelen' `filetype'
	if `r(done)' == 1 {
		if `r(quotes)' == 1 {
			exit
		}
	}
	else {
		// check failed
	}
}

// Hier geht es nur darum, ed_desc zu füllen: dann gleich wieder zurück
if "`action'" == "fill_ed_desc" {
	.rfl_dlg.main.ed_desc.setvalue `"`desc'"'
	exit
}

// Hier geht es nur darum, tx_desc zu füllen: dann gleich wieder zurück
if "`action'" == "fill_tx_desc" {
	.rfl_dlg.main.tx_desc.setlabel `"`desc'"'
	exit
}

// Hier geht es nur darum, ed_hid und ed_hidfo zu füllen: dann gleich wieder zurück
if "`action'" == "fill_ed_hid" | "`action'" == "fill_ed_hidfo" {
	if "`action'" == "fill_ed_hid" {
		.rfl_dlg.main.ed_hid.setvalue `"`desc'"'
	}
	else {
		.rfl_dlg.main.ed_hidfo.setvalue `"`desc'"'
	}
	.rfl_dlg.main.ed_desc.setvalue `"`desc'"'
	.rfl_dlg.main.tx_desc.setlabel `"`desc'"'
	if missing(`"`desc'"') {
		.rfl_dlg.main.bu_chgdesc.setlabel "Enter description"
	}
	else {
		.rfl_dlg.main.bu_chgdesc.setlabel "Change description"
	}
}

if "`action'" == "setmemtext" {
	setmemtext "`size'" "`mem'"
	exit
}

if "`action'" == "setdefault" {
	setdefault "`hidemenu'" "`rewritemenu'" "`recentno'" "`loadlastlog'" "`treatcmdlogpar'" "`replacelog'" "`replacecmdlog'" "`dontwarnlogreplace'" "`logbackup'" "`lastcmds'" "`minmem'" "`maxmem'" "`memmult'"
	exit
}

// Check whether dta newdta log cmdlog contains ", ', or `
foreach filetype in dta newdta log cmdlog {
	checkquotes `"``filetype''"' `piecelen' `filetype'
	if `r(done)' == 1 {
		if `r(quotes)' == 1 {
			exit
		}
	}
	else {
		// check failed
	}
}

if `"`dta'"' == "<no files>" {
	// muß nach checkopenfiles stehen
	.rfl_dlg.main.gb_Database.setlabel `"This is the first time you invoke rfl. Please press "Choose" to choose a file"'
	.rfl_dlg.main.tx_desc.setlabel ""
	.rfl_dlg.main.tx_filesize.setlabel ""
	if "`action'" == "openfiles" {
		noi disp as text "No file specified: no dataset loaded, no log file opened."
	}
	exit
}

// if `"`dta'"' == `"<no descriptions>"' & "`from'" ~= "program command" {
//	capture window stopbox note `"Please choose a file."'
	// TO DO Was soll hier geschehen?
if `"`dta'"' == `"<no descriptions>"' & "`from'" == "program command" {
	noi disp as text "No file specified: no dataset loaded, no log file opened."
	exit
}

// Jetzt die actions, für die dta benötigt wird
if "`action'" == "checkopenfiles" {
// $S_FN prüft auf einen Dataset-Namen; die Lösung mit c(N) + c(k) kriegt mit, ob Daten im Speicher sind
	if "`from'" == "rfluse_chkopenfiles" {
		return local filesinmemory 0
		if (c(N) + c(k) > 0) {
			return local filesinmemory 1
		}
		quietly log
		if ~ missing(r(filename)) {
			return local filesinmemory 1
		}
		quietly cmdlog
		if ~ missing(r(filename)) {
			return local filesinmemory 1
		}
		exit
	}

	if "`from'" == "rfluse_chkopenfiles_showdlg" {
		local dlgwin .rflCM_dlg.main.
	}
	else {
		local dlgwin .rfl_dlg.main.
		// The following commands help circumvent Stata 9's shortcoming of not stretching the label of a radio button when the label is changed
		.rfl_dlg.main.rb_log1default.setlabel "(Log file not yet chosen)"
		.rfl_dlg.main.rb_log2last.setlabel "<no last log file yet>"
		.rfl_dlg.second.rb_cmdlog1default.setlabel "(cmdlog file not yet chosen)"
		.rfl_dlg.second.rb_cmdlog2last.setlabel "<no last cmdlog file yet>"
	}

	if (c(N) + c(k) > 0) {
		`dlgwin'cb_dsave.show
		`dlgwin'cb_dclose.show
		`dlgwin'cb_dclose.seton
		if c(changed) == 1 {
			`dlgwin'cb_dsave.seton
		}
		else {
			`dlgwin'cb_dsave.setoff
		}
		if missing(`"$S_FN"') {
			`dlgwin'cb_dclose.setlabel `"Drop data in memory (no file name given)"'
		}
		else {
			writedlgpath "`dlgwin'cb_dclose.setlabel" `"$S_FN"' "Close " "" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
			if `r(done)' == 0 {
				`dlgwin'cb_dclose.setlabel `"Close $S_FN"'
			}
		}
	}
	else {
		`dlgwin'cb_dsave.hide
		`dlgwin'cb_dclose.hide
		`dlgwin'cb_dsave.setoff
		`dlgwin'cb_dclose.setoff
	}
	quietly log
	if missing(r(filename)) {
		`dlgwin'cb_lclose.hide
	}
	else {
		`dlgwin'cb_lclose.show
		`dlgwin'cb_lclose.seton
		writedlgpath "`dlgwin'cb_lclose.setlabel" `"`r(filename)'"' "Close " "" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
		if `r(done)' == 0 {
			quietly log
			`dlgwin'cb_lclose.setlabel `"Close `r(filename)'"'
		}
	}
	quietly cmdlog
	if missing(r(filename)) {
		`dlgwin'cb_cclose.hide
	}
	else {
		`dlgwin'cb_cclose.show
		`dlgwin'cb_cclose.seton
		writedlgpath "`dlgwin'cb_cclose.setlabel" `"`r(filename)'"' "Close " "" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
		if `r(done)' == 0 {
			quietly cmdlog
			`dlgwin'cb_cclose.setlabel `"Close `r(filename)'"'
		}
	}

	if "`dlgwin'" == ".rfl_dlg.main." {
		// see whether Mac, disable Reset window title button
		if c(os) == "MacOSX" {
			.rfl_dlg.second.bu_resetwindowtitle.disable
		}

		// Format 0.1 as 0,1 if dp=comma on second tab
		if c(dp) == "comma" {
			.rfl_dlg.second.tx_filesize1.setlabel "On main tab, suggest memory to be 0,1*"
		}
	}
	exit
}

if "`action'" == "rflupdatelog" {
	rflupdatelog `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow' `maxleninlist' "`strucversion'"
	return add
/*
	if `r(done)' == 0 {
		return local done 0
	}
	else {
		return local done 1
	}
*/
	exit
}

// zztaken einlesen
if ~ missing(`"`dta'"') {
	defrepchar `"`dta'"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
	local zzdta = r(zztaken)
	if `r(done)' == 0 {
		exit
	}
}

// Test routine, only for test purposes
if `test' > 0 {
	if "`action'" == "reverse" {
//		set trace on
		reverselongstr `"`:subinstr local dta " " "`zzdta'", all'"' `mem' "rev"
		forvalues i = 1(1)`r(revstrparts)' {
			if substr(`"`r(revstr`=`i'-1')'"',-1,1) == "\" {
				local dtahelp3 `dtahelp3'\`r(revstr`i')'
			}
			else {
				local dtahelp3 `dtahelp3'`r(revstr`i')'
			}
		}
		disp `"Ganze Folge    : `dta'"'
		disp `"Reversed string: `dtahelp3'"'
//		set trace off
		exit
	}
}

if "`action'" == "makeshortdta" & ~ missing(`"`dta'"') {
	// This is only called from rfl.ado when renaming files
	makeshortdta `"`dta'"' `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow' `maxleninlist' "`zzdta'"
	if `r(done)' == 0 {
		return local zzdta `"`zzdta'"'
	}
	return add
	exit
}

if "`action'" == "shortenpath" & ~ missing(`"`dta'"') {
	// This is only called from rfl.ado when renaming files
	shortenstr `"`:subinstr local dta " " "`zzdta'", all'"' "`mem'" 1 `piecelen'
	// mem is length of shortened string here
	return add
	/*
	return local strpartsbef = `r(strpartsbef)'
	return local strparts = `r(strparts)'
	forvalues i = 1(1)`r(strparts)' {
		return local str`i' `"`r(str`i')'"'
	}
	return local zzdta `"`zzdta'"'
	*/
	exit
}

if missing("`closel'") {
	local closel 0
}
if missing("`closec'") {
	local closec 0
}
if missing("`closed'") {
	local closed 0
}
if missing("`saved'") {
	local saved 0
}

if "`action'" == "noaction" {
	if `closel' + `closec' + `closed' +`saved' > 0 {
		closefiles `closed' `closel' `closec' `saved' `maxlengthstring' `maxlenwindow' `maxlenstrinwindow' `piecelen' `zzdta'
		if `r(dontoplog)' == 1 {
			disp "Closing of files not successful."
		}
	}
	if "`from'" == "rfl.menu" {
		exit
	}
	else {
		noi disp as text "As required: no dataset loaded, no log file opened."
	}
	// Continue to open log files, if required
//	exit
}

// actions which need dta or desc (dta, dtakurz or desckurz), but need not dta to be checked for
// existence
if "`action'" == "showname" {
	showname `"`dta'"' `"`log'"' `"`cmdlog'"' `"`desc'"' `dtaisdesc' `piecelen' "`zzdta'" `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
	exit
}

// Check if dta exists
quietly capture confirm file `"`dta'"'
local dtaexists = _rc == 0

if `dtaexists' == 0 & ~ missing(`"`dta'"') {
	// dta Trimmen
	if `:length local dta' <= `maxlengthstring' {
		local dta = trim(`"`dta'"')
	}
	else {
		strsplit `"`:subinstr local dta " " "`zzdta'", all'"' `piecelen' dta
		local ndtateilzahl = `r(dtastrparts)'
		if ltrim(`"`r(dtastr1)'"') ~= `"`r(dtastr1)'"' | rtrim(`"`r(dtastr`ndtateilzahl')'"') ~= `"`r(dtastr`ndtateilzahl')'"' {
			// Suche das erste piece, daß ltrimmed nicht missing ist
			local k=0
			local dtahelp
			while missing("`dtahelp'") & `k' < `ndtateilzahl' {
				local k = `k' + 1
				local dtahelp = ltrim(subinstr(`"`r(dtastr`k')'"',"`zzdta'"," ",.))
			}
			if missing(`"`dtahelp'"') {
				// leere Zeichenfolge: Fehlermeldung
				window stopbox note "You must specify a file name."
				exit
			}
			// Suche das letzte piece, daß rtrimmed nicht missing ist
			local j = `ndtateilzahl' + 1
			local dtahelp
			while missing("`dtahelp'") & `j' > 1 {
				local j = `j' - 1
				local dtahelp = rtrim(subinstr(`"`r(dtastr`j')'"',"`zzdta'"," ",.))
			}
			// Pieces zusammensetzen, auf \ am Ende einer Zeile achten
			local dtahelp3 = subinstr(ltrim(subinstr(`"`r(dtastr`k')'"',"`zzdta'"," ",.))," ","`zzdta'",.)
			forvalues i = `=`k'+1'(1)`=`j'-1' {
				if substr(`"`r(dtastr`=`i'-1')'"',-1,1) == "\" {
					local dtahelp3 `dtahelp3'\`r(dtastr`i')'
				}
				else {
					local dtahelp3 `dtahelp3'`r(dtastr`i')'
				}
			}
			if substr(`"`dtastr`=`j'-1''"',-1,1) == "\" {
				local dtahelp3 `dtahelp3'\`=subinstr(rtrim(subinstr(`"`r(dtastr`j')'"',"`zzdta'"," ",.))," ","`zzdta'",.)'
			}
			else {
				local dtahelp3 `dtahelp3'`=subinstr(rtrim(subinstr(`"`r(dtastr`j')'"',"`zzdta'"," ",.))," ","`zzdta'",.)'
			}
			// Wenn getrimmt: die pieces müssen neu bestimmt werden
			if `:length local dtahelp3' ~= `:length local dta' {
				strsplit `"`dtahelp3'"' `piecelen' dta
				local ndtateilzahl = `r(dtastrparts)'
				local dta `:subinstr local dtahelp3 "`zzdta'" " ", all'
			}
			forvalues i = 1(1)`ndtateilzahl' {
				local dtastr`i' `r(dtastr`i')'
			}
		}
	}
	quietly capture confirm file `"`dta'"'
	local dtaexists = _rc == 0
}

local thisfilemarked 0
if `dtaexists' == 0 & ~ missing(`"`dta'"') {
	// Maybe a description or a short file name?
	// Change short data file name or description into a long dataset file name
	if `"`dta'"' ~= "<no descriptions>" {
		quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
		if _rc == 0 {
			local found 0
			tempname rfllog
			file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
			local dtanum 0
			forvalues i = 1(1)16 {
				file read `rfllog' line
			}
			while r(eof) == 0 {
				file read `rfllog' line
				file read `rfllog' line
				local dtakurz `line'
				file read `rfllog' line
				local dtalang `line'
				forvalues i = 5(1)7 {
					file read `rfllog' line
				}
				local desckurz `line'
				file read `rfllog' line
				local desclang `line'
				forvalues i = 9(1)15 {
					file read `rfllog' line
				}
				local del `line'
				local thisfilemarked `line'
				// Hier muß ich m. E. nicht parsen, weil dtakurz und desckurz <=maxleninlist Zeichen
				if `"`dta'"' == `"`dtakurz'"' | `"`dta'"' == `"`desckurz'"' {
					local found 1
					file seek `rfllog' eof
				}
				else {
					file read `rfllog' line
				}
			}
			file close `rfllog'

			if `found' == 1 {
				local dtaisdesc = `"`dta'"' == `"`desckurz'"'  // TO DO Brauch ich das hier? dtaisdesc wird übergeben
				local dta `dtalang'
				if `:length local dta' > `maxlengthstring' {
					defrepchar `"`dta'"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
					local zzdta = r(zztaken)
					if `r(done)' == 0 {
						exit
					}
					strsplit `"`:subinstr local dta " " "`zzdta'", all'"' `piecelen' dta
					local ndtateilzahl = `r(dtastrparts)'
					forvalues i = 1(1)`ndtateilzahl' {
						local dtastr`i' `r(dtastr`i')'
					}
				}
				if `del' == 1 {
					// Meldung, daß Datei zum Löschen markiert ist?
				}
				quietly capture confirm file `"`dta'"'
				local dtaexists = _rc == 0
				if `dtaisdesc' == 1 {
					// dta im Beschreibungsfeld anzeigen. Beschreibung ins Feld ed_hid setzen
					writedlgpath ".rfl_dlg.main.tx_desc.setlabel" `"`dta'"' "" "" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
					if `r(done)' == 0 {
						.rfl_dlg.main.tx_desc.setlabel `"`dta'"'
					}
					.rfl_dlg.main.ed_hid.setvalue `"`desclang'"'
					local dtaisdesc 0
				}
			}
		}
	}
}

if `dtaexists' == 0 & "`action'" ~= "dellistentry" & "`action'" ~= "renlistentry" {
	// File has been renamed, moved to another directory or deleted, or it is a file which is
	// manually input in the file open control
	if ~ missing(`"`dta'"') & `"`dta'"' ~= `"<no descriptions>"' {
		// Show the proper controls in the dialog window
		if "`action'" == "openfiles" {
			// Relevant only if called from rfluse
			disp as result "`dta'" as text " does not exist any more. No action taken."
		}
		else if "`action'" == "noaction" {
		}
		else {
			if `thisfilemarked' == 0 {
				// Call the message box and the remove/rename group only if the entry has no marker
				local dispbefore
				if `dtaisdesc' == 1 {
					local dispbefore = "The file with the description "
				}
				local dispafter1 does not exist any more.
				local dispafter2 You may now remove or rename it from within rfl.
				local dispafter3
				// if message is displayed after the user has changed from one list to another,
				// the dialog loses focus and doesn't react any more
				dispmsg `"`dta'"' `maxlenwindow' `maxlenstrinwindow' 0 * note "`zzdta'" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'

				.rfl_dlg.main.gb_Logfile.hide
				.rfl_dlg.main.rb_log1default.hide
				.rfl_dlg.main.rb_log2last.hide
				.rfl_dlg.main.rb_log3nolog.hide
				.rfl_dlg.main.rb_log4other.hide
				.rfl_dlg.main.fi_logopen.hide
				.rfl_dlg.main.bu_dellistentry disable

				.rfl_dlg.main.gb_ren_del.show
				.rfl_dlg.main.rb_delete.show
				.rfl_dlg.main.rb_delete.seton
				.rfl_dlg.main.rb_rename.show
				.rfl_dlg.main.bu_fi_delete.show
				.rfl_dlg.main.bu_fi_cancel.show
			}
			.rfl_dlg.main.tx_filesize.setlabel "ERROR: SELECTED FILE NOT FOUND!"
		}
		// Continue, however, to get or write a description, display the log file etc.
	}
}

if "`action'" == "dellistentry" | "`action'" == "renlistentry" {
	dellistentry `"`dta'"' `"`newdta'"' "`action'" `dtaisdesc' "`zzdta'" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
	exit
}

if "`action'" == "dontchgrb_l1" {
	// Hier wird der komplette Logfilename richtig übergeben und muß unverändert zurückgegeben werden
	// Besides, fi_cmdlogopen gets filled
	setlogfile `"`dta'"' `"`log'"' `"`cmdlog'"' 1 "`action'" `piecelen' "`zzdta'" `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
	exit
}

if "`action'" == "getdesc" {
	getdesc `"`dta'"' `piecelen' "`zzdta'" `maxlengthstring'
	exit
}

if "`action'" == "writedesc" {
	writedesc `"`dta'"' `"`desc'"' `piecelen' "`zzdta'" `maxlengthstring' `maxleninlist'
	exit
}

if "`action'" == "setlogfile" | "`action'" == "setlogdesc_in_hidfo" | "`action'" == "setlogdesc" | "`action'" == "makelogfiles" {
	if ~ missing(`"`dta'"') & `"`dta'"' ~= `"<no descriptions>"' & `"`dta'"' ~= "<no files>" {
		makelogfilename `"`dta'"' "`action'" `piecelen' "`zzdta'" `maxlengthstring' `maxlengthfilename'
		if "`action'" == "makelogfiles" {
			// action = makelogfiles comes only from rfluse (or from the menu)
			return add
			exit
		}
		local nlogteilzahl = `r(logstrparts)'
		local lhelp3
		forvalues i = 1(1)`nlogteilzahl' {
			if substr(`"`r(logstr`=`i'-1')'"',-1,1) == "\" {
				local lhelp3 `lhelp3'\`r(logstr`i')'
			}
			else {
				local lhelp3 `lhelp3'`r(logstr`i')'
			}
		}
		setlogfile `"`dta'"' `"`:subinstr local lhelp3 "`zzdta'" " ", all'"' `"`:subinstr local lhelp3 "`zzdta'" " ", all'"' 0 "`action'" `piecelen' "`zzdta'" `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
	}
}

if `dtaexists' ~= 0 & ~ missing(`"`dta'"') {
//	set trace on
	// Speicherbedarf berechnen: Immer ausführen?
	// ********* Dateigröße einlesen, Speicher berechnen *************
	tempname f
	file open `f' using `"`dta'"', read binary
	file seek `f' eof
	file seek `f' query
	local fsz = r(loc)
	file close `f'

	local msz = `fsz'*`memmult'*0.1

	if `msz' < `minmem'*1024^2 {
		local msz = `minmem'*1024^2
	}
	else if `msz' > `maxmem'*1024^2 {
		local msz = `maxmem'*1024^2
	}
	if "`action'" ~= "openfiles" {
		local fmp = `=`msz'-`fsz''/`msz'*100
		local fszdisp = floor(round(`fsz'/(1024^2),.1)*10)/10
		local mszdisp = floor(round(`msz'/(1024^2),.1)*10)/10
		local mszsp_mem = floor(round(`msz'/(1024^2),.1)*10)/10
		// Damit die action von sp_mem nicht ausgelöst wird:
		.rfl_dlg.main.cb_runsetmemtext.setoff
		.rfl_dlg.main.sp_mem.setvalue `mszsp_mem'
		.rfl_dlg.main.ed_hisize.setvalue `mszsp_mem'
		.rfl_dlg.main.cb_runsetmemtext.seton
		setmemtext `fszdisp' `mszsp_mem'
	}
}

// Dateien öffnen *********************************************

if `dtaexists' ~= 0 | missing(`"`dta'"') {
	if "`action'" == "openfiles" & `"`dta'"' ~= `"<no files>"' & `"`dta'"' ~= `"<no descriptions>"' {
		local enterif 1
		if ~ missing(`"`dta'"') {
			quietly capture confirm file `"`dta'"'
			local enterif = _rc == 0
		}
		if `enterif' == 1 {
			openfile `"`dta'"' `"`desc'"' `"`log'"' `"`cmdlog'"' "`fsz'" "`msz'" "`piecelen'" "`zzdta'" "`saved'" "`closed'" "`closel'" "`closec'" "`mem'" "`from'" "`maxlengthstring'" "`maxlenwindow'" "`maxlenstrinwindow'" "`maxleninlist'" "`maxlengthfilename'" "`hidemenu'" "`rewritemenu'" "`recentno'" "`loadlastlog'" "`treatcmdlogpar'" "`replacelog'" "`replacecmdlog'" "`dontwarnlogreplace'" "`logbackup'" "`lastcmds'" "`minmem'" "`maxmem'" "`memmult'"
		}
		else {
			// The program should never enter this
			dellistentry `"`dta'"' "`newdta'" "`action'" `dtaisdesc' "`zzdta'" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
			disp in red "Dataset does not exist any more. No action taken."
			exit
		}
	}
}
end


* ---------------------------------------
program makelogfilename, rclass
* ------------------------------------
version 8.2
args dta action piecelen zzdta maxlengthstring maxlengthfilename
// build log and cmdlog file name from dta name

if `:length local dta' <= `maxlengthstring' {
	local enterif = substr(`"`dta'"', -4, 4) == `".dta"'
}
else {
	// Hier könnten die Teilstrings von dta noch nicht festgelegt sein
	if `:length local dta' > `maxlengthstring' {
		strsplit `"`:subinstr local dta " " "`zzdta'", all'"' `piecelen' dta
		local ndtateilzahl = `r(dtastrparts)'
		forvalues i = 1(1)`ndtateilzahl' {
			local dtastr`i' `r(dtastr`i')'
		}
	}
	reverselongstr `"`:subinstr local dta " " "`zzdta'", all'"' `piecelen' "rev"
	local enterif = substr(`"`r(revstr1)'"',1,4) == reverse(".dta")
}
if `enterif' == 1 {
	if `:length local dta' <= `maxlengthstring' {
		local lopen = reverse(substr(reverse(`"`dta'"'), index(reverse(`"`dta'"'),".")+1, .))
	}
	else {
		if length(`"`dtastr`ndtateilzahl''"') < 4 {
			local nlopteilzahl = `ndtateilzahl' - 1
		}
		else {
			local nlopteilzahl `ndtateilzahl'
		}
		local lopstr`nlopteilzahl' = reverse(substr(reverse(`"`dtastr`nlopteilzahl''"'), index(reverse(`"`dtastr`nlopteilzahl'''"'),".")+1, .))
		local dtahelp3
		forvalues i = 1(1)`=`nlopteilzahl'-1' {
			if substr(`"`dtastr`=`i'-1''"',-1,1) == "\" {
				local dtahelp3 `dtahelp3'\`dtastr`i''
			}
			else {
				local dtahelp3 `dtahelp3'`dtastr`i''
			}
		}
		if substr(`"`dtastr`=`nlopteilzahl'-1''"',-1,1) == "\" {
			local dtahelp3 `dtahelp3'\`lopstr`nlopteilzahl''
		}
		else {
			local dtahelp3 `dtahelp3'`lopstr`nlopteilzahl''
		}
		local lopen `:subinstr local dtahelp3 "`zzdta'" " ", all'
	}
}
else {
	// Warum erst jetzt?
	local lopen `"`dta'"'
/*
	local dta `dta'.dta
	if `:length local dta' > `maxlengthfilename' {
		local dispbefore
		local dispafter1 is `:length local dta' characters long (including the path).
		local dispafter2 Windows can handle file names of up to `maxlengthfilename' characters. Please choose another file or shorten the file name.
		local dispafter3
		dispmsg `"`dta'"' `maxlenwindow' `maxlenstrinwindow' 0 * note `zzdta' `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
		exit
	}
	// ndtateilzahl neu bestimmen
	strsplit `"`:subinstr local dta " " "`zzdta'", all'"' `piecelen' dta
	local ndtateilzahl = `r(dtastrparts)'
	forvalues i = 1(1)`ndtateilzahl' {
		local dtastr`i' `r(dtastr`i')'
	}
*/
}

// Date
local y = string(year(d($S_DATE)))
local m = string(month(d($S_DATE)))
if month(d($S_DATE)) < 10 {
	local m = "0`m'"
}
local d = string(day(d($S_DATE)))
if day(d($S_DATE)) < 10 {
	local d = "0`d'"
}
// Add date
if `:length local lopen' > `=`maxlengthfilename' - 5 - length(" `y'-`m'-`d'")' {
	strsplit `"`:subinstr local lopen " " "`zzdta'", all'"' `piecelen' tmp
	if length(`"`r(tmpstr`r(tmpstrparts)')'"') < `=`:length local lopen' - (`maxlengthfilename' - 5 - length(" `y'-`m'-`d'"))' {
		local nlopteilzahl = `r(tmpstrparts)' - 1
		local lastlogpart `=substr(`"`r(tmpstr`nlopteilzahl')'"',1,length(`"`r(tmpstr`nlopteilzahl')'"') - (`:length local lopen' - (`maxlengthfilename' - 5 - length(" `y'-`m'-`d'")) - length(`"`r(tmpstr`r(tmpstrparts)')'"')))'
	}
	else {
		local nlopteilzahl = `r(tmpstrparts)'
		local lastlogpart `=substr(`"`r(tmpstr`nlopteilzahl')'"',1,length(`"`r(tmpstr`nlopteilzahl')'"') - (`:length local lopen' - (`maxlengthfilename' - 5 - length(" `y'-`m'-`d'"))))'
	}
	local lhelp3
	forvalues i = 1(1)`=`nlopteilzahl'-1' {
		if substr(`"`r(tmpstr`=`i'-1')'"',-1,1) == "\" {
			local lhelp3 `lhelp3'\`r(tmpstr`i')'
		}
		else {
			local lhelp3 `lhelp3'`r(tmpstr`i')'
		}
	}
	if substr(`"`r(tmpstr`=`nlopteilzahl'-1')'"',-1,1) == "\" {
		local lhelp3 `lhelp3'\`lastlogpart'
	}
	else {
		local lhelp3 `lhelp3'`lastlogpart'
	}
	local lopen `"`:subinstr local lhelp3 "`zzdta'" " ", all'"'
}
local lopen `lopen' `y'-`m'-`d'
if `:length local lopen' <= `maxlengthstring' {
	return local logstrparts = 1
	return local logstr1 `"`lopen'"'
}
else {
	strsplit `"`:subinstr local lopen " " "`zzdta'", all'"' `piecelen' log
	return add
}

return local done 1
end

* ---------------------------------------
program setlogfile
* ------------------------------------
version 8.2
// Schreibt den Namen des aktuell konstruierten und des zuletzt benutzten Logfiles
// und die Beschreibung in den Dialog
args dta log cmdlog dontchgl1 action piecelen zzdta maxlengthstring maxlenstrinwindow maxlenwindow

// 1a. Write log (first choice) to the dialog window
local enterif 0
if ~ missing(`"`log'"') {
	if `:length local log' <= `maxlengthstring' {
		local enterif = substr(`"`log'"', -5, 5) ~= `".smcl"' & substr(`"`log'"', -4, 4) ~= `".log"'
	}
	else {
		strsplit `"`log'"' `piecelen' log
		local enterif = substr(`"`r(logstr`r(logstrparts)')'"',-5,5) ~= `".smcl"' & substr(`"`r(logstr`r(logstrparts)')'"',-4,4) ~= `".log"'
	}
}

if `enterif' == 1 {
	if length("`log'") > 0 {
		if c(logtype) == "smcl" {
			local log `log'.smcl
		}
		else {
			local log `log'.log
		}
	}
}

if `dontchgl1' == 0 {
	writedlgpath ".rfl_dlg.main.rb_log1default.setlabel" `"`log'"' "" "" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
	if `r(done)' == 0 {
		.rfl_dlg.main.rb_log1default.setlabel `"`log'"'
	}
	.rfl_dlg.main.ed_hil.setvalue `"`log'"'
}

// 1b. Write cmdlog (first choice) to the dialog window
local enterif 0
if ~ missing(`"`cmdlog'"') {
	if `dontchgl1' == 1 {
		// Prepare to write cmdlog to the fi_cmdlogopen control
		local enterif 1
		defrepchar `"`cmdlog'"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
		if `r(done)' == 0 {
			exit
		}
		local zzcmdlog = r(zztaken)
		strsplit `"`:subinstr local cmdlog " " "`zzcmdlog'", all'"' `piecelen' cmdlog
		local ncmdlogteilzahl = r(cmdlogstrparts)
		forvalues i = 1(1)`ncmdlogteilzahl' {
			local cmdlogstr`i' `r(cmdlogstr`i')'
			if index(`"`r(cmdlogstr`i')'"',".") > 0 {
				local lastcmdlogteilhasdot `i'
			}
		}
		local cmdlog
		forvalues i = 1(1)`=`lastcmdlogteilhasdot'-1' {
			if substr(`"`cmdlogstr`=`i'-1''"',-1,1) == "\" {
				local cmdlog `cmdlog'\`cmdlogstr`i''
			}
			else {
				local cmdlog `cmdlog'`cmdlogstr`i''
			}
		}
		if substr(`"`cmdlogstr`=`lastcmdlogteilhasdot'-1''"',-1,1) == "\" {
			local cmdlog `cmdlog'\`=reverse(substr(reverse(`"`cmdlogstr`lastcmdlogteilhasdot''"'), index(reverse(`"`cmdlogstr`lastcmdlogteilhasdot''"'),".")+1,.))'
		}
		else {
			local cmdlog `cmdlog'`=reverse(substr(reverse(`"`cmdlogstr`lastcmdlogteilhasdot''"'), index(reverse(`"`cmdlogstr`lastcmdlogteilhasdot''"'),".")+1,.))'
		}
		local cmdlog `:subinstr local cmdlog "`zzcmdlog'" " ", all'
	}
	else {
		if `:length local cmdlog' <= `maxlengthstring' {
			local enterif = substr(`"`cmdlog'"', -4, 4) ~= `".txt"'
		}
		else {
			strsplit `"`cmdlog'"' `piecelen' cmdlog
			local enterif = substr(`"`r(cmdlogstr`r(cmdlogstrparts)')'"',-4,4) ~= `".txt"'
		}
	}
}

if `enterif' == 1 {
	if length("`cmdlog'") > 0 {
		local cmdlog `cmdlog'.txt
	}
}

if `dontchgl1' == 0 {
	writedlgpath ".rfl_dlg.second.rb_cmdlog1default.setlabel" `"`cmdlog'"' "" "" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
	if `r(done)' == 0 {
		.rfl_dlg.second.rb_cmdlog1default.setlabel `"`cmdlog'"'
	}
	.rfl_dlg.second.ed_hicmdl.setvalue `"`cmdlog'"'
}
else {
//	writedlgpath ".rfl_dlg.second.fi_cmdlogopen.setvalue" `"`cmdlog'"' "" "" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
	// writedlgpath ändert das Format in <file> (<path>), daher
	.rfl_dlg.second.fi_cmdlogopen.setvalue `"`cmdlog'"'
}

// 2. Last log file (2nd choice) and description
if `dontchgl1' == 0 {
	local found 0
	local dtalang
	local loglang
	local deschelp

	quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
	if _rc == 0 {
		if `:length local dta' > `maxlengthstring' {
			strsplit `"`dta'"' `piecelen' dta
			local ndtanofillteilzahl = `r(dtastrparts)'
		}
		tempname rfllog
		file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
		forvalues i = 1(1)16 {
			file read `rfllog' line
		}
		while r(eof) == 0 {
			forvalues i = 2(1)4 {
				file read `rfllog' line
			}
			local dtalang `line'					// dtalang
			file read `rfllog' line
			local cmdloglang `line'				// cmdlog lang
			file read `rfllog' line
			local loglang `line'					// log lang
			file read `rfllog' line
			local desckurz `line'				// Beschreibung kurz
			file read `rfllog' line
			local desclang `line'				// Beschreibung lang
			forvalues i = 9(1)15 {
				file read `rfllog' line
			}
			local marked `line'

			if `:length local dta' == `:length local dtalang' {
				if `:length local dta' <= `maxlengthstring' {
					local found = `"`dtalang'"' == `"`dta'"'
				}
				else {
					local found 1
					forvalues i = 1(1)`ndtanofillteilzahl' {
						if `found' == 1 {
							local found = `"`:piece `i' `piecelen' of "`dta'"'"' == `"`:piece `i' `piecelen' of "`dtalang'"'"'
						}
					}
				}
				if `found' == 1 {
					file seek `rfllog' eof
				}
			}
			file read `rfllog' line
		}
		file close `rfllog'
	}

	if `found' == 1 {
		if `marked' == 1 {
			.rfl_dlg.main.gb_marked.show
			.rfl_dlg.main.tx_marked.show
			.rfl_dlg.main.tx_marked.setlabel "Del"
		}
		else if `marked' == 2 {
			.rfl_dlg.main.gb_marked.show
			.rfl_dlg.main.tx_marked.show
			.rfl_dlg.main.tx_marked.setlabel "Ren"
		}
		else {
			.rfl_dlg.main.gb_marked.hide
			.rfl_dlg.main.tx_marked.hide
		}
	}
	else {
		.rfl_dlg.main.gb_marked.hide
		.rfl_dlg.main.tx_marked.hide
	}
	if `found' == 0 {
		.rfl_dlg.main.ed_hill.setvalue ""
		.rfl_dlg.main.rb_log2last.setlabel `"<no last log file yet>"'
		.rfl_dlg.second.ed_hilcmdl.setvalue ""
		.rfl_dlg.second.rb_cmdlog2last.setlabel `"<no last cmdlog file yet>"'
	}
	else {
		if missing("`loglang'") {
			.rfl_dlg.main.ed_hill.setvalue ""
			.rfl_dlg.main.rb_log2last.setlabel `"<no last log file yet>"'
		}
		else {
			.rfl_dlg.main.ed_hill.setvalue `"`loglang'"'
			writedlgpath ".rfl_dlg.main.rb_log2last.setlabel" `"`loglang'"' "" "" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
			if `r(done)' == 0 {
				.rfl_dlg.main.rb_log2last.setlabel `"`loglang'"'
			}
		}
		if missing("`cmdloglang'") {
			.rfl_dlg.second.ed_hilcmdl.setvalue ""
			.rfl_dlg.second.rb_cmdlog2last.setlabel `"<no last cmdlog file yet>"'
		}
		else {
			.rfl_dlg.second.ed_hilcmdl.setvalue `"`cmdloglang'"'
			writedlgpath ".rfl_dlg.second.rb_cmdlog2last.setlabel" `"`cmdloglang'"' "" "" `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
			if `r(done)' == 0 {
				.rfl_dlg.second.rb_cmdlog2last.setlabel `"`cmdloglang'"'
			}
		}
	}
	if "`action'" == "setlogdesc_in_hidfo" & `found' == 0 {
//		.rfl_dlg.main.ed_hidfo.setvalue ""
	}
	if ("`action'" == "setlogdesc" | "`action'" == "setlogdesc_in_hidfo" ) & `found' == 1 {
		.rfl_dlg.main.tx_desc.setlabel `"`desclang'"'
		if "`action'" == "setlogdesc" {
			.rfl_dlg.main.tx_desc.enable
			.rfl_dlg.main.ed_hid.setvalue `"`desclang'"'
		}
		else {
			.rfl_dlg.main.ed_hidfo.setvalue `"`desclang'"'
		}
		if missing(`"`desclang'"') {
			.rfl_dlg.main.bu_chgdesc.setlabel "Enter description"
		}
		else {
			.rfl_dlg.main.bu_chgdesc.setlabel "Change description"
		}
	}
}
end
// program setlogfile

* ---------------------------------------
program getdesc
* ------------------------------------
version 8.2

args dta piecelen zzdta maxlengthstring
quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
if _rc == 0 {
	if `:length local dta' > `maxlengthstring' {
		strsplit `"`dta'"' `piecelen' dta
		local ndtanofillteilzahl = `r(dtastrparts)'
	}
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
	forvalues i = 1(1)16 {
		file read `rfllog' line
	}
	while r(eof) == 0 {
		forvalues i = 2(1)4 {
			file read `rfllog' line
		}
		local dtalang `line'		// dtalang
		forvalues i = 5(1)8 {
			file read `rfllog' line
		}
		local enterif = `:length local dta' == `:length local dtalang'
		if `enterif' == 1 {
			if `:length local dta' <= `maxlengthstring' {
				local enterif = `"`dtalang'"' == `"`dta'"'
			}
			else {
				forvalues i = 1(1)`ndtanofillteilzahl' {
					if `enterif' == 1 {
						// Hier brauch ich keine Ersetzungen.
						local enterif = `"`:piece `i' `piecelen' of "`dtalang'"'"' == `"`:piece `i' `piecelen' of "`dta'"'"'
					}
				}
			}
		}
		if `enterif' == 1 {
			.rfl_dlg.main.tx_desc.setlabel `"`line'"'
			.rfl_dlg.main.ed_hid.setvalue `"`line'"'
			if missing(`"`line'"') {
				.rfl_dlg.main.bu_chgdesc.setlabel "Enter description"
			}
			else {
				.rfl_dlg.main.bu_chgdesc.setlabel "Change description"
			}
			file seek `rfllog' eof
		}
		forvalues i = 9(1)16 {
			file read `rfllog' line
		}
	}
	file close `rfllog'
}
end

* ---------------------------------------
program showname
* ------------------------------------
version 8.2

args dta log cmdlog desc dtaisdesc piecelen zzdta maxlengthstring maxlenstrinwindow maxlenwindow
// Abkürzung möglich, wenn dtalang, dtakurz und desckurz auf Gleichheit überprüft würden.

local found 0
quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
if _rc == 0 {
	if `:length local dta' > `maxlengthstring' {
		strsplit `"`dta'"' `piecelen' dta
		local ndtanofillteilzahl = `r(dtastrparts)'
	}
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
	forvalues i = 1(1)16 {
		file read `rfllog' line
	}
	while r(eof) == 0 {
		file read `rfllog' line
		file read `rfllog' line
		local dtakurz `line'					// dtakurz
		file read `rfllog' line
		local dtalang `line'					// dtalang
		file read `rfllog' line
		local cmdloglang `line'					// cmdloglang
		file read `rfllog' line
		local loglang `line'					// loglang
		file read `rfllog' line
		local desckurz `line'				// Beschreibung kurz
		file read `rfllog' line
		local desclang `line'				// Beschreibung lang
		forvalues i = 9(1)15 {
			file read `rfllog' line
		}

		if `dtaisdesc' == 0 {
			if `:length local dta' == `:length local dtakurz' {
				local found = `"`dtakurz'"' == `"`dta'"'
			}
			if `found' == 0 {
				if `:length local dta' == `:length local dtalang' {
					local found = `"`dtalang'"' == `"`dta'"'
				}
			}
		}
		else {
			if `:length local dta' == `:length local desckurz' {
				local found = `"`desckurz'"' == `"`dta'"'
			}
			if `found' == 0 {
				if `:length local dta' == `:length local desclang' {
					local found = `"`desclang'"' == `"`dta'"'
				}
			}
		}
		if `found' == 1 {
			file seek `rfllog' eof
		}
		file read `rfllog' line
	}
	file close `rfllog'
}
if `found' == 0 {
	if ~ (missing(`"`dta'"') & missing(`"`log'"') & missing(`"`cmdlog'"') & missing(`"`desc'"')) {
		local dtalang `dta'
		local cmdloglang
		local loglang
		local desclang `desc'
		local found 1
	}
}
if `found' == 1 {
// set trace on


	local pathname1 `dtalang'
	local pathname2 `log'
	local pathname3 `loglang'
	local pathname4 `cmdlog'
	local pathname5 `cmdloglang'
	local varname1 dtalang
	local varname2 log
	local varname3 loglang
	local varname4 cmdlog
	local varname5 cmdloglang

	forvalues i = 1(1)5 {
		local pathstr
		local filestr
		if ~ missing(`"`pathname`i''"') {
			_getpathfile `"`pathname`i''"' `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
			if `r(done)' == 0 {
				exit
			}
			forvalues j = 1(1)`r(pathparts)' {
				if substr(`"`r(pathname`=`j'-1')'"',-1,1) == "\" {
					local pathstr `pathstr'\`r(pathname`j')'
				}
				else {
					local pathstr `pathstr'`r(pathname`j')'
				}
			}
			forvalues j = 1(1)`r(fileparts)' {
				if substr(`"`r(filename`=`j'-1')'"',-1,1) == "\" {
					local filestr `filestr'\`r(filename`j')'
				}
				else {
					local filestr `filestr'`r(filename`j')'
				}
			}
			if ~ missing(r(zztaken)) {
				local filestr `:subinstr local filestr "`r(zztaken)'" " ", all'
				local pathstr `:subinstr local pathstr "`r(zztaken)'" " ", all'
			}
			local `varname`i'' `filestr' (`pathstr')
		}
	}

	local done 0
	local msgpart1before Dataset:
	local msgpart1 `dtalang'
	local msgpart2before Log file:
	local msgpart2 `log'
	if ~ missing("`loglang'") {
		local msgpart3before Last log file:
	}
	else {
		local msgpart3before No last log file
	}
	local msgpart3 `loglang'
	local msgpart4before cmdlog file:
	local msgpart4 `cmdlog'
	if ~ missing("`cmdloglang'") {
		local msgpart5before Last cmdlog file:
	}
	else {
		local msgpart5before No last cmdlog file
	}
	local msgpart5 `cmdloglang'
	if ~ missing("`desclang'") {
		local msgpart6before Description:
	}
	else {
		local msgpart6before No description
	}
	local msgpart6 `desclang'
	forvalues k = 1(1)6 {
		if `:length local msgpart`k'before' + `:length local msgpart`k'' + 1 > `maxlenstrinwindow' {
			shortenstr `"`:subinstr local msgpart`k' " " "`zzdta'", all'"' `=`maxlenstrinwindow'-length("* `msgpart`k'before'")' 0 `piecelen'
			local msgpart`k' *
			forvalues i = 1(1)`r(strparts)' {
				if substr(`"`r(str`=`i'-1')'"',-1,1) == "\" {
					local msgpart`k' `msgpart`k''\`r(str`i')'
				}
				else {
					local msgpart`k' `msgpart`k''`r(str`i')'
				}
			}
			local msgpart`k' `:subinstr local msgpart`k' "`zzdta'" " ", all'
		}
	}
// set trace on
	local startword 1
	while `startword' <= 6 {
		// no string > 254 (maxlenstrinwindow) chars. Less then some 500 (maxlenwindow) chars in total
		local stopword 6
		local msgpart : word `startword' of `"`msgpart1before' `msgpart1'"' `"`msgpart2before' `msgpart2'"' `"`msgpart3before' `msgpart3'"' `"`msgpart4before' `msgpart4'"' `"`msgpart5before' `msgpart5'"' `"`msgpart6before' `msgpart6'"'
		local msglen `:length local msgpart'
		local j `startword'
		while `j' <= 6 {
			local msgpart : word `=`j'+1' of `"`msgpart1before' `msgpart1'"' `"`msgpart2before' `msgpart2'"' `"`msgpart3before' `msgpart3'"' `"`msgpart4before' `msgpart4'"' `"`msgpart5before' `msgpart5'"'  `"`msgpart6before' `msgpart6'"'
			if `msglen' + `:length local msgpart' + `=(`j'-1)*2' > `maxlenwindow' | `=`j'-`startword'+1' == 4 {
				if `j' < `stopword' {
					local stopword `j'
					local j 6
				}
			}
			else {
				if `j' < `stopword' {
					local msglen = `msglen' + `:length local msgpart' + `=(`j'-1)*2'
				}
			}
			local j = `j' + 1
		}
		if `=`startword'+5' == `stopword' {
			window stopbox note `"`msgpart`startword'before' `msgpart`startword''"' `"`msgpart`=`startword'+1'before' `msgpart`=`startword'+1''"' `"`msgpart`=`startword'+2'before' `msgpart`=`startword'+2''"' `"`msgpart`=`startword'+3'before' `msgpart`=`startword'+3''"' `"`msgpart`=`startword'+4'before' `msgpart`=`startword'+4''"' `"`msgpart`=`startword'+5'before' `msgpart`=`startword'+5''"'
		}
		if `=`startword'+4' == `stopword' {
			window stopbox note `"`msgpart`startword'before' `msgpart`startword''"' `"`msgpart`=`startword'+1'before' `msgpart`=`startword'+1''"' `"`msgpart`=`startword'+2'before' `msgpart`=`startword'+2''"' `"`msgpart`=`startword'+3'before' `msgpart`=`startword'+3''"' `"`msgpart`=`startword'+4'before' `msgpart`=`startword'+4''"'
		}
		if `=`startword'+3' == `stopword' {
			window stopbox note `"`msgpart`startword'before' `msgpart`startword''"' `"`msgpart`=`startword'+1'before' `msgpart`=`startword'+1''"' `"`msgpart`=`startword'+2'before' `msgpart`=`startword'+2''"' `"`msgpart`=`startword'+3'before' `msgpart`=`startword'+3''"'
		}
		else if `=`startword'+2' == `stopword' {
			window stopbox note `"`msgpart`startword'before' `msgpart`startword''"' `"`msgpart`=`startword'+1'before' `msgpart`=`startword'+1''"' `"`msgpart`=`startword'+2'before' `msgpart`=`startword'+2''"'
		}
		else if `=`startword'+1' == `stopword' {
			window stopbox note `"`msgpart`startword'before' `msgpart`startword''"' `"`msgpart`=`startword'+1'before' `msgpart`=`startword'+1''"'
		}
		else {
			window stopbox note `"`msgpart`startword'before' `msgpart`startword''"'
		}
		local startword = `stopword' + 1
	}
// set trace off
}
end

* ---------------------------------------
program writedesc
* ---------------------------------------
version 8.2

// Writes new description to log file
args dta desc piecelen zzdta maxlengthstring maxleninlist

local thisfileopened 0
quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
if _rc == 0 {
	if `:length local dta' > `maxlengthstring' {
		strsplit `"`dta'"' `piecelen' dta
		local ndtanofillteilzahl = `r(dtastrparts)'
	}
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
	file read `rfllog' line
	local strucversion `line'
	file read `rfllog' line
	local hidemenu `line'
	file read `rfllog' line
	local rewritemenu `line'
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
	local lastcmds `line'
	forvalues i = 15(1)16 {
		file read `rfllog' line
	}
	local dtanum 0
	while r(eof) == 0 {
		local dtanum = `dtanum' + 1
		local anzopen`dtanum' `line'
		file read `rfllog' line
		local lastopen`dtanum' `line'
		file read `rfllog' line
		local dtakurz`dtanum' `line'
		file read `rfllog' line
		local dtalang`dtanum' `line'
		if `thisfileopened' == 0 {
			local enterif = `:length local dta' == `:length local dtalang`dtanum''
			if `enterif' == 1 {
				if `:length local dta' <= `maxlengthstring' {
					local enterif = `"`dtalang`dtanum''"' == `"`dta'"'
				}
				else {
					local enterif 1
					forvalues i = 1(1)`ndtanofillteilzahl' {
						if `enterif' == 1 {
							local enterif = `"`:piece `i' `piecelen' of "`dtalang`dtanum''"'"' == `"`:piece `i' `piecelen' of "`dta'"'"'
						}
					}
				}
			}
			if `enterif' == 1 {
				local thisfileopened `dtanum'
			}
		}
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
		file read `rfllog' line
	}
	file close `rfllog'
	// Write rfl.log anew, if description is new or changed

	if `thisfileopened' > 0 {
		// Shorten the new description
		if `:length local desc' > `maxleninlist' {
			local newdesckurz = substr(`"`desc'"',1,`=`maxleninlist'-length("...")') + "..."
		}
		else {
			local newdesckurz `desc'
		}
		// Check whether new description exists already
		// Don't allow the same description for different entries. Empty descriptions do not count as doubles
		local exitloop 0
		local j 1
		local deschelp `newdesckurz'
		if ~ missing(`"`newdesckurz'"') {
			while `exitloop' == 0 {
				local k 1
				local exitloop 1
				while `k' <= `dtanum' {
					if `"`desckurz`k''"' == `"`deschelp'"' & `k' ~= `thisfileopened' {
						// Beschreibung existiert schon.
						// Bedingung thisfileopened==k: Vielleicht ist ja nichts geändert worden
						if length(`"`newdesckurz' (`j')"') > `maxleninlist' {
							local deschelp = substr(`"`newdesckurz'"',1,`=`maxleninlist'-length("... (`j')")') + "... (`j')"
						}
						else {
							local deschelp `newdesckurz' (`j')
						}
						local k `dtanum'
						local j = `j' + 1
						local exitloop 0
					}
					local k = `k' + 1
				}
			}
		}
		if `"`desckurz`thisfileopened''"' ~= `"`deschelp'"' {
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
			local i 1
			while `i' <= `dtanum' {
				file write `rfllog' "`anzopen`i''" _n
				file write `rfllog' "`lastopen`i''" _n
				file write `rfllog' `"`dtakurz`i''"' _n
				file write `rfllog' `"`dtalang`i''"' _n
				file write `rfllog' "`cmdloglang`i''" _n
				file write `rfllog' "`loglang`i''" _n
				if `i' == `thisfileopened' {
					file write `rfllog' `"`deschelp'"' _n
					file write `rfllog' `"`desc'"' _n
					if `"`desckurz`i''"' ~= `"`deschelp'"' {
						.rfl_dlg.main.cb_hidedesclist.seton
						.rfl_dlg.main.rb_listdesc.disable
					}
				}
				else {
					file write `rfllog' `"`desckurz`i''"' _n
					file write `rfllog' `"`desclang`i''"' _n
				}
				forvalues j = 9(1)13 {
					file write `rfllog' "" _n
				}
				file write `rfllog' "`newdta`i''" _n
				file write `rfllog' "`del`i''" _n
				local i = `i' + 1
			}
			file close `rfllog'
		}
	}
}
end

* ---------------------------------------
program openfile
* ---------------------------------------
version 8.2
// Öffnet die Dateien
args dta desc log cmdlog fsz msz piecelen zzdta saved closed closel closec mem from maxlengthstring  maxlenwindow maxlenstrinwindow maxleninlist maxlengthfilename hidemenu rewritemenu recentno loadlastlog treatcmdlogpar replacelog replacecmdlog dontwarnlogreplace logbackup lastcmds minmem maxmem memmult

// set trace on
//	disp `"OPENFILE: dta: `dta', desc: `desc', log: `log', fsz: `fsz', msz: `msz', closed: `closed', `closel', `closec'"'
noisily display
local dontoplog 0

if `:length local dta' > `maxlengthstring' {
	strsplit `"`dta'"' `piecelen' dta
	local ndtanofillteilzahl = `r(dtastrparts)'
}

// Read rfl.log
local thisfileopened 0
local dtanum 0
quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
if _rc == 0 {
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
	file read `rfllog' line
	local strucversion `line'
	file read `rfllog' line
	local hidemenufromrfllog `line'
	if missing("`hidemenu'") {
		local hidemenu `line'
	}
	file read `rfllog' line
	local rewritemenufromrfllog `line'
	if missing("`rewritemenu'") {
		local rewritemenu `line'
	}
	file read `rfllog' line
	local recentnofromrfllog `line'
	if missing("`recentno'") {
		local recentno `line'
	}
	file read `rfllog' line
	local loadlastlogfromrfllog `line'
	if missing("`loadlastlog'") {
		local loadlastlog `line'
	}
	file read `rfllog' line
	local treatcmdlogparfromrfllog `line'
	if missing("`treatcmdlogpar'") {
		local treatcmdlogpar `line'
	}
	file read `rfllog' line
	local replacelogfromrfllog `line'
	if missing("`replacelog'") {
		local replacelog `line'
	}
	file read `rfllog' line
	local replacecmdlogfromrfllog `line'
	if missing("`replacecmdlog'") {
		local replacecmdlog `line'
	}
	file read `rfllog' line
	local dontwarnlogreplacefromrfllog `line'
	if missing("`dontwarnlogreplace'") {
		local dontwarnlogreplace `line'
	}
	file read `rfllog' line
	local minmemfromrfllog `line'
	if missing("`minmem'") {
		local minmem `line'
	}
	file read `rfllog' line
	local maxmemfromrfllog `line'
	if missing("`maxmem'") {
		local maxmem `line'
	}
	file read `rfllog' line
	local memmultfromrfllog `line'
	if missing("`memmult'") {
		local memmult `line'
	}
	file read `rfllog' line
	local logbackupfromrfllog `line'
	if missing("`logbackup'") {
		local logbackup `line'
	}
	file read `rfllog' line
	local lastcmdsfromrfllog `line'
	if missing("`lastcmds'") {
		local lastcmds `line'
	}
	forvalues i = 15(1)16 {
		file read `rfllog' line
	}
	while r(eof) == 0 {
		local dtanum = `dtanum' + 1
		local anzopen`dtanum' `line'
		file read `rfllog' line
		local lastopen`dtanum' `line'
		file read `rfllog' line
		local dtakurz`dtanum' `line'
		file read `rfllog' line
		local dtalang`dtanum' `line'
		if `thisfileopened' == 0 {
			local enterif = `:length local dta' == `:length local line'
			if `enterif' == 1 {
				if `:length local dta' <= `maxlengthstring' {
					local enterif = `"`line'"' == `"`dta'"'
				}
				else {
					forvalues i = 1(1)`ndtanofillteilzahl' {
						if `enterif' == 1 {
							local enterif = `"`:piece `i' `piecelen' of "`line'"'"' == `"`:piece `i' `piecelen' of "`dta'"'"'
						}
					}
				}
			}
			if `enterif' == 1 {
				local thisfileopened `dtanum'
			}
		}
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
		file read `rfllog' line
	}
	file close `rfllog'
}
else {
	// fresh start (rfl.log does not yet exist)
	local strucversion version 3.6
	local hidemenufromrfllog "`hidemenu'"
	local rewritemenufromrfllog "`rewritemenu'"
	local recentnofromrfllog "`recentno'"
	local loadlastlogfromrfllog "`loadlastlog'"
	local treatcmdlogparfromrfllog "`treatcmdlogpar'"
	local replacelogfromrfllog "`replacelog'"
	local replacecmdlogfromrfllog "`replacecmdlog'"
	local dontwarnlogreplacefromrfllog "`dontwarnlogreplace'"
	local minmemfromrfllog "`minmem'"
	local maxmemfromrfllog "`maxmem'"
	local memmultfromrfllog "`memmult'"
	local logbackupfromrfllog "`logbackup'"
	local lastcmdsfromrfllog "`lastcmds'"
}

// Log öffnen ******************
if missing("`closel'") {
	local closel 0
}
if missing("`closec'") {
	local closec 0
}
if missing("`closed'") {
	local closed 0
}
if missing("`saved'") {
	local saved 0
}

if `closel' + `closec' + `closed' + `saved' > 0 {
	closefiles `closed' `closel' `closec' `saved' `maxlengthstring' `maxlenwindow' `maxlenstrinwindow' `piecelen' `zzdta'
	local dontoplog = `r(dontoplog)'
}

local fsz= round(round(`fsz',1),1)
local msz= round(round(`msz',1),1)
// Die folgenden 3 Zeilen, weil rfluse den Parameter mem nicht erfordert. Sie stellen sicher,
// daß die Standardeinstellung übernommen wird
if index("`mem'",",") > 0 {
	local mem = subinstr("`mem'",",",".",.)
}
if missing("`mem'") | "`mem'" == "-1" {
	local mem = `msz'/(1024^2)
}
if round(`msz'/(1024^2)) ~= `mem' {
	local msz = floor(round(`mem'*1024^2,1))
}

// open requested files
// 1) log files
if "`log'" == ".smcl" | "`log'" == ".log" {
	local log
}
if ~ missing(`"`log'"') & `dontoplog' == 0 {
	if `:length local log' > `maxlengthstring' {
		defrepchar `"`log'"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
		if `r(done)' == 0 {
			exit
		}
		local zzlog = r(zztaken)
		strsplit `"`:subinstr local log " " "`zzlog'", all'"' `piecelen' log
		local nlogteilzahl = `r(logstrparts)'
		forvalues i = 1(1)`nlogteilzahl' {
			local logstr`i' `r(logstr`i')'
			if index(`"`r(logstr`i')'"',".") > 0 {
				local lastlogteilhasdot `i'
			}
		}
		if `:length local log' + 4 > `maxlengthfilename' {
			local copytolog
			forvalues i = 1(1)`=`lastlogteilhasdot'-1' {
				if substr(`"`logstr`=`i'-1''"',-1,1) == "\" {
					local copytolog `copytolog'\`logstr`i''
				}
				else {
					local copytolog `copytolog'`logstr`i''
				}
			}
			if substr(`"`logstr`=`lastlogteilhasdot'-1''"',-1,1) == "\" {
				local copytolog `copytolog'\`=reverse(substr(reverse(`"`logstr`lastlogteilhasdot''"'), index(reverse(`"`logstr`lastlogteilhasdot''"'),".")+1,.))'
			}
			else {
				local copytolog `copytolog'`=reverse(substr(reverse(`"`logstr`lastlogteilhasdot''"'), index(reverse(`"`logstr`lastlogteilhasdot''"'),".")+1,.))'
			}
			if index(reverse(`"`logstr`lastlogteilhasdot''"'),".") == 5 {
				local copytolog `:subinstr local copytolog "`zzlog'" " ", all'.sbkp
			}
			else {
				local copytolog `:subinstr local copytolog "`zzlog'" " ", all'.lbp
			}
		}
		else {
			local copytolog `log'.bkp
		}
	}
	else {
		local copytolog `log'.bkp
	}
// Alternativ könnte man hier _getfilename verwenden: Nein, in r(filename)kommen nur 80(244) Zeichen zurück
	quietly log
	if missing(r(filename)) {
		local replaceconfirmed 0
		quietly capture confirm file `"`log'"'
		local logexists = _rc == 0
		if `replacelog' == 1 & `logexists' == 1 {
			// do not allow replacing without user input if called from rfluse or menu; unless a backup copy of the log file is made
			if `dontwarnlogreplace' == 1 & ( ~ ("`from'" == "rfluse" | "`from'" == "rfl.menu") | (("`from'" == "rfluse" | "`from'" == "rfl.menu") & `logbackup' == 1)) {
				local replaceconfirmed 1
			}
			else {
				local dispbefore
				local dispafter1 will be replaced. Continue?
				dispmsg `"`log'"' `maxlenwindow' `maxlenstrinwindow' 0 * rusure "" `piecelen' `maxlengthstring' "`dispbefore'" "`dispafter1'"
				if `r(done)' == 1 & `r(yes)' == 1 {
					local replaceconfirmed 1
				}
			}
			if `replaceconfirmed' == 1 {
				if `logbackup' == 1 {
					capture copy `"`log'"' `"`copytolog'"', replace
				}
				capture noisily log using `"`log'"', replace
				if _rc ~= 0 {
					noisily display as error "An error occured while opening " as result `"`log'"' as error ". The file has not been opened."
				}
				else {
					noisily display as result `"`log'"' as text " opened with replace option."
				}
			}
			else {
				noisily disp as text "No log file opened due to user request."
			}
		}
		else {
			capture noisily log using `"`log'"', append
			if _rc ~= 0 {
				noisily display as error "An error occured while opening " as result `"`log'"' as error ". The file has not been opened."
			}
		}
	}
	else {
		noi disp as result `"`log'"' as error " has not been opened, " as result r(filename) as error " is still in use."
		if length(`"`r(filename)'"') >= `=`maxlengthstring'-1' {
			noi disp as text "(The file name of the open log file may be abbreviated in this message)"
		}
	}
}
else {
	noisily disp as text "No log file opened."
}

// open cmdlog
if "`cmdlog'" == ".txt" {
	local cmdlog
}

local cmdlogopensuccess 0
if ~ missing(`"`cmdlog'"') & `dontoplog' == 0 {
	if `:length local cmdlog' > `maxlengthstring' {
		defrepchar `"`cmdlog'"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
		if `r(done)' == 0 {
			exit
		}
		local zzcmdlog = r(zztaken)
		strsplit `"`:subinstr local cmdlog " " "`zzcmdlog'", all'"' `piecelen' cmdlog
		local ncmdlogteilzahl = `r(cmdlogstrparts)'
		forvalues i = 1(1)`ncmdlogteilzahl' {
			local cmdlogstr`i' `r(cmdlogstr`i')'
			if index(`"`r(cmdlogstr`i')'"',".") > 0 {
				local lastcmdlogteilhasdot `i'
			}
		}
		if `:length local cmdlog' + 4 > `maxlengthfilename' {
			local copytocmdlog
			forvalues i = 1(1)`=`lastcmdlogteilhasdot'-1' {
				if substr(`"`cmdlogstr`=`i'-1''"',-1,1) == "\" {
					local copytocmdlog `copytocmdlog'\`cmdlogstr`i''
				}
				else {
					local copytocmdlog `copytocmdlog'`cmdlogstr`i''
				}
			}
			if substr(`"`cmdlogstr`=`lastcmdlogteilhasdot'-1''"',-1,1) == "\" {
				local copytocmdlog `copytocmdlog'\`=reverse(substr(reverse(`"`cmdlogstr`lastcmdlogteilhasdot''"'), index(reverse(`"`cmdlogstr`lastcmdlogteilhasdot''"'),".")+1,.))'
			}
			else {
				local copytocmdlog `copytocmdlog'`=reverse(substr(reverse(`"`cmdlogstr`lastcmdlogteilhasdot''"'), index(reverse(`"`cmdlogstr`lastcmdlogteilhasdot''"'),".")+1,.))'
			}
			local copytocmdlog `:subinstr local copytocmdlog "`zzcmdlog'" " ", all'.bkp
		}
		else {
			local copytocmdlog `cmdlog'.bkp
		}
	}
	else {
		local copytocmdlog `log'.bkp
	}
// Alternativ könnte man hier _getfilename verwenden: Nein, in r(filename)kommen nur 80(244) Zeichen zurück
	quietly cmdlog
	if missing(r(filename)) {
		local replaceconfirmed 0
		quietly capture confirm file `"`cmdlog'"'
		local cmdlogexists = _rc == 0
		if `replacecmdlog' == 1 & `cmdlogexists' == 1 {
			// do not allow replacing without user input if called from rfluse or menu, unless a backup copy of the log file made
			if `dontwarnlogreplace' == 1 & ( ~ ("`from'" == "rfluse" | "`from'" == "rfl.menu") | (("`from'" == "rfluse" | "`from'" == "rfl.menu") & `logbackup' == 1)) {
				local replaceconfirmed 1
			}
			else {
				local dispbefore
				local dispafter1 will be replaced. Continue?
				dispmsg `"`cmdlog'"' `maxlenwindow' `maxlenstrinwindow' 0 * rusure "" `piecelen' `maxlengthstring' "`dispbefore'" "`dispafter1'"
				if `r(done)' == 1 & `r(yes)' == 1 {
					local replaceconfirmed 1
				}
			}
			if `replaceconfirmed' == 1 {
				if `logbackup' == 1 {
					capture copy `"`cmdlog'"' `"`copytocmdlog'"', replace
				}
				capture noisily cmdlog using `"`cmdlog'"', replace
				if _rc ~= 0 {
					noisily display as error "An error occured while opening " as result `"`cmdlog'"' as error ". The file has not been opened."
				}
				else {
					noisily display as result `"`cmdlog'"' as text " opened with replace option."
					local cmdlogopensuccess 1
				}
			}
			else {
				noisily disp as text "No cmdlog file opened due to user request."
			}
		}
		else {
			capture noisily cmdlog using `"`cmdlog'"', append
			if _rc ~= 0 {
				noisily display as error "An error occured while opening " as result `"`cmdlog'"' as error ". The file has not been opened."
			}
			else {
				local cmdlogopensuccess 1
			}
		}
	}
	else {
		noi disp as result `"`cmdlog'"' as error " has not been opened, " as result r(filename) as error " is still in use."
		if length(`"`r(filename)'"') >= `=`maxlengthstring'-1' {
			noi disp as text "(The file name of the open cmdlog file may be abbreviated in this message.)"
		}
	}
}
else {
	noisily disp as text "No cmdlog file opened."
}

// If cmdlog opened successfully: Push last non-empty `lastcmds' to review window
if `cmdlogopensuccess' == 1 {
	quietly capture confirm file `"`cmdlog'"'
	if _rc == 0 {
		tempname rflcmd
		file open `rflcmd' using `"`cmdlog'"', read text
		local linenum 0
		// There must be a file read before r(eof) is evaluated, otherwise r(eof) is missing
		file read `rflcmd' line
		local linenum = `linenum' + 1
		while r(eof) == 0 {
			file read `rflcmd' line
			local linenum = `linenum' + 1
		}
		local linenum = `linenum' - 1
		file seek `rflcmd' tof
		forvalues i = 1(1)`=`linenum'-`lastcmds'' {
			file read `rflcmd' line
		}
		file read `rflcmd' line
		if ~ missing(`"`macval(line)'"') {
			window push `macval(line)'
		}
		while r(eof) == 0 {
			file read `rflcmd' line
			if ~ missing(`"`macval(line)'"') {
				window push `macval(line)'
			}
		}
		file close `rflcmd'
	}
}

// set memory *************
quietly capture set memory `msz'b
local errorno = _rc
if _rc ~= 0 {
//	quietly describe
	if (c(N) + c(k) > 0) {
		disp as error "Memory size could not be set" as text ", data in memory."
	}
	else {
		if `errorno' == 4 {
			if c(stata_version) >= 9 {
				capture window stopbox rusure "Memory size could not be set, probably because there's something in Mata." "Clear Mata?" "(If you press CANCEL, the dataset will be loaded only if there is enough memory allocated to Stata.)"
				if _rc == 0 {
					version 9: mata: mata clear
					quietly capture set memory `msz'b
					if _rc ~= 0 {
						disp as error "Memory size could not be set." as text " You may clear Mata manually. See [M] mata clear."
					}
				}
			}
			else {
				disp as error "Memory size could not be set" as text " for some unknown reason (data in memory?)."
			}
		}
		else if `errorno' == 909 {
			disp as error "Memory size could not be set" as text " (op. sys. refuses to provide memory)."
		}
		else if `errorno' == 912 {
			disp as error "Memory size could not be set" as text " (Memory size value too large)."
		}
		else {
			disp as error "Memory size could not be set" as text " for some unknown reason (not enough memory?)."
		}
	}
}

if missing(`"`dta'"') | `dontoplog' == 1 {
	noisily display as text "No dataset loaded."
}
else {
	// Open data file *************
	if (c(N) + c(k) > 0) {
		disp as result `"`dta'"' as error " has not been opened" as text " because there are data in memory. You must explicitly tell rfl to drop the data in memory."
	}
	else {
		local anfzeit = "$S_TIME"
		capture use `"`dta'"'    // Ist drop all weiter oben überhaupt nötig? Oder soll ich ohne clear öffnen?
		noisily display
		if _rc ~= 0 {
			noisily display as error "An error occurred while opening " as result `"`dta'"' as error ". The file has not been opened."
		}
		else {
			// Place the file under Stata's Open recent menu
			if c(stata_version) >= 9 {
				window menu add_recentfiles `"`dta'"', rlevel(-1)
			}
			local lfsz = round(`fsz'/1024,1)
			local lfsz : display %-`=length("`lfsz'") + int(length("`lfsz'")/3)'.0fc `lfsz'
			local lmsz = trim("`lfsz'")
			noisily display as result `"`dta'"' as text " opened (Size: " as result "`lfsz'" as text " KB)."
			capture which elapse
			if _rc == 0 {
				elapse "`anfzeit'" `"To open `dta'"'
			}
			else {
				disp `"`dta' opened."'
			}
//			local lmsz : display %-2.0fc `=round(`msz'/1024,1)'
			local lmsz : display %-`=length("`=`msz'/1024'") + int(length("`=`msz'/1024'")/3)'.0fc `=`msz'/1024'
			local lmsz = trim("`lmsz'")

			noisily display as text "Memory allocated to Stata: " as result "`lmsz' KB"

			makeshortdta `"`dta'"' `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow' `maxleninlist' "`zzdta'"
			local exitaftertitle `"`r(exitaftertitle)'"'
			if `exitaftertitle' == 1 {
				local filesave `"`r(filename)'"'
			}
			else {
				local filesave `r(filesave)'
				local pathsave `r(pathsave)'
			}
			// reset title
			if c(os) ~= "MacOSX" {
				if ~ missing(`"`pathsave'"') {
					window manage maintitle `"`filesave' (`pathsave')"'
				}
				else {
					window manage maintitle `"`filesave'"'
				}
			}
			if `exitaftertitle' == 1 {
				local dispbefore
				local dispafter1 cannot be included in the recent files list.
				local dispafter2
				local dispafter3
				dispmsg `"`dta'"' `maxlenwindow' `maxlenstrinwindow' 0 * note "" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
			}
			else {
				local dtakurz `"`filesave' (`pathsave')"'
				// Check whether dtakurz already exists
				local exitloop 0
				local j 1
				local strpart
				while `exitloop' == 0 {
					local k 1
					local exitloop 1
					while `k' <= `dtanum' {
						if `"`dtakurz`k''"' == `"`dtakurz'"' & `k' ~= `thisfileopened' {
							// dtakurz already exists: shorten pathsave
							shortenstr `"`:subinstr local pathsave" " "`zzdta'", all'"' `"`=`:length local pathsave'-length("* [`j']")'"' 2 `piecelen'
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
				quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
				tempname rfllog
				file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', write text replace
				file write `rfllog' "`strucversion'" _n
				file write `rfllog' "`hidemenufromrfllog'" _n
				file write `rfllog' "`rewritemenufromrfllog'" _n
				file write `rfllog' "`recentnofromrfllog'" _n
				file write `rfllog' "`loadlastlogfromrfllog'" _n
				file write `rfllog' "`treatcmdlogparfromrfllog'" _n
				file write `rfllog' "`replacelogfromrfllog'" _n
				file write `rfllog' "`replacecmdlogfromrfllog'" _n
				file write `rfllog' "`dontwarnlogreplacefromrfllog'" _n
				file write `rfllog' "`minmemfromrfllog'" _n
				file write `rfllog' "`maxmemfromrfllog'" _n
				file write `rfllog' "`memmultfromrfllog'" _n
				file write `rfllog' "`logbackupfromrfllog'" _n
				file write `rfllog' "`lastcmdsfromrfllog'" _n
				forvalues i = 15(1)15 {
					file write `rfllog' "" _n
				}
				// Write first entry to rflm.log
				local i 1
				local anzopenwritten 0

				// Write rfl.log
				// The file just opened is written as the first entry
				// anzopen = anzopen + 1 and lastopen = 5
				// The rest of the entries are written after the one just opened
				// Their lastopen has to be corrected by -1, if their position is greater then the lastopen of the file just opened
				if `thisfileopened' == 0 {
					file write `rfllog' "1" _n
				}
				else {
					file write `rfllog' "`=`anzopen`thisfileopened'' + 1'" _n
				}
				// Zuletzt geöffnet
				file write `rfllog' "5" _n
				// dtakurz schreiben
				file write `rfllog' `"`dtakurz'"' _n
				// dtalang schreiben
				file write `rfllog' `"`dta'"' _n
				// logkurz und loglang schreiben
				if `thisfileopened' == 0 {
					file write `rfllog' `"`cmdlog'"' _n
					file write `rfllog' `"`log'"' _n
				}
				else {
					if ~ missing(`"`cmdlog'"') {
						file write `rfllog' `"`cmdlog'"' _n
					}
					else {
						file write `rfllog' `"`cmdloglang`thisfileopened''"' _n
					}
					if ~ missing(`"`log'"') {
						file write `rfllog' `"`log'"' _n
					}
					else {
						file write `rfllog' `"`loglang`thisfileopened''"' _n
					}
				}
				if missing(`"`desc'"') & missing(`"`desclang`thisfileopened''"') {
					local desc `: data label'
				}
				if missing(`"`desc'"') {
					// no existing desc shall be overwritten with an empty string
					file write `rfllog' `"`desckurz`thisfileopened''"' _n
					file write `rfllog' `"`desclang`thisfileopened''"' _n
				}
				else {
					// shorten description
					if `:length local desc' > `maxleninlist' {
						local newdesckurz = substr(`"`desc'"',1,`=`maxleninlist'-length("...")') + "..."
					}
					else {
						local newdesckurz `desc'
					}
					// do not allow duplicate short description entries
					local exitloop 0
					local j 1
					local deschelp `newdesckurz'
					if ~ missing(`"`newdesckurz'"') {
						while `exitloop' == 0 {
							local k 1
							local exitloop 1
							while `k' <= `dtanum' {
								if `"`desckurz`k''"' == `"`deschelp'"' & `k' ~= `thisfileopened' {
									// Beschreibung existiert schon.
									// Bedingung i==k: Vielleicht ist ja nichts geändert worden
									if length(`"`newdesckurz' (`j')"') > `maxleninlist' {
										local deschelp = substr(`"`newdesckurz'"',1,`=`maxleninlist'-length("... (`j')")') + "... (`j')"
									}
									else {
										local deschelp `newdesckurz' (`j')
									}
									local k `dtanum'
									local j = `j' + 1
									local exitloop 0
								}
								local k = `k' + 1
							}
						}
					}
					file write `rfllog' `"`deschelp'"' _n
					file write `rfllog' `"`desc'"' _n
				}

				forvalues i = 9(1)13 {
					file write `rfllog' "" _n
				}

				if `thisfileopened' == 0 {
					file write `rfllog' "" _n
					file write `rfllog' "0" _n
				}
				else {
					file write `rfllog' "`newdta`thisfileopened''" _n
					file write `rfllog' "`del`thisfileopened''" _n
				}
				// The rest of the entries
				local j 1

				local menuitem`j' `"`dtakurz'"'

				forvalues i = 1 2 to `dtanum' {
					if `i' ~= `thisfileopened' {
						local j = `j' + 1
						file write `rfllog' "`anzopen`i''" _n
						if `thisfileopened' == 0 {
							file write `rfllog' "`=`lastopen`i'' - 1'" _n
						}
						else {
							if `lastopen`i'' > `lastopen`thisfileopened'' {
								file write `rfllog' `"`=`lastopen`i'' - 1'"' _n
							}
							else {
								file write `rfllog' `"`lastopen`i''"' _n
							}
						}
						file write `rfllog' `"`dtakurz`i''"' _n
						file write `rfllog' `"`dtalang`i''"' _n
						file write `rfllog' `"`cmdloglang`i''"' _n
						file write `rfllog' `"`loglang`i''"' _n
						file write `rfllog' `"`desckurz`i''"' _n
						file write `rfllog' `"`desclang`i''"' _n
						forvalues k = 9(1)13 {
							file write `rfllog' "" _n
						}
						file write `rfllog' `"`newdta`i''"' _n
						file write `rfllog' `"`del`i''"' _n
						local menuitem`j' `"`dtakurz`i''"'
					}
				}
				file close `rfllog'
				// Append to  menu or rewrite menu
				if $rfl_SETMENU > 0 {
					if `thisfileopened' == 0 | `thisfileopened' > $rfl_SETMENU_no {
						window menu append item "rfl..." `"`dtakurz'"' `"rfluse `dtakurz', from(rfl.menu)"'
						global rfl_SETMENU_no = $rfl_SETMENU_no + 1
					}
					if `rewritemenu' {
						window menu clear
						rflsetmenu `recentno' `rewritemenu' `dtanum' `"`menuitem1'"' `"`menuitem2'"' `"`menuitem3'"' `"`menuitem4'"' `"`menuitem5'"' `"`menuitem6'"' `"`menuitem7'"' `"`menuitem8'"' `"`menuitem9'"' `"`menuitem10'"' `"`menuitem11'"' `"`menuitem12'"' `"`menuitem13'"' `"`menuitem14'"' `"`menuitem15'"' `"`menuitem16'"' `"`menuitem17'"' `"`menuitem18'"' `"`menuitem19'"' `"`menuitem20'"' `"`menuitem21'"' `"`menuitem22'"' `"`menuitem23'"' `"`menuitem24'"' `"`menuitem25'"' `"`menuitem26'"' `"`menuitem27'"' `"`menuitem28'"' `"`menuitem29'"' `"`menuitem30'"'
					}
				}
			}
		}
	}
}

quietly memory
local fmsz = r(M_total)-_N*r(size_ptr)-_N*r(width)-r(M_dyn)
local fmp = `fmsz'/r(M_total)*100
local fmp : display %-2.1fc `fmp'
local lmsz= round(`fmsz'/1024,1)
local lmsz : display %-`=length("`lmsz'") + int(length("`lmsz'")/3)'.0fc `lmsz'
noisily display as text "Free memory: " as result "`lmsz' KB (`fmp'%)" as text "."

end

* ---------------------------------------
program closefiles, rclass
* ------------------------------------
version 8.2
args closed closel closec saved maxlengthstring maxlenwindow maxlenstrinwindow piecelen zzdta
// Schließen, was geschlossen werden soll
return local dontoplog = 0

if `closel' == 1 {
	quietly log
	local logold `r(filename)'
	if ~ missing(`"`logold'"') {
		capture log close
		if _rc == 0 {
			disp as result `"`logold'"' as text " closed."
		}
	}
}
if `closec' == 1 {
	quietly cmdlog
	local logold `r(filename)'
	if ~ missing(`"`logold'"') {
		capture cmdlog close
		if _rc == 0 {
			disp as result `"`logold'"' as text " closed."
		}
	}
}

local savedata 0
local datasaved 0
local closedata 0
local dataclosed 0
local forceclose 0

if c(N) + c(k) > 0 {
	// Save only if data in memory
	if `saved' == 1 {
		local savedata 1
		if missing(`"$S_FN"') {
			capture window fsave FILESAVE "Save data in memory" "Stata Data (*.dta)"
			if _rc ~= 0 {
				disp "Data in memory not saved. Operation cancelled. No dataset opened, data still in memory."
				local savedata 0
				return local dontoplog = 1
			}
		}
		else {
			global FILESAVE $S_FN
		}
	}
	if `closed' == 1 {
		local closedata 1
		if c(changed) == 1 & ~ `savedata' {
			local savedata 1
			if ~ missing(`"$S_FN"') {
				local dispbefore
				local dispafter1 has been changed and should be saved. Press OK to save the file.
				local dispafter2 If you press CANCEL, you will be offered a choice between dropping the data from memory or cancelling the loading of the selected file.
				local dispafter3
				dispmsg `"$S_FN"' `maxlenwindow' `maxlenstrinwindow' 0 * rusure "" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
			}
			else {
				local dispbefore
				local dispafter1 There are unsaved data in memory. Press OK to save them.
				local dispafter2 If you press CANCEL, you will be offered a choice between dropping the data from memory or cancelling the loading of the selected file.
				local dispafter3
				dispmsg `""' `maxlenwindow' `maxlenstrinwindow' 0 "" rusure "" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
			}
			if `r(done)' == 1 & `r(yes)' == 1 {
				// Save data
				local savedata 1
				if ~ missing(`"$S_FN"') {
					_getpathfile `"$S_FN"' `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
					if `r(done)' == 0 {
						_getfilename `"$S_FN"'
						global FILESAVE `r(filename)'
						capture window fsave FILESAVE "Save $FILESAVE" "Stata Data (*.dta)"
					}
					else {
						global PATHSAVE
						forvalues i = 1(1)`r(pathparts)' {
							if substr(`"`r(pathname`=`i'-1')'"',-1,1) == "\" {
								global PATHSAVE $PATHSAVE\`r(pathname`i')'
							}
							else {
								global PATHSAVE $PATHSAVE`r(pathname`i')'
							}
						}
						global FILESAVE
						forvalues i = 1(1)`r(fileparts)' {
							if substr(`"`r(filename`=`i'-1')'"',-1,1) == "\" {
								global FILESAVE $FILESAVE\`r(filename`i')'
							}
							else {
								global FILESAVE $FILESAVE`r(filename`i')'
							}
						}
						if ~ missing(r(zztaken)) {
							global FILESAVE `:subinstr global FILESAVE "`r(zztaken)'" " ", all'
							global PATHSAVE `:subinstr global PATHSAVE "`r(zztaken)'" " ", all'
						}
						capture window fsave FILESAVE "Save $FILESAVE (originally from $PATHSAVE)" "Stata Data (*.dta)"
					}
				}
				else {
					capture window fsave FILESAVE "Save data in memory" "Stata Data (*.dta)"
				}
				if _rc ~= 0 {
					local savedata 0
					local closedata 0
				}
			}
			else if `r(done)' == 0 {
				local savedata 0
				local closedata 0
			}
			else if `r(yes)' == 0 {
				local savedata 0
				if ~ missing(`"$S_FN"') {
					local dispbefore
					local dispafter1 has been changed. You have chosen not to save the file.
					local dispafter2 Press OK to drop the data from memory, or CANCEL if you want to cancel the loading of the selected dataset.
					local dispafter3
					dispmsg `"$S_FN"' `maxlenwindow' `maxlenstrinwindow' 0 * rusure "" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
				}
				else {
					local dispbefore
					local dispafter1 There are unsaved data in memory. You have chosen not to save them.
					local dispafter2 Press OK to drop the data from memory, or CANCEL if you want to cancel the loading of the selected dataset.
					local dispafter3
					dispmsg `""' `maxlenwindow' `maxlenstrinwindow' 0 "" rusure "" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
				}
				if `r(done)' == 1 & `r(yes)' == 1 {
					local forceclose 1
					// Drop data, savedata and closedata are both set to 1
				}
				else if `r(done)' == 0 {
					// Cancel operation
					local closedata 0
				}
				else if `r(yes)' == 0 {
					// Cancel operation
					local closedata 0
				}
			}
		}
	}
	if `savedata' == 1 & ~ missing(`"$FILESAVE"') {
		local anfzeit = "$S_TIME"
		capture save "$FILESAVE"
		local datasaved = _rc == 0
		if ~ `datasaved' {
			local dispbefore
			local dispafter1 will be overwritten.
			local dispafter2 Press OK to continue or CANCEL to abort.
			local dispafter3
			dispmsg `"$FILESAVE"' `maxlenwindow' `maxlenstrinwindow' 0 * rusure "" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
			if _rc == 0 {
				local anfzeit = "$S_TIME"
				capture save "$FILESAVE", replace
				local datasaved = _rc == 0
			}
		}
		if `datasaved' {
			capture which elapse
			if _rc == 0 {
				elapse "`anfzeit'" "$FILESAVE: Saving"
			}
			else {
				disp as result `"$FILESAVE"' as text " saved."
			}
		}
	}
	if (`saved' | `savedata' | c(changed)) & ~ `datasaved' & ~ `forceclose' {
		local closedata 0
		return local dontoplog = 1
		if ~ missing(`"$S_FN"') {
			disp as result "$S_FN" as error " not saved."
		}
		else {
			disp as text "Data in memory" as error " not saved."
		}
	}
	if `closedata' == 1 {
		if ~ missing(`"$S_FN"') {
			disp as result "$S_FN" as text " dropped."
		}
		else {
			disp as text "Data in memory dropped."
		}
		drop _all
		if c(os) ~= "MacOSX" {
			window manage maintitle reset
		}
		disp
	}
	else if `closed' == 1 {
		if ~ missing(`"$S_FN"') {
			disp as result "$S_FN" as error " has not been dropped from memory."
		}
		else {
			disp as error "Data in memory have not been dropped."
		}
		return local dontoplog = 1
	}
	quietly capture macro drop FILESAVE
	quietly capture macro drop PATHSAVE
}
end

* ---------------------------------------
program _getpathfile, rclass
* ------------------------------------
version 8.2
args pathfile piecelen maxlengthstring maxlenstrinwindow maxlenwindow

return local done = 0
if `:length local pathfile' <= `maxlengthstring' {
	_getfilename `"`pathfile'"'
	return local filename1 `r(filename)'
	return local pathname1 `=substr("`pathfile'",1,length("`pathfile'")-length("`r(filename)'")-1)'
	return local fileparts = 1
	return local pathparts = 1
	return local done = 1
}
else {
	// do it yourself
	defrepchar `"`pathfile'"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
	local zztaken = r(zztaken)
	if `r(done)' == 0 {
		return local done = 0
		exit
	}
	strsplit `"`:subinstr local pathfile " " "`zztaken'", all'"' `piecelen' paf
	forvalues i = 1(1)`r(pafstrparts)' {
		if index(`"`r(pafstr`i')'"',"/") + index(`"`r(pafstr`i')'"',"\") > 0 {
			local lastteilhasslash = `i'
		}
	}
	local slash \
	if index(`"`r(pafstr`lastteilhasslash')'"',"/") * index(`"`r(pafstr`lastteilhasslash')'"',"\") > 0 {
		if index(reverse(`"`r(pafstr`lastteilhasslash')'"'),"/") < index(reverse(`"`r(pafstr`lastteilhasslash')'"'),"\") {
			local slash /
		}
	}
	else {
		if index(`"`r(pafstr`lastteilhasslash')'"',"/") > 0 {
			local slash /
		}
	}
	forvalues i = 1(1)`=`lastteilhasslash'-1' {
		return local pathname`i' `"`r(pafstr`i')'"'
	}
	return local pathname`lastteilhasslash' `"`=reverse(substr(reverse("`r(pafstr`lastteilhasslash')'"), index(reverse("`r(pafstr`lastteilhasslash')'"),"`slash'")+1,.))'"'
	return local pathparts `lastteilhasslash'

	return local filename1 `"`=reverse(substr(reverse("`r(pafstr`lastteilhasslash')'"), 1, index(reverse("`r(pafstr`lastteilhasslash')'"),"`slash'")-1))'"'
	forvalues i = `=`lastteilhasslash'+1'(1)`r(pafstrparts)' {
		return local filename`=`i'-`lastteilhasslash'+1' `"`r(pafstr`i')'"'
	}
	return local fileparts = `r(pafstrparts)' - `lastteilhasslash' + 1
	return local zztaken `zztaken'
	return local done = 1
}
end

* ---------------------------------------
program dellistentry, rclass
* ---------------------------------------
version 8.2
// Markiert einen Listeneintrag zum Löschen oder zum Umbenennen
// args dta action dtaisdesc zzdta dellistentry piecelen maxlengthstring maxlenstrinwindow maxlenwindow
args dta newdta action dtaisdesc zzdta piecelen maxlengthstring maxlenstrinwindow maxlenwindow

// If dta and newdta are equal, do nothing
if `:length local dta' > `maxlengthstring' {
	strsplit `"`dta'"' `piecelen' dta
	local ndtanofillteilzahl = `r(dtastrparts)'
}
local enterif = `:length local dta' == `:length local newdta'
if `enterif' == 1 {
	if `:length local dta' <= `maxlengthstring' {
		local enterif = `"`newdta'"' == `"`dta'"'
	}
	else {
		forvalues i = 1(1)`ndtanofillteilzahl' {
			if `enterif' == 1 {
				local enterif = `"`:piece `i' `piecelen' of "`newdta'"'"' == `"`:piece `i' `piecelen' of "`dta'"'"'
			}
		}
	}
}
if `enterif' == 1 {
	local dispbefore You have chosen to rename
	local dispafter1 to itself. Please try again.
	local dispafter2
	local dispafter3
	dispmsg `"`dta'"' `maxlenwindow' `maxlenstrinwindow' 0 * note "`zzdta'" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
	exit
}

if "`action'" == "dellistentry" {
	local dispbefore
	local dispafter1 will be marked for removal from the files lists. Press OK to continue, otherwise press CANCEL.
	local dispafter2 (The actual removal from the files lists will take effect only after rfl has been restarted.)
	local dispafter3
}
else {
	local dispbefore
	local dispafter1 will be marked for renaming in the files lists. Press OK to continue, otherwise press CANCEL.
	local dispafter2 (The actual renaming in the files lists will take effect only after rfl has been restarted.)
	local dispafter3
}
dispmsg `"`dta'"' `maxlenwindow' `maxlenstrinwindow' 0 * rusure "`zzdta'" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
if `r(yes)' == 0 {
	return local done = 0
	exit
}
local thisfileopened 0
local dtanum 0
quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
if _rc == 0 {
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
	file read `rfllog' line
	local strucversion `line'
	file read `rfllog' line
	local hidemenu `line'
	file read `rfllog' line
	local rewritemenu `line'
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
	local lastcmds `line'
	forvalues i = 15(1)16 {
		file read `rfllog' line
	}
	while r(eof) == 0 {
		local dtanum = `dtanum' + 1
		local anzopen`dtanum' `line'
		file read `rfllog' line
		local lastopen`dtanum' `line'
		file read `rfllog' line
		local dtakurz`dtanum' `line'
		file read `rfllog' line
		local dtalang`dtanum' `line'
		if `thisfileopened' == 0 {
			local enterif = `:length local dta' == `:length local line'
			if `enterif' == 1 {
				if `:length local dta' <= `maxlengthstring' {
					local enterif = `"`line'"' == `"`dta'"'
				}
				else {
					forvalues i = 1(1)`ndtanofillteilzahl' {
						if `enterif' == 1 {
							local enterif = `"`:piece `i' `piecelen' of "`line'"'"' == `"`:piece `i' `piecelen' of "`dta'"'"'
						}
					}
				}
			}
			if `enterif' == 1 {
				local thisfileopened `dtanum'
			}
		}
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
		file read `rfllog' line
	}
	file close `rfllog'
	// Write rfl.log anew. When thisfileopened == 0, a description has been changed: Do nothing
	if `thisfileopened' > 0 {
		if "`action'" == "renlistentry" {
			// If a list entry is to be renamed, first look if there already is another list entry
			// with the same dta; ask for action if found
			local k 1
			strsplit `"`newdta'"' `piecelen' dta
			local ndtanofillteilzahl = `r(dtastrparts)'
			while `k' <= `dtanum' {
				// look for dtalang
				local enterif = `:length local dtalang`k'' == `:length local newdta' & `k' ~= `thisfileopened'
				if `enterif' == 1 {
					if `:length local dtalang`k'' <= `maxlengthstring' {
						local enterif = `"`newdta'"' == `"`dtalang`k''"'
					}
					else {
						forvalues i = 1(1)`ndtanofillteilzahl' {
							if `enterif' == 1 {
								local enterif = `"`:piece `i' `piecelen' of "`newdta'"'"' == `"`:piece `i' `piecelen' of "`dtalang`k''"'"'
							}
						}
					}
				}
				// look for newdta
				if `enterif' == 0 {
					local enterif = `:length local newdta`k'' == `:length local newdta' & `k' ~= `thisfileopened'
					if `enterif' == 1 {
						if `:length local newdta`k'' <= `maxlengthstring' {
							local enterif = `"`newdta'"' == `"`newdta`k''"'
						}
						else {
							forvalues i = 1(1)`ndtanofillteilzahl' {
								if `enterif' == 1 {
									local enterif = `"`:piece `i' `piecelen' of "`newdta'"'"' == `"`:piece `i' `piecelen' of "`newdta`k''"'"'
								}
							}
						}
					}
				}
				if `enterif' == 1 {
					// dta already exists in the files list, or another file is to be renamed to the same file name
					// Sum anzopen, set lastopen to highest priority, write info from the to-be-renamed
					// file to the one found, mark the to-be-renamed list entry for deletion
					local dispbefore Renaming
					local dispafter1 would create a double entry.
					local dispafter2 Press OK to remove it from the files list and preserve the other entry (appropriate information will be moved to the other entry).
					local dispafter3 CANCEL will leave both entries in the files list untouched.
					dispmsg `"`dta'"' `maxlenwindow' `maxlenstrinwindow' 2 * rusure "`zzdta'" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
					if `r(yes)' == 0 {
						return local done = 0
						exit
					}
					if _rc == 0 {
						local anzopen`k' = `anzopen`k'' + `anzopen`thisfileopened''
						if missing(`"`cmdloglang`k''"') {
							local cmdloglang`k' `cmdloglang`thisfileopened''
						}
						if missing(`"`loglang`k''"') {
							local loglang`k' `loglang`thisfileopened''
						}
						if missing(`"`desckurz`k''"') {
							local desckurz`k' `desckurz`thisfileopened''
						}
						if missing(`"`desclang`k''"') {
							local desclang`k' `desclang`thisfileopened''
						}
						local del`thisfileopened' 1
						local action dellistentry
					}
					local k `dtanum'
				}
				local k = `k' + 1
			}
		}
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
		local i 1
		forvalues i = 1(1)`dtanum' {
			file write `rfllog' "`anzopen`i''" _n
			file write `rfllog' "`lastopen`i''" _n
			file write `rfllog' `"`dtakurz`i''"' _n
			file write `rfllog' `"`dtalang`i''"' _n
			file write `rfllog' "`cmdloglang`i''" _n
			file write `rfllog' "`loglang`i''" _n
			file write `rfllog' `"`desckurz`i''"' _n
			file write `rfllog' `"`desclang`i''"' _n
			forvalues j = 9(1)13 {
				file write `rfllog' "" _n
			}
			if `i' == `thisfileopened' {
				if "`action'" == "renlistentry" {
					file write `rfllog' `"`newdta'"' _n
					file write `rfllog' "2" _n
					.rfl_dlg.main.gb_marked.show
					.rfl_dlg.main.tx_marked.show
					.rfl_dlg.main.tx_marked.setlabel "Ren"
				}
				else {
					file write `rfllog' "" _n
					file write `rfllog' "1" _n
					.rfl_dlg.main.gb_marked.show
					.rfl_dlg.main.tx_marked.show
					.rfl_dlg.main.tx_marked.setlabel "Del"
				}
			}
			else {
				file write `rfllog' `"`newdta`i''"' _n
				file write `rfllog' "`del`i''" _n
			}
		}
		file close `rfllog'
	}
}
else {
	.rfl_dlg.main.gb_marked.hide
	.rfl_dlg.main.tx_marked.hide
}
end

* ---------------------------------------
program setmemtext
* ------------------------------------
version 8.2
args size mem
local fmpdisp = floor(round(100-`size'/`mem'*100,.1)*10)/10
.rfl_dlg.main.ed_hisize.setvalue `size'

local commaformat c
if c(dp) == "period" {
	local commaformat
}
if `size' < 10 {
	local size : display %02.1f`commaformat' `size'
}
else {
	local size : display %2.0f`commaformat' `size'
}
local mem : display %2.0f`commaformat' `mem'
local fmpdisp : display %2.1f`commaformat' `fmpdisp'
.rfl_dlg.main.tx_filesize.setlabel `"File size `size' MB, memory allocated `mem' MB, free memory `fmpdisp'%."'
end

* ---------------------------------------
program strsplit, rclass
* ------------------------------------
version 8.2
args str piecelen stub
local i 0
if `:length local str' > 0 {
	while ~ missing(`"`:piece `=`i'+1' `piecelen' of "`str'" '"') {
		local i = `i' + 1
		return local `stub'str`i' `"`:piece `i' `piecelen' of "`str'"'"'
	}
}
return local `stub'strparts = `i'
end

* ---------------------------------------
program shortenstr, rclass
* ------------------------------------
version 8.2
// shortens a string from the beginning, the end, or by splitting it in 2 parts
// where: 0 beginning, 1 middle, 2 end
args str len where piecelen

return local done 0
if `:length local str' <= `len' {
	return local str1 `"`str'"'
	return local strpartsbef = 1
	return local strparts = 1
	return local done 1
	exit
}

local i 0
local cumlen 0

if `where' == 2 {
	if `:length local str' > `len' {
		while ~ missing(`"`:piece `=`i'+1' `piecelen' of "`str'" '"') & `cumlen' <= `len' {
			local i = `i' + 1
			if `cumlen' < `len' {
				if `cumlen' + length(`"`:piece `i' `piecelen' of "`str'" '"') > `len' {
					return local str`i' `=substr(`"`:piece `i' `piecelen' of "`str'"' "',1,`len'-`cumlen')'
					local cumlen = `cumlen' + length(`"`=substr(`"`:piece `i' `piecelen' of "`str'"' "',1,`len'-`cumlen')'"')
				}
				else {
					return local str`i' `"`:piece `i' `piecelen' of "`str'"'"'
					local cumlen = `cumlen' + length(`"`:piece `i' `piecelen' of "`str'" '"')
				}
			}
		}
		return local strparts = `i'
	}
}
if `where' == 0 {
	if `:length local str' > `len' {
		local j = floor((`:length local str' - `len') / `piecelen')
		// The next line works well, to my astonishment [substr("`: ... of "str" ", ...)]
		// Because it may happen that this string starts with ":", it has to be enclosed in double quotes
		return local str1 = substr(`"`:piece `=`j'+1' `piecelen' of "`str'"'"',`:length local str'-`len'-(`j'*`piecelen')+1,.)
		local i = `j' + 1
		while ~ missing(`"`:piece `=`i'+1' `piecelen' of "`str'" '"') {
			local i = `i' + 1
			return local str`=`i'-`j'' `"`:piece `i' `piecelen' of "`str'"'"'
		}
		return local strparts = `i'-`j'
	}
}
// Was mach das hier?
/*
if mod(`where',2) == 0 & `:length local str' <= `len' {
	return local str1 `"`str'"'
	return local strparts = 1
}
*/
if `where' == 1 {
	local lenbef = floor(`len'/2)
	local lenaft = ceil(`len'/2)
	// 1st half
	while ~ missing(`"`:piece `=`i'+1' `piecelen' of "`str'" '"') & `cumlen' < `lenbef' {
		local i = `i' + 1
		if `cumlen' < `lenbef' {
			if `cumlen' + length(`"`:piece `i' `piecelen' of "`str'" '"') > `lenbef' {
				return local str`i' `=substr(`"`:piece `i' `piecelen' of "`str'"' "',1,`lenbef'-`cumlen')'
				local cumlen = `cumlen' + length(`"`=substr(`"`:piece `i' `piecelen' of "`str'"' "',1,`lenbef'-`cumlen')'"')
			}
			else {
				return local str`i' `"`:piece `i' `piecelen' of "`str'"'"'
				local cumlen = `cumlen' + length(`"`:piece `i' `piecelen' of "`str'" '"')
			}
		}
	}
	return local strpartsbef = `i'
	local k 0
	local cumlen 0

	// 2nd half
	local j = floor((`:length local str' - `lenaft') / `piecelen')
	local i = `i' + 1
	return local str`i' `=substr(`"`:piece `=`j'+1' `piecelen' of "`str'"'"',`:length local str'-`lenaft'-(`j'*`piecelen')+1,.)'
	local k = `j' + 1
	while ~ missing(`"`:piece `=`k'+1' `piecelen' of "`str'" '"') {
		local k = `k' + 1
		local i = `i' + 1
		return local str`i' `"`:piece `k' `piecelen' of "`str'"'"'
	}
	return local strparts = `i'
}
return local done 1
end

* ---------------------------------------
program defrepchar, rclass
* ------------------------------------
version 8.2
args str maxlengthstring maxlenstrinwindow maxlenwindow

// Chooses a possible replace-character for blanks in a string
local z1 ¥
local z2 ®
local z3 «
local z4 ±
local z5 Ð

local taken 0
local i 1
while `i' <= 5 {
	local strhelp `:subinstr local str "`z`i''" "A", all'
// Alternative
//	local dtahelp `:subinstr local dtastr`ndtateilzahl' "þý" "", all count(local repcnt)'
// if repcnt == 0 {}
	if `:list str == strhelp' == 1 {
		// Nimm z`i'
		local taken `i'
		local i 6
	}
	local i = `i' + 1
}
if `taken' > 0 {
	return local zztaken `"`z`taken''"'
	return local done = 1
}
else {
	// Can't use dispmsg here, because it relies on defrepchar
	if `:length local dta' > `maxlenstrinwindow' {
		// no string > 255 chars. Less then some 500 chars in total
		_getfilename `"`dta'"'
		window stopbox note `"`r(filename)'"' "contains the characters ¥, ®, «, ±, and Ð." "rfl can not handle file names of this length containing all of those characters. Please rename the dataset, choose another one, or shorten the file name to `maxlengthstring' characters, and restart rfl."
	}
	else {
		window stopbox note `"`dta'"' "contains the characters ¥, ®, «, ±, and Ð." "rfl can not handle file names of this length containing all of those characters. Please rename the dataset, choose another one, or shorten the file name to `maxlengthstring' characters, and restart rfl."
	}
	return local done = 0
}
end

* ---------------------------------------
program dispmsg, rclass
* ------------------------------------
version 8.2
args str maxlenwindow maxlenstrinwindow where omit type zzstr piecelen maxlengthstring dispbefore dispafter1 dispafter2 dispafter3

return local done = 0
local shortento `maxlenwindow'
if `maxlenwindow' < `:length local str' + `:length local dispbefore' + `:length local dispafter1' + `:length local dispafter2' + `:length local dispafter3' + `:length local omit' + ((`:length local dispbefore'>0) + (`:length local dispafter1'>0) + (`:length local dispafter2'>0) + (`:length local dispafter3'>0) - 1) * 2 + 1 {
	local shortento = `maxlenwindow' - (`:length local dispbefore' + `:length local dispafter1' + `:length local dispafter2' + `:length local dispafter3' + `:length local omit' + ((`:length local dispbefore'>0) + (`:length local dispafter1'>0) + (`:length local dispafter2'>0) + (`:length local dispafter3'>0) - 1) * 2 + 1)
}
if `:length local str' + `:length local dispbefore' + 1 > `maxlenstrinwindow' {
	if `shortento' > `=`maxlenstrinwindow' - (`:length local dispbefore' + 1)' {
		local shortento `=`maxlenstrinwindow' - (`:length local dispbefore' + `:length local omit' + 1)'
	}
}
if `shortento' < `maxlenwindow' {
	if missing("`zzstr'") {
		defrepchar `"`str'"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
		local zzstr = r(zztaken)
		if `r(done)' == 0 {
			exit
		}
	}
	shortenstr `"`:subinstr local str " " "`zzstr'", all'"' `shortento' `where' `piecelen'
	if `where' == 0 {
		local strpart `omit'
	}
	forvalues i = 1(1)`r(strparts)' {
		if substr(`"`r(str`=`i'-1')'"',-1,1) == "\" {
			local strpart `"`strpart'\`r(str`i')'"'
		}
		else {
			local strpart `"`strpart'`r(str`i')'"'
		}
		if `where' == 1 {
			if `r(strpartsbef)' == `i' {
				local strpart `"`strpart'`omit'"'
			}
		}
	}
	if `where' == 2 {
		local strpart `"`strpart'`omit'"'
	}
	local strpart `"`:subinstr local strpart "`zzstr'" " ", all'"'
}
else {
	local strpart `str'
}
capture window stopbox `type' `"`dispbefore' `strpart'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
if _rc == 0 {
	return local yes = 1
}
else {
	return local yes = 0
}
return local done = 1
end

* ---------------------------------------
program reverselongstr, rclass
* ------------------------------------
version 8.2
args str piecelen stub
// string without blanks
return local done = 0
local strhelp
strsplit `"`str'"' `piecelen'
forvalues i = `r(strparts)'(-1)1 {
	if substr(`"`r(str`=`i'+1')'"',-1,1) == "\" {
		local strhelp `"`strhelp'\`=reverse("`r(str`i')'")'"'
	}
	else {
		local strhelp `"`strhelp'`=reverse("`r(str`i')'")'"'
	}
}
// The next piece of code assures that the last piece is the shortest, otherwise the first one
// would be the shortest, and its length would vary
strsplit `"`strhelp'"' `piecelen'
forvalues i = 1(1)`r(strparts)' {
	return local `stub'str`i' `"`r(str`i')'"'
}
return local `stub'strparts = r(strparts)
return local done = 1
end

* ------------------------------------
program writedlgpath, rclass
* ------------------------------------
// Splits path and writes it to an open dialog window
args controlaction pathname txtbefore txtafter piecelen maxlengthstring maxlenstrinwindow maxlenwindow

return local done 0
local pathstr
local filestr
_getpathfile `"`pathname'"' `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
if `r(done)' == 0 {
	exit
}
forvalues i = 1(1)`r(pathparts)' {
	if substr(`"`r(pathname`=`i'-1')'"',-1,1) == "\" {
		local pathstr `pathstr'\`r(pathname`i')'
	}
	else {
		local pathstr `pathstr'`r(pathname`i')'
	}
}
forvalues i = 1(1)`r(fileparts)' {
	if substr(`"`r(filename`=`i'-1')'"',-1,1) == "\" {
		local filestr `filestr'\`r(filename`i')'
	}
	else {
		local filestr `filestr'`r(filename`i')'
	}
}
if ~ missing(r(zztaken)) {
	local filestr `:subinstr local filestr "`r(zztaken)'" " ", all'
	local pathstr `:subinstr local pathstr "`r(zztaken)'" " ", all'
}
`controlaction' `"`txtbefore'`filestr' (`pathstr')``txtafter'"'
return local done 1
end

* ------------------------------------
program makeshortdta, rclass
* ------------------------------------
version 8.2
args dta piecelen maxlengthstring maxlenstrinwindow maxlenwindow maxleninlist zzdta

return local done 0
local pathsave
local filesave
return local exitaftertitle 1

if missing("`zzdta'") {
	defrepchar `"`dta'"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
	local zzdta = r(zztaken)
	if `r(done)' == 0 {
		exit
	}
}
_getpathfile `"`dta'"' `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
if `r(done)' == 0 {
	_getfilename `"`dta'"'
	return add
	exit
}
return local exitaftertitle 0
forvalues i = 1(1)`r(pathparts)' {
	if substr(`"`r(pathname`=`i'-1')'"',-1,1) == "\" {
		local pathsave `pathsave'\`r(pathname`i')'
	}
	else {
		local pathsave `pathsave'`r(pathname`i')'
	}
}
forvalues i = 1(1)`r(fileparts)' {
	if substr(`"`r(filename`=`i'-1')'"',-1,1) == "\" {
		local filesave `filesave'\`r(filename`i')'
	}
	else {
		local filesave `filesave'`r(filename`i')'
	}
}
if ~ missing(r(zztaken)) {
	local filesave `:subinstr local filesave "`r(zztaken)'" " ", all'
	local pathsave `:subinstr local pathsave "`r(zztaken)'" " ", all'
}
return add

local strpart
if `:length local filesave' + `:length local pathsave' <= `=`maxleninlist'-3' {
	// do nothing
}
else if `:length local filesave' > `=`maxleninlist'/2' & `:length local pathsave' > `=(`maxleninlist'/2)-3' {
	shortenstr `"`:subinstr local filesave" " "`zzdta'", all'"' `"39"' 2 `piecelen'
	forvalues i = 1(1)`r(strparts)' {
		if substr(`"`r(str`=`i'-1')'"',-1,1) == "\" {
			local strpart `strpart'\`r(str`i')'
		}
		else {
			local strpart `strpart'`r(str`i')'
		}
	}
	local filesave `:subinstr local strpart "`zzdta'" " ", all'*

	local strpart
	shortenstr `"`:subinstr local pathsave" " "`zzdta'", all'"' `"36"' 2 `piecelen'
	forvalues i = 1(1)`r(strparts)' {
		if substr(`"`r(str`=`i'-1')'"',-1,1) == "\" {
			local strpart `strpart'\`r(str`i')'
		}
		else {
			local strpart `strpart'`r(str`i')'
		}
	}
	local pathsave `:subinstr local strpart "`zzdta'" " ", all'*
}
else if `:length local filesave' > `maxleninlist' & `:length local filesave' > `=`maxleninlist'-`:length local pathsave'-3' {
	shortenstr `"`:subinstr local filesave" " "`zzdta'", all'"' `"`=`maxleninlist'-`:length local pathsave'-4'"' 2 `piecelen'
	forvalues i = 1(1)`r(strparts)' {
		if substr(`"`r(str`=`i'-1')'"',-1,1) == "\" {
			local strpart `strpart'\`r(str`i')'
		}
		else {
			local strpart `strpart'`r(str`i')'
		}
	}
	local filesave `:subinstr local strpart "`zzdta'" " ", all'*
}
else if `:length local pathsave' > `=`maxleninlist'-`:length local filesave'' {
	shortenstr `"`:subinstr local pathsave" " "`zzdta'", all'"' `"`=`maxleninlist'-`:length local filesave'-4'"' 2 `piecelen'
	forvalues i = 1(1)`r(strparts)' {
		if substr(`"`r(str`=`i'-1')'"',-1,1) == "\" {
			local strpart `strpart'\`r(str`i')'
		}
		else {
			local strpart `strpart'`r(str`i')'
		}
	}
	local pathsave `:subinstr local strpart "`zzdta'" " ", all'*
}
return local filesave `"`filesave'"'
return local pathsave `"`pathsave'"'
return local zzdta `zzdta'
return local done 1
end

* ------------------------------------
program rflupdatelog, rclass
* ------------------------------------
version 8.2
args piecelen maxlengthstring maxlenstrinwindow maxlenwindow maxleninlist strucversion

// Updates rfl.log after when invoking rfl the first time after a version change

// Structure of rfl.log
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
// Lines 14-15: empty

// then for the entries:
// Line 1: How many times opened
// Line 2: Last opened (5 last, 4 last but one, etc.)
// Line 3: short data file name
// Line 4: long data file name
// Line 5: long cmdlog file name (up to V2.2: short log file)
// Line 6: long log file name
// Line 7: short description
// Line 8: long description
// Lines 9-13: empty
// Line 14: newdta long
// Line 15: 1 to be deleted 2 to be renamed, 0 otherwise

local dtanum 0
local startversion 0
return local done 0
local rewrite 0
local strucversion = substr("`strucversion'", index("`strucversion'"," ")+1,.)

quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
if _rc ~= 0 {
	noisily display "rfl.log not found in your PERSONAL directory. Nothing to update."
	exit
}
noisily display "Updating rfl.log to version `strucversion' ... " _continue
tempname rfllog
file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
file read `rfllog' line
if ~ missing(real("`line'")) {
	local startversion 2
}
else {
	local startversion : word 2 of `line'
	file read `rfllog' line
	local hidemenu `line'
	file read `rfllog' line
	local rewritemenu `line'
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
	local lastcmds `line'
	forvalues i = 15(1)16 {
		file read `rfllog' line
	}
}
while r(eof)==0 {
	local dtanum = `dtanum' + 1
	local anzopen`dtanum' `line'
	file read `rfllog' line
	local lastopen`dtanum' `line'
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
	file read `rfllog' line
}
file close `rfllog'

if "`startversion'" == "2" {
	local rewrite 1
	// Change logkurz to cmdloglang
	forvalues i = 1 2 to `dtanum' {
		if `:length local loglang`i'' > `maxlengthstring' {
			defrepchar `"`loglang`i''"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
			local zzloglang = r(zztaken)
			if `r(done)' == 0 {
				defrepchar `"`dtalang`i''"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
				local zzdta = r(zztaken)
				local dispbefore "Entry "
				local dispafter1 in rfl.log do not adhere to rfl's rules.
				local dispafter2 You may now remove or rename it from within rfl.
				local dispafter3 Please send an email to the author of rfl.
				dispmsg `"`dtalang`i''"' `maxlenwindow' `maxlenstrinwindow' 0 * stop "`zzdta'" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
				return local done 0
				exit
			}
			strsplit `"`:subinstr local loglang`i' " " "`zzloglang'", all'"' `piecelen' loglang
			local nloglangteilzahl = `r(loglangstrparts)'
			forvalues j = 1(1)`nloglangteilzahl' {
				local loglangstr`j' `r(loglangstr`j')'
				if index(`"`r(loglangstr`j')'"',".") > 0 {
					local lastloglangteilhasdot `j'
				}
			}
			local cmdloglang
			forvalues j = 1(1)`=`lastloglangteilhasdot'-1' {
				if substr(`"`loglangstr`=`j'-1''"',-1,1) == "\" {
					local cmdloglang `cmdloglang'\`loglangstr`j''
				}
				else {
					local cmdloglang `cmdloglang'`loglangstr`j''
				}
			}
			if substr(`"`loglangstr`=`lastloglangteilhasdot'-1''"',-1,1) == "\" {
				local cmdloglang `cmdloglang'\`=reverse(substr(reverse(`"`loglangstr`lastloglangteilhasdot''"'), index(reverse(`"`loglangstr`lastloglangteilhasdot''"'),".")+1,.))'
			}
			else {
				local cmdloglang `cmdloglang'`=reverse(substr(reverse(`"`loglangstr`lastloglangteilhasdot''"'), index(reverse(`"`loglangstr`lastloglangteilhasdot''"'),".")+1,.))'
			}
			local cmdloglang `:subinstr local cmdloglang "`zzloglang'" " ", all'.txt
		}
		else if `:length local loglang`i'' == 0 {
			local cmdloglang
		}
		else {
			local cmdloglang `=reverse(substr(reverse("`loglang`i''"), index(reverse("`loglang`i''"),".")+1, .))'.txt
		}
		local cmdloglang`i' `cmdloglang'

		// Change dtakurz
		makeshortdta `"`dtalang`i''"' `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow' `maxleninlist'
		if `r(done)' == 0 {
			local dispbefore "Entry "
			local dispafter1 in rfl.log do not adhere to rfl's rules.
			local dispafter2 You may now remove or rename it from within rfl.
			local dispafter3 Please send an email to the author of rfl.
			dispmsg `"`dtalang`i''"' `maxlenwindow' `maxlenstrinwindow' 0 * stop "`zzdta'" `piecelen' `maxlengthstring' `"`dispbefore'"' `"`dispafter1'"' `"`dispafter2'"' `"`dispafter3'"'
			return local done 0
			exit
		}
		else {
			local filesave `r(filesave)'
			local pathsave `r(pathsave)'
			local dtakurz `"`filesave' (`pathsave')"'
			local zzdta `r(zzdta)'
		}
		// Check whether dtakurz already exists
		local exitloop 0
		local j 1
		local strpart
		while `exitloop' == 0 {
			local k 1
			local exitloop 1
			while `k' < `i' {
				if `"`dtakurz`k''"' == `"`dtakurz'"' {
					// dtakurz already exists: shorten pathsave
					shortenstr `"`:subinstr local pathsave" " "`zzdta'", all'"' `"`=`:length local pathsave'-length("* [`j']")'"' 2 `piecelen'
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
		local dtakurz`i' `dtakurz'
	}
}

if "`startversion'" == "3.0" | "`startversion'" == "3.2" {
	local rewrite 1
	local displayed 0
	forvalues i = 1 2 to `dtanum' {
		local enterif 0
		// Correct dtakurz, if necessary
		if `:length local dtakurz`i'' == `:length local dtalang`i'' {
			if `:length local dtakurz`i'' <= `maxlengthstring' {
				local enterif = `"`dtakurz`i''"' == `"`dtalang`i''"'
			}
			else {
				strsplit `"`dtakurz`i''"' `piecelen' dta
				forvalues i = 1(1)`r(dtastrparts)' {
					local enterif = `"`:piece `i' `piecelen' of "`dtakurz`i''"'"' == `"`:piece `i' `piecelen' of "`dtalang`i''"'"'
					if `enterif' ~= 1 {
						continue, break
					}
				}

			}
			if `enterif' == 1 {
				makeshortdta `"`dtalang`i''"' `piecelen' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow' `maxleninlist'
				if `r(done)' ~= 0 {
					local filesave `r(filesave)'
					local pathsave `r(pathsave)'
					local dtakurz`i' `"`filesave' (`pathsave')"'
				}
			}
		}

		// Correct cmdloglang, if necessary. cmdloglang is simply taken from loglang
		if `:length local cmdloglang`i'' <= `maxlengthstring' {
			local enterif = substr(`"`cmdloglang`i''"',-1,1) == ")"
		}
		else {
			strsplit `"`cmdloglang`i''"' `piecelen' cmdlog
			local enterif = substr(`"`r(cmdlogstr`r(cmdlogstrparts)')'"',-1,1) == `")"'
		}
		if `enterif' == 1 {
			if `:length local loglang`i'' <= `maxlengthstring' {
				if substr(`"`loglang`i''"', -5, 5) == `".smcl"' {
					local newcmdloglang `=substr(`"`loglang`i''"', 1, length(`"`loglang`i''"')-5)'.txt
				}
				else if substr(`"`loglang`i''"', -4, 4) == `".log"' {
					local newcmdloglang `=substr(`"`loglang`i''"', 1, length(`"`loglang`i''"')-4)'.txt
				}
			}
			else {
				defrepchar `"`loglang`i''"' `maxlengthstring' `maxlenstrinwindow' `maxlenwindow'
				local zzlog = r(zztaken)
				if `r(done)' == 0 & `displayed' == 0 {
					disp in red "rfl cannot update the cmdlog entries in rfl.log automatically,"
					disp in red "because there seem to be illegal charcters in the log file name."
					disp as text "You must manually edit rfl.log. Please open rfl.log (located in your PERSONAL directory) with any text editor like Notepad."
					disp as text "Step 1: Navigate to line 20 and check whether the cmdlog file has the form <file name (path name)>."
					disp as text "Step 2: If so, change it to the form <path name\file name>."
					disp as text "        If not, leave it as it is."
					disp as text "Step 3: Repeat this procedure for lines 35, 50, and so on."
					disp as text "Step 4: Invoke rfl again."
					local displayed 1
				}
				local newcmdloglang
				strsplit `"`:subinstr local loglang`i' " " "`zzlog'", all'"' `piecelen' log
				local nlogteilzahl = r(logstrparts)
				forvalues j = 1(1)`nlogteilzahl' {
					local logstr`j' `r(logstr`j')'
					if substr(`"`logstr`j''"', -5, 5) == `".smcl"' & `j' == `nlogteilzahl' {
						local logstr`j' `=substr(`"`logstr`j''"', 1, length(`"`logstr`j''"')-5)'.txt
					}
					else if substr(`"`logstr`j''"', -4, 4) == `".log"' & `j' == `nlogteilzahl' {
						local logstr`j' `=substr(`"`logstr`j''"', 1, length(`"`logstr`j''"')-4)'.txt
					}
					if substr(`"`logstr`=`j'-1''"',-1,1) == "\" {
						local newcmdloglang `newcmdloglang'\`logstr`j''
					}
					else {
						local newcmdloglang `newcmdloglang'`logstr`j''
					}
				}
				local newcmdloglang `:subinstr local newcmdloglang "`zzlog'" " ", all'
			}
			local cmdloglang`i' `newcmdloglang'
		}
	}
}

if "`startversion'" == "3.3" | "`startversion'" == "3.4"  | "`startversion'" == "3.5" {
	local rewrite 1
	if missing("`lastcmds'") {
		local lastcmds 0
	}
}


if `rewrite' == 1 {
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', write text replace
	if `startversion' == 2 {
		// insert 15 lines with default values
		file write `rfllog' "version `strucversion'" _n
		file write `rfllog' "0" _n
		file write `rfllog' "0" _n
		file write `rfllog' "9" _n
		file write `rfllog' "1" _n
		file write `rfllog' "1" _n
		file write `rfllog' "0" _n
		file write `rfllog' "0" _n
		file write `rfllog' "0" _n
		file write `rfllog' "10" _n
		file write `rfllog' "450" _n
		file write `rfllog' "15" _n
		file write `rfllog' "0" _n
		file write `rfllog' "0" _n
		forvalues i = 15(1)15 {
			file write `rfllog' "" _n
		}
	}
	else {
		// rewrite the first 15 lines
		file write `rfllog' "version `strucversion'" _n
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
	}

	// rewrite list entries
	forvalues i = 1 2 to `dtanum' {
		file write `rfllog' "`anzopen`i''" _n
		file write `rfllog' "`=`lastopen`i'''" _n
		file write `rfllog' `"`dtakurz`i''"' _n
		file write `rfllog' `"`dtalang`i''"' _n
		file write `rfllog' "`cmdloglang`i''" _n
		file write `rfllog' "`loglang`i''" _n
		file write `rfllog' `"`desckurz`i''"' _n
		file write `rfllog' `"`desclang`i''"' _n
		forvalues i = 9(1)13 {
			file write `rfllog' "" _n
		}
		file write `rfllog' `"`newdta`i''"' _n
		file write `rfllog' "0" _n
	}
	file close `rfllog'
}
noisily display "Successful!"
return local done 1

end

* ------------------------------------
program setdefault
* ------------------------------------
version 8.2
// sets dialog settings as default
args hidemenu rewritemenu recentno loadlastlog treatcmdlogpar replacelog replacecmdlog dontwarnlogreplace logbackup lastcmds minmem maxmem memmult
quietly capture confirm file `"`:sysdir PERSONAL'rfl.log"'
if _rc == 0 {
	// don't do anything if rfl.log does not exist: default values will be set when opening a file
	tempname rfllog
	file open `rfllog' using `"`:sysdir PERSONAL'rfl.log"', read text
	file read `rfllog' line
	local strucversion `line'
	forvalues i = 2(1)16 {
		file read `rfllog' line
	}
	local dtanum 0
	while r(eof) == 0 {
		local dtanum = `dtanum' + 1
		local anzopen`dtanum' `line'
		file read `rfllog' line
		local lastopen`dtanum' `line'
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
		file read `rfllog' line
	}
	file close `rfllog'
	// Write rfl.log anew with new settings

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
	local i 1
	while `i' <= `dtanum' {
		file write `rfllog' "`anzopen`i''" _n
		file write `rfllog' "`lastopen`i''" _n
		file write `rfllog' `"`dtakurz`i''"' _n
		file write `rfllog' `"`dtalang`i''"' _n
		file write `rfllog' "`cmdloglang`i''" _n
		file write `rfllog' "`loglang`i''" _n
		file write `rfllog' `"`desckurz`i''"' _n
		file write `rfllog' `"`desclang`i''"' _n
		forvalues j = 9(1)13 {
			file write `rfllog' "" _n
		}
		file write `rfllog' "`newdta`i''" _n
		file write `rfllog' "`del`i''" _n
		local i = `i' + 1
	}
	file close `rfllog'
}
end


* ------------------------------------
program checkquotes, rclass
* ------------------------------------
version 8.2
args str piecelen file

return local done 0
return local quotes 0

if "`file'" == "dta" {
	local errmsg Please rename the dataset or chose another one.
}
if "`file'" == "newdta" {
	local errmsg Please chose another name for the dataset.
}
if "`file'" == "log" {
	local errmsg Please rename the log file or chose another one.
}
if "`file'" == "cmdlog" {
	local errmsg Please rename the cmdlog file or chose another one.
}
if "`file'" == "desc" {
	local errmsg Please chose another description.
}

if `:length local str' > 0 {
	local i 0
	// This one produces an error if macro quote in string
	capture local teststr :  piece `=`i'+1' `piecelen' of `"`str'"'
	if _rc == 0 {
		// no macro quote in str, only for " and '
		while ~ missing(`"`teststr'"') {
			local i = `i' + 1
			if index(`"`teststr'"',`"'"') > 0 | index(`"`teststr'"',`"""') > 0 {
				disp as text `"`str'"' as error `" contains quotes like " and ' and cannot be processed by rfl. "' as error "`errmsg'"
				return local done 1
				return local quotes 1
				exit
			}
			local teststr : piece `=`i'+1' `piecelen' of `"`str'"'
		}
	}
	else {
		// only for macro quotes `
		capture local teststr :  piece `=`i'+1' `piecelen' of "`str'"
		while ~ missing("`teststr'") {
			local i = `i' + 1
			if index("`teststr'","`") > 0 {
				disp as text "`str'" as error " contains the macro quote " "`" " and cannot be processed by rfl. " as error "`errmsg'""
				return local done 1
				return local quotes 1
				exit
			}
			local teststr : piece `=`i'+1' `piecelen' of "`str'"
		}
	}
}
return local done 1

end

