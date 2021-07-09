*! ira 0.1.0 2017-11-01
*! Copyright (c) 2017 Lorenz Graf-Vlachy
*! mail@graf-vlachy.com

* Version history at bottom

cap program drop ira
prog define ira, rclass byable(recall)

	local debug 0 

	
	version 9
	syntax varlist(min=2 max=2) [if] [in] [, item(varname) group(varname) options(integer 7) distribution(real -1)]
	marksample touse

	
	if (`options' < 2) { 
		di as err "Invalid value: Scale cannot have a less than two response options"
		exit 198    
	}
	if (`distribution' == 0) { 
		di as err "Invalid value: Variance of user-specified null distribution cannot be zero"
		exit 198    
	}
	
	
	preserve
	
	
	qui drop if !`touse'
	
	
	tokenize `varlist'
	local judge `1'
	local rating `2'
	
	
	if "`group'" == "" {
		tempvar group 
		gen `group' = 0
	}
	if "`item'" == "" {
		tempvar item 
		gen `item' = 0
	}

	
	keep `judge' `rating' `group' `item'
	
	
	qui {
		drop if mi(`item')
		drop if mi(`judge')
		drop if mi(`rating')
		drop if mi(`group')
	}

	
	if _N == 0 {
		di as err "No data"
		exit 198
	}
	tempname N
	qui scalar `N' = _N
	
	
	cap confirm numeric variable `rating'
	if _rc != 0 { 
		cap destring `rating', replace
		if _rc != 0 { 
			di as err "Invalid data: Ratings contain non-numeric value(s)"
			exit 198
		}
		cap confirm integer variable `rating' 
		if _rc != 0 { 
			di as err "Invalid data: Ratings contain non-numeric value(s)"
			exit 198
		}
	}
	cap confirm integer variable `rating'
	if _rc != 0 { 
		tempvar tmp
		cap gen int `tmp' = `rating'
		cap assert `tmp' == `rating' 
		if _rc != 0 {
			di "Warning: Ratings contain non-integer value(s)"
		}
		else {
			drop `tmp'
		}
	}

	
	qui egen tmp = group(`item') 
	qui sum tmp
	tempname J
	qui scalar `J' = r(max) 
	if `debug' di "Number of items: " `J'
	drop tmp
	if `J' == 0 {
		di as err "No data"
		exit 198
	}

	
	tempvar tmp
	qui egen `tmp' = group(`group') 
	qui sum `tmp'
	tempname num_groups
	qui scalar `num_groups' = r(max) 
	if `debug' di "Number of groups: " `num_groups'
	drop `tmp'
	if `num_groups' == 0 {
		di as err "No data"
		exit 198
	}

	
	qui sum `rating'
	if (r(max) > `options') { 
		di as err "Invalid value: Data contains rating(s) > `options', outside the scale range"
		exit 198
	}
	if (r(min) < 1) { 
		di as err "Invalid value: Data contains rating(s) < 1, outside the scale range"
		exit 198
	}

	
	tempvar N_judge_per_group
	bys `group' `judge': gen `N_judge_per_group' = _N
	cap assert `N_judge_per_group' == `J'
	drop `N_judge_per_group'
	if _rc != 0 {
		di as err "Not all judges provided exactly one rating per item per group"
		di "Possible causes:"
		di "- Missing data: Not all judges provided ratings for all items"
		di "- Duplicate data: Judge(s) provided multiple ratings for items"
		di "- Command misspecification: Please check if specification of groups and items is correct"
		exit 198
	}
	
	
	tempname sigeu2_unif sigeu2_slight_skew sigeu2_mod_skew sigeu2_heavy_skew sigeu2_tri sigeu2_norm
	qui scalar `sigeu2_unif' = sum(`options' ^ 2 - 1) / 12 
	if `options' == 5 { 
		scalar `sigeu2_slight_skew' = 1.34
		scalar `sigeu2_mod_skew' = .90
		scalar `sigeu2_heavy_skew' = .44
		scalar `sigeu2_tri' = 1.32
		scalar `sigeu2_norm' = 1.04
	}
	else if `options' == 6 {
		scalar `sigeu2_slight_skew' = 1.85
		scalar `sigeu2_mod_skew' = 1.26
		scalar `sigeu2_heavy_skew' = .69
		scalar `sigeu2_tri' = 1.45
		scalar `sigeu2_norm' = 1.25
	}
	else if `options' == 7 {
		scalar `sigeu2_slight_skew' = 2.90
		scalar `sigeu2_mod_skew' = 2.14
		scalar `sigeu2_heavy_skew' = 1.39
		scalar `sigeu2_tri' = 2.10
		scalar `sigeu2_norm' = 1.40
	}
	else if `options' == 8 {
		scalar `sigeu2_slight_skew' = 3.47
		scalar `sigeu2_mod_skew' = 2.79
		scalar `sigeu2_heavy_skew' = 2.35
		scalar `sigeu2_tri' = 2.81
		scalar `sigeu2_norm' = 1.73
	}
	else if `options' == 9 {
		scalar `sigeu2_slight_skew' = 5.66
		scalar `sigeu2_mod_skew' = 4.73
		scalar `sigeu2_heavy_skew' = 3.16
		scalar `sigeu2_tri' = 3.00
		scalar `sigeu2_norm' = 1.58
	}
	else if `options' == 10 {
		scalar `sigeu2_slight_skew' = 6.30
		scalar `sigeu2_mod_skew' = 5.09
		scalar `sigeu2_heavy_skew' = 3.46
		scalar `sigeu2_tri' = 2.89
		scalar `sigeu2_norm' = 1.45
	}
	else if `options' == 11 {
		scalar `sigeu2_slight_skew' = 7.31
		scalar `sigeu2_mod_skew' = 6.32
		scalar `sigeu2_heavy_skew' = 4.02
		scalar `sigeu2_tri' = 3.32
		scalar `sigeu2_norm' = 1.40
	}
	
	
	tempname XU XL sigmv2
	scalar `XU' = `options' 
	scalar `XL' = 1 
	scalar `sigmv2' = .5 * (`XU'^2 + `XL'^2) - ( .5 * (`XU'+ `XL')) ^ 2 
	
	
	
	tempvar k M Md sigmpvm2 lo hi
	bys `group' `item': gen `k' = _N 
	bys `group' `item': egen `M' = mean(`rating') 
	qui gen `sigmpvm2' = ((`XU' + `XL') * `M' - (`M' ^ 2) - (`XU' * `XL')) * (`k' / (`k' - 1)) 
	
	qui gen `lo' = (1 * (`k' - 1) + `options') / `k' 
	qui gen `hi' = (`options' * (`k' - 1) + 1) / `k' 
	
	qui replace `sigmpvm2' = . if `M' < `lo'
	qui replace `sigmpvm2' = . if `M' > `hi'

	
	tempvar item_mean 
	egen `item_mean' = mean(`rating'), by(`group' `item')
	tempvar rating_dev_form 
	gen `rating_dev_form' = `rating' - `item_mean'
	tempvar Ym2
	egen `Ym2' = mean(`rating_dev_form'), by(`group' `judge') 
	qui replace `Ym2' = `Ym2' ^ 2 

	
	tempvar ADM ADMd
	bys `group' `item': egen `Md' = median(`rating') 
	tempvar absdiff_mean absdiff_median
	gen `absdiff_mean' = abs(`rating' - `M')
	egen `ADM' = total(`absdiff_mean'), by(`group' `item')
	qui replace `ADM' = `ADM' / `k'
	gen `absdiff_median' = abs(`rating' - `Md')
	egen `ADMd' = total(`absdiff_median'), by(`group' `item')
	qui replace `ADMd' = `ADMd' / `k'
	
	
	tempvar SD Sx2 Sx2_bar rwg_unif rwg_custom rstarwg awg sY2
	egen `SD' = sd(`rating'), by(`item' `group')
	gen `Sx2' = `SD' ^ 2
	egen `Sx2_bar' = mean(`Sx2'), by(`group') 
	
	gen `rstarwg' = 1 - (`Sx2_bar' / `sigeu2_unif') 
	
	qui gen `awg' = 1 - (( 2 * `Sx2' ) / `sigmpvm2') 
	qui replace `awg' = 1 if mi(`sigmpvm2') 
	
	gen `rwg_unif' = `J' * (1 - (`Sx2_bar' / `sigeu2_unif')) / (`J' * (1 - (`Sx2_bar' / `sigeu2_unif')) + (`Sx2_bar' / `sigeu2_unif')) 
	gen `rwg_custom' = `J' * (1 - (`Sx2_bar' / `distribution')) / (`J' * (1 - (`Sx2_bar' / `distribution')) + (`Sx2_bar' / `distribution')) 
	local non_unif slight_skew mod_skew heavy_skew tri norm 
	if `options' >= 5 & `options' <= 11 { 
		foreach x in `non_unif' {
			tempvar rwg_`x'
			gen `rwg_`x'' = `J' * (1 - (`Sx2_bar' / `sigeu2_`x'')) / (`J' * (1 - (`Sx2_bar' / `sigeu2_`x'')) + (`Sx2_bar' / `sigeu2_`x''))
		}
		collapse (mean) `rwg_unif' `rwg_slight_skew' `rwg_mod_skew' `rwg_heavy_skew' `rwg_tri' `rwg_norm' `rwg_custom' `rstarwg' `sY2'=`Ym2' `awg' `ADM' `ADMd' `k', by(`group')
	}
	else { 
		collapse (mean) `rwg_unif' `rwg_custom' `rstarwg' `sY2'=`Ym2' `awg' `ADM' `ADMd' `k', by(`group')
	}

	
	tempvar rapowgA rapowgB sMV2 rapowgC rapowgD
	gen `rapowgA' = 1 - ( `sY2' / ((1 / `J') * `sigeu2_unif')) 
	gen `rapowgB' = 1 - ( `sY2' / `sigeu2_unif') 
	gen `rapowgC' = 1 - ( `sY2' / ((1 / `J') * `sigmv2')) 
	gen `rapowgD' = 1 - ( `sY2' / `sigmv2') 

	
	if `debug' {
		di _n "rwg_unif by group"
		list `group' `rwg_unif'
		di _n "rwg_custom by group"
		list `group' `rwg_custom'
		di _n "rstarwg by group"
		list `group' `rstarwg'
		di _n "rapowgA by group"
		list `group' `rapowgA'
		di _n "rapowgB by group"
		list `group' `rapowgB'
		di _n "rapowgC by group"
		list `group' `rapowgC'
		di _n "rapowgD by group"
		list `group' `rapowgD'
		di _n "awg by group"
		list `group' `awg'
		di _n "ADM by group"
		list `group' `ADM'
		di _n "ADMd by group"
		list `group' `ADMd'
	}

	
	qui sum `rwg_unif', detail
	tempname rwg_unif_min rwg_unif_max
	scalar `rwg_unif_min' = r(min)
	if `debug' di `rwg_unif_min'
	scalar `rwg_unif_max' = r(max)
	if `debug' di `rwg_unif_max'
	
	if `options' >= 5 & `options' <= 11 {
		foreach x in `non_unif' {
			qui sum `rwg_`x'', detail
			tempvar rwg_`x'_min rwg_`x'_max
			scalar `rwg_`x'_min' = r(min)
			if `debug' di `rwg_`x'_min'
			scalar `rwg_`x'_max' = r(max)
			if `debug' di `rwg_`x'_max'
		}
	}
	
	qui sum `rwg_custom', detail
	tempname rwg_custom_min rwg_custom_max
	scalar `rwg_custom_min' = r(min)
	if `debug' di `rwg_custom_min'
	scalar `rwg_custom_max' = r(max)
	if `debug' di `rwg_custom_max'

	
	qui replace `rwg_unif' = 0 if `rwg_unif' < 0 | `rwg_unif' > 1 
	qui replace `rwg_custom' = 0 if `rwg_custom' < 0 | `rwg_custom' > 1 
	
	if `options' >= 5 & `options' <= 11 {
		foreach x in `non_unif' {
			qui replace `rwg_`x'' = 0 if `rwg_`x'' < 0 | `rwg_`x'' > 1
		}
	}

	
	qui sum `rwg_unif', detail
	tempname rwg_unif_mean rwg_unif_median rwg_unif_range
	scalar `rwg_unif_mean' = r(mean)
	if `debug' di `rwg_unif_mean'
	scalar `rwg_unif_median' = r(p50)
	if `debug' di `rwg_unif_median'
	scalar `rwg_unif_range' = r(max) - r(min)
	if `debug' di `rwg_unif_range'
	
	if `options' >= 5 & `options' <= 11 {
		foreach x in `non_unif' {
			qui sum `rwg_`x'', detail
			tempname rwg_`x'_mean rwg_`x'_median rwg_`x'_range
			scalar `rwg_`x'_mean' = r(mean)
			if `debug' di `rwg_`x'_mean'
			scalar `rwg_`x'_median' = r(p50)
			if `debug' di `rwg_`x'_median'
			scalar `rwg_`x'_range' = r(max) - r(min)
			if `debug' di `rwg_`x'_range'
		}
	}
	
	local otherstats rstarwg awg ADM ADMd rapowgA rapowgB rapowgC rapowgD rwg_custom
	foreach stat in `otherstats' {
		qui sum ``stat'', detail
		tempname `stat'_mean `stat'_median `stat'_range
		scalar ``stat'_mean' = r(mean)
		if `debug' di ``stat'_mean'
		scalar ``stat'_median' = r(p50)
		if `debug' di ``stat'_median'
		scalar ``stat'_range' = r(max) - r(min)
		if `debug' di ``stat'_range'
	}
	
	
	tempname missing_awg
	qui count if missing(`awg')
	qui scalar `missing_awg' = r(N)

	
	tempname min_k
	qui sum `k'
	scalar `min_k' = r(min)
	
	
	di as text _n	"Number of observations (N)                 = " `N'
	di as text 		"Number of items (J)                        = " `J'
	di as text		"Number of groups                           = " `num_groups'
	di as text		"Response options (A)                       = " `options'
	

	di as text _n "Interrater agreement (across groups)        {c |} Mean    {c |} Median  {c |} Range"
	di as text "{hline 44}{c +}{hline 9}{c +}{hline 9}{c +}{hline 9}"
	di as text "rwg(j) [null distribution: uniform]         {c |} " _c
		if `rwg_unif_mean' >= 0 di " " _c
		di as result %5.4f `rwg_unif_mean' as text " {c |} " _c
		if `rwg_unif_median' >= 0 di " " _c
		di as result %5.4f `rwg_unif_median' as text " {c |} " _c
		if `rwg_unif_range' >= 0 di " " _c
		di as result %5.4f `rwg_unif_range'
		if `rwg_unif_min' < 0 di as text "   Note: rwg < 0 in at least one group      {c |}         {c |}         {c |}"
		if `rwg_unif_max' > 1 di as text "   Note: rwg > 1 in at least one group      {c |}         {c |}         {c |}"
	if `options' >= 5 & `options' <= 11 {
		di as text "rwg(j) [null distribution: slight skew]     {c |} " _c
		if `rwg_slight_skew_mean' >= 0 di " " _c
		di as result %5.4f `rwg_slight_skew_mean' as text " {c |} " _c
		if `rwg_slight_skew_median' >= 0 di " " _c
		di as result %5.4f `rwg_slight_skew_median' as text " {c |} " _c
		if `rwg_slight_skew_range' >= 0 di " " _c
		di as result %5.4f `rwg_slight_skew_range'
		if `rwg_slight_skew_min' < 0 di as text "   Note: rwg < 0 in at least one group      {c |}         {c |}         {c |}"
		if `rwg_slight_skew_max' > 1 di as text "   Note: rwg > 1 in at least one group      {c |}         {c |}         {c |}"
		di as text "rwg(j) [null distribution: moderate skew]   {c |} " _c
		if `rwg_mod_skew_mean' >= 0 di " " _c
		di as result %5.4f `rwg_mod_skew_mean' as text " {c |} " _c
		if `rwg_mod_skew_median' >= 0 di " " _c
		di as result %5.4f `rwg_mod_skew_median' as text " {c |} " _c
		if `rwg_mod_skew_range' >= 0 di " " _c
		di as result %5.4f `rwg_mod_skew_range'
		if `rwg_mod_skew_min' < 0 di as text "   Note: rwg < 0 in at least one group      {c |}         {c |}         {c |}"
		if `rwg_mod_skew_max' > 1 di as text "   Note: rwg > 1 in at least one group      {c |}         {c |}         {c |}"
		di as text "rwg(j) [null distribution: heavy skew]      {c |} " _c
		if `rwg_heavy_skew_mean' >= 0 di " " _c
		di as result %5.4f `rwg_heavy_skew_mean' as text " {c |} " _c
		if `rwg_heavy_skew_median' >= 0 di " " _c
		di as result %5.4f `rwg_heavy_skew_median' as text " {c |} " _c
		if `rwg_heavy_skew_range' >= 0 di " " _c
		di as result %5.4f `rwg_heavy_skew_range'
		if `rwg_heavy_skew_min' < 0 di as text "   Note: rwg < 0 in at least one group      {c |}         {c |}         {c |}"
		if `rwg_heavy_skew_max' > 1 di as text "   Note: rwg > 1 in at least one group      {c |}         {c |}         {c |}"
		di as text "rwg(j) [null distribution: triangular]      {c |} " _c
		if `rwg_tri_mean' >= 0 di " " _c
		di as result %5.4f `rwg_tri_mean' as text " {c |} " _c
		if `rwg_tri_median' >= 0 di " " _c
		di as result %5.4f `rwg_tri_median' as text " {c |} " _c
		if `rwg_tri_range' >= 0 di " " _c
		di as result %5.4f `rwg_tri_range'
		if `rwg_tri_min' < 0 di as text "   Note: rwg < 0 in at least one group      {c |}         {c |}         {c |}"
		if `rwg_tri_max' > 1 di as text "   Note: rwg > 1 in at least one group      {c |}         {c |}         {c |}"
		di as text "rwg(j) [null distribution: normal]          {c |} " _c
		if `rwg_norm_mean' >= 0 di " " _c
		di as result %5.4f `rwg_norm_mean' as text " {c |} " _c
		if `rwg_norm_median' >= 0 di " " _c
		di as result %5.4f `rwg_norm_median' as text " {c |} " _c
		if `rwg_norm_range' >= 0 di " " _c
		di as result %5.4f `rwg_norm_range'
		if `rwg_norm_min' < 0 di as text "   Note: rwg < 0 in at least one group      {c |}         {c |}         {c |}"
		if `rwg_norm_max' > 1 di as text "   Note: rwg > 1 in at least one group      {c |}         {c |}         {c |}"
	}
	if `distribution' != -1 { 
		di as text "{hline 44}{c +}{hline 9}{c +}{hline 9}{c +}{hline 9}"
			di as text "rwg(j) [null distribution variance: " %5.4f `distribution' "] {c |} " _c
			if `rwg_custom_mean' >= 0 di " " _c
			di as result %5.4f `rwg_custom_mean' as text " {c |} " _c
			if `rwg_custom_median' >= 0 di " " _c
			di as result %5.4f `rwg_custom_median' as text " {c |} " _c
			if `rwg_custom_range' >= 0 di " " _c
			di as result %5.4f `rwg_custom_range'
			if `rwg_custom_min' < 0 di as text "   Note: rwg < 0 in at least one group      {c |}         {c |}         {c |}"
			if `rwg_custom_max' > 1 di as text "   Note: rwg > 1 in at least one group      {c |}         {c |}         {c |}"
	}
	di as text "{hline 44}{c +}{hline 9}{c +}{hline 9}{c +}{hline 9}"
		di as text "r*wg(j)                                     {c |} " _c
		if `rstarwg_mean' >= 0 di " " _c
		di as result %5.4f `rstarwg_mean' as text " {c |} " _c
		if `rstarwg_median' >= 0 di " " _c
		di as result %5.4f `rstarwg_median' as text " {c |} " _c
		if `rstarwg_range' >= 0 di " " _c
		di as result %5.4f `rstarwg_range' 
	di as text "{hline 44}{c +}{hline 9}{c +}{hline 9}{c +}{hline 9}"
		di as text "r'wg(A)                                     {c |} " _c
		if `rapowgA_mean' >= 0 di " " _c
		di as result %5.4f `rapowgA_mean' as text " {c |} " _c
		if `rapowgA_median' >= 0 di " " _c
		di as result %5.4f `rapowgA_median' as text " {c |} " _c
		if `rapowgA_range' >= 0 di " " _c
		di as result %5.4f `rapowgA_range'
		di as text "r'wg(B)                                     {c |} " _c
		if `rapowgB_mean' >= 0 di " " _c
		di as result %5.4f `rapowgB_mean' as text " {c |} " _c
		if `rapowgB_median' >= 0 di " " _c
		di as result %5.4f `rapowgB_median' as text " {c |} " _c
		if `rapowgB_range' >= 0 di " " _c
		di as result %5.4f `rapowgB_range'
		di as text "r'wg(C)                                     {c |} " _c
		if `rapowgC_mean' >= 0 di " " _c
		di as result %5.4f `rapowgC_mean' as text " {c |} " _c
		if `rapowgC_median' >= 0 di " " _c
		di as result %5.4f `rapowgC_median' as text " {c |} " _c
		if `rapowgC_range' >= 0 di " " _c
		di as result %5.4f `rapowgC_range'
		di as text "r'wg(D)                                     {c |} " _c
		if `rapowgD_mean' >= 0 di " " _c
		di as result %5.4f `rapowgD_mean' as text " {c |} " _c
		if `rapowgD_median' >= 0 di " " _c
		di as result %5.4f `rapowgD_median' as text " {c |} " _c
		if `rapowgD_range' >= 0 di " " _c
		di as result %5.4f `rapowgD_range'
	di as text "{hline 44}{c +}{hline 9}{c +}{hline 9}{c +}{hline 9}"
		di as text "awg(j)                                      {c |} " _c
		if `awg_mean' >= 0 di " " _c
		di as result %5.4f `awg_mean' as text " {c |} " _c
		if `awg_median' >= 0 di " " _c
		di as result %5.4f `awg_median' as text " {c |} " _c
		if `awg_range' >= 0 di " " _c
		di as result %5.4f `awg_range'
		if `missing_awg' != 0 {
			di as text "   Note: awg(j) omitted for " %4.0f `missing_awg' " group" _c
			if `missing_awg' == 1 {
				di " " _c
			}
			else {
				di "s" _c
			}
			di "     {c |}         {c |}         {c |}"
		}
	di as text "{hline 44}{c +}{hline 9}{c +}{hline 9}{c +}{hline 9}"
		di as text "ADM(j)                                      {c |} " _c
		if `ADM_mean' >= 0 di " " _c
		di as result %5.4f `ADM_mean' as text " {c |} " _c
		if `ADM_median' >= 0 di " " _c
		di as result %5.4f `ADM_median' as text " {c |} " _c
		if `ADM_range' >= 0 di " " _c
		di as result %5.4f `ADM_range'
		di as text "ADMd(j)                                     {c |} " _c
		if `ADMd_mean' >= 0 di " " _c
		di as result %5.4f `ADMd_mean' as text " {c |} " _c
		if `ADMd_median' >= 0 di " " _c
		di as result %5.4f `ADMd_median' as text " {c |} " _c
		if `ADMd_range' >= 0 di " " _c
		di as result %5.4f `ADMd_range'
	
	
	return scalar N = `N'
	return scalar J = `J'
	return scalar groups = `num_groups'
	return scalar A = `options'
	return scalar rwg_unif_mean = `rwg_unif_mean'
	return scalar rwg_unif_median = `rwg_unif_median'
	return scalar rwg_unif_range = `rwg_unif_range'
	if `options' >= 5 & `options' <= 11 {
		foreach x in `non_unif' {
			return scalar rwg_`x'_mean = `rwg_`x'_mean'
			return scalar rwg_`x'_median = `rwg_`x'_median'
			return scalar rwg_`x'_range = `rwg_`x'_range'
		}
	}
	local otherstats rwg_custom rstarwg awg ADM ADMd rapowgA rapowgB rapowgC rapowgD
	foreach stat in `otherstats' {
		return scalar `stat'_mean = ``stat'_mean'
		return scalar `stat'_median = ``stat'_median'
		return scalar `stat'_range = ``stat'_range'
	}

	
	restore 

end

* Version history
* 
* 0.1.0	Initial version
