*! version 1.1.6 October 05, 2005 @ 12:17
program define genass
version 8.0
* Defines options which determine which tests to perform
	syntax varlist(min=2) [if] [in], GRoup(string) ID(string) OUTput(string) [replace TEXt all HW ALLElic GENotypic DOMinant RECessive TRend PWLD(string) MAP(string) TABLE GRAPH]

* Convert switches to logicals (gleaned from Nick Cox's routines, thanks)
	local all         = "`all'"       == "all"
	local hw          = "`hw'"        == "hw"
	local allelic     = "`allelic'"   == "allelic"
	local genotypic   = "`genotypic'" == "genotypic"
	local dominant    = "`dominant'"  == "dominant"
	local recessive   = "`recessive'" == "recessive"
	local trend       = "`trend'"     == "trend"

* The pwld switch however needs to be saved first so that the desired statistics are calculated
	local pwld_stat "`pwld'"
	local pwld        = "`pwld'"      == "pwld"

* Opens an ASCII text file for writing the results to
	capture file close output
	qui file open output using `output'.txt, write `replace'

* Checks that there is an even number of variables. Something along the lines of counting the number of tokens in varlist and ensuring that dividing by two leaves an interger (or at least nothing left over)

* Checks that contradictory options have not been specified
	if(`all' == 1 & (`hw' == 1 | `allelic' == 1 | `genotypic' == 1 | `dominant' == 1 | `recessive' == 1 | `trend' == 1 | `pwld' == 1)){
		di in red "You can not specify the All option in conjunction with any others, please choose whether you want all statistics calculated or a subset"
		exit
	}

* Checks that if the graph option has been specified that the map file has also been specified
	if("`graph'" ~= "" & "`map'" == ""){
		di in red "You must specify your map file if you want graphs to be drawn"
		exit
	}
* Turns on all statistics if all is specified
	if(`all' == 1){
		local hw = 1
		local allelic = 1
		local genotypic = 1
		local dominant = 1
		local recessive = 1
		local trend = 1
	}

* Turns of all other statistics if specifics have been chosen
	if(`all' == 1){
		local all = 0
	}
	if(`hw' == 1 | `allelic' == 1 | `genotypic' == 1 | `dominant' == 1 | `recessive' == 1 | `trend' == 1 | `pwld' == 1){
		local all = 1
	}

* Writes the header of the results file
* Defines a local macro which contains a list of statistics that are to be calculated
	file write output "locus,control_frq1,control_frq2,control_wt,control_het,control_mut,control_n,case_frq1,case_frq2,case_wt,case_het,case_mut,case_n,"
	if(`all' == 0 | `hw' == 1){
		file write output "hw_d_control,hw_chi_control,hw_p_control,hw_exact_control,hw_d_case,hw_chi_case,hw_p_case,hw_exact_case,"
	}
	if(`all' == 0 | `allelic' == 1){
		file write output "allele1_or,allele1_lb_or,allele1_ub_or,allele1_exact,allele2_or,allele2_lb_or,allele2_ub_or,allele2_exact,allele_chi2,allele_chi2_p,"
	}
	if(`all' == 0 | `genotypic' == 1){
		file write output "gen_chi2,gen_df,gen_p,gen_exact,"
	}
	if(`all' == 0 | `dominant' == 1){
		file write output "dom_chi2,dom_df,dom_p,dom_exact,dom_or,dom_lb_or,dom_ub_or,"
	}
	if(`all' == 0 | `recessive' == 1){
		file write output "rec_chi2,rec_df,rec_p,rec_exact,rec_or,rec_lb_or,rec_ub_or,"
	}
	if(`all' == 0 | `trend' == 1){
		file write output "trend_z,trend_p,trend_n"
	}
	file write output _n

* Stores the data in a temporary file
* Use restore, preserve to get the data back
	tempfile temp
	preserve

* Defines temporary variables
	tempvar marker
		
* Initiates a loop to repeat for all pairs of alleles
	tokenize `varlist'
	while("`1'" ~= ""){
		local locus = subinstr("`1'", "_1","",.)
* Genotype frequencies in cases and controls are now calculated
		forval x = 0/1{
			if(`x' == 0) local status = "controls"
			else         local status = "cases"
			qui count if(`group' == `x' & (`locus'_1 == 1 & `locus'_2 == 1))
			local AA_`status' = r(N)
			qui count if(`group' == `x' & ((`locus'_1 == 1 & `locus'_2 == 2) | (`locus'_1 == 2 & `locus'_2 == 1)))
			local Aa_`status' = r(N)
			qui count if(`group' == `x' & (`locus'_1 == 2 & `locus'_2 == 2))
			local aa_`status' = r(N)
		}	
	
* Allele frequencies are calculated
* Genotypes are reshaped to long for calculation of OR
		qui reshape long `locus'_, i(`id') j(allele)

* Allele frequencies in controls are calculated and saved for reporting later
		qui sum `locus'_ if(`group' == 0)
		local controls = r(N)
		local controls_n = r(N) / 2
		qui sum `locus'_ if(`group' == 0 & `locus'_ == 1)
		local controls_frq_1 = r(N) / `controls'
		qui sum `locus'_ if(`group' == 0 & `locus'_ == 2)
		local controls_frq_2 = r(N) / `controls'

* Allele frequencies in cases are calculated and saved for reporting later
		qui sum `locus'_ if(`group' == 1)
		local cases = r(N)
		local cases_n = r(N) / 2
		qui sum `locus'_ if(`group' == 1 & `locus'_ == 1)
		local cases_frq_1 = r(N) / `cases'
		qui sum `locus'_ if(`group' == 1 & `locus'_ == 2)
		local cases_frq_2 = r(N) / `cases'

		file write output "`locus',`controls_frq_1',`controls_frq_2',`AA_controls',`Aa_controls',`aa_controls',`controls_n',`cases_frq_1',`cases_frq_2',`AA_cases',`Aa_cases',`aa_cases',`cases_n',"
		qui reshape wide `locus'_, i(`id') j(allele)

* Performs Hardy-Weinberg tests in controls
		if(`all' == 0 | `hw' == 1){
			qui genhw `1' `2' if(`group' == 0), exact

* Stores the results for returning at the end of the loop
			local hw_controls = r(D)
			local hw_controls_chi = r(chi2)
			local hw_controls_p = r(chi2_p)
			local hw_controls_exact = r(p_exact)

* Performs Hardy-Weinberg tests in cases
			qui genhw `1' `2' if(`group' == 1), exact

* Stores the results for returning at the end of the loop
			local hw_cases = r(D)
			local hw_cases_chi = r(chi2)
			local hw_cases_p = r(chi2_p)
			local hw_cases_exact = r(p_exact)
			file write output "`hw_controls',`hw_controls_chi',`hw_controls_p',`hw_controls_exact',`hw_cases',`hw_cases_chi',`hw_cases_p',`hw_cases_exact',"
		}

* Genotypes are reshaped to long for calculation of OR
		qui reshape long `locus'_, i(`id') j(allele)

* Allelic associations are now performed
		if(`all' == 0 | `allelic' == 1){

* Allele 2 as the risk factor is now tested, alleles encoded as 0 and 1 (allele2 = 1)
			qui replace `locus'_ = `locus'_ - 1
			qui cc `group' `locus'_ , exact
			qui replace `locus'_ = `locus'_ + 1
			local all_2_or = r(or)
			local all_2_ub_or = r(ub_or)
			local all_2_lb_or = r(lb_or)
			local all_2_exact = r(p_exact)
* Allele 1 as the risk allele is now tested, alleles encoded as 0 and 1 (allele1 = 1)
			qui replace `locus'_ = `locus'_ - 2
			qui cc `group' `locus'_, exact
			local all_1_or = r(or)
			local all_1_ub_or = r(ub_or)
			local all_1_lb_or = r(lb_or)
			local all_1_exact = r(p_exact)
			qui cc `group' `locus'_
			local all_chi2 = r(chi2)
			local all_chi2_p = r(p)
			qui replace `locus'_ = `locus'_ + 2
			file write output "`all_1_or',`all_1_lb_or',`all_1_ub_or',`all_1_exact',`all_2_or',`all_2_lb_or',`all_2_ub_or',`all_2_exact',`all_chi2',`all_chi2_p',"
		}

* Genotypes are reshaped to wide for further calculations
		qui reshape wide `locus'_, i(`id') j(allele)

* Performs genotypic association test and stores results for displaying later
		if(`all' == 0  | `genotypic' == 1){
* Encodes the current SNP so that genotypic tests of association can be performed
			qui gen __marker = .
			qui replace __marker = 1 if(`1' == 1 & `2' == 1)
			qui replace __marker = 2 if(`1' == 1 & `2' == 2) | (`1' == 2 & `2' == 1)
			qui replace __marker = 3 if(`1' == 2 & `2' == 2)
			qui tab `group' __marker, chi exact
			local gen_chi2 = r(chi2)
			local gen_df = (r(r) - 1) * (r(c) - 1)
			local gen_p = r(p)
			local gen_exact = r(p_exact)
			qui drop __marker
			file write output "`gen_chi2',`gen_df',`gen_p',`gen_exact',"
		}

* Genotypic tests are now performed
* Encodes the current SNP so that a dominant test of association can be performed
		if(`all' == 0 | `dominant' == 1){
			qui gen __marker = 2
			qui replace __marker = 1 if(`1' == 1 & `2' == 1)
			qui replace __marker = . if(`1' == . | `2' == .)
			qui tab `group' __marker, chi exact
			local gen_dom_chi2 = r(chi2)
			local gen_dom_df = (r(r) - 1) * (r(c) - 1)
			local gen_dom_p = r(p)
		   local gen_dom_exact = r(p_exact)
			qui replace __marker = __marker - 1
			qui cc `group' __marker
			local gen_dom_or = r(or)
			local gen_dom_lb = r(lb_or)
			local gen_dom_ub = r(ub_or)
			qui drop __marker
			file write output "`gen_dom_chi2',`gen_dom_df',`gen_dom_p',`gen_dom_exact',`gen_dom_or',`gen_dom_lb',`gen_dom_ub',"
		}

* Enocdes the current SNP so that a recessive test of association can be performed
		if(`all' == 0  | `recessive' == 1){
			qui gen __marker = 2
			qui replace __marker = 1 if(`1' == 1 | `2' == 1)
 			qui replace __marker = . if(`1' == . | `2' == .)
			qui tab `group' __marker, chi exact
			local gen_rec_chi2 = r(chi2)
			local gen_rec_df = (r(r) - 1) * (r(c) - 1)
			local gen_rec_p = r(p)
			local gen_rec_exact = r(p_exact)
 			qui replace __marker = __marker - 1
			qui cc `group' __marker
			local gen_rec_or = r(or)
			local gen_rec_lb = r(lb_or)
			local gen_rec_ub = r(ub_or)
			qui drop __marker	
			file write output "`gen_rec_chi2',`gen_rec_df',`gen_rec_p',`gen_rec_exact',`gen_rec_or',`gen_rec_lb',`gen_rec_ub',"
		}



* Performs Arimtage Trend Test using a slightly modified ptrend command (originally written by Patrick Royston.  The modified version has been placed on m:/stata8/ado/stbplus/p
		if(`all' == 0  | `trend' == 1){

* Encodes the current SNP so that genotypic tests of association can be performed
			qui gen __marker = .
			qui replace __marker = 1 if(`1' == 1 & `2' == 1)
			qui replace __marker = 2 if(`1' == 1 & `2' == 2) | (`1' == 2 & `2' == 1)
			qui replace __marker = 3 if(`1' == 2 & `2' == 2)
			qui nptrend `group', by(__marker)
			local trend_z = r(z)
			local trend_p = r(p)
			local trend_n = r(N)
			file write output "`trend_z',`trend_p',`trend_n'"
		}

* Adds a carriage return to the output file so data is on seperate lines
		file write output _n

* Shifts to the next two alleles
		mac shift 2

* Restores the original data set
		restore, preserve
	}

* Closes the text based results file
	file close output

* Calculates pair-wise LD using the specified statistic
	if(`pwld' == 1){
		
		qui pwld `varlist', measure(`pwld_stat') saving(`output'_pwld) `replace'
	}

* Reads in the results that have been stored in the text file and labels vars

* Reads in the data that was written to temporary text file
	qui insheet using `output'.txt, clear comma names

* Renames variables, this is required because upper case letters are converted to lower case when read in
	foreach x in case control{
		rename `x'_wt AA_`x'
		rename `x'_het Aa_`x'
		rename `x'_mut aa_`x'
	}
	
* Labels variables
	label var locus "Marker ID"
	label var control_frq1 "Frequency of allele1 in Controls"
	label var control_frq2 "Frequency of allele2 in Controls"
	label var AA_control "Frequency of 11 Genotype in Controls"
	label var Aa_control "Frequency of 12 Genotype in Controls"
	label var aa_control "Frequency of 22 Genotype in Controls"
	label var control_n "Number of controls genotyped"
	label var case_frq1 "Frequency of allele1 in Cases"
	label var case_frq2 "Frequency of allele2 in Cases"
	label var AA_case "Frequency of 11 Genotype in Cases"
	label var Aa_case "Frequency of 12 Genotype in Cases"
	label var aa_case "Frequency of 22 Genotype in Cases"
	label var case_n "Number of cases genotyped"
	if(`all' == 0 | `hw' == 1){
		label var hw_d_control "Hardy-Weinberg Equilibrium in Controls"
		label var hw_chi_control "Chi-squared for H-W eqm in Controls"
		label var hw_p_control "P-value for Chi-squared H-W eqm in Controls"
		label var hw_exact_control "Exact p-value for Chi-squared H-W eqm in Controls"
		label var hw_d_case "Hardy-Weinberg Equilibrium in Cases"
		label var hw_chi_case "Chi-squared for H-W eqm in Cases"
		label var hw_p_case "P-value for Chi-squared H-W eqm in Cases"
		label var hw_exact_case "Exact p-value for Chi-squared H-W eqm in Cases"
	}
	if(`all' == 0 | `allelic' == 1){
		label var allele1_or "Odds-Ratio for allelic association of allele1"
		label var allele1_lb_or "Lower 95% CI for allelic association of allele1"
		label var allele1_ub_or "Upper 95% CI for allelic association of allele1"
		label var allele1_exact "Exact p-value for allelic association of allele1"
		label var allele2_or "Odds-Ratio for allelic association of allele2"
		label var allele2_lb_or "Lower 95% CI for allelic association of allele2"
		label var allele2_ub_or "Upper 95% CI for allelic association of allele2"
		label var allele2_exact "Exact p-value for allelic association of allele2"
		label var allele_chi2 "Chi-squared for allelic association"
		label var allele_chi2_p "P-value of Chi-squared for allelic association"
	}
	if(`all' == 0 | `genotypic' == 1){
		label var gen_chi2 "Chi-squared for genotypic association"
		label var gen_df "Degrees of freedom for genotypic association"
		label var gen_p "P-value for genotypic association"
		label var gen_exact "Exact p-value for genotypic association"

	}
	if(`all' == 0 | `dominant' == 1){
		label var dom_chi2 "Chi-squared for dominant association"
		label var dom_df "Degrees of freedom for dominant association"
		label var dom_p "P-value for dominant association"
		label var dom_exact "Exact p-value for dominant association"
      label var dom_or "Odds-Ratio for dominant association"
		label var dom_lb_or "Lower 95% CI of Odds-Ratio for dominant association"
		label var dom_ub_or "Upper 95% CI of Odds-Ratio for dominant association"
	}
	if(`all' == 0 | `recessive' == 1){
		label var rec_chi2 "Chi-squared for recessive association"
		label var rec_df "Degrees of freedom for recessive association"
		label var rec_p "P-value for recessive association"
		label var rec_exact "Exact p-value for recessive association"
      label var dom_or "Odds-Ratio for recessive association"
		label var dom_lb_or "Lower 95% CI of Odds-Ratio for recessive association"
		label var dom_ub_or "Upper 95% CI of Odds-Ratio for recessive association"
	}
	if(`all' == 0 | `trend' == 1){
		label var trend_z "Z statistic for genotypic trend test"
		label var trend_p "P-value for trend test"
		label var trend_n "Sample size for trend test"
	}

* Generates -log10() of all p-values ready for graphing
	gen log_hw_exact_case = -log10(hw_exact_case)
	gen log_hw_exact_control = -log10(hw_exact_control)
	gen log_allelic_p = -log10(allele_chi2_p)
	gen log_gen_exact = -log10(gen_exact)
	gen log_dom_exact = -log10(dom_exact)
	gen log_rec_exact = -log10(rec_exact)
	gen log_trend_p = -log10(trend_p)

* If the tab-delimited map file has been specified it is now merged into the data
	if("`map'" ~= ""){
		sort locus
		qui save `output', `replace'
		qui insheet using `map', clear
		label var locus "Marker Name"
		label var pos "Positions (bp)"
		sort locus
		merge locus using `output'
		drop _merge
* Applies the locus names as labels to the position in base-pairs for labelling of the x-axis
		labmask pos, values(locus)
		sort pos
	}
	
* Removes any extra variables
	capture drop v*
* Saves the data set as a Stata formatted file
	save `output', `replace'

* Generate html-formatted tables if specified
        if("`table'" ~= ""){

* Formats numbers so they are displayed with four decimal places

* Genotype and Allele Frequencies in Cases
		format *_frq* %9.4f
		listtex locus case_n AA_case Aa_case aa_case case_frq1 case_frq2 using `output'.html, rstyle(html) head(`"<table cellspacing="2" cellpadding="4" border="3" align="center">"' `"<tr><th rowspan="2">Locus</th><th rowspan="2">Sample Size</th><th colspan="3">Genotype Fr<sup>q</sup></th><th colspan="2">Allele Fr<sup>q</sup></th></tr>"' `"<tr><th>11</th><th>12</th><th>22</th><th>1</th><th>2</th></tr>"') foot(`"</table>"' `"<br><b>Table 1</b> - Genotype and Allele Frequencies in Cases<br><br>"') missnum("-") replace

* Hardy-Weinberg Equilibrium in Cases
		format hw_* %9.4f
		listtex locus hw_d_case hw_chi_case hw_p_case hw_exact_case, rstyle(html) head(`"<table cellspacing="2" cellpadding="4" border="3" align="center">"' `"<tr><th rowspan="2">Locus</th><th colspan="4">Statistics</th></tr>"' `"<th>D</th><th>HW &chi;<sup>2</sup></th><th>P-value</th><th>Exact</th></tr>"') foot(`"</table>"' `"<br><b>Table 2</b> - Hardy-Weinberg Equilibrium in Cases<br><br>"') missnum("-") appendto(`output'.html)

* Genotype and Allele Frequencies in Controls
		format *_frq* %9.4f
		listtex locus control_n AA_control Aa_control aa_control control_frq1 control_frq2, rstyle(html) head(`"<table cellspacing="2" cellpadding="4" border="3" align="center">"' `"<tr><th rowspan="2">Locus</th><th rowspan="2">Sample Size</th><th colspan="3">Genotype Fr<sup>q</sup></th><th colspan="2">Allele Fr<sup>q</sup></th></tr>"' `"<tr><th>11</th><th>12</th><th>22</th><th>1</th><th>2</th></tr>"') foot(`"</table>"' `"<br><b>Table 3</b> - Genotype and Allele frequencies in Controls<br><br>"') missnum("-") appendto(`output'.html)

* Hardy-Weinberg Equilibrium in Controls
		format hw_* %9.4f
		listtex locus hw_d_control hw_chi_control hw_p_control hw_exact_control, rstyle(html) head(`"<table cellspacing="2" cellpadding="4" border="3" align="center">"' `"<tr><th rowspan="2">Locus</th><th colspan="4">Statistics</th></tr>"' `"<th>D</th><th>HW &chi;<sup>2</sup></th><th>P-value</th><th>Exact</th></tr>"') foot(`"</table>"' `"<br><b>Table 4</b> - Hardy-Weinberg Equilibrium in Controls<br><br>"') missnum("-") appendto(`output'.html)


* Genotypic association
		format *_chi2 *_df *_p *_exact %9.4f
        	listtex locus gen_chi2 gen_df gen_p gen_exact, rstyle(html) head(`"<table cellspacing="2" cellpadding="4" border="3" align="center">"' `"<tr><th rowspan="2">Locus</th><th colspan="4">Statistics</th></tr>"' `"<th>&chi;<sup>2</sup></th><th>df</th><th>P-value</th><th>Exact</th></tr>"') foot(`"</table>"' `"<br><b>Table 5</b> - Genotypic association<br><br>"') missnum("-") appendto(`output'.html)

* Allelic association of Allele 1
		format *_chi2 *_or *_df *_p *_exact %9.4f
        	listtex locus allele_chi2 allele_chi2_p allele1_or allele1_lb_or allele1_ub_or, rstyle(html) head(`"<table cellspacing="2" cellpadding="4" border="3" align="center">"' `"<tr><th rowspan="2">Locus</th><th colspan="5">Statistics</th></tr>"' `"<tr><th>&chi;<sup>2</sup></th><th>P-value</th><th>OR</th><th>Lower 95% CI</th><th>Upper 95% CI</th></tr>"') foot(`"</table>"' `"<br><b>Table 6</b> - Allelic association of allele 1<br><br>"') missnum("-") appendto(`output'.html)

* Allelic association of Allele 2
		format *_chi2 *_or *_df *_p *_exact %9.4f
        	listtex locus allele_chi2 allele_chi2_p allele2_or allele2_lb_or allele2_ub_or, rstyle(html) head(`"<table cellspacing="2" cellpadding="4" border="3" align="center">"' `"<tr><th rowspan="2">Locus</th><th colspan="5">Statistics</th></tr>"' `"<tr><th>&chi;<sup>2</sup></th><th>P-value</th><th>OR</th><th>Lower 95% CI</th><th>Upper 95% CI</th></tr>"') foot(`"</table>"' `"<br><b>Table 7</b> - Allelic association of allele 1<br><br>"') missnum("-") appendto(`output'.html)

* Dominant Association
		format *_chi2 *_or *_df *_p *_exact %9.4f
		listtex locus dom_chi2 dom_df dom_p dom_exact dom_or dom_lb_or dom_ub_or, rstyle(html) head(`"<table cellspacing="2" cellpadding="4" border="3" align="center">"' `"<tr><th rowspan="2">Locus</th><th colspan="7">Statistics</th></tr>"' `"<tr><th>&chi;<sup>2</sup></th><th>DF</th><th>P-value</th><th>Exact</th><th>OR</th><th>Lower 95% CI</th><th>Upper 95%</th></tr>"') foot(`"</table>"' `"<br><b>Table 8</b> - Dominant Association (Risk infered by carriage of allele 2)<br><br>"') missnum("-") appendto(`output'.html)

* Recessive Association
		format *_chi2 *_or *_df *_p *_exact %9.4f
		listtex locus rec_chi2 rec_df rec_p rec_exact rec_or rec_lb_or rec_ub_or, rstyle(html) head(`"<table cellspacing="2" cellpadding="4" border="3" align="center">"' `"<tr><th rowspan="2">Locus</th><th colspan="7">Statistics</th></tr>"' `"<tr><th>&chi;<sup>2</sup></th><th>DF</th><th>P-value</th><th>Exact</th><th>OR</th><th>Lower 95% CI</th><th>Upper 95%</th></tr>"') foot(`"</table>"' `"<br><b>Table 9</b> - Dominant Association (Risk infered by carriage of two copies of allele 2)<br><br>"') missnum("-") appendto(`output'.html)

* Trend Test Statistics
		format *_z *_p %9.4f
		listtex locus trend_z trend_p trend_n, rstyle(html) head(`"<table cellspacing="2" cellpadding="4" border="3" align="center">"' `"<tr><th rowspan="2">Locus</th><th colspan="3">Statistics</th></tr>"' `"<tr><th>Z-statistic</th><th>P-value</th><th>Sample Size</th></tr>"') foot(`"</table>"' `"<br><b>Table 10</b> - Trend Test for Association<br><br>"') missnum("-") appendto(`output'.html)
	}

* Draws graphs of results if specified
	if("`graph'" ~= ""){

* First a local macro is generated which contains all of the unique positions.  This is required for the drawing of the graphs to be done correctly.
		qui sum pos
		local obs = r(N)
		forval x = 1/`obs'{
			qui sum pos in `x'
			local temp = r(mean)
			local loci = "`loci' `temp'"
		}
		
* Creates the sub-directory graphs if it does not already exist
		capture mkdir graphs

* Draws all graphs which are displayed and then exported to .png files


* Allele frequencies are plotted first
		graph bar control_frq1 case_frq1, over(locus) scheme(s1color) title("Allele frequencies in Cases and Controls") legend( lab(1 "Controls") lab(2 "Cases")) ytitle("Frequency of Allele 1") yscale(range(0 1)) ylabel(0(0.1)1, grid) bargap(-10)
		qui graph export graphs/`output'_allele_frq.png, `replace'

	
* Hardy-Weinberg equilibrium in cases and controls is plotted first.
		if(`all' == 0 | `hw' == 1){
			twoway scatter log_hw_exact_case, connect(direct) || scatter log_hw_exact_control pos, scheme(s1color) ytitle("-log10(p-value)") ylabel(,grid) yline(1.30103 2) legend(label(1 "Cases") label(2 "Controls")) xtitle("Position (bp)") xlab(#10,angle(270) labsize(small)) title("Hardy-Weinberg Equilibrium in Cases and Controls") connect(direct)
			qui graph export graphs/`output'_hw_eqm.png, replace
		}
		
* OR's & CI's for allelic association are now plotted
		if(`all' == 0 | `allelic' == 1){
			twoway scatter allele1_or pos || rcap allele1_lb_or allele1_ub_or pos, scheme(s1color) ytitle("Odd's Ratio") ylabel(, grid) legend(lab(1 "Odds-Ratio") lab(2 "95% CI")) yline(1) xlab(#10,angle(270) labsize(small)) xtitle("Position (bp)") title("Odds-Ratio and 95% CI for association of allele 1")
			qui graph export graphs/`output'_allele1_or.png, replace
			twoway scatter allele2_or pos || rcap allele2_lb_or allele2_ub_or pos, scheme(s1color) ytitle("Odd's Ratio") ylabel(, grid) legend(lab(1 "Odds-Ratio") lab(2 "95% CI")) yline(1) xlab(#10,angle(270) labsize(small)) xtitle("Position (bp)") title("Odds-Ratio and 95% CI for association of allele 2")
			qui graph export graphs/`output'_allele2_or.png, replace
		}

* The results of the genotypic, dominant and recessive models are now plotted
		if(`all' == 0 | `dominant' == 1 | `recessive' == 1){
			twoway scatter log_gen_exact pos, connect(direct) || scatter log_dom_exact pos, connect(direct) || scatter log_rec_exact pos, scheme(s1color) ylabel(, grid) ytitle("-log10(p-value)") yline(1.30103 2) legend(label(1 "General") label(2 "Dominant") label(3 "Recessive")) xlab(#10,angle(270) labsize(small)) xtitle("Position (bp)") title("P-values for genetic association under varying disease models") connect(direct direct direct)
			qui graph export graphs/`output'_genotype_ass.png, replace

* OR's and CI's for dominant and recessive models are now plotted
			twoway scatter dom_or pos || rcap dom_lb_or dom_ub_or pos, scheme(s1color) ytitle("Odd's Ratio") legend(lab(1 "Odds-Ratio") lab(2 "95% CI")) ylabel(, grid) yline(1)  xtitle("Position (bp)") xlab(#10,angle(270) labsize(small)) title("Odds-Ratio and 95% CI for dominant association")
			qui graph export graphs/`output'_dominant_or.png, replace
			twoway scatter rec_or pos || rcap rec_lb_or rec_ub_or pos, scheme(s1color) ytitle("Odd's Ratio") legend(lab(1 "Odds-Ratio") lab(2 "95% CI")) ylabel(, grid) yline(1) xlab(#10,angle(270) labsize(small)) xtitle("Position (bp)") title("Odds-Ratio and 95% CI for recessive association")
			qui graph export graphs/`output'_recessive_or.png, replace
		}

* Results of the trend test are now drawn
		if(`all' == 0 | `trend' == 1){
			twoway scatter log_trend_p pos, scheme(s1color) ytitle("-log10(p-value)") ylabel(, grid) yline(1.30103 2) legend(label(1 "General") label(2 "Dominant") label(3 "Recessive")) xlab(#10,angle(270) labsize(small)) xtitle("Position (bp)") title("P-values for Trend Test") connect(direct)
			qui graph export graphs/`output'_trend.png, replace
		}

* Displays a message to indicate where graphs have been saved
		di in green "Graphs have been saved in the sub-directory graphs/"
	}
	
* Removes the temporary text file
	erase `output'.txt
* Restores the original data set
	restore, preserve

end
	
