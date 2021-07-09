*! version 2.2
* 29 Apr 2020
* add biennial option
*! version 2.1
* Kerry Du (kerrydu@xmu.edu.cn)
* 29 Nov 2019
capture program drop malmq2
program define malmq2,rclass prop(xt)
    version 16

	_xt, trequired 
	local id=r(ivar)
	local time=r(tvar)
	qui mata mata mlib index
*******************************************************************************
/////////This section is from  Yong-bae Ji and Choonjoo Lee's DEA.ado//////////
    // get and check invarnames
    gettoken word 0 : 0, parse("=,")
    while ~("`word'" == ":" | "`word'" == "=") {
        if "`word'" == "," | "`word'" == "" {
                error 198
        }
        local invars `invars' `word'
        gettoken word 0 : 0, parse("=,")
    }
    unab invars : `invars'
*********************************************************************************	
	
    syntax varlist [if] [in], [dmu(varname) FGNZ RD ort(string) ///
	                          BIennial GLOBAL SEQuential WINdow(numlist intege max=1 >=1) ///
							   SAVing(string) maxiter(numlist integer >0 max=1) tol(numlist max=1 >0)]
							   
							   
	if "`fgnz'"!=""&"`rd'"!=""{
	    disp as error "fgnz and rd cannot be specified together."
		error 498
	}
	preserve
	marksample touse 
    local opvars `varlist'
	qui keep `invars' `opvars' `id' `time' `touse' `dmu'
	qui gen Row=_n
	label var Row "Row # in the original dataset"

/*	
	qui cap bys `id' (`time'): gen Pdwise=`time'[_n-1]+"~"+`time' if _n>1
	qui cap bys `id' (`time'): gen Pdwise=string(`time'[_n-1])+"~"+string(`time') if _n>1
	label var Pdwise "Period wise"
*/	
	qui _malmq `invars'=`opvars' if `touse', id(`id') time(`time') ort(`ort') `global' `sequential' ///
	                                     window(`window')  maxiter(`maxiter') tol(`tol')
							   
	local resvars `r(rvars)'
	
	if  "`fgnz'"==""&"`rd'"==""{
	
	    format `resvars' %9.4f

		qui keep if `touse'
		qui cap bys `id' (`time'): gen Pdwise=`time'[_n-1]+"~"+`time' if _n>1
		qui cap bys `id' (`time'): gen Pdwise=string(`time'[_n-1])+"~"+string(`time') if _n>1
		order Row `dmu' `id' Pdwise  `resvars' 
		label var Pdwise "Period wise"
		qui keep if !missing(Pdwise) & `touse'
		qui keep  Row `dmu' `id' Pdwise  `resvars' 
	
		disp _n(2) " Malmquist Productivity Index Results:"
		disp "    (Row: Row # in the original data; Pdwise: periodwise)"

		list Row `dmu' `id'  Pdwise  `resvars', sep(0) 
		di "Note: missing value indicates infeasible problem."

		if `"`saving'"'!=""{
		  save `saving'
		  gettoken filenames saving:saving, parse(",")
		  local filenames `filenames'.dta
		  disp _n `"Estimated Results are saved in `filenames'."'
		}	
		

	    return local file `filenames'
	    restore	
		
	}
	else{
		
		foreach v of local resvars{
		
			rename `v' `v'_crs
		
		}
		
	  qui  _malmq `invars'=`opvars' if `touse', vrs id(`id') time(`time') ort(`ort') `biennial' `global' `sequential' ///
	                                        window(`window')  maxiter(`maxiter') tol(`tol')		
		
		if "`rd'"!=""{
		
			qui gen SECH=TFPCH_crs/TFPCH
			label var SECH "Scale efficiecny change"
			qui replace TFPCH=TFPCH_crs
			local resvars `resvars' SECH
		
		}
		else{
			qui gen SECH=TECH_crs/TECH
			label var SECH "Scale efficiecny change"			
			qui replace TFPCH=TFPCH_crs
			if "`global'"!=""{
				qui replace BPC=BPC_crs
			}
			else{
				qui replace TECCH=TECCH_crs		
			}

			local resvars `resvars' SECH
		}
		
		
	    format `resvars' %9.4f

		qui keep if `touse'
		qui cap bys `id' (`time'): gen Pdwise=`time'[_n-1]+"~"+`time' if _n>1
		qui cap bys `id' (`time'): gen Pdwise=string(`time'[_n-1])+"~"+string(`time') if _n>1
		label var Pdwise "Period wise"
			    
		order Row `dmu' `id' Pdwise  `resvars' 
		qui keep if !missing(Pdwise) & `touse'
		qui keep  Row `dmu' `id' Pdwise  `resvars' 
	
		disp _n(2) " Malmquist Productivity Index Results:"
		disp "    (Row: Row # in the original data; Pdwise: periodwise)"

		list Row `dmu' `id'  Pdwise  `resvars' , sep(0) 
		di "Note: missing value indicates infeasible problem."

		if `"`saving'"'!=""{
		  save `saving'
		  gettoken filenames saving:saving, parse(",")
		  local filenames `filenames'.dta
		  disp _n `"Estimated Results are saved in `filenames'."'
		}	
		

	    return local file `filenames'
	    restore			
		

	
	
	}
	
	
end	
	
	
	

**************************************************
capture program drop _malmq
program define _malmq,rclass
    version 16
	

*******************************************************************************
/////////This section is from  Yong-bae Ji and Choonjoo Lee's DEA.ado//////////
    // get and check invarnames
    gettoken word 0 : 0, parse("=,")
    while ~("`word'" == ":" | "`word'" == "=") {
        if "`word'" == "," | "`word'" == "" {
                error 198
        }
        local invars `invars' `word'
        gettoken word 0 : 0, parse("=,")
    }
    unab invars : `invars'
*********************************************************************************	
	
    local num: word count `invars'
    syntax varlist [if] [in], id(varname) time(varname) [VRS ort(string) ///
	                         BIennial  GLOBAL SEQuential WINdow(numlist intege max=1 >=1) ///
							   maxiter(numlist integer >0 max=1) tol(numlist max=1 >0)]
							   
	marksample touse 
    local opvars `varlist'
	
	
	
	local techtype "contemporaneous"
   

   if "`global'"!=""{
	   if "`sequential'"!=""{
	   
		   disp as error "global and sequential cannot be specified together."
		   error 498	   
	   
	   }
	   
	   if "`window'"!=""{
	   
		   disp as error "global and window() cannot be specified together."
		   error 498	   
	   
	   }	

	   if "`biennial'"!=""{
	   
		   disp as error "global and biennial cannot be specified together."
		   error 498	   
	   
	   }	      
	   
	   local techtype "global"
	
	}	
	
   

   if "`sequential'"!=""{
 
	   if "`window'"!=""{
	   
		   disp as error "sequential and window() cannot be specified together."
		   error 498	   
	   
	   }	   

	   if "`biennial'"!=""{
	   
		   disp as error "sequential and biennial cannot be specified together."
		   error 498	   
	   
	   }		   
	   
	   local techtype "sequential"
	
	}	
		
 
	   if "`window'"!=""{

		   if "`biennial'"!=""{
		   
			   disp as error "biennial and window() cannot be specified together."
			   error 498	   
		   
		   }		   	
	   
	       local techtype "window"   
	   
	   }


		   if "`biennial'"!=""{
		   
				local techtype "biennial"     
		   
		   }		   	
	   
	       


	   
	if "`maxiter'"==""{
		local maxiter=-1
	}
	if "`tol'"==""{
		local tol=-1
	}	
	
   
    tempvar period dmu
	
	qui egen `period'=group(`time')
	qui egen `dmu'=group(`id')	

	
    qui su  `period'
    local tmax=r(max)

    tempvar flag temp DD D21 D12
    
    qui gen `DD'=.
    qui gen `D21'=.
    qui gen `D12'=.
	
    qui gen `flag'=0
	
	sort `period' `dmu'
	
  if `"`techtype'"'=="contemporaneous"{
  
	    qui{
        forv t=1/`tmax'{
            qui replace `flag'= (`period'==`t')
            shepdf  if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `DD'=`temp' if `period'==`t'
            qui drop `temp'
        }    
        local tt=`tmax'-1
        forv t=1/`tt'{
            qui replace `flag'=(`period'==`t'+1) 
            shepdf  if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `D21'=`temp' if `period'==`t'
            qui drop `temp'
        }  

        forv t=2/`tmax'{
            qui replace `flag'=(`period'==`t'-1)
            shepdf  if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `D12'=`temp' if `period'==`t'
            qui drop `temp'
        }       

    }
  
  
  }
  
  
    if `"`techtype'"'=="sequential"{
  
	  
        forv t=1/`tmax'{
            qui replace `flag'=(`period'<=`t')
            shepdf if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `DD'=`temp' if `period'==`t'
            qui replace `flag'=0
            qui drop `temp'
        }    
        local tt=`tmax'-1
        forv t=1/`tt'{
            qui replace `flag'=(`period'<=`t'+1) 
            shepdf  if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `D21'=`temp' if `period'==`t'
            qui drop `temp'
        }  

        forv t=2/`tmax'{
            qui replace `flag'= (`period'<=`t'-1) 
            shepdf if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `D12'=`temp' if `period'==`t'
            qui drop `temp'
        }       

    
  
  
  }
  
  
  
     if `"`techtype'"'=="window"{
		local band=(`window'-1)/2
	 
        forv t=1/`tmax'{
            qui replace `flag'=(`period'<=`t'+`band' & `period'>=`t'-`band') 
            shepdf  if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `DD'=`temp' if `period'==`t'
            qui cap drop `temp'
        }    
        local tt=`tmax'-1
        forv t=1/`tt'{
            qui replace `flag'= (`period'<=`t'+1+`band' &  `period'>=`t'-`band'+1)
            shepdf  if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `D21'=`temp' if `period'==`t'
            qui cap drop `temp'
        }  

        forv t=2/`tmax'{
            qui replace `flag'=(`period'<=`t'-1+`band' & `period'>=`t'-1-`band') 
            shepdf  if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `D12'=`temp' if `period'==`t'
            qui cap drop `temp'
        }       

    
  
  
  }
 
     if `"`techtype'"'=="biennial" {
	 
        forv t=1/`tmax'{
            qui replace `flag'=(`period'<=`t'+1 & `period'>=`t') 
            shepdf  if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `DD'=`temp' if `period'==`t'
            qui cap drop `temp'
        }    

        forv t=2/`tmax'{
            qui replace `flag'=(`period'<=`t' & `period'>=`t'-1) 
            shepdf  if `period'==`t' & `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
            qui replace `D12'=`temp' if `period'==`t'
            qui cap drop `temp'
        }       

    
  
  }


 	
 
	if `"`techtype'"'=="global"{

	    qui replace `flag'=1
		shepdf  if `touse', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
        
        qui bys `dmu' (`period'): gen TFPCH=`temp'/`temp'[_n-1]	
		label var TFPCH "Total factor productivity change"
		cap drop `temp'		
		
		sort `period' `dmu'
		forv t=1/`tmax'{
			qui replace `flag'=(`period'==`t')
			shepdf  if `touse' & `period'==`t', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
			qui replace `DD'=`temp' if `period'==`t'
			qui cap drop `temp'
		}
		
		qui bys `dmu' (`period'): gen TECH=`DD'/`DD'[_n-1]	
		qui bys `dmu' (`period'): gen BPC=TFPCH/TECH			
	
		label var TECH  "Technical efficiency change"	
		label var BPC "Best practice gap change"
		local resvars TFPCH TECH  BPC
		
		
	}
	else if `"`techtype'"'=="biennial"{

        qui bys `dmu' (`period'): gen TFPCH=`DD'/`D12' if _n>1
		label var TFPCH "Total factor productivity change"
		cap drop `temp'	

		sort `period' `dmu'
		forv t=1/`tmax'{
			qui replace `flag'=(`period'==`t')
			shepdf  if `touse' & `period'==`t', rflag(`flag') gen(`temp') `vrs' ort(`ort') in(`invars') op(`opvars') maxiter(`maxiter') tol(`tol')
			qui replace `DD'=`temp' if `period'==`t'
			qui cap drop `temp'
		}

		qui bys `dmu' (`period'): gen TECH=`DD'/`DD'[_n-1]	
		qui bys `dmu' (`period'): gen TECCH=TFPCH/TECH			
	
		label var TECH  "Technical efficiency change"	
		label var TECCH "Techological change"
		local resvars TFPCH TECH  TECCH						

	}
	else{
	
			//su `DD' `D12' `D21'
		qui {
			sort `dmu' `period'
			bys `dmu' (`period'): gen TECH=`DD'/`DD'[_n-1]
			bys `dmu' (`period'): gen TECCH=sqrt(`D12'/`DD'*`DD'[_n-1]/`D21'[_n-1])
			gen TFPCH= TECH*TECCH
			local resvars TFPCH TECH TECCH
		    label var TFPCH "Total factor productivity change"
		    label var TECH  "Technical efficiency change"	
		    label var TECCH "Techological change"				
		}	
	
	}
	
	return local rvars "`resvars'"
	


end  






**************************************************
capture program drop shepdf
program define shepdf
    version 16

    syntax [if] [in], gen(string) INvars(varlist) OPvars(varlist) [rflag(varname) ort(string) VRS maxiter(numlist) tol(numlist)]
        marksample touse 
		markout `touse' `invars' `opvars' 
		
		tempvar touse2
		mark `touse2' if `rflag'
		markout `touse2' `invars' `opvars'
		//qui gen `touse2'=`rflag'	
        qui gen `gen'=.

		local comvars: list invars & opvars 
		if !(`"`comvars'"'==""){
			disp as error "`comvars' should not be specified as input and output simultaneously."
			error 498
		}		
		
        local data `invars' `opvars'
        local num: word count `invars'		
		
*******************************************************************************
/////////This section is from  Yong-bae Ji and Choonjoo Lee's DEA.ado//////////		
		// default orientation - Input Oriented
		if ("`ort'" == "") local ort = "IN"
		else {
			local ort = upper("`ort'")
			if ("`ort'" == "I" | "`ort'" == "IN" | "`ort'" == "INPUT") {
				local ort = "IN"
			}
			else if ("`ort'" == "O" | "`ort'" == "OUT" | "`ort'" == "OUTPUT") {
				local ort = "OUT"
			}
			else {
				di as err "option ort allows for case-insensitive " _c
				di as err "(i|in|input|o|out|output) or nothing."
				exit 198
			}
		}
		
*******************************************************************************		
		if "`vrs'"!=""{
			local rts=1
		}
		else{
			local rts=0
		
		}
		
		
		if "`ort'" =="OUT"{
			mata: sdf_o("`data'","`touse'", "`touse2'",`num',`rts',"`gen'",`maxiter',`tol')
			qui replace `gen'=1/`gen'
		  }
		else{
			mata: sdf_i("`data'","`touse'", "`touse2'",`num',`rts',"`gen'",`maxiter',`tol')
		 }
		 

end 
