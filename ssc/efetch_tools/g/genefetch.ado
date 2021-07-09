/* 
GENE FETCH 
---------------------
	D. ELWOOD COOK
	Danielecook@gmail.com
	Elwoodcook.com
	Version 1.2
	Feb 15, 2011
	
	// Feb 15, 2012 - 1.2 - Updated to fix changes made to efetch tools by NCBI. Added whitespace trim to location variable.
*/
program define genefetch
    version 12.0
    syntax varlist [, bundle(integer 20) assembly(string) organism(string)]
	tempvar id_list_distinct sort_preserve
	tempname  OPEN_FILE obs max id_list id_list_use distinct bundle_list parse_list record_check varuse wordcount
	tempfile txtfile
	
	set more off

	generate `sort_preserve' = _n
	
	/* Get GENES */
	local id_list: word 1 of `varlist'
	
	/* Get Gene Names if User provides a list of genes */
	capture confirm string variable `id_list', exact
	if !_rc {
	getgeneids `id_list', organism(`organism')
	local id_list Gene_ID
	}
	

	// Define Variables being Used - varuse.
	local varuse Gene_Name Full_Name Species Location From To Chr_ID 
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
by `id_list', sort: generate `id_list_distinct' = _n if `id_list' != .
quietly count if `id_list_distinct' == 1 // Used to generate distinct count.
local distinct = `r(N)'

// Set obs
local obs = 0

/*  Sort Obs by distinct. */
sort `id_list_distinct' `id_list'
	
/* Generate Bundles*/
	quietly levelsof `id_list', local(parse_list)
	local bundle_list = ""
	forvalues j =  1/`distinct' {
	
		// Create the bundle.
		if "`bundle_list'" == "" {
		parse "`parse_list'", parse(" ")
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
		
		local copy_url "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?&db=gene&id=`bundle_list'&retmode=text"
		quietly copy "`copy_url'" "`txtfile'", replace
		file open `OPEN_FILE' using "`txtfile'", read
		file read `OPEN_FILE' line

		 while r(eof)==0 {
		 // Reset item.
		 local item = 0
		 		 
		 /* Adding to current count if item found  ==> This section is used to build up each record which will be parsed.*/
			
					if regexm(`"`macval(line)'"',"[0-9]+\. (.*)") == 1  | (regexm(`"`macval(line)'"',"\</html\>") == 1 & `obs' == `distinct') {
						/* Parse Build Lines -- Get Data*/

							// Tokenize the string (split it up, to pull out the Location and other information.
							local builduse = wordcount("`buildline'")
							
							tokenize "`buildline'", parse(":")
							foreach word of numlist 1(1)`builduse' {
								// Get Gene_Name
								if regexm("``word''","(.*) and Name") == 1 {
								quietly replace Gene_Name = regexs(1) in `obs'
								}
								// Get Full_Name and species
								if regexm("``word''","(.*)\[(.*)\]") == 1 {
								quietly replace Full_Name = regexs(1) in `obs'
								quietly replace Species = regexs(2) in `obs'
								}
								// Get Chromosome
								if regexm("``word''","(.*); Location") == 1 {
								quietly replace Chr_ID = regexs(1) in `obs'
								}
								// Get Location
								if regexm("``word''","(.*)Annotation") == 1 {
								quietly replace Location = trim(regexs(1)) in `obs'
								}
								// Get Positions
								if regexm("``word''","\(([0-9]*)\.\.([0-9]*)") == 1 {
								quietly replace From = regexs(1) in `obs'
								quietly replace To = regexs(2) in `obs'
								}
				
							}
													
						/* ---END Parse Build Lines*/
						
					// Reset built lines.
					local buildline = ""
					// Add one to obs number.
					local obs = `obs' + 1
					// Gene Name
					// quietly replace Gene_Name = regexs(1) in `obs'
					// Read to next line.
					file read `OPEN_FILE' line
					}
					else if regexm(`"`macval(line)'"',"Error") == 1 {
					
					// Display Error
					di "`line'"
					// Go on to next observation if error received.
					local obs = `obs' + 1
					file read `OPEN_FILE' line
					}
					/* This part is used to add a line to each record */
					else {
					// Build up record into lines for parsing.
					local buildline "`buildline' `line'"
					// local record_check = regexs(1)
					local current_record = `id_list'[`obs']
					file read `OPEN_FILE' line
					}
				
		//
		//
		//
		//
		/* End of custom section.*/
		 
		 
		 }
		 /* Display Progress */
		 if `obs' > `distinct' {
		 di "`distinct'/`distinct'"
		 }
		 else {
		 di "`obs'/`distinct'"
		 }
			
		file close `OPEN_FILE'
			
		/* Reset Bundle List */
		local bundle_list = ""
		local bundle_count = 0 // bundle count counts up to bundle number (default 25) and returns to 0, creating a new bundle.
		
		}		
	}
	
	// Convert to number some of the variables.
	foreach varid in From To {
	quietly destring `varid', replace force
	format %15.0g `varid'
	}


	// Convert the chromosome variable to a number with labels.
	quietly  replace Chr_ID = "23" if Chr_ID == "X"
	quietly  replace Chr_ID = "24" if Chr_ID == "Y"
	quietly  replace Chr_ID = "25" if Chr_ID == "MT"
	quietly destring Chr_ID, replace force
	label define Chr_ID_lbl 23 "X" 24 "Y" 25 "MT", modify
	label values Chr_ID Chr_ID_lbl
	
	// Shorten some of the variables.
	foreach varid in Full_Name {
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