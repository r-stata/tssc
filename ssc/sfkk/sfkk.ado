*! version 2.0.0  25oct2016
*! version 1.0.4  02jun2016
*! version 1.0.3  25oct2015
*! version 1.0.2  11sep2015
*! version 1.0.1  03jul2015
*! version 1.0.0  01jun2015
/*
-sfkk-
version 1.0.0 
June 1, 2015
Program Author: Dr. Mustafa Ugur Karakaplan
E-mail: mukarakaplan@yahoo.com
Website: www.mukarakaplan.com

Recommended Citations:

The following two citations are recommended for referring to the sfkk program
package and the underlying econometric methodology:

Karakaplan, Mustafa U. (2016) "Estimating Endogenous Stochastic Frontier Models
in Stata." Forthcoming. The Stata Journal.  Also available at www.mukarakaplan.com

Karakaplan, Mustafa U. and Kutlu, Levent (2013) "Handling Endogeneity in 
Stochastic Frontier Analysis." Available at www.mukarakaplan.com
*/

program sfkk
		version 13.1
		if replay() {
			if "`2'"=="version" | "`2'"=="ver" | "`2'"=="vers" | "`2'"=="versi" | "`2'"=="versio" {
				di _n(1) "{bf:{ul:Version}}"
				di _n(1) "{txt}{sf}    sfkk version 2.0.0"
				di "    October 25, 2016"
				di _n(1) "{bf:{ul:Program Author}}"
				di _n(1) "    Dr. Mustafa Ugur Karakaplan"
				di `"    E-mail: {browse "mailto:mukarakaplan@yahoo.com":mukarakaplan@yahoo.com}"'
				di "    Website: {browse www.mukarakaplan.com}"
				di _n(1) "{pstd}For comments, suggestions, or questions about {cmd: sfkk},"
				di "please send an email to me."
				di _n(1) "{bf:{ul:Recommended Citations}}"
				di _n(1) "{pstd}The following two citations are recommended for referring to the sfkk program "
				di "package and the underlying econometric methodology: {p_end}"
				di _n(1) `"{phang}Karakaplan, Mustafa U. (2016) "Estimating Endogenous Stochastic"'
				di `"Frontier Models in Stata." {it:Forthcoming.}  {browse "www.stata-journal.com":The Stata Journal}."'
				di " Also available at {browse www.mukarakaplan.com}{p_end}"
				di _n(1) "{phang}Karakaplan, Mustafa U. and Kutlu, Levent (2013)"
				di `""Handling Endogeneity in Stochastic Frontier Analysis." "'
				di `"Available at "'
				di "{browse www.mukarakaplan.com}{p_end}"
				exit
			}
			else if ("`e(cmd)'" != "sfkk") error 301
			Replay `0'
		}
		else Estimate `0'
end

program Estimate, eclass
		syntax varlist(min=2 fv) [pweight fweight iweight aweight] [if] [in], [ COST PRODuction ENdogenous(varlist fv) /*
		*/ Instruments(varlist fv) EXogenous(varlist fv) LEAVEout(varlist fv) Uhet(string) Whet(string) /*
		*/ noCONStant INITial(string) DELVE FAST(string)    SAVE(string) LOAD(string) NOMESSage NOOUTput NOREFresh /*
		*/ EFFiciency(string) TEST TIMER BEEP DIFficult ITERate(string) TECHnique(string) /*
		*/ HEADER COMPare NICEly MLMAX(string) MLMODel(string) MLDISplay(string) ]  
		
		if ("`timer'"!="") {
			timer clear 1
			timer on 1
		}
		if ("`norefresh'"=="") {
			capture estimates drop ModelEN
			capture estimates drop ModelEX
			}
		
		gettoken lhs frontier : varlist
		_fv_check_depvar `lhs'
		ereturn clear
		if"`weight'" != "" local wgt "[`weight'`exp']"
		marksample touse
		capture set matsize 800
		capture set matsize 11000
		
		local porc = "production" //default is production frontier
		scalar prod = 1
		if ("`production'" !="" & "`cost'" !="") {
			di as error "{p}Specify either {bf:{ul:prod}uction} or {bf:{ul:cost}}. Do not specify both."
			error 198
		}
		else if ("`cost'" !="") {
		local porc = "cost"
		scalar prod = -1
		}
		
		if("`technique'"!="" & "`fast'"=="") {
			if strpos("`technique'", "bhhh") != 0 {
				di as error "{p}bhhh technique is only allowed with {bf:fast({it:#})} specification."
				error 198
			}
		}
		
		if ("`efficiency'"!="") {
			tokenize "`efficiency'", parse(",", " ") 
			if ("`2'"!="," & "`2'"!="") {
				di as error "{p}Too many efficiency variables are specified to be generated."
				error 103
			}
			capture summ `1'_EN
			if (_rc!=111 & "`3'"!="replace") {
				di as error "{p}`1'_EN is specified to be the efficiency variable but the variable is already in the data and the replace option is not specified. Either specify a new efficiency variable or specify the replace option."
				error 110
			}
			if ("`compare'"!="") {
				capture summ `1'_EX
				if (_rc!=111 & "`3'"!="replace") {
				di as error "{p}`1'_EX is specified to be the efficiency variable but the variable is already in the data and the replace option is not specified. Either specify a new efficiency variable or specify the replace option."
				error 110
				}
			}
			local effvar = "`1'"
		}
	
		if ("`uhet'"!="") {
			gettoken urhs uno: uhet, parse(",")
			if (strpos("`uno'",",")!=0 & strpos("`uno'","nocons")!=0) local unocons=1
			else local unocons=0
			if ("`urhs'"==",") {
				di as err "{p}Specify at least one variable or the constant in Uhet."
				error 198
			}
		}
		else local unocons=0
		
		if ("`whet'"!="") {
			gettoken wrhs wno: whet, parse(",")
			if (strpos("`wno'",",")!=0 & strpos("`wno'","nocons")!=0) {
				di as err "{p}noconstant option is not allowed in Whet."
				error 198
			}
			if ("`wrhs'"==",") {
				di as err "{p}Invalid Whet syntax."
				error 198
			}
		}		
		

		
		if ("`norefresh'"=="") global exo=0
		
		if (("`endogenous'"=="" | "`instruments'"=="") & "`norefresh'"=="" ) {
			global exo=1
			if ("`nomessage'"=="") {
				di as error "{p}Specify both {bf:{ul:en}dogenous()} and {bf:{ul:i}nstruments()} to analyze the endogenous model."
				di _n(2) in red "Analyzing the exogenous model (Model EX)..." _n(1)
				
				sfkk `lhs' `frontier' `wgt' if `touse', `porc' u(`uhet') w(`whet') `constant' tech(`technique') `beep' noref
				
				di as error _n(1) "{p}Warning: Exogenous model is analyzed. Specify both {bf:{ul:en}dogenous()} and {bf:{ul:i}nstruments()} to analyze the endogenous model."
				if ("`timer'"!="") {
					timer off 1
					capture timer list 1
					di _n(2) in red "Completed in " `=int(r(t1)/3600)' " hour(s), " `=int((r(t1)-(int(r(t1)/3600)*3600))/60)' " minute(s) and " `=round(r(t1)-int((r(t1)-(int(r(t1)/3600)*3600))/60)*60)' " second(s)." 
				}	
				exit
			}
		}
		
		if ("`instruments'"!="") {
			forvalues j = 1/`=wordcount("`instruments'")' {
				if (strpos("`frontier'", "`=word("`instruments'", `j')'") != 0) {
					di as error "{p}Instrumental variable `=word("`instruments'", `j')' is specified as a frontier variable."
					error 110			
				}
				if (strpos("`urhs'", "`=word("`instruments'", `j')'") != 0) {
					di as error "{p}Instrumental variable `=word("`instruments'", `j')' is specified as a uhet variable."
					error 110			
				}
				if (strpos("`whet'", "`=word("`instruments'", `j')'") != 0) {
					di as error "{p}Instrumental variable `=word("`instruments'", `j')' is specified as a whet variable."
					error 110			
				}
				if (strpos("`endogenous'", "`=word("`instruments'", `j')'") != 0) {
					di as error "{p}Instrumental variable `=word("`instruments'", `j')' is specified as an endogenous variable."
					error 110			
				}					
				if (strpos("`exogenous'", "`=word("`instruments'", `j')'") != 0 | strpos("`leaveout'", "`=word("`instruments'", `j')'") != 0) {
					di as error "{p}Instrumental variable `=word("`instruments'", `j')' is specified as an included exogenous variable."
					error 110			
				}					

			}			
		}
		
		if ("`exogenous'" !="" & "`leaveout'" !="") {
			di as error "{p}Specify either {bf:{ul:ex}ogenous({it:exovarlist})} or {bf:{ul:leave}out({it:lovarlist})}. Do not specify both."
			error 198
		}
		
		global fastroute = 0
		
		if ("`fast'"!="") {
			if (`fast'<=0) {
				di as error "{p}fast(`fast') is invalid -- invalid number, outside of allowed range"
				di as error "{p}fast({it:#}) can be specified to take any value larger than 0."
				error 125
			}
			global fastroute = 1
		}

		global p = wordcount("`endogenous'")		

		forvalues j = 1/$p {
			if (strpos("`frontier'", "`=word("`endogenous'", `j')'") ==0) {
				if (strpos("`urhs'", "`=word("`endogenous'", `j')'") ==0) {
					di as error "{p}`=word("`endogenous'", `j')' is specified as an endogenous variable but not specified as a frontier or uhet variable."
					error 198
				}
			}
		}
		
		if ("`exogenous'"=="") {
			local allexogenous "`frontier' `urhs' `whet'"
			local leftout = wordcount("`leaveout'")
			forvalues j = 1/`leftout' {
				local allexogenous : subinstr local allexogenous "`=word("`leaveout'", `j')'" "", word all
			}
			local allexogenous "`instruments' `allexogenous'"
			
		}
		else local allexogenous "`instruments' `exogenous'"

		forvalues j = 1/$p {
			local allexogenous : subinstr local allexogenous "`=word("`endogenous'", `j')'" "", word all
		}
		
		local iveq = ""
		forvalues j = 1/$p {
			local ivin = word("`endogenous'", `j')
			local iveq "`iveq'(ivr`j'_`=word("`endogenous'", `j')': `=word("`endogenous'", `j')' = `allexogenous') (eta`j'_`=word("`endogenous'", `j')': ) "	
		}		

		local le = ""
		forvalues j = 1/`=($p*($p+1))/2' {
			local le = "`le'(le`j': ) "
		}

		foreach x in lhs frontier urhs whet endogenous instruments allexogenous {
			local `x': list retokenize `x'
			local `x': list uniq `x'
		}
		
		if("`header'"!="") {
			di _n(2) in red "{p}{sf:`c(current_date)'  `c(current_time)'}" 
			di _n(2) in red "{p}{sf:`=upper("Endogenous Stochastic `porc' Frontier Model")' (Model EN)}"
			di _n(1) in red "{p}{sf:Dependent Variable:} " as text "`lhs'"
			if("`constant'"!="noconstant") di _n(1) in red "{p}{sf:Frontier Variable(s):} " as text "Constant `frontier'"
			else di _n(1) in red "{p}{sf:Frontier Variable(s):} " as text "`frontier'"
			if (`unocons'==0) di _n(1) in red "{p}{sf:U Variable(s):} " as text "Constant `urhs'"
			else di _n(1) in red "{p}{sf:U Variable(s):} " as text "`urhs'"
			di _n(1) in red "{p}{sf:W Variable(s):} " as text "Constant `whet'"	
			di _n(1) in red "{p}{sf:Endogenous Variable(s):} " as text "`endogenous'"
			di _n(1) in red "{p}{sf:Excluded Instrument(s):} " as text "`instruments'"
			di _n(1) in red "{p}{sf:Exogenous Variable(s):} " as text "`allexogenous'{p_end}" _n(2)
		}
		
		if("`delve'"!="") di _n(1) in red "Delving into the problem..." 
		

		if("`initial'"=="" & "`delve'"!="") { 
			forvalues j = 1/$p {
				capture regress `=word("`endogenous'", `j')' `allexogenous'  `wgt' if `touse'
				tempvar `=word("`endogenous'", `j')'_res
				capture noisily predict ``=word("`endogenous'", `j')'_res', res
				tempname B`=`j'+1'
				capture matrix `B`=`j'+1''=e(b)
			}
			local wc1 = wordcount("`frontier'")
			local f_res = ""
			forvalues j = 1/`wc1' {
				capture confirm variable ``=word("`frontier'", `j')'_res'
				if !_rc local f_res = "`f_res'``=word("`frontier'", `j')'_res' "
			}
			
			local wc2 = wordcount("`urhs'")
			local u_res = ""
			forvalues j = 1/`wc2' {
				capture confirm variable ``=word("`urhs'", `j')'_res'
				if !_rc local u_res = "`u_res'``=word("`urhs'", `j')'_res' "
			}
			
			local wc3 = wordcount("`whet'")
			local wc4 = wordcount("`allexogenous'")
			
			local preal = $p
			tempname B1
			if ("`uhet'"=="`urhs'") {
				if scalar(prod)==1 capture frontier `lhs' `frontier' `f_res' `wgt' if `touse', u(`uhet' `u_res') v(`whet') `constant' tech(bfgs dfp bhhh ) iter(50)
				else capture frontier `lhs' `frontier' `f_res' `wgt' if `touse', cost u(`uhet' `u_res') v(`whet') `constant' tech(bfgs dfp bhhh ) iter(50)			
				matrix `B1'=e(b)
				local ll = e(ll)
				capture	sfkk `lhs' `frontier' `f_res' `wgt' if `touse', `porc' u(`uhet' `u_res') w(`whet') `constant' tech(bfgs dfp ) iter(50) nomess
				if `ll'<e(ll) matrix `B1'=e(b)
				}
			else {
				if scalar(prod)==1 capture frontier `lhs' `frontier' `f_res' `wgt' if `touse', u(`u_res' `uhet') v(`whet') `constant' tech(bfgs dfp bhhh ) iter(50)
				else capture frontier `lhs' `frontier' `f_res' `wgt' if `touse', cost u(`u_res' `uhet') v(`whet') `constant' tech(bfgs dfp bhhh ) iter(50)			
				matrix `B1'=e(b)
				local ll = e(ll)
				capture	sfkk `lhs' `frontier' `f_res' `wgt' if `touse', `porc' u(`u_res' `uhet') w(`whet') `constant' tech(bfgs dfp ) iter(50) nomess
				if `ll'<e(ll) matrix `B1'=e(b)
				}
			global p = `preal'
			global exo = 0
		}		
		
		local EE="Endogenous"
		local WV="lnsig2w"
		if ($exo==1) {
			local EE="Exogenous"
			local WV="lnsig2v"
		}
		
		
		
		if ("`fast'"!="") {
			global fastroute = 1
			if ("`technique'"=="") local technique="nr"
			ml model lf0 sfkk_ml (frontier_`lhs': `lhs' = `frontier', `constant') `iveq' /*        
				*/ (lnsig2u: `uhet') (`WV': `whet') `le'  `wgt' if `touse', /*
				*/ title("{bf:`EE' stochastic `=substr("`porc'",1,4)' frontier model with normal/half-normal specification}") /*
				*/ `log' tech(`technique') `mlmodel'
			}
		else {
			if ("`technique'"=="") local technique="bfgs"
			ml model d0 sfkk_ml (frontier_`lhs': `lhs' = `frontier', `constant') `iveq' /*        
				*/ (lnsig2u: `uhet') (`WV': `whet') `le'  `wgt' if `touse', /*
				*/ title("{bf:`EE' stochastic `=substr("`porc'",1,4)' frontier model with normal/half-normal specification}") /*
				*/ `log' tech(`technique') `mlmodel'
			}
		
		if("`initial'"!="") ml init `initial', copy
		
		if("`initial'"=="" & "`delve'"=="") ml search //, r(50)
		
		if("`initial'"=="" & "`delve'"!="") { 
			forvalues j = 1/`wc1' {
				capture ml init frontier_`lhs':`=word("`frontier'", `j')' = `=`B1'[1,colnumb(`B1',"frontier_`lhs':`=word("`frontier'", `j')'")]'
			}		
			capture ml init frontier_`lhs':_cons = `=`B1'[1,colnumb(`B1',"frontier_`lhs':_cons")]'
			
			forvalues j = 1/`wc2' {
				capture ml init lnsig2u:`=word("`urhs'", `j')' = `=`B1'[1,colnumb(`B1',"lnsig2u:`=word("`urhs'", `j')'")]'
			}					
			capture ml init lnsig2u:_cons = `=`B1'[1,colnumb(`B1',"lnsig2u:_cons")]'
			
			forvalues j = 1/`wc3' {
				capture ml init lnsig2w:`=word("`whet'", `j')' = `=`B1'[1,colnumb(`B1',"lnsig2w:`=word("`whet'", `j')'")]'
			}
			capture ml init lnsig2w:_cons = `=`B1'[1,colnumb(`B1',"lnsig2w:_cons")]'
			
			forvalues j = 1/$p {
				forvalues k = 1/`wc4' {
					capture ml init ivr`j'_`=word("`endogenous'", `j')':`=word("`allexogenous'", `k')' = `=`B`=`j'+1''[1,colnumb(`B`=`j'+1'',"`=word("`allexogenous'", `k')'")]'
				}
				capture ml init ivr`j'_`=word("`endogenous'", `j')':_cons = `=`B`=`j'+1''[1,colnumb(`B`=`j'+1'',"_cons")]'
				capture ml init eta`j'_`=word("`endogenous'", `j')':_cons = 0
			}
			
			forvalues j = 1/`=($p*($p+1))/2' {
				capture ml init le`j':_cons = 0.5
			}
		
		}	
	
		if ("`fast'"!="") ml max , noout iter(`iterate') `difficult' `mlmax' tol(`fast') ltol(`fast') nrtol(`fast') qtol(`fast') //`mlopts'
		if ("`fast'"=="") ml max , noout iter(`iterate') `difficult' `mlmax' //`mlopts'

		eret local cmd "sfkk"
		eret local cmdbase "ml"
		if ($exo==0) {
			estimates title: Model EN
			estimates store ModelEN
		}
		if ($exo==1) {
			estimates title: Model EX
			estimates store ModelEX			
		}
		
		
		if ("`nicely'"=="" & "`nooutput'"=="") {
			ml display, neq(`=$p*2+3') `mldisplay'		
			}
		else {
			local NEN : di %4.0f round(e(N),1)
			local llEN : di %8.2f round(e(ll),0.01)
			local etalist = ""
			forvalues j = 1/$p {
				local ivin = word("`endogenous'", `j')
				local beta`j': di %4.3f round(_b[eta`j'_`=word("`endogenous'", `j')':_cons],0.001)
				local seta`j': di %4.3f round(_se[eta`j'_`=word("`endogenous'", `j')':_cons],0.001)
				//local teta`j'=`beta`j''/`seta`j''
				scalar peta`j'= (2 * ttail(10^16,abs(_b[eta`j'_`=word("`endogenous'", `j')':_cons]/_se[eta`j'_`=word("`endogenous'", `j')':_cons])))
				local steta="   "
				if (scalar(peta`j')<0.001) local steta="***"
				else if (scalar(peta`j')<0.01) local steta="** "
				else if (scalar(peta`j')<0.05) local steta="*  "
				local rmargin=55 //if with compare `tw'-(`cw'+1) 64-9
				if ("`compare'"=="") local rmargin=34 // 43-9
				if (`j'!=$p) local etalist = "`etalist'" + ///
					"{bf:`=abbrev("eta`j' (`=word("`endogenous'", `j')')",22)'}" + ///
					"{ralign `=`rmargin'-`=strlen("`=abbrev("eta`j' (`=word("`endogenous'", `j')')",22)'")'':{bf:`beta`j''`steta'}}" + ///
					"{ralign 9:{bf:(`seta`j'')}}" + "{break}"
				if (`j'==$p) local etalist = "`etalist'" + ///
					"{bf:`=abbrev("eta`j' (`=word("`endogenous'", `j')')",22)'}" + ///
					"{ralign `=`rmargin'-`=strlen("`=abbrev("eta`j' (`=word("`endogenous'", `j')')",22)'")'':{bf:`beta`j''`steta'}}" + ///
					"{ralign 9:{bf:(`seta`j'')}}"
			}
		}		
		
		if ("`test'"!="" | "`nicely'"!="") {
			local etaeq = ""
		    forvalues j = 1/$p {
				local etaeq "`etaeq'[eta`j'_`=word("`endogenous'", `j')']_cons "	
			}			
			if ("`nicely'"=="") {
				di _n(2) "{bf:{center 64:eta Endogeneity Test}}"
				di "{hline 64}"
				di "Ho: Correction for endogeneity is not necessary."
				di "Ha: There is endogeneity in the model and correction is needed."
				test "`etaeq'"
				if (r(p)<0.001) di _n(1) "{bf:Result: Reject Ho at 0.1% level.}"
				else if (r(p)<0.01) di _n(1) "{bf:Result: Reject Ho at 1% level.}"
				else if (r(p)<0.05) di _n(1) "{bf:Result: Reject Ho at 5% level.}"
				else if (r(p)<0.1) di _n(1) "{bf:Result: Reject Ho at 10% level.}"
				else di _n(1) "{bf:Result: Cannot reject Ho at 10% level.}"
			}
			else capture test "`etaeq'"
			local etatestp : di %5.3f round(r(p),0.001)
			local etatestX2 : di round(r(chi2),0.01)
			ereturn scalar etatestp = r(p)
			ereturn scalar etatestX2 = r(chi2)
		}						
		
		if ("`efficiency'"!="" | "`nicely'"!="") {
			tempvar term1 lnsigu2 lnsigw2 xb ei sigs2 mustar sigstar ENeff
			quietly {
				gen double `term1' = 0
				forvalues j = 1/$p {
					tempvar zd`j' epsilon`j'
					tempname eta`j'
					scalar `eta`j'' = _b[eta`j'_`=word("`endogenous'", `j')':_cons]
					predict double `zd`j'', xb equation(ivr`j'_`=word("`endogenous'", `j')')
					gen double `epsilon`j'' = `=word("`endogenous'", `j')' - `zd`j''
					replace `term1' = `term1' +  (1/sqrt(exp(_b[lnsig2w:_cons]))) * scalar(`eta`j'') * `epsilon`j''
				}
				predict double `lnsigu2', xb equation(lnsig2u)
				predict double `lnsigw2', xb equation(lnsig2w)
				predict double `xb', xb equation(frontier_`lhs')
				gen double `ei' = `lhs' - `xb' - sqrt(exp(`lnsigw2')) * `term1'
				gen double `sigs2' = exp(`lnsigw2') + exp(`lnsigu2')
				gen double `mustar' = (-scalar(prod) * `ei' * exp(`lnsigu2')) / `sigs2'
				gen double `sigstar' = sqrt((exp(`lnsigw2') * exp(`lnsigu2')) / `sigs2')
				gen double `ENeff' = (((1 - normal(scalar(prod) * `sigstar' - `mustar'/`sigstar')) / (1 - normal(-`mustar'/`sigstar'))) * exp(-scalar(prod) * `mustar' + 0.5 * `sigstar'^2))^scalar(prod)
				if ("`efficiency'"!="") {
					capture drop `effvar'_EN			
					gen double `effvar'_EN=`ENeff'
				}
			}
			if ("`nicely'"=="") {
				capture summ `ENeff' `wgt' if `touse', d
				di _n(2) "{bf:{center 50:Summary of Model EN `=proper("`porc'")' Efficiency}}"
				di "{hline 50}"
				di "{txt}Mean Efficiency{tab}{tab}" r(mean)
				di "Median Efficiency{tab}" r(p50)
				di "Minimum Efficiency{tab}" r(min)
				di "Maximum Efficiency{tab}" r(max)
				di "Standard Deviation{tab}" r(sd)				
				di _n(1) "where"
				di "0 = Perfect `porc' inefficiency"
				di "1 = Perfect `porc' efficiency"				
			}
			else capture summ `ENeff' `wgt' if `touse', d
			local meaneffEN : di %7.4f round(r(mean),0.0001)
			local medeffEN : di %7.4f round(r(p50),0.0001)
			ereturn scalar effmean = r(mean)
			ereturn scalar effmed = r(p50)
		}
		
		
		
		if ("`compare'"!="") {
			di _n(2) in red "Analyzing the exogenous comparison model (Model EX)..." _n(1)
			global exo=1
			local preal = $p
						
			if ("`nicely'"=="") {
				sfkk `lhs' `frontier' `wgt' if `touse', `porc' u(`uhet' ) w(`whet') `constant' iter(`iterate') tech(bfgs) nomess noref
			}
			else sfkk `lhs' `frontier' `wgt' if `touse', `porc' u(`uhet' ) w(`whet') `constant' iter(`iterate') tech(bfgs) nomess noout noref
			
			global p = `preal'
			
			if ("`efficiency'"!="" | "`nicely'"!="") {
				tempvar lnsigu2 lnsigv2 xb ei sigs2 mustar sigstar EXeff 
				quietly {
					predict double `lnsigu2', xb equation(lnsig2u)
					predict double `lnsigv2', xb equation(lnsig2v)
					predict double `xb', xb equation(frontier_`lhs')
					gen double `ei' = `lhs' - `xb' - sqrt(exp(`lnsigv2')) 
					gen double `sigs2' = exp(`lnsigv2') + exp(`lnsigu2')
					gen double `mustar' = (-scalar(prod) * `ei' * exp(`lnsigu2')) / `sigs2'
					gen double `sigstar' = sqrt((exp(`lnsigv2') * exp(`lnsigu2')) / `sigs2')
					gen double `EXeff' = (((1 - normal(scalar(prod) * `sigstar' - `mustar'/`sigstar')) / (1 - normal(-`mustar'/`sigstar'))) * exp(-scalar(prod) * `mustar' + 0.5 * `sigstar'^2))^scalar(prod)
					if ("`efficiency'"!="") {
						capture drop `effvar'_EX			
						gen double `effvar'_EX=`EXeff'
					}
				}

				if ("`nicely'"=="") {
					capture summ `EXeff' `wgt' if `touse', d
					di _n(2) "{bf:{center 50:Summary of Model EX `=proper("`porc'")' Efficiency}}"
					di "{hline 50}"
					di "{txt}Mean Efficiency{tab}{tab}" r(mean)
					di "Median Efficiency{tab}" r(p50)
					di "Minimum Efficiency{tab}" r(min)
					di "Maximum Efficiency{tab}" r(max)
					di "Standard Deviation{tab}" r(sd)				
					di _n(1) "where"
					di "0 = Perfect `porc' inefficiency"
					di "1 = Perfect `porc' efficiency"				
				}
				else capture summ `EXeff' `wgt' if `touse', d
				local meaneffEX : di %6.4f round(r(mean),0.0001)
				local medeffEX : di %6.4f round(r(p50),0.0001)
				ereturn scalar effmean = r(mean)
				ereturn scalar effmed = r(p50)
			}
			local NEX : di round(e(N),1)
			local llEX : di round(e(ll),0.01)
			
		}

		
		if ("`compare'"!="" & "`nicely'"!="") {			
			local vw = 22 //variable name width
			local cw = 8 //column width
			local tw = `vw' + 1 + `cw' + 3 + 1 + `cw' + 1 + `cw' + 3 + 1 + `cw' //table width
			if("`constant'"!="noconstant") local firsteq="#1:_cons #1:* "
			else local firsteq="#1:* "
			capture di _b[lnsig2u:_cons]
			if (_rc!=111) local secondeq="lnsig2u:_cons lnsig2u:*"
			else local secondeq="lnsig2u:*"
			capture di _b[lnsig2v:_cons]
			if (_rc!=111) local thirdeq="lnsig2v:_cons lnsig2v:* lnsig2w:_cons lnsig2w:*"
			else local thirdeq="lnsig2v:* lnsig2w:*"
			capture estout
			if (_rc==199) capture ssc install estout
			local eql ""Dep.var: `lhs'" "Dep.var: ln(sigma`=char(178)'_u)" "Dep.var: ln(sigma`=char(178)'_v)" "Dep.var: ln(sigma`=char(178)'_w)""
			capture {
			version 14: local eql ""Dep.var: `lhs'" "Dep.var: ln(`=uchar(963)'`=uchar(178)'_u)" "Dep.var: ln(`=uchar(963)'`=uchar(178)'_v)" "Dep.var: ln(`=uchar(963)'`=uchar(178)'_w)""
			}
			estout ModelEX ModelEN, ///
				title({bf:Table: Estimation Results})  ///
				mlabels("       Model EX" "       Model EN", span) ///
				collabel(none) ///
				varwidth(`vw') ///
				modelwidth(`cw') ///
				equations(1:1) ///
				cells("b(star fmt(3)) se(par fmt(3))") ///
				keep(#1: lnsig2u: lnsig2v: lnsig2w:) ///
				order(`firsteq' `secondeq' `thirdeq') ///
				varlabels(_cons Constant) ///
				eqlabel( `eql' , span)			
			di "`etalist'"
			di "{hline `tw'}"
			di "eta Endogeneity Test  " ///
				"{bf:{ralign `=1+`cw'+3+1+`cw'+1+`cw'+3':X2=`etatestX2'}{ralign `=1+`cw'':p=`etatestp'}}"
			di "{hline `tw'}"
			di "Observations          " ///
				"{space 2}{bf:{center `=`cw'+3+1+`cw'':`NEX'}{space 1}{center `=`cw'+3+`cw'':`NEN'}}" 
			di "Log Likelihood        " ///
				"{space 2}{bf:{center `=`cw'+3+1+`cw'':`llEX'}{space 1}{center `=`cw'+3+`cw'':`llEN'}}" 
			di "Mean " substr(proper("`porc'"),1,4) " Efficiency  " ///
				"{space 2}{bf:{center `=`cw'+3+1+`cw'':`meaneffEX'}{space 1}{center `=`cw'+3+`cw'':`meaneffEN'}}" 
			di "Median " substr(proper("`porc'"),1,4) " Efficiency" ///
				"{space 2}{bf:{center `=`cw'+3+1+`cw'':`medeffEX'}{space 1}{center `=`cw'+3+`cw'':`medeffEN'}}" 
			di "{hline `tw'}"
			di "{p 0 0 0 `tw'}Notes: Standard errors are in parentheses. Asterisks indicate significance at the {bind:0.1% (***)}, {bind:1% (**)} and {bind:5% (*)} levels."
			di "{hline `tw'}"			
		}
		
		if ("`compare'"=="" & "`nicely'"!="") {
			local vw = 22 //variable name width
			local cw = 8 //column width
			local tw = `vw' + 1 + `cw' + 3 + 1 + `cw' //table width
			if("`constant'"!="noconstant") local firsteq="#1:_cons #1:*"
			else local firsteq="#1:*"
			capture di _b[lnsig2u:_cons]
			if (_rc!=111) local secondeq="lnsig2u:_cons lnsig2u:*"
			else local secondeq="lnsig2u:*"
			capture di _b[lnsig2w:_cons]
			if (_rc!=111) local thirdeq="lnsig2w:_cons lnsig2w:*"
			else local thirdeq="lnsig2w:*"
			capture estout
			if (_rc==199) capture ssc install estout
			local eql ""Dep.var: `lhs'" "Dep.var: ln(sigma`=char(178)'_u)" "Dep.var: ln(sigma`=char(178)'_w)""
			capture {
			version 14: local eql ""Dep.var: `lhs'" "Dep.var: ln(`=uchar(963)'`=uchar(178)'_u)" "Dep.var: ln(`=uchar(963)'`=uchar(178)'_w)""
			}
			estout ModelEN, ///  
				title({bf:Table: Estimation Results})  ///
				mlabels("       Model EN", span) ///  
				collabel(none) ///
				varwidth(`vw') ///
				modelwidth(`cw') /// 
				equations(1) ///
				cells("b(star fmt(3)) se(par fmt(3))") ///
				keep(#1: lnsig2u: lnsig2w:) ///
				order(`firsteq' `secondeq' `thirdeq') ///
				varlabels(_cons Constant) ///
				eqlabel( `eql' , span)
			di "`etalist'"
			di "{hline `tw'}"
			di "eta Endogeneity Test  " ///
				"{bf:{ralign `=1+`cw'+3':X2=`etatestX2'}{ralign `=1+`cw'':p=`etatestp'}}"
			di "{hline `tw'}"
			di "Observations          " ///
				"{space 2}{bf:{center `=`cw'+3+`cw'':`NEN'}}" 
			di "Log Likelihood        " ///
				"{space 2}{bf:{center `=`cw'+3+`cw'':`llEN'}}" 
			di "Mean " substr(proper("`porc'"),1,4) " Efficiency  " ///
				"{space 2}{bf:{center `=`cw'+3+`cw'':`meaneffEN'}}" 
			di "Median " substr(proper("`porc'"),1,4) " Efficiency" ///
				"{space 2}{bf:{center `=`cw'+3+`cw'':`medeffEN'}}" 
			di "{hline `tw'}"
			di "{p 0 0 0 `tw'}Notes: Standard errors are in parentheses. Asterisks indicate significance at the {bind:0.1% (***)}, {bind:1% (**)} and {bind:5% (*)} levels."
			di "{hline `tw'}"			
		}
	
		if ("`nomessage'"=="") {	
				di _n(1) "{bf:{ul:Recommended Citations}}"
				di _n(1) "{pstd}The following two citations are recommended for referring to the sfkk program "
				di "package and the underlying econometric methodology: {p_end}"
				di _n(1) `"{phang}Karakaplan, Mustafa U. (2016) "Estimating Endogenous Stochastic"'
				di `"Frontier Models in Stata." {it:Forthcoming.}  {browse "www.stata-journal.com":The Stata Journal}."'
				di " Also available at {browse www.mukarakaplan.com}{p_end}"
				di _n(1) "{phang}Karakaplan, Mustafa U. and Kutlu, Levent (2013)"
				di `""Handling Endogeneity in Stochastic Frontier Analysis." "'
				di `"Available at "'
				di "{browse www.mukarakaplan.com}{p_end}"
		}
		
		capture drop _est_ModelEN
		capture drop _est_ModelEX

		if ("`beep'"!="") beep
		if ("`timer'"!="") {
			timer off 1
			capture timer list 1
			di _n(2) in red "Completed in " `=int(r(t1)/3600)' " hour(s), " `=int((r(t1)-(int(r(t1)/3600)*3600))/60)' " minute(s) and " `=round(r(t1)-int((r(t1)-(int(r(t1)/3600)*3600))/60)*60)' " second(s)." 
		}	
end




program Replay
		syntax [, Level(cilevel)]
		capture estimates restore ModelEN
		di "{hline `=c(linesize)'}"
		di "{center `=c(linesize)':{bf:MODEL EN}}"
		di "{hline `=c(linesize)'}"
		ml display, neq(`=$p*2+3') level(`level')
		di _n(2)
		capture estimates restore ModelEX
		if !_rc {
			di "{hline `=c(linesize)'}"
			di "{center `=c(linesize)':{bf:MODEL EX}}"
			di "{hline `=c(linesize)'}"
			ml display, level(`level')
		}
end




