*! Ravshanbek Khodzhimatov
*! 1/1/2018
*! This program does Pedroni's(1996) generalization of FMOLS and DOLS models to panel data.
*! Please make sure "cointreg" is installed via "net install st0272.pkg" from http://www.stata-journal.com/software/sj12-3/
*! All of the options are available under cointreg except for "full" option
*! When you add "full" option it gives not only the Pedroni average but also FMOLS for every single panel
*! Contact me via rsk@ravshansk.com
capt program drop xtcointreg
program xtcointreg, eclass sortpreserve
version 11.0
syntax varlist(ts fv) [if] [in] , [ est(string) noCONStant EQTrend(integer 0) EQDet(varlist) XTrend(integer 0) XDet(varlist) diff stage(integer 1) dlead(integer 1) dlag(integer 1) dic(string) DMAXorder(integer 0) dvar(varlist ts fv) dvce(string) noDADJdof noDIVN dof(integer 0) vic(string) vlag(integer 0) noVADJdof KERNel(string) BWIDth(real 0) bmeth(string) blag(integer 0) BTRUnc Level(real 95) full]

marksample touse

qui {
	xtset
	
	local ivar `r(panelvar)'
	local tvar `r(timevar)'
	
	levels `ivar' if `touse', local(panels)
	
	tokenize `varlist'
	global Y `1'
	macro shift
	global X `*'

	local indnum = wordcount("$X")
	local panelnum = wordcount("`panels'")
}
	

*! Estimation 

matrix Bsum = J(`indnum',1,0)
matrix Tsum = J(`indnum',1,0)


quietly foreach pan of local panels{
	di "`pan'"
	cointreg `varlist' if `ivar'==`pan', est(`est') `constant' eqt(`eqtrend') eqd(`eqdet') xt(`xtrend') diff stage(`stage') dlead(`dlead') dlag(`dlag') dic(`dfk') dmax(`dmaxorder') dvar(`dvar') dvce(`dvce')`dadjdof' `divn' dof(`dof') vic(`vic') vlag(`vlag') `vadjdof' kern(`kernel') bwid(`bwidth') bmeth(`bmeth') blag(`blag') `btrunc' level(`level')
	
	matrix B`pan' = e(b)
	matrix B`pan' = B`pan'[1,1..`indnum']' // to remove constant
	matrix rownames B`pan' = $X
	matrix colnames B`pan' = beta_`pan'

	matrix V`pan' = e(V)
	matrix V`pan' = V`pan'[1..`indnum',1..`indnum'] // to remove constant
	matrix T`pan' = J(`indnum',1,.)  // to remove constant
	matrix Se`pan' = J(`indnum',1,.) // to remove constant
	forval i = 1/`indnum' {
		matrix Se`pan'[`i',1] = sqrt(V`pan'[`i',`i'])
		matrix T`pan'[`i',1] = B`pan'[`i',1]/Se`pan'[`i',1]
	}
	matrix rownames T`pan' = $X
	matrix rownames Se`pan' = $X
	matrix colnames T`pan' = t-stat_`pan'
	matrix colnames Se`pan' = s.e._`pan'
	
	
	matrix Bsum = Bsum + B`pan'
	matrix Tsum = Tsum + T`pan'
	
}

matrix Bave = Bsum/`panelnum'
matrix Tave = Tsum/sqrt(`panelnum')
matrix Cave = Bave,Tave
matrix colnames Cave = beta t-stat


matrix Tab = J(1,`indnum',.)
quietly foreach pan of local panels {
	matrix Tab = Tab\B`pan''\Se`pan''\T`pan''
}
matrix colnames Tab = $X




if "`est'"==""{
	di "Method of estimation: FMOLS"
}
else{
	di "Method of estimation: `est'"
}

di "Number 


if "`full'"!=""{
	matrix list Tab, format(%8.2f)
	matrix list Cave, format(%8.2f)
}
else {
	matrix list Cave, format(%8.2f)
}


end
