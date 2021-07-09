program umbrella //------------------------------------------------------
version 10.0
preserve
*
* Perform o'Brien's multivariate test (Biometrics 1984;40:1079-1087).
* This is an alternative to the Hotelling' T test.  It is more powerful than
* Hotellings test when there is a natural ordering to 
* the univariate response variables.
*
* Input
*	y1 = first response variable
*	...
*	yK = Kth response variable
*       factor_var = classification variable
*       highlow string
*       ranktable
*       id variable name
*
*	(K = number of response variables is calculated by counting
*        the number of response variables on the command line)
*
* Output
*	Lists P value from O'Brien's multivariate test of the null hypothesis
*	that the mean of the response vectors are equal in groups defined by
*	each value of factor_var.
*
* Program call
*	umbrella y1...yK [if] [in] [, BY(factor_variables) highlow(string) ranktable id(varlist)]
*
syntax varlist [if] [in] [, BY(varlist) HIghlow(string) RAnktable id(varlist)]
*
*  deal with [if] and [in]
*
if "`if'`in'"~="" {
	keep `if' `in'
}
*
*  The by option is required.  Make sure it is here.
*
if "`by'"=="" {
	display in red "by() option required"
	exit 100
}       
*
*  Extract the factor variables.
*
local factor_var="`by'"
*
*  The remaining variables on the command line are the
*  response variables.  Process these one at a time.
*  Keep a count (K) of the number of response variables.
*
tokenize "`varlist'"
local missing = 0
local K=0
while "`1'" ~= "" {
	local K=`K' + 1
        local resp`K' `1'
	local missing =`missing'+ (`1' == .)
	quietly drop if `1' ==.
	sort `1'
        egen r`K' = rank(`1')
        egen r_`1' = rank(`1')
	mac shift
}
display _newline(1) as text "Number of response variables: " as result "`K'"
*
*  Reverse the rank if small values are "better".
*  H is assumed if an "L" is not present.
*
tokenize "`highlow'"
local J=0
while "`1'" ~= "" {
	local J=`J' + 1
        local hilo`J' `1'
        quietly count
        if "`1'"=="L" {
            qui replace r`J'=(r(N)+1)-r`J'
            qui replace r_`resp`J''=r`J'
        }
	mac shift
}
*
*  Calculate the sum of the ranks.
*
gen S = r1
forvalues k = 2/`K' {
    quietly replace S = S + r`k'
}
*
*  Make a table showing H and L settings.
*
* ----------------------------
display _newline(1) as text _col(5) "Variable" _col(14) "{c |}" _col(22) "Outcome"

display             as text "{hline 13}{c +}{hline 53}"

forvalues k = 1/`K' {
        local hilo_label`k' "lower values are better"
        if "`hilo`k''" ~= "L" {
                local hilo_label`k' "higher values are better"
        }
        local abname = abbrev("`resp`k''",12)
        display as text          "{ralign 12:`abname'}" /*
*/              as text _col(14) "{c |}"               /*
*/              as resu _col(23) "`hilo_label`k''"
}
*-------------------------------------
*
*  Output a summary table of the input variables by the factor variable(s).
*
bysort `factor_var': summ `varlist'
*
*  Produce the table that lists the ranks
*  and sum of ranks.
*
gen sum_of_ranks=S
if "`ranktable'" ~= "" {
	sort `factor_var' sum_of_ranks
	display _newline(1) as text "List of ranks"
	by `factor_var': list `id' r_* sum_of_ranks, abbreviate(12)
}

display _newline(1) as text "Missing observations dropped from analysis = " as result "`missing'" 

display _newline(1) as text "O'Brien's Umbrella test is the following Kruskal-Wallis test on the
display as text "sum of the ranks across the dependent variables."

kwallis S, by(`factor_var')

 
end //---------------------------------------------------
 