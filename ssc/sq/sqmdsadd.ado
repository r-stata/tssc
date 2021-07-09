*! version 2.0 März 15, 2016 @ 18:12:06
*! Add file with MDS Predictions to SQ-data
* ukohler@uni-potsdam.de

*1.0 Initial version
*2.0 We now use entire distance matrix
	
program sqmdsadd
version 10
	
	syntax using  [, keep(varlist) ]
	
	// Shrink the Data to the dimensions of SQdist and save necessary files
	_sqdata

	// Merge file
	merge _Category `using'
	assert _merge == 3
	drop _merge Category
	
	// Adds results to origional data
	capture	_sqmdsreturn `keep'
	
	if _rc {
		use _Sqorig, replace
		di as text "Group results could not be merged to sequence data"
		di as text "Returned to original sequence data"
	}
end

program _sqdata 
	quietly {
		
		save _Sqorig, replace
		capture keep `_dta[SQomsample]'
		if "`_dta[SQomsubseq]'" != "" drop `_dta[SQomsubseq]'
		
		// Drop Sequences with Gaps 
		tempvar lcensor rcensor gap
		by `_dta[SQiis]' (`_dta[SQtis]'), sort: gen `lcensor' = sum(!mi(`_dta[SQis]'))
		by `_dta[SQiis]' (`_dta[SQtis]'): gen `rcensor' = sum(mi(`_dta[SQis]'))
		by `_dta[SQiis]' (`_dta[SQtis]'): ///
		  replace `rcensor' = ((_N-_n) == (`rcensor'[_N]-`rcensor'[_n])) & mi(`_dta[SQis]')
		by `_dta[SQiis]' (`_dta[SQtis]'): ///
		  gen `gap' = sum(mi(`_dta[SQis]') & `lcensor' & !`rcensor')
		by `_dta[SQiis]' (`_dta[SQtis]'): ///
		  drop if `gap'[_N]>0
		drop `lcensor' `rcensor' `gap'
		
		//One-to-one mapping of sequences to the alphabet 1,2,..,n
		//Condition: no raw distance
		if "`_dta[SQomsubcost]'" != "rawdistance" {
			tempvar newalph
			gen `newalph'= .
			levelsof `_dta[SQis]', local(Element)
			
			local newelement 1
			
			foreach l of local Element{
				replace `newalph' = `newelement++' if `_dta[SQis]'== `l'
			}
			replace `_dta[SQis]' = `newalph'
		}
		
		// Reshape Wide
		keep `_dta[SQis]' `_dta[SQiis]' `_dta[SQtis]'
		reshape wide `_dta[SQis]', i(`_dta[SQiis]') j(`_dta[SQtis]') 
		unab varlist: `_dta[SQis]'*
		noi describe
		
		// Store a copy (for -_sqmdsreturn-)
		by `varlist' `_dta[SQiis]', sort: gen _Category = 1 if _n==1
		drop `varlist'
		replace _Category = sum(_Category)
		label var _Category "key for -sqclusterdata, return-"
		sort _Category
		save _Sqdata, replace
		
		// Keep one Sequence of each type
		// by _Category: keep if _n==1
		// sort _Category
		// save _SQrows, replace
	}
	
end

program define _sqmdsreturn
	syntax [varlist]
	tempfile mds
	noi d

	quietly {
		keep _Category `varlist'
		sort _Category
		save `mds'

		use _Sqdata, clear
		sort _Category
		merge _Category using `mds'
		assert _merge ==3
		drop _merge
		erase _Sqdata.dta

		keep `_dta[SQiis]' `varlist'
		sort `_dta[SQiis]'
		save `mds', replace

		use _Sqorig, clear
		sort `_dta[SQiis]'
		merge `_dta[SQiis]' using `mds'
		assert _merge!=2
		drop _merge _Category
		erase _Sqorig.dta
	}

end

