*! difd.ado            v 1.0.2  	April 11, 2012

/*	
syntax varlist, ABility(str) GRoups(str)
[CATegorical(str) RUnname(str) NUL(integer 1) NUW(integer 0) NUPValue(real 0.05) 
UBeta(integer 1) UBCH(real 0.10) UL(integer 0) ULPValue(real 0.05) UW(integer 0) 
UWPValue(real 0.05) ITemsub(integer 0)]

	Output:	DIFdRUnname.log
			DIFd.dta (includes selected model-checking statistics)

*/
	
**************************************************************************
* DIFd 1.0, by Paul Crane, Laura Gibbons, Lance Jolley, and Gerald van Belle
* 
* This program evaluates test items for differential item functioning (DIF) 
* between groups, controlling for the ability/trait the test is measuring.  
*
* Copyright 2005, University of Washington.
*
* Written by Laura Gibbons, PhD, and Lance Jolley, MS, under the direction of 
* Paul Crane, MD MPH, and Gerald van Belle, PhD,.  The time of Drs. Gibbons and 
* Crane was supported by NIH grant AG K08 22232, “Improving cognitive tests
* with modern psychometrics.”  Dr. Gibbons was also supported by 
* NIH grant 5 P50 AG05136-17.
* 
* We appreciate the help of May M. Boggess and Tom Koepsell with sections of 
* this program.
*
*   DIFD Software License
*
*
* The University of Washington (UW) gives permission for you to use
* the DIFD software package developed at UW, on the following
* conditions:
*
*     DIFD is not published, distributed, or otherwise transferred or 
*     made available except through the UW DIFdetect web site.  
*
*     You agree to make improvements to DIFD available to the UW 
*     DIFD team for consideration and deployment in future releases
*     of DIFD. In this way, future versions of DIFD will be
*     tested, standardized and improved through one central academic
*     site.  All improvements must come with a statement and warranty 
*	  that the work is original and that the person offering the
*	  improvement has the right to grant permission to use the 
*	  improvement.
*
*     You retain in DIFD and any modifications to DIFD the
*     copyright, trademark, or other notices pertaining to DIFD as
*     provided by UW.
*
*     You provide the DIFD team with feedback on the use of DIFD
*     software in your research, and that the DIFD team and UW are
*     permitted to use any information you provide in making changes to
*     DIFD software.  All bug reports and technical questions shall
*     be sent to: gibbonsl@u.washington.edu
*
*     You acknowledge that UW and its licensees may develop
*     modifications to DIFD that may be substantially similar to your
*     modifications of DIFD, and that UW and its licensees shall not
*     be constrained in any way by you in UW's or its licensees' use or
*     management of such modifications. You acknowledge the right of
*     the UW to DIFde and publish modifications to DIFD that may
*     be substantially similar or functionally equivalent to your
*     modifications and improvements, and if you obtain patent
*     protection for any modification or improvement to DIFD you
*     agree not to allege or enjoin infringement of your patent 
*     by UW or by any of UW's licensees obtaining modifications or
*     improvements to DIFD from UW.
*
*     Please send bibliographic citations regarding the use of DIFD
*     to Dr. Paul Crane at pcrane@u.washington.edu so that the
*     DIFD team can keep an up-to-date list of projects published
*     using the program. 
*
*     Any risk associated with using the DIFD software at your
*     institution is with you and your Institution/Company.  
*     DIFD is experimental in nature and is made available as a
*     research courtesy "AS IS," without obligation by UW to provide
*     accompanying services or support.  UW AND THE AUTHORS EXPRESSLY
*     DISCLAIM ANY AND ALL WARRANTIES REGARDING THE SOFTWARE, WHETHER
*     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES
*     PERTAINING TO MERCHANTABILITY, NON_INFRINGEMENT, OR FITNESS FOR 
* 	  A PARTICULAR PURPOSE.
*
************************************************************************
		
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


capture program drop DIFd03
program define DIFd03
	version 7.0
preserve

global DB_noncat
global DB_non
global ncat : word count $DB_categorical

noisily di in green "There are " in white _N in green " observations."
if $DB_ival==1{
	noisily di in yellow "The $DB_ival item of interest:  $DB_items."
	}
else {
	noisily di in yellow "The $DB_ival items of interest:  $DB_items."
   }
if $DB_DIFtypesval==1{
   noisily di in yellow "The $DB_DIFtypesval group of interest:  $DB_groups."
   if $ncat==0 {
	    noisily di in yellow "The group $DB_groups is either dichotomous or continuous."
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
if $DB_itemsub==1{
     noisily di "Item value subtracted from ability."
     }
noisily di ""
noisily di "_______________________________________________________________"
noisily di ""


foreach y of global DB_groups {
        tempname sumcat
        scalar `sumcat'=0

*makes the suffixes for the categorical comparisons;
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

tempfile results results1 results2 results3

capture postfile `out' type item group ability ll bab sebab bgp sebgp bi sebintx pHL pBrant using "`results'" 

capture gen conv=0
capture gen coll=0

foreach x of global DB_items {
	capture gen resp =`x'
	capture replace resp =`x'
	capture drop levels
	capture qui tab resp
	capture qui gen levels=r(r)
    foreach y of global DB_groups {
		capture gen gp = `y'
		capture replace gp = `y'
        foreach z of global DB_abilities {
			capture gen ab = `z'
			capture replace ab = `z'
			if $DB_itemsub==1{
				quietly replace ab=ab-resp
				}

*interactions;

			quietly capture gen intx=gp*ab
			quietly capture replace intx=gp*ab

			*ologit, with interaction;

			capture gen pBrant=.
			capture gen pHL=.
			capture replace pBrant=.
			capture replace pHL=.

			if levels > 2 {   
			    capture quietly q_ologit resp gp ab intx if (gp~=. & ab ~=.)
				if r(cd)>0 & r(cd) ~= . {
					di in red "Problem with `x' `y' `z', full model "
					di in red r(cd) " observations completely determined "
					di " "
				    capture replace conv=0
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
		     	capture quietly q_logit resp gp ab intx if (gp~=. & ab ~=.)
				if r(cd)>0 {
					di in red "Problem with `x' `y' `z', interaction model"
					di in red r(cd) " observations completely determined "
					di " "
					capture replace conv=0
					capture replace coll=0
		        	local i = `i'+1
		        	local ability = `ability'+1
					continue
					}
				capture replace pHL=r(phls)
		       }


			if _rc==430 & conv==0{
		        noisily di in white "Convergence not achieved with:"
		        noisily di in white "  `x' `y' `z', interaction model" 
		        replace conv=conv+1
		        replace coll=0
		        local i = `i'+1
		        local ability = `ability'+1
		        continue
		        }
			if _rc==430 & conv~=0{
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
		        capture quietly q_ologit resp gp ab intx if (gp~=. & ab ~=.)
				if r(cd)>0 & r(cd) ~= . {
					di in red "Problem with `x' `y' `z', interaction model "
					di in red r(cd) " observations completely determined "
					di " "
				    capture replace conv=0

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
		        if _rc~=0 & r(cd)==. {
			        noisily di in red "Unaccounted for error listed as " _rc
			        noisily di in red "Error applies to `x', `y', and `z' in the interaction model" 
			        continue
			        }
		        }
		if _rc~=0 & r(cd)==. {
	        noisily di in red "Unaccounted for error listed as " _rc
	        noisily di in red "Error applies to `x', `y', and `z' in the interaction model" 
	        continue
	        }

		if _rc==111 &coll==0{
			noisily di in yellow "Collinearity problems with:"
			noisily di in yellow "  `x', `y', `z', and `y'*`z'"
			local i = `i'+1
			local ability = `ability'+1
			capture replace conv=0
			replace coll=coll+1
			continue
			}
		if _rc==111 &coll~=0{
			noisily di in yellow "  `x', `y', `z', and `y'*`z'" 
		    local i = `i'+1
		    local ability = `ability'+1
		    capture replace conv=0
		    continue
		    }
		if _rc~=0 & r(cd)==.{
	        noisily di in red "Unaccounted for error listed as " _rc
	        noisily di in red "Error applies to `x', `y', and `z' in the interaction model" 
	        local i = `i'+1
	        local ability = `ability'+1
	        capture replace conv=0
	        continue
	        }

		*adds a new observation to out;
		post `out' (`i') (`item') (`group') (`ability') (e(ll)) (_b[ab]) (_se[ab]) (_b[gp]) (_se[gp]) (_b[intx]) (_se[intx]) (pHL) (pBrant)

		*no interaction;
		if levels > 2 {   
			capture quietly q_ologit resp gp ab if (gp~=. & ab ~=.)
			if r(cd)>0 {
				di in red "Problem with `x' `y' `z', group+ability model "
				di in red r(cd) " observations completely determined "
				di " "
			    capture replace conv=0
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
			capture quietly q_logit resp gp ab if (gp~=. & ab ~=.)
			if r(cd)>0 {
				di in red "Problem with `x' `y' `z', group+ability model "
				di in red r(cd) " observations completely determined "
				di " "
			    capture replace conv=0
		      	capture replace coll=0
		        local i = `i'+1
		        local ability = `ability'+1
				continue
		  		}
			capture replace pHL=r(phls)
	        }

		if _rc==430 & conv==0{
	        noisily di "Convergence not achieved with:"
	        noisily di "  `x' `y' `z', main effect model" 
	        replace conv=conv+1
	        local i = `i'+1
	        local ability = `ability'+1
	        continue
	        }
		if _rc==430 & conv~=0{
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

		post `out' (`i') (`item') (`group') (`ability') (e(ll)) (_b[ab]) (_se[ab]) (_b[gp]) (_se[gp]) (.) (.) (pHL) (pBrant)


*no group;
		if levels > 2 {   
			capture quietly q_ologit resp ab if (gp~=. & ab ~=.)
			if r(cd)>0 {
				di in red "Problem with `x' `y' `z', ability only model "
				di in red r(cd) " observations completely determined "
				di " "
			    capture replace conv=0
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
			capture quietly q_logit resp ab if (gp~=. & ab ~=.)
			if r(cd)>0 {
				di in red "Problem with `x' `y' `z', ability only model "
				di in red r(cd) " observations completely determined "
				di " "
			    capture replace conv=0
		      	capture replace coll=0
		        local i = `i'+1
		        local ability = `ability'+1
				continue
		  		}
			capture replace pHL=r(phls)
	        }

		if _rc==430 & conv==0{
	        noisily di "Convergence not achieved with:"
	        noisily di "`x' `y' `z', ability only model" 
	        replace conv=conv+1
	        local i = `i'+1
	        local ability = `ability'+1
	        continue
	        }
		if _rc==430 & conv~=0{
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

		post `out' (`i') (`item') (`group') (`ability') (e(ll)) (_b[ab]) (_se[ab]) (.) (.) (.) (.) (pHL) (pBrant)


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

*capture save "itemdata", replace  /*for DIFforPar*/

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
 
sort type bi sebintx
*computes output parameters;
quietly {
	by type: gen model=_n
	by type: gen dif=(bab[2]/bab[3]-1)
	by type: gen ll1=ll[1]
	by type: gen ll2=ll[2]
	by type: gen ll3=ll[3]
	by type: gen ldif=chiprob(1,2*(ll1-ll2))
	by type: gen pb3 =2*(1-norm(abs(bi[1])/sebintx[1]))
	by type: gen ludif=chiprob(1,2*(ll2-ll3))
	by type: gen pb2=2*(1-norm(abs(bgp[2])/sebgp[2]))

	capture save DIFd.dta, replace

	by type: keep if _n==1
	}

la var ldif "P(Dif.(LL))"
la var ludif "P(Dif.(LL))"
la var dif "Change in Est."
la var pb3 "P(beta)"
la var pb2 "P(beta)"

if $DB_unichk1==1 & $DB_unichk2==0 & $DB_unichk3==0{
	if $DB_nonunichk2==0 & $DB_nonunichk1==1 {

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
		noisily by group: tabdisp item, cell(ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange"
		}
	else if $DB_nonunichk2==1 & $DB_nonunichk1==0 {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if pb3<=$DB_pval3
		quietly gen unif=0 
		quietly replace unif=1 if abs(dif)>=$DB_pchange
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if pb3==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange"
		}
	else {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if (pb3<=$DB_pval3 | ldif<=$DB_pval3) 
		quietly gen unif=0 
		quietly replace unif=1 if abs(dif)>=$DB_pchange
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if (pb3==.| ldif==.) 
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) or P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange"
		}
	}
else if $DB_unichk1==1 & $DB_unichk2==0 & $DB_unichk3==1 {
	if $DB_nonunichk2==0 & $DB_nonunichk1==1 {
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
		noisily by group: tabdisp item, cell(ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange or P(Dif.(LL)) {ul:<} $DB_pval7"
		}
	else if $DB_nonunichk2==1 & $DB_nonunichk1==0 {
		quietly gen nonunif=0
		quietly replace nonunif=1 if pb3<=$DB_pval3
		quietly gen unif=0 
		quietly replace unif=1 if (abs(dif)>=$DB_pchange | ludif <=$DB_pval7)
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if pb3==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange or P(Dif.(LL)) {ul:<} $DB_pval7"
		}
	else {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if (pb3<=$DB_pval3 | ldif<=$DB_pval3) 
		quietly gen unif=0
		quietly replace unif=1 if (abs(dif)>=$DB_pchange | ludif <=$DB_pval7)
		la var dif "Change in Est."
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"

		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type

		quietly drop if (pb3==. | ldif==.)
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) or P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange or P(Dif.(LL)) {ul:<} $DB_pval7"
		}
	}
else if $DB_unichk1==1 & $DB_unichk2==1 & $DB_unichk3==0 {
	if $DB_nonunichk2==0 & $DB_nonunichk1==1 {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if ldif<=$DB_pval3 
		quietly gen unif=0 
		quietly replace unif=1 if (abs(dif)>=$DB_pchange | pb2 <=$DB_pval6)
		la var dif "Change in Est."
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if ldif==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif pb2 unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange or P(beta) {ul:<} $DB_pval6"
		}
	else if $DB_nonunichk2==1 & $DB_nonunichk1==0 {
		quietly gen nonunif=0
		quietly replace nonunif=1 if pb3<=$DB_pval3
		quietly gen unif=0 
		quietly replace unif=1 if (abs(dif)>=$DB_pchange | pb2 <=$DB_pval6)
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if pb3==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif pb2 unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange or P(beta) {ul:<} $DB_pval6"
		}
	else {
		quietly gen nonunif=0 

		quietly replace nonunif=1 if (pb3<=$DB_pval3 | ldif<=$DB_pval3)
		quietly gen unif=0 
		quietly replace unif=1 if (abs(dif)>=$DB_pchange | pb2 <=$DB_pval6)
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if (pb3==. | ldif==.)
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif pb2 unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) or P(Dif.(LL)) {ul:<} $DB_pval3"

		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange or P(beta) {ul:<} $DB_pval6"
		}
	}
else if $DB_unichk1==1 & $DB_unichk2==1 & $DB_unichk3==1 {
	if $DB_nonunichk2==0 & $DB_nonunichk1==1 {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if ldif<=$DB_pval3 
		quietly gen unif=0 
		quietly replace unif=1 if (abs(dif)>=$DB_pchange | pb2 <=$DB_pval6 | ludif <=$DB_pval7)
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  

		la val unif udif
		sort group type
		quietly drop if ldif==.

		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"

		noisily by group: tabdisp item, cell(dif pb2 ludif unif) by(ability) cen

		noisily di "Non-Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange or P(beta) {ul:<} $DB_pval6"
		noisily di "or P(Dif.(LL)) {ul:<} $DB_pval7"
		}
	else if $DB_nonunichk2==1 & $DB_nonunichk1==0 {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if pb3<=$DB_pval3
		quietly gen unif=0 
		quietly replace unif=1 if (abs(dif)>=$DB_pchange | pb2 <=$DB_pval6 |ludif <=$DB_pval7)
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"

		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if pb3==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif pb2 ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange or P(beta) {ul:<} $DB_pval6"
		noisily di "or P(Dif.(LL) {ul:<} $DB_pval7"
		}
	else {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if (pb3<=$DB_pval3 | ldif<=$DB_pval3) 
		quietly gen unif=0 
		quietly replace unif=1 if (abs(dif)>=$DB_pchange | pb2 <=$DB_pval6 | ludif <=$DB_pval7)
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if (pb3==. | ldif==.)


		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(dif pb2 ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) or P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if Change in Est. {ul:>} $DB_pchange or P(beta) {ul:<} $DB_pval6"
		noisily di "or P(Dif.(LL) {ul:<} $DB_pval7"
		}
	}
else if $DB_unichk1==0 & $DB_unichk2==1 & $DB_unichk3==0 {
	if $DB_nonunichk2==0 & $DB_nonunichk1==1 {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if ldif<=$DB_pval3 
		quietly gen unif=0 
		quietly replace unif=1 if pb2 <=$DB_pval6 
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if ldif==.

		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb2 unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if P(beta) {ul:<} $DB_pval6"
		}
	else if $DB_nonunichk2==1 & $DB_nonunichk1==0 {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if pb3<=$DB_pval3
		quietly gen unif=0 
		quietly replace unif=1 if pb2 <=$DB_pval6 
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if pb3==.
		noisily di as result "Non-Uniform Differential Item Functioning"

		noisily by group: tabdisp item, cell(pb3 nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb2 unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if P(beta) {ul:<} $DB_pval6"
		}
	else {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if (pb3<=$DB_pval3 | ldif<=$DB_pval3) 
		quietly gen unif=0 
		quietly replace unif=1 if pb2 <=$DB_pval6 
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if (pb3==. | ldif==.)
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb2 unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) or P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if P(beta) {ul:<} $DB_pval6"
		}
	}
else if $DB_unichk1==0 & $DB_unichk2==0 & $DB_unichk3==1 {
	if $DB_nonunichk2==0 & $DB_nonunichk1==1 {
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
		noisily by group: tabdisp item, cell(ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval7"
		}
	else if $DB_nonunichk2==1 & $DB_nonunichk1==0 {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if pb3<=$DB_pval3
		quietly gen unif=0 
		quietly replace unif=1 if ludif <=$DB_pval7
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if pb3==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval7"
		}
	else {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if (pb3<=$DB_pval3 | ldif<=$DB_pval3) 
		quietly gen unif=0 
		quietly replace unif=1 if ludif <=$DB_pval7
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if (pb3==. | ldif==.)
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) or P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval7"
		}
	}
else  {
	if $DB_nonunichk2==0 & $DB_nonunichk1==1 {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if ldif<=$DB_pval3 
		quietly gen unif=0 
		quietly replace unif=1 if (pb2 <=$DB_pval6 | ludif <=$DB_pval7)
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if ldif==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb2 ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if P(beta) {ul:<} $DB_pval6 or P(Dif.(LL)) {ul:<} $DB_pval7"
		}
	else if $DB_nonunichk2==1 & $DB_nonunichk1==0 {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if pb3<=$DB_pval3
		quietly gen unif=0 
		quietly replace unif=1 if (pb2 <=$DB_pval6 |ludif <=$DB_pval7)
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if pb3==.
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb3 nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb2 ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if P(beta) {ul:<} $DB_pval6 or P(Dif.(LL)) {ul:<} $DB_pval7"
		}
	else {
		quietly gen nonunif=0 
		quietly replace nonunif=1 if (pb3<=$DB_pval3 | ldif<=$DB_pval3) 
		quietly gen unif=0 
		quietly replace unif=1 if (pb2 <=$DB_pval6 | ludif <=$DB_pval7)
		 
		la var nonunif "Non-Uniform DIF"
		la var unif "Uniform DIF"
		la de nudif 0 "no" 1 "yes"
		la val nonunif nudif
		la de udif 0 "no" 1 "yes"  
		la val unif udif
		sort group type
		quietly drop if (pb3==. | ldif==.)
		noisily di as result "Non-Uniform Differential Item Functioning"
		noisily di as result "Significant results determined when either indicator {ul:<} " $DB_pval3

		noisily by group: tabdisp item, cell(pb3 ldif nonunif) by(ability) cen
		noisily di as result "Uniform Differential Item Functioning"
		noisily by group: tabdisp item, cell(pb2 ludif unif) by(ability) cen
		noisily di "Non-Uniform DIF if P(beta) or P(Dif.(LL)) {ul:<} $DB_pval3"
		noisily di "Uniform DIF if P(beta) {ul:<} $DB_pval6 or P(Dif.(LL)) {ul:<} $DB_pval7"
		}
	}

clear
use "Difd" 
gen str check="Check model:"
la define model 1 "Interaction" 2 "Ability + Group" 3 "Ability only"
la val model model
format se* %6.2f

if (sebgp > 4 & sebgp ~= .) | (sebab > 4 & sebab ~= .) | (sebintx > 4 & sebintx ~= .){
	noisily di "" 
	noisily di in red "Warning, the following models need checking: " 
	list item group ability model sebab sebgp sebintx if (sebgp > 4 & sebgp ~= .) | (sebab > 4 & sebab ~= .) | (sebintx > 4 & sebintx ~= .),noobs label
	}

clear

noisily di ""
noisily di ""
noisily di in yellow as text "This output was produced using DIFd version 1.0"

noisily di in yellow as text "by Paul Crane, Laura Gibbons, Lance Jolley, and Gerald van Belle"
noisily di in yellow as text "University of Washington"
noisily di in yellow as text "Copyright 2005"
noisily di ""
noisily di in white "Recommended citation:"
noisily di in white "DIFd v. 1.0, Crane P, Gibbons LE, Jolley L, van Belle G."
noisily di in white "   Seattle, WA:  University of Washington, 2005."
end

capture prog drop difd
program define difd
	version 8.0

syntax varlist, ABility(str) GRoups(str) [CATegorical(str) RUnname(str) NUL(integer 1) NUW(integer 0) NUPValue(real 0.05) UBeta(integer 1) UBCH(real 0.10) UL(integer 0) ULPValue(real 0.05) UW(integer 0) UWPValue(real 0.05) ITemsub(integer 0)] 


set more off
capture log close
log using "DIFd`runname'.log", replace
preserve
capture save "tempdata", replace
global DB_items "`varlist'"						/*items				*/
global DB_ival: word count $DB_items			/*number of items			*/
global DB_abilities "`ability'"					/*ability measures		*/
global DB_abilval: word count $DB_abilities		/*number of ability measures	*/
global DB_groups "`groups'"						/*groups				*/
global DB_categorical "`categorical'"			/*groups with > 2 levels	*/
global DB_DIFtypesval: word count $DB_groups	/*number of groups		*/
global DB_nonunichk1 = `nul'				/*-2LL criteria for non-uniform	*/
global DB_pval3 = `nupvalue'				/*alpha level for non-uniform		*/
global DB_nonunichk2 = `nuw'				/*p-value criteria for non-uniform	*/
global DB_unichk1 = `ubeta'					/*change in beta for uniform		*/
global DB_unichk2 = `uw'					/*p-value confounder for uniform	*/

global DB_unichk3 = `ul'					/*-2LL for uniform			*/
global DB_itemsub = `itemsub'				/*subtract item value from ability	*/
global DB_pchange = `ubch'					/*percent change for beta in uniform*/
global DB_pval6 = `uwpvalue'				/*p-value for confounder for uniform*/
global DB_pval7 = `ulpvalue'				/*p-value for -2LL for uniform	*/

capture assert $DB_nonunichk1==0 | $DB_nonunichk1==1	
	if _rc==9 {
		noisily di "NUL must be 0 or 1 (-2LL option for non-uniform DIF) "
		exit	
		}
capture assert $DB_nonunichk2==0 | $DB_nonunichk2==1	
	if _rc==9 {
	noisily di "NUP must be 0 or 1 (P-value option for non-uniform DIF) "
		exit	
		}
capture assert $DB_unichk1==0 | $DB_unichk1==1	
	if _rc==9 {
	noisily di "UBeta must be 0 or 1 (change in beta option for uniform DIF) "
		exit	
		}
capture assert $DB_unichk2==0 | $DB_unichk2==1	
	if _rc==9 {
	noisily di "UP must be 0 or 1 (P-value option for uniform DIF) "
		exit	
		}
capture assert $DB_unichk3==0 | $DB_unichk3==1	
	if _rc==9 {
	noisily di "UL must be 0 or 1 (-2LL option for uniform DIF) "
		exit	
		}
capture assert $DB_itemsub==0 | $DB_itemsub==1	
	if _rc==9 {
		noisily di "ITEMSUB must be 0 or 1"
		exit	
		}
capture assert $DB_pval3 > 0 & $DB_pval3 < 1
	if _rc==9 {
		noisily di "NUPV must be between 0 and 1"
		exit	
		}
capture assert $DB_pchange > 0
	if _rc==9 {
		noisily di "UBP must be < 0"
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
drop if $DB_groups ==.
noisily DIFd03

capture erase "tempdata.dta"
end
set more on
capture log close

