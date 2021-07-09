*! byhist graphs side by side "interlaced" histograms  
*! or a single histogram, allowing weights 
*! byhist 1.3 19 Apr 2010 Austin Nichols added options tw1 tw2 etc. 
* byhist 1.2 12 Feb 2009 Austin Nichols added "asis" to tw option
* byhist 1.1 3 Dec 2008 Austin Nichols added options
* byhist 1.0 26 Nov 2008 Austin Nichols
prog byhist, rclass
version 8.2
syntax varname [fw aw pw] [if] [in], [ by(string) FREQuency FRACtion DENSity percent name(passthru) tw(string asis) tw1(string asis) tw2(string asis) tw3(string asis) tw4(string asis) tw5(string asis) tw6(string asis) tw7(string asis) otol(int 2) SUPpress * ]
* note undocumented otol sets tolerance for order (power of ten) above which to convert units to integers
* and option tw passes options to the final twoway graph--all other options * are passed to twoway__histogram_gen
gettoken by byopt: by
if substr("`by'",1,1)=="," | "`by'"=="" {
 loc by: subinstr local by "," "", all
 loc byopt `"`by' `byopt'"'
 tempvar by
 g byte `by'=1
 loc noby "no by var"
 }
else loc by: subinstr local by "," "", all
marksample touse
cap conf numeric var `by'
if _rc {
 tempvar b
 encode `by', gen(`b')
 unab byvar: `by'
 loc by "`b'"
 di as err "Variable " as res "`by'" as err " not numeric;" 
 di as smcl as err "using {help encode} to make a numeric variable"
 di as smcl as err "which may change the ordering of categories." _n
 }
else unab byvar: `by'
markout `touse' `by'
tempvar nvals
qui bys `touse' `by' : gen byte `nvals' =(_n == 1)*`touse'*(`by'<.)
su `nvals' if `touse', meanonly
loc nval=r(sum)
if `nval'>7 {
 di as err "Variable `byvar' has " as res r(sum) as err " distinct values"
 di as err "are you sure you want that many interlaced histograms?" _n
 di as res "Break to abort, or any other key to continue"
 loc wasmore=c(more)
 set more on
 more
 set more `wasmore'
 }
loc v `varlist'
tempvar x y wt sum wtvar
loc u = 1
qui if "`weight'"!="" {
 loc wtvar: subinstr local exp "=" "", all
 capture assert float(`wtvar') == float(round(`wtvar',1)) if `touse'
 if _rc == 0 {
 	while _rc == 0 {
 		loc u = `u'*10
 		capture assert float(`wtvar') == float(round(`wtvar',`u')) if `touse'
 	}
 	loc u = `u'/10
 }
 else {
 	while _rc {
 		loc u = `u'/10
 		capture assert float(`wtvar') == float(round(`wtvar',`u')) if `touse'
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
loc b=r(bin)
return local min=`s'
return local width=`w'
return local bin=`b'
qui {
replace `x'=.
replace `x'=`s'+`w'/2 if (`v'>=`s')&(`v'<=`s'+`w')
forv i=2/`b' {
 replace `x'=`s'+(2*`i'-1)*`w'/2 if (`v'>=`s'+(`i'-1)*`w')&(`v'<`s'+(`i')*`w')
 }
replace `x'=`s'+(2*`b'-1)*`w'/2 if float(`v')==float(`s'+(`b')*`w')
}
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
loc iwidth=`w'/(`:word count `bl''+1)
loc lowlim=`w'/2
loc ilev 1
qui foreach lev of local bl {
 replace `x'=`x'-(`lowlim')+`ilev'*`iwidth' if `by'==`lev'
 loc ilev=`ilev'+1
}
su `y', meanonly
loc m=r(max)
tempname matrix mat
forv ni=1/`=_N' {
 matrix `mat'=(`=`by'[`ni']',`=`x'[`ni']',`=`y'[`ni']')
 matrix `matrix'=nullmat(`matrix')\ `mat'
 }
loc frac=cond("`percent'"=="","`fraction'","`percent'")
matrix colnames `matrix'=`byvar' `v' `frequency'`frac'`density'
return matrix b=`matrix'
loc o: di int(log10(`m'))-1
if abs(`o')>`otol' {
 loc M=ceil(`m'/10^`o')
 qui replace `y'=`y'/10^`o'
 }
else loc M=ceil(`m'/10^`o')*10^`o'
loc p=cond(length("`:di `M'/3'")<length("`:di `M'/4'"),3,4)
loc l "ylabel("
forv i=0/`p' {
 loc l `"`l' `=`M'*`i'/`p'' "`:di `M'*abs(`i')/`p''" "'
}
loc l `"`l')"'
loc frac=cond("`percent'"=="","`fraction'","`percent'")
loc l `"`l' yti("`:di proper("`frequency'`frac'`density'")' "'
if `o'>`otol'  loc l `"`l'in `=trim("`: di %20.0gc `:di 10^(`o')''")'s")"'
if `o'<-`otol' loc l `"`l'in `=trim("`: di %20.0gc `:di 10^-(`o')''")'ths")"'
if abs(`o')<=`otol' loc l `"`l'")"'
if `"`xl'"'!="" loc l `"`l' xti(`xl')"'
loc l `"`l' leg("'
loc bli=1
tokenize `bl'
while "`1'"!="" {
 loc l `"`l' label(`bli' "`=cond("`:var lab `by''"=="","","`:var lab `by'' = ")'`:label (`by') `1''")"'
 loc bli=`bli'+1
 mac shift
 }
loc l `"`l')"'
loc byopt `"barw(`iwidth') `byopt'"'
loc cmd
loc bli=1
tokenize `bl'
while "`1'"!="" {
 loc cmd `"`cmd' (bar `y' `x' if `by'==`1', `byopt' `tw`bli'')"'
 loc bli=`bli'+1
 mac shift
 }
tw `cmd', `l' `tw' `name'
end
