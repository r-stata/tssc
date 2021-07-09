*! version 2.0 February2019
*! author Ricardo Mora
program crtrees, eclass byable(recall)
version 11.0
quietly {
syntax varlist [if] [in] [aw fw iw pw],[ RFORests CLASSification GENerate(name)	BOOTstraps(integer 2147483647)	/// 
SEED(numlist max=1) STOP(integer  2147483647) REGressors(varlist) EXOGenous(varlist) noConstant		/// 
Level(cilevel) IMPurity(string) PRiors(string) Costs(string) Detail LSSize(real 0.5) TSample(name)	/// 
VCV(integer 2147483647) RULE(real 0) Tree ST_code RSPLITting(real 0.33) RSAMPLing(real 1) OOB		/// 
IJ SAVEtrees(string) ]
marksample touse
tempvar nueva vieja equi learn_smpl test_smpl residuos
tempname jUYYJ5Vnol coeficientes sigma sigma_ts ajustes _jUYYJ5Vnol criterios jUYYJ5Vnol_pod predicciones pred_errstd missprob ///
podas optimo b V rmse D Int tamano tamano_add tamano_new minmax secuencia clases b V
if "`classification'"=="" & "`rforests'"==""{
if "`impurity'"!="" {
                noi di as err "impurity() can only be used together with classification"
                error 1
}
if "`priors'"!="" {
                noi di as err "priors() can only be used together with classification"
                error 1
}
if "`costs'"!="" {
                noi di as err "costs() can only be used together with classification"
                error 1
}
}
if "`classification'"!="" & "`rforests'"=="" {
if "`regressors'"!="" {
                noi di as err "regressors() cannot be used together with classification"
                error 1
}
if "`exogenous'"!="" {
                noi di as err "exogenous() cannot be used together with classification"
                error 1
}
if "`noconstant'"!="" {
                noi di as err "noconstant cannot be used together with classification"
                error 1
}
if "`bootstraps'"!="2147483647" {
                noi di as err "bootstraps() cannot be used together with classification trees"
                error 1
}
}
if "`rforests'"!="" {
if "`tssample'"!="" {
                noi di as err "tssample() cannot be used together with rforests"
                error 1
}
if "`tree'"!="" {
                noi di as err "tree cannot be used together with rforests"
                error 1
}
if "`detail'"!="" {
                noi di as err "detail cannot be used together with rforests"
                error 1
}
}
if "`rforests'"=="" {
if "`oob'"!="" {
                noi di as err "oob can only be used together with rforests"
                error 1
}
if "`ij'"!="" {
                noi di as err "ij can only be used together with rforests"
                error 1
}
if "`savetrees'"!="" {
                noi di as err "savetrees can only be used together with rforests"
                error 1
}
}
if "`classification'"=="" & "`rforests'"!="" {
if "`oob'"!="" {
                noi di as err "oob can only be used together with classification"
                error 1
}
}
if "`classification'"!="" & "`rforests'"!="" {
if "`ij'"!="" {
                noi di as err "ij cannot be used together with classification"
                error 1
}
}
gettoken depvar splvar : varlist
local splvar =  strltrim("`splvar'")
local regvar = "`regressors'"
local insvar = "`exogenous'"
capture confirm numeric `depvar'
                if _rc==7 {
        	noi di as err "`depvar' must be numeric"
                error 1
   		}
if "`classification'"!="" {
capture confirm numeric variable `depvar'
                if _rc==7 {
        	noi di as err "`depvar' must be discrete"
                error 1
   		}
capture confirm byte variable `depvar'
                if _rc==7 {
capture confirm int variable `depvar'
        	        if _rc==7 {
capture confirm long variable `depvar'
                if _rc==7 {
        	noi di as err "`depvar' must be discrete"
                error 1
   			}
   		}
   		}
}
if "`splvar'"!=""{
foreach v of varlist `splvar'    {
capture confirm numeric `v'
                if _rc==7 {
        	noi di as err "splitting variable `v' must be numeric"
error 1
   			}
}
}
if "`regvar'"!=""{
foreach v of varlist `regvar'    {
capture confirm numeric `v'
                if _rc==7 {
        	noi di as err "regressor `v' must be numeric"
error 1
   			}
}
}
if "`insvar'"!=""{
foreach v of varlist `insvar'    {
capture confirm numeric `v'
                if _rc==7 {
        	noi di as err "instrument `v' must be numeric"
                error 1
   			}
}
}
local k=wordcount("`regvar'")+("`constant'"!="noconstant")
if "`generate'"!= "" {
  ds
  local all_v=r(varlist)
  foreach v of varlist `all_v'    {
if "`v'"=="`generate'" {
  noi di _newline as error `" "`generate'" already defined in current dataset"'
  error 1
}
        if "`rforests'"!="" &  "`classification'"=="" {
  if "`v'"=="`generate'_se" {
   noi di _newline as error `" "`generate'_se" already defined in current dataset"'
   error 1
  }
        }
        if "`rforests'"!="" &  "`classification'"!="" {
  if "`v'"=="`generate'_pm" {
   noi di _newline as error `" "`generate'_pm" already defined in current dataset"'
   error 1
  }
        }
  }
}
if "`rforests'"!="" {
if "`generate'"=="" {
                noi di as err "option generate() is required with rforests"
                error 1
}
}
if "`st_code'"!="" & "`rforests'"==""{
if "`generate'"=="" {
                noi di as err "option generate() is required with st_code"
                error 1
}
}
if "`rforests'"!= "" & "`bootstraps'"=="2147483647" local bootstraps=1000
if "`bootstraps'"!="2147483647" & "`vcv'"!="2147483647" local vcv=2147483647
if (`bootstraps'<0 ) | (`bootstraps'>2147483647) {
                noi di as err "<boostraps> must be between 0 and 2^31-1 (or 2,147,483,647)"
                error 1
}
if "`seed'"!="" {
if (`seed'<0 ) | (`seed'>2147483647) {
                noi di as err "<seed> must be between 0 and 2^31-1 (or 2,147,483,647)"
                error 1
}
set seed `seed'
}
if (`stop'<=`k') {
                  noi di _newline as error "stop rule must be greater than # coefficients for each terminal model"
  error 1
                }
if (`stop'==2147483647) {
local stop=`k'+1
}
if "`bootstraps'"=="2147483647" & "`vcv'"=="2147483647"{
if (`lssize'>=1 | `lssize'<=0) {
noi di as error "<lssize> must belong to the unit interval"
error 1
}
gen `learn_smpl'=(uniform()<=`lssize')*`touse'
gen `test_smpl'=(`learn_smpl'==0)*(`touse'==1)
count if `learn_smpl'
local N_ls=r(N)
count if `test_smpl'
local N_ts=r(N)
if (`N_ls'<=`k') {
                  noi di _newline as error "learning sample is too small"
  error 1
}
}
if "`tsample'"!= "" {
  ds
  local all_v=r(varlist)
  foreach v of varlist `all_v'    {
if "`v'"=="`tsample'" {
  noi di _newline as error `" "`tsample'" already defined in current dataset"'
  error 1
}
  }
  gen `tsample'=`test_smpl'
}
if "`bootstraps'"!="2147483647" | "`vcv'"!="2147483647" { 
gen `learn_smpl'=`touse'
gen `test_smpl'=`touse'
count if `learn_smpl'
local N_ls=r(N)
local N_ts=r(N)
if "`tsample'"!= "" {
                  noi di _newline as error "you cannot use <tsample> with <bootstrap> or <vcv>"
  error 1
}
}
if "`vcv'"!="2147483647" {				// vcv must be integer in (0,100)
if ((`vcv'<=0) | (`vcv'>=100)) {
        	noi di as err "<vcv> must be between 0 and 100"
                error 1
}
}
if (`rule'<0) {
          	  noi di _newline as error "rule for honest tree must be a positive real number"
  error 1
        }
if ("`classification'"=="") {
if ("`regvar'"=="" | "`bootstraps'"!="2147483647" | "`vcv'"!="2147483647") {
                  	if "`detail'"!="" {
local detail=""
}
                  }
}
if ("`classification'"!="") {
 preserve
 tab `depvar' if `touse', generate(`D')
 local nc=r(r)
 if ("`priors'"=="") {
tempname priors
matrix `priors'=J(`nc',1,0)
forvalues lnum=1/`nc'  {
 su `D'`lnum' if `learn_smpl'
 matrix `priors'[`lnum',1]=r(mean)
}
 }
 restore
 confirm matrix `priors'
 if rowsof(`priors')!=`nc' {
        	noi di as err "rows in `priors' not equal to number of classes"
                error 1
 }
 if ("`costs'"=="") {
tempname costs
matrix `costs'=J(`nc',`nc',1)-I(`nc')
 }
 confirm matrix `costs'
 if (rowsof(`costs')!=`nc' | colsof(`costs')!=`nc') {
        	noi di as err "rows or columns in `costs' not equal to number of classes"
                error 1
 }
 tab `depvar' if `learn_smpl'
 if (`nc'!=r(r)) {
        	noi di as err "not all classes in learning sample"
                error 1
 }
}
local impurity=strlower("`impurity'")
if "`classification'"!="" {
  if ("`impurity'"=="") {
local impurity="gini"
  }
  if ("`impurity'"!="Gini" & "`impurity'"!="Entropy" & "`impurity'"!="gini" & "`impurity'"!="entropy")  {
                  	noi di _newline as error `"<impurity> must be either "gini" or "entropy""'
  	error 1
                  }
  if ("`impurity'"=="Gini") local impurity="gini"
  if ("`impurity'"=="Entropy") local impurity="entropy"
}
if ("`regvar'" == "" & "`constant'"=="noconstant") {
                  noi di _newline as error "<noconstant> not allowed because the model has no regressors"
  error 1
                }
if ("`regvar'" == "" & "`insvar'"!="") {
                  noi di _newline as error "there cannot be exogenous variables without regressors."
                  error 1
                }
if (wordcount("`regvar'")>wordcount("`insvar'") & "`insvar'" != "") {
 noi di _newline as error "there must be at least as many exogenous variables as regressors."		
 error 1
}
if "`rforests'"!="" {
if ((`rsplitting'<=0) | (`rsplitting'>=1)) {
        	noi di as err "<rsplitting> must be between 0 and 1"
                error 1
}
if ((`rsampling'<=0) | (`rsampling'>1)) {
        	noi di as err "<rsampling> must be between 0 and 1"
                error 1
}
if "`savetrees'"=="" local savetrees="matatrees"
}
if ("`rforests'"!="") {
if ("`classification'" == "") {
noi dis _newline as txt "Random Forests: Regression"
noi dis as txt "Bootstrap replications (" in y `bootstraps' as txt ")" _continue
noi dis _newline in g "{hline 4}{c +}{hline 2} 100 {hline 2}{c +}{hline 2} " _continue 
noi dis in g "200 {hline 2}{c +}{hline 2} 300 {hline 2}{c +}{hline 2} 400 {hline 2}{c +}{hline 1} 500"
noi mata: _NfHW4APu("`depvar'", "`splvar'","`regvar'", "`touse'","`constant'",`stop',	///
`bootstraps',`rsampling',`rsplitting',"`ij'","`predicciones'","`pred_errstd'", ///
"`savetrees'")
}
if ("`classification'" != "") {
noi dis _newline as txt "Random Forests: Classification"
noi dis as txt "Bootstrap replications (" in y `bootstraps' as txt ")" _continue
noi dis _newline in g "{hline 4}{c +}{hline 2} 100 {hline 2}{c +}{hline 2} " _continue 
noi dis in g "200 {hline 2}{c +}{hline 2} 300 {hline 2}{c +}{hline 2} 400 {hline 2}{c +}{hline 1} 500"
noi mata: _PKzTnqtq("`depvar'","`splvar'","`touse'",`stop',"`impurity'","`priors'",	///
"`costs'",`bootstraps',`rsampling',`rsplitting',"`oob'","`predicciones'",	///
"`missprob'","`savetrees'","`clases'")

}
}
else if ("`classification'" == "") {
if "`vcv'"!="2147483647"  local message "with V-fold Cross Validation"
else if "`bootstraps'"!="2147483647" local message "with Bootstrap"
else local message "with learning and test samples"
noi dis _newline as txt "Regression Trees `message' (SE rule: `rule')"
if "`bootstraps'"!="2147483647" {
noi dis as txt "Bootstrap replications (" in y `bootstraps' as txt ")" _continue
noi dis _newline in g "{hline 4}{c +}{hline 2} 100 {hline 2}{c +}{hline 2} " _continue 
noi dis in g "200 {hline 2}{c +}{hline 2} 300 {hline 2}{c +}{hline 2} 400 {hline 2}{c +}{hline 1} 500"
}
noi mata: _XnT5Yf8A("`depvar'", "`splvar'","`regvar'", "`insvar'",		///
"`touse'","`learn_smpl'","`test_smpl'", "`constant'",`stop',`rule', ///
`bootstraps',`vcv',"`jUYYJ5Vnol'","`coeficientes'","`sigma'","`sigma_ts'",	///
"`ajustes'","`criterios'","`predicciones'","`minmax'","`podas'","`secuencia'")
}
else {
if "`vcv'"!="2147483647"  local message "with V-fold Cross Validation"
else local message "with learning and test samples"
noi dis _newline as txt "Classification Trees `message' (SE rule: `rule')"
noi mata: _REAj4BLL("`depvar'","`splvar'","`touse'","`learn_smpl'","`test_smpl'",	///
`stop',`rule',"`impurity'","`priors'","`costs'",`vcv',		///
"`jUYYJ5Vnol'","`coeficientes'","`ajustes'","`criterios'","`predicciones'",	///
"`minmax'","`podas'","`secuencia'","`clases'")
 	}
if ("`rforests'" == "") {
mat colnames `jUYYJ5Vnol' = Node Child_1 Split_var Cut_off
local lista = "Node "
if "`splvar'"!="" {
foreach v of varlist `splvar' {
local lista = "`lista' `v'_min `v'_max "
}
}
mat colnames `criterios' = `lista'
mat colnames `minmax' = `lista'
local lista = " T_MAX "
local k = colsof(`secuencia')-1
        forvalues i = 1/`k' {
local lista = "`lista' T_`i' "
        }
mat colnames `secuencia' = `lista'
local lista = " Node:1 "
local k = rowsof(`secuencia')
        forvalues i = 2/`k' {
local lista = "`lista' `i' "
        }
mat rownames `secuencia' = `lista'
if "`vcv'"!="2147483647" local lista = "|T| R R^cv SE(R^cv)"
else if "`bootstraps'"!="2147483647" local lista = "|T| R SE(R^b)"
else local lista = "|T| R^ls R^ts SE(R^ts)"
mat colnames `ajustes' = `lista'
mat colnames `podas' = `lista'
local lista = "rule=0 rule=`rule'"
mat rownames `ajustes' = `lista'
local k = rowsof(`podas')-1
local lista = ""
        forvalues i = `k'(-1)1 {
local lista = "`lista' T_`i' "
        }
local lista = "`lista' T_MAX"
mat rownames `podas' = `lista'
if ("`classification'" == "") {
local lista = "Node avg rmse_ls rmse_ts noobs R2 `regvar'"
if ("`constant'"!="noconstant") local lista = "`lista' _const"
mat colnames `coeficientes' = `lista'
mat define `_jUYYJ5Vnol'=`criterios'
su `depvar' if `learn_smpl'
local k=(colsof(`coeficientes')-6)*rowsof(`coeficientes')
local avg_ls=r(mean)
local TSS=(r(N)-1)*r(Var)
local R2_ls=1-(`ajustes'[2,2]/(`TSS'/r(N)))
local rmse_ls=sqrt(`ajustes'[2,2]*(`N_ls')/(`N_ls'-`k'))
su `depvar' if `test_smpl'
local avg_ts=r(mean)
local TSS=(r(N)-1)*r(Var)
local R2_ts=1-(`ajustes'[2,3]/(`TSS'/r(N)))
local rmse_ts=sqrt(`ajustes'[2,3]*(`N_ls')/(`N_ls'-`k'))
local complejidad=rowsof(`criterios')
if "`vcv'"!="2147483647"  noi dis _newline as txt "Sample" _col(56) "V-fold cross validation"
else if "`bootstraps'"!="2147483647" noi dis _newline 
else noi dis _newline as txt "Learning Sample" _col(52) "Test Sample" 
noi dis as txt "|T*|          = " as result %-9.0f = `ajustes'[2,1] 
noi dis as txt "Number of obs = " as result %-9.0f = `N_ls' _continue
if "`vcv'"!="2147483647"  noi dis _col(52) as txt "V-fold c.v.     = " as result %9.0f = `vcv' _continue
else if "`bootstraps'"!="2147483647" noi dis _newline as txt "No bootstraps = " as result %-9.0f = `bootstraps' _continue
else noi dis _col(52) as txt "Number of obs   = " as result %9.0f = `N_ts' _continue
noi dis _newline as txt "R-squared     = " as result %-9.4f = `R2_ls'  _continue
if "`bootstraps'"=="2147483647" noi dis _col(52) as txt "R-squared       = " as result %9.4f = `R2_ts' _continue
noi dis _newline as txt "Avg Dep Var   = " as result %-9.3f = `avg_ls' _continue
if "`bootstraps'"=="2147483647" & "`vcv'"=="2147483647" ///
noi dis _col(52) as txt "Avg Dep Var     = " as result %9.3f = `avg_ts' _continue
noi dis _newline  as txt "Root MSE      = " as result %-9.3f = `rmse_ls' _continue
if "`bootstraps'"=="2147483647" noi dis _col(52) as txt "Root MSE        = " as result %9.3f = `rmse_ts'
else noi dis _newline
if "`tree'"=="tree" {
noi dis _newline
noi dis as txt "Text representation of tree:"
 local nonodes=rowsof(`jUYYJ5Vnol')
 forvalues lnum=1/`nonodes'  {
local sQaqMexR=`jUYYJ5Vnol'[`lnum',1]
local hijo1=`jUYYJ5Vnol'[`lnum',2]
local hijo2=`jUYYJ5Vnol'[`lnum',2]+1
local criterio=`jUYYJ5Vnol'[`lnum',4]
if `jUYYJ5Vnol'[`lnum',2]!=0 noi dis as txt "At node " in y "`sQaqMexR'" as txt " if " 	///
in y word("`splvar'",`jUYYJ5Vnol'[`lnum',3]) ///
as txt " <= " in y "`criterio'" as txt " go to node " in y "`hijo1'" 		///
as txt " else go to node " in y "`hijo2'"
 }
}
 	 noi dis _newline as txt "Terminal node results:" _newline
 local i=1
 local k=1
 local nt=rowsof(`criterios')
 forvalues i=1/`nt' {
 	noi dis _newline as txt "Node " in y string(`criterios'[`i',1]) as txt ": " 
noi dis _col(5) as txt " Characteristics:"
 	local k=1
 	foreach v of varlist `splvar'  {
 		local columna=1+(`k'-1)*2+1
local inferior=`criterios'[`i',`columna']
local superior=`criterios'[`i',`columna'+1]
local infroot=`minmax'[1,`columna']
local suproot=`minmax'[1,`columna'+1]
if `inferior'!=`superior' & (`inferior'!=`infroot' | `superior'!=`suproot') {
local mensaje= string(`criterios'[`i',`columna']) + ///
"<=`v'<=" + string(`criterios'[`i',`columna'+1]) 
noi dis _col(9) as txt "`mensaje'"
}
if `inferior'==`superior' & (`inferior'!=`infroot' | `superior'!=`suproot') {
 		local mensaje= "`v'==" + string(`criterios'[`i',`columna'+1])
noi dis _col(9) as txt "`mensaje'"
}
 		local k=`k'+1
 	}
noi dis _col(51) as txt " Number of obs   = " as result %9.0f = `coeficientes'[`i',5]
if ("`regvar'"!="") noi dis _col(51) as txt " R-squared       = " as result %9.4f = `coeficientes'[`i',6]
 matrix define `b'=`coeficientes'[`i',7..colsof(`coeficientes')]
 if ("`bootstraps'"=="2147483647" & "`vcv'"=="2147483647") {
 mat `V'=`sigma_ts'[`i',1..colsof(`sigma_ts')]'
 mata: st_matrix(`"`V'"',invvech(st_matrix("`V'")))
 }
 if ("`bootstraps'"!="2147483647" | "`vcv'"!="2147483647") mat `V'=J(colsof(`b'),colsof(`b'),0)
 local lista: colnames `b'
 mat colnames `V' = `lista'
 mat rownames `V' = `lista'
 ereturn post `b' `V', depname(`depvar') 
 	 noi ereturn display, level(`level')
noi dis _newline
 	local i=`i'+1
 }
if "`stcode'"=="st_code" {
 noi dis _newline as txt "// Stata code to generate predictions" 
 noi dis as txt "generate `generate'=."
 local i=1
 local k=1
 forvalues i=1/`nt' {	
   local codigo="replace `generate'="
   local j=7
   if ("`regvar'"!="") {
foreach v of varlist `regvar'  {
if (`j'>7) {
if (abs(`coeficientes'[`i',`j'])==(`coeficientes'[`i',`j'])) local codigo="`codigo' + "
else local codigo="`codigo' - "
local valor=abs(`coeficientes'[`i',`j'])
local codigo="`codigo' `valor'*`v'"
}
else {
local valor=`coeficientes'[`i',`j']
local codigo="`codigo' `valor'*`v'"
}
local j=`j'+1	
}
   }
   if "`constant'"!="noconstant" {	
if (`j'>7) {
if (abs(`coeficientes'[`i',`j'])==(`coeficientes'[`i',`j'])) local codigo="`codigo' + "
else local codigo="`codigo' - "
local valor=abs(`coeficientes'[`i',`j'])
local codigo="`codigo' `valor'"
}
else {
local valor=`coeficientes'[`i',`j']
local codigo="`codigo' `valor'"
}
local j=`j'+1	
   }
   local codigo="`codigo' if "
   local k=1
   foreach v of varlist `splvar'  {
if "`k'"!="1" local codigo="`codigo' & "
  	 		local columna=1+(`k'-1)*2+1
local inferior=`criterios'[`i',`columna']
local superior=`criterios'[`i',`columna'+1]
   			local codigo="`codigo' `inferior'<=`v'"
   			local codigo="`codigo' & `v'<=`superior'"
 		local k=`k'+1
 }
 noi dis as txt "`codigo'"
 noi dis "// end of Stata code to generate predictions"
}
}
if "`generate'"!= "" gen `generate'=`predicciones'
 ereturn clear
 ereturn post , esample(`touse')
 if ("`constant'"=="noconstant") ereturn local noconstant "`constant'"        
 if "`regvar'"!="" ereturn local regvar "`regvar'"        
 ereturn local splvar "`splvar'"
 ereturn local depvar "`depvar'"
 ereturn scalar T =`complejidad'
 if "`bootstraps'"=="2147483647" & "`vcv'"=="2147483647" ereturn matrix Vs = `sigma'
 ereturn matrix coefficients = `coeficientes'
 ereturn matrix criteria = `criterios'
 ereturn matrix tree = `jUYYJ5Vnol'
 ereturn matrix R_T_j = `podas'
 ereturn matrix T_j = `secuencia'
 if "`bootstraps'"!="2147483647" {
 ereturn scalar B =`bootstraps'
 	 	 ereturn scalar N =`N_ls'
 ereturn scalar r2 = `R2_ls'
 ereturn local algorithm "CART: Regression with Bootstrap"
 }
 else if "`vcv'"!="2147483647" {
 ereturn scalar vcv =`vcv'
 ereturn scalar N =`N_ls'
 ereturn scalar r2 = `R2_ls'
 ereturn scalar r2_cv = `R2_ts'
 ereturn local algorithm "CART: Regression with V-fold Cross Validation"
 }
 else {
 ereturn scalar lssize =`lssize'
 ereturn scalar N_ls =`N_ls'
 ereturn scalar N_ts =`N_ts'
 ereturn scalar r2_ls = `R2_ls'
 ereturn scalar r2_ts = `R2_ts'
 ereturn local algorithm "CART: Regression with Learning and Test Sample"
 }
 ereturn local  predict "crtrees_p"
 ereturn local cmd "crtrees"
}
if ("`classification'" != "") {
local lista = "Node Class* r(t) Noobs"
local k = colsof(`clases')
        forvalues i = 1/`k' {
local clase=`clases'[1,`i']
local lista = "`lista' Pr_`clase' "
        }
mat colnames `coeficientes'=`lista'
mat define `_jUYYJ5Vnol'=`criterios'
noi dis _newline as txt "Impurity measure: " as txt strproper("`impurity'")
if "`vcv'"!="2147483647"  noi dis _newline as txt "Sample" _col(56) "V-fold cross validation"
else noi dis _newline as txt "Learning Sample" _col(52) "Test Sample" 
noi dis as txt "Number of obs = " as result %-9.0f = `N_ls' _continue
if "`vcv'"!="2147483647"  noi dis _col(52) as txt "V               = " as result %9.0f = `vcv' _continue
else noi dis _col(52) as txt "Number of obs  = " as result %9.0f = `N_ts' _continue
noi dis _newline as txt "|T*|          = " as result %-9.0f = `ajustes'[2,1] _continue
noi dis _newline as txt "R(T*)         = " as result %-9.4f = `ajustes'[2,2]  _continue
noi dis _col(52) as txt "R(T*)           = " as result %9.4f = `ajustes'[2,3] _continue
noi dis _newline _col(52) as txt "SE(R(T*))       = " as result %9.4f = `ajustes'[2,4] _continue
if "`tree'"=="tree" {
noi dis _newline as txt "Text representation of tree:"
 local nonodes=rowsof(`jUYYJ5Vnol')
 forvalues lnum=1/`nonodes'  {
local sQaqMexR=`jUYYJ5Vnol'[`lnum',1]
local hijo1=`jUYYJ5Vnol'[`lnum',2]
local hijo2=`jUYYJ5Vnol'[`lnum',2]+1
local criterio=`jUYYJ5Vnol'[`lnum',4]
if `jUYYJ5Vnol'[`lnum',2]!=0 noi dis as txt "At node " in y "`sQaqMexR'" as txt " if " 	///
in y word("`splvar'",`jUYYJ5Vnol'[`lnum',3]) ///
as txt " <= " in y "`criterio'" as txt " go to node " in y "`hijo1'" 		///
as txt " else go to node " in y "`hijo2'"
 }
}
 	 noi dis _newline as txt "Terminal node results:"
 local i=1
 local k=1
 local nt=rowsof(`criterios')
 forvalues i=1/`nt' {
 	noi dis as txt "Node " in y string(`criterios'[`i',1]) as txt ": " 
noi dis _col(5) as txt " Characteristics:"
 	local k=1
 	foreach v of varlist `splvar'  {
 		local columna=1+(`k'-1)*2+1
local inferior=`criterios'[`i',`columna']
local superior=`criterios'[`i',`columna'+1]
local infroot=`minmax'[1,`columna']
local suproot=`minmax'[1,`columna'+1]
if `inferior'!=`superior' & (`inferior'!=`infroot' | `superior'!=`suproot') {
local mensaje= string(`criterios'[`i',`columna']) + ///
"<=`v'<=" + string(`criterios'[`i',`columna'+1]) 
noi dis _col(9) as txt "`mensaje'"
}
if `inferior'==`superior' & (`inferior'!=`infroot' | `superior'!=`suproot') {
 		local mensaje= "`v'==" + string(`criterios'[`i',`columna'+1])
noi dis _col(9) as txt "`mensaje'"
}

 		local k=`k'+1
 	}
noi dis _col(5) as txt " Class predictor = " as result %9.0f = `coeficientes'[`i',2]
noi dis _col(5) as txt " r(t)            = " as result %9.3f = `coeficientes'[`i',3]
noi dis _col(5) as txt " Number of obs   = " as result %9.0f = `coeficientes'[`i',4]
if "`detail'"=="detail" {				// resultados detallados
local k = colsof(`clases')+4
forvalues j=5/`k' {
local valor=`clases'[1,`j'-4]
noi dis _col(5) as txt " Pr(`depvar'=`valor')   = " as result %9.3f `coeficientes'[`i',`j']
}
}
noi dis _newline
 	local i=`i'+1
 }
if "`st_code'"=="st_code" {
noi dis _newline as txt "// Stata code to generate predictions" 
noi dis as txt "generate `generate'=."
local i=1
forvalues i=1/`nt' {	
   local valor=`coeficientes'[`i',2]	
   local codigo="replace `generate'=`valor' if "
   local k=1
   foreach v of varlist `splvar'  {
if "`k'"!="1" local codigo="`codigo' & "
  	 		local columna=1+(`k'-1)*2+1
local inferior=`criterios'[`i',`columna']
local superior=`criterios'[`i',`columna'+1]
   			local codigo="`codigo' `inferior'<=`v'"
   			local codigo="`codigo' & `v'<=`superior'"
 		local k=`k'+1
   }
  noi dis as txt "`codigo'"
  local i=`i'+1
}
noi dis "// end of Stata code to generate predictions"
}
if "`generate'"!= "" gen `generate'=`predicciones'
 ereturn clear
 ereturn post , esample(`touse')
 ereturn local splvar "`splvar'"
 ereturn local depvar "`depvar'"
 ereturn matrix coefficients = `coeficientes'
 ereturn matrix criteria = `criterios'
 ereturn matrix tree = `jUYYJ5Vnol'
 ereturn matrix R_T_j = `podas'
 ereturn matrix T_j = `secuencia'
 ereturn matrix classes = `clases'
 ereturn scalar T =`ajustes'[2,1]
 if "`vcv'"!="2147483647" {
 ereturn scalar vcv =`vcv'
 ereturn scalar N =`N_ls'
 ereturn scalar R_T = `ajustes'[2,2]
 ereturn scalar R_T_cv = `ajustes'[2,3]
 ereturn scalar SE_R_cv = `ajustes'[2,4]
 ereturn local algorithm "CART: Classification with V-fold Cross Validation"
 }
 else {
 ereturn scalar lssize =`lssize'
 ereturn scalar N_ls =`N_ls'
 ereturn scalar R_T_ls = `ajustes'[2,2]
 ereturn scalar N_ts =`N_ts'
 ereturn scalar R_T_ts = `ajustes'[2,3]
 ereturn scalar SE_R_ts = `ajustes'[2,4]
 ereturn local algorithm "CART: Classification with Learning and Test Sample"
 }
ereturn local  predict "crtrees_p"
ereturn local cmd "crtrees"
}
}

else {
gen `generate'=`predicciones'
if ("`classification'" == "") {
gen `generate'_se=`pred_errstd'
noi dis _newline as txt "Dep. Variable = " as result "`depvar'"
if strlen("`splvar'")>49 noi dis as txt "Splitting variables = " as result word("`splvar'",1) " " ///
as result word("`splvar'",2) as txt "..."
else noi dis as txt "Splitting Variables = " as result "`splvar'"
if "`regvar'"!="" { 
if strlen("`regvar'")>49 noi dis as txt "Regressors = " as result word("`regvar'",1) " " ///
as result word("`regvar'",2) as txt "..."
else noi dis as txt "Regressors  = " as result "`regvar'"
}
su `depvar' if `learn_smpl'
local TSS=(r(N)-1)*r(Var)
noi dis as txt "B bootstraps  = " as result %-9.0f = `bootstraps'
noi dis  _col(44) as txt "Number of obs    =" as result %10.0f = 	r(N)
su `generate' if `learn_smpl'
local ESS=(r(N)-1)*r(Var)
local R2=`ESS'/`TSS'
gen `residuos'=`depvar'-`generate'
su `residuos' if `learn_smpl'
local RSS=(r(N)-1)*r(Var)
noi dis _col(44) as txt "R-squared        =" as result %10.4f = `R2'
noi dis _col(44) as txt "Model root SS    =" as result %10.2g = sqrt(`ESS')
noi dis _col(44) as txt "Residual root SS =" as result %10.2g = sqrt(`RSS')
noi dis _col(44) as txt "Total root SS    =" as result %10.2g = sqrt(`TSS')
noi su `generate'* if `learn_smpl'
if "`ij'"!="" noi dis _newline as txt "Infinitessimal Jacknife Standard Errors"
else noi dis _newline as txt "Jacknife-after-Bootstrap Standard Errors"
 ereturn clear
 ereturn post , esample(`touse')
 		 if ("`constant'"=="noconstant") ereturn local noconstant "`constant'"        
 if "`regvar'"!="" ereturn local regvar "`regvar'"        
 ereturn local splvar "`splvar'"
 ereturn local depvar "`depvar'"
 ereturn scalar B =`bootstraps'
 ereturn scalar N =r(N)
 ereturn scalar R2 = `R2'
 ereturn local algorithm "Random Forest: Regression"
 ereturn local matatrees "`savetrees'"
 ereturn local  predict "crtrees_p"
 ereturn local cmd "crtrees"
}
if ("`classification'" != "") {
gen `generate'_mp=`missprob'
noi dis _newline as txt "Dep. Variable = " as result "`depvar'"
if strlen("`splvar'")>49 noi dis as txt "Splitting variables = " as result word("`splvar'",1) " " ///
as result word("`splvar'",2) as txt "..."
else noi dis as txt "Splitting Variables = " as result "`splvar'"
su `generate'_mp if `learn_smpl'
local N = r(N)
local Cost = r(mean)
noi dis as txt "B bootstraps  = " as result %-9.0f = `bootstraps' _col(44) ///
as txt "Number of obs    =" as result %10.0f = `N'
noi dis _col(44) as txt "Missclass. cost  =" as result %10.4f = `Cost'
noi tab `depvar' `generate' if `learn_smpl', nol
if "`oob'"!="" noi dis _newline as txt "Out-of-bag misclassification costs"
 ereturn clear
 ereturn post , esample(`touse')
 ereturn local splvar "`splvar'"
 ereturn local depvar "`depvar'"
 ereturn matrix classes = `clases'
 ereturn scalar B =`bootstraps'
 ereturn scalar N =`N'
 ereturn scalar Cost = `Cost'
 ereturn local algorithm "Random Forest: Classification"
 ereturn local matatrees "`savetrees'"
 ereturn local  predict "crtrees_p"
 ereturn local cmd "crtrees"

}
}
}
end

mata
mata set matastrict on

                void _5MmwTVMH(numeric matrix jUYYJ5Vn1, numeric matrix jUYYJ5Vn3, numeric matrix xs, numeric matrix equi, ///
numeric matrix sQaqMexR,numeric matrix criterios) 
        {
        real matrix jUYYJ5Vn1_s,jUYYJ5Vn3_s,xs_sQaqMexR,jUYYJ5Vn3_sQaqMexR,carac
real scalar ra,j,k,i,columna
jUYYJ5Vn1_s=select(jUYYJ5Vn1,jUYYJ5Vn1[.,2]:==0)	
jUYYJ5Vn3_s=select(jUYYJ5Vn3,jUYYJ5Vn1[.,2]:==0)	
ra = rows(jUYYJ5Vn1_s)
k=cols(xs)
for (j=1; j<=ra; j++) {
xs_sQaqMexR=select(xs,sQaqMexR[.,1]:==jUYYJ5Vn1_s[j,1])
jUYYJ5Vn3_sQaqMexR=jUYYJ5Vn3_s[j,.]
jUYYJ5Vn3_sQaqMexR=colshape(jUYYJ5Vn3_sQaqMexR,2)'
carac=rowshape((colmin(xs_sQaqMexR\jUYYJ5Vn3_sQaqMexR[1,.])\colmax(xs_sQaqMexR\jUYYJ5Vn3_sQaqMexR[2,.]))',1)
for (i=1; i<=k; i++) {		
columna=(i-1)*2+1
equi_col=select(equi[.,columna::columna+1],equi[.,columna]:!=.)
carac[1,columna]=equi_col[carac[1,columna],1]
carac[1,columna+1]=equi_col[carac[1,columna+1],1]
}
criterios=(j==1? rowshape(carac',1) : criterios\rowshape(carac',1))
}
criterios=jUYYJ5Vn1_s[.,1],criterios
}
                void _kuVUVxcx(numeric matrix jUYYJ5Vn1, numeric matrix jUYYJ5Vn3, numeric matrix xs,numeric vector sQaqMexR) 
        {
        real matrix jUYYJ5Vn1_s, jUYYJ5Vn3_s, carac
real scalar ra,j,rn,i
sQaqMexR = J(rows(xs),2,0)
jUYYJ5Vn3_s=select(jUYYJ5Vn3,jUYYJ5Vn1[.,2]:==0)
jUYYJ5Vn1_s=select(jUYYJ5Vn1,jUYYJ5Vn1[.,2]:==0)
ra = rows(jUYYJ5Vn1_s)
for (j=1; j<=ra; j++) {
carac=colshape(jUYYJ5Vn3_s[j,.],2)'         	
sQaqMexR[.,1]=sQaqMexR[.,1]+jUYYJ5Vn1_s[j,1]*rowmin((xs:>=carac[1,.]):*(xs:<=carac[2,.]))
}
rn=rows(sQaqMexR)
for (i=1; i<=rn; i++) {
if (sQaqMexR[i,1] == 0) {
j=1
while (j!=0) {		
if (jUYYJ5Vn1[j,2]==0) {                  
sQaqMexR[i,1]=jUYYJ5Vn1[j,1]
sQaqMexR[i,2]=1
j=0
}
else {
if (xs[i,jUYYJ5Vn1[j,3]]<=jUYYJ5Vn1[j,4]) j=jUYYJ5Vn1[j,2]    
else j=jUYYJ5Vn1[j,2]+1				
}
}
}
}
}	

     	void _pau8gNYG(numeric vector WpW, numeric scalar no, numeric scalar Yp1, numeric matrix tipo,	///
string scalar con, numeric scalar ssq, numeric vector coef, numeric vector mana) 
        {
        real matrix XpX,XpZ,ZpZ,ZpZi,XZXi,XpXi
real vector XpY,ZpY,beta
real scalar k,YpY,MSS,rr
WpW = invvech(WpW)
k=tipo[2,2]-tipo[1,2]+1					
        if (tipo[1,3]!=0) {					
   YpY = WpW[1,1]
   XpY = WpW[2::1+k,1]
   XpX = WpW[2::1+k,2::1+k]
   XpZ = WpW[2::1+k,2+k::cols(WpW)]
   ZpZ = WpW[2+k::rows(WpW),2+k::cols(WpW)]
   ZpZi= invsym(ZpZ)
   ZpY = WpW[2+k::rows(WpW),1]
   XZXi=invsym(XpZ*ZpZi*XpZ')
   beta=XZXi*XpZ*ZpZi*ZpY
   ssq=YpY-2*beta'XpY+beta'XpX*beta
   mana=vech(XZXi)'
        }                           
else  {                      				
   YpY = WpW[1,1]
   XpY = WpW[2::1+k,1]
   XpX = WpW[2::1+k,2::1+k]
   XpXi = invsym(XpX)
   beta = XpXi*XpY
   ssq = YpY-2*beta'XpY+beta'XpX*beta
   	   mana=vech(XpXi)'	   
}
if (con == "noconstant") {
   	MSS = beta'XpX*beta
   	rr = (MSS/(ssq+MSS))
   	}
else {
   	rr = 1-(ssq/(YpY-((Yp1)^2/no)))
   	}
coef=beta',rr
}

                void _g2DYzCsZ(numeric vector v,numeric matrix tipo,string scalar con,		///
                      		numeric scalar ssqi,numeric vector coefi,numeric vector manai,		///
                		numeric scalar ssqd,numeric vector coefd,numeric vector manad)
       {
real vector WpW,coef,mana
real scalar q,Yp1,no,ssq
q=rows(v)/2
WpW=v[1::q-2,1]
Yp1=v[q-1,1]	
no=v[q,1]	
_pau8gNYG(WpW,no,Yp1,tipo,con,ssq=.,coef=.,mana=.)
ssqi=ssq
coefi=coef
manai=mana
WpW=v[q+1::2*q-2,1]
Yp1=v[2*q-1,1]
no=v[2*q,1]
_pau8gNYG(WpW,no,Yp1,tipo,con,ssq=.,coef=.,mana=.)
ssqd=ssq
coefd=coef
manad=mana
}

                void _nmaYY9my(numeric matrix data,numeric matrix tipo,numeric vector carac,numeric scalar ssqp,	///
                		numeric scalar l, string scalar con, 							///
                		numeric vector ssq,numeric matrix coef,numeric vector no,numeric matrix mana,		///
numeric scalar xf, numeric scalar h)
        {
        real matrix vn,maux,v2,x,mres,coefi,coefd,manai,manad,bloque
real vector vx,ssqi,ssqd,coefi_0,manai_0,coefd_0,manad_0
real scalar v1,k,ncoef,q,rx,v3,v4,j,i,ssqi_0,ssqd_0
carac=colshape(carac,2)' 
vn = carac
carac=range(1,cols(carac),1),carac'	
carac=select(carac, carac[.,2]:!=carac[.,3])
if (rows(carac)>0) {				
carac[.,3]=carac[.,3]-carac[.,2]		
v1=colmax(carac[.,3])                           
k=rows(carac)					
ncoef=tipo[2,2]-tipo[1,2]+1				
if (tipo[1,3]!=0) q=ncoef+(tipo[2,3]-tipo[1,3]+1)+1	
if (tipo[1,3]==0) q=ncoef+1				
q=((q*(q+1))/2)+1+1					
maux=J(2*q*k,v1,0)                          
v2=data[.,tipo[1,1]::tipo[2,1]]                    
x=select(data,(quadrowsum((v2:<=vn[2,.]):*(v2:>=vn[1,.])):==cols(v2)))
if (rows(x)>0) {				
  rx=rows(x)
  j=1
  while (j<=rx) {			
    if (tipo[1,3]!=0) vx=(x[j,1],x[j,tipo[1,2]::tipo[2,3]])	
    if (tipo[1,3]==0) vx=(x[j,1],x[j,tipo[1,2]::tipo[2,2]])	
    vx=vech(((vx')*vx))\x[j,1]\1				
    i=1
    while (i<=k) {						
        v1=x[j,carac[i,1]+1]-carac[i,2]+1	   		
        v2=carac[i,3]						
        v3=v1-1							
        v4=(i-1)*2*q						
        if (v1<=v2) maux[v4+1::v4+q,v1::v2]=maux[v4+1::v4+q,v1::v2]:+vx	
        if (v3!=0) maux[v4+q+1::v4+2*q,1::v3]=maux[v4+q+1::v4+2*q,1::v3]:+vx 
        i=i+1
        }	
    j=j+1
  }		
}		
mres=J(k,7,0)		
coefi=J(k,ncoef+1,0)    
coefd=J(k,ncoef+1,0)    
ssqi=J(k,1,0)	        
ssqd=J(k,1,0)	        
manai=J(k,ncoef*(ncoef+1)/2,0)		
manad=J(k,ncoef*(ncoef+1)/2,0)		
i=1
while (i<=k) {				
    bloque=(maux[(i-1)*2*q+1::i*2*q,1::carac[i,3]])\	
((range(carac[i,2],carac[i,2]+carac[i,3]-1,1):+0.5)')	
    v1=bloque[q,.]:>=l	                                	
    v2=bloque[2*q,.]:>=l					
    v1=v1:*v2
    bloque=select(bloque',v1')'					
    	    if (rows(bloque)>0) {					
j=1
while (j<=cols(bloque)) {				
  _g2DYzCsZ(bloque[1::2*q,j],tipo,con,		/// 
ssqi_0=.,coefi_0=.,manai_0=.,ssqd_0=.,coefd_0=.,manad_0=.)
  if ((ssqp-(ssqi_0+ssqd_0))>mres[i,4]) {		
   coefi[i,.]=coefi_0
   coefd[i,.]=coefd_0
   manai[i,.]=manai_0
   manad[i,.]=manad_0
   mres[i,.]=(carac[i,1],ssqi_0,ssqd_0,(ssqp-(ssqi_0+ssqd_0)),	///
bloque[q,j],bloque[2*q,j],bloque[2*q+1,j])	
   }	
  j=j+1
  }  	
        }	
    i=i+1
    }		
v1=colmax(mres[.,4])		
if (v1 > 0) {			
   v1=select(mres[.,1],mres[.,4]:==v1)	
   if (rows(v1) > 1) v1=v1[1,1]		
   v1=mres[.,1]:==v1
   mres=select(mres,v1)
   coefi=select(coefi,v1)
   coefd=select(coefd,v1)
   manai=select(manai,v1)
   manad=select(manad,v1)
   }					
else {					
   mres=J(k,7,0)
   coefi=coefd=manai=manad=0
   }
 		}			                
else {					
   mres=J(k,7,0)
   coefi=coefd=manai=manad=0
   }
ssq=mres[1,2]\mres[1,3]
coef=coefi\coefd
no=mres[1,5]\mres[1,6]
mana=manai\manad
xf=mres[1,1]
h=mres[1,7]
 	}			

 	        void _h5QqASwC(numeric matrix data,numeric matrix tipo,string scalar constant_s,	///
numeric scalar l,numeric matrix jUYYJ5Vn1,numeric matrix jUYYJ5Vn2,numeric matrix jUYYJ5Vn3, 	///
numeric matrix jUYYJ5Vn4 )
        {
                real matrix splvar,W,WpW,xaux,carac,v2,x
real vector coef,mana
real scalar ssq,no,xf,h,s,fin,c,kr,ks
kr=(tipo[2,2]-tipo[1,2]+1)
ks=(tipo[2,1]-tipo[1,1]+1)
jUYYJ5Vn1=1,J(1,5,-1),0 					
jUYYJ5Vn2=J(1,kr+2,0)
splvar=data[.,tipo[1,1]::tipo[2,1]]
jUYYJ5Vn3=rowshape((colmin(splvar)\colmax(splvar))',1)	
jUYYJ5Vn4=vech(J(kr,kr,0))' 
no=rows(data)
W = data[.,1],data[.,tipo[1,2]::tipo[2,2]]		
if (tipo[1,3]!=0) W = W,data[.,tipo[1,3]::tipo[2,3]]	
WpW = vech(quadcross(W,W))
_pau8gNYG(WpW,no,quadsum(data[.,1]),tipo,constant_s,ssq=.,coef=.,mana=.)
jUYYJ5Vn1[1,5]=ssq
jUYYJ5Vn1[1,6]=no			
jUYYJ5Vn2[1,.]=coef,mean(data[.,tipo[1,2]..tipo[2,2]])*coef[1,1..cols(coef)-1]'
jUYYJ5Vn4[1,.]=mana
s=1 
carac=colshape(jUYYJ5Vn3[s,.],2)'         
carac=range(1,cols(carac),1),carac'	
carac=select(carac, carac[.,2]:!=carac[.,3])	
if (rows(carac)==0) {	
fin=1				
jUYYJ5Vn1[s,2::4]=(0,0,0)
}
else {					
fin=0		
c=2             
}
while (fin==0) {		
   if (jUYYJ5Vn1[s,2]==-1) {		
_nmaYY9my(data,tipo,jUYYJ5Vn3[s,.],jUYYJ5Vn1[s,5],l,constant_s,ssq=.,coef=.,no=.,mana=.,xf=.,h=.)
jUYYJ5Vn1[s,2::4]=(c,xf,h)	
if (xf!=0){		
   xaux = ((c\c+1),(J(2,3,-1)),ssq,no,J(2,1,s)) 
   if (no[1,1]<=l) xaux[1,(2,3,4)]=J(1,3,0)	
   if (no[2,1]<=l) xaux[2,(2,3,4)]=J(1,3,0)	
   jUYYJ5Vn1=jUYYJ5Vn1\xaux				
   jUYYJ5Vn4=jUYYJ5Vn4\mana	
   xaux=jUYYJ5Vn3[s,.]#J(2,1,1)	
   xaux[1,2*xf]=(h-0.5)
   xaux[2,2*xf-1]=(h+0.5)
   jUYYJ5Vn3=jUYYJ5Vn3\xaux		
   xaux=colshape(xaux,2)	
    if (xaux[1::ks,1]==xaux[1::ks,2]) jUYYJ5Vn1[rows(jUYYJ5Vn1)-1,(2,3,4)]=J(1,3,0)	
    if (xaux[(ks+1)::(2*ks),1]==xaux[(ks+1)::(2*ks),2]) jUYYJ5Vn1[rows(jUYYJ5Vn1),(2,3,4)]=J(1,3,0)	
   jUYYJ5Vn2=jUYYJ5Vn2\(coef,(0\0))	
   v2=data[.,tipo[1,1]::tipo[2,1]] 
   x=select(data,(quadrowsum((v2:<=xaux[1..ks,2]'):*(v2:>=xaux[1..ks,1]')):==cols(v2))) 
   jUYYJ5Vn2[rows(jUYYJ5Vn2)-1,cols(jUYYJ5Vn2)]=mean(x[.,tipo[1,2]..tipo[2,2]])*coef[1,1..cols(coef)-1]'
   v2=data[.,tipo[1,1]::tipo[2,1]] 
   x=select(data,(quadrowsum((v2:<=xaux[ks+1..2*ks,2]'):*(v2:>=xaux[ks+1..2*ks,1]')):==cols(v2))) 
   jUYYJ5Vn2[rows(jUYYJ5Vn2),cols(jUYYJ5Vn2)]=mean(x[.,tipo[1,2]..tipo[2,2]])*coef[2,1..cols(coef)-1]'
   c=c+2			
} 				
else jUYYJ5Vn1[s,2]=0		
   }               			
   s=s+1
   if (s==(rows(jUYYJ5Vn1)+1)) fin=1		
}				
jUYYJ5Vn4=(jUYYJ5Vn1[.,5]:/(jUYYJ5Vn1[.,6]:-kr)):*jUYYJ5Vn4
      }					

        void _rqJjcayd(numeric matrix jUYYJ5Vn1,numeric matrix jUYYJ5Vn2,numeric matrix seq, numeric matrix alph)
        {
                real matrix jUYYJ5Vn,pod
real vector hijos,wlinks,vaux
real scalar i,fin,rws,rwsl,tss,a
jUYYJ5Vn=jUYYJ5Vn1	
tss=jUYYJ5Vn[1,5]/(1-jUYYJ5Vn2[1,cols(jUYYJ5Vn2)-1])	
jUYYJ5Vn[.,5]=jUYYJ5Vn[.,5]:/tss		
seq=jUYYJ5Vn1[.,2]			
rws=rows(jUYYJ5Vn)
vaux=select(jUYYJ5Vn[.,(5,6)],jUYYJ5Vn[.,2]:==0)	
alph=rows(vaux)\(quadcolsum(vaux[.,1]*tss)/quadcolsum(vaux[.,2]))\0	
while (rows(select(jUYYJ5Vn,jUYYJ5Vn[.,2]:==0))>1) {	
 pod=jUYYJ5Vn1[.,1],J(rows(jUYYJ5Vn1),3,0)	
 vaux=(jUYYJ5Vn[.,2]:!=0):*(jUYYJ5Vn[.,2]:!=-1)	
 for (i=1; i<=rws; i++) {
if (vaux[i,1]==1) {		
 hijos=jUYYJ5Vn[i,2]\jUYYJ5Vn[i,2]+1	
 fin=0
 while (fin==0) {		
   if (jUYYJ5Vn[hijos[1,1],2]==0) {	
pod[i,2]=pod[i,2]+jUYYJ5Vn[hijos[1,1],5]	
pod[i,3]=pod[i,3]+1	
   }
   else hijos=hijos[.,1]\jUYYJ5Vn[hijos[1,1],2]\(jUYYJ5Vn[hijos[1,1],2]+1) 
   if (rows(hijos)>1) hijos=hijos[2..rows(hijos),1]		
   else fin=1							
 }
}
 }
 pod[.,4]=(jUYYJ5Vn[.,5]-pod[.,2]):/(pod[.,3]:-1):*(vaux[.,1]:==1)-(vaux[.,1]:==0)
 a=colmin(select(pod[.,4],pod[.,4]:!=-1))  
 wlinks=select(pod[.,1],pod[.,4]:==a)
 rwsl=rows(wlinks)
 for (i=1; i<=rwsl; i++) {
 hijos=jUYYJ5Vn[wlinks[i,1],2]\jUYYJ5Vn[wlinks[i,1],2]+1	
 if (hijos[1,1]!=-1) {	
   jUYYJ5Vn[wlinks[i,1],2]=0	
   fin=0
   while (fin==0) {	
if (jUYYJ5Vn[hijos[1,1],2]!=0) hijos=hijos[.,1]\jUYYJ5Vn[hijos[1,1],2]\(jUYYJ5Vn[hijos[1,1],2]+1) 
jUYYJ5Vn[hijos[1,1],2]=-1	
if (rows(hijos)>1) hijos=hijos[2..rows(hijos),1]	
else fin=1						
   }
  }
 }
 seq=seq,jUYYJ5Vn[.,2]
vaux=select(jUYYJ5Vn[.,(5,6)],jUYYJ5Vn[.,2]:==0)	
alph=alph,(rows(vaux)\(quadcolsum(vaux[.,1]*tss)/quadcolsum(vaux[.,2]))\a)	
}
}	

        void _DURCKrqs(numeric matrix data2,numeric matrix tipo, numeric matrix jUYYJ5Vn1,	///
numeric matrix jUYYJ5Vn2,numeric matrix jUYYJ5Vn3,numeric matrix seq, 	///
numeric vector jUYYJ5Vn1_ts,numeric vector tes)
        {
real matrix X,jUYYJ5Vn1_old,jUYYJ5Vn2_old,jUYYJ5Vn1_s,sQaqMexR_obs,W
real vector beta,r_sq,r_sq2
real scalar no,p,nseq,ncoef,i,rws,rss,rs4,j
    no=rows(data2)
    X = data2[.,1],data2[.,tipo[1,2]::tipo[2,2]]	
    p=rows(jUYYJ5Vn1)
    nseq=cols(seq)
    jUYYJ5Vn1_old=jUYYJ5Vn1
    jUYYJ5Vn2_old=jUYYJ5Vn2
    ncoef=cols(jUYYJ5Vn2)-2
    tes=J(3,1,0)					
    jUYYJ5Vn1_ts=jUYYJ5Vn1[.,1],J(p,4,0)
    for (i=1; i<=nseq; i++) {	
jUYYJ5Vn1[.,2]=seq[.,i]	
jUYYJ5Vn1_s=select(jUYYJ5Vn1[.,1],jUYYJ5Vn1[.,2]:==0)	
rws = rows(jUYYJ5Vn1_s)
_kuVUVxcx(jUYYJ5Vn1,jUYYJ5Vn3,(data2[.,tipo[1,1]::tipo[2,1]]),sQaqMexR_obs=.)	
rss=0
rs4=0
for (j=1; j<=rws; j++) {	
if (jUYYJ5Vn1_ts[jUYYJ5Vn1_s[j,1],5]==0) {	
W=select(X,sQaqMexR_obs[.,1]:==jUYYJ5Vn1_s[j,1])		
beta=select(jUYYJ5Vn2[.,1::ncoef],jUYYJ5Vn1[.,1]:==jUYYJ5Vn1_s[j,1])
r_sq=(W[.,1]-W[.,2::ncoef+1]*beta'):^2
r_sq2=r_sq:^2
jUYYJ5Vn1_ts[jUYYJ5Vn1_s[j,1],2::5]=(quadcolsum(r_sq)/no),(quadcolsum(r_sq2)/no),rows(W),1
}
rss=rss+jUYYJ5Vn1_ts[jUYYJ5Vn1_s[j,1],2]
rs4=rs4+jUYYJ5Vn1_ts[jUYYJ5Vn1_s[j,1],3]
}
tes=tes,(rws\rss\sqrt((1/no)*(rs4-rss^2)))
    } 	
    tes=tes[.,2::cols(tes)]
    jUYYJ5Vn1_ts=jUYYJ5Vn1_ts[.,1::4]
    jUYYJ5Vn1=jUYYJ5Vn1_old;jUYYJ5Vn2=jUYYJ5Vn2_old
}	

        void _53djHRYj(numeric matrix jUYYJ5Vn1,numeric matrix seq,numeric matrix tes,numeric scalar rule,	///
numeric scalar tmin,numeric scalar tstar,numeric matrix jUYYJ5Vn1_h)
        {
real scalar minv,vn,cols,i		
minv=rowmin(tes[2,.])
tmin=select(tes,tes[2,.]:==minv)
minv=rowmin(tmin[1,.])
tmin=select(tmin,tmin[1,.]:==minv)
jUYYJ5Vn1_h=jUYYJ5Vn1
vn=tmin[2,1]+rule*tmin[3,1]
vn=tes[2,.]:<=vn
cols=cols(vn)
for (i=1; i<=cols; i=i+1) {
if (vn[1,i]==1) {
jUYYJ5Vn1_h[.,2]=seq[.,i]
tstar=tes[1,i]
}				
}
tmin=tmin[1,1]
}	
  
        void _XnT5Yf8A(string scalar depvar_s, string scalar splvar_s, string scalar regvar_s, ///
string scalar insvar_s,string scalar smpl_s, string scalar learn_smpl_s, 	///
string scalar test_smpl_s,string scalar constant_s, numeric scalar l, numeric scalar rule, ///
numeric scalar bootstraps,numeric scalar vcv,string scalar jUYYJ5Vnol_s, 		///
string scalar coeficientes_s,string scalar varianzas_s,string scalar varianzas_ts_s,	///
string scalar ajustes_s,string scalar criterios_s,string scalar predicciones_s,	///
string scalar minmax_s,string scalar podas_s,string scalar secuencia_s)
       {
                real matrix splvar,splvar_ts,splvar_all,regvar,regvar_ts,regvar_all,insvar,insvar_ts,	///
tipo,data,data_ts,data_all,data_v,jUYYJ5Vn1,jUYYJ5Vn2,jUYYJ5Vn3,jUYYJ5Vn4,pod,alph,t1,tes,jUYYJ5Vn1_h,	///
sQaqMexRs,predicciones,jUYYJ5Vnol,criterios,podas,v_original,v_new,v_old,equi,equi_col,	///
newvars,coeficientes,sigma,sigma_ts,ajustes_h,minmax,rmse,seq,rmse_bs,jUYYJ5Vn1_v,	///
jUYYJ5Vn2_v,jUYYJ5Vn3_v,jUYYJ5Vn4_v,seq_v,alph_v,data_ts_v,jUYYJ5Vn1_ts_v,tes_v,jUYYJ5Vn1_ter,jUYYJ5Vn2_ter
real vector depvar,depvar_ts,depvar_all,constante,constante_ts,constante_all,aux,	///
Tmin,Tstar
real scalar no,no_ts,no_all,k,max,i,r,r_ts,r_all,j,columna,rws,max_a,cols_a
depvar=st_data(.,tokens(depvar_s),learn_smpl_s)
no=rows(depvar)
constante=J(no,1,1)
depvar_ts=st_data(.,tokens(depvar_s),test_smpl_s)
no_ts=rows(depvar_ts)
constante_ts=J(no_ts,1,1)
depvar_all=st_data(.,tokens(depvar_s),smpl_s)
no_all=rows(depvar_all)
constante_all=J(no_all,1,1)
        if (splvar_s=="") {
        	splvar=constante
        	splvar_ts=constante_ts
        	splvar_all=constante_all
        	}
        else {	
splvar = st_data(., tokens(splvar_s),learn_smpl_s)
        	splvar_ts = st_data(.,tokens(splvar_s),test_smpl_s)
splvar_all = st_data(., tokens(splvar_s),smpl_s)
minmax=0,rowshape((colmin(splvar_all)\colmax(splvar_all))',1)
k=cols(splvar)
r=rows(splvar)
r_ts=rows(splvar_ts)
r_all=rows(splvar_all)
max=0
for (i=1; i<=k; i++) max=colmax((rows(uniqrows(splvar_all[.,i]))\max))
equi=J(max,2*k,.)
for (i=1; i<=k; i++) {
j=(i-1)*2+1
equi_col=uniqrows(splvar_all[.,i])
equi_col=equi_col,runningsum(J(rows(equi_col),1,1))
equi[1::rows(equi_col),j::j+1]=equi_col
splvar[.,i]=(splvar[.,i]:==(equi_col[.,1]')#J(r,1,1))*equi_col[.,2]
splvar_ts[.,i]=(splvar_ts[.,i]:==(equi_col[.,1]')#J(r_ts,1,1))*equi_col[.,2]
splvar_all[.,i]=(splvar_all[.,i]:==(equi_col[.,1]')#J(r_all,1,1))*equi_col[.,2]
}
}
        if (regvar_s=="") {
        	regvar=constante
        	regvar_ts=constante_ts
        	regvar_all=constante_all
        	}
        if (regvar_s!="" & constant_s=="noconstant") {
        	regvar=st_data(.,tokens(regvar_s),learn_smpl_s)
        	regvar_ts=st_data(.,tokens(regvar_s),test_smpl_s)
        	regvar_all=st_data(.,tokens(regvar_s),smpl_s)
        	}
        if (regvar_s!="" & constant_s!="noconstant") {
        	regvar=st_data(.,tokens(regvar_s),learn_smpl_s),constante
        	regvar_ts=st_data(.,tokens(regvar_s),test_smpl_s),constante_ts
        	regvar_all=st_data(.,tokens(regvar_s),smpl_s),constante_all
        	}
        if (insvar_s!="" & constant_s=="noconstant") {
        	insvar=st_data(.,tokens(insvar_s),learn_smpl_s)
        	insvar_ts=st_data(.,tokens(insvar_s),test_smpl_s)
        	insvar_all=st_data(.,tokens(insvar_s),smpl_s)
        	}
        if (insvar_s!="" & constant_s!="noconstant") {
        	insvar=st_data(.,tokens(insvar_s),learn_smpl_s),constante
        	insvar_ts=st_data(.,tokens(insvar_s),test_smpl_s),constante_ts
        	insvar_all=st_data(.,tokens(insvar_s),smpl_s),constante_all
        	}
        data=depvar,splvar,regvar
        data_ts=depvar_ts,splvar_ts,regvar_ts
        data_all=depvar_all,splvar_all,regvar_all
        if (insvar_s!="") {
        	data=data,insvar
        	data_ts=data_ts,insvar_ts
        	data_all=data_all,insvar_all
        	}
tipo=	(2\1+cols(splvar)),
(2+cols(splvar)\(1+cols(splvar)+cols(regvar))),
(2+cols(splvar)+cols(regvar)\1+cols(splvar)+cols(regvar)+cols(insvar))
if (insvar_s=="") tipo[.,3]=J(2,1,0)
_h5QqASwC(data,tipo,constant_s,l,jUYYJ5Vn1=.,jUYYJ5Vn2=.,jUYYJ5Vn3=.,jUYYJ5Vn4=.)	
_rqJjcayd(jUYYJ5Vn1,jUYYJ5Vn2,seq=.,alph=.)	
if (bootstraps==2147483647 & vcv==2147483647) _DURCKrqs(data_ts,tipo,jUYYJ5Vn1,jUYYJ5Vn2,jUYYJ5Vn3,seq,jUYYJ5Vn1_ts=.,tes=.)
if (vcv!=2147483647) {
cols_a=cols(alph)
tes=alph[1,.]\J(2,cols_a,0)
j=J(1,cols_a,0)
aux=floor(rows(data)/(100/vcv))#J(floor(rows(data)/floor(rows(data)/(100/vcv))),1,1)
i=rows(data)-quadcolsum(aux)
if (i!=0 & i<rows(aux)) aux=aux:+(J(i,1,1)\J(rows(aux)-i,1,0))
else aux = aux\i
rws=rows(aux)
v_new=J(aux[1,1],1,1)
        for (i=2; i<=rws; i++) v_new=v_new\J(aux[i,1],1,i)
        for (i=1; i<=rws; i++) {
    data_ts_v=select(data,v_new:==i)		
    data_v=select(data,v_new:!=i)		
    _h5QqASwC(data_v,tipo,constant_s,l,jUYYJ5Vn1_v=.,jUYYJ5Vn2_v=.,jUYYJ5Vn3_v=.,jUYYJ5Vn4_v=.)	
    _rqJjcayd(jUYYJ5Vn1_v,jUYYJ5Vn2_v,seq_v=.,alph_v=.)	
    _DURCKrqs(data_ts_v,tipo,jUYYJ5Vn1_v,jUYYJ5Vn2_v,jUYYJ5Vn3_v,seq_v,jUYYJ5Vn1_ts_v=.,tes_v=.)
    max_a=rowmax((alph[3,.],alph_v[3,.]))+10
    aux=((alph[3,.]':<=alph_v[3,.]#J(cols_a,1,1)):* //
((alph[3,2::cols_a],max_a)':>=alph_v[3,.]#J(cols_a,1,1)))
    j=j+(quadrowsum(aux):>0)'
    tes[2,.]=tes[2,.]:+editmissing(quadrowsum(aux:*(tes_v[2,.]#J(cols_a,1,1))):/quadrowsum(aux),0)'
    tes[3,.]=tes[3,.]:+editmissing(quadrowsum(aux:*(tes_v[3,.]#J(cols_a,1,1))):/quadrowsum(aux),0)'
}
tes[(2,3),.]=tes[(2,3),.]:/j
                }
if (bootstraps!=2147483647) {
tes=alph[(1,2),.]\J(2,cols(alph),0)
    		for (i=1; i<=bootstraps; i++) {
   x=data_ts[ceil(no*runiform(no,1)),.]		
   _h5QqASwC(x,tipo,constant_s,l,jUYYJ5Vn1_v=.,jUYYJ5Vn2_v=.,jUYYJ5Vn3_v=.,jUYYJ5Vn4_v=.)	
   aux=select(jUYYJ5Vn1_v[.,(5,6)],jUYYJ5Vn1_v[.,2]:==0)	
   aux=editmissing(quadcolsum(aux[.,1])/quadcolsum(aux[.,2]),0)	
   tes[3,1]=tes[3,1]+(1/bootstraps)*aux
   tes[4,1]=tes[4,1]+(1/bootstraps)*aux^2
   if (ceil(i/10)==i/10) stata(`"noi dis in y "." _continue"')
   if (ceil(i/500)==i/500) i
   if (i==bootstraps) ""
    		}
tes[3,.]=sqrt(tes[4,1]-tes[3,1]^2)*J(1,cols(tes),1)
tes=tes[1::3,.]
}
_53djHRYj(jUYYJ5Vn1,seq,tes,rule,Tmin=.,Tstar=.,jUYYJ5Vn1_h=.) 	
_kuVUVxcx(jUYYJ5Vn1_h,jUYYJ5Vn3,(data_all[.,tipo[1,1]::tipo[2,1]]),sQaqMexRs=.) 
jUYYJ5Vn1_ter=select(jUYYJ5Vn1_h[.,1],jUYYJ5Vn1_h[.,2]:==0)
jUYYJ5Vn2_ter=select(jUYYJ5Vn2[.,1..cols(jUYYJ5Vn2)-2],jUYYJ5Vn1_h[.,2]:==0)
predicciones=rowsum((sQaqMexRs[.,1]:==jUYYJ5Vn1_ter[.,1]'#J(rows(sQaqMexRs),1,1)):*(regvar_all*jUYYJ5Vn2_ter'))	
jUYYJ5Vnol=jUYYJ5Vn1_h[.,1::4]
r=rows(jUYYJ5Vn1_h)	
for (i=1; i<=r; i++) {
v_old=jUYYJ5Vnol[i,3]	
if (v_old!=0) {
equi_col=select(equi[.,(v_old-1)*2+1::(v_old-1)*2+2],equi[.,(v_old-1)*2+1]:!=.)	
jUYYJ5Vnol[i,4]=(equi_col[jUYYJ5Vn1_h[i,4]-0.5,1]+equi_col[jUYYJ5Vn1_h[i,4]+0.5,1])/2
}			
if (jUYYJ5Vnol[i,2]==0) jUYYJ5Vnol[i,3..4]=J(1,2,0)
}
jUYYJ5Vnol=select(jUYYJ5Vnol,jUYYJ5Vn1_h[.,2]:!=-1)
_5MmwTVMH(jUYYJ5Vn1_h,jUYYJ5Vn3,(data_all[.,tipo[1,1]::tipo[2,1]]),equi,sQaqMexRs,criterios=.) 
if (bootstraps==2147483647 & vcv==2147483647) rmse=sqrt((jUYYJ5Vn1[.,5]:/jUYYJ5Vn1[.,6],(no_ts:/jUYYJ5Vn1_ts[.,4]):*jUYYJ5Vn1_ts[.,2]))
else rmse=J(rows(jUYYJ5Vn1),2,.)
coeficientes=jUYYJ5Vn1[.,1],jUYYJ5Vn2[.,cols(jUYYJ5Vn2)],rmse,jUYYJ5Vn1[.,6],		///
jUYYJ5Vn2[.,cols(jUYYJ5Vn2)-1],jUYYJ5Vn2[.,1..cols(jUYYJ5Vn2)-2]
coeficientes=select(coeficientes,jUYYJ5Vn1_h[.,2]:==0)
sigma=select(jUYYJ5Vn4,jUYYJ5Vn1_h[.,2]:==0)
sigma_ts=select(rmse[.,2]:/rmse[.,1],jUYYJ5Vn1_h[.,2]:==0):*sigma
if (bootstraps==2147483647) podas=sort((alph[(1,2),.]\tes[(2,3),.])',1)
else podas=sort((alph[(1,2),.]\tes[3,.])',1)
ajustes_h=select(podas,podas[.,1]:==Tmin)\select(podas,podas[.,1]:==Tstar)
st_matrix(jUYYJ5Vnol_s,jUYYJ5Vnol)
st_matrix(coeficientes_s,coeficientes)
st_matrix(varianzas_s,sigma)
st_matrix(varianzas_ts_s,sigma_ts)
st_matrix(ajustes_s,ajustes_h)
st_matrix(criterios_s,criterios)
newvars = st_addvar("float", (predicciones_s))
st_store(.,newvars,smpl_s,predicciones)
st_matrix(minmax_s,minmax)
st_matrix(podas_s,podas)
st_matrix(secuencia_s,seq)
}	

        void _NfHW4APu(string scalar depvar_s, string scalar splvar_s, string scalar regvar_s, ///
string scalar smpl_s,string scalar constant_s, numeric scalar l, numeric scalar bootstraps,	///
numeric scalar rsampling,numeric scalar rsplitting,string scalar ij,		///
string scalar predicciones_s,string scalar errstd_s,string scalar matatree)
       {
                real matrix splvar,regvar,tipo,data,equi,equi_col,x,x_ts,aux,jUYYJ5Vn1,jUYYJ5Vn2,jUYYJ5Vn3,	///
jUYYJ5Vn1_v,jUYYJ5Vn2_v,jUYYJ5Vn3_v,jUYYJ5Vn4_v,jUYYJ5Vn1_ter,jUYYJ5Vn2_ter,trees,criteria,		///
coefficients,pred_jack
real vector depvar,constante,orden,pred,pred_sd,e,e2,num_ls,num_ts,v,v_ts,pred_v,e_v,	///
v_old,newvars,minmax,n_b,no_j
real scalar no,k,r,max,i,j,q,k_bs,no_bs,splitvar_ind,fh

depvar=st_data(.,tokens(depvar_s),smpl_s)
no=rows(depvar)
constante=J(no,1,1)
orden=runningsum(J(no,1,1))
        if (splvar_s=="") splvar=constante
        else {	
splvar = st_data(., tokens(splvar_s),smpl_s)
k=cols(splvar)
r=rows(splvar)
max=0
for (i=1; i<=k; i++) max=colmax((rows(uniqrows(splvar[.,i]))\max))
equi=J(max,2*k,.)
for (i=1; i<=k; i++) {
j=(i-1)*2+1
equi_col=uniqrows(splvar[.,i])
equi_col=equi_col,runningsum(J(rows(equi_col),1,1))
equi[1::rows(equi_col),j::j+1]=equi_col
splvar[.,i]=(splvar[.,i]:==(equi_col[.,1]')#J(r,1,1))*equi_col[.,2]
}
}
minmax=rowshape((colmin(splvar)\colmax(splvar))',1)
        if (regvar_s=="") regvar=constante
        if (regvar_s!="" & constant_s=="noconstant") regvar=st_data(.,tokens(regvar_s),smpl_s)
        if (regvar_s!="" & constant_s!="noconstant") regvar=st_data(.,tokens(regvar_s),smpl_s),constante
        data=depvar,splvar,regvar
tipo=	(2\1+cols(splvar)),
(2+cols(splvar)\(1+cols(splvar)+cols(regvar))),J(2,1,0)
q=cols(regvar)	
k=cols(splvar)	
k_bs=colmax((floor(k*rsplitting)\1))	
no_bs=floor(no*rsampling)	
splitvar_ind=1:+runningsum(J(k,1,1))
pred=J(no,1,0)
pred_sd=pred
e=pred
e2=pred
num_ls=pred
num_ts=pred
    	for (i=1; i<=bootstraps; i++) {
if (rsampling==1) v=ceil(no*runiform(no,1))	
if (rsampling<1) {	
v=jumble(orden)
v=v[1::no_bs,.]
}
x=data[v,.]
if (ij=="") v_ts=rowsum(orden:==v'#J(no,1,1)):==0	
else v_ts=rowsum(orden:==v'#J(no,1,1))			
aux=jumble(splitvar_ind)
aux=sort(aux[k_bs+1::rows(aux),1],1)
x[.,(aux')]=J(no_bs,rows(aux),1)
_h5QqASwC(x,tipo,constant_s,l,jUYYJ5Vn1_v=.,jUYYJ5Vn2_v=.,jUYYJ5Vn3_v=.,jUYYJ5Vn4_v=.)	
jUYYJ5Vn3_v[.,(rowshape((-3:+2:*aux,-2:+2:*aux),1))]=		/// 
minmax[.,(rowshape((-3:+2:*aux,-2:+2:*aux),1))]#J(rows(jUYYJ5Vn3_v),1,1)
jUYYJ5Vn1=(i==1? jUYYJ5Vn1_v[.,1..4] : jUYYJ5Vn1\jUYYJ5Vn1_v[.,1..4] )
jUYYJ5Vn2=(i==1? jUYYJ5Vn2_v[.,1..q] : jUYYJ5Vn2\jUYYJ5Vn2_v[.,1..q] )
jUYYJ5Vn3=(i==1? jUYYJ5Vn3_v : jUYYJ5Vn3\jUYYJ5Vn3_v)
_kuVUVxcx(jUYYJ5Vn1_v,jUYYJ5Vn3_v,(data[.,tipo[1,1]::tipo[2,1]]),sQaqMexRs=.) 
jUYYJ5Vn1_ter=select(jUYYJ5Vn1_v[.,1],jUYYJ5Vn1_v[.,2]:==0)
jUYYJ5Vn2_ter=select(jUYYJ5Vn2_v[.,1..cols(jUYYJ5Vn2_v)-2],jUYYJ5Vn1_v[.,2]:==0)
pred_v=rowsum((sQaqMexRs[.,1]:==jUYYJ5Vn1_ter[.,1]'#J(rows(sQaqMexRs),1,1)):*(regvar*jUYYJ5Vn2_ter'))
pred=pred:+pred_v/bootstraps
if (rows(v_ts)>0 & ij=="") {	
pred_jack=(i==1? (pred_v#v_ts') : (pred_jack:+(pred_v#v_ts')))
no_jack=(i==1? (v_ts') : (no_jack:+(v_ts')))
}
else {	
pred_jack=(i==1? (pred_v) : (pred_jack,pred_v))
no_jack=(i==1? (v_ts) : (no_jack,v_ts))
}
if (ceil(i/10)==i/10) stata(`"noi dis in y "." _continue"')
if (ceil(i/500)==i/500) i
if (i==bootstraps) ""
}
if (ij=="") {	
pred_jack=pred_jack:/no_jack
pred_sd=sqrt(((no-1)/no)*quadrowsum((pred_jack:-mean(pred_jack')'):^2))
}
else {		
pred_jack=pred_jack:-mean(pred_jack')'
no_jack=no_jack:-mean(no_jack')'
    	for (i=1; i<=no; i++) {
aux=sqrt(quadrowsum((mean((no_jack:*pred_jack[i,.])')):^2))
pred_sd=(i==1? (aux) : (pred_sd\aux))
}
}
trees=jUYYJ5Vn1[.,1::4]
coefficients=jUYYJ5Vn2
criteria=jUYYJ5Vn3
r=rows(trees)
for (i=1; i<=r; i++) {
v_old=trees[i,3]	
if (v_old!=0) {
equi_col=select(equi[.,(v_old-1)*2+1::(v_old-1)*2+2],equi[.,(v_old-1)*2+1]:!=.)	
trees[i,4]=(equi_col[trees[i,4]-0.5,1]+equi_col[trees[i,4]+0.5,1])/2
}			
}
ra = rows(criteria)
for (j=1; j<=ra; j++) {
jUYYJ5Vn3_sQaqMexR=criteria[j,.]
for (i=1; i<=k; i++) {	
columna=(i-1)*2+1
equi_col=select(equi[.,columna::columna+1],equi[.,columna]:!=.)
jUYYJ5Vn3_sQaqMexR[1,columna]=equi_col[jUYYJ5Vn3_sQaqMexR[1,columna],1]
jUYYJ5Vn3_sQaqMexR[1,columna+1]=equi_col[jUYYJ5Vn3_sQaqMexR[1,columna+1],1]
}
criteria[j,.]=jUYYJ5Vn3_sQaqMexR
}
newvars = st_addvar("float", (predicciones_s))
st_store(.,newvars,smpl_s,pred)
newvars = st_addvar("float", (errstd_s))
st_store(.,newvars,smpl_s,pred_sd)
fh=fopen(matatree, "w")
fputmatrix(fh, trees)
fputmatrix(fh, criteria)
fputmatrix(fh, coefficients)
fclose(fh)
}	
        void _gSY5Ek89(numeric matrix jUYYJ5Vn1,numeric matrix seq,numeric matrix tes,numeric scalar rule,	///
numeric scalar tmin,numeric scalar tstar,numeric matrix jUYYJ5Vn1_h)
        {
real scalar minv,vn,cols,i		
minv=rowmin(tes[2,.])
tmin=select(tes,tes[2,.]:==minv)
minv=rowmin(tmin[1,.])
tmin=select(tmin,tmin[1,.]:==minv)
jUYYJ5Vn1_h=jUYYJ5Vn1
vn=tmin[2,1]+rule*tmin[3,1]
vn=tes[2,.]:<=vn
cols=cols(vn)
for (i=1; i<=cols; i=i+1) {
if (vn[1,i]==1) {
jUYYJ5Vn1_h[.,2]=seq[.,i]
tstar=tes[1,i]
}				
}
tmin=tmin[1,1]
}	

                void _EPsLyEaj(numeric matrix jUYYJ5Vn1, numeric matrix jUYYJ5Vn3, numeric matrix xs,numeric vector sQaqMexR) 
        {
        real matrix jUYYJ5Vn1_s, jUYYJ5Vn3_s, carac
real scalar ra,j,rn,i
sQaqMexR = J(rows(xs),2,0)
jUYYJ5Vn3_s=select(jUYYJ5Vn3,jUYYJ5Vn1[.,2]:==0)	
jUYYJ5Vn1_s=select(jUYYJ5Vn1,jUYYJ5Vn1[.,2]:==0)
ra = rows(jUYYJ5Vn1_s)
for (j=1; j<=ra; j++) {
carac=colshape(jUYYJ5Vn3_s[j,.],2)'   
sQaqMexR[.,1]=sQaqMexR[.,1]+jUYYJ5Vn1_s[j,1]*rowmin((xs:>=carac[1,.]):*(xs:<=carac[2,.]))
}
rn=rows(sQaqMexR)
for (i=1; i<=rn; i++) {
if (sQaqMexR[i,1] == 0) {
j=1
while (j!=0) {		
if (jUYYJ5Vn1[j,2]==0) {                 
sQaqMexR[i,1]=jUYYJ5Vn1[j,1]
sQaqMexR[i,2]=1
j=0
}
else {
if (xs[i,jUYYJ5Vn1[j,3]]<=jUYYJ5Vn1[j,4]) j=jUYYJ5Vn1[j,2]    
else j=jUYYJ5Vn1[j,2]+1				
}
}
}
}
}	

        void _yAk6bvkx(numeric matrix data2,numeric matrix pi,numeric matrix costs,	///
numeric matrix jUYYJ5Vn1,numeric matrix jUYYJ5Vn2,numeric matrix seq, 	///
numeric matrix clases, numeric vector jUYYJ5Vn1_ts,numeric vector tes)
        {
                real matrix jUYYJ5Vn1_old,jUYYJ5Vn2_old,jUYYJ5Vn1_s,sQaqMexR_obs,W,x2,maux,maux2,num_ts
real vector x1,vaux,N_j,N_j_t,p_jt,p_j_t,p_ts,r_ts
real scalar no,p,q,nseq,rws,j,i,r
    no=rows(data2)
    p=rows(jUYYJ5Vn1)
    q=cols(clases)
    nseq=cols(seq)
    jUYYJ5Vn1_old=jUYYJ5Vn1
    jUYYJ5Vn2_old=jUYYJ5Vn2
    jUYYJ5Vn1_ts=jUYYJ5Vn1[.,1],J(p,2,0)
    maux=jUYYJ5Vn1[.,1],J(p,q,0),jUYYJ5Vn1[.,6]	
    jUYYJ5Vn1_s=select(jUYYJ5Vn1[.,1],jUYYJ5Vn1[.,2]:==0)	
    rws = rows(jUYYJ5Vn1_s)
    _EPsLyEaj(jUYYJ5Vn1,jUYYJ5Vn2,data2[.,2::cols(data2)],sQaqMexR_obs=.)	
    for (j=1; j<=rws; j++) {
W=select(data2[.,1],sQaqMexR_obs[.,1]:==jUYYJ5Vn1_s[j,1])	
for (i=1; i<=q; i++) maux[jUYYJ5Vn1_s[j,1],1+i]=rows(select(W,W:==clases[1,i]))	
}
    for (i=1; i<=p; i++) {	
        if (jUYYJ5Vn1[i,2]==0) {     
            x1=maux[i,2::q+1]	
            j=jUYYJ5Vn1[i,10]
            while (j!=0) {      
                maux[j,2::q+1]=maux[j,2::q+1]+x1
                j=jUYYJ5Vn1[j,10]
                }
    	}			
    }
    num_ts=quadrowsum(maux[.,2..q+1])
    N_j=maux[1,2..q+1]
    N_j_t=maux[.,(2,3)]
    p_jt=pi:*N_j_t:/N_j
    p_ts=quadrowsum(p_jt)
    p_j_t=editmissing(p_jt:/p_ts,0)
    r_ts=quadrowsum(p_j_t:*(maux[.,4]:==(clases#J(p,1,1)))*costs)
    jUYYJ5Vn1_ts=jUYYJ5Vn1[.,1],p_ts,r_ts,num_ts	
    tes=J(3,1,.)	
    for (i=1; i<=nseq; i++) {		
jUYYJ5Vn1[.,2]=seq[.,i]		
maux2=select(jUYYJ5Vn1_ts[.,(2,3,4)],jUYYJ5Vn1[.,2]:==0)	
r=quadcolsum(maux2[.,1]:*maux2[.,2])
tes=tes,(rows(maux2)\r\sqrt(r*(1-r)/no))
    }	
    tes=tes[.,2..cols(tes)]
    jUYYJ5Vn1=jUYYJ5Vn1_old;jUYYJ5Vn2=jUYYJ5Vn2_old
}	

        void _RcEsM4Hk(numeric matrix tes,numeric vector min)
        {
min=J(3,1,0)
min[2,1]=colmin(tes[.,2])
min=select(tes,tes[.,2]:==min[2,1])'		
}	

        void _N4rrP6Lp(numeric matrix data2,numeric matrix jUYYJ5Vn1,numeric matrix jUYYJ5Vn2, ///
numeric matrix pod,numeric matrix t1, numeric matrix clases, ///
        		numeric vector jUYYJ5Vn1_ts,numeric vector tes)
        {
                real matrix jUYYJ5Vn1_old,jUYYJ5Vn2_old,jUYYJ5Vn1_s,sQaqMexR_obs,W,x2,pij		
real vector x1,vaux						
real scalar no,p,q,rws,j,i,vn,no_all,r_ts,r_ts2,no_t,rt,pt	
    no=rows(data2)
    p=rows(jUYYJ5Vn1)
    q=cols(clases)
    jUYYJ5Vn1_old=jUYYJ5Vn1
    jUYYJ5Vn2_old=jUYYJ5Vn2
    jUYYJ5Vn1_ts=jUYYJ5Vn1[.,1],J(p,2,0)
    pij=J(1,q,0)
    maux=jUYYJ5Vn1[.,1],J(p,q,0),jUYYJ5Vn1[.,6]		
    _EPsLyEaj(jUYYJ5Vn1,jUYYJ5Vn2,data2[.,2::cols(data2)],sQaqMexR_obs=.)	
    jUYYJ5Vn1_s=select(jUYYJ5Vn1[.,1],jUYYJ5Vn1[.,2]:==0)			
    rws = rows(jUYYJ5Vn1_s)
    for (j=1; j<=rws; j++) {
W=select(data2[.,1],sQaqMexR_obs[.,1]:==jUYYJ5Vn1_s[j,1])	
for (i=1; i<=q; i++) maux[jUYYJ5Vn1_s[j,1],1+i]=rows(select(W,W:==clases[1,i]))	
}
    for (i=1; i<=p; i++) {	
        if (jUYYJ5Vn1[i,2]==0) {     
            x1=maux[i,2::q+1]	
            j=jUYYJ5Vn1[i,10]
            while (j!=0) {      
                maux[j,2::q+1]=maux[j,2::q+1]+x1
                j=jUYYJ5Vn1[j,10]
                }
    	}			
    } 
for (i=1; i<=p; i++) {
 jUYYJ5Vn1_ts[i,3]=rowsum(maux[i,2::q+1])
 jUYYJ5Vn1_ts[i,2]= rowsum(select(maux[i,2::q+1],clases:!=maux[i,cols(maux)]))	
}
rws=rows(t1)
if (rows(t1)>1)  {   
for (i=1; i<=rws; i=i+2) {	
j=jUYYJ5Vn1[t1[i,1],10]      
jUYYJ5Vn1[j,(2,3,4)]=J(1,3,0)
jUYYJ5Vn1[t1[i,1],1]=0       
jUYYJ5Vn1[t1[i+1,1],1]=0     
} 				
} 					
x1=select(jUYYJ5Vn1[.,(1,2)],jUYYJ5Vn1[.,1]:!=0)	
x2=select(jUYYJ5Vn1_ts,jUYYJ5Vn1[.,1]:!=0)	
x2=select(x2,x1[.,2]:==0)		
no_all=sum(x2[.,3])
r_ts=0
r_ts2=0
for (i=1; i<=(rows(x2)); i++) {
 no_t=x2[i,3]
 rt= x2[i,2]/no_t			
 pt=no_t/no_all				
 r_ts=r_ts+rt*pt
 r_ts2=r_ts2+(no_all*rt*pt)^2
}
r_ts2=sqrt((r_ts2/no_all-(r_ts)^2)/no_all)
tes=0,rows(x2),r_ts,r_ts2		
rws=rows(pod)
for (i=2; i<=rws; i++) {			
vn=pod[i,1]		                
vaux=jUYYJ5Vn1[vn,2]\(jUYYJ5Vn1[vn,2]+1)  	
while (rows(vaux)>0) {			
  j=jUYYJ5Vn1[vaux[1,1],2]        		
  if (j!=0) vaux=vaux\j\(j+1)  		
  jUYYJ5Vn1[vaux[1,1],1]=0 			
  vaux[1,1]=0
  vaux=select(vaux,vaux:!=0)
}					
jUYYJ5Vn1[vn,(2,3,4)]=J(1,3,0) 		
x1=select(jUYYJ5Vn1[.,(1,2)],jUYYJ5Vn1[.,1]:!=0)	
x2=select(jUYYJ5Vn1_ts,jUYYJ5Vn1[.,1]:!=0)	
x2=select(x2,x1[.,2]:==0)		
no_all=sum(x2[.,3])
r_ts=0
r_ts2=0
for (j=1; j<=(rows(x2)); j++) {
 no_t=x2[j,3]
 rt= x2[j,2]/no_t			
 pt=no_t/no_all				
 r_ts=r_ts+rt*pt
 r_ts2=r_ts2+(no_all*rt*pt)^2
}
r_ts2=sqrt((r_ts2/no_all-(r_ts)^2)/no_all)
tes=tes\(i,rows(x1),r_ts,r_ts2)
}						
tes=tes[.,(3,4)]
jUYYJ5Vn1_ts[.,2]=jUYYJ5Vn1_ts[.,2]:/jUYYJ5Vn1_ts[.,3]
jUYYJ5Vn1=jUYYJ5Vn1_old;jUYYJ5Vn2=jUYYJ5Vn2_old
}	
        void _FMqdUxV2(numeric matrix jUYYJ5Vn1, numeric matrix seq, numeric matrix alph)
        {
                real matrix jUYYJ5Vn,pod
real vector hijos,wlinks,vaux
real scalar i,fin,rws,rwsl
jUYYJ5Vn=jUYYJ5Vn1		
seq=jUYYJ5Vn1[.,2]		
rws=rows(jUYYJ5Vn)
vaux=select(jUYYJ5Vn[.,(5,8)],jUYYJ5Vn[.,2]:==0)	
alph=rows(vaux)\quadcolsum(vaux[.,1]:*vaux[.,2])\0	
while (rows(select(jUYYJ5Vn,jUYYJ5Vn[.,2]:==0))>1)	{	
 pod=jUYYJ5Vn1[.,1],J(rows(jUYYJ5Vn1),3,0)		
 vaux=(jUYYJ5Vn[.,2]:!=0):*(jUYYJ5Vn[.,2]:!=-1)		
 for (i=1; i<=rws; i++) {
if (vaux[i,1]==1) {		
 hijos=jUYYJ5Vn[i,2]\jUYYJ5Vn[i,2]+1	
 fin=0
 while (fin==0) {		
   if (jUYYJ5Vn[hijos[1,1],2]==0) {	
pod[i,2]=pod[i,2]+jUYYJ5Vn[hijos[1,1],5]*jUYYJ5Vn[hijos[1,1],8]	
pod[i,3]=pod[i,3]+1					
   }
   else hijos=hijos[.,1]\jUYYJ5Vn[hijos[1,1],2]\(jUYYJ5Vn[hijos[1,1],2]+1) 
   if (rows(hijos)>1) hijos=hijos[2..rows(hijos),1]		
   else fin=1							
 }
}
 }
 pod[.,4]=(jUYYJ5Vn[.,5]:*jUYYJ5Vn[.,8]-pod[.,2]):/(pod[.,3]:-1):*(vaux[.,1]:==1)-(vaux[.,1]:==0)	
 a=colmin(select(pod[.,4],pod[.,4]:!=-1))  
 wlinks=select(pod[.,1],pod[.,4]:==a)
 rwsl=rows(wlinks)
 for (i=1; i<=rwsl; i++) {
 hijos=jUYYJ5Vn[wlinks[i,1],2]\jUYYJ5Vn[wlinks[i,1],2]+1	
 if (hijos[1,1]!=-1) {		
   jUYYJ5Vn[wlinks[i,1],2]=0		
   fin=0
   while (fin==0) {		
if (jUYYJ5Vn[hijos[1,1],2]!=0) hijos=hijos[.,1]\jUYYJ5Vn[hijos[1,1],2]\(jUYYJ5Vn[hijos[1,1],2]+1) 
jUYYJ5Vn[hijos[1,1],2]=-1	
if (rows(hijos)>1) hijos=hijos[2..rows(hijos),1]	
else fin=1						
   }
  }
 }
 seq=seq,jUYYJ5Vn[.,2]
vaux=select(jUYYJ5Vn[.,(5,8)],jUYYJ5Vn[.,2]:==0)			
alph=alph,(rows(vaux)\quadcolsum(vaux[.,1]:*vaux[.,2])\a)	
}
}	

             void _wenwun6q(numeric matrix data_t,numeric matrix N_j,numeric scalar tipo,numeric matrix pi, ///
numeric matrix costs,numeric matrix clases, numeric vector carac,numeric scalar imp_p, 		///
numeric scalar l,numeric vector imp,numeric vector not,numeric vector pt,numeric vector jstar,	///
numeric vector rt,numeric scalar pjt,numeric scalar xf,numeric scalar h)
        {
        real matrix vn, maux,v2,bloque					
real vector vx, p_j_t, p_j_t_i, p_j_t_d, N_j_t,p_t_i,p_t_d
real scalar v1,v3,v4,k,q,j,i,no_i,no_d,impi,impd,r_i,r_d,avg_imp,old_imp
old_imp=imp_p
carac=colshape(carac,2)' 
vn = carac
p_j_t=J(2,cols(clases),0)  
carac=range(1,cols(carac),1),carac'	
carac[.,3]=carac[.,3]-carac[.,2]	
carac=select(carac, carac[.,3]:!=0)	
if (rows(carac)>0) {			
v1=colmax(carac[.,3])           
k=rows(carac)			
q=cols(clases)			
maux=J(2*q*k,v1,0)              
        rx=rows(data_t)
j=1
while (j<=rx) {		
    vx=data_t[j,1]				
    vx=clases':==vx	
    i=1
    while (i<=k) {	
        v1=data_t[j,carac[i,1]+1]-carac[i,2]+1	 
        v2=carac[i,3]				
        v3=v1-1					
        v4=(i-1)*2*q				
        if (v1<=v2) maux[v4+1::v4+q,v1::v2]=maux[v4+1::v4+q,v1::v2]:+vx	
        if (v3!=0) maux[v4+q+1::v4+2*q,1::v3]=maux[v4+q+1::v4+2*q,1::v3]:+vx 
        i=i+1
        }		
    j=j+1
}			
i=1
while (i<=k) {							
    bloque=(maux[(i-1)*2*q+1::i*2*q,1::carac[i,3]])\		///
((range(carac[i,2],carac[i,2]+carac[i,3]-1,1):+0.5)')	
    v1=quadcolsum(bloque[1::q,.]):>=l		                
    v2=quadcolsum(bloque[q+1::2*q,.]):>=l	                
    v1=v1:*v2
    bloque=select(bloque',v1')'					
    	    if (rows(bloque)>0) {					
j=1
while (j<=cols(bloque)) { 				
           no_i=quadcolsum(bloque[1::q,j])
   no_d=quadcolsum(bloque[q+1::2*q,j])
   N_j_t=bloque[1::q,j]'				
   p_jt=pi:*N_j_t:/N_j
   p_t_i=quadrowsum(p_jt)
   p_j_t_i=p_jt:/p_t_i
   if (tipo==1) impi=-p_j_t_i*ln(editvalue(p_j_t_i',0,1))	
   else impi=quadsum(costs:*(p_j_t_i'*p_j_t_i))			
   r_i=colmin(costs*p_j_t_i')		
   N_j_t=bloque[q+1::2*q,j]'		
   p_jt=pi:*N_j_t:/N_j
   p_t_d=quadrowsum(p_jt)
   p_j_t_d=p_jt:/p_t_d
   if (tipo==1) impd=-p_j_t_d*ln(editvalue(p_j_t_d',0,1))	
   else impd=quadsum(costs:*(p_j_t_d'*p_j_t_d))			
   r_d=colmin(costs*p_j_t_d')	
   avg_imp=(no_i/(no_i+no_d))*impi+(no_d/(no_i+no_d))*impd		
   if (avg_imp<old_imp) {			
old_imp=avg_imp
xf=carac[i,1]
h=bloque[rows(bloque),j]
imp=impi\impd
rt=r_i\r_d
not=no_i\no_d
pt=p_t_i\p_t_d
v3=select(clases,p_j_t_i*costs':==r_i)
v4=select(clases,p_j_t_d*costs':==r_d)
jstar=v3[1,1]\v4[1,1]
pjt=p_j_t_i\p_j_t_d
   }
   j=j+1
  }  			
    }				
    i=i+1
    }				
}	                               	
 	}	

 	        void _GE94DHek(numeric matrix data,numeric scalar tipo,numeric matrix pi,  ///
numeric matrix costs,numeric matrix clases, 	///
numeric scalar l,numeric matrix jUYYJ5Vn1,numeric matrix jUYYJ5Vn2,numeric matrix jUYYJ5Vn3)
        {
                real matrix depvar,splvar,xaux,pjt,carac,pi_j,N_j,N_j_t,p_jt,p_j_t,data_t		
real scalar no,xf,h,nrows,k,i,imp,jstar,s,fin,c,rt,pt,r
depvar=data[.,1]
no=rows(depvar)
splvar=data[.,2::cols(data)]
jUYYJ5Vn1=1,J(1,8,-1),0 					
jUYYJ5Vn1[1,5]=1						
jUYYJ5Vn3=rowshape((colmin(splvar)\colmax(splvar))',1)	
k=cols(clases)						
N_j=J(1,k,0)						
for (i=1; i<=k; i++) { 
 	N_j[1,i]=rows(select(depvar,depvar:==clases[1,i]))
 	}
N_j_t=N_j						
p_jt=pi:*N_j_t:/N_j
p_j_t=p_jt:/quadrowsum(p_jt)
jUYYJ5Vn2=p_j_t
if (tipo==1) imp=-p_j_t*ln(editvalue(p_j_t',0,1))	
else imp=quadsum(costs:*(p_j_t'*p_j_t))			
r=colmin(costs*p_j_t')				
jstar=select(clases,p_j_t*costs':==r)	
jUYYJ5Vn1[1,6]=jstar[1,1]			
jUYYJ5Vn1[1,7]=imp				
jUYYJ5Vn1[1,8]=r				
jUYYJ5Vn1[1,9]=no				
s=1                             
c=2                             
carac=colshape(jUYYJ5Vn3[s,.],2)'         
carac=range(1,cols(carac),1),carac'	
k=rows(carac)			
carac=select(carac, carac[.,2]:!=carac[.,3])	
if (rows(carac)==0) {			
fin=1				
jUYYJ5Vn1[s,2::4]=(0,0,0)
}
else fin=0				
while (fin==0) {		
 if (jUYYJ5Vn1[s,2]==-1) {		
  xaux=colshape(jUYYJ5Vn3[s,.],2)'	
  data_t=select(data,(quadrowsum((splvar:<=xaux[2,.]):*(splvar:>=xaux[1,.])):==cols(splvar)))	
  if (rows(data_t)>0) {			
   _wenwun6q(data_t,N_j,tipo,pi,costs,clases,jUYYJ5Vn3[s,.],jUYYJ5Vn1[s,7],l,imp=.,no=.,pt=.,jstar=.,rt=.,pjt=.,xf=.,h=.)
    if (xf!=.){				
jUYYJ5Vn1[s,2::4]=(c,xf,h)		
xaux = ((c\c+1),(J(2,3,-1)),pt,jstar,imp,rt,no,J(2,1,s)) 
if (no[1,1]<=l) xaux[1,(2,3,4)]=J(1,3,0)		
if (no[2,1]<=l) xaux[2,(2,3,4)]=J(1,3,0)		
jUYYJ5Vn1=jUYYJ5Vn1\xaux						
jUYYJ5Vn2=jUYYJ5Vn2\pjt						
xaux=jUYYJ5Vn3[s,.]#J(2,1,1)					
xaux[1,2*xf]=(h-0.5)
xaux[2,2*xf-1]=(h+0.5)
jUYYJ5Vn3=jUYYJ5Vn3\xaux					
xaux=colshape(xaux,2)				
nrows=rows(xaux)/2
if (xaux[1::nrows,1]==xaux[1::nrows,2]) jUYYJ5Vn1[rows(jUYYJ5Vn1)-1,(2,3,4)]=J(1,3,0)	
if (xaux[(nrows+1)::(2*nrows),1]==xaux[(nrows+1)::(2*nrows),2]) jUYYJ5Vn1[rows(jUYYJ5Vn1),(2,3,4)]=J(1,3,0)	
c=c+2			
    } 				
    else jUYYJ5Vn1[s,2::4]=J(1,3,0)	
  } 
}   
s=s+1
if (s==(rows(jUYYJ5Vn1)+1)) fin=1					
}				
      }	

        void _REAj4BLL(string scalar depvar_s, string scalar splvar_s, /// 
string scalar smpl_s, string scalar learn_smpl_s, string scalar test_smpl_s, /// 
numeric scalar l, numeric scalar rule, string scalar impureza, string scalar pi, ///
string scalar costs,numeric scalar vcv,string scalar jUYYJ5Vnol_s,string scalar coeficientes_s, 	///
string scalar ajustes_s,string scalar criterios_s,string scalar predicciones_s, 	///
string scalar minmax_s,string scalar podas_s,string scalar secuencia_s,string scalar clases_s)
       {
real matrix splvar,splvar_ts,splvar_all,data,data_ts,data_all,jUYYJ5Vn1,jUYYJ5Vn2,jUYYJ5Vn3,pod,t1,tes,	///
jUYYJ5Vn1_ts,jUYYJ5Vn1_ts_bs,jUYYJ5Vn2_ts,jUYYJ5Vn2_ts_bs,min,jUYYJ5Vn1_h,sQaqMexRs,predicciones,jUYYJ5Vnol,criterios,	///
podas,v_original,v_new,v_old,equi,equi_col,newvars,clases,coeficientes,sigma,ajustes,	///
minmax,rmse,seq,rmse_bs,data_ts_v,data_v,aux,Tmin,Tstar
real vector depvar, depvar_ts,depvar_all,constante, constante_ts,constante_all,tipo,alph
real scalar no,no_ts,no_all,k,max,i,r,r_ts,j,columna,rws,cols_a
depvar=st_data(.,tokens(depvar_s),learn_smpl_s)
no=rows(depvar)
clases=uniqrows(depvar)'		
constante=J(no,1,1)
depvar_ts=st_data(.,tokens(depvar_s),test_smpl_s)
no_ts=rows(depvar_ts)
constante_ts=J(no_ts,1,1)
depvar_all = st_data(., tokens(depvar_s),smpl_s)
no_all=rows(depvar_all)
constante_all=J(no_all,1,1)
tipo=(impureza=="entropy")+2*(impureza=="gini")		
pi=(st_matrix(pi))'
costs=(st_matrix(costs))
        if (splvar_s=="") {
        	splvar=constante
        	splvar_ts=constante_ts
        	splvar_all=constante_all
        	}
        else {
splvar = st_data(., tokens(splvar_s),learn_smpl_s)
        	splvar_ts = st_data(.,tokens(splvar_s),test_smpl_s)
splvar_all = st_data(., tokens(splvar_s),smpl_s)
minmax=0,rowshape((colmin(splvar_all)\colmax(splvar_all))',1)
k=cols(splvar)
r=rows(splvar)
r_ts=rows(splvar_ts)
r_all=rows(splvar_all)
max=0
for (i=1; i<=k; i++) max=colmax((rows(uniqrows(splvar_all[.,i]))\max))
equi=J(max,2*k,.)
i=1
for (i=1; i<=k; i++) {
j=(i-1)*2+1
equi_col=uniqrows(splvar_all[.,i])
equi_col=equi_col,runningsum(J(rows(equi_col),1,1))
equi[1::rows(equi_col),j::j+1]=equi_col
splvar[.,i]=(splvar[.,i]:==(equi_col[.,1]')#J(r,1,1))*equi_col[.,2]
splvar_ts[.,i]=(splvar_ts[.,i]:==(equi_col[.,1]')#J(r_ts,1,1))*equi_col[.,2]
splvar_all[.,i]=(splvar_all[.,i]:==(equi_col[.,1]')#J(r_all,1,1))*equi_col[.,2]
}
}
        data=depvar,splvar
        data_ts=depvar_ts,splvar_ts
        data_all=depvar_all,splvar_all
_GE94DHek(data,tipo,pi,costs,clases,l,jUYYJ5Vn1=.,jUYYJ5Vn2=.,jUYYJ5Vn3=.)	
_FMqdUxV2(jUYYJ5Vn1,seq=.,alph=.)					
if (vcv==2147483647) _yAk6bvkx(data_ts,pi,costs,jUYYJ5Vn1,jUYYJ5Vn3,seq,clases,jUYYJ5Vn1_ts=.,tes=.)
if (vcv!=2147483647) {
_yAk6bvkx(data_ts,pi,costs,jUYYJ5Vn1,jUYYJ5Vn3,seq,clases,jUYYJ5Vn1_ts=.,tes=.)
aux=sort((data,runiform(no,1)),k+2)	
data=aux[.,1..k+1]
cols_a=cols(alph)
j=J(1,cols_a,0)
aux=floor(rows(data)/(100/vcv))#J(floor(rows(data)/floor(rows(data)/(100/vcv))),1,1)
i=rows(data)-quadcolsum(aux)
if (i!=0 & i<rows(aux)) aux=aux:+(J(i,1,1)\J(rows(aux)-i,1,0))
else aux = aux\i
rws=rows(aux)
v_new=J(aux[1,1],1,1)
        for (i=2; i<=rws; i++) v_new=v_new\J(aux[i,1],1,i)
tes=alph[1,.]\J(2,cols_a,0)
        for (i=1; i<=rws; i++) {
    data_ts_v=select(data,v_new:==i)	
    data_v=select(data,v_new:!=i)	
    _GE94DHek(data_v,tipo,pi,costs,clases,l,jUYYJ5Vn1_v=.,jUYYJ5Vn2_v=.,jUYYJ5Vn3_v=.)	
    _FMqdUxV2(jUYYJ5Vn1_v,seq_v=.,alph_v=.)					
            _yAk6bvkx(data_ts_v,pi,costs,jUYYJ5Vn1_v,jUYYJ5Vn3_v,seq_v,clases,jUYYJ5Vn1_ts_v=.,tes_v=.)
    max_a=rowmax((alph[3,.],alph_v[3,.]))+10
    aux=((alph[3,.]':<=alph_v[3,.]#J(cols_a,1,1)):* ///
((alph[3,2::cols_a],max_a)':>=alph_v[3,.]#J(cols_a,1,1)))
    j=j+(quadrowsum(aux):>0)'
    tes[2,.]=tes[2,.]:+editmissing(quadrowsum(aux:*(tes_v[2,.]#J(cols_a,1,1))):/quadrowsum(aux),0)'
    tes[3,.]=tes[3,.]:+editmissing(quadrowsum(aux:*(tes_v[3,.]#J(cols_a,1,1))):/quadrowsum(aux),0)'
}
tes[(2,3),.]=tes[(2,3),.]:/j
                }
_gSY5Ek89(jUYYJ5Vn1,seq,tes,rule,Tmin=.,Tstar=.,jUYYJ5Vn1_h=.) 		
_EPsLyEaj(jUYYJ5Vn1_h,jUYYJ5Vn3,(data_all[.,2::cols(data_all)]),sQaqMexRs=.)	
jUYYJ5Vn1_ter=select(jUYYJ5Vn1_h,jUYYJ5Vn1_h[.,2]:==0)
predicciones=(sQaqMexRs[.,1]:==jUYYJ5Vn1_ter[.,1]'#J(rows(sQaqMexRs),1,1))*jUYYJ5Vn1_ter[.,6]	
jUYYJ5Vnol=jUYYJ5Vn1_h[.,1..4]
r=rows(jUYYJ5Vn1_h)	
for (i=1; i<=r; i++) {
v_old=jUYYJ5Vnol[i,3]	
if (v_old!=0) {
equi_col=select(equi[.,(v_old-1)*2+1::(v_old-1)*2+2],equi[.,(v_old-1)*2+1]:!=.)	
jUYYJ5Vnol[i,4]=(equi_col[jUYYJ5Vn1_h[i,4]-0.5,1]+equi_col[jUYYJ5Vn1_h[i,4]+0.5,1])/2
}			
if (jUYYJ5Vnol[i,2]==0) jUYYJ5Vnol[i,3..4]=J(1,2,0)
}
jUYYJ5Vnol=select(jUYYJ5Vnol,jUYYJ5Vn1_h[.,2]:!=-1)
_5MmwTVMH(jUYYJ5Vn1_h,jUYYJ5Vn3,(data_all[.,2::cols(data_all)]),equi,sQaqMexRs,criterios=.) 
coeficientes=jUYYJ5Vn1_h[.,(1,6,8,9)],jUYYJ5Vn2
coeficientes=select(coeficientes,jUYYJ5Vn1_h[.,2]:==0)
podas=sort((alph[(1,2),.]\tes[(2,3),.])',1)
ajustes=select(podas,podas[.,1]:==Tmin)\select(podas,podas[.,1]:==Tstar)
st_matrix(jUYYJ5Vnol_s,jUYYJ5Vnol)
st_matrix(coeficientes_s,coeficientes)
st_matrix(criterios_s,criterios)
newvars = st_addvar("float", (predicciones_s))
st_store(.,newvars,smpl_s,predicciones)
st_matrix(minmax_s,minmax)
st_matrix(podas_s,podas)
st_matrix(ajustes_s,ajustes)
st_matrix(secuencia_s,seq)
st_matrix(clases_s,clases)
}	

        void _PKzTnqtq(string scalar depvar_s, string scalar splvar_s, string scalar smpl_s,	///
numeric scalar l,string scalar impureza, string scalar pi,string scalar costs,	///
numeric scalar bootstraps,numeric scalar rsampling,numeric scalar rsplitting,	///
string scalar oob,string scalar classpred_s,string scalar missprob_s,		///
string scalar matatree,string scalar clases_s)
       {
                real matrix tipo,splvar,equi,equi_col,data,jUYYJ5Vn1,jUYYJ5Vn2,x,x_ts,aux,		///
jUYYJ5Vn1_v,jUYYJ5Vn2_v,jUYYJ5Vn3_v,sQaqMexRs,trees,coefficients,criteria,v_old
real vector depvar,clases,constante,orden,splitvar_ind,pred,misspr,num_ts,v,v_ts,	///
pred_v,misspr_v,minmax
real scalar no,q,k,r,max,i,j,k_bs,no_bs

depvar=st_data(.,tokens(depvar_s),smpl_s)
no=rows(depvar)
clases=uniqrows(depvar)'	
q=cols(clases)
constante=J(no,1,1)
orden=runningsum(J(no,1,1))
tipo=(impureza=="entropy")+2*(impureza=="gini")	
pi=(st_matrix(pi))'
costs=(st_matrix(costs))
        if (splvar_s=="") splvar=constante
        else {
splvar = st_data(., tokens(splvar_s),smpl_s)
k=cols(splvar)
r=rows(splvar)
max=0
for (i=1; i<=k; i++) max=colmax((rows(uniqrows(splvar[.,i]))\max))
equi=J(max,2*k,.)
i=1
for (i=1; i<=k; i++) {
j=(i-1)*2+1
equi_col=uniqrows(splvar[.,i])
equi_col=equi_col,runningsum(J(rows(equi_col),1,1))
equi[1::rows(equi_col),j::j+1]=equi_col
splvar[.,i]=(splvar[.,i]:==(equi_col[.,1]')#J(r,1,1))*equi_col[.,2]
}
}
minmax=rowshape((colmin(splvar)\colmax(splvar))',1)
        data=depvar,splvar
k=cols(splvar)				
k_bs=colmax((floor(k*rsplitting)\1))	
no_bs=floor(no*rsampling)		
splitvar_ind=1:+runningsum(J(k,1,1))
pred=J(no,q,0)
misspr=J(no,1,0)
num_ts=misspr
    	for (i=1; i<=bootstraps; i++) {
if (rsampling==1) v=ceil(no*runiform(no,1))	
if (rsampling<1) {				
v=jumble(orden)
v=v[1::no_bs,.]
}
x=data[v,.]
if (oob!="") v_ts=rowsum(orden:==v'#J(no,1,1)):==0	
else v_ts=J(no,1,1)
aux=jumble(splitvar_ind)
aux=sort(aux[k_bs+1::rows(aux),1],1)		
x[.,(aux')]=J(no_bs,rows(aux),1)		
_GE94DHek(x,tipo,pi,costs,clases,l,jUYYJ5Vn1_v=.,jUYYJ5Vn2_v=.,jUYYJ5Vn3_v=.)	
jUYYJ5Vn3_v[.,(rowshape((-3:+2:*aux,-2:+2:*aux),1))]=		/// 
minmax[.,(rowshape((-3:+2:*aux,-2:+2:*aux),1))]#J(rows(jUYYJ5Vn3_v),1,1)
jUYYJ5Vn1=(i==1? jUYYJ5Vn1_v: jUYYJ5Vn1\jUYYJ5Vn1_v )
jUYYJ5Vn2=(i==1? jUYYJ5Vn2_v[.,1..q] : jUYYJ5Vn2\jUYYJ5Vn2_v[.,1..q] )
jUYYJ5Vn3=(i==1? jUYYJ5Vn3_v : jUYYJ5Vn3\jUYYJ5Vn3_v)
_EPsLyEaj(jUYYJ5Vn1_v,jUYYJ5Vn3_v,(data[.,2::cols(data)]),sQaqMexRs=.)	
pred_v=(sQaqMexRs[.,1]:==jUYYJ5Vn1_v[.,1]'#J(rows(sQaqMexRs),1,1))*jUYYJ5Vn1_v[.,6]	
misspr_v=(sQaqMexRs[.,1]:==jUYYJ5Vn1_v[.,1]'#J(rows(sQaqMexRs),1,1))*jUYYJ5Vn1_v[.,8]	
num_ts=num_ts:+v_ts
pred=pred:+(pred_v:==clases#J(no,1,1)):*v_ts
misspr=misspr:+misspr_v:*v_ts
if (ceil(i/10)==i/10) stata(`"noi dis in y "." _continue"')
if (ceil(i/500)==i/500) i
if (i==bootstraps) ""
    		}
    	for (i=1; i<=q; i++) {		
j =( i==1 ? J(no,1,clases[1,1]) : ((j:*(pred[.,1]:>=pred[.,i])):+(clases[1,i]:*(pred[.,1]:<pred[.,i]))))
pred[.,1]= ((pred[.,1]:*(pred[.,1]:>=pred[.,i])):+(pred[.,i]:*(pred[.,1]:< pred[.,i])))
}
pred=j
misspr=misspr:/num_ts
trees=jUYYJ5Vn1[.,1::4]
criteria=jUYYJ5Vn3
coefficients=jUYYJ5Vn1[.,(1,6,8,9)],jUYYJ5Vn2
r=rows(trees)
for (i=1; i<=r; i++) {
v_old=trees[i,3]	
if (v_old!=0) {
equi_col=select(equi[.,(v_old-1)*2+1::(v_old-1)*2+2],equi[.,(v_old-1)*2+1]:!=.)	
trees[i,4]=(equi_col[trees[i,4]-0.5,1]+equi_col[trees[i,4]+0.5,1])/2
}			
}
ra = rows(criteria)
for (j=1; j<=ra; j++) {
jUYYJ5Vn3_sQaqMexR=criteria[j,.]
for (i=1; i<=k; i++) {	
columna=(i-1)*2+1
equi_col=select(equi[.,columna::columna+1],equi[.,columna]:!=.)
jUYYJ5Vn3_sQaqMexR[1,columna]=equi_col[jUYYJ5Vn3_sQaqMexR[1,columna],1]
jUYYJ5Vn3_sQaqMexR[1,columna+1]=equi_col[jUYYJ5Vn3_sQaqMexR[1,columna+1],1]
}
criteria[j,.]=jUYYJ5Vn3_sQaqMexR
}
criteria=jUYYJ5Vn1[.,1],criteria
newvars = st_addvar("float", (classpred_s))
st_store(.,newvars,smpl_s,pred)
newvars = st_addvar("float", (missprob_s))
st_store(.,newvars,smpl_s,misspr)
st_matrix(clases_s,clases)
fh=fopen(matatree, "w")
fputmatrix(fh, trees)
fputmatrix(fh, criteria)
fputmatrix(fh, coefficients)
fclose(fh)
}	
end	
exit	
