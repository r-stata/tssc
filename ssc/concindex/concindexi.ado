!*Version 1.0
*!Amadou B. DIALLO
*!AFTPM, The World Bank, and CERDI, Univ. of Auvergne.
*!December 15, 2004
*!Program to compute the concentration index on individual (Micro) data.
*!More information available in technical notes 6 and 7 provided by Wagstaff and al.
*!http://web.worldbank.org/WBSITE/EXTERNAL/TOPICS/EXTHEALTHNUTRITIONANDPOPULATION/EXTPAH/0,,contentMDK:20216933~menuPK:460204~pagePK:148956~piPK:216618~theSitePK:400476,00.html

prog concindexi, byable(recall) rclass sortpreserve

vers 8.2

se mo 1

preserve

cap mat drop CI CIC CISEF CISEC M

syntax varlist [if] [in] [aweight fweight pweight iweight], Welfarevar(string) ///
[CUrve COnvenient CLean Format(string) ]

if "`weight'" ~= "" & "`convenient'" ~= "" {
   noi di _n
   noi di in r "Weights generally inappropriate to compute concentration index (see Wagstaff and al.)" _n
   noi di in r "Warning...You have specified weights and requested both formula and convenient regression method."
   noi di in r "This could produce different concentration indices between the estimated concentration indices."_n
}

qui drop if `welfarevar' == .

marksample touse, novar
if "`by'" ~= "" {
    markout `touse' `by' , strok
}

// Concentration index using the "convenient covariance" formula:
di _n
di in g "Concentration index estimation using the covariance/formula method" _n
// If convenient regression
if "`convenient'" ~= "" {
   di in g "Concentration index also estimated using the convenient regression method" _n
}

loc nam `nam' CIF CISEF
if "`convenient'" ~= "" {
   loc mat ", CIC, CISEC"
   loc nam `nam' CIC CISEC
   loc dr "CIC CISEC"
}

qui foreach i of local varlist {

   tempvar rank ccurve glvar cclag a a2 va2 sa2 
   su `i' [`weight' `exp'] if `touse', meanonly
   loc mean = r(mean)
   qui glcurve `i' [`weight' `exp'] if `touse', glvar(`glvar') pvar(`rank') sortvar(`welfarevar') nogr
   la var `glvar' "Y coordinates of the Lorenz curve of `i'"
   la var `rank'  "X coordinates of the Lorenz curve of `i'"
   g double `ccurve' = `glvar' / `mean'
   la var `ccurve' "Concentration curve for `i'"
   corr `rank' `i' [`weight' `exp'] if `touse', c
   loc cov = r(cov_12)
   loc ccindex = 2 * (`cov' / `mean') 
   mat CIF = (nullmat(CIF) \ `ccindex' )
   so `ccurve' 
   g `cclag' = `ccurve'[_n - 1] if `touse'
   g `a' = ( `i' / `mean' ) * ( 2 * `rank' - 1 - `ccindex' ) + 2 - `cclag' - `ccurve' if `touse'
   g `a2' = `a' ^ 2 
   loc mea = r(mean)
   cou if `touse'
   loc n = r(N)
   egen `sa2' = sum(`a2')
   g `va2' = (1 / `n') * ((`sa2' / `n') - ((1 + `ccindex') ^ 2)) if `touse'
   su `va2' [`weight' `exp']
   loc ccindexsd = sqrt(`va2')
   mat CISEF = (nullmat(CISEF) \ `ccindexsd')

   // If convenient regression requested

   if "`convenient'" ~= "" {
      so `ccurve' 
      tempvar sdrank lhs 
      egen `sdrank' = sd(`rank') if `touse'
      g `lhs' = 2 * (`sdrank'^2) * `i' / `mean' if `touse'
      newey2 `lhs' `rank' if `touse', lag(1) t(`rank') force
      mat b = get(_b)
      mat v = get(VCE)
      loc ci = b[1,1]
      loc varci = sqrt(v[1,1])
      mat CIC = (nullmat(CIC) \ `ci')
      mat CISEC = (nullmat(CISEC) \ `varci')
   }

}

mat M = CIF, CISEF `mat'
mat rown M = `varlist'
mat coln M = `nam'
di _n
noi di in g "Final matrice of Concentration Indices on Individual (Micro) Data." _n

if "`format'" ~= "" {
   mat li M, noh f(`format')
   di _n
}
else {
   mat li M, noh
   di _n
}

noi di in y "CIF :   " in g "Concentration index using formula/covariance method"
noi di in y "CIC :   " in g "Concentration index using convenient regression method"
noi di in y "CISEF : " in g "Standard errors of the concentration index using formula/covariance method"
noi di in y "CISEC : " in g "Standard errors of the concentration index convenient regression method" _n

ret mat CII = M, copy

// If concentration curves requested
if "`curve" ~= "" {
   noi cap graph `ccurve' `rank' `rank' , sy(..) ylabel xlabel l1(Cum. Prop. of  `i') saving(CC`i', replace)
}

// If cleaning requested
if "`clean'" ~= "" {
   mat drop M CIF CISEF `dr' 
}

restore 

end

exit
