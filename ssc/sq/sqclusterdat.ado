*! version 2.0 Juni 8, 2016 @ 18:20:03
*! Construct -sqom- sample to allow faster cluster specification
* ukohler@uni-potsdam.de

*1.0 Initial version
*1.1 Option "keep(varlist) added"
*1.2 Bug fix. Wrong sorting in sqclusterdat return -> also needed a fix in sqom.ado
*1.3 Bug fix. Reshape wide error (also see sqom.ado 1.6)
*1.4 Clean up: Saving/Using tempfiles in compound double-qoutes
*1.5 Bug fix: Subsequence Option of sqom not respected
*1.6 Bug fix: Wrong _dta[_cl] -> _dta[_cluster_objects]
*1.7 Bug fix: _dta[_cluster_objects] is buggy for versions < 10 -> fixed
*1.8 Bug fix: Speed up of sqom 1.15 introduced a bug here. -> fixed
*2.0 Use full n*n distance Matrix

program sqclusterdat
version 9.1

	syntax [, return keep(varlist) ]

	// Shrink the Data to the dimensions of SQdist
	if "`return'" == "" {

		if "`_dta[Sqclusterdat]'" != "" {
			di as error "Data already groupdat"
			exit 198
		}

		_sqclusterdata  

	}

	// Adds results to origional data
	else {

		if "`_dta[Sqclusterdat]'" == ""  {
			di as error "Data already returned"
			exit 198
		}

		capture	_sqclusterreturn `keep'

		if _rc {
			use _Sqclusterorig, replace
			di as text "Group results could not be merged to sequence data"
			di as text "Returned to original sequence data"
		}

		char _dta[Sqclusterdat] 
	}
end

program _sqclusterdata 
    quietly {
  
		save _Sqclusterorig, replace
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
		
		// Store a copy (for -_sqclusterreturn-)
		sort `varlist' `_dta[SQiis]'
		gen _SQid = _n
		drop `varlist'
		label var _SQid "key for -sqclusterdata, return-"
		sort _SQid
		save _Sqclusterdata, replace
		
		// Keep one Sequence of each type
		* not in 2.0 by _SQid: gen _SQn = _N
		* not in 2.0 label var _SQn "Sequence frequency"
		* not in 2.0 by _SQid: keep if _n==1
		* not in 2.0 sort _SQid
		
		char _dta[Sqclusterdat] 1
		cluster drop _all
	}
	
end
	
program define _sqclusterreturn
	syntax [varlist]

	tempfile clusterdat

	local clusternames = cond(c(stata_version)<10,"_dta[_cl]","_dta[_cluster_objects]")
	
	foreach name in `_`clusternames'' {
		local namelist "`namelist' `name'*"
	}
	
	quietly {

		capture confirm new variable _SQid
		if !_rc {
			gen _SQid = `=word("``clusternames''",1)'_id
		}
		else replace _SQid = `=word("``clusternames''",1)'_id
		sort _SQid
		save `"`clusterdat'"'

		use _Sqclusterdata, clear
		merge _SQid using `"`clusterdat'"'
		assert _merge ==3
		erase _Sqclusterdata.dta

		keep `_dta[SQiis]' `namelist' `varlist'
		sort `_dta[SQiis]'
		save `"`clusterdat'"', replace

		use _Sqclusterorig, clear
		sort `_dta[SQiis]'
		merge `_dta[SQiis]' using `"`clusterdat'"'
		assert _merge!=2
		drop _merge
		erase _Sqclusterorig.dta
	}

end

