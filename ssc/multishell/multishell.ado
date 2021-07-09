*! multishell v 2.0 - October 2018
program define multishell , rclass
	version 14
	
	syntax anything , *

	tokenize `anything'
	local one "`1'"
	
	if "`one'" == "path" {
		return local path = "`2'"			
		return add
		**clear path
		if "`options'" == "clear" {
			local datafiles : dir `"`2'"' files "*" 
			foreach file in `datafiles' {
				erase "`2'\\`file'"
			}
			local datafiles : dir `"`2'"' dir "*" 
			foreach file in `datafiles' {
				!rmdir "`2'\\`file'"  /s /q
			}
		}
	}
	else if "`one'" == "adopath" {
		return local adopath = "`2'"
		return add
	}
	else if "`one'" == "exepath" {
		return local exepath  "`2'"
		local exename = subinstr("`exepath'","\","/",.)
		local exename = ustrright("`exepath'",strlen("`exename'")-strpos("`exename'","/"))
		return local exename "`exename'"
		return add
	}
	else if "`one'" == "add" {
		macro shift
		`qui' multishell_add `*' , mainfile("`*'") macnameadd("") `options' 
		noi disp "file: `*' added"
		return add
	}
	else if "`one'" == "change" {
		macro shift
		multishell_change `*', `options'
	}
	else if "`one'" == "run" {
		macro shift
		multishell_run `*' , `options'
	}
	else if "`one'" == "alttext" {
		local i = 1 
		while "`r(alttext`i')'" ~= "" {
			local i=`i' + 1
		}
		macro shift
		return add
		return local alttext`i' = "`*'"
	}
	else if "`one'" == "status" {		
		multishell_status		
	}
	else if "`one'" == "seed" {
		tempname return
		_return hold `return'
		_return restore `return', hold

		macro shift
		multishell_seed `*', `options'
		
		local seed_option = `r(seed_option)'
		local seed_file "`r(seed_file)'"
		
		_return restore `return', hold
		return local seed_file "`seed_file'"
		return scalar seed_option = `seed_option'
		return add
	}
	else if "`one'" == "reset" {
		macro shift
		multishell_reset `*' , `options'
	}
	else if "`one'" == "StartDisplay" {
		multishell_StartDisplay
	}
	else {
		disp "Error - multishell not correctly defined"
	}
	return add
	
end

program multishell_reset
	syntax anything , computer(string)
	
	local path "`r(path)'"
	
	multishell_refresh_overview  `path' 
	
	tokenize `anything' 
	
	while "`1'" != "" {
		if "`1'" == "running" {
			local state = 2
		}
		else if "`1'" == "assigned" {
			local state = 1
		}
		else if "`1'" == "finished" {
			local state = 3
		}
		else if "`1'" == "stopped" {
			local state = 4
		}
		else if "`1'" == "error" {
			local state = 5
			mata index = selectindex((multishell_overview[.,4]:!="0"):*(multishell_overview[.,4]:!="1"):*(multishell_overview[.,4]:!="2"):*(multishell_overview[.,4]:!="3"):*(multishell_overview[.,4]:!="4"))
			mata multishell_overview[index,4] = J(rows(index),1,"5")
			mata multishell_overview[index,4] = J(rows(index),1,"5")
		}
		else if strmatch("`1'","id(*") == 1 {
			local state = 5
			local id = subinstr("`1'","id(","",.)
			local id = subinstr("`id'",")","",.)
			mata index = selectindex(multishell_overview[.,1]:== "`id'")
			mata multishell_overview[index,4] = J(rows(index),1,"5") 
		}
		else {
			display "multishell reset not correctly specified."
		}
		
		if "`computer'" == "_all" {
			mata index = selectindex(multishell_overview[.,4]:=="`state'")
		}
		else {
			mata index = selectindex((multishell_overview[.,4]:=="`state'"):*(multishell_overview[.,8]:=="`computer'"))
		}
		mata index = multishell_overview[index,.]
		
		mata st_local("nn",strofreal(rows(index)))
		
		forvalues i = 1(1)`nn' {
			mata st_local("subpath",index[`i',3])			
			qui multishell_capture mata mata matuse "`path'\\`subpath'\stata_batch_N", replace
			mata stata_batch_N[1,1] = "0"
			mata stata_batch_N[1,2] = "`c(current_date)' - `c(current_time)'"
			mata stata_batch_N[1,3] = ""
			qui multishell_capture mata mata matsave "`path'\\`subpath'\stata_batch_N" stata_batch_N seed multishell_stats_N, replace
			mata st_local("taskid",index[`i',1])
			noi disp "Task `taskid' changed to queued."
		}
		
		macro shift
	}
end


program define multishell_status
		**Obtain output
		if "`r(path)'" == "" {
			display "No path set."
			exit
		}
		
		*qui multishell_capture mata mata matuse "`r(path)'\\multishell_overview", replace
		dis as text "Overview"
		multishell_refresh_overview  `r(path)' 
		if fileexists("`r(path)'\\multishell_overview.mmat") == 1 {
			multishell_output multishell_overview , ncls
		}
		**client list
		multishell_clientlist
		*loop over clients
		mata st_local("num_client",strofreal(rows(ClientList)))
		di ""
		di "Clientlist"
		if `num_client' > 0 {
			dis as text "{hline 100}"
			dis as text  _col(2) "id" _col(6) "Computername" _col(26) "Number of Threads"
			dis as text "{hline 100}"
			forvalues i = 1(1)`num_client' {
				mata st_local("client_i",ClientList[`i',2])
				mata st_local("threads_i",ClientList[`i',3])
				dis as text  _col(2) `i' _col(6) "`client_i'" _col(26) `threads_i'
			}
			dis as text "{hline 100}"
		}
		else {
			di as text "no clients found."
		}
		di ""
		di as text "Set paths"
		dis as text "{hline 100}"
		dis as text _col(2) "Type"  _col(22) "Path"
		dis as text "{hline 100}"
		dis as text _col(2) "Main path" _col(22) `"`r(path)'"'
		if "`r(exepath)'" != "" {
			dis as text _col(2) "Path to Stata Exe" _col(22) "`r(exepath)'"
		}
		if "`r(adopath)'" != "" {
			dis as text _col(2) "ado path" _col(22) "`r(adopath)'"
		}
		dis as text "{hline 100}"

		
		if "`r(alttext1)'" != "" {
			di ""
			di as text "strings to be changed"
			dis as text "{hline 100}"
			dis as text _col(2) "Old String" _col(40) "Changed into"
			dis as text "{hline 100}"
			local i = 1
			while "`r(alttext`i')'" != "" {
				tokenize `r(alttext`i')' , parse("@")
				
				dis as text _col(2) "`1'" _col(40) `"`3'"'
				
				local i = `i' + 1
			}
			dis as text "{hline 100}"
		}
		
end


program define multishell_seed, rclass
	syntax anything , [seed(string) NOSEEDstream rngstate(string) state]
	
	if "`r(path)'" == "" {
		noi disp as smcl "Path not set. Use {stata multishell path} to set path."
		exit
	}
	if "`seed'" != "" & "`rngstate'" != "" {
		noi disp "Define either seed or rngstate."
		error 184 
	}
	** Internally only use seed.
	if "`rngstate'" != "" | "`state'" != "" {
		local rngstate = 1
		local seed = "`rngstate'"
	}
	else {
		local rngstate = 0
	}
	
	local path `"`r(path)'"'
	qui multishell_capture mata mata matuse "`r(path)'\\multishell_overview", replace
	tokenize `anything'
	
	if "`1'" == "save" {
		local status = 1
	}
	else if "`1'" == "load" {
		local status = 2
	}
	else if "`1'" == "create" {
		local status = 4	
	}
	
	*status 5 is create and then save. no status 3.
	
	local using "`2'"
	qui {
		preserve
			clear
			** create empty dataset
			if `status' == 1 | `status' == 4 {
				mata st_local("nn",strofreal(rows(multishell_overview)))
				clear
				set obs `nn'
				mata tmp = multishell_overview[.,(1,7)]
				getmata (id options) =   tmp  , replace
				destring id, replace
				*** Version prior to Stata 15
				** Obtain seed from random.org
				if `c(stata_version)' < 15 {					
					gen seed = ""
					if `status' == 4 & "`seed'" == "random" {
						local status = 5
						forvalues i = 1(1)`nn' {
							tempname res
							_return hold `res'
							qui multishell_setrngseed
							replace seed = "`r(seed)'" in `i'
							_return restore `res'
						}
					}
					else if `status' == 4 & "`seed'" != "" {
						local status = 5
						replace seed = "`seed'"
					}
				}
				** Stata Version 15				
				if `c(stata_version)' >= 15 {
					gen seed = ""
					gen stream = ""
					if `status' == 4 & "`seed'" == "random" {
						local status = 5
						tempname res
						_return hold `res'
						qui multishell_setrngseed
						replace seed = "`r(seed)'" 
						_return restore `res'
					}
					else if `status' == 4 & "`seed'" != "" {
						local status = 5
						replace seed = "`seed'"
					}
					else {
						** case Stata 15, create seed used but no seed option. Use current seed.
						** Not in use. create empty dataset
						*local status = 5
						*replace seed = "`r(rngstate)'"
					}
				}
				save "`path'\`using'", replace 
				
				if `status' != 4 {
					forvalues i = 1(1)`nn' {
						multishell_capture mata mata matuse "`path'\\temp\\`i'\\stata_batch_N", replace
						mata seed[1,2] = "`status'"
						multishell_capture mata mata matsave "`path'\\temp\\`i'\\stata_batch_N" seed stata_batch_N multishell_stats_N, replace
					}
				}
			}			
			** For save, create and time: create new dataset with row for each 
			if `status' == 2 | `status' == 5 {
				use `"`path'\\`using'"', clear
				
				mata st_local("nn",strofreal(rows(multishell_overview)))
				forvalues i = 1(1)`nn' {
					** load stata batch N
					multishell_capture mata mata matuse "`path'\\temp\\`i'\\stata_batch_N", replace
					** set status to seed
					if "`noseedstream'" == "noseedstream" {
						mata seed[1,1] = "1"
					}
					mata seed[1,2] = "`status'"
					mata seed[1,3] = "`=seed[`i']'"
					multishell_capture mata mata matsave "`path'\\temp\\`i'\\stata_batch_N" seed stata_batch_N multishell_stats_N, replace
				}			
			}
			
			
			
			if `status' == 5 & `c(stata_version)' < 15 & "`seed'" == "random" {
				noi display in smcl "Seeds filled with 'random' seeds from random.org. "
				noi display in smcl as error "Random number generator can produce identical stream of random numbers."
				noi display in smcl as text "Please see{help multishell##seed: multishell seed} or use Stata 15."
			}
			
		restore
		return scalar seed_option = `status'
		return scalar rngstate = `rngstate'
		return local seed_file = "`using'"
	}
end

program define multishell_getExePath, rclass
	tempname res
	_return hold `res'
	if "`r(exepath)'" == "" {
		*** find Exefile in sysdir. If only 1 file, use this, if many, compile Stata exe and then check if exists.
		*fs "`c(sysdir_stata)'/*.exe"
		
		local datafiles: dir "`c(sysdir_stata)'" files "*.exe"
		
		if wordcount(`"`datafiles'"') == 1 {
			local exepath "`c(sysdir_stata)'/`datafiles'"
			local exename `"`datafiles)'"'
		}
		else {
			if `c(SE)' == 1 & `c(MP)' == 0 {
				local type "SE"
			}
			else if `c(SE)' == 0 & `c(MP)' == 1 {
				local type "MP"
			}
			else {
				local type "IC"
			}
			local exepath "`c(sysdir_stata)'Stata`type'-`c(bit)'.exe"
			local exename "Stata`type'-`c(bit)'.exe"
			
			if fileexists("`exepath'") == 0 {
				display as smcl "No Stata exe found. Please set a path using {help multishell##settingup:multishell exepath}."
				exit
			}
		}
		
		return local exepath "`exepath'"
		return local exename "`exename'"
		
	}
	else {
		return local exepath "`r(exepath)'"
		local pos = strrpos("`exepath'","/") 
		if `pos' == 0 {
			local pos = strrpos("`exepath'","\")
		}
		local exename ustrright("`exepath'",`pos')
		return local exename "`exename'"
	}
	_return restore `res'
	return add
end



program define multishell_run, rclass
	syntax [anything] , threads(string) sleep(string) [NOSTOP nolog stop(passthru) maxtime(passthru) ncls continue seedstream]
		
		multishell_getExePath
		
		* Initalise ID. If option continue is used, check if not create
		if ("`stop'" != "" | "`maxtime'" != "") & "`continue'" == ""  {
			multishell_GetStataID , start path("`r(path)'") newid(0) exename("`r(exename)'")
		}
		else if ("`stop'" != "" | "`maxtime'" != "") & "`continue'" != ""  {
			capture mata rows(StataProcessID)
			if _rc != 0 {
				noi disp "No old Instances of multishell found. Build new process ID list."
				noi disp as smcl "See {help multishell##specific: Stop tasks in multishell}."
				multishell_GetStataID , continue path("`r(path)'")  exename("`r(exename)'")
			}
			else {
				noi disp "Old Instances of multishell found. Use process ID of those."
			}
		}
		
		if "`seedstream'" != "" & "`r(seed_option)'" == "" {
			if `c(stata_version)' < 15 {
				disp "Option seedstream only available in Stata 15 or later."
			}
			else {
				disp "Add seed stream with current stream"				
				multishell seed create seedfile , rngstate("`c(rngstate)'") 
			}
		}
		
		if "`threads'" == "" {
			local threads = 8
		}
		if "`sleep'" == "" {
			local sleep 500
		}
		
		if "`anything'" == "client" {
			multishell_run_client , threads(`threads') sleep(`sleep') `nostop' `log' `log' `stop' `maxtime' `ncls'
			if "`nostop'" != "" {
				local i = 0
				while `i' == 0 {
					*neverending loop!
					multishell_run_client , threads(`threads') sleep(`sleep') `nostop' `log' `log' `stop' `maxtime' `ncls'
				}
			}
		}
		else {
			multishell_run_server, threads(`threads') sleep(`sleep') `log' `stop' `maxtime' `ncls'
		}

end


**This program calls the client. 
*Steps
*1. create client file
*2. wait for server
*3. run until all is done
program define multishell_run_client
	syntax [anything] , threads(string) sleep(string) [nostop nolog stop(passthru) maxtime(passthru) ncls]
	
	local exename "`r(exename)'"
	local path  "`r(path)'"	
	
	*1. Create Client File
	local hostname "`c(hostname)'"
	mata Info = ("`hostname'","`threads'")
	qui multishell_capture mata mata matsave "`path'\\Client_`hostname'" Info, replace	
	
	*2. Wait for server to distribute tasks
	**check if overview file exists if not, 
	local exists =	0
	display "Check if multishell Server is set-up." _c
	while `exists' < 1 {
		local exists =	fileexists("`path'\\multishell_overview.mmat")
		disp ".", _c
		sleep `sleep'
	}
	dis ""
	display "multishell Server set up, waiting for assigned tasks (for `hostname')." _c
	local AssignedTasks = 0
	while `AssignedTasks' == 0 {
		if fileexists("`path'\\multishell_overview.mmat") == 1 {
			qui multishell_capture mata mata matuse "`path'\\multishell_overview.mmat", replace
			mata st_local("AssignedTasks",strofreal(sum((multishell_overview[.,8]:=="`hostname'"))))
			disp ".", _c
		}
		else {
			local AssignedTasks = 0 
			disp "x", _c
		}
		* make sure client still exists
		if fileexists("`path'\\Client_`hostname'.mmat") == 0 {
			mata Info = ("`hostname'","`threads'")
			qui multishell_capture mata mata matsave "`path'\\Client_`hostname'" Info, replace
		}
		*only sleep if necessary
		if `AssignedTasks' == 0 {
			sleep `sleep'	
		}
	}
	
	mata st_local("todo",strofreal(rows(multishell_overview)))
	mata st_local("done",strofreal(sum(multishell_overview[.,4]:=="3")))
	mata st_local("stopped",strofreal(sum(multishell_overview[.,4]:=="4")))
	mata st_local("left",strofreal(sum(multishell_overview[.,4]:=="0")))
	mata st_local("RunningThis",strofreal(sum((multishell_overview[.,4]:=="2"):*(multishell_overview[.,8]:=="`hostname'"))))
	
	local starttime "`c(current_date)' `c(current_time)'"	
	
	** count stopped as done
	local done = `done' + `stopped'
	local while_check = ((`done' < `todo')==1 | (`left' == 0 & `RunningThis' == 0) == 0)
	
	while `while_check' == 1 {
		qui multishell_capture mata mata matuse "`path'\\multishell_overview.mmat", replace
		
		
		** check here time and if tasks need to be finished
		multishell_StopMaxTime , `maxtime' `stop' path("`path'") exename("`exename'")
		noi return list
		noi disp `"interrupt at: `r(interrupt)' with `maxtime' `stop'"'
		if `r(interrupt)' == 3 {
			local while_check = 0
		}
		else if `r(interrupt)' == 0 | `r(interrupt)' == 1 | `r(interrupt)' == 2 {
			
			mata st_local("todo",strofreal(rows(multishell_overview)))
			mata st_local("done",strofreal(sum(multishell_overview[.,4]:=="3")))
			mata st_local("stopped",strofreal(sum(multishell_overview[.,4]:=="4")))
			mata st_local("left",strofreal(sum(multishell_overview[.,4]:=="0")))
			mata st_local("RunningThis",strofreal(sum((multishell_overview[.,4]:=="2"):*(multishell_overview[.,8]:=="`hostname'"))))
					
			multishell_start_batch "`hostname'"	,`log'	`maxtime' `stop'
			multishell_output multishell_overview , sleep(`sleep')  starttime("`starttime'") `ncls' `maxtime' `stop'
			
			** count stopped as done
			local done = `done' + `stopped'
			local while_check = ((`done' < `todo')==1 | (`left' == 0 & `RunningThis' == 0) == 0)
			
			
			
			*only sleep if necessary
			if `while_check' == 1 {
				sleep `sleep'
			}
		}
		else {
			local while_check = 0
		}
	}
end


		

** Server program. Starts the server and organises the files to run
*1. Load Overview and get number of tasks to do
*2. Start loop and maintain until all tasks done
* Loop:
*1. Refresh overview
*2. Get clientlist and add server
*3. Loop over clientlist and assign tasks
*4. Save changed overview
*5. Update todo and done
*6. Start own tasks
*7. Output
program define multishell_run_server 
	syntax [anything] , threads(string) sleep(string) [seedsave(string) nolog stop(passthru) maxtime(passthru) ncls]
	local path  "`r(path)'"	
	local starttime "`c(current_date)' - `c(current_time)'"
	local seed "`r(seed_option)'"
	local seedfile "`r(seed_file)'"
	local exename "`r(exename)'"
	*1. Load Overview
	multishell_refresh_overview  `path'
	mata st_local("total",strofreal(rows(multishell_overview)))
	mata st_local("todo",strofreal(sum(multishell_overview[.,4]:=="0")))
	mata st_local("done",strofreal(sum(multishell_overview[.,4]:=="3")))
	mata st_local("stopped",strofreal(sum(multishell_overview[.,4]:=="4")))
	** count stopped as done
	local done = `done' + `stopped'
	** here todo >= 0, necessary for restarted
	local loop_check = (((`todo' >= 0) == 1) & ((`done' < `total')==1))
		
	*2. LOOP
	while (`loop_check'==1) {
		*1 Refresh Overview
		multishell_refresh_overview  `path'		
		
		** check here time and if tasks need to be finished
		multishell_StopMaxTime , `maxtime' `stop' path("`path'") exename("`exename'")
		*noi mata StataProcessID
		
		local interrupt = `r(interrupt)'
				
		*2. Open client list
		multishell_clientlist
		*Add this computer
		mata ClientList = (ClientList \ (strofreal(rows(ClientList)),"`c(hostname)'","`threads'"))
		
		*3. Loop over clientlist and assign new tasks, pnly if not interrupted
		if `interrupt' < 3 {
			mata st_local("num_clients",strofreal(rows(ClientList)))
			forvalues i = 1(1)`num_clients' {
				mata st_local("ClientName",ClientList[`i',2])
				mata st_local("numThreads",ClientList[`i',3])
				
				**count assigned or running tasks by client
				mata index = (((multishell_overview[.,4]:=="1"):+(multishell_overview[.,4]:=="2")):*(multishell_overview[.,8]:=="`ClientName'"))
				mata st_local("RunningClient",strofreal(sum(index)))
				
				**count remaining tasks
				mata st_local("TasksLeft",strofreal(sum(multishell_overview[.,4]:=="0")))
				local toassign = `numThreads' - `RunningClient'

				while `=`toassign'*`TasksLeft'' > 0 {				
					**get first occurence of a 0
					mata index2 = selectindex(multishell_overview[.,4]:=="0")[1]
					
					mata multishell_overview[index2,4] = "1"
					mata multishell_overview[index2,8] = "`ClientName'"
					
					local toassign = `toassign' - 1
					mata st_local("TasksLeft",strofreal(sum(multishell_overview[.,4]:=="0")))
				}			
			}
		}
		* Save Overview
		multishell_capture mata mata matsave  "`path'\\multishell_overview.mmat" multishell_overview , replace
		
		*6. Start Own task
		if `interrupt' != 3 {
			qui multishell_start_batch "`c(hostname)'"		,`log'	`maxtime' `stop'
		}
		
		*4. Save Overview
		*multishell_capture mata mata matsave  "`path'\\multishell_overview.mmat" multishell_overview , replace
		
		*5. Update todo and done
		mata total = rows(multishell_overview[.,4])
		mata todo = sum(multishell_overview[.,4] :== "0")
		mata assigned = sum(multishell_overview[.,4] :== "1")
		mata running = sum(multishell_overview[.,4] :== "2")
		mata done = sum(multishell_overview[.,4] :== "3")
		mata stopped = sum(multishell_overview[.,4] :== "4")
		mata errors = total - todo - assigned - running - done - stopped
		
		mata st_local("errors",strofreal(errors))
		mata st_local("todo",strofreal(todo))
		mata st_local("done",strofreal(done))
		mata st_local("total",strofreal(total))
		mata st_local("stopped",strofreal(stopped))
		
		** count stopped as done
		local done = `done' + `stopped'
		local loop_check = (((`todo' > 0) == 1) | ((`=`done'+`errors'' < `total')==1))

		*7. Output 
		multishell_output multishell_overview , sleep(`sleep') starttime("`starttime'") `ncls' `maxtime' `stop'			
		
		*only sleep if necessary
		if `loop_check' == 1 {
			sleep `sleep'
		}
	}
	
	if "`seed'" == "1" | "`seed'" == "4" | "`seed'" == "5" {
		qui {
			mata st_local("nn",strofreal(rows(multishell_overview)))
			preserve
				clear
				use "`path'\\`seedfile'", clear	
				forvalues i = 1(1)`nn' {	
					qui multishell_capture mata mata matuse "`path'\\temp\\`i'\\stata_batch_N", replace
					mata st_local("id",seed[1,1])
					mata st_local("seed_i",seed[1,3])
					if `id' == `i' {
						replace seed = "`seed_i'" if id == `id'
						if `c(stata_version)' >= 15 {
							replace stream = "`id'" if id == `id'
						}
					}
				}
				qui save "`path'\\`seedfile'" , replace
				noi display "File with seeds saved in `path'\\`seedfile'.dta."
			restore
		}
	}
end	



program define multishell_refresh_overview
	syntax anything 
	local path "`anything'"
	if fileexists("`path'\\multishell_overview.mmat") == 1 {
		qui multishell_capture mata mata matuse "`path'\\multishell_overview", replace	
		*loop over all entries and replace running number those from the stata_batch_N files
		mata st_local("multishellN",strofreal(rows(multishell_overview)))		
		forvalues rows = 1(1)`multishellN' {
			mata st_local("path_i",multishell_overview[`rows',3])
			qui multishell_capture mata mata matuse `"`path'\\`path_i'\\stata_batch_N"' , replace
			mata multishell_overview[`rows',4] = stata_batch_N[1]
			mata multishell_overview[`rows',5] = stata_batch_N[2]
			mata multishell_overview[`rows',8] = stata_batch_N[3]
			
		}
	}
	else {
		display "No files added."
		exit
	}
end


program define multishell_start_batch
	syntax anything , [nolog stop(string) maxtime(string) ]
		local path "`r(path)'"
		local exename "`r(exename)'"
		**get number of tasks to open
		mata index = selectindex((multishell_overview[.,4]:=="1"):*(multishell_overview[.,8]:==`anything'))
		mata index = multishell_overview[index,.]
		mata st_local("to_open",strofreal(rows(index)))
		
		forvalues i = 1(1)`to_open' {
			mata st_local("do_file_to_run",index[`i' ,2])
			mata st_local("subpath",index[`i',3])
			mata st_local("multishelln",index[`i',1])
			**check if stata_batch_N is 0 (not running) then start, otherwise skip
			multishell_capture mata mata matuse "`path'\\`subpath'\stata_batch_N", replace
			mata st_local("check_N",stata_batch_N[1,1])
			
			if `check_N' == 0 {
				multishell_create_batch `do_file_to_run' , multishelln(`multishelln') `log'
			
				local S_run `"`path'\\`subpath'\\`do_file_to_run'.bat"'
			
				*** Run batch file
				winexec "`S_run'"
				
				*** Update IDs
				if `"`stop'"' != "" | `"`maxtime'"' != "" {
					sleep 500
					multishell_GetStataID , path("`path'") newid(`multishelln') exename("`exename'")			
				}			
				mata multishell_overview[strtoreal(index[`i',1]),4] = "2"
				*noi disp "Started `S_run'"
			}
			mata mata drop stata_batch_N seed
		}	
end

program define multishell_create_batch
	syntax anything , multishelln(string) [nolog]
	local path "`r(path)'"
	local hostname "`s(hostname)'"
	local adopath "`r(adopath)'"
	local exepath "`r(exepath)'"
	local rngstate "`r(rngstate)'"
		
	local dofile_original "`anything'"
	local multishellN `multishelln'
	
	local path_long `"`path'\\temp\\`multishellN'"'
	
	local batfile `"`path_long'\\`dofile_original'.bat"'
	
	local do_temp `"`path_long'\\`anything'_tmp.do"'
	local do_final `"`path_long'\\`anything'.do"'
	
	tempname dofile dofilenew
	
	tempname return
	_return  hold `return'
			
	** Correct do file
	multishell_capture file open `dofile' using `"`do_temp'"' , read  
	multishell_capture file open `dofilenew' using `"`do_final'"' , w replace
	
	*** HERE SEED, at the very beginning as multishell change saves the seed
	mata st_local("stream",seed[1])
	mata st_local("seed_state",seed[2])
	mata st_local("seed",seed[3])
	
	*** Stata >= 15 block
	if `seed_state' == 2 | `seed_state' == 5 {
		
		if "`rngstate'" == "1" {
			local SeedORRngstate "rngstate"
		}
		else {
			local SeedORRngstate "seed"
		}
		
		if `c(stata_version)' >= 15 {
			file write `dofilenew' `"set rng mt64s"' _n
			file write `dofilenew' `"set rngstream `stream'"' _n
			file write `dofilenew' `"set `SeedORRngstate' `seed'"' _n		
		}
		if `c(stata_version)' < 15 {
			file write `dofilenew' `"set `SeedORRngstate' `seed'"' _n			
		}
	}	
	
	*local rcval : macval("`rcval'")
	if "`adopath'" != "" {
		file write `dofilenew' `"adopath + "`adopath'""' _n
	}
	file write `dofilenew' `"multishell change `"`path'\temp\\`multishellN'\stata_batch_N"' , changeval(2) rc(0) "' _n
	

	
	file write `dofilenew' "capture noi{"  _n
	if "`log'" == "" {
		file write `dofilenew' `"capture log close"' _n
		file write `dofilenew' `"log using `"`path'\temp\\`multishellN'\\`dofile_original'.smcl"', replace "'  _n
	}
	
	*** display start screen
	file write `dofilenew' "multishell StartDisplay" _n
	
	file read `dofile' temp
	while r(eof) == 0 {
		file write `dofilenew' `"`macval(temp)'"' _n
		file read `dofile' temp
	}
	if "`log'" == "" {
		file write `dofilenew' `"capture log close"'  _n
	}
	file write `dofilenew' "}"  _n
	file write `dofilenew' `"local rcval = _rc"' _n
	file write `dofilenew' `"display _rc"' _n
	file write `dofilenew' `"multishell change `"`path'\temp\\`multishellN'\stata_batch_N"' , changeval(3) rc(rcvalueToBeRep)"' _n
	file close `dofile'
	file close `dofilenew'
			
	*write batch
	tempname file

	multishell_capture file open `file' using `"`batfile'"' , w  text replace
	file write `file' `"@ECHO OFF"' _n 
	file write `file' `"set STATATMP=`path'temp\\`multishellN'"' _n
	file write `file' `"cd `path'temp\\`multishellN'"' _n
	file write `file' `" "`exepath'" /e do "`do_final'""' _n
	*file write `file' `"copy "`path'\temp\\`multishellN'\\`logfile'" "`path'\\`logfile'" /Y"' _n
	file write `file' "EXIT"
	file close `file'
	
	**replace rcvalues and time
	multishell_capture filefilter `"`do_final'"' `"`do_temp'"' , from("rcvalueToBeRep") to("\LQrcval\RQ") replace
	multishell_capture filefilter `"`do_temp'"' `"`do_final'"', from("TimeToBeRep")  to("\LQc(current_date)\RQ - \LQc(current_time)\RQ") replace
	
	**replace user specified changes
	_return restore `return', hold 
	local i = 1
	while "`r(alttext`i')'" ~= "" {		
		tokenize `r(alttext`i')' , parse("@")
		local fromold = ustrrtrim("`1'")
		local tochange = ustrrtrim("`3'")
		local tochange = subinstr("`tochange'","\","\BS",.)
		local tochange = subinstr("`tochange'","`","\LQ",.)
		local tochange = subinstr("`tochange'","'","\RQ",.)
		local tochange = subinstr("`tochange'",`"""',"\Q",.)
		local tochange = subinstr("`tochange'","$","\$",.)
		filefilter `"`do_final'"' `"`do_temp'"' , from("`fromold'") to("`tochange'") replace
		*empty to copy back
		sleep 100
		filefilter `"`do_temp'"' `"`do_final'"' , from("") to("") replace
		local i = `i' + 1
		_return restore `return', hold 
	}
	
	_return restore `return', hold 
	
	
end


program define multishell_clientlist
	syntax [anything]
	
	local path "`r(path)'"
	
	local datafiles : dir "`path'" files "Client_*"
	
	mata ClientList = J(0,3,"")
	local i = 1
	foreach file in `datafiles' {
		qui multishell_capture mata mata matuse "`path'\\`file'", replace
		mata ClientList = (ClientList \ ("`i'" , Info))
		local i++
	}
	
end

program define multishell_change
	syntax anything , [changeval(string) rc(string) time(string) number(string)]
		multishell_capture mata mata matuse "`anything'", replace
		noi disp "rc: `rc'"
		if "`rc'" != "0" {
			display "Error `rc' in file `number'."
			mata stata_batch_N = ("Error (`rc')","`c(current_date)' - `c(current_time)'","`c(hostname)'")
		}
		else {
			mata stata_batch_N = ("`changeval'","`c(current_date)' - `c(current_time)'","`c(hostname)'")
		}
		
		*set or save new seed only if changeval = 2 (to running)
		*save seed
		mata seed_old = seed
		if `changeval' == 2 {			
			mata seed[1,3] = "`c(rngstate)'"		
		}	
		multishell_capture mata mata matsave "`anything'" stata_batch_N seed multishell_stats_N, replace
end


program define multishell_add 
	syntax anything , [Path(string) EXepath(string) mainfile(string) macnameadd(string) strict ]
		
		local dopath `"`anything'"'
		
		if "`exepath'" == "" {
			local exepath  "`r(exepath)'"
		}
		if "`path'" == "" {
			local path  "`r(path)'"
		}
		
		**check if overview exists
		local exists =	fileexists("`path'\\multishell_overview.mmat")
		if `exists' == 0 {
			mata multishell_overview = J(0,8,"")
			multishell_capture mata mata matsave  "`path'\\multishell_overview" multishell_overview , replace
			*clean tempdir
			shell mkdir "`anything'\temp"
		}
		
		tempname return
		_return  hold `return'
		
		*get number of files
		multishell_capture mata mata matuse "`path'\multishell_overview", replace
		mata st_local("multishellN",strofreal(rows(multishell_overview)))
		local multishellN = `multishellN' + 1
		**Get do file name
		tokenize `dopath' , p("\")	
		while "`1'" != "" {
			local dofilename "`*'"
			macro shift
		}
		
		local dofilename = subinstr("`dofilename'",".do","",.)
		local dofilename =  ustrrtrim("`dofilename'")
		local dofilename =  ustrtoname("`dofilename'")
				
		**add folder
		shell mkdir "`path'\temp\\`multishellN'"

		*location for batch file
		local logfile = subinstr("`dofilename'",".do",".log",.)
		
		*** check for multishell loop
		tempname LoopCheck
		multishell_capture file open `LoopCheck' using `"`dopath'"' , read  text
		file read `LoopCheck' temp
		local strictint = ""
		while r(eof) == 0 {
			if regexm(`"`temp'"',"multishell loop") == 1 {
				local strict = "strict"
				continue, break
			}
			file read `LoopCheck' temp
		}
		file close `LoopCheck'
		
		***check if loops in file
		local foreach_indic = 0
		tempname fors m_foreach_indic
		mata `fors' = J(0,3,"")
		mata `m_foreach_indic' = J(0,2,.)

		tempname source dofile_nob_name
		multishell_capture file open `source' using `"`dopath'"' , read  text
		multishell_capture file open `dofile_nob_name' using `"`path'\temp\\`multishellN'\\`dofilename'_tmp.do"' , write replace		
		
		file read `source' temp
		
		while r(eof) == 0 {
			if  regexm(`"`temp'"',"forval") == 1 |  regexm(`"`temp'"',"foreach") == 1 {
				if (regexm(`"`temp'"',"multishell loop") == 1 & "`strict'" == "strict") | "`strict'" == "" {
					mata `fors' = (`fors' \ ("`r(loc)'","`macval(temp)'","1"))
					mata `m_foreach_indic'[.,1] = (`m_foreach_indic'[.,1]:+1:*(`m_foreach_indic'[.,1]:!=-999))
					mata `m_foreach_indic' = (`m_foreach_indic' \ (1,0))
					local foreach_indic = 1
				}
			}
			
			else if `foreach_indic' == 1 {
				if  regexm(`"`temp'"',"}") == 1 {
					mata `m_foreach_indic'[.,1] = (`m_foreach_indic'[.,1]:-1:*(`m_foreach_indic'[.,1]:!=-999))
					
					mata st_local("check",strofreal(sum(`m_foreach_indic'[.,1]:==0)))
					if "`check'" > "0" {
						local temp ""
					}
				}
			}
			
			file write `dofile_nob_name' `"`macval(temp)'"' _n
			file read `source' temp

		}
		file close `source'
		file close `dofile_nob_name'
		
		if `foreach_indic' == 1 {
			mata st_local("todo",strofreal(rows(`fors')))

			local i = 1
			mata st_local("loop",`fors'[`i',2])
			local loop2 = subinstr("`loop'","{","",.)
			local loop2 = subinstr("`loop2'","/*","",.)
			local loop2 = subinstr("`loop2'","*/","",.)
			local loop2 = subinstr("`loop2'","multishell loop","",.)
			
			tokenize `loop2'
			local typeloop `"`1'"'

			macro shift
			local macname `1'
			local rest `*'
			
			if regexm("`typeloop'","foreach") == 1 {
				foreach `*'  {			
					if "``macname''" != "" {
						*local dofile2 = subinstr("`dofilename'",".do","_``macname''.do",.)
						filefilter `"`path'\temp\\`multishellN'\\`dofilename'_tmp.do"' `"`path'\temp\\`multishellN'\\`dofilename'_``macname''.do"'   , from("`loop'") to("local `macname' \Q``macname''\Q") replace
						multishell_add `path'\temp\\`multishellN'\\`dofilename'_``macname''.do , p(`path') ex(`exepath') mainfile("`mainfile'") macnameadd("`macnameadd' , `macname' = ``macname''") `strict'
						
					}
				}
			}
			else if regexm("`typeloop'","forval") == 1 {
				forvalues `*'  {			
					if "``macname''" != "" {
						*local dofile2 = subinstr("`dofilename'",".do","_``macname''.do",.)
						filefilter `"`path'\temp\\`multishellN'\\`dofilename'_tmp.do"' `"`path'\temp\\`multishellN'\\`dofilename'_``macname''.do"', from("`loop'") to("local `macname' = ``macname''") replace
						multishell_add `path'\temp\\`multishellN'\\`dofilename'_``macname''.do  , p(`path') ex(`exepath') mainfile("`mainfile'") macnameadd("`macnameadd' , `macname' = ``macname''") `strict'
						
					}
				}
			}
		}
		
		else {			
			*add mata matrix
			capture multishell_capture mata mata matuse "`path'\multishell_overview", replace
			if _rc != 0 {
				mata multishell_overview = J(0,7,"")
			}
			mata multishell_overview = (multishell_overview \ ("`multishellN'" , "`dofilename'" , "\temp\\`multishellN'","0","","`mainfile'","`macnameadd'",""))
			mata stata_batch_N = ("0","`c(current_date)' - `c(current_time)'","")
			mata multishell_stats_N = ("`multishellN'","`path'/temp/`multishellN'","`dofilename'","`mainfile'","`macnameadd'")
			**here seed ("id","state: 0 no seed, 1: save seed, 2: use seed, 3: time seed","seed")
			mata seed = ("`multishellN'","0","")
			multishell_capture mata mata matsave `"`path'\temp\\`multishellN'\stata_batch_N"' stata_batch_N seed multishell_stats_N, replace 
			multishell_capture mata mata matsave  `"`path'\multishell_overview"' multishell_overview , replace			
		}
		
		_return restore `return', hold 
end



program define multishell_StopMaxTime, rclass
syntax [anything] , [maxtime(string) stop(string) path(string) exename(string)]	
		local interrupt = 0
		
		tempname returns
		_return hold `returns'
		
		** Check for Time here
		if "`stop'" != "" {
			** tokenize stop
			tokenize "`stop'" , parse(",")
			local time "`1'"
			local options "`3'"
			** convert stop time into minutes
			local end_time = clock("`time'","DMYhm")

			if `end_time' == . {
				noi display "Please specify time in the format: DD.MM.YYYY HH:MM, like 11.09.2018 12:10. Format was `time'"
				exit 199
			}
			
			** get current time
			local current_time =clock("`c(current_date)' `c(current_time)'","DMYhms")

			if `current_time' > `end_time' {
				local interrupt = 2
				if "`options'" == "killall" {
					** get ids which are running
					mata Running = multishell_overview[selectindex(((multishell_overview[.,8]:=="`c(hostname)'") :* (multishell_overview[.,4]:=="2"))),1]
					mata st_local("TaskToKillList",invtokens(Running'))
					local interrupt = 3
				}
			}
			
		}
		** Check if any running instance is overdue. Also only do it if interrupt is 0 or 2 (i.e. tasks are still running)
		if "`maxtime'" != "" & (`interrupt' == 0 | `interrupt' == 2) {
			
			** tokenize stop
			tokenize `maxtime' , parse(",")
			local max_hrs = clock("`1'","hm")
			local options "`3'"
			
			mata Running = multishell_overview[selectindex(((multishell_overview[.,8]:=="`c(hostname)'") :* (multishell_overview[.,4]:=="2"))),1]
				mata st_local("RunningList",invtokens(Running'))
				
				foreach task in `RunningList' {
					multishell_capture mata mata matuse "`path'/temp/`task'/stata_batch_N", replace
					mata st_local("StartTime",stata_batch_N[2])
					
					local StartTime = clock("`StartTime'","DMYhms")
					local CurrentTime =clock("`c(current_date)' `c(current_time)'","DMYhms")
					
					if `=`CurrentTime'-`StartTime'' > `max_hrs' {
						local interrupt = 1
						local TaskToKillList "`TaskToKillList' `task'"
					}
				}
		}
		
		
		if `interrupt' > 0 {		
			foreach TaskToKill in `TaskToKillList' {	
				*noi disp "Tasks to kill: `TaskToKillList'"
				multishell_capture mata mata matuse "`path'/temp/`TaskToKill'/stata_batch_N", replace
				mata stata_batch_N[1,1] = "4"
				mata stata_batch_N[1,2] = "`c(current_date)' `c(current_time)'"
				multishell_capture mata mata matsave "`path'/temp/`TaskToKill'/stata_batch_N" stata_batch_N seed multishell_stats_N, replace
				mata multishell_mm_KillStata("`TaskToKill'",StataProcessID)
			
			}
			local TaskToKillList ""
			
			** Update running list
			multishell_GetStataID , path("`path'") update exename("`exename'")
			
		}
		** Values for interrupt (keep running for tasks 0 - 2)
		* 0: all good
		* 1: task running longer than allowed. kill specific task. continue multishell
		* 2: program running longer than allowed, do not start further tasks, continue multishell
		* 3: program running longer than allowed, kill all tasks and close multishell
		return clear
		_return restore `returns', hold
		return add
		return local interrupt = `interrupt'
	end






program define multishell_output
	syntax anything , [sleep(string) starttime(string) ncls stop(string) maxtime(string) ]
	
	mata st_local("rows",strofreal(rows(`anything')))
	if "`ncls'" == "" {
		cls
	}
	dis as text "{hline 100}"
	dis as text _col(2) "#" _col(6) "do-file" _col(45) "State" _col(60) "Time" _col(85) "Machine"
	dis as text "{hline 100}"
	forvalues r = 1(1)`rows' {
		mata st_local("dofile_orginal",`anything'[`r',2])
		mata st_local("state",`anything'[`r',4])
		mata st_local("time",`anything'[`r',5])
		local maindo_old "`maindo'"
		mata st_local("maindo",`anything'[`r',6])
		mata st_local("loop",`anything'[`r',7])
		mata st_local("machine",`anything'[`r',8])
		
		if "`state'" == "0" {
			local staten = "queued"
		}
		else if "`state'" == "1" {
			local staten = "assigned"
		}
		else if "`state'" == "2" {
			local staten = "running"
		}
		else if "`state'" == "3" {
			local staten = "finished"
		}
		else if "`state'" == "4" {
			local staten = "stopped"			
		}
		else {
			local staten = "`state'"
		}
				
		
		**case that no loops:
		local dofile = subinstr("`dofile_orginal'",".bat",".do",.)
		local dofile = subinstr("`dofile'"," .bat",".do",.)
		if "`dofile'" == "`maindo'" {			
			local dofile = strreverse("`dofile'")		
			tokenize `dofile' , p("\")
			local dofile = strreverse("`1'")
			if "`state'" != "0" & "`state'" != "1" & "`state'" != "2" {
				** point to logfile in smcl. Check first if it exists
				if fileexists("`r(path)'\temp/`r'/`dofile_orginal'.smcl") == 1 {
					local staten `"{view `""`r(path)'/temp/`r'/`dofile_orginal'.smcl""' :`staten'}"'
				}
			}
			dis as text _col(2) "`r'" _col(6) abbrev("`dofile'",35) _col(45) `"`staten'"' _col(60) "`time'"  _col(85) "`machine'"
		
		}
		else {
			**check if new main do file, if so add panel above with name of do file and state
			if "`maindo_old'" != "`maindo'" {
				local dofile = strreverse("`maindo'")		
				tokenize `dofile' , p("\")
				local dofile = strreverse("`1'")
				
				**get states
				mata dof = strtoreal(`anything'[selectindex(`anything'[.,6] :== "`maindo'"),4])
				mata st_local("state_nn",strofreal(sum(dof)/rows(dof)))
				local state_nn = `state_nn'
				if `state_nn' == 0 {
					local state_nn = "queued"
				}
				else if `state_nn' > 0 & `state_nn' < 2 {
					local state_nn = "queued and running"
				}
				else if `state_nn' == 2 {
					local state_nn = "running"
				}
				else if `state_nn' > 2 & `state_nn' < 3 {
					local state_nn = "running and finished"
				}
				else if `state_nn' == 3 {
					local state_nn = "finished"
				}
				else if `state_nn' >3 & `state_nn' < 4 {
					local state_nn "finished and stopped"
				}
				else if `state_nn' == 4 {
					local state_nn = "stopped"
				}
				else {
					local state_nn = "Error (`state_nn')"
				}				
				
				dis as text _col(2) "" _col(6) "`dofile'" _col(45) "`state_nn'" _col(60) ""
			
			}
			if "`state'" != "0" & "`state'" != "1" & "`state'" != "2" {
				** point to logfile in smcl. Check first if it exists
				if fileexists("`r(path)'\temp/`r'/`dofile_orginal'.smcl") == 1 {
					local staten `"{view `""`r(path)'/temp/`r'/`dofile_orginal'.smcl""' :`staten'}"'
				}
			}
			local dofile = subinstr("`loop'",",","  ",1)			
			dis as text _col(2) "`r'" _col(6) abbrev("`dofile'",35) _col(45) `"`staten'"' _col(60) "`time'"  _col(85) "`machine'"
		}		
		

	}
	
	**** Bottom Statistics
	
	dis as text "{hline 100}"
	dis as text _col(2) "Machine" _col(20) "Queued" _col(30) "Assigned" _col(40) "Running"  _col(50) "Finished" _col(60) "Stopped" _col(70)"Total"
	mata machine = uniqrows(`anything'[.,8])
	mata st_local("Nmachine",strofreal(rows(machine)))
	if `Nmachine' > 1 {
		forvalues i = 1(1)`Nmachine' {
			mata st_local("name",machine[`i'])
			if "`name'" != "" {
				mata st_local("stopped",strofreal(sum((`anything'[.,8]:==machine[`i']):*(`anything'[.,4]:=="4"))))
				mata st_local("finish",strofreal(sum((`anything'[.,8]:==machine[`i']):*(`anything'[.,4]:=="3"))))
				mata st_local("running",strofreal(sum((`anything'[.,8]:==machine[`i']):*(`anything'[.,4]:=="2"))))
				mata st_local("assigned",strofreal(sum((`anything'[.,8]:==machine[`i']):*(`anything'[.,4]:=="1"))))
				mata st_local("queued",strofreal(sum((`anything'[.,8]:==machine[`i']):*(`anything'[.,4]:=="0"))))
				if "`name'" == "`c(hostname)'" {
					local name "This Computer"
				}
				dis as text _col(2) abbrev("`name'",16) _col(20) "`queued'" _col(30) "`assigned'" _col(40) "`running'" _col(50) "`finish'" _col(60) "`stopped'" _col(70) "`=`stopped'+`running'+`finish'+`assigned''"
			}
		}
		dis as text "{hline 100}"
	}
	mata st_local("stopped",strofreal(sum((`anything'[.,4]:=="4"))))
	mata st_local("finish",strofreal(sum((`anything'[.,4]:=="3"))))
	mata st_local("running",strofreal(sum((`anything'[.,4]:=="2"))))
	mata st_local("assigned",strofreal(sum((`anything'[.,4]:=="1"))))
	mata st_local("queued",strofreal(sum((`anything'[.,4]:=="0"))))
	if `Nmachine' > 1 {
		local name = "Total"
	}
	else {
		local name = "This Computer"
	}
	noi disp _col(2) "`name'"  _col(20) "`queued'" _col(30) "`assigned'" _col(40) "`running'" _col(50) "`finish'" _col(60) "`stopped'" _col(70) "`=`stopped'+`running'+`finish'+`assigned''"
	dis as text "{hline 100}"
	dis as text "Computername: `c(hostname)'"
	if "`stop'" != "" {
		if regexm("`stop'","killall") == 1 {
			tokenize "`stop'" , p(",")
			local stop "`1'"
			local killall " with all running tasks closed"
		}
		dis as text "multishell instance will be stopped at `stop'`killall'."
	}
	if "`maxtime'" != "" {
		dis as text "Maximum running time for each task is `maxtime'. Tasks running longer will be stopped."
	}
	if "`starttime'" != "" {
		dis as text "as of `c(current_date)' - `c(current_time)'; started at `starttime'"
	}
	if `c(stata_version)' < 15 {
		noi display in smcl as error "Stata Version < 15 used. Random numbers can overlap."
		noi display in smcl as text "Please see{help multishell##seed: multishell seed} or use Stata 15."
	}
	if "`r(seed_option)'" == "" {
		noi disp "No seed set. Random numbers in all tasks will be the same. Please see{help multishell##seed: multishell seed} and/or use option seedstream in Stata 15."
	}
	if "`sleep'" != "" {
		dis as text "next refresh in `=`sleep'/1000's."
	}

	
end 

program define multishell_StartDisplay
syntax [anything]
	
	local maxleng "`c(linesize)'"
	
	if `maxleng '< 80 {
		local maxleng = "80"
	}
	
	mata st_local("RunningID",multishell_stats_N[1])
	mata st_local("path",multishell_stats_N[2])
	mata st_local("dofile",multishell_stats_N[3])
	mata st_local("mainfile",multishell_stats_N[4])
	mata st_local("cond",multishell_stats_N[5])
	
	** Remove leading "," from cond
	local cond = ustrtrim(subinstr("`cond'",",","",1))
	local path = subinstr("`path'","\","/",.)
	
	** Main File and Path
	local mainfiles = subinstr("`mainfile'","\","/",.)
	local mainpath = strrpos("`mainfiles'","/")
	local mainfile = ustrright("`mainfiles'",strlen("`mainfiles'")-`mainpath')
	local mainpath = ustrleft("`mainfiles'",`mainpath'-1)

	mata st_local("set_seed",seed_old[1,3])	
	
	local ms_disp = floor(8 + (`maxleng' - strlen("Multishell Version 2.0") - 8 - 8) / 2)
	local left_disp = `maxleng' - 25 - 8
	local current_seed "`c(rngstate)'"
	
	foreach lok in mainpath mainfile path dofile RunningID cond {
		if strlen("``lok''") > `left_disp' {
			local `lok' = substr("``lok''",1,`left_disp'-5) + "~"+substr("``lok''",strlen("``lok''")-4,strlen("``lok''"))
		}
	}	

	dis in smcl "`="*"*`maxleng''"
	dis in smcl "*" 																		_col(`maxleng') "*"
	dis in smcl "*" _col(`ms_disp') "Multishell Version 2.0" 								_col(`maxleng') "*"
	dis in smcl "*" 																		_col(`maxleng') "*"
	dis in smcl "*" _col(5) "Parent File Properties"										_col(`maxleng') "*"
	dis in smcl "*" _col(8) "Folder: " _col(25) "`mainpath'"								_col(`maxleng') "*"
	dis in smcl "*" _col(8) "do Filename: " _col(25) "`mainfile'"							_col(`maxleng') "*"
	dis in smcl "*" _col(5) "Running File Properties"										_col(`maxleng') "*"
	dis in smcl "*" _col(8) "Folder: " _col(25) "`path'"									_col(`maxleng') "*"
	dis in smcl "*" _col(8) "do Filename: " _col(25) "`dofile'.do"							_col(`maxleng') "*"
	dis in smcl "*" _col(8) "Variation No.: " _col(25) "`RunningID'"						_col(`maxleng') "*"
	dis in smcl "*" _col(8) "Variation: " 	_col(25) "`cond'"								_col(`maxleng') "*"
	dis in smcl "*" 																		_col(`maxleng') "*"
	dis in smcl "*" _col(5) "Random Number Generator Properties"							_col(`maxleng') "*"
	dis in smcl "*" _col(8) "RNG Type : `c(rng_current)'"									_col(`maxleng') "*"
	if `c(stata_version)' > 15 {
			dis in smcl "*" _col(8) "Seed Stream Number : `c(rngstream)'" 					_col(`maxleng') "*"
	}
	multishell_DisplaySeed , seed("`c(rngstate)'") name("RNG State") maxleng(`maxleng')
	multishell_DisplaySeed , seed("`set_seed'") name("Set Seed") maxleng(`maxleng')
	
	dis in smcl "*" 																		_col(`maxleng') "*"
	dis in smcl "`="*"*`maxleng''"
end


program define multishell_DisplaySeed
syntax [anything] , [seed(string) name(string) maxleng(string)]
	local anything_length = strlen("`name'")
	local seed_length = `maxleng' - 8 - 5 - `anything_length' - 3
	
	local seed_one = ustrleft("`seed'",`seed_length')
	local seed_rest = ustrright("`seed'",strlen("`seed'")-`seed_length')
	
	dis in smcl "*" _col(8) "`name'" " = `seed_one'" _col(`maxleng') "*"

	while "`seed_rest'" != "" {
		local seed_one = ustrleft("`seed_rest'",`seed_length') 
		dis in smcl "*" _col(`=`anything_length' + 8 + 3') "`seed_one'" _col(`maxleng') "*"
		local seed_rest = ustrright("`seed_rest'",strlen("`seed_rest'")-`seed_length')	
	}	
end

program define multishell_capture
syntax anything(everything) , *
	local run = 0
	noi capture `anything' , `options'
	while ((_rc != 0) & (`run' < 5)) {
		noi capture `anything' , `options'
		local run = `run' + 1
		sleep 100
	}
	if `run' >= 5 {
		noi disp `"Failed: `anything'."'
		exit
	}
end

program define multishell_GetStataID
syntax [anything] , path(string)  exename(string) [start update newid(string) continue]
	qui {
		tempname returns
		_return hold `returns'
		preserve
			shell tasklist > "`path'/`c(hostname)' - ids.csv" /fo "CSV" /FI "imagename eq `exename'" /V
			import delimited  "`path'/`c(hostname)' - ids.csv" ,  clear rowr(2:)
			
			** make pid string as combined with start time.
			tostring pid, replace
			
			** if update, make newid empty
			if "`update'" == "update" {
				local newid = "-999"
			}
			if "`continue'" == "continue" {
				local newid = "-999"
				local start ""
			}
			putmata StataProcessID_tmp = (pid), replace
			
			if "`start'" == "start" {
				** make sure only one observation
				if _N > 1 {
					noi display "More than one instance of Stata running. multishell is not able to identify parent instance of Stata."
					noi display as smcl "See {help multishell##killprocess:Stopping multishell}."
					exit
				}
				putmata StataProcessID = (pid), replace
				mata StataProcessID = (StataProcessID_tmp , "0" , "`c(current_date)' - `c(current_time)'")
			
			}
			else {
				mata StataProcessID = multishell_mm_Combine(StataProcessID,StataProcessID_tmp,"`newid'","`c(current_date)' - `c(current_time)'")
			}	
			
			mata mata drop StataProcessID_tmp
		restore
		_return restore `returns'
		
	}
end


capture mata mata drop multishell_mm_KillStata()
mata:
	function multishell_mm_KillStata ( string scalar ToKillID, 
									   string matrix ProcessMatrix)
	
	{
		real scalar 	rows, i
		string vector 	PID
		string scalar 	ToKillCMD
		
		
		PID = ProcessMatrix[selectindex(ProcessMatrix[.,2]:==ToKillID),1]
		
		rows = rows(PID)
		
		for (i=1; i <=rows; i++ ) {
			ToKillCMD = sprintf("winexec taskkill /f /t /pid %s",PID[i])
			stata(ToKillCMD)
		}
	}

end


capture mata mata drop multishell_mm_Combine()
mata:
	function multishell_mm_Combine (string matrix process,
							string matrix pidNew,
							string scalar msID,
							string scalar TimeStamp )
	{
		string matrix 	output, tmp
		real scalar 	i, rowsproc
		
		rowsproc = rows(process)
		output = J(0,3,"")
		
		// build new matrix with common pids	
		for (i=1; i<=rowsproc; i++) {
			tmp = process[i,.]
			// check if id in tmp (currently running), then add to output matrix and remove from pid matrix
			if (sum(tmp[1]:==pidNew) == 1) {
				output = (output \ tmp)				
				pidNew = pidNew[selectindex(pidNew:!=tmp[1])]
			}
		}
		// check that pid has only 1 line (only one more Stata task possible), if more show error and assign an empty multishell pid.
		if (rows(pidNew) > 1 & cols(pidNew) == 1) {
			stata(`"noi display "More than 1 new instance of Stata started. multishell stop will not be able to stop those instances""')
			output = (output \(pidNew , J(rows(pidNew),1,"") , J(rows(pidNew),1,TimeStamp)))
		}
		else if (rows(pidNew) == 1 & cols(pidNew) == 1) {
			output = (output \ (pidNew[1] , msID , TimeStamp))
		}
		return(output)
	}	
end


************************************************************************************************
************************************************************************************************
*! version 2.0.1  04oct2010

/*
        setrngseed 

        Authors:  
                Antoine Terracol, Universit� Paris 1, 
                Centre d'�conomie de la Sorbonne

                William Gould, StataCorp

        -setrngseed- sets Stata's uniform pseudo-random-number generator's 
                seed to a value returned from http://www.random.org.
				
		Modified by Jan Ditzen, 11.09.2018

*/

program define multishell_setrngseed, rclass
        version 10

        syntax [, noSETseed Verify Query]

        /* ------------------------------------------------------------ */
                                        /* check syntax */
        if ("`query'"!="" & ("`setseed'"!="" | "`verify'"!="")) {
                di as error ///
"option query cannot be used concurrently with options nosetseed and verify" 
                exit 198
        }       



        /* ------------------------------------------------------------ */
                                        /* check quota  */
        if ("`query'"!="") {
                check_quota 
                local quota=r(quota)
                return scalar quota=`quota'             
                exit
        }       

        /* ------------------------------------------------------------ */
                                        /* obtain real random seed      */

        get_random_seed "`verify'"
        local value "`r(result)'"

        /* ------------------------------------------------------------ */
                                        /* set seed                     */

        if ("`setseed'"=="") {
                set seed `value'
                di as txt "(random-number seed set to `value')"
        }
        else {
                di as txt "random.org returns `value' (seed not set)"
        }

        /* ------------------------------------------------------------ */

        return scalar seed = `value'
end


program check_quota, rclass
        tempfile rndquota
        tempname myquota        

        local site "https://www.random.org"
        display as txt "(contacting `site', checking quota)"
        qui copy "`site'/quota/?format=plain" "`rndquota'"

        file open `myquota' using "`rndquota'", read text
        file read `myquota' quota
        file close `myquota'    

        local quotanum=floor(`quota'/31)        
        di as txt ///
        "current IP's 24-hour quota is `quota' bits, about `quotanum' random seeds" 
        return scalar quota=`quota'
end     

program get_random_seed, rclass
        args check 

        tempfile rndseed
        tempname myseed

        /* ------------------------------------------------------------ */
                                        /* obtain random number(s)      */

        local min  -1000000000
        local max   1000000000
        local toadd 1000000000
        
        local num = cond("`check'"=="", 1, 2)

        local site "https://www.random.org"
        local args "/integers/?num=`num'&min=`min'&max=`max'"
        local args "`args'&col=1&base=10&format=plain&rnd=new"

        display as txt "(contacting `site')"
        qui copy "`site'`args'" "`rndseed'"

        file open `myseed' using "`rndseed'", read text
        file read `myseed' value1
        if ("`check'" != "") {
                file read `myseed' value2
        }
        file close `myseed'

        /* ------------------------------------------------------------ */
                                        /* check results                */

        check_integer_result `"`value1'"'
        local value1 = `value1' + `toadd'

        if ("`check'" == "") {
                return local result `value1'
                exit
        }

        /* ------------------------------------------------------------ */
                /* check second value, and compare with the first       */

        check_integer_result `"`value2'"'
        local value2 = `value2' + `toadd'
        if (`value1' != `value2') {
                return local result `value1'
                exit
        }

        di as err "{p 0 4 2}"
        di as err "random.org behaved unexpectedly{break}"
        di as err "random.org returned the same"
        di as err "value twice, so the values are not"
        di as err "random or a very unlikely event occured."
        di as err "{p_end}"
        exit 674
end


program check_integer_result
        args value

        capture confirm integer number `value'
        if (_rc) {
                di as err "{p 0 4 2}"
                di as err "random.org behaved unexpectedly{break}"
                di as err `"value returned was "`value'", which"'
                di as err "was not an integer."
                di as err "{p_end}"
                exit 674
        }
end
