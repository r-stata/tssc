*! _xtspecialreg  cfb  2sep2016  cloned from _sspecialreg 1.1.6
*! B723: synced to sspecialreg, 1.1.3
*! E902: synced to sspecialreg, 1.1.6

program define _xtspecialreg, rclass
version 11.0
syntax varlist, TOUSE(string) ENDOG(string) IV(string) ///
    EXOG(string) HETERO(string) HETV(string) KDENS(string) TRIM(string) [WINSOR(string)]

loc qq qui
	
loc D: word 1 of `varlist'
loc V: word 2 of `varlist'

	tempvar vee uhat uhat2 sc sigmau duhat fuhat T dxb sigma h kd dk m num tlim ttrm mu uuhat fuuhat ssc
	tempname dxb0 em mfx bee 
	
// loop over time periods to produce transformed depvar
	qui xtset
	loc st = r(tmin)
	loc nd = r(tmax)
	loc del = r(tdelta)
	loc tvar = r(timevar)
	qui g double `vee' = .
	qui g double `uhat' = .
	qui g double `fuhat' = .
	qui g double `sc' = .
	forv t =`st'(`del')`nd' {
//	di as err "`t'"

// demean special regressor for each time period
	su `V' if `touse' & `tvar' == `t', mean
	qui replace `vee' = `V' - r(mean) if `touse' & `tvar' == `t' 

// regress demeaned special regressor on endog, exog, iv for each time period
	`qq' reg `vee' `exog' `endog' `iv' if `touse' & `tvar' == `t' 
	capt drop `uuhat'
	qui predict double `uuhat' if `touse' & `tvar' == `t', resid 
	qui replace `uhat' = `uuhat' if `touse' & `tvar' == `t'
//	su `uuhat' `uhat'

// create uhat depending on hetero option
	if "`hetero'" == "hetero" {
		capt drop `uhat2'
		qui gen double `uhat2'=`uhat'^2 if `touse'  & `tvar' == `t'
		qui reg `uhat2'  `endog' `exog' `iv' `hetv' if `touse'  & `tvar' == `t'
		capt drop `ssc'
		qui predict double `ssc' if `touse' & `tvar' == `t', xb
		qui replace `sc' = `ssc' if `touse' & `tvar' == `t'
		qui replace `uhat' = `uhat'/sqrt(abs(`sc')) if `sc' != 0 & `tvar' == `t'
	di as err "hetero"
	su `uhat'
	}

// compute kernel density estimator via Jann's _kdens if KDENS; otherwise use sorted data density
// estimator (Ben Jann's translation) per SimpleStata2010
	capt drop `fuuhat'
	if "`kdens'" == "kdens" {
		qui _kdens `uhat' if `touse' & `tvar' == `t', kernel(epanechnikov) at(`uhat') gen(`fuuhat') 
	} 
	else {
	qui ssortedfm `uhat' if `touse' & `tvar' == `t', gen(`fuuhat')	
	}
// zrnd inline
	quietly replace `fuhat' = ((abs(`fuuhat')>10^(-20))*`fuuhat')+ ///
	((1-(abs(`fuuhat')>10^(-20)))*10^(-20)*((2*(`fuuhat'>0))-1))  if `touse' & `tvar' == `t'

// end loop over time periods
}
	
// create T variable: this should be able to be done over all panels

	if "`hetero'" != "hetero" {
		qui gen `T' = (`D' - ( `vee' >= 0)) / `fuhat' if `touse'
		}
	else {  
		qui gen `T' =(`D' - ( `vee' >= 0)) / `fuhat' * sqrt(abs(`sc')) if `touse' 
	}

// apply trimming / winsorizing
	loc ptrim = 100 - `trim'
	qui egen `tlim' = pctile(abs(`T')), p(`ptrim')
	qui gen byte `ttrm' = cond((abs(`T') > `tlim'), ., 1) 
	if "`winsor'" != "winsor" {
		markout `touse' `ttrm'
		qui count if mi(`ttrm')	
		loc delta = r(N)
	} 
	else {
		qui replace `T' = cond(`T' > `tlim', `tlim', cond(`T' < -1*`tlim', -1*`tlim', `T'))
		qui count if abs(`T') == `tlim'
		loc delta = r(N)
	}
// end of mods to T

// now apply within estimator to transformed depvar

   `qq' xtivreg `T' `exog' (`endog' = `iv') if `touse', fe
	
	qui predict double `dxb' if e(sample), xb
	qui replace `dxb' =`dxb' + `vee' if e(sample)

	qui su `dxb'
	loc k2 = r(N)
	qui g double `h' = 0.9 * r(sd) * r(N)^(-1/5)
	qui g double `m' = .
	mata: indfn("`dxb'", "`D'", "`h'", "`m'", "`touse'")
	su `m' if `touse', mean

	matrix `mfx' = r(mean) * [ 1, e(b) ]'
	loc nelt: word count `exog' `endog' 
	loc nelt = `nelt' + 2 // allow for V and constant
// mat li `mfx'
	forv i=1/`nelt' {
		return scalar mfx`i' =  `mfx'[`i', 1] 
	}
end

	version 11
	mata:
	void indfn(string scalar sdxb,
			   string scalar sd,
	           string scalar sh,
	           string scalar sm,
	           string scalar touse)
	{
		real scalar k2, j, zt, skd
		real colvector kd, em, num
		st_view(dxb, ., sdxb, touse)
		st_view(D, ., sd, touse)
		st_view(h, ., sh, touse)
		st_view(m, ., sm, touse)
		
		k2 = rows(dxb)
		kd = J(k2, 1, .)
		for(j=1; j<=k2; j++) {
			zt = (dxb :- dxb[j, 1]) :/ h
			kd =  0.75 :* ( 1 :- zt :^2) :* (abs(zt) :< 1 )
			skd = sum(kd)
			em = D :- sum(kd :* D) / skd
// correction: should be 0.75 * 2 Zt, not 0.75 * (1 + 2 Zt)
//			num = em :* ( 0.75 :* (1 :+ 2 :* zt) ) :* (abs(zt) :< 1 )
			num = em :* ( 1.5 :* zt) :* (abs(zt) :< 1 )
			m[j, 1] = sum(num) :/ (h[j, 1] :* skd ) 
		}
	}
	end
	exit
	
