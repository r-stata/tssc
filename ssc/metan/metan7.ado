*! version 1.86 1Apr2004

/*Revision list at end

Syntax:
a) binary data:
	metan #events_group1 #nonevents_group1 #events_group2 #nonevents_group2 , ...
b) cts data:     
	metan #group1 mean1 sd1  #group2 mean2 sd2 , ...
c) generic effect size+st error: 
	metan theta se_theta , ...
d) generic effect size+ci: 
	metan theta lowerlimit upperlimit , ...

*/

program define metan7 , rclass
    version 7.0
    #delimit ;
    syntax varlist(min=2 max=6 default=none numeric) [if] [in] [, BY(string)
  ILevel(integer $S_level) OLevel(integer $S_level) CC(string) 
  OR RR RD FIXED FIXEDI RANDOM RANDOMI PETO COHEN HEDGES GLASS noSTANDARD 
  CHI2 CORNFIELD LOG BRESLOW EFORM noINTeger noOVERALL noSUBGROUP SGWEIGHT 
  SORTBY(passthru) noKEEP noGRAPH noTABLE LABEL(string) SAVING(passthru) noBOX
  XLAbel(passthru) XTick(passthru) FORCE BOXSCA(real 1.0) BOXSHA(integer 4) 
  TEXTS(real 1.0)  T1title(string) T2title(string) LEGEND(string)
  B1title(string) B2title(string) noWT noSTATS COUNTS WGT(varlist numeric max=1) 
  GROUP1(string) GROUP2(string) EFFECT(string)  ] ;
    #delimit cr


    global MA_FBSH=`boxsha'
    global MA_FBSC=`boxsca'
    global MA_ESLA="`effect'"
    if "`legend'"!="" { global S_TX="`legend'" }
     else { global S_TX "Study" }
    
*label groups 
    if "`group1'"==""  { global MA_G1L "Treatment" }
     else              { global MA_G1L "`group1'"  }
    if "`group2'"==""  { global MA_G2L "Control"   }
     else              { global MA_G2L "`group2'"  }
    if "`legend'"!=""  { global S_TX "`legend'" }

    if (`texts'>2 | `texts'<0.1 ) {local texts=1} 
    global MA_FTSI=`texts'
    if ("`by'"=="" & "`overall'"!="") {local wt "nowt"}
    if `ilevel'<1 {local ilevel=`ilevel'*100 }
    if `ilevel'>99 | `ilevel'<10 { local ilevel $S_level }
    global ZIND= -invnorm((100-`ilevel')/200)
    if `olevel'<1 {local olevel=`olevel'*100 }   
    if `olevel'>99 | `olevel'<10 { local olevel $S_level }
    global ZOVE= -invnorm((100-`olevel')/200)
    global IND=`ilevel'
    global OVE=`olevel'
    #delimit ;
    global S_1 "."; global S_2 "."; global S_3 "."; global S_4 "."; 
    global S_5 "."; global S_6 "."; global S_7 "."; global S_8 "."; 
    global S_9 "."; global S_10 ".";global S_11 ".";global S_12 ".";  
    #delimit cr

*If not using own weights set fixed as default 
    if "`fixed'`random'`fixedi'`randomi'`peto'"=="" & ( "`wgt'"=="" ) { local fixed "fixed" }
*declare study labels for display
    if "`label'"!="" {
	parse "`label'", parse("=,")
	while "`1'"!="" {
		cap confirm var `3'
		if _rc!=0  {
			di in re "Variable `3' not defined"
			exit _rc
		}
		local `1' "`3'" 
		mac shift 4
	}
    }
    tempvar code
    qui {
*put name/year variables into appropriate macros
	if "`namevar'"!="" {
		local lbnvl : value label `namevar' 
		if "`lbnvl'"!=""  { quietly decode `namevar', gen(`code') }
		 else {
		      gen str10 `code'=""  
		      cap confirm string variable `namevar'
		      if _rc==0       { replace `code'=`namevar' }
		       else if _rc==7 { replace `code'=string(`namevar') }
		}
	 }
	 else { gen str3 `code'=string(_n) }
	if "`yearvar'"!=""  {
		  local yearvar "`yearvar'" 
		  cap confirm string variable `yearvar'
		  if _rc==7 { local str "string" }
		  if "`namevar'"=="" { replace `code'=`str'(`yearvar') }
		   else { replace `code'=`code'+" ("+`str'(`yearvar')+")" }
	}
	if "`wgt'"!=""  {
*User defined weights verification
		if "`fixed'`random'`fixedi'`randomi'`peto'"!="" { 
		  di in re "Option invalid with user-defined weights"
		  exit _rc
		}
		confirm numeric variable `wgt'
		local wgt "wgt(`wgt')"
	}
    } /* End of quietly loop */
    parse "`varlist'", parse(" ")
    if "`6'"=="" {
	     if "`4'"=="" {
*Input is {theta setheta} or {theta lowerci upperci} => UDW, IV or D+L weighting
		if "`3'"!="" {
*input is theta lci uci
		  cap assert ((`3'>=`1') & (`1'>=`2'))
		  if _rc!=0 {
		    di in bl "Effect size and confidence intervals invalid:"
		    di in bl "order should be {effect size, lower ci limit, upper ci limit}"
		    exit _rc
		  }
		}
		cap assert "`log'"==""
		if _rc!=0 {
		  di in bl "Log option not available without raw data counts: if necessary, transform both"
		  di in bl "effect and standard error using " in wh "generate" in bl " and re-issue the metan command"
		  exit _rc
		}

 		cap assert "`chi2'`cornfield'`peto'`breslow'`counts'`or'`rr'`rd'`standard'`hedges'`glass'`cohen'"==""
		if _rc!=0 {
		  di in re "Option not available without raw data counts" 
		  exit _rc
		}
		if "`wgt'"!="" { local method "*" }
		else {
		 if "`random'`randomi'"!="" {
		  local randomi
		  local random "random"
		  local method  "D+L" 
		 }
		 if "`fixed'`fixedi'"!="" {
		  local fixedi
		  local fixed "fixed"
		  local method  "I-V" 
		 }
		 cap assert ("`random'"=="") + ("`fixed'"=="")==1
		 if _rc!=0 {
		  di in re "Specify fixed or random effect/s model"
		  exit _rc
		 }
		}
		cap assert "`cc'"=="" 
		if _rc!=0 {
		 di in re "Continuity correction not valid with unless individual counts specified" 
		 exit _rc
		}
		local callalg "iv_init"
		local sumstat "ES"  
	     } /*end of 2-variable set-up */
	     if "`4'"!="" {
*Input is 2x2 tables: MH, Peto, IV, D+L or user defined weighting allowed
		cap assert "`5'"==""
		if _rc!=0 {
		  di in re "Wrong number of variables specified" 
		  exit _rc
		}
		if "`integer'"=="" {
			cap { 
			 assert int(`1')==`1'
			 assert int(`2')==`2'
			 assert int(`3')==`3'
			 assert int(`4')==`4'
			}
			if _rc!=0 {
			 di in re "Non integer cell counts found" 
			 exit _rc
			}

		}
		cap assert ( (`1'>=0) & (`2'>=0) & (`3'>=0) & (`4'>=0) )
		if _rc!=0 {
		 di in re "Non-positive cell counts found" 
		 exit _rc
		}
		if "`cc'"!="" {
*Ensure Continuity correction is valid
			if "`peto'"!="" {
			  di in re "Peto method not valid with continuity correction"
			  exit
			}
*Currently, allows user to define own constant [0,1) to add to all cells
			cap confirm number `cc'
			if _rc!=0 {
				di in re "Invalid continuity correction: specify a constant number eg metan ... , cc(0.166667)"
				exit
			}
			cap assert (`cc'>=0) & (`cc'<1)
			if _rc!=0 {
				di in re "Invalid continuity correction: must be in range [0,1)"
				exit
			}
		 }
		 else { local cc "0.5" }
		if "`peto'"=="" { local cont "cc(`cc')" }
		if "`peto'"!="" { local or "or" }
		capture {
		  assert ( ("`or'"!="")+("`rr'"!="")+("`rd'"!="") <=1 )
		  assert ("`fixed'"!="")+("`fixedi'"!="")+("`random'"!="")+ /* 
 */ ("`randomi'"!="")+("`peto'"!="")+("`wgt'"!="") <=1
		  assert "`standard'`hedges'`glass'`cohen'"==""
 		}
		if _rc!=0 {
		 di in re "Invalid specifications for combining trials" 
		 exit 198
		}
*Default is set at pooling RRs. 
		if "`or'"!=""         {local sumstat "OR"  }
		 else if "`rd'"!=""   {local sumstat "RD"  }
		 else                 {local sumstat "RR"  }
		if "`wgt'"!=""          { local method "*" }
		 else if "`random'`randomi'"!=""  {local method  "D+L" }
		 else if "`peto'"!=""   {local method  "Peto"}
		 else if "`fixedi'"!="" {local method  "I-V"}
		 else                   {local method  "M-H" }
		if "`peto'"!=""  {local callalg "Peto"}
		 else            {local callalg "`sumstat'"}
		if ("`sumstat'"!="OR" | "`method'"=="D+L") & "`chi2'"!="" {
		 di in re "Chi-squared option invalid for `method' `sumstat'"
		 exit 
		}
		if ("`sumstat'"!="OR" | "`method'"=="D+L" | "`method'"=="Peto" ) & "`breslow'"!="" {
		 di in re "Breslow-Day heterogeneity option not available for `method' `sumstat'"
		 exit 
		}
		if ("`sumstat'"!="OR" & "`sumstat'"!="RR") & "`log'"!="" {
		 di in re "Log option not appropriate for `sumstat'"
		 exit 
	  	}
		if "`keep'"=="" { 
		 cap drop _SS
		 qui gen _SS =`1'+`2'+`3'+`4' 
		}
	      } /* end of binary variable setup */
    }
    if "`6'"!="" {
*Input is form N mean SD for continuous data: IV, D+L or user defined weighting allowed
	cap assert "`7'"==""
	if _rc!=0 {
	  di in re "Wrong number of variables specified" 
	  exit _rc
	}
	if "`integer'"=="" {
		cap assert ((int(`1')==`1') & (int(`4')==`4'))
		if _rc!=0 {
		 di in re "Non integer sample sizes found" 
		 exit _rc
		}
	}
	cap assert (`1'>0 & `4'>0)
	if _rc!=0 {
	 di in re "Non positive sample sizes found" 
	 exit _rc
	}
	if "`random'`randomi'"!="" {
	  local randomi
	  local random "random"
	}
	if "`fixed'`fixedi'"!="" {
	  local fixedi
	  local fixed "fixed"
	}
	cap{
	  assert ("`hedges'"!="")+ ("`glass'"!="")+ ("`cohen'"!="")+ ("`standard'"!="")<=1
	  assert ("`random'"!="")+ ("`fixed'"!="") <=1
	  assert "`or'`rr'`rd'`peto'`log'`cornfield'`chi2'`breslow'`eform'"==""
	}
	if _rc!=0 {
		di in re "Invalid specifications for combining trials" 
		exit 198
	}	
	if  "`standard'"!="" {
		local sumstat "WMD"  
		local stand "none"  
	 }
	 else {
		if "`hedges'"!="" {local stand "hedges"}
		else if "`glass'"!=""  {local stand "glass" }
		else {local stand "cohen"}
		local sumstat "SMD"  
	}
	local stand "standard(`stand')"
	if "`wgt'"!="" { local method  "*" }
	 else if "`random'"!="" { local method  "D+L" }
	 else                   { local method  "I-V" }
	if "`counts'"!="" {
		di in bl "Data option counts not available with continuous data"	
		local counts
	}
	if  "`cc'"!="" {
		di in re "Continuity correction not available with continuous data"	
		exit 
	}
	local callalg "MD"
	if "`keep'"=="" { 
		cap drop _SS
		qui gen _SS =`1'+`4' 
	}
    } /*end of 6-var set-up*/
    if "`by'"!="" {
	cap confirm var `by'
	if _rc!=0 {
	  di in red "Variable `by' does not exist"
	  exit _rc
	}
	local by "by(`by')"
	local nextcall "nextcall(`callalg')"
	local callalg "metanby"
	local sstat "sumstat(`sumstat')"
    }

    `callalg' `varlist' `if' `in',  `by' label(`code') `keep' `table' `graph' /*
  */ method(`method') `randomi' `cont' `stand' `chi2' `cornfield'  /*
  */ `log' `breslow' `eform' `wgt' `overall' `subgroup' `sgweight' /*
  */ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
  */ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'")    /*
  */ `groupla' `nextcall' `sstat'

    if $S_8<0 {
	 di in re "Insufficient data to perform this meta-analysis" 
    }

/*Saved results: to keep compatible with v5 have retained $S_. macros. 
Now assign also to r() macros

The macro names and descriptions in the prev version are

Name                      v7.0      v5.0
pooled ES                 r(ES)     $S_1*
se(ES) - not if RR or OR  r(seES)   $S_2
se(logES) - only if RR/OR, non-logged
                          r(selogES) $S_2
lower CI of pooled ES     r(ci_low) $S_3
upper CI of pooled ES     r(ci_upp) $S_4
Z-value for ES            r(z)      $S_5
p(Z)                      r(p_z)    $S_6
chi2 heterogeneity        r(het)    $S_7
df (#studies-1)           r(df)     $S_8
p(chi2 heterogeneity)     r(p_het)  $S_9
Chi2 for ES (OR only)     r(chi2)   $S_10
p(chi2) (OR only)         r(p_chi2) $S_11
Estimated tau^2(D&L only) r(tau2)   $S_12
Effect measure (RR,SMD..) r(measure) - 
		*unless log option used..
Overall event rate [binary data; group 1)
                          r(tger)   -
Overall event rate [binary data; group 2)
                          r(cger)   -
*/


*return log or eform as appropriate for OR/RR
  return scalar ES=$S_1
  if ("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="") { return scalar selogES=$S_2 }
   else if ("`sumstat'"=="ES" & "`eform'"!="") { return scalar selogES=$S_2 }
   else  { return scalar seES=$S_2 }
  return scalar ci_low=$S_3
  return scalar ci_upp=$S_4
  return scalar z=$S_5
  return scalar p_z=$S_6
  return scalar het=$S_7
  return scalar df=$S_8
  return scalar p_het=$S_9
  return scalar chi2=$S_10
  return scalar p_chi2=$S_11
  return scalar tau2=$S_12
  return local  measure "`log'`sumstat'"
  if ("`sumstat'"=="RR" | "`sumstat'"=="OR" | "`sumstat'"=="RD") {
	return scalar tger=$S_13
	return scalar cger=$S_14
  }

end

program define OR 
    version 7.0
    #delimit ;
    syntax varlist(min=4 max=4 default=none numeric) [if] [in] [,
  LABEL(string) SORTBY(passthru) noGRAPH noTABLE CHI2 RANDOMI CC(string)
  METHOD(string) XLAbel(passthru) XTICK(passthru) FORCE CORNFIELD noKEEP 
  SAVING(passthru) noBOX T1(string) T2(string) B1(string) B2(string) noOVERALL 
  noWT noSTATS LOG BRESLOW COUNTS WGT(varlist numeric max=1) noGROUPLA ] ;
    #delimit cr
    qui {
	tempvar a b c d use zeros r1 r2 c1 c2 t or lnor es v se ill iul ea /*
  */ va weight qhet id rawdata cont_a cont_b cont_c cont_d
	tempname ernum erden R S PR PS QR QS W OR lnOR selnOR A EA VA 
	parse "`varlist'", parse(" ")
	if "`log'"!="" { local exp }
	 else          { local exp "exp"}
	gen double `a' =`1'
	gen double `b' =`2'
	gen double `c' =`3'
	gen double `d' =`4'
	gen double `r1'=`a'+`b'
	gen double `r2'=`c'+`d'
	gen double `c1'=`a'+`c'
	gen double `c2'=`b'+`d'
	gen byte `use'=1 `if' `in'
	replace `use'=9 if `use'==.
	replace `use'=9 if (`r1'==.) | (`r2'==.)
	replace `use'=2 if (`use'==1) & (`r1'==0 | `r2'==0 )
	replace `use'=2 if (`use'==1) & (`c1'==0 | `c2'==0 )
	count if `use'==1
	global S_8  =r(N)-1 
	if $S_8<0 { exit }
	if "`counts'"!="" { 
*Display raw counts 
	   gen str20 `rawdata'= string(`a') + "/" + string(`r1') +";" + /*
*/  string(`c') + "/"+ string(`r2') if `use'!=9
	   replace `rawdata'= trim(`rawdata')
	   if "`overall'"=="" {	
		sum `a'  if (`use'==1 | `use'==2)
		local sum1=r(sum)
		sum `r1' if (`use'==1 | `use'==2)
		local sum2=r(sum)
		sum `c'  if (`use'==1 | `use'==2)
		local sum3=r(sum)
		sum `r2' if (`use'==1 | `use'==2)
		local sum4=r(sum)
		global MA_ODC = "`sum1'/`sum2';`sum3'/`sum4'" 
	   }
	 }
	 else {gen str1 `rawdata'="."}
	if "`method'"=="D+L" & ($S_8==0) { local method "M-H"}
*Get average event rate for each group (before any 0.5 adjustments or excluding 0-0 studies) 
	sum `a' if `use'<3
	scalar `ernum'=r(sum)
	sum `r1' if `use'<3
	scalar `erden'=r(sum)
	global S_13=`ernum'/`erden'
	sum `c' if `use'<3
	scalar `ernum'=r(sum)
	sum `r2' if `use'<3
	scalar `erden'=r(sum)
	global S_14=`ernum'/`erden'

*Remove "uninformative" studies
	replace `a'=. if `use'!=1
	replace `b'=. if `use'!=1
	replace `c'=. if `use'!=1
	replace `d'=. if `use'!=1
	replace `r1'=. if `use'!=1
	replace `r2'=. if `use'!=1
	gen double `t' =`r1'+`r2'
* Chi-squared test for effect
	sum `a',meanonly
	scalar `A'=r(sum)
	gen double `ea'=(`r1'*`c1')/`t' 
	gen double `va'=`r1'*`r2'*`c1'*(`b'+`d')/(`t'*`t'*(`t'-1)) 
	sum `ea',meanonly
	scalar `EA'=r(sum)
	sum `va',meanonly
	scalar `VA'=r(sum)
	global S_10=( (`A'-`EA')^2 )/`VA' /* chi2 effect value */
	global S_11=chiprob(1,$S_10)      /*  p(chi2)  */

	if "`cornfield'"!="" {
*Compute Cornfield CI
	   gen `ill'=.
	   gen `iul'=.
	   local j=1
	   tempname i al aj c1j r1j r2j alold
	   while `j'<=_N {
	    if `use'[`j']==1 {
	      scalar `i'  = 0 
	      scalar `al' =`a'[`j']
	      scalar `aj' =`a'[`j']
	      scalar `c1j'=`c1'[`j']
	      scalar `r1j'=`r1'[`j']
	      scalar `r2j'=`r2'[`j']
	      scalar `alold'= .
	      while abs(`al'-`alold')>.001 & `al'!=. { 
		 scalar `alold' = `al'
		 scalar `al'=`aj'-($ZIND)/sqrt( (1/`al') + 1/(`c1j'-`al') + /*
 */   1/(`r1j'-`al') +  1/(`r2j'-`c1j'+`al') ) 
		 if `al'==. {
			scalar `i'=`i'+1
			scalar `al'=`aj'-`i'
			if (`al'<0 | (`r2j'-`c1j'+`al')<0) {scalar `al'= . }
		 }
	      }
	      if `al'==. { scalar `al'= 0 } 
 replace `ill'=`log'( `al'*(`r2j'-`c1j'+`al')/((`c1j'-`al')*(`r1j'-`al')) ) in `j'
	      scalar `al'= `a'[`j']
	      scalar `alold'= . 
	      scalar `i'= 0 
	      while abs(`al'-`alold')>.001 & `al'!=. {
		 scalar `alold'= `al'
		 scalar `al'=`aj'+($ZIND)/sqrt( (1/`al')+ 1/(`c1j'-`al') + /*
 */  1/(`r1j'-`al') +  1/(`r2j'-`c1j'+`al') )
		 if `al'==. {
			  scalar `i'=`i'+1
			  scalar `al'=`aj'+`i'
			  if (`al'>`r1j' | `al'>`c1j' ) { scalar `al' = . }
		 }
	      }
 replace `iul'=`log'( `al'*(`r2j'-`c1j'+`al')/((`c1j'-`al')*(`r1j'-`al')) ) in `j'
	    }
	    local j=`j'+1
	   }
	 }
*Adjustment for zero cells in calcn of OR and var(OR)
	gen `zeros'=1 if `use'==1 & (`a'==0 | `b'==0 | `c'==0 | `d'==0 )
	gen `cont_a'=`cc'
	gen `cont_b'=`cc'
	gen `cont_c'=`cc'
	gen `cont_d'=`cc'
	replace `a'=`a'+`cont_a' if `zeros'==1
	replace `b'=`b'+`cont_b' if `zeros'==1
	replace `c'=`c'+`cont_c' if `zeros'==1
	replace `d'=`d'+`cont_d' if `zeros'==1
	replace `r1'=`r1'+(`cont_a'+`cont_b') if `zeros'==1
	replace `r2'=`r2'+(`cont_c'+`cont_d') if `zeros'==1
	replace `t' =`t' +(`cont_a'+`cont_b')+(`cont_c'+`cont_d') if `zeros'==1
	gen double `or'  =(`a'*`d')/(`b'*`c')
	gen double `lnor'=log(`or') 
	gen double `v'   =1/`a' +1/`b' +1/`c' + 1/`d' 
	gen double `es'  =`log'(`or') 
	gen double `se'  =sqrt(`v')
	if "`cornfield'"=="" {
		gen `ill' =`exp'(`lnor'-$ZIND*`se')
		gen `iul' =`exp'(`lnor'+$ZIND*`se')
	}
	if "`method'"=="M-H" | ( "`method'"=="D+L" & "`randomi'"=="" ) {
		tempname p q r s pr ps qr qs
		gen double `r'   =`a'*`d'/`t'
		gen double `s'   =`b'*`c'/`t'
		sum `r', meanonly
		scalar `R'  =r(sum)
		sum `s', meanonly
		scalar `S'  =r(sum)
*Calculate pooled MH- OR 
		scalar `OR' =`R'/`S'
		scalar `lnOR'=log(`OR') 
*Calculate variance/SE of lnOR and weights
		gen double `p'   =(`a'+`d')/`t'
		gen double `q'   =(`b'+`c')/`t'
		gen double `pr'  =`p'*`r' 
		gen double `ps'  =`p'*`s'
		gen double `qr'  =`q'*`r'
		gen double `qs'  =`q'*`s'
		sum `pr', meanonly
		scalar `PR' =r(sum)
		sum `ps', meanonly
		scalar `PS' =r(sum)
		sum `qr', meanonly
		scalar `QR' =r(sum)
		sum `qs', meanonly
		scalar `QS' =r(sum)
		scalar `selnOR'= sqrt( (`PR'/(`R'*`R') + (`PS'+`QR')/(`R'*`S') + /*
  */ `QS'/(`S'*`S'))/2 )
		gen  `weight'=100*`s'/`S' 
*Store results in global macros, on log scale if requested
		global S_1  =`log'(`OR')
		global S_2  =`selnOR' 
		global S_3  =`exp'(`lnOR' -$ZOVE*`selnOR')
		global S_4  =`exp'(`lnOR' +$ZOVE*`selnOR')
		global S_5  =abs(`lnOR')/(`selnOR') 
		global S_6  =normprob(-abs($S_5))*2    
		drop `p' `q' `r' `pr' `ps' `qr' `qs' 
*Calculate heterogeneity
		if "`breslow'"=="" {
		  gen double `qhet' =( (`lnor'-`lnOR')^2 )/`v'
		  sum `qhet', meanonly
		  global S_7 =r(sum)              /*Chi-squared */
		  global S_9 =chiprob($S_8,$S_7)  /*p(chi2 het) */
		}
	}
	if "`wgt'"!="" {
		cap gen `weight'=.
		udw `lnor' `v' , wgt(`wgt') `exp'
		replace `weight'=`wgt'*100/$MA_W
		local udwind "wgt(`wgt')"
	 }
	 else if "`method'"!="M-H" {
		cap gen `weight'=.
		iv `lnor' `v', method(`method') `randomi' `exp'
		replace `weight'=100/( (`v'+$S_12)*($MA_W) )
	}

	if "`breslow'"!="" {
*Calculate heterogeneity by Breslow-Day test: need to reset zero cells and margins

	  if "`log'"=="" {local bexp }
	   else          {local bexp "exp" }
	  replace `a'=`a'-`cont_a' if `zeros'==1
	  replace `b'=`b'-`cont_b' if `zeros'==1
	  replace `c'=`c'-`cont_c' if `zeros'==1
	  replace `d'=`d'-`cont_d' if `zeros'==1
	  replace `r1'=`r1'-(`cont_a'+`cont_b') if `zeros'==1
	  replace `r2'=`r2'-(`cont_c'+`cont_d') if `zeros'==1
	  replace `t' =`t' -(`cont_a'+`cont_b')-(`cont_c'+`cont_d') if `zeros'==1
	  if abs(`bexp'($S_1) - 1)<0.0001 {
		gen afit = `r1'*`c1'/`t'
		gen bfit = `r1'*`c2'/`t'
		gen cfit = `r2'*`c1'/`t'
		gen dfit = `r2'*`c2'/`t'
	   }
	   else {
		tempvar sterm cterm root1 root2 afit bfit cfit dfit bresd_q
		tempname qterm
		scalar `qterm' = 1-`bexp'($S_1)
		gen `sterm' = `r2' - `c1' + (`bexp'($S_1))*(`r1'+`c1')
		gen `cterm' = -(`bexp'($S_1))*`c1'*`r1'
		gen `root1' = (-`sterm' + sqrt(`sterm'*`sterm' - 4*`qterm'*`cterm'))/(2*`qterm')
		gen `root2' = (-`sterm' - sqrt(`sterm'*`sterm' - 4*`qterm'*`cterm'))/(2*`qterm')
		gen `afit' = `root1' if `root2'<0
		replace `afit' = `root2' if `root1'<0
		replace `afit' = `root1' if (`root2'>`c1') | (`root2'>`r1') 
		replace `afit' = `root2' if (`root1'>`c1') | (`root1'>`r1') 
		gen `bfit' = `r1' - `afit'
		gen `cfit' = `c1' - `afit'
		gen `dfit' = `r2' - `cfit'
	  }
	  gen `qhet' = ((`a'-`afit')^2)*((1/`afit')+(1/`bfit')+(1/`cfit')+(1/`dfit'))
	  sum `qhet', meanonly
	  global S_7 =r(sum)            /*Het. Chi-squared */
	  global S_9 =chiprob($S_8,$S_7)    /*p(chi2 het) */
	}
	replace `weight'=0 if `weight'==.
	}  /* End of "quietly" loop  */    
	_disptab `es' `se' `ill' `iul' `weight' `use' `label' `rawdata', `keep' `sortby' /*
 */ `table' method(`method') sumstat(OR) `chi2' `xlabel' `xtick' `force' `graph' /*
 */ `box' `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") `overall' `wt'  /*
 */ `stats' `counts' `log' `groupla' `udwind' `cornfield'
end

program define Peto
    version 7.0
    #delimit ;
    syntax varlist(min=4 max=4 default=none numeric) [if] [in] [,
  LABEL(string) ORDER(string) noGRAPH METHOD(string) CHI2 XLAbel(passthru) 
  XTICK(passthru) FORCE noKEEP SAVING(passthru) noBOX noTABLE SORTBY(passthru) T1(string)
  T2(string) B1(string) B2(string) noOVERALL noWT noSTATS LOG COUNTS ] ;
    #delimit cr
    qui {
	tempvar a b c d use r1 r2 t ea olesse v lnor or es se /*
 */ ill iul p weight id rawdata
	tempname ernum erden OLESSE V SE P lnOR A C R1 R2 
	parse "`varlist'", parse(" ")      
	if "`log'"!="" { local exp }
	 else          { local exp "exp"}
	gen double `a'  =`1' `if' `in'
	gen double `b'  =`2' `if' `in'
	gen double `c'  =`3' `if' `in'
	gen double `d'  =`4' `if' `in'
	gen double `r1'  =`a'+`b'
	gen double `r2'  =`c'+`d'
	gen byte `use'=1   `if' `in' 
	replace `use'=9 if `use'==.
	replace `use'=9 if (`r1'==.) | (`r2'==.)
	replace `use'=2 if (`use'==1) & (`r1'==0 | `r2'==0 )
	replace `use'=2 if (`use'==1) & ((`a'==0 & `c'==0 ) | (`b'==0 & `d'==0))
	count if `use'==1
	global S_8  =r(N)-1  
	if $S_8<0 { exit }
	if "`counts'"!="" { 
*Display raw counts 
	   gen str20 `rawdata'= string(`a') + "/" + string(`r1') +";" + /*
*/  string(`c') + "/"+ string(`r2') if `use'!=9
	   replace `rawdata'= trim(`rawdata')
	   if "`overall'"=="" {	
		sum `a'  if (`use'==1 | `use'==2)
		local sum1=r(sum)
		sum `r1' if (`use'==1 | `use'==2)
		local sum2=r(sum)
		sum `c'  if (`use'==1 | `use'==2)
		local sum3=r(sum)
		sum `r2' if (`use'==1 | `use'==2)
		local sum4=r(sum)
		global MA_ODC = "`sum1'/`sum2';`sum3'/`sum4'" 
	   }
	 }
	 else {gen str1 `rawdata'="."}
*Get average event rate for each group (before any 0.5 adjustments or excluding 0-0 studies) 
	sum `a' if `use'<3
	scalar `ernum'=r(sum)
	sum `r1' if `use'<3
	scalar `erden'=r(sum)
	global S_13=`ernum'/`erden'
	sum `c' if `use'<3
	scalar `ernum'=r(sum)
	sum `r2' if `use'<3
	scalar `erden'=r(sum)
	global S_14=`ernum'/`erden'

*Remove "uninformative" studies
	replace `a'=. if `use'!=1
	replace `b'=. if `use'!=1
	replace `c'=. if `use'!=1
	replace `d'=. if `use'!=1
	replace `r1'=. if `use'!=1
	replace `r2'=. if `use'!=1
	gen double `t'     =`r1'+`r2'  
	gen double `ea'    =`r1'*(`a'+`c')/`t'  
	gen double `olesse'=`a'-`ea'
	gen double `v'     =`r1'*`r2'*(`a'+`c')*(`b'+`d')/( `t'*`t'*(`t'-1) ) 
	gen double `lnor'  =`olesse'/`v'   
	gen double `es'    = `exp'(`lnor')
	gen double `se'    = 1/(sqrt(`v'))
	gen double `ill'   = `exp'(`lnor'-$ZIND*`se')
	gen double `iul'   = `exp'(`lnor'+$ZIND*`se')
	gen double `p'     =(`olesse')*(`olesse')/`v'
	sum `olesse', meanonly
	scalar `OLESSE'=r(sum)
	sum `v', meanonly
	scalar `V' =r(sum)
	sum `p', meanonly
	scalar `P'    =r(sum)
	scalar `lnOR' =`OLESSE'/`V'
	global S_1 =`exp'(`lnOR')
	global S_2 =1/sqrt(`V')
	global S_3 =`exp'(`lnOR'-$ZOVE*($S_2))
	global S_4 =`exp'(`lnOR'+$ZOVE*($S_2))
	sum `a', meanonly
	scalar `A'  =r(sum)
	sum `c', meanonly
	scalar `C'  =r(sum)
	sum `r1', meanonly
	scalar `R1' =r(sum)
	sum `r2', meanonly
	scalar `R2' =r(sum)
	global S_10 =(`OLESSE'^2)/`V'  /*Chi-squared effect*/
	global S_11 =chiprob(1,$S_10)
	global S_5  =abs(`lnOR')/($S_2)
	global S_6  =normprob(-abs($S_5))*2
/*Heterogeneity */
	global S_7=`P'-$S_10
	global S_9 =chiprob($S_8,$S_7) 
	gen `weight' =100*`v'/`V' 
	replace `weight'=0 if `weight'==.
    }  /* End of quietly loop */


_disptab `es' `se' `ill' `iul' `weight' `use' `label' `rawdata' , `keep' `sortby' /*
 */ `table' method(`method') sumstat(OR) `chi2' `xlabel' `xtick' `force' `graph' `box' /*
 */ `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") `overall' `wt' `stats' `counts' `log'
end

program define RR
    version 7.0
    #delimit ;
    syntax varlist(min=4 max=4 default=none numeric) [if] [in] [,
  LABEL(string) SORTBY(passthru) noGRAPH noTABLE RANDOMI METHOD(string) CC(string)
  XLAbel(passthru) XTICK(passthru) FORCE noKEEP SAVING(passthru) noBOX T1(string)
  T2(string) B1(string) B2(string) noOVERALL noWT noSTATS LOG COUNTS 
  WGT(varlist numeric max=1) ] ;
    #delimit cr
    qui {
	tempvar a b c d use zeros r1 r2 t p r s rr lnrr es v se ill iul q /*
 */ weight id rawdata cont_a cont_b cont_c cont_d
	tempname ernum erden P R S RR lnRR vlnRR 
	parse "`varlist'", parse(" ")
	if "`log'"!="" { local exp }
	 else          { local exp "exp"}
	gen double `a'  =`1'
	gen double `b'  =`2'
	gen double `c'  =`3'
	gen double `d'  =`4'
	gen double `r1' =`a'+`b'
	gen double `r2' =`c'+`d'
	gen byte `use'=1   `if' `in' 
	replace `use'=9 if `use'==.
	replace `use'=9 if (`r1'==.) | (`r2'==.)
	replace `use'=2 if (`use'==1) & (`r1'==0 | `r2'==0 ) 
	replace `use'=2 if (`use'==1) & ((`a'==0 & `c'==0 ) | (`b'==0 & `d'==0))
	count if `use'==1
	global S_8  =r(N)-1  
	if $S_8<0 { exit }
	if "`counts'"!="" { 
*Display raw counts 
	   gen str20 `rawdata'= string(`a') + "/" + string(`r1') +";" + /*
*/  string(`c') + "/"+ string(`r2') if `use'!=9
	   replace `rawdata'= trim(`rawdata')
	   if "`overall'"=="" {	
		sum `a'  if (`use'==1 | `use'==2)
		local sum1=r(sum)
		sum `r1' if (`use'==1 | `use'==2)
		local sum2=r(sum)
		sum `c'  if (`use'==1 | `use'==2)
		local sum3=r(sum)
		sum `r2' if (`use'==1 | `use'==2)
		local sum4=r(sum)
		global MA_ODC = "`sum1'/`sum2';`sum3'/`sum4'" 
	   }
	 }
	 else {gen str1 `rawdata'="."}
	if "`method'"=="D+L" & ($S_8==0) { local method "M-H"}
*Get average event rate for each group (before any 0.5 adjustments or excluding 0-0 studies) 
	sum `a' if `use'<3
	scalar `ernum'=r(sum)
	sum `r1' if `use'<3
	scalar `erden'=r(sum)
	global S_13=`ernum'/`erden'
	sum `c' if `use'<3
	scalar `ernum'=r(sum)
	sum `r2' if `use'<3
	scalar `erden'=r(sum)
	global S_14=`ernum'/`erden'

*Adjustment for zero cells in calcn of OR and var(OR)
	gen `zeros'=1 if `use'==1 & (`a'==0 | `b'==0 | `c'==0 | `d'==0 )
	gen `cont_a'=`cc'
	gen `cont_b'=`cc'
	gen `cont_c'=`cc'
	gen `cont_d'=`cc'
	replace `a'=`a'+`cont_a' if `zeros'==1
	replace `b'=`b'+`cont_b' if `zeros'==1
	replace `c'=`c'+`cont_c' if `zeros'==1
	replace `d'=`d'+`cont_d' if `zeros'==1
	replace `r1'=`r1'+(`cont_a'+`cont_b') if `zeros'==1
	replace `r2'=`r2'+(`cont_c'+`cont_d') if `zeros'==1

*Remove "uninformative" studies
	replace `a'=. if `use'!=1
	replace `b'=. if `use'!=1
	replace `c'=. if `use'!=1
	replace `d'=. if `use'!=1
	replace `r1'=. if `use'!=1
	replace `r2'=. if `use'!=1

	gen double `t'   =`r1'+`r2'
	gen double `r'   =`a'*`r2'/`t'
	gen double `s'   =`c'*`r1'/`t'
	gen double `rr'  =`r'/`s'
	gen double `lnrr'=log(`rr') 
	gen double `es'  =`log'(`rr')
	gen double `v'   =1/`a' +1/`c' - 1/`r1' - 1/`r2' 
	gen double `se'  =sqrt(`v')
	gen double `ill' =`exp'(`lnrr'-$ZIND*`se')
	gen double `iul' =`exp'(`lnrr'+$ZIND*`se')
	if "`method'"=="M-H" | "`method'"=="D+L" & "`randomi'"=="" {
*MH method for pooling/calculating heterogeneity in DL method
		gen double `p'  =`r1'*`r2'*(`a'+`c')/(`t'*`t') - `a'*`c'/`t'
		sum `p', meanonly
		scalar `P'  =r(sum)
		sum `r', meanonly
		scalar `R'  =r(sum)
		sum `s', meanonly
		scalar `S'  =r(sum)
		scalar `RR'=`R'/`S'
		scalar `lnRR'=log(`RR')
*  Heterogeneity
		gen double `q'   =( (`lnrr'-`lnRR')^2 )/`v'
		sum `q', meanonly
		global S_7 =r(sum)
		global S_9 =chiprob($S_8,$S_7) 
		gen `weight'=100*`s'/`S' 
		global S_1 =`log'(`RR')
		global S_2 =sqrt( `P'/(`R'*`S') )
		global S_3 =`exp'(`lnRR' -$ZOVE*($S_2)) 
		global S_4 =`exp'(`lnRR' +$ZOVE*($S_2))
		global S_5 =abs(`lnRR')/($S_2)      
		global S_6 =normprob(-abs($S_5))*2
	}
	if "`wgt'"!="" {
		cap gen `weight'=.
		udw `lnrr' `v' , wgt(`wgt') `exp'
		replace `weight'=`wgt'*100/$MA_W
		local udwind "wgt(`wgt')"
	 }
	 else if "`method'"!="M-H" {
		cap gen `weight'=.
		iv `lnrr' `v', method(`method') `randomi' `exp'
		replace `weight'=100/( (`v'+$S_12)*($MA_W) )
	}
	replace `weight'=0 if `weight'==.
    }  /* End of "quietly" loop  */ 
    _disptab `es' `se' `ill' `iul' `weight' `use' `label' `rawdata' , `keep' `sortby' /*
 */ `table' method(`method') sumstat(RR) `xlabel' `xtick' `force' `graph' `box' /*
 */ `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'")  `overall' `wt' /*
 */  `stats' `counts' `log' `udwind'

end

program define RD
    version 7.0
    #delimit ;
    syntax varlist(min=4 max=4 default=none numeric) [if] [in] [,
 LABEL(string) SORTBY(passthru) noGRAPH noTABLE RANDOMI METHOD(string) CC(string) noKEEP 
 SAVING(passthru) XLAbel(passthru) XTICK(passthru) noBOX FORCE T1(string) T2(string)
 B1(string) B2(string) noOVERALL noWT noSTATS COUNTS WGT(varlist numeric max=1)  ] ;
    #delimit cr
    qui {
	tempvar a b c d use zeros r1 r2 t rd weight rdnum v se ill iul vnum q /*
 */ id w rawdata cont_a cont_b cont_c cont_d
	tempname ernum erden RDNUM VNUM W 
	parse "`varlist'", parse(" ")      
	gen double `a'  =`1'
	gen double `b'  =`2'
	gen double `c'  =`3'
	gen double `d'  =`4'
	gen double `r1'  =`a'+`b'
	gen double `r2'  =`c'+`d'
	gen byte `use'=1   `if' `in' 
	replace `use'=9 if `use'==.
	replace `use'=9 if (`r1'==.) | (`r2'==.)
	replace `use'=2 if ( `use'==1) & (`r1'==0 | `r2'==0 )
	count if `use'==1
	global S_8  =r(N)-1  
	if $S_8<0 { exit }
	if "`counts'"!="" { 
*Display raw counts 
	   gen str20 `rawdata'= string(`a') + "/" + string(`r1') +";" + /*
*/  string(`c') + "/"+ string(`r2') if `use'!=9
	   replace `rawdata'= trim(`rawdata')
	   if "`overall'"=="" {	
		sum `a'  if (`use'==1 | `use'==2)
		local sum1=r(sum)
		sum `r1' if (`use'==1 | `use'==2)
		local sum2=r(sum)
		sum `c'  if (`use'==1 | `use'==2)
		local sum3=r(sum)
		sum `r2' if (`use'==1 | `use'==2)
		local sum4=r(sum)
		global MA_ODC = "`sum1'/`sum2';`sum3'/`sum4'" 
	   }
	 }
	 else {gen str1 `rawdata'="."}
	if "`method'"=="D+L" & ($S_8==0) { local method "M-H"}
*Get average event rate for each group (before any cont adjustments or excluding 0-0 studies) 
	sum `a' if `use'<3
	scalar `ernum'=r(sum)
	sum `r1' if `use'<3
	scalar `erden'=r(sum)
	global S_13=`ernum'/`erden'
	sum `c' if `use'<3
	scalar `ernum'=r(sum)
	sum `r2' if `use'<3
	scalar `erden'=r(sum)
	global S_14=`ernum'/`erden'

*Remove "uninformative" studies
	replace `a'=. if `use'!=1
	replace `b'=. if `use'!=1
	replace `c'=. if `use'!=1
	replace `d'=. if `use'!=1
	replace `r1'=. if `use'!=1
	replace `r2'=. if `use'!=1
	gen double `t'   =`r1'+`r2'
	gen double `rd'  =`a'/`r1' - `c'/`r2'
	gen `weight'=`r1'*`r2'/`t'
	sum `weight',meanonly
	scalar `W'  =r(sum)
	gen double `rdnum'=( (`a'*`r2')-(`c'*`r1') )/`t'
*  Zero cell adjustments, placed here to ensure 0/n1 v 0/n2 really IS RD=0
*Adjustment for zero cells in calcn of OR and var(OR)
	gen `zeros'=1 if `use'==1 & (`a'==0 | `b'==0 | `c'==0 | `d'==0 )
	gen `cont_a'=`cc'
	gen `cont_b'=`cc'
	gen `cont_c'=`cc'
	gen `cont_d'=`cc'
	replace `a'=`a'+`cont_a' if `zeros'==1
	replace `b'=`b'+`cont_b' if `zeros'==1
	replace `c'=`c'+`cont_c' if `zeros'==1
	replace `d'=`d'+`cont_d' if `zeros'==1
	replace `r1'=`r1'+(`cont_a'+`cont_b') if `zeros'==1
	replace `r2'=`r2'+(`cont_c'+`cont_d') if `zeros'==1
	replace `t' =`t' +(`cont_a'+`cont_b')+(`cont_c'+`cont_d') if `zeros'==1

	gen double `v'   =`a'*`b'/(`r1'^3)+`c'*`d'/(`r2'^3)
	gen double `se'  =sqrt(`v')
	gen double `ill' = `rd'-$ZIND*`se'
	gen double `iul' = `rd'+$ZIND*`se'

	if "`method'"=="M-H" | ("`method'"=="D+L" & "`randomi'"=="" ) {
		sum `rdnum',meanonly
		scalar `RDNUM'=r(sum)
		global S_1 =`RDNUM'/`W'
		gen double `q' =( (`rd'-$S_1)^2 )/`v'
		sum `q', meanonly
		global S_7 =r(sum)
		global S_9 =chiprob($S_8,$S_7)
		gen double `vnum'=( (`a'*`b'*(`r2'^3) )+(`c'*`d'*(`r1'^3)))  /*
   */ /(`r1'*`r2'*`t'*`t')
		sum `vnum',meanonly
		scalar `VNUM'=r(sum)
		global S_2 =sqrt( `VNUM'/(`W'*`W') )
		replace `weight'=`weight'*100/`W'
		global S_3 =$S_1 -$ZOVE*($S_2)
		global S_4 =$S_1 +$ZOVE*($S_2)
		global S_5 =abs($S_1)/($S_2)
		global S_6 =normprob(-abs($S_5))*2
	}
	if "`wgt'"!="" {
		udw `rd' `v' ,wgt(`wgt')
		replace `weight'=`wgt'*100/$MA_W
		local udwind "wgt(`wgt')"
	 }
	 else if "`method'"!="M-H" {
		iv `rd' `v', method(`method') `randomi'
		replace `weight'=100/( (`v'+$S_12)*($MA_W) )
	}
	replace `weight'=0 if `weight'==.
    }  /* End of "quietly" loop  */    
    _disptab `rd' `se' `ill' `iul' `weight' `use' `label' `rawdata', `keep'  `sortby' /*
 */ `table' method(`method') sumstat(RD) `xlabel' `xtick'`force' `graph' `box' /* 
 */ `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") `overall' `wt' `stats' `counts' `udwind'

end

program define MD
    version 7.0
    #delimit ;
    syntax varlist(min=6 max=6 default=none numeric) [if] [in] [,
  LABEL(string) SORTBY(passthru) noGRAPH METHOD(string) noKEEP SAVING(passthru) noBOX
  noTABLE STANDARD(string) XLAbel(passthru) XTICK(passthru) FORCE T1(string) T2(string)
  B1(string) B2(string) noOVERALL noWT noSTATS COUNTS WGT(string) ] ;
    #delimit cr
    qui {
	tempvar n1 x1 sd1 n2 x2 sd2 use n s md v se ill iul weight id qhet rawdata
	parse "`varlist'", parse(" ")      
	gen double `n1' =`1' 
	gen double `x1' =`2'
	gen double `sd1'=`3'
	gen double `n2' =`4'
	gen double `x2' =`5'
	gen double `sd2'=`6'

	gen `use'=1 `if' `in' 
	replace `use'=9 if `use'==.
	replace `use'=9 if (`n1'==.) | (`n2'==.) | (`x1'==.) | (`x2'==.) | /*
 */  (`sd1'==.) | (`sd2'==.)
	replace `use'=2 if ( `use'==1) & (`n1' <2  | `n2' <2  )
	replace `use'=2 if ( `use'==1) & (`sd1'<=0 | `sd2'<=0 )
	count if `use'==1
	global S_8  =r(N)-1  
	if $S_8<0 { exit }
	if "`counts'"!="" { 
*Display raw counts instead of default 
	   gen str40 `rawdata'= string(`n1') + " " + string(`x1') +" (" + string(`sd1') +  /*
 */ ") ; " + string(`n2') + " " + string(`x2') +" (" + string(`sd2') +") "  
	   replace `rawdata'= trim(`rawdata')
	 }
	 else {gen str1 `rawdata'="."}
	if "`method'"=="D+L" & ($S_8==0) { local method "I-V"}
	replace `n1' =. if `use'!=1
	replace `x1' =. if `use'!=1
	replace `sd1'=. if `use'!=1
	replace `n2' =. if `use'!=1
	replace `x2' =. if `use'!=1
	replace `sd2'=. if `use'!=1
	gen double `n'  =`n1'+`n2'
	if "`standard'"=="none" {
		gen double `md' =`x1'-`x2'
		gen double `v'=(`sd1'^2)/`n1' + (`sd2'^2)/`n2'
		local prefix "W"
	 }
	 else {
		gen double `s'=sqrt( ((`n1'-1)*(`sd1'^2)+(`n2'-1)*(`sd2'^2) )/(`n'-2) )
		if "`standard'"=="cohen" {
 gen double `md' = (`x1'-`x2')/`s' 
 gen double `v'= ( `n'/(`n1'*`n2') )+( (`md'^2)/(2*(`n'-2)) )
		 }
		 else if "`standard'"=="hedges" {
 gen double `md' =( (`x1'-`x2')/`s' )*( 1-  3/(4*`n'-9) )
 gen double `v'=( `n'/(`n1'*`n2') ) + ( (`md'^2)/(2*(`n'-3.94)) )
		 }
		 else if "`standard'"=="glass" {
 gen double `md' =  (`x1'-`x2')/`sd2' 
 gen double `v'= (`n'/(`n1'*`n2')) + ( (`md'^2)/(2*(`n2'-1)) )
		}
	   local prefix "S"
	}
	gen double `se'  =sqrt(`v')
	gen double `ill'  =`md'-$ZIND*`se' 
	gen double `iul'  =`md'+$ZIND*`se' 
	if "`wgt'"!="" {
		udw `md' `v' , wgt(`wgt')
		gen `weight'=`wgt'*100/$MA_W
		local udwind "wgt(`wgt')"
	 }
	 else {
		iv `md' `v', method(`method') randomi 
		gen `weight'=100/( (`v'+$S_12)*($MA_W) )
	}
	replace `weight'=0 if `weight'==.
    }  /* End of quietly loop  */
    _disptab `md' `se' `ill' `iul' `weight' `use' `label' `rawdata', `keep' `sortby' /*
 */ `table' method(`method') sumstat(`prefix'MD) `xlabel' `xtick' `force' `graph'  /*
 */ `box' `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") `overall' `wt' `stats' `udwind'
end

program define iv_init
    version 7.0
    #delimit ;
    syntax varlist(min=2 max=3 default=none numeric) [if] [in] [,
  LABEL(string) SORTBY(passthru) noGRAPH METHOD(string) noKEEP SAVING(passthru)  noBOX
  noTABLE XLAbel(passthru) XTICK(passthru) FORCE T1(string) T2(string) B1(string)
  B2(string) noOVERALL noWT noSTATS EFORM WGT(string)  ] ;
    #delimit cr
    qui {
	tempvar es se use v ill iul weight id rawdata
	parse "`varlist'", parse(" ")      
	gen `es'=`1'
	if "`eform'"!="" { local exp "exp" }
	if "`3'"=="" {
	   gen double `se'=`2'
	   gen double `ill'  =`exp'(`es'-$ZIND*`se' )
	   gen double `iul'  =`exp'(`es'+$ZIND*`se' )
	}
	if "`3'"!="" {
	   gen double `se'=(`3'-`2')/($ZIND*2)
	   gen double `ill'  =`exp'(`2')
	   gen double `iul'  =`exp'(`3')
	   local var3 "var3" 
	}
	gen double `use'=1 `if' `in' 
	replace `use'=9 if `use'==.
	replace `use'=9 if (`es'==. | `se'==.)
	replace `use'=2 if (`use'==1 & `se'<=0 )
	count if `use'==1
	global S_8  =r(N)-1  
	if $S_8<0 { exit }

	if "`method'"=="D+L" & ($S_8==0) { local method "I-V"}
	replace `es' =. if `use'!=1
	replace `se' =. if `use'!=1
	gen double `v'=(`se')^2
	gen str1 `rawdata'="."
	if "`wgt'"!="" { 
		gen `weight' = `wgt' if `use'==1
		udw `es' `v', wgt(`weight') `exp' 
		replace `weight'=100*`wgt'/($MA_W) 
		local udwind "wgt(`wgt')"
	 }
	 else {
		iv  `es' `v', method(`method') `exp' randomi 
*NB randomi necc to calculate heterogeneity
		gen `weight'=100/( (`v'+$S_12)*($MA_W) )
	}
	replace `weight'=0 if `weight'==.
	replace `es'=`exp'(`es')

   }  /* End of quietly loop  */
    _disptab `es' `se' `ill' `iul' `weight' `use' `label' `rawdata', `keep' `sortby' /*
 */`table' method(`method') sumstat(ES) `xlabel' `xtick' `force' `graph' `box' /*
 */ `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") `overall' `wt' `stats' `eform' /*
 */ `var3' `udwind'

end


program define iv 
	version 7.0
	#delimit ;
	syntax varlist(min=2 max=2 default=none numeric) [if] [in] [,
  METHOD(string) RANDOMI EXP ] ;
	#delimit cr
	tempvar stat v w qhet w2 wnew e_w e_wnew 
	tempname W W2 C T2 E_W E_WNEW OV vOV QHET
	parse "`varlist'", parse(" ")
	gen `stat'=`1'
	gen `v'   =`2'
	gen `w'   =1/`v'
	sum `w',meanonly
	scalar `W'=r(sum)
	global S_12=0
	global MA_W =`W'
	if ("`randomi'"=="" & "`method'"=="D+L") { scalar `QHET'=$S_7 }
	 else {
		gen `e_w' =`stat'*`w'
		sum `e_w',meanonly
		scalar `E_W'=r(sum)
		scalar `OV' =`E_W'/`W'
*  Heterogeneity
		gen `qhet' =( (`stat'-`OV')^2 )/`v'
		sum `qhet', meanonly
		scalar `QHET'=r(sum)
		global S_7=`QHET'
	}
	if "`method'"=="D+L" {
		gen `w2'  =`w'*`w'
		sum `w2',meanonly
		scalar `W2' =r(sum)
		scalar `C'  =`W' - `W2'/`W'
		global S_12 =max(0, ((`QHET'-$S_8)/`C') )
		gen `wnew'  =1/(`v'+$S_12)
		gen `e_wnew'=`stat'*`wnew'
		sum `wnew',meanonly
		global MA_W =r(sum)
		sum `e_wnew',meanonly
		scalar `E_WNEW'=r(sum)
		scalar `OV' =`E_WNEW'/$MA_W
	}
	global S_1 =`exp'(`OV')
	global S_2 =sqrt( 1/$MA_W )
	global S_3 =`exp'(`OV' -$ZOVE*($S_2))
	global S_4 =`exp'(`OV' +$ZOVE*($S_2))
	global S_5 =abs(`OV')/($S_2) 
	global S_6 =normprob(-abs($S_5))*2
	global S_9 =chiprob($S_8,$S_7)
end


program define udw
* user defined weights to combine trials
	version 7.0
	#delimit ;
	syntax varlist(min=2 max=2 default=none numeric) [if] [in] [,
  METHOD(string)  EXP   WGT(varlist numeric max=1) ] ;
	#delimit cr
	tempvar stat v w e_w varcomp qhet  

	tempname W E_W OV W2 Vnum V QHET
	parse "`varlist'", parse(" ")
	gen `stat'=`1' 
	gen `v'   =`2'
	gen `w'   =`wgt' if `stat'!=.
	sum `w',meanonly
	scalar `W'=r(sum)
	if `W'==0 {
	  di in re "Usable weights sum to zero: the table below will probably be nonsense"
	}
	global MA_W =`W'
*eff size = SIGMA(wi * thetai)/SIGMA(wi)
	gen `e_w' =`stat'*`w'
	sum `e_w',meanonly
	scalar `E_W'=r(sum)
	scalar `OV' =`E_W'/`W'
*VAR = SIGMA{wi^2 * var(thetai) }/[SIGMA(wi)]^2
	sum `w',meanonly
	scalar `W2'=(r(sum))^2
	gen `varcomp' =	`w'*`w'*`v'
	sum `varcomp' ,meanonly
	scalar `Vnum'=r(sum)
	scalar `V'  =`Vnum'/`W2' 

*Heterogeneity (need to use variance weights here - BUT use ES=wgt*es/wgt, not necc var wts)
	gen `qhet' =( (`stat'-`OV')^2 )/`v'
	sum `qhet', meanonly
	scalar `QHET'=r(sum)

	global S_1 =`exp'(`OV')
	global S_2 =sqrt( `V' )
	global S_3 =`exp'(`OV' -$ZOVE*($S_2))
	global S_4 =`exp'(`OV' +$ZOVE*($S_2))
	global S_5 =abs(`OV')/($S_2) 
	global S_6 =normprob(-abs($S_5))*2
	global S_7=`QHET'
	global S_9 =chiprob($S_8,$S_7)
end


program define _disptab
    version 7.0
    #delimit ;
    syntax varlist(min=7 max=8 default=none) [if] [in] [,
  XLAbel(passthru) XTICK(passthru) FORCE noKEEP SAVING(passthru)  noBOX noTABLE 
  noGRAPH METHOD(string) SUMSTAT(string) CHI2 T1(string) T2(string) B1(string) 
  B2(string) noOVERALL noWT noSTATS COUNTS LOG EFORM noGROUPLA SORTBY(string) 
  WGT(string) VAR3 CORNFIELD ] ;
    #delimit cr
    tempvar effect se lci uci weight use label tlabel rawdata id
    parse "`varlist'", parse(" ")
    qui {
	gen `effect'=`1'
	gen `se'    =`2'
	gen `lci'   =`3'
	gen `uci'   =`4'
	gen `weight'=`5'
	gen byte `use'=`6'
	format `weight' %5.1f
	gen str10 `label'=""
	replace `label'=`7'
	global IND:  displ %2.0f $IND
	gen str40 `rawdata' = `8' 
	if "`keep'"=="" {
 	   if ("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="") { local ln "log"}
	    else  { local ln  }
	   cap drop _ES 
	   cap drop _seES
	   cap drop _selogES 
	   if "`sumstat'"!="ES" {
	     #delimit ;
	     replace _SS  =. if `use'!=1; label var _SS "Sample size";
	     gen _ES  =`effect';label var _ES "`log'`sumstat'";
	     gen _se`ln'ES=`se';label var _se`ln'ES "se(`ln'`log'`sumstat')";
	     #delimit cr
	   }
	   #delimit ;
	   cap drop _LCI ; cap drop _UCI; cap drop _WT;
	   gen _LCI =`lci';   label var _LCI "Lower CI (`log'`sumstat')";
	   gen _UCI =`uci';   label var _UCI "Upper CI (`log'`sumstat')";
	   gen _WT=`weight';label var _WT "`method' weight";
	   #delimit cr
	}

	preserve
	if "`overall'"=="" {
**If overall figure requested, add an extra line to contain overall stats
	   qui {
		local nobs1=_N+1
		set obs `nobs1'
		replace `effect'= ($S_1) in `nobs1'
		replace `lci'=($S_3) in `nobs1'
		replace `uci'=($S_4) in `nobs1'
		replace `weight'=100 in `nobs1' 
		replace `use'=5 in `nobs1'
		replace `label' = "Overall" in `nobs1'
		if "`counts'"!="" { replace `rawdata'="$MA_ODC" in `nobs1' }
		replace `label' = "Overall" in `nobs1'
	   }
	}
	local usetot=$S_8+1
	count if `use'==2
	local alltot=r(N)+`usetot'
	gen `id'=_n
	sort `use' `sortby' `id'


    } /* End of quietly loop */
    if "`table'"=="" {
	qui gen str20 `tlabel'=`7'  /*needs to be own label so as not to overrun!*/
	if "`overall'`wt'"=="" { 
		local ww "% Weight" 
	}

	if $IND!=$OVE { 
	     global OVE: displ %2.0f $OVE
	     local insert "[$OVE% Conf. Interval]" 
	 } 
	 else { local insert "--------------------" }

	di _n in gr _col(12) "Study" _col(22) "|" _col(24) "`log'" _col(28) "`sumstat'" /*
 */  _col(34) "[$IND% Conf. Interval]"  _col(59) "`ww'" _n _dup(21) "-" "+" _dup(51) "-"
	local i=1
	while `i'<=_N {
	   if "`overall'`wt'"=="" { local ww=`weight'[`i'] }
	    else { local ww }

	   if (`use'[`i'])==2 {
*excluded trial
	     di in gr `tlabel'[`i'] _col(22) "|  (Excluded)"
	   }
	   if ( (`use'[`i']==1) | (`use'[`i']==5) ) {
		if (`use'[`i'])==1 { 
*trial results
		   di in gr `tlabel'[`i']  _cont
		 }
		 else {
*overall
		   di in gr _dup(21) "-" "+" _dup(11) "-"  "`insert'" _dup(20) "-" _n /*
*/   "`method' pooled `log'`sumstat'" _cont
		}
		di in gr _col(22) "|" in ye  %7.3f  `effect'[`i'] /* 
 */ _col(35) %7.3f `lci'[`i'] "   " %7.3f `uci'[`i'] _col(60)  %6.2f `ww' 
	   }
	   local i=`i'+1
	}
	di in gr _dup(21) "-" "+" _dup(51) "-"  
	if "`overall'"=="" {
	  if ("`method'"=="*" | "`var3'"!="") {
		if "`method'"=="*" { 
		   di in gr "* note: trials pooled by user defined weight `wgt'"
		}
		di in gr " Heterogeneity calculated by formula" _n  /*
  */ "  Q = SIGMA_i{ (1/variance_i)*(effect_i - effect_pooled)^2 } "
  	  	if "`var3'"!="" {
			di in gr "where variance_i = ((upper limit - lower limit)/(2*z))^2 "
		}
	  }
*Heterogeneity etc
	  if  ( ("`sumstat'"=="OR" | "`sumstat'"=="RR") & "`log'"=="") {local h0=1}
	   else if ("`sumstat'"=="ES" & "`eform'"!="") {local h0=1}
	   else {local h0=0}
	  di _n in gr "  Heterogeneity chi-squared = " in ye %6.2f $S_7 in gr /*
  */  " (d.f. = " in ye $S_8 in gr  ") p = "   in ye %4.3f $S_9
	  local i2=max(0, (100*($S_7-$S_8)/($S_7)) )
	  if $S_8<1 { local i2=. }
	  di in gr "  I-squared (variation in `sumstat' attributable to " /*
  */  "heterogeneity) =" in ye %6.1f `i2' "%"
	  if "`method'"=="D+L" { di in gr "  Estimate of between-study variance " /*
  */ "Tau-squared = " in ye %7.4f $S_12 }

	  if "`chi2'"!="" {  di _n in gr "  Test of OR=1: chi-squared = " in ye %4.2f /*
  */  $S_10 in gr  " (d.f. = 1) p = "  in ye %4.3f $S_11 }
	   else { di _n in gr "  Test of `log'`sumstat'=`h0' : z= " in ye %6.2f $S_5  /*
  */  in gr  " p = "  in ye %4.3f $S_6 }
	}
    }

*capture only 1 trial scenario
    qui {
	count
	if r(N)==1 { 
		set obs 2
		replace `use'=99 in 2
		replace `weight'=0 if `use'==99
	}
    } /*end of qui. */
    if "`graph'"=="" & `usetot'>0 { 
	_dispgby `effect' `lci' `uci' `weight' `use' `label' `rawdata', `log'    /*
  */  `xlabel' `xtick' `force' sumstat(`sumstat') `saving' `box' t1("`t1'") /*
  */ t2("`t2'")  b1("`b1'") b2("`b2'") `overall' `wt' `stats' `counts' `eform' /*
  */ `groupla' `cornfield'
   }
   restore
end


program define metanby
    version 7.0
    #delimit ;
    syntax varlist(min=2 max=6 default=none numeric) [if] [in] [, BY(string)
  LABEL(string) SORTBY(string) noGRAPH noTABLE noKEEP NEXTCALL(string) 
  METHOD(string) SUMSTAT(string) RANDOMI WGT(passthru) noSUBGROUP SGWEIGHT
  CORNFIELD CHI2 CC(passthru) STANDARD(passthru) noOVERALL LOG EFORM BRESLOW 
  XLAbel(passthru) XTICK(passthru) FORCE SAVING(passthru) T1(string) T2(string) 
  B1(string) B2(string) noWT noSTATS COUNTS noBOX noGROUPLA ] ;
    #delimit cr
    if ("`subgroup'"!="" & "`overall'`sgweight'"!="") { local wt "nowt" }
    tempvar use by2 newby r1 r2 rawdata effect se lci uci weight wtdisp  /*
  */ hetc hetdf hetp i2 tau2 tsig psig expand tlabel id

    qui {
	gen `use'=1 `if' `in'
	replace `use'=9 if `use'==.
	gen str1 `rawdata'="."

	tokenize `varlist'
	if ("`nextcall'"=="RR" | "`nextcall'"=="OR" | "`nextcall'"=="RD" |"`nextcall'"=="Peto" ) {
*Sort out r1 & r2 for 2x2 table: might be needed in counts and mh/use
	   gen `r1' = `1'+`2'
	   gen `r2' = `3'+`4'
	   replace `use'=2 if ((`use'==1) & (`r1'==0 | `r2'==0 ))
	   replace `use'=2 if ((`use'==1) & ((`1'+`3'==0) | (`2'+`4'==0) ) & "`nextcall'"!="RD")
	   replace `use'=9 if (`r1'==.) | (`r2'==.)
	   if "`counts'"!="" { 
*create new variable with count data (if requested)
		replace `rawdata'= trim( string(`1') + "/" + string(`r1') +";" + /*
*/  string(`3') + "/"+ string(`r2') ) if `use'!=9
	   }
	}
	if "`nextcall'"=="MD" {
*Sort out n1 & n2 
	   replace `use'=9 if (`1'==.) | (`2'==.) | (`3'==.) | (`4'==.) | (`5'==.) | (`6'==.)
	   replace `use'=2 if ( `use'==1) & (`1' <2 | `4' <2  )
	   replace `use'=2 if ( `use'==1) & (`3'<=0 | `6'<=0 )	   
	}
	if "`nextcall'"=="iv_init" {
	   replace `use'=9 if (`1'==. | `2'==.)
	   if "`3'"=="" {
		replace `use'=2 if (`use'==1 & `2'<=0 )
	    }
	    else {
		replace `use'=9 if (`3'==.)
		replace `use'=2 if ( `2'>`1' | `3'<`1' | `3'<`2')
	   }
	}

	if  (("`sumstat'"=="OR" | "`sumstat'"=="RR") & "`log'"=="" ) {local h0=1}
	 else if ("`sumstat'"=="ES" & "`eform'"!="") {local h0=1}
	 else {local h0=0}
	if "`eform'"!="" { local exp "exp" }

*Get the individual trial stats 
	`nextcall' `varlist' if `use'==1, nograph notable method(`method') `randomi' /*
  */ label(`label') `wgt' `cornfield' `chi2' `cc' `standard' `log' `eform' `breslow' 
	if $S_8<0 {
*no trials - bomb out
	   exit
	}
	local nostud=$S_8
*need to calculate from variable itself if only 2 variables (ES, SE(ES) syntax used)
	if "`sumstat'"=="ES" { 
	   gen `effect'=`exp'(`1')
	   if "`3'"=="" {
		gen `se'=`2'
	    }
	    else {
		gen `se'=.
		local var3 "var3"  
	   }
	 }
	 else { 
	   gen `effect'=_ES 
	   if `h0'<0.01 { gen `se'=_seES }
	   else         { gen `se'=_selogES }
	}
	gen `lci'=_LCI
	gen `uci'=_UCI
	gen `weight'=_WT
*put overall weight into var if requested
	if ("`sgweight'"=="" & "`overall'"=="" )  {
		gen `wtdisp'=_WT
	 }
	 else {
		gen `wtdisp'=.
	}
	gen `id'=_n
	sort `by' `sortby' `id'
*Keep only neccesary data (have to put preserve here in order to keep _ES etc)
	preserve
	drop if `use'==9
*Can now forget about the if/in conditions specified: unnecc rows have been removed

*Keep tger and cger here (otherwise it ends up in last subgroup only)
	if ("`sumstat'"=="OR" | "`sumstat'"=="RR" | "`sumstat'"=="RD"  ) {
		local tger=$S_13
		local cger=$S_14
	}

*subgroup component of heterogeneity
	gen `hetc'=.
	gen `hetdf'=.
	gen `hetp'=.
	gen `i2'=.
	gen `tau2'=.
	gen `tsig'=.
	gen `psig'=.
*Convert "by" variable to numeric if its a string variable
	cap confirm numeric var `by'
	if _rc>0 { 
	   encode `by', gen(`by2') 
	   drop `by'
	   rename `by2' `by'
	}
*Create new "by" variable to take on codes 1,2,3.. 
	gen `newby'=(`by'>`by'[_n-1])
	replace `newby'=1+sum(`newby')
	local ngroups=`newby'[_N]

	if "`overall'"=="" {
*If requested, add an extra line to contain overall stats
	   local nobs1=_N+1
	   set obs `nobs1'

	   replace `use'=5 in `nobs1'
	   replace `newby'=`ngroups'+1 in `nobs1'
	   replace `effect'= ($S_1) in `nobs1'
	   replace `lci'=($S_3) in `nobs1'
	   replace `uci'=($S_4) in `nobs1'
*Put cell counts in subtotal row
	   if ("`counts'"!="" & "`nextcall'"!="MD") { 
*put up overall binary count data
		sum `1'  if (`use'==1 | `use'==2)
		local sum1=r(sum)
		sum `r1' if (`use'==1 | `use'==2)
		local sum2=r(sum)
		sum `3'  if (`use'==1 | `use'==2)
		local sum3=r(sum)
		sum `r2' if (`use'==1 | `use'==2)
		local sum4=r(sum)
		replace `rawdata'= "`sum1'/`sum2';`sum3'/`sum4'" in `nobs1'
	   }
	   replace `hetc' =($S_7) in `nobs1'
	   replace `hetdf'=($S_8) in `nobs1'
	   replace `hetp' =($S_9) in `nobs1'
	   replace `i2'=max(0, ( 100*($S_7-$S_8))/($S_7) ) in `nobs1'
	   if $S_8<1 { replace `i2'=. in `nobs1' }
	   replace `tau2' =$S_12 in `nobs1'
	   replace `se'=$S_2 in `nobs1'
	   if "`chi2'"!="" { 
		replace `tsig'=$S_10 in `nobs1'
		replace `psig'=$S_11 in `nobs1'
		local z=$S_5
		local pz=$S_6
	    }
	    else { 
		replace `tsig'=$S_5 in `nobs1'
		replace `psig'=$S_6 in `nobs1'
		local echi2 =$S_10
		local pchi2=$S_11
	    }
	    replace `label' = "Overall" in `nobs1'
	    if "`sgweight'"=="" { replace `wtdisp'=100 in `nobs1' }
	}

*Create extra 2 or 3 lines per bygroup: one to label, one for gap
*and one for overall effect size (unless no subgroup combining is done)
	sort `newby' `use' `sortby' `id'
	by `newby': gen `expand'=1 + 2*(_n==1) + (_n==1 & "`subgroup'"=="") 
	replace `expand'=1 if `use'==5
	expand `expand'
	gsort `newby' -`expand' `use' `sortby' `id'
	by `newby': replace `use'=0 if `expand'>1 & _n==2   /* row for by label */
	by `newby': replace `use'=4 if `expand'>1 & _n==3   /* row for blank line */
	by `newby': replace `use'=3 if `expand'>1 & _n==4   /* (if specified) row to hold subgp effect sizes */

* blank out effect sizes in new rows
	replace `effect'=.  if `expand'>1 & `use'!=1    
	replace `lci'=. if `expand'>1 & `use'!=1  
	replace `uci'=. if `expand'>1 & `use'!=1    
	replace `weight' =. if `expand'>1 & `use'!=1   
	replace `rawdata' ="." if `expand'>1 & `use'!=1   
*Perform subgroup analyses 
	local j=1
	while `j'<=`ngroups' {
	  if "`subgroup'"=="" {
*First ensure the by() category has any data
	   count if (`newby'==`j' & `use'==1)
	   if r(N)==0 {
*No data in subgroup=> fill variables with missing and move on
		replace `effect'=. if (`use'==3 & `newby'==`j')
		replace `lci'=. if (`use'==3 & `newby'==`j')
		replace `uci'=. if (`use'==3 & `newby'==`j')
		replace `wtdisp'=0 if `newby'==`j'
		replace `weight'=0 if `newby'==`j'
		replace `hetc'=. if `newby'==`j'
		replace `hetdf'=. if `newby'==`j'
		replace `hetp'=. if `newby'==`j'
		replace `i2'=. if `newby'==`j'
		replace `tsig'=. if `newby'==`j'
		replace `psig'=. if `newby'==`j'
		replace `tau2'=. if `newby'==`j'
	    }
	    else {

		`nextcall' `varlist' if (`newby'==`j' & `use'==1) , nograph /*
  */ notable label(`label') method(`method') `randomi' `wgt' `cornfield' `chi2' /*
  */ `cc' `standard' `log' `eform' `breslow'
		replace `effect'=($S_1) if `use'==3 & `newby'==`j'
		replace `lci'=($S_3) if `use'==3 & `newby'==`j'
		replace `uci'=($S_4) if `use'==3 & `newby'==`j'
*Put within-subg weights in if nooverall or sgweight options specified
		if ("`overall'`sgweight'"!="" )  {
		   replace `wtdisp'=_WT if `newby'==`j'
		   replace `wtdisp'=100 if (`use'==3 & `newby'==`j')
		 }
		 else {
		   qui sum `wtdisp' if (`use'==1 & `newby'==`j')
		   replace `wtdisp'=r(sum) if (`use'==3 & `newby'==`j')
		}
		sum `weight' if `newby'==`j'
		replace `weight'= r(sum) if `use'==3 & `newby'==`j'
		replace `hetc' =($S_7) if `use'==3 & `newby'==`j'
		replace `hetdf'=($S_8) if `use'==3 & `newby'==`j'
		replace `hetp' =($S_9) if `use'==3 & `newby'==`j'
		replace `i2'=max(0, ( 100*($S_7-$S_8))/($S_7) ) if `use'==3 & `newby'==`j'
		if $S_8<1 { replace `i2'=. if `use'==3 & `newby'==`j' }
		if "`chi2'"!="" {  
		   replace `tsig'=($S_10) if `use'==3 & `newby'==`j'
		   replace `psig'=($S_11) if `use'==3 & `newby'==`j'
		}
		 else {
		   replace `tsig'=($S_5) if `use'==3 & `newby'==`j'
		   replace `psig'=($S_6) if `use'==3 & `newby'==`j'
		}
		if "`method'"=="D+L" {
		   replace `tau2' =($S_12) if `use'==3 & `newby'==`j'
		}
	   }

*Whether data or not - put cell counts in subtotal row if requested (will be 0/n1;0/n2 or blank if all use>1)
	   if "`counts'"!="" { 
*don't put up anything for MDs:
*1 Cochrane just put up N_gi. Not sure whether weighted mean should be in..
*2 justifying N_gi is tedious!
	     if "`nextcall'"!="MD" {
		sum `1'  if (`use'==1 | `use'==2) & (`newby'==`j')
		local sum1=r(sum)
		sum `r1' if (`use'==1 | `use'==2) & (`newby'==`j')
		local sum2=r(sum)
		sum `3'  if (`use'==1 | `use'==2) & (`newby'==`j')
		local sum3=r(sum)
		sum `r2' if (`use'==1 | `use'==2) & (`newby'==`j')
		local sum4=r(sum)
		replace `rawdata'= "`sum1'/`sum2';`sum3'/`sum4'" if (`use'==3 & `newby'==`j')
	     }
	   }
	  }
*Label attatched (if any) to byvar
	  local lbl: value label `by'
	  sum `by' if `newby'==`j'
	  local byvlu=r(mean)
	  if "`lbl'"=="" { local lab "`by'==`byvlu'" }
	   else { local lab: label `lbl' `byvlu' }
	  replace `label' = "`lab'" if ( `use'==0 & `newby'==`j')
	  replace `label' = "Subtotal" if ( `use'==3 & `newby'==`j')
	  local j=`j'+1
	}

    } /*End of quietly loop*/


*Put table up (if requested)
    sort `newby' `use' `sortby'  `id'

    if "`table'"=="" {
	qui gen str20 `tlabel'=`label'
	if "`overall'`wt'"=="" { 
		local ww  "% Weight" 
	}
	di _n in gr _col(12) "Study" _col(22) "|" _col(24) "`log'" _col(28) "`sumstat'" /*
 */  _col(34) "[$IND% Conf. Interval]"  _col(59) "`ww'"
	di  _dup(21) "-" "+" _dup(51) "-"
*legend for pooled confidence intervals

	local i=1
	while `i'<= _N {
	   if (`use'[`i'])==0 { 
*by label
		 di _col(6) in gr `tlabel'[`i'] 
	   }
	   if "`overall'`wt'"=="" { local ww=`wtdisp'[`i'] }
	    else { local ww }
	   if (`use'[`i'])==1 { 
*trial results
		di in gr `tlabel'[`i'] _col(22) "|  " in ye  %7.3f  `effect'[`i'] /* 
 */ _col(35) %7.3f `lci'[`i'] "   " %7.3f `uci'[`i'] _col(60)  %6.2f `ww' 
	   }
	   if (`use'[`i'])==2 {
*excluded trial
		di in gr `tlabel'[`i'] _col(22) "|  (Excluded)"
	   }
	   if ((`use'[`i']==3) & "`subgroup'"=="") | (`use'[`i']==5) {
*Subgroup effect size or overall effect size
		if (`use'[`i'])==3 { 
		   di in gr " Sub-total" _col(22) "|"
		}
		if (`use'[`i'])==5 { 
		   if $IND!=$OVE { 
			local insert "[$OVE% Conf. Interval]" 
		   }
		   di in gr "Overall"  _col(22) "|" _col(34) "`insert'"
		}
		if "`ww'"=="." { local ww }
		di in gr "  `method' pooled `log'`sumstat'" _col(22) "|  " in ye  %7.3f /*
  */ `effect'[`i'] _col(35) %7.3f  `lci'[`i'] "   "  %7.3f `uci'[`i'] _col(60) %6.2f `ww'
		if (`use'[`i'])==5 { 
		   di in gr _dup(21) "-" "+" _dup(51) "-" 
		}
	   }

	   if (`use'[`i'])==4 { 
*blank line separator (need to put line here in case nosubgroup was selected)
		di in gr _dup(21) "-" "+" _dup(51) "-" 
	   }

	   local i=`i'+1

	}
*Skip next bits if nooverall AND nosubgroup
	if ("`subgroup'"=="" | "`overall'"=="") {

*part 2: user defined weight notes and heterogeneity 
	 if ("`method'"=="*" | "`var3'"!="") {
		if "`method'"=="*" { 
		   di in gr "* note: trials pooled by user defined weight `wgt'"
		}
		di in bl " Heterogeneity calculated by formula" _n  /*
  */ "  Q = SIGMA_i{ (1/variance_i)*(effect_i - effect_pooled)^2 } "
  	  	if "`var3'"!="" {
			di in bl "where variance_i = ((upper limit - lower limit)/(2*z))^2 "
		}
	 }

	 di in gr _n "Test(s) of heterogeneity:" _n _col(16) "Heterogeneity  degrees of"
	 di in gr _col(18) "statistic     freedom      P    I-squared**" _cont
	 if "`method'"=="D+L" { di in gr "   Tau-squared" }
	 di
	 local i=1
	 while `i'<= _N {
	   if ("`subgroup'"=="" & (`use'[`i'])==0) | ( (`use'[`i'])==5) { 
		di in gr _n `tlabel'[`i'] _cont 
	   }
	   if ( ((`use'[`i'])==3) | ((`use'[`i'])==5) ) { 

		di in ye _col(20) %6.2f `hetc'[`i'] _col(35) %2.0f `hetdf'[`i']   /*
  */  _col(43) %4.3f `hetp'[`i'] _col(51) %6.1f `i2'[`i'] "%" _cont

		if "`method'"=="D+L" { 
		   di in ye "      " %7.4f `tau2'[`i'] _cont
		}

		if (`use'[`i']==5) & ("`subgroup'"=="") {
		   qui sum `hetc' if `use'==3
		   local btwghet = (`hetc'[`i']) -r(sum)
		   local df = `ngroups'-1
		   di _n in gr "Overall Test for heterogeneity between sub-groups : " _n   /*
  */ in ye _col(20) %6.2f `btwghet' _col(35) %2.0f `df'  _col(43) %4.3f  (chiprob(`df',`btwghet'))
		}
	   }
	   local i=`i'+1
	 }
	 di _n in gr "** I-squared: the variation in `sumstat' attributable to heterogeneity)" _n

*part 3: test statistics
	 di _n in gr "Significance test(s) of `log'`sumstat'=`h0'" 
	 local i=1
	 while `i'<= _N {
	   if ("`subgroup'"=="" & (`use'[`i'])==0) | ( (`use'[`i'])==5) { 
		di _n in gr `tlabel'[`i'] _cont 
	   }
	   if ( ((`use'[`i'])==3) | ((`use'[`i'])==5) ) { 

		if "`chi2'"!="" {  
		   di in gr _col(20) "chi-squared = " in ye %5.2f `tsig'[`i'] /*
  */ in gr  _col(35) " (d.f. = 1) p = "  in ye %4.3f `psig'[`i'] _cont
	  	 }
	  	 else { 
		   di in gr _col(23) "z= " in ye %5.2f `tsig'[`i'] _col(35) in gr  /*
  */ " p = "  in ye %4.3f `psig'[`i'] _cont
		}
	   }
	   local i=`i'+1
	 }
	 di _n in gr _dup(73) "-" 
	} 

    } /* end of table display */

    if "`overall'"=="" {
*need to return overall effect to $S_1 macros and so on...
	 global S_1=`effect'[_N]
	 global S_2=`se'[_N]
	 global S_3=`lci'[_N]
	 global S_4=`uci'[_N]
	 global S_7=`hetc'[_N] 
	 global S_8=`hetdf'[_N]
	 global S_9=`hetp'[_N] 
	 if "`chi2'"!="" {
	    global S_10=`tsig'[_N]
	    global S_11=`psig'[_N]
	    global S_5=`z'
	    global S_6=`pz'
	  }
	  else {
	    global S_5=`tsig'[_N]
	    global S_6=`psig'[_N]
	    global S_10=`echi2'
	    global S_11=`pchi2'
	 }
	 global S_12=`tau2'[_N] 
	if ("`sumstat'"=="OR" | "`sumstat'"=="RR" | "`sumstat'"=="RD"  ) {
	 global S_13=`tger'
	 global S_14=`cger'
	}
     }
     else {
	 #delimit ;
    global S_1 "."; global S_2 "."; global S_3 "."; global S_4 "."; 
    global S_5 "."; global S_6 "."; global S_7 "."; global S_8= `nostud'; 
    global S_9 "."; global S_10 ".";global S_11 ".";global S_12 ".";  
    global S_13 ".";global S_14 ".";  
    #delimit cr
    }

    if "`graph'"=="" {
	_dispgby `effect' `lci' `uci' `weight' `use' `label' `rawdata' `wtdisp',  /*
  */ `log' `xlabel' `xtick' `force' sumstat(`sumstat') `saving' `box' t1("`t1'")  /*
  */ t2("`t2'")  b1("`b1'") b2("`b2'") `overall' `wt' `stats' `counts' `eform'    /*
  */ `groupla'  `cornfield'
    }

    restore
    if "`keep'"=="" {
      qui{
	if ("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="") { local ln "log"}
	 else  { local ln  }
	cap drop _ES 
	cap drop _seES
	cap drop _selogES 
	if "`sumstat'"!="ES" {
	   #delimit ;
	   replace _SS  =. if `use'!=1; label var _SS "Sample size";
	   gen _ES  =`effect';label var _ES "`log'`sumstat'";
	   gen _se`ln'ES=`se';label var _se`ln'ES "se(`ln'`log'`sumstat')";
	   #delimit cr
	}
	#delimit ;
	cap drop _LCI ; cap drop _UCI; cap drop _WT;
	gen _LCI =`lci';   label var _LCI "Lower CI (`log'`sumstat')";
	gen _UCI =`uci';   label var _UCI "Upper CI (`log'`sumstat')";
	#delimit cr
       
*correct weight if subgroup weights given	
        if ("`sgweight'"=="" & "`overall'"=="" )  { gen _WT=`weight' }
         else if "`subgroup'"=="" & ("`overall'`sgweight'"!="" )  {
	  tempvar tempsum
	  by `by': gen `tempsum'=sum(`weight')
	  by `by': replace `tempsum'=`tempsum'[_N]
	  gen _WT=`weight'*100/`tempsum'
	  local sg "(subgroup) "
	}
	cap label var _WT "`method' `sg'% weight"
      }
    }
end


program define _dispgby
    version 7.0
    #delimit ;
    syntax varlist(min=6 max=8 default=none ) [if] [in] [,
  LOG XLAbel(string) XTICK(string) FORCE SAVING(string) noBOX SUMSTAT(string) 
  T1(string) T2(string) B1(string) B2(string) noOVERALL noWT noSTATS COUNTS EFORM 
  noGROUPLA CORNFIELD ];
    #delimit cr
    tempvar effect lci uci weight wtdisp use label tlabel id yrange xrange Ghsqrwt rawdata
    parse "`varlist'", parse(" ")
    qui {
	gen `effect'=`1'
	gen `lci'   =`2'
	gen `uci'   =`3'
	gen `weight'=`4'
	gen byte `use'=`5'
*Use is now coded:
*0: blank line, except for text containing "by"
*1: trial
*2: excluded trial
*3. subgroup effect (in which case `label' or `6' is to contain the name of the subgroup)
*4. blank line
*5. overall effect
*9. missed/not considered
*As before effect sizes are held elsewhere

	gen str10 `label'=""
	replace `label'=`6'
	count if (`use'==1 | `use'==2)
	local ntrials=r(N)
	count if (`use'>=0 & `use'<=5)
	local ymax=r(N)
	gen `id'=`ymax'-_n+1 if `use'<9
	gen str40 `rawdata' = `7'
	compress `rawdata'
	if "`8'"!="" {
	   gen `wtdisp'=`8' 
	 }
	 else { 
	   gen `wtdisp'=`weight' 
	}
	format `wtdisp' %5.1f
	sum `lci'
	local Gxlo=r(min) /* minimum of CIs*/
	sum `uci'
	local Gxhi=r(max) /* maximum of CIs*/
	local h0=0
	if (("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="")) | ("`eform'"!="") {
	  local h0=1
	  local Glog "xlog"
	  local xlog "log" 
	  local xexp "exp"
	  replace `lci'=1e-9 if `lci'<1e-8
	  replace `lci'=1e9  if `lci'>1e8 & `lci'!=.
	  replace `uci'=1e-9 if `uci'<1e-8
	  replace `uci'=1e9  if `uci'>1e8 & `uci'!=.
	  if `Gxlo'<1e-8 {local Gxlo=1e-8}
	  if `Gxhi'>1e8  {local Gxhi=1e8}
	}
	if "`cornfield'"!="" {
	  replace `lci'=`log'(1e-9) if ( (`lci'==. | `lci'==0) & (`effect'!=. & `use'==1) )
	  replace `uci'=`log'(1e9)  if ( (`uci'==.) & (`effect'!=. & `use'==1) )
	}
	local flag1=0
	if "`xtick'"!="" {
* capture inappropriate tick
	   cap assert ("`xlog'"=="" ) | /*
 */  ( ( min(`xtick' ,`Gxhi')>1e-8 ) & (max(`xtick' ,`Gxlo')<1e8) )
	   if _rc!=0 {
		  local flag1=10 
		  local xtick "`h0'"
	   }
	 }
	 else { 
	   local xtick  "`h0'"
	}
	if "`xlabel'"!="" {
* capture inappropriate label
	   cap {
	    assert ("`xlog'"=="" ) |  /*
 */ ( ( min(`xlabel',`Gxhi')>1e-8 ) & (max(`xlabel',`Gxlo')<1e8) )
	   }
	   if _rc!=0 {
		  local flag1=10 
		  local xlabel 
	    }
	    else {
		if "`force'"!="" {
		   parse "`xlabel'", parse(",")
		   if "`3'"!="" {
			local Gxlo=`h0'
			local Gxhi=`h0'
		   }
		}
	   }
	}

	if "`xlabel'"=="" | (`flag1'>1) {
	   local Gmodxhi=max( abs(`xlog'(`Gxlo')),abs(`xlog'(`Gxhi')))
	   if `Gmodxhi'==. {local Gmodxhi=2}
	   local Gxlo=`xexp'(-`Gmodxhi')
	   local Gxhi=`xexp'( `Gmodxhi')
	   local xlabel "`Gxlo',`h0',`Gxhi'"
	}
	local Gxlo=`xlog'(min(`xlabel',`xtick',`Gxlo'))
	local Gxhi=`xlog'(max(`xlabel',`xtick',`Gxhi'))

	local Gxlo1=`Gxlo'-0.1*`Gxhi'
	local Gxrange=(`Gxhi'-`Gxlo')
	local Gyhi=`id'[1]

	local Gxh20=`Gxhi'+`Gxrange'*0.2
	local Gxh40=`Gxhi'+`Gxrange'*0.4
	local Gxh60=`Gxhi'+`Gxrange'*0.6
	local Gxh80=`Gxhi'+`Gxrange'*0.8
	local Gxh100=`Gxhi'+`Gxrange'*1.0
	gen `xrange'=`xexp'(`Gxlo') in 1

*If user wants no counts (c), stats (s) or weights (w) , use entire window for trial plots
	if ("`stats'"!="" & "`wt'"!="" & "`counts'"=="" ) { 
		local Txhi=`Gxhi'
	}
*If user wants s&w (default) or c&w use Gxh60 (60% of graph range) for figures
	if (("`stats'"=="" & "`wt'"=="" & "`counts'"=="" ) | ("`stats'"!="" & "`wt'"=="" & "`counts'"!="" )) { 
		local Txhi=`Gxh60'
	}
*If user wants s or c alone use Gxh40 (40% of range)
	if (("`stats'"=="" & "`wt'"!="" & "`counts'"=="" ) |  ("`stats'"!="" & "`wt'"!="" & "`counts'"!="" )) { 
		local Txhi=`Gxh40'
	}
*If user wants w alone use Gxh20
	if ("`stats'"!="" & "`wt'"=="" & "`counts'"=="" ) { 
		local Txhi=`Gxh20'
	}
*If user wants s&c use Gxh80
	if ("`stats'"=="" & "`wt'"!="" & "`counts'"!="" )  { 
		local Txhi=`Gxh80'
	}
*If user wants all 3 use Gxh100
	if ("`stats'"=="" & "`wt'"=="" & "`counts'"!="" ) { 
		local Txhi=`Gxh100'
	}
	replace `xrange'=`xexp'(`Txhi') in 2 

	gen `yrange'=0 in 1
	replace `yrange'=`Gyhi'+2 in 2
	cap label drop tmpyl
	cap label drop tmpxl
* Study legend now removed
	label define tmpyl 0 " " 
	label define tmpxl `h0' " " 

	label values `yrange' tmpyl
	label values `xrange' tmpxl
*Label x-axis and top right *if stats requested
	if "`sumstat'"=="OR"        {local sscale "`log' Odds ratio"}
	 else if "`sumstat'"=="RR"  {local sscale "`log' Risk ratio"}
 else if "`sumstat'"=="RD"  {local sscale "Risk difference"}
 else if "`sumstat'"=="WMD" {local sscale "Mean difference"}
 else if "`sumstat'"=="SMD" {local sscale "Standardised mean difference"}
 else if ("`sumstat'"=="ES" & "$MA_ESLA"!="") { local sscale "$MA_ESLA" }
 else if "`sumstat'"=="ES"  {local sscale "Effect size"}

	if "`t1'"=="." {local t1 }
	 else {
		local t1=substr("`t1'",2,.)
		local t1 "t1(`t1')"
	}
	if "`t2'"=="." {local t2 }
	 else {
		local t2=substr("`t2'",2,.)
		local t2 "t2(`t2')"
	}
	if "`b2'"=="." { local b2 "`sscale'"}
	 else {
*Revise position of b2 title: graph command doesn't put it in the right place
		local b2=substr("`b2'",2,.)
	}
	if "`saving'"!=""   {local saving "saving(`saving')" }
	 else { local saving }
	gph open, `saving'

	if "`b1'"=="." {
	  graph `yrange' `xrange', s(i) xli(`h0') `Glog' xlabel(`h0') /*
 */  noaxis  yla(0) gap(10) `t1' `t2' b2(" ")
	 }
	 else { 
	  graph `yrange' `xrange', s(i) xli(`h0') `Glog' xlabel(`h0') /*
 */  noaxis  yla(0) gap(10) `t1' `t2' b1(" ") b2(" ")
	}


	local r5=r(ay)
	local r6=r(by)
	local r7=r(ax)
	local r8=r(bx)
	local Aytexs=($MA_FTSI)*max(200, min(700, (600-20*(`ymax'-15)) ) )
	local Axtexs=($MA_FTSI)*max(130, min(360,(0.6*`Aytexs')) )

	gph font `Aytexs' `Axtexs'
	gph pen 1
	local Axh0  =`r7'*(`xlog'(`h0'))+`r8'
	local Axlo  =`r7'*(`Gxlo') +`r8'
	local Axloe =`r7'*(`Gxlo') +`r8' -1500
	local Axhi  =`r7'*(`Gxhi') +`r8'
	local Axhie =`r7'*(`Gxhi') +`r8' + 1500*( ("`wt'"=="") | ("`stats'"=="") | ("`counts'"!="") )
	local Axh20 =`r7'*(`Gxh20') +`r8'
	local Axh40 =`r7'*(`Gxh40') +`r8'
	local Axh60 =`r7'*(`Gxh60') +`r8'
	local Axh80 =`r7'*(`Gxh80') +`r8'
	local Axh100=`r7'*(`Gxh100')+`r8'
*add x-axis line and label manually

	gph line `r6' `Axloe'  `r6' `Axhie'
	local yb=`r6'+1000
	gph line `r6' `Axh0' `yb' `Axh0'
	local yb=`r6'+2400+max(0,(1000-100*`ymax'))
 	gph text `yb' `Axh0'  0 0 `b2' 
	if "`b1'"!="." { 
	  local yb=`r6'+3000+max(0,(1200-100*`ymax'))
	  local b1=substr("`b1'",2,.) 
	  if substr("`b1'",1,3)=="*I:" {
*"Favours ..." labels 
		local flab= substr("`b1'",4,.)
		tokenize "`flab'" , parse(*)
		if "`1'"!="" {
		  local xt=`Axh0'-1000
		  gph text `yb' `xt' 0 1 `1'
		}
		if "`3'"!="" {
		  local xt=`Axh0'+1000
		  gph text `yb' `xt' 0 -1 `3'
		}
	  }
	  else {
 		gph text `yb' `Axh0'  0 0 `b1' 
	 }
	}


*add xtick & xlabel manually
	tokenize "`xlabel'", parse(,)
	while "`1'"!="" {
	  local x=`1'
  	  if (`x'>10e8) { local x="10e8" } 
  	  if ((`x'<=-10e8) & (`h0'==0)) { local x="-10e8" } 
	  local Ax=`r7'*(`xlog'(`x')) +`r8'
	  local Ayh=`r6'
	  local Ayl=`r6'+400
	  local Ayt=`r6'+1700
	  gph line `Ayh' `Ax' `Ayl' `Ax'
  	  if ((`x'<10e-6) & (`h0'==1)) { local x="0.00000" }
	  if ((`x'<10e4) & (`x'>-10e4)) { local x=substr("`x'",1,7) }
	  gph text `Ayt' `Ax' 0 0 `x'
	  mac shift 2
	}

	tokenize "`xtick'", parse(,)
	while "`1'"!="" {
	  local Ax=`r7'*(`xlog'(`1')) + `r8'
	  local Ayh=`r6'
	  local Ayl=`r6'+400
	  local Ayt=`r6'+1000
	  gph line `Ayh' `Ax' `Ayl' `Ax'
	  mac shift 2
	}

*Add legend
	local Ayhi =(`Gyhi'+2)*`r5'+`r6'
	local Axtexh=50+max(0,min(2400,`ymax'*60-700))
	local Ayhead=`r5'*(`ymax'+1) + `r6'

	gph text `Ayhead' `Axtexh' 0 -1 $S_TX 


/*Order of text: stats, counts, weights (where selected)*/
*New positionings reduce gaps between stats/weight/counts

	if ("`stats'"=="") {
*Align stats first at Axhi. Use prev line if `sscale' too long (>12chrs)
*	   local lenssc=length("`sscale'")
*	   if `lenssc'<13 {
*		gph text `Ayhead' `Axhi' 0 -1 `sscale' ($IND% CI)
*	    }
*	    else {
		local Ayhead2=`r5'*(`ymax'+1.65) + `r6'
		gph text `Ayhead2' `Axhi' 0 -1 `sscale'
		gph text `Ayhead'  `Axhi' 0 -1  ($IND% CI)
*	   }
	}
	if ("`counts'"!="") {
*Align counts 2nd if both stats & weight
	   if ("`stats'"=="") { 
		local Ax2hi1=`Axh20'+(`Axh60'-`Axh20')*(max(0.4, min(1,2-0.07*`ymax') ) )
		local Ax2hi2=`Axh20'+(`Axh80'-`Axh20')*(max(0.4, min(1,2-0.07*`ymax') ) )
*local Ax2hi1=`Axh60'
*local Ax2hi2=`Axh80'
	    }
	    else  { 
		local Ax2hi1=`Axhi'+(`Axh20'-`Axhi')*(max(0.4, min(1,2-0.07*`ymax') ) )
		local Ax2hi2=`Axhi'+(`Axh40'-`Axhi')*(max(0.4, min(1,2-0.07*`ymax') ) )
*local Ax2hi1=`Axh20'
*local Ax2hi2=`Axh40'
	   }
	   local yt=`Ayhead'-max(200, min(1000,1600-40*`ymax'))
	   gph text `yt' `Ax2hi1' 0  0 No. of events
*	   gph font 500 270
	   gph text `Ayhead' `Ax2hi1' 0  1 $MA_G1L
	   gph text `Ayhead' `Ax2hi2' 0  1 $MA_G2L
	}
	if ("`wt'"=="") {
	   if ("`stats'"=="" & "`counts'"!="") { 
*local Ax3hi=`Axh100' 
		local Ax3hi=`Axh20'+(`Axh100'-`Axh20')*(max(0.4, min(1,2-0.07*`ymax') ) )
	    }
	    else if ("`stats'"!="" & "`counts'"=="") { 
		local Ax3hi=`Axh20' 
	    }
	    else  { 
*local Ax3hi=`Axh60' 
		local Ax3hi=`Axh20'+(`Axh60'-`Axh20')*(max(0.4, min(1,2-0.07*`ymax') ) )
	   }
	   gph text `Ayhead' `Ax3hi' 0  1 % Weight
	}
	gen `Ghsqrwt'=0.5*sqrt(`weight')/2
	local flag=0
	while `flag'<1 {
	   cap assert `Ghsqrwt'<0.5 if (`use'==1)
	   if _rc!=0 { replace `Ghsqrwt'=0.9*`Ghsqrwt' }
	    else { local flag=10}
	}
	replace `Ghsqrwt'=($MA_FBSC)*`Ghsqrwt'
	local flag2=0
	local flag3=0
	local i=1
	gph pen 2

	while `i'<=`ymax' {
	 local Aytcen= `r5'*(`id'[`i']-0.2)+`r6'   /* text label centre */
	 local Aygcen= `r5'*(`id'[`i'])+`r6'   /* graphics label centre */


*label to put on left hand 
	 local tx = `label'[`i']
	 local Axtexs=`Axtexh'+400

*use=0 => blank line except for "by" legend 
	 if  (`use'[`i']==0) { 
	   gph pen 3
	   gph text `Aytcen' `Axtexh' 0 -1 `tx'
	 }

*use=1 => individual trial
	 if `use'[`i']==1 {
	   gph pen 2
	   gph text `Aytcen' `Axtexs' 0 -1 `tx'
	   if `lci'[`i']==. | `uci'[`i']==. { local flag2=10 }
	    else {
* Define lower/upper points on x-line, and centre on y-axis 
		local Axlpt= `r7'*(`xlog'( `lci'[`i'] ))+`r8'
		local Axupt= `r7'*(`xlog'( `uci'[`i'] ))+`r8'
		if (`Axupt' < `Axlo') | (`Axlpt' > `Axhi') {  
* If CI is totally off scale draw (triangular) arrow 
		  local Ayco1=`r5'*(`id'[`i']-0.2)+`r6'
		  local Ayco2=`r5'*(`id'[`i']+0.2)+`r6'
		  if `Axupt'<=`Axlo' {
			local Axlpt =`Axlo'
			local Axco1=`r7'*(`Gxlo')+`r8'
			local Axco2=`r7'*(`Gxlo')+`r8'+450
		  }
		  if `Axlpt'>=`Axhi' {  
			local Axupt =`Axhi'
			local Axco1=`r7'*(`Gxhi')+`r8'
			local Axco2=`r7'*(`Gxhi')+`r8'-450
		  }
		  gph line `Aygcen' `Axco1' `Ayco2'  `Axco2'
		  gph line `Ayco2'  `Axco2' `Ayco1'  `Axco2'
		  gph line `Ayco1'  `Axco2' `Aygcen' `Axco1'
		 }
		 else {
		  local Axcen  =`r7'*`xlog'(`effect'[`i'])+`r8'
* Define box size 
		  local Ahboxl =abs(`r5'*( `Ghsqrwt'[`i'] ))
		  local Ay1cord=`Aygcen'+`Ahboxl' 
		  local Ax1cord=`Axcen' -`Ahboxl' 
		  local Ay2cord=`Aygcen'-`Ahboxl' 
		  local Ax2cord=`Axcen' +`Ahboxl' 
		  if (`Axlpt' < `Axlo') | (`Axupt' > `Axhi')  {
* CI is on but not totaly on scale: draw arrow at end of CI
			local Ayco1=`r5'*(`id'[`i']-0.1)+`r6'
			local Ayco2=`r5'*(`id'[`i']+0.1)+`r6'
			if `Axlpt' < `Axlo' {
			    local Axlpt =`Axlo'
			    local Axco1=`r7'*(`Gxlo')+`r8'
			    local Axco2=`r7'*(`Gxlo')+`r8'+350
			    gph line `Aygcen' `Axco1' `Ayco1' `Axco2'
			    gph line `Aygcen' `Axco1' `Ayco2' `Axco2'
			}
			if `Axupt' > `Axhi'  {
			    local Axupt =`Axhi'
			    local Axco1=`r7'*(`Gxhi')+`r8'
			    local Axco2=`r7'*(`Gxhi')+`r8'-350
			    gph line `Aygcen' `Axco1' `Ayco1' `Axco2'
			    gph line `Aygcen' `Axco1' `Ayco2' `Axco2'
			}
		  }

*draw line for CI
		  gph line `Aygcen' `Axlpt' `Aygcen' `Axupt'
*either draw box for ES/weight...
		  if "`box'"=="" {
		   if (`Ax1cord' >=`Axlo') & (`Ax2cord'<=`Axhi') {
			gph box `Ay1cord' `Ax1cord' `Ay2cord' `Ax2cord' $MA_FBSH
		    }
		    else {local flag2=10}
		  }
*...or simply plot ES (as circle) instead of box
		  if "`box'"!="" { 
		   if (`Ax1cord' >=`Axlo') & (`Ax2cord'<=`Axhi') {
		   	local ptsize=250*$MA_FBSC
			gph point `Aygcen' `Axcen' `ptsize' 1
		    }
		    else {local flag2=10}
		  }
		}
	   }
	 }

*use=2 => Excluded trial
	 if  (`use'[`i']==2) { 
	   gph text `Aytcen' `Axtexs' 0 -1 `tx'
	 }
*use=4 => blank line: no text or graphic necessary (above displays nothing)

*use=3 => subgroup effect size (display by default), or...
*use=5 => overall effect size (display by default)

	 if ( ((`use'[`i']==3) & ("`subgrp'"=="")) |  /*
 */   ((`use'[`i']==5) & ("`overall'"=="")) )  {

 	   if (`use'[`i']==3) { gph pen 3 }
	   if (`use'[`i']==5) { gph pen 5 }
	   gph text `Aytcen' `Axtexh' 0 -1 `tx'
	   local Aycol=`r5'*((`id'[`i'])-0.2)+`r6'
	   local Aycoh= `r5'*((`id'[`i'])+0.2)+`r6'
*the following 4 are necc in case diamond is chopped off
	   local Aycenl1=`Aygcen'
	   local Aycenl2=`Aygcen'
	   local Aycenh1=`Aygcen'
	   local Aycenh2=`Aygcen'
	   local Axcol=`r7'*(`xlog'(`lci'[`i']))+`r8'
	   local Axcen=`r7'*(`xlog'(`effect'[`i']))+`r8'
	   local Axcoh=`r7'*(`xlog'(`uci'[`i']))+`r8'
	   if (`Axcen'<`Axlo') | (`Axcen'>`Axhi') { 
*diamond is off the scale!
		local flag3=10 
	    }
	    else {
* phi is angle between diamond slope and y=id  in right angle triangle; use this
* fact to get y where diamond is chopped off at
		if `Axcol'<`Axlo' { 
		  local flag3=10
		  local tanphi=(0.2*`r5')/(`Axcen'-`Axcol')
		  local Aydiff=(`Axlo'-`Axcol')*`tanphi'
		  local Aycenl1=`Aygcen'-`Aydiff'
		  local Aycenl2=`Aygcen'+`Aydiff'
		  local Axcol=`Axlo'
		  gph line `Aycenl1' `Axcol' `Aycenl2' `Axcol'
		}
		if `Axcoh'>`Axhi' {
		  local flag3=10
		  local tanphi=(0.2*`r5')/(`Axcoh'-`Axcen')
		  local Aydiff=(`Axcoh'-`Axhi')*`tanphi'
		  local Aycenh1=`Aygcen'-`Aydiff'
		  local Aycenh2=`Aygcen'+`Aydiff'
		  local Axcoh=`Axhi'
		  gph line `Aycenh1' `Axcoh' `Aycenh2' `Axcoh'
		}
		gph line `Aycoh' `Axcen' `Aycenh2' `Axcoh' 
		gph line `Aycenh1' `Axcoh' `Aycol' `Axcen'
		gph line `Aycol' `Axcen' `Aycenl1' `Axcol' 
		gph line `Aycenl2' `Axcol' `Aycoh' `Axcen'
*Overall line (if specified)
		if ((`use'[`i'])==5 & "`line'"=="" ) {
		  gph pen 5
		  local Adashl=`r5'*(`Gyhi'-1)/100
		  local Ayhi =`r5'*`Gyhi'+`r6' 
		  local j =`r5'+`r6'
		  while `j'>`Ayhi' { 
			local Aycol=`j'
			local Aycoh=`j'+`Adashl'
			gph line `Aycol' `Axcen' `Aycoh' `Axcen'
			local j=`j'+2*`Adashl'
		  }
		}

	   }
	 }
*use=9 => excluded, ignore (will have been sorted to bottom of data)

*Diamonds or boxes&lines are now drawn - put text on the end

	 if ( `use'[`i']==1 | `use'[`i']==3 | `use'[`i']==5 ) {
*put text at end of graph (if requested)
	   if "`stats'"=="" {
*effect sizes
		local e1=`effect'[`i']
		local e2=`lci'[`i']
		local e3=`uci'[`i']
*Make allowance for alignment where es<0
		local sp1
		if (`e1'>0) {local sp1 " "}
		local sp2
		if (`e2'>0) {local sp2 " "}
		local sp3
		if (`e3'>0) {local sp3 " "}
		if (`e1'<1e-8) & "`Glog'"!="" {local e1 "<10^-8"}
		 else if (`e1'>1e8) & (`e1'!=.) & "`Glog'"!=""  {
		    local e1 ">10^8"
		 }
		 else { local e1: displ %4.2f `e1' }
		if (`e2'<1e-8) & ("`Glog'"!="" | "`cornfield'"!="") {
		    local e2 "<10^-8"
		 }
		 else if (`e2'>1e8) & (`e2'!=.) & "`Glog'"!=""  {local e2 ">10^8"}
		 else { local e2: displ %4.2f `e2' }
		if (`e3'<1e-8) & "`Glog'"!="" {local e3 "<10^-8"}
		 else if (`e3'>1e8) & (`e3'!=.) & ("`Glog'"!=""  | "`cornfield'"!="") {
		    local e3 ">10^8"
		 }
		 else { local e3: displ %4.2f `e3' }

		local esize "`sp1'`e1' (`sp2'`e2',`sp3'`e3')"
		gph text `Aytcen' `Axhi'  0 -1 `esize'
	   }
	   if "`wt'"=="" {
		local weit: displ %4.1f `wtdisp'[`i']
		if `weit'!=. { gph text `Aytcen' `Ax3hi' 0 1 `weit' }
	   }
	   if "`counts'"!="" {
		local nm: displ `rawdata'[`i']
		if "`nm'"!="." {
		   parse "`nm'" , parse(";")
		   local nm1 "`1'"
		   local nm2 "`3'"
		   gph text `Aytcen' `Ax2hi1'  0 1 `nm1'
		   gph text `Aytcen' `Ax2hi2'  0 1 `nm2'
		}
	   }
	 }
	 if `use'[`i']==2 & "`stats'"=="" {
	   gph text `Aytcen' `Axhi'  0 -1 (Excluded)
	   if "`counts'"!="" {
		local nm: displ `rawdata'[`i']
		if "`nm'"!="." {
		   parse "`nm'" , parse(";")
		   local nm1 "`1'"
		   local nm2 "`3'"
		   gph text `Aytcen' `Ax2hi1'  0 1 `nm1'
		   gph text `Aytcen' `Ax2hi2'  0 1 `nm2'
		}
	   }
	 }
	local i=`i'+1 
	} 


	gph close
    }  /* end of qui section*/
    #delimit ;
    if `flag1'>1 { di in bl _n "Note: invalid xlabel() or xtick(): graph has been rescaled"};
    if `flag2'>1 { di in bl _n "Warning: Some trials cannot be
represented graphically (may contain" _n "inestimable effects).  Consider using different xlabel()"};
    if `flag3'>1 { di in bl _n "Warning: Overall (or subgroup) effect size not fully 
represented graphically." _n "Consider using xlabel()"};
    #delimit cr
end

exit

Revision history
*Log option added: can display Log(ORs,RRs) on table & graph. 
*graph appears when only 1 trial.
*nomenclature for _ES changed when OR or RR selected
*std err of estimate /log est in saved results is renamed and labelled so is clearer
*can handle 2 variables (ES, seES), exponentiated with new eform option
*Max label length for table is now 20chrs 
*Breslow Day test for OR heterogeneity added
*Can display n/N for trials, with and without weights/stats.
*Groups can be labelled when using the counts option with group1() and group2() 
*User-defined weight option:
* - can't use with fixed or random option
* - metan ... , wgt(wt) == metan ... , fixedi if wt=1/v ie IV weighting 
* - however will differ if RE: 
* -  no tau2 involved in weights ie variance est differs: wgt=1/(vi+t) but SIGMA{1/wgt}=/= SIGMA{wi^2 * var(thetai) }/[SIGMA(wi)]^2
* -  pooled ES=SIGMA{wgt*es}/SIGMA{wgt} =/= FE weighted, so heterogeneity not equal
*Can plot the ES alone without the box (nobox) 
*Option to change "Study" label to something else
*Display a bit nicer (table formatted 3 rather than up to 7 dec places)
*Removed "Study -" from top; by default is replaced with "Study". Annoying "tick" next to it removed
*Added I^2 (Higgins & Thompson 2003) 
*xtick, b2title options added can add "Favours ..." below graph with prefix and asterisk in b1(*I: .... * ....)
*Nointeger: allows sample size to be non-integer if requested.
*Adding continuity correction: currently allows user-defined const (or via nointeger opt)
*r(sumstat) now displays with S/WMD (did forget to was long standing bug)
*by() option added!!!
*r(tger) and r(cger) corrected from prev by() versions; overall ERs were not reported (were from the last by subg)
*bug with by() removed: wasn't keeping _ES etc
*allows CI syntax (3 variables: theta lower_limit upper_limit), BUT:
* - does not follow "meta" syntax, ie does not assume log transform needed
* - default is to assume symmetry and calculate se=0.5*(upper-lower)/z, but allows asymmetry
* - bug with udw and missing data fixed 1Mar04
*minor bugs fixed: trial labelling with by() on table,  extended line to right of graph with 
*options nostats nowt counts all specified, sortby w/o by() option, junk text if by() subgroup 
*contained no informative trials, erroneous lack of overall summary on graph in some situations.

