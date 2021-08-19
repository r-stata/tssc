*! version 3.0
*! 2020/11/24 15:43

capture program drop regfit
program define regfit
version 9
syntax [, Format(string) Tvalue NOnotes ]
qui {
	tempname _colA
	matrix `_colA'=e(b)
	local _colnames: colnames `_colA'
	local i=1
	if "`format'" == "" {
		local format1="4.2f"
	}
	else {
		local format1=subinstr("`format'","%","",.)
	}
    local sf = substr("`format1'",1,1)  //format 占的字符长度
}
di _n _c

*---------------
*-display coef
*---------------
  local i = 1
  local K = wordcount("`_colnames'")
  tokenize `_colnames'

  *-dependentvar  = ...
    di as result e(depvar) " =" _c
  *-constant term
	if _coef["``K''"]<0 {
		di as result " -" %`format1' (-1)*_coef["``K''"] _c
	}
	else {
		di as result "  " %`format1' _coef["``K''"] _c
	}
  *-explian variables
    forvalues i=1/`=`K'-1'{
   	  if _coef["``i''"]>=0 {
		di as result " + " %`format1' _coef["``i''"] "*``i''" _c
	  }
	  else {
		di as result " - " %`format1' (-1)*_coef["``i''"] "*``i''" _c
	  } 
    }	
  di _n _c	
	

*---------------
*-display se[]
*---------------
if "`tvalue'"==""{
  *-constant
    local deplength = length("`e(depvar)'")
	di as result _col(`=`deplength'+3') " (" %`format1' _se["``K''"] ")" _c

  *-other variables
    forvalues i=1/`=`K'-1'{
	  if `i'==1{
	    *local skip = `sf'
	    di as result _skip(1) "(" %`format1' _se["``i''"] ")" _c	    
	  }
	  else{
	    local lvar1 = length("``=`i'-1''")  //new 
	    local skip = `lvar1' + 4 -2
	    di as result _skip(`skip') "(" %`format1' _se["``i''"] ")" _c
	  }
    }
}
	
*-----------------
*-display t-value
*-----------------
else{
  *-constant
    local deplength = length("`e(depvar)'")
	local ttt = _b["``K''"]/_se["``K''"]
	di as result _col(`=`deplength'+4') " (" %`format1' `ttt' ")" _c

  *-other variables
    forvalues i=1/`=`K'-1'{
	  if `i'==1{
	    local ttt = _b["``i''"]/_se["``i''"]
	    di as result _skip(1) "(" %`format1' `ttt' ")" _c	    
	  }
	  else{
	    local lvar1 = length("``=`i'-1''")  //new 
	    local skip = `lvar1' + 4 -2
		local ttt = _b["``i''"]/_se["``i''"]
	    di as result _skip(`skip') "(" %`format1' `ttt' ")" _c
	  }
    }	
}

	
*---------------
*-R2 and N	
*---------------
   dis _n _c
      
   di as result _col(`=`deplength'+5') "N = `e(N)'"   _c
   
 if e(cmd)=="regress"{
   di as result ", R2 = "     %`format1' `e(r2)'   _c
   di as result ", adj-R2 = " %`format1' `e(r2_a)' _c	
 }
 else if e(cmd)=="logit"{
   di as result ", Pseudo-R2 = "  %`format1' `e(r2_p)'   _c
 } 
 else if e(cmd)=="xtreg"{
   di as result ", N_g = `e(N_g)'" _c
   di as result ", R2-within = "  %`format1' `e(r2_w)' _c
   di as result ", R2-between = " %`format1' `e(r2_b)' _c	
   di as result ", R2-overall = " %`format1' `e(r2_o)' _c
 }  
   
*---------------
*-Notes
*---------------   
   if "`nonotes'"==""{
      dis _n _c
      if "`tvalue'"!=""{
	     dis in g "Note: t-value in parentheses"
	  }
	  else{
	     dis in g "Note: S.E. in parentheses"
	  }
   }
   
end
