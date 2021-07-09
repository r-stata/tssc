* Release notes:
*
*	version 1.1 2019-12-18
*	Add a version option to syntax.  If option is present
*	    the program will report its version.
*
*	version 1.2 2020-01-15
*	Fixed bug that caused program to crash when the program tries to 
*	    continue when no more variants remain to be eliminated.  getmata
*           and putmata appropriately fail when their inputs are undefined.
*	Change way version information is rendered in log.
*	Make listing of variants considered by the sentinel program optional.
*	Make show progress optional.
*
*      version 1.3 2020-03-20
*      Delete SNPs whose number of variant alleles do not vary among the
*          case patients.  Such SNPs caues missing correlation coefficients
*          with other SNPs which Stata treats as having a correlation coefficient
*          that is greater than any R^2 value.
*
*      version 1.3.1 2020-03-27
*	Moved code that set global values sentinel_version and sentinel_version_date into the
*	function sentinel.  Because sentinel performs "capture program drop sentinel" at the
*	beginning, the version information output in subsequent runs in a single session was wrong.
*
*     version 1.3.2 2020-04-03
*	All intermediary files saved in previous versions have been replaced by temporary files
* 	created with tempfile macros. The user's data is preserved at the beginning of the 
*	program and restored at the end.
*
* This program was coded by William D. Dupont and W. Dale Plummer.
* Its algorithm was created by 
* William D. Dupont, W. Dale Plummer & Jeffrey R. Smith

version 15.0 // This program was written under Stata version 15.
*=======================================================================
* subroutine sentinel
*=======================================================================
capture program drop sentinel
program define sentinel, rclass 
*
* Create a global to contain version information.
*
global sentinel_version "1.3.2"
global sentinel_version_date "April 3, 2020"

*
* Inputs
*
*    varlist - a list of variables from the dataset in memory when 
*              sentinel is called. The first of these variables, 
*   	       which are called 
*    depvar -  is the dependent variable and equals 1 for cases and
* 	       0 for controls.  The remaining variables are SNPs that
* 	       are called
*    indepvars 
*
*    delta - a stepsize used to decrement the value of r2
*        that defines bin sizes.  Default is 0.025.
*
*    r2values - number of r2values.  Default is 1/delta.	
*
*    pvalue - the threshold for including a snp in the model. Default is 0.01.
*	After snps have been deleted from consideration from bins with a
*	given R^2 value, a multivariate model is run on the remaining snps. 
*	Snps from this model that are significant with p <= $sentinel_pvalue 
*	are marked for consideration in subsequent models with bins having 
*	smaller R^2 values.  At the end of the algorithm the only snps 
*	included in the final model must have p <= pvalue.
*
*    version - If present a version message is shown.
*
*    listvariants - If present the variants considered by the sentinel 
*	            program will be listed.
*
*    showprogress - If present this option gives the SNPs deleted or marked 
*                   at each value of R^2 and the SNPs to be consider by the
*                   next value of R^2
*
* We are using a value of r2values=9999 to mean that the user did not specify
* the r2values() option.  In that case, we will set r2values = 1/delta.
*
* Output
*    $sentinel_bestlist - a list of snps that are significant in a
*        multivariate model and which include important
*        snps that might have otherwise have been deleted
*        due to high linkage disequilibrium.
*
preserve // Preserve the user's original data

* Create tempfile macros needed by this program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tempfile temp_proinpdata
tempfile dictionary
tempfile preserve

*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

syntax varlist(min=2) [if] [in] ///
       [, VERsion LIStvariants SHOWPROGress DELta(real 0.025) r2values(integer 9999) Pvalue(real 0.01)]
marksample touse
*
* Extract the dependent variable name (the first name in varlist)
*
local depvar=word("`varlist'",1)
*
* Get the names of the independent variables (subsequent names in varlist)
*
local indepvars=subinword("`varlist'","`depvar'","",1)

* Keep the dependent variable and the variables that are to be included in the regression

keep `depvar' `indepvars'
*
* Delta must be >0.
*
display " "
if `delta'<=0 {
	display in red "delta must be > 0"
	exit 498
}
*
* If r2values is not specified set r2values=1/delta.
*
if `r2values'==9999 { 
	local r2values=int(1/`delta')		
}
*
* r2values must be <= 1/delta.  Check that here.
*
if `r2values'> 1/`delta' { 				
	display in red "r2values must be <= "  1/`delta' " (1/delta)" 
	exit 498
}

if `pvalue'>= 1 | `pvalue'<=0 { 
	display in red "pvalue must be >0 and <1"
	exit 498
}
*
*  If requested, display the sentinel program verison being used.
*
if "`version'"=="version" {
	display as result "This is sentinel version $sentinel_version ($sentinel_version_date)."
}
*
* Request to list variants considered by the sentinel program.
*
global listvariants=0
if "`listvariants'"=="listvariants" {
	global listvariants=1
}
*
* Request to show progress of the program.
*
global showprogress=0
if "`showprogress'"=="showprogress" {
	global showprogress=1
}

* Eliminate SNPs that do not vary among cases.  These SNPs create missing
* correlation coefficients that cause the agorithm to fail.

quietly ds `depvar', not
local snplist `r(varlist)'
local bettersnplist  `snplist'
foreach snp of local snplist {
    quietly summarize `snp' if `depvar' == 1
    if r(sd) == 0 { // This SNP is constant for all cases
        local nvariants = r(mean)
        disp " "
        display as result "Warning: `snp' is dropped because it does not vary among cases."
        display as result "         All case patients have `nvariants' variant alleles for this SNP."
        local bettersnplist = subinword("`bettersnplist'", "`snp'", " ", .)
        quietly drop `snp'
    }
}
local snplist  `bettersnplist'

global sentinel_depvar "`depvar'"
global sentinel_indepvars "`snplist'"
*
* Get the name of the open data set.  It is
* used later in rename_variants function.
*
* global sentinel_input_data=c(filename)

global sentinel_pvalue=`pvalue'
*
* This is set to prevent regressions
* running forever.  Is this a good value?
*
global sentinel_nregiter=15
*
* Important working variable
*
*    $sentinel_nextr2 - the r2 value used to identify snps in the same bin.
*
* =============================================================
* create vectors with all possible pair-wise correlation coefficients
* between snps.
* =============================================================
*
* Create the following 4 variables that will be saved as vectors:
*    snp1 - integer snp name and takes values 1,2,...n-1
*    snp2 - integer snp name and takes values snp1+1, snp1+2, ... ,n
*    r2   - squared correlation coefficient between snp1 & snp2
*    drop - indicates if record should be dropped.  
*          Set in function eliminate.
* This file contains (n*(n-1))/2 records and gives the pearson correlation
* coefficient for each possible pair of snps.
*
* Read in the main data set again.
*
* Local macro n contains count of SNP variables.
*
* Rename the SNPs using the rename subroutine.
*

local sentinel_depvar $sentinel_depvar
rename_variants `dictionary' `temp_proinpdata' `sentinel_depvar' // This subroutine renames the SNPs snp_1, snp_2, ... etc
quietly ds `depvar', not
local n=wordcount(r(varlist))
local snplist `r(varlist)'
* snpvars is a list of the SNP variables names.
*
* unab snpvars: snp_*
*
* Calculate number of 2-way correlations.
*
display as result "Calculating pair-wise correlation coefficients between SNPs"
display as result "This may take a while if the number of SNPs is large"
local ncor = (`n' -1)*`n'/2
*
* Create mata vectors snp1, snp2, r, r2, bin & drop.
*
mata: snp1=J(`ncor',1,.)
mata: snp2=J(`ncor',1,.)
mata: r=J(`ncor',1,.)
mata: r2=J(`ncor',1,.)
mata: bin=J(`ncor',1,0)
mata: drop=J(`ncor',1,0)
*
* Use pwcorr to calculate each of the pair-wise
* correlation values r.
*
local nrecord = 0 
forvalues i=1/`n' {
    local xx=`i'+1
    forvalues j=`xx'/`n' {
	quietly pwcorr snp_`i' snp_`j' if `depvar'==1
	local nrecord = `nrecord'+1
	local r=r(rho)
	local r2=r(rho)*r(rho)
*
* Store these correlation values in mata vectors.
*	
	mata:snp1[`nrecord']=`i'	
	mata:snp2[`nrecord']=`j'	
	mata:r[`nrecord']=`r'	
	mata:r2[`nrecord']=`r2'	
    }
}
*
* Record the number of 2-way correlations.
*
global sentinel_correlate_N = `ncor'
if `ncor' >0 {
    global no_remaining_correlations = 0
}
else {
    global no_remaining_correlations = 1
    display "Less than 2 SNPs in the sentinel input"
}    

*==============================================================================
* Create a vector snps containing the initial list fot the numerical snp names.
* Create a vector best which will indicate snps thatshould not be dropped
* in the next round of evaluations with a smaller R^2 value
*==============================================================================
*
* Local macro n contains count of SNP variables.
*
quietly ds snp*
local n=wordcount(r(varlist))
display " "
disp as result "The dataset contains `n' SNPs"
*
* snpvars is a list of the SNP variables names.
*
unab snpvars: snp*
*
* Make a file snpfile that contains two variables: snps, best.
*
quietly save "`preserve'"
clear

quietly set obs `n'
gen snps = _n
gen best = 0
global sentinel_snpfile_N = _N
quietly putmata snps best, replace

use "`preserve'", clear
quietly ds snp*
local inputn=wordcount(r(varlist))
global sentinel_nextr2=1
*
* sentinel_bestlist - this will be a list of snps that predict cancer well.
*        Initially null.
*
global sentinel_bestlist " "

display as result "Consider `r2values' different R^2 values to define bin membership"
display as result "Difference between consecutive R^2 values = `delta' "
display as result "P-value for inclusion in the sentinel model = `pvalue' "
display " "

*macro list _all

if $showprogress==1 {
	disp "Progress..."
}
global bin_exiting_early=0
global count_marked = 0
forvalues k=1/`r2values' {
    global count_dropped = 0
    if $no_remaining_correlations == 0 {
        if $showprogress == 1 {
            display as result "Iteration " `k'
        }    
        bin // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% bin call %%%%%%%%%%%%%
    }	
    global sentinel_nextr2=$sentinel_nextr2-`delta'
}

if $showprogress==1 {
	disp " "
}
*
* Make a local macro by copying the global
* $sentinel_bestlist.
*
local covariatelist $sentinel_bestlist
*
* Run a regression with the selected SNPs as the
* covariates.
*
quietly logit `depvar' `covariatelist', iter($sentinel_nregiter)
*
* Remove the SNPs that were dropped by the above
* regression.  Make a list of the remaining SNPs.
*
global sentinel_bestlist ""
foreach snp of local covariatelist {
    local thispvalue = 2*normal(-abs(_b[`snp']/_se[`snp']) )
    if `thispvalue' <= `pvalue' {
        global sentinel_bestlist $sentinel_bestlist `snp'
    }
}
local tempn=wordcount("`covariatelist'")
local bestn=wordcount("$sentinel_bestlist")
name_restoration `dictionary'
local bestn=wordcount("$sentinel_bestrealnames")
if `bestn'~=0 {
	disp as result "`bestn' variants have been selected by the sentinel program. They are: $sentinel_bestrealnames" 
} 
else {
	disp as result "`bestn' variants have been selected by the sentinel program." 
}

use "`temp_proinpdata'", clear
*
* If the sentinel selects no snps then there is nothing
* to do at the end of the routine.
*
if `bestn'~=0 {
    display " "
    display "Logistic regression of `depvar' vs. the variants selected by the sentinel program"
    logistic `depvar' $sentinel_bestrealnames, iter($sentinel_nregiter)
    predict logodds2, xb
    display " "
    display "Area under the ROC curve obtained using the linear predictor from the previous model"
	
    roctab `depvar' logodds2
    if `bestn' > 1 {
	display " "
	display "Correlation matrix of the selected variants among case patients"
	pwcorr $sentinel_bestrealnames if `depvar'==1
	display " "
	display "Correlation matrix of the selected variants among all patients"
	pwcorr $sentinel_bestrealnames 
    }
}

return local n = `bestn'
return local sentinel = strtrim("$sentinel_bestrealnames")
*
* Drop the global macros we created in this program:
* 
macro drop sentinel_*
*
* The global macros created by this program are:
* sentinel_bestrealnames 
* sentinel_bestlist 
* sentinel_nextr2 
* sentinel_snpfile_N 
* sentinel_working_i 
* sentinel_correlate_N 
* sentinel_case_control_N 
* sentinel_cancerfile_mapped 
* sentinel_proinpdata 
* sentinel_nregiter 
* sentinel_pvalue 
* sentinel_input_data 
* sentinel_indepvars 
* sentinel_depvar
*

* Drop all matrices created by this program

mata: mata drop snp1 snp2 r r2 drop
restore

end //end of sentinel

*========================================================================
* subroutine rename_variants 
*=========================================================================

* This program assigns new names to the SNPs of the form
* snp_1, snp_2, snp_3, ....
* It also creates a table to translate these names back to the
* original names when the sentinel program is finished.

capture program drop rename_variants
program define rename_variants
    args temp_name_map temp_proinpdata sentinel_depvar
quietly drop if `sentinel_depvar' == .
local snplist $sentinel_indepvars
keep `sentinel_depvar' `snplist' 
quietly ds

if $listvariants==1 {
    display " "
    display as result "Dependent variable = `sentinel_depvar'"
    display as result "Complete list of variants considered by the sentinel program"
    display as result "`snplist'"
}
quietly save "`temp_proinpdata'"
*
* Make a data set where the SNP names are are renamed
* to be snp1, snp2, etc.
*
clear
local snpcount=wordcount("`snplist'")
global nsnpsconsidered = `snpcount'
display " "
display "Number of SNPs evaluated = `snpcount'"
quietly set obs `snpcount'
quietly gen n=.
quietly gen real_snpname =""
quietly gen abbre_snpname = ""
local i=0
local complete_snp_list = " "
* Create translation table of real and simple snp names"
foreach snpname of local snplist {
    local i=`i'+1
    local complete_snp_list = "`complete_snp_list' snp_`i'"
    quietly replace n = `i' 			if _n == `i'
    quietly replace real_snpname = "`snpname'" 	if _n == `i'
    quietly replace abbre_snpname = "snp_`i'"	if _n == `i'
}

quietly save "`temp_name_map'"
if $showprogress == 1 {
    disp " "
    disp "Table of ID numbers assigned to SNPs"
    gen SNP_ID = n
    gen SNP_name = real_snpname 
    list SNP_name SNP_ID
}
quietly use "`temp_proinpdata'", clear
local i=0
foreach snpname of local snplist {
    local i=`i'+1
    quietly rename   `snpname' snp_`i'
}
global sentinel_case_control_N = _N
quietly putmata *, replace
end // of routine rename_variants

*=======================================================================
* subroutine eliminate
*=======================================================================
*
* Identify snps in the same bin as the sentinel_working_i snp
* Select the best snp from this bin
* Regress case against all of the snps in the bin
* Delete records from snpfile that are in the bin but not either the best snp
* in this bin or significant in the multivariable model with p <= $sentinel_pvalue
* Delete records in correlate that refer to pairs of snps that have been considered 
* this bin.
*
capture program drop eliminate
program define eliminate
preserve 

clear
quietly set obs $sentinel_correlate_N
if $no_remaining_correlations == 0  {
    quietly getmata snp1 snp2 r r2 drop bin, replace
    quietly replace drop=0
    quietly replace bin=0
    quietly replace bin=-1 if (snp1==$sentinel_working_i | snp2==$sentinel_working_i) & r2 >= $sentinel_nextr2
    
    sort bin snp1 snp2

* binlist always contains $sentinel_working_i. It may be the only snp in the current bin

    local binlist "$sentinel_working_i"
    local newbinlist `binlist'
    local identify=0
    local j=0
*
* Initialize N to be dimension of the vectors snp1 snp2 r r2 drop & bin 
* We don't want j to become bigger than N.
*
    local N=_N
    while `identify'==0 & `j'<`N'{
        local j=`j'+1
        if bin[`j']==-1 {
*
* add any new values of snp1 or snp2 to newbinlist
*
            local s1 = string(snp1[`j'])
            local s2 = string(snp2[`j'])
            local newvalues=0
            if strpos("`newbinlist'","`s1'")==0 {
                local newvalues=1
                local newbinlist "`newbinlist' `s1'"
            }
            if strpos("`newbinlist'","`s2'")==0 {
                local newvalues=1
                local newbinlist "`newbinlist' `s2'"
            } 
            if `newvalues'==1 {
*
* For all records which have one of these new values
* and for which r2 >= $sentinel_nextr2, set bin=-1.
*
                quietly replace bin=-1 if (snp1==`s1' | snp1==`s2') & r2>=$sentinel_nextr2
                quietly replace bin=-1 if (snp2==`s1' | snp2==`s2') & r2>=$sentinel_nextr2
                local binlist `newbinlist'
                sort bin snp1 snp2
            }
            else {
*
* Otherwise there are no new values so set
* identify=1 and the while loop will terminate.
*
                local identify=1
            }
        }
    }
    local j=1
    local binlist "$sentinel_working_i"
    local snp_binlist "snp_$sentinel_working_i"
    
    while bin[`j']==-1 {
        local s1 = string(snp1[`j'])
        local s2 = string(snp2[`j'])
        local binlist "`binlist' `s1' `s2'"
        local snp_binlist "`snp_binlist' snp_`s1' snp_`s2'"
        quietly replace drop=1 if _n==`j'
        local j=`j'+1
    }
    quietly drop if drop==1  
*
* Remove duplicates from binlist.
*
    local binlist : list uniq binlist
    local snp_binlist : list uniq snp_binlist

    global sentinel_correlate_N = _N
    if _N == 0  {
        global no_remaining_correlations = 1
    }
    quietly putmata snp1 snp2 r r2 drop bin, replace  

    if $sentinel_nextr2==1 {
        clear
        quietly set obs $sentinel_snpfile_N
        quietly getmata snps best
        quietly gen drop=0
*
* Any snp will do as best in bin we will keep
* the first snp in binlist
*
        local i=0
        foreach s in `binlist'{
            local i=`i'+1
            if `i' == 1 {
                local bestsnp = `s' 
            }
            quietly replace drop=1 if `s'==snps & `i'>1
            global count_dropped = r(N)*r(mean) + $count_dropped
        }
        quietly drop if drop==1
        quietly drop drop
        global sentinel_snpfile_N = _N
        quietly putmata snps best, replace
*
* Remove bestsnp from binlist
*
        local binlist=subinstr("`binlist'", "`bestsnp'", "", .)
    }
    else {
*
* Identify snp in binlist that best predicts cancer.
* We define best in terms of z values rather than
* delta gap values.
        clear
        quietly set obs $sentinel_case_control_N
        quietly getmata $sentinel_depvar `snp_binlist'
        local bestvalue=0
        foreach snp of local binlist{
            local snpname "snp_`snp'"
            quietly logit $sentinel_depvar `snpname', iter($sentinel_nregiter)
	    local x = abs(_b[`snpname']/_se[`snpname'])
        
* In order to choose the same snp accross platforms round to 6 significant figures
        
            local x= round(`x',10^( floor(log10(`x')) - 5))       
            if `x' >= `bestvalue' {
                local bestsnp `snp'
                local bestvalue=`x'
            }
        }
* If there are more than one snp in the bin, 
* run a multivariable regression against all of the snps
* in the current bin. snps that are significant with 
* p <= $sentinel_pvalue will not be deleted below.
    
        if wordcount("`snp_binlist'") > 1 & wordcount("`snp_binlist'") != . {
            quietly logistic $sentinel_depvar `snp_binlist', iter($sentinel_nregiter)
            if e(converged) ==  1 {
                foreach multisnp of local snp_binlist {
                    quietly pwcorr `snp_binlist' if $sentinel_depvar == 1 
                    if  2*normal(-abs(_b[`multisnp']/_se[`multisnp']) ) <= $sentinel_pvalue {
*
* Remove multisnp from binlist if it is not the bestsnp. This
* will prevent it from being permenantly dropped from 
* consideration in this model
*
                        local multisnpnumber = ustrregexrf("`multisnp'","snp_" ,"")
                        if `multisnpnumber' != `bestsnp' {
                            local binlist=subinstr("`binlist'", "`multisnpnumber'", "", .)
                        }
                    }
                }    
            }
        }
        clear

       quietly set obs $sentinel_snpfile_N 
       quietly getmata snps best 
*
* drop all snps in the curent bin that are either
* 1) not the best in bin
* 2) not significant in the multivariable model
* 3) not already been selected with a higher value of sentinel_nextr2
*
* Remove bestsnp from binlist
*
        local binlist=subinstr("`binlist'", "`bestsnp'", "", .)
*
* Remove from the snps and best matrices the snps remaining in 
* binlist that have not previously been marked for possible 
* consideration in the model (i.e. snps with best = 1.
*

        foreach s of local binlist   {
            global count_dropped = $count_dropped + 1
            quietly drop if snps==`s' & best ~= 1
        }

        global sentinel_snpfile_N = _N
        quietly putmata snps best, replace
    }
*   Delete pairs of snps when one of the pair has already been
*   identified as not best in bin or not significant in the multivariable model

    clear
}

quietly set obs $sentinel_correlate_N 
if _N == 0  {
    global no_remaining_correlations = 1
}
if $no_remaining_correlations == 0  {
    quietly getmata snp1 snp2 r r2 drop bin 
    foreach s of local binlist   {
        quietly drop if  snp1 == `s' | snp2 == `s'
    }
    global sentinel_correlate_N = _N
    if _N == 0  {
        global no_remaining_correlations = 1
    }
    quietly putmata snp1 snp2 r r2 drop bin, replace
}
restore

end // of routine eliminate 

*=======================================================================
* subroutine bin
*=======================================================================
*
* This subroutine identifies bins of snps that are correlated with
* each other.  In each bin there must be one snp that has an
* r2 value >= $sentinel_nextr2 with every other snp in its bin.
*
capture program drop bin
program define bin
    
preserve
clear
if $showprogress == 1 {
    display "value of R2 = " $sentinel_nextr2 ". Number of SNPs considered at beginning of this iteration = " $nsnpsconsidered
}
quietly set obs $sentinel_snpfile_N
quietly capture getmata snps best
local rc=_rc
if (`rc' ~= 0) {
    disp "rc =`rc'"
    global bin_exiting_early=1
}

if `rc'==0 {
*
* Set sentinel_working_i to be the value of snps in the first record 
*
    global sentinel_working_i=snps[1]
*
* Loop while $sentinel_working_i <= value of snps in the last record 
*
    while $sentinel_working_i <= snps[_N] {
        if $no_remaining_correlations == 0 {
            eliminate					//!!! eliminate called here !!!!!!!!!!!!!!!!
        }
        clear
    quietly set obs $sentinel_snpfile_N

    * Create a Stata variable for each Mata vector specified
        quietly capture getmata snps best   
        local rc=_rc
    
        if (`rc' ~= 0) {
        	global bin_exiting_early=1
                continue, break
        }
*
* set sentinel_working_i to be smallest of snps that
* is greater than the current sentinel_working_i
*
        quietly gen working_i=$sentinel_working_i
        quietly gen greater=0
        quietly replace greater=1 if snps>working_i
        quietly egen tmpworking_i=min(snps) if greater ==1
        quietly egen tmp2=max(tmpworking_i )
        global sentinel_working_i=tmp2
        quietly drop working_i greater tmpworking_i tmp2
    }  // end of while $sentinel_working_i <= snps[_N] loop
} //end of conditional if `rc'==0 

if `rc'==0 {
*
* Initialise covariatelist.
*
    local covariatelist ""
*
* Get the values of snps in a local macro "tmplist"
* For example if snps have the value of 2, 3, and 6
* then tmplist would be "2 3 6".
*
    quietly levelsof snps, local(tmplist)
    global remainingsnps `tmplist'
*
* Make a covariatelist by prepending "snp_"
* to each of the values in tmplist.  Given the 
* example in the comment above covariatelist 
* would be "snp_2 snp_3 snp_6".
*
    foreach lname of local tmplist   {
        local x "snp_`lname'"
        local covariatelist `covariatelist' `x'
    }
    clear
    quietly set obs $sentinel_case_control_N
    quietly getmata $sentinel_depvar `covariatelist'
    quietly logit $sentinel_depvar `covariatelist', iter($sentinel_nregiter)
    if e(converged) ==  1 {
*
* Build sentinel_bestlist global macro of SNPs for
* the SNPs that survive the above regression.
*
        global sentinel_bestlist " "
        global count_marked = 0
        foreach snp of local covariatelist {
       	    local x = abs(_b[`snp']/_se[`snp'])
            local pvalue = 2*normal(-`x')  
            if `pvalue' <= $sentinel_pvalue & `pvalue' != . {
                global sentinel_bestlist $sentinel_bestlist `snp'
                global count_marked =$count_marked + 1
            }
        }
    } 
*
* If regression does not converge then
* do not modify the previous value of $sentinel_bestlist or $count_marked
*
* At end of bin report the number of snps in
* covariatelist and $sentinel_bestlist
*
* Set best=1 for each snp in sentinel_bestlist.
*
    clear
    quietly set obs $sentinel_snpfile_N
    quietly getmata snps best
    quietly replace best=0
    foreach snp of global sentinel_bestlist {
        local snpnum=real(subinstr("`snp'", "snp", "", 1))
        quietly replace best=1 if snps==`snpnum'
    } 
    global sentinel_snpfile_N = _N
    quietly putmata snps best, replace
 
} //end of if `rc'==0 conditional

restore
local remainingsnpscount = wordcount("$remainingsnps")
if $showprogress == 1 {
    display "Number of SNPs considered at the end of this iteration = `remainingsnpscount'"
    display "Number of SNPs dropped during this iteration = " $nsnpsconsidered - `remainingsnpscount'
    display "Number of marked snps = " wordcount("$sentinel_bestlist")
    display "SNP IDs of SNPs considered at the end of this iteration = $remainingsnps"
    local markedsnpid = subinstr("$sentinel_bestlist", "snp_", "", .)
    display "SNP IDs of marked snps = `markedsnpid'"
    display " "
}
global nsnpsconsidered  = `remainingsnpscount'

end //of routine bin

*========================================================================
* subroutine name_restoration
*=========================================================================

* This program converts the SNPs in $sentinel_bestlist back to their original names

capture program drop name_restoration
program define name_restoration
    args temp_name_map
*
* Translate back to real snp names.
*
use "`temp_name_map'", clear
gen use=0
foreach snp of global sentinel_bestlist {
    quietly replace use=1 if trim(abbre_snpname) == trim("`snp'")
}
quietly keep if use==1
keep real_snpname

global sentinel_bestrealnames " "
local N=_N
forvalues i = 1/`N' {
    local snp=real_snpname[`i']
    global sentinel_bestrealnames "$sentinel_bestrealnames `snp'"
}
global sentinel_bestrealnames=trim("$sentinel_bestrealnames")

end // of routine name_restoration


