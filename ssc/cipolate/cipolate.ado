*! NJC 1.0.0 4 July 2002 
* ipolate 1.3.1  14jun2000
program define cipolate, byable(onecall) sort
	version 7
	syntax varlist(min=2 max=2) [if] [in], Generate(string) [ BY(varlist) ]
	
	if _by() {
		if "`by'" != "" {
			di as err /*
			*/ "option by() may not be combined with by prefix"
			exit 190
		}
		local by "`_byvars'"
	}

	confirm new var `generate'
	tokenize `varlist'
	args usery x 
	tempvar touse negx negy ok ok2 x1 x2 x3 x4 y1 y2 y3 y4 
	tempvar m m1 m2 m3 m4 z y
	
	quietly {
		mark `touse' `if' `in'
		replace `touse' = 0 if `x' == .
		sort `touse' `by' `x'
		
		by `touse' `by' `x': /*
		*/ gen `y' = sum(`usery') / sum(`usery' != .) if `touse'
		by `touse' `by' `x': replace `y' = `y'[_N]
		
		* following values 
		gen `negx' = -`x'
		gen `negy' = -`y'
		bysort `touse' `by' (`negx' `negy') : /* 
		*/ gen `ok' = _n * (`y' < .) 
		by `touse' `by' : /* 
		*/ replace `ok' = `ok'[_n-1] if !`ok'
		by `touse' `by' : gen `ok2' = `ok'[_n-1] * (`ok' > `ok'[_n-1]) 
		by `touse' `by' : replace `ok2' = `ok2'[_n-1] if !`ok2' 
		by `touse' `by' : gen `x4' = `x'[`ok2'] 
		by `touse' `by' : gen `y4' = `y'[`ok2'] 
		by `touse' `by' : gen `x3' = `x'[`ok']
		by `touse' `by' : gen `y3' = `y'[`ok']

		* preceding values
		bysort `touse' `by' (`x' `y'): /* 
		*/ replace `ok' = _n * (`y' < .) 
		by `touse' `by' : /* 
		*/ replace `ok' = `ok'[_n-1] if !`ok'
		by `touse' `by' : replace `ok2' = /* 
		*/ `ok'[_n-1] * (`ok' > `ok'[_n-1]) 
		by `touse' `by' : replace `ok2' = /* 
		*/ `ok2'[_n-1] if !`ok2' 
		by `touse' `by' : gen `x1' = `x'[`ok2'] 
		by `touse' `by' : gen `y1' = `y'[`ok2'] 
		by `touse' `by' : gen `x2' = `x'[`ok']
		by `touse' `by' : gen `y2' = `y'[`ok']

		gen double `m1' = (`x' - `x2') * (`x' - `x3') * (`x' - `x4') /* 
		*/ / ((`x1' - `x2') * (`x1' - `x3') * (`x1' - `x4'))
		gen double `m2' = (`x' - `x1') * (`x' - `x3') * (`x' - `x4') /* 
		*/ / ((`x2' - `x1') * (`x2' - `x3') * (`x2' - `x4'))
		gen double `m3' = (`x' - `x1') * (`x' - `x2') * (`x' - `x4') /* 
		*/ / ((`x3' - `x1') * (`x3' - `x2') * (`x3' - `x4')) 
		gen double `m4' = (`x' - `x1') * (`x' - `x2') * (`x' - `x3') /* 
		*/ / ((`x4' - `x1') * (`x4' - `x2') * (`x4' - `x3')) 
		gen double `m' = /* 
		*/ `m1' * `y1' + `m2' * `y2' + `m3' * `y3' + `m4' * `y4'
		
		gen `z' = `y' if `touse'
		replace `z' = `m' if `touse' & `z' == .
		rename `z' `generate'
		count if `generate' == .
	}
	
	if r(N) > 0 {
		if r(N) != 1 { local pl "s" }
		di as txt "(" r(N) `" missing value`pl' generated)"'
	}
end
