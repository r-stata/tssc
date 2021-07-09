*! version 1.0.1  09jan2018
*! version 1.0.0  01jan2018
/*
-xtsfkk-
version 1.0.0 
January 1, 2018
Program Author: Dr. Mustafa Ugur Karakaplan
E-mail: mukarakaplan@yahoo.com
Website: www.mukarakaplan.com

Recommended Citations:

The following citations are recommended for referring to the xtsfkk
program package, underlying econometric methodology, and examples:

+ Karakaplan, Mustafa U. (2018) "xtsfkk: Stata Module for Endogenous 
Panel Stochastic Frontier Models." Available at Boston College, 
Department of Economics, Statistical Software Components (SSC) S458445.

+ Karakaplan, Mustafa U. and Kutlu, Levent (2017) "Endogeneity in Panel
Stochastic Frontier Models." Applied Economics


More Recommended Citations:

Karakaplan, Mustafa U. (2017) "Fitting Endogenous Stochastic Frontier
Models in Stata." The Stata Journal

Karakaplan, Mustafa U. and Kutlu, Levent (2017) "Handling Endogeneity in
Stochastic Frontier Analysis." Economics Bulletin

Karakaplan, Mustafa U. and Kutlu, Levent (2018) "School District
Consolidation Policies: Endogenous Cost Inefficiency and Saving
Reversals." Empirical Economics

Kutlu, Levent (2010) "Battese–Coelli Estimator with Endogenous 
Regressors." Economics Letters 
*/

program xtsfkk
		version 13.1
		if replay() {
			if "`2'"=="version" | "`2'"=="ver" | "`2'"=="vers" | "`2'"=="versi" | "`2'"=="versio" {
				di _n(1) "{bf:{ul:Version}}"
				di _n(1) "{txt}{sf}    xtsfkk version 1.0.1"
				di "    January 9, 2018"
				di _n(1) "{bf:{ul:Program Author}}"
				di _n(1) "    Dr. Mustafa Ugur Karakaplan"
				di `"    E-mail: {browse "mailto:mukarakaplan@yahoo.com":mukarakaplan@yahoo.com}"'
				di "    Website: {browse www.mukarakaplan.com}"
				di _n(1) "{pstd}For comments, suggestions, or questions about {cmd: xtsfkk}, please send an email to me."
				di _n(1) "{bf:{ul:Recommended Citations}}"
				di _n(1) "{pstd}The following citations are recommended for referring to the xtsfkk program package, the underlying econometric methodology, and examples: {p_end}"
				di _n(1) `"{phang}+ Karakaplan, Mustafa U. (2018) "xtsfkk: Stata Module for Endogenous Panel Stochastic Frontier Models." Available at Boston College, Department of Economics, Statistical Software Components (SSC) {browse "https://ideas.repec.org/c/boc/bocode/s458445.html":S458445}{p_end}"'
				di _n(1) `"{phang}+ Karakaplan, Mustafa U. and Kutlu, Levent (2017) "Endogeneity in Panel Stochastic Frontier Models." {browse "http://www.tandfonline.com/doi/abs/10.1080/00036846.2017.1363861":Applied Economics}{p_end}"'
				di _n(1) "{help xtsfkk##citation:{bf:{ul:More Recommended Citations}}}"
				exit
			}
			else if ("`e(cmd)'" != "xtsfkk") error 301
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
		
		capture xtset
		if (_rc!=0) {
			di as error "{p} Use {bf:xtset} to specify panel and time variables"
			error _rc
		}
		
		if ("`timer'"!="") {
			timer clear 1
			timer on 1
		}
		
		if ("`norefresh'"=="") {
			capture estimates drop ModelEN
			capture estimates drop ModelEX
		}
		
		global savedmatrix = ""
		if ("`save'"!="") {
			capture matin4
			if (_rc==199) capture ssc install matin4-matout4
			global savedmatrix = "`save'"
		}
		
		gettoken lhs frontier : varlist
		_fv_check_depvar `lhs'
		ereturn clear
		if"`weight'" != "" local wgt "[`weight'`exp']"
		marksample touse
		capture set matsize 800
		capture set matsize 11000
		
		local porc = "production" //default is production frontier
		local torc = "tech"
		scalar prod = 1
		if ("`production'" !="" & "`cost'" !="") {
			di as error "{p}Specify either {bf:{ul:prod}uction} or {bf:{ul:cost}}. Do not specify both."
			error 198
		}
		else if ("`cost'" !="") {
		local porc = "cost"
		local torc = "cost"
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
	
	//mark
		if ("`uhet'"!="") {
			local uhet = subinstr("`uhet'", ",", " ,", .)
			gettoken urhs uno: uhet, parse(",")
			if (strpos("`uno'",",")!=0 & strpos("`uno'","nocons")!=0) local unocons=1
			else local unocons=0
			if ("`urhs'"==",") {
				di as err "{p}Specify at least one variable or the constant in Uhet."
				error 198
			}
		}
		else local unocons=0
	//
	
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
				
				xtsfkk `lhs' `frontier' `wgt' if `touse', `porc' u(`uhet') w(`whet') `constant' tech(`technique') `beep' noref
				
				di as error _n(1) "{p}Warning: Exogenous model is analyzed. Specify both {bf:{ul:en}dogenous()} and {bf:{ul:i}nstruments()} to analyze the endogenous model."
				if ("`timer'"!="") {
					timer off 1
					Timermessage
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
			//global fastroute = 1
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
		
	//mark
		
		// clean strings
		foreach x in lhs frontier uhet urhs whet endogenous instruments allexogenous {
			local `x': list retokenize `x'
			local `x': list uniq `x'
		}
		
	//

		local iveq = ""
		forvalues j = 1/$p {
			local ivin = word("`endogenous'", `j')
			local iveq "`iveq'(ivr`j'_`=word("`endogenous'", `j')': `=word("`endogenous'", `j')' = `allexogenous') (eta`j'_`=word("`endogenous'", `j')': ) "	
		}		

		local le = ""
		forvalues j = 1/`=($p*($p+1))/2' {
			local le = "`le'(le`j': ) "
		}
		
		if("`header'"!="") {
			di _n(2) in red "{p}{sf:`c(current_date)'  `c(current_time)'}" 
			di _n(2) in red "{p}{sf:`=upper("Endogenous Panel Stochastic `porc' Frontier Model")' (Model EN)}"
			di _n(1) in red "{p}{sf:Dependent Variable:} " as text "`lhs'"			
			if("`constant'"!="noconstant") {
				if(`=wordcount("`frontier'")'==0) di _n(1) in red "{p}{sf:Frontier Variable:} " as text "Constant `frontier'"
				if(`=wordcount("`frontier'")'>0) di _n(1) in red "{p}{sf:Frontier Variables:} " as text "Constant `frontier'"
			}			
			else {
				if(`=wordcount("`frontier'")'==1) di _n(1) in red "{p}{sf:Frontier Variable:} " as text "`frontier'"
				if(`=wordcount("`frontier'")'>1) di _n(1) in red "{p}{sf:Frontier Variables:} " as text "`frontier'"
			}			
			if (`unocons'==0) {
				if(`=wordcount("`urhs'")'==0) di _n(1) in red "{p}{sf:U Variable:} " as text "Constant `urhs'"
				if(`=wordcount("`urhs'")'>0) di _n(1) in red "{p}{sf:U Variables:} " as text "Constant `urhs'"
			}
			else {
				if(`=wordcount("`urhs'")'==1) di _n(1) in red "{p}{sf:U Variable:} " as text "`urhs'"
				if(`=wordcount("`urhs'")'>1) di _n(1) in red "{p}{sf:U Variables:} " as text "`urhs'"
			}			
			if(`=wordcount("`whet'")'==0) di _n(1) in red "{p}{sf:W Variable:} " as text "Constant `whet'"	
			if(`=wordcount("`whet'")'>0) di _n(1) in red "{p}{sf:W Variables:} " as text "Constant `whet'"	
			if(`=wordcount("`endogenous'")'==1) di _n(1) in red "{p}{sf:Endogenous Variable:} " as text "`endogenous'"
			if(`=wordcount("`endogenous'")'>1) di _n(1) in red "{p}{sf:Endogenous Variables:} " as text "`endogenous'"
			if(`=wordcount("`instruments'")'==1) di _n(1) in red "{p}{sf:Added Instrument:} " as text "`instruments'"
			if(`=wordcount("`instruments'")'>1) di _n(1) in red "{p}{sf:Added Instruments:} " as text "`instruments'"
			if(`=wordcount("`allexogenous'")'==1) di _n(1) in red "{p}{sf:Exogenous Variable:} " as text "`allexogenous'{p_end}"
			if(`=wordcount("`allexogenous'")'>1) di _n(1) in red "{p}{sf:Exogenous Variables:} " as text "`allexogenous'{p_end}"
			capture xtset
			di _n(1) in red "{p}Panel Variable: " as text "`r(panelvar)'"
			di _n(1) in red "{p}Time Variable: " as text "`r(timevar)'" _n(2)
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
				capture	xtsfkk `lhs' `frontier' `f_res' `wgt' if `touse', `porc' u(`uhet' `u_res') w(`whet') `constant' tech(bfgs dfp ) iter(50) nomess
				if `ll'<e(ll) matrix `B1'=e(b)
				}
			else {
				if scalar(prod)==1 capture frontier `lhs' `frontier' `f_res' `wgt' if `touse', u(`u_res' `uhet') v(`whet') `constant' tech(bfgs dfp bhhh ) iter(50)
				else capture frontier `lhs' `frontier' `f_res' `wgt' if `touse', cost u(`u_res' `uhet') v(`whet') `constant' tech(bfgs dfp bhhh ) iter(50)			
				matrix `B1'=e(b)
				local ll = e(ll)
				capture	xtsfkk `lhs' `frontier' `f_res' `wgt' if `touse', `porc' u(`u_res' `uhet') w(`whet') `constant' tech(bfgs dfp ) iter(50) nomess
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
			//global fastroute = 1
			if ("`technique'"=="") local technique="bfgs"
			//lf0
			ml model d0 xtsfkk_ml (frontier_`lhs': `lhs' = `frontier', `constant') `iveq' /*        
				*/ (lnsig2u: `uhet') (`WV': `whet') `le'  `wgt' if `touse', /*
				*/ title("{bf:`EE' stochastic `=substr("`porc'",1,4)' frontier model with normal/half-normal specification}") /*
				*/ `log' tech(`technique') `mlmodel'
			}
		else {
			if ("`technique'"=="") local technique="bfgs"
			ml model d0 xtsfkk_ml (frontier_`lhs': `lhs' = `frontier', `constant') `iveq' /*        
				*/ (lnsig2u: `uhet') (`WV': `whet') `le'  `wgt' if `touse', /*
				*/ title("{bf:`EE' stochastic `=substr("`porc'",1,4)' frontier model with normal/half-normal specification}") /*
				*/ `log' tech(`technique') `mlmodel'
			}
		
		//load overrides init
		if ("`load'"!="") {
			capture matin4
			if (_rc==199) capture ssc install matin4-matout4
			if (substr("`load'",-4,1) == ".") {
				matin4 loadedmatrix using "`load'.old"
			}
			else {
				matin4 loadedmatrix using "`load'.est.old"
			}
			local initial "loadedmatrix"
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

		eret local cmd "xtsfkk"
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
			tempvar term1 eit eit2 Ti eidot2 hit2 hidot2 exh eidothidot lnsigu2 lnsigw2 xb muistar sigistar ENeff
			tempname mu2
			quietly {
				scalar `mu2' = 0
				gen double `term1' = 0 
				forvalues j = 1/$p {
					tempvar zd`j' epsilon`j'
					tempname eta`j'
					scalar `eta`j'' = _b[eta`j'_`=word("`endogenous'", `j')':_cons]
					predict double `zd`j'', xb equation(ivr`j'_`=word("`endogenous'", `j')')
					gen double `epsilon`j'' = `=word("`endogenous'", `j')' - `zd`j''
					replace `term1' = `term1' +  scalar(`eta`j'') * `epsilon`j''
				}
				predict double `lnsigu2', xb equation(lnsig2u)
				predict double `lnsigw2', xb equation(lnsig2w)
				predict double `xb', xb equation(frontier_`lhs')
				gen double `eit' = `lhs' - `xb' - `term1'
				xtset
				sort `r(panelvar)' `r(timevar)'
				by `r(panelvar)': egen double `Ti' = count(`r(timevar)')
				gen double `eit2' = `eit'^2
				xtset
				sort `r(panelvar)' `r(timevar)'
				by `r(panelvar)': egen double `eidot2' = total(`eit2')				
				gen double `hit2' = exp(`lnsigu2') / exp(_b[lnsig2u:_cons]) 
				xtset
				sort `r(panelvar)' `r(timevar)'
				by `r(panelvar)': egen double `hidot2' = total(`hit2')
				gen double `exh' = `eit' * sqrt(`hit2')
				xtset
				sort `r(panelvar)' `r(timevar)'
				by `r(panelvar)': egen double `eidothidot' = total(`exh')
				gen double `muistar' = ((exp(_b[lnsig2w:_cons])*sqrt(`mu2') - (scalar(prod) * exp(_b[lnsig2u:_cons])*`eidothidot'))/(exp(_b[lnsig2u:_cons])*`hidot2'+exp(_b[lnsig2w:_cons])))
				gen double `sigistar' = sqrt((exp(_b[lnsig2u:_cons])*exp(_b[lnsig2w:_cons]))/(exp(_b[lnsig2u:_cons])*`hidot2'+exp(_b[lnsig2w:_cons])))
				gen double `ENeff' = exp( -sqrt(`hit2') * ( `muistar' + ((`sigistar' * normalden(`muistar'/`sigistar'))/normal(`muistar'/`sigistar')) ) )
				if ("`efficiency'"!="") {
					capture drop `effvar'_EN			
					gen double `effvar'_EN=`ENeff'
				}
			}
			if ("`nicely'"=="") {
				capture summ `ENeff' `wgt' if `touse', d
				di _n(2) "{bf:{center 50:Summary of Model EN `=proper("`torc'")' Efficiency}}"
				di "{hline 50}"
				di "{txt}Mean Efficiency{tab}{tab}" r(mean)
				di "Median Efficiency{tab}" r(p50)
				di "Minimum Efficiency{tab}" r(min)
				di "Maximum Efficiency{tab}" r(max)
				di "Standard Deviation{tab}" r(sd)				
				di _n(1) "where"
				di "0 = Perfect `torc' inefficiency"
				di "1 = Perfect `torc' efficiency"				
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
				xtsfkk `lhs' `frontier' `wgt' if `touse', `porc' u(`uhet' ) w(`whet') `constant' iter(`iterate') tech(bfgs) nomess noref
			}
			else xtsfkk `lhs' `frontier' `wgt' if `touse', `porc' u(`uhet' ) w(`whet') `constant' iter(`iterate') tech(bfgs) nomess noout noref
			
			global p = `preal'
			
			if ("`efficiency'"!="" | "`nicely'"!="") {
			tempvar term1 eit eit2 Ti eidot2 hit2 hidot2 exh eidothidot lnsigu2 lnsigv2 xb muistar sigistar EXeff
			tempname mu2
			quietly {
				scalar `mu2' = 0
				/*
				gen double `term1' = 0 
				forvalues j = 1/$p {
					tempvar zd`j' epsilon`j'
					tempname eta`j'
					scalar `eta`j'' = _b[eta`j'_`=word("`endogenous'", `j')':_cons]
					predict double `zd`j'', xb equation(ivr`j'_`=word("`endogenous'", `j')')
					gen double `epsilon`j'' = `=word("`endogenous'", `j')' - `zd`j''
					replace `term1' = `term1' +  scalar(`eta`j'') * `epsilon`j''
				}*/
				predict double `lnsigu2', xb equation(lnsig2u)
				predict double `lnsigv2', xb equation(lnsig2v)
				predict double `xb', xb equation(frontier_`lhs')
				gen double `eit' = `lhs' - `xb' //- `term1'
				xtset
				sort `r(panelvar)' `r(timevar)'
				by `r(panelvar)': egen double `Ti' = count(`r(timevar)')
				gen double `eit2' = `eit'^2
				xtset
				sort `r(panelvar)' `r(timevar)'
				by `r(panelvar)': egen double `eidot2' = total(`eit2')				
				gen double `hit2' = exp(`lnsigu2') / exp(_b[lnsig2u:_cons]) 
				xtset
				sort `r(panelvar)' `r(timevar)'
				by `r(panelvar)': egen double `hidot2' = total(`hit2')
				gen double `exh' = `eit' * sqrt(`hit2')
				xtset
				sort `r(panelvar)' `r(timevar)'
				by `r(panelvar)': egen double `eidothidot' = total(`exh')
				gen double `muistar' = ((exp(_b[lnsig2v:_cons])*sqrt(`mu2') - (scalar(prod) * exp(_b[lnsig2u:_cons])*`eidothidot'))/(exp(_b[lnsig2u:_cons])*`hidot2'+exp(_b[lnsig2v:_cons])))
				gen double `sigistar' = sqrt((exp(_b[lnsig2u:_cons])*exp(_b[lnsig2v:_cons]))/(exp(_b[lnsig2u:_cons])*`hidot2'+exp(_b[lnsig2v:_cons])))
				gen double `EXeff' = exp( -sqrt(`hit2') * ( `muistar' + ((`sigistar' * normalden(`muistar'/`sigistar'))/normal(`muistar'/`sigistar')) ) )
				if ("`efficiency'"!="") {
					capture drop `effvar'_EX			
					gen double `effvar'_EX=`EXeff'
				}
			}
				if ("`nicely'"=="") {
					capture summ `EXeff' `wgt' if `touse', d
					di _n(2) "{bf:{center 50:Summary of Model EX `=proper("`torc'")' Efficiency}}"
					di "{hline 50}"
					di "{txt}Mean Efficiency{tab}{tab}" r(mean)
					di "Median Efficiency{tab}" r(p50)
					di "Minimum Efficiency{tab}" r(min)
					di "Maximum Efficiency{tab}" r(max)
					di "Standard Deviation{tab}" r(sd)				
					di _n(1) "where"
					di "0 = Perfect `torc' inefficiency"
					di "1 = Perfect `torc' efficiency"				
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
				"{space 2}{bf:{center `=`cw'+3+1+`cw'':`NEX'}{space 1}{center `=1+`cw'+3+`cw'':`NEN'}}" 
			di "Log Likelihood        " ///
				"{space 2}{bf:{center `=`cw'+3+1+`cw'':`llEX'}{space 1}{center `=`cw'+3+`cw'':`llEN'}}" 
			di "Mean " substr(proper("`torc'"),1,4) " Efficiency  " ///
				"{space 2}{bf:{center `=`cw'+3+1+`cw'':`meaneffEX'}{space 1}{center `=`cw'+3+`cw'':`meaneffEN'}}" 
			di "Median " substr(proper("`torc'"),1,4) " Efficiency" ///
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
				"{space 2}{bf:{center `=1+`cw'+3+`cw'':`NEN'}}" 
			di "Log Likelihood        " ///
				"{space 2}{bf:{center `=`cw'+3+`cw'':`llEN'}}" 
			di "Mean " substr(proper("`torc'"),1,4) " Efficiency  " ///
				"{space 2}{bf:{center `=`cw'+3+`cw'':`meaneffEN'}}" 
			di "Median " substr(proper("`torc'"),1,4) " Efficiency" ///
				"{space 2}{bf:{center `=`cw'+3+`cw'':`medeffEN'}}" 
			di "{hline `tw'}"
			di "{p 0 0 0 `tw'}Notes: Standard errors are in parentheses. Asterisks indicate significance at the {bind:0.1% (***)}, {bind:1% (**)} and {bind:5% (*)} levels."
			di "{hline `tw'}"			
		}
	
		if ("`nomessage'"=="") {	
				di _n(1) "{bf:{ul:Recommended Citations}}"
				di _n(1) "{pstd}The following citations are recommended for referring to the xtsfkk program package, the underlying econometric methodology, and examples: {p_end}"
				di _n(1) `"{phang}+ Karakaplan, Mustafa U. (2018) "xtsfkk: Stata Module for Endogenous Panel Stochastic Frontier Models." Available at Boston College, Department of Economics, Statistical Software Components (SSC) {browse "https://ideas.repec.org/c/boc/bocode/s458445.html":S458445}{p_end}"'
				di _n(1) `"{phang}+ Karakaplan, Mustafa U. and Kutlu, Levent (2017) "Endogeneity in Panel Stochastic Frontier Models." {browse "http://www.tandfonline.com/doi/abs/10.1080/00036846.2017.1363861":Applied Economics}{p_end}"'
				di _n(1) "{help xtsfkk##citation:{bf:{ul:More Recommended Citations}}}"
				di _n(1) `"Visit {browse "http://www.mukarakaplan.com":www.mukarakaplan.com} for updates."'
		}
		
		capture drop _est_ModelEN
		capture drop _est_ModelEX

		if ("`beep'"!="") beep
		if ("`timer'"!="") {
			timer off 1
			Timermessage
		}	
end

program Timermessage
		capture timer list 1
		local hrs = string(`=int(r(t1)/3600)')
		local mins = string(`=int((r(t1)-(int(r(t1)/3600)*3600))/60)')
		local secs = string(`=int(r(t1) - int(r(t1)/3600)*3600 - int((r(t1)-(int(r(t1)/3600)*3600))/60)*60)')
		if "`hrs'"=="0" local hrs = ""
		else if "`hrs'"=="1" local hrs = "`hrs' hour "
		else local hrs = "`hrs' hours "
		if "`mins'"=="0" local mins = "`mins' minute "
		else if "`mins'"=="1" local mins = "`mins' minute "
		else local mins = "`mins' minutes "
		if "`secs'"=="1" local secs = "`secs' second"
		else local secs = "`secs' seconds"			
		di _n(2) in red "Completed in `hrs'`mins'`secs'." 
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




