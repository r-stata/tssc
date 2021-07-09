/*! rdecompose.ado, 0.4.1 Jinjing Li, 22/9/2015
*----------------------------------------------------------------------
* Revision history :
* 0.4.1: Minor format updates
* 0.4.0: Baseline selection
* 0.3.0: multi comparisons
* 0.2.0: with direct effect
* 0.1.2: Add if support
* 0.1.1: Add transform() feature; fixed the bug in function specifications
* 0.1.0: First complete version
* 0.0.2: functional form
* 0.0.1:
* - First development version
*
* todo: multiple year(group) comparison, moving average
* todo: specify baseline group value
*----------------------------------------------------------------------
*----------------------------------------------------------------------
* Description :
*
* This program decomposes the rate differences between two population groups using Gupta's method
*
*----------------------------------------------------------------------
*----------------------------------------------------------------------
* Syntax :
*
* rdecompose varlist [if] , group(varname) [sum(varlist) detail function(string) force reverse TRANSform(varlist)]
*
*----------------------------------------------------------------------*/
/*------------------------------------------------ MAIN -------- */
/*------------------------------------------------ rdecompose */
program define rdecompose , eclass sortpreserve
version 12.0
if replay() {
if (`"`e(cmd)'"' != "rdecompose") {
noi di as error "results for rdecompose not found"
exit 301
}
rDisplay `0'
exit `rc'
}
else Decompose `0'
ereturn local cmdline `"rdecompose `0'"'
end
/*------------------------------------------------ SUBROUTINES -- */
/*------------------------------------------------ Decompose */
program define Decompose, eclass
syntax varlist(numeric) [if], Group(varname) [sum(varlist)] [Detail] [FUNCtion(string asis)] [force] [reverse] [TRANSform(varlist numeric)] [multi] [BASEline(real -9999999)]
tempname grouplevel
qui levelsof `group' `if', local(`grouplevel')
local i = 0
foreach l of local `grouplevel' {
local ++i
local group`i'value `l'
if (("`baseline'" != "-9999999") & ("`baseline'" == "`l'")) {
local matched_base `i'
}
}
if `i'==1 {
display as error "There needs to be 2 groups"
exit 322
}
if (("`baseline'" != "-9999999") & ("`matched_base'" == "")) {
display as error "Baseline value `baseline' not found in `group'"
exit 322
}
else {
if "`matched_base'" != "" {
local temp "`group1value'"
local group1value "`group`matched_base'value'"
local group`matched_base'value "`temp'"
}
}
if `i' >2 {
if "`multi'" == "" {
display as error "option [multi] is required if there are more than two groups"
exit 322
}
forvalues j=2/`i' {
tempname nif
cap confirm numeric variable `group'
if _rc !=0 {
local subif `"(`group' == "`group1value'" | `group' == "`group`j'value'")"'
}
else {
local subif "(`group' == `group1value' | `group' == `group`j'value')"
}
if "`if'" == "" {
local `nif' "if `subif'"
}
else {
local `nif' "`if' & `subif'"
}
rDecompose `varlist' ``nif'', group(`group') sum(`sum') `detail' function(`function') `force' `reverse' transform(`transform') baseline(`baseline')
}
}
else {
rDecompose `varlist' `if', group(`group') sum(`sum') `detail' function(`function') `force' `reverse' transform(`transform') baseline(`baseline')
}
end
/*------------------------------------------------ SUBROUTINES -- */
/*------------------------------------------------ Decompose */
program define rDecompose, eclass
syntax varlist(numeric) [if], Group(varname) [sum(varlist)] [Detail] [FUNCtion(string asis)] [force] [reverse] [TRANSform(varlist numeric)] [BASEline(real -9999999)]
local factors "`varlist'"
if "`function'" =="" {
local i = 1
foreach v of local factors {
if `i' == 1 {
local function "`v'"
}
else {
local function "`function'*`v'"
}
local ++i
}
}
foreach v of local transform {
tempvar t_sum_`v'
qui bys `group': egen double `t_sum_`v'' = sum(`v') `if'
}
tempvar testvar
cap gen `testvar' = `function' `if'
cap count if `testvar' !=.
if (_rc!=0 | r(N) == 0) {
display as text "The function specified does not appear to be valid"
if length("`force'") ==0 {
exit 322
}
}
tempvar original_sum sum_combination
local `original_sum' "`sum'"
if "`sum'" == "" {
tempvar sum_replacement
gen byte `sum_replacement' = 0
local sum `sum_replacement'
}
local i = 1
foreach sumvar of local sum {
local sumvar`i'_name "`sumvar'"
qui levelsof `sumvar' `if', local(sumvar_`i')
local lcount =0
foreach l of local sumvar_`i' {
local ++lcount
local sumfactor_`i'_`lcount'_value `l'
}
local sumvar_`i'_length = `lcount'
local ++i
}
local i = 1
local `sum_combination' = 1
foreach sumvar of local sum {
local `sum_combination' = ``sum_combination'' * `sumvar_`i'_length'
local ++i
}
local num_of_sums = `i' - 1
tempname s_res sum_cond factor_index
forvalues s=1/``sum_combination'' {
local `s_res'= `s'
local `sum_cond' ""
forvalues c=1/`num_of_sums' {
local `factor_index' = mod(``s_res'', `sumvar_`c'_length') + 1
cap confirm numeric variable `sumvar`c'_name'
if _rc !=0 {
local `sum_cond' ``sum_cond'' & `sumvar`c'_name' == "`sumfactor_`c'_``factor_index''_value'"
}
else {
local `sum_cond' "``sum_cond'' & `sumvar`c'_name' == `sumfactor_`c'_``factor_index''_value'"
}
local `s_res' = int(``s_res''/`sumvar_`c'_length') + ``factor_index''
}
tempname nif`s'
if "`if'" == "" {
local `nif`s'' "if 1 ``sum_cond''"
}
else {
local `nif`s'' "`if' ``sum_cond''"
}
}
tempname grouplevel
qui levelsof `group' `if', local(`grouplevel')
local i = 0
foreach l of local `grouplevel' {
local ++i
local group`i'value `l'
if (("`baseline'" != "-9999999") & ("`baseline'" == "`l'")) {
local matched_base `i'
}
}
if `i'==1 {
display as error "There needs to be 2 groups"
exit 322
}
if (("`baseline'" != "-9999999") & ("`matched_base'" == "")) {
display as error "Baseline value `baseline' not found in `group'"
exit 322
}
else {
if "`matched_base'" != "" {
local temp "`group1value'"
local group1value "`group`matched_base'value'"
local group`matched_base'value "`temp'"
}
}
if "`reverse'" != "" {
tempname temp_gv
local `temp_gv' = `group1value'
local group1value = `group2value'
local group2value = ``temp_gv''
}
// final_diff stores the final differences
tempname final_diff factor_count factor_name total_N b_overall final_rate1 final_rate2
local `final_diff' = 0
local `total_N' = 0
local `final_rate1' = 0
local `final_rate2' = 0
tempname factormat
local transform_count =0
forvalues s=1/``sum_combination'' {
local `factor_count' = 0
tempname display_name mat_name
foreach v of local factors {
local extra_name ""
forvalues g=1/2 {
cap confirm numeric variable `group'
if _rc !=0 {
qui sum `v' ``nif`s''' & `group' == "`group`g'value'"
}
else {
qui sum `v' ``nif`s''' & `group' == `group`g'value'
}
if r(mean) == . {
display as error "Missing values in group `group' with value `group`g'value'"
exit 322
}
local `v'_`g' = r(mean)
capture confirm variable `t_sum_`v''
if _rc == 0 {
sum `t_sum_`v'' ``nif`s''' & `group' == `group`g'value', meanonly
local `v'_`g' = ``v'_`g'' / r(mean)
local extra_name "(*)"
}
local `total_N' = ``total_N'' + r(N)
}
local ++`factor_count'
tempname factor_name``factor_count''
local `factor_name``factor_count''' `v'
local `display_name' "``display_name'' `v'`extra_name'"
if ``factor_count'' == 1 {
mat input `factormat' = (``v'_1', ``v'_2')
}
else {
mat `factormat' = (`factormat' \ ``v'_1', ``v'_2')
}
}
tempname total_combination
local `total_combination' = 2^``factor_count''
forvalues withheld_factor = 1/``factor_count''{
local q`withheld_factor' = 0
forvalues i=1/``total_combination''{
local res = `i' -1
local used_factor = 0
local from_group1 = 0
local from_group2 = 0
local from_group1offset = 0
local from_group2offset = 0
while (`res' !=0 | `used_factor' <``factor_count'') {
local ++used_factor
local resmod = mod(`res',2)
local ++from_group`=`resmod'+1'
local factor_value = `factormat'[`used_factor', `resmod'+1]
if `withheld_factor' == `used_factor' {
local withheld_group = `resmod' + 1
local ++from_group`=`resmod'+1'offset
}
local res = int(`res'/2)
tempname factor_value`used_factor'
local `factor_value`used_factor'' = `factor_value'
}
tempname c_rate rexpr newfunc
local `c_rate' = 1
local `newfunc' " `function' "
forvalues j=1/``factor_count'' {
local rexpr = "[^a-zA-Z0-9]" +"``factor_name`j'''" +"[^a-zA-Z0-9]"
local replaced = 0
while (regexm("``newfunc''", "`rexpr'") == 1) {
local sub1 = substr(regexs(0),1,1)
local sub2 = substr(regexs(0),-1,1)
local value_string "``factor_value`j'''"
local replace_string "`sub1'`value_string'`sub2'"
local `newfunc' = regexr("``newfunc''", "`rexpr'","`replace_string'")
local ++replaced
}
if `replaced' == 0 {
display "Factor ``factor_name`j''' is not used in the function"
exit 332
}
}
local `c_rate' =``newfunc''
local denominator =``factor_count''
forvalues j=1/`=`from_group2'- `from_group2offset'' {
if `j' < ``factor_count''{
local denominator = `denominator' * (``factor_count''-`j') / `j'
}
}
if `withheld_group' == 1 {
local denominator= - `denominator'
}
else {
if `from_group2' == 1 {
local direct_factor`withheld_factor' = ``c_rate''
}
}
local q`withheld_factor' = `q`withheld_factor'' + ``c_rate'' /`denominator'
}
}
tempname b total_diff
local total_rate1 = 1
local total_rate2 = 1
forvalues k=1/2{
forvalues i=1/``factor_count'' {
tempname factor_value`i'
local `factor_value`i'' = `factormat'[`i', `k']
}
tempname c_rate rexpr newfunc
local `c_rate' = 1
local `newfunc' " `function' "
forvalues j=1/``factor_count'' {
local rexpr = "[^a-zA-Z0-9]" +"``factor_name`j'''" +"[^a-zA-Z0-9]"
local replaced = 0
while (regexm("``newfunc''", "`rexpr'") == 1) {
local sub1 = substr(regexs(0),1,1)
local sub2 = substr(regexs(0),-1,1)
local value_string "``factor_value`j'''"
local replace_string "`sub1'`value_string'`sub2'"
local `newfunc' = regexr("``newfunc''", "`rexpr'","`replace_string'")
local ++replaced
}
if `replaced' == 0 {
display "Factor ``factor_name`j''' is not used in the function"
exit 332
}
local `c_rate' = ``c_rate'' * ``factor_value`j'''
}
local `c_rate' =``newfunc''
local total_rate`k' = ``c_rate''
}
local `total_diff' = `total_rate2'-`total_rate1'
tempname dfactor
forvalues i=1/``factor_count'' {
local diff = `q`i''
if `i' == 1 {
mat input `b' = (`diff')\
mat input `dfactor' = (`=`direct_factor`i''-`total_rate1'')
}
else {
mat `b' = (`b', `diff')
mat `dfactor' = (`dfactor', `=`direct_factor`i''-`total_rate1'')
}
}
matrix colname `dfactor' = ``display_name''
matrix colname `b' = ``display_name''
if `s' ==1 {
matrix `b_overall' = `b'
matrix colname `b_overall' = ``display_name''
}
else {
matrix `b_overall' = (`b_overall' \ `b')
}
if _rc != 0 {
}
local `s_res'= `s'
local `sum_cond' ""
forvalues c=1/`num_of_sums' {
local `factor_index' = mod(``s_res'', `sumvar_`c'_length') + 1
cap matrix `b_sumfactor_`c'_``factor_index''' = (`b_sumfactor_`c'_``factor_index'''\ `b')
if _rc != 0 {
tempname b_sumfactor_`c'_``factor_index''
matrix `b_sumfactor_`c'_``factor_index''' = `b'
matrix colname `b_sumfactor_`c'_``factor_index''' = `factors'
}
local `s_res' = int(``s_res''/`sumvar_`c'_length') + ``factor_index''
}
local `final_diff' = ``final_diff'' + ``total_diff''
local `final_rate1' = ``final_rate1'' + `total_rate1'
local `final_rate2' = ``final_rate2'' + `total_rate2'
}
mat `b' = J(1,``sum_combination'',1) * `b_overall'
forvalues c=1/`num_of_sums' {
tempname b_sumfactor_`c' next_one temp_mat
local n = 1
while (1) {
cap mat `next_one' = `b_sumfactor_`c'_`n''
if _rc != 0{
continue, break
}
local nrows rowsof(`next_one')
mat `temp_mat'= J(1,`nrows',1) * `next_one'
cap matrix `b_sumfactor_`c'' = (`b_sumfactor_`c'' \ `temp_mat')
if _rc != 0 {
matrix `b_sumfactor_`c'' = `temp_mat'
matrix colname `b_sumfactor_`c'' = ``display_name''
}
local ++n
}
mat rownames `b_sumfactor_`c'' = `sumvar_`c''
}
ereturn post `b' , obs(``total_N'')
ereturn matrix direct_b = `dfactor'
if "``original_sum''" != "" {
forvalues c=1/`num_of_sums' {
ereturn matrix sum_`c' = `b_sumfactor_`c''
}
}
if "`detail'" =="detail" {
ereturn scalar detail_view = 1
}
else {
ereturn scalar detail_view = 0
}
ereturn scalar diff = ``final_diff''
ereturn scalar rate1 = ``final_rate1''
ereturn scalar rate2 = ``final_rate2''
ereturn local sum_factor "``original_sum''"
ereturn local cmd "rdecompose"
ereturn local title "Decomposition using Generalised Gupta(1991) Method"
ereturn local group "`group'"
ereturn local basegroup_value "`group1value'"
ereturn local comparison_value "`group2value'"
local display_r1 = trim("`: display %18.2f ``final_rate1'''")
local display_r2 = trim("`: display %18.2f ``final_rate2'''")
ereturn local desc1 `"Decomposition between `group' == `group1value' (`display_r1')"'
ereturn local desc2 `"and `group' == `group2value' (`display_r2')"'
tempname overall_function
local `overall_function' ""
if "``original_sum''" !="" {
foreach v of local sum {
local `overall_function' "``overall_function''\sum(`v')"
}
local `overall_function' "``overall_function''{`function'}"
ereturn local overall_function "``overall_function''"
}
else {
ereturn local overall_function "`function'"
}
ereturn local transformed "`transform'"
ereturn local function "`function'"
rDisplay
end
/*------------------------------------------------ rDisplay */
program define rDisplay
local diopts "`options'"
local fmt "%12.3g"
local fmtprop "%8.2f"
tempname nfactor result_b result_prop factor_name result_df
mat `result_b' = e(b)
mat `result_df' = e(direct_b)
local `nfactor' = colsof(`result_b')
local colname: colnames `result_b'
tokenize `colname'
display
display as text e(desc1)
display as text %18s "" _c e(desc2) _newline
display as text "Func Form = `=e(overall_function)'"
display as txt "{hline 72}"
display as text %25s "Component" _c
display as text %28s "Absolute Difference" _c
display as text %18s "Proportion (%)"
display as txt "{hline 72}"
forvalues i = 1/ ``nfactor'' {
local direct_contr = `result_df'[1,`i']
local contribute = `result_b'[1,`i']
local prop = `contribute' / e(diff) * 100
local `factor_name' = abbrev("``i''", 15)
display as result %25s "``factor_name''" _c
display as result %28s `"`:display `fmt' `contribute' '"' _c
display as result %14s `"`:display `fmtprop' `prop' '"'
}
display as txt "{hline 72}"
local f =0
tempname factor_list subfactor_name
local factor_list = e(sum_factor)
if ("`factor_list'" != "." & e(detail_view) ==1) {
foreach sumfactor of local factor_list {
local ++f
local `factor_name' = abbrev("`sumfactor'", 10)
display as text %35s "Value of ``factor_name'' and Components" _c
display as text %32s "Detailed Contributions"
display as txt "{hline 72}"
matrix `result_b' = e(sum_`f')
local result_row = rowsof(`result_b')
forvalues j = 1/ `result_row' {
local rowname: rownames `result_b'
tokenize `rowname'
local group_name = abbrev("``j''", 13)
local colname: colnames `result_b'
tokenize `colname'
forvalues i = 1/ ``nfactor'' {
local contribute = `result_b'[`j',`i']
local prop = `contribute' / e(diff) * 100
local `subfactor_name' = abbrev("``i''", 15)
display as result %18s "`group_name' " _c
display as result %17s "``subfactor_name''" _c
display as result %18s `"`:display `fmt' `contribute' '"' _c
display as result %14s `"`:display `fmtprop' `prop' '"'
local group_name ""
}
}
display as txt "{hline 72}"
}
}
display as text %25s "Overall" _c
display as result %28s `"`:display `fmt' `=e(diff)' '"' _c
display as result %14s `"`:display `fmtprop' 100 '"'
display as txt "{hline 72}"
if "`=e(transformed)'" !="." {
display as text "{lalign 50:(*) indicates transformed variables}" _c
}
else {
display as text "{lalign 50:}" _c
}
display as text "{ralign 20:Number of Obs : `=e(N)'}"
end
