program define mvdcmp
*! version 2.0 19jun2019 Dan Powers
////////////////////////////////////////////////////////////////////////////////////
//  -mvdcmpgroup- (now appears to work with Stata 15)
// 6/19/19 nbreg?
// fixed: parameter name problem in nbreg resulting in Stata version changes 
// broke: the norm option (devcon)
// solution: force version 12 in nbreg
// fixed output format 12feb2019
// reformated output table for long variable names 08aug2018
// iweights implemented 07apr2018
// cluster and robust options 25apr2017
// major update 17sept2010
//  added new PDFs(x1,b1,wv1) for logit, probit, poisson, nbreg and cll
//  changed from e(Var) to e(V), e(Coef) to e(b)
//  version 10 added 17sept2010 
//  e(sample) added  06apr2010
// 
/////////////////////////////////////////////////////////////////////////////////////
version 15.0
gettoken mvdcmp_cmd model:0, parse(":")
gettoken grp 1:mvdcmp_cmd, parse(",")
gettoken 1 options:1
gettoken colon model:model
gettoken cmd model:model
gettoken model moptions:model, parse(",")
gettoken moptions moptions:moptions, parse(",")
nobreak {
global mvdcmp_grp `grp'
local 0 `model', by(`grp') `options' `moptions'  
if ("`cmd'"=="logit"){
logitDecomp `0'
}
else if ("`cmd'"=="poisson"){
PoissonDecomp `0'
}
else if ("`cmd'"=="probit"){
probitDecomp `0'
}
else if ("`cmd'"=="nbreg"){
nbregDecomp `0'
}
else if ("`cmd'"=="cloglog"){
CLLDecomp `0'
}
else if substr("`cmd'",1,3)=="reg" {
linearDecomp `0'
}

else{
di as error "mvdcmp only accepts regress, logit, probit, poisson, nbreg, and cloglog commands"
macro drop mvdcmp_*
 }
}
end

program linearDecomp 
syntax anything(id="varlist") [fw pw aw iw] , BY(varname) ///
    [REVerse NORmal(string) Scale(integer 1) CLUSter(varname) ROBust]
// 
tempname matrix
capture tab `by', matrow(`matrix')
if _rc==0 & r(r)!=2 {
di as error "group variable (i.e., `by') must take exactly two values"
macro drop mvdcmp_*
}

else{
gettoken cmd newvarlist:newvarlist
tempvar _cons
gen `_cons'=1
gettoken depvar varlist:anything
local weight [`weight'`exp']

*****Means, determining high-low order
if substr("`weight'",2,2)=="pw" | substr("`weight'",2,2)=="fw" ///
 | substr("`weight'",2,2)=="aw" | substr("`weight'",2,2)=="iw" {
	gettoken depvar varlist:anything
	local tempweight [`weight'`exp']
	gettoken w1 wv: tempweight, parse("=")
	gettoken wv wv: wv
	gettoken wv test: wv, parse("]")
}
else{
tempvar wv
gen `wv' = 1
}



// Means, determining high-low order (regress only)
forvalue row = 1/2 {
mata: wv`row'=0
mata: st_view(wv`row', ., (tokens("`wv'")), "`touse'")
mata: dv`row'=0
mata: st_view(dv`row', ., (tokens("`depvar'")), "`touse'")
mata: m`row'=sum(dv`row':*wv`row')/sum(wv`row')
mata: st_matrix("m`row'", m`row')
local m`row' = m`row'[1,1]
    }

if (`m2'>=`m1' & "`reverse'"=="") | (`m2'<`m1' & "`reverse'"!="") {
        local val0 = `matrix'[2,1]
        local val1 = `matrix'[1,1]
    }
    else {
        local val0 = `matrix'[1,1]
        local val1 = `matrix'[2,1]
        }
//handle model options robust and cluster
if ("`robust'"!="")  {
  local ropt = "robust"
  }
  else { 
  local ropt = ""
  }

if ("`cluster'"!="") {
  local copt = "cluster(`varname')"
  }
  else { 
  local copt = ""
 }
 

//estimation by group 

forval i = 0/1 {

qui regress `depvar' `varlist' `weight' if `by'==`val`i'' , `ropt' `copt' 

  
local normal`i' `normal'
if "`normal`i''"!=""{
local j 0
local k 0
while (1) {
        if "`normal`i''" == "" continue, break
        gettoken gvars normal`i': normal`i', parse("|")
        unab gvars: `gvars'
        devcon, group(`gvars') nonoise
        local gvars`++j' `gvars'
        if "`normal`i''"!=""{
        gettoken bar normal`i' : normal`i', parse("|")
        }
        local nnormal `++k'
        }
}
global mvdcmp_lab`i' "`by'==`val`i''"
local df`i' = e(df_m)

tempvar touse
gen `touse'=0
qui replace `touse'=1 if `by'==`val`i''

mata: x`i'=0
mata: b`i'=st_matrix("e(b)")
local modvarlist: colnames e(b)
local cons _cons
local modvarlist2: list modvarlist - cons
mata: st_view(x`i', ., (tokens("`modvarlist2'"), "`_cons'"), "`touse'")
//
if substr("`weight'",2,2)=="pw" | substr("`weight'",2,2)=="fw" | ///
   substr("`weight'",2,2)=="iw" | substr("`weight'",2,2)=="aw" {
gettoken temp wv : weight, parse("=")
gettoken temp wv : wv
gettoken tempwv wv : wv, parse("]")
mata: wv`i'=0
mata: st_view(wv`i', ., (tokens("`tempwv'")), "`touse'")
}
else{
tempvar tempwv
gen `tempwv' = 1
mata: wv`i'=0
mata: st_view(wv`i', ., (tokens("`tempwv'")), "`touse'")
}

mata: xMean`i'=mean(x`i':*wv`i'):/mean(wv`i')
mata: varb`i'=st_matrix("e(V)")
}

if `df0'!=`df1' {
        di as error "Number of regressors differs between the groups"
        di as error "Perhaps a variable was dropped in one of the groups defined by `by'"
        exit
}

nobreak {
mata:Wdx=Wdx_F(xMean0, xMean1, b0)
mata:Wdb=Wdb_F(b0, b1, xMean1)
mata:wbA=dwA_F(b0, b1, xMean1)
mata:wbB=dwB_F(b0, b1, xMean1)
mata:dWx=dW_F(b0, xMean0, xMean1)
mata:E=mean(CDF_Linear(x0, b0, wv0))/mean(wv0) - mean(CDF_Linear(x1, b0, wv1))/mean(wv1)
mata:C=mean(CDF_Linear(x1, b0, wv1))/mean(wv1) - mean(CDF_Linear(x1, b1, wv1))/mean(wv1)
mata:PDF0=PDF_Linear(wv0)
mata:PDF1=PDF_Linear(wv1)
mata:dCdb1=dCdb1(x1, Wdb, wbA, wv1, PDF1, C)
mata:dCdb2=dCdb2(x1, Wdb, wbB, wv1, PDF1, C)
mata:dEdb=dEdb(x0, x1, Wdx, dWx, E, wv0, wv1, PDF0, PDF1)
mata:Var_E_k=varcomp(dEdb, varb0)
mata:seWdx=colsum(sqrt(diag(Var_E_k)))
mata:Var_C_k=varcoef(dCdb1, dCdb2, varb0, varb1)
mata:seWdb=colsum(sqrt(diag(Var_C_k)))
mata:dCdb0A=dCdbA(x1, wv1, PDF1)
mata:dCdb0B=dCdbA(x1, wv1, PDF1)
mata:dEdb0=dEdb0(x0,x1,wv0,wv1, PDF0, PDF1)
mata:sE0=sqrt(varE(dEdb0, varb0))
mata:sC0=sqrt(varC(varb0, varb1, dCdb0A, dCdb0B))
mata:temp=J(cols(dEdb),cols(dEdb),0)
mata:eV=((dEdb,temp)\(dCdb1,dCdb2))*(varb0,temp\temp,varb1)*((dEdb,temp)\(dCdb1,dCdb2))'
mata:sR0=sqrt(sum(eV))
eret clear
global mvdcmp_scale `scale'
global mvdcmp_varlist `modvarlist2'
global mvdcmp_nvarlist "`modvarlist2' _cons"
global mvdcmp_depvar `depvar'
setresult
displayresult
macro drop mvdcmp_*
 }
}
end

program logitDecomp, eclass
syntax anything(id="varlist") [fw pw iw], BY(varname) ///
[REVerse NORmal(string) Scale(integer 1) CLUster(varname) ROBust] 
tempname matrix
capture tab `by', matrow(`matrix')
if _rc==0 & r(r)!=2 {
di as error "group variable (i.e., `by') must take exactly two values"
macro drop mvdcmp_*
}
else{
tempvar _cons
gen `_cons'=1
gettoken depvar varlist:anything
local weight [`weight'`exp']
if   substr("`weight'",2,2)=="pw" | substr("`weight'",2,2)=="fw" |  ///
     substr("`weight'",2,2)=="iw" {
gettoken depvar varlist:anything
local tempweight [`weight'`exp']
gettoken w1 wv: tempweight, parse("=")
gettoken wv wv: wv
gettoken wv test: wv, parse("]")
}
else{
tempvar wv
gen `wv' = 1
}
forvalue row = 1/2 {
mata:wv`row'=0
mata:st_view(wv`row', ., (tokens("`wv'")), "`touse'")
mata:dv`row'=0
mata:st_view(dv`row', ., (tokens("`depvar'")), "`touse'")
mata:m`row'=sum(dv`row':*wv`row')/sum(wv`row')
mata:st_matrix("m`row'", m`row')
local m`row' = m`row'[1,1]
    }
if (`m2'>=`m1' & "`reverse'"=="") | (`m2'<`m1' & "`reverse'"!="") {
        local val0 = `matrix'[2,1]
        local val1 = `matrix'[1,1]
    }
    else {
        local val0 = `matrix'[1,1]
        local val1 = `matrix'[2,1]
        }
// handle model options robust and cluster
if ("`robust'"!="")  {
  local ropt = "robust"
  }
  else { 
  local ropt = ""
  }

if ("`cluster'"!="") {
  local copt = "cluster(`varname')"
  }
  else { 
  local copt = ""
 }

// estimation by group
forval i = 0/1 {
qui logit `depvar' `varlist' `weight' if `by'==`val`i'' , `ropt' `copt'
local normal`i' `normal'
if "`normal`i''"!=""{
local j 0
local k 0
while (1) {
        if "`normal`i''" == "" continue, break
        gettoken gvars normal`i': normal`i', parse("|")
        unab gvars: `gvars'
        qui devcon, group(`gvars') nonoise
        local gvars`++j' `gvars'
        if "`normal`i''"!=""{
        gettoken bar normal`i' : normal`i', parse("|")
        }
        local nnormal `++k'
        }
}
global mvdcmp_lab`i' "`by'==`val`i''"
local df`i' = e(df_m)
tempvar touse
gen `touse'=0
qui replace `touse'=1 if `by'==`val`i''
mata: x`i'=0
mata: b`i'=st_matrix("e(b)")
local modvarlist: colnames e(b)
local cons _cons
local modvarlist2: list modvarlist - cons
mata: st_view(x`i', ., (tokens("`modvarlist2'"), "`_cons'"), "`touse'")
mata: wv`i'=0
mata: st_view(wv`i', ., (tokens("`wv'")), "`touse'")
mata: xMean`i'=mean(x`i')
mata: xMean`i'=mean(x`i':*wv`i'):/mean(wv`i')
mata: varb`i'=st_matrix("e(V)")
}
//check if the number of independent variables
//included in each model is identical
if `df0'!=`df1' {
        di as error "Number of regressors differs between the groups"
        di as error "Perhaps a variable was dropped in one of the groups defined by `by'"
        macro drop mvdcmp_*
        exit
}
nobreak {
mata:Wdx=Wdx_F(xMean0, xMean1, b0)
mata:Wdb=Wdb_F(b0, b1, xMean1)
mata:wbA=dwA_F(b0, b1, xMean1)
mata:wbB=dwB_F(b0, b1, xMean1)
mata:dWx=dW_F(b0, xMean0, xMean1)
mata:E=mean(CDF_lgt(x0, b0, wv0))/mean(wv0) - mean(CDF_lgt(x1, b0, wv1))/mean(wv1)
mata:C=mean(CDF_lgt(x1, b0, wv1))/mean(wv1) - mean(CDF_lgt(x1, b1, wv1))/mean(wv1)
mata:PDF00=PDF_lgt(x0, b0, wv0)  /*changed from 0 to 00 20100917*/
mata:PDF10=PDF_lgt(x1, b0, wv1)  /*changed from 1 to 10 20100917*/
mata:PDF11=PDF_lgt(x1, b1, wv1)  /*newly added 20100917*/
mata:dCdb1=dCdb1(x1, Wdb, wbA, wv1, PDF10, C) /*changed from 1 to 10 20100917*/
mata:dCdb2=dCdb2(x1, Wdb, wbB, wv1, PDF11, C) /*changed from 1 to 11 20100917*/
mata:dEdb=dEdb(x0, x1, Wdx, dWx, E, wv0, wv1, PDF00, PDF10) /*changed here too 20100917*/
mata:Var_E_k=varcomp(dEdb, varb0)
mata:seWdx=colsum(sqrt(diag(Var_E_k)))
mata:Var_C_k=varcoef(dCdb1, dCdb2, varb0, varb1)
mata:seWdb=colsum(sqrt(diag(Var_C_k)))
mata:dCdb0A=dCdbA(x1, wv1, PDF10) /*changed 1 to 10 20100917*/
mata:dCdb0B=dCdbA(x1, wv1, PDF11) /*changed 1 to 11 20100917*/
mata:dEdb0=dEdb0(x0,x1,wv0,wv1, PDF00, PDF10) /*changed here 20100917*/
mata:sE0=sqrt(varE(dEdb0, varb0))
mata:sC0=sqrt(varC(varb0, varb1, dCdb0A, dCdb0B))
mata:temp=J(cols(dEdb),cols(dEdb),0)
mata:eV=((dEdb,temp)\(dCdb1,dCdb2))*(varb0,temp\temp,varb1)*((dEdb,temp)\(dCdb1,dCdb2))'
mata:sR0=sqrt(sum(eV))
eret clear
global mvdcmp_scale `scale'
global mvdcmp_varlist `modvarlist2'
global mvdcmp_nvarlist "`modvarlist2' _cons"
global mvdcmp_depvar `depvar'
setresult
displayresult
macro drop mvdcmp_*
  }
 }
end

program probitDecomp, eclass
syntax anything(id="varlist") [fw pw iw], BY(varname) ///
[,REVerse NORmal(string) Scale(integer 1) CLUSter(varname) ROBust]
tempname matrix
capture tab `by', matrow(`matrix')
if _rc==0 & r(r)!=2 {
di as error "group variable (i.e., `by') must take exactly two values"
macro drop mvdcmp_*
}
else{
tempvar _cons
gen `_cons'=1
gettoken depvar varlist:anything
local weight [`weight'`exp']
if substr("`weight'",2,2)=="pw" | substr("`weight'",2,2)=="fw" | substr("`weight'",2,2)=="iw" {
gettoken depvar varlist:anything
local tempweight [`weight'`exp']
gettoken w1 wv: tempweight, parse("=")
gettoken wv wv: wv
gettoken wv test: wv, parse("]")
}
else{
tempvar wv
gen `wv' = 1
}
forvalue row = 1/2 {
mata:wv`row'=0
mata:st_view(wv`row', ., (tokens("`wv'")), "`touse'")
mata:dv`row'=0
mata:st_view(dv`row', ., (tokens("`depvar'")), "`touse'")
mata:m`row'=sum(dv`row':*wv`row')/sum(wv`row')
mata:st_matrix("m`row'", m`row')
local m`row' = m`row'[1,1]
    }
if (`m2'>=`m1' & "`reverse'"=="") | (`m2'<`m1' & "`reverse'"!="") {
        local val0 = `matrix'[2,1]
        local val1 = `matrix'[1,1]
    }
    else {
        local val0 = `matrix'[1,1]
        local val1 = `matrix'[2,1]
        }

// handle model options robust and cluster
if ("`robust'"!="")  {
  local ropt = "robust"
  }
  else { 
  local ropt = ""
  }

if ("`cluster'"!="") {
  local copt = "cluster(`varname')"
  }
  else { 
  local copt = ""
 }
  

// estimation by group
forval i = 0/1 {
qui probit `depvar' `varlist' `weight' if `by'==`val`i'' , `ropt' `copt'
local normal`i' `normal'
if "`normal`i''"!=""{
local j 0
local k 0
while (1) {
        if "`normal`i''" == "" continue, break
        gettoken gvars normal`i': normal`i', parse("|")
        unab gvars: `gvars'
        qui devcon, group(`gvars') nonoise
        local gvars`++j' `gvars'
        if "`normal`i''"!=""{
        gettoken bar normal`i' : normal`i', parse("|")
        }
        local nnormal `++k'
        }
}

global mvdcmp_lab`i' "`by'==`val`i''"
local df`i' = e(df_m)
tempvar touse
gen `touse'=0
qui replace `touse'=1 if `by'==`val`i''
mata: x`i'=0
mata: b`i'=st_matrix("e(b)")
local modvarlist: colnames e(b)
local cons _cons
local modvarlist2: list modvarlist - cons
mata: st_view(x`i', ., (tokens("`modvarlist2'"), "`_cons'"), "`touse'")
mata: wv`i'=0
mata: st_view(wv`i', ., (tokens("`wv'")), "`touse'")
mata: xMean`i'=mean(x`i')
mata: xMean`i'=mean(x`i':*wv`i'):/mean(wv`i')
mata: varb`i'=st_matrix("e(V)")
}
//check if the number of independent variables
//included in each model is identical
if `df0'!=`df1' {
        di as error "Number of regressors differs between the groups"
        di as error "Perhaps a variable was dropped in one of the groups defined by `by'"
        macro drop mvdcmp_*
        exit
}
nobreak{
mata:Wdx=Wdx_F(xMean0, xMean1, b0)
mata:Wdb=Wdb_F(b0, b1, xMean1)
mata:wbA=dwA_F(b0, b1, xMean1)
mata:wbB=dwB_F(b0, b1, xMean1)
mata:dWx=dW_F(b0, xMean0, xMean1)
mata:E=mean(CDF_probit(x0, b0, wv0))/mean(wv0) - mean(CDF_probit(x1, b0, wv1))/mean(wv1)
mata:C=mean(CDF_probit(x1, b0, wv1))/mean(wv1) - mean(CDF_probit(x1, b1, wv1))/mean(wv1)
mata:PDF00=PDF_probit(x0, b0, wv0)  /*changed from 0 to 00 20100917*/
mata:PDF10=PDF_probit(x1, b0, wv1)  /*changed from 1 to 10 20100917*/
mata:PDF11=PDF_probit(x1, b1, wv1)  /*newly added 20100917*/
mata:dCdb1=dCdb1(x1, Wdb, wbA, wv1, PDF10, C) /*changed from 1 to 10 20100917*/
mata:dCdb2=dCdb2(x1, Wdb, wbB, wv1, PDF11, C) /*changed from 1 to 11 20100917*/
mata:dEdb=dEdb(x0, x1, Wdx, dWx, E, wv0, wv1, PDF00, PDF10) /*changed here too 20100917*/
mata:Var_E_k=varcomp(dEdb, varb0)
mata:seWdx=colsum(sqrt(diag(Var_E_k)))
mata:Var_C_k=varcoef(dCdb1, dCdb2, varb0, varb1)
mata:seWdb=colsum(sqrt(diag(Var_C_k)))
mata:dCdb0A=dCdbA(x1, wv1, PDF10) /*changed 1 to 10 20100917*/
mata:dCdb0B=dCdbA(x1, wv1, PDF11) /*changed 1 to 11 20100917*/
mata:dEdb0=dEdb0(x0,x1,wv0,wv1, PDF00, PDF10) /*changed here 20100917*/
mata:sE0=sqrt(varE(dEdb0, varb0))
mata:sC0=sqrt(varC(varb0, varb1, dCdb0A, dCdb0B))
mata:temp=J(cols(dEdb),cols(dEdb),0)
mata:eV=((dEdb,temp)\(dCdb1,dCdb2))*(varb0,temp\temp,varb1)*((dEdb,temp)\(dCdb1,dCdb2))'
mata:sR0=sqrt(sum(eV))
eret clear
global mvdcmp_scale `scale'
global mvdcmp_varlist `modvarlist2'
global mvdcmp_nvarlist "`modvarlist2' _cons"
global mvdcmp_depvar `depvar'
setresult
displayresult
macro drop mvdcmp_*
  }
}
end

program PoissonDecomp, eclass
syntax anything(id="varlist") [fw pw iw], BY(varname) [OFFset(varname) ///
 REVerse NORmal(string) Scale(integer 1) CLUSter(varname)  ROBust]
if ("`offset'"==""){
tempvar offset
gen `offset'=0
}
tempname matrix
capture tab `by', matrow(`matrix')
if _rc==0 & r(r)!=2 {
di as error "group variable (i.e., `by') must take exactly two values"
macro drop mvdcmp_*
}
else{
tempvar _cons
gen `_cons'=1
gettoken depvar varlist:anything
local weight [`weight'`exp']
if substr("`weight'",2,2)=="pw" | substr("`weight'",2,2)=="fw" | substr("`weight'",2,2)=="iw" {
     local tempweight [`weight'`exp']
     gettoken w1 wv: tempweight, parse("=")
     gettoken wv wv: wv
     gettoken wv test: wv, parse("]")
   }
else {
  tempvar wv
  gen `wv' = 1
 }

forvalue row = 1/2 {
mata:wv`row'=0
mata:st_view(wv`row', ., (tokens("`wv'")), "`touse'")
mata:dv`row'=0
mata:st_view(dv`row', ., (tokens("`depvar'")), "`touse'")
mata:m`row'=sum(dv`row':*wv`row')/sum(wv`row')
mata:st_matrix("m`row'", m`row')
local m`row' = m`row'[1,1]
    }
if substr("`weight'",2,2)=="pw" | substr("`weight'",2,2)=="fw" | substr("`weight'",2,2)=="iw" {
    gettoken temp wv : weight, parse("=")
    gettoken temp wv : wv
    gettoken tempwv wv : wv, parse("]")
}
else{
  tempvar tempwv
  gen `tempwv' = 1
}

if (`m2'>=`m1' & "`reverse'"=="") | (`m2'<`m1' & "`reverse'"!="") {
        local val0 = `matrix'[2,1]
        local val1 = `matrix'[1,1]
    }
    else {
        local val0 = `matrix'[1,1]
        local val1 = `matrix'[2,1]
        }

// handle model options robust and cluster
if ("`robust'"!="")  {
  local ropt = "robust"
  }
  else { 
  local ropt = ""
  }

if ("`cluster'"!="") {
  local copt = "cluster(`varname')"
  }
  else { 
  local copt = ""
 }

// estimation by group
forval i = 0/1 {
qui poisson `depvar' `varlist' `weight' if `by'==`val`i'' , offset(`offset') `ropt' `copt'
local normal`i' `normal'
if "`normal`i''"!=""{
local j 0
local k 0
while (1) {
        if "`normal`i''" == "" continue, break
        gettoken gvars normal`i': normal`i', parse("|")
        unab gvars: `gvars'
        qui devcon, group(`gvars') nonoise
        local gvars`++j' `gvars'
        if "`normal`i''"!=""{
        gettoken bar normal`i' : normal`i', parse("|")
        }
        local nnormal `++k'
        }
}

global mvdcmp_lab`i' "`by'==`val`i''"
local df`i' = e(df_m)
tempvar touse
gen `touse'=0
qui replace `touse'=1 if `by'==`val`i''
mata: x`i'=0
mata: b`i'=st_matrix("e(b)")
local modvarlist: colnames e(b)
local cons _cons
local modvarlist2: list modvarlist - cons
mata: st_view(x`i', ., (tokens("`modvarlist2'"), "`_cons'"), "`touse'")
mata: wv`i'=0
mata: st_view(wv`i', ., (tokens("`tempwv'")), "`touse'")
mata: xMean`i'=mean(x`i')
mata: xMean`i'=mean(x`i':*wv`i'):/mean(wv`i')
mata: varb`i'=st_matrix("e(V)")
mata: off`i'=0
mata: st_view(off`i', ., "`offset'", "`touse'")
mata: off`i'=exp(off`i')
}
//check if the number of independent variables
//included in each model is identical
if `df0'!=`df1' {
        di as error "Number of regressors differs between the groups"
        di as error "Perhaps a variable was dropped in one of the groups defined by `by'"
        macro drop mvdcmp_*
        exit
}
nobreak{
mata:Wdx=Wdx_F(xMean0, xMean1, b0)
mata:Wdb=Wdb_F(b0, b1, xMean1)
mata:wbA=dwA_F(b0, b1, xMean1)
mata:wbB=dwB_F(b0, b1, xMean1)
mata:dWx=dW_F(b0, xMean0, xMean1)
mata:E=mean(pois(x0, b0, off0, wv0))/mean(wv0:*off0) - mean(pois(x1, b0, off1, wv1))/mean(wv1:*off1)
mata:C=mean(pois(x1, b0, off1, wv1))/mean(wv1:*off1) - mean(pois(x1, b1, off1, wv1))/mean(wv1:*off1)
mata:PDF00=pois(x0, b0, off0,wv0) /*PDFs changed for poisson 20100917*/
mata:PDF10=pois(x1, b0, off1,wv1)
mata:PDF11=pois(x1, b1, off1,wv1)
**************************************************CHANGE DP 07/09/10******* wv for off***
mata:dCdb1=dCdb1Pois(x1, Wdb, wbA, wv1, off1, PDF10, C)
mata:dCdb2=dCdb2Pois(x1, Wdb, wbB, wv1, off1, PDF11, C)
mata:dEdb=dEdbPois(x0, x1, Wdx, dWx, E, wv0, wv1, off0, off1, PDF00, PDF10)
******************************************************************************************
mata:Var_E_k=varcomp(dEdb, varb0)
mata:seWdx=colsum(sqrt(diag(Var_E_k)))
mata:Var_C_k=varcoef(dCdb1, dCdb2, varb0, varb1)
mata:seWdb=colsum(sqrt(diag(Var_C_k)))
**************************************************CHANGE DP 07/09/10******** (as above)*****
mata:dCdb0A=dCdbAPois(x1, wv1, off1, PDF10)
mata:dCdb0B=dCdbAPois(x1, wv1, off1, PDF11)
mata:dEdb0=dEdb0Pois(x0,x1,wv0,wv1,off0, off1, PDF00, PDF10)
******************************************************************************************
mata:sE0=sqrt(varE(dEdb0, varb0))
mata:sC0=sqrt(varC(varb0, varb1, dCdb0A, dCdb0B))
mata:temp=J(cols(dEdb),cols(dEdb),0)
mata:eV=((dEdb,temp)\(dCdb1,dCdb2))*(varb0,temp\temp,varb1)*((dEdb,temp)\(dCdb1,dCdb2))'
mata:sR0=sqrt(sum(eV))
eret clear
global mvdcmp_scale `scale'
global mvdcmp_varlist `modvarlist2'
global mvdcmp_nvarlist "`modvarlist2' _cons"
global mvdcmp_depvar `depvar'
setresult
displayresult
macro drop mvdcmp_*
 }
}
end


program nbregDecomp, eclass
// use old version for nbreg
version 12
//
syntax anything(id="varlist") [fw pw iw], BY(varname) [OFFset(varname) ///
REVerse NORmal(string) Scale(integer 1) CLUSter(varname) ROBust]
if ("`offset'"==""){
tempvar offset
gen `offset'=0
}
tempname matrix
capture tab `by', matrow(`matrix')
if _rc==0 & r(r)!=2 {
di as error "group variable (i.e., `by') must take exactly two values"
macro drop mvdcmp_*
}
else{
tempvar _cons
gen `_cons'=1
gettoken depvar varlist:anything
local weight [`weight'`exp']
if substr("`weight'",2,2)=="pw" | substr("`weight'",2,2)=="fw" | substr("`weight'",2,2)=="iw" {
local tempweight [`weight'`exp']
gettoken w1 wv: tempweight, parse("=")
gettoken wv wv: wv
gettoken wv test: wv, parse("]")
}
else{
tempvar wv
gen `wv' = 1
}
forvalue row = 1/2 {
mata:wv`row'=0
mata:st_view(wv`row', ., (tokens("`wv'")), "`touse'")
mata:dv`row'=0
mata:st_view(dv`row', ., (tokens("`depvar'")), "`touse'")
mata:m`row'=sum(dv`row':*wv`row')/sum(wv`row')
mata:st_matrix("m`row'", m`row')
local m`row' = m`row'[1,1]
    }

if substr("`weight'",2,2)=="pw" | substr("`weight'",2,2)=="fw" | substr("`weight'",2,2)=="iw" {
gettoken temp wv : weight, parse("=")
gettoken temp wv : wv
gettoken tempwv wv : wv, parse("]")
}
else{
tempvar tempwv
gen `tempwv' = 1
}

if (`m2'>=`m1' & "`reverse'"=="") | (`m2'<`m1' & "`reverse'"!="") {
        local val0 = `matrix'[2,1]
        local val1 = `matrix'[1,1]
    }
    else {
        local val0 = `matrix'[1,1]
        local val1 = `matrix'[2,1]
        }
// handle robust and cluster options

if ("`robust'"!="")  {
  local ropt = "robust"
  }
  else { 
  local ropt = ""
  }

if ("`cluster'"!="") {
  local copt = "cluster(`varname')"
  }
  else { 
  local copt = ""
 }

// estimation by group
forval i = 0/1 {
qui nbreg `depvar' `varlist' `weight' if `by'==`val`i'', offset(`offset') `ropt' `copt'
local normal`i' `normal'
if "`normal`i''"!=""{
local j 0
local k 0
while (1) {
        if "`normal`i''" == "" continue, break
        gettoken gvars normal`i': normal`i', parse("|")
        unab gvars: `gvars'
        qui devcon, group(`gvars') equations(1) nonoise
        local gvars`++j' `gvars'
        if "`normal`i''"!=""{
        gettoken bar normal`i' : normal`i', parse("|")
        }
        local nnormal `++k'
        }
}

global mvdcmp_lab`i' "`by'==`val`i''"
local df`i' = e(df_m)
tempvar touse
gen `touse'=0
qui replace `touse'=1 if `by'==`val`i''
mata: x`i'=0
local modvarlist: colnames e(b)
// di "`modvarlist'"
local cons _cons
local modvarlist2: list modvarlist - cons /*get rid of the first cons*/
// di "`modvarlist2'"
// fix problem due to renaming of scale parameter in Stata 15
local cons2 _cons
//local cons2 lnalpha
local modvarlist2: list modvarlist2 - cons2 /*get rid of lnalpha*/
//di "`modvarlist2'"
mata: st_view(x`i', ., (tokens("`modvarlist2'"), "`_cons'"), "`touse'")
mata: b=st_matrix("e(b)")
mata: b`i'=0
mata: st_subview(b`i', b, 1,((1\cols(b)-1)))
mata: wv`i'=0
mata: st_view(wv`i', ., (tokens("`tempwv'")), "`touse'")
mata: xMean`i'=mean(x`i')
mata: xMean`i'=mean(x`i':*wv`i'):/mean(wv`i')
mata: varb=st_matrix("e(V)")
mata: varb`i'=0
mata: st_subview(varb`i', varb, (1,rows(varb)-1),((1\cols(varb)-1)))
mata: off`i'=0
mata: st_view(off`i', ., "`offset'", "`touse'")
mata: off`i'=exp(off`i')
}

//check if the number of independent variables
//included in each model is identical
if `df0'!=`df1' {
        di as error "Number of regressors differs between the groups"
        di as error "Perhaps a variable was dropped in one of the groups defined by `by'"
        macro drop mvcdmp_*
        exit
}
nobreak {
mata:Wdx=Wdx_F(xMean0, xMean1, b0)
mata:Wdb=Wdb_F(b0, b1, xMean1)
mata:wbA=dwA_F(b0, b1, xMean1)
mata:wbB=dwB_F(b0, b1, xMean1)
mata:dWx=dW_F(b0, xMean0, xMean1)
mata:E=mean(pois(x0, b0, off0, wv0))/mean(wv0:*off0) - mean(pois(x1, b0, off1, wv1))/mean(wv1:*off1)
mata:C=mean(pois(x1, b0, off1, wv1))/mean(wv1:*off1) - mean(pois(x1, b1, off1, wv1))/mean(wv1:*off1)
mata:PDF00=pois(x0, b0, off0,wv0) /*PDFs changed for nbreg 20100917*/
mata:PDF10=pois(x1, b0, off1,wv1)
mata:PDF11=pois(x1, b1, off1,wv1)
***************************************************************CHANGED 07/09/10 DP*********
mata:dCdb1=dCdb1Pois(x1, Wdb, wbA, wv1, off1, PDF10, C)
mata:dCdb2=dCdb2Pois(x1, Wdb, wbB, wv1, off1, PDF11, C)
mata:dEdb=dEdbPois(x0, x1, Wdx, dWx, E, wv0, wv1, off0, off1, PDF00, PDF10)
mata:Var_E_k=varcomp(dEdb, varb0)
mata:seWdx=colsum(sqrt(diag(Var_E_k)))
mata:Var_C_k=varcoef(dCdb1, dCdb2, varb0, varb1)
mata:seWdb=colsum(sqrt(diag(Var_C_k)))
mata:dCdb0A=dCdbAPois(x1, wv1, off1, PDF10)
mata:dCdb0B=dCdbAPois(x1, wv1, off1, PDF11)
mata:dEdb0=dEdb0Pois(x0, x1, wv0, wv1, off0, off1, PDF00, PDF10)
********************************************************************************************
mata:sE0=sqrt(varE(dEdb0, varb0))
mata:sC0=sqrt(varC(varb0, varb1, dCdb0A, dCdb0B))
mata:temp=J(cols(dEdb),cols(dEdb),0)
mata:eV=((dEdb,temp)\(dCdb1,dCdb2))*(varb0,temp\temp,varb1)*((dEdb,temp)\(dCdb1,dCdb2))'
mata:sR0=sqrt(sum(eV))
eret clear
global mvdcmp_scale `scale'
global mvdcmp_varlist `modvarlist2'
global mvdcmp_nvarlist "`modvarlist2' _cons"
global mvdcmp_depvar `depvar'
setresult
displayresult
macro drop mvdcmp_*
}
}
end

program CLLDecomp, eclass
syntax anything(id="varlist") [fw pw iw], BY(varname) ///
[REVerse  NORmal(string)  Scale(integer 1)  CLUSter(varname)  ROBust]
tempname matrix
capture tab `by', matrow(`matrix')
if _rc==0 & r(r)!=2 {
di as error "group variable (i.e., `by') must take exactly two values"
macro drop mvdcmp_*
}

else{
gettoken cmd newvarlist:newvarlist
tempvar _cons
gen `_cons'=1
gettoken depvar varlist:anything
local weight [`weight'`exp']

*****Means, determining high-low order
if substr("`weight'",2,2)=="pw" | substr("`weight'",2,2)=="fw" | substr("`weight'",2,2)=="iw" {
gettoken depvar varlist:anything
local tempweight [`weight'`exp']
gettoken w1 wv: tempweight, parse("=")
gettoken wv wv: wv
gettoken wv test: wv, parse("]")
}
else{
tempvar wv
gen `wv' = 1
}

*****Means, determining high-low order
forvalue row = 1/2 {
mata:wv`row'=0
mata:st_view(wv`row', ., (tokens("`wv'")), "`touse'")
mata:dv`row'=0
mata:st_view(dv`row', ., (tokens("`depvar'")), "`touse'")
mata:m`row'=sum(dv`row':*wv`row')/sum(wv`row')
mata:st_matrix("m`row'", m`row')
local m`row' = m`row'[1,1]
    }
if (`m2'>=`m1' & "`reverse'"=="") | (`m2'<`m1' & "`reverse'"!="") {
        local val0 = `matrix'[2,1]
        local val1 = `matrix'[1,1]
    }
    else {
        local val0 = `matrix'[1,1]
        local val1 = `matrix'[2,1]
        }

// handle model options robust and cluster
if ("`robust'"!="")  {
  local ropt = "robust"
  }
  else { 
  local ropt = ""
  }

if ("`cluster'"!="") {
  local copt = "cluster(`varname')"
  }
  else { 
  local copt = ""
 }

// estimation by group
forval i = 0/1 {
	qui cloglog `depvar' `varlist' `weight' if `by'==`val`i'' , `ropt' `copt'
local normal`i' `normal'
if "`normal`i''"!=""{
	local j 0
	local k 0
while (1) {
        if "`normal`i''" == "" continue, break
        gettoken gvars normal`i': normal`i', parse("|")
        unab gvars: `gvars'
        devcon, group(`gvars') nonoise
        local gvars`++j' `gvars'
        if "`normal`i''"!=""{
        gettoken bar normal`i' : normal`i', parse("|")
        }
        local nnormal `++k'
        }
}

global mvdcmp_lab`i' "`by'==`val`i''"
local df`i' = e(df_m)

tempvar touse
gen `touse'=0
qui replace `touse'=1 if `by'==`val`i''

mata: x`i'=0
mata: b`i'=st_matrix("e(b)")
local modvarlist: colnames e(b)
local cons _cons
local modvarlist2: list modvarlist - cons
mata: st_view(x`i', ., (tokens("`modvarlist2'"), "`_cons'"), "`touse'")
mata: wv`i'=0
mata: st_view(wv`i', ., (tokens("`wv'")), "`touse'")
mata: xMean`i'=mean(x`i':*wv`i'):/mean(wv`i')
mata: varb`i'=st_matrix("e(V)")
}

if `df0'!=`df1' {
        di as error "Number of regressors differs between the groups"
        di as error "Perhaps a variable was dropped in one of the groups defined by `by'"
        macro drop mvdcmp_*
        exit
}

nobreak{
mata:Wdx=Wdx_F(xMean0, xMean1, b0)
mata:Wdb=Wdb_F(b0, b1, xMean1)
mata:wbA=dwA_F(b0, b1, xMean1)
mata:wbB=dwB_F(b0, b1, xMean1)
mata:dWx=dW_F(b0, xMean0, xMean1)
mata:E=mean(CDF_CLL(x0, b0, wv0))/mean(wv0) - mean(CDF_CLL(x1, b0, wv1))/mean(wv1)
mata:C=mean(CDF_CLL(x1, b0, wv1))/mean(wv1) - mean(CDF_CLL(x1, b1, wv1))/mean(wv1)
mata:PDF00=PDF_CLL(x0, b0, wv0) /*PDFs modified for CLL 20100917*/
mata:PDF10=PDF_CLL(x1, b0, wv1)
mata:PDF11=PDF_CLL(x1, b1, wv1)
mata:dCdb1=dCdb1(x1, Wdb, wbA, wv1, PDF10, C)
mata:dCdb2=dCdb2(x1, Wdb, wbB, wv1, PDF11, C)
mata:dEdb=dEdb(x0, x1, Wdx, dWx, E, wv0, wv1, PDF00, PDF10)
mata:Var_E_k=varcomp(dEdb, varb0)
mata:seWdx=colsum(sqrt(diag(Var_E_k)))
mata:Var_C_k=varcoef(dCdb1, dCdb2, varb0, varb1)
mata:seWdb=colsum(sqrt(diag(Var_C_k)))
mata:dCdb0A=dCdbA(x1, wv1, PDF10)
mata:dCdb0B=dCdbA(x1, wv1, PDF11)
mata:dEdb0=dEdb0(x0,x1,wv0,wv1, PDF00, PDF10)
mata:sE0=sqrt(varE(dEdb0, varb0))
mata:sC0=sqrt(varC(varb0, varb1, dCdb0A, dCdb0B))
mata:temp=J(cols(dEdb),cols(dEdb),0)
mata:eV=((dEdb,temp)\(dCdb1,dCdb2))*(varb0,temp\temp,varb1)*((dEdb,temp)\(dCdb1,dCdb2))'
mata:sR0=sqrt(sum(eV))
eret clear
global mvdcmp_scale `scale'
global mvdcmp_varlist `modvarlist2'
global mvdcmp_nvarlist "`modvarlist2' _cons"
global mvdcmp_depvar `depvar'
setresult
displayresult
macro drop mvdcmp*
}
}
end

program setresult, eclass
mata:R=E+C
mata:ZvalueE=E/sE0
mata:ZvalueC=C/sC0
mata:ZvalueR=R/sR0
mata:PctE=100*E/(E+C)
mata:PctC=100*C/(E+C)
mata:DCE=E:*Wdx
mata:ZEWdx=E*Wdx:/seWdx
mata:PCTcom=100*(E*Wdx:/(E+C))
mata:CWdb=C*Wdb
mata:ZCWdb=C*Wdb:/seWdb
mata:PCTcoe=100*(C*Wdb:/(E+C))
mata:El=E-1.96*sE0
mata:Eh=E+1.96*sE0
mata:Cl=C-1.96*sC0
mata:Ch=C+1.96*sC0
mata:Rl=R-1.96*sR0
mata:Rh=R+1.96*sR0
mata:st_matrix("El", El)
mata:st_matrix("Eh", Eh)
mata:st_matrix("Cl", Cl)
mata:st_matrix("Ch", Ch)
mata:st_matrix("Rl", Rl)
mata:st_matrix("Rh", Rh)
mata:st_matrix("E", E)
mata:st_matrix("C", C)
mata:st_matrix("R", R)
mata:st_matrix("VarEk", Var_E_k)
mata:st_matrix("seWdx", seWdx)
mata:st_matrix("seWdb", seWdb)
mata:st_matrix("VarCk", Var_C_k)
mata:st_matrix("sE0", sE0)
mata:st_matrix("sC0", sC0)
mata:st_matrix("sR0", sR0)
mata:st_matrix("ZE", ZvalueE)
mata:st_matrix("ZC", ZvalueC)
mata:st_matrix("ZR", ZvalueR)
mata:st_matrix("PE", PctE)
mata:st_matrix("PC", PctC)
mata:st_matrix("DCE", DCE)
mata:st_matrix("ZEWdx", ZEWdx)
mata:st_matrix("PCTcom", PCTcom)
mata:st_matrix("CWdb", CWdb)
mata:st_matrix("ZCWdb", ZCWdb)
mata:st_matrix("PCTcoe", PCTcoe)
mata: N = rows(x0) + rows(x1)
mata:st_matrix("N", N)
mata: PZE=2*normal(-abs(ZvalueE))
mata: PZC=2*normal(-abs(ZvalueC))
mata: PZR=2*normal(-abs(ZvalueR))
mata:st_matrix("PZE", PZE)
mata:st_matrix("PZC", PZC)
mata:st_matrix("PZR", PZR)
global mvdcmp_N=N[1,1]
global mvdcmp_ZE=ZE[1,1]
global mvdcmp_ZC=ZC[1,1]
global mvdcmp_ZR=ZR[1,1]
global mvdcmp_PE=PE[1,1]
global mvdcmp_PC=PC[1,1]
global mvdcmp_PZE=PZE[1,1]
global mvdcmp_PZC=PZC[1,1]
global mvdcmp_PZR=PZR[1,1]
global mvdcmp_El = El[1,1]*$mvdcmp_scale
global mvdcmp_Eh = Eh[1,1]*$mvdcmp_scale
global mvdcmp_Cl = Cl[1,1]*$mvdcmp_scale
global mvdcmp_Ch = Ch[1,1]*$mvdcmp_scale
global mvdcmp_Rl = Rl[1,1]*$mvdcmp_scale
global mvdcmp_Rh = Rh[1,1]*$mvdcmp_scale
/*****summary stats added 20100918 start***********************/
global mvdcmp_E = E[1,1]*$mvdcmp_scale
global mvdcmp_C = C[1,1]*$mvdcmp_scale
global mvdcmp_R = R[1,1]*$mvdcmp_scale
global mvdcmp_seE = sE0[1,1]*$mvdcmp_scale
global mvdcmp_seC = sC0[1,1]*$mvdcmp_scale
global mvdcmp_seR = sR0[1,1]*$mvdcmp_scale
/*****summary stats added 20100918 end***********************/
global mvdcmp_nvar: word count $mvdcmp_nvarlist
global mvdcmp_nvar2 = $mvdcmp_nvar - 1
forval i = 1/$mvdcmp_nvar {
global mvdcmp_varname`i' : word `i' of $mvdcmp_nvarlist
}
forval i = 1/$mvdcmp_nvar {
local cvarlist `cvarlist' E:${mvdcmp_varname`i'}
}
forval i = 1/$mvdcmp_nvar {
local cvarlist `cvarlist' C:${mvdcmp_varname`i'}
}
local cvarlist `cvarlist' Summary:E Summary:C Summary:R /****************20100917*/
mat coln DCE = $mvdcmp_nvarlist
mat rown DCE = estimate
mat coln CWdb = $mvdcmp_nvarlist
mat rown CWdb = estimate
mat coln VarEk = $mvdcmp_nvarlist
mat rown VarEk = $mvdcmp_nvarlist
mat coln VarCk = $mvdcmp_nvarlist
mat rown VarCk = $mvdcmp_nvarlist
mat coln seWdx=$mvdcmp_nvarlist
mat coln seWdb=$mvdcmp_nvarlist
forval i = 1/$mvdcmp_nvar {
global mvdcmp_DCE`i'=DCE[1,`i']*$mvdcmp_scale
global mvdcmp_seWdx`i'=seWdx[1,`i']*$mvdcmp_scale
global mvdcmp_ZEWdx`i'=ZEWdx[1,`i']
global mvdcmp_PZE`i'= 2*normal(-abs(${mvdcmp_ZEWdx`i'}))
global mvdcmp_El`i'= (${mvdcmp_DCE`i'} + invnormal(.025)*${mvdcmp_seWdx`i'})
global mvdcmp_Eh`i'= (${mvdcmp_DCE`i'} + invnormal(.975)*${mvdcmp_seWdx`i'})
global mvdcmp_PCTcom`i'=PCTcom[1,`i']
global mvdcmp_CWdb`i'=CWdb[1,`i']*$mvdcmp_scale
global mvdcmp_seWdb`i'=seWdb[1,`i']*$mvdcmp_scale
global mvdcmp_ZCWdb`i'=ZCWdb[1,`i']
global mvdcmp_PZC`i'=2*normal(-abs(${mvdcmp_ZCWdb`i'}))
global mvdcmp_Cl`i'= (${mvdcmp_CWdb`i'}-1.96*${mvdcmp_seWdb`i'})
global mvdcmp_Ch`i'= (${mvdcmp_CWdb`i'}+1.96*${mvdcmp_seWdb`i'})
global mvdcmp_PCTcoe`i'=PCTcoe[1,`i']
}
mata:Coef=DCE,CWdb,E,C,R /*************E, C, R added 20100917*/
************create new e(V) 20100919 start*************************
mata:VarE=J(${mvdcmp_nvar}*2+3,1,0)
mata:VarE[${mvdcmp_nvar}*2+1,1]=sE0^2
mata:VarC=J(${mvdcmp_nvar}*2+3,1,0)
mata:VarC[${mvdcmp_nvar}*2+2,1]=sC0^2
mata:VarR=J(${mvdcmp_nvar}*2+3,1,0)
mata:VarR[${mvdcmp_nvar}*2+3,1]=sR0^2
mata:temp=J(1,${mvdcmp_nvar}*2,0)
mata:eV=eV\temp\temp\temp
mata:eV=eV,VarE,VarC,VarR
mata:st_matrix("Coef", Coef)
mata:st_matrix("eV", eV)
mat coln Coef = `cvarlist'
mat coln eV = `cvarlist'
mat rown eV = `cvarlist'

************create new e(V) 20100919 end*************************
********************************************new 20100917 start
tempvar touse
gen `touse' = $mvdcmp_grp
tempname b V
matrix `b' = Coef
matrix `V' = eV
eret post `b' `V', esample(`touse')

********************************************new 20100917 end
eret local low $mvdcmp_lab1
eret local high $mvdcmp_lab0
eret local indvar="$mvdcmp_varlist"
eret local depvar $mvdcmp_depvar
eret scalar scale = $mvdcmp_scale
eret scalar N = $mvdcmp_N
eret local cmd = "mvdcmp"
end

program displayresult, eclass
local format
{
        
		di as text "Version 2.0"
        di %10s as text "Decomposition Results"               as text %55s    "Number of obs =   "   as res %7s "$mvdcmp_N"
        di as text "{hline 31}{hline 71}"
        di as text "Reference group (A): " as res "`e(high)'"  as text " ---  Comparison group (B): " as res "`e(low)'""
        di as text "{hline 31}{c TT}{hline 71}"
        di as text %30s "$mvdcmp_depvar", _col(30) as text "{c |}" _col(11) as text %11s "Coef." _col(22) as text %11s "Std. Err." _col(29) as text %8s "z" _col(38) /*
        */ as text %9s "P>|z|" _col(47) as text %24s "[95% Conf. Interval]" _col(71) as text %8s "Pct."
        di as text "{hline 31}{c +}{hline 71}"
        di as text %30s  "E"       , _col(30) as text "{c |}"  as res %11.5f $mvdcmp_E    as res %11.5f $mvdcmp_seE  as res %8.2f $mvdcmp_ZE /*
        */                                                     as res %9.3f $mvdcmp_PZE  as res %11.5f $mvdcmp_El   as res %11.5f $mvdcmp_Eh   as res %10.2f $mvdcmp_PE
        di as text %30s  "C"       , _col(30) as text "{c |}"  as res %11.5f $mvdcmp_C   as res %11.5f $mvdcmp_seC as res %8.2f $mvdcmp_ZC /*
        */                                                     as res %9.3f $mvdcmp_PZC  as res %11.5f $mvdcmp_Cl   as res %11.5f $mvdcmp_Ch   as res %10.2f $mvdcmp_PC
        di as text "{hline 31}{c +}{hline 71}"
        di as text %30s  "R"       , _col(30) as text "{c |}"  as res %11.5f $mvdcmp_R as res %11.5f $mvdcmp_seR as res %8.2f $mvdcmp_ZR /*
        */                                                     as res %9.3f $mvdcmp_PZR as res %11.5f $mvdcmp_Rl   as res %11.5f $mvdcmp_Rh as res %10.2f

        di
        di %~84s as text "Due to Difference in Characteristics (E)"
        di as text "{hline 31}{c TT}{hline 71}"
        di as text %30s "$mvdcmp_depvar", _col(30) as text "{c |}" _col(11) as text %11s "Coef." _col(22) as text %11s "Std. Err." _col(29) as text %8s "z" _col(38) /*
        */ as text %9s "P>|z|" _col(47) as text %24s "[95% Conf. Interval]" _col(71) as text %8s "Pct."
        di as text "{hline 31}{c +}{hline 71}"
forval i = 1/$mvdcmp_nvar2{
        di as text %30s  "${mvdcmp_varname`i'}" , _col(30) as text "{c |}" as res %11.5f ${mvdcmp_DCE`i'}  as res %11.5f ${mvdcmp_seWdx`i'} /*
        */  as res %8.2f ${mvdcmp_ZEWdx`i'} as res %9.3f ${mvdcmp_PZE`i'}  as res %11.5f ${mvdcmp_El`i'}   as res %11.5f ${mvdcmp_Eh`i'}  as res %10.2f ${mvdcmp_PCTcom`i'}
}
        di as text "{hline 31}{c BT}{hline 71}"
        di
        di %~84s as text "Due to Difference in Coefficients (C)"
        di as text "{hline 31}{c TT}{hline 71}"
        di as text %30s "$mvdcmp_depvar", _col(30) as text "{c |}" _col(11) as text %11s "Coef." _col(22) as text %11s "Std. Err." _col(29) as text %8s "z" _col(38) /*
        */ as text %9s "P>|z|" _col(47) as text %24s "[95% Conf. Interval]" _col(71) as text %8s "Pct."
        di as text "{hline 31}{c +}{hline 71}"
forval i = 1/$mvdcmp_nvar {
        di as text %30s  "${mvdcmp_varname`i'}", _col(30) as text "{c |}" as res %11.5f ${mvdcmp_CWdb`i'}  as res %11.5f ${mvdcmp_seWdb`i'} /*
        */ as res %8.2f ${mvdcmp_ZCWdb`i'} as res %9.3f ${mvdcmp_PZC`i'}  as res %11.5f ${mvdcmp_Cl`i'}    as res %11.5f ${mvdcmp_Ch`i'}  as res %10.2f ${mvdcmp_PCTcoe`i'}
}
        di as text "{hline 31}{c BT}{hline 71}"
}
end

******************************
*                            *
*   common mata functions    *
*                            *
******************************
mata:
function Wdx_F(real matrix xMean0, real matrix xMean1, real matrix b0)
		{
			Wdx=J(1, cols(b0), .)
			  A=(xMean0-xMean1)*b0'
				for (i=1; i<=cols(b0); i++){
					Wdx[i]=(xMean0[i]-xMean1[i])*b0[i]':/A
				}
return(Wdx)
	}
end

mata:
function Wdb_F(real matrix b0, real matrix b1, real matrix xMean1)
		{
			Wdb=J(1, cols(xMean1), .)
			  A=xMean1*(b0'-b1')
				for (i=1; i<=cols(b0); i++){
					Wdb[i]=(xMean1[i]*(b0[i]'-b1[i]')):/A
				}
return(Wdb)
	}
end

mata:
function dwA_F(real matrix b0, real matrix b1, real matrix xMean1)
		{
			dwA=J(cols(xMean1), cols(xMean1), .)
			  A=xMean1*(b0'-b1')
				for (i=1; i<=cols(xMean1); i++){
					for (j=1; j<=cols(xMean1); j++){
						if(i==j){
						B = 1
						}
					else{
						B = 0
					}
			dwA[i,j]= B:*xMean1[i]:/A - (xMean1[i]:*xMean1[j]*(b0[i]'-b1[i]')):/A:^2
				}
			}
return (dwA)
	}
end

mata:
function dwB_F(real matrix b0, real matrix b1, real matrix xMean1)
	{
			dwB=J(cols(xMean1), cols(xMean1), .)
			  A=xMean1*(b0'-b1')
				for (i=1; i<=cols(xMean1); i++){
					for (j=1; j<=cols(xMean1); j++){
						if(i==j){
						B = 1
						}
					else{
						B = 0
					}
			dwB[i,j]= (xMean1[i]:*xMean1[j]*(b0[i]'-b1[i]')):/A:^2  - B:*xMean1[i]:/A
				}
			}
return (dwB)
	}
end

mata:
function dW_F(real matrix b0, real matrix xMean0, real matrix xMean1)
	{
			dW=J(cols(xMean1), cols(xMean1), .)
			 A=(xMean0-xMean1)*b0'
				for (i=1; i<=cols(xMean1); i++){
					for (j=1; j<=cols(xMean1); j++){
						if(i==j){
						B = 1
						}
					else{
						B = 0
					}
			dW[i,j]= B:*(xMean0[i]-xMean1[i]):/A - (b0[i]'*(xMean0[i]-xMean1[i]):*(xMean0[j]-xMean1[j])):/A:^2
				}
			}
return (dW)
	}
end

mata:
function dCdb1(real matrix x1, real matrix Wdb, real matrix wbA, real matrix weight, real matrix PDF, real scalar C)
	{
		dCdb1=J(cols(x1), cols(x1), .)
			for (i=1; i<=cols(x1); i++){
				for (j=1; j<=cols(x1); j++){
					dCdb1[i,j]=Wdb[i]:*mean(x1[,j]:*PDF):/mean(weight) :+ wbA[i,j]:*C
				}
			}
return(dCdb1)
	}
end

// fixed Poisson beginning here
mata:
function dCdb1Pois(real matrix x1, real matrix Wdb, real matrix wbA, real matrix weight, real matrix off, real matrix PDF, real scalar C)
	{
			dCdb1=J(cols(x1), cols(x1), .)
				for (i=1; i<=cols(x1); i++){
					for (j=1; j<=cols(x1); j++){
						dCdb1[i,j]=Wdb[i]:*sum(x1[,j]:*PDF):/sum(weight:*off) :+ wbA[i,j]:*C
				}
			}
return(dCdb1)
	}
end
// ending here

mata:
function dCdb2(real matrix x1, real matrix Wdb, real matrix wbB, real matrix weight, real matrix PDF, real scalar C)
	{
			dCdb2=J(cols(x1), cols(x1), .)
				for (i=1; i<=cols(x1); i++){
					for (j=1; j<=cols(x1); j++){
						dCdb2[i,j] = wbB[i,j]:*C - Wdb[i]:*mean(PDF:*x1[,j]):/mean(weight)
				}
			}
return(dCdb2)
	}
end

// fixed Poisson beginning here
mata:
function dCdb2Pois(real matrix x1, real matrix Wdb, real matrix wbB, real matrix weight, real matrix off, real matrix PDF, real scalar C)
	{
			dCdb2=J(cols(x1), cols(x1), .)
				for (i=1; i<=cols(x1); i++){
					for (j=1; j<=cols(x1); j++){
						dCdb2[i,j] = wbB[i,j]:*C - Wdb[i]:*sum(PDF:*x1[,j]):/sum(weight:*off)
				}
			}
return(dCdb2)
	}
end

// ending here

mata:
function dEdb(real matrix x0, real matrix x1, real matrix Wdx,real matrix dWx, real scalar E,
				real matrix w0, real matrix w1, real matrix PDF0, real matrix PDF1)
	{
			dEdb=J(cols(x0), cols(x0), .)
				for (i=1; i<=cols(x0); i++){
					for (j=1; j<=cols(x0); j++){
						dEdb[i,j]= Wdx[i]:*(mean(PDF0:*x0[,j]):/mean(w0)
									:-mean(PDF1:*x1[,j]):/mean(w1)):+dWx[i,j]:*E
				}
			}
return(dEdb)
	}
end

// starting point of Poisson fix
mata:
function dEdbPois(real matrix x0, real matrix x1, real matrix Wdx,real matrix dWx, real scalar E,
					real matrix w0, real matrix w1, real matrix off0, real matrix off1, real matrix PDF0, real matrix PDF1)
	{
			dEdb=J(cols(x0), cols(x0), .)
				for (i=1; i<=cols(x0); i++){
					for (j=1; j<=cols(x0); j++){
						dEdb[i,j]= Wdx[i]:*(sum(PDF0:*x0[,j]):/sum(w0:*off0)
									:-sum(PDF1:*x1[,j]):/sum(w1:*off1)):+dWx[i,j]:*E
				}
			}
return(dEdb)
	}
end

// ending point of Poisson fix 

mata:
function varcomp(real matrix dEdb, real matrix varb_beta0)
	{
		Var_E_k= J(cols(dEdb),cols(dEdb),.)
		Var_E_k=dEdb*varb_beta0*dEdb'
return(Var_E_k)
	}
end

mata:
function varcoef(dCdb0, dCdb1, varb0, varb1)
	{
		Var_C_k=J(cols(dCdb1), cols(dCdb1), .)
		Var_C_k = dCdb0*varb0*dCdb0' + dCdb1*varb1*dCdb1'
return(Var_C_k)
	}
end

mata:
function dCdbA(x, weight, PDF) {
		dCdba=J(1, cols(x), .)
			for (i=1; i<=cols(x); i++){
				dCdba[i] = mean(PDF:*x[,i]):/mean(weight)
			}
return(dCdba)
	}
end


mata:
function dCdbAPois(x, weight, off, PDF) {
		dCdba=J(1, cols(x), .)
			for (i=1; i<=cols(x); i++){
				dCdba[i] = sum(PDF:*x[,i]):/sum(weight:*off)
		}
return(dCdba)
	}
end


mata:
function dEdb0(x0, x1, weight0, weight1, PDF0, PDF1)
	{
		dEdb0=J(1,cols(x0), .)
			for (i=1; i<=cols(x0); i++){
				dEdb0[i] = mean(PDF0:*x0[,i])/mean(weight0) - mean(PDF1:*x1[,i]):/mean(weight1)
		}
return(dEdb0)
	}
end


mata:
function dEdb0Pois(x0, x1, weight0, weight1, off0, off1, PDF0, PDF1)
	{
		dEdb0=J(1,cols(x0), .)
			for (i=1; i<=cols(x0); i++){
				dEdb0[i] = sum(PDF0:*x0[,i])/sum(weight0 :*off0) - sum(PDF1:*x1[,i]):/sum(weight1 :*off1)
		}
return(dEdb0)
	}
end


mata:
function varE(real matrix dEdb, real matrix varb0)
	{
		varE0=J(1, cols(dEdb), .)
		varE0=dEdb*varb0*dEdb'
return(varE0)
	}
end

mata:
function varC(varb0, varb1, dCdb0, dCdb1)
	{
		varC0=0
		varC0=dCdb0*varb0*dCdb0' + dCdb1*varb1*dCdb1'
return(varC0)
	}
end

******************************
*                            *
*           PDFs/CDFs         *
*                            *
******************************
//Linear CDF
mata:
function CDF_Linear(real matrix x, real matrix b, real matrix weight)
	{
		F=((x:*weight))*b'
return(F)
	}
end

//Linear pdf
mata:
function PDF_Linear(real matrix weight)
	{
		f=weight
return(f)
	}
end

//Logistic CDF
mata:
function CDF_lgt(real matrix x, real matrix b, real matrix weight)
	{
		xb=x*b'
		 F=(exp(xb):/ (1:+exp(xb))):*weight
return(F)
	}
end

//Logistic pdf
mata:
function PDF_lgt(real matrix x, real matrix b, real matrix weight)
	{
		xb=x*b'
		 f=(exp(xb):/(1:+exp(xb)):^2):*weight
return(f)
	}
end

//Poisson pdf & CDF
mata:
function pois(real matrix x, real matrix b, real matrix off, real matrix weight)
	{
		xb=x*b'
		 F=exp(xb :+ log(off)):*weight
return(F)
	}
end

//probit CDF
mata:
function CDF_probit(real matrix x, real matrix b, real matrix weight)
	{
		xb=x*b'
		 F=(normal(xb):*weight)
return(F)
	}
end

// probit pdf
mata:
function PDF_probit(real matrix x, real matrix b, real matrix weight)
	{
		xb=x*b'
		 f=(normalden(xb):*weight)
return(f)
	}
end

// CLL CDF
mata:
function CDF_CLL(real matrix x, real matrix b, real matrix weight)
	{
		xb=x*b'
		F = (1 :- exp(-exp(xb))):*weight
return(F)
	}
end

// CLL pdf
mata:
function PDF_CLL(real matrix x, real matrix b, real matrix weight)
	{
		xb=x*b'
		f = (exp(-exp(xb))):*weight
return(f)
	}
end
//////////////// end subroutines /////////////
