/* 
SNP FETCH 
---------------------
	D. ELWOOD COOK
	Danielecook@gmail.com
	Elwoodcook.com
	Version 1.2
	
	// 1.2 -- Fixed bug which would prevent the use of string rs variables.
	
	Feb 15, 2012
*/
program define snpfetch
    version 12.0
    syntax varlist [, bundle(integer 20) assembly(string)]
	tempvar SNP id_list_distinct sort_preserve
	tempname  OPEN_FILE obs max id_list id_list_use distinct bundle_list parse_list record_check varuse
	tempfile txtfile
	
	set more off
	
	generate `sort_preserve' = _n

	// Set assembly here
	if "`assembly'"==""{
	local assembly = "GRCh37.p5"
	}
	
	/* Get SNP */
	local id_list: word 1 of `varlist'
	
	
	// Check to see if SNP is a number (with no rs) or not a number...with Rs prefix.
	capture confirm string variable `id_list'
	if !_rc {
		quietly generate `id_list_use' = subinstr(`id_list',"rs","",.)
		destring `id_list_use', replace force
		di "SNPs coded as a string variable, ignoring 'rs'"
	}
	else {
	 // Nothing is needed for string variables.
		quietly generate `id_list_use' = `id_list'
		di "numeric variable"
	}
	
	
	// Define Variables being Used - varuse.
	local varuse Gene_Name Gene_ID Chr_ID Pos_bp alleles  heterozygosity se_heterozygosity loc_type orient Species Validated min_prob max_prob
	// Generate Variables if need be.
	foreach varid in `varuse' {
	capture confirm variable `varid', exact
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
			
			
	
	
/* Get number of distinct values */
by `id_list_use', sort: generate `id_list_distinct' = _n if `id_list_use' != .
quietly count if `id_list_distinct' == 1 // Used to generate distinct count.
local distinct = `r(N)'

// Set obs
local obs = 0

/*  Sort Obs by distinct. */
sort `id_list_distinct' `id_list_use'
	
/* Generate Bundles*/
	quietly levelsof `id_list_use', local(parse_list)
	parse "`parse_list'", parse(" ")
	local bundle_list = ""
	local bundle_tally = 0
	forvalues j =  1/`distinct' {
		
		// Create the bundle.
		if "`bundle_list'" == "" {
		local bundle_list = "``j''" 
		}
		else {
		local bundle_list = "`bundle_list',``j''" 
		}
		
		local bundle_count = `bundle_count' + 1
		if `bundle_count' == `bundle' | `j' == `distinct' {
		local bundle_tally = `bundle_tally' + 1		
		
		/* Use bundle list to get infromation online. Custom Section */
		//
		//
		//
		//
		
		local copy_url "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=snp&id=`bundle_list'&rettype=flt&retmode=text"
		quietly copy "`copy_url'" "`txtfile'", replace
		file open `OPEN_FILE' using "`txtfile'", read
		file read `OPEN_FILE' line

		local line_count = 0
		 while r(eof)==0 {
		 local item = 0
		
			// For reading the first line.
		 	local line_count = `line_count' + 1
			if `line_count' == 1 {
			 
			local obs = `obs' + 1
			local item = regexm(`"`macval(line)'"',"rs([0-9]+) \| ([^\|]*) ")
			quietly replace Species = regexs(2) in `obs'
			}
			else if ("`line'" == "" | `line_count' == 1) & (`obs' != `distinct') & (`obs' != `bundle') & (`obs' != (`bundle'*`bundle_tally')) {
			
				file read `OPEN_FILE' line
				local obs = `obs' + 1

				local item = regexm(`"`macval(line)'"',"rs([0-9]+) \| ([^\|]*) ")
				quietly replace Species = regexs(2) in `obs'

				// local record_check = regexs(1)
				// quietly replace Species = regexs(2) in `obs'
				local current_record = `id_list_use'[`obs']
				}
		
			// Get SNP, Het, and SE Het
			local item = regexm(`"`macval(line)'"',"SNP.*alleles=([^\|]*) .*het=(0\.[0-9]*|0).*se\(het\)=(.*)")
			if `item' == 1 {
			quietly replace alleles = regexs(1) in `obs'
			quietly replace heterozygosity = regexs(2) in `obs'
			quietly replace se_heterozygosity = regexs(3) in `obs'
			}

			// Get Gene Name, Locus ID (gene name)
			local item = regexm(`"`macval(line)'"',"LOC \| (.*) \| locus_id=([0-9]*)")
			if `item' == 1 {
			quietly replace Gene_Name = regexs(1) in `obs'
			quietly replace Gene_ID = regexs(2) in `obs'
			}
			
			
			// Get Chr, Pos_bp, ctg_start, ctg_end, loctype
			local item = regexm(`"`macval(line)'"',"assembly=`assembly'.*chr=(.*) \|.*chr-pos=([0-9]*).*loctype=([0-9]*).*orient=(.*)")
			if `item' == 1 {
			quietly replace Chr_ID = regexs(1) in `obs'
			quietly replace Pos_bp = regexs(2) in `obs'
			quietly replace loc_type = regexs(3) in `obs'
			quietly replace orient = regexs(4) in `obs'
			}
			
			// Validated
			local item = regexm(`"`macval(line)'"',"VAL \| validated=(.*) \| min_prob=(.*) \| max_prob=(.*) \| (.*)")
			if `item' == 1 {
			quietly replace Validated = regexs(1) in `obs'
			quietly replace min_prob = regexs(2) in `obs'
			quietly replace max_prob = regexs(3) in `obs'
			}
			


		
		
		//
		//
		//
		//
		/* End of custom section.*/
		 
		 file read `OPEN_FILE' line
		 }
		 di "`obs'/`distinct'"
			
		file close `OPEN_FILE'
			
		
		
		/* Reset Bundle List */
		local bundle_list = ""
		local bundle_count = 0 // bundle count counts up to bundle number (default 25) and returns to 0, creating a new bundle.
		
		}		
	}
	
	// Convert to number some of the variables.
	foreach varid in heterozygosity se_heterozygosity loc_type Gene_ID Pos_bp min_prob max_prob {
	quietly destring `varid', replace force
	format %15.0g `varid'
	}

	// Convert Validated and Orient to variables with labels.
	quietly {
	replace orient = "1" if orient == "+"
	replace orient = "-1" if orient == "-"
	destring orient, replace
	label define orient_lbl 1 "+" -1 "-", modify
	label values orient orient_lbl
	replace Validated = "0" if Validated == "NO"
	replace Validated = "1" if Validated == "YES"
	destring Validated, replace
	label define Validated_lbl 0 "NO" 1 "YES", modify
	label values Validated Validated_lbl
	}

	// Convert the chromosome variable to a number with labels.
	quietly  replace Chr_ID = "23" if Chr_ID == "X"
	quietly  replace Chr_ID = "24" if Chr_ID == "Y"
	quietly  replace Chr_ID = "25" if Chr_ID == "MT"
	quietly destring Chr_ID, replace force
	label define Chr_ID_lbl 23 "X" 24 "Y" 25 "MT", modify
	label values Chr_ID Chr_ID_lbl
	

	// Deal with Duplicates
	sort `id_list_use' `id_list_distinct'
	quietly foreach var in `varuse' {
		   replace `var' = `var'[_n-1] if `id_list_use' == `id_list_use'[_n-1]  & !missing(`id_list_use')
	}
	

	
	sort `sort_preserve'

end
exit