/*

	rcl_test_data_generation.do
	This do file reproduces for the rcl command the simulated equilibrium dataset 
	rcl_test_data.dta if it does not exist and saves it into the plus/r folder.

*/
	
/* */
/* */
/* */

version 12.1
set more off, perm

* check whether the dta file exists
capture use `c(sysdir_plus)'r\rcl_test_data.dta, clear

* generate test data (if the file does not exist)
if (_rc!=0) {

	* parameters
	global nmarket=25													/* number of markets */
	global nfirm=10														/* number of firms */
	global nproduct=2													/* maximum number of products per firm */
	global nobs=$nmarket*$nfirm*$nproduct								/* maximum number of observations */
	global alpha=0.5													/* negative of price coefficient in mean utility (alpha) */
	global rcsigmas 1													/* BLP-type random coefficient sigma on price (sigmap) */
	global sigmas 0.5 0.75 0.95											/* nested logit sigmas: nest, subnest, sub-subnest */
	global b0=2															/* coefficient on constant term in mean utility */
	global b1=2															/* coefficient on exogenous characteristic (x1) in mean utility */
	global gamma10=0.7													/* coefficient on constant term in marginal cost */
	global gamma11=0.7													/* coefficient on characteristic (x1) in marginal cost */
	global gamma_g1=0.7													/* coefficient on product group dummy (g) in marginal cost */
	global gamma21=3													/* coefficient on cost shifter w1 in marginal cost */
	global gamma22=3													/* coefficient on cost shifter w2 in marginal cost */
	global gamma23=3													/* coefficient on cost shifter w3 in marginal cost */
	global sigma_ksi=1													/* standard deviation of unobserved product characteristic (ksi, error term of demand estimating equation) */
	global sigma_omega=1												/* standard deviation of unobserved marginal cost component (omega, error term of pricing equation) */
	global sigma_ksiomega=0.7											/* covariance between ksi and omega) */
	global rho_ksiomega=$sigma_ksiomega/(($sigma_ksi*$sigma_omega)^0.5)
	global msize_factor=1

	* globals specifying variable names (for the rcl command)
	global market market
	global msize msize
	global firm firm
	global firm_post firm
	global mc mc
	global xb0 xb0
	global ksi ksi
	global rc x1
	global nests g h
	global sample if market<=$nmarket
	global msample if market<=$nmarket & market<=5
	local acc_option accuracy(9)
	local acc_option $acc_option

	* non-random variables (same for each draw)
	clear
	set obs $nobs
	local nmarket=$nmarket
	local nfirm=$nfirm
	local nproduct=$nproduct
	* market variable
	generate market=1
	forvalues i=1/`nmarket' {
		replace market=`i' if _n>(`i'-1)*(`nfirm'*`nproduct') & _n<(`i'+1)*(`nfirm'*`nproduct')
	}
	bys market: generate product=_n
	* g, h, k: "nest", "subnest" and "sub-subnest" identifiers of product groupings
	generate g=(product<=`nfirm'*`nproduct'/2) + 2*(product>`nfirm'*`nproduct'/2)
	generate h=(product<=`nfirm'*`nproduct'/4) + 2*(product>`nfirm'*`nproduct'/4 & product<=`nfirm'*`nproduct'*2/4) + 3*(product>`nfirm'*`nproduct'*2/4 & product<=`nfirm'*`nproduct'*3/4) + 4*(product>`nfirm'*`nproduct'*3/4)
	generate k=(product<=`nfirm'*`nproduct'/8) + 2*(product>`nfirm'*`nproduct'/8 & product<=`nfirm'*`nproduct'*2/8) + 3*(product>`nfirm'*`nproduct'*2/8 & product<=`nfirm'*`nproduct'*3/8) + 4*(product>`nfirm'*`nproduct'*3/8 & product<=`nfirm'*`nproduct'*4/8) + 5*(product>`nfirm'*`nproduct'*4/8 & product<=`nfirm'*`nproduct'*5/8) + 6*(product>`nfirm'*`nproduct'*5/8 & product<=`nfirm'*`nproduct'*6/8) + 7*(product>`nfirm'*`nproduct'*6/8 & product<=`nfirm'*`nproduct'*7/8) + 8*(product>`nfirm'*`nproduct'*7/8)
	generate constant=1
	sort market, stable
	by market: generate rs=sum(constant)
	generate rs1=ceil(rs/`nfirm')
	* firm identifier
	generate firm=rs-(rs1-1)*`nfirm' if rs1!=1
	replace firm=rs if rs1==1
	drop rs rs1
	* post-merger firm identifier (assuming firm 1 and 2 merging; used in examples)
	generate firm_post=firm*(firm!=2) + (firm==2)
	generate msize=$msize_factor
	generate xb0=$b0*constant
	order market product firm firm_post g h k xb0
	sort market product, stable
	xtset market product
	compress

	* generating random datasets

	* generating random variables for current draw
	sort market product, stable
	set seed 1
	quietly generate $ksi=rnormal(0,$sigma_ksi) $sample
	quietly generate omega=rnormal(0,1) $sample
	quietly replace omega=$sigma_omega*( $ksi*$rho_ksiomega + omega*((1-($rho_ksiomega)^2)^0.5) ) $sample
	quietly generate x1=1+(2-1)*runiform() $sample
	quietly generate w1=runiform() $sample
	quietly generate w2=runiform() $sample
	quietly generate w3=runiform() $sample
	* marginal costs
	quietly generate $mc=$gamma10*constant + $gamma11*x1 + $gamma_g1*(g==1) + $gamma21*w1 + $gamma22*w2 + $gamma23*w3 + omega $sample
	* "observed", exogenous part of mean utility
	quietly replace $xb0=$xb0 + $b1*x1 $sample

	* implied initial market shares
	quietly generate p0=$mc*1.35
	quietly generate share_init=exp(-$alpha*p0+$xb0+$ksi) $sample
	quietly by market: egen tshare_init=total(share_init)
	quietly replace share_init=share_init/(tshare_init+1) $sample
	drop tshare_init

	* simple logit data simulation
	sort market product, stable
	global price p0
	global share share_init
	capture quietly rcl $share $price $sample, market($market) msize($msize) mc($mc) xb0($xb0) ksi($ksi) alpha($alpha) msimulation($firm $firm) noest /*nodisplay*/
	if (_rc!=0) {
		capture drop __p_post
		capture drop __s_post
		capture drop __foc_post
		quietly generate __p_post=$price
		quietly generate __s_post=$share
		quietly generate __foc_post=.
	}
	sort market product, stable
	quietly generate price_logit0=__p_post
	quietly generate share_logit0=__s_post
	drop __* p0 share_init
	global price price_logit0
	global share share_logit0
	capture quietly rcl $share $price $sample, market($market) msize($msize) mc($mc) xb0($xb0) ksi($ksi) alpha($alpha) msimulation($firm $firm) noest /*nodisplay*/
	if (_rc!=0) {
		capture drop __p_post
		capture drop __s_post
		capture drop __foc_post
		quietly generate __p_post=$price
		quietly generate __s_post=$share
		quietly generate __foc_post=.
	}
	sort market product, stable
	drop price_logit0 share_logit0
	rename __p_post price_logit
	rename __s_post share_logit
	rename __foc_post foc_post_logit
	drop __* 

	* random coefficient logit data simulation
	sort market product, stable
	global price price_logit
	global share share_logit
	capture quietly rcl $share $price $sample, market($market) msize($msize) mc($mc) xb0($xb0) ksi($ksi) alpha($alpha) rcsigmas($rcsigmas) rc($rc) msimulation($firm $firm) `acc_option' noest /*nodisplay*/
	scalar _rc_sim=_rc
	if (_rc!=0) {
		capture drop __p_post
		capture drop __s_post
		capture drop __foc_post
		quietly generate __p_post=$price
		quietly generate __s_post=$share
		quietly generate __foc_post=.
	}
	* variable management
	capture drop price
	capture drop share
	rename __p_post price
	rename __s_post share
	rename __foc_post foc
	drop __*
	quietly generate quantity=share*msize
	quietly generate mrkp=price-mc

	* instrument variables
	local todrops n ng nf nfg nfo nfog cc ccg ccf ccfg ccfo ccfog
	foreach todrop of local todrops {
		capture drop `todrop'
	}
	sort market g, stable
	by market: generate n=_N											// # of products
	by market g: generate ng=_N											// # of products in the same nest
	sort market firm g, stable
	by market firm: generate nf=_N										// # of products of the firm
	by market firm g: generate nfg=_N									// # of products of the firm in the same nest
	generate nfo=nf-1													// # of other products of the firm
	generate nfog=nfg-1													// # of other products of the firm in the same nest
	bys market: egen cc=total(x1)										// sum of continuous characteristics of products
	bys market g: egen ccg=total(x1)									// sum of continuous characteristics of products in the same nest
	bys market firm: egen ccf=total(x1)									// sum of continuous characteristics of products of the firm
	bys market firm g: egen ccfg=total(x1)								// sum of continuous characteristics of products of the firm in the same nest
	generate ccfo=ccf-x1												// sum of continuous characteristics of other products of the firm
	generate ccfog=ccfg-x1												// sum of continuous characteristics of other products of the firm in the same nest
	local todrops nf nfg ccf ccfg 
	foreach todrop of local todrops {									// drop collinear instruments
		capture drop `todrop'
	}
	foreach v of varlist x1 w* {
		quietly generate `v'_2=`v'^2
	}
	local vs0 x1 w1 w2 w3
	local vs1 `vs0'
	foreach v of varlist `vs0' {
		local vs1: list vs1 - v
		if ("`vs1'"!="") {
			foreach vv of varlist `vs1' {
				quietly generate `v'_`vv'=`v'*`vv'
			}
		}
	}

	* labelling
	capture label variable market `""market" identifier"'
	capture label variable product "product identifier"
	capture label variable g "nest's identifier"
	capture label variable h "subnest's identifier"
	capture label variable k "sub-subnest's identifier"
	capture label variable firm "firm identifier"
	capture label variable firm_post `""post-merger" firm identifier"'
	capture label variable price "price"
	capture label variable quantity "quantity"
	capture label variable share "share"
	capture label variable mrkp "markups"
	capture label variable mc "marginal costs"
	capture label variable x1 `""continuous" product characteristic""'
	capture label variable xb0 `""observed" part of mean utility"'
	capture label variable ksi `""unobserved" part of mean utility"'
	capture label variable msize "market size"
	capture label variable foc "first order conditions of equilibrium (consitent with price, share and mc)"
	capture label variable constant "constant variable"
	capture label variable omega "error term of price equation"
	capture label variable w1 "cost shifter 1"
	capture label variable w2 "cost shifter 2"
	capture label variable w3 "cost shifter 3"
	capture label variable n "# of products"
	capture label variable ng "# of products in the same nest"
	capture label variable nfo "# of other products of the firm"
	capture label variable nfog "# of other products of the firm in the same nest"
	capture label variable cc "sum of (continuous) characteristics of products"
	capture label variable ccg "sum of (continuous) characteristics of products in the same nest"
	capture label variable ccfo "sum of (continuous) characteristics of other products of the firm"
	capture label variable ccfog "sum of (continuous) characteristics of other products of the firm in the same nest"
	capture label variable w1_2 "square of cost shifter 1"
	capture label variable w2_2 "square of cost shifter 2"
	capture label variable w3_2 "square of cost shifter 3"
	capture label variable x1_2 "square of continuous characteristic"
	capture label variable w1_w2 "interaction of cost shifters 1 and 2"
	capture label variable w1_w3 "interaction of cost shifters 1 and 3"
	capture label variable w2_w3 "interaction of cost shifters 2 and 3"
	capture label variable x1_w1 "interaction of continuous characteristic and cost shifter 1"
	capture label variable x1_w2 "interaction of continuous characteristic and cost shifter 2"
	capture label variable x1_w3 "interaction of continuous characteristic and cost shifter 3"

	* saving final simulated dataset of current draw
	drop *logit
	sort market product, stable
	xtset product market
	order market product g h k firm firm_post price quantity share mrkp mc x1 xb0 ksi msize foc n* cc* x*_* w*_*
	quietly compress
	noisily save "`c(sysdir_plus)'r\rcl_test_data.dta", replace

}
	
* display summary results for draw
capture noisily sum price share mrkp mc foc

/* */
/* */
/* */
