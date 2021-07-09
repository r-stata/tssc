// md2ddi2_5.ado
// Transform Meta Data to DDI 2.5
// Florian Thirolf
// 2019-07-09
// version 1.0.4
// CC BY-NC-SA 4.0

// Change log
// v1: 2019-07-08: Transform do-file to ado
//                 Input control
// v2: 2019-07-09: Continue Input control
// v3: 2019-07-09: input control done
// v4: 2019-10-10: Set minimal version to 10.0

// Draft of program:
//	** LOGISTICS
//	*  open metadata file
//	*  count number of cases
//	*  Check if there are attached variables in the file (variable mother exists and mother has at least one value !='')
//	*  Start writing Output-File
//
//	*  if so, generate variable to identify group specific variables referring to the same mother	(motherGroupCountry)
//	*  replace motherGroupCountry = "Grp-" + mother +"-"+ country if first == 1 and mother!=''
//
//	** OUTPUT
//	*  OPTIONAL: if attachted variables exist varGroups-area is printed:
//	   * drop irrelevant lines (first != 1 and mother=='')
//	   * generate variable to identify country specific variables referring to the same mother
//	   * forvalues over all remaining categories
//	   * Loop over motherGroupCountry to define varGroups for countries on the highest level
//	*  write var for every variable of every group
//     * forvalues over all categories
//     * output on variable level is limited to first category of variable (first==1)
//     * output on categoy level (for discrete variable) is written for all categories 
//	*  write notes (2nd note is only printed if attached variables exist)
//	*  write end of frame for DDI2.5 xml-file
//
//	** LOGISTICS
//	*  Closing the Log-Files

//******************************************************************************
program define md2ddi2_5, nclass
  version 10.0
  syntax, INput(string) OUTput(string) [RELATion REPLace]

  // Input Control
  // INPUT?
  if `"`input'"'!="" {
    // Check input file option
    capture confirm file `"`input'"'
	if _rc!=0 {
	  noisily di as error `"input file `input' not found"'
	  quietly exit
	}
	if _rc==0 {
	  // integrity of data?
	  quietly use in 1 using `"`input'"', clear
	  // all necessary variables in data
	  if "`relation'"!="" {
	    capture confirm variable group computed varName mother variableLabel total_n total_missing min max Mean StandardDeviation value valueLabel n percent validPercent isValid first, exact
	  }
	  if "`relation'"=="" {
	    capture confirm variable group computed varName variableLabel total_n total_missing min max Mean StandardDeviation value valueLabel n percent validPercent isValid first, exact
	  }
	  if _rc!=0 {
	    noisily di as error "Not all necessary variables included in meta data file"
	    if "`relation'"!="" {
	      noisily di as error "Mandatory list of variables: group computed varName mother variableLabel" 
		  noisily di as error "total_n total_missing min max Mean StandardDeviation value valueLabel"
		  noisily di as error "n percent validPercent isValid first"
		  noisily di ""
		  noisily di as error "Because you specified relation option, mother variable is necessary"
		  quietly exit
	    }
	    if "`relation'"=="" {
	      noisily di as error "Mandatory list of variables: group computed varName variableLabel" 
		  noisily di as error "total_n total_missing min max Mean StandardDeviation value valueLabel"
		  noisily di as error "n percent validPercent isValid first"
		  quietly exit
	    }
	  }
	  // unnecessary variables in data
	  if "`relation'"!="" {
	    quietly ds group computed varName mother variableLabel total_n total_missing min max Mean StandardDeviation value valueLabel n percent validPercent isValid first, not
      }
	  if "`relation'"=="" {
	    quietly ds group computed varName variableLabel total_n total_missing min max Mean StandardDeviation value valueLabel n percent validPercent isValid first, not
      }
	  if `"`r(varlist)'"'!="" {
	    noisily di as error "Warning: Additional unnecessary variables in data file" 
	    noisily di as error `"`r(varlist)'"'
	  }
	}
  }
  // OUTPUT?
  if `"`output'"'=="" {
    noisily di as error "No output file specified"
	quietly exit
  }
  if `"`output'"'!="" {
    tempname outputcheck
    capture noisily file open `outputcheck' using `output', write binary `replace'
	if _rc!=0 {
	  quietly exit
	}
	capture file close _all
	if `"`replace'"'=="" {
	  noisily confirm new file `output'
	  if _rc!=0 {
	    noisily di as error "Output file exists"
		quietly exit
	  }
	}
	if substr(`"`output'"',-4,.)!=".xml" {
	  noisily di as error "Warning: The output file has not .xml as filename extension." 
	  noisily di as error "The output is an xml-file, so the filename extension should be given accordingly."
	}
  }
  
  //****************************************************************************
  
  // save data
  quietly preserve
  
  // LOGISTICS
  // open metadata file	
  quietly use `"`input'"', clear
  // count number of cases 
  local N = _N

  // Start writing Output-File
  quietly tempname ddiOutputLog
  quietly capture file close `ddiOutputLog'
  quietly file open `ddiOutputLog' using `"`output'"', write `replace'
  
  // write start of frame for DDI2.5 xml-file
  quietly file write `ddiOutputLog' `"<?xml version="1.0" encoding="UTF-8"?>"' _n
  quietly file write `ddiOutputLog' `"<codeBook xmlns="ddi:codebook:2_5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="ddi:codebook:2_5 http://www.ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd">"' _n
  quietly file write `ddiOutputLog' "	<stdyDscr>" _n
  quietly file write `ddiOutputLog' "		<citation>" _n
  quietly file write `ddiOutputLog' "			<titlStmt>" _n
  quietly file write `ddiOutputLog' "				<titl/>" _n
  quietly file write `ddiOutputLog' "			</titlStmt>" _n
  quietly file write `ddiOutputLog' "		</citation>" _n
  quietly file write `ddiOutputLog' "	</stdyDscr>" _n
  quietly file write `ddiOutputLog' "	<dataDscr>" _n

  //****************************************************************************

  // OUTPUT

  // VarGrps

  // OPTIONAL: relation option used:
  if `"`relation'"'!="" {
    * drop irrelevant lines (first != 1 and mother=='')
    quietly keep if first == 1 & mother!=""
    * generate variable to identify group specific variables referring to the same mother
    quietly gen motherGroupCountry = ""
    * generate variable to count the number of variables with same mother
    quietly gen motherCountMax = 0	
    * forvalues over all remaining categories
    forvalues i = 1/`N' {
	  quietly replace motherGroupCountry = "Grp-" + mother + "-" + group
    }
 
    * Loop over motherGroupCountry to define varGroups for countries on the highest level
    quietly file write `ddiOutputLog' "		<!--Linking attached variables to main variables (on group level)-->" _n
    quietly levelsof motherGroupCountry, local(motherGroupCountryLevels)
    foreach mgcL of local motherGroupCountryLevels {
      quietly file write `ddiOutputLog' `"		<varGrp ID="`mgcL'" type="other" otherType="associatedVariables" var=""'
      * Loop over all cases to identify all variables of the same motherGroupCountry
      forvalues i = 1/`N' {
	    if "`mgcL'" == (motherGroupCountry[`i']) & (motherCountMax[`i']) == 0 {
          * The mother-Variable is needed as well, but only once. Therefore output is limited to motherCountMax=0 and value is changed at the end of the block 
          quietly file write `ddiOutputLog' (mother[`i'])
          quietly file write `ddiOutputLog' "-"
          quietly file write `ddiOutputLog' (group[`i'])
          quietly file write `ddiOutputLog' " "
          quietly file write `ddiOutputLog' (varName[`i'])
          quietly file write `ddiOutputLog' "-"
          quietly file write `ddiOutputLog' (group[`i'])
		  quietly replace motherCountMax = 1 if motherGroupCountry == ["`mgcL'"]
	    }
        else if "`mgcL'" == (motherGroupCountry[`i']) & (motherCountMax[`i']) > 0 {
          quietly file write `ddiOutputLog' " "
          quietly file write `ddiOutputLog' (varName[`i'])
          quietly file write `ddiOutputLog' "-"
          quietly file write `ddiOutputLog' (group[`i'])		
        }
      }
      quietly file write `ddiOutputLog' `""/>"' _n	
    }

    * Loop over mother to bunch together group-specific vargroups of one variable
    quietly file write `ddiOutputLog' "		<!--Bunch together group-specific varGrps of one variable-->" _n
    * reset motherCountMax
    quietly replace motherCountMax = 0
    quietly levelsof mother, local(motherLevels)
    foreach mL of local motherLevels {
      quietly file write `ddiOutputLog' `"		<varGrp ID="`mL'" type="other" otherType="associatedVariables" varGrp=""'
      * Loop over all cases to identify all variables of the same motherGroup
      forvalues i = 1/`N' {
        * motherCountMax is used to limit the output to the first appearance of every mother in a group 
        if "`mL'" == (mother[`i']) &  (motherCountMax[`i'])==0 {
          * local is used to set motherCountMax to 1 for all lines with same mother and group (see five lines below) 
          local motherCountCountry = group[`i']
          quietly file write `ddiOutputLog' (motherGroupCountry[`i'])
          if (group[`i'])!="all" {
            quietly file write `ddiOutputLog' " "
          }
          quietly replace motherCountMax = 1 if mother == ["`mL'"] & group == ["`motherCountCountry'"]				
        }
      }
      file write `ddiOutputLog' `""/>"' _n	
    }
    * open metadata file	
    quietly use `"`input'"', clear
  }

  //OUTPUT: Vars

  * Loop over all rows of the metadatafile (variable level)
  quietly file write `ddiOutputLog' "		<!--Variables of the dataset-->" _n
  forvalues i = 1/`N' {
    * Variable-level: Part adresses only first category of variable. Preceding variable-Tag is closed, unless Position=1
    if (first[`i']) == 1 & [`i'] > 1{
      quietly file write `ddiOutputLog' "		</var>" _n
    }
    if (first[`i']) == 1 {
      quietly file write `ddiOutputLog' `"		<var ID=""'
      quietly file write `ddiOutputLog'  (varName[`i'])
      quietly file write `ddiOutputLog' "-"
      quietly file write `ddiOutputLog'  (group[`i'])
      quietly file write `ddiOutputLog' `"" name=""'
      quietly file write `ddiOutputLog'  (varName[`i'])
      quietly file write `ddiOutputLog' `"" intrvl=""'
      if (computed[`i']) == 1 {
        quietly file write `ddiOutputLog' "discrete"	
      }
      else {
        quietly file write `ddiOutputLog' "contin"		
      }
      quietly file write `ddiOutputLog' `"">"'  _n
      * Label
      quietly file write `ddiOutputLog' "			<labl>"
      quietly file write `ddiOutputLog'  (variableLabel[`i'])
      quietly file write `ddiOutputLog' "</labl>"_n

      * Universe (geographical scope of the variable)
      quietly file write `ddiOutputLog' "			<universe>"
      quietly file write `ddiOutputLog'  (group[`i'])
      quietly file write `ddiOutputLog' "</universe>"_n
    
      * Summay Statistics (for all variables)
      * Number of valid cases
      quietly file write `ddiOutputLog' `"			<sumStat type="vald">"'
      quietly file write `ddiOutputLog'  (total_n[`i']) - (total_missing[`i'])
      quietly file write `ddiOutputLog' "</sumStat>"_n
    
      * Number of missing cases
      quietly file write `ddiOutputLog' `"			<sumStat type="invd">"'
      quietly file write `ddiOutputLog'  (total_missing[`i'])
      quietly file write `ddiOutputLog' "</sumStat>"_n
    
      * mean
      quietly file write `ddiOutputLog' `"			<sumStat type="mean">"'
      quietly file write `ddiOutputLog'  (Mean[`i'])
      quietly file write `ddiOutputLog' "</sumStat>"_n
    
      * standard deviation
      quietly file write `ddiOutputLog' `"			<sumStat type="stdev">"'
      quietly file write `ddiOutputLog'  (StandardDeviation[`i'])
      quietly file write `ddiOutputLog' "</sumStat>"_n
    }
  
    * Category-level (discrete variables only)
	if (computed[`i']) == 1 {
      quietly file write `ddiOutputLog' `"			<catgry missing=""'
	  if (isValid[`i']) == 1 {
        quietly file write `ddiOutputLog' "N"	
	  }
	  else {
        quietly file write `ddiOutputLog' "Y"		
	  }
      quietly file write `ddiOutputLog' `"">"' _n

      * catValu 
      quietly file write `ddiOutputLog' "				<catValu>"
      quietly file write `ddiOutputLog'  (value[`i'])
      quietly file write `ddiOutputLog' "</catValu>"	_n

      * label
      quietly file write `ddiOutputLog' "				<labl>"
      quietly file write `ddiOutputLog'  (valueLabel[`i'])
      quietly file write `ddiOutputLog' "</labl>"	_n

      * catStats
      quietly file write `ddiOutputLog' `"				<catStat type="freq">"'
      quietly file write `ddiOutputLog'  (n[`i'])
      quietly file write `ddiOutputLog' "</catStat>"	_n

      quietly file write `ddiOutputLog' `"				<catStat type="percent">"'
      quietly file write `ddiOutputLog'  (percent[`i'])
      quietly file write `ddiOutputLog' "</catStat>"	_n

      quietly file write `ddiOutputLog' `"				<catStat type="other" otherType="validPercent">"'
      quietly file write `ddiOutputLog'  (validPercent[`i'])
      quietly file write `ddiOutputLog' "</catStat>"	_n
		
      quietly file write `ddiOutputLog' "			</catgry>" _n
	}
    * for the last <var> the tag is closed explicitely
	if [`i'] == `N'{
      quietly file write `ddiOutputLog' "		</var>" _n	
	}
  }
	
  * write end of frame for DDI2.5 xml-file

  * Note: 2nd note is only printed if auxilliary variables are found
  quietly file write `ddiOutputLog' "		<notes>" _n
  quietly file write `ddiOutputLog' `"			<p>Two types of percentage distribution are available: catStat type="percent" describes the distribution over all cases, catStat type="other" otherType="validPercent" refers to the number of valid cases.</p>"' _n
  quietly file write `ddiOutputLog' "		</notes>" _n
  if `"`relation'"' != "" {
    quietly file write `ddiOutputLog' "		<notes>" _n
    quietly file write `ddiOutputLog' "			<p>The relationship beween variables is declared in the varGrp-elements. EU-SILC e.g. contains flags (_F) and imputation factors (_I) which relate to the main variable with the according variable name.</p>" _n
    quietly file write `ddiOutputLog' "		</notes>" _n
  } 

  quietly file write `ddiOutputLog' "	</dataDscr>" _n
  quietly file write `ddiOutputLog' "</codeBook>" _n	
	
	
  //****************************************************************************

  //** LOGISTICS

  * Closing the Log-Files
  quietly file close `ddiOutputLog' 
  // set back original data
  quietly restore
end
