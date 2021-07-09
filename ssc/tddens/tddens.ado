*! tddens version 1.3  16mar2010
*! estimates bivariate density using symmetric triangle kernel
*! with bandwidth given as proportion of sample range (default 20%)
*! and produces several graphs
*! by Austin Nichols <austinnichols@gmail.com>
* 1.3 adds genstub to save graphing variables
* 1.2 switches from S marker symbol to tw rbar, adds weights
* 1.1 adds options format and marker symbol/size
* tddens version 1.0   2Sep2009
prog tddens
version 8.2
syntax varlist(min=2 max=2)  [fw aw pw] [if] [in] [, BWidth(real .2) Gridpoints(int 40) Bgraph Sgraph SCatter namestub(string) Format(string) MSymbol(string) MSIZe(string) SGOpt(string) BGOpt(string) GEnstub(string) *]
marksample touse 
qui if "`weight'"!="" {
 tempvar wt
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
 qui g double `wt'=(`wtvar')/`u'
 loc tempwt "fw=`wt'"
 markout `touse' `wt'
 }
if `"`format'"'=="" loc format %7.5g
if `"`msymbol'"'=="" loc msymbol "S"
if `"`msize'"'=="" loc msize "large"
conf format `format'
if `bwidth'<=0 | `bwidth'>=1 loc h=.2
else loc h=`bwidth'
if `gridpoints'<=0 loc n=40
else loc n=`gridpoints'
loc N=(`n'+1)^2
tokenize `varlist'
tempvar x y x1 y1 f w rf c rz r1 r2 y0 y2
if `"`genstub'"'=="" preserve
qui {
su `1', meanonly
g `x' = (`1'-r(min))/(r(max)-r(min))
loc X `"xla(0 "`=trim("`:di `format' `r(min)''")'""'
forv i=1/4 {
 loc X `"`X' `=`i'/4' "`=trim("`:di `format' `i'/4*(r(max)-r(min))+r(min)'")'""'
 }
loc xti: var label `1'
if `"`xti'"'=="" loc xti "`1'"
su `2', meanonly
g `y' = (`2'-r(min))/(r(max)-r(min))
loc Y `"yla(0 "`=trim("`:di %5.2g `format' `r(min)''")'""'
forv i=1/4 {
 loc Y `"`Y' `=`i'/4' "`=trim("`:di `format' `i'/4*(r(max)-r(min))+r(min)'")'""'
 }
loc yti: var label `2'
if `"`yti'"'=="" loc yti "`2'"
cap set obs `N'
g `x1'=(mod(_n-1,`n'+1))/`n' in 1/`N'
g `y1'=floor((_n-1)/(`n'+1))/`n' in 1/`N'
g `y2'=`y1'+(1/(`n')/2)
g `y0'=`y1'-(1/(`n')/2)
g `f'=.
g `w'=.
forv i=1/`N' {
 replace `w'=max(`h'-(`x'-`x1'[`i'])^2-(`y'-`y1'[`i'])^2,0)
 su `w' [`tempwt'], meanonly
 replace `f'=max(0,r(sum)) in `i'
 }
g `rf'=sqrt(`f')
su `rf', meanonly
g `c'=round((`rf'-r(min))/(r(max)-r(min))*255)
qui levelsof `c', loc(cs)
loc g
foreach k of loc cs {
loc g `"`g'||rbar `y2' `y0' `x1' if `c'==`k', col("`k' 100 100") barw(`=1/(`n')') fi(inten100) lw(none)"'
}
loc g `"`g' `X') `Y') xti(`xti') yti(`yti') leg(off)"'
if "`scatter'"!="" loc sc `"||sc `y' `x', ms(d) "'
tw `g' ti(Density heat map) xsize(4) ysize(4) `options' `sc' name(h`namestub', replace)
}
if "`sgraph'"!="" {
 loc a 0.25
 loc r 1
 qui g `r2'=`a'*(1-`y1'/`r')+`x1'/`r'*(`r'-`a')
 qui g `r1'=`a'*(1-`y1'/`r')
 su `f', meanonly
 loc m=r(max)
 qui g `rz'=`r1'+`f'*(`r'-`a')/`m'
 loc g
 foreach k of loc cs {
  loc g `"`g'||sc `rz' `r2' if `c'==`k', ms(`msymbol') msize(`msize') mc("`k' 100 100")"'
  }
 loc g `"`g' leg(off) xsc(off) ysc(off) yla(,nogrid)"'
 tw `g' ti(Density surface) xsize(4) ysize(4) name(f`namestub', replace) `sgopt'
 }
if "`bgraph'"!="" {
 loc b
 foreach k of loc cs {
  loc b `"rbar `rz' `r1' `r2' if `c'==`k', barw(`=`r'/`n'/3') col("`k' 100 100")||`b'"'
  }
 loc b `"`b', leg(off) xsc(off) ysc(off) yla(,nogrid)"'
 tw `b' ti(Density surface) xsize(4) ysize(4) name(g`namestub', replace) `bgopt'
 }
if `"`genstub'"'!="" {
 foreach v in y1 x1 y2 y0 c rz r2 r1 {
  cap ren ``v'' `genstub'`v'
  }
 }
end
