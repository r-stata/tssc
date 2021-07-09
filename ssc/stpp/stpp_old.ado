*! version 0.2 2020-02-21

program define stpp_old, rclass
  version 16.0
  syntax [newvarlist(max=1)] using/                             ///
                                                                ///
	           [if] [in]                                        ///
		   ,                                                    ///
		   AGEDiag(varname)                                     ///
		   DATEDiag(varname)                                    ///
		   [                                                    ///  
		   by(varlist)                                          ///
		   ederer2                                              ///
		   INDWeights(varname)                                  ///
		   LIST(numlist ascending >0)                           ///
		   pmage(string)                                        ///
		   pmother(string)                                      ///
		   pmrate(string)                                       ///
		   pmyear(string)                                       ///
           pmmaxage(real 99)                                    ///
           pmmaxyear(real 10000)                                ///
		   STANDSTrata(varname)                                 ///                            
		   STANDWeights(numlist >=0 <=1)                        ///
		   verbose                                              ///
		   ]

  st_is 2 analysis
  marksample touse, novarlist
  qui replace `touse' = 0  if _st==0 | _st==. 	
	
// id variable
  if `"`_dta[st_id]'"' == "" {
  di as err "stpp requires that you have previously stset an id() variable"
    exit 198
  }

  cap bysort `_dta[st_id]' : assert _N==1
  if _rc {
    di as err "stpp requires that the data are stset with only one observation per individual"
    exit 198
  } 
	
************
// Checks //	
************

  confirm var `agediag' `datediag'
  confirm var `pmother'
  foreach var in `agediag' `datediag' `pmother' {
    qui count if missing(`var') & `touse'
    if `r(N)' >0 {
      di as error "`var' has missing values"
    }
  }
  local newvarname `varlist'

  if "`indweights'" != "" confirm var `indweights'    
  if "`by'"         != "" confirm var `by'    

  if "`standstrata'" != "" {
    qui levelsof `standstrata' if `touse'
    local Nstandlevels `r(r)'
    if "`standweights'" == "" {
      di "You need to specify weights using teh standweights() option when you standardize"
      exit 198
    }
    else {
      if wordcount("`standweights'") != `Nstandlevels' {
        di as error(You must give as many weights as there are levels of `standstrata')
        exit 198
      }
    }
  }
	
*******************	
// popmort file ///
*******************
  if "`pmage'" == "" local pmage _age
  if "`pmyear'" == "" local pmyear _year
  if "`pmrate'" == "" local pmrate rate
  qui describe using "`using'", varlist short
  local popmortvars `r(varlist)'
  foreach var in `pmage' `pmyear' `pmother' `pmrate' {
    local varinpopmort:list posof "`var'" in popmortvars
    if !`varinpopmort' {
      di "`var' is not in popmort file"
      exit 198
    }
  }

  // restrict popmort file to necessary ages and years
  tempvar attage yeardiag attyear

  summ `agediag' if `touse', meanonly
  local minage = floor(`r(min)')
  qui gen `attage' = `agediag' + _t + 1 if `touse'
  summ `attage' if `touse', meanonly
  local maxattage = min(ceil(`r(max)'),`pmmaxage')
  qui gen `yeardiag' = year(`datediag') if `touse'
  summ `yeardiag'  if `touse', meanonly
  local minyear = `r(min)'
  qui gen `attyear' = year(`datediag' + (_t+1)*365.25)  if `touse'
  summ `attyear' if `touse', meanonly
  local maxattyear = min(`r(max)',`pmmaxyear')	
  
  tempname popmortframe
  frame create `popmortframe'
  frame `popmortframe': use "`using'" if                             ///
	                   inrange(`pmage',`minage',`maxattage') &   ///
	                   inrange(`pmyear',`minyear',`maxattyear')          
	
  clear results
	
  mata: stpp()

*******************
// fill in gaps	///
*******************	

  local newvarlist `newvarname' `newvarname'_lci `newvarname'_uci
  tempvar d0
  gen byte `d0' = 1 - _d
  if "`by'" == "" {
    tempvar cons
    gen `cons' = 1
    local by `cons'
  }
	
  foreach v in `newvarlist' {
    quietly bysort `by' (_t `d0'): replace `v' = `v'[_n-1] if `v' >= . & `touse' & _d==0
  }
  return add
end

version 16.0
mata:
void function stpp() {
// Read in options
  verbose       = st_local("verbose") != ""
  hasindweights = st_local("indweights") != ""
  hasby         = st_local("by") != ""
  ederer2       = st_local("ederer2") != ""
  pmage         = st_local("pmage")
  pmyear        = st_local("pmyear")
  pmother       = tokens(st_local("pmother"))
  pmrate        = st_local("pmrate")
  pmmaxage      = strtoreal(st_local("pmmaxage"))
  pmmaxyear     = strtoreal(st_local("pmmaxyear"))
  newvarname    = st_local("newvarname")
  level         = st_numscalar("c(level)")/100  
  hasstandstrata = st_local("standstrata") != ""
  pmvars        = (pmage,pmyear,pmother,pmrate)
 
// details to list and store at specific values of time  
  list    = st_local("list")
  haslist = list != ""
  if(haslist) {
    list    = strtoreal(tokens(list))
    Nlist   = cols(list)
  }
  
// popmort file as a view
  if(verbose) printf("Reading in popmort file\n")

  currentframe = st_framecurrent()
  st_framecurrent(st_local("popmortframe"))
  st_view(popmort=.,.,pmvars,.)
  st_framecurrent(currentframe)

// read in relevant data
  touse     = st_local("touse")
  id        = st_data(.,st_global("_dta[st_id]"),touse)
  Nobs      = rows(id)

  datediag  = st_data(., st_local("datediag"), touse)
  agediag   = st_data(., st_local("agediag"), touse)
  
  // individual weights
  if(hasindweights) indweights    = st_data(.,st_local("indweights"),touse)
  else              indweights    = J(Nobs,1,1)
  
// standstrata
  if(hasstandstrata) {
    standstrata_var = st_local("standstrata")
    standstrata     = st_data(., standstrata_var, touse)
    standweights    = strtoreal(tokens(st_local("standweights")))	
    Nstandlevels    = strtoreal(st_local("Nstandlevels"))
    standlevels     = uniqrows(standstrata)
  } 
  else {
    Nstandlevels = 1
    standlevels  = 1
    standstrata = J(Nobs,1,1)
  }  
  
  
  // by variables
  if(hasby) {
    byvars     = st_local("by")
    by         = st_data(.,byvars,touse)
    bylevels   = uniqrows(by)
    Nbylevels  = rows(bylevels)
    Nbyvars    = cols(by)
    byvars     = tokens(byvars)
  }
  else {
    byvars     = J(1,0,"")
    by         = J(Nobs,1,1)
    bylevels   = 1
    Nbylevels  = 1
    Nbyvars    = 1
  }

  Npmother      = cols(pmother)
  pmothervars   = st_data(.,tokens(pmother),touse)
  Npmvars       = 2 :+ Npmother
  ratevarcol    = Npmvars + 1

  t  = st_data(.,"_t",touse)
  t0 = st_data(.,"_t0",touse)
  d  = st_data(.,"_d",touse) 

  unique_t_sk  = asarray_create("real",2)
  unique_t_k   = asarray_create("real",1)
  Nunique_t_sk = J(Nstandlevels,Nbylevels,.)
  Nobs_by_sk   = J(Nstandlevels,Nbylevels,.)  

// store popmort file in array
// for each pm strata from matrix for ages(rows) and columns(years)
  pmoth_levels  = uniqrows(pmothervars)
  Npmoth_levels = rows(pmoth_levels)

  pm = asarray_create("real",Npmother) //- appropraiet dimensions
  cols_pmother = J(1,Npmoth_levels,.)
  pm_endcol = 3 :+ (Npmother:-1)

  pm_minage   = min(popmort[,1])
  pm_maxage   = max(popmort[,1])
  pm_minyear  = min(popmort[,2])
  pm_maxyear  = max(popmort[,2])
  ageplus   = 1 - pm_minage
  yearplus  = 1 - pm_minyear 
  
  for(j=1;j<=Npmoth_levels;j++) {
    tmppm = popmort[selectindex(popmort[,3..pm_endcol]:==pmoth_levels[j,]),]
    tmp_ageyear = J((pm_maxage:-pm_minage:+1),(pm_maxyear:-pm_minyear:+1),.)
    tmppm[,1] = tmppm[,1] :+ ageplus
    tmppm[,2] = tmppm[,2] :+ yearplus
    Nrows_tmppm = rows(tmppm)

    for(i=1;i<=Nrows_tmppm;i++) {
      tmp_ageyear[tmppm[i,1],tmppm[i,2]] = tmppm[i,ratevarcol]
    }
    asarray(pm,pmoth_levels[j,],tmp_ageyear)
	  
    cols_pmother[j] = cols(asarray(pm,pmoth_levels[j,]))
  }

// unique values of t
  Nunique_t_k = J(1,Nbylevels,.)
  for(k=1;k<=Nbylevels;k++) {
    for(s=1;s<=Nstandlevels;s++) {
      asarray(unique_t_sk,(s,k),uniqrows(t[selectindex(d :& rowsum(by:==bylevels[k,]):==Nbyvars :& standstrata:==standlevels[s])]))
      Nunique_t_sk[s,k] = rows(asarray(unique_t_sk,(s,k)))
      Nobs_by_sk[s,k]   = sum(by:==bylevels[k,] :& standstrata:==standlevels[s])
    }
    asarray(unique_t_k,(k),uniqrows(t[selectindex(d :& rowsum(by:==bylevels[k,]):==Nbyvars)]))
    Nunique_t_k[k] = rows(asarray(unique_t_k,(k)))
  }
  Nobs_by_k = colsum(Nobs_by_sk)

  // calculate PP
  returnmat    = J(Nobs,3,.)
  lambda_t     = asarray_create("real",Nbyvars:+1)
  lambda_t_var = asarray_create("real",Nbyvars:+1)

// loop over by groups and standardized levels 
timer_on(99)
  for(k=1;k<=Nbylevels;k++) {
    for(s=1;s<=Nstandlevels;s++) {
      if(hasby) {
        if(verbose) {
  	  bytext = ""
  	  for(j=1;j<=Nbyvars;j++) {
  	    bytext = bytext + byvars[j] + " = " + strofreal(bylevels[k,j])  + (j!=Nbyvars):*", "
  	  }	
          printf("\nStratum: %s = %3.0f",standstrata_var,s)
          printf("\n%s\n",bytext)
        }
      }
      if(verbose) printf("\nLooping over Risksets\n")

      byselect     = rowsum(by:==bylevels[k,]):==Nbyvars :& standstrata:==standlevels[s]
      byselect_ind = selectindex(byselect)

      lambda_tmp     = J(Nunique_t_sk[s,k],1,.)
      lambda_tmp_var = J(Nunique_t_sk[s,k],1,.)

      t_rates_start = (0\asarray(unique_t_sk,(s,k))[|1 \ (Nunique_t_sk[s,k]:-1)|])
      y = asarray(unique_t_sk,(s,k)) :- t_rates_start

      pmmaxyear_vec = J(Nobs_by_sk[s,k],1,pmmaxyear)
      pmmaxage_vec  = J(Nobs_by_sk[s,k],1,pmmaxage)
      expcumhaz     = J(Nobs_by_sk[s,k],1,0)

      t_by           = t[byselect_ind]
      t0_by          = t0[byselect_ind]
      d_by           = d[byselect_ind]
      agediag_by     = agediag[byselect_ind] 
      datediag_by    = datediag[byselect_ind]
      indweights_by  = indweights[byselect_ind]
      pmothervars_by = pmothervars[byselect_ind] 

      Nobs_sk = Nobs_by_sk[s,k]
      Nuniq   = Nunique_t_sk[s,k]

      for(j=1;j<=Nuniq;j++) {
        if(verbose) {
  	       printf(".")
    	  displayflush()
  	    }   
	    tj       = asarray(unique_t_sk,(s,k))[j]
        yj       = y[j]
  	    tstart_j = t_rates_start[j]
	  
    	atrisk  = (t_by:>=tj):&(t0_by:<tj)

    	attage  = rowmin((floor(agediag_by :+ (tstart_j)), pmmaxage_vec)) :+ ageplus
    	attyear = rowmin((year(datediag_by :+ (tstart_j)*365.24), pmmaxyear_vec)) :+ yearplus
	  
        exprates = J(Nobs_sk,1,.)

        bob = J(Nobs_sk,2,.)
  	for(p=1;p<=Npmoth_levels;p++) {
	  pmotherselect = pmothervars_by :== pmoth_levels[p,]
          zzz = cols_pmother[p]
          for(b=zzz;b;b--) {
  	    rateindex = selectindex((attyear:==b) :& pmotherselect)
	    if(rows(rateindex)) exprates[rateindex] = yj:*(asarray(pm,pmoth_levels[p,])[attage[rateindex] , b])
  	    if(!hasmissing(exprates)) break
  	  }
  	}

        expcumhaz = expcumhaz :+ exprates
        expsurv_tj = exp(-(expcumhaz))

        if(!ederer2) wt_t = indweights_by:/expsurv_tj
        else wt_t = indweights_by

        died_tj = (t_by:==tj) :& d_by
    	wt_atrisk = atrisk :* wt_t
  
        N_wt = sum(wt_atrisk :* died_tj)
        Y_wt = sum(wt_atrisk)	
        v1   = sum(wt_atrisk:^2 :* died_tj)	

        lambda_tmp[j] = (N_wt :- sum(wt_atrisk:*exprates)):/Y_wt
        lambda_tmp_var[j] = (v1:/(Y_wt:^2))
      }
      asarray(lambda_t,    (s,bylevels[k]),(lambda_tmp))
      asarray(lambda_t_var,(s,bylevels[k]),(lambda_tmp_var))
    }
  }
 timer_off(99)
 
// now for each level of by group assemble the strata
  RS_PP = asarray_create("real",1)
  zz = invnormal(0.5*(1+level))
  if(hasstandstrata) {
    for(k=1;k<=Nbylevels;k++) {
      Nuniq  = Nunique_t_k[k]
      tmpmat   = J(Nuniq,Nstandlevels,.)
      tmpmat_v = J(Nuniq,Nstandlevels,.)
   	for(s=1;s<=Nstandlevels;s++) {
	  for(j=1;j<=Nuniq;j++) {
	    tj = asarray(unique_t_k,k)[j]
	    qqq = selectindex(asarray(unique_t_sk,(s,k)):==tj)
	    if(rows(qqq)!=0) {
	      tmpmat[j,s]   = asarray(lambda_t,(s,bylevels[k]))[qqq] 
	      tmpmat_v[j,s] = asarray(lambda_t_var,(s,bylevels[k]))[qqq]  
	    }
          }
	  tmpmat[,s]   = runningsum(tmpmat[,s])
	  tmpmat_v[,s] = ((exp(-tmpmat[,s]):^2):*runningsum(tmpmat_v[,s]))
	}
	RS_tmp   = J(Nuniq,1,0)
	RS_tmp_v = J(Nuniq,1,0)

	for(s=1;s<=Nstandlevels;s++) {
	  RS_tmp   = RS_tmp   :+ standweights[s]:*exp(-(tmpmat[,s]))
	  RS_tmp_v = RS_tmp_v :+ standweights[s]:^2:*(tmpmat_v[,s])
	}
      asarray(RS_PP,k,(RS_tmp, RS_tmp:- zz:*sqrt(RS_tmp_v), RS_tmp:+ zz:*sqrt(RS_tmp_v)))
    }
  }	  
  else {
    for(k=1;k<=Nbylevels;k++) {
      tmpmat = runningsum(asarray(lambda_t,(1,bylevels[k])))
      tmpmat_v = sqrt(runningsum(asarray(lambda_t_var,(1,bylevels[k])))) 
      asarray(RS_PP, k, exp(-(tmpmat, tmpmat :+ zz:*tmpmat_v, tmpmat :- zz:*tmpmat_v)))
    }
  }

// create output list
  if(haslist) {
    list_matrix = asarray_create("real",1)
    for(k=1;k<=Nbylevels;k++) {
      tmplist = J(Nlist,4,.)
      for(i=1;i<=Nlist;i++) {
        tindex = selectindex(asarray(unique_t_k,k):<=list[i])
        minindex(list[i]:-asarray(unique_t_k,k)[tindex],1,tminindex,tmp=.)
	tmplist[i,] = (i,asarray(RS_PP, k)[tminindex,])
      }
      asarray(list_matrix,k,tmplist)
    }
  }

  for(k=1;k<=Nbylevels;k++) {
    Nuniq  = Nunique_t_k[k]
    for(j=1;j<=Nuniq;j++) {
      has_tj = selectindex(t:==asarray(unique_t_k,k)[j] :& rowsum(by:==bylevels[k,]):==Nbyvars :& d:==1)
      if(rows(has_tj)>0) returnmat[has_tj,] = J(rows(has_tj),1,(asarray(RS_PP, k))[j,])
    }  	
  }    
 
// save new variables
  newvars = newvarname,newvarname+"_lci", newvarname+"_uci"
  (void) st_addvar("double", newvars)
  st_store(.,newvars,touse,returnmat)
  if(verbose) printf("\nVariables " + invtokens(newvars) + " created")
  
// List and store results

  if(haslist) {
    printf("\n\nPohar Perme Estimates of Marginal Relative Survival\n")
    if(hasstandstrata) printf("(Standardized by %s)",standstrata_var) 
    printf("\n\n")
    for(k=1;k<=Nbylevels;k++) {
      if(hasby) {
    	bytext = ""
    	for(j=1;j<=Nbyvars;j++) {
    	  bytext = bytext + byvars[j] + " = " + strofreal(bylevels[k,j])  + (j!=Nbyvars):*", "
    	}
    	printf("{txt}-> %s\n\n",bytext)
      }
      printf("{txt}Time{space 4}{c |}   PP (95%% CI) \n")
      printf("{hline 8}{c +}{hline 26}\n")		
      for(i=1;i<=Nlist;i++) {
	printf("{res}%3.2g{space 4}{txt}{c |} {res}%5.3f (%5.3f to %5.3f)\n",
        asarray(list_matrix,k)[i,1],
	asarray(list_matrix,k)[i,2],
	asarray(list_matrix,k)[i,3],
	asarray(list_matrix,k)[i,4])
      }
      printf("{txt}{hline 8}{c +}{hline 26}\n\n")
      rmatname = "r(PP" + strofreal(k) + ")"
      stata("return clear")
      st_matrix(rmatname,asarray(list_matrix,k))
    }
  }
}

end

	








