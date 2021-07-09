*! parallelise simulate2
*! Version 1.03 - 27.02.2020
*! by Jan Ditzen - www.jan.ditzen.net
/* changelog
To version 1.01
	- 21.10.2019: 	- bug fixes in program to get exe name
					- no batch file written anymore; support for MacOS
					- added options nocls and processors to set max processors for Stata MP
					- version 15 and simulate support
	- 17.01.2020	- added seedstream option
	- 21.01.2020	- fix if used in loops; added global to save seed ($psim2Seed)
To version 1.02
	- 30.01.2020	- added mata matrices copied over
To version 1.03
	- 27.02.2020	- improved behaviour for long lines in do files or programs
					- warning message if no seed set


*/
program psimulate2 , rclass
       version 15
	   
		_on_colon_parse `0'
		local after `"`s(after)'"'
        local 0 `"`s(before)'"'	
		
		** parse only part before : , rest doesnt matter
		syntax [anything(name=exp_list equalok)]   ///
						 [fw iw pw aw] [if] [in] [, ///
						Reps(integer -1)                ///
                        SAving(string)                  ///
                        DOUBle                          /// not documented
                        noLegend                        ///
                        Verbose                         ///
                        SEED(string)                    /// not documented
                        TRace                           /// "prefix" options                       
						/// simulate2 options
						SEEDSave(string)	///	
						Parallel(string)	/// parallel options
						NOCls				/// do not refresh windows
						simulate			/// use simulate rather than simulate2
						seedstream(integer 0) /// first seedstream
		]
		
		local 0 `parallel'
		
		syntax [anything(name = instance)] , [  ///
							exe(string)			 ///
							temppath(string)	///
							PROCessors(integer 1) ///
							]
		
		
		if "`instance'" == "" {
			local instance = 1
		}
		if `seedstream' > 0 {
			local seedstream = `seedstream' - 1
		}
		if "`temppath'" == "" {
			local temppath `"`c(tmpdir)'"'
		}
		
		if "`nocls'" == "" {
			local cls cls
		}
		if "`c(mode)'" == "batch" {
			** If run in batch mode, do not use cls
			local cls ""
		}
		*** which simulate is used
		if "`simulate'" == "" {
			** make sure even if simulate not used but version < 16, use simulate
			if `c(stata_version)' < 16 {
				local simulate simulate
				local whichsim "simulate"
			}
			else {
				local whichsim "simulate2"
				*** re-set to version 16
				version 16
			}
		}
		else {
			local whichsim "simulate"
		}
		
		*** remove p2sim files from folder
		local files: dir `"`temppath'"' files "psim2_*" 
		foreach file in `files' {
			erase "`temppath'/`file'" 
		}
		cap erase "`temppath'/lpsim2_matafunc.mlib"
		*** Get exe path
		if "`exe'" == "" {
			psim2_getExePath
			local exepath `"`r(exepath)'"'
		}
		
		*** Copy mata matrices
		local matamatsave = 0
		cap erase "`temppath'/psim2_matamat.mmat"
		
		*** Process seed options
		*** 1. neither frame nor dta used, then seed(seed rng seedstream)
		*** 2. frame used -> save as dta; if rng and stream empty, use mt64s and instance
		*** 3. dta used -> load as dta; if rng and stream empty, use mt64s and instance
		*** 4. no seed set; set seed to Stata default seed, rng to mt64s and stream instance
		local seednote = 0
		local resetseed = 0
		if "`whichsim'" == "simulate2" {
			local instseed = `inst' + `seedstream' 
			if "`seed'" == "" {
				*** case 4.
				local seednote = 1
				local seed `". mt64s \`instseed'"'
			}
			else {
				local 0 `seed'	
				syntax anything , [frame dta start(integer 1)]
				
				
				tokenize `anything'
				
				if "`1'" == "." | "`1'" == "_current" {
					if "`1'" == "_current" {
						local resetseed = 1
					}
					if "$psim2Seed" != "" {
						local 1 "$psim2Seed"					
					}
					else {
					
						local 1 `c(rngstate)'
						local 2 `c(rng_current)'
					}
					*local 3 `c(rngstream)'
				}
				
				if wordcount("`frame' `dta'") == 2 {
					di as err "options frame and dta cannot be combined"
					exit 184
				}
				local startseednum = `start'
				if "`frame'`dta'" == "" {
					
					if "`2'" == ""  {
						local 2 "mt64s"
					}
					if "`3'" == "" {
						local 3 `"\`instseed'"'
					}
					local seed `"`1' `2' \`3'"'
				}
				else {
					tokenize `anything'				
					if "`frame'" != "" {
						frame `1': save "`temppath'/psim2_seed", replace
						local seed `"`temppath'/psim2_seed `2' `3' `4' , dta"'
						local seedstartop `"start(\`=\`repscum'+\`startseednum'-1')"'
					}
					else if "`dta'" != "" {
						local seed `"`1' `2' `3' `4' , dta"'
						local seedstartop `"start(\`=\`repscum'+\`startseednum'-1')"'
					}
					
				}			
			}	
			
			if "`seedsave'" != "" {		
				local 0 `seedsave'
				syntax anything , [frame seednumber(integer 1) append]
				
				local sseeddest `"`anything'"'
				local sseedframe "`frame'"
				local sseedappend "`append'"
				
				local seedsave  `"`temppath'/psim2_seedsave_\`inst' , seednumber(\`repscum')"'
			}			
		}
		else {
			local seedsave ""
			local seed seed(`seed')
		}
		*** remove last saved seed from global
		if "$psim2Seed" != "" {
			macro drop psim2Seed		
		}
		
		*** save dta
		save "`temppath'/psim2_start", replace emptyok
		
		*** Number of replications for each
		local repsavg = floor(`reps'/`instance')
		local repscum = 1
		
		*** check if repsavg > 0
		if `repsavg' == 0 {
			while `repsavg' == 0 {
				local instance = `instance'-1
				local repsavg = floor(`reps'/`instance')
			}		
		}
		
		*** correct here commandline
		forvalues inst = 1(1)`instance' {
			local repsi = `repsavg' + (`inst'==1) * (`reps' - `repsavg'*`instance')			
			local instseed = `inst' + `seedstream' 
			if "`whichsim'" == "simulate2" {
				psim2_WriteDofile 	`exp_list' , ///
									/// sim2 options
									saving("`temppath'psim2_results_`inst'", replace) reps(`repsi')  ///
									perindicator(100, perindicpath(`"`temppath'"') performid(`inst')) ///
									seed("`seed'" "`seedstartop'") seedsave("`seedsave'") seedstream(`seedstream')	///
									/// writeBatch options
									id(`inst')  processors(`processors')  ///
									startdta(psim2_start)  temppath(`temppath') ///
									: `after'
			}
			else {
				psim2_WriteDofile 	`exp_list' , ///
									/// sim options
									saving("`temppath'psim2_results_`inst'", replace) reps(`repsi')  ///
									`seed' 	///
									/// writeBatch options
									id(`inst')  processors(`processors') simulate ///
									startdta(psim2_start)  temppath(`temppath') ///
									: `after'
			}
			local repscum = `repscum'+`repsi'
		
		}
		
		if "`c(os)'" == "Windows" {
			local winexec_e "/e"
		}
		else if "`c(os)'" == "MacOSX" {
			local winexec_e "-e"
		}
		else if "`c(os)'" == "Unix" {
			local winexec_e ""
		}
		
		local starttime = clock(c(current_time),"hms")
			
		if "`c(console)'" == "" {
			forvalues inst = 1(1)`instance' {
			*	noi disp `"command line to execute: winexec `exepath' `winexec_e' do  "`temppath'psim2_DoFile_`inst'.do" "'
			*	local lastcmd `"winexec `exepath' `winexec_e' do  "`temppath'psim2_DoFile_`inst'.do" "'
				winexec `exepath' `winexec_e' do  "`temppath'psim2_DoFile_`inst'.do"
			}
		}
		else {
			forvalues inst = 1(1)`instance' {
				local line "`line' (`exepath' do  "`temppath'/psim2_DoFile_`inst'.do" &)"
				if `inst' != `instance'  {
					local line "`line' ; "
				}
			}
			noi disp "Starting `instance' Instances. No output available, please wait."
			qui shell `line'
		}
		**** Output
		
		local sleeptime = 1000
		
		noi disp "Initalising...."
		local reps_done = 0
		
		while `reps' > `reps_done' {			
			** Reset reps done
			local reps_done = 0
			
			sleep `sleeptime'
			
			forvalues inst = 1(1)`instance' {
				if fileexists("`temppath'/psim2_performance_`inst'.mmat") == 1 {
					cap qui mata mata matuse "`temppath'/psim2_performance_`inst'", replace
					if _rc != 0 {
						** build in artifical sleep
						sleep 500
						cap qui mata mata matuse "`temppath'/psim2_performance_`inst'", replace
					}
					qui mata st_local("done_`inst'",strofreal(p2sim_performance[1,1]))
					qui mata st_local("reps_`inst'",strofreal(p2sim_performance[1,2]))
					
					** if simulate is used -999 is returned when done
					if `reps_`inst'' == -999 {
						local reps_`inst' = `reps' / `instance'
						local done_`inst' = `reps_`inst''
					}
					
				}
				else {
					local reps_`inst' = `reps'
					local done_`inst' = 0
				}
				local reps_done = `reps_done' + `done_`inst''
			}
			*** all times in ms sec.
			local nowtime = clock(c(current_time),"hms")
			local avg_run = (`nowtime' - `starttime') /`reps_done'
			if `avg_run' == . {
				local avg_run = 0
			}
			
			
			** time in minutes
			local time_elapsed = (`nowtime' - `starttime') 
			*local exp_time_left = (`reps'-`reps_done')*`avg_run'/`instance' 
			local exp_time_left = `time_elapsed'  / `reps_done' * `reps'
			
			*** in hour format
			local exp_finish_time = `nowtime'+`exp_time_left'
			
			`cls'
			noi disp as text ""
			noi disp "psimulate2 - parallelise `whichsim'"
			noi disp as text  ""
			noi disp as text `"command: `after' "'
			noi disp as text ""
			noi disp as text  "Timings (hour, minute, sec):"  _col(40) "Estimated:"
			noi disp as text  "  Average Run: " _col(24) %tcHH:MM:SS.sss `avg_run' _col(40) "  Time left (min):" _col(60) %tcHH:MM:SS `exp_time_left' 
			noi disp as text  "  Time Elapsed:" _col(24) %tcHH:MM:SS  `time_elapsed' _col(40) "  finishing time:" _col(60) %tcHH:MM:SS `exp_finish_time'
			noi disp ""	
			if "`whichsim'" == "simulate2" {
				forvalues inst = 1(1)`instance' {
					noi disp as text  "Instance `inst':"
					noi disp as text "  Done " %9.2f `=`done_`inst''/`reps_`inst''*100' "%" _col(20) "(`done_`inst''/`reps_`inst'')"
				}
				noi disp as text "Total"
				noi disp as text "  Done " %9.2f `=`reps_done'/`reps'*100' "%" _col(20) "(`reps_done'/`reps')"
			}
			else {
				noi disp as text "  simulate does not allow for process indication. Please wait."
			}
			local sleeptime = `avg_run' * `reps' / 100 
			
			*** wait at least 0.25 sec
			if `sleeptime' < 250 {
				local sleeptime = 250
			}
			else if `sleeptime' > 60000 {
				local sleeptime = 59999
			}
			noi disp ""
			noi disp as text "Current Time: `c(current_time)' - next refresh in " %tcSS.ss `sleeptime' " sec."
			if `seednote' == 1 {
				noi disp as text "No seed set. If psimulate is used in a loop, "
				noi disp as text "all iterations of the loop will have the Stata default seed."
			}
			sleep `sleeptime'
		}
		noi disp ""
		noi disp "Click on link to open log file: "
		di as text "Log files "
		forvalues inst = 1(1)`instance' {
			if fileexists("psim2_DoFile_`inst'.log") == 1 {
				disp as smcl _col(5) "Instance `inst':" _col(20) `"{view psim2_DoFile_`inst'.log: Log File}"'
			}	
		}
		
		*** Save seeds
		qui {
		
			if "`sseeddest'" != "" {
				clear
				use "`temppath'/psim2_seedsave_1"
				forvalues inst = 2(1)`instance' {
					append using "`temppath'/psim2_seedsave_`inst'", force
				}
				
				if "`sseedframe'" == "" {
					if "`sseedappend'" != "" {
						append using "`sseeddest'", force
					}
					save "`sseeddest'" , replace
				}
				else {
					if "`sseedappend'" != "" {
						frame `sseeddest': save "`temppath'/psim2_oldseed", replace	
						append using "`temppath'/psim2_oldseed"
					}
					cap frame drop `sseeddest'
					frame copy `c(frame)' `sseeddest'
					
				}
			}
			*** Collect data
			clear
			use "`temppath'psim2_results_1"
			forvalues inst = 2(1)`instance' {
				qui append using "`temppath'psim2_results_`inst'", force
			}
			
			if "`saving'" != "" { 
				local 0 `"`saving'"'
				syntax anything [, frame replace append]
				
				if "`frame'" != "" {
					if "`append'" != "" {
							frame `anything': save "`temppath'/psim2_oldframe", replace	
							append using "`temppath'/psim2_oldframe"
						}
					cap frame drop `anything'
					frame copy `c(frame)' `anything'
				}
				else {
					if "`append'" != "" {
						append using `"`anything'"'
					}
					save `"`anything'"', replace
				}
			}
			
			mata st_local("last_seed1",p2sim_lastseed[1])
			return local rngstate "`last_seed1'"
			mata st_local("last_seed",p2sim_lastseed[2])
			return local rngseed_mt64s "`last_seed'"
			mata st_local("p2sim_lastrng",p2sim_lastrng)
			return local rng_current "`p2sim_lastrng'"
			
			if `resetseed' == 1 {		
				global psim2Seed = "`last_seed1'"
			}
		}
		
end

cap program drop psim2_WriteDofile
program define psim2_WriteDofile
		
		_on_colon_parse `0'
		local after `"`s(after)'"'
        local 0 `"`s(before)'"'

		syntax [anything(name=explist equalok)], id(string) startdta(string) temppath(string) processors(integer) seedstream(integer)  [simulate] *  
		
		local sim2_options `options'
		
		local path `"`temppath'"'
        local doFileName "psim2_DoFile_`id'.do"
		
		tempname dofile
		
		
		**** Create do file with programs
		psim2_programlist , temppath("`temppath'")
		local pnames "`r(pnames)'"
				
		**** Write do file
		file open `dofile' using `"`path'/`doFileName'"' , w replace        
		
		if "`pnames'"  != "" {
			file write `dofile' `"include `"`temppath'/psim2_programs.do"'"' _n
		}
		
		**** If Stata MP, use only one core:
		if `c(MP)' == 1 {
			file write `dofile' `"set processors `processors'"' _n
		}
		
		**** Add ados and globals
		**** ado
		tokenize `"$S_ADO"' , p(";")
		while "`1'" != "" {
			if "`1'" != "BASE" & "`1'" != "SITE" &  "`1'" != "." &  "`1'" != "BASE" & "`1'" != "PERSONAL" & "`1'" != "PLUS" & "`1'" != "OLDPLACE"  & "`1'" != ";"  {
				file write `dofile' `"adopath + "`1'""' _n
			}
			macro shift
		}
		
		**** globals
		local allGlobals : all globals
		tokenize `"`allGlobals'"' 
		while "`1'" != "" {
			if "`1'" != "S_ADO" & "`1'" != "S_level" & "`1'" != "F1" & "`1'" != "F2" & "`1'" != "F7" & "`1'" != "F8" & "`1'" != "S_StataSE" & "`1'" != "S_FLAVOR" & "`1'" != "S_OS" & "`1'" != "S_OSDTL" & "`1'" != "S_MACH" {
				if strtoname("`1'") == "`1'" {
					file write `dofile' `"global `1' ="$`1'""' _n
				}
			}
			macro shift
		}
		
		**** Mata programs; easy way, check if mata programs exist, if so, add then to libary and 
		**** set new ado path to library in do file
		mata mata memory
		if `r(Nf_def)' > 0 {
			lmbuild lpsim2_matafunc , dir(`temppath') replace			
			file write `dofile' `"adopath + `temppath'"' _n
		}
		
		**** Mata programs
		mata mata memory
		if  `r(Nm)' > 0 {
			mata mata matsave "`temppath'/psim2_matamat.mmat" *, replace
			file write `dofile' `"mata mata matuse "`temppath'/psim2_matamat.mmat", replace"' _n
		} 
		
		/*
		**** do same for matrices
		local allMatrices: all matrices
		tokenize `"`allMatrices'"'
		while "`1'" != "" {
			file write `dofile' `"matrix `1' =``'1'"' _n
			macro shift
		}
		
		**** all scalars
		local allScalar: all scalars
		tokenize `"`allScalar'"'
		while "`1'" != "" {
			file write `dofile' `"scalar `1' ="`1'""' _n
			macro shift
		}
		*/
		**** Open Dataset
		file write `dofile'  `"use "`temppath'/`startdta'""' _n
		
		**** Do cmd
		if "`simulate'" == "" {
			file write `dofile' `"simulate2 `explist' , `options' : `after'"' _n
		}
		else {
			file write `dofile' `"set rng mt64s"' _n
			file write `dofile' `"set rngstream `=`id'+`seedstream''"' _n
			file write `dofile' `"simulate `explist' , `options' : `after'"' _n
			file write `dofile'	`"mata p2sim_performance = -999, -999 "' _n
			file write `dofile'	`"mata p2sim_lastrng = "\`c(rng_current)'""' _n
			file write `dofile' `"mata p2sim_lastseed = "\`c(rngstate)'" , "\`c(rngseed_mt64s)'""' _n
			file write `dofile' `"mata mata matsave "`temppath'/psim2_performance_`id'" p2sim_performance p2sim_lastseed p2sim_lastrng , replace "' _n
		}
		**** Close do file
		file close `dofile'	
end

cap program drop psim2_getExePath
program define psim2_getExePath, rclass 
	local datafiles: dir "`c(sysdir_stata)'" files "*.exe"                
	if wordcount(`"`datafiles'"') == 1 {

		local datafiles = subinstr(`"`datafiles'"',`"""',"",.)
		local exepath `c(sysdir_stata)'`datafiles'
		local exename `"`datafiles)'"'
	}
	else {
		if "`c(os)'" == "Windows" {							
			if `c(SE)' == 1 & `c(MP)' == 0 {
					local type SE
			}
			else if `c(MP)' == 1 {
					local type MP
			}
			else {
					local type IC
			}
			local exepath "`c(sysdir_stata)'Stata`type'-`c(bit)'.exe"
			local exename "Stata`type'-`c(bit)'.exe"
		}
		else if "`c(os)'" == "MacOSX" {
			if `c(SE)' == 1 & `c(MP)' == 0 {
				local type "SE"
				local exepath /usr/local/bin/stata-se
			}
			else if `c(MP)' == 1 {
				local type "MP"
				loc exepath /usr/local/bin/stata-mp
			}
			else {
				local type "IC"
				loc exepath /usr/local/bin/stata
			}
		}
		else if "`c(os)'" == "Unix" {
			local w = c(sysdir_stata)
			if `c(SE)' == 1 & `c(MP)' == 0 {
				local type "SE"
				loc exepath `w'stata-se
			}
			else if `c(MP)' == 1 {
				local type "MP"
				loc exepath `w'stata-mp
			}
		}
		if fileexists("`exepath'") == 0 {
			display as smcl "No Stata exe found. Please set a path using {help psimulate2##options:exepath()}."
			exit
		}
	}
	
	return local exepath `"`exepath'"'
	return local exename "`exename'"

end

program define psim2_programlist, rclass
	syntax [anything] , temppath(string)
		
	log
	local logname "`r(filename)'"
	cap log close
	local linesize `c(linesize)'
	set linesize 250
	log using "`temppath'/psim2_plog", replace text nomsg
	program dir
	log close
	set linesize `linesize'
	tempname file nextline
	file open `file' using `"`temppath'/psim2_plog.log"' , read
    file read `file' line
	while r(eof)==0 {
        local line `"  `macval(line)'"'
		local count = wordcount("`line'") 

		tokenize `line'
		capture confirm number `2'

		if `count' == 2 & _rc != 0 {
			local pnames "`pnames' `2'"
		}
		file read `file' line
	}
	file close `file'	
	
	**** write a new do file with contents of each program	
	
	if "`pnames'" != "" {
		*local appendreplace "replace"
		tempname dofilenew
		file open `dofilenew' using "`temppath'/psim2_programs.do" , write text replace
		
		
		foreach prog in `pnames' {
			local linesize `c(linesize)'
			set linesize 250
			log using "`temppath'/psim2_tmp_program.log" , text nomsg replace
			cap noi program list `prog'
			log close
			set linesize `linesize'
			if _rc == 0 {
				file open `file' using `"`temppath'/psim2_tmp_program.log"' , read
				file read `file' line
				
				/// Open it the second time and shift one line down to check if line was cut off
				file open `nextline' using `"`temppath'/psim2_tmp_program.log"' , read
				file read `nextline' next
				file read `nextline' next
				
				local inprog = -1
				while r(eof)==0 {
								
					gettoken 1 2 : line
					if "`1'" != "." & "`1'" != "" & "`1'" != "=" & "`1'" != "-" {
						local first = subinstr("`1'",".","",.)
						capture confirm number `first'
						
						*** line starts with a number, contains code					
						if _rc != 0 & `inprog' == -1 {
							local line = subinstr("`line'",":","",.)
							file write `dofilenew' `"program define `line'"' _n
							local inprog = 1
						}
						else if `inprog'  == 1 {
							local rest = subinstr(`"`macval(line)'"',"`1'","",.)
							//// check if next line start with ">", then this needs to be added to current line
							gettoken n1 n2: next
							if regexm(`"`n1'"',">") == 1 {
								local rest = strtrim(`"`rest'"')
								local n2 = strtrim(`"`n2'"')
								file write `dofilenew' `"`macval(rest)'`macval(n2)'"' _n
								
								/// now shift both files one line down
								file read `file' line
								file read `nextline' next
								
							} 
							else {
								file write `dofilenew' `"`macval(rest)'"' _n
							}						
						}
						else {
							local inprog = 0
						}
					}
					file read `nextline' next
					file read `file' line
				}
				file close `file'
				file close `nextline'
				** add end
				file write `dofilenew' `"end"' _n
				file write `dofilenew' `""' _n
			}
		}
		file close `dofilenew' 
	}
	
	if "`logname'" != "" {
		log using "`logname'", append
	}	
	return clear
	return local pnames "`pnames'"	
end