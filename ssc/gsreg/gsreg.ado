*===============================================================================================*
* GSREG: global search regressions																*
* Authors:																						*
* Pablo Gluzmann, CEDLAS-UNLP and CONICET - La Plata, Argentina - gluzmann@yahoo.com			*
* Demian Panigo, CEIL-CONICET, UNM and UNLP - La Plata, Argentina - dpanigo@ceil-conicet.gov.ar	*
*-----------------------------------------------------------------------------------------------*
* Version 1.1 - 23-11-2013																		*
* DNDA Exp. 5137544																				*
*===============================================================================================*
program define gsreg, eclass 
version 11.0
qui {
	syntax varlist(min=2) [aw fw iw pw] [if] [in] , [NComb(numlist >=0 integer max=2) Fixvar(varlist) FIXINTeractions Lags(numlist >0 integer) DLags(numlist >0 integer) ILags(numlist >0 integer) SChange(varname) INTeractions SQuares CUBic Outsample(integer 0) CMDEst(string) CMDOptions(string) CMDStat(string) CMDIveq(string) AICbic HETtest hettest_o(string) ARChlm archlm_o(string) BGODdfrey bgodfrey_o(string) DURbinalt durbinalt_o(string) DWatson SKtest sktest_o(string) SWilk swilk_o(string) SFrancia RESultsdta(string) COMpact TESTpass(numlist >0 <1 max=1 ) MIndex(string) NIndex(string) best(numlist >0 integer max=1 ) NOCOunt DOuble REPlace SAMESample VSelect Part(numlist >0 integer min=2 max=2) BACKup(numlist >0 integer min=1 max=1)]
	if "`weight'`exp'"!="" loc weight =" [`weight'`exp'] "
	if "`vselect'"!="" {
		noi di as text "Warning: vselect command must be previously installed if vselect option is specified"
		
		if "`ncomb'"!="" | "`fixinteractions'"!=""  | "`lags'"!=""  | "`dlags'"!=""  | "`ilags'"!=""  | "`schange'"!=""  | "`interactions'"!=""  | "`squares'"!=""  | "`cubic'"!=""  | "`outsample'"!="0"  | "`cmdest'"!=""  | "`cmdoptions'"!="" | "`cmdiveq'"!="" | "`cmdstat'"!=""  | "`aibic'"!="" | "`hettest'"!=""  | "`hettest_o'"!="" | "`archlm'"!=""  | "`archlm_o'"!=""  | "`bgodfrey'"!=""  | "`bgodfrey_o'"!=""  | "`durbinalt'"!=""  | "`durbinalt_o'"!=""  | "`dwatson'"!=""  | "`sktest'"!=""  | "`sktest_o'"!=""  | "`swilk'"!=""  | "`swilk_o'"!=""  | "`sfrancia'"!=""  | "`resultsdta'"!=""  | "`compact'"!=""  | "`testpass'"!=""  | "`mindex'"!=""  | "`nindex'"!=""  | "`best'"!=""  | "`nocount'"!=""  | "`double'"!=""  | "`replace'"!=""  | "`samesample'"!="" | "`part'"!="" | "`backup'"!=""  {
			di as error "Only fixvar option is allowed with vselect option"
			exit 198
		}		
		noi vselect `varlist' `weight' `if' `in' , best fix(`fixvar')
		exit
	}
	tempvar touse
	mark `touse' `if' `in' 
        capture tsset
	loc time=r(timevar)
	loc panel=r(panelvar)
	if "`time'"=="." loc time=""
	if "`panel'"=="." loc panel=""
	if (`outsample'>0 & `outsample'<. & "`time'"=="") {
			display as error "time variable not set"
			exit 111
	}
	if "`resultsdta'"=="" loc resultsdta "gsreg"
	if "`nindex'"=="" & "`mindex'"=="" loc nindex ="r_sqr_a"
	if "`cmdest'"=="" loc cmdest = "regress"
	if "`fixvar'"!="" {
		loc aux=0
		foreach var1 of varlist `fixvar'  {
			foreach var2 of varlist `varlist' `schange' {
				if "`var1'"=="`var2'" loc aux =1
			}
		}
		if `aux' ==1 {
		display as error "Option fixvar contains at last one variable already included in estimation"
		exit 503
		}
	}
	if "`schange'"!="" {
		loc aux=0
		foreach var1 of varlist `schange'  {
			foreach var2 of varlist `varlist'  {
				if "`var1'"=="`var2'" loc aux =1
			}
		}
		if `aux' ==1 {
		display as error "Variable included in option schange can not be included as regressor"
		exit 503
		}
	}
	if "`cubic'"!="" & "`squares'"=="" {
		display as error "Option cubic not allowed without squares option"
		exit 198
	}
 	if "`squares'"!="" & "`interactions'"=="" {
		loc interactions ="interactions"
		loc sqonly ="sqonly"
	}
	if "`mindex'"!="" & "`nindex'"!="" {
		display as error "mindex and nindex options are not allowed together"
		exit 198
	}
	if "`mindex'"!="" & "`best'"=="" {
		display as error "mindex not allowed without best option"
		exit 198
	}
	if "`best'"!="" & "`mindex'"=="" {
		display as error "best not allowed without mindex option"
		exit 198
	}
	if "`fixinteractions'"!="" & "`fixvar'"=="" {
		display as error "fixinteractions not allowed without fixvar option"
		exit 198
	}
	if "`part'"!="" & "`backup'"!="" {
		display as error "part and backup options are not allowed together"
		exit 198
	}
	if "`part'"!="" {
		*********************************
		tokenize `part'	
		*********************************
		loc part_div `1'
		loc part_tot `2'
		if `part_div'>`part_tot' {
			display as error "part() invalid, elements out of order"
			exit 124
		}
	}
	preserve
	tempname aux
	tempvar var1
	drop _all
	set obs 1
	gen `var1' =1
	capture save "`resultsdta'`aux'.dta", replace
	replace `var1' =2
	sum `var1' , mean
	loc a=r(mean)
	capture use "`resultsdta'`aux'.dta", clear
	capture sum `var1', mean
	loc a=r(mean) 
	if `a'!=1 & "`resultsdta'"=="gsreg" {
		display as error "stata cannot save files in the working directory, change the working directory using command cd or specify another path using option resultsdta"
		exit 603
	}
	if `a'!=1 & "`resultsdta'"!="gsreg" {
		display as error "stata cannot save files in the working directory or the path specified in option resultsdta, change the working directory using command cd or specify another path using option resultsdta"
		exit 603
	}
	capture erase "`resultsdta'`aux'.dta"
	drop _all
	if "`replace'"=="" {
		if "`compact'"!="" save "`resultsdta'_labels.dta", emptyok
		if "`part'" =="" save "`resultsdta'.dta", emptyok
	}
	restore

	local wt : word 2 of `exp'
	tokenize `varlist'	
	loc depvar "`1'"
	macro shift 1
	loc indepvar "`*'"
	if "`lags'"!="" {
		loc depvarlag =""
		loc indepvarlag  =""
		foreach n of numlist `lags' {
			loc depvarlag "`depvarlag' L`n'.`depvar'"
			foreach var of local indepvar {
				loc indepvarlag "`indepvarlag' L`n'.`var'"
			}
		}
	}
	if "`dlags'"!="" {
		loc depvarlag =""
		foreach n of numlist `dlags' {
			loc depvarlag "`depvarlag' L`n'.`depvar'"
		}
	}
	if "`ilags'"!="" {
		loc indepvarlag  =""
		foreach n of numlist `ilags' {
			foreach var of local indepvar {
				loc indepvarlag "`indepvarlag' L`n'.`var'"
			}
		}
	}
	if "`ncomb'" == "" {
		loc allcomb: word count `varlist'
		loc allcomb = `allcomb'-1
		loc ncomb ="1 `allcomb'"
		if "`fixvar'"!="" {
			loc ncomb ="0 `allcomb'"
		}
	}
	local none: word 1 of `ncomb'
	if `none' == 0 {
		if "`fixvar'"=="" {
			display as error "Combinatory 0 not allowed without fixvar"
			exit 198
		}
		local aux: word 2 of `ncomb'
		loc ncomb ="1 `aux'"
			
	}
	tokenize `ncomb'	
	loc kmin `1'
	if "`2'"!="" loc kmax `2'
	if "`2'"=="" loc kmax `1'
	if `kmin'>`kmax' {
		display as error "ncomb() invalid, elements out of order"
		exit 124
	}
	loc lista_comb1 "`indepvar' `indepvarlag' `depvarlag'"
	loc tindep : word count `lista_comb1'
	loc orden_var1 "`fixvar' `indepvar' `indepvarlag' `depvarlag' "
	if "`samesample'"!="" {
		tempvar aux
		gen `aux'=0 if `touse' ==1
		foreach var of varlist `orden_var1' `schange' {
			replace `aux'=1 if `touse' ==1 & `var'>=. 
		}
		replace `touse' =0 if `aux' ==1
	}
	loc lista_fixint "`lista_comb1'"
	foreach var1 of local lista_comb1 {
		if "`squares'"!="" loc lista1 "`lista1' c.`var1'#c.`var1'"
		if "`cubic'"!="" loc lista2 "`lista2' c.`var1'#c.`var1'#c.`var1'"
		if "`interactions'"!="" & "`sqonly'"=="" {		
			foreach var2 of local lista_comb1 {
				if "`var1'"!="`var2'" loc lista3 "`lista3' c.`var1'#c.`var2'"
			}
		}
		if "`schange'"!="" loc lista4 "`lista4' c.`schange'#c.`var1'"
		if "`fixinteractions'"!="" {		
			foreach fix of local fixvar {
				loc lista8 "`lista8' c.`var1'#c.`fix'"
			}		
		}		
	}
	if "`schange'"!="" &  "`squares'"!=""  {		
		foreach var1 of local lista1 {
			loc lista5 " `lista5' c.`schange'#`var1'"
		}
	}
	if "`schange'"!="" &  "`cubic'"!=""  {		
		foreach var1 of local lista2 {
			loc lista6 " `lista6' c.`schange'#`var1'"
		}
	}
	if "`schange'"!="" &  "`interactions'"!="" & "`sqonly'"==""  {		
		foreach var1 of local lista3 {
			loc lista7 " `lista7' c.`schange'#`var1'"
		}
	}
	if "`schange'"!="" & "`fixinteractions'"!="" {		
		foreach var1 of local lista8 {
			loc lista9 " `lista9' c.`schange'#`var1'"
		}
	}
	loc orden_var1 "`orden_var1' `lista1' `lista2' `lista3' `lista4' `lista5' `lista6' `lista7' `lista8' `lista9' `schange'"
	if "`cmdiveq'"!=""  {
			_iv_parse `depvar' (`cmdiveq')
			loc instruments "`s(inst)'"
			loc endogenous "`s(endog)'"

	}
	if "`instruments'"!="" & "`endogenous'"!="" {
		foreach var1 of local endogenous {
			local orden_var1: subinstr local orden_var1 "`var1'" "", word
		}
		loc orden_var1 "`endogenous' `orden_var1'"
	}
	loc Ntotreg=0
	loc total=0
	forvalues j=`kmin'/`kmax' {
		loc n1 =0
		loc n2 =0
		loc n3 =0
		loc n4 =0
		loc n4_1 =0
		loc n5 =0
		loc n1=comb(`tindep',`j')
		if "`fixinteractions'"!="" {
			local naux1: word count `fixvar'
			local naux2 =`j'*`naux1'
			forvalues int =1/`naux2' {
				loc naux3 =comb(`naux2',`int')
				loc n5 =`n5'+`naux3'
			}
		}
		if "`interactions'"!=""  {
			if "`squares'"!="" {
				mata aux=factorial(`j'+2-1) / (factorial(2)*factorial(`j'-1))
				mata st_numscalar("naux", aux)
				loc aux=naux
				if `j'!=1 loc aux2= `aux' - comb(`j',2)
				if `j'==1 loc aux2= 1
				if "`sqonly'"=="" & `j'!=1 loc aux3= comb(`j',2)
			}
			if "`sqonly'"!="" & `j'!=1 {
				loc aux= `aux' - comb(`j',2)
			}				
			if "`squares'"=="" {
				loc aux=comb(`j',2)
			}
			if "`squares'"!="" | ("`squares'"=="" & `j' !=1) {
				forvalues int =1/`aux' {
					loc naux=comb(`aux',`int')
					loc n2 =`n2'+`naux'
				}
			 }
			if "`squares'"=="" & `j' ==1 loc n2 =0
			if "`cubic'"!="" {
				forvalues int =1/`aux2' {
					loc naux1=comb(`aux2',`int')
					loc naux2=0
					forvalues int2 =1/`int' {
						loc naux2=`naux2'+comb(`int',`int2')
					}
					loc n4 =`n4'+`naux1'*`naux2'
				}
				loc naux3=0
				if "`sqonly'"=="" & `j' !=1 {
					forvalues int =1/`aux3' {
						loc naux3=`naux3'+comb(`aux3',`int')
					}
				}	
					loc n2=`n2'+`n4'*(`naux3'+1)
			}
		}
		if "`schange'"!="" {
			forvalues i=1 /`j' {
				loc aux=comb(`j',`i')
				loc n3 =`n3'+`aux'
			}
			loc n3 =`n3'*2
		}
		loc total = `total'+`n1'*(`n2'+1)*(`n3'+1)*(`n5'+1)
	}
	if `none' ==0 loc total = `total'+1
	if `total'<=0 | `total' >=. {
		display as error "Too few independent variables (or lags) specified for selected combinatorial"
		exit 198
	}
	noi di as text "----------------------------------------------------"
	noi di as text "Total Number of Estimations: " as result "`total'"
	noi di as text "----------------------------------------------------"
	if "`part'"!="" {
		if `part_tot'>`total' {
		noi di as text "The number of partitions is greater than the number of estimates"
		noi di as text "The number of partitions reset to " as result "`total'"
			loc part_tot =`total'
			if `part_div'>`part_tot' loc part_div=`part_tot' 
		}
		loc part_0_fin=0
		forvalues h=1/`part_tot' {
			loc h_1=`h'-1
			loc part_`h'_ini=`part_`h_1'_fin'+1
			loc part_`h'_fin=round((`h'/`part_tot')*`total',1)
		}
		loc part_`part_tot'_fin = `total'
		noi di as text "Part "as result "`part_div'" as text " of " as result "`part_tot'"
		noi di as text "Estimations "as result "`part_`part_div'_ini'" as text " to " as result "`part_`part_div'_fin'"
		noi di as text "----------------------------------------------------"
	}
	if "`backup'"!="" {
		if `backup'>`total' {
		noi di as text "The number of partitions is greater than the number of estimates"
		noi di as text "The number of partitions reset to " as result "`total'"
			loc backup =`total'
		}
		loc part_tot =`backup'
		loc part_0_fin=0
		forvalues h=1/`part_tot' {
			loc h_1=`h'-1
			loc part_`h'_ini=`part_`h_1'_fin'+1
			loc part_`h'_fin=round((`h'/`part_tot')*`total',1)
		}
		loc part_`part_tot'_fin = `total'
	}
	loc estcomoptions "cmde(`cmdest') cmdoptions(`cmdoptions') cmdstat(`cmdstat') resultsdta(`resultsdta') outsample(`outsample') `aicbic' `hettest' hettest_o(`hettest_o') `archlm' archlm_o(`archlm_o') `bgodfrey' bgodfrey_o(`bgodfrey_o') `durbinalt' durbinalt_o(`durbinalt_o') `dwatson' `sktest' sktest_o(`sktest_o') `swilk' swilk_o(`swilk_o') `sfrancia' `compact' testpass(`testpass') mindex(`mindex') best(`best') lastreg(`total') `double' `nocount' time(`time') panel(`panel') instruments(`instruments') endogenous(`endogenous') " 
	local hh1 : word count `fixvar'
	if "`squares'"!=""	loc hh1 =`hh1' + `kmax'
	if "`cubic'"!=""	loc hh1 =`hh1' + `kmax'
	if "`interactions'"!="" & "`sqonly'"=="" loc hh1 =`hh1' + `kmax'
	if "`fixinteractions'"!="" loc hh1 =`hh1' + `kmax'
	if "`schange'"!="" loc hh1 =`hh1' + 1
	if "`schange'"!="" &  "`squares'"!="" loc hh1 =`hh1' + `kmax'
	if "`schange'"!="" &  "`cubic'"!=""  loc hh1 =`hh1' + `kmax'
	if "`schange'"!="" &  "`interactions'"!="" & "`sqonly'"=="" loc hh1 =`hh1' + `kmax'
	if "`schange'"!="" & "`fixinteractions'"!="" loc hh1 =`hh1' + `kmax'
	local hh2 : word count `orden_var1'
	loc hh=1
	if `hh2'>`kmax'+`hh1' {
		foreach var of local orden_var1 {
			if `hh'<=(`kmax'+`hh1') loc listaaux "`listaaux' `var'"
			loc ++hh
		}
	}
	else loc listaaux "`orden_var1'"
	timer clear 99
	timer on 99
	capture estcomtry `depvar' `listaaux' `weight' if `touse' ==1 , `estcomoptions' ordenvar(`orden_var1') nroreg(`Ntotreg') 
	timer off 99
	timer list
	ret li
	loc time1 = r(t99)
	loc timeprox =round((`time1'*`total')/50)
	if `timeprox'>=1 {
		noi di as text "----------------------------------------------------"
		noi di as text "Warning: Estimation could take about " as result "`timeprox'" as text " minutes "
		noi di as text "----------------------------------------------------"
	}
	if `timeprox'>3 {
		noi more
		noi di as text " "
	}	
	noi di as text "Computing combinations..."
	forvalues combaux=1/`kmax' {
		tempfile __a_`combaux'
		loc __a_ "`__a_' `__a_`combaux''"
	}
	combinate `__a_', nsamp(`tindep') ncomb(`kmin',`kmax')
	noi di as text "Preparing regression list..."
	if `none' ==0 loc ++Ntotreg
	if `none' ==0 loc regress`Ntotreg' "" 
	tokenize `lista_comb1' 
	forvalues j=`kmin'/`kmax' {
		preserve
		use `__a_`j'', clear
		erase `__a_`j''
		loc v=_N
		loc v1 ="`"
		loc v2 ="'"
		d _all
		forvalues i =1/`v' {
			macro drop _reg`i' 
			foreach var of varlist _all {
				loc vaux = `var'[`i']
				loc reg`i'= " `reg`i'' `v1'`vaux'`v2' "
			}
		}
		restore
		forvalues i =1/`v' {
			loc ++Ntotreg
			loc regress`Ntotreg' "`reg`i''" 
			if "`fixinteractions'"!="" {
				loc lf ""
				foreach var1 of local reg`i' {
					foreach fix of local fixvar {
						loc lf "`lf' c.`var1'#c.`fix'"
					}
				}
				loc nlf: word count `lf'
				loc __f_ =""
				forvalues combaux=1/`nlf' {
					tempfile __f_`combaux'
					loc __f_ "`__f_' `__f_`combaux''"
				}
				combinate `__f_', nsamp(`nlf') ncomb(1,`nlf')
				
				loc n=1
				foreach nn of local lf {
					loc lf_`n' "`nn'"
					loc ++n
				}
				loc countlf =1
				forvalues nlf1 =1/`nlf' {
					preserve
					use "`__f_`nlf1''", clear
					erase "`__f_`nlf1''"
					loc R=_N
					forvalues hh =1/`R' {
						loc lff ""
						foreach var of varlist _all {
							loc vaux = `var'[`hh']
							loc lff = " `lff' `lf_`vaux''"
						}
						loc lff_`hh' "`lff'"
					}
					restore
					forvalues hh =1/`R' {
						loc ++Ntotreg
						loc regress`Ntotreg' "`reg`i'' `lff_`hh''" 
						loc intfixlist_`countlf' "`lff_`hh''" 
						loc ++countlf 
					}
				}
				loc totlf =`countlf'-1
			}

			if "`interactions'"!=""  {
				loc __c_ ""
				forvalues combaux=1/2 {
					tempfile __c_`combaux'
					loc __c_ "`__c_' `__c_`combaux''"
				}
				if "`squares'"!="" combinate `__c_', nsamp(`j') ncomb(2,2) reps
				if "`squares'"=="" combinate `__c_', nsamp(`j') ncomb(2,2) 
				loc token=1
				foreach tokenvar of local reg`i' {
					loc c_`token' ="`tokenvar'"
					loc ++token
				}
				preserve
				clear
				use "`__c_2'", clear
				erase "`__c_2'"
				if "`sqonly'"!="" drop if aux1!=aux2
				loc c1v=_N
				loc c1reg ""
				loc cubreg ""
				loc poscuadreg =""
				forvalues c1i =1/`c1v' {
					loc vaux1 = aux1[`c1i']
					loc vaux2 = aux2[`c1i']
					loc c1reg " `c1reg' c.`v1'c_`vaux1'`v2'#c.`v1'c_`vaux2'`v2'  "
					if "`cubic'" !="" {
						if "`vaux1'" == "`vaux2'" loc cubreg " `cubreg' c.`v1'c_`vaux1'`v2'#c.`v1'c_`vaux1'`v2'#c.`v1'c_`vaux1'`v2'"
						if "`vaux1'" == "`vaux2'" loc poscuadreg "`poscuadreg' `c1i'"
					}
				}
				loc c1zreg="`c1reg'"
				restore
				loc tc1 : word count `c1reg'
				loc __d_ ""
				forvalues combaux=1/`tc1' {
					tempfile __d_`combaux'
					loc __d_ "`__d_' `__d_`combaux''"
				}
				if "`squares'"!="" | ("`squares'"=="" & `j' !=1)  combinate `__d_', nsamp(`tc1') ncomb(1,`tc1') 
				loc token=1
				foreach tokenvar of local c1reg {
					loc d_`token' ="`tokenvar'"
					loc ++token
				}
				forvalues k=1/`tc1' {
					preserve
					clear
					use "`__d_`k''", clear
					loc c2v=_N
					forvalues c2i =1/`c2v' {
						loc c2reg`c2i' ""
						loc cubc2reg`c2i' ""
						foreach var of varlist _all {
							loc vaux = `var'[`c2i']
							loc c2reg`c2i'= " `c2reg`c2i'' `v1'd_`vaux'`v2' "
							if "`cubic'" !="" {
								loc ncub1=1
								foreach cubvar of local cubreg {
									loc ncub2 =1
									foreach cub of numlist `poscuadreg' {
										if `ncub1' == `ncub2' & `cub' == `vaux' loc cubc2reg`c2i' " `cubc2reg`c2i'' `cubvar'"
										loc ++ncub2 
									}
									loc ++ncub1
								}
							}
						}
					}
					restore
					forvalues c2i =1/`c2v' {
						loc c2zreg`k'_`c2i' = "`c2reg`c2i''" 
						loc cubc2zreg`k'_`c2i' = "`cubc2reg`c2i''" 
						loc ++Ntotreg
						loc regress`Ntotreg' "`reg`i'' `c2reg`c2i''" 
						if "`fixinteractions'"!="" {
							forvalues countlf=1/`totlf' {
								loc ++Ntotreg
								loc regress`Ntotreg' "`reg`i'' `c2reg`c2i'' `intfixlist_`countlf''" 
							}
						}
						if "`cubic'" !="" & "`cubc2reg`c2i''"!="" {
							loc ncub: word count `cubc2reg`c2i''
							if `ncub' ==1 {
								loc ++Ntotreg
								loc regress`Ntotreg' "`reg`i'' `c2reg`c2i'' `cubc2reg`c2i''" 
								if "`fixinteractions'"!="" {
									forvalues countlf=1/`totlf' {
										loc ++Ntotreg
										loc regress`Ntotreg' "`reg`i'' `c2reg`c2i'' `cubc2reg`c2i'' `intfixlist_`countlf''" 
									}
								}
							}
							if `ncub' >=2 {
								loc __e_ ""
								forvalues combaux=1/`ncub' {
									tempfile __e_`combaux'
									loc __e_ "`__e_' `__e_`combaux''"
								}
								combinate `__e_', nsamp(`ncub') ncomb(1,`ncub') 
								forvalues m=1/`ncub' {
									preserve
									clear
									use "`__e_`m''", clear
									erase "`__e_`m''"
									loc c3v=_N
									loc c3v_`k'_`m'_`c2i'_`c3i' =`c3v'
									forvalues c3i =1/`c3v' {
										loc n=1
										foreach nn of local cubc2reg`c2i' {
											loc nn_`n' "`nn'"
											loc ++n
										}
										loc cub_`c2i'_`c3i' ""
										foreach var of varlist _all {
											loc vaux = `var'[`c3i']
											loc cub_`c2i'_`c3i' = " `cub_`c2i'_`c3i'' `nn_`vaux''"
										}
									}
									restore
									forvalues c3i =1/`c3v' {
										loc cubz_`k'_`m'_`c2i'_`c3i' = "`cub_`c2i'_`c3i''" 
										loc ++Ntotreg
										loc regress`Ntotreg' "`reg`i'' `c2reg`c2i'' `cub_`c2i'_`c3i''" 
										if "`fixinteractions'"!="" {
											forvalues countlf=1/`totlf' {
												loc ++Ntotreg
												loc regress`Ntotreg' "`reg`i'' `c2reg`c2i'' `cub_`c2i'_`c3i'' `intfixlist_`countlf'' " 
											}
										}
										
									}
								}
							}
						}
					}
				}
			}
			if "`schange'"!="" {
				loc listacomb_2 =""
				foreach var of local reg`i' {
					loc listacomb_2 "`listacomb_2' c.`schange'#c.`var'"
				}
				loc token=1
				foreach tokenvar of local listacomb_2 {
					loc b_`token' ="`tokenvar'"
					loc ++token
				}

				loc __b_ ""
				forvalues combaux=1/`j' {
					tempfile __b_`combaux'
					loc __b_ "`__b_' `__b_`combaux''"
				}
				combinate `__b_', nsamp(`j') ncomb(1,`j') 

				forvalues k=1/`j' {
					preserve
					clear
					use "`__b_`k''", clear
					erase "`__b_`k''"
					loc zv=_N
					forvalues zi =1/`zv' {
						loc zreg`zi' ""
						foreach var of varlist _all {
							loc vaux = `var'[`zi']
							loc zreg`zi'= " `zreg`zi'' `v1'b_`vaux'`v2' "
						}
					}

					restore
					forvalues zi =1/`zv' {
						loc ++Ntotreg
						loc regress`Ntotreg' "`reg`i'' `zreg`zi''" 
						if "`fixinteractions'"!="" {
							forvalues countlf=1/`totlf' {
								loc sc_intfix_`zi'_`countlf' ""
								foreach aux of local reg`i' {
									foreach scvar of local zreg`zi' {
										if "c.`schange'#c.`aux'"=="`scvar'" {
											foreach fix1 of local fixvar {
												foreach fix2 of local intfixlist_`countlf' {
													if "`fix2'"=="c.`aux'#c.`fix1'" loc sc_intfix_`zi'_`countlf' "`sc_intfix_`zi'_`countlf'' `scvar'#c.`fix1'"
												}
											}
										}
									}
								}
								loc ++Ntotreg
								loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `intfixlist_`countlf'' `sc_intfix_`zi'_`countlf''" 
							}
						}

						loc ++Ntotreg
						loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `schange'" 
						if "`fixinteractions'"!="" {
							forvalues countlf=1/`totlf' {
								loc ++Ntotreg
								loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `intfixlist_`countlf'' `sc_intfix_`zi'_`countlf'' `schange'" 
							}
						}

						if "`interactions'"!=""  {
							forvalues k=1/`tc1' {
								preserve
								clear
								use "`__d_`k''", clear
								loc c2v=_N
								restore
								forvalues c2i =1/`c2v' {
									loc zregzreg_`c2i'=""
									foreach var of local c2zreg`k'_`c2i' {
										loc vaux="c.`schange'#`var'"
										loc zregzreg_`c2i' ="`zregzreg_`c2i'' `vaux'"
									}
									if "`cubic'" !="" {
										loc cubzregzreg_`c2i'=""
										foreach var of local cubc2zreg`k'_`c2i' {
											loc vaux="c.`schange'#`var'"
											loc cubzregzreg_`c2i' ="`cubzregzreg_`c2i'' `vaux'"
										}
									}
									loc ++Ntotreg
									loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i''" 
									if "`fixinteractions'"!="" {
										forvalues countlf=1/`totlf' {
											loc ++Ntotreg
											loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `intfixlist_`countlf'' `sc_intfix_`zi'_`countlf''" 
										}
									}
									if "`cubic'" !="" & "`cubc2zreg`k'_`c2i''"!="" {
										loc ncub: word count `cubc2zreg`k'_`c2i''
										if `ncub' ==1 {
											loc ++Ntotreg
											loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `cubc2zreg`k'_`c2i'' `cubzregzreg_`c2i''" 
											if "`fixinteractions'"!="" {
												forvalues countlf=1/`totlf' {
													loc ++Ntotreg
													loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `cubc2zreg`k'_`c2i'' `cubzregzreg_`c2i'' `intfixlist_`countlf'' `sc_intfix_`zi'_`countlf''" 
												}
											}
										}
										if `ncub' >=2 {
											forvalues m=1/`ncub' {
												loc c3v=`c3v_`k'_`m'_`c2i'_`c3i''
												forvalues c3i =1/`c3v' {
													loc cubz_aux ""
													foreach var of local cubz_`k'_`m'_`c2i'_`c3i' {
														loc vaux="c.`schange'#`var'"
														loc cubz_aux ="`cubz_aux' `vaux'"
													}
													
													loc ++Ntotreg
													loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `cubz_`k'_`m'_`c2i'_`c3i''  `cubz_aux'" 
													if "`fixinteractions'"!="" {
														forvalues countlf=1/`totlf' {
															loc ++Ntotreg
															loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `cubz_`k'_`m'_`c2i'_`c3i''  `cubz_aux' `intfixlist_`countlf'' `sc_intfix_`zi'_`countlf''" 
														}
													}
												
												}
											}
										}
									}
									loc ++Ntotreg
									loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `schange'" 
									if "`fixinteractions'"!="" {
										forvalues countlf=1/`totlf' {
											loc ++Ntotreg
											loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `intfixlist_`countlf'' `sc_intfix_`zi'_`countlf'' `schange'" 
										}
									}
									if "`cubic'" !="" & "`cubc2zreg`k'_`c2i''"!="" {
										if `ncub' ==1 {
											loc ++Ntotreg
											loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `cubc2zreg`k'_`c2i'' `cubzregzreg_`c2i'' `schange'" 
											if "`fixinteractions'"!="" {
												forvalues countlf=1/`totlf' {
													loc ++Ntotreg
													loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `cubc2zreg`k'_`c2i'' `cubzregzreg_`c2i'' `intfixlist_`countlf'' `sc_intfix_`zi'_`countlf'' `schange'" 
												}
											}
										}
										if `ncub' >=2 {
											forvalues m=1/`ncub' {
												loc c3v=`c3v_`k'_`m'_`c2i'_`c3i''
												forvalues c3i =1/`c3v' {
													loc cubz_aux ""
													foreach var of local cubz_`k'_`m'_`c2i'_`c3i' {
														loc vaux="c.`schange'#`var'"
														loc cubz_aux ="`cubz_aux' `vaux'"
													}
													loc ++Ntotreg
													loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `cubz_`k'_`m'_`c2i'_`c3i'' `cubz_aux' `schange' " 
													if "`fixinteractions'"!="" {
														forvalues countlf=1/`totlf' {
															loc ++Ntotreg
															loc regress`Ntotreg' "`reg`i'' `zreg`zi'' `c2zreg`k'_`c2i'' `zregzreg_`c2i'' `cubz_`k'_`m'_`c2i'_`c3i'' `cubz_aux' ``intfixlist_`countlf'' `sc_intfix_`zi'_`countlf'' schange' " 
														}
													}
												
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
			macro drop _reg_`i'
		}
	}

	noi di as text "Doing regressions..."
	if "`backup'"!="" loc tback =`backup'
	if "`backup'"=="" loc tback =1
	forvalues back=1/`tback' {
		if "`part'"=="" {
			loc ini=1
			loc fin=`Ntotreg'
		}
		if "`backup'"!="" loc part_div= `back'
		if "`part'"!="" | "`backup'"!="" {
			loc ini=`part_`part_div'_ini'
			loc fin=`part_`part_div'_fin'
		}
		loc nopt =round(sqrt(`fin'-`ini'),1)
		if 	`nopt' <=100 loc nopt =100
		loc samemindex =0
		loc kk=1
		loc totS=0
		forvalues i=`ini'/`fin' {
			tempfile res_`i'
			noi estcom `depvar' `fixvar' `regress`i'' `weight' if `touse' ==1 , `estcomoptions' ordenvar(`orden_var1') nroreg(`i') resn(`res_`i'')
			if `i'== (`ini'-1)+`nopt'*`kk' {
				preserve
				clear
				tempfile  resS_`kk'
				loc ini2=`ini'+`nopt'*(`kk'-1)
				forvalues k=`ini2'/`i' {
					capture append using `res_`k''
					capture erase `res_`k''
					count 
					if r(N)==0 & "`testpass'"!="" continue
					if "`best'"!="" & "`mindex'"!="" {
						count
						loc nbest=r(N)
						if (`nbest'>`best') {
							capture drop mindex 
							loc aux: word count `mindex'
							if `aux' ==1 {
								sum `mindex'
								if "`double'" !="" gen double mindex =(`mindex'-r(mean))/r(sd)
								if "`double'" =="" gen mindex =(`mindex'-r(mean))/r(sd)
							}
							if `aux' >1 {
								if "`double'" !="" gen double mindex =0
								if "`double'" =="" gen mindex =0
								forvalues i = 1(2)`aux' {
									local aux1: word `i' of `mindex'
									loc j=`i' +1
									local aux2: word `j' of `mindex'
									sum `aux2'
									loc mean=r(mean)
									loc sd=r(sd)
									gen naux=(`aux2'-`mean')/`sd'
									replace mindex=mindex+`aux1'*naux if naux !=.
									drop naux
								}
							}
							tempvar mmindex
							sort mindex, stable
							if mindex[1]==mindex[2] loc samemindex= `samemindex'+1
							drop if _n==1
						}
					}
				}
				save `resS_`kk'', replace
				restore
				macro drop _res_*
				loc ++kk
				loc totS=`kk'-1
			}
		}
		noi di as text "Saving results..."
		preserve
		clear
		forvalues i=1/`totS' {
			capture append using `resS_`i''
			capture erase `resS_`i''
			count 
			if r(N)==0 & "`testpass'"!="" continue
			if "`best'"!="" & "`mindex'"!="" {
				count
				loc nbest=r(N)
				if (`nbest'>`best') {
					capture drop mindex 
					loc aux: word count `mindex'
					if `aux' ==1 {
						sum `mindex'
						if "`double'" !="" gen double mindex =(`mindex'-r(mean))/r(sd)
						if "`double'" =="" gen mindex =(`mindex'-r(mean))/r(sd)
					}
					if `aux' >1 {
						if "`double'" !="" gen double mindex =0
						if "`double'" =="" gen mindex =0
						forvalues i = 1(2)`aux' {
							local aux1: word `i' of `mindex'
							loc j=`i' +1
							local aux2: word `j' of `mindex'
							sum `aux2'
							loc mean=r(mean)
							loc sd=r(sd)
							gen naux=(`aux2'-`mean')/`sd'
							replace mindex=mindex+`aux1'*naux if naux !=.
							drop naux
						}
					}
					tempvar m_mindex
					gen `m_mindex'=-mindex
					sort `m_mindex', stable
						if `i'==`totS' {
							if mindex[_n]==mindex[_n+1] loc samemindex= `samemindex'+1
						}
					drop if _n>`best'
				}
			}
		}
		macro drop _resS_*
		loc faltan =(`fin'-`ini'+1)-(`totS'*`nopt')
		if `faltan'>0 {
			loc inifalta=`fin'-`faltan'+1
			forvalues i=`inifalta'/`fin' {
				capture append using `res_`i''
				capture erase `res_`i''
				count 
				if r(N)==0 & "`testpass'"!="" continue
				if "`best'"!="" & "`mindex'"!="" {
					count
					loc nbest=r(N)
					if (`nbest'>`best') {
						capture drop mindex 
						loc aux: word count `mindex'
						if `aux' ==1 {
							sum `mindex'
							if "`double'" !="" gen double mindex =(`mindex'-r(mean))/r(sd)
							if "`double'" =="" gen mindex =(`mindex'-r(mean))/r(sd)
						}
						if `aux' >1 {
							if "`double'" !="" gen double mindex =0
							if "`double'" =="" gen mindex =0
							forvalues i = 1(2)`aux' {
								local aux1: word `i' of `mindex'
								loc j=`i' +1
								local aux2: word `j' of `mindex'
								sum `aux2'
								loc mean=r(mean)
								loc sd=r(sd)
								gen naux=(`aux2'-`mean')/`sd'
								replace mindex=mindex+`aux1'*naux if naux !=.
								drop naux
							}
						}
						sort mindex, stable
						if "`i'"=="`fin'" {
							if mindex[1]==mindex[2] noi di "Warning: when sorting models by mindex the `best'th model and higher have the same value of mindex"
							if `samemindex'>0 noi di "Warning: when sorting models by mindex `samemindex' times the `best'th model and higher have the same value of mindex"
						}
						drop if _n==1
					}
				}
			}
			macro drop _res_*
		}
		loc i=1
		foreach var of local orden_var1 {
			capture label var v_`i'_b "`var' coeff."
			capture label var v_`i'_t "`var' tstat."
			loc ++i
		}
		capture label var v_cons_b "Constant coeff."
		capture label var v_cons_t "Constant tstat."
		label var order "Order number of estimation"
		label var obs "Observations"
		label var nvar "Number of regressors"
		label var r_sqr_a "Adjusted R-squared"
		label var rmse_in "RMSE in sample"
		if `outsample'!=0 {
			label var rmse_out "RMSE out of sample"
		}
		if "`aicbic'"!="" {
			label var aic "Akaike information criterion"
			capture label var aicc "Akaike information criterion corrected"
			label var bic "Bayesian information criterion"
		}
		if "`hettest'"!=""	label var hettest "pvalue of Breusch-Pagan / Cook-Weisberg test for heteroskedasticity"
		if "`archlm'"!="" {
			foreach var of varlist archlm* {
				local aux1 ="`var'"
				loc aux2: subinstr local aux1 "archlm" ""
				label var archlm`aux2' "pvalue of lag `aux2', LM test for autoregressive conditional heteroskedasticity (ARCH)"
			}
		}
		if "`bgodfrey'"!="" {
			foreach var of varlist bgodfrey* {
				local aux1 ="`var'"
				loc aux2: subinstr local aux1 "bgodfrey" ""
				label var bgodfrey`aux2' "pvalue of lag `aux2', Breusch-Godfrey LM test for autocorrelation"
			}
		}
		if "`durbinalt'"!="" {
			foreach var of varlist durbinalt* {
				local aux1 ="`var'"
				loc aux2: subinstr local aux1 "durbinalt" ""
				label var durbinalt`aux2' "pvalue of lag `aux2', Durbin's alternative test for autocorrelation"
			}
		}
		if "`dwatson'"!=""	label var dwatson "Durbin-Watson d-statistic"
		if "`sktest'"!=""	label var sktest "Pvalue of joint skewness and kurtosis test for normality of residuals"
		if "`swilk'"!=""	label var swilk "Pvalue of joint Shapiro-Wilk W test for normality of residuals"
		if "`sfrancia'"!=""	label var sfrancia "Pvalue of joint Shapiro-Francia W' test for normality of residuals"
		order v_*,  seq
		if "`part'" !="" | "`backup'" !="" {
			noi save "`resultsdta'_part_`part_div'_of_`part_tot'.dta", `replace'
			restore
			if "`part'" !="" exit
		}
	}
	if "`backup'" !="" {
		preserve
		drop _all
		forvalues back=1/`tback' {
			append using "`resultsdta'_part_`back'_of_`part_tot'.dta"
		}
	}
	count
	if r(N)==0 & "`testpass'"!="" {
		display as error "No estimations has passed the residual test specified"
		exit 
	}
	if r(N)==0  {
		display as error "No estimations has been stored"
		exit 
	}
	if "`mindex'"!="" {
		capture drop mindex
		loc aux: word count `mindex'
		if `aux' ==1 {
			sum `mindex'
			if "`double'" !="" gen double mindex =(`mindex'-r(mean))/r(sd)
			if "`double'" =="" gen mindex =(`mindex'-r(mean))/r(sd)
		}
		if `aux' >1 {
			if "`double'" !="" gen double mindex =0
			if "`double'" =="" gen mindex =0
			forvalues i = 1(2)`aux' {
				local aux1: word `i' of `mindex'
				loc j=`i' +1
				local aux2: word `j' of `mindex'
				sum `aux2'
				loc mean=r(mean)
				loc sd=r(sd)
				gen naux=(`aux2'-`mean')/`sd'
				replace mindex=mindex+`aux1'*naux if naux !=.
				drop naux
			}
		}
		label var mindex "Lineal combination index of selected normalized estimation"
	}
	if "`nindex'"!="" {
		loc aux: word count `nindex'
		if `aux' ==1 {
			sum `nindex'
			if "`double'" !="" gen double nindex =(`nindex'-r(mean))/r(sd)
			if "`double'" =="" gen nindex =(`nindex'-r(mean))/r(sd)
		}
		if `aux' >1 {
			if "`double'" !="" gen double nindex =0
			if "`double'" =="" gen nindex =0
			forvalues i = 1(2)`aux' {
				local aux1: word `i' of `nindex'
				loc j=`i' +1
				local aux2: word `j' of `nindex'
				sum `aux2'
				loc mean=r(mean)
				loc sd=r(sd)
				gen naux=(`aux2'-`mean')/`sd'
				replace nindex=nindex+`aux1'*naux if naux !=.
				drop naux
			}
		}
		label var nindex "Lineal combination index of selected normalized estimation"
	}
	if "`best'"!="" & "`nindex'"!="" {
		count
		loc aux=r(N)
		if `aux'>`best' {
			drop if nindex==.
			gsort -nindex +order
			if nindex[`best']==nindex[`best'+1] noi di "Warning: when sorting models by nindex the `best'th model and higher have the same value of nindex"
			drop if _n>`best'
		}
	}
	order v_*,  seq
	loc i=1
	foreach var of varlist v_*_b {
		capture ren `var' v_`i'_b 
		loc ++i
	}
	if "`compact'"=="" {
		loc i=1
		foreach var of varlist v_*_t {
			capture ren `var' v_`i'_t 
			loc ++i
		}
	}
	if "`compact'"!="" {
		tempfile foto
		save `foto', replace
		describe v_*, replace clear
		keep  position varlab
		label var position "Position of each variable in regressors indicator variable"
		ren varlab variable
		label var variable "Regressor variable used in each model"
		noi save "`resultsdta'_labels.dta", replace
		use `foto', clear
		egen regressors =concat( v_*_b )
		label var regressors "Order of regressors indicating witch variables are used in each model"
		drop v_*_b
	}
	order order, first
	if "`mindex'"!="" gsort -mindex +order
	if "`nindex'"!="" gsort -nindex +order
	if "`double'" !="" {
		capture format r_sqr_a rmse_in	%20.0g
		capture format rmse_out %20.0g
		capture format mindex %20.0g
		capture format nindex %20.0g
		if "`cmdstat'"!="" {
			foreach i of local cmdstat {
				capture format `i' %20.0g
			}
			
		}
	}
	compress
	if "`part'"=="" noi save "`resultsdta'.dta", replace
	if "`backup'" !="" {
		forvalues back=1/`tback' {
			erase "`resultsdta'_part_`back'_of_`part_tot'.dta"
		}
	}
	if "`compact'"!="" {
		keep if _n==1
		sum order , mean
		loc bestreg =r(mean)
		loc aux =length(regressors)-1
		forvalues i=1/`aux' {
			gen aux= substr(regressors,`i',1)
			loc aux`i'=aux
			drop aux
		}
		
		use "`resultsdta'_labels.dta", clear
		loc listabestreg ""
		forvalues i=1/`aux' {
			loc vaux = word(variable[`i'],1)
			if `aux`i''==1 loc listabestreg "`listabestreg' `vaux'"
		}
		restore
	}
	if "`compact'"=="" {
		keep if _n==1
		sum order , mean
		loc bestreg =r(mean)
		drop *_t
		keep v_*
		d 
		loc aux =r(k)-1
		forvalues i=1/`aux' {
			sum v_`i'_b
			loc aux`i'=r(N)
		}
		describe, replace clear
		loc listabestreg ""
		forvalues i=1/`aux' {
			loc vaux =word(varlab[`i'],1)
			if `aux`i''==1 loc listabestreg "`listabestreg' `vaux'"
		}
		restore
	}
	noi di as text "----------------------------------------------------"
	noi di as text "Best estimation in terms of `nindex'`mindex' "
	noi di as text "Estimation number " as result "`bestreg'"
	noi di as text "----------------------------------------------------"
	tempvar insample
	gen `insample' =1 if `touse'==1
	if `outsample'!=0 {
		sort `panel' `time'
		if "`panel'"=="" replace `insample' =0 if _n>_N-`outsample' & `touse'==1
		if "`panel'"!="" by `panel': replace `insample' =0 if _n>_N-`outsample' & `touse'==1
	}
	if "`instruments'"!="" {
		foreach var1 of local listabestreg {
			foreach var2 of local endogenous {
				if "`var1'" =="`var2'" loc ivendogenous " `ivendogenous' `var2' "
			}
		}
		foreach var1 of local ivendogenous {
			local listabestreg: subinstr local listabestreg "`var1'" "", word
		}
		loc estim: word 2 of `cmdest'
		if ("`ivendogenous'"!="" | "`estim'"=="gmm") noi `cmdest' `depvar' `listabestreg' (`ivendogenous' =`instruments') `weight' if `insample'==1, `cmdoptions'
		else noi `cmdest' `depvar' `listabestreg' `weight' if `insample' ==1, `cmdoptions'
	}
	else noi `cmdest' `depvar' `listabestreg' `weight' if `insample' ==1, `cmdoptions'
}
end

capture program drop combinate
program define combinate

	syntax anything ,NSamp(integer) NComb(numlist >0 integer max=2) [Reps]
	preserve
	tokenize `ncomb'
	loc kmin `1'
	if "`2'"!="" loc kmax `2'
	if "`2'"=="" loc kmax `1'
	tokenize `anything'
	clear
	set obs `nsamp'
	gen aux1=_n
	tempfile temp
	save `temp', replace
	if `kmin' ==1 {
		save "`1'", replace
		count
	}
	if `kmax' >=2 {
		loc lista_ant ="aux1 "
		tempfile foto
		save `foto', replace
		forvalues j=2/`kmax' {
			tempfile temp`j'
			ren aux aux`j'
			save `temp`j'', replace
		}
		use `foto', clear
		forvalues j=2/`kmax' {
			loc j_1 =`j'-1
			cross using `temp`j''
			if "`reps'" =="" drop if aux`j_1'>=aux`j'
			if "`reps'" !="" drop if aux`j_1'>aux`j'
			if `kmin'<=`j' {
				save "``j''", replace
				count
			}
		}
	}
	restore
end

capture program drop estcom
program define estcom
qui	{
	loc setmoreprev=c(more)
	set more off
	syntax anything [aw fw iw pw] [if], CMDEst(string) [CMDOptions(string) cmdstat(string)] resultsdta(string) ORdenvar(string) [nroreg(integer 0) Outsample(integer 0) compact aicbic hettest hettest_o(string) archlm  archlm_o(string) bgodfrey bgodfrey_o(string) durbinalt durbinalt_o(string) dwatson sktest sktest_o(string) swilk swilk_o(string) sfrancia testpass(numlist >0 <1 max=1 ) mindex(string) best(numlist >0 integer max=1 ) lastreg(integer 0) double NOCOunt time(string) panel(string) resn(string) instruments(string) endogenous(string) ] [*]
	loc weight "`weight'`exp'"
	if "`nocount'"=="" noi di as text "Estimation number " as result "`nroreg'" as text " of " as result "`lastreg'"
	tempvar touse
	mark `touse' `if' 
	tempvar insample
	gen `insample' =1 if `touse'==1
	if `outsample'!=0 {
		sort `panel' `time'
		if "`panel'"=="" replace `insample' =0 if _n>_N-`outsample' & `touse'==1
		if "`panel'"!="" by `panel': replace `insample' =0 if _n>_N-`outsample' & `touse'==1
	}
	if "`instruments'"!="" {
		foreach var1 of local anything {
			foreach var2 of local endogenous {
				if "`var1'" =="`var2'" loc ivendogenous " `ivendogenous' `var2' "
			}
		}
		loc anything2 "`anything'"
		foreach var1 of local ivendogenous {
			local anything2: subinstr local anything2 "`var1'" "", word
		}
		loc estim: word 2 of `cmdest'
		if ("`ivendogenous'"!="" | "`estim'"=="gmm") `cmdest' `anything2' (`ivendogenous' =`instruments') `weight' if `insample'==1, `cmdoptions'
		else `cmdest' `anything2' `weight' if `insample'==1, `cmdoptions'
	}
	else `cmdest' `anything' `weight' if `insample'==1, `cmdoptions'
	loc i=1
	loc b_ordenvar =""
	loc t_ordenvar =""
	foreach var1 of local ordenvar {
		foreach var2 of local anything {
			if "`var1'" =="`var2'" loc b_ordenvar "`b_ordenvar' v_`i'_b"
			if "`var1'" =="`var2'" loc t_ordenvar "`t_ordenvar' v_`i'_t"
		}
		loc ++i
	}
	tempname betas sigmas t
	mat `betas' =e(b) 
	mat `sigmas' =e(V)
	loc obs =e(N)
	loc rank =e(rank)
	if `rank' ==0 exit
	loc nvar =colsof(`betas')
	local r_sqr_a = e(r2_a) 
	local rmse_in = e(rmse) 
	mat `t' = `betas'
	forvalues i=1/`nvar'{
		mat `t'[1,`i'] = `betas'[1,`i'] / `sigmas'[`i',`i']^.5
	}
	if `outsample'!=0 {
		tempvar resout resout_sq 
		if "`cmdest'"=="xtreg" predict `resout' if `insample'==0, e  
		else predict `resout' if `insample'==0, res
		gen `resout_sq'= `resout'*`resout' 
		sum `resout_sq', mean
		tempname rmse_out
		mat `rmse_out' =( r(sum)/(`obs'-`nvar') )^.5	
		mat colnames `rmse_out' = rmse_out
	}
	if "`aicbic'"!="" {
		estat ic
		tempname aicbic
		mat `aicbic'=r(S)
		mat `aicbic'=`aicbic'[1,5],`aicbic'[1,6]
		mat colnames `aicbic' = aic bic 
		
	}
	if "`hettest'"!="" {
		estat hettest
		tempname hettest
		mat `hettest' =r(p)
		mat colnames `hettest' = hettest
	}
	if "`archlm'"!="" {
		loc lista ""
		estat archlm, `archlm_o'
		loc aux=r(lags)
		foreach i of local aux {
			loc lista "`lista' archlm`i'"
		}
		tempname archlm
		mat `archlm' =r(p)
		mat colnames `archlm' =`lista' 
	}
	if "`bgodfrey'"!="" {
		loc lista ""
		estat bgodfrey, `bgodfrey_o'
		loc aux=r(lags)
		foreach i of local aux {
			loc lista "`lista' bgodfrey`i'"
		}
		tempname bgodfrey
		mat `bgodfrey' =r(p)
		mat colnames `bgodfrey' =`lista' 
	}
	if "`durbinalt'"!="" {
		loc lista ""
		estat durbinalt, `durbinalt_o'
		loc aux=r(lags)
		foreach i of local aux {
			loc lista "`lista' durbinalt`i'"
		}
		tempname durbinalt
		mat `durbinalt' =r(p)
		mat colnames `durbinalt' =`lista' 
	}
	if "`dwatson'"!="" {
		estat dwatson
		tempname dwatson
		mat `dwatson' =r(dw)
		mat colnames `dwatson' = dwatson
	}
	if "`sktest'"!="" | "`swilk'"!="" | "`sfrancia'"!="" {
		tempvar resxt
		if "`cmdest'"=="xtreg" predict `resxt' if e(sample), e  
		else predict `resxt' if e(sample), res
		if "`sktest'"!="" {
			sktest `resxt' ,`sktest_o'
			tempname sktest1
			mat `sktest1' =r(P_chi2)
			mat colnames `sktest1' = sktest
		}
		if "`swilk'"!="" {
			swilk `resxt' ,`swilk_o'
			tempname swilk1
			mat `swilk1' =r(p)
			mat colnames `swilk1' = swilk
		}
		if "`sfrancia'"!="" {
			sfrancia `resxt' 
			tempname sfrancia1
			mat `sfrancia1' =r(p)
			mat colnames `sfrancia1' = sfrancia
		}
	}
	tempname mastermat
	mat `mastermat' = `betas',`t',`obs',`nvar',`r_sqr_a',`rmse_in'
	loc aux=colnumb(`betas',"_cons")
	if `aux'==.	mat colnames `mastermat'= `b_ordenvar' `t_ordenvar' obs nvar r_sqr_a rmse_in
	if `aux'!=.	mat colnames `mastermat'= `b_ordenvar' v_cons_b `t_ordenvar' v_cons_t obs nvar r_sqr_a rmse_in
	if "`cmdstat'"!="" {
		foreach i of local cmdstat {
			tempname aux
			mat `aux'=e(`i')
			mat colnames `aux'= `i'
			mat `mastermat'=`mastermat',`aux'
		}
	}
	if `outsample'!=0	mat `mastermat' =`mastermat',`rmse_out'
	if "`aicbic'"!=""	mat `mastermat' =`mastermat',`aicbic'
	if "`hettest'"!=""	mat `mastermat' =`mastermat',`hettest'
	if "`archlm'"!=""	mat `mastermat' =`mastermat',`archlm'
	if "`bgodfrey'"!=""	mat `mastermat' =`mastermat',`bgodfrey'
	if "`durbinalt'"!=""	mat `mastermat' =`mastermat',`durbinalt'
	if "`dwatson'"!=""	mat `mastermat' =`mastermat',`dwatson'
	if "`sktest'"!=""	mat `mastermat' =`mastermat',`sktest1'
	if "`swilk'"!=""	mat `mastermat' =`mastermat',`swilk1'
	if "`sfrancia'"!=""	mat `mastermat' =`mastermat',`sfrancia1'
	preserve
	drop _all
	if "`double'" !="" svmat double `mastermat', names(col)
	if "`double'" =="" svmat `mastermat', names(col)
	if "`testpass'" !="" {
		if "`hettest'"!="" {
			foreach i of varlist hettest* {
				loc aux=`i'[1]
				if `aux'<`testpass' continue, break
			}
		}
		if "`archlm'"!="" {
			foreach i of varlist archlm* {
				loc aux=`i'[1]
				if `aux'<`testpass' continue, break
			}
		}
		if "`bgodfrey'"!="" {
			foreach i of varlist bgodfrey* {
				loc aux=`i'[1]
				if `aux'<`testpass' continue, break
			}
		}
		if "`durbinalt'"!="" {
			foreach i of varlist durbinalt* {
				loc aux=`i'[1]
				if `aux'<`testpass' continue, break
			}
		}
		if `aux'<`testpass' exit
		if "`sktest'"!="" {
				loc aux=sktest[1]
				if `aux'<`testpass' exit
		}
		if "`swilk'"!="" {
				loc aux=swilk[1]
				if `aux'<`testpass' exit
		}
		if "`sfrancia'"!="" {
				loc aux=sfrancia[1]
				if `aux'<`testpass' exit
		}
	}
	gen order =`nroreg'

	if "`compact'"!="" {
		drop v_*_t
		loc i=1
		foreach var of varlist v_*_b {
			replace `var'=1 if `var'!=.
			replace `var'=0 if `var'==.
		}
		compress
	}
	save "`resn'", replace
	if "`setmoreprev'"=="on" set more on
}
end

capture program drop estcomtry
program define estcomtry
qui	{
	loc setmoreprev=c(more)
	set more off
	syntax anything [aw fw iw pw] [if], CMDEst(string) [CMDOptions(string) cmdstat(string)] resultsdta(string) ORdenvar(string) [nroreg(integer 0) Outsample(integer 0) compact aicbic hettest hettest_o(string) archlm  archlm_o(string) bgodfrey bgodfrey_o(string) durbinalt durbinalt_o(string) dwatson sktest sktest_o(string) swilk swilk_o(string) sfrancia testpass(numlist >0 <1 max=1 ) mindex(string) best(numlist >0 integer max=1 ) lastreg(integer 0) double NOCOunt time(string) panel(string) resn(string) instruments(string) endogenous(string) ] [*]
	loc weight "`weight'`exp'"
	if "`nocount'"=="" noi di as text "Estimation number " as result "`nroreg'" as text " of " as result "`lastreg'"
	tempvar touse
	mark `touse' `if' 
	tempvar insample
	gen `insample' =1 if `touse'==1
	if `outsample'!=0 {
		sort `panel' `time'
		if "`panel'"=="" replace `insample' =0 if _n>_N-`outsample' & `touse'==1
		if "`panel'"!="" by `panel': replace `insample' =0 if _n>_N-`outsample' & `touse'==1
	}
	if "`instruments'"!="" {
		foreach var1 of local anything {
			foreach var2 of local endogenous {
				if "`var1'" =="`var2'" loc ivendogenous " `ivendogenous' `var2' "
			}
		}
		loc anything2 "`anything'"
		foreach var1 of local ivendogenous {
			local anything2: subinstr local anything2 "`var1'" "", word
		}
		loc estim: word 2 of `cmdest'
		if ("`ivendogenous'"!="" | "`estim'"=="gmm") `cmdest' `anything2' (`ivendogenous' =`instruments') `weight' if `insample'==1, `cmdoptions'
		else `cmdest' `anything2' `weight' if `insample'==1, `cmdoptions'
	}
	else `cmdest' `anything' `weight' if `insample'==1, `cmdoptions'
	loc i=1
	loc b_ordenvar =""
	loc t_ordenvar =""
	foreach var1 of local ordenvar {
		foreach var2 of local anything {
			if "`var1'" =="`var2'" loc b_ordenvar "`b_ordenvar' v_`i'_b"
			if "`var1'" =="`var2'" loc t_ordenvar "`t_ordenvar' v_`i'_t"
		}
		loc ++i
	}
	tempname betas sigmas t
	mat `betas' =e(b) 
	mat `sigmas' =e(V)
	loc obs =e(N)
	loc rank =e(rank)
	loc nvar =colsof(`betas')
	local r_sqr_a = e(r2_a) 
	local rmse_in = e(rmse) 
	mat `t' = `betas'
	forvalues i=1/`nvar'{
		mat `t'[1,`i'] = `betas'[1,`i'] / `sigmas'[`i',`i']^.5
	}
	if `outsample'!=0 {
		tempvar resout resout_sq 
		if "`cmdest'"=="xtreg" predict `resout' if `insample'==0, e  
		else predict `resout' if `insample'==0, res
		gen `resout_sq'= `resout'*`resout' 
		sum `resout_sq', mean
		tempname rmse_out
		mat `rmse_out' =( r(sum)/(`obs'-`nvar') )^.5	
		mat colnames `rmse_out' = rmse_out
	}
	if "`aicbic'"!="" {
		estat ic
		tempname aicbic
		mat `aicbic'=r(S)
		mat `aicbic'=`aicbic'[1,5],`aicbic'[1,6]
		mat colnames `aicbic' = aic bic 
		
	}
	if "`hettest'"!="" {
		estat hettest
		tempname hettest
		mat `hettest' =r(p)
		mat colnames `hettest' = hettest
	}
	if "`archlm'"!="" {
		loc lista ""
		estat archlm, `archlm_o'
		loc aux=r(lags)
		foreach i of local aux {
			loc lista "`lista' archlm`i'"
		}
		tempname archlm
		mat `archlm' =r(p)
		mat colnames `archlm' =`lista' 
	}
	if "`bgodfrey'"!="" {
		loc lista ""
		estat bgodfrey, `bgodfrey_o'
		loc aux=r(lags)
		foreach i of local aux {
			loc lista "`lista' bgodfrey`i'"
		}
		tempname bgodfrey
		mat `bgodfrey' =r(p)
		mat colnames `bgodfrey' =`lista' 
	}
	if "`durbinalt'"!="" {
		loc lista ""
		estat durbinalt, `durbinalt_o'
		loc aux=r(lags)
		foreach i of local aux {
			loc lista "`lista' durbinalt`i'"
		}
		tempname durbinalt
		mat `durbinalt' =r(p)
		mat colnames `durbinalt' =`lista' 
	}
	if "`dwatson'"!="" {
		estat dwatson
		tempname dwatson
		mat `dwatson' =r(dw)
		mat colnames `dwatson' = dwatson
	}
	if "`sktest'"!="" | "`swilk'"!="" | "`sfrancia'"!="" {
		tempvar resxt
		if "`cmdest'"=="xtreg" predict `resxt' if e(sample), e  
		else predict `resxt' if e(sample), res
		if "`sktest'"!="" {
			sktest `resxt' ,`sktest_o'
			tempname sktest1
			mat `sktest1' =r(P_chi2)
			mat colnames `sktest1' = sktest
		}
		if "`swilk'"!="" {
			swilk `resxt' ,`swilk_o'
			tempname swilk1
			mat `swilk1' =r(p)
			mat colnames `swilk1' = swilk
		}
		if "`sfrancia'"!="" {
			sfrancia `resxt' 
			tempname sfrancia1
			mat `sfrancia1' =r(p)
			mat colnames `sfrancia1' = sfrancia
		}
	}
	tempname mastermat
	mat `mastermat' = `betas',`t',`obs',`nvar',`r_sqr_a',`rmse_in'
*******	try	***************
	loc aux ""
	loc size= colsof(`mastermat')
	forvalues h=1/`size' {
		loc aux "`aux' v_`h' "
	}
	mat colnames `mastermat'= `aux' 
*******	try	***************
	if "`cmdstat'"!="" {
		foreach i of local cmdstat {
			tempname aux
			mat `aux'=e(`i')
			mat colnames `aux'= `i'
			mat `mastermat'=`mastermat',`aux'
		}
		
	}
	if `outsample'!=0	mat `mastermat' =`mastermat',`rmse_out'
	if "`aicbic'"!=""	mat `mastermat' =`mastermat',`aicbic'
	if "`hettest'"!=""	mat `mastermat' =`mastermat',`hettest'
	if "`archlm'"!=""	mat `mastermat' =`mastermat',`archlm'
	if "`bgodfrey'"!=""	mat `mastermat' =`mastermat',`bgodfrey'
	if "`durbinalt'"!=""	mat `mastermat' =`mastermat',`durbinalt'
	if "`dwatson'"!=""	mat `mastermat' =`mastermat',`dwatson'
	if "`sktest'"!=""	mat `mastermat' =`mastermat',`sktest1'
	if "`swilk'"!=""	mat `mastermat' =`mastermat',`swilk1'
	if "`sfrancia'"!=""	mat `mastermat' =`mastermat',`sfrancia1'
	preserve
	drop _all
	if "`double'" !="" svmat double `mastermat', names(col)
	if "`double'" =="" svmat `mastermat', names(col)
	if "`testpass'" !="" {
		if "`hettest'"!="" {
			foreach i of varlist hettest* {
				loc aux=`i'[1]
				if `aux'<`testpass' continue, break
			}
		}
		if "`archlm'"!="" {
			foreach i of varlist archlm* {
				loc aux=`i'[1]
				if `aux'<`testpass' continue, break
			}
		}
		if "`bgodfrey'"!="" {
			foreach i of varlist bgodfrey* {
				loc aux=`i'[1]
				if `aux'<`testpass' continue, break
			}
		}
		if "`durbinalt'"!="" {
			foreach i of varlist durbinalt* {
				loc aux=`i'[1]
				if `aux'<`testpass' continue, break
			}
		}
		if `aux'<`testpass' exit
		if "`sktest'"!="" {
				loc aux=sktest[1]
				if `aux'<`testpass' exit
		}
		if "`swilk'"!="" {
				loc aux=swilk[1]
				if `aux'<`testpass' exit
		}
		if "`sfrancia'"!="" {
				loc aux=sfrancia[1]
				if `aux'<`testpass' exit
		}
	}
	gen order =`nroreg'
	tempfile aa
	save "`aa'", replace
	if "`setmoreprev'"=="on" set more on
	erase "`aa'"
	macro drop _aa
}
end

