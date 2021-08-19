*! version 1.0 2020-12-29

// ADD THE FOLLOWING
// checks that not overlap between keep and pmother and by
// if lifetable not long enough

program define mrsprep, rclass
  version 16.0
  syntax [newvarlist(max=1)] using/                           ///
         [if] [in]                                            ///
         ,                                                    ///
         AGEDiag(varname)                                     ///
         BReaks(numlist)                                      ///
         DATEDiag(varname)                                    ///
         [                                                    ///  
         by(varlist)                                          ///
         INDWeights(varname)                                  ///
         KEEP(varlist)                                        ///
         NEWFrame(string)                                     ///                 
         pmage(string)                                        ///
         pmother(string)                                      ///
         pmrate(string)                                       ///
         pmyear(string)                                       ///
         pmmaxage(real 99)                                    ///
         pmmaxyear(real 10000)                                ///
         verbose                                              ///
         ]

  st_is 2 analysis
  marksample touse, novarlist
  qui replace `touse' = 0  if _st==0 | _st==. 	
	
// id variable
  if `"`_dta[st_id]'"' == "" {
    di as err "mrsprep requires that you have previously stset an id() variable"
    exit 198
  }

  cap bysort `_dta[st_id]' : assert _N==1
  if _rc {
    di as err "mrsprep requires that the data are stset with only one observation per individual"
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
      exit 198
    }
  }
  local newvarname `varlist'

  if "`indweights'" != "" confirm var `indweights'    
  if "`by'"         != "" confirm var `by'    

  qui frame
  local currentframe  `r(currentframe)'

  if "`newframe'" == "" local newframe mrs_data
  else {
    tokenize "`newframe'", parse(",")
    if "`1'"=="," local newframe mrs_data
    else local newframe `1'
    if "`3'" == "replace" | "`2'" == "replace" local framereplace replace    
  }
  qui frames dir
  local framelist `r(frames)'
  local frameexists:list posof "`newframe'" in framelist
  if `frameexists' & "`framereplace'" == "" {
    di as err "Frame `newframe' exists. Drop it or use replace option"
    exit 198
  }	
  if "`newframe'" == "`currentframe'" {
    di as err "The active frame is `currentframe' and you cannot overwrite it"
    exit 198
  }
  if `frameexists' & "`framereplace'" == "replace" {
    frame drop `newframe'
  }
	
*******************	
// popmort file ///
*******************
  if "`pmage'" == ""  local pmage _age
  if "`pmyear'" == "" local pmyear _year
  if "`pmrate'" == "" local pmrate rate
  
  local usingfilename `using'
  qui describe using "`usingfilename'", varlist short
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
  qui gen `attyear' = year(`datediag' + (_t+1)*365.241)  if `touse'
  summ `attyear' if `touse', meanonly
  local maxattyear = min(`r(max)',`pmmaxyear')	


  tempname popmortframe
  frame create `popmortframe'
  frame `popmortframe': use "`using'" if                          ///
                        inrange(`pmage',`minage',`maxattage') &   ///
	                inrange(`pmyear',`minyear',`maxattyear')
  clear results

  mata: mrsprep()
  sort id tstart
end

version 16.0
mata:
void function mrsprep() {
// Read in options
  verbose       = st_local("verbose") != ""
  hasindweights = st_local("indweights") != ""
  hasby         = st_local("by") != ""
  haskeep       = st_local("keep") != ""
  pmage         = st_local("pmage")
  pmyear        = st_local("pmyear")
  pmother       = tokens(st_local("pmother"))
  pmrate        = st_local("pmrate")
  pmmaxage      = strtoreal(st_local("pmmaxage"))
  pmmaxyear     = strtoreal(st_local("pmmaxyear"))
  pmvars        = (pmage,pmyear,pmother,pmrate)
  breaks        = strtoreal(tokens(st_local("breaks") ))'
  
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

  datediag_varname   = st_local("datediag")
  datediag_varlabel  = st_varlabel(datediag_varname)
  datediag           = st_data(., datediag_varname, touse)

  agediag_varname    = st_local("agediag")
  agediag_varlabel   = st_varlabel(agediag_varname)
  agediag            = st_data(., agediag_varname, touse)
  
  // individual weights
  if(hasindweights) indweights    = st_data(.,st_local("indweights"),touse)
  else              indweights    = J(Nobs,1,1)
  
  // by variables
  if(hasby) {
    byvars     = tokens(st_local("by"))
    by         = st_data(.,(byvars),touse)
    bylevels   = uniqrows(by)
    Nbylevels  = rows(bylevels)
    Nbyvars    = cols(by)
  }
  else {
    byvars     = "cons"
    by         = J(Nobs,1,1)
    bylevels   = 1
    Nbylevels  = 1
    Nbyvars    = 1
  }
  
  //keep variables
  if(haskeep) {
    keepvars = tokens(st_local("keep"))
    keepdata = st_data(.,keepvars,touse)
  }
  else {
    keepvars = J(1,0,"")
    keepdata = J(Nobs,0,.)
  }	  
 
  Npmother      = cols(pmother)
  pmothervars   = st_data(.,(pmother),touse)
  Npmvars       = 2 :+ Npmother
  ratevarcol    = Npmvars + 1
  pmoth_levels  = uniqrows(pmothervars)
  Npmoth_levels = rows(pmoth_levels)

  t  = st_data(.,"_t",touse)
  t0 = st_data(.,"_t0",touse)
  d  = st_data(.,"_d",touse) 

  unique_t_k   = asarray_create("real",1)

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
  
// error checks
  if(rows(popmort) != rows(uniqrows(popmort[,1..pm_endcol]))) {
    errprintf(pmage + ", " + pmyear + ", " + invtokens(pmother,", ") + " do not uniquely represent observations in using file\n")
    exit(198)
  }   

  for(j=1;j<=Npmoth_levels;j++) {
    tmppm = popmort[selectindex(rowsum(popmort[,3..pm_endcol]:==pmoth_levels[j,]):==Npmother),]
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
  Nobs_by_k = J(1,Nbylevels,.)
  for(k=1;k<=Nbylevels;k++) {
    asarray(unique_t_k,(k),uniqrows(t[selectindex(d :& (rowsum(by:==bylevels[k,]):==Nbyvars))]))
    tmpuniqe_t = rows(asarray(unique_t_k,(k)))
    if(tmpuniqe_t==1) {
        errprintf("Zero or one event for by level: %s\n", invtokens(strofreal(bylevels[k,]))) 
        exit(2000)
    }
    Nunique_t_k[1,k] = rows(asarray(unique_t_k,(k)))
    Nobs_by_k[1,k] = sum(rowsum(by:==bylevels[k,]):==Nbyvars)
  }


// create matrix of yearly rates
  N_breaks = rows(breaks)
  t_start      = breaks[1..(N_breaks:-1),]
  N_intervals  = rows(t_start)
  t_stop       = breaks[2..(N_breaks),]
  int_length   = t_stop :- t_start  

	
  // calculate PP
  meanhazard = J(Nobs,1,.)

// loop over by groups 
  for(k=1;k<=Nbylevels;k++) {
    if(hasby) {
      if(verbose) {
        bytext = ""
        for(j=1;j<=Nbyvars;j++) {
          bytext = bytext + byvars[j] + " = " + strofreal(bylevels[k,j])  + (j!=Nbyvars):*", "
        }	
        printf("\n%s\n",bytext)
      }
    }
    if(verbose) printf("\nLooping over Risksets\n")
 
    byselect     = rowsum(by:==bylevels[k,]):==Nbyvars
    byselect_ind = selectindex(byselect)
    
    t_rates_start = (0\asarray(unique_t_k,(k))[|1 \ (Nunique_t_k[k]:-1)|])
    y = asarray(unique_t_k,(k)) :- t_rates_start

    pmmaxyear_vec = J(Nobs_by_k[k],1,pmmaxyear)
    pmmaxage_vec  = J(Nobs_by_k[k],1,pmmaxage)
    expcumhaz     = J(Nobs_by_k[k],1,0)

    t_by           = t[byselect_ind]
    t0_by          = t0[byselect_ind]
    d_by           = d[byselect_ind]
    agediag_by     = agediag[byselect_ind] 
    datediag_by    = datediag[byselect_ind]
    indweights_by  = indweights[byselect_ind]
    pmothervars_by = pmothervars[byselect_ind,] 
    Nobs_k = Nobs_by_k[k]
    Nuniq  = Nunique_t_k[k]
    tmp_meanhazard = J(Nuniq,1,.)

    for(j=1;j<=Nuniq;j++) {
      if(verbose) {
        printf(".")
        displayflush()
      } 
  	  
      tj       = asarray(unique_t_k,(k))[j]
      tstart_j = t_rates_start[j]
      yj       = y[j]
 
      atrisk_all  = (t_by:>=tj)
      atrisk_all_index = selectindex(atrisk_all)      

      atrisk  = (t_by:>=tj) :& (t0_by:<tj)
      atrisk_index =selectindex(atrisk)

      attage  = rowmin((floor(agediag_by[atrisk_all_index] :+ (tstart_j)), pmmaxage_vec[atrisk_all_index])) :+ ageplus
      attyear = rowmin((year(datediag_by[atrisk_all_index] :+ (tstart_j)*365.241), pmmaxyear_vec[atrisk_all_index])) :+ yearplus
      
      exprates = J(rows(atrisk_all_index),1,.)
      for(p=1;p<=Npmoth_levels;p++) {
        pmotherselect = rowsum(pmothervars_by[atrisk_all_index,] :== pmoth_levels[p,]):==Npmother :& atrisk_all[atrisk_all_index]
        zzz = cols_pmother[p]
        for(b=zzz;b;b--) {
          rateindex = selectindex((attyear:==b) :& pmotherselect)
          if(rows(rateindex)) exprates[rateindex] = (asarray(pm,pmoth_levels[p,])[attage[rateindex] , b])
          if(!hasmissing(exprates)) break
        }
      }

      expcumhaz[atrisk_all_index] = expcumhaz[atrisk_all_index] :+ exprates:*yj

      expsurv_tj = exp(-(expcumhaz[atrisk_all_index]))

      wt_t = indweights_by[atrisk_all_index]:/expsurv_tj
      hastj = selectindex(byselect :& t:==tj :& d)
      meanhazard[hastj] = J(rows(hastj),1,mean(exprates, wt_t:*atrisk[atrisk_all_index]))
    }
  }
  
// Now loop over t_start to create expanded data
  if(verbose) printf("\nWriting Data\n.")
  
  // if by includes same variables in pmothervars

  bypmcombvars = pmother
  bypmcomb = pmothervars
  if(hasby) {
    for(k=1;k<=Nbyvars;k++) {
      if(rowsum(byvars[k]:==bypmcombvars)) continue
      bypmcomb = bypmcomb, by[,k]
      bypmcombvars = bypmcombvars,byvars[1,k]
    }
  }

  newvars = ("id",
             agediag_varname,
             datediag_varname,
             bypmcombvars,
             keepvars,
             "meanhazard_wt",
             "tstart",
             "tstop",
             "event",
             "t",
             "wt")

  expanded_data = J(0,cols(newvars),.)			 
  expcumhaz = J(Nobs,1,0)
  for(i=1;i<=N_intervals;i++) {
    if(verbose) {
      printf(".")
  	  displayflush()
  	} 

    atrisk = selectindex(t:>t_start[i] :& t0:<=t_start[i])
    addedrows = rows(atrisk)
    event = d:*(t:<=t_stop[i] :& t:>t_start[i])

    mhtmp = meanhazard[atrisk]:*event[atrisk]
    to999 = selectindex(event[atrisk]:==0)
    mhtmp[to999] = J(rows(to999),1,999) 

    ttmp = t[atrisk]

    yi = (ttmp:>t_stop[i]):*(t_stop[i] :- t_start[i]) :+ (ttmp:<=t_stop[i] :& ttmp:>t_start[i]):*(ttmp:-t_start[i])
    ttmp_stop = t_start[i] :+ yi

    attage  = rowmin((floor(agediag[atrisk] :+ (t_start[i])), J(addedrows,1,pmmaxage))) :+ ageplus
    attyear = rowmin((year(datediag[atrisk] :+ (t_start[i]):*365.241), J(addedrows,1,pmmaxyear))) :+ yearplus

    exprates = J(addedrows,1,.)

    for(p=1;p<=Npmoth_levels;p++) {
      zzz = cols_pmother[p]
        for(b=zzz;b;b--) {	
          ageindex = selectindex(attyear:==b)
          if(rows(ageindex)) exprates[ageindex] = yi[ageindex]:*(asarray(pm,pmoth_levels[p,])[attage[ageindex] , attyear[b]])
          if(!hasmissing(exprates)) break
      }
    }	
	
    expcumhaz[atrisk] = expcumhaz[atrisk] :+ exprates
    tmpexpcumhaz = expcumhaz[atrisk] :- exprates:/2 
    wt = indweights[atrisk]:/exp(-(tmpexpcumhaz))
    //wt = indweights[atrisk]:/exp(-(expcumhaz[atrisk]))
       
    expanded_data = expanded_data \
      (id[atrisk],
      agediag[atrisk],
      datediag[atrisk],
      bypmcomb[atrisk,],
      keepdata[atrisk,],
      mhtmp,           
      J(addedrows,1,t_start[i]),
      ttmp_stop,
      event[atrisk],
      t[atrisk],
      wt)
  }

 // new variables  

  newframe = st_local("newframe")
  st_framecreate(newframe)
  st_framecurrent(newframe)
  st_addobs(rows(expanded_data))

  (void) st_addvar("double", newvars)
  st_store(.,newvars,expanded_data)

  st_varlabel(datediag_varname, datediag_varlabel)
  st_varlabel(agediag_varname,  agediag_varlabel)  

}

end




        
