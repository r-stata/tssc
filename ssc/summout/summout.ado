*! version 4.4 24dic2010
* command made byable
* got rid of function strtoname() to correct labels, now suitable for versions < 11
* fixed bug caused by variables without labels
* fixed bug caused by long variable lists
* added options nt and nolabel
* added variable and value labels on output matrix
* added options se, ci, level and dp
* fixed bug created by missing values in varlist
* added exporting into file capability (requires mat2txt)
* added option ignore
* added column with totals
* version 1.0 3jun2010
program define summout, sortpreserve byable(recall)
	version 9.2
	syntax varlist [if] [in] [using/], BY(varname) [IGnore se ci level(cilevel) dp(integer 2) noLabel nt(string)]
	marksample touse, novarlist

* ----- Preparación inicial, pruebas de normalidad y cálculo de totales
	local dp = string(abs(real("`dp'")))
	quietly: levelsof `by' if `touse', local(cats)
	foreach var in `varlist' {
		scalar _an`var' = 0
		foreach x of local cats {
			if "`nt'" == "sk" {
				quietly: sktest `var' if `touse' & `by' == `x'
				if r(P_chi2) < 0.05 | r(P_chi2) == . scalar _an`var' = scalar(_an`var') + 1
			}
			else if "`nt'" == "ks" {
				quietly: summ `var' if `touse' & `by' == `x'
				quietly: ksmirnov `var' = normal((`var'-r(mean))/r(sd)) if `touse' & `by' == `x'
				if r(p_cor) < 0.05 | r(p_cor) == . scalar _an`var' = scalar(_an`var') + 1
			}
			else {
				quietly: swilk `var' if `touse' & `by' == `x'
				if r(p) < 0.05 | r(p) == . scalar _an`var' = scalar(_an`var') + 1
			}
		}
		if scalar(_an`var') > 0 scalar _an`var' = 1
		if "`ignore'" == "ignore" scalar _an`var' = 0

		quietly: summarize `var' if `touse', detail
		if scalar(_an`var') == 1 {
			scalar _mtot`var' = round(r(p50),1e-`dp')
			scalar _dtot`var' = round(r(p75) - r(p25),1e-`dp')
		}
		else {
			scalar _mtot`var' = round(r(mean),1e-`dp')
			scalar _dtot`var' = round(r(sd),1e-`dp')
			if "`se'" == "se" scalar _dtot`var' = round((r(sd)/sqrt(r(N))),1e-`dp')
		}
		if "`ci'" == "ci" {
			if scalar(_an`var') == 1 {
				quietly: centile `var', level(`level')
				scalar _utot`var' = round(r(ub_1),1e-`dp')
				scalar _ltot`var' = round(r(lb_1),1e-`dp')
			}
			else {
				quietly: ci `var', level(`level')
				scalar _utot`var' = round(r(ub),1e-`dp')
				scalar _ltot`var' = round(r(lb),1e-`dp')
			}
		}

* ----- Cálculo de las medidas de tendencia central y dispersión
		foreach x of local cats {
			quietly: summarize `var' if `touse' & `by' == `x', detail
			if scalar(_an`var') == 1 {
				scalar _m`x'`var' = round(r(p50),1e-`dp')
				scalar _d`x'`var' = round(r(p75) - r(p25),1e-`dp')
			}
			else {
				scalar _m`x'`var' = round(r(mean),1e-`dp')
				scalar _d`x'`var' = round(r(sd),1e-`dp')
				if "`se'" == "se" scalar _d`x'`var' = round((r(sd)/sqrt(r(N))),1e-`dp')
			}
			if "`ci'" == "ci" {
				if scalar(_an`var') == 1 {
					quietly: centile `var' if `touse' & `by' == `x', level(`level')
					scalar _u`x'`var' = round(r(ub_1),1e-`dp')
					scalar _l`x'`var' = round(r(lb_1),1e-`dp')
				}
				else {
					quietly: ci `var' if `touse' & `by' == `x', level(`level')
					scalar _u`x'`var' = round(r(ub),1e-`dp')
					scalar _l`x'`var' = round(r(lb),1e-`dp')
				}
			}
		}

* ----- Prueba de hipótesis y valor de p de la comparación
		if scalar(_an`var') == 1 {
			quietly: kwallis `var' if `touse', by(`by')
			scalar _pv`var' = chi2tail(r(df),r(chi2_adj))
		}
		else {
			quietly: oneway `var' `by' if `touse'
			scalar _pv`var' = Ftail(r(df_m),r(df_r),r(F))
		}
	}

* ----- Creación de la matriz con resultados y salida
	if "`ci'" == "ci" {
		local _vlwc : word count `varlist'
		matrix _final = J(`_vlwc',(wordcount("`cats'")*3)+5,.)
		scalar _i1 = 0
		foreach var in `varlist' {
			scalar _i1 = scalar(_i1) + 1
			matrix _final[scalar(_i1),1] = scalar(_an`var')
			scalar _i2 = 0
			foreach x of local cats {
				scalar _i2 = scalar(_i2) + 3
				matrix _final[scalar(_i1),scalar(_i2)-1] = scalar(_m`x'`var')
				matrix _final[scalar(_i1),scalar(_i2)] = scalar(_l`x'`var')
				matrix _final[scalar(_i1),scalar(_i2)+1] = scalar(_u`x'`var')
			}
			matrix _final[scalar(_i1),(wordcount("`cats'")*3)+2] = scalar(_mtot`var')
			matrix _final[scalar(_i1),(wordcount("`cats'")*3)+3] = scalar(_ltot`var')
			matrix _final[scalar(_i1),(wordcount("`cats'")*3)+4] = scalar(_utot`var')
			matrix _final[scalar(_i1),(wordcount("`cats'")*3)+5] = scalar(_pv`var')
		}
		if "`label'" == "nolabel" {
			matrix rownames _final = `varlist'
			local fmcn ""
			foreach x of local cats {
				local fmcn `"`fmcn' `by'==`x':est `by'==`x':lb `by'==`x':ub"'
			}
			matrix colnames _final = nonparam `fmcn' total:est total:lb total:ub "p value"
		}
		else {
			foreach var in `varlist' {
				local vl`var' : variable label `var'
				if "`vl`var''" == "" local vl`var' = "`var'"
				local vl`var' = subinstr("`vl`var''",".","",.)
				local vl`var' = subinstr("`vl`var''",":","",.)
				local vl`var' `""`vl`var''""'
			}
			local fmrns ""
			foreach var in `varlist' {
				local fmrns `"`fmrns'`vl`var''"'
			}
			matrix rownames _final = `fmrns'
			local fmcn ""
			foreach x of local cats {
				local vlc : label (`by') `x'
				local vlc = subinstr("`vlc'",".","",.)
				local vlc = subinstr("`vlc'",":","",.)
				local fmcn `"`fmcn'"`vlc':est""`vlc':lb""`vlc':ub""'
			}
			matrix colnames _final = nonparam `fmcn' total:est total:lb total:ub "p value"
		}
	}
	else {
		local _vlwc : word count `varlist'
		matrix _final = J(`_vlwc',(wordcount("`cats'")*2)+4,.)
		scalar _i1 = 0
		foreach var in `varlist' {
			scalar _i1 = scalar(_i1) + 1
			matrix _final[scalar(_i1),1] = scalar(_an`var')
			scalar _i2 = 0
			foreach x of local cats {
				scalar _i2 = scalar(_i2) + 2
				matrix _final[scalar(_i1),scalar(_i2)] = scalar(_m`x'`var')
				matrix _final[scalar(_i1),scalar(_i2)+1] = scalar(_d`x'`var')
			}
			matrix _final[scalar(_i1),(wordcount("`cats'")*2)+2] = scalar(_mtot`var')
			matrix _final[scalar(_i1),(wordcount("`cats'")*2)+3] = scalar(_dtot`var')
			matrix _final[scalar(_i1),(wordcount("`cats'")*2)+4] = scalar(_pv`var')
		}
		if "`label'" == "nolabel" {
			matrix rownames _final = `varlist'
			local fmcn ""
			foreach x of local cats {
				local fmcn `"`fmcn' `by'==`x':est `by'==`x':dis"'
			}
			matrix colnames _final = nonparam `fmcn' total:est total:dis "p value"
		}
		else {
			foreach var in `varlist' {
				local vl`var' : variable label `var'
				if "`vl`var''" == "" local vl`var' = "`var'"
				local vl`var' = subinstr("`vl`var''",".","",.)
				local vl`var' = subinstr("`vl`var''",":","",.)
				local vl`var' `""`vl`var''""'
			}
			local fmrns ""
			foreach var in `varlist' {
				local fmrns `"`fmrns'`vl`var''"'
			}
			matrix rownames _final = `fmrns'
			local fmcn ""
			foreach x of local cats {
				local vlc : label (`by') `x'
				local vlc = subinstr("`vlc'",".","",.)
				local vlc = subinstr("`vlc'",":","",.)
				local fmcn `"`fmcn'"`vlc':est""`vlc':dis""'
			}
			matrix colnames _final = nonparam `fmcn' total:est total:dis "p value"
		}
	}

* -----	Exportación de la matriz a un archivo
	if "`using'" != "" {
		file open export using "`using'", write append
		file write export _n "Comparative table of summary statistics across categories of `by'" _n
		if "`ignore'" == "ignore" file write export "Warning: all variables assumed normal" _n(2)
		file close export
		mat2txt, matrix(_final) saving("`using'") append
	}

* ----- Salida y cierre
	di _newline "Comparative table of summary statistics"
	if "`ignore'" == "ignore" di _newline "Warning: all variables assumed normal"
	matrix list _final, noh
*	scalar drop _all
*	macro drop _all
end
