*! bihist graphs bihistograms: histograms for two categories shown in opposite directions from the abscissa
*! bihist 1.3 19 Apr 2010 Austin Nichols added tw1 option
* bihist 1.2 3 Dec 2008 Austin Nichols added support for string by var
* bihist 1.1 26 Nov 2008 Austin Nichols fixed labels, added options
* bihist 1.0 26 Aug 2008 Austin Nichols
prog bihist, rclass
version 8.2
syntax varname [fw aw pw] [if] [in], by(string) [FREQuency FRACtion DENSity percent name(passthru) tw(string) tw1(string) otol(int 2) SUPpress * ]
* note undocumented otol sets tolerance for order (power of ten) above which to convert units to integers
* and option tw passes options to the final twoway graph--all other options * are passed to twoway__histogram_gen
gettoken by byopt: by
loc by: subinstr local by "," "", all
marksample touse
cap conf numeric var `by'
if _rc {
 tempvar b
 encode `by', gen(`b')
 loc byvar "`by'"
 loc by "`b'"
 di as smcl as err "Variable `by' not numeric;" 
 di as smcl as err "using {help encode} to make a numeric variable"
 di as smcl as err "which may change the ordering of categories."
 }
else loc byvar "`by'"
markout `touse' `by'
tempvar nvals
qui bys `touse' `by' : gen byte `nvals' =(_n == 1)*`touse'*(`by'<.)
su `nvals' if `touse', meanonly
if r(sum)!=2 {
 di as err "Variable `by' should have two distinct values but has " r(sum)
 err 198
 }
loc v `varlist'
tempvar x y wt sum wtvar
loc u = 1
qui if "`weight'"!="" {
 loc wtvar: subinstr local exp "=" "", all
 capture assert float(`v') == float(round(`v',1)) if `touse'
 if _rc == 0 {
 	while _rc == 0 {
 		loc u = `u'*10
 		capture assert float(`v') == float(round(`v',`u')) if `touse'
 	}
 	loc u = `u'/10
 }
 else {
 	while _rc {
 		loc u = `u'/10
 		capture assert float(`v') == float(round(`v',`u')) if `touse'
 	}
 }
 qui g `wt'`exp'/`u'
 loc tempwt "fw=`wt'"
 markout `touse' `wt'
 }
else g `wtvar'=1
if "`percent'"!="" loc fraction="fraction"
if "`frequency'`fraction'`density'"=="" loc frequency "frequency"
twoway__histogram_gen `v' if `touse' [`tempwt'],gen(`x' `y') `frequency' `fraction' `density' `options'
loc s=r(min)
loc w=r(width)
loc b=r(bin)+1
return local min=`s'
return local width=`w'
return local bin=`b'-1
qui {
replace `x'=.
replace `x'=`s'+`w'/2 if (`v'>=`s')&(`v'<=`s'+`w')
forv i=2/`b' {
 replace `x'=`s'+(2*`i'-1)*`w'/2 if (`v'>=`s'+(`i'-1)*`w')&(`v'<`s'+(`i')*`w')
 }
replace `x'=`s'+(2*`b'-1)*`w'/2 if float(`v')==float(`s'+(`b')*`w')
}
qui replace `y'=(`v'<.)
loc xl=cond(`"`:var lab `v''"'=="","`v'",`"`:var lab `v''"')
preserve
qui keep if `touse'
cap drop `y'
la val `x' `: value label `v''
qui egen double `y'=sum(`wtvar'), by(`by' `x') 
 collapse `y',  by(`by' `x') fast
bys `by': g double `sum'=sum(`y')
if "`fraction'"!="" qui by `by': replace `y'=`y'/`sum'[_N]
if "`percent'"!=""  qui by `by': replace `y'=`y'*100
if "`density'"!=""  qui by `by': replace `y'=`y'/`sum'[_N]/`w'
qui levelsof `by', loc(bl)
tokenize `bl'
su `y', meanonly
loc m=r(max)
tempname matrix mat
forv ni=1/`=_N' {
 matrix `mat'=(`=`by'[`ni']',`=`x'[`ni']',`=`y'[`ni']')
 matrix `matrix'=nullmat(`matrix')\ `mat'
 }
loc frac=cond("`percent'"=="","`fraction'","`percent'")
matrix `matrix'=`mat'
matrix colnames `matrix'=`byvar' `v' `frequency'`frac'`density'
return matrix b=`matrix'
qui replace `y'=-`y' if `by'==`1'
loc o: di int(log10(`m'))-1
if abs(`o')>`otol' {
 loc M=ceil(`m'/10^`o')
 qui replace `y'=`y'/10^`o'
 }
else loc M=ceil(`m'/10^`o')*10^`o'
loc p=cond(length("`:di `M'/3'")<length("`:di `M'/4'"),3,4)
loc l "ylabel("
forv i=-`p'/`p' {
 loc l `"`l' `=`M'*`i'/`p'' "`:di `M'*abs(`i')/`p''" "'
}
loc l `"`l')"'
loc l `"`l' yti("`:di proper("`frequency'`frac'`density'")' "'
if `o'>`otol'  loc l `"`l'in `=trim("`: di %20.0gc `:di 10^(`o')''")'s")"'
if `o'<-`otol' loc l `"`l'in `=trim("`: di %20.0gc `:di 10^-(`o')''")'ths")"'
if abs(`o')<=`otol' loc l `"`l'")"'
if `"`xl'"'!="" loc l `"`l' xti(`xl')"'
loc l `"`l' leg(label(1 "`=cond("`suppress'"=="","`=cond("`:var lab `by''"=="","","`:var lab `by'' = ")'","")'`:label (`by') `1''")"'
loc l `"`l' label(2 "`=cond("`suppress'"=="","`=cond("`:var lab `by''"=="","","`:var lab `by'' = ")'","")'`:label (`by') `2''"))"'
loc byopt `"barw(`=`w'/2') `byopt'"'
cap tw bar `y' `x' if `by'==`1', `tw1' `byopt'|| bar `y' `x' if `by'==`2', `l'  `byopt' `tw' `name'
if _rc!=0 tw bar `y' `x' if `by'==`1', `byopt'|| bar `y' `x' if `by'==`2', `l'  `byopt' `tw' `name'
end
