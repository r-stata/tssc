*! version 0.4.1 08jul2020
/*
  The Activity Index (AI) of a  variable x is defined as a fraction of fractions.
  Thereby the dividend of the AI is the fraction of the original variable by the 
  aggregation of that variable along the first dimension. The divisor of the AI 
  is the fraction of the aggregation of the original variable along the second
  dimension by the overall sum of it. In mathematical notation and by the use of
  sum(x|y) as aggregation of x along y we get:
    ai(x) := (x/sum(x|dim1)) / (sum(x|dim2)/sum(x)).
	
  Author:
    Joel E. H. Fuchs a.k.a. Fantastic Captain Fox
	jfuchs@uni-wuppertal.de
*/
program define _gresp
    version 6, missing
    syntax newvarname(generate) =/exp [if] [in], /*
	 */ Dim(varlist min=2 max=2) [BY(varlist) Mode(string) DUPlicates]
	local dim1 : word 1 of `dim'
	local dim2 : word 2 of `dim'
	tempvar touse sum
    quietly {
	    generate byte `touse' = 1 `if' `in'
		if `"`duplicates'"' != "" {
		    version 8, missing
			sort `touse' `by' `dim'
			duplicates report `by' `dim' if `touse' == 1, fast
			if `r(N)' == `r(unique_value)' {
				display as error "Data set includes duplicates."
			    error 9
			}
			version 6, missing
		}
		sort `touse' `by' `dim1'
	    by `touse' `by' `dim1': generate `type' `sum' = sum(`exp') if `touse' == 1
		by `touse' `by' `dim1': replace `varlist' = `exp' / `sum'[_N] if `touse' == 1
		
		by `touse' `by': replace `sum'  = sum(`exp') if `touse' == 1
		by `touse' `by': replace `varlist' = `varlist' * `sum'[_N] if `touse' == 1
		
		sort `touse' `by' `dim2'
		by `touse' `by' `dim2': replace `sum' = sum(`exp') if `touse' == 1
		by `touse' `by' `dim2': replace `varlist' = `varlist' / `sum'[_N] if `touse' == 1
		
	    if `"`mode'"' == "ai" | `"`mode'"' == "AI" | `"`mode'"' == ""  {
	    }
		else if `"`mode'"' == "rpa" | `"`mode'"' == "RPA" {
		    replace `varlist' = ln(`varlist') if `touse' == 1
	    }
		else if `"`mode'"' == "rsi" | `"`mode'"' == "RSI" {
		    replace `varlist' = 1 - 2/(`varlist' + 1) if `touse' == 1
		}
		else if `"`mode'"' == "resp" | `"`mode'"' == "RESP" {
		    replace `varlist' = 100 - 200/(`varlist'^2 + 1) if `touse' == 1
		}
		else {
		    display as error "Option MODE incorrectly specified."
		    error 198
	    }
	}
end
