/* 
PMID FETCH
---------------------
	D. ELWOOD COOK
	Danielecook@gmail.com
	Elwoodcook.com
	Version 1.2
	Feb 1, 2011
*/
program define pmidfetch
    version 12.0
    syntax varlist [, bundle(integer 20) mine ]
	tempvar pmid id_list_distinct sort_preserve
	tempname  OPEN_FILE obs max id_list distinct bundle_list parse_list record_check varuse MINE
	tempfile txtfile
	
	set more off
	
	generate `sort_preserve' = _n

	/* Get PMID */
	local id_list: word 1 of `varlist'
	
	/* Check to make sure PMID is numeric. If not, exit.*/
	capture confirm numeric variable `id_list', exact
	if _rc {
		di "`id_list' Must be numeric. Cannot Proceed."
		exit
	}
	
	// Drop Variables with multiple items - necessary to be properly created.
	quietly {
	foreach varid in Author Mesh_Terms {
		capture confirm variable `varid',exact
		if !_rc {
			drop `varid'
		}
	}
	}
	
	// Define Variables being Used - varuse.
	local varuse Title Date Volume Issue Page Abstract Affiliation Author Mesh_Terms SNP_List Locus_List
	// Generate Variables if need be.
	foreach varid in `varuse' {
	capture confirm variable `varid', exact
	if !_rc {
					capture confirm string variable `varid', exact
					if _rc {
						di "`varid' exists (number). Converting to String."
						tostring `varid', replace force
						}
						else {
						di "`varid' exists (string)"
						}
				   }
				   else {
					   di "`varid' Generated"
					   generate `varid' = ""
			}
		}
			
			
	
	
/* Get number of distinct values */
by `id_list', sort: generate `id_list_distinct' = _n if `id_list' != .
count if `id_list_distinct' == 1 // Used to generate distinct count.
local distinct = `r(N)'


// Set obs
local obs = 0

/*  Sort Obs by distinct. */
sort `id_list_distinct' `id_list'
	
/* Generate Bundles*/
	local bundle_list = ""

	forvalues j =  1/`distinct' {
	quietly levelsof `id_list', local(parse_list)
	parse "`parse_list'", parse(" ")

		
		// Create the bundle.
		if "`bundle_list'" == "" {
		local bundle_list = "``j''" 
		}
		else {
		local bundle_list = "`bundle_list',``j''" 
		}
		
		local bundle_count = `bundle_count' + 1
		if `bundle_count' == `bundle' | `j' == `distinct' {
				
		
		
		/* Use bundle list to get infromation online. Custom Section */
		//
		//
		//
		//
		
		local copy_url "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=`bundle_list'&retmode=text&rettype=medline"
		quietly copy "`copy_url'" "`txtfile'", replace
		file open `OPEN_FILE' using "`txtfile'", read
		file read `OPEN_FILE' line
		
		 while r(eof)==0 {
		 local item = 0
		 /* Adding to current count if item found */
                local item = regexm(`"`macval(line)'"',"PMID- (.*)")
				if `item' == 1 {
				local obs = `obs' + 1
                local record_check = regexs(1)
				local current_record = `id_list'[`obs']
				}
		 
		 /* Add to current count if item NOT found */
				local item = regexm(`"`macval(line)'"',"[0-9]*: id:(.*)")
				if `item' == 1 {
				// Go on to next observation if error received.
				local obs = `obs' + 1
				// Display Error
				di regexs(1)
				}
		
		/* Retrieve Single Line Items */
		local Volume = "VI  - (.*)"
		local Issue = "IP  - (.*)"
		local Date = "DP  - (.*)"
		local Page = "PG  - (.*)"
		
		foreach varid in Volume Issue Date Page {
			local item = regexm(`"`macval(line)'"',"``varid''")
			if `item' == 1 & "`record_check'" == "`current_record'"{
			quietly replace `varid' = regexs(1) in `obs'
			}
		}
		
		/* Retrieve  Multi-line Items */
		local Title = "TI  - (.*)"
		local Abstract = "AB  - (.*)"
		local Affiliation = "AD  - (.*)"
		
		foreach varid in Title Abstract Affiliation {
			local item = regexm(`"`macval(line)'"',"``varid''")
			if `item' == 1 & "`record_check'" == "`current_record'" {
			quietly replace `varid' = regexs(1) in `obs'
			
			

				
				// Check to see if next line has leading blanks (continued line).
					while `item' == 1 {
					file read `OPEN_FILE' line
					local item = regexm(`"`macval(line)'"',"      (.*)")
						if `item' == 1 & "`record_check'" == "`current_record'" {
							quietly replace `varid' = `varid' + regexs(1) in `obs'
							
							/* Build lines for MINING */
							local result = regexs(1)
							local buildline `buildline' `result'
							
						}
					}
			}
		}
		
		
		/* IF MINE IS ON, Pull out */
		if "`mine'" != "" & "`buildline'" != ""{
		
	
		// Mining the Title
		tokenize "`buildline'"
		
		local j = 1
		
		while "``j''" != "" {
			
			// Pull Out SNPs
			if regexm("``j''","(rs[0-9]+)") == 1 {
			quietly replace SNP_List =  SNP_List + " " + regexs(1) in `obs'
			}
			
			// Pull out Genes
			if regexm("``j''","([A-Z][0-9A-Za-z]+)") == 18 {
			di regexs(1)
			}
			
			// Get Locus
			if regexm("``j''","([0-9]+[pq][0-9]+\.*[0-9]*)") == 1 {
			quietly replace Locus_List =  Locus_List + " " + regexs(1) in `obs'
			}
			
			local j = `j' + 1
			} // Closes WHILE j loop
			
		}
		
		// Clean Lists
		local SNP_List = ""
		local Locus_List = ""
		local buildline = ""
		
		/* Retrieve  Multiples */
		local Author = "FAU - (.*)"
		local Mesh_Terms = "MH  - (.*)"
		
		foreach varid in Author Mesh_Terms {
			local item = regexm(`"`macval(line)'"',"``varid''")
			if `item' == 1 & "`record_check'" == "`current_record'" {
			quietly replace `varid' = `varid' + " | " + regexs(1) in `obs'
				}	 
			local item = 0
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
	
	// Cleanup multiple fields with leading items
	foreach varid in Author Mesh_Terms{
			quietly replace `varid' = substr(`varid',4,length(`varid'))
			}
			
	// Shorten some of the variables.
	foreach varid in Title Affiliation Author Abstract Mesh_Terms{
	format %10s `varid'
	}
	
	// Deal with Duplicates
	sort `id_list' `id_list_distinct'
	// Thank you nick cox!
	quietly foreach var in `varuse' {
		   replace `var' = `var'[_n-1] if `id_list' == `id_list'[_n-1] & !missing(`id_list')
	}

	
	sort `sort_preserve'

	


end
exit