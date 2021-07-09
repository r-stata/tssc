/***********************
*
* cem-stata: mata utility functions
* mb 07/03/08
*
* description: mata functions to run CEM
*
************************/

version 10.1
mata:


mata clear


real scalar sturges(x) {
  classes = ceil((log10(rows(x))/log10(2))+1)
  return(classes)
}
real scalar quantile(numeric vector x, numeric scalar p) {
  n = rows(x)
  q = .5*(sort(x,1)[ceil(p*n)] + sort(x,1)[floor(p*n+1)])
  return(q)
}

real scalar iqr(numeric vector x) {
  return(quantile(x,.75)-quantile(x,.25))
}

real scalar rangeof(numeric vector x) {
  return(max(x)-min(x))
}

real vector sample(numeric scalar n, numeric vector x) {
   out = x[ceil(runiform(n, 1) * length(x))]
   return(out)
}

real vector bincount2(real vector x, real vector breaks,
                      real scalar inclbor, real scalar left) {

  counts = J(length(breaks)-1,1,0)

  for (i = 1; i <=length(x); i++) {
    lo = 1
    hi = length(breaks)
    if (breaks[lo] <= x[i] &&
        (x[i] < breaks[hi] || (x[i]==breaks[hi] && (inclbor)))) {
      while (hi-lo >= 2) {
        newpt = (hi+lo)/2
        if (x[i] > breaks[newpt] || (x[i]==breaks[newpt] && left))
          lo = newpt
        else
          hi = newpt
      }
      counts[lo] = counts[lo]+1
    }
  }
  return(counts)

}


real vector bincount(real vector x, real vector breaks,
                     real scalar inclbor, real scalar left) {

  counts = J(length(breaks)-1,1,0)

  for (i = 1; i <= length(breaks)-1; i++) {
    counts[i] = sum((x :>= breaks[i]) :& (x :<breaks[i+1]))
  }
  return(counts)

}

real scalar shsh(numeric vector x) {
  N = 2::100
  C = J(length(N),1,.)
  D = C

  for (i = 1; i <= length(N); i++) {
    D[i] = rangeof(x)/N[i]
    edges = rangen(min(x),max(x),N[i])
    cn = bincount(x, edges, 1, 0)
    k = mean(cn)
    v = sum((cn:-k):^2)/N[i]
    C[i] = (2*k-v)/D[i]^2
    C[i]
  }
  minC = (C:==min(C))
  if (sum(minC)>1)
    ret = select(N,minC)[1]
  else
    ret = select(N,minC)
  return(ret)

}

numeric scalar FD (numeric vector x) {
  n = rows(x)
  h = iqr(x)
  if (h == 0)
    h <- quantile(abs(x:-quantile(x,.5)),.5)
  if (h > 0)
    return(ceil(rangeof(x)/(2*h*n^(-1/3))))
  else
    return(1)
}

numeric scalar scott(numeric vector x) {
  n = rows(x)
  v = variance(x)
  h = 3.5 * sqrt(v) *n^(-1/3)

  if (h > 0)
    return(ceil(rangeof(x)/h))
  else
    return(1)
}


real vector cut(numeric vector x, numeric vector breaks) {
  xx =  x:*0 :+ (x :>= breaks[1])
  for (i=2; i <= length(breaks); i++) {
    xx = xx :+ (x :> breaks[i])
  }
  return(xx)
}



/* Note a difference from the R version, which
uses "pretty" to make pretty cutpoints. No alternative
in Mata.
*/
  real vector coarsen(numeric vector x, breaks) {
    if (isstring(breaks)) {
      if (breaks == "sturges")
        breaks = sturges(x)
      else if (breaks == "fd")
        breaks = FD(x)
      else if (breaks == "scott") {
        breaks = scott(x)
      }
      else if (breaks == "ss") {
        breaks = shsh(x)
      }
      else
        _error("break method not supported")
    }
    if (breaks==0 | breaks ==.) {
      outx = x
    }
    else {
      if (length(breaks) == 1 & breaks != .) {
          breaks = rangen(min(x),max(x),breaks)
      }
      if (length(breaks) > 0) {
        outx=cut(x,breaks)
      }
    }
    return(outx)
  }

struct veclist {
  real vector vec
  string scalar autoname
}


struct cemout {
  real matrix data
  struct veclist vector cutpoints

}

struct cemout cem(numeric matrix data, real colvector treatment,
                  struct veclist vector cutpoints, string scalar impvar) {

  struct cemout scalar out

  n = rows(data)
  k = cols(data)

  out.cutpoints = veclist(k)
  out.data = J(n,k,.)

  for (i=1; i <= k; i++) {
    if (cutpoints[i].vec == J(1,1,.))
      tempcuts = cutpoints[i].autoname
    else
      tempcuts = cutpoints[i].vec
    out.data[,i] = coarsen(data[,i], tempcuts)
    out.cutpoints[i].vec = tempcuts
    out.cutpoints[i].autoname =  cutpoints[i].autoname
  }
  if (treatment==.)
    assignStrata(out.data, impvar)
  else
    assignStrata(out.data, impvar, treatment)

  return(out)
}


void assignStrata(real matrix x, string scalar impvar, | real vector treat) {
  n = rows(x)
  k = cols(x)
  touse = st_local("touse")

  strs = strofreal(x)
  xx = J(n,1,"")
  for (i=1; i <= n; i++) {
    xx[i] = invtokens(strs[i,])
  }

  strata = J(n,1,0)
  st = uniqrows(xx)
  nstrata = length(st)

  if (args()==3) {
    groups = uniqrows(treat)
    ngroups = length(groups)
    gtable = J(nstrata,ngroups,0)
    matched = J(n,1,0)
  }

  for (i = 1; i <= n; i++) {
    strata[i] = lookup(xx[i], st)
    if (args() == 3) {
      thistreat = oneInds(treat[i] :== groups)
      gtable[strata[i],thistreat] = gtable[strata[i],thistreat] + 1
      if (min(gtable[strata[i],]) > 0) {
          matched = matched :+ (1:-matched):*(strata:==strata[i])
      }
    } 
  }
/*  for (i = 1; i <= nstrata; i++) {
    strata = strata :+ i:*strmatch(xx,st[i])

    if (args()==3) {
      for (g = 1; g <= ngroups; g++) {
        gtable[i,g] = sum(treat :== groups[g] :& strata :== i)
      }
      if (min(gtable[i,]) == 0) {
        mstrata = mstrata :+ strmatch(xx,st[i])
      }
    }
  }
*/
  /* if (args() == 3) { */
  /*   mstrata = rowmin(gtable) :> 0 */
  /*   for (i = 1; i <=nstrata; i++) { */
  /*     matched = matched + (strata:==i):*mstrata[i] */
  /*   } */
  /* } */
  if (impvar != "") {
    if (args() == 3) {
      combineMulticem(strata, impvar, treat)
    } else {
      combineMulticem(strata, impvar)
    }
  } else {

    if (_st_varindex("cem_strata")!=.)
      st_dropvar("cem_strata")
    if (nstrata > 32700) {
      (void) st_addvar("long","cem_strata")
    } else {      
      (void) st_addvar("int","cem_strata")
    }
    st_store(., "cem_strata", touse, strata)
    st_rclear()
    st_numscalar("r(n_strata)", nstrata)
    
    
    if (args()==3) {
      if (_st_varindex("cem_matched")!=.)
        st_dropvar("cem_matched")
      (void) st_addvar("double","cem_matched")
      st_store(.,"cem_matched", touse,matched)
      st_matrix("r(groups)", groups)
      st_matrix("r(gtable)",gtable)
      st_matrixcolstripe("r(gtable)", (J(ngroups,1,""),strofreal(groups)))
      st_numscalar("r(n_groups)",ngroups)
      
      cemsum = J(3,ngroups,.)
      
      cemsum[1,] = colsum(gtable)
      cemsum[2,] = colsum(select(gtable,rowmin(gtable) :>0))
      cemsum[3,] = colsum(select(gtable,rowmin(gtable) :==0))
      
      st_matrix("r(cem_sum)", cemsum)
      st_matrixrowstripe("r(cem_sum)", (J(3,1,""),("All"\ "Matched"\"Unmatched")))
      st_matrixcolstripe("r(cem_sum)",(J(ngroups,1,""),strofreal(groups)))
      wh = gtable[,2]:/gtable[,1] :* sum(treat:==groups[1] :& matched :== 1)/
        sum(treat:==groups[2] :& matched :== 1)
      wh = wh[strata',] :* (matched:==1)
      wh = wh :* (!(wh :> 0 :& treat:==1)) + (wh :> 0 :& treat:==1)
      wh = editmissing(wh, 0)
      if (_st_varindex("cem_weights")!=.)
        st_dropvar("cem_weights")
      (void) st_addvar("double","cem_weights")
      st_store(., "cem_weights", touse, wh)
      st_numscalar("r(n_matched)",sum(matched:==1))
      st_numscalar("r(n_mstrata)",sum(uniqrows(strata:*matched):>0))
    }
  }
}



struct veclist makeCuts(string vector cutlist, real matrix data) {

struct veclist vector cutpoints
cutpoints = J(length(cutlist),1,veclist())
/* we need to parse the breaks list */
  for (i=1; i <= length(cutlist); i++) {

    /* number of breaks has the hash first */
    if (strmatch(cutlist[i],"#*")) {
        cutpoints[i].vec = strtoreal(subinstr(cutlist[i],"#",""))
        cutpoints[i].autoname = "user"
    }
    else {
      /* names have no numbers */
      if (regexm(cutlist[i],"[0-9]")==0) {
        cutpoints[i].vec= J(1,1,.)
        cutpoints[i].autoname = cutlist[i]
      }
      else {
        /* everything else should be a numlist */
        stcommand = `"numlist ""'+ cutlist[i] + `"" "'
        stata(stcommand)
        cutz = strtoreal(tokens(st_global("r(numlist)")))'

        if (length(cutz) == 1) {
          cutz = (min(data[,i])\cutz)
        }
        cutpoints[i].vec = cutz
        cutpoints[i].autoname = "user"
      }
    }
  }
  return(cutpoints)
}


struct cemout function cemStata(string scalar varlist, string scalar cutlist,
                       string scalar treat,
                       string scalar show, string scalar filename,
                       real scalar m, string scalar impvar) {

  struct cemout scalar out
  string vector cutpoints
  touse = st_local("touse")
  real scalar L1

  varlist = tokens(varlist)
  t = tokeninit(" ","",("()"))
  tokenset(t,cutlist)
  cutlist = tokengetall(t)


  if (filename != "") {
    
    files = J(m,1,filename) + strofreal(1::m) + J(m,1,".dta")
    stata("qui use "+files[1]+",replace")
    n = st_nobs()
    for(i = 2;i <= m; i++) {
      stata("qui append using "+files[i])
    }

    if (_st_varindex("cem_imp") != .) {
      st_dropvar("cem_imp")
    }
    (void) st_addvar("int","cem_imp")
    imps = vec(J(n,1, 1..m))
    st_store(., "cem_imp", imps)
    impvar = "cem_imp"
    st_local("impvar", "cem_imp")
    printf("Using MI files, ignoring impvar...")
  }

  
  data = st_data(.,varlist, touse)

  if (treat == "")
    treatment = .
  else
    treatment = st_data(.,treat, touse)

  if (impvar != "") {
    imps = st_data(.,impvar, touse)
    m = max(imps)
    data = select(data, imps :> 0)
    treatment = select(treatment, imps :> 0)
  }


  /* strip problem causing whitespace */
  cutlist = subinstr(cutlist, "(","")
  cutlist = subinstr(cutlist, ")","")
  cutlist = strtrim(stritrim(cutlist))
  cutpoints = makeCuts(cutlist, data)




  out = cem(data, treatment, cutpoints, impvar)

  /* here we post-process the imputed datasets */
  /* if (filename != "") { */
  /*   combineMulticem(filename, m, treat) */
  /* } */


  if (show == "showbreaks") {
    stata(`"display in green "Cutpoints:" "')
    for (i = 1; i <= length(varlist); i++) {
      printf("%s:{res} (%s) \n",varlist[i], out.cutpoints[i].autoname)
      out.cutpoints[i].vec
    }
  }
  return(out)
}



void function imbalance(string scalar varlist, string scalar breaks,
                        string scalar trname, real scalar useweights,
                        string scalar impvar) {
 
  real colvector treat
  real matrix data
  touse = st_local("touse")
  if (touse == "") {
    marked = J(rows(st_data(.,trname)), 1,1)
  }
  else {
    marked = st_data(.,touse)
  }
  varlist = tokens(varlist)
  if (impvar == "") {
    /* if (_st_varindex("cemtmp__")!=.) */
    /*   st_dropvar("cemtmp__") */
    /* (void) st_addvar("int","cemtmp__") */
    /* st_store(., "cemtmp__", marked) */
    data = st_data(.,varlist, touse)
    treat = st_data(.,trname, touse)
  } else {
    /* stata("qui use "+filename+"1.dta, replace") */
    /* if (_st_varindex("cemtmp__")!=.) */
    /*   st_dropvar("cemtmp__") */
    /* (void) st_addvar("int","cemtmp__") */
    /* st_store(., "cemtmp__", marked) */
    /*     data = st_data(.,varlist,"cemtmp__") */
    /*     st_dropvar("cemtmp__") */
    /* for (i = 2; i <= m; i++) { */
    /*   stata("qui use "+filename +strofreal(i)+".dta, replace") */
    /*   if (_st_varindex("cemtmp__")!=.) */
    /*     st_dropvar("cemtmp__") */
    /*   (void) st_addvar("int","cemtmp__") */
    /*   st_store(., "cemtmp__", marked) */
    /*   data = data :+ st_data(.,varlist,"cemtmp__")
    }*/
    data = st_data(., varlist, touse)
    imps = st_data(., impvar, touse)
    imbdata = select(data, imps :== 1)

    for (i = 2; i <= max(imps); i++) {
      imbdata = imbdata :+ select(data, imps :== i)  
    }  
    data = imbdata/max(imps)
    treat = st_data(.,trname, touse)
    treat = select(treat, imps :== 1)

  }

  n = rows(data)
  k = cols(data)

  if (useweights == 0 | _st_varindex("cem_weights")==.) {
    weights = J(n,1,1)
  }
  else {
    weights = st_data(.,"cem_weights", touse)
    if (impvar != "") {
      weights = select(weights, imps :== 1)
    }
  }

  if (sum(weights)==0)
    weights = J(n,1,1)

  treat = select(treat, weights :> 0)
  data = select(data, weights :> 0)
  weights = select(weights, weights :> 0)

  L1m = L1meas(treat, data, breaks,weights)
  st_numscalar("r(L1)",L1m)

  unimatrix = J(k,7,.)

  groups = uniqrows(treat)
  if (length(groups) > 2) {
    return
  }
  
  idx1 = treat :== groups[1]
  idx2 = treat :== groups[2]

  for(i = 1; i <= k; i++) {
    unimatrix[i,1] = L1meas(treat, data[,i], breaks, weights)
    unimatrix[i,2] = sum(idx2:*data[,i]:*weights)/sum(idx2:*weights) -
                     sum(idx1:*data[,i]:*weights)/sum(idx1:*weights)
    unimatrix[i,(3\4\5\6\7)] = wquant(data[,i],weights,(0,.25,.5,.75,1),idx2) -
                               wquant(data[,i],weights,(0,.25,.5,.75,1),idx1)

  }
  st_matrix("r(imbal)", unimatrix)

  st_matrixrowstripe("r(imbal)", (J(k,1,""),varlist'))
  st_matrixcolstripe("r(imbal)", (J(7,1,""),(
                                  "L1"\"mean"\"min"\"25%"\"50%"\"75%"\"max")))
}

real vector function wquant(real colvector x, real colvector weights,
                             real vector probs, real colvector sel) {
  real vector out

  xwh = sort(select((x,weights),sel),1)

  F = runningsum(xwh[,2]):/sum(xwh[,2])
  out = J(1,length(probs),.)
  for(i = 1; i <= length(probs); i++) {
    out[,i] = (select(xwh,F:>=probs[i]))[1,1]
  }
  return(out)

}


/*  This function procudes slightly different results than the R version
*   b/c the R version double-reduces (incorrectly?) the individual variables before 
*   calculating the L1. Extremely minor differences.
*/
real scalar function L1meas(real colvector treat, real matrix data,
                             string scalar L1breaks, real colvector weights) {
  real matrix reddata
  groups = uniqrows(treat)

  treat2 = select(treat,weights:>0)
  reddata = select(data,weights:>0)
  weights2 = select(weights, weights:>0)

  for (i = 1;i<=cols(reddata);i++) {
    breakdance = L1breaks
    reddata[,i] = coarsen(reddata[,i],breakdance)
  }


  cells = uniqrows(reddata)
  L1 = 0

  idx1 = treat2 :== groups[1]
  idx2 = treat2 :== groups[2]

  n1 = sum(idx1:*weights2)
  n2 = sum(idx2:*weights2)

  for (i = 1; i <= rows(cells); i++) {
    idx = rowsum(reddata :== cells[i,]):==cols(reddata)
    jdx1 = (idx1:+idx) :== 2
    jdx2 = (idx2:+idx) :== 2
    m1 = sum(jdx1:*weights2)/n1
    m2 = sum(jdx2:*weights2)/n2
    L1 = L1 + abs(m1-m2)
  }
  L1 = L1/2
  return(L1)
}


void function combineMulticem(real matrix bigstrata, string scalar impvar, | real vector bigtreat) {


  imps = st_data(., impvar)
  bign = length(bigstrata)
  n = bign/max(imps)

  if (_st_varindex("_mi_id") != .) {
    ids = st_data(.,"_mi_id")
    ids = select(ids, imps :> 0)
  } else {
    ids = J(max(imps), 1, 1::n)
  }

  posimps = select(imps, imps :> 0)

  alln = bign + n * (min(imps) == 0)
  bigmstrata = J(alln , 1, .)
  bigweights = J(alln, 1, .)
  
  combstrata = J(n,1,.)
  combtreat  = J(n,1,.)


  for (i = 1; i <= n; i++) {
    multistrata = select(bigstrata, ids :== i)
    bins = uniqrows(multistrata)
    counts = J(length(bins), 1, .)
    for (j = 1; j <= length(bins); j++) {
      counts[j] = sum(multistrata :== bins[j])
    }
    stchoices = uniqrows(select(bins,counts:==max(counts)))
    combstrata[i] = stchoices[1]/*stchoices[sample(1, 1::length(stchoices))]*/
    bigstrata[select(1::bign, ids :== i)] = J(max(imps), 1,combstrata[i])

    if (args() == 3) {
      multitreat = select(bigtreat, ids:== i)
      trbins = uniqrows(multitreat)
      trcounts = J(length(trbins), 1, .)
      for (j = 1; j <= length(trbins); j++) {
        trcounts[j] = sum(multitreat :== trbins[j])
      }
      trchoices = uniqrows(select(trbins,trcounts:==max(trcounts)))
      combtreat[i] = trchoices[1]/*trchoices[sample(1, 1::length(trchoices))]*/
      bigtreat[select(1::bign, ids :== i)] = J(max(imps), 1,combtreat[i])
    }
  }

  if (min(imps) == 0) {
    bigstrata = J(n, 1, .) \ bigstrata
  }
  nstrata = length(uniqrows(combstrata))
  st_rclear()
  st_numscalar("r(n_strata)", nstrata)
  if (_st_varindex("cem_strata")!=.)
    st_dropvar("cem_strata")
  if (nstrata > 32700) {
    (void) st_addvar("long","cem_strata")
  } else {      
    (void) st_addvar("int","cem_strata")
  }
  st_store(., "cem_strata", bigstrata)

  if (args() == 3) {
    if (min(imps) == 0) {
      bigtreat = J(n, 1, .) \ bigtreat
    }

    /* get weights */
    groups = uniqrows(combtreat)
    ngroups = length(groups)
    gtable = J(nstrata,ngroups,.)
    mstrata = J(n,1,0)
    wh = J(n,1,0)
    for (i = 1; i <= nstrata; i++) {
      for (g = 1; g <= ngroups; g++) {
        gtable[i,g] = sum(combtreat :== groups[g] :& combstrata :== uniqrows(combstrata)[i])
      }
      if (gtable[i,1] > 0)
        wh = wh :+ ((gtable[i,2]/gtable[i,1]):*(combstrata:==uniqrows(combstrata)[i]))
   
      if (min(gtable[i,]) == 0)
        mstrata = mstrata :+ (combstrata:==uniqrows(combstrata)[i])
    }

    mstrata = 1:-mstrata

    wh = wh :* sum(combtreat:==groups[1] :& mstrata :> 0)/
                                    sum(combtreat:==groups[2] :& mstrata :> 0)

    wh = wh :* (mstrata:>0)


    wh = wh :* (!(wh :> 0 :& combtreat:==groups[2])) +
               (wh :> 0 :& combtreat:==groups[2])
    wh = editmissing(wh, 0)

    cemsum = J(3,ngroups,.)

    cemsum[1,] = colsum(gtable)
    cemsum[2,] = colsum(select(gtable,rowmin(gtable) :>0))
    cemsum[3,] = colsum(select(gtable,rowmin(gtable) :==0))

    nmstrata = colsum(rowmin(gtable) :> 0)

    st_matrix("r(cem_sum)", cemsum)
    st_matrixrowstripe("r(cem_sum)", (J(3,1,""),("All"\ "Matched"\"Unmatched")))
    st_matrixcolstripe("r(cem_sum)",(J(ngroups,1,""),strofreal(groups)))
    st_numscalar("r(n_strata)", nstrata)
    st_matrix("r(groups)", groups)
    st_matrix("r(gtable)",gtable)
    st_matrixcolstripe("r(gtable)", (J(ngroups,1,""),strofreal(groups)))
    st_numscalar("r(n_groups)",ngroups)
    st_numscalar("r(n_matched)",sum(mstrata:!=0))
    st_numscalar("r(n_mstrata)",nmstrata)
  
    for (i = 1; i <= max(imps); i++) {
      bigmstrata[select(1::alln, imps :== i)] = mstrata
      bigweights[select(1::alln, imps :== i)] = wh
    }

    if (_st_varindex("cem_weights")!=.)
      st_dropvar("cem_weights")
    (void) st_addvar("double","cem_weights")
    st_store(., "cem_weights", bigweights)
    if (_st_varindex("cem_matched")!=.)
      st_dropvar("cem_matched")
    (void) st_addvar("int","cem_matched")
    st_store(., "cem_matched", bigmstrata)
    if (_st_varindex("cem_treat")!=.)
      st_dropvar("cem_treat")
    (void) st_addvar("int","cem_treat")
    st_store(., "cem_treat", bigtreat)
    st_local("treatment", "cem_treat")

  }
}

void function k2k(string scalar varlist, string scalar trname,
                  string scalar method, string scalar impvar) {

  vlist = varlist
  varlist = tokens(varlist)

  treat = st_data(.,trname)

  strata = st_data(.,"cem_strata")
  weights = st_data(.,"cem_weights")
  matched = st_data(.,"cem_matched")

  if (impvar != "") {
    imps = st_data(.,impvar)
    m = max(imps)
    treat = select(treat, imps :== 1)
    strata = select(strata, imps :== 1)
    weights = select(weights, imps :== 1)
    matched = select(matched, imps :== 1)
    alln = st_nobs()
    bigweights = J(alln, 1, .)
    bigmatched = J(alln, 1, .)
  }


  strataID = uniqrows(strata)
  groups = uniqrows(treat)

  n = length(weights)


  /* get weights */
  nstrata = length(uniqrows(strata))
  ngroups = length(groups)
  mtable = J(nstrata,ngroups,.)

  if (ngroups > 2) {
    return
  }

  for (i = 1; i <= length(strataID); i++) {
    s = strataID[i]
    idx = (strata:==s)
    tr = idx :& treat:==groups[2]
    ct = idx :& treat:==groups[1]

    ntr = sum(tr)
    nct = sum(ct)

    goal = min((ntr,nct))

    if ((ntr != nct) & (goal > 0)) {
      idx2 = (select(1::n,tr)\select(1::n,ct))
      /*(void) st_addvar("int","__tempidx")
      st_store(.,"__tempidx",idx)
      stata("mat dis kdist = "+vlist+" if __tempidx==1, "+method)
      st_dropvar("__tempidx")
      st_matrix("kdist") */

      mat = uniform(ntr,nct)
      if (ntr > nct) {
        trash = J(ntr,1,1)
        for (j = 1; j <= goal; j++) {
          trash = trash -  (mat[,j]:==min(select(mat[,j],trash)))
        }
        weights[(select(select(1::n,tr),trash))] = J(sum(trash),1,0)
        matched[(select(select(1::n,tr),trash))] = J(sum(trash),1,0)
      }
      else {
        trash = J(1,nct,1)
        for (j = 1; j <= goal; j++) {
          trash = trash - (mat[j,]:==min(select(mat[j,],trash)))
        }
        weights[(select(select(1::n,ct),trash'))] = J(sum(trash),1,0)
        matched[(select(select(1::n,ct),trash'))] = J(sum(trash),1,0)
      }
    }
    mtable[i,] = J(1,ngroups,goal)
  }
  gtable = table(strata, treat)
  weights = 1*(weights :> 0)

  cemsum = J(3,ngroups,.)

  cemsum[1,] = colsum(gtable)
  cemsum[2,] = colsum(mtable)
  cemsum[3,] = cemsum[1,]-cemsum[2,]

  nmstrata = colsum(rowmin(mtable) :> 0)


  st_matrix("r(cem_sum)", cemsum)
  st_matrixrowstripe("r(cem_sum)", (J(3,1,""),("All"\ "Matched"\"Unmatched")))
  st_matrixcolstripe("r(cem_sum)",(J(ngroups,1,""),strofreal(groups)))
  st_numscalar("r(n_groups)",ngroups)
  st_numscalar("r(n_matched)",sum(matched))
  st_numscalar("r(n_mstrata)",nmstrata)


  if (impvar == "") { 
    if (_st_varindex("cem_weights")!=.)
      st_dropvar("cem_weights")
    (void) st_addvar("int","cem_weights")
    st_store(., "cem_weights", weights)
    if (_st_varindex("cem_matched")!=.)
      st_dropvar("cem_matched")
    (void) st_addvar("int","cem_matched")
    st_store(., "cem_matched", matched)
  } else {
    for (i = 1; i <= max(imps); i++) {
      bigweights[select(1::alln, imps :== i)] = weights
      bigmatched[select(1::alln, imps :== i)] = matched
    }
    if (_st_varindex("cem_weights")!=.)
      st_dropvar("cem_weights")
    (void) st_addvar("int","cem_weights")
    st_store(., "cem_weights", bigweights)
    if (_st_varindex("cem_matched")!=.)
      st_dropvar("cem_matched")
    (void) st_addvar("int","cem_matched")
    st_store(., "cem_matched", bigmatched)
  }
}

real matrix function table(transmorphic vector x, transmorphic vector y) {
  xs = uniqrows(x)
  ys = uniqrows(y)
  nx = length(xs)
  ny = length(ys)

  mat = J(nx,ny,0)
  for (i = 1; i <= nx; i++) {
    for (j = 1; j <= ny; j++) {
      mat[i,j] = sum((x:==xs[i]) :& (y:==ys[j]))
    }
  }
  return(mat)

}

real scalar function lookup(transmorphic scalar x, transmorphic vector tab) {
  for (i = 1; i <= length(tab); i++) {
    if (tab[i] == x) return(i)
  }
}

// given a vector of 0's and 1's, return indices of the 1's, like selectindex() function added in Stata 13
// if v = 0 (so can't tell if row or col vector), returns rowvector J(1, 0, 0) 
real vector oneInds(real vector v) {
    real colvector i, t; real matrix w
    pragma unset i; pragma unset w
    maxindex((cols(v)==1? v \ 0 : v, 0), 1, i, w)
    t = rows(i)>length(v)? J(0, 1, 0) : i
    return (cols(v)==1 & rows(v)!=1? t : t')
}

/* mata mlib create lcem, replace */
/* mata mlib add lcem *() */
/* mata mlib index */

end
