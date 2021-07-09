*! 1.0 Theil's refined decomposition between groups
*! for differentiating between shared and different
*! dispersions and for a quantile-based decomposition
*! The decomposition is performed for either 
*! Theil's L (2nd) or Theil's T (1st) index
*! Tim F. Liao, University of Illinois, May 2016 

program define theildeco, byable(recall) rclass sortpreserve 

version 8.1 
syntax varname(numeric) [aweight fweight] [if] [in] ///
  [, BYg(varname numeric) Alpha(integer 1) Method(integer 0) Quant(real 5)]

local inc "`varlist'"

tempvar fi T Syk Tk Tk Tb Tw wi inck meanyk miny maxy     ///
  minyk maxyk twa twb wika wikb incka inckb Twa Twb first ///
    

if `alpha'==0 {
  qui count if `inc'<=0 
  if r(N) > 0 {
    di " "
	di as error "`inc' has `r(N)' values <= 0." _c
	di as error " Omit these cases and restart the analysis."
	exit 459
	}
 }
if `alpha'==1 {
  qui count if `inc'<0 
  if r(N) > 0 {
   di " "
   di as error "`inc' has `r(N)' values < 0." _c
   di as error " Omit these cases and restart the analysis."
   exit 459
   }
 }

if "`weight'" == "" gen byte `wi' = 1
  else gen `wi' `exp'

marksample touse
  if "`byg'" != "" markout `touse' 

qui count if `touse'
if r(N) == 0 error 2000

lab var `touse' "All obs"
lab def `touse' 1 " "
lab val `touse' `touse'

if "`byg'" != "" {
  capture levelsof `byg' if `touse' , local(grp)
  qui if _rc levels `byg' if `touse' , local(grp)
  foreach x of local grp {
 	if int(`x') != `x' | (`x' < 0) { 
   	  di as error "`byg' contains non-integer or negative values"
	  exit 459
	  }
	}
  }

set more off
	
quietly {
	sum `inc' [aw = `wi'] if `touse', meanonly

	local sumwi = r(sum_w)
	local meany = r(mean)
	local sumy = r(sum)
	
	gen double `fi' = `wi' / `sumwi' if `touse'
	
	gsort -`touse' `inc' 

	if (`touse' & `alpha'==0) {
	egen double `T' = sum(`fi' * log(`meany' / `inc'))
	}
	if (`touse' & `alpha'==1) {
	egen double `T' = sum(`fi' * (`inc' / `meany') * log(`inc' / `meany'))
	}

	lab var `T' "Theil's Index"
	return scalar Theil = `T'[1]
		
***************************
* DECOMPOSITIONS BY GROUP *
***************************

if "`byg'" != "" {	

		tempvar ck nk vk fik lambdak thetak maxg 
		sort `byg' `inc'

		by `byg': gen byte `first' = _n == 1 if `touse'
		by `byg': egen double `ck' = count(`inc') if `touse'
		by `byg': egen double `nk' = sum(`wi') if `touse'
		by `byg': gen double `vk' = `nk' / `sumwi' if `touse'
		by `byg': gen double `fik' = `wi' / `nk' if `touse'
		by `byg': egen double `meanyk' = sum(`fik' * `inc') if `touse'
		by `byg': egen double `Syk' = sum(`wi' * `inc'/`sumy') if `touse'
		gen double `lambdak' = `meanyk' / `meany' if `touse'
		gen double `thetak' = `vk' * `lambdak' if `touse'
		by `byg': egen double `minyk' = min(`inc') if `touse'
		sum `minyk', meanonly
		scalar `miny'=r(max)
		by `byg': egen double `maxyk' = max(`inc') if `touse'
		sum `maxyk', meanonly
		scalar `maxy'=r(min)
		if `touse' & `alpha'==0 {
		by `byg': egen double `Tk' = sum(`fik' * log(`meanyk' / `inc'))
		}
		if `touse' & `alpha'==1 {
		by `byg': egen double `Tk' = sum(`fik' * (`inc' / `meanyk') * log(`inc' / `meanyk'))
		}
		by `byg': gen double `wika' = `wi' if (`touse' & (`inc'>=`miny' & `inc'<=`maxy'))
		by `byg': gen double `wikb' = `wi' if (`touse' & (`inc'<`miny' | `inc'>`maxy'))
		by `byg': gen double `incka' = `inc' if (`touse' & (`inc'>=`miny' & `inc'<=`maxy'))
		by `byg': gen double `inckb' = `inc' if (`touse' & (`inc'<`miny' | `inc'>`maxy'))
	
	lab var `thetak' "Income share"
	lab var `vk' "Pop share"
	lab var `meanyk' "Mean income"
	lab var `Tk' "Group Theil"

	egen `maxg' = max(`byg')
	scalar G = `maxg' 	
	mat a = J(G,1,.)
	mat b = a
	mat c = a
	mat d = a
	scalar drop G

	capture levelsof `byg' if `touse' , local(grp)
	qui if _rc levels `byg' if `touse' , local(grp)

	gsort -`first' `byg'
	local i = 1
	foreach k of local grp {
		mat a[`k',1] = `thetak'[`i']
		mat b[`k',1] = `vk'[`i']
		mat c[`k',1] = `meanyk'[`i']
		mat d[`k',1] = `Tk'[`i']
		local ++i
	}
	return matrix IncomeShare = a
	return matrix PopShare = b
	return matrix MeanY = c
	return matrix GroupTheil = d
 
  	noi { 
		di "  "
		if `alpha'==0 di as txt "{bf: Theil's L (2nd) index decomposition}"
		if `alpha'==1 di as txt "Theil's T (1st) index decomposition" 
		di "  "
		di as txt "Groupwise inequality, for group g = 1,...,G"
		tabdisp `byg', c(`thetak' `vk' `meanyk' `Tk')  f(%9.6f)
	}
	drop `lambdak' `thetak'

	*** Theil index between-group inequality ***

	if `touse' & `alpha'==0 {
	egen double `Tb' = sum(`vk' * log(`meany' / `meanyk') / `ck') 
	}
	if `touse' & `alpha'==1 {
	egen double `Tb' = sum(`Syk' * log(`meanyk' / `meany')  / `ck') 
	}
	lab var `Tb' "Theil between"
	return scalar between_T = `Tb'[1]

	*** Theil index within-group inequality ***

	if `touse' & `alpha'==0 {
	egen double `Tw' = sum(`vk' * `Tk'  / `ck') 
	}
	if `touse' & `alpha'==1 {
	egen double `Tw' = sum(`Syk' * `Tk' / `ck') 
	}
	lab var `Tw' "Theil within"

	return scalar within_T = `Tw'[1] 

	noi { 
		di " "
		di as txt "Theil's decomposition of inequality by group" 
		tabdisp `touse' in 1, c(`T' `Tb' `Tw') f(%9.6f)
	}	

	drop `T' `Tb' `Tk' `Tw'

	** Theil index wihin-within-group inequalities **
	if `method' == 0 {

	if `touse' & `alpha'==0 {
	egen double `Twa' = sum(`vk'*(`wika'/`nk') * log(`meanyk'/`incka')) 
	}
	if `touse' & `alpha'==0 {
	egen double `Twb' = sum(`vk'*(`wikb'/`nk') * log(`meanyk'/`inckb'))
	} 
	if `touse' & `alpha'==1 {
	egen double `Twa' = sum(`Syk'*(`wika'/`nk') * (`incka'/`meanyk') * log(`incka'/`meanyk'))
	}
	if `touse' & `alpha'==1 {
	egen double `Twb' = sum(`Syk'*(`wikb'/`nk') * (`inckb'/`meanyk') * log(`inckb'/`meanyk'))
	}
	lab var `Twa' "Shared within" 
	lab var `Twb' "Dif'nt within"

	noi { 
		di "  "
		di as txt "Theil's decomposition: within-within-group inequality"
		tabdisp `touse' in 1 if `touse', c(`Twa' `Twb') f(%9.6f)
	}	

	return scalar shared_within = `Twa'[1]
	return scalar diffnt_within = `Twb'[1]
	drop `Twa' `Twb'
    }

******************************
* DECOMPOSITIONS BY QUANTILE *
******************************
 
  if `method' == 1 | `method'==2 {
  
  quietly {
  tempvar qnt nq vq fiq wiq meanyq syq Syq Tqb Tqw Twqb Twqw ///
  lambdaq Tq vqk fiqk wikq nqk meanyqk lambdaqk Syqk cq cqk  ///
  tqkb tqkw Tqkb Tqkw Head Tail head tail Mid mid mida midb ///
  TopMidR BotMidR TopBotR 
  if `method'==1 xtile `qnt' = `inc' [aw=`wi'], n(`quant')
  else if `method'==2 {
    _pctile `inc' [aw=`wi'], p(`quant')
	gen `qnt' = 1 if `inc'<=r(r1)
	replace `qnt' = 2 if `inc'>r(r1)
	}
  sort `qnt' `byg' `inc'    
	
	by `qnt': replace `first' = _n == 1 if `touse'
	by `qnt': egen double `cq' = count(`inc') if `touse'
	by `qnt': egen double `nq' = sum(`wi') if `touse'
	by `qnt': gen double `vq' = `nq' / `sumwi' if `touse'
	by `qnt': gen double `fiq' = `wi' / `nq' if `touse'
	by `qnt': egen double `meanyq' = sum(`fiq' * `inc') if `touse'
	by `qnt': egen double `syq' = sum(`wi' * `inc') if `touse'
	by `qnt': gen double `Syq' = (`syq' / `sumy') if `touse'
	if `touse' & `alpha'==0 {
	by `qnt': egen double `Tq' = sum(`fiq' * log(`meanyq' / `inc'))
	egen double `Tqb' = sum(`vq' * log(`meany' / `meanyq') / `cq') 
	egen double `Tqw' = sum(`vq' * `Tq' / `cq')
	}
	if `touse' & `alpha'==1 {
	by `qnt': egen double `Tq' = sum(`fiq' * (`inc' / `meanyq') * log(`inc' / `meanyq')) 
	egen double `Tqb' = sum(`Syq' * log(`meanyq' / `meany') / `cq') 
	egen double `Tqw' = sum(`Syq' * `Tq' / `cq')
	}
	by `qnt' `byg': egen double `cqk' = count(`inc') if `touse'
	by `qnt' `byg': egen double `vqk' = sum(`wi'/`nq') if `touse'
	by `qnt' `byg': egen double `nqk' = sum(`wi') if `touse'
	by `qnt' `byg': gen double `fiqk' = `wi' / `nqk' if `touse'
	by `qnt' `byg': egen double `meanyqk' = sum(`fiqk' * `inc') if `touse'
	by `qnt' `byg': egen double `Syqk' = sum((`wi' * `inc') / `syq') if `touse'
 	if `touse' & `alpha'==0 {
	by `qnt' `byg': egen double `tqkw' = sum(`fiqk' * log(`meanyqk' / `inc')) 
	by `qnt': egen double `Tqkb' = sum(`vq' * `vqk' * log(`meanyq' / `meanyqk') / `cqk')
	by `qnt': egen double `Tqkw' = sum(`vq' * `vqk' * `tqkw' / `cqk')
	}
	if `touse' & `alpha'==1 {
	by `qnt' `byg': egen double `tqkw' = sum(`fiqk' * (`inc' / `meanyqk') * log(`inc' / `meanyqk')) 	
	by `qnt': egen double `Tqkb' = sum(`Syq' * `Syqk' * log(`meanyqk' / `meanyq') / `cqk')
	by `qnt': egen double `Tqkw' = sum(`Syq' * `Syqk' * `tqkw' / `cqk')
	}
	egen `Tail'=min(`qnt') 
	egen `Head'=max(`qnt')
	gen double `head'=`Tqkb' if `qnt'==`Head'
	gen double `tail'=`Tqkb' if `qnt'==`Tail'
    replace `tail'=`tail'[_n-1] if missing(`tail')

	if `method'==1 {
	egen `Mid'=median(`qnt')
	if mod(`Head',2)==0 {
	  gen double `mida'=`Tqkb' if `qnt'==floor(`Mid')
	  gen double `midb'=`Tqkb' if `qnt'==round(`Mid')
	  replace `mida'=`mida'[_n-1] if missing(`mida')
	  replace `midb'=`midb'[_n-1] if missing(`midb')
	  while (missing(`mida') | missing(`midb')) {
	    replace `mida'=`mida'[_n+1] if missing(`mida')
	    replace `midb'=`midb'[_n+1] if missing(`midb')
	    }
	  while (missing(`mida') | missing(`midb')) {
	    replace `mida'=`mida'[_n+1] if missing(`mida')
	    replace `midb'=`midb'[_n+1] if missing(`midb')
	    }
	  egen double `mid'=rowmean(`mida' `midb')
      }
	if mod(`Head',2)!=0 {
	  gen double `mid'=`Tqkb' if `qnt'==`Mid'
	  replace `mid'=`mid'[_n-1] if missing(`mid')
	  while (missing(`head') | missing(`mid')) {
	    replace `head'=`head'[_n+1] if missing(`head')
	    replace `mid'=`mid'[_n+1] if missing(`mid')
	    }
	  }
    } // end if method=1 block
	if `method'==2 {
	while (missing(`head')) {
	  replace `head'=`head'[_n+1] if missing(`head')
	  }
	} // end if method=2 block

	egen `Twqb' = sum(`Tqkb'/`cq')
	egen `Twqw' = sum(`Tqkw'/`cq')
	lab var `Tqb' "Theil between" 
	lab var `Tqw' "Theil within"
	lab var `Tqkb' "Between in q" 
	lab var `Tqkw' "Within in q"
	lab var `Twqb' "Within q b'n" 
	lab var `Twqw' "Within q w'n"
	lab var `qnt' "q"
	if `method'==1 {
	  gen double `TopMidR' = 2*log(`head'/`mid')
	  gen double `BotMidR' = 2*log(`tail'/`mid')
	  lab var `TopMidR' "Top-mid lnR"
	  lab var `BotMidR' "Bot-mid lnR"
	  return scalar TopMidlnR = `TopMidR'[1]
	  return scalar BotMidBIC = `BotMidR'[1]
	}
	if `method'==2 {
	  gen double `TopBotR' = 2*log(`head'/`tail')
	  lab var `TopBotR' "Top-Bot lnR"
	  return scalar TopBotlnR = `TopBotR'[1]
	  }
		
	noi { 
		di "  "
		di as txt "Theil's decomposition of inequality by quantile"
		tabdisp `touse' in 1, c(`Tqb' `Tqw')  f(%9.6f)
		di "  "
		di as txt "Within-quantile inequality decomposition, for quantile q = 1,...,Q"
		if `touse' tabdisp `qnt', c(`Tqkb' `Tqkw')  f(%9.6f)
		di "  "
		di as txt "Total within-quantile decomposition (columns 1 & 2)"
		di as txt "BIC of within-quantile between-group contrasts (columns 3 & 4)"
		if `method'==1 tabdisp `touse' in 1, c(`Twqb' `Twqw' `TopMidR' `BotMidR')  f(%9.6f)
		if `method'==2 tabdisp `touse' in 1, c(`Twqb' `Twqw' `TopBotR')  f(%9.6f)
		}
	return scalar between_Tq = `Tqb'[1]
	return scalar within_Tq = `Tqw'[1]
	scalar Q=`Head'
	mat btn = J(Q,1,.)
	mat wtn = J(Q,1,.)
	capture levelsof `qnt' if `touse' , local(qgp)
	qui if _rc levels `qnt' if `touse' , local(qgp)

	gsort -`first' `qnt'
	local i = 1
	foreach j of local qgp {
		mat btn[`j',1] = `Tqkb'[`i']
		mat wtn[`j',1] = `Tqkw'[`i']
		local ++i
	}
	return matrix within_q_between = btn
	return matrix within_q_within = wtn

    } // end quietly block
  } // end if method=1 or 2 block
 } // end of  "if `byg'"  block for decompositions 
} // end quietly block

end
