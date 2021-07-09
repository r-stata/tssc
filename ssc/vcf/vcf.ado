* VCF (Variant Caller Format)
* Daniel E. Cook 2012
program define vcf
    version 11.0
    syntax using/ 

/*

This is a program for importing VCF datasets into Stata.

It can take a very long time to import the data - (~ sometimes several minutes).
You may want to consider filtering with Tabix. The more RAM you have - the larger the VCF you should be able to import.


*** IMPORTANT ***
Currently, this program does not support VCF Files with greater than 9 Alternative Alleles.

*/

quietly {

// Find the first line (variable names)
tempname vfile
file open `vfile' using `"`using'"', read
file read `vfile' line



while r(eof)==0 {
local linenum = `linenum' + 1
file read `vfile' line
// Store vcf file parameters
if (regexm(`"`line'"',"^##.*")) {

	// Capture INFO Elements.
	if (substr(`"`line'"',1,6) == "##INFO") {
		break
		if (regexm(`"`line'"',"ID=([A-Za-z0-9_]*),")) {
		local next = regexs(1)
		local length_infos:length local infos
		// The fact that I have to do this is ridiculous. If someone knows of an easier way please tell me; Stata does not 
		// make working with lists/strings very easy....
		if (`length_infos'<220) {
		local infos = "`infos' `next'"
		} 
		else {
		local infos2 = "`infos2' `next'"
		}
		
		// Generate label descriptions
		local desc  = regexm(`"`line'"',`"Description=\"(.*)\">"') // I don't know why this works...

		local l`next' = regexs(1)

		}
	}
	
} 
else if (regexm(`"`line'"',"CHROM")) {
// Identify the line of variable names; 

		// Import Data
		insheet using `"`using'"', clear tab
		quietly drop in 1/`linenum'
		// Rename Variables
		foreach var of varlist * {
			local rename = `var'[1]
			di strtoname("`rename'")
			local rename = strtoname("`rename'")
			rename `var' `rename'
		}
		quietly drop in 1 // Drop Variable names
		
		// Rename _CHROM if it exists.
		capture confirm variable _CHROM, exact
		if !_rc {
			rename _CHROM CHROM
		}
		local header_lines = `linenum'
		di "There are `linenum' header lines."
		break
	
}

}

		// Compress
		foreach var of varlist * {
		destring `var', replace ignore("")
		}
		

		// Correctly pull out from INFO column:
		preserve
		
		drop * // Drop everything.
		insheet using `"`using'"', delimiter(";")
		
		quietly drop in 1/`header_lines' // Drop header lines.
		quietly drop in 1 // Drop extra header line.
	
		// Remove trailing beginning of first variable:
		qui ds
		loc firstvar: word 1 of `r(varlist)'
		replace `firstvar' = reverse(`firstvar')
		// Remove trailing endings for certain variables.
		foreach var of varlist * {
		replace `var' = substr(`var',1,strpos(`var',"`=char(9)'")) if strpos(`var',"`=char(9)'") > 0
		}
		pause
		replace `firstvar' = reverse(`firstvar')
		replace `firstvar' = subinstr(`firstvar',"`=char(9)'","",.)
		
		// The DB Variable does not make use of an equal sign. Must be generated.
		
		
		foreach info in `infos' `infos2' {
			quietly generate `info' = ""
			
			foreach var of varlist v* {
		
				quietly replace `info' = `var' if regexm(`var',"^`info'=")
				quietly replace `info' = subinstr(`info',"`info'=","",.)
				quietly replace `info' = `var' if `var' == "`info'"
				
				
					
		}
	
		}
		pause
		
		keep `infos' `infos2' // Keep newly generated variables.
		
		// Recapture the first variable again; will be used when formatting genotypic data.
		qui ds
		loc firstvar: word 1 of `r(varlist)'
		
		tempfile info_c // create a temporary file to store this data.
		
		// Greatly condense data:
		foreach var of varlist * {
		destring `var', replace ignore("")
		label variable `var' "`l`var''"
		}
		
		save `info_c'
		compress
		
		restore
		quietly merge 1:1 _n using `info_c' // Bring data back in
		
		drop _merge
		drop INFO
		quietly compress
		
	
		
	}
		
		// Recode Alleles
		split ALT, parse(",")
		foreach var of varlist FORMAT-`firstvar' {
		if ("`var'" != "FORMAT" && "`var'" != "`firstvar'") {
		// Allele 1
		generate `var'_a1 = REF if substr(`var',1,1) == "0"
		generate `var'_a2 = REF if substr(`var',1,1) == "0"
		
		
		local c = 1
		foreach alt of varlist ALT? {
			replace `var'_a1 = ALT`c' if substr(`var',1,1) == "`c'"
			local c = `c' + 1
		}
		
		local c = 1
		foreach alt of varlist ALT? {
			replace `var'_a2 = ALT`c' if substr(`var',3,1) == "`c'"
			local c = `c' + 1
		}
		

		}
		}
		
				



end
