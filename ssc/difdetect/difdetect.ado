*! difdetect.ado            v 2.0  	April 14, 2015

/* 
syntax: 
difdetect varlist, RUnname(str) ABility(str) GRoups(str) 
           [MULtinomial(str)  NUL(integer 1)  NUPValue(real 0.05) 
           UBeta(integer 0) UBCH(real 0.10) UL(integer 1) ULPValue(real 0.05) 
           minsize(integer 20) CYcles(str) NQpt(str)]

	Output:	Dif_runname.log
			DIFDetect_runname.dta
*/

*********************************************************************************
* difdetect, by Paul Crane, MD MPH, Laura Gibbons, PhD, Lance Jolly, MS, and Gerald van Belle, PhD.
* 
* Copyright 2005-2006, University of Washington.
* Written by Laura Gibbons, PhD, and Lance Jolly, MS, under the direction of Paul Crane, MD MPH, and Gerald van Belle, PhD.  
* The time of Drs. Gibbons and Crane was supported by NIH grant AG K08 22232, Improving cognitive tests with modern psychometrics. 
* Dr. Gibbons was also supported by NIH grant 5 P50 AG05136-17.
* 
* We appreciate the help of May M. Boggess, Tom Koepsell, and Rich Jones with sections of this program.
*
*   difdetect Software License:
*
* The University of Washington (UW) gives permission for you to use the difdetect software package developed at UW, on the following conditions:
*
*     difdetect is not published, distributed, or otherwise transferred or made available except through the UW DIFdetect web site.  
*
*     You agree to make improvements to difdetect available to the UW difdetect team for consideration and deployment in future releases
* 	  of difdetect. In this way, future versions of difdetect will be tested, standardized and improved through one central academic
* 	  site.  All improvements must come with a statement and warranty that the work is original and that the person offering the
* 	  improvement has the right to grant permission to use the improvement.
*
*     You retain in difdetect and any modifications to difdetect the copyright, trademark, or other notices pertaining to difdetect as provided by UW.
*
*     You provide the difdetect team with feedback on the use of difdetect software in your research, and that the difdetect team and UW are
*     permitted to use any information you provide in making changes to difdetect software.  All bug reports and technical questions shall
*     be sent to: gibbonsl@u.washington.edu
*
*     You acknowledge that UW and its licensees may develop modifications to difdetect that may be substantially similar to your
*     modifications of difdetect, and that UW and its licensees shall not be constrained in any way by you in UW's or its licensees' use or
*     management of such modifications. You acknowledge the right of the UW to prepare and publish modifications to difdetect that may
*     be substantially similar or functionally equivalent to your modifications and improvements, and if you obtain patent
*     protection for any modification or improvement to difdetect you agree not to allege or enjoin infringement of your patent 
*     by UW or by any of UW's licensees obtaining modifications or improvements to difdetect from UW.
*
*     Any risk associated with using the difdetect software at your institution is with you and your Institution/Company.  
*     difdetect is experimental in nature and is made available as a research courtesy "AS IS," without obligation by UW to provide
*     accompanying services or support.  UW AND THE AUTHORS EXPRESSLY DISCLAIM ANY AND ALL WARRANTIES REGARDING THE SOFTWARE, WHETHER
*     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES PERTAINING TO MERCHANTABILITY, NON_INFRINGEMENT, OR FITNESS FOR A PARTICULAR PURPOSE.
*
************************************************************************

/*--------------------------------------------------------------------------
* SUBROUTINE STRUCTURE:

	difdetect
		difdetect03
			q_ologit &/or q_logit
			processitems
				If dif: 
					makevirtualitems 
						collapsecat
				If no dif: 
					collapsecat
*------------------------------------------------------------------------*/


*----------------------------------------------------------
* START COLLAPSECAT PROGRAM
* Routine to collapse categories on a scale var to assure that
* all categories have at least a certain minimum frequency 
* and that there are no more than 15 categories 

capture prog drop collapsecat
program define collapsecat

	args var 
	version 13.0
	tempvar count

	preserve
	sort `var'

* not efficient but left over from Tom's code and parscale days	
	quietly by `var': gen long `count' = _N
	quietly by `var': keep if _n == 1
	
	global norigcat = _N
	local endloop = $norigcat
	forvalues i = 1/`endloop' {
		if `var'[`i'] >= . { 
			global norigcat = $norigcat - 1 
			}
		}
	local nnewcat = $norigcat

	forvalues i = 1/$norigcat {
		local ocode`i' = `var'[`i']		/* Original codes */
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
		/* If all new categories have at least required minimum, all done*/  
		if `mincount' >= $minsize | `nnewcat' ==1 { 
			continue, break 
			}
		/* Find whether new category with current minimum count should be
			combined with the next-lower or the next-higher category */
		if `whichcat' == 1 { 
			local bottomcat = 1 
			}
		else if `whichcat' == `nnewcat' { 
			local bottomcat = `nnewcat'- 1 
			}
		else {
			local nextlower = `whichcat' - 1

			local nexthigher = `whichcat' + 1
			if `newcat`nextlower'' < `newcat`nexthigher'' {
				local bottomcat = `nextlower'
				}
			else { 
			local bottomcat = `whichcat' 
				}
			}
			
		/* Collapse two new categories into one */
		local toplimit = `nnewcat' - 1
		forvalues i = `bottomcat'/`toplimit' {
			local j = `i' + 1
			if `i' == `bottomcat' {
				local newcat`i' = `newcat`i'' + `newcat`j''
				}
			else {
				local newcat`i' = `newcat`j'' 
				}
			}
		local nnewcat = `nnewcat' - 1
			
		/* Revise mappings to reflect smaller no. of new categories */
		forvalues i = 1/$norigcat {
			if `mapping`i'' > `bottomcat' {
				local mapping`i' = `mapping`i'' - 1
				}
			}
		}
		
	if `nnewcat' < 2 { 
		gen __ts`var' =1
		noisily di in white as result "Warning:  `var' has too few subjects" 
		}
	if `nnewcat' >= 2 { 
		gen __ts`var' =0
		}
	end

* END COLLAPSECAT PROGRAM
*----------------------------------------------------------


*----------------------------------------------------------
* START PROGRAM TO MAKE THE VIRTUAL ITEMS
* Routine to create 2+ "virtual" scale items from a single item on
*	which differential item performance has been found 

capture program drop makevirtualitems
program define makevirtualitems
	args var group
	version 13.0
	
	tempvar count
	preserve
	sort `group'
	quietly by `group': gen long `count' = _N
	quietly by `group': keep if _n == 1
	local ngroups = _N
	if `group'[`ngroups'] == . { 
		local ngroups = `ngroups' - 1 
		}
	forvalues i = 1/`ngroups' { 
		local g`i' = `group'[`i'] 
		}
	restore
	
	forvalues i = 1/`ngroups' {
		local vvarname "`var'_`group'`g`i''"
		capture drop `vvarname' 
		quietly gen `vvarname' = .
		quietly replace `vvarname' = `var' if `group' == `g`i''

		collapsecat `vvarname' 

		if __ts`vvarname' ~=1{
				global newlist "$newlist `vvarname'"	
			}
		}
		
	end

* END MAKEVIRTUALITEMS PROGRAM
*----------------------------------------------------------


*----------------------------------------------------------		
* START PROCESSITEMS CODE
* Routine to go through each
* item and carry out collapsing of categories, creation of virtual items 
* and writing of PARSCALE code 
		

capture program drop processitems
program define processitems
	version 13.0
	tempfile postdata
	
	/* Initializations */
		local ntypes = _N		/* No. of item/group/ability combinations */
		global newlist ""

	/* Main loop through types */
	local itype = 1
	while (`itype' <= `ntypes') {
			
		local ivar = item[`itype']
		tokenize "$DB_items"
		local var "``ivar''"	/* Set var = item variable name */
		if nonunif[`itype'] == 0 & unif[`itype'] == 0 {	
										/* If no DIF */
			quietly save "`postdata'", replace
			use "itemdata", replace
			collapsecat `var'		/* Collapse categories on var */
			if __ts`var' ~=1{
				global newlist "$newlist `var'"	
				}
			quietly save "itemdata", replace
			use "`postdata'", replace
			}
		else {			    		 /* If there IS DIF */
			
			local igroup = group[`itype']
			tokenize "$DB_groups"
			local gp "``igroup''"  /* Set gp = group variable name */
			quietly save "`postdata'", replace
			use "itemdata", replace
		  	qui tab `var'
		  	if r(r) > 1{
				makevirtualitems `var' `gp'
				quietly save "itemdata", replace
				use "`postdata'", replace
				}
			
			else {
				di in red "`var' dropped, all one level"	
				}
			}
		local itype = `itype' + 1		/* Go to next type */
	}
	
	end
			
* END PROCESS ITEMS PROGRAM
*----------------------------------------------------------		


*----------------------------------------------------------
* BEGIN Q_OLOGIT
* specialized ologit module to output the "completely determined"
* error message that would occur if data are too sparse and the models
* were not run quietly.

capture program drop q_ologit
program define q_ologit, rclass
        version 8.2
preserve

	syntax anything [if], *

	ologit `0'
	capture brant     
	if _rc==999 {
		local bnp=0      	
		return scalar bnp=`bnp'
        	}
	else if _rc~=999 {
		local pb = r(p)
		return scalar pb=`pb'
	      }
      local exp=""
	ologit `0'
	local levels=e(k_cat)
      forvalues k=1/`levels'{
      	predict double ppp`k', p outcome(#`k')
      	local exp   "`exp' & (ppp`k'<1e-6 | (1-ppp`k')<1e-6)"
        	}
      local exp : subinstr local exp "&" ""
      count if `exp'
      local cd=r(N)
	return scalar cd=`cd'
end

* END Q_OLOGIT
*----------------------------------------------------------

*----------------------------------------------------------
* BEGIN Q_LOGIT
* specialized logit module to output the "completely determined"
* error message that would occur if data are too sparse and the models
* were not run quietly.


capture program drop q_logit
program define q_logit, rclass
        version 8.2
preserve

	syntax anything [if], *
	logit `0'
	lfit, group(10)
	local phls = 1-chi2(r(df),r(chi2))
	predict double ppp,rules
	count if (ppp<1e-6 | (1-ppp)<1e-6)  
      local cd=r(N)
	return scalar cd=`cd'
	return scalar phls=`phls'
end

* END OLOGIT
*----------------------------------------------------------

*----------------------------------------------------------
* BEGIN DIFdetect03

* main program for DIF detection

capture program drop DIFdetect03
program define DIFdetect03
	version 13.0
preserve

global DB_noncat
global DB_non

global ncat : word count $DB_categorical

noisily di in yellow "There are " in white _N in yellow " observations."
if $DB_ival==1{
	noisily di in yellow "The $DB_ival item of interest:  $DB_items." 
	}
else {
	noisily di in yellow "The $DB_ival items of interest:  $DB_items." 
	}
if $DB_DIFtypesval==1{
	noisily di in yellow "The $DB_DIFtypesval group of interest:  $DB_groups."
	if $ncat==0 {
		noisily di in yellow "The group $DB_groups is either dichotomous or ordinally grouped."
		}
	else {
		noisily di in yellow "The group $DB_categorical is labeled categorical."
		}
	}
else {
	noisily di in yellow "The $DB_DIFtypesval groups of interest:  $DB_groups."
	if $ncat==0 {
		noisily di in yellow "None of the groups is categorical."
		}
	else {
		noisily di in yellow "Of these groups, the following are categorical:  $DB_categorical."
		}
	}
if $DB_abilval ==1 {
	noisily di in yellow "The $DB_abilval ability of interest:  $DB_abilities."
	}
else {
	noisily di in yellow "The $DB_abilval abilities of interest: $DB_abilities."
	}

noisily di ""
noisily di "_______________________________________________________________"
noisily di ""

foreach y of global DB_groups {
        tempname sumcat
        scalar `sumcat'=0
        *makes the suffixes for the categorical comparisons
   
     	  foreach z of global DB_categorical{
                if "`y'"=="`z'" {
                        tempvar c`z' max2`z'
                        egen `c`z''=group(`y')
                        egen `max2`z''=max(`c`z'')
                        local max`z' `max2`z''
                        scalar `sumcat'=`sumcat'+1
                }
        }

        if `sumcat'==0 {
        global DB_noncat $DB_non
        global DB_non "\$DB_noncat `y'"
        }
}
global DB_cat1

global DB_cat
foreach z of global DB_categorical{
local i=1
while `i'< `max`z''{
local j=`i'+1

        while `j'<=`max`z''{
                capture gen c`z'`i'`j'=1 if `c`z''==`i'
                if _rc==110 {                   
				noisily di in red "c`z'`i'`j' already exists, consider renaming variable."
                        tempvar c`z'`i'`j'
                        noisily di in red "the contrast variable is now called `c`z'`i'`j''."
                        gen `c`z'`i'`j''=1 if `c`z''==`i'
                        replace `c`z'`i'`j'' =0 if `c`z''==`j'
                        global DB_cat1 $DB_cat
                        global DB_cat "\$DB_cat1 `c`z'`i'`j''"
                        local j=`j'+1
                        continue
                        }
                replace c`z'`i'`j' =0 if `c`z''==`j'
                global DB_cat1 $DB_cat
                global DB_cat "\$DB_cat1 c`z'`i'`j'"
local j=`j'+1
}
local i=`i'+1
}
}
*sets up data;
global DB_groups "$DB_cat $DB_non"
local i = 1
local item = 1
local group =1
local ability =1

tempname out out1 out2 out3
tempfile results 

global gpbse ""
global intbse ""
global gplist ""
global intlist ""
global postg ""
global posti ""
global postni ""
global gnm ""

if "$DB_ordinal" ~= "" {
	forvalues i3 = 2/$olevels {
		global gpbse "$gpbse gp`i3' sebgp`i3' "		
		global intbse "$intbse bi`i3' sebintx`i3' "
		global gplist "$gplist gp_`i3' "
		global intlist "$intlist intx_`i3'"
		global postg "$postg (_b[gp_`i3']) (_se[gp_`i3']) "
		global posti "$posti (_b[intx_`i3']) (_se[intx_`i3']) "
		global postni "$postni (.) (.) "
		global gnm="gp_2"
		}
	}
else {
        global gpbse " bgp sebgp "
        global intbse " bi sebintx "
        global gplist " gp "
        global intlist " intx "
        global postg " (_b[gp]) (_se[gp]) "
        global posti " (_b[intx]) (_se[intx]) "
        global postni " (.) (.) "
	global gnm="gp"

	}

capture postfile `out' type item group ability ll bab sebab $gpbse $intbse pHL pBrant using "`results'" 

capture gen __conv=0
capture gen coll=0


foreach x of global DB_items {
	capture gen resp =`x'
	capture replace resp =`x'
	capture drop levels
	capture qui tab resp
	capture qui gen levels=r(r)


    foreach y of global DB_groups {
		if "$DB_ordinal" ~= "" {
			qui capture tab `y', gen(gp_)
              	*capture replace gp = `y' *ok?
			}
 	    else {
 			capture gen gp = `y'
			capture replace gp = `y'
			**not sure what the above line does
         	}	
	    foreach z of global DB_abilities {
      		capture gen ab = `z'
		    capture replace ab = `z'

*interactions;

	if "$DB_ordinal" ~= "" {
		forvalues i2 = 2/$olevels {
       		quietly capture gen intx_`i2'=gp_`i2'*ab
       		quietly capture replace intx_`i2'= gp_`i2'*ab
			}
		}
      else {
		quietly capture gen intx=gp*ab
		quietly capture replace intx=gp*ab
		}
*ologit, with interaction;

	capture gen pBrant=.
	capture gen pHL=.
	capture replace pBrant=.
	capture replace pHL=.

	if levels > 2 {   
	    capture quietly q_ologit resp $gplist ab $intlist if ($gnm ~=. & ab ~=.)

	
		if r(cd)>0 & r(cd) ~= . {
			di in red "Problem with `x' `y' `z', full model "
			di in red r(cd) " observations completely determined (or convergence not achieved)"
			di " "
		      capture replace __conv=0
      		capture replace coll=0
	        	local i = `i'+1
	        	local ability = `ability'+1		
			continue
  			}
		if r(bnp)==0 {
			di in red "Brant test not possible for:"
	        	di in red "  `x' `y' `z', interaction model" 
			capture replace pBrant=.
			}
		else if r(bnp)~=0 {
			capture replace pBrant=r(pb)
			}
		}

	else if levels == 2 {        
		quietly sum resp
		if r(min) ~=0 {
			quietly replace resp=resp-r(min)
			*recoded for logit so 0 is minimum value
			}	
	     	capture quietly q_logit resp $gplist ab $intlist if ($gnm~=. & ab ~=.)
		if r(cd)>0 {
			di in red "Problem with `x' `y' `z', interaction model"
			di in red r(cd) " observations completely determined (or convergence not achieved)"
			di " "
		      capture replace __conv=0
      		capture replace coll=0
        		local i = `i'+1
	        	local ability = `ability'+1	
			continue
  			}
		capture replace pHL=r(phls)
       }

	if _rc==430 & __conv==0{
      	  noisily di in white "Convergence not achieved with:"
	        noisily di in white "  `x' `y' `z', interaction model" 
      	  replace __conv=__conv+1
	        replace coll=0
      	  local i = `i'+1
	        local ability = `ability'+1
      	  continue
        	  }
	if _rc==430 & __conv~=0{
      	  noisily di "  `x' `y' `z', interaction model" 
	        local i = `i'+1
	        local ability = `ability'+1
	        continue
	        }
	if _rc==908{
       	noisily di in yellow "Too many categories for `x'."
        	noisily di in yellow "Recoded temporarily into 5 groups by autocode"
        	sort resp
        	replace resp=autocode(resp,5,resp[1],resp[_N])
	      la var resp `x'
      	noisily table resp

	     	capture quietly q_ologit resp $gplist ab $intlist if ($gnm~=. & ab ~=.)
		if r(cd)>0 & r(cd) ~= . {
			di in red "Problem with `x' `y' `z', interaction model "
			di in red r(cd) " observations completely determined (or convergence not achieved)"
			di " "
		      capture replace __conv=0
 	   	  	capture replace coll=0
 	       	local i = `i'+1
 	       	local ability = `ability'+1
			continue
  			}
		if r(bnp)==0 {
			di in red "Brant test not possible for:"
      	  	di in red "  `x' `y' `z', interaction model" 
			capture replace pBrant=.
			}
		else if r(bnp)~=0 {
			capture replace pBrant=r(pb)
			}

		if _rc~=0 {
        		noisily di in red "Unaccounted for error listed as " _rc
        		noisily di in red "Error applies to `x', `y', and `z' in the interaction model" 
        		continue
		      }
        }
	if _rc~=0{
      	noisily di in red "Unaccounted for error listed as " _rc
        	noisily di in red "Error applies to `x', `y', and `z' in the interaction model" 
	      continue
	      }

	if _rc==111 &coll==0{
		noisily di in yellow "Collinearity problems with:"
		noisily di in yellow "  `x', `y', `z', and `y'*`z'" 
	     	local i = `i'+1
	     	local ability = `ability'+1
		capture replace __conv=0
 	    	replace coll=coll+1
 	    	continue
 	    	}
	if _rc==111 &coll~=0{
		noisily di in yellow "  `x', `y', `z', and `y'*`z'" 
        	local i = `i'+1
        	local ability = `ability'+1
      	capture replace __conv=0
        	continue
        	}
	if _rc~=0 {

      	noisily di in red "Unaccounted for error listed as " _rc
        	noisily di in red "Error applies to `x', `y', and `z' in the interaction model" 
	      local i = `i'+1
        	local ability = `ability'+1
        	capture replace __conv=0
        	continue
        	}

*adds a new observation to out;
	post `out' (`i') (`item') (`group') (`ability') (e(ll)) (_b[ab]) (_se[ab]) $postg $posti (pHL) (pBrant)


*no interaction;
	if levels > 2 {   
	     	capture quietly q_ologit resp $gplist ab if ($gnm~=. & ab ~=.)
	
		if r(cd)>0 {
			di in red "Problem with `x' `y' `z', group+ability model "


			di in red r(cd) " observations completely determined (or convergence not achieved)"
			di " "
	      	capture replace __conv=0
      		capture replace coll=0
        		local i = `i'+1
        		local ability = `ability'+1
			continue
  			}
		if r(bnp)==0 {
			di in red "Brant test not possible for:"
        		di in red "  `x' `y' `z', group+ability model" 
			capture replace pBrant=.
			}
		else if r(bnp)~=0 {
			capture replace pBrant=r(pb)
			}
		}
	else if levels == 2 {        
      	capture quietly q_logit resp $gplist ab if ($gnm~=. & ab ~=.)
		if r(cd)>0 {
			di in red "Problem with `x' `y' `z', group+ability model "
			di in red r(cd) " observations completely determined (or convergence not achieved)"
			di " "
	    		capture replace __conv=0
      		capture replace coll=0
        		local i = `i'+1
        		local ability = `ability'+1
			continue
  			}
		capture replace pHL=r(phls)
       	}
	if _rc==430 & __conv==0{
      	noisily di "Convergence not achieved with:"
        	noisily di "  `x' `y' `z', main effect model" 

        	replace __conv=__conv+1
        	local i = `i'+1
        	local ability = `ability'+1
        	continue
        	}
	if _rc==430 & __conv~=0{
      	noisily di "  `x' `y' `z', main effect model" 
        	local i = `i'+1
        	local ability = `ability'+1
	      continue
	      }
	if _rc~=0{
	      noisily di in red "Unaccounted for error listed as " _rc
      	noisily di in red "Error applies to `x', `y', and `z' in the main effect model" 
        	continue
        	}

	post `out' (`i') (`item') (`group') (`ability') (e(ll)) (_b[ab]) (_se[ab]) $postg $postni (pHL) (pBrant)


*no group;
	if levels > 2 {   
	     capture quietly q_ologit resp ab if ($gnm~=. & ab ~=.)

		if r(cd)>0 {
			di in red "Problem with `x' `y' `z', ability only model "
			di in red r(cd) " observations completely determined (or convergence not achieved)"
			di " "
	      	capture replace __conv=0
      		capture replace coll=0
        		local i = `i'+1
        		local ability = `ability'+1
			continue
  			}
		if r(bnp)==0 {
			di in red "Brant test not possible for:"
        		di in red "  `x' `y' `z', ability only model" 
			capture replace pBrant=.
			}
		else if r(bnp)~=0 {
			capture replace pBrant=r(pb)
			}
	        }
	else if levels == 2 {        
     		capture quietly q_logit resp ab if ($gnm~=. & ab ~=.)

	
		if r(cd)>0 {
			di in red "Problem with `x' `y' `z', ability only model "
			di in red r(cd) " observations completely determined (or convergence not achieved)"
			di " "
		      capture replace __conv=0
   		   	capture replace coll=0
    		    	local i = `i'+1
     		   	local ability = `ability'+1
			continue
  			}
		capture replace pHL=r(phls)
      	}

	if _rc==430 & __conv==0{
      	noisily di "Convergence not achieved with:"
     		noisily di "`x' `y' `z', ability only model" 
    	      replace __conv=__conv+1
        	local i = `i'+1
       	local ability = `ability'+1
        	continue
        	}
	if _rc==430 & __conv~=0{
	      noisily di "`x' `y' `z', ability only model" 
      	local i = `i'+1
        	local ability = `ability'+1
        	continue
        	}
	if _rc~=0{
      	noisily di in red "Unaccounted for error listed as " _rc
        	noisily di in red "Error applies to `x', `y', and `z' in the ability only model" 
        	continue
        	}

	*adds that observation to data set;

	post `out' (`i') (`item') (`group') (`ability') (e(ll)) (_b[ab]) (_se[ab]) $postni $postni (pHL) (pBrant)
	
	*on to the next combination;

	local i = `i'+1
	local ability = `ability'+1
		}

	local group = `group'+1
	local ability =1
	}
local item = `item'+1
local group =1
local ability=1
}

postclose `out'

capture save "itemdata", replace  

quietly use "`results'", replace

local a=1

foreach x of global DB_items {
	label define itemlbl `a' `x', add
	local a=`a'+1
	}
label values item itemlbl
local a=1

foreach x of global DB_groups {
	label define gplbl `a' `x', add
	local a=`a'+1
	}

label values group gplbl
local a=1
foreach x of global DB_abilities {
	label define ablbl `a' `x', add
	local a=`a'+1
	}

label values ability ablbl
 
if "$DB_ordinal" == "" {
	sort type bi sebintx
	}
else {
	sort type 
	}
*computes output ;
quietly {
	by type: gen model=_n
	by type: gen dif=(bab[2]/bab[3]-1)
	by type: gen ll1=ll[1]
	by type: gen ll2=ll[2]
	by type: gen ll3=ll[3]
	if "$DB_ordinal" == "" {
		by type: gen pb3=2*(1-normal(abs(bi[1])/sebintx[1]))
		by type: gen pb2=2*(1-normal(abs(bgp[2])/sebgp[2]))
		by type: gen ldif=chiprob(1,2*(ll1-ll2))
		by type: gen ludif=chiprob(1,2*(ll2-ll3))
		}
	else {
		by type: gen ldif=chiprob(($olevels-1),2*(ll1-ll2))
		by type: gen ludif=chiprob(($olevels-1),2*(ll2-ll3))
		gen pb3=.
		gen pb2=.
		}
	format dif %8.6f
	format ldif %8.6f
	format ludif %8.6f
		format pb3 %8.6f
		format pb2 %8.6f
	if "$DB_ordinal" == "" {
		gen str5 dirU="+" if model==2 & sign(bgp)==1
		replace dirU="-" if model==2 & sign(bgp)==-1
		gen str5 dirNU="Mixed" if model==1 & sign(bgp)==1 & sign(bi)==-1
		replace dirNU="Mixed" if model==1 & sign(bgp)==-1 & sign(bi)==1
		replace dirNU="+" if model==1 & sign(bgp)==1 & sign(bi)==1
		replace dirNU="-" if model==1 & sign(bgp)==-1 & sign(bi)==-1
		}
	****deal with nonbinary group variables later********************************
	else {
		gen str5 dirU=""
		gen str5 dirNU=""
		}
	capture save DIFdetect_$DB_runname.dta, replace

	by type: keep if _n==1
	}	/*closes quietly*/

	
la var ldif "P(Dif.(LL))"
la var ludif "P(Dif.(LL))"
la var dif "Change in Est."

 *  change beta for U DIF
if $DB_unichk1==1 & $DB_unichk3==0{
		*identify dif;
		quietly gen nonunif=0 
		quietly replace nonunif=1 if ldif<=$DB_pval3 
		quietly gen unif=0 
		quietly replace unif=1 if abs(dif)>=$DB_pchange
 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif

		la de udif 0 "no" 1 "yes"  
		la val unif udif

		sort group type
		quietly drop if ldif==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ldif nonunif dirNU) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif unif dirU) by(ability) cen
		noisily di "Non-Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange"
		}	
* both change beta and LL for U DIF
else if $DB_unichk1==1 & $DB_unichk3==1 {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if ldif<=$DB_pval3 
		quietly gen unif=0 
		quietly replace unif=1 if (abs(dif)>=$DB_pchange | ludif <=$DB_pval7)
 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif

		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if ldif==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ldif nonunif dirNU) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif ludif unif dirU) by(ability) cen
		noisily di "Non-Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange or P(Dif.(LL)) {ul:<} $DB_pval7"
		}

 *  LL for U DIF
else if $DB_unichk1==0 & $DB_unichk3==1 {
	
		quietly gen nonunif=0 
		quietly replace nonunif=1 if ldif<=$DB_pval3 
		quietly gen unif=0 
		quietly replace unif=1 if ludif <=$DB_pval7
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type

		quietly drop if ldif==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ldif nonunif dirNU) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ludif unif dirU) by(ability) cen
		noisily di "Non-Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval7"
		}

processitems		/* Do new tasks */

clear
use "Difdetect_$DB_runname" 
gen str check="Check model:"
la define model 1 "Interaction" 2 "Ability + Group" 3 "Ability only"
la val model model
format se* %6.2f

if "$DB_ordinal" == "" {
	if (sebgp > 4 & sebgp ~= .) | (sebab > 4 & sebab ~= .) | (sebintx > 4 & sebintx ~= .){
		noisily di "" 
		noisily di in red "Warning, the following models need checking: " 
		list item group ability model sebab sebgp sebintx if (sebgp > 4 & sebgp ~= .) | (sebab > 4 & sebab ~= .) | (sebintx > 4 & sebintx ~= .),noobs label
		}
	}

clear
end
* END DIFdetect03
*----------------------------------------------------------


*----------------------------------------------------------
* START difdetect PROGRAM 

capture prog drop difdetect
program define difdetect
	version 13.0

syntax varlist, RUnname(str) ABility(str) GRoups(str) ///
       [MULtinomial(str) NUL(integer 1) NUPValue(real 0.05) ///
       UBeta(integer 0) UBCH(real 0.10) UL(integer 1) ULPValue(real 0.05) ///
       minsize(integer 20) NQpt(str) CYcles(str)] 

set more off
capture log close
capture log using "Dif_`runname'.log", replace

if "`nqpt'"=="" {
	global nqpt = 30
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
  qui de
  local d=r(N)

global DB_allitems "`varlist'"			/*items				*/
        *sort out items with just one level:
        global DB_items ""
        foreach x of global DB_allitems {
			capture qui tab `x' 
			if r(r)==1{
				di in red "`x' dropped, all one level"	
				continue
				}
			else global DB_items "$DB_items`x' "		
		}
global DB_ival: word count $DB_items		/*number of items			*/
global DB_runname "`runname'"				/*name for output files		*/
global DB_abilities "`ability'"				/*ability measure			*/
global DB_abilval: word count $DB_abilities	/*number of ability measures	*/
	if $DB_abilval ~= 1 {
		noisily di in red "Only one ability variable can be processed at a time."
		exit	
		}
global DB_groups "`groups'"					/*groups				*/
global gval: word count $DB_groups
	if $gval ~= 1 {
		noisily di in red "Only one grouping variable can be processed at a time."
		exit	
		}

global DB_ordinal "`multinomial'"		/*ordinal group with > 2 levels	*/
							/*will be treated as MULTINOMIAL    */

global oval: word count $DB_ordinal
	if $oval ~= 0 {
		local tempvar __tempvar2
        bysort $DB_ordinal: gen `tempvar'=_N if $DB_ordinal < .
        egen __tempvarx=min(`tempvar')
        if __tempvarx < 20 {
			di in red "Multinomial grouping variable must have at least 20 subjects/level"
			drop  __tempvar*
			exit
        	}
		drop __tempvar*
		}
	if $oval == 0 {
		capture drop __templevg
		capture qui tab $DB_groups 
		capture qui gen __templevg=r(r)
		if r(r) ~= 2 {
			noisily di in red "Grouping variable must be binary or designated as multinomial."
			drop __templevg
			exit	
			}
		drop __templevg
		}
capture qui tab $DB_ordinal 
global olevels=r(r)

global DB_categorical "`categorical'"	/*nominal groups with > 2 levels (not allowed here yet, will be empty)	*/
global DB_DIFtypesval: word count $DB_groups	/*number of groups; keep for compatibility with DIFd		*/

global DB_nonunichk1 = 1		/*-2LL criteria for non-uniform	*/
global DB_pval3 = `nupvalue'			/*alpha level for non-uniform		*/

global DB_unichk1 = `ubeta'			/*change in beta for uniform		*/
global DB_unichk3 = `ul'			/*-2LL for uniform			*/
global DB_pchange = `ubch'			/*percent change for beta in uniform*/

global DB_pval7 = `ulpvalue'		/*p-value for -2LL for uniform	*/
global minsize = `minsize'			/* Minimum category frequency	      */

capture assert $DB_nonunichk1==1	
	if _rc==9 {
		noisily di "NUL must be 1 (-2LL option for non-unif DIF) until we make an effect size measure "
		exit	
		}
capture assert $DB_unichk1==0 | $DB_unichk1==1
	if _rc==9 {
		noisily di "UBeta must be 0 or 1 (change in beta option for uniform DIF) "
		exit	
		}
capture assert $DB_unichk3==0 | $DB_unichk3==1	
	if _rc==9 {
		noisily di "UL must be 0 or 1 (-2LL option for uniform DIF) "
		exit	
		}
capture assert $DB_pval3 > 0 & $DB_pval3 < 1
	if _rc==9 {
		noisily di "NUPV must be between 0 and 1"
		exit	
		}
capture assert $DB_pchange > 0
	if _rc==9 {
		noisily di "UBP must be > 0"
		exit	
		}
capture assert $DB_pval6 > 0 & $DB_pval6 < 1
	if _rc==9 {
		noisily di "UPPV must be between 0 and 1"
		exit
		}
capture assert $DB_pval7 > 0 & $DB_pval7 < 1
	if _rc==9 {
		noisily di "ULPV must be between 0 and 1"
		exit
		}
qui drop if $DB_groups ==.
qui su $DB_groups
local m=`d'-r(N)
if `m'~=0 {
    noi di in red "Theta acounting for DIF due to $DB_groups will not be calculated for the `m' observation(s) missing $DB_groups."
    }

capture save "tempdata", replace

noisily DIFdetect03

* get new theta
use itemdata, clear
drop __conv-levels __*
noisily di ""
noisily di ""
noisily di in yellow "Estimating theta_$DB_runname and se_$DB_runname, this may take a while..."
noisily di ""
noisily di ""
*qui irt grm $newlist
qui gsem (T1 -> $newlist, ologit), var(T1@1) latent(T1)

if e(converged)==0 {
	noisily di in red "Convergence problems with $newlist"
	}
capture drop theta_$DB_runname
capture drop se_$DB_runname
qui predict theta_$DB_runname, latent se(se_$DB_runname) intp($nqpt) iter($cycles) // empirical Bayes means
save "$origdata", replace

* wrap up
noisily di ""
noisily di ""

local blocks: word count $newlist	
noisily di in white as result "There are now " `blocks' " items: $newlist " 
noisily di ""
noisily di ""
noisily di in yellow "Copyright 2014"
noisily di in white "Recommended citation:difdetect v. 2.0, Crane P, Gibbons LE, Jolley L, van Belle G. Seattle, WA:  University of Washington, 2014."
noisily di ""
noisily di ""

set more on
capture log close
erase "tempdata.dta"
erase "itemdata.dta"
end

* END difdetect PROGRAM
*----------------------------------------------------------



