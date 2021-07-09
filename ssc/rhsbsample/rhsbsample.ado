*! v1.1.0, 2013-11-14, Philippe Van Kerm, Repeated Half-Sample Bootstrap -- Saigo, Shao & Sitter (Survey Methodology, 2001).
* minor fixes
* v1.0.0, 2013-09-09, Philippe Van Kerm, Repeated Half-Sample Bootstrap -- Saigo, Shao & Sitter (Survey Methodology, 2001).
* allow generation of weight if variable does not exist
* read -svy- settings with option SVYsettings
* fix details in random sample selection
* v0.0.2, 2009-02-20, Philippe Van Kerm, Repeated Half-Sample Bootstrap -- Saigo, Shao & Sitter (Survey Methodology, 2001).
* fix the weight option incompatiblity with marksample, and weight must  be  existing (as bsample)
* v0.0.1, 2009-02-19, Philippe Van Kerm, Repeated Half-Sample Bootstrap -- Saigo, Shao & Sitter (Survey Methodology, 2001).

pr def rhsbsample  , sortpreserve

  version 9.2
  syntax  [if] [in] [,                  ///
                CLuster(varlist)        ///
                IDcluster(string)       ///
                STRata(varlist)         ///
                Weight(string)          ///
                SVYsettings             /// 
                ]

        // mark sample 
        tempvar touse
        mark `touse' `if' `in'  // notice that marksample does not work 'cos of the -weight- option
        qui markout `touse' `strata' `cluster' , strok
        qui replace `touse' = . if !`touse'
        
        
        // read svy settings if -svysettings- specified:
        if ("`svysettings'" != "") {
          if ("`: char _dta[_svy_version]'" == "") {
            di as error "svy settings not available"
            exit 198
          }
          if ("`cluster'" != "") {
            di as error "svysettings and cluster() options are mutually exclusive"
            exit 198
          }
          if ("`strata'" != "") {
            di as error "svysettings and strata() options are mutually exclusive"
            exit 198
          }
          local strata  : char _dta[_svy_strata1]
          local cluster : char _dta[_svy_su1]
        }
        
        // parse cluster and idcluster options (from -bsample-)
        if (`"`cluster'"' == "") {
                if ("`idcluster'" != "") {
                        di as err ///
                "idcluster() can only be specified with the cluster() option"
                        exit 198
                }
                tempvar cluster
                qui gen double `cluster' = _n if `touse'
        }        
        else {
                confirm variable `cluster'
                if ("`idcluster'" != "") {
                        if (`"`weight'"' != "") {
                                di as err ///
                        "options idcluster() and weight() may not be combined"
                                exit 198
                        }
                        capture confirm new variable `idcluster'
                        if _rc {
                                confirm variable `idcluster'
                                drop `idcluster'
                        }
                }
        }
        
        
        if ("`weight'"!="") {
            cap confirm new variable `weight' 
            if (_rc==0) {
              qui gen `weight' = .
              lab var `weight' "Repeated half-sample bootstrap replication weight"            
            }   
            else {
              di as text "variable `weight' overwritten"
            }
        }
        if ("`strata'"=="") {
          tempvar strata
          qui gen byte `strata' = 1 if `touse'
        }
        
        // --- implement the repeated half-sample bootstrap:         
        
        // select just one obs from each cluster and compute number of clusters per strata:
        tempvar nh onecobs         
        sort `strata' `cluster' `touse'
        qui by `strata' `cluster' (`touse') : gen byte `onecobs' = 1 if _n==1 & !missing(`touse')
        qui by `strata' : egen `nh' = total(`onecobs')   
                  
         // draw:
        tempvar fw u1 u2 typeodddraw
        
        qui gen byte `fw' = 0 
        qui gen double `u1' = uniform() if `onecobs' 
        qui gen double `u2' = uniform() if `onecobs' 
        loc u   `u1' `u2' 
        
        sort `strata' `onecobs'
        qui by `strata' (`onecobs') : gen byte `typeodddraw' = (`u1'[1]<=.25)  if (mod(`nh',2)!=0)        // for odd-sized strata, pick draw 1 or 2 with proba 1/4 (do this before sort on u!)
        sort `strata' `onecobs' `u'
        // even-sized strata
        qui by `strata' (`onecobs' `u') : replace `fw' = 2 if (mod(`nh',2)==0) & (_n<=`nh'/2)
        // odd-sized strata
        qui by `strata' (`onecobs' `u') : replace `fw' = 2 if (mod(`nh',2)!=0) & (_n<`nh'/2)
        qui by `strata' (`onecobs' `u') : replace `fw' = 3 if (mod(`nh',2)!=0) & `typeodddraw'==1 & (_n==int(`nh'/2))
        qui by `strata' (`onecobs' `u') : replace `fw' = 1 if (mod(`nh',2)!=0) & `typeodddraw'==0 & (_n==int(`nh'/2)+1)
        
        qui replace `fw' = 0 if missing(`touse')
        
        qui bysort `strata' `cluster' (`onecobs') : replace `fw' = `fw'[1] if !missing(`onecobs'[1])
    
        if ("`weight'"!="") {
          qui replace `weight' = `fw' 
        }
        else {
          qui drop if `fw'==0
          if ("`idcluster'"=="")  {
             qui expand `fw'
          }
          else {        
             qui expandcl `fw' , generate(`idcluster') cluster(`cluster')
          }
        }
end



exit
Philippe Van Kerm
CEPS/INSTEAD, Luxembourg  
        
