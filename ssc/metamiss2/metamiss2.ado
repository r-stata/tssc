*! version 1.2.8, 01.10.2018, Anna Chaimani & Ian White
* bug in output after using compare() fixed
* added option seed() for the bootstrap method
* version 1.2.7, 06.03.2018, Anna Chaimani & Ian White
* added option tau2() that allows different heterogeneity estimators using metaan
* version 1.2.6, 19.07.2016, Anna Chaimani & Ian White
* bug for NMA with binary data fixed
* version 1.2.5, 11.10.2016, Anna Chaimani & Ian White
* improved output for both NMA and pairwise MA
* bug for smd when rho!=0 fixed
* version 1.2.4, 16.08.2016, Anna Chaimani & Ian White
* alternative version with improved output for NMA but not for pairwise MA
* version 1.2.3, 18.05.2016, Anna Chaimani & Ian White
* AC 16may2016 - correction to lines 853, 909, 954 for NMA for consistency with pairwise meta-analysis
* AC 16may2016 - further correction to line 1349 gives total agreement with metamiss for binary outcome
* IW 18mar2016 - correction to lines 1265, 1267 gives agreement with metamiss for binary outcome (?)
* version 1.2.2, 14.10.2015, Anna Chaimani & Ian White

program metamiss2
version 13
	syntax [anything] [if] [in], [IMPType(string) IMPMean(string) IMPSD(string) IMPCorrelation(string) ///
	MD SMD ROM OR RR RD SDPool(string) Bootstrap Taylor REPS(string) NOKEEP NOMETA EFORM LOG FIXED ///
	COMPare(string asis) VARCHange INConsistency SENSitivity NETPLOT TRTLABels(string asis) TAU2(string) ///
	NETPLOTREFerence(string asis) NETPLOTOPTions(string asis) METANOPTions(string asis) NETWORKOPTions(string asis) seed(string)]	
	
	tokenize `anything'
	
	if "`1'"==""{	
		local network "on"	//data in format from network setup
		if "`tau2'"!=""{
			di as err "Option {it:tau2()} is available only for pairwise meta-analysis"
			exit
		}
	}	
	if "`tau2'"!=""{
		if "`tau2'"!="ml" & "`tau2'"!="reml" & "`tau2'"!="pl" & "`tau2'"!="pe"{
			di as err "Option `tau2' is not a valid estimator for between-study variance - see {helpb metaan} for the available estimators"
			exit
		}
		else{
			local command metaan
		}
		if "`compare'"!=""{
			di as err "Option {it:compare()} may not be combined with option {it:tau2()}"
			exit
		}
		if "`sensitivity'"!=""{
			di as err "Option {it:sensitivity} may not be combined with option {it:tau2()}"
			exit
		}		
		if "`metanoptions'"!=""{
			di as err "Option {it:metanoptions()} may not be combined with option {it:tau2()}"
			exit
		}	
		if "`eform'"!=""{
			di as err "Option {it:eform} may not be combined with option {it:tau2()}"
			exit
		}		
	}
	else{
		local command metan
	}
	if  "`7'"=="" & "`6'"!=""{	
		local type "bin"	//binary data
		local network "off"	//data in format for metan
	}	
	if "`8'"!=""{	
		local type "cont"	//continuous data
		local network "off"	//data in format for metan
	}	
	if "`2'"=="" & "`1'"!=""{
		di as err "Wrong number of variables specified"
		exit
	}
	if "`6'"=="" & "`5'"!=""{
		di as err "Wrong number of variables specified"
		exit
	}
	if "`8'"=="" & "`7'"!=""{
		di as err "Wrong number of variables specified"
		exit
	}
	if "`9'"!=""{
		di as err "Wrong number of variables specified"
		exit
	}
	
	tempvar use nobs rankstart
	qui gen `use'=1 `if' `in'
	qui{
		gen `rankstart'=_n
		by `use',sort: gen `nobs'=_N if `use'==1
	}
	qui sort `use'
	local nall=`nobs'

			
	/*input for network meta-analysis*/
	
	if "`network'"=="on"{
		local options `"`networkoptions'"'
		local form:char _dta[network_format]
		if "`form'"!="augmented"{
			di as err "Data not in augmented format"
			exit
		}
		local n:char _dta[network_n]
		local d:char _dta[network_d]
		local r `d'
		local y:char _dta[network_mean]
		local sd:char _dta[network_sd]
		local m:char _dta[network_nmiss]
		if "`m'"==""{
			di as err "Variables with number of missing participants not found"
			exit
		}
		if "`d'"!=""{
			local type "bin"	//binary data
		}
		else{
			local type "cont"	//continuous data
		}
		local prey:char _dta[network_y]
		local preY "`prey'_"
		local pres:char _dta[network_S]
		local preS "`pres'_"
		local dim:char _dta[network_dim]
		local ntm=`dim'+1
		local ref:char _dta[network_ref]
		local trts:char _dta[network_trtlistnoref]
		tokenize `trts'
		forvalues i=1/`dim'{
			local tr`i' ``i''
		}
		local meas:char _dta[network_measure]
		if `"`netplotoptions'"'!="" & "`netplot'"==""{
			di as err "Option {it:netplotoptions()} requires option {it:netplot}"
			exit
		}
		if `"`trtlabels'"'!="" & "`netplot'"==""{
			di as err "Option {it:trtlabels()} requires option {it:netplot}"
			exit
		}
		if `"`trtlabels'"'=="" & `"`netplotreference'"'!=""{
			di as err "Option {it:netplotreference()} requires option {it:trtlabels()}"
			exit
		}
		if `"`netplotoptions'"'!="" & "`netplot'"!=""{
			local plotoptions `"`netplotoptions'"'
		}
		if `"`netplotoptions'"'=="" & "`netplot'"!=""{
			local plotoptions ""
		}
		if `"`trtlabels'"'!="" & "`netplot'"!=""{
			local trtlab `"`trtlabels'"'
		}
		if `"`trtlabels'"'=="" & "`netplot'"!=""{
			local trtlab ""
		}
		if `"`netplotreference'"'!="" & `"`trtlabels'"'!=""{
			local plotref `"`netplotreference'"'
		}
		if `"`netplotreference'"'=="" & `"`netplotoptions'"'!=""{
			local plotref ""
		}
		if `ntm'>10{
			cap set matsize 800
			cap set matsize 11000
		}
	}
	
	/*input for standard meta-analysis*/

	if "`network'"=="off"{	
		cap local options `"`metanoptions'"'
		if "`type'"=="cont"{	//observed, unobserved, mean, sd in treatment and control arm - consistent with metan
			local nt `1'
			local mt `2'
			local yt `3'
			local sdt `4'
			local nc `5'
			local mc `6'
			local yc `7'
			local sdc `8'	
			qui li `nt' `mt' `yt' `sdt' `nc' `mc' `yc' `sdc'
		}
		if "`type'"=="bin"{	//successes, failures, unobserved in treatment and control arm - consistent with metan
			local rt `1'
			local ft `2'
			local mt `3'
			local rc `4'
			local fc `5'
			local mc `6'
			qui li `rt' `ft' `mt' `rc' `fc' `mc'
		}
		if "`varchange'"!=""{
			di as err "Option {it:varchange()} not allowed for the case of standard meta-analysis"
			exit
		}
		if "`netplot'"!=""{
			di as err "Option {it:netplot} not allowed for the case of standard meta-analysis"
			exit
		}
		if "`netplotoptions'"!=""{
			di as err "Option {it:netplotoptions()} not allowed for the case of standard meta-analysis"
			exit
		}
		if "`inconsistency'"!=""{
			di as err "Option {it:inconsistency} not allowed for the case of standard meta-analysis"
			exit
		}
	}
	/*mean and sd for IMP in treatment and control arms, default is IMPmean(0 0) and IMPsd(0 0)*/
	/*for network meta-analysis impmean and impsd common for all non-reference arms*/
	if "`imptype'"!="" & "`type'"=="bin"{
		di as err "Option {it:imptype()} is available only for continuous outcome data"
	}
	if "`type'"=="bin"{
		local model "logimor" //model logIMOR for binary data
	}
	if "`type'"=="cont"{
		if "`imptype'"=="imdom" | "`imptype'"==""{
			local model "imdom" //model IMDoM, default for continuous data
		}
		else if "`imptype'"=="logimrom"{
			local model "logimrom" //model logIMRoM for continuous data		
		}
		else{
			di as error "Invalid type of IMP specified in option {it:imptype()}"
			exit
		}
	}
	if "`network'"=="off"{
		local mulambdat=0
		local mulambdac=0
		local sdlambdat=0
		local sdlambdac=0
	}
	if "`network'"=="on"{
		local mulambda`ref'=0
		local sdlambda`ref'=0
		forvalues i=1/`dim'{
			local mulambda`tr`i''=0
			local sdlambda`tr`i''=0
		}
	}	
	if "`impmean'"!=""{
		tokenize `impmean'
		if "`network'"=="off"{
			local mulambdat=`1'
			if "`2'"==""{			
				local mulambdac=`1'
			}	
			else{
				local mulambdac=`2'
			}
			if "`3'"!=""{
				di as err "Option {it:impmean()} requires 1 or 2 input values/variables for standard meta-analysis"
				exit
			}	
		}
		if "`network'"=="on"{
			if "`2'"==""{
				local mulambda`ref'=`1'
				forvalues i=1/`dim'{
					local mulambda`tr`i''=`1'
				}
			}
			else if "``ntm''"=="" | "``=`ntm'+1''"!=""{
				di as err "Option {it:impmean()} requires 1 or `ntm' input values/variables for a network meta-analysis with `ntm' treatments"
			}
			else{
				local mulambda`ref'=`1'
				forvalues i=1/`dim'{
					local mulambda`tr`i''=``=`i'+1''
				}
			}
		}
	}
	if "`impsd'"!=""{
		tokenize `impsd'
		if "`network'"=="off"{
			local sdlambdat `1'
			if "`2'"==""{			
				local sdlambdac=`1'
			}	
			else{
				local sdlambdac=`2'
			}
			if "`3'"!=""{
				di as err "Option {it:impsd()} requires 1 or 2 input values/variables for standard meta-analysis"
				exit
			}		
		}
		if "`network'"=="on"{
			if "`2'"==""{
				local sdlambda`ref'=`1'
				forvalues i=1/`dim'{
					local sdlambda`tr`i''=`1'
				}
			}
			else if "``ntm''"=="" | "``=`ntm'+1''"!=""{
				di as err "Option {it:impsd()} requires 1 or `ntm' input values/variables for a network meta-analysis with `ntm' treatments"
			}
			else{
				local sdlambda`ref'=`1'
				forvalues i=1/`dim'{
					local sdlambda`tr`i''=``=`i'+1''
				}
			}
		}
	}	
	if "`network'"=="off"{
		tempvar mulc sdlc mult sdlt
		qui gen double `mulc'=`mulambdac'
		qui gen double `sdlc'=`sdlambdac'
		qui gen double `mult'=`mulambdat'
		qui gen double `sdlt'=`sdlambdat'
	}
	if "`network'"=="on"{
		tempvar mul`ref' sdl`ref'
		qui gen double `mul`ref''=`mulambda`ref''
		qui gen double `sdl`ref''=`sdlambda`ref''
		forvalues i=1/`dim'{
			tempvar mul`tr`i'' sdl`tr`i''
			qui gen double `mul`tr`i'''=`mulambda`tr`i'''
			qui gen double `sdl`tr`i'''=`sdlambda`tr`i'''
		}
	}	
	if "`bootstrap'"==""{
		local method "taylor" //estimate relative effects and variances using Taylor approximation, default
		if "`seed'"!=""{
			di as err "Option {it:seed()} requires option {it:bootstrap}" 
			exit
		}		
	}
	if "`bootstrap'"!=""{
		local method "bootstrap" //estimate relative effects and variances using parametric bootstrap
		if "`seed'"!=""{
			local seed=int(`seed')
		}
		else{
			local seed=0
		}		
	}
	if "`taylor'"!="" & "`bootstrap'"!=""{
		di as err "Option {it:bootstrap} may not be combined with option {it:taylor}" 
		exit
	}	
	if "`network'"=="off"{
		if "`sdlambdat'"=="0" & "`sdlambdac'"=="0" & "`sensitivity'"==""{
			local method "taylor"
			if "`bootstrap'"!=""{
				di _newline " Note: Option {it:bootstrap} is not allowed when sd(IMP) is zero for all treatment groups and all studies - reset to default option ({it:taylor})"
			}
		}
		cap{
			assert `sdlambdac'>0 & `sdlambdat'>0
		}
		if _rc!=0{
			local method "taylor"
			if "`bootstrap'"!=""{
				di _newline " Note: Option {it:bootstrap} is not allowed when sd(IMP) is zero for all treatment groups and all studies - reset to default option ({it:taylor})"
			}
		}
	}
	tempvar tayl tayl2
	if "`network'"=="on"{
		qui gen `tayl'=1
		cap{
			assert `sdl`ref''==0
		}
		if _rc!=0{
			qui replace `tayl'=0
		}
		forvalues i=1/`dim'{
			cap{
				assert `sdl`tr`i'''==0
			}
			if _rc!=0{
				qui replace `tayl'=0
			}
		}
		if `tayl'==1 & "`bootstrap'"!=""{
			di _newline " Note: Option {it:bootstrap} is not allowed when sd(IMP) is zero for all treatment groups and all studies - reset to default option ({it:taylor})"
		}
		qui gen `tayl2'=1
		cap{
			assert `mul`ref''==0
		}
		if _rc!=0{
			qui replace `tayl2'=0
		}
		forvalues i=1/`dim'{
			cap{
				assert `mul`tr`i'''==0
			}
			if _rc!=0{
				qui replace `tayl2'=0
			}
		}
	}
	/*correlation of IMP between treatment and control or reference and non-reference arms, default is impcorr(0)*/
	if "`impcorrelation'"!=""{
		local corr "`impcorrelation'"
		cap local corr=`corr'
	}
	else{
		local corr=0
	}
	if "`network'"=="off"{	
		tempvar corrl
		qui gen double `corrl'=`corr'
		cap{
			assert `corrl'<=1 & `corrl'>=-1
		}
		if _rc!=0{
			di as err "Correlation of IMPs in option {it:impcorrelation()} should be between -1 and 1"
			exit
		}		
	}
	tempname Corr X L
	if "`network'"=="on"{
		cap{
			assert real("`corr'")==`corr'
		}
		if _rc==0{
			local corrtype "comm"	//common correlation across trials and arms - value specified
		}
		else{
			local corrtype "diff"	//different correlation across trials or arms - matrix or variable specified
		}
		if "`corrtype'"=="diff"{
			cap mkmat `corr'
			if _rc==0{
				local corrstudy "diff"	//common correlation across arms - different across studies - variable specified
			}
			else{
				local corrstudy "comm"	//different correlation across arms - common across studies - matrix specified
			}
		}
		if "`method'"=="taylor"{
			forvalues i=1/`dim'{
				tempvar corrl`ref'`tr`i''
			}
			forvalues i=1/`=`dim'-1'{
				forvalues j=`=`i'+1'/`dim'{
					tempvar corrl`tr`i''`tr`j''
				}	
			}		
			if "`corrtype'"=="comm" | ("`corrtype'"=="diff" & "`corrstudy'"=="diff"){
				forvalues i=1/`dim'{
					qui gen double `corrl`ref'`tr`i'''=`corr'
				}
				forvalues i=1/`=`dim'-1'{
					forvalues j=`=`i'+1'/`dim'{
						qui gen double `corrl`tr`i''`tr`j'''=`corr'
					}	
				}
			}
			if "`corrtype'"=="diff" & "`corrstudy'"=="comm"{
				mat colnames `corr'=`ref' `trts'
				mat rownames `corr'=`ref' `trts'
				mat `Corr'=`corr'
				forvalues i=1/`dim'{
					qui gen double `corrl`ref'`tr`i'''=`Corr'[`=`i'+1',1]
				}
				forvalues i=1/`=`dim'-1'{
					forvalues j=`=`i'+1'/`dim'{
						qui gen double `corrl`tr`i''`tr`j'''=`Corr'[`=`i'+1',`=`j'+1']
					}	
				}			
			}
		}	
		if "`method'"=="bootstrap"{
			forvalues i=1/`nall'{
				tempname tn`i' tnn`i' tm`i' tmean`i' tsd`i' tR`i' z`i' Corr`i' MLcorr`i' SLcorr`i' SLcov`i'
			}
			forvalues i=1/`nall'{ //identify which treatments each study includes and produce the respective data vectors
				local sdes`i'=_design in `i'
				local sna`i'=wordcount("`sdes`i''")
				tokenize `sdes`i''
				forvalues j=1/`sna`i''{
					local str`i'_`j' "``j''"
				}				
			}
			forvalues i=1/`nall'{
				local n`i'_1 "`n'`str`i'_1'"
				local m`i'_1 "`m'`str`i'_1'"
				if "`type'"=="cont"{
					local mean`i'_1 "`y'`str`i'_1'"
					local sd`i'_1 "`sd'`str`i'_1'"
				}
				if "`type'"=="bin"{
					local r`i'_1 "`r'`str`i'_1'"
				}
				forvalues j=2/`sna`i''{
					if "`str`i'_`j''"=="`ref'" continue
					local n`i'_`j' "`n`i'_`=`j'-1'' `n'`str`i'_`j''" 
					local n`i'="`n`i'_`sna`i'''"	
					local m`i'_`j' "`m`i'_`=`j'-1'' `m'`str`i'_`j''" 
					local m`i'="`m`i'_`sna`i'''"					
					if "`type'"=="cont"{
						local mean`i'_`j' "`mean`i'_`=`j'-1'' `y'`str`i'_`j''" 
						local mean`i'="`mean`i'_`sna`i'''"
						local sd`i'_`j' "`sd`i'_`=`j'-1'' `sd'`str`i'_`j''" 
						local sd`i'="`sd`i'_`sna`i'''"	
					}
					if "`type'"=="bin"{
						local r`i'_`j' "`r`i'_`=`j'-1'' `r'`str`i'_`j''" 
						local r`i'="`r`i'_`sna`i'''"					
					}
				}
				mkmat `n`i'' in `i',mat(`tn`i'')
				mkmat `n`i'' in `i',mat(`tnn`i'')
				mkmat `m`i'' in `i',mat(`tm`i'')
				if "`type'"=="cont"{
					mkmat `mean`i'' in `i',mat(`tmean`i'')
					mkmat `sd`i'' in `i',mat(`tsd`i'')
				}
				if "`type'"=="bin"{
					mkmat `r`i'' in `i',mat(`tR`i'')
				}
				if "`str`i'_1'"!="`ref'"{
					local nref=`n'`ref' in `i'
					mat `tn`i''=(`nref',`tn`i'')
					mat `tnn`i''=(`nref',`tnn`i'')
					local mref=`m'`ref' in `i'
					mat `tm`i''=(`mref',`tm`i'')					
					if "`type'"=="cont"{
						local meanref=`y'`ref' in `i'
						local sdref=`sd'`ref' in `i'
						mat `tmean`i''=(`meanref',`tmean`i'')
						mat `tsd`i''=(`sdref',`tsd`i'')
					}
					if "`type'"=="bin"{
						local rref=`r'`ref' in `i'
						mat `tR`i''=(`rref',`tR`i'')
					}
				}
				local narms`i'=colsof(`tn`i'')
				mat `z`i''=`tm`i''
				forvalues j=1/`narms`i''{	//required to allow the use of beta distribution
					if "`type'"=="bin"{
						if `tn`i''[1,`j']<0.2{
							mat `tn`i''[1,`j']=0.2
						}
						if `tR`i''[1,`j']<0.05{
							mat `tR`i''[1,`j']=0.05
						}					
					}
					mat `z`i''[1,`j']=0
					if `tm`i''[1,`j']==. | `tm`i''[1,`j']==0{
						mat `z`i''[1,`j']=1
						//mat `tm`i''[1,`j']=0.15
					}					
				}
			}
			local trtlist: char _dta[network_trtlistnoref]
			forvalues i=1/`nall'{
				local ltr`i'_1 "`str`i'_1'"
				forvalues j=2/`sna`i''{
					if "`str`i'_`j''"=="`ref'" continue
					local ltr`i'_`j' "`ltr`i'_`=`j'-1'' `str`i'_`j''" 
				}
				if "`str`i'_1'"!="`ref'"{
					local ltr`i' "`ref' `ltr`i'_`sna`i'''"
				}
				else{
					local ltr`i'="`ltr`i'_`sna`i'''"
				}	
			}			
			if "`corrtype'"=="comm"{ //produce the study-specific correlation matrices for lambda
				forvalues i=1/`nall'{
					mat `Corr`i''=J(`narms`i'',`narms`i'',`corr')
					forvalues j=1/`=colsof(`Corr`i'')'{
						mat `Corr`i''[`j',`j']=1
					}
				}
			}	
			if "`corrtype'"=="diff" & "`corrstudy'"=="diff"{
				forvalues i=1/`nall'{
					local corr_`i'=`corr' in `i'
					mat `Corr`i''=J(`narms`i'',`narms`i'',`corr_`i'')
					forvalues j=1/`=colsof(`Corr`i'')'{
						mat `Corr`i''[`j',`j']=1
					}
				}
			}
			if "`corrtype'"=="diff" & "`corrstudy'"=="comm"{
				mat colnames `corr'=`ref' `trtlist'
				mat rownames `corr'=`ref' `trtlist'
				forvalues i=1/`nall'{
					mat `Corr`i''=J(`narms`i'',`narms`i'',1)
					mat colnames `Corr`i''=`ltr`i''
					mat rownames `Corr`i''=`ltr`i''
				}
				forvalues i=1/`nall'{
					foreach trt in `ltr`i''{
						cap local posS`trt'=colnumb(`Corr`i'',"`trt'")
						cap local posC`trt'=colnumb(`corr',"`trt'")
						cap mat `Corr`i''[`posS`trt'',`posS`trt'']=`corr'[`posC`trt'',`posC`trt'']
					} 
					foreach trt in `ltr`i''{
						foreach trt2 in `ltr`i''{
							if "`trt'"=="`trt2'" continue
							cap mat `Corr`i''[`posS`trt'',`posS`trt2'']=`corr'[`posC`trt'',`posC`trt2'']
							cap mat `Corr`i''[`posS`trt2'',`posS`trt'']=`corr'[`posC`trt2'',`posC`trt'']
						}
					}
				}
			}
			forvalues i=1/`nall'{
				local ml`ref'_`i'=`mul`ref'' in `i'
				local sl`ref'_`i'=`sdl`ref'' in `i'
				foreach trt in `ltr`i''{
					local ml`trt'_`i'=`mul`trt'' in `i'
					local sl`trt'_`i'=`sdl`trt'' in `i'						
				}
				mat `MLcorr`i''=J(1,`narms`i'',0)
				mat colnames `MLcorr`i''=`ltr`i''
				foreach trt in `ltr`i''{
					cap local posM`trt'=colnumb(`MLcorr`i'',"`trt'")
				}
				mat `MLcorr`i''[1,1]=`ml`ref'_`i''
				foreach trt in `ltr`i''{
					cap mat `MLcorr`i''[1,`posM`trt'']=`ml`trt'_`i''
				}
				mat `SLcorr`i''=`Corr`i''
				mat colnames `SLcorr`i''=`ltr`i''
				mat rownames `SLcorr`i''=`ltr`i''
				mat `SLcorr`i''[1,1]=`sl`ref'_`i''^2
				foreach trt in `ltr`i''{
					cap mat `SLcorr`i''[1,`posM`trt'']=`sl`ref'_`i''*`sl`trt'_`i''*`Corr`i''[1,`posM`trt'']
					cap mat `SLcorr`i''[`posM`trt'',1]=`sl`ref'_`i''*`sl`trt'_`i''*`Corr`i''[`posM`trt'',1]
				}
				foreach trt in `ltr`i''{  
					foreach trt2 in `ltr`i''{
						cap mat `SLcorr`i''[`posM`trt'',`posM`trt2'']=`sl`trt2'_`i''*`sl`trt'_`i''*`Corr`i''[`posM`trt'',`posM`trt2'']
						cap mat `SLcorr`i''[`posM`trt2'',`posM`trt'']=`sl`trt2'_`i''*`sl`trt'_`i''*`Corr`i''[`posM`trt2'',`posM`trt'']						
					}
				}
				cap mat `SLcov`i''=cholesky(`SLcorr`i'')	//if covariance matrix positive definite
				if _rc!=0{	//otherwise
					mat symeigen `X' `L'=`SLcorr`i''
					forvalues j=1/`narms`i''{
						mat `L'[1,`j']=sqrt(max(0,`L'[1,`j']))
					}	
					mat `SLcov`i''=`X'*diag(`L')
				}
			}
		}
	}
	
	if "`network'"=="on"{
		if "`meas'"=="Mean difference"{
			local measure "md"
		}
		if "`meas'"=="Standardised mean difference"{
			local measure "smd"
		}
		if "`meas'"=="Log odds ratio"{
			local measure "or"
		}
		if "`meas'"=="Log risk ratio"{
			local measure "rr"
		}
		if "`meas'"=="Risk difference"{
			local measure "rd"
		}
	}
	if "`type'"=="cont"{	//effect measures for continuous data
		if "`network'"=="off"{
			if "`md'"=="" & "`rom'"==""{
				local measure "smd" //estimate standardized mean differences, default for standard meta-analysis
			}
		}
		if "`network'"=="on"{
			if "`md'"!="" & "`smd'"=="" & "`rom'"==""{
				local measure "md" //estimate mean differences
			}
		}
		if "`md'"!="" & "`rom'"=="" & "`smd'"==""{
			local measure "md" //estimate standardized mean differences
		}
		if "`rom'"!="" & "`smd'"=="" & "`md'"==""{
			local measure "rom" //estimate ratios of means
			cap{
				assert `yt'>=0 & `yc'>=0
			}
			if _rc!=0{
				cap{
					assert `yt'<=0 & `yc'<=0
				}
				if _rc!=0{
					di as err "Effect sizes with opposite signs cannot be used when ratios of means are estimated"
					exit
				}
			}		
		}
		if ("`smd'"!="" & "`rom'"!="") | ("`md'"!="" & "`rom'"!="") | ("`smd'"!="" & "`md'"!=""){
			di as err "Two or more measures of interest specified" 
			exit
		}
		if "`or'"!="" | "`rr'"!="" | "`rd'"!=""{
			di as err "Not appropriate measure of interest for continuous data specified"
			exit
		}
	}
	if "`type'"=="bin"{	//effect measures for binary data
		if "`network'"=="off"{
			if "`or'"=="" & "`rd'"==""{
				local measure "rr" //estimate risk ratios, default for standard meta-analysis
			}
		}
		if "`network'"=="on"{
			if "`or'"!="" & "`rr'"=="" & "`rd'"==""{
				local measure "or" //estimate odds ratios
			}
		}
		if "`rr'"=="" & "`or'"!="" & "`rd'"==""{
			local measure "or" //estimate odds ratios
		}
		if "`rd'"!="" & "`or'"=="" & "`rr'"==""{
			local measure "rd" //estimate risk differences
		}
		if ("`rr'"!="" & "`rd'"!="") | ("`or'"!="" & "`rd'"!="") | ("`rr'"!="" & "`or'"!=""){
			di as err "Two or more measures of interest specified" 
			exit
		}
		if "`md'"!="" | "`smd'"!="" | "`rom'"!=""{
			di as err "Not appropriate measure of interest for binary data specified"
			exit
		}
	}
	if "`sdpool'"==""{	//SDpooled used only for SMD by default
		if "`measure'"=="md"{
			local sdpool "off"
		}
		if "`measure'"=="smd"{
			local sdpool "on"
		}
		if "`measure'"=="rom"{
			local sdpool "off"
		}
	}
	if "`sdpool'"!="" & "`type'"=="bin"{
		di as err "Option {it:sdpool()} allowed only for continuous outcome data"
		exit
	}
	tempvar pooledsd
	qui gen double `pooledsd'=0 `if' `in'
	
	if "`network'"=="off"{
		if "`sdpool'"=="off"{
			local sdnewc `sdc'
			local sdnewt `sdt'
		}
		if "`sdpool'"=="on"{
			local sdnewc `pooledsd'
			local sdnewt `pooledsd'
		}
	}
	if "`network'"=="on"{
		if "`sdpool'"=="off"{
			local sdnew`ref' `sd'`ref'
			forvalues i=1/`dim'{
				local sdnew`tr`i'' `sd'`tr`i''
			}
		}
		if "`sdpool'"=="on"{
			local sdnew`ref' `pooledsd'
			forvalues i=1/`dim'{
				local sdnew`tr`i'' `pooledsd'
			}
		}
	}
	
	if "`network'"=="off"{
		if ("`measure'"=="or" | "`measure'"=="rr") & "`log'"==""{
			local eform "eform"
		}
		if "`log'"!=""{
			local eform ""
		}
		if "`eform'"!=""{
			if "`measure'"=="md" | "`measure'"=="smd" | "`measure'"=="rd"{
				di as err "Option {it:eform} allowed only for ratio measures"
				exit
			}
			else{
				local eform "eform"
			}
		}
	}
	if "`network'"=="on"{
		if "`eform'"!=""{
			if "`measure'"=="md" | "`measure'"=="smd" | "`measure'"=="rd"{
				di as err "Option {it:eform} allowed only for ratio measures"
				exit
			}
			else{
				local eform "eform"
			}
		}
		else{
			local eform ""
		}
	}
	if "`reps'"!="" & "`bootstrap'"==""{
		di as err "Option {it:reps()} requires option {it:bootstrap}"
		exit
	}	
	
	/*number of random samlpes for the bootstrap method, default is reps(10000)*/
	if "`reps'"!=""{
		local reps `reps'
	}
	else{
		local reps=10000
	}
	
	/*transfer locals to compare and sensitivity programs*/
	global METAMISS2_model `model'
	global METAMISS2_measure `measure'
	global METAMISS2_reps `reps'
	global METAMISS2_corr `corr'
	global METAMISS2_method `method'
	global METAMISS2_anything `anything'
	global METAMISS2_impmean `impmean'
	global METAMISS2_if `if'
	global METAMISS2_in `in'		
	global METAMISS2_eform `eform'
	global METAMISS2_network `network'
	global METAMISS2_options `options'
	if "`compare'"!=""{
		global COMPARE_options $METAMISS2_options
	}
		
	
	if "`method'"=="bootstrap"{
		if "`model'"=="imdom" | "`model'"=="logimor"{
			scalar Mod=1
		}
		if "`model'"=="logimrom"{
			scalar Mod=2
		}
		if "`type'"=="cont"{
			scalar Dat=1
		}
		if "`type'"=="bin"{
			scalar Dat=2
		}
		if "`measure'"=="md" | "`measure'"=="or"{
			scalar Meas=1
		}
		if "`measure'"=="smd" | "`measure'"=="rr"{
			scalar Meas=2
		}		
		if "`measure'"=="rom" | "`measure'"=="rd"{
			scalar Meas=3
		}	
		scalar Mreps=real("`reps'")
		scalar Mntm=real("`dim'")
		scalar Mntm=Mntm+1
		scalar Mseed=`seed'
	}
	
	if "`network'"=="off"{
		cap replace `corrl'=0 if `corrl'==. & `use'==1
		qui replace `mulc'=0 if `mulc'==. & `use'==1
		qui replace `sdlc'=0 if `sdlc'==. & `use'==1	
		qui replace `mult'=0 if `mult'==. & `use'==1
		qui replace `sdlt'=0 if `sdlt'==. & `use'==1
	}

	if "`network'"=="on"{
		qui replace `mul`ref''=0 if `mul`ref''==. & `use'==1
		qui replace `sdl`ref''=0 if `sdl`ref''==. & `use'==1
		forvalues i=1/`dim'{
			qui replace `mul`tr`i'''=0 if `mul`tr`i'''==. & `use'==1
			qui replace `sdl`tr`i'''=0 if `sdl`tr`i'''==. & `use'==1
		}
		forvalues i=1/`dim'{
			cap replace `corrl`ref'`tr`i'''=0 if `corrl`ref'`tr`i'''==. & `use'==1
		}
		forvalues i=1/`=`dim'-1'{
			forvalues j=`=`i'+1'/`dim'{
				cap replace `corrl`tr`i''`tr`j'''=0 if `corrl`tr`i''`tr`j'''==. & `use'==1
			}	
		}		
	}
	
	if "`varchange'"!="" | "`nometa'"!=""{
		local nometa "nometa"
		char _dta[network_MNAR] imptype(`model') impmean(`impmean') impsd(`impsd') impcorr(`impcorrelation') `measure' `method'
	}
	else{
		local nometa ""
	}	

	if "`network'"=="on"{

		qui replace `m'`ref'=0 if `m'`ref'==. & `use'==1	//replace with zero missing participants for imputed reference arms

		if "`type'"=="cont"{
			tempvar pooleddf
			qui replace `pooledsd'=(`n'`ref'-1)*`sd'`ref'^2 if `sd'`ref'!=. & `use'==1 //compute the pooled SD across all treatment arms
			qui gen double `pooleddf'=(`n'`ref'-1) if `sd'`ref'!=. & `use'==1
			forvalues i=1/`dim'{
				qui replace `pooledsd'=`pooledsd'+(`n'`tr`i''-1)*`sd'`tr`i''^2 if `sd'`tr`i''!=.
				qui replace `pooleddf'=`pooleddf'+(`n'`tr`i''-1) if `sd'`tr`i''!=.
			}
			qui replace `pooledsd'=sqrt(`pooledsd'/`pooleddf')		
		}
		if "`method'"=="taylor"	{	//estimation via Taylor approximation
			
			tempvar var`ref' p`ref' ytot`ref' pobs`ref' ptot`ref' varobs`ref' varl`ref' g_`ref' q_`ref'
			
			qui gen double `p`ref''=`n'`ref'/(`n'`ref'+`m'`ref') `if' `in' //probabilities of the observations in reference arm
			
			if "`model'"=="logimrom"{
				gen double `ytot`ref''=`p`ref''*`y'`ref'+(1-`p`ref'')*(exp(`mul`ref''+(`sdl`ref''^2)/2)*`y'`ref') `if' `in' //'true' mean in reference arm
				/*'true' variance in reference arm*/
				gen double `var`ref''=((`p`ref''*(1-`p`ref''))/(`n'`ref'+`m'`ref'))*(1-2*exp(`mul`ref''+0.5*`sdl`ref''^2)+exp(2*`mul`ref''+2*`sdl`ref''^2))*`y'`ref'^2+(`sdnew`ref''^2/`n'`ref')*((1-`p`ref'')^2*exp(2*`mul`ref''+2*`sdl`ref''^2)+2*`p`ref''*(1-`p`ref'')*exp(`mul`ref''+0.5*`sdl`ref''^2)+`p`ref''^2)+exp(2*`mul`ref''+`sdl`ref''^2)*(exp(`sdl`ref''^2)-1)*((1-`p`ref'')*`y'`ref')^2 `if' `in' // 16may2016: corrected according to pairwise meta-analysis
			}
			if "`model'"=="imdom"{
				gen double `ytot`ref''=`p`ref''*`y'`ref'+(1-`p`ref'')*(`mul`ref''+`y'`ref') `if' `in' //'true' mean in reference arm
				/*'true' variance in reference arm*/
				gen double `var`ref''=((`p`ref''*(1-`p`ref''))/(`n'`ref'+`m'`ref'))*(`mul`ref''^2+`sdl`ref''^2)+(`sdnew`ref''^2/`n'`ref')+`sdl`ref''^2*(1-`p`ref'')^2 `if' `in'
			}
			if "`model'"=="logimor"{
				gen double `pobs`ref''=(`r'`ref'/`n'`ref') `if' `in' //observed percentage of successes in reference arm
				/*'true' percentage of successes in reference arm*/
				gen double `ptot`ref''=`p`ref''*`pobs`ref''+(1-`p`ref'')*((exp(`mul`ref'')*`pobs`ref'')/(exp(`mul`ref'')*`pobs`ref''+1-`pobs`ref'')) `if' `in'
				/*'true' variance arising from observed data in reference arm*/
				gen double `varobs`ref''=(`pobs`ref''*(1-`pobs`ref'')/`n'`ref')*(`p`ref''+(1-`p`ref'')*exp(`mul`ref'')/(`pobs`ref''*exp(`mul`ref'')+1-`pobs`ref'')^2)^2+(`p`ref''*(1-`p`ref'')/(`n'`ref'+`m'`ref'))*(`pobs`ref''*(1-`pobs`ref'')*(exp(`mul`ref'')-1)/(`pobs`ref''*exp(`mul`ref'')+1-`pobs`ref''))^2 `if' `in'
				/*'true' variance arising from IMP in reference arm*/
				gen double `varl`ref''=((1-`p`ref'')*`pobs`ref''*(1-`pobs`ref'')*exp(`mul`ref'')/(`pobs`ref''*exp(`mul`ref'')+1-`pobs`ref'')^2)*`sdl`ref'' `if' `in'	
				if "`measure'"=="rd"{
					gen `g_`ref''=1 `if' `in'
					gen `q_`ref''=1 `if' `in'
				}
				if "`measure'"=="rr"{
					gen double `g_`ref''=1/`ptot`ref'' `if' `in'	
					gen double `q_`ref''=1/`pobs`ref'' `if' `in'
				}
				if "`measure'"=="or"{
					gen double `g_`ref''=1/(`ptot`ref''*(1-`ptot`ref'')) `if' `in'	
					gen double `q_`ref''=1/(`pobs`ref''*(1-`pobs`ref'')) `if' `in'
				}
			}
			forvalues i=1/`dim'{
				qui replace `m'`tr`i''=0 if `m'`tr`i''==. & `use'==1	//zero missing participants if no information on missing participants in an arm
				tempvar cov`ref'_`tr`i'' p`tr`i'' var`tr`i'' ytot`tr`i'' vartot`tr`i'' _es_`tr`i'' _sees_`tr`i''
				tempvar f1_`tr`i'' f2_`tr`i'' f3_`tr`i'' f4_`tr`i'' es_`tr`i'' sees_`tr`i''
				tempvar or_`preY'`tr`i'' or_`preS'`tr`i''_`tr`i''
				tempvar pobs`tr`i'' ptot`tr`i'' varobs`tr`i'' varl`tr`i'' g_`tr`i'' q_`tr`i''
				
				qui gen double `p`tr`i'''=`n'`tr`i''/(`n'`tr`i''+`m'`tr`i'') `if' `in'	//probabilities of the observations in all non-reference arms
				qui{
					if "`model'"=="logimrom"{
						/*'true' variance in all non-reference arms*/
						gen double `var`tr`i'''=((`p`tr`i'''*(1-`p`tr`i'''))/(`n'`tr`i''+`m'`tr`i''))*(1-2*exp(`mul`tr`i'''+0.5*`sdl`tr`i'''^2)+exp(2*`mul`tr`i'''+2*`sdl`tr`i'''^2))*`y'`tr`i''^2+(`sdnew`tr`i'''^2/`n'`tr`i'')*((1-`p`tr`i''')^2*exp(2*`mul`tr`i'''+2*`sdl`tr`i'''^2)+2*`p`tr`i'''*(1-`p`tr`i''')*exp(`mul`tr`i'''+0.5*`sdl`tr`i'''^2)+`p`tr`i'''^2)+exp(2*`mul`tr`i'''+`sdl`tr`i'''^2)*(exp(`sdl`tr`i'''^2)-1)*((1-`p`tr`i''')*`y'`tr`i'')^2	`if' `in'
						gen double `ytot`tr`i'''=`p`tr`i'''*`y'`tr`i''+(1-`p`tr`i''')*(exp(`mul`tr`i'''+(`sdl`tr`i'''^2)/2)*`y'`tr`i'') `if' `in' //'true' mean in all non-reference arms
						/*covariance between the reference arm and each non-reference arm*/
						gen double `cov`ref'_`tr`i'''=`corrl`ref'`tr`i'''*`sdl`tr`i'''*`sdl`ref''*(1-`p`tr`i''')*(1-`p`ref'')*`y'`tr`i''*`y'`ref'*exp(`mul`tr`i'''+0.5*`sdl`tr`i'''^2)*exp(`mul`ref''+0.5*`sdl`ref''^2) `if' `in'	
					}
					if "`model'"=="imdom"{
						/*'true' variance in all non-reference arms*/
						gen double `var`tr`i'''=((`p`tr`i'''*(1-`p`tr`i'''))/(`n'`tr`i''+`m'`tr`i''))*(`mul`tr`i'''^2+`sdl`tr`i'''^2)+(`sdnew`tr`i'''^2/`n'`tr`i'')+`sdl`tr`i'''^2*(1-`p`tr`i''')^2
						gen double `ytot`tr`i'''=`p`tr`i'''*`y'`tr`i''+(1-`p`tr`i''')*(`mul`tr`i'''+`y'`tr`i'') `if' `in' //'true' mean in all non-reference arms
						/*covariance between the reference arm and each non-reference arm*/
						gen double `cov`ref'_`tr`i'''=`corrl`ref'`tr`i'''*`sdl`tr`i'''*`sdl`ref''*(1-`p`tr`i''')*(1-`p`ref'') `if' `in'
					}
					if "`model'"=="logimor"{
						gen double `pobs`tr`i'''=(`r'`tr`i''/`n'`tr`i'') `if' `in' //observed percentage of successes in all non-reference arms
						/*'true' percentage of successes in all non-reference arms*/
						gen double `ptot`tr`i'''=`p`tr`i'''*`pobs`tr`i'''+(1-`p`tr`i''')*((exp(`mul`tr`i''')*`pobs`tr`i''')/(exp(`mul`tr`i''')*`pobs`tr`i'''+1-`pobs`tr`i''')) `if' `in'
						/*'true' variance arising from observed data in all non-reference arms*/
						gen double `varobs`tr`i'''=(`pobs`tr`i'''*(1-`pobs`tr`i''')/`n'`tr`i'')*(`p`tr`i'''+(1-`p`tr`i''')*exp(`mul`tr`i''')/(`pobs`tr`i'''*exp(`mul`tr`i''')+1-`pobs`tr`i''')^2)^2+(`p`tr`i'''*(1-`p`tr`i''')/(`n'`tr`i''+`m'`tr`i''))*(`pobs`tr`i'''*(1-`pobs`tr`i''')*(exp(`mul`tr`i''')-1)/(`pobs`tr`i'''*exp(`mul`tr`i''')+1-`pobs`tr`i'''))^2 `if' `in' // 16may2016: corrected according to pairwise meta-analysis
						/*'true' variance arising from IMP in all non-reference arms*/
						gen double `varl`tr`i'''=((1-`p`tr`i''')*`pobs`tr`i'''*(1-`pobs`tr`i''')*exp(`mul`tr`i''')/(`pobs`tr`i'''*exp(`mul`tr`i''')+1-`pobs`tr`i''')^2)*`sdl`tr`i''' `if' `in'						
					}
					if "`measure'"=="md"{
						gen `f1_`tr`i'''=1 `if' `in'
						gen `f2_`tr`i'''=1 `if' `in'
						gen `f4_`tr`i'''=1 `if' `in'
						gen `f3_`tr`i'''=1 `if' `in'
						gen double `es_`tr`i'''=`ytot`tr`i'''-`ytot`ref'' `if' `in'  //estimate of 'true' MD for each treatment vs reference
					}
					if "`measure'"=="smd"{
						gen `f1_`tr`i'''=1 `if' `in'
						gen double `f2_`tr`i'''=1/`pooledsd'^2 `if' `in'
						gen `f4_`tr`i'''=1 `if' `in'
						gen `f3_`tr`i'''=1	`if' `in'			
						gen double `es_`tr`i'''=(`ytot`tr`i'''-`ytot`ref'')/(1/sqrt(`f2_`tr`i''')) `if' `in' //estimate of 'true' SMD for each treatment vs reference
					}
					if "`measure'"=="rom"{
						gen double `f1_`tr`i'''=1/(`ytot`ref''*`ytot`tr`i''') `if' `in'
						gen `f2_`tr`i'''=1 `if' `in'
						gen double `f3_`tr`i'''=1/(`y'`ref'^2) `if' `in'
						gen double `f4_`tr`i'''=1/(`y'`tr`i''^2) `if' `in'
						gen double `es_`tr`i'''=log(abs(`ytot`tr`i''')/abs(`ytot`ref'')) `if' `in' //estimate of 'true' RoM for each treatment vs reference
					}
					if "`measure'"=="rd"{
						gen double `es_`tr`i'''=`ptot`tr`i'''-`ptot`ref'' `if' `in' //estimate of 'true' RD for each treatment vs reference
						gen `g_`tr`i'''=1 `if' `in'
						gen `q_`tr`i'''=1 `if' `in'
					}
					if "`measure'"=="rr"{
						gen double `es_`tr`i'''=log(`ptot`tr`i''')-log(`ptot`ref'') `if' `in' //estimate of 'true' RR for each treatment vs reference
						gen double `g_`tr`i'''=1/`ptot`tr`i''' `if' `in'	
						gen double `q_`tr`i'''=1/`pobs`tr`i''' `if' `in'
					}
					if "`measure'"=="or"{
						gen double `es_`tr`i'''=logit(`ptot`tr`i''')-logit(`ptot`ref'') `if' `in' //estimate of 'true' OR for each treatment vs reference
						gen double `g_`tr`i'''=1/(`ptot`tr`i'''*(1-`ptot`tr`i''')) `if' `in'	
						gen double `q_`tr`i'''=1/(`pobs`tr`i'''*(1-`pobs`tr`i''')) `if' `in'
					}
					/*'true' variances for each treatment vs reference depending on model and measure*/
					if "`type'"=="cont"{
						gen double `vartot`tr`i'''=`f2_`tr`i'''*((`var`ref''*`f3_`tr`i'''+`var`tr`i'''*`f4_`tr`i''')-2*`f1_`tr`i'''*`cov`ref'_`tr`i''') `if' `in'
					}
					if "`type'"=="bin"{
						gen double `vartot`tr`i'''=`varobs`ref''*`g_`ref''^2+`varobs`tr`i'''*`g_`tr`i'''^2+(`varl`ref''*`q_`ref'')^2+(`varl`tr`i'''*`q_`tr`i''')^2-2*`corrl`ref'`tr`i'''*`varl`ref''*`q_`ref''*`varl`tr`i'''*`q_`tr`i''' `if' `in' // 16may2016: corrected according to pairwise meta-analysis
					}
					if "`varchange'"==""{
						qui gen double `or_`preY'`tr`i'''=`preY'`tr`i''		//save original effect sizes
						qui gen double `or_`preS'`tr`i''_`tr`i'''=`preS'`tr`i''_`tr`i''	//save original variances
					}
					/*use the estimated 'true' effect sizes and variances to run NMA*/
					replace `preY'`tr`i''=`es_`tr`i''' `if' `in'	
					replace `preS'`tr`i''_`tr`i''=`vartot`tr`i''' `if' `in'
					
					if "`type'"=="bin"{
						gen double `cov`ref'_`tr`i'''=`corrl`ref'`tr`i'''*`varl`ref''*`g_`ref''*`varl`tr`i'''*`g_`tr`i''' //covariance between the reference arm and each non-reference arm
					}
				}
			}
			forvalues i=1/`=`dim'-1'{					
				forvalues j=`=`i'+1'/`dim'{
					tempvar cov`tr`i''_`tr`j''
					/*covariance for each pair of non-reference arms*/
					if "`model'"=="logimrom"{
						qui gen double `cov`tr`i''_`tr`j'''=`corrl`tr`i''`tr`j'''*`sdl`tr`i'''*`sdl`tr`j'''*(1-`p`tr`i''')*(1-`p`tr`j''')*`y'`tr`i''*`y'`tr`j''*exp(`mul`tr`i'''+0.5*`sdl`tr`i'''^2)*exp(`mul`tr`j'''+0.5*`sdl`tr`j'''^2) `if' `in'	
					}
					if "`model'"=="imdom"{
						qui gen double `cov`tr`i''_`tr`j'''=`corrl`tr`i''`tr`j'''*`sdl`tr`i'''*`sdl`tr`j'''*(1-`p`tr`i''')*(1-`p`tr`j''') `if' `in'
					}
					if "`model'"=="logimor"{
						qui gen double `cov`tr`i''_`tr`j'''=`corrl`tr`i''`tr`j'''*`varl`tr`i'''*`g_`tr`i'''*`varl`tr`j'''*`g_`tr`j'''
					}
				}
			}
			forvalues i=1/`=`dim'-1'{		
				forvalues j=`=`i'+1'/`dim'{
					tempvar or_`preS'`tr`i''_`tr`j''
					if "`varchange'"==""{
						qui gen double `or_`preS'`tr`i''_`tr`j'''=`preS'`tr`i''_`tr`j''		//save original covariances
					}
					/*covariance between effect sizes depending on model and measure*/
					if "`type'"=="cont"{
						qui replace `preS'`tr`i''_`tr`j''=`f1_`tr`i'''*`cov`tr`i''_`tr`j'''-`f1_`tr`i'''*`cov`ref'_`tr`i'''-`f1_`tr`i'''*`cov`ref'_`tr`j'''+`var`ref''*`f3_`tr`i'''*`f2_`tr`i''' `if' `in'
					}
					if "`type'"=="bin"{
						qui replace `preS'`tr`i''_`tr`j''=`cov`tr`i''_`tr`j'''-`cov`ref'_`tr`i'''-`cov`ref'_`tr`j'''+`varobs`ref''*`g_`ref''^2+(`varl`ref''*`g_`ref'')^2
					}
				}
			}
		}
		
		if "`method'"=="bootstrap"{	//estimation via parametric bootstrap	

			forvalues i=1/`dim'{
				tempvar or_`preY'`tr`i'' or_`preS'`tr`i''_`tr`i''
				if "`varchange'"==""{
					qui gen double `or_`preY'`tr`i'''=`preY'`tr`i''		//save original effect sizes
					qui gen double `or_`preS'`tr`i''_`tr`i'''=`preS'`tr`i''_`tr`i''	//save original variances
				}
			}
			forvalues i=1/`=`dim'-1'{
				forvalues j=`=`i'+1'/`dim'{
					tempvar or_`preS'`tr`i''_`tr`j''
					if "`varchange'"==""{
						qui gen double `or_`preS'`tr`i''_`tr`j'''=`preS'`tr`i''_`tr`j''		//save original covariances
					}
				}
			}				

			/*get the estimated 'true' means and variances for all treatment arms from the function NETrandom()*/
			
			forvalues i=1/`nall'{	//run the function for each study in the network
				scalar snt=`narms`i''
				mat sn=`tn`i''
				mat snn=`tnn`i''
				mat sm=`tm`i''
				mat sz=`z`i''
				if "`type'"=="cont"{
					mat sy=`tmean`i''
					mat ssd=`tsd`i''
					scalar ssdpooled=`pooledsd' in `i'
				}
				if "`type'"=="bin"{
					mat sr=`tR`i''
				}
				mat muL=`MLcorr`i''
				mat varL=`SLcov`i''
				mat corrL=`Corr`i''
				
				mata NETrandom()
				
				mat colnames _mean=`ltr`i''
				mat colnames _var=`ltr`i''
				mat rownames _var=`ltr`i''
				qui{
					foreach trt in `ltr`i''{
						if "`trt'"=="`ref'" continue
						local posR`trt'=colnumb(_mean,"`trt'")
						replace `preY'`trt' in `i'=_mean[1,`posR`trt''] if `preY'`trt'!=.	//use the estimated 'true' effect sizes to run NMA
						replace `preS'`trt'_`trt' in `i'=_var[`posR`trt'',`posR`trt''] if `preS'`trt'_`trt'!=.	//use the estimated 'true' variances to run NMA
						foreach trt2 in `ltr`i''{
							if "`trt2'"=="`trt'" continue
							if "`trt2'"=="`ref'" continue
							local posR`trt2'=colnumb(_mean,"`trt2'")	//use the estimated 'true' covariances to run NMA
							cap replace `preS'`trt'_`trt2' in `i'=_var[`posR`trt'',`posR`trt2''] if `preS'`trt'_`trt2'!=.
							cap replace `preS'`trt2'_`trt' in `i'=_var[`posR`trt2'',`posR`trt''] if `preS'`trt2'_`trt'!=.
						}
					}
				}
			}
		}
		
		/*compare the results of different assumptions for IMP*/
		if `"`compare'"'!=""{
			global METAMISS2_impsd `impsd'
			global METAMISS2_compare `compare'
			global METAMISS2_type `type'
			
			if "`inconsistency'"!=""{
				global METAMISS2_inc `inconsistency'
			}
			else{
				global METAMISS2_inc ""
			}
			if "`netplot'"!=""{
				global METAMISS2_plot "plot"
				global METAMISS2_plotoptions `netplotoptions' 
				global METAMISS2_plotref `netplotref'
				global METAMISS2_trtlab `trtlab'
			}
			else{
				global METAMISS2_plot ""
			}
			if "`nokeep'"!=""{
				global METAMISS2_nokeep "nokeep"
			}
			else{
				global METAMISS2_nokeep ""
			}
			compare `anyhting'
		}
		
		/*run a sensitivity analysis using a range of standard deviations for IMP*/
		else if "`sensitivity'"!=""{	
			
			global METAMISS2_ntm `ntm'
			forvalues i=1/`ntm'{
				global METAMISS2_tr`i' `tr`i''
			}
			global METAMISS2_ref `ref'
		
			di as text _newline "*******************************************************************"
			di as text "**** METAMISS2: network meta-analysis allowing for missing data ***"
			di as text "******** Informative missingness parameter with uncertainty *******"
			di as text "****    Sensitivity analysis assuming departures from MAR     *****"
			di as text "*******************************************************************"
			
			sensitivity `anything', `options'	
		}
		
		else{		
		
		  /*run network meta-analysis using the estimated 'true' relative effects, variances, covariances*/
			di as text _newline "*******************************************************************"
			di as text "**** METAMISS2: network meta-analysis allowing for missing data ***"
			cap{ 	
				assert `tayl2'==1 & `tayl'==1
			}
			if _rc==0{
				di as text "********               Available cases analysis            ********"
			}
			cap{
				assert `tayl2'==0 & `tayl'==1
			}
			if _rc==0{
				di as text "****** Informative missingness parameter without uncertainty ******"
			}
			cap{
				assert  `tayl'==0
			}
			if _rc==0{
				di as text "******** Informative missingness parameter with uncertainty *******"
			}
			di as text "*******************************************************************"
			di as text _newline "Informative missingness parameter:" _col(36) _c
			if "$METAMISS2_model"=="imdom" di as result "IMDOM"
			if "$METAMISS2_model"=="logimrom" di as result "logIMROM"
			if "$METAMISS2_model"=="logimor" di as result "logIMOR"
			
			di as text "Measure of interest:" _col(36) _c
			if "$METAMISS2_measure"=="md" di as result "Mean difference"
			if "$METAMISS2_measure"=="smd" di as result "Standardized mean difference"	
			if "$METAMISS2_measure"=="rom" & "`eform'"!="" di as result "Ratio of means"	
			if "$METAMISS2_measure"=="rom" & "`eform'"=="" di as result "log(Ratio of means)"
			if "$METAMISS2_measure"=="or" & "`eform'"!="" di as result "Odds ratio"
			if "$METAMISS2_measure"=="or" & "`eform'"=="" di as result "log(Odds ratio)"
			if "$METAMISS2_measure"=="rr" & "`eform'"!="" di as result "Risk ratio"	
			if "$METAMISS2_measure"=="rr" & "`eform'"=="" di as result "log(Risk ratio)"
			if "$METAMISS2_measure"=="rd" di as result "Risk difference"

			cap assert  `tayl'==0
			if _rc==0{
				di as text "Assumed distribution for IMP:" _col(36) _c
				di as result "`ref' ~ N(`mulambda`ref'',`sdlambda`ref''^2)  (Reference group)"
				forvalues i=1/`dim'{
					di as result _col(36) "`tr`i'' ~ N(`mulambda`tr`i''',`sdlambda`tr`i'''^2)"
				}
				di as text "IMP correlation between groups:" _col(36) _c
				if "`corrtype'"=="diff" & "`corrstudy'"=="comm"	di as result "Matrix " _c
				di as result "`corr'"
			}

			di as text "Method for first stage model:" _col(36) _c
			if "$METAMISS2_method"=="taylor" di as result "Taylor series approximation"
			if "$METAMISS2_method"=="bootstrap" di as result "Parametric Bootstrap (`reps' draws)"

			di as text "Second stage model:" _col(36) _c
			if "`fixed'"!="" di as result "Fixed effect network meta-analysis"
			else di as result "Random effects network meta-analysis"	

			if "`nometa'"==""{
				di as text _newline "(Calling network meta " _c
				cap{ 
					assert "$METAMISS2_options"!=""
				}
				if _rc==0{
					if "$METAMISS2_compare"!=""{
						di as text "with options: $COMPARE_options" _c
					}
					else{
						di as text "with options: `options'" _c
					}
				}
				di as text " ...)" _newline
				
				if "`inconsistency'"==""{	//consistency model
					if "`fixed'"!=""{
						network meta c, fixed `options'	//fixed effect model
					}
					else{
						network meta c, `options'	//random effects model
					}	
				}
				else{	//inconsistency model
					if "`fixed'"!=""{
						network meta i, fixed `options'	//fixed effect model
					}
					else{
						network meta i, `options'	//random effects model
					}	
				}
				
				if "`netplot'"!=""{
					intervalplot, `netplotoptions' ref(`netplotref') lab(`trtlab')	//draw a forest plot of the NMA results
				}
			}
			if "`nokeep'"==""{
				cap drop _imp_*
				forvalues i=1/`dim'{
					qui gen double _imp_`preY'`tr`i''=`preY'`tr`i''
					qui gen double _imp_`preS'`tr`i''_`tr`i''=`preS'`tr`i''_`tr`i''
					forvalues j=`=`i'+1'/`dim'{
						qui gen double _imp_`preS'`tr`i''_`tr`j''=`preS'`tr`i''_`tr`j''
					}
				}
			}
			/*obtain again original effect sizes, variances, covariances*/
			if "`varchange'"==""{
				forvalues i=1/`dim'{
					qui replace `preY'`tr`i''=`or_`preY'`tr`i'''
					qui replace `preS'`tr`i''_`tr`i''=`or_`preS'`tr`i''_`tr`i'''
				}
				forvalues i=1/`=`dim'-1'{
					forvalues j=`=`i'+1'/`dim'{
						qui replace `preS'`tr`i''_`tr`j''=`or_`preS'`tr`i''_`tr`j'''
					}
				}
			}
		}
		
	}

	if "`network'"=="off"{
		tempvar pc pt ytotc ytott covf f1 varc vart f2 vartot f3 f4 varobsc varobst pobsc pobst varlc varlt ptotc ptott gc gt qc qt
		qui{
			if "`type'"=="bin"{
				tempvar contcorr
				qui gen `contcorr'=1 if (`rc'==0 | `fc'==0) & `use'==1
				replace `rc'=`rc'+0.5 if `contcorr'==1	//continuity correction for zero cells
				replace `rt'=`rt'+0.5 if `contcorr'==1
				replace `fc'=`fc'+0.5 if `contcorr'==1
				replace `ft'=`ft'+0.5 if `contcorr'==1
			}
			replace `mc'=0 if `mc'==. & `use'==1	//zero missing participants in each arm if no information on missing participants
			replace `mt'=0 if `mt'==. & `use'==1
		
			/*probabilities of the observations in control and treatment arms*/
			if "`type'"=="cont"{
				gen double `pc'=`nc'/(`nc'+`mc') `if' `in'
				gen double `pt'=`nt'/(`nt'+`mt') `if' `in'
				
				tempvar pooleddf
				replace `pooledsd'=(`nc'-1)*`sdc'^2+(`nt'-1)*`sdt'^2 `if' `in' //compute the SDpooled and dfpooled
				gen double `pooleddf'=(`nc'-1)+(`nt'-1) `if' `in'
				replace `pooledsd'=sqrt(`pooledsd'/`pooleddf')
			}
			if "`type'"=="bin"{
				gen double `pc'=(`rc'+`fc')/(`rc'+`fc'+`mc') `if' `in'
				gen double `pt'=(`rt'+`ft')/(`rt'+`ft'+`mt') `if' `in'
			}
			cap drop _es _sees
			
			if "`method'"=="taylor"{ //estimation via Taylor approximation
				if "`model'"=="logimrom"{
					gen double `ytotc'=`pc'*`yc'+(1-`pc')*(exp(`mulc'+(`sdlc'^2)/2)*`yc') `if' `in' //'true' mean in control arm 
					gen double `ytott'=`pt'*`yt'+(1-`pt')*(exp(`mult'+(`sdlt'^2)/2)*`yt') `if' `in' //'true' mean in treatment arm
					/*covariance between treatment and cotrol arms*/
					gen double `covf'=`corrl'*`sdlt'*`sdlc'*(1-`pt')*(1-`pc')*`yt'*`yc'*exp(`mult'+0.5*`sdlt'^2)*exp(`mulc'+0.5*`sdlc'^2) `if' `in'
					/*'true' variance in control arm */
					gen double `varc'=((`pc'*(1-`pc'))/(`nc'+`mc'))*(1-2*exp(`mulc'+0.5*`sdlc'^2)+exp(2*`mulc'+2*`sdlc'^2))*`yc'^2+(`sdnewc'^2/`nc')*((1-`pc')^2*exp(2*`mulc'+2*`sdlc'^2)+2*`pc'*(1-`pc')*exp(`mulc'+0.5*`sdlc'^2)+`pc'^2)+exp(2*`mulc'+`sdlc'^2)*(exp(`sdlc'^2)-1)*((1-`pc')*`yc')^2 `if' `in'
					/*'true' variance in treatment arm */
					gen double `vart'=((`pt'*(1-`pt'))/(`nt'+`mt'))*(1-2*exp(`mult'+0.5*`sdlt'^2)+exp(2*`mult'+2*`sdlt'^2))*`yt'^2+(`sdnewt'^2/`nt')*((1-`pt')^2*exp(2*`mult'+2*`sdlt'^2)+2*`pt'*(1-`pt')*exp(`mult'+0.5*`sdlt'^2)+`pt'^2)+exp(2*`mult'+`sdlt'^2)*(exp(`sdlt'^2)-1)*((1-`pt')*`yt')^2	`if' `in'		
				}
				if "`model'"=="imdom"{
					gen double `ytotc'=`pc'*`yc'+(1-`pc')*(`mulc'+`yc') `if' `in' //'true' mean in control arm 
					gen double `ytott'=`pt'*`yt'+(1-`pt')*(`mult'+`yt') `if' `in' //'true' mean in treatment arm
					/*covariance between treatment and cotrol arms*/
					gen double `covf'=`corrl'*`sdlt'*`sdlc'*(1-`pt')*(1-`pc') `if' `in'
					/*'true' variance in control arm */
					gen double `varc'=((`pc'*(1-`pc'))/(`nc'+`mc'))*(`mulc'^2+`sdlc'^2)+(`sdnewc'^2/`nc')+`sdlc'^2*(1-`pc')^2 `if' `in'
					/*'true' variance in treatment arm */
					gen double `vart'=((`pt'*(1-`pt'))/(`nt'+`mt'))*(`mult'^2+`sdlt'^2)+(`sdnewt'^2/`nt')+`sdlt'^2*(1-`pt')^2 `if' `in'	
				}
				if "`model'"=="logimor"{
					gen double `pobsc'=(`rc'/(`rc'+`fc')) `if' `in'	//observed percentage of successes in control arm
					gen double `pobst'=(`rt'/(`rt'+`ft')) `if' `in'	//observed percentage of successes in treatment arm
					/*'true' percentage of successes in control arm*/
					gen double `ptotc'=`pc'*`pobsc'+(1-`pc')*((exp(`mulc')*`pobsc')/(exp(`mulc')*`pobsc'+1-`pobsc')) `if' `in'
					/*'true' percentage of successes in treatment arm*/
					gen double `ptott'=`pt'*`pobst'+(1-`pt')*((exp(`mult')*`pobst')/(exp(`mult')*`pobst'+1-`pobst')) `if' `in'
					/*'true' variance arising from observed data in control arm*/
					gen double `varobsc' = (`pobsc'* (1-`pobsc')/(`rc'+`fc')) * (`pc'+(1-`pc')*exp(`mulc')/(`pobsc'*exp(`mulc')+1-`pobsc')^2)^2 + (`pc'*(1-`pc')/(`rc'+`fc'+`mc')) * (`pobsc'*(1-`pobsc')*(exp(`mulc')-1)/(`pobsc'*exp(`mulc')+1-`pobsc'))^2 `if' `in' // 18mar2016: inserted final ^2
					/*'true' variance arising from observed data in treatment arm*/
					gen double `varobst' = (`pobst'*(1-`pobst')/(`rt'+`ft')) * (`pt'+(1-`pt')*exp(`mult')/(`pobst'*exp(`mult')+1-`pobst')^2)^2 + (`pt'*(1-`pt')/(`rt'+`ft'+`mt')) * (`pobst'*(1-`pobst')*(exp(`mult')-1)/(`pobst'*exp(`mult')+1-`pobst'))^2 `if' `in' // 18mar2016: inserted final ^2
					/*'true' variance arising from IMP in control arm*/
					gen double `varlc'=((1-`pc')*`pobsc'*(1-`pobsc')*exp(`mulc')/(`pobsc'*exp(`mulc')+1-`pobsc')^2)*`sdlc' `if' `in'
					/*'true' variance arising from IMP in treatment arm*/
					gen double `varlt'=((1-`pt')*`pobst'*(1-`pobst')*exp(`mult')/(`pobst'*exp(`mult')+1-`pobst')^2)*`sdlt' `if' `in'
				}
				if "`measure'"=="md"{
					gen `f1'=1 `if' `in'
					gen `f2'=1 `if' `in'
					gen `f4'=1 `if' `in'
					gen `f3'=1 `if' `in'
					gen double _es=`ytott'-`ytotc' `if' `in' //estimate of 'true' MD treatment vs. control
				}
				if "`measure'"=="smd"{
					gen `f1'=1 `if' `in'
					gen double `f2'=1/`pooledsd'^2 `if' `in'
					gen `f4'=1 `if' `in'
					gen `f3'=1	`if' `in'			
					gen double _es=(`ytott'-`ytotc')/(1/sqrt(`f2')) `if' `in' //estimate of 'true' SMD treatment vs. control
				}
				if "`measure'"=="rom"{
					gen double `f1'=1/(`ytotc'*`ytott') `if' `in'
					gen `f2'=1 `if' `in'
					gen double `f3'=1/(`yc'^2) `if' `in'
					gen double `f4'=1/(`yt'^2) `if' `in'
					gen double _es=log(abs(`ytott')/abs(`ytotc')) `if' `in' //estimate of 'true' RoM treatment vs. control
				}
				if "`measure'"=="rd"{
					gen double _es=`ptott'-`ptotc' `if' `in'	//estimate of 'true' RD treatment vs. control
					gen `gc'=1 `if' `in'
					gen `gt'=1 `if' `in'
					gen `qc'=1 `if' `in'
					gen `qt'=1 `if' `in'
				}
				if "`measure'"=="rr"{
					gen double _es=log(`ptott')-log(`ptotc') `if' `in'	//estimate of 'true' RR treatment vs. control
					gen `gc'=1/`ptotc' `if' `in'
					gen `gt'=1/`ptott' `if' `in'
					gen `qc'=1/`pobsc' `if' `in'
					gen `qt'=1/`pobst' `if' `in'
				}				
				if "`measure'"=="or"{
					gen double _es=logit(`ptott')-logit(`ptotc') `if' `in'	//estimate of 'true' OR treatment vs. control
					gen `gc'=1/(`ptotc'*(1-`ptotc')) `if' `in'
					gen `gt'=1/(`ptott'*(1-`ptott')) `if' `in'
					gen `qc'=1/(`pobsc'*(1-`pobsc')) `if' `in'
					gen `qt'=1/(`pobst'*(1-`pobst')) `if' `in'
				}				
				/*'true' variances depending on model and measure*/
				if "`type'"=="cont"{
					gen double `vartot'=`f2'*((`varc'*`f3'+`vart'*`f4')-2*`f1'*`covf') `if' `in' 
				}
				if "`type'"=="bin"{
					gen double `vartot'=`varobsc'*`gc'^2+`varobst'*`gt'^2+(`varlc'*`qc')^2+(`varlt'*`qt')^2-2*`corrl'*`varlc'*`qc'*`varlt'*`qt' `if' `in' // 16may2016: corrected gc, gt with qc, qt when necessary
				}				
				gen double _sees=sqrt(`vartot') `if' `in'
			} 
		}	
		if "`method'"=="bootstrap"{	//estimation via parametric bootstrap
	
			tempvar rank nomiss zeromissc zeromisst
			
			qui gen `zeromissc'=(`mc'==0)
			qui gen `zeromisst'=(`mt'==0)
			
			qui replace `mc'=0.15 if `mc'==0 & `use'==1	//required to allow the use of beta distribution for all studies - not used in the estimation
			qui replace `mt'=0.15 if `mt'==0 & `use'==1
			
			if "`type'"=="cont"{
				qui gen `nomiss'=1 if `use'==1 & `sdc'!=. & `sdt'!=. & `mc'!=.	//missing values not allowed in mata distributions
			}
			if "`type'"=="bin"{
				qui gen `nomiss'=1 if `use'==1 & `rc'!=. & `rt'!=. & `mc'!=.
			}
			qui gen `rank'=_n
			
			/*transfer the observed values into mata using matrices*/
			
			mkmat `mc' if `nomiss'==1 ,mat(Mmc) 
			mkmat `mt' if `nomiss'==1 ,mat(Mmt) 
			mat Mmc=Mmc'
			mat Mmt=Mmt'
			
			mkmat `zeromissc' if `nomiss'==1 ,mat(Mzc) 
			mkmat `zeromisst' if `nomiss'==1 ,mat(Mzt)
			mat Mzc=Mzc'
			mat Mzt=Mzt'
			
			if "`type'"=="cont"{
				mkmat `yc' if `nomiss'==1 ,mat(Myc) 
				mkmat `yt' if `nomiss'==1 ,mat(Myt) 
				mkmat `sdnewc' if `nomiss'==1 ,mat(Msdc) 
				mkmat `sdnewt' if `nomiss'==1 ,mat(Msdt) 
				mkmat `nc' if `nomiss'==1 ,mat(Mnc) 
				mkmat `nt' if `nomiss'==1 ,mat(Mnt) 
				mkmat `pooledsd' if `nomiss'==1 ,mat(Msdp) 
				mat Myc=Myc'
				mat Myt=Myt'
				mat Msdc=Msdc'
				mat Msdt=Msdt'
				mat Mnc=Mnc'
				mat Mnt=Mnt'
				mat Msdp=Msdp'
				scalar Mns=colsof(Msdc)
			}
			if "`type'"=="bin"{
				mkmat `rc' if `nomiss'==1 ,mat(Mrc) 
				mkmat `rt' if `nomiss'==1 ,mat(Mrt)
				mkmat `fc' if `nomiss'==1 ,mat(Mfc) 
				mkmat `ft' if `nomiss'==1 ,mat(Mft)
				mat Mrc=Mrc'
				mat Mrt=Mrt'
				mat Mfc=Mfc'
				mat Mft=Mft'
				scalar Mns=colsof(Mrc)
			}
			mkmat `mulc' if `nomiss'==1 ,mat(Mmulc) 
			mkmat `sdlc' if `nomiss'==1 ,mat(Msdlc) 
			mkmat `mult' if `nomiss'==1 ,mat(Mmult) 
			mkmat `sdlt' if `nomiss'==1 ,mat(Msdlt) 
			mkmat `corrl' if `nomiss'==1 ,mat(Mcorr) 
			mat Mmulc=Mmulc'
			mat Msdlc=Msdlc'
			mat Mmult=Mmult'
			mat Msdlt=Msdlt'
			mat Mcorr=Mcorr'		
			
			/*get the estimated 'true' means and variances for treatment and control arms from the function random()*/
			mata random()
			
			mat _mean=_mean'
			mat _var=_var'	
			
			qui sort `nomiss' `rank'
			cap drop _mean1 _var1
			qui svmat _mean, name(_mean)
			qui svmat _var, name(_var)
			qui rename _mean1 _mean
			qui rename _var1 _var							
			
			cap drop _es _sees
			qui sort `rank'
			
			qui gen double _es=_mean	//estimate the 'true' relative effects
			qui gen double _sees=sqrt(_var)	//estimate the 'true' variances
		}		
		
		/*compare the results of different assumptions for the IMP*/
		if `"`compare'"'!=""{
			global METAMISS2_impsd `impsd'
			global METAMISS2_compare `compare'
			global METAMISS2_type `type'
			if "`nokeep'"!=""{
				global METAMISS2_nokeep "nokeep"
			}
			else{
				global METAMISS2_nokeep ""
			}
			
			compare `anyhting'
		}	
		
		/*run a sensitivity analysis using a range of standard deviations for the IMP*/
		else if "`sensitivity'"!=""{	

			di as text _newline "*******************************************************************"
			di as text "******** METAMISS2: meta-analysis allowing for missing data *******"
			di as text "******** Informative missingness parameter with uncertainty *******"
			di as text "****    Sensitivity analysis assuming departures from MAR     *****"
			di as text "*******************************************************************"
			
			sensitivity `anyhting', `options'
			
			cap drop _ES _seES
		}
		
		else{
		
			/*run meta-analysis using the estimated 'true' relative effects and variances*/

			di as text _newline "*******************************************************************"
			di as text "******** METAMISS2: meta-analysis allowing for missing data *******"
			cap{ 	
				assert `mulambdat'==0 & `mulambdac'==0 & `sdlambdat'==0 & `sdlambdac'==0 
			}
			if _rc==0{
				di as text "********               Available cases analysis            ********"
			}
			cap{
				assert (`mulambdat'!=0 | `mulambdac'!=0) & `sdlambdat'==0 & `sdlambdac'==0
			}
			if _rc==0{
				di as text "****** Informative missingness parameter without uncertainty ******"
			}
			cap{
				assert `sdlambdat'!=0 | `sdlambdac'!=0
			}
			if _rc==0{
				di as text "******** Informative missingness parameter with uncertainty *******"
			}
			di as text "*******************************************************************"
			di as text _newline "Informative missingness parameter:" _col(36) _c
			if "$METAMISS2_model"=="imdom" di as result "IMDOM"
			if "$METAMISS2_model"=="logimrom" di as result "logIMROM"
			if "$METAMISS2_model"=="logimor" di as result "logIMOR"
			di as text "Measure of interest:" _col(36) _c
			if "$METAMISS2_measure"=="md" di as result "Mean difference"
			if "$METAMISS2_measure"=="smd" di as result "Standardized mean difference"	
			if "$METAMISS2_measure"=="rom" & "`eform'"!="" di as result "Ratio of means"
			if "$METAMISS2_measure"=="rom" & "`eform'"=="" di as result "log(Ratio of means)"
			if "$METAMISS2_measure"=="or" & "`eform'"!="" di as result "Odds ratio"
			if "$METAMISS2_measure"=="or" & "`eform'"=="" di as result "log(Odds ratio)"
			if "$METAMISS2_measure"=="rr" & "`eform'"!="" di as result "Risk ratio"
			if "$METAMISS2_measure"=="rr" & "`eform'"=="" di as result "log(Risk ratio)"
			if "$METAMISS2_measure"=="rd" di as result "Risk difference"
			
			cap{
				assert `sdlambdat'!=0 | `sdlambdac'!=0
			}
			if _rc==0{
				di as text "Assumed distribution for IMP:" _col(36) _c
				di as result "Experimental group ~ N(`mulambdat',`sdlambdat'^2)" 
				di as result _col(36) "Control group ~ N(`mulambdac',`sdlambdac'^2)" 
				di as text "IMP correlation between groups:" _col(36) _c
				di as result "`corr'"			
			}
			di as text "Method for first stage model:" _col(36) _c
			if "$METAMISS2_method"=="taylor" di as result "Taylor series approximation"
			if "$METAMISS2_method"=="bootstrap" di as result "Parametric Bootstrap (`reps' draws)"
			
			di as text "Second stage model:" _col(36) _c
			if "`fixed'"!="" di as result "Fixed effect meta-analysis"
			else di as result "Random effects meta-analysis"

			if "`nometa'"==""{
				di as text _newline "(Calling `command' " _c
				cap{ 
					assert "$METAMISS2_options"!=""
				}
				if _rc==0{
					if "$METAMISS2_compare"!=""{
						di as text "with options: $COMPARE_options" _c
					}
					else{
						di as text "with options: `options'" _c
					}
				}
				di as text " ...)"	
			}	
			tempvar es sees
			cap gen double `es'=_es
			cap gen double `sees'=_sees
			cap drop _es _sees
			
			if "`nometa'"==""{	
				if "`measure'"=="md"{
					local effect "MD"
				}
				if "`measure'"=="smd"{
					local effect "SMD"
				}
				if "`measure'"=="rom"{
					if "`eform'"!=""{
						local effect "RoM"
					}
					else{
						local effect "lnRoM"
					}
				}
				if "`measure'"=="or"{
					if "`eform'"!=""{
						local effect "OR"
					}
					else{
						local effect "lnOR"
					}
				}
				if "`measure'"=="rr"{
					if "`eform'"!=""{
						local effect "RR"
					}
					else{
						local effect "lnRR"
					}
				}
				if "`measure'"=="rd"{
					local effect "RD"
				}
				if "`fixed'"!=""{
					qui metan `es' `sees', fixed `options' effect(`effect') `eform' nokeep nograph
					if _rc==0{
						metan `es' `sees', fixed `options' effect(`effect') `eform'	//fixed effect model
						cap drop _ES
						cap drop _seES
						qui gen double _ES=`es'
						qui gen double _seES=`sees'
					}
				}
				else{
					if "`command'"=="metan"{
						qui metan `es' `sees', random `options' effect(`effect') `eform' nokeep nograph
						if _rc==0{
							metan `es' `sees', random `options' effect(`effect') `eform'	//random effects model
							cap drop _ES
							cap drop _seES
							qui gen double _ES=`es'
							qui gen double _seES=`sees'
						}
					}
					if "`command'"=="metaan"{
						qui metaan `es' `sees', `tau2' 
						if _rc==0{
							metaan `es' `sees', `tau2' forest
							cap drop _ES
							cap drop _seES
							qui gen double _ES=`es'
							qui gen double _seES=`sees'							
						}
					}
				}
			}
			if "`nokeep'"==""{
				if "$METAMISS2_measure"=="md"{
					label var _ES MD
					label var _seES "se(MD)"
				}
				if "$METAMISS2_measure"=="smd"{
					label var _ES SMD
					label var _seES "se(SMD)"
				}	
				if "$METAMISS2_measure"=="rom"{
					label var _ES lnRoM
					label var _seES "se(lnRoM)"
				}		
				if "$METAMISS2_measure"=="or"{
					label var _ES lnOR
					label var _seES "se(lnOR)"
				}
				if "$METAMISS2_measure"=="rr"{
					label var _ES lnRR
					label var _seES "se(lnRR)"
				}	
				if "$METAMISS2_measure"=="rd"{
					label var _ES RD
					label var _seES "se(RD)"
				}
			}
			else{
				cap drop _ES _seES _LCI _UCI _SS _WT
			}
		}
		cap replace `mc'=0 if `mc'<1 & `use'==1
		cap replace `mt'=0 if `mt'<1 & `use'==1
		cap replace `rc'=`rc'-0.5 if `contcorr'==1	//obtain back the zero cells
		cap replace `rt'=`rt'-0.5 if `contcorr'==1
		cap replace `fc'=`fc'-0.5 if `contcorr'==1
		cap replace `ft'=`ft'-0.5 if `contcorr'==1		
		
		qui sort `rankstart'

		cap scalar drop Mreps Mns Mod Meas Dat Mseed
		cap mat drop Mmc Mmt Mmulc Msdlc Mmult Msdlt Mcorr Mzt Mzc
		cap mat drop Myc Myt Msdc Msdt Mnc Mnt Msdp
		cap mat drop Mrt Mrc Mft Mfc
		cap mat drop Mn Mm Mnr Mnr2 Mmr Mz Mzr Mmulr Msdlnr Mmulnr Msdlr Mcorr
		cap mat drop My Msd Myr Msdr
		cap mat drop Mr Mrr
		cap drop _mean* _var*
	}
end
********************************************************************************************************************************************************
/*generate random samples for the bootstrap method for the case of network meta-analysis*/	
mata
void NETrandom()
{
	dat=st_numscalar("Dat")
	mod=st_numscalar("Mod")
	meas=st_numscalar("Meas")
	reps=st_numscalar("Mreps")
	snt=st_numscalar("snt")
	seed=st_numscalar("Mseed")
	
	m=st_matrix("sm")
	z=st_matrix("sz")
	n=st_matrix("sn")
	if (dat==1){
		sd=st_matrix("ssd")
		sdp=st_numscalar("ssdpooled")
		y=st_matrix("sy")
	}
	if (dat==2){
		r=st_matrix("sr")
		f=n-r
	}
	SC=st_matrix("varL")	//cholesky decomposition of variance-covariance matrix for lambda
	ML=st_matrix("muL")	//vector of means for lambda
	
	rseed(seed)
	
	P=rbeta(reps,1,n,m)	//beta distribution on the non-missing rates for each arm
	for (i=1; i<=rows(P); i++){
		for (j=1; j<=cols(P); j++){
			if (z[1,j]==1){
				P[i,j]=1	//use P=1 if missing equals zero in a study arm
			}
		}
	}
	/*LR=rnormal(reps,1,mulambdar,sdlambdar)	//bivariate normal distribution on IMPs
	Mlambdanr=LR
	Slambdanr=LR
	for (i=1; i<=rows(Mlambdanr); i++){
		for (j=1; j<=cols(Mlambdanr); j++){
			Mlambdanr[i,j]=mulambdanr[1,j]+(sdlambdanr/sdlambdar)*corr[1,j]*(LR[i,j]-mulambdar[1,j])
			Slambdanr[i,j]=sdlambdanr[1,j]*sqrt(1-corr[1,j]*corr[1,j])
		}
	}
	LNR=rnormal(1,1,Mlambdanr,Slambdanr)*/
	
	LN=rnormal(reps,snt,0,1) //normal draws with mean 0 and sd 1
	MVNL=LN*SC
	for (i=1; i<=rows(MVNL); i++){
		for (j=1; j<=cols(MVNL); j++){
			MVNL[i,j]=MVNL[i,j]+ML[1,j]	//mulitvarite draws with desired means and sds
		}
	}
	if (dat==1){	//continuous data
		sigma=sd
		for (i=1; i<=cols(sigma); i++){
			sigma[1,i] = sd[1,i]/sqrt(n[1,i])
		}
		Y=rnormal(reps,1,y,sigma)	//normal distribution on the means for each arm

		YM=Y
		if (mod==2){
			for (i=1; i<=rows(YM); i++){
				for (j=1; j<=cols(YM); j++){
					YM[i,j]=exp(MVNL[i,j])*Y[i,j]	//means of missing participants for each arm when logIMRoM
				}	
			}
		}
		if (mod==1){
			for (i=1; i<=rows(YM); i++){
				for (j=1; j<=cols(YM); j++){
					YM[i,j]=MVNL[i,j]+Y[i,j]	//means of missing participants for each arm when IMDoM
				}
			}
		}
		Ytrue=YM
		for (i=1; i<=rows(Ytrue); i++){
			for (j=1; j<=cols(Ytrue); j++){
				Ytrue[i,j] = P[i,j]*Y[i,j]+(1-P[i,j])*YM[i,j]	//'true' means for each arm
			}
		}
		if (meas==1){
			YtrueR=Ytrue	//mean differences
		}
		if (meas==2){
			YtrueR=Ytrue
			for (i=1; i<=rows(YtrueR); i++){
				for (j=1; j<=cols(YtrueR); j++){		
					YtrueR[i,j]=Ytrue[i,j]/sdp	//standardized mean differences
				}
			}		
		}	
		if (meas==3){	
			YtrueR=Ytrue
			for (i=1; i<=rows(YtrueR); i++){
				for (j=1; j<=cols(YtrueR); j++){		
					YtrueR[i,j]=log(abs(Ytrue[i,j]))	//ratio of means
				}
			}				
		}
	}
	if (dat==2){	//binary data
		RP=rbeta(reps,1,r,f)	//beta distribution on the success rate for each arm

		Ptrue=RP
		if (mod==1){
			for (i=1; i<=rows(Ptrue); i++){
				for (j=1; j<=cols(Ptrue); j++){
				Ptrue[i,j] = P[i,j]*RP[i,j]+(1-P[i,j])*((RP[i,j]*exp(MVNL[i,j]))/(RP[i,j]*exp(MVNL[i,j])+1-RP[i,j])) //'true' percentage of successes for each arm when logIMOR
				}
			}	
		}		
		if (meas==1){
			YtrueR=Ptrue
			for (i=1; i<=rows(YtrueR); i++){
				for (j=1; j<=cols(YtrueR); j++){		
					YtrueR[i,j]=logit(Ptrue[i,j])	//odds ratios
				}
			}			
		}
		if (meas==2){
			YtrueR=Ptrue
			for (i=1; i<=rows(YtrueR); i++){
				for (j=1; j<=cols(YtrueR); j++){		
					YtrueR[i,j]=log(Ptrue[i,j])	//risk ratios
				}
			}
		}
		if (meas==3){
			YtrueR=Ptrue	//risk differences
		}
	}
	ES=YtrueR
	for (i=1; i<=rows(ES); i++){
		for (j=1; j<=cols(ES); j++){
			ES[i,j]=YtrueR[i,j]-YtrueR[i,1]
		}
	}
	Mean=mean(ES)	//'true' mean of effect size
	Var=variance(ES)
	/*Varnew=J(1,snt,0)	
	for (i=1; i<=cols(Varnew); i++){
		Varnew[1,i]=Var[i,i]	//'true' variance of effect size	
	}*/
	
	st_matrix("_mean",Mean)
	st_matrix("_var",Var)
		
}
end

/*generate random samples for the bootstrap method for the case of standard meta-analysis*/	
mata
void random()
{	
	mod=st_numscalar("Mod")
	meas=st_numscalar("Meas")	
	dat=st_numscalar("Dat")

	mulambdac=st_matrix("Mmulc")
	sdlambdac=st_matrix("Msdlc")
	mulambdat=st_matrix("Mmult")
	sdlambdat=st_matrix("Msdlt")
	corr=st_matrix("Mcorr")

	reps=st_numscalar("Mreps")
	ns=st_numscalar("Mns")
	seed=st_numscalar("Mseed")

	mc=st_matrix("Mmc")
	mt=st_matrix("Mmt")
	
	zc=st_matrix("Mzc")
	zc=st_matrix("Mzc")
	zt=st_matrix("Mzt")

	if (dat==1){
		yc=st_matrix("Myc")
		yt=st_matrix("Myt")	
		nc=st_matrix("Mnc")
		nt=st_matrix("Mnt")	
		sdt=st_matrix("Msdt")
		sdc=st_matrix("Msdc")
		sdp=st_matrix("Msdp")
	}
	if (dat==2){
		rc=st_matrix("Mrc")
		rt=st_matrix("Mrt")	
		fc=st_matrix("Mfc")
		ft=st_matrix("Mft")	
		nc=rc+fc
		nt=rt+ft
	}	
	
	rseed(seed)
	
	PC=rbeta(reps,1,nc,mc) //beta distribution on the non-missing rates for treatment and control arms
	PT=rbeta(reps,1,nt,mt)
	for (i=1; i<=rows(PC); i++){
		for (j=1; j<=cols(PC); j++){
			if (zc[1,j]==1){
				PC[i,j]=1
			}
			if (zt[1,j]==1){
				PT[i,j]=1
			}
		}
	}
	LC=rnormal(reps,1,mulambdac,sdlambdac) //bivariate normal distribution on IMPs
	Mlambdat=LC
	Slambdat=LC
	for (i=1; i<=rows(Mlambdat); i++){
		for (j=1; j<=cols(Mlambdat); j++){
			Mlambdat[i,j]=mulambdat[1,j]+(sdlambdat[1,j]/sdlambdac[1,j])*corr[1,j]*(LC[i,j]-mulambdac[1,j])
			Slambdat[i,j]=sdlambdat[1,j]*sqrt(1-corr[1,j]*corr[1,j])
		}
	}
	LT=rnormal(1,1,Mlambdat,Slambdat)	
	if (dat==1){	//continuous data
		sigmac=sdc
		sigmat=sdt
		for (i=1; i<=cols(sigmac); i++){
			sigmac[1,i] = sdc[1,i]/sqrt(nc[1,i])
			sigmat[1,i] = sdt[1,i]/sqrt(nt[1,i])
		}
		
		YC=rnormal(reps,1,yc,sigmac) //normal distribution on the means for treatment and control arms
		YT=rnormal(reps,1,yt,sigmat)
	
		if (mod==2){
			YMC=YC
			YMT=YT
			for (i=1; i<=rows(YMC); i++){
				for (j=1; j<=cols(YMC); j++){
					YMC[i,j]=exp(LC[i,j])*YC[i,j] //means from missing participants for treatment and control arms when logIMRoM
					YMT[i,j]=exp(LT[i,j])*YT[i,j]
				}	
			}
		}
		if (mod==1){	
			YMC=LC+YC //means from missing participants for treatment and control arms when IMDoM
			YMT=LT+YT	
		}
		YCtrue=YMC
		YTtrue=YMT
		for (i=1; i<=rows(YCtrue); i++){
			for (j=1; j<=cols(YCtrue); j++){
				YCtrue[i,j] = PC[i,j]*YC[i,j]+(1-PC[i,j])*YMC[i,j] //'true' means for treatment and control arms
				YTtrue[i,j] = PT[i,j]*YT[i,j]+(1-PT[i,j])*YMT[i,j]
			}
		}	
		if (meas==1){
			YtrueRC=YCtrue	//mean differences
			YtrueRT=YTtrue
		}
		if (meas==2){
			YtrueRC=YCtrue
			YtrueRT=YTtrue
			for (i=1; i<=rows(YtrueRC); i++){
				for (j=1; j<=cols(YtrueRC); j++){		
					YtrueRC[i,j]=YCtrue[i,j]/sdp[1,j]	//standardized mean differences
				}
			}
			for (i=1; i<=rows(YtrueRT); i++){
				for (j=1; j<=cols(YtrueRT); j++){		
					YtrueRT[i,j]=YTtrue[i,j]/sdp[1,j]	
				}
			}			
		}
		if (meas==3){
			YtrueRC=YCtrue
			YtrueRT=YTtrue
			for (i=1; i<=rows(YtrueRC); i++){
				for (j=1; j<=cols(YtrueRC); j++){		
					YtrueRC[i,j]=log(abs(YCtrue[i,j]))	//ratio of means
				}
			}
			for (i=1; i<=rows(YtrueRT); i++){
				for (j=1; j<=cols(YtrueRT); j++){		
					YtrueRT[i,j]=log(abs(YTtrue[i,j]))
				}
			}							
		}
	}
	if (dat==2){	//binary data
		RPC=rbeta(reps,1,rc,fc)	//beta distribution on success rates for treatment and control arms
		RPT=rbeta(reps,1,rt,ft)
		
		PCtrue=RPC
		PTtrue=RPT
		if (mod==1){
			for (i=1; i<=rows(PCtrue); i++){
				for (j=1; j<=cols(PCtrue); j++){
					PCtrue[i,j] = PC[i,j]*RPC[i,j]+(1-PC[i,j])*((RPC[i,j]*exp(LC[i,j]))/(RPC[i,j]*exp(LC[i,j])+1-RPC[i,j])) //'true' percentage of successes for treatment and control arms when logIMOR
					PTtrue[i,j] = PT[i,j]*RPT[i,j]+(1-PT[i,j])*((RPT[i,j]*exp(LT[i,j]))/(RPT[i,j]*exp(LT[i,j])+1-RPT[i,j]))
				}
			}	
		}		
		if (meas==1){
			YtrueRC=PCtrue
			YtrueRT=PTtrue		
			for (i=1; i<=rows(YtrueRC); i++){
				for (j=1; j<=cols(YtrueRC); j++){		
					YtrueRC[i,j]=logit(PCtrue[i,j])	//odds ratios
				}
			}
			for (i=1; i<=rows(YtrueRT); i++){
				for (j=1; j<=cols(YtrueRT); j++){		
					YtrueRT[i,j]=logit(PTtrue[i,j])
				}
			}
		}
		if (meas==2){
			YtrueRC=PCtrue
			YtrueRT=PTtrue
			for (i=1; i<=rows(YtrueRC); i++){
				for (j=1; j<=cols(YtrueRC); j++){		
					YtrueRC[i,j]=log(PCtrue[i,j])	//risk ratios
				}
			}
			for (i=1; i<=rows(YtrueRT); i++){
				for (j=1; j<=cols(YtrueRT); j++){		
					YtrueRT[i,j]=log(PTtrue[i,j])
				}
			}			
		}
		if (meas==3){
			YtrueRC=PCtrue	//risk differences
			YtrueRT=PTtrue
		}
	}
	ES=YtrueRT-YtrueRC
	
	Mean=mean(ES)	//'true' means of effect sizes
	Var=variance(ES)
	Varnew=J(1,ns,0)
	for (i=1; i<=cols(Varnew); i++){
		Varnew[1,i]=Var[i,i]	//'true' variances of effect sizes
	}			
			
	st_matrix("_mean",Mean)
	st_matrix("_var",Varnew)

}
end
	
	
program def compare
	syntax [anything] [if] [in]
	
	if "$METAMISS2_network"=="off"{
		tempvar double es sees
		cap drop _ESfirst _ESsecond _seESfirst _seESsecond
		cap drop _es _sees
		//preserve
		qui expand 2 $METAMISS2_if $METAMISS2_in,gen(`double')
		lab def _anal 0 "Primary analysis" 1 "Secondary analysis"
		lab val `double' _anal 
		
		di as text _newline "Primary analysis"	
		if "$METAMISS2_method" =="taylor"{
			if "$METAMISS2_type"=="bin"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nograph $COMPARE_options by(`double') nooverall) $METAMISS2_measure $METAMISS2_eform impmean("$METAMISS2_impmean") impsd("$METAMISS2_impsd") impcorr("$METAMISS2_corr")  
			}
			if "$METAMISS2_type"=="cont"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nograph $COMPARE_options by(`double') nooverall) $METAMISS2_measure $METAMISS2_eform imptype("$METAMISS2_model") impmean("$METAMISS2_impmean") impsd("$METAMISS2_impsd") impcorr("$METAMISS2_corr")  
			}
		}
		if "$METAMISS2_method" =="bootstrap"{
			if "$METAMISS2_type"=="bin"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nograph $COMPARE_options by(`double') nooverall) $METAMISS2_measure $METAMISS2_eform b reps("$METAMISS2_reps") impmean("$METAMISS2_impmean") impsd("$METAMISS2_impsd") impcorr("$METAMISS2_corr")  		
			}
			if "$METAMISS2_type"=="cont"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nograph $COMPARE_options by(`double') nooverall) $METAMISS2_measure $METAMISS2_eform b reps("$METAMISS2_reps") imptype("$METAMISS2_model") impmean("$METAMISS2_impmean") impsd("$METAMISS2_impsd") impcorr("$METAMISS2_corr")  		
			}
		} 
		cap rename _ES _first
		cap rename _seES _sefirst
		di as text _newline "Secondary analysis"
		cap{
			if "$METAMISS2_type"=="bin"{
				qui metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_compare $METAMISS2_eform $METAMISS2_measure metanopt(nograph)
			}
			if "$METAMISS2_type"=="cont"{
				qui metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_compare $METAMISS2_eform $METAMISS2_measure imptype("$METAMISS2_model") metanopt(nograph)
			}
		}
		if _rc!=0{
			di as text _newline " {bf:Warning}: Option '$METAMISS2_compare' in {it:compare()} is not a valid IMP definition - ACA is used as the comparator model" 
			if "$METAMISS2_type"=="bin"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nograph $COMPARE_options by(`double') nooverall) impmean(0) impsd(0)  $METAMISS2_eform $METAMISS2_measure 
			}
			if "$METAMISS2_type"=="cont"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nograph $COMPARE_options by(`double') nooverall) impmean(0) impsd(0)  $METAMISS2_eform $METAMISS2_measure imptype("$METAMISS2_model") 
			}
		}
		else{
			if "$METAMISS2_type"=="bin"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nograph $COMPARE_options by(`double') nooverall) $METAMISS2_compare  $METAMISS2_eform $METAMISS2_measure 
			}
			if "$METAMISS2_type"=="cont"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nograph $COMPARE_options by(`double') nooverall) $METAMISS2_compare  $METAMISS2_eform $METAMISS2_measure imptype("$METAMISS2_model") 
			}
		}
		cap rename _ES _second
		cap rename _seES _sesecond
		
		cap gen double `es'=_second if `double'==1
		cap gen double `sees'=_sesecond if `double'==1
		cap replace `es'=_first if `double'==0
		cap replace `sees'=_sefirst if `double'==0
		
		metan `es' `sees', random $COMPARE_options by(`double') nooverall $METAMISS2_eform
		cap rename _first _ESfirst
		cap rename _sefirst _seESfirst
		cap rename _second _ESsecond
		cap rename _sesecond _seESsecond
		cap drop if `double'==1
		cap lab drop _anal
		cap drop _es _sees
		cap drop _LCI _UCI _WT
		macro drop COMPARE_options METAMISS2_compare
	}
	if "$METAMISS2_network"=="on"{
		cap drop _first_* _second_*
		di as text _newline "Primary analysis"	
		if "$METAMISS2_method" =="taylor"{
			if "$METAMISS2_type"=="bin"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_measure impmean("$METAMISS2_impmean") impsd("$METAMISS2_impsd") impcorr("$METAMISS2_corr") networkopt($COMPARE_options) $METAMISS2_inc
			}
			if "$METAMISS2_type"=="cont"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_measure imptype("$METAMISS2_model") impmean("$METAMISS2_impmean") impsd("$METAMISS2_impsd") impcorr("$METAMISS2_corr") networkopt($COMPARE_options) $METAMISS2_inc
			}
		}
		if "$METAMISS2_method" =="bootstrap"{
			if "$METAMISS2_type"=="bin"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_measure b reps("$METAMISS2_reps") impmean("$METAMISS2_impmean") impsd("$METAMISS2_impsd") impcorr("$METAMISS2_corr") networkopt($COMPARE_options) $METAMISS2_inc		 
			}
			if "$METAMISS2_type"=="cont"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_measure b reps("$METAMISS2_reps") imptype("$METAMISS2_model") impmean("$METAMISS2_impmean") impsd("$METAMISS2_impsd") impcorr("$METAMISS2_corr") networkopt($COMPARE_options) $METAMISS2_inc		
			}
		} 
		if "$METAMISS2_plot"!=""{
			qui intervalplot, noplot notable keep $METAMISS2_plotoptions ref($METAMISS2_plotref) lab($METAMISS2_trtlab)
			qui drop _Comparison
			rename _LPrI _first_LPrI
			rename _UPrI _first_UPrI
			rename _Effect_Size _first_Effect_Size
			rename _Standard_Error _first_Standard_Error
			rename _LCI _first_LCI
			rename _UCI _first_UCI
		}
		foreach var of varlist _imp_*{
			rename `var' _first`var'
		}
		di as text _newline "Secondary analysis"
		cap{
			if "$METAMISS2_type"=="bin"{
				qui metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_compare $METAMISS2_eform
			}
			if "$METAMISS2_type"=="cont"{
				qui metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_compare $METAMISS2_eform imptype("$METAMISS2_model")
			}
		}
		if _rc!=0{
			di as text _newline " {bf:Warning}: Option '$METAMISS2_compare' in {it:compare()} is not a valid IMP definition - ACA is used as the comparator model" 
			if "$METAMISS2_type"=="bin"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, impmean(0) impsd(0) networkopt($COMPARE_options) $METAMISS2_eform
			}
			if "$METAMISS2_type"=="cont"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, impmean(0) impsd(0) networkopt($COMPARE_options) $METAMISS2_eform imptype("$METAMISS2_model")
			}
		}
		else{
			if "$METAMISS2_type"=="bin"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_compare networkopt($COMPARE_options) $METAMISS2_eform
			}
			if "$METAMISS2_type"=="cont"{
				metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_compare networkopt($COMPARE_options) $METAMISS2_eform imptype("$METAMISS2_model")
			}
		}
		if "$METAMISS2_plot"!=""{
			qui intervalplot, noplot notable keep networkopt($METAMISS2_plotoptions) ref($METAMISS2_plotref) lab($METAMISS2_trtlab)
			rename _LPrI _second_LPrI
			rename _UPrI _second_UPrI
			rename _Effect_Size _second_Effect_Size
			rename _Standard_Error _second_Standard_Error
			rename _LCI _second_LCI
			rename _UCI _second_UCI
		}
		foreach var of varlist _imp_*{
			rename `var' _second`var'
		}
		if "$METAMISS2_plot"!=""{
			intervalplot _first_Effect_Size _first_LCI _first_UCI _second_Effect_Size _second_LCI _second_UCI if _Comparison!="",nomvmeta labels(_Comparison) labt("Comparison") valuest("Effect size (95%CI)") $METAMISS2_plotoptions
			if "$METAMISS2_nokeep"!=""{
				qui drop _Comparison
				qui drop _first_* _second_*
				qui keep if _design!=
			}
			else{
				order _Comparison _first_Eff _first_Stand _first_LCI _first_UCI _first_LPrI _first_UPrI _second_Eff _second_Stand* _second_LCI _second_UCI _second_LPrI _second_UPrI,last
			}
		}
	}
	
end
	
	
program def sensitivity
	syntax [anything] [if] [in], [*]
	
	local nobs=`=_N'
	cap set obs 100
	
	tempvar sdlambda
	
	qui gen double `sdlambda' in 1=0

	forvalues i=2/100{
		qui replace `sdlambda' in `i'=`sdlambda'[`=`i'-1']+5/99
		local sdlambda`i'=`sdlambda'[`i']
	}

	if "$METAMISS2_measure"=="md"{
		local ytitle "Mean difference with 95%CI"
	}
	if "$METAMISS2_measure"=="smd"{
		local ytitle "Standardized mean difference with 95%CI"
	}
	if "$METAMISS2_measure"=="rom"{
		if "$METAMISS2_eform"!=""{
			local ytitle "Ratio of means with 95%CI"
		}
		else{
			local ytitle "log(Ratio of means) with 95%CI"
		}
	}
	if "$METAMISS2_measure"=="or"{
		if "$METAMISS2_eform"!=""{
			local ytitle "Odds ratio with 95%CI"
		}
		else{
			local ytitle "log(Odds ratio) with 95%CI"
		}
	}
	if "$METAMISS2_measure"=="rr"{
		if "$METAMISS2_eform"!=""{
			local ytitle "Risk ratio with 95%CI"
		}
		else{
			local ytitle "log(Risk ratio) with 95%CI"
		}
	}
	if "$METAMISS2_measure"=="rd"{
		local ytitle "Risk difference with 95%CI"
	}
	if "$METAMISS2_model"=="imdom"{
		local xtitle "IMDoM"
	}
	if "$METAMISS2_model"=="logimrom"{
		local xtitle "logIMRoM"
	}	
	if "$METAMISS2_model"=="logimor"{
		local xtitle "logIMOR"
	}	
	
	if "$METAMISS2_network"=="off"{
		qui metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nokeep nograph) $METAMISS2_measure impmean("$METAMISS2_impmean") $METAMISS2_eform	
		local ES1=r(ES)
		local LCI1=r(ci_low)
		local UCI1=r(ci_upp)
	}
	if "$METAMISS2_network"=="on"{
		qui metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_measure impmean("$METAMISS2_impmean") $METAMISS2_eform	
		tempname ES1 seES1 lciES1 uciES1
		mat `ES1'=e(b)
		mat `ES1'=`ES1'[1,1..`=$METAMISS2_ntm-1']
		mat `seES1'=e(V)
		mat `seES1'=vecdiag(`seES1')
		mat `seES1'=`seES1'[1,1..`=$METAMISS2_ntm-1']
		mat `lciES1'=`ES1'-abs(invnorm(0.025))*`seES1'
		mat `uciES1'=`ES1'+abs(invnorm(0.025))*`seES1'		
	}
	forvalues i=2/100{
		local sd `"impsd(`sdlambda`i'')"'
		if "$METAMISS2_network"=="off"{
			if "$METAMISS2_method" =="taylor"{
				qui metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nokeep nograph) $METAMISS2_measure `sd' impmean("$METAMISS2_impmean") impcorr("$METAMISS2_corr") $METAMISS2_eform
			}
			if "$METAMISS2_method" =="bootstrap"{
				qui metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, metanopt(notable nokeep nograph) $METAMISS2_measure b reps("$METAMISS2_reps") `sd' impmean("$METAMISS2_impmean") impcorr("$METAMISS2_corr") $METAMISS2_eform
			}		
			local ES`i'=r(ES)
			local LCI`i'=r(ci_low)
			local UCI`i'=r(ci_upp)
		}
		if "$METAMISS2_network"=="on"{
			if "$METAMISS2_method" =="taylor"{
				qui metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_measure `sd' impmean("$METAMISS2_impmean") impcorr("$METAMISS2_corr")
			}
			if "$METAMISS2_method" =="bootstrap"{
				qui metamiss2 $METAMISS2_anything $METAMISS2_if $METAMISS2_in, $METAMISS2_measure b reps("$METAMISS2_reps") `sd' impmean("$METAMISS2_impmean") impcorr("$METAMISS2_corr")
			}		
			tempname ES`i' seES`i' lciES`i' uciES`i'
			mat `ES`i''=e(b)
			mat `ES`i''=`ES`i''[1,1..`=$METAMISS2_ntm-1']
			mat `seES`i''=e(V)
			mat `seES`i''=vecdiag(`seES`i'')
			mat `seES`i''=`seES`i''[1,1..`=$METAMISS2_ntm-1']
			mat `lciES`i''=`ES`i''-abs(invnorm(0.025))*`seES`i''
			mat `uciES`i''=`ES`i''+abs(invnorm(0.025))*`seES`i''				
		}
	}
	if "$METAMISS2_network"=="off"{
		tempvar ESlambda LCIlambda UCIlambda
		qui{
			gen double `ESlambda' in 1=`ES1'
			gen double `LCIlambda' in 1=`LCI1'
			gen double `UCIlambda' in 1=`UCI1'

			forvalues i=2/100{
				replace `ESlambda' in `i'=`ES`i''
				replace `LCIlambda' in `i'=`LCI`i''
				replace `UCIlambda' in `i'=`UCI`i''	
			}
		}	
		sc `ESlambda' `sdlambda', mcol(black)|| sc `LCIlambda' `sdlambda',mcol(black) msymb(plus) || sc `UCIlambda' `sdlambda', mcol(black) msymb(plus) legend(label(1 "Summary effect") label(2 "Lower & Upper CI") order(1 2)) xtitle("Standard deviation of `xtitle'") ytitle(`ytitle') `options'
		cap drop _LCI _UCI _WT
	}
	if "$METAMISS2_network"=="on"{
		forvalues i=1/$METAMISS2_ntm{
			if "${METAMISS2_tr`i'}"=="$METAMISS2_ref" continue
			if "${METAMISS2_tr`i'}"<"$METAMISS2_ref"{
				tempvar ESlambda_tr`i' LCIlambda_tr`i' UCIlambda_tr`i'
				qui{
					gen double `ESlambda_tr`i'' in 1=`ES1'[1,`i']
					gen double `LCIlambda_tr`i'' in 1=`lciES1'[1,`i']
					gen double `UCIlambda_tr`i'' in 1=`uciES1'[1,`i']
					
					forvalues j=2/100{
						replace `ESlambda_tr`i'' in `j'=`ES`j''[1,`i']
						replace `LCIlambda_tr`i'' in `j'=`lciES`j''[1,`i']
						replace `UCIlambda_tr`i'' in `j'=`uciES`j''[1,`i']				
					}
				}
			}
			if "${METAMISS2_tr`i'}">"$METAMISS2_ref"{
				tempvar ESlambda_tr`i' LCIlambda_tr`i' UCIlambda_tr`i'
				qui{
					gen double `ESlambda_tr`i'' in 1=`ES1'[1,`=`i'-1']
					gen double `LCIlambda_tr`i'' in 1=`lciES1'[1,`=`i'-1']
					gen double `UCIlambda_tr`i'' in 1=`uciES1'[1,`=`i'-1']
					
					forvalues j=2/100{
						replace double `ESlambda_tr`i'' in `j'=`ES`j''[1,`=`i'-1']
						replace double `LCIlambda_tr`i'' in `j'=`lciES`j''[1,`=`i'-1']
						replace double `UCIlambda_tr`i'' in `j'=`uciES`j''[1,`=`i'-1']				
					}
				}
			}			
		}
		forvalues i=1/$METAMISS2_ntm{
			if "${METAMISS2_tr`i'}"=="$METAMISS2_ref" continue
			qui sc `ESlambda_tr`i'' `sdlambda', mcol(black)|| sc `LCIlambda_tr`i'' `sdlambda',mcol(black) msymb(plus) || sc `UCIlambda_tr`i'' `sdlambda', mcol(black) msymb(plus) legend(off) xtitle("Standard deviation of `xtitle'") ytitle(`ytitle') `options' saving(tr`i'.gph) title("${METAMISS2_tr`i'} versus $METAMISS2_ref")
		}
		local comb2 "tr2.gph"
		forvalues i=3/$METAMISS2_ntm{
			local comb`i' `"`comb`=`i'-1'' tr`i'.gph"' 
		}
		graph combine `comb$METAMISS2_ntm'
		forvalues i=2/$METAMISS2_ntm{
			cap erase "tr`i'.gph"
		}
	}
	cap drop if _n>`nobs'
end	

