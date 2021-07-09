*! v2.2.0, 2020-01-22 Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multiple deprivation
* v2.2.0, 2020-01-22 Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multiple deprivation
* use -polychoric- instead of -tetrachoric- in all instances to allow aw
* v2.1.0, 2019-11-15 Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multiple deprivation
* fix rounding issue in estimation of rhoh (use midpoint in the largest gap to get round the problem).
* update Stas Kolenikov website adress
* thanks Aldo Benini for pointing this out!
* v2.0.0, 2014-03-14, Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multiple deprivation
* clean up, post on SSC
* v1.1.0, 2009-02-04, Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multiple deprivation
* correct and uncorrect bug which turned out not to be a bug. Drop the 'alternative' definitions.
* v1.0.5, 2009-02-04, Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multiple deprivation
*   option -rescale- removed
* v1.0.3, 2009-02-02, Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multiple deprivation
*   bug fix ("rescale"!==="")
* v1.0.2, 2009-01-31, Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multiple deprivation
*   bug fix: [if] [in] [weight]
* v1.0.1, 2009-01-31, Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multidimensional deprivation
*   rescale option, desai & shah weighting 
* v1.0.0, 2009-01-30, Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multidimensional deprivation
* v0.0.3, 2009-01-30, Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multidimensional deprivation
* v0.0.2, 2009-01-29, Maria Noel Pi Alperin and Philippe Van Kerm, Synthetic indicators of multidimensional deprivation

pr def mdepriv , rclass sortpreserve 

  version 9.2
  
  syntax anything [if] [in] [fweight aweight] , ///
     [                       ///
     GENerate(string)        ///
     METhod(string)          ///
     WA(string) WB(string)   ///
     FORCE                   /// 
     INSTall                 ///
     ]
     
  // --- check dependencies on user-written packages and prompt to install missing packages
  if ("`install'"!="") _check_dependencies 
  
  // --- parse anything
  _parse expand vlist junk : anything  // undocumented command - creates vlist_1 vlist_2 ... graph syntax - (varlist) (varlist) || varlist ... 
  loc K = `vlist_n'
  
  // --- parse generate options (from ozsutils package)
  if ("`generate'"!="")  _ozs_parse_genvar generate `generate'

  // --- set sample marker and weight exp - here because later syntax calls resets sample and weight
  marksample touse
  loc wexp `"`weight'`exp'"' 

  // --- parse method(), wa() and wb() options
  if (("`method'"!="") & ("`wa'`wb'"!="")) {
    di as error "method() and wa()/wb() options are mutually exclusive"
    exit 198
  }
      
  if ("`method'`wa'`wb'"=="") local method "cz"
  
  if ("`method'"!="") {
    _parse comma methname methopts : method
    if ("`methname'"!="bv") & ("`methopts'"!="") {
      di as error "method() option incorrectly specified; only method(bv) takes sub-options"
      exit 198
    }
    
    if ("`methname'"=="cz") {
      loc wa "cz"
      loc wb "diagonal"
      loc weightschemename "Cerioli & Zani (1990)"
    }  
*    else if ("`methname'"=="czalt") {
*      loc wa "czalt"
*      loc wb "diagonal"
*      loc weightschemename "Modified Cerioli & Zani (1990)"
*    }  
    else if ("`methname'"=="ds") {
      loc wa "ds"
      loc wb "diagonal"
      loc weightschemename "Desai & Shah (1988)"
    }  
*    else if ("`methname'"=="dsalt") {
*      loc wa "dsalt"
*      loc wb "diagonal"
*      loc weightschemename "Modified Desai & Shah (1988)"
*    }  
    else if ("`methname'"=="equal") {
      loc wa "equal"
      loc wb "diagonal"
      loc weightschemename "Equi-proportionate"
    }  
    else if ("`methname'"=="bv") {
      loc wa "bv"
      gettoken comma wb : methopts
      loc weightschemename "Betti & Verma (1998)"
    }  
    else if ( substr("`methname'",1,4)=="vec(" ) {
      loc 0 `", `methname'"'
      cap syntax , vec(namelist min=1)
      if (_rc>0) {
        di as error "method(vec()) option incorrectly specified"
        exit 198
      }
      // note: loc vec contains list of vector names 
      if (`: word count `vec'' != `K' ) {
        di as error "method(vec()) option incorrectly specified"
        exit 198
      }
    }  
    else {
      di as error "method() option incorrectly specified"
      exit 198
    }
  }  
  if ("`vec'"=="") {
    if ("`wa'"=="") loc wa "cz"
    if ("`wb'"=="") loc wb "mixed"
  }  

  if ("`weightschemename'"=="") loc weightschemename "User-defined"
    
  // check validity wa() option
  loc 0 `" , `wa' "'
  cap syntax , [ cz ds bv equal ]
  if (_rc>0) {
    di as error "wa() option incorrectly specified"
    exit 198
  }
  if (`: word count `cz' `ds' `bv' `equal' ' > 1) {
    di as error "`cz' `ds' `bv' `equal' are mutually exclusive
    exit 198
  }
  
  // --- check validity of varlists and set sample marker
  forv i=1/`K' {
    markout `touse' `vlist_`i''
    unab vlist_`i' : `vlist_`i'' 
    loc dim_`i' : word count `vlist_`i''
    foreach var of varlist `vlist_`i'' {
      cap assert inrange(`var',0,1.001) if `touse' 
      if (_rc>0) {
        if ("`force'"=="") {
          di as error "`var' not in [0,1]; use -force- option to force computation on data outside [0,1] range"
          exit 198
        }
        else di as text "(note: `var' not in [0,1])"
      }  
    }
    if ("`vec'"!="") {
      if ( rowsof(`:word `i' of `vec'') != `dim_`i'') {
        di as error "length of " `:word `i' of `vec'' " does not match length of (`vlist_`i'')"
        exit 198 
      }
    }    
  }

  // --- COMPUTATIONS:
  
  // parse wb() and --- compute correlation matrix within each dimension  
  loc 0 `" , `wb' "'
  cap syntax , [ rhoh(real -2) Diagonal MIXed PEARson TETRAchoric POLYchoric]
  if (_rc>0) {
    di as error "method(bv()) option or wb() option incorrectly specified"
    exit 198
  }
  if (`: word count `diagonal' `mixed' `pearson' `tetrachoric' `polychoric' ' > 1) {
    di as error "`diagonal' `mixed' `pearson' `tetrachoric' `polychoric' are mutually exclusive correlation types"
    exit 198
  }
    
  if ("`diagonal'"=="" & "`vec'"=="") {
    tempvar values
    forv i=1/`K' {
      tempname correlations_`i' 
      mat `correlations_`i'' = J(`dim_`i'',`dim_`i'',1)
      forv j=1/`dim_`i'' {
        forv k=`=`j'+1'/`dim_`i'' {
          // determine the type of correlation
          if ("`pearson'" != "" ) {
            loc corrcmd "correlate"
          }
          else if ("`tetrachoric'" != "" ) {
            // loc corrcmd "tetrachoric"  --> use polychoric to allow aweights
            loc corrcmd "polychoric"
          }          
          else if ("`polychoric'" != "" ) {
            loc corrcmd "polychoric"
          }          
          else {
            qui bys `touse' `: word `j' of `vlist_`i''' : gen byte `values' = (_n == 1) if `touse'
            qui su `values' if `touse', meanonly
            loc nval1 = r(sum)
            qui bys `touse' `: word `k' of `vlist_`i''' : replace `values' = (_n == 1) if `touse'
            qui su `values' if `touse', meanonly
            loc nval2 = r(sum)
            if (`nval1'<=2) & (`nval2'<=2) { 
			  // loc corrcmd "tetrachoric"  --> use polychoric to allow aweights
              loc corrcmd "polychoric"
            }  
            else if (`nval1'>10) & (`nval2'>10) {
              loc corrcmd "correlate"
            }  
            else {  
              loc corrcmd "polychoric"
            } 
            drop `values'  
          }
          // estimate correlation
          qui `corrcmd' `: word `j' of `vlist_`i'''  `: word `k' of `vlist_`i'''  if `touse' [`wexp']
          mat `correlations_`i''[`j',`k'] = r(rho) 
          mat `correlations_`i''[`k',`j'] = r(rho) 
          if (r(rho)==-1)  di as text "!! Perfect (negative) correlation between " as res "`: word `j' of `vlist_`i'''" as text " and " as res "`: word `k' of `vlist_`i'''" as text" !!"
          if (r(rho)==1)   di as text "!! Perfect (positive) correlation between " as res "`: word `j' of `vlist_`i'''" as text " and " as res "`: word `k' of `vlist_`i'''" as text" !!"
          loc rhos "`rhos' `=r(rho)'"
        }
      } 
    } // end loop dimensions
    cap drop  __POLY2hi __POLY2lo  // left-overs from -polychoric-
    // determine rhoh a la Betti & Verma 1998
    if (`rhoh'==-2) {
      if (`: word count `rhos'' > 1) {
        mata: rhos = st_local("rhos")
        mata: rhos = strtoreal(tokens(rhos)')
        mata: _sort(rhos,1)
        mata: step = rhos[(2..rows(rhos)),1] - rhos[(1..rows(rhos)-1),1] 
        // mata: rhoh = rhos[order(-step,1)[1,1]+1,1]
		mata: rhoh = (rhos[order(-step,1):+1,1]+rhos[order(-step,1),1]) /2
        mata: st_local("rhoh",strofreal(rhoh[1,1]))
      }
      else {
        loc rhoh = `rhos'
      }  
    }
  }
      
  // --- compute vectors of item weights
  forv i=1/`K' {
    tempname wvec_`i'
    mat `wvec_`i'' = J(`dim_`i'',1,0)
    loc j 0
    foreach var of varlist `vlist_`i'' {
      loc ++j
      if ("`vec'"!="") {
        mat `wvec_`i''[`j',1] = `: word `i' of `vec''[`j',1] 
      }
      else {
        // wa:
        if ("`wa'"=="cz") {
          qui su `var' [`wexp'] if `touse' , meanonly
*          mat `wvec_`i''[`j',1] = -1/log(r(mean))
          mat `wvec_`i''[`j',1] = log(1/r(mean))    // this is equal to -log(r(mean))  
        }
*        else if ("`wa'"=="czalt") {
*          qui su `var' [`wexp'] if `touse' , meanonly
*          mat `wvec_`i''[`j',1] = 1/(1-r(mean))
*        }    
        else if ("`wa'"=="ds") {
          qui su `var' [`wexp'] if `touse' , meanonly
          mat `wvec_`i''[`j',1] = 1-r(mean)
        }    
*        else if ("`wa'"=="dsalt") {
*          qui su `var' [`wexp'] if `touse' , meanonly
*          mat `wvec_`i''[`j',1] = -log(r(mean))
*        }    
        else if ( ("`wa'"=="bv") | ("`wa'"=="") )  {
          qui su `var' [`wexp'] if `touse' 
          mat `wvec_`i''[`j',1] =  r(sd) / r(mean)
        }
        else  { // ("`methname'"=="equal")  
          mat `wvec_`i''[`j',1] =  1
        }
        // wb: 
        if ("`diagonal'"=="") {
          loc sum_h 0
          loc sum_l 0
          forv k=1/`dim_`i'' {
            if ( `correlations_`i''[`j',`k']<`rhoh' ) loc sum_l = `sum_l' + `correlations_`i''[`j',`k']
            else                                      loc sum_h = `sum_h' + `correlations_`i''[`j',`k']
          }         
          mat `wvec_`i''[`j',1] = `wvec_`i''[`j',1] * (1/(1+`sum_l')) * (1/(`sum_h'))
        }
      }  
      loc rownames_`i' "`rownames_`i'' `var'"   
      
      if (missing(`wvec_`i''[`j',1])) {
        di as error "weight is undefined for item `j' in dimension `i' (`var')"
        exit 499
      }   
    }
    
    // --- normalize weights within dimensions
    mat `wvec_`i'' =  `wvec_`i'' / trace(diag(`wvec_`i''))
    mat rowname `wvec_`i'' = `rownames_`i''
    if ("`diagonal'"=="" & "`vec'"=="") {
      mat rowname `correlations_`i'' = `rownames_`i''
      mat colname `correlations_`i'' = `rownames_`i''
    } 
    
    // --- generate synthetic variable for dimension i
    tempvar S_`i'
    qui gen double `S_`i'' = 0 if `touse'
    loc j 0
    foreach var of varlist `vlist_`i'' {
      qui replace `S_`i'' =  `S_`i''  +  `wvec_`i''[`++j',1]*`var'  
    }
    loc Ss "`Ss' `S_`i''"
  }
  
  // --- generate overall synthetic variable
  tempvar S
  qui egen double `S' = rowmean(`Ss') if `touse'
  if ("`generate'"!="")       qui generate double `generate' = `S'

  // --- compute summary information
  
  qui su `S' [`wexp'] if `touse' , meanonly
  loc mnS = r(mean)
  tempname fullindex fullcontri fullshare
  mat def `fullindex' = J(1,1,0)
  mat def `fullcontri' = J(1,1,0)
  mat def `fullshare' = J(1,1,0)
  forv i=1/`K' {
    qui su `S_`i'' [`wexp'] if `touse' , meanonly
    loc mnS_`i' = r(mean)
    loc mnS_`i'_c = r(mean) / `K'
    loc mnS_`i'_s = `mnS_`i'_c' / `mnS'
    loc j 0
    foreach var of varlist `vlist_`i'' {
      qui su `var' [`wexp'] if `touse' , meanonly
      loc mn_`var' = r(mean)
      * next locals are for contrbutions within dimension
      loc mn_`var'_c = r(mean) * `wvec_`i''[`++j',1]
      loc mn_`var'_s = `mn_`var'_c' / `mnS_`i''
      loc mn_`var'_c_tot = `mn_`var'_c' / `K'
      loc mn_`var'_s_tot = `mn_`var'_c_tot' / `mnS'
      * and these values are for contributions to total
      mat def `fullindex'  = `fullindex'  \ `mn_`var''
      mat def `fullcontri' = `fullcontri' \ `mn_`var'_c_tot' 
      mat def `fullshare'  = `fullshare'  \ `mn_`var'_s_tot' 
    }
  }
  mat def `fullindex'  = `fullindex'[2...,1]
  mat def `fullcontri' = `fullcontri'[2...,1]    
  mat def `fullshare'  = `fullshare'[2...,1]
    
  // --- report summary information
  di ""
  di as text "`weightschemename' weighting scheme"
  di ""
  di as text "Aggregate deprivation level: " as result %8.4f `mnS'
  di ""
  if (`K'>1) { // display results by dimension
    di as text "Deprivation level, weight and contribution to total, by dimension"
    di as text " " _dup(26) "{c -}" "{c TT}" _dup(39) "{c -}"
    di as text _col(28) "{c |}" ///
        _col(30) %8s "Index"    ///
        _col(40) %8s "Weight"    ///
        _col(50) %8s "Contri"  /// 
        _col(60) %8s "Share"   
    di as text " " _dup(26) "{c -}" "{c +}" _dup(39) "{c -}"  
    forv i=1/`K' {
      di as text  %26s "Dimension `i'" _col(28) "{c |}" ///
          _col(30) as result %8.4f `mnS_`i''    ///
          _col(40) as result %8.4f (1/`K')  /// 
          _col(50) as result %8.4f `mnS_`i'_c'  /// 
          _col(60) as result %8.4f `mnS_`i'_s'   
    }
    di as text " " _dup(26) "{c -}" "{c +}" _dup(39) "{c -}"  
    di as text %26s "Total" _col(28) "{c |}" ///
          _col(40) as result %8.4f 1.0000 ///
          _col(50) as result %8.4f `mnS'  /// 
          _col(60) as result %8.4f 1.0000
    di as text " " _dup(26) "{c -}" "{c BT}" _dup(39) "{c -}"
    di ""
  }    
     
  di as text "Deprivation level, weight and contribution to total, by item"
  di as text " " _dup(26) "{c -}" "{c TT}" _dup(39) "{c -}"
  di as text _col(28) "{c |}" ///
      _col(30) %8s "Index"    ///
      _col(40) %8s "Weight"    ///
      _col(50) %8s "Contri"  /// 
      _col(60) %8s "Share"   
  forv i=1/`K' { // display results by item
    loc j 0
    di as text " " _dup(26) "{c -}" "{c +}" _dup(39) "{c -}"  
    foreach var of varlist `vlist_`i'' {
      di as text %26s  abbrev("`var'",20)  _col(28) "{c |}" ///
          _col(30) as result %8.4f `mn_`var''   ///
          _col(40) as result %8.4f `wvec_`i''[`++j',1]/`K'   ///
          _col(50) as result %8.4f `mn_`var'_c_tot' ///  
          _col(60) as result %8.4f `mn_`var'_s_tot'  
    }
  }  
  di as text " " _dup(26) "{c -}" "{c +}" _dup(39) "{c -}"  
  di as text %26s "Total" _col(28) "{c |}" ///
         _col(40) as result %8.4f 1.0000 ///
        _col(50) as result %8.4f `mnS'  /// 
        _col(60) as result %8.4f 1.0000
  di as text " " _dup(26) "{c -}" "{c BT}" _dup(39) "{c -}"

  
      
  // --- full weigths matrix
  tempname fullweightsmat
  mat def `fullweightsmat' = `wvec_1' / `K'
  loc fullrownames "`rownames_1'"
  forv i=2/`K' {
    mat def `fullweightsmat' = `fullweightsmat' \ (`wvec_`i''/ `K')
    loc fullrownames "`fullrownames' `rownames_`i''"
  }  
  mat rowname `fullweightsmat' = `fullrownames'

  mat rowname `fullindex'  = `fullrownames'
  mat rowname `fullcontri' = `fullrownames'
  mat rowname `fullshare'  = `fullrownames'
  
    
  // --- return results
  return local itemslist "`anything'"
  if ("`method'"!="") return local method "`methname'"
  return local wa "`wa'"
  return local wb "`wb'"  
  return local weightschemename "`weightschemename'"  
  
  forv i=1/`K' {
    return local  items_`i' "`vlist_`i''"
    return matrix itemweights_`i' = `wvec_`i''
    return scalar dim_`i' = `dim_`i''
    if ("`diagonal'"==""  & "`vec'"=="") return matrix itemcorrelations_`i' = `correlations_`i''
    return scalar index_`i' = `mnS_`i''
    return scalar contri_`i' = `mnS_`i'_c'
    return scalar share_`i' = `mnS_`i'_s'
  }
  
  return matrix fullweights = `fullweightsmat'
  return matrix fullindices = `fullindex'
  return matrix fullcontris = `fullcontri'
  return matrix fullshares = `fullshare'
  
  return scalar ndim = `K'
  if ("`rhoh'"!="")  return scalar rhoh = `rhoh'
  
  qui su `generate' if `touse' [`wexp'] , meanonly
  return scalar N = r(N)
  return scalar sum_w = r(sum_w)
  
  if ("`generate'"!="") return local generate "`generate'"
     
  return scalar aggregate = `mnS'
  
  
end


pr def _ozs_parse_genvar
    version 9.2
    gettoken locname 0 : 0
    gettoken genvar genopts : 0 , parse(",")
    gettoken  comma genopts : genopts  , parse(",")
    if (trim("`genopts'")=="")  confirm new variable `genvar'
    else {
      if (trim("`genopts'")=="replace") cap drop `genvar'
      else {
        di as error "`0'   invalid"
        exit 198
      }
    }
    c_local `locname' "`genvar'"
end


pr def _check_dependencies
    di ""
    cap which polychoric 
    if (_rc>0) {
      di as text `"[1] Package {stata "findit polychoric":polychoric} by Stas Kolenikov is missing and required when using -method(bv)- (except if forcing -method(bv ,pearson)- or -method(bv, tetrachoric)-) "' _c
      di as text `"[{stata "net install polychoric , replace from(http://staskolenikov.net/stata)":click to download and install}]"'
      loc stop 1
    }
    else  di as text "[1] Package {help polychoric} by Stas Kolenikov already installed."

    if ("`stop'"=="1") {
      di 
      di as text "Some required user-written package not installed"
      exit 
    }  
end

exit
---
Philippe Van Kerm
CEPS/INSTEAD, Luxembourg  
       
