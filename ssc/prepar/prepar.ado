*! prepar.ado 		v 2.1, 	September 26, 2012

/* 

Syntax:
prepar varlist, ID(str) RUnname(str) 
        [MINsize(integer 20) SCALE(str) NQpt(str) CYcles(str) SCORE(str)
         PARameterfile(str) SKIP(varlist) ALL(integer 0) CLeanup(integer 0) ]

	Input:  items, id, runname.
	        Have the source dataset open.
	        Change the Stata working directory to where your data set is.

	Output:	code_runname.psl	(Parscale input code)
		data_runname.txt	(Data prepared for Parscale)
			
This program takes Stata data and writes the code and the data file needed to process the variables in PARSCALE.

Special features:
		- Collapses categories on variables for which the number of 
			observations is below a specified threshold (default is 20, 			
			can change with option minsize(newvalue)).
		- If you just want to estimate using an existing Parscale parameter file, 
                        use the PAR option.
                - Occasionally you will want to use the existing parameter file for only a 
                        subset of the items, in which case you want SKIP.
		- Drops any variable that does not have enough observations for at
			least 2 categories, and displays a warning message.
		- Warning message for variables with more than 15 modified levels 			
			(Parscale will reject).  Letter codes automatically made for
			2-digit values.
		- Allows missing values.
		- Allows character or numeric ID’s up to 9 digits.  A 10-digit ID is
		generated for use in Parscale.

Usage notes:
		- Run from the directory where the input data are.  
		- Data set name must not have spaces in it.
		- The maximum number of variables is 230.
		- Writen for Stata 8.0.
 
*/

**************************************************************************
* prepar 2.0, by Laura Gibbons, PhD, and Paul Crane, MD MPH
* 
* This program prepares a PARSCALE dataset and writes PARSCALE code
* from Stata.
*
* Copyright 2005-2010, University of Washington.
* Written by Laura Gibbons, PhD, with assistance by Tom Koepsell, MD MPH, and
* Rich Jones, ScD, under the direction of Paul Crane, MD MPH.  
* The time of Drs. Gibbons and Crane was supported by NIH grant AG K08 22232,
* “Improving cognitive tests with modern psychometrics.”  
* Dr. Gibbons was also supported by NIH grant 5 P50 AG05136-17.
* 
*   prepar Software License
*
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
* 	A PARTICULAR PURPOSE.
*
************************************************************************


set more off


/* Routine to collapse categories on a scale var to assure that
	all categories have at least a certain minimum frequency */

capture prog drop collapsecat
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
			gen __ts`var'=1
	noisily di in white as result "Warning:  `var'   has too few subjects"
		}

		}
		if `nnewcat' >= 2 { 
			gen __ts`var'=0
		}

	if $norigcat > 15 {
	noisily di in white as result "Warning:  `var'  has > 15 categories, Parscale will reject." 
		}
/*	for when we modify the original data if the modified data have <= 15 categories.
	if `nnewcat' > 15 {
	noisily di in white as result "Warning:  `var'  has > 15 modified categories, Parscale will reject."
		}
	if $norigcat > (some number) { 
	noisily di in white as result "Warning:  `var'  has > (some number) original categories, the output data set will not be correct." 
		}	*/

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


/* Routine to write PARSCALE code for one "block", which is one
	scale item variable */

capture program drop writecode
program define writecode
	args var
	version 7.0
        if "$skip"~="" {        // only take this time if a subset is skipped
        local fix=0
           foreach x in $skip {
                   if "`var'"=="`x'"   {
                      local fix=1
                   }
           }
        }
        else local fix=$fix
	global nblocks = $nblocks + 1
        global ncodelines = $ncodelines + 1
	global codeline$ncodelines = ">BLOCK$nblocks BNAme=('`var''), ORI=($ori),"
	global ncodelines = $ncodelines + 1
	global codeline$ncodelines = "  MOD=($mod), NITems=1, NCAT=$norigcat, CADjust=0.0, SKIP=(`fix',`fix',`fix',`fix');"
        global varlist "$varlist`var' "
	end
		

/* Routine to go through each
   item and carry out collapsing of categories, and writing of PARSCALE code */
	
capture program drop processitems
program define processitems
	version 7.0


	tempfile postdata

	/* Initializations */


		global ncodelines = $nheaderlines
		global nblocks = 0

	/* Main loop through types */
		foreach x of global items {

		  local var "`x'"		/* Set var = item variable name */
		  qui tab `var'
			if r(r) > 1{
			  quietly save "`postdata'", replace
			  use "tempdata", replace
			  collapsecat `var'		/* Collapse categories on var */
			  if __ts`var' ~=1 {
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

/* Routine to dump PARSCALE code to a text file */
	
capture program drop dumpcode
program define dumpcode
	version 7.0

	drop _all
	local x = $ncodelines + $ntrailerlines		/* Allow for trailer */
	quietly set obs `x'
	quietly gen str80 code = ""


	/* Code for header is here */
	local blocks=($ncodelines-$nheaderlines)/2
	quietly replace code = "" if _n == 1
	quietly replace code = "" if _n == 2
	quietly replace code = ">COMMENT" if _n == 3
	quietly replace code = ">FILES DFNAME='data_$runname.txt'," if _n == 4 
	quietly replace code = "NFNAME='data_$runname.txt', SAVE;" if _n == 5 & $fix==0
	quietly replace code = "NFNAME='data_$runname.txt', IFNAME='$par.par', SAVE;" if _n == 5 & $fix==1
	quietly replace code = ">SAVE PARM='$runname.par'," if _n == 6
	quietly replace code = "FIT='$runname.fit'," if _n == 7
	quietly replace code = "SCORE='$runname.sco';" if _n == 8
	quietly replace code = ">INPUT NTEST=1, LENGTH=`blocks', NID=10, NTO=`blocks';" if _n == 9
	quietly replace code = "(10A1, `blocks'A1)" if _n == 10

	/*  It appears that Parscale can indeed read at least 240 char lines.
	quietly replace code = "(10A1, `blocks'A1)" if _n == 10 & $lines==1
	quietly replace code = "(10A1, 70A1/`r1'A1)" if _n == 10 & $lines==2
	quietly replace code = "(10A1, 70A1/80A1/`r1'A1)" if _n == 10 & $lines==3 */
	quietly replace code = ">TEST1 TNAME='$runname', items=(1(1)`blocks'), NBL=`blocks', SLOPE;" if _n == 11

	/* body code */
		local s = $nheaderlines+1
		forvalues i = `s'/$ncodelines {
		local x = "\$codeline`i'"
		quietly replace code = "`x'" if _n == `i'
		}

	/* Code for trailer is here */
	local end = $nheaderlines+2*`blocks'+2
	quietly replace code = ">CALIB GRADED, LOGISTIC, SCALE=$scale, NQPT=$nqpt, CYCLES=$cycles, CRIT=.001;" if _n == `end'-1 & ($fix==0 | "$skip"~="")
	quietly replace code = ">CALIB GRADED, LOGISTIC, SCALE=$scale, NOCAL;" if _n == `end'-1 & $fix==1 & "$skip"==""
                                                          // keep calibration in if some items are estimated
        quietly replace code = ">SCORE $score;" if _n == `end'
	capture outsheet code using "code_$runname.psl", noquote nolabel nonames replace
	end



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
capture outfile parscaleid $varlist using "data_$runname.txt", replace runtogether 

end

*----------------------------------------------------------
* START THETAIN PROGRAM			
* merges Parscale theta scores back into the original Stata data set

version 7.0

capture program drop thetain
program define thetain

clear
tempfile temp
infix 2 lines  1: long parscaleid 2-11  2: theta$runname 58-65 setheta$runname 70-78 using "$runname.SCO"
sort parscaleid
capture save "`temp'", replace
clear

use "$origdata"
capture drop _merge
sort parscaleid

merge parscaleid using "`temp'", update replace

save "$origdata", replace
end

* END THETAIN PROGRAM
*----------------------------------------------------------		


capture prog drop prepar
program define prepar
	version 8.0

syntax varlist, ID(str) RUnname(str)       ///
        [MINsize(integer 20) SCALE(str) NQpt(str) CYcles(str) SCORE(str)   ///
        PARameterfile(str) SKIP(varlist) ALL(integer 0) CLeanup(integer 0) ]

global runname ="`runname'"
global id ="`id'"
global items "`varlist'"
global nheaderlines = 11	/* No. of header lines in PARSCALE code file */
global ntrailerlines = 2 	/* And no. of trailer lines */
global varlist ""

if `minsize' == . {
	global minsize = 20		/* Minimum category frequency allowed */
	}
else global minsize = `minsize'
global origdata "$S_FN"
capture drop parscaleid
local idtype: type $id
if substr("`idtype'",1,3)=="str" {
	capture encode $id, gen(__numid)
	if _rc==134 {
		noisily di in yellow "The sample size limit for an ID in string (character) format"
		noisily di in yellow "is 65,536 subjects.  Please create a numeric ID and use that."
		exit
		}
	capture assert __numid < 1000000000	
	if _rc==9 {
		noisily di "ID is more than 9 digits, need to modify code"
		exit
		}
	gen long parscaleid = __numid +1000000000	
	drop __numid
	}

/* If ID is more than 9 digits, modify here, in dumpfile header lines (recalculate), and in writepardata (add more spaces to NPKY line)*/
else	{
	capture assert $id < 1000000000
	if _rc==9 {
		noisily di "ID is more than 9 digits, need to modify code"
		exit
		}
	gen long parscaleid = $id +1000000000
	}
capture save "$origdata", replace

capture save "tempdata", replace

global runname ="`runname'"
global id ="`id'"
global items "`varlist'"
global skip "`skip'"
global nheaderlines = 11	/* No. of header lines in PARSCALE code file */
global ntrailerlines = 2 	/* And no. of trailer lines */
global varlist ""

if `minsize' == . {
	global minsize = 20		/* Minimum category frequency allowed */
	}
else global minsize = `minsize'

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
if "`score'"=="" {
	global score = "EAP"
	}
else {
	global score="`score'"
	}
global par "`parameterfile'"
if "`parameterfile'"=="" {
	global fix = 0
	}
else {
	global fix = 1
	}
global all = `all'                              // run parscale and merge in theta
global cleanup = `cleanup'			// Erase parscale files when done merging
processitems
dumpcode			/* Write code_$runname.psl */
writepardata		/* Write data_$runname.txt*/

local blocks=($ncodelines-$nheaderlines)/2
noisily di ""
noisily di in white as result "There are " `blocks' " items: $varlist "
noisily di ""
noisily di in white as result "The PARSCALE input psl file is: code_$runname.psl"
noisily di ""
noisily di in white as result "The data input file is: data_$runname.txt"

if $all==1 {
  capture confirm file C:\PROGRA~1\parscale\PSL0.EXE
  if _rc~=0 {
  	  di in red "This program won't execute parscale because you do not have"
  	  di in red "parscale executables in the folder c:\program files\parscale"
  	  di in red "either move your parscale executables or fix the path in"
  	  di in red "this ado file."
  	  }

  foreach i of numlist 0/3 {
  	  !C:\PROGRA~1\parscale\PSL`i'.EXE code_$runname
  	  }

  thetain				/* merges in theta and setheta*/
}
else use "$origdata", clear
capture drop parscaleid 
capture drop _merge
capture save "$origdata", replace
capture erase "tempdata.dta"

if $cleanup>=1 {
 	! del $runname.FIT
 	! del $runname.SCO
	! del code_$runname.*
	! del data_$runname.*
	erase pscalscore_file
	erase pscaltotinfo_file
	erase pscalinfo_file
	erase pscalicc_file
	}
if $cleanup==1 {
	! del $runname.PAR 
	}
	
noisily di ""
noisily di in yellow as text "Output was produced using prepar version 2.0"
noisily di in yellow as text "by Laura Gibbons and Paul Crane"
noisily di in yellow as text "University of Washington, Copyright 2005-2010"
noisily di ""
end

set more on
