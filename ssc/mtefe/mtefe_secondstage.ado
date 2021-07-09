			* Author: Martin Eckhoff Andresen
			* This program is part of the mtefe package.

			cap program drop mtefe_secondstage
			{
				program define mtefe_secondstage, eclass
					version 13.0
					syntax varlist(fv) [if] [in] [fweight pweight], /*
					*/PROPscore(varname) /*
					*/link(string) /*
					*/gammaZ(varname) /*
					*/treatment(varname) /*
					*/instruments(varlist fv) /*
					*/evalgrid(namelist) /*
					*/evalgrid1(namelist) /*
					*/evalgrid0(namelist) /*
					*/uweights(namelist) [ /*
					*/boot /*
					*/init(string) /*
					*/REStricted(varlist fv) /*
					*/DEGree(string) /*
					*/YBWidth(real 0.2) /*
					*/XBWidth(string) /*
					*/polynomial(integer 0) /*
					*/semiparametric /*
					*/vce(passthru) /*
					*/norepeat1 /*
					*/prte(varname) /*
					*/separate /*
					*/splines(numlist) /*
					*/gridpoints(integer 0) /*
					*/kernel(string) /*
					*/mtexs_ate(string) /*
					*/mtexs_att(string) /*
					*/mtexs_atut(string) /*
					*/mtexs_late(string) /*
					*/mtexs_prte(string) /*
					*/mtexs_mprte1(string) /*
					*/mtexs_mprte2(string) /*
					*/mtexs_mprte3(string) /*
					*/mtexs_full(string) /*
					*/firststageoptions(string) /*
					*/savekp /*
					*/mlikelihood /*
					*/second /*
					*/colnames(string) /*
					*/numx(integer 0) /*
					*/numr(integer 0) /*
					*/norescale /*
					*/clustlevels(string) /*
					*/idcluster(varname) /*
					*/]
				
				marksample touse
				qui {
					if "`second'"!="" loc noi noi
					if "`weight'"=="fweight" {
						su `=subinstr("`exp'","=","",1)' if `touse'
						loc N=r(sum)
						}
					else {
						count if `touse'
						loc N=r(N)
						}
					
					if "`exp'"!=""&"`boot'"==""&"`vce'"==""|"`exp'"!=""&"`boot'"!="" loc regress _regress
					else loc regress regress
					
					tokenize `varlist'
					local y "`1'"
					macro shift
					loc x `*'

					fvexpand `*' if `touse'
					foreach var in `r(varlist)' {
						if strpos("`var'",".")>0 loc xnames `xnames' `var'
						else loc xnames `xnames' c.`var'
						}
					local numx: word count `xnames'
					
					fvexpand `restricted' if `touse'
					local numr: word count `r(varlist)'
					
					local d `treatment'
					local z `instruments'
					
					if "`prte'"!="" {
						loc prtevar `prte'
						loc prte prte
						}
						
					tempname cons
					gen `cons'=1
					
					tempname support support0 support1
					mat `support'=`evalgrid'
					mat `support1'=`evalgrid1'
					mat `support0'=`evalgrid0'
					loc numS=rowsof(`support')
					if "`separate'"!="" {
						loc numS1=rowsof(`support1')
						loc numS0=rowsof(`support0')
						cap assert mreldif(`support1',`support')<1e-7
						loc diffS=_rc!=0
						cap assert mreldif(`support0',`support')<1e-7
						if _rc!=0 loc ++diffS		
						}
					else loc diffS=0
					
					//Parse knots in splines
					if "`splines'"!="" {
						local numknots: word count `splines'
						tokenize `splines'
						forvalues q=1/`numknots'  {
							loc knot`q'=``q''
							}
						}
					else loc numknots=0
					
					if "`rescale'"=="norescale" loc denomateweights=99
					else loc denomateweights=`numS'
					
					*******************************************************
					* Rerun first stage & weight calculation if necessary *
					*******************************************************
					
					tempvar p
					if "`repeat1'"=="norepeat1" {
						gen double `p'=`propscore'
						tokenize `uweights'
						tempname uweightsatt uweightsatut uweightslate uweightsprte uweightsmprte1 uweightsmprte2 uweightsmprte3
						mat `uweightsatt'=`1'
						mat `uweightsatut'=`2'
						mat `uweightslate'=`3'
						mat `uweightsmprte1'=`4'
						mat `uweightsmprte2'=`5'
						mat `uweightsmprte3'=`6'
						if "`prte'"!="" mat `uweightsprte'=`7'
						}
					else {
						tempname dhat upsilon uweightslate uweightsatt uweightsatut xweightslate xweightsatt xweightsatut indicator covmat gammaZ
						`link' `d' `z' `x' `restricted' [`weight'`exp'] if `touse', `firststageoptions'
						predict double `p' if e(sample)
						replace `p'=1 if `p'>1&`touse'
						replace `p'=0 if `p'<0&`touse'
						
						predict double `gammaZ' if e(sample), xb
											
						`regress' `d' `z' `x' `restricted' [`weight'`exp'] if `touse'
						predict double `dhat' if `touse'
						`regress' `dhat' `x' `restricted' [`weight'`exp'] if `touse'
						predict double `upsilon' if `touse', residuals
						mean `upsilon' [`weight'`exp'] if `touse'
						loc upsilonbar=_b[`upsilon']
						mean `d' [`weight'`exp'] if `touse'
						loc dbar=_b[`d']
						mat accum `covmat'=`d' `upsilon'  [`weight'`exp'] if `touse', deviations nocons
						mat `covmat'=`covmat'/(`N'-1)
						loc dVar=`covmat'[1,1]
						loc cov_du=`covmat'[2,1]
						gen double `xweightslate'=((`d'-`dbar')*(`upsilon'-`upsilonbar'))/(`cov_du') if `touse'
						mean `p' [`weight'`exp'] if `touse'
						loc pbar=_b[`p']
						gen double `xweightsatt'=`p'/(`pbar') if `touse'
						gen double `xweightsatut'=(1-`p')/((1-`pbar')) if `touse'
						if "`prte'"!="" {
							tempname xweightsprte uweightsprte
							mean `prtevar' [`weight'`exp'] if `touse'
							loc prtebar=_b[`prtevar']
							gen double `xweightsprte'=(`prtevar'-`p')/((`prtebar'-`pbar')) if `touse'
							}
						gen `indicator'=.
						su `p' if `touse'
						loc min=r(min)
						loc max=r(max)
						if "`prte'"!="" {
							su `prtevar' if `touse'
							loc minpprte=r(min)
							loc maxpprte=r(max)
							}
						forvalues i=1/`=rowsof(`support')' {
							if `min'>=`support'[`i',1] loc prop=1
							else if `max'<=`support'[`i',1] loc prop=0
							else {
								replace `indicator'=`p'>`support'[`i',1] if `touse'
								proportion `indicator' [`weight'`exp'] if `touse'
								loc prop=_b[`indicator':1]
								}
							if `prop'>0 {
								mean `upsilon' [`weight'`exp'] if `p'>`support'[`i',1]&`touse'
								loc eupsilon=_b[`upsilon']
								mat `uweightslate'=[nullmat(`uweightslate') \ `=(1/99)*(`prop'*(`eupsilon'-`upsilonbar'))/`cov_du'']
								}
							else mat `uweightslate'=[nullmat(`uweightslate') \ 0 ]
							mat `uweightsatt'=[nullmat(`uweightsatt') \ `=(1/99)*(`prop'/`pbar')']
							mat `uweightsatut'=[nullmat(`uweightsatut') \ `=(1/99)*(1-`prop')/(1-`pbar')']
							if "`prte'"!="" {
								if `minpprte'>=`support'[`i',1] loc propprte=1
								else if `maxpprte'<=`support'[`i',1] loc propprte=0
								else {
									replace `indicator'=`prtevar'>`support'[`i',1] if `touse'
									proportion `indicator' [`weight'`exp'] if `touse'
									loc propprte=_b[`indicator':1]
									}
								mat `uweightsprte'=[nullmat(`uweightsprte') \ `=(`propprte'-`prop')/(99*(`prtebar'-`pbar'))']
								}
							}
						
						
						if "`rescale'"!="norescale"&rowsof(`support')!=99 {
						tempname sum
						foreach param in att atut late `doprte' {
							mat `sum'=J(1,rowsof(`uweights`param''),1)*`uweights`param''
							mat `uweights`param''=`uweights`param''/`sum'[1,1]
							}
						}
						
						//Calculate MPRTE weights
						tempname pcat temppden pden pmean fgammaZ fgammaZmean fv uweightsmprte1 uweightsmprte2 uweightsmprte3 xweightsmprte1
						egen `pcat'=cut(`p') if `touse', at(0.005(0.01)0.995) icodes
						replace `pcat'=`pcat'+1
						proportion `pcat' [`weight'`exp'] if `touse'
						mat `temppden'=e(b)
						mean `p' [`weight'`exp'] if `touse'
						mat `pmean'=e(b)
						
						forvalues s=1/`=rowsof(`support')' {
							cap mat `pden'=[nullmat(`pden') \ `temppden'[1,"`pcat':`s'"] ]
							if _rc!=0 mat `pden'=[nullmat(`pden') \ 0]
							}
						
						if "`link'"=="probit" gen double `fgammaZ'=normalden(`gammaZ') if `touse'
						else if "`link'"=="logit" gen double `fgammaZ'=exp(`gammaZ')/(1+exp(`gammaZ'))^2 if `touse'
						else gen double `fgammaZ'=`gammaZ' if `touse'
						mean `fgammaZ' [`weight'`exp'] if `touse'
						mat `fgammaZmean'=e(b)
						gen double `xweightsmprte1'=`fgammaZ'/`fgammaZmean'[1,1]
						
						if "`link'"=="logit" mata: `fv'=exp(invlogit(st_matrix("`support'"))):/((J(`=rowsof(`support')',1,1)+exp(invlogit(st_matrix("`support'")))):^2)
						else if "`link'"=="probit" mata: `fv'=normalden(invnormal(st_matrix("`support'")))
						else mata: `fv'=st_matrix("`support'")
						
						mata: st_matrix("`uweightsmprte1'",(st_matrix("`pden'"):*`fv'):/st_matrix("`fgammaZmean'"))
						mat `uweightsmprte2'=`pden'
						mata: st_matrix("`uweightsmprte3'",(st_matrix("`pden'"):*st_matrix("`support'")):/st_matrix("`pmean'"))
						
						if "`prte'"!="" loc doprte prte
						if "`saveweights'"!=""{
							foreach param in late att atut mprte1 `dprte' {
								gen double `saveweights'`param'=`xweights`param''
								}
							}

					*********************************
					* Re-estimate mean vector for X *
					*********************************
						
						tempname temp
						if "`prte'"=="" loc end 7
						else loc end 8

						tokenize ate att atut late mprte1 mprte2 mprte3 `prte'
						tempname temp
						
						tempvar xweightsate xweightsmprte2 xweightsmprte3
						foreach param in ate mprte2 mprte3 {	
								gen `xweights`param''=1
								}
						
						forvalues i=1/`end' {
							mat accum `temp'=(`xnames')#c.`xweights``i''' [`weight'`exp'] if `touse', means(`mtexs_``i''')
							mat `mtexs_``i'''=`mtexs_``i''''
							mat rownames `mtexs_``i'''=`xnames' _cons
							}
						if "`restricted'"!="" {
							mat accum `temp'=`restricted' [`weight'`exp'] if `touse', means(`mtexs_full')
							if "`x'"!="" mat `mtexs_full'=`mtexs_ate'[1..`numx',1] \ `mtexs_full''
							else mat `mtexs_full'=`mtexs_full''
							}
						else mat `mtexs_full'=`mtexs_ate'
						}
				
					***************************
					* PARAMETRIC NORMAL MODEL *
					***************************
					
					if `polynomial'==0&"`semiparametric'"=="" {
						tempname K fullb sort count sortb sortV V fullV Vtemp beta10pi Vbeta10pi Vbeta10 S pi pi1 pi0 dkdp Vmte mte beta0 beta1 beta10 beta0pi betaR invnormal ate Vate covb10b0
						
						//MAXIMUM LIKELIHOOD
						if "`mlikelihood'"!="" {
							
							//Use restricted variables as constraints
							if "`restricted'" != "" {
								fvexpand `restricted' if `touse'
								loc restrictedlist `r(varlist)'
								tokenize `restrictedlist'
								forvalues i=1/`numr' {
									if strpos("``i''","b.")>0 continue
									constraint `i' [`y'0]``i''==[`y'1]``i''
									loc constraints `constraints' `i'
									}
								}
							
							if "`second'"=="" {
								noi di as text 	"Estimating switching regression model. If Stata is working for"
								noi di as text	"a long time, log likelihood function might not be concave and" 
								noi di as text 	"fail to converge. Use option second to display iteration log."
								}
								
							`noi' ml model lf2 mtefe_movestay_lf2 /// 
								(`y'0: `y'=`x' `restricted') ///
								(`y'1: `y'=`x' `restricted') ///
								(`d': `d'=`z' `x' `restricted') /lns0 /lns1 /athrho0 /athrho1 [`weight'`exp'] if `touse' ///
								, init(`init') 	constraints(`constraints') `vce'
							
							`noi' ml maximize, search(on) difficult
								
							if "`boot'"=="" {
								foreach var in `xnames' {
								loc coeflist0 `coeflist0' (_b[`y'0:`var'])
								loc coeflist1 `coeflist1' (_b[`y'1:`var']-_b[`y'0:`var'])
								}
								loc coeflist0 `coeflist0' (_b[`y'0:_cons])
								loc coeflist1 `coeflist1' (_b[`y'1:_cons]-_b[`y'0:_cons])
								
								if "`restricted'"!="" {
									foreach var in `restrictedlist' {
										loc coeflistR `coeflistR' (_b[`y'0:`var'])
										}
									}
								
								nlcom `coeflist0' ( -exp(_b[lns0:_cons]) * tanh(_b[athrho0:_cons]) ) `coeflist1' ( - exp(_b[lns1:_cons])*tanh(_b[athrho1:_cons]) + exp(_b[lns0:_cons])*tanh(_b[athrho0:_cons]) ) `coeflistR', post
								mat `fullb'=e(b)
								mat `fullV'=e(V)
								}
							else {
								mat `fullb'=e(b)
								//mat `fullV'=J(2*`numx'+`numr'+4,2*`numx'+`numr'+4,.)
								if "`restricted'"=="" mat `fullb'=`fullb'[.,"`y'0:"],-exp(_b[lns0:_cons]) * tanh(_b[athrho0:_cons]),`fullb'[.,"`y'1:"]-`fullb'[.,"`y'0:"], - exp(_b[lns1:_cons])*tanh(_b[athrho1:_cons]) + exp(_b[lns0:_cons])*tanh(_b[athrho0:_cons])
								else {
									tempname temp0 temp1 tempR
									mat `temp0'=`fullb'[.,"`y'0"]
									mat `temp1'=`fullb'[.,"`y'0"]
									mat `tempR'=`temp0'[.,`=`numx'+1'..`=`numx'+`numr'']
									mat `temp0'=`temp0'[.,1..`numx'],`temp0'[.,`=colsof(`temp0')']
									mat `temp1'=`temp1'[.,1..`numx'],`temp1'[.,`=colsof(`temp1')']
									mat `fullb'=`temp0',-exp(_b[lns0:_cons]) * tanh(_b[athrho0:_cons]),`temp1',- exp(_b[lns1:_cons])*tanh(_b[athrho1:_cons]) + exp(_b[lns0:_cons])*tanh(_b[athrho0:_cons]),`tempR'
									}
								}
							}
						
						//SEPARATE APPROACH
						else if "`separate'"!="" {
							gen double `K'= -(normalden(invnormal(`p'))/`p') if `touse'&`d'
							replace `K'= normalden(invnormal(`p'))/(1-`p') if `touse'&!`d'
							`noi' `regress' `y' (`xnames' c.`K')##1.`d' `restricted' [`weight'`exp'] if `touse', `vce'
							loc dof dof(`e(df_r)')
							mat `fullb'=e(b)
							mat `fullV'=e(V)
							forvalues i=1/`=colsof(`fullb')' {
								if `numx'>0&inrange(`i',1,`numx') mat `sort'=[nullmat(`sort') \ 1]
								if `i'==`=`numx'+1' mat `sort'=[nullmat(`sort') \ 3]
								if `i'==`=`numx'+2' mat `sort'=[nullmat(`sort') \ 5]
								if `numx'>0&inrange(`i',`=`numx'+3',`=2*`numx'+2') mat `sort'=[nullmat(`sort') \ 4]
								if `i'==`=2*`numx'+3' mat `sort'=[nullmat(`sort') \ 6]
								if `numr'>0 {
									if inrange(`i',`=2*`numx'+3',`=2*`numx'+2+`numr'') mat `sort'=[nullmat(`sort') \ 7]
									}
								if `i'==`=colsof(`fullb')' mat `sort'=[nullmat(`sort') \ 2]
								mat `count'= [nullmat(`count') \ `i']
								}
							mat `sortb'= `sort',`count',`fullb''
							mat `sortV'=`sort',`count',`fullV'
							mata: st_matrix("`fullb'",sort(st_matrix("`sortb'"),(1,2))[.,3]')
							mata: st_matrix("`fullV'",sort(st_matrix("`sortV'"),(1,2))[.,3..cols(st_matrix("`sortV'"))])
							mat `sortV'=`sort',`count',`fullV''
							mata: st_matrix("`fullV'",sort(st_matrix("`sortV'"),(1,2))[.,3..cols(st_matrix("`sortV'"))]')
							}
						
						//LOCAL IV
						else {
							gen double `K'= -normalden(invnormal(`p')) if `touse'
							`noi' `regress' `y'  `xnames'  1.`cons' `restricted'  (`xnames')#c.`p' `p' `K' [`weight'`exp'] if `touse', nocons `vce'
							loc dof dof(`e(df_r)')
							mat `fullb'=e(b)
							mat `fullV'=e(V)
							}
						
						
						if "`savekp'"!="" {
							cap drop mills0 mills
							gen double mills=-normalden(invnormal(`p')) if `touse'
							if "`separate'"!=""|"`mlikelihood'"!="" gen double mills0=normalden(invnormal(`p'))/(1-`p')
							}
						
						mat colnames `fullb'=`colnames' 
						mat colnames `fullV'=`colnames'
						mat rownames `fullV'=`colnames'
						mat `pi'=`fullb'[.,"k:mills"]
						if "`separate'"!=""|"`mlikelihood'"!="" {
							mat `pi0'=`fullb'[.,"k0:mills0"]
							mat `pi1'=`pi'+`pi0'
							}
						mat `beta0'=`fullb'[.,"beta0:"]
						mat `beta10pi'=`fullb'[.,"beta1-beta0:"],`fullb'[.,"k:"]
						mat `beta10'=`fullb'[.,"beta1-beta0:"]
						mat `beta1'=`beta10'+`beta0'
						if `numr'>0 {
							mat `betaR'=`fullb'[.,"restricted:"]
							mat `beta1'=`beta10'+`beta0',`betaR'
							mat `beta0'=`beta0',`betaR'
							}
						mat `Vbeta10pi'=`fullV'["beta1-beta0:","beta1-beta0:"] , `fullV'["beta1-beta0:","k:"] \ `fullV'["k:","beta1-beta0:"] ,`fullV'["k:","k:"]
						mata: st_matrix("`S'",invnormal(st_matrix("`support'")'))
						mat `dkdp'=`pi'*`S'
						
						mata: mtefecalc(st_matrix("`beta10pi'"),st_matrix("`Vbeta10pi'"),st_matrix("`S'"),st_matrix("`mtexs_ate'"),J(`numS',1,`=1/`denomateweights''),"`mte'","`Vmte'","`ate'","`Vate'")
						if "`separate'`mlikelihood'"!="" {
							tempname S1 S0 dkdp1 dkdp0 pot1 pot0 K0 K1
							mata: mtefecalc_sep(st_matrix("`beta1'"),st_matrix("`beta0'"),invnormal(st_matrix("`support1'")),invnormal(st_matrix("`support0'")),st_matrix("`mtexs_full'"),st_matrix("`pi1'"),st_matrix("`pi0'"),"`pot1'","`pot0'","`dkdp1'","`dkdp0'")
							mata: st_matrix("`K1'",-st_matrix("`pi1'"):*normalden(invnormal(st_matrix("`support1'")')):/st_matrix("`support1'")')
							mata: st_matrix("`K0'",-st_matrix("`pi0'"):*normalden(invnormal(st_matrix("`support0'")')):/(J(1,rows(st_matrix("`support0'")),1)-st_matrix("`support0'")'))
							}
						}
						
						
					*********************************************************
					* PARAMETRIC AND SEMIPARAMETRIC POLYNOMIAL (w/ splines) *
					*********************************************************
				
					if `polynomial'>0 {
						tempname fullb fullV b sort count sortb sortV V pi pi1 pi0 S S1 S0 keep tempsup tempsup1 tempsup0 Vbeta10pi beta0pi beta10pi mte Vmte ate Vate beta0 beta1 beta10 betaR dkdp
			
						//LOCAL IV
						if "`separate'"=="" {
							//Generate polynomial in P(z)
							forvalues k=1/`=`polynomial'' {
								tempname p`k'
								gen double `p`k''=((`p'^`k'-1)*`p')/(`k'+1)
								loc poly `poly' `p`k''
								loc polynames `polynames' k:p`k'
								}
							//Generate splines
							if "`splines'"!="" {
								loc num=0
								forvalues knot=1/`numknots' {
									forvalues k=2/`=`polynomial'' { 
										loc ++num
										tempvar spline`knot'_`k'
										gen double `spline`knot'_`k''=(1/(`k'+1))*((`p'>=`knot`knot'')*((`p'-`knot`knot'')^(`k'+1)-((1-`knot`knot'')^(`k'+1)))*`p')
										loc splinevars `splinevars' `spline`knot'_`k''
										loc splinenames `splinenames' k:spline`knot'_`k'
										}
									}
								}
							`noi' `regress' `y' `xnames' 1.`cons' `restricted' (`xnames')#c.`p' `p' `poly' `splinevars' [`weight'`exp'] if `touse', nocons `vce'
							mat `fullb'=e(b)
							mat `fullV'=e(V)
							loc dof dof(`e(df_r)')
							}
							
						//SEPARATE	
						if "`separate'"!="" {
							forvalues k=1/`polynomial' {
								tempname p`k'
								gen double `p`k''=(`p'^(`k')-1)/(`k'+1) if `d'&`touse'
								replace `p`k''=((1-`p'^`k')*`p')/((1-`p')*(`k'+1)) if `touse'&!`d'
								loc polyvars `polyvars' c.`p`k''
								loc polynames1 `polynames1' k:p`k'
								loc polynames0 `polynames0' k0:p0`k'
								}
							if "`splines'"!="" {
								loc numsplines=(`polynomial'-1)*`numknots'
								loc num=0
								forvalues knot=1/`numknots' {
									forvalues k=2/`=`polynomial'' { 
										loc ++num
										tempvar spline`knot'_`k'
										gen double `spline`knot'_`k''=(1/(`p'*(`k'+1)))*((`p'>=`knot`knot'')*(`p'-`knot`knot'')^(`k'+1)-`p'*(1-`knot`knot'')^(`k'+1)) if `d'&`touse'
										replace `spline`knot'_`k''=(1/((1-`p')*(`k'+1)))*(`p'*(1-`knot`knot'')^(`k'+1)-(`p'>=`knot`knot'')*(`p'-`knot`knot'')^(`k'+1)) if !`d'&`touse'
										loc splinevars `splinevars' c.`spline`knot'_`k''
										loc splinenames0 `splinenames0' k0:spline0`knot'_`k' 
										loc splinenames1 `splinenames1' k:spline`knot'_`k' 
										}
									}
								}
							else loc numsplines=0
							`noi' `regress' `y' (`xnames' `polyvars' `splinevars')##1.`d' `restricted' [`weight'`exp'] if `touse', `vce'
							loc dof dof(`e(df_r)')
							mat `fullb'=e(b)
							mat `fullV'=e(V)
							forvalues i=1/`=colsof(`fullb')' {
								if `numx'>0&inrange(`i',1,`numx') mat `sort'=[nullmat(`sort') \ 1]
								if inrange(`i',`=`numx'+1',`=`numx'+`polynomial'+`numsplines'') mat `sort'=[nullmat(`sort') \ 3]
								if `i'==`=`numx'+`polynomial'+`numsplines'+1' mat `sort'=[nullmat(`sort') \ 5]
								if `numx'>0&inrange(`i',`=`numx'+`polynomial'+`numsplines'+2',`=2*`numx'+`polynomial'+1+`numsplines'') mat `sort'=[nullmat(`sort') \ 4]
								if inrange(`i',`=2*`numx'+`polynomial'+2+`numsplines'',`=2*`numx'+2*`polynomial'+1+2*`numsplines'') mat `sort'=[nullmat(`sort') \ 6]
								if `numr'>0 if inrange(`i',`=2*`numx'+2*`polynomial'+2+2*`numsplines'',`=2*`numx'+2*`polynomial'+1+2*`numsplines'+`numr'') mat `sort'=[nullmat(`sort') \ 7]
								if `i'==`=colsof(`fullb')' mat `sort'=[nullmat(`sort') \ 2]
								mat `count'= [nullmat(`count') \ `i']
								}
							mat `sortb'= `sort',`count',`fullb''
							mat `sortV'=`sort',`count',`fullV'
							mata: st_matrix("`fullb'",sort(st_matrix("`sortb'"),(1,2))[.,3]')
							mata: st_matrix("`fullV'",sort(st_matrix("`sortV'"),(1,2))[.,3..cols(st_matrix("`sortV'"))])
							mat `sortV'=`sort',`count',`fullV''
							mata: st_matrix("`fullV'",sort(st_matrix("`sortV'"),(1,2))[.,3..cols(st_matrix("`sortV'"))]')
							}
						
						if "`savekp'"!="" {
							forvalues k=1/`=`polynomial'' {
								cap gen double p`k'=((`p'^`k'-1)*`p')/(`k'+1) if `touse'
								cap if "`separate'"!="" gen double p0`k'=((1-`p'^`k')*`p')/((1-`p')*(`k'+1)) if `touse'
								}
							//Generate splines
							if "`splines'"!="" {
								loc num=0
								forvalues knot=1/`numknots' {
									forvalues k=2/`=`polynomial'' { 
										loc ++num
										gen double spline`knot'_`k'=(1/(`k'+1))*((`p'>=`knot`knot'')*((`p'-`knot`knot'')^(`k'+1)-((1-`knot`knot'')^(`k'+1)))*`p') if `touse'
										if "`separate'"!="" gen double spline0`knot'_`k'=(1/((1-`p')*(`k'+1)))*(`p'*(1-`knot`knot'')^(`k'+1)-(`p'>`knot`knot'')*(`p'-`knot`knot'')^(`k'+1)) if `touse'
										}
									}
								}
							}
							
						mat colnames `fullb'=`colnames'
						mat colnames `fullV'=`colnames'
						mat rownames `fullV'=`colnames'
						mat `beta10'=`fullb'[1,"beta1-beta0:"]
						mat `beta0'=`fullb'[1,"beta0:"]
						mat `beta1'=`beta10'+`beta0'
						if `numr'>0 {
							mat `betaR'=`fullb'[.,"restricted:"]
							mat `beta0'=nullmat(`beta0'),`betaR'
							mat `beta1'=nullmat(`beta1'),`betaR'
							}
						
						if "`semiparametric'"=="" {
							mat `Vbeta10pi'=`fullV'["beta1-beta0:","beta1-beta0:"] ,`fullV'["beta1-beta0:","k:"] \ `fullV'["k:","beta1-beta0:"] ,`fullV'["k:","k:"]
							mat `beta10pi'=`fullb'[1,"beta1-beta0:"],`fullb'[1,"k:"]
							mat `pi'=`fullb'[1,"k:"]
							if "`separate'"!=""  {
								mat `pi0'=`fullb'[1,"k0:"]
								mat `pi1'=`pi'+`pi0'						
								}				
							forvalues k=1/`=`polynomial'' {
								if `k'==1 mat `tempsup'=`support''
								else mat `tempsup'=hadamard(`tempsup',`support'')
								mat `S'=[nullmat(`S') \ `tempsup'-J(1,`numS',`=1/(`k'+1)')]
								if "`separate'"!=""&`diffS'!=0 forvalues s=0/1 {
									if `k'==1 mat `tempsup`s''=`support`s'''
									else mat `tempsup`s''=hadamard(`tempsup`s'',`support`s''')
									mat `S`s''=[nullmat(`S`s'') \ `tempsup`s''-J(1,`numS`s'',`=1/(`k'+1)')]
									}
								}
								
							if "`splines'"!="" {
								tempname knotS knotS1 knotS0
								mat `knotS'=J(1,rowsof(`support'),.)
								if "`separate'"!=""`diffS'!=0 forvalues s=0/1 {
									mat `knotS`s''=J(1,rowsof(`support`s''),.)
									}
								forvalues k=2/`=`polynomial'' {
									forvalues knot=1/`numknots' {
										forvalues i=1/`=rowsof(`support')' {
											if `support'[`i',1]>=`knot`knot'' mat `knotS'[1,`i']=(`support'[`i',1]-`knot`knot'')^`k'
											else mat `knotS'[1,`i']=0
											}
										mat `S'=[`S' \ `knotS' ]
										if "`separate'"!=""&`diffS'!=0	forvalues s=0/1 {
											forvalues i=1/`=rowsof(`support`s'')' {
												if `support`s''[`i',1]>=`knot`knot'' mat `knotS`s''[1,`i']=(`support`s''[`i',1]-`knot`knot'')^`k'
												else mat `knotS`s''[1,`i']=0
												}
											mat `S`s''=[`S`s'' \ `knotS`s'' ]
											}
										}
									}
								}
							if `diffS'==0 {
								mat `S1'=`S'
								mat `S0'=`S'
								}

							mat `dkdp'=`pi'*`S'
							
							mata: mtefecalc(st_matrix("`beta10pi'"),st_matrix("`Vbeta10pi'"),st_matrix("`S'"),st_matrix("`mtexs_ate'"),J(`numS',1,`=1/`denomateweights''),"`mte'","`Vmte'","`ate'","`Vate'")			
							if "`separate'"!="" {
								tempname dkdp1 dkdp0 pot1 pot0	
								mata: mtefecalc_sep(st_matrix("`beta1'"),st_matrix("`beta0'"),st_matrix("`S1'"),st_matrix("`S0'"),st_matrix("`mtexs_full'"),st_matrix("`pi1'"),st_matrix("`pi0'"),"`pot1'","`pot0'","`dkdp1'","`dkdp0'")
								}
							}
						}

					
					************************
					* SEMIPARAMETRIC MODEL *
					************************
					
					else if `polynomial'==0&"`semiparametric'"!="" {
						if "`weight'"=="pweight" loc lpolyweight aweight
						else loc lpolyweight `weight'
						
						//LOCAL IV
						if ("`separate'"==""&"`x'"!="")|("`separate'"==""&`numr'>0) {
							//Run local linear regressions of X, Y and XP on p
							nois _dots 0, title(Running local linear regressions) reps(`=2*`numx'+1+`numr'')
							tempname floorp ceilp bandwidth
							tempvar variable evalpoints
							else loc gridspec at(`p') gen(`smooth')
							loc num=0
							gen double `variable'=.
							fvexpand `restricted' if `touse'
							loc exprestricted `r(varlist)'
							foreach var in `y' `xnames' `exprestricted' `xnames' {
								loc ++num
								tempname e`num'
								if "`var'"=="`y'" loc bw `ybwidth'
								else loc bw `xbwidth'
								if `num'<=`=`numx'+`numr'+1' replace `variable'=`var'
								else replace `variable'=`var'*`p'
								if `gridpoints'!=0 {
									if "`var'"=="`y'" loc gridspec n(`gridpoints') gen(`evalpoints' `e`num'')
									else loc gridspec at(`evalpoints') gen(`e`num'')
									}
								else loc gridspec at(`p') gen(`e`num'')
								lpoly `variable' `p' [`lpolyweight'`exp'] if `touse', `gridspec' degree(1) bwidth(`bw') nograph noscatter kernel(`kernel')
								mat `bandwidth'=[nullmat(`bandwidth') \ `r(bwidth)']
								loc enames `enames' `e`num''
								if `gridpoints'==0 replace `e`num''=`variable'-`e`num''
								nois _dots `num' 0
								}
							noi di _newline
								
							if `gridpoints'!=0 {
								tempfile dataset datasetsmooth
								save `dataset'
								keep if `evalpoints'!=.
								keep `enames' `evalpoints'
								rename `evalpoints' `p'
								save `datasetsmooth'
								u `dataset', clear
								drop `enames' `evalpoints'
								nearmrg using `datasetsmooth', nearvar(`p') nogen
								loc num=0
								foreach var in `y' `xnames' `exprestricted' `xnames' {
									loc ++num
									if `num'<=`=`numx'+`numr'+1' replace `variable'=`var'
									else replace `variable'=`var'*`p'
									replace `e`num''=`variable'-`e`num''
									}
								}
							
							
							`noi' `regress' `enames' [`weight'`exp'] if `touse', nocons `vce'
							tempname b beta1 beta0 beta10 betaR fullb
							mat `fullb'=e(b)
							mat colnames `fullb'=`colnames'
							if "`x'"!="" {
								mat `beta10'=`fullb'[1,"beta1-beta0:"]
								mat `beta0'=`fullb'[1,"beta0:"]
								mat `beta1'=`beta10'+`beta0'
								}
							if `numr'>0 {
								mat `betaR'=`fullb'[1,"restricted:"]
								mat `beta1'=nullmat(`beta1'),`betaR'
								mat `beta0'=nullmat(`beta0'),`betaR'
								}					
							}
						
						//SEPARATE APPROACH
						if ("`separate'"!=""&"`x'"!="")|("`separate'"!=""&`numr'>0) {
							nois _dots 0, title(Running double residual regression) reps(`=`numx'+1+`numr'')
							tempname bandwidth1 bandwidth0 fullb
							tempvar variable smooth evalpoints1 evalpoints0
							loc num=0
							gen double `variable'=.
							foreach var in `y' `xnames' {
								loc ++num
								if "`var'"=="`y'" loc bw `ybwidth'
								else loc bw `xbwidth'
								tempvar e`num'
								gen `e`num''=.
								replace `variable'=`var'
								forvalues dum=0/1 {
									if `gridpoints'!=0 {
										if "`var'"=="`y'" loc gridspec n(`gridpoints') gen(`evalpoints`dum'' `smooth')
										else loc gridspec at(`evalpoints`dum'') gen(`smooth')
										}
									else loc gridspec at(`p') gen(`smooth')
									lpoly `variable' `p' [`lpolyweight'`exp'] if `touse'&`d'==`dum', `gridspec' degree(1) bwidth(`bw') nograph noscatter kernel(`kernel')
									mat `bandwidth`dum''=[nullmat(`bandwidth`dum'') \ `r(bwidth)']
									if `gridpoints'==0 {
										replace `e`num''=`variable'-`smooth' if `d'==`dum'
										drop `smooth'
										}
									else {
										tempvar smooth`dum'`num'
										rename `smooth' `smooth`dum'`num''
										loc smooths`dum' `smooths`dum'' `smooth`dum'`num''
										}
									}
								loc enames `enames' `e`num''
								nois _dots `num' 0
								}
							loc num2=0
							if "`restricted'"!="" tempvar evalpoints
							fvexpand `restricted' if `touse'
							foreach var in `r(varlist)' {
								loc ++num
								loc ++num2
								tempvar e`num'
								replace `variable'=`var'
								if `gridpoints'!=0 {
									if `num2'==1 loc gridspec n(`gridpoints') gen(`evalpoints' `smooth')
									else loc gridspec at(`evalpoints') gen(`smooth')
									}
								else loc gridscpec at(`p') gen(`smooth')
								lpoly `variable' `p' [`lpolyweight'`exp'] if `touse', `gridspec' degree(1) bwidth(`xbwidth') nograph noscatter kernel(`kernel')
								mat `bandwidth0'=[nullmat(`bandwidth0') \ `r(bwidth)']
								if `gridpoints'==0 {
									gen `e`num''=`variable'-`smooth'
									drop `smooth'
									}
								else {
									tempvar smoothR`num'
									rename `smooth' `smoothR`num''
									loc smoothsR `smoothsR' `smoothR`num''
									}
								loc enamesR `enamesR' `e`num''
								nois _dots `num' 0
								}
							noi di _newline
								
							if `gridpoints'!=0 {
								tempfile dataset datasetsmooth
								save `dataset'
								keep if `evalpoints1'!=.
								keep `evalpoints' `evalpoints1' `evalpoints0' `smooths1' `smooths0' `smoothsR'
								save `datasetsmooth'
								u `dataset', clear
								drop `smooths1' `smooths0' `smoothsR' `evalpoints' `evalpoints1' `evalpoints0'
								forvalues dum=0/1 {
									loc num=0
									rename `p' `evalpoints`dum''
									nearmrg using `datasetsmooth', nearvar(`evalpoints`dum'') nogen keepusing(`smooths`dum'')
									foreach var in `y' `xnames' {
										replace `variable'=`var'
										loc ++num
										replace `e`num''=`variable'-`smooth`dum'`num'' if `d'==`dum'&`touse'
										}
									rename `evalpoints`dum'' `p'
									drop `smooths`dum''
									}
								if "`restricted'"!="" {
									rename `p' `evalpoints'
									nearmrg using `datasetsmooth', nearvar(`evalpoints') nogen keepusing(`smoothsR')
									fvexpand `restricted' if `touse'
									foreach var in `r(varlist)' {
										replace `variable'=`var'
										loc ++num
										gen `e`num''=`variable'-`smoothR`num'' if `touse'
										}
									rename `evalpoints' `p'
									}
								}
							
							tempname beta0 beta1 beta10 betaR
							tokenize `enames'
							loc ey `1'
							mac shift
							loc enamesminy `*'
							`noi' `regress' `ey' c.(`enamesminy') `enamesR' c.(`enamesminy')#1.`d' [`weight'`exp'] if `touse', nocons `vce'
							mat `fullb'=e(b)
							mat colnames `fullb'=`colnames'
							if "`x'"!="" {
								mat `beta10'=`fullb'[1,"beta1-beta0:"]
								mat `beta0'=`fullb'[1,"beta0:"]
								mat `beta1'=`beta10'+`beta0'
								}
							if `numr'>0 {
								mat `betaR'=`fullb'[1,"restricted:"]
								mat `beta1'=nullmat(`beta1'),`betaR'
								mat `beta0'=nullmat(`beta0'),`betaR'
								}
							}
						}
					

				
					//construct ytilde & MTE semiparametrically
					if "`semiparametric'"!="" {
						tempname evalgridvar tempsup ytilde
						mat `tempsup'=`support'
						svmat `tempsup', names(`evalgridvar')
						if `numx'>0|`numr'>0 {
							tempname xb0 xb10 tempclustvar
							if "`idcluster'"!="" {
								gen `tempclustvar'=`idcluster' if `touse'
								loc i=0
								foreach level in `clustlevels' {
									loc ++i
									replace `idcluster'=`level' if `tempclustvar'==`i'
									}
								}
							if "`x'"=="" gen `xb10'=0	
							else mat score double `xb10'=`beta10' if `touse'
							mat score double `xb0'=`beta0' if `touse'
							if "`separate'"=="" gen double `ytilde'=`y'-`xb0'-`xb10'*`p' if `touse'
							else gen double `ytilde'=`y'-`xb0'-`xb10'*`d' if `touse'
							if "`idcluster'"!="" replace `idcluster'=`tempclustvar'
							}
						else gen double `ytilde'=`y' if `touse'
						
						//find dK/dp semiparametrically
						tempname mtebase mte
						if "`weight'"=="fweights" {
							tempname dupe
							expand `exp', generate(`dupe')
							}
						if "`x'"!="" {
							if `polynomial'>0 mat `mtebase'=`beta10'*`mtexs_ate'
							else mat `mtebase'=`beta10'*`mtexs_ate'[1..`=rowsof(`mtexs_ate')-1',1]
							}
						else mat `mtebase'=0
						
						if "`separate'"=="" {
							tempvar K dkdpvar dkdp Vmte 
							sort `evalgridvar'
							locpoly3 `ytilde' `p' [`weight'`exp'] if `touse', degree(`degree') gen(`K' `dkdpvar') noscatter at(`evalgridvar') width(`ybwidth') nograph `kernel'
							if "`bandwidth'"=="" tempname bandwidth
							mat `bandwidth'=[nullmat(`bandwidth') \ `r(width)' ]
							mkmat `dkdpvar', nomissing matrix(`dkdp')
							mat `dkdp'=`dkdp''
							
							cap drop if `dupe'
							
							if `polynomial'>0|("`x'"==""&"`restricted'"=="") mat rownames `bandwidth'=ytilde
							else mat rownames `bandwidth'=`y' `colnames0' `colnamesR' `colnames1' ytilde
							
						//Generate MTE matrix
							matrix `mte' = J(1,rowsof(`support'),`mtebase'[1,1])+`dkdp'
							}
							
						//If using separate approach and semiparametric methods, construct Y1 and Y0
						if "`separate'"!="" {
							tempvar K0var K1var dkdpvar0 dkdpvar1 dkdp0 dkdp1 pot1 pot0 mte dkdp evalgridvar evalgridvar0 evalgridvar1 tempsup tmpname 
							if `diffS'!=0 forvalues i=0/1 {
								mat `tempsup'=`support`i''
								svmat `tempsup', names(`tmpname')
								rename `tmpname'1 `evalgridvar`i''
								}
							else {
								mat  `tempsup'=`support'
								svmat `tempsup', names(`evalgridvar')
								forvalues i=0/1 {
									gen `evalgridvar`i''=`evalgridvar'
									}
								}
							if "`bandwidth0'"=="" tempname bandwidth0
							if "`bandwidth1'"=="" tempname bandwidth1
							tempname K1 K0 
							
							sort `evalgridvar1'							
							locpoly3 `ytilde' `p' [`weight'`exp'] if `touse'&`d', degree(`degree') gen(`K1var' `dkdpvar1') noscatter at(`evalgridvar1') width(`ybwidth') nograph `kernel'
							mat `bandwidth1'=[nullmat(`bandwidth1') \ `r(width)' ]
							mkmat `dkdpvar1', nomissing matrix(`dkdp1')
							if ("`x'"==""&"`restricted'"=="")|`polynomial'>0 mat rownames `bandwidth1'= ytilde
							else mat rownames `bandwidth1'=`y' `colnames1' ytilde
							mat `dkdp1'=`dkdp1''
							mkmat `K1var', nomissing matrix(`K1')
							mat `K1'=`K1''
							
							sort `evalgridvar0'
							locpoly3 `ytilde' `p' [`weight'`exp']  if `touse'&!`d', degree(`degree') gen(`K0var' `dkdpvar0') noscatter at(`evalgridvar0') width(`ybwidth') nograph `kernel'
							mat `bandwidth0'=[nullmat(`bandwidth0') \ `r(width)' ]
							if ("`x'"==""&"`restricted'"=="")|`polynomial'>0 mat rownames `bandwidth0'=ytilde
							else mat rownames `bandwidth0'=`y' `colnames0' `colnamesR' ytilde
							mkmat `dkdpvar0', nomissing matrix(`dkdp0')
							mat `dkdp0'=`dkdp0''
							mkmat `K0var', nomissing matrix(`K0')
							mat `K0'=`K0''
							
							if `diffS'!=0 {
								tempfile Kpoints
								tempname evalgridvartmp
								forvalues i=0/1 {
									
									preserve
									keep `evalgridvar`i'' `K`i'var' `dkdpvar`i''
									keep if `evalgridvar`i''!=.
									if `i'==0 {
										rename `evalgridvar0' `evalgridvar1'
										save `Kpoints', replace
										}
									else {
										merge 1:1 `evalgridvar1' using `Kpoints', keep(3) nogen
										forvalues s=0/1 {
											tempname dkdp`s'shared K`s'shared
											mkmat `dkdpvar`s'', matrix(`dkdp`s'shared') nomissing
											mat `dkdp`s'shared'=`dkdp`s'shared''
											mkmat `K`s'var', matrix(`K`s'shared') nomissing
											mat `K`s'shared'=`K`s'shared''
											}
										}
									restore
									}
								}
							else forvalues i=0/1 {
								tempname dkdp`i'shared K`i'shared
								mat `dkdp`i'shared'=`dkdp`i''
								mat `K`i'shared'=`K`i''
								}								
						
							mata: st_matrix("`dkdp'",st_matrix("`K1shared'") :+ st_matrix("`dkdp1shared'"):*st_matrix("`support'")' :- ( st_matrix("`K0shared'") :-(1:-st_matrix("`support'")'):*st_matrix("`dkdp0shared'")))
						
							if "`x'"!=""|`numr'>0 {
								if `polynomial'==0 mat `mtexs_full'=`mtexs_full'[1..`=rowsof(`mtexs_full')-1',1]
								mata: st_matrix("`pot1'",J(1,`numS1',st_matrix("`beta1'")*st_matrix("`mtexs_full'")) :+ st_matrix("`K1'") :+ st_matrix("`dkdp1'"):*(st_matrix("`support1'")'))
								mata: st_matrix("`pot0'",J(1,`numS0',st_matrix("`beta0'")*st_matrix("`mtexs_full'")) :+ st_matrix("`K0'") :-(J(1,`numS0',1):-(st_matrix("`support0'")')):*st_matrix("`dkdp0'"))
								}
							else {
								mata: st_matrix("`pot1'",st_matrix("`K1'") :+ st_matrix("`dkdp1'"):*st_matrix("`support1'")')
								mata: st_matrix("`pot0'",st_matrix("`K0'") :-(1:-st_matrix("`support0'")'):*st_matrix("`dkdp0'"))
								}
						
							
							//Generate MTE matrix
							mat `mte'=J(1,rowsof(`support'),`mtebase'[1,1])+`dkdp'
							}
						
						cap drop if `dupe'
						
						tempname Vmte ate Vate
						mat `Vmte'=J(colsof(`mte'),colsof(`mte'),0)
						if "`rescale'"!="norescale" mat `ate'=`mte'*J(`numS',1,1/`numS')
						else mat `ate'=`mte'*J(`numS',1,1/99)
						mat `Vate'=0
						}
						
				
					**************
					* ALL MODELS *
					**************
					
					//Name MTE
					forvalues i = 1/`=rowsof(`support')' {
						loc mtenames `mtenames' mte:u`=round(`support'[`i',1]*100)'
							}
					mat colnames `mte'=`mtenames'
					
					
					*************************
					* Combine all estimates *
					*************************
					cap confirm matrix `fullV'
					loc doV=_rc==0
					tempname b V
					if "`fullb'"!="" mat `b'=`fullb',`ate'
					else mat `b'=`ate'
					if "`semiparametric'"!=""&`doV'==1 mat `Vate'=J(1,1,0)
					if `doV'==1 mat `V'=[`fullV' , J(rowsof(`fullV'),1,0) \ J(1,colsof(`fullV'),0) , `Vate'' ]
					loc colnames `colnames' effects:ate
					
					
					******************************************
					* Calculcate treatment effect parameters *
					******************************************

					tempname temp2
					foreach param in att atut late mprte1 mprte2 mprte3 `prte' {
						tempname mte`param' Vmte`param' `param' V`param'
						if "`semiparametric'"=="" {
							mata: mtefecalc(st_matrix("`beta10pi'"),st_matrix("`Vbeta10pi'"),st_matrix("`S'"),st_matrix("`mtexs_`param''"),st_matrix("`uweights`param''"),"`mte`param''","`Vmte`param''","``param''","`V`param''")			
							}
						else {
							if `polynomial'==0&"`x'"!="" mat `temp2'=`beta10'*`mtexs_`param''[1..`=rowsof(`mtexs_`param'')-1',1]
							else if `polynomial'>0&"`x'"!="" mat `temp2'=`beta10'*`mtexs_`param''
							else if "`x'"=="" mat `temp2'=0
							mat `mte`param''=J(1,rowsof(`support'),`temp2'[1,1])+`dkdp'
							mat ``param''=`mte`param''*`uweights`param''
							mat `V`param''=J(1,1,0)
							mat `Vmte`param''=J(rowsof(`mte'),colsof(`mte'),0)
							}
						
						mat `b'=`b',``param''
						loc colnames `colnames' effects:`param'
						if `doV'==1 mat `V'= [`V' , J(rowsof(`V'),1,0) \ J(1,colsof(`V'),0) , `V`param'' ]
						}
					
					//Add estimated mte to e() and V)
					mat `b'=`b',`mte'
					if `doV'==1 mat `V'=[`V' , J(rowsof(`V'),colsof(`Vmte'),0) \ J(rowsof(`Vmte'),colsof(`V'),0) , `Vmte']
					//else mat `V'=[`V' , J(rowsof(`V'),colsof(`Vmte'),0) \ J(rowsof(`Vmte'),colsof(`V'),0) , J(colsof(`mte'),colsof(`mte'),0) ]
					
					mat colnames `b'=`colnames' `mtenames'
					if `doV'==1 {
						mat colnames `V'=`colnames' `mtenames'
						mat rownames `V'=`colnames' `mtenames'
						}
					
					//Temporary hack: drop empty obs created by combinations of gridpoints, semiparametric and trimsupport
					drop if `touse'==.
					
					//Post results
					if `doV'==1 ereturn post `b' `V', depname(`y') esample(`touse') buildfvinfo obs(`N') `dof'
					else ereturn post `b', depname(`y') esample(`touse') buildfvinfo obs(`N') `dof'
					if "`separate'"!="" ereturn local method "Separate approach"
					else if "`mlikelihood'"!="" ereturn local method "Maximum Likelihood"
					else ereturn local method "Local IV"
					if "`semiparametric'"=="" {
						if `polynomial'==0 {
							ereturn local title "Parametric normal MTE model"
							}
						if `polynomial'>0 {
							if "`splines'"=="" ereturn local title "Parametric polynomial MTE model"
							else ereturn local title "Parametric polynomial MTE model with splines at `splines'"
							ereturn scalar polynomial = `polynomial'
							}
						}
					if "`semiparametric'"!="" {
						ereturn scalar degree=`degree'
						if `polynomial'>0 {
							if "`splines'"!="" ereturn local title "Semiarametric polynomial MTE model with splines at `splines'"
							else ereturn local title "Semiparametric polynomial MTE model"
							ereturn scalar polynomial = `polynomial'
							ereturn local bandwidth=`ybwidth'
							}
						if `polynomial'==0 {
							ereturn local title "Semiparametric MTE model"
							if "`separate'"=="" ereturn matrix bandwidth=`bandwidth'
							else {
								ereturn matrix bandwidth1=`bandwidth1'
								ereturn matrix bandwidth0=`bandwidth0'
								}
							
							}
						}

					ereturn matrix support=`support'
					ereturn matrix dkdp=`dkdp'
					ereturn matrix mte=`mte'
					ereturn local cmd "mtefe"
					
					tempname temp
					if "`x'"!="" {
						mat `temp'=`mtexs_ate'[1..`numx',1]
						ereturn matrix mtexs_ate=`temp'
						}
					
					if "`separate'`mlikelihood'"!="" {
				
						forvalues i=0/1 {
							ereturn matrix Y`i'=`pot`i''
							ereturn matrix support`i'=`support`i''
							}
						}
					
					if  "`prte'"!="" loc tempprte prte
					foreach param in att atut late `tempprte' mprte1 mprte2 mprte3 {
						if "`x'"!="" {
							mat `temp'=`mtexs_`param''[1..`numx',1]
							ereturn matrix mtexs_`param'=`temp'
							}
						ereturn matrix mte`param'=`mte`param''
						ereturn matrix weights`param'=`uweights`param''
						}

					if "`prte'"!="" loc prte=`prtevar'
					}
			end
			}

			******************
			* MATA FUNCTIONS *
			******************

			mata:
			mata clear
			void mtefecalc(real matrix beta10pi, real matrix Vbeta10pi, real matrix S, real matrix mtexs, real matrix uweights, ///
				string scalar mtename, string scalar Vmtename, string scalar paramname, string scalar Vparamname) 
			{
				real matrix Vmte, fullS
				real scalar i
				real vector mte
				real scalar param, Vparam
				
				fullS=J(rows(mtexs),cols(S),.)
				for (i=1;i<=cols(S);i++) fullS[.,i]=mtexs
				fullS=fullS \ S
				mte=beta10pi*fullS
				Vmte=fullS'*Vbeta10pi*fullS
				param=mte*uweights
				Vparam=uweights'*Vmte*uweights
				st_matrix(mtename,mte)
				st_matrix(Vmtename,Vmte)
				st_matrix(paramname,param)
				st_matrix(Vparamname,Vparam)
			}

			void mtefecalc_sep(real matrix beta1, real matrix beta0, real matrix S1, real matrix S0, real matrix mtexs_full, ///
				real matrix pi1, real matrix pi0, string scalar Y1name, string scalar Y0name, string scalar dkdp1name, string scalar dkdp0name) 
			{
				real vector pot0, pot1, dkdp1, dkdp0
				
				pot1=(beta1*mtexs_full :+ pi1 * S1)'
				pot0=(beta0*mtexs_full :+ pi0 * S0)'
				dkdp1=pi1 * S1
				dkdp0=pi0 * S0
				st_matrix(Y1name,pot1)
				st_matrix(Y0name,pot0)
				st_matrix(dkdp1name,dkdp1)
				st_matrix(dkdp0name,dkdp0)
			}
			end
