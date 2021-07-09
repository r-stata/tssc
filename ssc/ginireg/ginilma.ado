*! ginilma.ado 1.0.00 22Jan2015
*! author mes
*  General notes:

program define ginilma, sort
	version 10.1

* Parsing assumes all LMA blocks surrounded
* so if only one block and no parens, add them
	if substr(`"`0'"',1,1) ~= "(" {
		local 0 (`0')
	}
	
* Needed because first ob in plot is (0,0)
	preserve
	local newobs = _N+1
	qui set obs `newobs'
	
* Loop through blocks
	local rest `0'
* Counts block number
	local block 0

	while `"`rest'"' ~= "" {

		gettoken 0 rest : rest , bind quotes match(macparen)
* Get rid of any leading blanks in `rest'
		local rest = ltrim(`"`rest'"')
* If `rest' is options for twoway, catch and give to twoway
		if substr(`"`rest'"',1,1) == "," {
			local twoway_options `"`rest'"'
			local rest
		}

		local ++block
		local multiblock = (`"`rest'"' ~= "") | ("`multiblock'" ~= "")

* Parse block and execute
		syntax varlist [fw aw pw/] [if] [in] [ , nlma * ]
	
* Loop puts all but last var of varlist into y; last var goes into x
* Initialize for this block
		local y
		local x

		local remvars `varlist'
		tokenize `remvars'
		while "`2'" ~= "" {
			tokenize `remvars'
			local y "`y' `1'"
			local x `2'
			mac shift
			local remvars `*'
		}
* For multi-block LMA, x var must be same throughout
		if "`xaxis'"=="" {
			local xaxis `x'				//  initialize
		}
		else {
			if "`xaxis'" ~= "`x'" {		//  check
di as err "error - X-axis variable must be the same in all LMA graphs"
				exit 601
			}
		}
	
		marksample touse
		tempvar wgt
* Raw weight variable
		if `"`exp'"' != "" {
			qui gen double `wgt' = `exp' if `touse'
		}
		else {
			qui gen double `wgt' = 1
		}
* Normalized weight var; sum=1
		sum `wgt' if `touse', meanonly
		qui replace `wgt' = `wgt'/r(sum)
	
		markout `touse' `y' `x' `wgt'
	
* Used to hold data for graphing
		tempvar Fx
		qui gen double `Fx' = .
		local varlab : variable label `x'
		if "`varlab'"=="" {
			local varlab "`x'"
		}
		label var `Fx' "F(`varlab')"

* Initialize varlists holding Y variables
		local LMA
		local NLMA
		foreach var of varlist `y' {
			tempvar LMAj NLMAj
			qui gen double `LMAj' = .
			qui gen double `NLMAj' = .
			local LMA "`LMA' `LMAj'"
			local NLMA "`NLMA' `NLMAj'"
			local varlab : variable label `var'
			if "`varlab'"=="" {
				local varlab "`var'"
			}
			if `multiblock' {
				label var `LMAj' "LMA `varlab' (`block')"
				label var `NLMAj' "NLMA `varlab' (`block')"
			}
			else {
				label var `LMAj' "LMA `varlab'"
				label var `NLMAj' "NLMA `varlab'"
			}
		}
	
* Data are sent pre-sorted
		sort `x'
	
		mata:	s_lma(					///
						"`y'",			///
						"`x'",			///
						"`LMA'",		///
						"`NLMA'",		///
						"`Fx'",			///
						"`wgt'",		///
						"`touse'"		///
						)

* Create block to pass to twoway
		if "`nlma'"=="" {
			local twoway_block	(line `LMA' `Fx' if `Fx' < ., title(LMA) `options')
		}
		else {
			local twoway_block	(line `NLMA' `Fx' if `Fx' < ., title(NLMA) `options')
		}
* And add to list of blocks
		local twoway_args `" `twoway_args' `twoway_block' "'
	}

	twoway `twoway_args' `twoway_options'
	
	restore
end


version 10.1
mata:

void s_lma(		string scalar yname,
				string scalar xname,
				string scalar LMAname,
				string scalar NLMAname,
				string scalar Fxname,
				string scalar wvarname,
				string scalar touse
				)
{

	st_view(y=.,.,tokens(yname),touse)
	st_view(x=.,.,xname,touse)
	st_view(w=.,.,wvarname,touse)
// No touse here because all missing, and anyway we need an extra row
	st_view(LMA=.,.,tokens(LMAname))
	st_view(NLMA=.,.,tokens(NLMAname))
	st_view(Fx=.,.,Fxname)

	N = rows(y)
	mtouse = J(N,1,1)
	ob = runningsum(mtouse)

// Weights must sum to 1
	sumw=quadsum(w[.,1])
	mw = w * 1/sumw

// Initialize
	myw = y :* mw

// sumyw = sum of yw (scalar)
// Fx = empirical CDF for rank(x) (equivalent to cumulation of weights)
// Ryw = weighted y with cumulations for ties
	sumyw=quadcolsum(myw)
	mFx = quadrunningsum(mw)
	mRyw = myw

// Calculate running sum of (weighted) y, x and wt.
// Must deal with ties in x
// Use FIRST appearance of a dup to cumulate subsequent values
	lasti=1									//  most recent row to be used (not a duplicate)
	lastx=x[1,1]
	lastyw=0
	for (i=2; i<=N; i++) {
		if (x[i,1]==lastx) {				//  dup found
											//  put cum sums in row to use
			mRyw[lasti,.] = mRyw[lasti,.] + myw[i,.]
			mFx[lasti,1] = mFx[i,1]
			mtouse[i,1] = 0					//  mark current row as not to use
		}
		else {								//  finish up and restart
			lasti=i							//  has row of singleton or FIRST appearance of dup
			lastx=x[i,1]
		}
	}

// Select only used obs
	mx = select(x, mtouse)
	mFx = select(mFx, mtouse)
	mRyw = select(mRyw, mtouse)

// Initialize mLMA
	mLMA = J(rows(mx),0,.)
	for (j=1; j<=cols(mRyw); j++) {
// ACC
		mACC = quadrunningsum(mRyw[.,j])
// LMA
		mLMA = mLMA, sumyw[1,j]*mFx - mACC
	}

// Needed for NLMA curve
	cov_xFx = quadvariance((mx, mFx))
// Remove small-sample adjustment
	cov_xFx = cov_xFx * (rows(mx)-1)/rows(mx)
	cov_xFx = cov_xFx[1,2]

// NLMA curve
	mNLMA = mLMA * 1/cov_xFx

// Append initial observation
	mFx = 0 \ mFx
	mLMA = J(1,cols(mLMA),0) \ mLMA
	mNLMA = J(1,cols(mNLMA),0) \ mNLMA
	
// Write into Stata variables

	for (i=1; i<=rows(mFx); i++) {
		Fx[i,1] = mFx[i,1]
		LMA[i,.] = mLMA[i,.]
		NLMA[i,.] = mNLMA[i,.]
	}
}

end
