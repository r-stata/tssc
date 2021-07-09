*! abuxton 27sep2020  pwexp -piecewise exponential-
*! pwexp varlist [if] [in], TIMe(numlist) SURvival(numlist) Gen(string) [ Ftype(string) RHR(real 1) ]
*27sep2020  v2 check rhr >=0 & subtaskA(...st_matrix()...); 13sep2020 v1
version 16.1
mata: mata set matastrict on
mata:
//subtask subtaskA
void subtaskA(string scalar xv, 
              string scalar yv, 
              real scalar rhr , 
			  string scalar tp, 
              real colvector nrowi,
			  real colvector tmpts,
			  real colvector svpts
)
{
real scalar i, j, cA, cB, cumhazard
real scalar Jnrow, nrow, answerflag, npw, npw1, newvarnum, minuslambda, sstar
real matrix tbl
real colvector xcol, ycol, F, S, T
st_view(xcol, ., tokens(xv))
st_view(ycol, ., tokens(yv))

tbl  = ( svpts , tmpts )

nrow = rows(xcol)

  npw = rows(tbl)
  npw1= rows(tbl)-1

S = tbl[(1::npw),1] :^ rhr
F = J(npw,1,1)-S
T = tbl[(1::npw),2]

if ( tp == "pdf" ) {
  for(i=1; i<=nrow; i++) {
  cumhazard = 0
  answerflag = 0
  for(j=1; j<=npw1; j++) {
   cA = (xcol[i] <=  T[j+1])
   cB = (xcol[i] >=  T[j])
   if (cA & cB & answerflag == 0) {
   minuslambda=log(S[j+1] / S[j]) / (T[j+1] - T[j])
   cumhazard = -log(S[j]) + -minuslambda*(xcol[i]-T[j]) /*H*/
   ycol[i] = exp(-cumhazard)
   answerflag = 1
  }
  } /*j loop*/
 } /*i loop*/
}
if ( tp == "cdf" ) {
  for(i=1; i<=nrow; i++) {
  cumhazard = 0
  answerflag = 0
  for(j=1; j<=npw1; j++) {
   cA = (xcol[i] <=  T[j+1])
   cB = (xcol[i] >=  T[j])
   if (cA & cB & answerflag == 0) {
   minuslambda=log(S[j+1] / S[j]) / (T[j+1] - T[j])
   cumhazard = -log(S[j]) + -minuslambda*(xcol[i]-T[j]) /*H*/
   ycol[i] = 1 - exp(-cumhazard)
   answerflag = 1
  }
  } /*j loop*/
 } /*i loop*/
}
else if ( tp == "inv" ) { 
 for(i=1; i<=nrow; i++) {
  answerflag = 0
  for(j=1; j<=npw1; j++) {
   cA = (xcol[i] <= S[j])
   cB = (xcol[i] > S[j+1])
  if (cA & cB & answerflag == 0) {
   minuslambda=log(S[j+1] / S[j]) / (T[j+1] - T[j])
   sstar = (xcol[i] / S[j])
   ycol[i] = T[j] + log(sstar)/minuslambda
   answerflag = 1 
  }
  } /*j loop*/
 } /*i loop*/ 
}
else if ( tp == "lmd" ) {
 for(i=1; i<=nrow; i++) {
  cumhazard = 0
  answerflag = 0
  for(j=1; j<=npw1; j++) {
   cA = (xcol[i] <=  T[j+1])
   cB = (xcol[i] >=  T[j])
   if (cA & cB & answerflag == 0) {
   minuslambda=log(S[j+1] / S[j]) / (T[j+1] - T[j])
   ycol[i] = -minuslambda
   answerflag = 1
  }
  } /*j loop*/
 } /*i loop*/
}
}
end

program define pwexp , rclass
 version 16.1
 syntax varlist(numeric min=1 max=1) [if] [in] , TIMepoints(numlist) SURvivalpoints(numlist) Generate(string) [ Ftype(string) RHR(real 1) replace]
 marksample touse 
 qui count if `touse' 
 if r(N) == 0 error 2000 
 
 tokenize `varlist' 
 args xvar
 
 tokenize `generate' 
 args yvar garbage 
 if "`garbage'" != "" {
  di as err "at most one name should be given in generate()" 
  exit 198 
 } 
 tokenize `ftype' 
 args ftp garbage 
 if "`garbage'" != "" {
  di as err "at most one name should be given in ftype( {pdf , cdf , inv , lmd} )" 
  exit 198 
 } 
 if `"`replace'"' == `""' {
  confirm new variable `yvar' 
  qui gen double `yvar' = .
 }
 else if `"`replace'"' == `"replace"' {
  cap confirm new variable `yvar' 
  if !_rc {
  qui gen double `yvar' = .
  }
  else {
  cap confirm numeric variable `yvar' 
  qui replace `yvar' = .
  }
 }
 if `"`ftp'"'==`"pdf"' | `"`ftp'"'==`""' {
  local type `"pdf"'
  }
 else if `"`ftp'"'==`"cdf"' {
  local type `"cdf"'
  }
 else if `"`ftp'"'==`"inv"' {
  local type `"inv"'
  }
 else if `"`ftp'"'==`"lmd"' | `"`ftp'"'==`"lambda"'{
  local type `"lmd"'
  }
 else {
  di as err "one name in ftype( {pdf , cdf , inv , lmd or lambda} )" 
  exit 198 
 }
qui {
		if `rhr' < 0 {
		di as err "option rhr(), relative hazard ratio, must be >=0"
		exit 198
		}
		local tlst = `"`timepoints'"'
		cap numlist "`tlst'" , min(2) range(>=0) ascending
		if _rc != 0 {
		di as err "time() values, n=2+, must be ascending with no repeated values & >=0"
		exit 198
		}
		local timepointlst = r(numlist)
		local Ntlst = 0
		foreach z in numlist `timepointlst' {
		local Ntlst = `Ntlst'+1
		}
		local Ntlst = `Ntlst'-1
		local timepointA   =subinstr("`timepointlst'"," ","\",.)

		local slst = `"`survivalpoints'"'
		cap numlist "`slst'" , min(2) range(>=0 <=1) 
		if _rc != 0 {
		di as err "survival() values, n=2+, must be >=0 & <=1"
		exit 198
		}
		local survpointlst = r(numlist)
		local Nslst = 0
		foreach z in numlist `survpointlst' {
		local Nslst = `Nslst'+1
		}
		local Nslst = `Nslst'-1
		local survpointA   =subinstr("`survpointlst'"," ","\",.)
		
		if `Ntlst' != `Nslst' {
		di as err "time() (n=`Ntlst') and survival() (n=`Nslst') require an equal number of values" 
		exit 198
		}

		numlist "1/`Nslst'"
		local rowindex = r(numlist)
		local rowindexA   =subinstr("`rowindex'"," ","\",.)

tempname a b c d
matrix input `a' = (`rowindexA')
matrix input `b' = (`timepointA')
matrix input `c' = (`survpointA')
mata : st_matrix("`b'", sort(st_matrix("`b'"), 1))
mata : st_matrix("`c'", sort(st_matrix("`c'"),-1))
matrix `d' = (`a',`b',`c')
matrix colnames `d' = irow time survival

return matrix itimeS = `d'
}
mata subtaskA("`xvar'", "`yvar'" , `rhr' , "`type'" , st_matrix("`a'") , st_matrix("`b'") , st_matrix("`c'") )
qui replace `yvar' = . if cond(`touse',0,1)
end
