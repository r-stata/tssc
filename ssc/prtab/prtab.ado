
program prtab, rclass
    version 11

	syntax varlist (numeric min=2 max=2) [if] [in] , [prec_at(real .2) COMpare(varname) INTERpolate rank THREShold fscore NOGraph NOREFline *]
	
	_get_gropts, graphopts(`options')
	local twowayopts `"`s(graphopts)'"'	
	
	gettoken y_name classifier_name : varlist 
	
 /* Call preserve because we will need to create new variables */
	preserve
	
	tempvar y classifier
	qui gen `y' = `y_name' `if' `in'
	qui gen `classifier' = `classifier_name' `if' `in'
	qui drop if missing(`y') | missing(`classifier')
	gsort -`classifier'
		
 /* Checks on inputs */
	cap assert `y'==0 | `y'==1
	if  _rc~=0 {
	  noi di in red "true status of variable `y_name' must be 0 or 1"
	  exit 198
	}
	if "`rank'"!="" & "`threshold'"!="" {
	  noi di in red "you cannot specify both rank and threshold"
	  exit 198
	}
	if "`compare'"!="" & "`threshold'"!="" {
	  noi di in red "you cannot use compare with threshold"
	  exit 198
	}
    if "`rank'"!="" & "`fscore'"!="" {
	  noi di in red "you cannot specify both rank and fscore"
	  exit 198
	}
	if "`rank'"!="" & "`interpolate'"!="" {
	  noi di in red "you cannot specify both rank and interpolate"
	  exit 198
	}
    if "`prec_at'" > "1" & "`rank'"=="" {
	  noi di in red "you have provided prec_at with a value of recall that is greater than 1"
	  exit 198
	}
 /* Finished checks on inputs */	
 
	
	
  if "`compare'" == "" {
    qui sum `y'
	local rnd_rate = r(mean)
	local obs = r(N)
	local total_pos = `rnd_rate'*`obs'
	
    if "`rank'"=="" {
	  tempvar running_total prec recall ranking fscore_val
	  gen `running_total' = sum(`y')
	  gen `ranking' = _n
	  gen `prec' = `running_total'/`ranking'
      gen `recall' = `running_total'/`total_pos'
      gen `fscore_val' = 2*`prec'*`recall'/(`prec'+`recall')
	  
	  tempvar unique
	  gsort `classifier' -`recall'
	  by `classifier': gen `unique'= _n==1
	  qui sum `unique'
	  local unique_obs = r(N)*r(mean)
	  gsort -`classifier' 
      qui drop if `unique'==0

      tempvar obs_number
	  gen `obs_number' = _n
	
 /* Display table */

      di as txt _n "{col 12}Number of observations       =  " as result    `obs'
      di as txt "{col 12}Unique values of classifier  =  "  as result   `unique_obs'
      di as txt "{col 12}Number of positive cases     =  " as result    `total_pos'
      di as txt  "{col 12}Portion of positive cases    =" as result  %8.04f `rnd_rate'
	  
	  if `unique_obs' >= 3 {
       tempvar firsttime1 firsttime2 firsttime3
       egen `firsttime1' = min(cond(`recall' >= `prec_at'-.1, `obs_number', .))
       egen `firsttime2' = min(cond(`recall' >= `prec_at', `obs_number', .))
       if `firsttime1'==`firsttime2'{
	     qui replace `firsttime2'=`firsttime1' + 1
	   }
	   egen `firsttime3' = min(cond(`recall' >= `prec_at'+.1, `obs_number', .))
       if `firsttime3'<=`firsttime2'{
	     qui replace `firsttime3'=`firsttime2' + 1
	   }
	   di as txt _n "{hline 50}   
       di as txt "{col 5} Recall =" %8.04f `recall'[`firsttime1']  _col(25)  %8.04f `recall'[`firsttime2'] _col(37)  %8.04f `recall'[`firsttime3']
       di as txt "{hline 50}
       di as res "{col 2}Precision" as result  _col(14) %8.04f `prec'[`firsttime1'] _col(25) %8.04f `prec'[`firsttime2'] _col(37) %8.04f `prec'[`firsttime3']
       di as txt "{hline 50}	 
	  }

 /* Interpolate */	  
	  if "`interpolate'" !=""{
	    local new = _N + 1
		qui set obs `new'
		qui replace `recall'=0 if missing(`recall')
		qui replace `prec'=0 if missing(`prec')
	    gsort -`recall'
      	tempvar inter_prec
        qui gen `inter_prec'=`prec'[1] in 1
		qui replace `inter_prec'=max(`prec', `inter_prec'[_n-1]) if missing(`inter_prec')
		qui replace `prec'=`inter_prec'
		sort `recall'		
	  }
 /* Display graph */	
      if "`nograph'"=="" {
	    if "`threshold'"=="" & "`fscore'"==""{
          if "`norefline'"==""{
            graph twoway line `prec' `recall' , yline(`rnd_rate') ytitle("Precision") xtitle("Recall") `twowayopts'
	      }
	      else{
	        graph twoway line `prec' `recall', ytitle("Precision") xtitle("Recall") `twowayopts'
	      }
        }
	    else if "`fscore'"==""{
          if "`norefline'"==""{
		    graph twoway line `prec' `classifier', xsc(reverse) yline(`rnd_rate') ytitle("Precision") xtitle("Threshold") `twowayopts'
		  }
		  else{
		    graph twoway line `prec' `classifier', xsc(reverse) ytitle("Precision") xtitle("Threshold") `twowayopts'
		  }
	    }
		else{
		  if "`threshold'"=="" {
            graph twoway line `fscore_val' `recall', ytitle("F-score") xtitle("Recall") `twowayopts'		  
		  }
		  else{
		    graph twoway line `fscore_val' `classifier', xsc(reverse) ytitle("F-score") xtitle("Threshold") `twowayopts'
		  }
		}
	  }
 /* Calculate and display AUC */	
	qui integ `prec' `recall'
	local auc = r(integral)
	di as txt _n"{col 2}Area under precision-recall curve:"%8.04f `auc'
	
 /* Return values */
	return scalar AUC = `auc'
	return scalar N = `obs'
	return scalar unique_val = `unique_obs'
	return scalar pos_cases = `total_pos'
    return scalar prct_pos = `rnd_rate'
	}
	else {
	  tempvar running_total prec ranking avg_pos
	  gen `ranking' = _n
      bysort `classifier': egen `avg_pos'= mean(`y')
	  gsort -`classifier' 
	  gen `running_total' = sum(`avg_pos')
	  gen `prec' = `running_total'/`ranking'

	  tempvar unique
	  bysort `classifier': gen `unique'= _n==1
	  qui sum `unique'
	  local unique_obs = r(N)*r(mean)
	  gsort -`classifier' 

      tempvar obs_number
	  gen `obs_number' = _n

 /* Display table */
      di as txt _n "{col 12}Number of observations       =  " as result    `obs'
      di as txt "{col 12}Unique values of classifier  =  "  as result   `unique_obs'
      di as txt "{col 12}Number of positive cases     =  " as result    `total_pos'
      di as txt  "{col 12}Portion of positive cases    =" as result  %8.04f `rnd_rate'
       local top_1 = round(.01*`obs',1)
       local top_5 = round(.05*`obs',1)
	   local top_10 = round(.10*`obs',1)
	   
	   if "`prec_at'"==".2" {
	     di as txt _n"{hline 50}
         di as txt  "{col 15} Top 1% {col 28} Top 5% {col 40} Top 10%"
         di as txt "{hline 50}
         di as res "{col 2}Precision" _col(14) as result  %8.04f `prec'[`top_1'] _col(27) %8.04f `prec'[`top_5'] _col(39) %8.04f `prec'[`top_10']
         di as txt "{hline 50}
       }
	   else if floor(`prec_at') <= `obs'{
	   	 di as txt _n"{hline 50}
         di as txt  "{col 23} At rank " floor(`prec_at')
         di as txt "{hline 50}
         di as res "{col 12}Precision" _col(24)as result   %8.04f `prec'[floor(`prec_at')] 
         di as txt "{hline 50}
	   }
	   else{
	   	 di as txt _n"{hline 50}
         di as txt  "{col 23} At rank " floor(`obs')
         di as txt "{hline 50}
         di as res "{col 12}Precision" _col(24)as result   %8.04f `prec'[floor(`obs')] 
         di as txt "{hline 50}
		  di as res _n"Note: The provided value of prec_at is greater than the"
	      di as res "number of observations."
	   }
	   
 /* Display graph */	
      if "`nograph'"=="" {
        if "`norefline'"==""{
          graph twoway line `prec' `ranking', yline(`rnd_rate') ytitle("Precision") xtitle("Rank") `twowayopts'
	    }
	    else{
	      graph twoway line `prec' `ranking', ytitle("Precision") xtitle("Rank") `twowayopts'
	    }
	    if `unique_obs'<`obs' {
	      di as res _n"Note: There are multiple observations with the same classifer"
	      di as res "value. Average precision over possible rankings was used."
	    }

      }
	
 /* Return values */
	return scalar N = `obs'
	return scalar unique_val = `unique_obs'
	return scalar pos_cases = `total_pos'
    return scalar prct_pos = `rnd_rate'
	}
  
  }
 /* Now handle comparisons of two classifiers */	  
  else {
     tempvar classifier2
	 qui gen `classifier2' = `compare' `if' `in'
	 qui drop if missing(`classifier2')
	 qui sum `y'
	 local rnd_rate = r(mean)
	 local obs = r(N)
	 local total_pos = `rnd_rate'*`obs'
	 
	 if "`rank'"=="" {

	 /*  Main classifier */
	  tempvar running_total prec recall ranking fscore_val
	  qui gen `running_total' = sum(`y')
	  qui gen `ranking' = _n
	  qui gen `prec' = `running_total'/`ranking'
      qui gen `recall' = `running_total'/`total_pos'
      qui gen `fscore_val' = 2*`prec'*`recall'/(`prec'+`recall')

	  tempvar unique
	  gsort `classifier' -`recall'
	  by `classifier': gen `unique'= _n==1
	  
  /*  Comparison classifier */
	  tempvar running_total2 prec2 recall2 ranking2 fscore_val2
      gsort -`classifier2'
	  qui gen `running_total2' = sum(`y')
	  qui gen `ranking2' = _n
	  qui gen `prec2' = `running_total2'/`ranking2'
      qui gen `recall2' = `running_total2'/`total_pos'
      qui gen `fscore_val2' = 2*`prec2'*`recall2'/(`prec2'+`recall2')
	  
	  tempvar unique2
	  gsort `classifier2' -`recall2'
	  by `classifier2': gen `unique2'= _n==1
	  
 /* Interpolate */	  
	  if "`interpolate'" !=""{
	    tempvar temp_prec new_prec
	    qui gen `temp_prec'=`prec' if `unique'
	    qui bysort `classifier': egen `new_prec'=max(`temp_prec')
	   
	    local new = _N + 1
		qui set obs `new'
		qui replace `recall'=0 if missing(`recall')
		qui replace `new_prec'=0 if missing(`prec')
		qui replace `unique'=1 if missing(`unique')
		qui sum `classifier'
		qui replace `classifier'=r(max)+1 if missing(`classifier') 
		gsort `classifier' -`recall' 
      	tempvar inter_prec
        qui gen `inter_prec'=`new_prec'[1] in 1 
		qui replace `inter_prec'=max(`new_prec', `inter_prec'[_n-1]) if  missing(`inter_prec')
		qui replace `prec'=`inter_prec' 
	
	    tempvar temp_prec2 new_prec2
	    qui gen `temp_prec2'=`prec2' if `unique2'
	    qui bysort `classifier2': egen `new_prec2'=max(`temp_prec2')
	
		qui replace `recall2'=0 if missing(`recall2')
		qui replace `prec2'=0 if missing(`prec2')
		qui sum `classifier2'
		qui replace `classifier2'=r(max)+1 if missing(`classifier2')
        gsort -`recall2' `classifier2' 
      	tempvar inter_prec2
        qui gen `inter_prec2'=`new_prec2'[1] in 1
		qui replace `inter_prec2'=max(`new_prec2', `inter_prec2'[_n-1]) if  missing(`inter_prec2') 
		qui replace `prec2'=`inter_prec2'
	  }
 /* Display graph */	
      if "`nograph'"=="" {
	  	gsort -`classifier'
	    tempvar neg_c2
	    gen `neg_c2' = -`classifier2'

	    if "`fscore'"==""{
          if "`norefline'"==""{
		    graph twoway line `prec' `recall' if `unique', yline(`rnd_rate') ytitle("Precision") xtitle("Recall") `twowayopts' legend(order(1 "`classifier_name'" 2 "`compare'"))|| line `prec2' `recall2' if `unique2', sort(`neg_c2')
		  }
	      else{
	        graph twoway line `prec' `recall' if `unique', ytitle("Precision") xtitle("Recall") `twowayopts' legend(order(1 "`classifier_name'" 2 "`compare'"))|| line `prec2' `recall2' if `unique2', sort(`neg_c2')
	      }
        }
	    else {
		  graph twoway line `fscore_val' `recall' if `unique', sort xsc(reverse) ytitle("F-score") xtitle("Recall") `twowayopts' legend(order(1 "`classifier_name'" 2 "`compare'")) || line `fscore_val2' `recall2' if `unique2', xsc(reverse) sort(`neg_c2')
		}
	  }
 /* Calculate AUC */	
	qui integ `prec' `recall' if `unique'
	local auc = r(integral)
	qui integ `prec2' `recall2' if `unique2'
	local auc2 = r(integral)
	
 /* Display table */
    local shortname1 = substr("`classifier_name'", 1, 17)
	local shortname2 = substr("`compare'", 1, 17)
    di as txt _n "{col 12}Number of observations       =  " as result   `obs'
    di as txt "{col 12}Number of positive cases     =  "   as result  `total_pos'
    di as txt  "{col 12}Portion of positive cases    ="  as result %8.04f `rnd_rate'
	di as txt _n"{hline 50}
	di as txt "{col 14}`shortname1'{col 34}`shortname2'"
	di as txt "{hline 50}
	di as txt "{col 2}PR AUC{col 12}"as result  %8.04f `auc' "{col 32}" %8.04f `auc2'
	di as txt "{hline 50}
	
 /* Return values */
	return scalar AUC = `auc'
	return scalar AUC2 = `auc2'
	return scalar N = `obs'
	return scalar pos_cases = `total_pos'
    return scalar prct_pos = `rnd_rate'
	 }
	 else{
	  tempvar running_total prec ranking avg_pos
	  gen `ranking' = _n
      bysort `classifier': egen `avg_pos'= mean(`y')
	  gsort -`classifier' 
	  gen `running_total' = sum(`avg_pos')
	  gen `prec' = `running_total'/`ranking'

	  tempvar unique
	  bysort `classifier': gen `unique'= _n==1
	  qui sum `unique'
	  local unique_obs = r(N)*r(mean)
	  	  
	  tempvar running_total2 prec2 ranking2 avg_pos2
	  gsort -`classifier2' 
	  gen `ranking2' = _n
      bysort `classifier2': egen `avg_pos2'= mean(`y')
	  gsort -`classifier2' 
	  gen `running_total2' = sum(`avg_pos2')
	  gen `prec2' = `running_total2'/`ranking2'

	  tempvar unique2
	  bysort `classifier2': gen `unique2'= _n==1
	  qui sum `unique2'
	  local unique_obs2 = r(N)*r(mean)
	  	  
      tempvar obs_number
	  gen `obs_number' = _n

 /* Start table */	  
	  di as txt _n "{col 12}Number of observations       =  " as result   `obs'
      di as txt "{col 12}Number of positive cases     =  "   as result  `total_pos'
      di as txt  "{col 12}Portion of positive cases    ="  as result %8.04f `rnd_rate'

 /* Display graph */	
      if "`nograph'"=="" {
	  	gsort -`classifier'
        if "`norefline'"==""{
          graph twoway line `prec' `ranking', sort yline(`rnd_rate') ytitle("Precision") xtitle("Rank") legend(order(1 "`classifier_name'" 2 "`compare'")) `twowayopts' || line `prec2' `ranking2', sort(`ranking2')
	    }
	    else{
	      graph twoway line `prec' `ranking', sort ytitle("Precision") xtitle("Rank") legend(order(1 "`classifier_name'" 2 "`compare'")) `twowayopts' || line `prec2' `ranking2', sort(`ranking2')
	    }
      }
 
 /* Calculate AUC to return and display */	  
    drop `prec' `prec2' `ranking' `ranking2' `running_total' `running_total2'

	/*  Main classifier */
	  tempvar running_total prec recall ranking 
	  qui gen `running_total' = sum(`y')
	  qui gen `ranking' = _n
	  qui gen `prec' = `running_total'/`ranking'
      qui gen `recall' = `running_total'/`total_pos'

	  tempvar unique
	  gsort `classifier' -`recall'
	  by `classifier': gen `unique'= _n==1
	  
     /*  Comparison classifier */
	  tempvar running_total2 prec2 recall2 ranking2 
      gsort -`classifier2'
	  qui gen `running_total2' = sum(`y')
	  qui gen `ranking2' = _n
	  qui gen `prec2' = `running_total2'/`ranking2'
      qui gen `recall2' = `running_total2'/`total_pos'
	 
     /* Interpolate */	  
	  if "`interpolate'" !=""{
  	    sort `classifier'
      	tempvar inter_prec
        qui gen `inter_prec'=`prec'[1] in 1
		qui replace `inter_prec'=max(`prec', `inter_prec'[_n-1]) if missing(`inter_prec')
		qui replace `prec'=`inter_prec'
		
	    sort `classifier2'
      	tempvar inter_prec2
        qui gen `inter_prec2'=`prec2'[1] in 1
		qui replace `inter_prec2'=max(`prec2', `inter_prec2'[_n-1]) if missing(`inter_prec2')
		qui replace `prec2'=`inter_prec2'
	  }
     /* Calculate AUC */	
	qui integ `prec' `recall' if `unique'
	local auc = r(integral)
	qui integ `prec2' `recall2' if `unique2'
	local auc2 = r(integral)

     /* Display table */
    local shortname1 = substr("`classifier_name'", 1, 17)
	local shortname2 = substr("`compare'", 1, 17)
    di as txt _n"{hline 50}
	di as txt "{col 14}`shortname1'{col 34}`shortname2'"
	di as txt "{hline 50}
	di as txt "{col 2}PR AUC{col 12}"as result  %8.04f `auc' "{col 32}" %8.04f `auc2'
	di as txt "{hline 50}
	
	 if "`nograph'"=="" & (`unique_obs2'<`obs' | `unique_obs'<`obs') {
	      di as res _n"Note: There are multiple observations with the same classifer"
	      di as res "value. Average precision over possible rankings was used."
	    }


	
 /* Return values */
	return scalar AUC = `auc'
	return scalar AUC2 = `auc2'
	return scalar N = `obs'
	return scalar pos_cases = `total_pos'
    return scalar prct_pos = `rnd_rate'
	}
  
	  
	  
	 
 }	
	

	
 /* Call restore to remove created variables */
	restore

	end
