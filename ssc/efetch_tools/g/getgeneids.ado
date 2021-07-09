/* 
Get Gene ID's
---------------------
	D. ELWOOD COOK
	Danielecook@gmail.com
	Elwoodcook.com
	Version 1.0
	
	Intended as part of the genefetch program.
*/
program define getgeneids
    version 12.0
    syntax varlist [, organism(string)]
	tempvar genes_distinct
	tempname distinct OPEN_FILE
	tempfile txtfile
	
	di "It looks like you've provided a list of genes. Retrieving Gene IDs."
	

	// Generate Variables if need be.
	foreach varid in Gene_ID {
	capture confirm variable Gene_ID, exact
	if !_rc {
					capture confirm string variable `varid', exact
					if _rc {
						di "`varid' exists (number). Converting to String."
						quietly tostring `varid', replace force
						}
						else {
						di "`varid' exists (string)"
						}
				   }
				   else {
					   di "`varid' Generated"
					   quietly generate `varid' = ""
			}
		}
			
	
	// Get organism and replace if necessary.
	if "`organism'" == "" {
	local display_organism = "Homo Sapiens"
	local organism = "Homo%20Sapiens"
	}
	else {
	local display_organism = "`organism'"
	local organism = subinstr("`organism'"," ","%20",.)
	}
	
	local genes: word 1 of `varlist'
	
	by `genes', sort: generate `genes_distinct' = _n
	quietly count if `genes_distinct' == 1
	sort `genes_distinct' `genes'
	local distinct = `r(N)'
	
	di ""
	di "Progress" _col(20) "Gene Name" _col(40) "Gene ID" _col(60) "Species"
	forvalues obs = 1/`distinct' {
	local current_gene = `genes'[`obs']

	local copy_url "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=gene&retstart=0&retmax=1&term=`current_gene'%5BUni%5D%20`organism'%5BOrganism%5D"
	quietly copy "`copy_url'" "`txtfile'", replace
	file open `OPEN_FILE' using "`txtfile'", read
	file read `OPEN_FILE' line
			while r(eof)==0 {
				// Get Gene ID
				if regexm(`"`macval(line)'"',"<Id>(.*)</Id>") == 1 {
					quietly replace Gene_ID = regexs(1) in `obs'	
					di "`obs'/`distinct'" _col(20) "`current_gene'" _col(40) regexs(1) _col(60) "`display_organism'"
					}						
				file read `OPEN_FILE' line
			}
	file close `OPEN_FILE'
	}
	
		// Deal with Duplicates
	sort `genes' `genes_distinct'
	local max = _N
	forvalues obs = 1/`max' {
		foreach var in Gene_ID {
		if `genes'[`obs'] == `genes'[`obs'-1] & `genes'[`obs'] != "" {
		quietly replace `var' = `var'[`obs'-1] in `obs'
		}
	}
	}
	
//
destring Gene_ID, replace
	
	
	
end
exit