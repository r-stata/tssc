*Program to list all the command start with perticular letter
*! created by Chamra on 05th Jan 2015
*! version 1.1
	version 8.0

	capture program drop prolist 
	program define prolist 
	set more off
	local bdirectory=c(pwd)
	local flet=trim(substr("`0'",1,1))
	local spart=trim("`0'")
		
	capture cd "`c(sysdir_base)'"	
	capture cd "`flet'"
	if _rc==0 {
	
	dis as result "Stata commands"
	dis as result "..................................."
	dis "Base"
*Program to check each ado file	
		local stadata: dir . files "`spart'*.ado",respectcase
*Number order for the list
		local i=1
		foreach file of local stadata {
			local diabox=substr("`file'",1,length("`file'")-4)
			
				local sthlp: dir . files "`diabox'.*hlp",respectcase
				foreach hlfile of local  sthlp {
					local helptxt="{help `diabox':help}"
				}
			
				local stdlg: dir . files "`diabox'.dlg",respectcase
				foreach stfile of local stdlg {
					local stwindow="{dialog `diabox':Dialog}"
				
				}
			dis "`i'. `diabox'"_col(35)"`helptxt'{tab}`stwindow' "
			local i = `i'+1
			local stwindow=""
			local helptxt=""
		}
		if `i'==1 {
			display as error "No Stata program code for this search"
		}
		
		
******************************************************
	local stwindow=""
	local adof=""	
	dis ""
	dis as result "..................................."
	dis as result "Built-in"
*Program to check each ado file	
		local stadata: dir . files "`spart'*.*hlp",respectcase
*Number order for the list
		local i=1
		foreach file of local stadata {
			local diabox=substr("`file'",1,strpos("`file'",".")-1)
			local helptxt="{help `diabox':help}"
			
				local stado: dir . files "`diabox'.ado",respectcase
				foreach adofile of local  stado {
					local adof="`adofile'"
				}
			
				local stdlg: dir . files "`diabox'.dlg",respectcase
				foreach stfile of local stdlg {
					local stwindow="{dialog `diabox':Dialog}"
				
				}
			if "`adof'"=="" {
			dis "`i'. `diabox'"_col(35)"`helptxt'{tab}`stwindow' "
			local i = `i'+1
			local stwindow=""
			local adof=""
		}
		}
		if `i'==1 {
			display as error "No Stata program code for this search"
		}
	}
*********************************************	
	local stwindow=""
	local adof=""	
*Plus
	capture cd "`c(sysdir_plus)'"		
	
	capture cd "`flet'"
	if _rc==0 {
	dis ""
	dis as result "..................................."
	dis as result "Plus"
*Program to check each ado file	
		local stadata: dir . files "`spart'*.ado",respectcase
*Number order for the list
		local i=1
		foreach file of local stadata {
			local diabox=substr("`file'",1,length("`file'")-4)
			
				local sthlp: dir . files "`diabox'.*hlp",respectcase
				foreach hlfile of local  sthlp {
					local helptxt="{help `diabox':help}"
				}
			
				local stdlg: dir . files "`diabox'.dlg",respectcase
				foreach stfile of local stdlg {
					local stwindow="{dialog `diabox':Dialog}"
				
				}
			dis "`i'. `diabox'"_col(35)"`helptxt'{tab}`stwindow' "
			local i = `i'+1
			local stwindow=""
			local helptxt=""
		}
		if `i'==1 {
			display as error "No Stata program code for this search"
		}
	}
			
*********************************************	
	local stwindow=""
	local adof=""	
*Plus
	capture cd "`c(sysdir_personal)'"		
	
	capture cd "`flet'"
	if _rc==0 {
	dis ""
	dis as result "..................................."
	dis as result "Personal"
*Program to check each ado file	
		local stadata: dir . files "`spart'*.ado",respectcase
*Number order for the list
		local i=1
		foreach file of local stadata {
			local diabox=substr("`file'",1,length("`file'")-4)
			
				local sthlp: dir . files "`diabox'.*hlp",respectcase
				foreach hlfile of local  sthlp {
					local helptxt="{help `diabox':help}"
				}
			
				local stdlg: dir . files "`diabox'.dlg",respectcase
				foreach stfile of local stdlg {
					local stwindow="{dialog `diabox':Dialog}"
				
				}
			dis "`i'. `diabox'"_col(35)"`helptxt'{tab}`stwindow' "
			local i = `i'+1
			local stwindow=""
			local helptxt=""
		}
		if `i'==1 {
			display as error "No Stata program code for this search"
		}
	}
		
*********************************************	
	local stwindow=""
	local adof=""	
*Plus
	capture cd "`c(sysdir_oldplace)'"		
	
	capture cd "`flet'"
	if _rc==0 {
	dis ""
	dis as result "..................................."
	dis as result "Other"
*Program to check each ado file	
		local stadata: dir . files "`spart'*.ado",respectcase
*Number order for the list
		local i=1
		foreach file of local stadata {
			local diabox=substr("`file'",1,length("`file'")-4)
			
				local sthlp: dir . files "`diabox'.*hlp",respectcase
				foreach hlfile of local  sthlp {
					local helptxt="{help `diabox':help}"
				}
			
				local stdlg: dir . files "`diabox'.dlg",respectcase
				foreach stfile of local stdlg {
					local stwindow="{dialog `diabox':Dialog}"
				
				}
			dis "`i'. `diabox'"_col(35)"`helptxt'{tab}`stwindow' "
			local i = `i'+1
			local stwindow=""
			local helptxt=""
		}
		if `i'==1 {
			display as error "No Stata program code for this search"
		}
	}

	dis as res "_____________________________________"
	dis as input "Note: if '_' appears in the command line it can replaced using 'space'"
	qui cd "`bdirectory'"
	end
