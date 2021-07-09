*! Version 1.4 			<Jan/10/2013> 			Andrés Castañeda. 
	* fix bugs in copy option
*===================================================================*
* WORLD BANK - LCSPP						 
* PROYECT: Program to make daily backup of important files. 
*-------------------------------------------------------------------*  
* Author: Andres Castaneda 
* Update: Dec/2013
*===================================================================*

cap program drop backup
program define backup

syntax , Source(string)  Destination(string) [ 		///
		mirror 										///
		copy(string)								///
		Files(string)								///
		STart(string) 								///
		NFolders(int 8) 							///
		Period(string)								///
		speed(int 32)								///
		XDir(string)								///
		XFile(string)								///
		INFile(string)								///
		]

version 10.0

	/* **********
	* 0. errors
	 ************ */
	* check to determine whether it can be run
	if ("`c(os)'" != "Windows") {
		disp as error "Unfortunately," in smcl "{cmd: backup }" as error "only works over Windows."
		error
	}
	* Check multi-threads are not greater than 128 or less that 1
	if (!inrange(`speed', 1,128)) {
		disp as error "the multi-threaded copies can not be greater than 128 or lower than 1"
		error
	}
	
	* Incompatibility of excluding and including files at the same time
	if ("`xfile'" != "" & "`infile'" != "" ) {
		disp in red "You cannot exclude and include type of file at the same time. use either xfile or infile option"
		error
	}
	
	/*******************************
	1. define locals and consistency
	********************************/
	
	* 1.1 define locals
	
	local mt "/MT:`speed'"				//define multi threads
	
	if ("`xdir'" == "") local xd ""		// define folder to exclude
	else local xd `"/XD "`xdir'" "'
	
	* define file format to exclude
	if ("`xfile'" == "") local xf ""
	else {
		local xf "/XF "
		foreach file of local xfile {
			local xf "`xf' *.`file'"
		}
	}
	
	* define file format to include
	local inf ""
	if ("`infile'" != "") {
		foreach file of local infile {
			local inf "`inf' *.`file'"
		}
	}
	
	* Copy option
	if ("`copy'" == "") local copy "DAT"
	local copy = upper("`copy'")
	if (!regexm("`copy'", "[^DATSOU]"))   local flags "/copy:`copy'"
	else if ("`copy'" == "all") local flags "/copyall"
	else local flags "/copy:DAT"
	
	* Make sure user does not want to take so long copying unnecessary files properties 
	if (regexm("`copy'", "[SOU]")) {
		cap window stop rusure `"copying files with properties such as "NTFS access control list (ACL)" "Owner information" or "Auditing information" "' ///
			`"May take a long time"' "click OK if you want to proceed any way"
		if (_rc) exit
	}
	
	* define type of copy: tree folder or just files
	if ( "`mirror'" == "mirror" ) local mir "/MIR"
	else local mir "/e"
	
	* default period
	if ("`period'" == "") local period "2w"
	
	* to erase  local destination "L:\backup\datalib"
	
	* define date
	local date: di %tdMonth_dd,_CCYY date("$S_DATE", "DMY")
	local date = lower(trim("`date'"))
	
	* 1.2 check if the date folder already exists
	local fdates: dir "`destination'" dirs "*"
	foreach fdate of local fdates {
		if ("`date'" == "`fdate'") {
			disp in y "There is a backup of " in g "`destination'/`date'" in y " already"
			exit
		}
	}
	
	/* *************************************************************
	2. erase old folders and check whether the folder to be created 
	meets period and number-of-folders conditions 
	****************************************************************/
	
	local nfold: word count `fdates'					// number of folders with dates
 
	* 2.1 copy if date is according to the period specification. 
	
	*2.1.1 Specify period
	cap confirm number `period'
	if (_rc == 0) local freq `period'		// in case number of days selected
	else {			// in case compounded periods are selected
		local per = substr("`period'",-1,.)
		local times = substr("`period'",1,`: disp length("`period'")' - 1) 			// " get only the numeric part
		
		if ("`per'" == "d") local freq `times'			// daily
		if ("`per'" == "w") local freq 	`times'*7		// weekly
		if ("`per'" == "m") local freq 	`times'*30		// monthly
		if ("`per'" == "q") local freq 	`times'*90		// quarterly
		if ("`per'" == "s") local freq 	`times'*180		// semester
		if ("`per'" == "y") local freq 	`times'*360		// yearly
	} // end of else
	
	*2.1.2 Check number of folders already in house
	local dnumbers ""
	if (`nfold' > 0 & `nfold' < .) {			// in case there is at least one folder
		foreach fdate of local fdates {
			local lower(trim("`fdate'"))			// everything in lower cases and with no blank spaces at the end
			local dnumbers `"`dnumbers' `: disp date("`fdate'", "MDY")' "'
		}	//  end of loop for folder names
		
		local dnumbers = itrim(trim("`dnumbers'"))				// get rid of multiple internal, leading or trailing blanks
		local dnumbers: subinstr local dnumbers " " ", ", all	// replace blanks for comma and then blank
		if (`nfold' > 1) local newdate = max(`dnumbers')
		if (`nfold' == 1) local newdate = `dnumbers'
		
		* check whether current date is higher than minimum period to create backup
		
		if (`: disp date("$S_DATE", "DMY")' - `newdate' >= `freq') local copy 1
		else local copy 0
	}
	else local copy 1
	
	* 2.2 Delete old folders
	while (`nfold' > `nfolders') {
		local dnumbers ""
		foreach fdate of local fdates {
			local lower(trim("`fdate'"))			// everything in lower cases and with no blank spaces at the end
			local dnumbers `"`dnumbers' `: disp date("`fdate'", "MDY")' "'
		}	//  end of loop for folder names
		
		local dnumbers = itrim(trim("`dnumbers'"))				// get rid of multiple internal, leading or trailing blanks
		local dnumbers: subinstr local dnumbers " " ", ", all	// replace blanks for comma and then blank
		local olddate = min(`dnumbers')
		local name: di %tdMonth_dd,_CCYY `olddate'				// convert to date
		local name = trim("`name'")							// get rid of preceding spaces
		disp in w "deleting folder `destination'/`name'"
		shell rd /s /q "`destination'/`name'"					// delete folder that is older than number of folders allowed
		
		local fdates: dir "`destination'" dirs "*"
		local nfold: word count `fdates'					// number of folders with dates
	}	// end of conditional 
	

	/* ***********
	3. Crete copy
	 *************/
	if (`copy' == 1) {

	*3.1 Path after the start point
		/* path after start point. Start point is the directory from which
		-backup- will copy the folder structure from the source path */
		if (regexm("`source'","(^.*)(\\\`start'.*$)")) local tree = regexs(2)
		local basedir  "`destination'/`date'"				// base directory for destination folder
		cap mkdir "`basedir'"								// create date folder
		local destdir = "`basedir'`tree'"					// rename destination directory with tree and date
		
		*3.2 Copy
		shell ROBOCOPY "`source'" "`destdir'" `files' `flags' `mir' `inf' `mt' `xd' `xf'				
	}
	
end

exit 

********************************************************************************************************
History of the file

1.3 			<Dec/23/2013> 			Andrés Castañeda. 
 fix bugs
 add 'copy' option
1.2 			<Dec/12/2013> 			Andrés Castañeda. 
	Change encoding format to ANSI
1.1 			<Dec/12/2013> 			Andrés Castañeda. 
	include a check at the beginning to determine whether it can be run
1.0 			<Dec/09/2013> 			Andrés Castañeda 
0.1 			<Sep/19/2013> 			Andrés Castañeda 
0.2 			<Dec/05/2013> 			Andrés Castañeda 
