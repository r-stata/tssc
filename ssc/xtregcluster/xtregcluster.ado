*! version 1.0  24Feb2016
*! author: Demetris Christodoulou (Sydney) and Vasilis Sarafidis (Monash)

program define xtregcluster, eclass
version 10

syntax varlist(fv ts numeric min=2)     /// minimum one indepvar
       [if] [in] [aw fw pw iw]          /// qualifiers and weights
       ,                                ///
       [                                ///
       random                           /// init.partition via randomized classification
       preclass(varname numeric)        /// init.partition via predetermined classification
       prevars(str)                     /// init.partition via prespecified variation
       prevarsopt(str)                  /// options for command cluster kmeans
       omega(numlist >1 integer min=1)  /// cannot be specified with preclass
       theta(real -999)                 /// default is weighted theta, or user input
       seed(numlist >0 integer max=1)   /// random seed for random and prevars()
       name(name max=1)                 /// name of new variable
       ITERate(integer 100)             /// max number of iterations for total RSS convergence
       TOLerance(real 1e-6)             /// conergence precision
       noLOG                            /// supress iteration log
       graph                            /// scatter and lfit graph with no options
       TABLE                            /// estimates table of xtreg if omega==k, fe
       ]

**************************
**** COLLECT KEY INFO **** 
**************************

// default for obtaining initial partition via uniform random assignment
if "`seed'"=="" {
   local seed 123 // default seed for entire program, for randid, random and prevars()
}

// check if xtset and collect panelid and timeid
qui xtset // will issue error 459 if panel variable not set
local panel   = r(panelvar)
local timeid  = r(timevar)
   if "`timeid'"=="." local timeid = ""
local balance = r(balanced)

// varlist: store into depvar indepvars 
// depvar is the first token and indepvars stores the rest of the tokens
gettoken depvar indepvars : varlist
local sizeofb: list sizeof local indepvars

// [if] [in] qualifiers: mark estimation sample e(sample) 
marksample touse
markout `touse' `varlist' `preclass'
novarabbrev {
 if "`prevars'"!="" {
    local prevarsno: word count `prevars' // number of variables specified in prevars()
    tokenize "`prevars'"
    forvalues i = 1/`=`prevarsno'' {
       if ("``i''"!="X" & "``i''"!="b") markout `touse' ``i''
    }
 }
 if "`prevarsno'"=="" local prevarsno 0
}

// remove individuals with Ti=1
tempvar  Ti_remove
tempname Ti_removeis1
qui bysort `panel': generate `Ti_remove' = _N if `touse'
qui count if `Ti_remove'==1 & `touse'
scalar `Ti_removeis1' = r(N)
if `Ti_removeis1'>0 {
   di as txt "{bf:Warning}: `=`Ti_removeis1'' individuals with Ti=1 have been excluded"
}
qui replace `Ti_remove'=. if `Ti_remove'==1 & `touse'
markout `touse' `Ti_remove'

// given `touse', collect panel data dimensions
qui xtsum `panel' if `touse'
tempname sc_T sc_N sc_NT
scalar `sc_T'  = r(Tbar) // T for balanced or average Ti for unbalanced
scalar `sc_N'  = r(n)    // number of panels
scalar `sc_NT' = r(N)    // number of total observations


*************************
**** OPTION DEFAULTS **** 
*************************


// default option for number of iterations
if "`iterate'"==""   local iterate = 100      //  set default at 100 iterations

// default option for tolerance
if "`tolerance'"==""   local tolerance = 1e-6 //  set default covergence at 0.000001 tolerance

// check for table if there are existing estimates with name omega*
if `"`table'"'!="" {
   // set estimates table options
   local tableopt stats(N_g Tbar N r2_w rho corr) b(%9.3f) stfmt(%9.2f) title(Table: Panel data fixed effects estimates by omega)

   capture estimates dir omega* // check if estimates with same names already exist
   if _rc==0 {
      di as err "There are existing estimates with name omega*; see {stata estimates dir omega*:estimates dir omega*}"
      error
   }
}

// default option for theta, the penalty for over-parameterisation
tempname sc_theta
if `theta'==-999 { // 0 is the default program value of theta
   scalar `sc_theta' = (1/3) * ln(`sc_N') + (2/3) * sqrt(`sc_N')  // set as default
}
else {
   scalar `sc_theta' = `=`theta'' // user-specific theta
}

// check that one type of initial partition is specified
if !strpos("`0'","random") & !strpos("`0'","preclass") & !strpos("`0'","prevars(") {
   di as err "Must specify one of {bf:random}, {bf:preclass()}, or {bf:prevars()}."
   error 197
}
if [strpos("`0'","prevarsopt(") & strpos("`0'","random")  ]  | ///
   [strpos("`0'","prevarsopt(") & strpos("`0'","preclass")]  | ///
   [strpos("`0'","prevarsopt(") & !strpos("`0'","prevars(")] {
   di as err "{bf:prevarsopt()} can only be specified together with {bf:prevars()}."
   error 197
}
if [strpos("`0'","random")  & strpos("`0'","preclass")]  | ///
   [strpos("`0'","random")  & strpos("`0'","prevars(")]  | ///
   [strpos("`0'","prevars(") & strpos("`0'","preclass")] {
   di as err "Specify only one method of initial partition: " _c
   di as err "{bf:random}, {bf:preclass()}, or {bf:prevars()}."
   error 197
} 


//  default for obtaining initial partition via predetermined classification 
if strpos("`0'","preclass") & "`preclass'"=="" {
   di as err "Must specify one categorical variable in {bf:preclass()}"
   error 197
}
if "`preclass'"=="`panel'" {
   di as err "Specifying the panel id in {bf:preclass()} accounts to setting Omega = N. " _c
   di as err "This is the same as estimating individual-specific {bf:regress} N times"
   error 197
}
if strpos("`0'","preclass") & strpos("`0'","omega(") {
   di as err "{bf:omega()} cannot be specified with {bf:preclass()}"
   error 197
}
if "`preclass'"!="" {
   qui tab `preclass'
   if r(r)<2 {
      di as err "{bf:preclass()} must specify a categorical variable with minimum 2 levels"
      error 197
   }
}


//  default for obtaining initial partition via cluster kmeans
novarabbrev {
 if strpos("`0'","prevars(") & "`prevars'"=="" {
    local prevars "`indepvars'" // default is the list of all explanatory variables
 }

 if "`prevars'"!="" {

    if strtrim("`prevars'")=="X" {
       local prevars "`indepvars'" // same as default
    }

    if "`prevars'"!="" & `prevarsno'>1 {
       tokenize "`prevars'"
       forvalues i = 1/`=`prevarsno'' {
          if "``i''"=="X" local prevars "`indepvars'" // first find if X is in prevars()
       }
       forvalues i = 1/`=`prevarsno'' { // then go again through the same list
          if "``i''"=="b" { // check if b is in the same list
             di as err "{bf:prevars(b)} cannot be combined with other variables in {bf:prevars()}"
             error
          }
          if "``i''"!="X" & "``i''"!="b" {
             confirm variable ``i'' // check that all non-X variables exist
             local prevars "`prevars' ``i''"
          }
       }
    }

    if strtrim("`prevars'")=="b" | strtrim("`prevars'")=="X" {
       cap confirm new variable `prevars'
       if _rc {
          di as err "A variable exists with name " as res "`prevars' " _c
          di as err "and clashes with " as res "{bf:prevars(}`prevars'{bf:)}"
          error 110
       }
    }

    if  strtrim("`prevars'")=="b" {  // option prevars(b)
       local prevars_b = 1 // tag this option for later conditional statements

       forvalues j = 1/`=`sizeofb'' {  // number of b slopes but not the model intercept
          tempvar b`j'
          qui generate `b`j'' = .  if `touse'
       }

       qui levelsof `panel' if `touse', local(idlist)
       foreach i of local idlist {
          tempvar Ti
          bysort `panel': egen `Ti' = count(`panel')
          qui sum `Ti' if `touse'

          if r(min) < `sizeofb'+1 { // enough degrees of freedom for slopes plus intercept
             di as err "Some panels have Ti < k+1. Choose an alternative initial partition, " _c
             di as err "or qualify the sample to panels with enough observations"
             error 2001
          } // if
          else {
             qui regress `depvar' `indepvars' if `panel'==`i' & `touse'
             matrix pars = get(_b)
             local blist ""
             forvalues j = 1/`=`sizeofb'' {
                tempname sc_b`j'
                scalar `sc_b`j'' = pars[1,`j']
                qui replace `b`j'' = `sc_b`j'' if `panel'==`i' & `touse'
                local blist "`blist' `b`j''"
             } // forvalues
          } // else
       }  // foreach 
       local prevars "`blist'" // overwrite prevars
    
    } // option prevars(b)
 
 } // if prevars
 local prevars: list uniq prevars // eliminate possible duplicate names of vars

 // get list of prevars means to use in obtaining initial partition
 if "`prevars'"!="" { // applies to all possibilities: varlist, X, and b slopes
    local prevarsno: word count `prevars'
    tokenize "`prevars'"
    local prevarsmeans ""
    forvalues i = 1/`=`prevarsno'' { // get the individual-specific means of all prevars()
       tempvar ``i''_mn
       qui bysort `panel': egen ```i''_mn' = mean(``i'') if `touse'
       local prevarsmeans "`prevarsmeans' ```i''_mn'"
    }
 }
} // novarabbrev

//  default for -cluster kmeans- (kmedians not allowed given the focus on mean estimates from xtreg,fe)
if "`prevarsopt'"!="" {
   if strpos("`prevarsopt'","k(") {
      di as err "Option {bf:k()} in {bf:prevarsopt()} is not allowed " _c
      di as err "beause it is already set by {bf:omega()}"
      error 197
   }
   if strpos("`prevarsopt'","name(") | strpos("`prevarsopt'","generate(") {
      di as err "Options {bf:name()} and {bf:generate()} in {bf:prevarsopt()} are not allowed."
      error 197
   }
}

// get name prefix for the omega numlist loop
if "`omega'"=="" & "`preclass'"=="" & ("`random'"!="" | "`prevars'"!=""){
   di as err "option {bf:omega()} required with {bf:random} or {bf:prevars()}"
   error 198
}
// omega() determines prefix if name() is missing
if "`name'"!="" local nameprefix `name'
if "`name'"=="" local nameprefix omega

// check for existing variable names and numerical list de/incrementing by 1
if "`preclass'"=="" local omeganumlist "`omega'"
local omega_no: word count `omega' // 1 for preclass, possibly >1 for random or prevars
tokenize `omega'
forvalues o = 1/`=`omega_no'' {
   confirm new variable `nameprefix'``o''
}
forvalues o = 1/`=`omega_no'' { // just a warning
   if `o'!=1 { // start from the second item in the list
      if (``o''-``--o''!=abs(1)) {
         di as txt "{bf:Warning}: the omega(numlist) does not de/increment by 1"
         continue, break
      }
      local ++o
   }
}

// MIC for Omega=1, this is the benchmark
tempvar tousemata
mark `tousemata' if `touse'
mata: matafe() // Mata FE estimator
tempname sc_RSSpool sc_MICpool
scalar `sc_RSSpool' = matafe_rss
scalar `sc_MICpool' = `sc_N' * ln(`sc_RSSpool' / (`sc_N' * `sc_T') ) + ( 1 * `sc_theta' )


*************************************************
**** obtain initial partition via preclass() ****
*************************************************


if "`preclass'"!="" {

   set seed `seed'

   // before all randomize order of ids for individuals
   tempvar tag unifid pop2id randid
   qui egen `tag' = tag(`panel') if `touse'
   qui generate `unifid' = runiform() if `touse' & `tag'
   qui bysort `panel': egen `pop2id' = min(`unifid') if `touse'
   qui egen `randid' = group(`pop2id') if `touse'
   qui sort `randid' `timeid'

   qui tab `preclass'
   local omega = r(r) // overwrite omega with number of levels in catvar
   local omeganumlist "`omega'"

   local name = substr("`nameprefix'_`preclass'",1,32) // max 32 chars

   egen `name' = group(`preclass') // generate the grouping variable with values 1,2,...,N
   label variable `name' "`name'"

   // check that the predetermined classification is firm-specific 
   tempvar sd_name
   qui bysort `randid': egen `sd_name' = sd(`name') if `touse'
   qui sum `sd_name' if `touse'
   if r(sd)!=0 {
      di as err "{bf:preclass()} must be individual-specific and not time-varying. " _c
      di as err "No individual can belong to more than one Omega."
      error 197
   }

   local omega_no = 1 // so that the omega nulist loop runs only once
} 

**************************************************************
**** loop for omega numlist only for random and prevars() ****
**************************************************************


// output headings
if "`preclass'"!="" {
   di as txt _newline "Initial partition via the categories of " as res "{bf:`preclass'}" _c
   di as txt " and seed " as res "{bf:`seed'}"
   if !strpos("`0'","nolog") di as txt _newline "{bf:Omega = `omega'}"
}
if "`random'"!="" {
   di as txt _newline "Initial partition via randomized classification and seed " _c
   di as res "{bf:`seed'}"
}
if "`prevars_b'"=="1" {
       di as txt _newline "Initial partition via the slopes of " _c
       di as res "{bf:`=strtrim("`indepvars'")'}" as txt " and seed " as res "{bf:`seed'}"
}
if "`prevars'"!=""  & "`prevars_b'"!="1" {
      di as txt _newline "Initial partition via the variation in " _c
      di as res "{bf:`=strtrim("`prevars'")'}" as txt " and seed " as res "{bf:`seed'}"
}

forvalues o = 1/`=`omega_no'' { // omega nulist loop
   
   if "`preclass'"=="" { // set omega and name only for random and prevars()
      local omega = ``o''
      local name "`nameprefix'`omega'"
   }


   **********************************************************
   **** obtain initial partition via random or prevars() ****
   **********************************************************


   if "`preclass'"=="" {

      set seed `seed' // repeatedly set seed as if you are running xtregcluster Omega times separately

      // before all randomize order of ids for individuals
      tempvar tag unifid pop2id randid
      qui egen `tag' = tag(`panel') if `touse'
      qui generate `unifid' = runiform() if `touse' & `tag'
      qui bysort `panel': egen `pop2id' = min(`unifid') if `touse'
      qui egen `randid' = group(`pop2id') if `touse'
      qui sort `randid' `timeid'
   }

   // obtain inital partition via uniform random classification
   if "`random'"!="" {
      if !strpos("`0'","nolog") di as txt _newline "{bf:Omega = `omega'}"
   
      tempvar tag randpart
   
      egen `tag' = tag(`randid')  if `touse'
      qui generate `randpart' = runiform() if `tag' & `touse'

      tempname cut
      scalar `cut' = 1/`=`omega''
      qui generate `name' = 1 if `randpart'<`cut' & `tag' & `touse'
      label variable `name' "`name'"
      if `omega'>2 {
         local c 1
         forvalues i = 2/`=`omega'-1' {
            qui replace `name' = `i' if inrange(`randpart',`cut'*`c',`cut'*`++c') & `tag' & `touse'
         }
      }
      qui replace `name' = `omega' if `randpart'>=(1-`cut') & `tag' & `touse'
      qui bysort `randid': replace `name' = sum(`name') if `touse'
   } 

   // obtain inital partition via prespecified variation
   if "`prevars'"!="" {
         if !strpos("`0'","nolog") di as txt _newline "{bf:Omega = `omega'}"

      // initial partition via Calinski-Harabasz kmeans using individual-specific means (not obs.)
      cap cluster drop `name' // in case the user breaks and leaves a trail of clname tempvars behind
      qui cluster kmeans `prevarsmeans' if `touse', ///
                  k(`omega') name(`name') `prevarsopt' generate(`name') // minimum requirement for kmeans - start(krandom(`seed')) 
   }

   // restore xtset in case program breaks and does not get the chance to restore xtset
   qui xtset `panel' `timeid'


   **************************************************************
   **** optimize the objective function - min{RSS} for xtreg ****
   **************************************************************


   // before all, report total RSS from initial partition - call this iteration 0
   tempname sc_RSStot`omega'
   scalar `sc_RSStot`omega'' = 0
   tempvar tousemata
   forvalues i = 1/`=`omega'' {
      qui generate `tousemata' = 0
      qui replace `tousemata' = (`touse' & `name'==`i')
      mata: matafe() // Mata FE estimator
      scalar `sc_RSStot`omega'' = `sc_RSStot`omega'' + matafe_rss
      drop `tousemata'
   }
   if !strpos("`0'","nolog") {
      di as txt "Iteration 0: {col 15} Total RSS = " ///
         as res "{ralign 16: `:di %17.6f `=`sc_RSStot`omega''''}" 
   }

   tempvar stopwhile  // used to check if any changes have been made
   qui generate `stopwhile'  = 0 if `touse' // to contain previous values of omega allocation

   // RSS optimization while loop
   qui levelsof `randid' if `touse', local(randidtot) // id levels from pooled sample
   local criterion = 0 // 0 for change, 1 for no change
   local p = 0         // iteration counter
   tempvar tousemata   // goes into matafe()

   // levels of `name'
   qui levelsof `name' if `touse', local(omegalevels)

   while `criterion'==0 & `p'<=`iterate' {

      local ++p // increase iteration counter

      // for every iteration, get id levels in each omega given the current partition
      forvalues i = 1/`omega' {
         qui levelsof `randid' if `name'==`i' & `touse', local(id`i')
      }

      // loop over all panels from the pooled sample
      foreach i of local randidtot {

         //find in which omega the id is currently in
         local stop 0 // reset for every individual
         forvalues j = 1/`omega' {
            foreach z of local id`j' {  // from the above levelsof, local(id`i')
               if `i'==`z' & `stop'== 0 {  // if `i' is the same as `z' in parition id`j'
                  local inomega = `j'    // then the individual `i' is in omega `j'
                  local stop  1
               }
            }
         }

         // calculate RSS for the various cases
         forvalues j = 1/`omega' {   
            // Case 1: if the `inomega' id is currently excluded from its current omega
            if `inomega'==`j' {  // if value is not in omega
               qui generate `tousemata' = 0
               // FE for a given omega, excluding the individual `i'
               qui replace `tousemata' = ((`name'==`j' & `randid'!=`i') & `touse')
               mata: matafe() // Mata FE estimator
               if _rc! = 0 { // insufficient observations
                  local case1rss = 0  // make zero when not included
                  continue   
               }
               local case1rss = matafe_rss // the one with a `randid' excluded
               drop `tousemata'
            }
            // Case 2: if the excluded `randid' is added to an omega
            else {
               qui generate `tousemata' = 0
               qui replace `tousemata' = ((`name'==`j' | `randid'==`i') & `touse')
               mata: matafe() // Mata FE estimator; case2rss is 0 if insufficient obs
               if _rc! = 0 { // insufficient observations
                  local case2rss`j' = 0  // make zero when not included
                  continue   
               }
               local case2rss`j' = matafe_rss  // the one with a `randid' excluded
               drop `tousemata'
            }
         }

         // Case 3: if the omega participation has not changed
         forvalues j = 1/`omega' {
            qui generate `tousemata' = 0
            qui replace `tousemata' = ((`name'==`j') & `touse')
            mata: matafe() // Mata FE estimator; case3rss is 0 if insufficient obs
            if _rc! = 0 { // insufficient observations
               local case3rss`j' = 0  // make zero when not included
               continue   
            }
            local case3rss`j' = matafe_rss  // the one with a `randid' excluded
            drop `tousemata'

            // get total RSS where nothing has changed                                                              
            if `j'==1 local totrss = matafe_rss
            else      local totrss = `totrss' + matafe_rss

         }

         // add-up RSS for each comb, e.g. move `inomega' to another omega
         forvalues j = 1/`omega' { // omega2  j is the one that now includes the `randid' 
   
            if `inomega'==`j' { // if `randid' is in same position that it is allocated to
               local totrss`j'= `totrss'  // all RSS as is
            } // if
            else {
               local totrss`j'=`case1rss'  // RSS for the one missing
               local totrss`j'=`totrss`j''+ `case2rss`j''  // RSS for the one added to
               local uniqlist : list omegalevels - inomega // RSS for the ones that have not changed
               local uniqlist : list uniqlist - j

               foreach w of local uniqlist {
                  local totrss`j' = `totrss`j'' + `case3rss`w''
               }
            } // else

            // mark total RSS with the j that it is in         
            if `j'==1 local loclistRSS `totrss`j''  // local loclistRSS goes into mata fillmaxrss()
            else      local loclistRSS `loclistRSS'  `totrss`j''
         }

         // sort and then reassign the level(`randid') to the new omega
         mata: fillmaxrss()   // gets macro with the highest RSS

         qui replace `name'=`loclistRSS' if `randid' ==`i' & `touse'
         local loclistRSS ""  // reset loclistRSS to take next `randid' info
   
      } // loop over all panels

      // stop the while loop if no more changes in partition variable `name'
      qui replace `stopwhile' = abs(`stopwhile' - `name') if `touse'
      qui sum `stopwhile' if `touse'
      if r(sum)==0  local criterion = 1  // value of 1 stops the loop
      if `criterion'==0 qui replace `stopwhile' = `name' if `touse'

      // the saved result in ereturn matrix rss
      if `p'==1 matrix rsslist`omega' = `rss_total_now'
      else matrix rsslist`omega' = rsslist`omega', `rss_total_now'  // afix column to rsslist, and make a row vector

      // iterations report
      if !strpos("`0'","nolog") {
         di as txt "Iteration `p': {col 15} Total RSS = " ///
            as res "{ralign 16: `:di %17.6f `=`rss_total_now'''}" 
      }
      if `p'==100 & "`iterate'"=="" {
         di as txt "The RSS did not converge. " _c
         di as txt "{bf:xtregcluster} has stopped because of the default {bf:iterate(100)}"
         continue, break // exit the loop
      }
      if `iterate'==`p' {
         di as txt "The RSS did not converge. " _c
         di as res "{bf:xtregcluster} has stopped because of option {bf:iterate(`p')}"
         continue, break // exit the loop
      }

      // exit given tolerance in convergence
      if (`sc_RSStot`omega'' - `rss_total_now') < abs(`tolerance') {
         continue, break // exit the loop
      }
   
      tempname sc_RSStot`omega'
      scalar `sc_RSStot`omega'' = `rss_total_now'

   } // while


   tempname sc_MICtot`omega'
   scalar `sc_MICtot`omega'' = `sc_N' * ln(`sc_RSStot`omega'' / (`sc_N' * `sc_T') ) + ( `omega' * `sc_theta' )

} // omega numlist


*******************************************************
**** Model Information Criterion (MIC) for Omega>1 ****
*******************************************************


// output tabular report
n di as txt "{c TLC}{hline 15}{c TT}{hline 15}{c TT}{hline 15}{c TRC}"
n di as txt "{c |}{col 7}Omega{col 17}{c |}{col 22}Total RSS{col 33}{c |}{col 40}MIC{col 49}{c |}"
n di as txt "{c LT}{hline 15}{c +}{hline 15}{c +}{hline 15}{c RT}"
n di as txt "{c |} " _c
n di as res "{center 14:{ralign 1:1}}" _c // Omega=1
n di as txt "{col 17}{c |} " _c
n di as res "{center 14:{ralign 13: `:di %12.3f `=`sc_RSSpool'''}}" _c
n di as txt "{col 33}{c |}" _c
n di as res "{center 14:{ralign 13: `:di %12.3f `=`sc_MICpool'''}}" _c
n di as txt "{col 49}{c |}"
foreach i of local omeganumlist { // omega nulist loop
   n di as txt "{c |} " _c
   n di as res "{center 14:{ralign 1:`i'}}" _c // Omegas>1
   n di as txt "{col 17}{c |} " _c
   n di as res "{center 14:{ralign 13: `:di %12.3f `=`sc_RSStot`i''''}}" _c
   n di as txt "{col 33}{c |}" _c
   n di as res "{center 14:{ralign 13: `:di %12.3f `=`sc_MICtot`i''''}}" _c
   n di as txt "{col 49}{c |}"
}
n di as txt "{c BLC}{hline 15}{c BT}{hline 15}{c BT}{hline 15}{c BRC}"

tempname optMIC
local optOmega = 1            // Omega=1 assumed optimal
scalar `optMIC'   = `sc_MICpool' // MIC of Omega=1 assumed optimal
foreach i of local omeganumlist { // find the lowest MIC
   if `sc_MICtot`i'' < `optMIC' {
      local optOmega = `i'
      scalar `optMIC' = `sc_MICtot`i'' 
   }
}

if "`preclass'"=="" local optName `nameprefix'`optOmega'
else local optName `name'

local c 0
local nlist "1"
forvalues i = 2/`optOmega' {
   local nlist "`nlist',`i'"
}
local nlist = strltrim("`nlist'")

if `sc_MICpool' < `optMIC' {
   di as txt "Recommendation: proceed with pooled OLS"
}
if `sc_MICpool' >= `optMIC' {
   di as txt "Proceed with " _c
   di as res "xtreg if `optName'==`=char(96)'i`=char(39)',fe  " _c
   di as txt "where `=char(96)'i`=char(39)'=`nlist'"
}


*************************************************
**** Show scatters by omega with lfit graphs ****
*************************************************


if "`graph'"!="" {
   local scheme `c(scheme)'
   set scheme s2color

   local ytit : variable label `depvar'
   if "`ytit'"=="" local ytit "`depvar'"
   
   local clist "blue*1.25 red black yellow*1.5 green*1.5 magenta cyan*1.5"
   local c 0
   foreach i of local clist {
      local col`++c' "`i'"
   }

   tempname minlab maxlab midlab
   qui sum `depvar'
   scalar `minlab' = r(min)
   scalar `maxlab' = r(max)
   local slist ""
   local llist ""
   local c 0
   forvalues i = 1/`=`optOmega'' {
      qui xtreg `depvar' `indepvars' if `touse' & `optName'==`i', fe
      tempvar xb`i'
      qui predict `xb`i'' if `touse'  & `optName'==`i', xb
      local slist "`slist' (scatter `depvar' `xb`i'' if `touse' & `optName'==`i', msym(o) mcol(`col`++c'') msize(*.6) mlwidth(*.4))"
      local llist "`llist' (lfit `depvar' `xb`i'' if `touse' & `optName'==`i', lcolor(`col`c'') lwidth(*1.25))"
      qui sum `xb`i''
      if r(min) < `minlab' scalar `minlab' = r(min)
      if r(max) > `maxlab' scalar `maxlab' = r(max)
   }
   scalar `midlab' = (`=`maxlab'' + `=`minlab'') / 2
   twoway `slist' `llist', legend(off) ytitle("`ytit'") ///
                           xtitle("Linear prediction by omega") ///
                           ysize(1) xsize(1) aspect(1)  ///
                           ylab(`=`minlab'' `=`midlab'' `=`maxlab'', format(%16.3g)) ///
                           xlab(`=`minlab'' `=`midlab'' `=`maxlab'', format(%16.3g))

   set scheme `scheme'
}


***************************************************
**** Show estimates table of xtreg,fe by omega ****
***************************************************


if `"`table'"'!="" {

   cap estimates drop Pooled
   qui xtreg `depvar' `indepvars' if `touse', fe
   estimates store Pooled

   local mwidth = max(strlen("`optName'_0"),strlen("Pooled"))
   local tablist ""
   local c 0
   forvalues i = 1/`=`optOmega'' {
      qui xtreg `depvar' `indepvars' if `touse' & `optName'==`i', fe
      estimates store `optName'_`i'
   }
   estimates table `optName'_* Pooled, `tableopt'  modelwidth(`mwidth')
   estimates drop  `optName'_* Pooled
   n di as txt "{it:Note}: For a description of model diagnostics see " _c
   n di as txt "stored results in {stata help xtreg:xtreg,fe}."
}


*****************************************
**** Return estimation saved results ****
*****************************************


ereturn clear
ereturn scalar N         = `sc_N'
ereturn scalar T         = `sc_T'
ereturn scalar NT        = `sc_NT'
ereturn scalar rss_pool  = `sc_RSSpool'
ereturn scalar mic_pool  = `sc_MICpool'
ereturn scalar omega_opt = `optOmega'
ereturn scalar theta     = `sc_theta'
foreach i of local omeganumlist { // find the lowest MIC
   ereturn scalar rss_tot`i' = `sc_RSStot`i''
   ereturn scalar mic_tot`i' = `sc_MICtot`i''
   ereturn matrix rss`i' = rsslist`i'
}
ereturn local name_opt  = "`optName'"
ereturn local cmdline   = itrim("xtreg `varlist', fe")

end // xtregcluster


*********************************************************
**** Mata program to calculate RSS from FE estimator ****
*********************************************************


mata:
void matafe()
{
  stata("sort " + st_local("panel")) // execute Stata command sort on panelvar id
  st_view(id, ., st_local("panel"), st_local("tousemata"))

  st_view(y,.,st_local("depvar"),st_local("tousemata")) // st_data consumes too much memory
  st_view(X,.,tokens(st_local("indepvars")),st_local("tousemata"))
  
  info = panelsetup(id, 1) // identify first and last rows of each panel; id is already sorted
  nt = rows(X)  // number of observations
  k  = cols(X)  // number of indepvars
  
  y_within = J(nt, 1, 0) // nt rows x 1 col  full of zeroes
  X_within = J(nt, k, 0) // nt rows x k cols full of zeroes

  for (i=1; i<=rows(info); i++) { // rows(info) gives number of panels
     panelsubview(yi, y, i, info) // 'yi' has depvar   values for panel 'i'
     panelsubview(Xi, X, i, info) // 'xi' has indepvar values for panel 'i'
     toprow = info[i,1] // row number for first obs of panel 'i'
     botrow = info[i,2] // row number for last  obs of panel 'i'
     y_within[toprow..botrow, .] = yi :- mean(yi, 1) // within transf, subtract panel mean(yi,1)
     X_within[toprow..botrow, .] = Xi :- mean(Xi, 1) // within transf, subtract panel mean(Xi,1)
  }

  y_within = y_within :+ mean(y, 1) // add global mean(y,1) to within transformation
  X_within = X_within :+ mean(X, 1) // add global mean(X,1) to within transformation
  X_within = X_within, J(nt,1,1)    // affix nt x 1 vector for regression intercept

  // RSS  =  y'y - y'X * b  =  y'y - y'X * (X'X)^-1 * X'y
  rss = quadcross(y_within,y_within) - quadcross(y_within,X_within) * ///
        invsym(quadcross(X_within,X_within)) * quadcross(X_within,y_within)

  st_numscalar("matafe_rss",rss) // RSS is the only outout from matafe()
}
end


***********************************************
**** Mata program to determine largest RSS ****
***********************************************


mata:
void fillmaxrss()
{
   j = strtoreal(st_local("omega"))
   for (i=1;i<=j;i++) {
         if (i==1) listofomega=i
         else listofomega = listofomega,i
   } 
   listofRSS  = strtoreal(tokens(st_local("loclistRSS")))
   stacklists = listofRSS\listofomega // stack the two lists
   orderedRSS = sort(stacklists',1)   // transpose and sort in acending order of RSS (smallest to largest)
   
   submat = select(orderedRSS, rowmissing(orderedRSS):==0)

   optomega = submat[1,2]         // pick omega with the smallest RSS
   smallestRSS = orderedRSS[1,1]  // pick smallest RSS

   st_local("rss_total_now",strofreal(smallestRSS))
   st_local("loclistRSS",strofreal(optomega))
}
end // stop mata


********************************************************

exit // exit ado-file
