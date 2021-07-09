*! Adrian Sayers 06/10/2015
* QSUB
version 13.1
cap prog drop qsub
	prog define qsub , rclass
 
  syntax   ,	 jobdir(string) 		/// Job Directory
    [ 						///
			MAXProc(integer 2) 			/// Define Maximum No of Processores
			QUEuesheet(string) 			/// Define the name of the queuesheet
			FLAGEnd(string) 			/// Give the flags a name, flags define when a process has finished.
			FLAGStart(string) 			/// Give the starting flag a  name
			wait(real 1) 				/// Define the length of wait before initiating the next process (second). long process should have large wait times
			WAITB4append(real 1) 		/// Define the length of wait before attempting to looking for running processes.
			statadir(string)   			/// Specify the location of stata i.e. give the full path and .exe
			outputdir(string)			/// Output Directory
			OUTPUTSAVEname(string) 		/// Compiled results save name
			append 						/// Instigate the append code
			deletelogs					/// Delete logs from working in batch mode
		] 	//

capture confirm existence "`jobdir'"
	if _rc !=0 di as error "Specify {opth jobdir(string)} compulsory option"

{ // Defaults local macros
	
if `"`queuesheet'"' == "" local queuesheet "queuesheet.dta"
if `"`jobstubb'"'   == "" local jobstubb   "job"
if `"`flagend'"'    == "" local flagend    "flagend"
if `"`flagstart'"'  == "" local flagstart  "flagstart"

* Build Stata Path
local executable : dir "`c(sysdir_stata)'" files "Stata*-*.exe" , respect
	foreach exe in  `executable' {
		if strpos("`exe'","old") ==0 {
			local currentstata_exe  `exe'
		} 
	}	
if `"`statadir'"'   == "" local statadir	`"`c(sysdir_stata)'`currentstata_exe'"'
	capture confirm file `"`c(sysdir_stata)'`currentstata_exe'"'
		if _rc !=0 	di as error "Specify Stata system directory and executable using {opth statadir(string)} option, automated method failed"
}

{ // Compiles a list of jobs 
noisily display _n "Building Job File"

quietly {
preserve
	local myjobs : dir "`jobdir'" files "*.do"
	clear
	gen filename =""
	local i = 1
	foreach job in `myjobs' {
    set obs `i'
    replace filename = "`job'" in `i'
    local i = `i'+1
   }
	gen jobno = _n
	gen action = 0
	save `"`jobdir'\\`queuesheet'"' , replace
restore
}
}
{ // Set initialisation parameters
local break = 0 // Break instruction
local job   = 1 // Start the Job Counter
}
{ // Initialise the jobs in each processor 
noisily display _n "Initialising Processors"

forvalues processor = 1/`maxproc' {
  cap erase "`jobdir'\\`flagend'`processor'.dta"		

  * Open the queue sheet and tick off the job 
  quietly {
    use `"`jobdir'\\`queuesheet'"' , clear
    sum jobno if action==0 , mean
    local nextjobno = `r(min)'
    local nextjobname= filename[`nextjobno']
    replace action =1 if jobno==`nextjobno'
    save `"`jobdir'\\`queuesheet'"' , replace
  }
  * Write code to create a flag to indicate when the command has started 
  _filei - `"save "`jobdir'\\`flagstart'`processor'.dta" , emptyok replace "' "`jobdir'\\`nextjobname'"

  * Write code to create a flag to indicate when the command has finished and then exit stata
  file open  mydofile using "`jobdir'\\`nextjobname'", write  append
  file write mydofile  _n "clear  all" 
  file write mydofile  _n `"save "`jobdir'\\`flagend'`processor'.dta" , emptyok replace "'
  file write mydofile  _n `"erase "`jobdir'\\`flagstart'`processor'.dta"	"'	
  file write mydofile  _n `"exit , clear STATA "'
  file close mydofile

  * Send the command
  winexec `statadir'  /e do "`jobdir'\\`nextjobname'"
  noisily di " `nextjobname' " _c
  local job = `job' + 1 // Add 1 to the Job Counter loop
}
}
{ // Look for a spare processor 
noisily display _n "Redistribution"
quietly {
while (1) {	

  forvalues processor = 1/`maxproc' {
    * Look for flags	
    cap confirm file "`jobdir'\\`flagend'`processor'.dta"
    local shell`processor' = _rc

    * Re issue the shell depending on the flag status of the process	
    if `shell`processor'' == 0 {

      * Open the queue sheet and tick off the job 
      use `"`jobdir'\\`queuesheet'"' , clear
      sum jobno if action==0 , mean
      * Create an Exit indicator if no more jobs to do, and break out the loop.
      if r(N) == 0 {
        local break =1
        continue , break
      }
      local nextjobno = `r(min)'
      local nextjobname= filename[`nextjobno']
      replace action =1 if jobno==`nextjobno'
      save `"`jobdir'\\`queuesheet'"' , replace
              
          
      * Remove the ready flag 
      erase "`jobdir'\\`flagend'`processor'.dta"		
      * Write code to create a flag to indicate when the command has started 
      _filei - `"save "`jobdir'\\`flagstart'`processor'.dta" , emptyok replace "' "`jobdir'\\`nextjobname'"

      * Write code to create a flag to indicate when the command has finished and then exit stata
      file open  mydofile using "`jobdir'\\`nextjobname'", write  append
      file write mydofile  _n "clear  all"
      file write mydofile  _n `"save "`jobdir'\\`flagend'`processor'.dta" , emptyok replace "'
      file write mydofile  _n `"erase "`jobdir'\\`flagstart'`processor'.dta"	"'
      file write mydofile  _n "exit , clear STATA "
      file close mydofile

      winexec `statadir' /e do "`jobdir'\\`nextjobname'"
              
      noisily di " `nextjobname' " _c
              
      * Move to the next job
      local job = `job' + 1 												

    } // end if 

  } // end looking over each processor

  * Break out the while if no more jobs.
  if `break'==1 {
    continue , break
  }

  * Increase the wait length for long jobs.
  local sleep =round(1000*`wait',1)
  sleep `sleep'

} // end while
} // end quietly 
}
{ // Just pause for a seconds to allow the jobs to be allocated before checking they are finished.
local sleepb4append =round(1000*`waitb4append',1)
sleep `sleepb4append'
}
{ // Wait for all jobs to finish before compiling the results.
noisily display _n "Waiting for full finish"		
* Wait for all jobs to finsih	
while (1) {	// loop over the processors until exit condition is reached
	local running = `maxproc'
  forvalues processor = 1/`maxproc' {
    cap confirm file "`jobdir'\\`flagstart'`processor'.dta"
		if _rc !=0 { // If the running file is not present subtract 1  from the total number of processors.
      local running = `running'-1
		}   // end running criteria
	}	// end loop of processors
	if `running'==0 {
    continue , break
	}
	* Increase the wait length for long jobs.
	local sleep =round(1000*`wait',1)
	sleep `sleep'	
} // end while loop
}
{ // Append outputs
quietly {
if "`append'"!="" {	
  noisily di _n "Appending output files" _n
  preserve		
	local myoutputs : dir "`outputdir'" files "*.dta"
	local i = 1
	foreach file in `myoutputs' {
		if `i'==1 {
      use "`outputdir'\\`file'" , clear
		}
		if `i'>1 {
      append using "`outputdir'\\`file'"
		}
    local i = `i'+1
	}			
	save "`outputsavename'" , replace	
  restore		
}
}
}
{ // Clear logs
quietly {	
if "`deletelogs'"!="" {
  noisily di _n "Deleting Log Files" _n
  local logs : dir `"`c(pwd)'"' files "*.log"
	foreach i in `logs' {
		erase `i'
	}			
}
}
}

end // End the Program

{ // filei command from Nick Cox
*! NJC 1.0.0 27 July 2007 
cap prog drop _filei
program _filei    
        version 8.2 

        // syntax can be 
        // + <text> <filename>   create or append 
        // - <text> <filename>   prepend 

        tokenize `"`0'"' 
        if `"`2'"' == "" | `"`4'"' != "" error 198 

        if `"`1'"' == "+" { 
                capture confirm file "`3'"
                local exists = _rc == 0 
                local file "`3'" 
        } 
        else if `"`1'"' == "-" { 
                confirm file "`3'"  
                local file "`3'" 
                local exists 1 
        } 
        else error 198  
                
        tempname ho hi 

        if !`exists' { 
                file open `ho' using "`file'", w 
                file write `ho' `"`2'"' _n
                file close `ho' 
                exit 0                   
        } 
        else {
                if "`1'" == "+" {  
                        file open `ho' using "`file'", w append 
                        file write `ho' `"`2'"' _n 
                        exit 0     
                }                    
                else { 
                        tempfile work 
                        file open `ho' using `work', w 
                        file write `ho' `"`2'"' _n 
                        file open `hi' using "`file'", r 
                        file read `hi' line 

                        while r(eof) == 0  { 
                                file write `ho' `"`macval(line)'"' _n 
                                file read `hi' line 
                        } 
                        
                        file close _all
                        copy `work' "`file'", replace 
                }
        }
end
}

*END
