*! version 1.3.0 29dec2017 daniel klein and Rafael Reckmann
program kalpha , byable(recall)
	version 11.2
	
	syntax varlist [ if ] [ in ] 	///
	[ , 							///
		Scale(passthru) 			///
		Transpose 					///
		XPOSE /// synonym for transpose; not documented
		FORMAT(string) 				/// not documented
		BOOTstrap 					///
		BOOTstrap2(string) 			///
	]
	
	kalpha_get_format `format'
	
	if ("`xpose'" != "") {
		local transpose transpose
	}
	
	marksample touse , novarlist
	
	kalpha_get_scale `varlist' , `scale'
	
	if ("`bootstrap'`bootstrap2'" != "") {
		kalpha_get_bootstrap , `bootstrap2'
		if (("`seed'" != "") & _by()) {
			display as err "option seed may not be combined with by"
			exit 190
		}
	}
	
	local caller = _caller()
	
	mata : kalpha_ado()
	
	kalpha_display , format(`format')
end

program kalpha_get_format
	version 11.2
	
	args format
	
	if (mi("`format'")) {
		local format %4.3f
	}
	else {
		confirm numeric format `format'
	}
	
	c_local format : copy local format
end

program kalpha_get_scale
	version 11.2
	
	syntax varlist [ , SCALE(string) ]
	
	capture confirm numeric variable `varlist'
	local has_str = (_rc != 0)
	capture confirm string variable `varlist'
	local all_str = (_rc == 0)
	
	if (mi("`scale'")) {
		local scale = cond(`has_str', "nominal", "interval")
	}
	else {
		local scale = strlower("`scale'")
	}
	
	local 0 , `scale'
	syntax 						///
	[ , 						///
		Nominal 				///
		Ordinal 				///
		Interval 				///
		Ratio 					///
		Circular 				///
		CIRCULARDeg 			///
		Circular2(string) 		///
		CIRCULARDeg2(string) 	///
		Polar 					///
		Polar2(string) 			///
	]
	
	foreach C in circular circulardeg {
		if (mi("``C'2'")) {
			continue
		}
		capture numlist "``C'2'" , integer max(1) range(>0)
		if (_rc) {
			display as err _continue "invalid option `C'() -- "
			error _rc
		}
		local U `r(numlist)'
		local `C' `C'
	}
	
	if ("`polar2'" != "") {
		capture numlist "`polar2'" , ascending min(2) max(2)
		if (_rc) {
			display as err _continue "invalid option polar() -- "
			error _rc
		}
		tokenize `r(numlist)'
		local Min `1'
		local Max `2'
		local polar polar
	}
	
	local scale 		///
		`nominal' 		///
		`ordinal' 		///
		`interval' 		///
		`ratio' 		///
		`circular' 		///
		`circulardeg' 	///
		`polar'
		
	if (`: word count `scale'' > 1) {
		display as err "option scale() incorrectly specified"
		exit 198
	}
	
	if ((`has_str') & ("`scale'" != "nominal")) {
		display as err "`scale' scale not allowed with string variables"
		exit 109
	}
		
	if ("`circular'`circulardeg'" != "") {
		local scale circular
		local sine = cond(mi("`circulardeg'"), "pi", "180")
	}
	
	if ("`polar'" != "") {
		local scale bipolar
	}
	
	c_local scale 	: copy local scale
	c_local U 		: copy local U
	c_local sine 	: copy local sine
	c_local Min 	: copy local Min
	c_local Max 	: copy local Max
	c_local has_str : copy local has_str
	c_local all_str : copy local all_str
end

program kalpha_get_bootstrap
	version 11.2
	
	syntax 									///
	[ , 									///
		Reps(integer 20000) 				///
		Level(cilevel) 						///
		MINAlpha(numlist > 0 < 1) 			///
		SEED(string) 						///
		NODOTS 								///
		DOTS 								///
		DOTS2(numlist integer max = 1 >= 0) ///
		DRAWs(numlist integer max = 1 > 1) 	/// not documented
		RETURN 								/// not documented
	]
	
	if (`reps' < 2) {
		display as err "reps() must be an integer greater than 1"
		e 198
	}
	
	if (mi("`nodots'")) {
		if mi("`dots2'") {
			local dots = max(1, floor(`reps'/50))
		}
		else {
			local dots : copy local dots2
		}
	}
	else {
		if ("`dots'`dots2'" != "") {
			display as err "option nodots not allowed"
			exit 198
		}
		local dots 0
	}
	
	c_local bootstrap 	bootstrap
	c_local reps 		: copy local reps
	c_local level 		: copy local level
	c_local minalpha 	: copy local minalpha
	c_local seed 		: copy local seed
	c_local dots 		: copy local dots
	c_local draws 		: copy local draws
	c_local return 		: copy local return
end

program kalpha_display
	version 11.2
	
	syntax , FORMAT(string)
	
	local txt as text
	local res as res
	
	display `txt' _newline "Krippendorff's Alpha Reliability"
	display `txt' "(" `res' r(metric) `txt' " data)" _newline
	
	display `txt' %21s "No. of units " "= " `res' r(units)
	display `txt' %21s "No. of observers " "= " `res' r(observers)
	display `txt' %21s "Krippendorff's alpha " "= " `res' `format' r(kalpha)
	
	if (mi(r(reps))) {
		exit 0
	}
	
	if (!r(reps)) {
		display `txt' _newline "Bootstrapping does not apply"
		exit 0
	}
	
	display `txt' _newline "Bootstrap results" _newline
	display `txt' %21s "No. of coincidences " "= " `res' r(n)
	display `txt' %21s "Replications " "= " `res' r(reps)
	display _newline _continue
	display `txt' %12s "[`r(level)'% " " Conf. Interval]"
	display _column(8) `res' `format' r(ci_lb) _continue
	local col = 29 - length("`: display `format' `r(ci_ub)''")
	display _column(`col') `res' `format' r(ci_ub)
	
	if ("`r(q)'" == "matrix") {
		local rows = rowsof(r(q))
		display _newline _continue
		display `txt' _column(2) "Probability of failure to reach alpha"
		display `txt' _newline _column(8) "min. alpha" _column(`++col') "q"
		forvalues j = 1/`rows' {
			display `res' _column(8) `format' el(r(q), `j', 1) _continue
			display `res' _column(`= `col' - 1') `format' el(r(q), `j', 2)
		}
	}	
end

version 11.2

local S scalar
local R rowvector
local C colvector
local M matrix

local SS string `S'
local SR string `R'
local SC string `C'
local SM string `M'

local RS real `S'
local RR real `R'
local RC real `C'
local RM real `M'

local TS transmorphic `S'
local TC transmorphic `C'
local TM transmorphic `M'

local stK struct_kalpha_def
local stKS struct `stK' `S'

mata :

struct `stK' {
	/* input */
	`SR' varlist
	`SS' touse
	`RS' has_str
	`RS' all_str
	`RS' transpose
	`SS' scale
	`RS' U
	`RS' sine
	`RS' p_min
	`RS' p_max
	`RS' caller
	/* input bootstrap */
	`RS' bootstrap
	`RS' reps
	`RS' level
	`RC' minalpha
	`SS' seed
	`RS' dots
	`RS' draws
	`RS' returnall
	/* created */
	`TM' R
	`TC' levels
	`RM' VbyU
	`RS' nu_
	`RS' n_c
	`RS' n__
	`RM' Ock
	`RM' delta2
	`RS' Do
	`RS' De
	`RS' kalpha
	`RC' bkalpha
	`RR' CI
	`RM' Q
}

void kalpha_ado()
{
	`stKS' K
	
	kalpha_get_info(K)
	kalpha_get_Rmat(K)
	kalpha_get_VbyU(K)
	kalpha_get_dmat(K)
	kalpha_get_coef(K)
	kalpha_get_boot(K)
	kalpha_set_rres(K)
}

void kalpha_get_info(`stKS' K)
{
	K.varlist 		= tokens(st_local("varlist"))
	K.touse 		= st_local("touse")
	K.has_str 		= strtoreal(st_local("has_str"))
	K.all_str 		= strtoreal(st_local("all_str"))
	K.transpose 	= (st_local("transpose") != "")
	K.scale 		= st_local("scale")
	K.U 			= strtoreal(st_local("U"))
	K.sine 			= (st_local("sine") == "pi") ? c("pi") : 180
	K.p_min 		= strtoreal(st_local("Min"))
	K.p_max 		= strtoreal(st_local("Max"))
	
	K.bootstrap 	= (st_local("bootstrap") != "")
	K.reps 			= strtoreal(st_local("reps"))
	K.level 		= strtoreal(st_local("level"))
	K.minalpha 		= strtoreal(tokens(st_local("minalpha"))')
	K.seed 			= st_local("seed")
	K.dots 			= strtoreal(st_local("dots"))
	K.draws 		= strtoreal(st_local("draws"))
	K.returnall 	= (st_local("return") != "")
	
	K.caller 		= strtoreal(st_local("caller"))
}

void kalpha_get_Rmat(`stKS' K)
{
	`TM' R, r
	
	if (!K.has_str) {
		K.R = st_data(., K.varlist, K.touse)
	}
	else if (K.all_str) {
		K.R = st_sdata(., K.varlist, K.touse)
	}
	else {
		R = J(colsum(st_data(., K.touse) :== 1), cols(K.varlist), "")
		for (i = 1; i <= cols(K.varlist); ++i) {
			if (st_isnumvar(K.varlist[i])) {
				r = editmissing(st_data(., K.varlist[i], K.touse), .)
				R[., i] = editvalue(strofreal(r, "%18.0g"), ".", "")
			}
			else {
				R[., i] = st_sdata(., K.varlist[i], K.touse)
			}
		}
		K.R = R
	}
	
	K.R = select(K.R, (colsum(K.R :== missingof(K.R)) :< rows(K.R)))
	K.R = select(K.R, (rowsum(K.R :== missingof(K.R)) :< cols(K.R)))
	
	if (K.transpose) {
		K.R = K.R'
	}
	
	if (!length(K.R)) {
		exit(error(2000))
	}
}

void kalpha_get_VbyU(`stKS' K)
{
	K.levels = uniqrows(vec(K.R))
	K.levels = select(K.levels, (K.levels :!= missingof(K.levels)))
	
	K.VbyU = J(rows(K.levels), cols(K.R), .)
	for (i = 1; i <= rows(K.levels); ++i) {
		K.VbyU[i, .] = colsum(K.R :== K.levels[i])
	}
	
	K.nu_ = colsum(K.VbyU)
	K.n_c = rowsum(select(K.VbyU, (K.nu_ :> 1)))
	K.n__ = colsum(K.n_c)
	
	K.Ock = editmissing(K.VbyU:/(K.nu_:-1), 0)*K.VbyU'
	_diag(K.Ock, quadrowsum(K.VbyU:*(K.VbyU:-1):/(K.nu_:-1)))
}

void kalpha_get_dmat(`stKS' K)
{
	`RM' c
	`RM' k
	`RS' rc
	
	if (K.scale == "nominal") {
		K.delta2 = !I(rows(K.levels))
	}
	else if (K.scale == "ordinal") {
		c = J(1, rows(K.n_c), K.n_c)
		k = J(rows(K.n_c), 1, K.n_c')
		K.delta2 = lowertriangle(c)
		for (i = 1; i < cols(K.delta2); ++i) {
			K.delta2[., i] = quadrunningsum(K.delta2[., i])
		}
		K.delta2 = makesymmetric((K.delta2 - (c+k)/2):^2)
	}
	else {
		c = J(1, rows(K.levels), K.levels)
		k = J(rows(K.levels), 1, K.levels')
		if (K.scale == "interval") {
			K.delta2 = (c-k):^2
		}
		else if (K.scale == "ratio") {
			K.delta2 = ((c-k):/(c+k)):^2
		}
		else if (K.scale == "circular") {
			if (missing(K.U)) {
				K.U = K.levels[rows(K.levels)] - K.levels[1] + 1
			}
			K.delta2 = sin(K.sine*(c-k)/K.U):^2
		}
		else if (K.scale == "bipolar") {
			if (missing(K.p_min)) {
				K.p_min = K.levels[1]
			}
			if (missing(K.p_max)) {
				K.p_max = K.levels[rows(K.levels)]
			}
			K.delta2 = (c+k:-2*K.p_min):*(2*K.p_max:-c:-k)
			K.delta2 = ((c-k):^2):/K.delta2
		}
		else {
			assert(0)
				/* internal error */
		}
	}
	_diag(K.delta2, 0)
	
	if (missing(K.delta2)) {
		rc = 504
	}
	else if (!issymmetric(K.delta2)) {
		rc = 505
	}
	else {
		rc = 0
	}
	
	if (rc) {
		errprintf("invalid metric difference matrix %s\n", K.scale)
		exit(rc)
	}
}

void kalpha_get_coef(`stKS' K)
{
	K.Do = (K.n__-1)*quadsum(lowertriangle(K.Ock:*K.delta2))
	K.De = quadcolsum(lowertriangle(J(1, rows(K.n_c), K.n_c):*K.delta2))*K.n_c
	
	if (((K.Do == 0) & (K.De == 0)) | (rowsum(K.nu_ :> 1) == 1)) {
		K.kalpha = 0 // by definition
	}
	else {
		K.kalpha = 1 - (K.Do/K.De)
	}
}

void kalpha_get_boot(`stKS' K)
{
	`RS' De, nx
	`RM' Pck, fr, sfr
	`RC' r
	
	if (!K.bootstrap) {
		return
	}
	
	if (anyof((0, 1), K.kalpha)) {
		K.reps = 0
		return
	}
	
	if (K.seed != "") {
		if (!missing(strtoreal(K.seed))) {
			K.seed = strtoreal(K.seed)
		}
		rseed(K.seed)
	}
	
	// first : get M
	if (missing(K.draws)) {
		K.draws = min((25*sum(K.Ock:>0), round(K.n__*(rows(K.R)-1)/2)))
	}
	
	// second : create function f(r)
	De 	= 2*(K.De/(K.n__*(K.n__-1)))
	Pck = (lowertriangle(K.Ock)/K.n__) + (lowertriangle(K.Ock, 0)/K.n__)
	fr 	= (quadrunningsum(vech(Pck)), vech(K.delta2):/(K.draws*De))
	
	// third : bootstrap
	K.bkalpha = J(K.reps, 1, .)
	for (i = 1; i <= K.reps; ++i) {
		if (!mod(i, K.dots)) {
			printf("{txt}%s", ".")
		}
		if (!mod(i/K.dots, 50) | i == K.reps) {
			printf("{txt}%6.0f\n", i)
		}
		displayflush()
		
		r 	= runiform(K.draws, 1)
		sfr = 0
		sfr = sfr + colsum(r:<=fr[1, 1])*fr[1, 2]
		for (j = 1; j <= (rows(fr)-1); ++j) {
			sfr = sfr + ///
			(colsum((r:>=fr[j, 1]):&(r:<=fr[(j+1), 1]))*fr[(j+1), 2])
		}
		
		K.bkalpha[i, 1] = 1 - sfr
	}
	
	// fourth : correct
	K.bkalpha = K.bkalpha - ((K.bkalpha:+1):*(K.bkalpha:<-1))
	if (anyof(K.bkalpha, 1)) {
		if ((colsum(diagonal(K.Ock)):>0) == 1) {
			K.bkalpha = K.bkalpha + ((K.bkalpha:==1):*(-1))
		}
		if ((colsum(diagonal(K.Ock)):>0) > 1) {
			nx = round(K.reps*colsum(diagonal(Pck):^K.draws))
			if (nx >= (colsum(K.bkalpha:==1))) {
				K.bkalpha = K.bkalpha + ((K.bkalpha:==1):*(-1))
			}
			else {
				K.bkalpha = sort(K.bkalpha, 1)
				for (i = 1; i <= nx; ++i) {
					K.bkalpha[(rows(K.bkalpha) - (i-1)), 1] = 0
				}
			}
		}
	}
	
	// fith : distribution
	K.bkalpha = sort(K.bkalpha, 1)
	
	// CI
	K.CI = J(1, 2, .)
	K.CI[1] = K.bkalpha[max(((1-K.level/100)/2*K.reps, 1))]
	K.CI[2] = K.bkalpha[floor(((1 - ((1-K.level/100)/2))*K.reps) + 1)]
	
	// q
	K.Q = J(rows(K.minalpha), 1, .)
	for (i = 1; i <= rows(K.Q); ++i) {
		K.Q[i] = (colsum(K.bkalpha:<K.minalpha[i])/K.reps)
	}
}

void kalpha_set_rres(`stKS' K)
{
	`SM' names
	
	st_rclear()
	
	/* macros */
	st_global("r(metric)", K.scale)
	
	/* scalars */
	st_numscalar("r(kalpha)", K.kalpha)
	st_numscalar("r(observers)", rows(K.R))
	st_numscalar("r(units)", rowsum(K.nu_ :> 1))
	st_numscalar("r(n)", K.n__)
	st_numscalar("r(Do)", K.Do)
	st_numscalar("r(De)", K.De)
	if (!missing(K.reps)) {
		st_numscalar("r(level)", K.level)
		st_numscalar("r(reps)", K.reps)
		st_numscalar("r(ci_lb)", K.CI[1])
		st_numscalar("r(ci_ub)", K.CI[2])
	}
	
	/* matrices */
	st_matrix("r(coin)", K.Ock)
	st_matrix("r(delta2)", K.delta2)
	if (!K.has_str) {
		st_matrix("r(uniqv)", K.levels)
	}
	if (K.bootstrap) {
		if (rows(K.minalpha)) {
			st_matrix("r(q)", (K.minalpha, K.Q))
		}
		if (K.returnall) {
			st_matrix("r(bkalpha)", K.bkalpha)
		}
	}
	if (K.caller < 15.2) {
		st_matrix("r(csum)", K.nu_)
		st_matrix("r(rsum)", K.n_c)
		st_matrix("r(vbu)", K.VbyU)
		if (!K.has_str) {
			st_matrix("r(rel)", K.R)
		}
	}
	
	if (length(K.R)) {
		names = (J(rows(K.levels), 1, "level"), strofreal(1::rows(K.levels)))
		st_matrixrowstripe("r(coin)", names)
		st_matrixcolstripe("r(coin)", names)
		st_matrixrowstripe("r(delta2)", names)
		st_matrixcolstripe("r(delta2)", names)
		if (K.bootstrap) {
			if (rows(K.minalpha)) {
				st_matrixcolstripe("r(q)", (("min."\ ""), ("alpha"\ "q")))
			}
		}
		
		if (K.caller < 15.2) {
			st_matrixrowstripe("r(vbu)", names)
			names = (J(cols(K.VbyU), 1, "unit"), strofreal(1::cols(K.VbyU)))
			st_matrixcolstripe("r(vbu)", names)
			if (!K.has_str) {
				st_matrixcolstripe("r(rel)", names)
				names = (J(rows(K.R), 1, "observer"), strofreal(1::rows(K.R)))
				st_matrixrowstripe("r(rel)", names)
			}
		}
	}
}

end
exit

1.3.0	27dec2017	rewrite ado code with more subroutines
					rewrite Mata code struct, matrix algebra replaces loops
					option dots(max(1, floor(reps/50))) is default
					return r(coin)
					return r(Do) and r(De)
					no longer return r(rel), r(vbu), r(rsum), r(csum)
					old r-results preserved under version controll
					extended help file
					kalpha no longer supported; superseded by kappaetc
1.2.2	25sep2014	bug fix -polar- default min and max
1.2.1	14aug2014	bug fix all missing rows or cols in R matrix
					may not combine option -seed- with by
					extend and document dots[()] option
					new rc for inappropriate scale with strings
					minor code polish
1.2.0	11jul2014	implement bootstrap algorithm (Krippendorff 2013)
					additional r-results
					no longer return r(Do) and r(De)
					new option format() (not documented)
					new option dots (not documented)
					new option return (not documented)
					new option draws() (not documented)
					first release on SSC
1.1.0 	07jul2014	allow string variables
					alpha = 0 if Do == De == 0 (by definition)
					bug fix conformability error if R matrix is scalar
					return Do and De
					xpose as synonym for transpose (not documented)
1.0.0 	03jul2014	first full version
					display results
					support all levels of measurement
					new option scale()
					new option transpose
					byable
					new Mata function calculates sums
					sent to Jim Lemon and Alexander Staudt
1.0.0	01jul2014	beta version
					rudimetary do-file and Mata function
					sent to Alexander Staudt
