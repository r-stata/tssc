capture program drop fitstat_ers

*!version 1.0 22aug 2011
*!christian a. gregory, economic research service

***********************************************************************************************
*this program computes outfit and infit statistics for the conditional maximum likelihood (cml)
*rasch model, using formulas outlined in the documentation. these fit statistics differ from
*those computed by the raschtest. for more information on the fit statistics, see documentation
*or contact mark nord @ marknord@ers.usda.gov, or christian gregory @ cgregory@ers.usda.gov.
************************************************************************************************
*the gammasym module is required to run this program. to get this module, type "findit gammasym" 
*in stata. if you wish to keep the fit statistics in an excel file, install xml_tab.ado; if you wish
*to keep them in a LaTex file, install outtable.ado.
************************************************************************************************

program define fitstat_ers, rclass
version 9.0
syntax varlist(min=2) [if] [in], ///
	[excel(string)               ///
	 latex(string)               ///
	 replace ]
	 

tempfile fitstat
qui save `fitstat', replace	 
marksample touse
qui keep if `touse'
qui keep `varlist'
	 	 
*compute score
tempvar score
genscore `varlist', score(`score')


*prep data to reshape
g id = _n
local r 0
foreach x of local varlist {
	local `++r'
	rename `x' item`r'
	}
local nbitems: word count `varlist'

*total obs before reshape
qui count if `score'!=0 & `score'!=`nbitems'
local totalobs = r(N)


*get size of groups by score
forvalues i=0/`nbitems' {
      qui count if `score'==`i' //& item==1
      local realscore`i'=r(N)
      }

local t = `nbitems'-1      
    
*reshape      
qui reshape long item, i(id) j(rep)

forvalues i = 1/`nbitems' {
	qui {
		g item`i' = rep==`i'
		replace item`i' = -item`i'
	}
}


*estimate parameters
qui clogit item item1-item`t', group(id)

matrix beta = e(b)

forvalues i=1/`t' {
	local beta`i' = beta[1,`i']
	}
local beta`nbitems' = 0



tempname Pi
matrix define `Pi'=J(`nbitems',`t',0)


tempname Obs Obs2 Th Th2
matrix define `Obs'=J(`nbitems',`t',0)
matrix define `Th'=J(`nbitems',`t',0)
local listofitemsc

******************************************************************************************************
*estimation of the gamma symetrical functions. i use these to calculate the expected values of the 
*model, conditional on the score. hardouin (07) and glas(88) use these forms. the current stata module
*-raschtest- uses them for general cml models and R tests.
*******************************************************************************************************
forvalues j=1/`nbitems' {
      local listini`j'
      local listofitemsc "`listofitemsc' `beta`j''"
      forvalues k=1/`nbitems' {
         local listini`j'k`k'
         if `k'!=`j' {
            local listini`j' "`listini`j'' `beta`k''" //vector w/o current item paramter--diags of vcv
         }
         forvalues l=1/`nbitems' {
            if `l'!=`j'&`l'!=`k' {
               local listini`j'k`k' "`listini`j'k`k'' `beta`l''" //vector w/o current item parameter--off diags of vcv
         }
       }
     }
   }

   qui gammasym `listofitemsc' //gamma function of full vector of difficulty parameters
	
*estimation of probabilities (pi) and expected (th), as well as observed (obs)
   forvalues s=1/`nbitems' {
      local denom`s'=r(gamma`s')
      }
   local m = `nbitems'-1
   local p = `m'-1
   forvalues j=1/`nbitems' {
   	forvalues s=1/`m' {
   	 	 local r=`s'-1
   	 	 qui count if rep==`j'& item==1 &`score'==`s'
         matrix `Obs'[`j',`s']=r(N)
         gammasym `listini`j''
         local num`j'=r(gamma `r') //gamma function of vector w/o item j, for score s-1
         matrix `Pi'[`j',`s']=exp(-`beta`j'')*`num`j''/`denom`s''
         matrix `Th'[`j',`s']=`Pi'[`j',`s']*`realscore`s''
         }
   }

//local totalobs = _N
matrix outstat = J(`nbitems',2,0)

forvalues j = 1/`nbitems' {
	local outfit_j = 0
	local infit_j = 0
	local outfit_num = 0
	local outfit_denom = 0
	local infit_num = 0
	local infit_denom = 0
	forvalues s = 1/`m' {
		local n_score = `realscore`s''
		disp "frac score = " `n_score'/`totalobs'
		local obs_js = `Obs'[`j',`s']
		local pred_js = `Th'[`j',`s']
		local p_obs_js = `obs_js'/`n_score'
		local p_exp_js = `pred_js'/`n_score'
		local fitnum = `p_obs_js'*(1-`p_exp_js')^2 + (1-`p_obs_js')*`p_exp_js'^2
		local fitdenom = `p_exp_js'*(1-`p_exp_js')
		local outfit_j = `outfit_j'+ ((`n_score'/`totalobs')*(`fitnum'/`fitdenom'))
		local infit_num = `infit_num'+ (`n_score'/`totalobs')*(`fitnum')
		local infit_denom = `infit_denom'+ (`n_score'/`totalobs')*(`fitdenom')
		}
	local infit_j = `infit_j' + (`infit_num'/`infit_denom')
	local outfit_j = `outfit_j' 
	matrix outstat[`j',1] = `outfit_j'
	matrix outstat[`j',2] = `infit_j'
}




matrix rownames outstat = `varlist'
matrix colnames outstat = Outfit Infit


if "`excel'"!="" {
	local rand = round(1000*runiform(),1)
	if "`replace'"!="" {
		xml_tab outstat, save(`excel') replace
	}
	else {
		capture confirm new file `excel'
			if _rc {
		    	xml_tab outstat, save(outstat`rand')
				di in green "`excel' already exists; results saved in outstat`rand'.xml"
			}
			else {
				xml_tab outstat, save(`excel')
				}
		}
	}
	
if "`latex'"!=""{
	local rand = round(1000*runiform(),1)
	if "`replace'"!="" {
		outtable using `latex', mat(outstat) nobox replace
	}
	else {
		capture confirm new file `latex'.tex
			if _rc {
		    	outtable using `latex'`rand', mat(outstat) nobox
				di in green "`latex' already exists; results saved in outstat`rand'.tex"
			}
			else {
				outtable using `latex'`rand', mat(outstat) nobox
				}
		}
	}	


return matrix outstat = outstat
	
use `fitstat', clear


end







