*! runparscale.ado 		v 1.2.2, 	Sept 26, 2012

/* 
Runparscale writes the code and data file needed to process test items in PARSCALE, runs PARSCALE, 
and merges the estimated thetas and their standard errors into the original data set.

Syntax:
.runparscale varlist, ID(str)
                 [RUnname(str) 
                  MINsize(integer 20)
                  DIsplay(str)
                  CLeanup
                  SCale(str)
				  NQpt(str)
				  CYcles(str)
				  ONEpl(integer 0)
                 ];


Special features:

		- Collapses categories on variables for which the number of 
			observations is below a specified threshold (default is the 20 
			or 5% of N for last item in varlist, whichever is smaller); 			
			can change with option minsize(newvalue)).
		- Drops any variable that does not have enough observations for at			
			least 2 categories, and displays a warning message.
		- Allows missing values.
		- Allows character or numeric ID's up to 9 digits.  A 10-digit ID is
			generated for use in Parscale.
		- Program is rclass, returning item parameters and standard errors.  			
			Results are also displayed in the log.
		- Display option (string with 0,1,2,and/or 3).  Displays the results 
			of the PARSCALE run phase 0, 1, 2, and/or 3 as indicated.
   	    - Cleanup option erases the PARSCALE files generated.  Cleanup is
		    automatically invoked if a runname is not specified.
		- Can specify the SCALE (default is 1.7).
		- Can specify the number of iterations in PARSCALE (default is 1000).
		
Usage notes:	
		- Items can have 2-10 categories.
			Note that PARSCALE can have up to 15 categories, but the item parameter 
			display here only allows for 9 cutpoints.  
			See prepar.ado for up to 15 categories or use the .PAR file to get 
			the	cutpoints.
		- Default Parscale instructions are: 
        >CALIB GRADED, LOGISTIC, SCALE=1.7, NQPT=11, CYCLES=1000, CRIT=.001 
        >SCORE EAP 
			If you want to change anything but the SCALE, NQPT, or CYCLES, you need to 
			make the changes by hand in the .PSL file.
		- Current maximum is 230 variables.
		- Writen for Stata 8.2.  Most sections require only Stata 7.0, but 
			writepardata needs to be altered to work in 7.0, and then the 
			spaces need to be edited out of the data input file (see that 
			section).
*/
 

***************************************************************************
* RUNPARSCALE was written by Laura Gibbons, PhD, Paul Crane, MD MPH, and Richard 
* Jones, ScD.
*
* It extends prepar 1.0, by Laura Gibbons and Paul Crane.
* See bottom of file for acknowledgements and license from UW
*
*--------------------------------------------------------------------------
* SUBROUTINE STRUCUTRE:
*
*     prepar (calls match.ado, something rich jones created)
*      + processitems
*      |  +  collapsecat
*      |  +  writecode
*      +  dumpcode
*      +  writepardata
*--------------------------------------------------------------------------
***************************************************************************

set more off

capture prog drop runparscale
program define runparscale , rclass
	version 8.0

#d ;
syntax varlist, ID(str)
                 [RUnname(str) 
                  MINsize(integer 20)
                  DIsplay(str)
                  CLeanup
                  SCale(str)
				  NQpt(str)
				  CYcles(str)
				  ONEpl(integer 0)
                 ];

#d cr

local numvars = wordcount("`varlist'")
/**************
* local macros containing variable names
local i=1
foreach var of varlist `varlist' {
   local item_name_`i' = "`var'"
   local i = `i'+1
}
*/
if "`scale'"=="" {
	global scale = 1.7
	}
else {
	global scale=`scale'
	}
if "`nqpt'"=="" {
	global nqpt = 11
	}
else {
	global nqpt=`nqpt'
	}
if "`cycles'"=="" {
	global cycles = 1000
	}
else {
	global cycles=`cycles'
	}
global origdata "$S_FN"

qui capture save "tempdata", replace			

		if "`runname'"=="" {
		   local runname = "__000000"
		   global DB_runname ="`runname'"
		   *force cleanup if runname not specified
		   local cleanup="cleanup"
		}
		else {
		   global DB_runname ="`runname'"
		}
		global DB_id ="`id'"
		global DB_items "`varlist'" /* was: "`namelist'" */

global nheaderlines = 8		/* No. of header lines in PARSCALE code file */
global ntrailerlines = 2 	/* And no. of trailer lines */
global varlist ""


if `minsize' == . {
    qui su `1'
    global minsize = min(20,int(.05*r(N)))	/* Minimum category frequency allowed */
	}
else global minsize = `minsize'
global ONEpl=`onepl'


use "tempdata"

preserve

capture drop parscaleid

local idtype: type $DB_id
if substr("`idtype'",1,3)=="str" {
	capture encode $DB_id, gen(__numid)
	if _rc==134 {
		noisily di in yellow "The sample size limit for an ID in string (character) format"
		noisily di in yellow "is 65,536 subjects.  Please create a numeric ID and use that."
		exit
		}
	capture assert __numid < 1000000000	
	if _rc==9 {
		noisily di "ID is more than 9 digits, need to modify runparscale code or your ID"
		exit	
		}
	gen long parscaleid = __numid +1000000000	
	drop __numid
	}

* If ID is more than 9 digits, 
* modify here, in dumpfile header lines (recalculate), and 
* in writepardata (add more spaces to NPKY line)

else	{
	capture assert $DB_id < 1000000000
	if _rc==9 {
		noisily di "ID is more than 9 digits, need to modify runparscale code or your ID"
		exit	
		}
	gen long parscaleid = $DB_id +1000000000
	}


* save a file with the original file id and the parscaleid
  capture outsheet `id' parscaleid using "_idfile.csv" , comma nonames replace
	
qui capture save "tempdata", replace			


processitems		
dumpcode			/* Write code_$DB_runname.psl */
writepardata		/* Write data_$DB_runname.txt*/

local i=1
foreach var of varlist $varlist {
   local item_name_`i' = "`var'"
   local i = `i'+1
}


local blocks=($ncodelines-$nheaderlines)/2
noisily di ""

if "$DB_runname"=="__000000" {
   noisily di in green "note: Parscale command files and data files not be saved. If you wanted them use the RUnname option"
   
}
else {
noisily di in green "Gibbons and Crane's prepar has created a"
noisily di in green "database and PARSCALE program with `blocks' items: $varlist "
noisily di in green "The PARSCALE input psl file is: code_$DB_runname.psl" 
noisily di in green "The data input file is: data_$DB_runname.txt" 
noisily di ""
}

capture erase "tempdata.dta"

set more on

capture confirm file C:\PROGRA~1\parscale\PSL0.EXE
if _rc~=0 {
  di in red "This program won't execute parscale because you do not have"
  di in red "parscale executables in the folder c:\program files\parscale"
  di in red "either move your parscale executables or fix the path in"
  di in red "this ado file."
}

foreach i of numlist 0/3 {
  !C:\PROGRA~1\parscale\PSL`i'.EXE code_$DB_runname
}

if "`display'"~="" {
   local display_length = length("`display'")
   foreach i of numlist 1(1)`display_length' {
      local part = substr("`display'",`i',1)
      if "`part'"=="0"|"`part'"=="1"|"`part'"=="2"|"`part'"=="3"{
        type code_$DB_runname.PH`part'
      }
   }
}


* display parameter estimates

clear
tempfile temp1 temp2 

qui {
	infix str p1 1-200 using $DB_runname.par
	gen x=_n if substr(p1,1,8)=="GROUP 01" 
	sort x
	global omit=x
	clear
	infix str p1 1-200 using $DB_runname.par

	drop if _n <=$omit
	save `temp2',replace
	keep if _n-3*floor(_n/3)==2
	split p1, gen(bc)
	destring bc*, replace

	forvalues p=3/9{
	capture confirm variable bc`p'
	if _rc==111 {
		gen bc`p'=.
		}
	}

	save `temp2',replace

    infix str line 1-85 using $DB_runname.par, clear
	drop if _n <=$omit
	keep if _n-3*floor(_n/3)==1
    split line, gen(par)
    rename par1 item
    rename par2 itemid
    rename par3 slope
    rename par4 se_slope
    rename par5 location
    rename par6 se_location
    rename par7 guessing
    rename par8 se_guessing

    foreach var of varlist itemid slope se_slope location se_location guessing se_guessing {
         destring `var', replace
         }
	local levels=floor(itemid/10000)
		if `levels' > 10 {
		di in red "warning, all cutpoints can not be displayed (at least one item has > 9 cutpoints)"
		di in red "you can find them all in the runname.par file if you use the runname option"
		}

	save `temp1'
	merge using `temp2'
	drop _merge 
*	forvalues i=1/`levels' {
	forvalues i=1/9 {
		replace bc`i'=. if bc`i'==0
		}	

	save `temp1',replace
      drop if slope==.
      su guessing
}      
  if r(mean)~=0 {
      list
      }
   else {
      di in green
      di ""
      di in green "PARSCALE ITEM PARAMETERS (some categories may have been combined to meet minsize requirements)"
      di in green "------------------------"
      di ""
      #d ;
      di in green _col(5)  "item"
                  _col(24) "slope (se)"
                  _col(40) "location (se)" 
			_col(57) "cutpoints";
      di in green _col(5)  "------------------------------------------------------------------------------------------------------------------" ;
      #d cr
      local N=_N
      return local items = `N'

      foreach i of numlist 1/`N' {
         if _n==`i' {
            local item`i'="item"
         }
         foreach par in slope location {
            qui su `par' if _n==`i'
            local `par'`i' = r(mean)
            return scalar `par'`i' = r(mean)
            qui su se_`par' if _n==`i'
            local se_`par'`i'=r(mean)
            return scalar se_`par'`i' = r(mean)
         }
set li 120
       #d ;
       di in green  _col(5) "`i'   `item_name_`i''"
          in yellow _col(23) %6.3f `slope`i'' 
                            _skip(1) "(" %5.3f `se_slope`i'' ")"
          in yellow _skip(3) %6.3f `location`i'' 
                            _skip(1) "(" %5.3f  `se_location`i'' ")" 
          in yellow _col(56)  %6.3f	bc1[`i'] _skip(1) 
                              %6.3f bc2[`i'] _skip(1) 
                              %6.3f bc3[`i'] _skip(1) 
                              %6.3f bc4[`i'] _skip(1) 
                              %6.3f bc5[`i'] _skip(1)
                              %6.3f bc6[`i'] _skip(1)
                              %6.3f bc7[`i'] _skip(1)
                              %6.3f bc8[`i'] _skip(1)
                              %6.3f bc9[`i'] _skip(1)
		;
       #d cr
       return local item_`i' = "`item_name_`i''"
       foreach j of numlist 1/9 {
          if bc`j'[`i']~=. {
             return scalar cut`i'`j' = bc`j'[`i']
          }
       }
       }
}
di in green _col(5)  "------------------------------------------------------------------------------------------------------------------" 
* end display parameter estimates


restore


capture confirm variable theta`runname' 
if _rc==111 {
   capture confirm variable sem`runname'
   if _rc==111 {
      qui tempfile idfile
      qui tempfile thetafile
      qui tempfile masterfile
      qui save `masterfile'
      * read in thetas
      qui insheet `id' parscaleid using _idfile.csv, comma clear
      qui save `idfile', replace
      qui capture erase _idfile.csv
      qui infix 2 lines 1: str parscaleid 1-15 ///
                        2: theta`runname' 56-66 sem`runname' 69-78 using "`runname'.sco", clear
      qui destring parscaleid, replace
      qui save `thetafile' , replace
      qui use `masterfile', clear
      qui match `id' , file1(*) file2(`idfile')
      qui drop _merge
      qui match parscaleid , file1(*) file2(`thetafile')
      qui move sem`runname' _merge
      qui move theta`runname' sem`runname'
      qui drop _merge
      qui drop parscaleid
   }
}
else {
  di ""
  di in red "CAUTION:" in green "   theta`runname'/sem`runname' not loaded, varnames already exist"
}


if "$DB_runname"=="__000000" {
   capture rename theta__000000 theta
   if _rc==110 {
      di in red "CAUTION:" in green "theta not loaded, varname exists"
      drop theta__000000
   }
   capture rename sem__000000 sem
   if _rc==110 {
      di in red "CAUTION:" in green "sem not loaded, varname exists"
      drop sem__000000
   }
}


if "$origdata"~="" {
    qui save  "$origdata", replace
 }



if "`cleanup'"~="" {
! del `runname'.*
! del code_`runname'.*
! del vars_`runname'.*
! del data_`runname'.*
! del _idfile.csv
 erase pscalscore_file
 erase pscaltotinfo_file
 erase pscalinfo_file
 erase pscalicc_file
}

end

*----------------------------------------------------------
* START COLLAPSE CAT PROGRAM
* Routine to collapse categories on a scale var to assure that
* all categories have at least a certain minimum frequency 

capture program drop collapsecat
program define collapsecat
	args var
	version 7.0
	tempvar count
	preserve
	sort `var'
	quietly by `var': gen long `count' = _N
	quietly by `var': keep if _n == 1
	global norigcat = _N
	local endloop = $norigcat
	forvalues i = 1/`endloop' {
	if `var'[`i'] >= . { 
		global norigcat = $norigcat - 1 }
		}
	local nnewcat = $norigcat
	forvalues i = 1/$norigcat {
		local ocode`i' = `var'[`i']		/* Original codes */
		if `ocode`i''==10 {			/* deal with values > 9 */
			local nocode`i' "A" 
			}
		else if `ocode`i''==11 {
			local nocode`i' "B" 
			}
		else if `ocode`i''==12 {
			local nocode`i' "C" 
			}
		else if `ocode`i''==13 {
			local nocode`i' "D" 
			}
		else if `ocode`i''==14 {
			local nocode`i' "E"
			}
		else if `ocode`i''==15 {
			local nocode`i' "F" 
			}
		else local nocode`i'= `ocode`i'' 
		local mapping`i' = `i'	/* Code to which each will be mapped */
		local newcat`i' = `count'[`i']	/* Vector of frequencies */
		}
	restore


		
	while (1) {			/* Keep looping till no more collapsing needed */
		
		/* Find current minimum count among new categories */
		local mincount = .
		local whichcat = .
		forvalues i = 1/`nnewcat' {
			if `newcat`i'' < `mincount' {
				local mincount = `newcat`i''
				local whichcat = `i'
				}
			}
			
		/* If all new categories have at least required minimum, all done  
(note: it will now reject variables with only one category )*/ 
		if `mincount' >= $minsize /*| `nnewcat' < 3*/ { continue, break }
		
		/* Find whether new category with current minimum count should be
			combined with the next-lower or the next-higher category */
		if `whichcat' == 1 { local bottomcat = 1 }

		else if `whichcat' == `nnewcat' { local bottomcat = `nnewcat'- 1 }
		else {

			local nextlower = `whichcat' - 1
			local nexthigher = `whichcat' + 1
			if `newcat`nextlower'' < `newcat`nexthigher'' {
				local bottomcat = `nextlower'
				}
			else { local bottomcat = `whichcat' }
			}
			
		/* Collapse two new categories into one */
		local toplimit = `nnewcat' - 1
		forvalues i = `bottomcat'/`toplimit' {
			local j = `i' + 1
			if `i' == `bottomcat' {
				local newcat`i' = `newcat`i'' + `newcat`j''
				}
			else {local newcat`i' = `newcat`j'' }
			}
		local nnewcat = `nnewcat' - 1
			
		/* Revise mappings to reflect smaller no. of new categories */
		forvalues i = 1/$norigcat {
			if `mapping`i'' > `bottomcat' {
				local mapping`i' = `mapping`i'' - 1
				}
			}
		if `nnewcat' < 2 { 
			gen ts`var'=1
	noisily di in white as result "Warning:  `var'   has too few subjects" 
		}

		}
		if `nnewcat' >= 2 { 
			gen ts`var'=0
		}

	if $norigcat > 15 { 
	noisily di in white as result "Warning:  `var'  has > 15 original categories, Parscale will reject." 
		}

	/* Create PARSCALE "ORI" and "MOD" specifications */
	global ori ""
	global mod ""
	forvalues i = 1/$norigcat {
		global ori "$ori`nocode`i''"
		global mod "$mod`mapping`i''"
		if `i' < $norigcat { 
			global ori "$ori,"
			global mod "$mod,"
			}
		}

	end

* END COLLAPSECAT PROGRAM
*----------------------------------------------------------


*----------------------------------------------------------
* START PROGRAM TO WRITE PARSCALE CODE
* Routine to write PARSCALE code for one "block", which is 
* one scale item variable

capture program drop writecode
program define writecode
	args var
	version 7.0
	
	global nblocks = $nblocks + 1

	global ncodelines = $ncodelines + 1
	global codeline$ncodelines = ">BLOCK$nblocks BNAme=('`var''), ORI=($ori),"
	global ncodelines = $ncodelines + 1
	global codeline$ncodelines = "  MOD=($mod), NITems=1, NCAT=$norigcat, CADjust=0.0, SKIP=($ONEpl,0,0,0);"
	global varlist "$varlist`var' "		
	end

* END OF WRITECODE PROGRAM
*----------------------------------------------------------


*----------------------------------------------------------
* START PROCESS ITEMS CODE
* Routine to go through each
* item and carry out collapsing of categories, 
* and writing of PARSCALE code 
	
capture program drop processitems

program define processitems
	version 7.0


	tempfile postdata

	/* Initializations */
	

		global ncodelines = $nheaderlines
		global nblocks = 0

	/* Main loop through types */
	
		foreach x of global DB_items {
		  	local var "`x'"		/* Set var = item variable name */
		  	qui tab `var'
			if r(r) > 1{
			  quietly save "`postdata'", replace
			  use "tempdata", replace
			  collapsecat `var'		/* Collapse categories on var */
			  if ts`var' ~=1 {
				writecode `var'		/* Write parscale code */
				}
			  quietly save "tempdata", replace
			  use "`postdata'", replace
			}
			else {
				di in red "`var' dropped, all one level"	
			}
		  }

end
	
* END PROCESS ITEMS PROGRAM
*----------------------------------------------------------		



*----------------------------------------------------------
* START DUMPCODE PROGRAM			
* Routine to dump PARSCALE code to a text file *
	
capture program drop dumpcode
program define dumpcode
	version 7.0
	
	drop _all
	local x = $ncodelines + $ntrailerlines		/* Allow for trailer */
	quietly set obs `x'
	quietly gen str80 code = ""

	
	/* Code for header is here */
	local blocks=($ncodelines-$nheaderlines)/2
	local lines=int((`blocks'+9)/80)+1
	if `lines' == 2 {
		local r1=`blocks'- 70
		}
	if `lines' == 3 {
		local r1=`blocks'- 150
		}
	quietly replace code = "This run has `lines' line(s) of data per subject." if _n == 1
	quietly replace code = "" if _n == 2
	quietly replace code = ">COMMENT" if _n == 3
	quietly replace code = ">FILES DFNAME='data_$DB_runname.txt', NFNAME='data_$DB_runname.txt', SAVE;" if _n == 4 	
	quietly replace code = ">SAVE PARM='$DB_runname.par', FIT='$DB_runname.fit', SCORE='$DB_runname.sco';" if _n == 5 	
	quietly replace code = ">INPUT NTEST=1, LENGTH=`blocks', NID=10, NTO=`blocks';" if _n == 6 	
	quietly replace code = "(10A1, `blocks'A1)" if _n == 7 & `lines'==1 
	quietly replace code = "(10A1, 70A1/`r1'A1)" if _n == 7 & `lines'==2
	quietly replace code = "(10A1, 70A1/80A1/`r1'A1)" if _n == 7 & `lines'==3
	quietly replace code = ">TEST1 TNAME='$DB_runname', items=(1(1)`blocks'), NBL=`blocks', SLOPE;" if _n == 8

	/* body code */
		local s = $nheaderlines+1
		forvalues i = `s'/$ncodelines {
		local x = "\$codeline`i'"
		quietly replace code = "`x'" if _n == `i'
		}

	/* Code for trailer is here */
	local end = $nheaderlines+2*`blocks'+2
	quietly replace code = ">CALIB GRADED, LOGISTIC, SCALE=$scale, NQPT=$nqpt, CYCLES=$cycles, CRIT=.001;" if _n == `end'-1
	quietly replace code = ">SCORE EAP;" if _n == `end'

	capture outsheet code using "code_$DB_runname.psl", noquote nolabel nonames replace
	end
* END DUMPCODE
*----------------------------------------------------------
*----------------------------------------------------------
* START WRITEPARDATA

capture program drop writepardata
program define writepardata
	version 8.0
***runtogether option only in version 8
***can run in version 7 with noquote instead of runtogether and then edit out the spaces

clear
tempfile temp1

use "tempdata"
*this first step is just to keep from converting and merging huge data sets
keep parscaleid $varlist

capture save "tempdata", replace

*makes the list all string variables so they'll allow conversion to X and A-F
quietly {
	tostring _all, replace force
	foreach var in    $varlist	 {
	replace `var'="X" if `var'=="."
	replace `var'="X" if `var'==".x"
	replace `var'="A" if `var'=="10"
	replace `var'="B" if `var'=="11"
	replace `var'="C" if `var'=="12"
	replace `var'="D" if `var'=="13"
	replace `var'="E" if `var'=="14"
	replace `var'="F" if `var'=="15"
	}
	}
capture save "`temp1'", replace

clear
tempfile temp2
quietly set obs 1
gen parscaleid="NPKY      "


foreach var in    $varlist	 {
        gen `var'="X"
	}
capture save "`temp2'", replace

append using "`temp1'" 
capture save "`temp1'", replace



*outputs the data in a nice, tidy rectangle
capture outfile parscaleid $varlist using "data_$DB_runname.txt", replace runtogether 
end


* END WRITEPARDATA
*----------------------------------------------------------

*----------------------------------------------------------
* BEGIN MATCH
capture program drop match
program define match
syntax varlist , file1(string) file2(string)

if "`file1'"~="*" {
   use "`file1'", clear
}
sort `varlist'
tempfile f1
capture drop _merge
save `f1'

use "`file2'"
sort `varlist'
merge `varlist' using `f1'

#d ;
label define merge
  1    "1-file2 only"
  2    "2-file1 only"
  3    "3-both files" ;
#d cr

label values _merge merge

tabulate _merge

end
* END MATCH PROGRAM
*----------------------------------------------------------

* Richard Jones was supported by NIH grant 5 P60 AG 008812-14.

**************************************************************************
* prepar 1.0, by Laura Gibbons, PhD, and Paul Crane, MD MPH
* 
* This program prepares a PARSCALE dataset and writes PARSCALE code
* from STATA.
*
* Copyright 2005, University of Washington.
* Written by Laura Gibbons, PhD, with assistance by Tom Koepsell, MD MPH, 
* under the direction of Paul Crane, MD MPH.  The time of Drs. Gibbons and Crane 
* was supported by NIH grant AG K08 22232, “Improving cognitive tests
* with modern psychometrics.”  Dr. Gibbons was also supported by 
* NIH grant 5 P50 AG05136-17.
* 
*   prepar Software License
*
* The University of Washington (UW) gives permission for you to use
* the prepar software package developed at UW, on the following
* conditions:
*
*     prepar is not published, distributed, or otherwise transferred or 
*     made available except through the UW DIFdetect web site.  
*
*     You agree to make improvements to prepar available to the UW 
*     prepar team for consideration and deployment in future releases
*     of prepar. In this way, future versions of prepar will be
*     tested, standardized and improved through one central academic
*     site.  All improvements must come with a statement and warranty 
*	that the work is original and that the person offering the
*	improvement has the right to grant permission to use the 
*	improvement.
*
*     You retain in prepar and any modifications to prepar the
*     copyright, trademark, or other notices pertaining to prepar as
*     provided by UW.
*
*     You provide the prepar team with feedback on the use of prepar
*     software in your research, and that the prepar team and UW are
*     permitted to use any information you provide in making changes to
*     prepar software.  All bug reports and technical questions shall
*     be sent to: gibbonsl@u.washington.edu
*
*     You acknowledge that UW and its licensees may develop
*     modifications to prepar that may be substantially similar to your
*     modifications of prepar, and that UW and its licensees shall not
*     be constrained in any way by you in UW's or its licensees' use or
*     management of such modifications. You acknowledge the right of
*     the UW to prepare and publish modifications to prepar that may
*     be substantially similar or functionally equivalent to your
*     modifications and improvements, and if you obtain patent
*     protection for any modification or improvement to prepar you
*     agree not to allege or enjoin infringement of your patent 
*     by UW or by any of UW's licensees obtaining modifications or
*     improvements to prepar from UW.
*
*     Please send bibliographic citations regarding the use of prepar
*     to Dr. Paul Crane at pcrane@u.washington.edu so that the
*     prepar team can keep an up-to-date list of projects published
*     using the program. 
*
*     Any risk associated with using the prepar software at your
*     institution is with you and your Institution/Company.  
*     prepar is experimental in nature and is made available as a
*     research courtesy "AS IS," without obligation by UW to provide
*     accompanying services or support.  UW AND THE AUTHORS EXPRESSLY
*     DISCLAIM ANY AND ALL WARRANTIES REGARDING THE SOFTWARE, WHETHER
*     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES
*     PERTAINING TO MERCHANTABILITY, NON_INFRINGEMENT, OR FITNESS FOR 
* 	  A PARTICULAR PURPOSE.
*
************************************************************************

