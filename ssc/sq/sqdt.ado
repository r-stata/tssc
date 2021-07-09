*! version 1.0 December 22, 2006 @ 13:10:36
*! Calculate Dijkstra and Taris measurs of sequence distance 

*1.0 Initial version

program sqdt, rclass
version 9.1

syntax [if] [in] [,                                        ///
  Alpha Beta Gamma                                         ///
  REFseqid(string) full ]

// SQ-Data
// -------

if "`_dta[SQis]'" == "" {
	di as error "data not declared as SQ-data; use -sqset-"
	exit 9
}

// Store definition of sqom-sample for sqclusterdat
// ------------------------------------------------

char _dta[SQomsample] `if' `in'

// Declarations
// ------------

tempvar gap epiid epicount SQom SQid cutter N
tempfile SQorig SQrefseq noshrink results 



    // Error Checks
    // ------------

    
	if "`name'" != "" confirm new variable `name'

	if "`alpha'" == "" & "`beta'" == "" & "`gamma'" == "" local alpha "alpha" 
	capture assert ("`alpha'" != "") + ("`beta'" != "") + ("`gamma'" != "") == 1
	if _rc {
		di as error "Only one of -alpha-, -beta-, -gamma- allowed"
		exit _rc
	}
	

	// Defaults
	// --------


if "`alpha'" == "alpha"    local method 1
if "`beta'" == "beta"	   local method 2
if "`gamma'" == "gamma"	   local method 3
		
local full = cond("`full'"=="full",1,0)

if !`full' capture drop _SQdist

quietly {

    // Shrink the Data -> Speed
    // ------------------------
    
    preserve
    marksample touse
 
    // Drop Sequences with Gaps 
    if "`gapinclude'" == "" {
       tempvar lcensor rcensor gap
       by `_dta[SQiis]' (`_dta[SQtis]'), sort: gen `lcensor' = sum(!mi(`_dta[SQis]'))
       by `_dta[SQiis]' (`_dta[SQtis]'): gen `rcensor' = sum(mi(`_dta[SQis]'))
       by `_dta[SQiis]' (`_dta[SQtis]'): ///
         replace `rcensor' = ((_N-_n) == (`rcensor'[_N]-`rcensor'[_n])) & mi(`_dta[SQis]')
       by `_dta[SQiis]' (`_dta[SQtis]'): ///
       gen `gap' = sum(mi(`_dta[SQis]') & `lcensor' & !`rcensor')
       by `_dta[SQiis]' (`_dta[SQtis]'): ///
        replace `touse' = 0 if `gap'[_N]>0
    }
    keep if `touse'
    if _N == 0 {
       noi di as text "(No observations)"
       exit
    }
    drop `lcensor' `rcensor' 
    
   // Reshape Wide
   keep `_dta[SQis]' `_dta[SQiis]' `_dta[SQtis]'
   reshape wide `_dta[SQis]', i(`_dta[SQiis]') j(`_dta[SQtis]') 
   unab varlist: `_dta[SQis]'*

   // Store reference sequence
   if "`refseqid'" != "" {
      save `"`results'"'
      capture confirm numeric variable `_dta[SQiis]'
			if !_rc {
				count if `_dta[SQiis]' == `refseqid' 		
				capture assert r(N) > 0
				if _rc {
					noi di as error "reference sequence does not exist"
					exit 198
				}
				keep if `_dta[SQiis]' == `refseqid'
			}
			else {
				count if `_dta[SQiis]' == "`refseqid'"
				capture assert r(N) > 0
				if _rc {
					noi di as error "reference sequence does not exist"
					exit 198
				}
				keep if `_dta[SQiis]' == "`refseqid'"
			}
			save `"`SQrefseq'"'
			use `"`results'"', clear
   }
   
   // Store a copy
   by `varlist', sort: gen `SQid' = 1 if _n==1
   replace `SQid' = sum(`SQid')
   sort `SQid'
   save `"`noshrink'"'

   // Keep only one Sequence of each type
   by `varlist', sort: gen `N' = _N
   by `SQid', sort: keep if _n==1
   if "`refseqid'" != "" append using `SQrefseq'
   sort `SQid'

   // Call the Mata-Function from lsq.lib (Source-Code: lsq.mata)
	if !`full' {
	   capture drop _SQdist
       mata: sqdtref("`varlist'","`method'")
	   drop if `SQid'==.
	   sort `SQid'
       save `"`results'"', replace

       use `"`noshrink'"', clear 
       merge `SQid' using `results'
       assert _merge ==3
       drop _merge
	   keep `_dta[SQiis]' _SQdist
	   label var _SQdist ///
	  `"sqom with k(`k') indel(`indelcost') subcost(`subcost') refseqid(`refseqid') "'	
       if "`name'" != "" ren _SQdist `name'	
       sort `_dta[SQiis]'
       save `"`results'"', replace

       restore
       sort `_dta[SQiis]'
       merge `_dta[SQiis]' using `results'
       assert _merge!=2
       drop _merge
	   noi di as text `"Distance Variable saved as"' ///
		  as res `" `=cond("`name'"=="","_SQdist","`name'")' "'
   }

   if `full' {
       noi di as text "Perform " ///
         as res _N*(_N-1)/2 ///
         as text " calculations of DT distances"
   
        mata: sqdtfull("`varlist'",`method')
        restore
        noi di as text "Distance matrix saved as " as res "SQdist" 
   }
}


// Return
// ------

return local name =cond("`name'"=="","_SQdist","`name'")

end
exit




