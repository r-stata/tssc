/*  Program to extract code lists from CPRD by Evangelos Kontopantelis
    v1.0, 5 June 2015
        - test codes are only a handful and can be added manually, focusing on Read/OXMIS code and product code searches
		- sheet names are irrelevant, the first sheet in excel is aways imported for the search info
		- variable names are irrelevant (always need to be provided) in excel/csv but the order is important: Description name stubs for Read/OXMIS; Read/OXMIS codes; Product name stubs
		- when opening csv files, do not double-click to open in excel because codes will not be imported as string and for example 2326.00 would be imported as 2326
		- PCD code and product files can be Stata or text files
		- Rules:
			- words, as standard: "angin" will return all cases that include the stub
			- phrases with underscore: "ischemic_cardiomyopathy" will search for "ischemic cardiomyopathy"
			- combinations plus sign: "alcohol+depend" will search for "alcohol" AND "depend" anywhere within a specific field
			- minus sign at start of word/stub: cases with word/stub to be excluded e.g. "splen" "-hypersplenism" will return cases with "splen" but not any with "hypersplenism" (does not work for combinations)
			- all words/stubs as lowercase: capitals do not matter since the respective fields in the lookup files are turned to lowercase
			- if words/stubs as capitals: will only be searched as capitals to avoid many false positives (e.g. UTI).
			- codes are searched for exactly as inputed but at the start of the respective field. Hence search for "H33" would return H331.11 (Late onset asthma) but not 8H33.00 (Day hospital care)
	v1.1, 13 June 2019
		- updated to make compatible with Aurum. will automatically rename variables to the GOLD format
*/
program pcdsearch
	//Stata version
    version 13.1
	tempfile tempf tempx1 tempx2
    /*command syntax*/
    syntax anything, [pcddir(string) filedir(string) pcdcodefnm(string) pcdprodfnm(string)]
	//identify if excel or csv file
	local outfnm = word("`anything'",1)
	if strpos("`outfnm'",".csv")==strlen("`outfnm'")-3 {
		local filetp=0
		local stbnm=substr("`outfnm'",1,`=strlen("`outfnm'")-4')
	}
	else if strpos("`outfnm'",".xls")>0  {
		local filetp=1
        if strpos("`outfnm'",".xlsx")>0 {
        	local stbnm=subinstr("`outfnm'",".xlsx","",.)
        }
        else {
        	local stbnm=subinstr("`outfnm'",".xls","",.)
        }
	}
	else {
        di as error "Provide the full name of an excel or csv file, including the extension"
        error 197	
	}
	//verify PCD directory	
    if "`pcddir'"!="" {
        capture cd "`pcddir'"
        if _rc!=0 {
            di as error "Specified pcddir (PCD directory) does not exist"
            error 197
        }
		//do not need both
		capture confirm existence $pcdsourcepath
		if _rc==0 {
			di as error "Both global macro pcdsourcepath and command option pcddir (PCD directory) are used"
			di as error "Please only use one of them"
			error 197
		}			
		local srcdirx "`pcddir'"
	}
	else {
		capture confirm existence $pcdsourcepath
		if _rc!=0 {
			di as error "Global macro pcdsourcepath or command option pcddir (PCD directory) have not been defined"
			di as error "Define pcdsourcepath either in profile.do or before calling pcdsearch, or use the pcddir option"
			error 197
		}	
		local srcdirx "$pcdsourcepath"
	}
	//verify output directory	
    if "`filedir'"!="" {
        capture cd "`filedir'"
        if _rc!=0 {
            di as error "Specified filedir (output directory) does not exist"
            error 197
        }
		//do not need both
		capture confirm existence $pcdoutputpath
		if _rc==0 {
			di as error "Both global macro pcdoutputpath and command option filedir (output directory) are used"
			di as error "Please only use one of them"
			error 197
		}			
		local outdirx "`filedir'"
	}
	else {
		capture confirm existence $pcdoutputpath
		if _rc!=0 {
			di as error "Global macro pcdoutputpath or command option filedir (output directory) have not been defined"
			di as error "Define pcdoutputpath either in profile.do or before calling pcdsearch, or use the filedir option"
			error 197
		}	
		local outdirx "$pcdoutputpath"
	}
	//verify the Read/OXMIS code file
	 if "`pcdcodefnm'"!="" {
		capture confirm file "`pcddir'/`pcdcodefnm'"
        if _rc!=0 {
            di as error "Specified pcdcodefnm (PCD code file) does not exist"
            error 601
        }
		//do not need both
		capture confirm existence $pcdcodefilenm
		if _rc==0 {
			di as error "Both global macro pcdcodefilenm and command option pcdcodefnm (PCD code file) are used"
			di as error "Please only use one of them"
			error 197
		}	
		local codefilex "`pcdcodefnm'"
	 }
	else {
		capture confirm existence $pcdcodefilenm
		if _rc!=0 {
			di as error "Global macro pcdcodefilenm or command option pcdcodefnm (PCD code file) have not been defined"
			di as error "Define pcdcodefilenm either in profile.do or before calling pcdsearch, or use the pcdcodefnm option"
			error 197
		}	
		local codefilex "$pcdcodefilenm"
	}
	//verify the Product code file
	 if "`pcdprodfnm'"!="" {
		capture confirm file "`pcddir'/`pcdprodfnm'"
        if _rc!=0 {
            di as error "Specified pcdprodfnm (PCD product/drug file) does not exist"
            error 601
        }
		//do not need both
		capture confirm existence $pcdprodfilenm
		if _rc==0 {
			di as error "Both global macro pcdprodfilenm and command option pcdprodfnm (PCD product/drug file) are used"
			di as error "Please only use one of them"
			error 197
		}	
		local prodfilex "`pcdprodfnm'"
	 }
	else {
		capture confirm existence $pcdprodfilenm
		if _rc!=0 {
			di as error "Global macro pcdprodfilenm or command option pcdprodfnm (PCD product/drug file) have not been defined"
			di as error "Define pcdprodfilenm either in profile.do or before calling pcdsearch, or use the pcdprodfnm option"
			error 197
		}
		local prodfilex "$pcdprodfilenm"
	}
	//confirm existence of search info file
	capture confirm file "`outdirx'/`outfnm'"
	if _rc!=0 {
		di as error "Search info file `outfnm' not found in `outdirx'"
		error 601
	}

	//display directories and files
	di _newline(1) as text "Search info file:" _col(25) as result "`outfnm'"
	di as text "Output directory:" _col(25) as result "`outdirx'"
	di as text "Read/OXMIS code file:" _col(25) as result "`srcdirx'/`codefilex'"
	di as text "Products(drugs) file:" _col(25) as result "`srcdirx'/`prodfilex'"

	preserve
	//open input excel/csv file
	if `filetp'==0 {
		qui import delimited "`outdirx'/`outfnm'", varnames(1) clear
	}
	else {
		qui import excel "`outdirx'/`outfnm'", firstrow allstring clear
	}
	//get info from variables
	qui ds
	local varname1 = word("`r(varlist)'",1)
	local varname2 = word("`r(varlist)'",2)
	local varname3 = word("`r(varlist)'",3)
	rename `varname1' xvar1
	rename `varname2' xvar2
	rename `varname3' xvar3
	qui save `tempf', replace
	local xdict1=""	/*odict*/
	local xdict2=""	/*coddic*/
	local xdict3=""	/*ddict*/
	forvalues i=1(1)3 {
		qui use `tempf', clear
		qui keep xvar`i'
		qui keep if xvar`i'!=""
		qui count
		forvalues j=1(1)`=r(N)' {
			local temp = trim(xvar`i'[`j'])
			local xdict`i' = "`xdict`i'' `temp'"
			//make sure no spaces included
            if strpos("`temp'"," ")>0 {
                di as error "Please do not include blank spaces in the stubs or codes - see the documentation as to how to search for phrases"
			    error 197
            }
		}
	}
	//debug
	//di "`xdict1'"
	//di "`xdict2'"
	//di "`xdict3'"	

    /*GET STRING DICTIONARIES into manageable local strings*/
    /*first for DIAGNOSES search terms - odict/xdict1*/
    local wrdcnt1 = 0
	local wordnum = wordcount("`xdict1'")
	forvalues i=1(1)`wordnum' {
		local wrdcnt1 = `wrdcnt1' + 1
		local sword1`wrdcnt1' = word("`xdict1'",`i')
		/*default number of bits in search term is 1 (1 word phrase)*/
		local bitcnt1`wrdcnt1' = 1
		/*remove underscores*/
		if strpos("`sword1`wrdcnt1''","_")>0 {
			local sword1`wrdcnt1' = subinstr("`sword1`wrdcnt1''","_"," ",.)
		}
		/*if string has one more "+" signs then break down to bits and search for all of those later*/
		if strpos("`sword1`wrdcnt1''","+")> 0 {
			local tmpstr = "`sword1`wrdcnt1''"
			local tmppos =  strpos("`tmpstr'","+")
			local cntr = 0
			while `tmppos'>0 {
				local cntr = `cntr' + 1
				local swordx1`wrdcnt1'_`cntr' = substr("`tmpstr'",1,`tmppos'-1)
				local tmpstr = substr("`tmpstr'",`tmppos'+1,.)
				local tmppos =  strpos("`tmpstr'","+")
			}
			local cntr = `cntr' + 1
			local swordx1`wrdcnt1'_`cntr' = "`tmpstr'"
			local bitcnt1`wrdcnt1' = `cntr'
		}
    }
    /*second for DRUG search terms - ddict/xdict3*/
    local wrdcnt2 = 0
	local wordnum = wordcount("`xdict3'")
	forvalues i=1(1)`wordnum' {
		local wrdcnt2 = `wrdcnt2' + 1
		local sword2`wrdcnt2' = word("`xdict3'",`i')
		/*default number of bits in search term is 1 (1 word phrase)*/
		local bitcnt2`wrdcnt2' = 1
		/*remove underscores*/
		if strpos("`sword2`wrdcnt2''","_")>0 {
			local sword2`wrdcnt2' = subinstr("`sword2`wrdcnt2''","_"," ",.)
		}
		/*if string has one more "+" signs then break down to bits and search for all of those later*/
		if strpos("`sword2`wrdcnt2''","+")> 0 {
			local tmpstr = "`sword2`wrdcnt2''"
			local tmppos =  strpos("`tmpstr'","+")
			local cntr = 0
			while `tmppos'>0 {
				local cntr = `cntr' + 1
				local swordx2`wrdcnt2'_`cntr' = substr("`tmpstr'",1,`tmppos'-1)
				local tmpstr = substr("`tmpstr'",`tmppos'+1,.)
				local tmppos =  strpos("`tmpstr'","+")
			}
			local cntr = `cntr' + 1
			local swordx2`wrdcnt2'_`cntr' = "`tmpstr'"
			local bitcnt2`wrdcnt2' = `cntr'
		}
    }
    /*third get CODE dictionaries into manageable local strings*/
	local codenum = wordcount("`xdict2'")
	local coddcnt=0
	forvalues i=1(1)`codenum' {
		local coddcnt = `coddcnt' + 1
		local code`coddcnt' = word("`xdict2'",`i')
	}

	//open CPRD medical codes file and identify variables needed
	if strpos("`codefilex'",".dta")>0  {
    	qui use "`srcdirx'/`codefilex'",clear
 	}
	else {
    	qui import delimited "`srcdirx'/`codefilex'",clear
	}
	local mlouttp=0
	capture confirm variable medcode readcode desc
	if _rc==0 {
		local mlouttp=1
	}
	capture confirm variable gprd_medical_code read_oxmis_code read_oxmis_name
	if _rc==0 {
		local mlouttp=2
		rename gprd_medical_code medcode
		rename read_oxmis_code readcode
		rename read_oxmis_name desc
	}
	capture confirm variable medcodeid originalreadcode term
	if _rc==0 {
		local mlouttp=3
		rename medcodeid medcode
		rename originalreadcode readcode
		rename term desc
	}	
	if `mlouttp'==0 {
		di as error "Layout in medical codes file not recognised"
		di as error "Rename to medcode readcode desc for CPRD medical code, Read codes and description respectively"
		error 197	
	}
	qui save `tempx1', replace
	
	//open CPRD product codes file and identify variables needed
	if strpos("`prodfilex'",".dta")>0  {
    	qui use "`srcdirx'/`prodfilex'",clear
 	}
	else {
    	qui import delimited "`srcdirx'/`prodfilex'",clear
	}
	local plouttp=0
	capture confirm variable prodcode productname bnfchapter drugsubstance
	if _rc==0 {
		local plouttp=1
	}
	capture confirm variable gpprodcode mx_product_name mx_bnf_header mx_drug_substance_name
	if _rc==0 {
		local plouttp=2
		rename gpprodcode prodcode
		rename mx_product_name productname
		rename mx_bnf_header bnfchapter
		rename mx_drug_substance_name drugsubstance
	}
	capture confirm variable prodcodeid productname termfromemis drugsubstancename
	if _rc==0 {
		local plouttp=3
		rename prodcodeid prodcode
		rename bnfchapter bnfchapter_temp
		rename termfromemis bnfchapter
		rename drugsubstancename drugsubstance
	}	
	if `plouttp'==0 {
		di as error "Layout in product codes file not recognised"
		di as error "Rename to prodcode productname bnfchapter drugsubstance for CPRD prod code, prod name, bnf chapter name and drug substance name"
		error 197	
	}		
	qui save `tempx2', replace

    /*READ file search with strings and/or codes*/
    if `wrdcnt1'>0 | `coddcnt'>0 {
        /*string search*/
        qui use `tempx1',clear
        qui qui gen tempinfo = .
        forvalues i=1(1)`wrdcnt1' {
            /*if word string has been broken to various bits search for all of them*/
            if `bitcnt1`i'' > 1 {
                /*create the string that will be used in the replace command*/
                if upper("`swordx1`i'_1'")== "`swordx1`i'_1'" {
                    local tmpstr=`" if strpos(desc,"`swordx1`i'_1'")>0"'
                }
                else {
                    local tmpstr=`" if strpos(lower(desc),"`swordx1`i'_1'")>0"'
                }
                forvalues j=2(1)`bitcnt1`i'' {
                    if upper("`swordx1`i'_`j'")== "`swordx1`i'_`j'" {
                        local tmpstr=`"`tmpstr' & strpos(desc,"`swordx1`i'_`j''")>0"'
                    }
                    else {
                        local tmpstr=`"`tmpstr' & strpos(lower(desc),"`swordx1`i'_`j''")>0"'
                    }
                }
                qui replace tempinfo=1 `tmpstr'
            }
            else {
                /*if search term is uppercase DON'T transform searched variable to lowercase*/
                if upper("`sword1`i''") == "`sword1`i''" {
                    qui replace tempinfo=1 if strpos(desc,"`sword1`i''")>0
                }
                else {
                    qui replace tempinfo=1 if strpos(lower(desc),"`sword1`i''")>0
                }
            }
        }
        /*code search*/
        forvalues i=1(1)`coddcnt' {
            qui replace tempinfo=1 if strpos(readcode,"`code`i''")==1
        }
		*set trace on
		*set tracedepth 1
        /*remove cases with words that should be excluded (doensn't work for combinations just words and phrases)*/
        forvalues i=1(1)`wrdcnt1' {
            if strpos("`sword1`i''","-")==1 {
                local tstr = substr("`sword1`i''",2,.)
                /*if search term is uppercase DON'T transform searched variable to lowercase*/
                if upper("`tstr'") == "`tstr'" {
                    qui replace tempinfo=0 if strpos(desc,"`tstr'")>0
                }
                else {
					local tstr=lower("`tstr'")
                    qui replace tempinfo=0 if strpos(lower(desc),"`tstr'")>0
                }
            }
        }
		*set trace off
		*error
        qui keep if tempinfo==1
        qui drop tempinfo
		qui order medcode* read* desc*
        //OUTPUT
        di
        qui count
        if r(N)>0 {
  		    //excel
  		    if `filetp'==1 {
          	    export excel using "`outdirx'/`outfnm'", sheetreplace sheet("pcdsearch_med") firstrow(variables)
    		}
    		//csv
    		else if `filetp'==0 {
                outsheet using "`outdirx'/`stbnm'_pcdsearch_med.csv", replace comma
  		    }
  		}
  		else {
            di as result "no codes identified, nothing exported"  
        }
    }

    /*DRUGS file search using strings*/
    if `wrdcnt2'>0 {
        qui use `tempx2',clear
        qui gen tempinfo = .
        forvalues i=1(1)`wrdcnt2' {
            /*if word string has been broken to various bits search for all of them*/
            if `bitcnt2`i'' > 1 {
                /*create the strings that will be used in the replace command*/
                /*first bit of the word*/
                if upper("`swordx2`i'_1'")== "`swordx2`i'_1'" {
                    local cntr = 0
                    foreach x in "productname" "bnfchapter" "drugsubstance" {
                        local cntr = `cntr' + 1
                        forvalues j=1(1)2 {
                            if `j'==1 {
                                local tmpstr`cntr'_`j' = `" if strpos(`x',"`swordx2`i'_1'")==1"'
                            }
                            else {
                                local tmpstr`cntr'_`j' = `" if strpos(`x'," `swordx2`i'_1'")>0"'
                            }
                        }
                    }
                }
                else {
                    local cntr = 0
                    foreach x in "productname" "bnfchapter" "drugsubstance" {
                        local cntr = `cntr' + 1
                        forvalues j=1(1)2 {
                            if `j'==1 {
                                local tmpstr`cntr'_`j' = `" if strpos(lower(`x'),"`swordx2`i'_1'")==1"'
                            }
                            else {
                                local tmpstr`cntr'_`j' = `" if strpos(lower(`x')," `swordx2`i'_1'")>0"'
                            }
                        }
                    }
                }
                /*go through the remaining bits of the word*/
                forvalues j=2(1)`bitcnt2`i'' {
                    if upper("`swordx2`i'_`j'")== "`swordx2`i'_`j'" {
                        local cntr = 0
                        foreach x in "productname" "bnfchapter" "drugsubstance" {
                            local cntr = `cntr' + 1
                            forvalues l=1(1)2 {
                                if `l'==1 {
                                    local tmpstr`cntr'_1 = `"`tmpstr`cntr'_1' & strpos(`x',"`swordx2`i'_`j''")==1"'
                                }
                                else {
                                    local tmpstr`cntr'_2 = `"`tmpstr`cntr'_2' & strpos(`x'," `swordx2`i'_`j''")>0"'
                                }
                            }
                        }
                    }
                    else {
                        local cntr = 0
                        foreach x in "productname" "bnfchapter" "drugsubstance" {
                            local cntr = `cntr' + 1
                            forvalues l=1(1)2 {
                                if `l'==1 {
                                    local tmpstr`cntr'_1 = `"`tmpstr`cntr'_1' & strpos(lower(`x'),"`swordx2`i'_`j''")==1"'
                                }
                                else {
                                    local tmpstr`cntr'_2 = `"`tmpstr`cntr'_2' & strpos(lower(`x')," `swordx2`i'_`j''")>0"'
                                }
                            }
                        }
                    }
                }
                forvalues j=1(1)`cntr' {
                    qui replace tempinfo=1 `tmpstr`j'_1'
                    qui replace tempinfo=1 `tmpstr`j'_2'
                }
            }
            else {
                /*if search term is uppercase DON'T transform searched variable to lowercase*/
                if upper("`sword2`i''") == "`sword2`i''" {
                    qui replace tempinfo = 1 if strpos(productname,"`sword2`i''")==1 | strpos(bnfchapter,"`sword2`i''")==1 | /*
                    */ strpos(drugsubstance,"`sword2`i''")==1 
                    qui replace tempinfo = 1 if strpos(productname," `sword2`i''")>0 | strpos(bnfchapter," `sword2`i''")>0 | /*
                    */ strpos(drugsubstance," `sword2`i''")>0 
                }
                else {
                    qui replace tempinfo = 1 if strpos(lower(productname),"`sword2`i''")==1 | strpos(lower(bnfchapter),"`sword2`i''")==1 | /*
                    */ strpos(lower(drugsubstance),"`sword2`i''")==1
                    qui replace tempinfo = 1 if strpos(lower(productname)," `sword2`i''")>0 | strpos(lower(bnfchapter)," `sword2`i''")>0 | /*
                    */ strpos(lower(drugsubstance)," `sword2`i''")>0 
                }
            }
        }
		*set trace on
		*set tracedepth 1
        /*remove cases with words that should be excluded (doensn't work for combinations just words and phrases)*/
        forvalues i=1(1)`wrdcnt2' {
            if strpos("`sword2`i''","-")==1 {
                local tstr = substr("`sword2`i''",2,.)
                /*if search term is uppercase DON'T transform searched variable to lowercase*/
                if upper("`tstr'") == "`tstr'" {
                    qui replace tempinfo=0 if strpos(productname,"`tstr'")>0
					qui replace tempinfo=0 if strpos(drugsubstance,"`tstr'")>0
                }
                else {
					local tstr=lower("`tstr'")
                    qui replace tempinfo=0 if strpos(lower(productname),"`tstr'")>0
					qui replace tempinfo=0 if strpos(lower(drugsubstance),"`tstr'")>0
                }
            }
        }
		*set trace off
		*error
        qui keep if tempinfo==1
        qui drop tempinfo
        qui capture duplicates drop prodcode, force
		//rename back for products and Aurum
		if `plouttp'==3 {
			rename bnfchapter termfromemis
			rename bnfchapter_temp bnfchapter
		}
		qui order prodcode* productname*
    	//OUTPUT
		//excel
		if `filetp'==1 {
        	export excel using "`outdirx'/`outfnm'", sheetreplace sheet("pcdsearch_prod") firstrow(variables)
  		}
  		//csv
  		else if `filetp'==0 {
            outsheet using "`outdirx'/`stbnm'_pcdsearch_prod.csv", replace comma
		}
    }
	restore
end
