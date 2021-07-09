*! Stata-Syntax for outdat.ado 1.2 ukohler@sowi.uni-mannheim.de
* Change-log
* ----------

* Version 1.2: String-Variables could not be read. Fixed
*              Using STatement of "Infile" was not complete. Fixed
* Version 1.1: New Output
* Version 1.0: Variable-List in column-style
* Version 0.1: First draft
  
version 7.0
program define outdat_stata
syntax [varlist] using/ 

quietly {
  file open dofile using `using'.do, replace text write

  * DATA LIST
  * ---------

  file write dofile `"* Stata-commands to read and label `using'.dat"'
  file write dofile  _n _n `"infile /*"' _n `"*/"' 
  local j 1
  foreach var of varlist `varlist' { 
    local t: type `var'
    local l = 9-length("`var'")+(mod(`j',7)!=0)
    file write dofile `"`t' `var'"' _skip(`l') 
    local j=`j'+1
    if (mod(`j'-1,7)==0) { 
      file write dofile `"/*"'_n`"*/"'
    }
  }
  file write dofile `"using `using'.dat"' 
  file write dofile _n


  * VARIABLE LABEL
  * --------------

  foreach var of varlist `varlist' {
    local varlab: variable label `var'
    file write dofile _n `"label variable `var' "`varlab'" "'
    local label: value label `var'
    if "`label'" ~= "" {
      file write dofile _n `"label value `var' `label' "'
    }
  }
  
  * VALUE LABEL
  * -----------
    
  tempfile labeldo
  label save _all using `labeldo'
  file open labels using `labeldo', read text
  file read labels line 
  while r(eof)==0 {
    file write dofile _n `"`line'"'
    file read labels line
  }
  file close labels
  file close dofile
  noi di "{res}Stata{txt} commands written to {view `using'.do:`using'.do}"
}
		
end
exit


Ulrich Kohler
University of Mannheim
Faculty of Social Sciences
68131 Mannheim
+49 (0621) 181-2053
