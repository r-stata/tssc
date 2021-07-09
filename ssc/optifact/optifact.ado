*! version 1.1 P.MILLAR 06Sep2005 - Adds N and p value for significance
*! version 1.2 P.MILLAR 11Mar2008 -Bugs fixed, allows unlimited sizes, speed improvements
*! This software can be used for non-commercial purposes only. 
*! The copyright is retained by the developer.
*! Copyright 2005-2008 Paul Millar
program define optifact, byable(recall)
  syntax varlist(numeric) [aweight fweight] [if] [in], [top(integer 10) smallest(integer 3) criteria(string) largest(integer 99) minslope(real 0.01) maxfact(integer 1) SIG BIC PRE type(string)] 
local ver=c(version)

if `ver' >= 9.0 {
  local ver="9.0"
  version 9.0
  }
else {
  local ver="7.0"
  version 7.0
  }

if `ver' < 9.0 & "`pre'" == "pre" {
  di as err "PRE not vailable for Stata version earlier than 9.0"
  exit 198
  }

if `ver' < 9.0 & "`sig'" == "sig" {
  di as err "SIG not vailable for Stata version earlier than 9.0"
  exit 198
  }


if "`type'" == "" {
  local type="pf"
  }
if "`type'" != "pf" & "`type'" != "pcf"  & "`type'" != "ml" {
  di as error "Type must be one of the following: pc, pcf or ml"
  di "See help for {help factor}"
  exit 198
  }

if "`sig'" == "sig" {
  local type="ml"
  }

local preval=0
local bicval=0
local sigp=0

tokenize `varlist'
local word="`1'"
local nvars=0
while "`word'" !="" {
  local var`nvars'="`word'"
  local nvars=`nvars'+1
  local word="``nvars'+1'"
  }
local nvars=`nvars'-1

/* save the items to be processed */
forvalues i=1/`nvars' {
  local item`i'="``i''"
  }

if `smallest' < 2 {
  local smallest = 2
  }
else if `smallest' > `nvars' {
  local smallest = `nvars'
  }

if `largest' < 2 {
  local largest = 2
  }
else if `largest' > `nvars' {
  local largest = `nvars'
  }

/* save the names of the variables in the row names of a matrix */
matrix savevars =J(`nvars',1,0)
matrix rownames savevars = `invars'


di as text "`nvars' items will be processed"

local sum=0
local maxcomb=0
forvalues i=`smallest'/`largest' {
  local combs=comb(`nvars',`i')
  local sum=`sum'+`combs'
  if `combs' > `maxcomb' {
    local maxcomb=`combs'
    }
  }

di as text " "
di as text "There are `sum' potential scales, maximum `maxcomb' for a single number of items (k)"

/* this is the main loop */
forvalues size=`smallest'/`largest' {

  local count=0
  local rejects=0
  local width=`nvars'+8

/* check for enough memory, matsize */
  local matsize=c(matsize)
  local maxmat =c(max_matsize)
  local combs=comb(`nvars',`size')
  local nrows=min(`combs',`top')
  if `matsize' < `nrows' {
    if `nrows' > `maxmat' {
      di as error "Too many models requested"
      exit 198
      }
    if `matsize' < `nrows' {
      set matsize `nrows'
      }
    }
  matrix stor = J(`nrows',`width',0)

  forvalues i=1/`size' {
    local digit`i'=`i'
    local max`i'=`nvars'-`size'+`i'
    local min`i'=`i'
    }
  local digit`size'=`digit`size''-1

  while `digit1' <= `max1' {
    local digit`size'= `digit`size''+1
    if `digit`size'' > `nvars' {
      local inc=0
      local j=`size'
      while `inc' ==0 {
        local j=`j'-1
        if `j' <= 0 {
          local digit1 = `digit1' + 1
          local inc = 1
          }
        else if `digit`j'' < `max`j'' { 
          local digit`j'=`digit`j''+1
          local inc=1
          }
        }
        local next=`j'+1
        if `next' > 1 {
          forvalues k=`next'/`size' {
            local prev=`k'-1
            local digit`k'=`digit`prev''+1
            }
          local digit`size' = `digit`size'' - 1
          }
      }
    else {
      forvalues j=1/10 {
        local varstr`j'=" "
        }
      local nvarstr=1
      forvalues i=1/`size' {
        local lstr=length("`varstr`nvarstr''")+length("`var`digit`i''' ")
        if `lstr' > 80 {
          local nvarstr=`nvarstr'+1
          }
        local varstr`nvarstr' = "`varstr`nvarstr''" + "`var`digit`i''' "
        }
      qui factor `varstr1' `varstr2' `varstr3' `varstr4' `varstr5' `varstr6' `varstr7' `varstr8' `varstr9' `varstr10' [`weight'`exp']  `if' `in' ,`type'
      if `ver' >= 9.0 {
        local factors=e(f)
        local ncases=e(N)
        local bicval=-`e(chi2_i)' + ((`e(df_m)') * ln(`e(N)') )
        local df_i =e(df_i)
        local chi2_i =e(chi2_i)
        local sigp=1-chi2(`df_i',`chi2_i')
        }
      else {
        local factors=r(k_f)
        local ncases=r(N)
        }

        /* Calc PRE value */
     if "`pre'" == "pre" {
        local e1=`e(df_m)'*`e(f)'
        mat fload=e(L)
        local k=`e(df_m)'
        local err=0
        forvalues i=1/`k' {
          local h=fload[`i',1]
          local U=1-(`h'*`h')
          local err=`err'+`U'
          }
        local e2=`err'
        local preval=(`e1'-`e2')/`e1'
        }

      if `factors' <= `maxfact' {
        quietly alpha `varstr1' `varstr2' `varstr3' `varstr4' `varstr5' `varstr6' `varstr7' `varstr8' `varstr9' `varstr10' `if' `in'
        local alpha = r(alpha)
        if "`alpha'" == "." {
          local alpha=0
          }
        local k = r(k)
        local cov = r(cov)
        local count = `count' + 1
        local rownum=`count'
        local rowalpha=0
        if `count' > `nrows' {
          local minalpha=1
          local minrow=0
          forvalues j=1/`nrows' {
            local curalpha=stor[`j',2]
            if `curalpha'<`minalpha' {
              local minalpha=`curalpha'
              local minrow=`j'
              }
            }         
          local rownum=`minrow'
          local rowalpha=stor[`minrow',2]
          }
        local 	s : rownames stor
// di as result "count=`count', rownum=`rownum' nrows=`nrows'"
        if `alpha' > `rowalpha' {
          matrix stor[`rownum',1] = `k'
          matrix stor[`rownum',2] = `alpha'
          matrix stor[`rownum',3] = `cov'
          matrix stor[`rownum',4] = `ncases'
          matrix stor[`rownum',5] = `bicval'
          matrix stor[`rownum',6] = `sigp'
          matrix stor[`rownum',7] = `preval'
          matrix stor[`rownum',8] = `factors'
          local last=8+`size'
          forvalues ii=9/`last' {
            local jj=`ii'-8
            matrix stor[`rownum',`ii']=`digit`jj''
            }
          }
        } 
      else {
        local rejects = `rejects' + 1
        }
      }
    }

  matrix colnames stor = k alpha cov N BIC Sigp PRE NFact Item1 

  di as text " "
  if `maxfact'==1 {
    di as text "`count' combinations of `size' items had one factor, `rejects' had more than one factor"
    }
  else {
    di as text "`count' combinations of `size' items had up to `maxfact' factors, `rejects' had more than `maxfact' factor(s)"
    }

/* --------------------------------- */
/* sort the matrix in order of alpha */
/* --------------------------------- */
  matsort stor 2 down replace
/* now re-run the top ten and print them out */
  local end=min(`top',`count')
  di as text   " "
  local prelength=0
  local siglength=0
  local biclength=0
  if "`pre'" == "pre" {
    local prelength=6
    }
  if "`sig'" == "sig" {
    local siglength=6
    }
  if "`bic'" == "bic" {
    local biclength=10
    }

  if `end' > 0 {
   local totlength=`prelength'+`siglength'+`biclength'
   local posn=`totlength'+30
   di as text "Top `end' scales using `size' items"
   di as text " "

/* 1st Title Line */
   di as text "              Avg. Can "

/* 2nd Title Line */
   di as text "     K Alpha  Cov. Chk   N   NF "  _continue
   if "`pre'" == "pre" {
     di as text _continue "  PRE "
     }
   if "`sig'" == "sig" {
     di as text _continue " Sigp "
     }
   if "`bic'" == "bic" {
     di as text _continue "     BIC  "
     }
   di as text  _col(`posn') "Items"

/* 3rd Title Line */
   di as text "     - ----- ----- --- ----- -- "  _continue
   if "`pre'" == "pre" {
     di as text _continue " -----"
     }
   if "`sig'" == "sig" {
     di as text _continue " ----- "
     }
   if "`bic'" == "bic" {
     di as text _continue " ---------"
     }
   di as text as text _col(`posn') "-----"   
   }

  forvalues i=1/`end' {
    forvalues j=1/10 {
      local varstr`j'=" "
      }
    local nvarstr=1
    forvalues j=1/`size' {
      local col=`j'+8
      local itemno=stor[`i',`col']
      local lstr=length("`varstr`nvarstr''")+length("`item`itemno'' ")
      if `lstr' > 80 {
        local nvarstr=`nvarstr'+1
        }
      local varstr`nvarstr' = "`varstr`nvarstr'' " + "`item`itemno''"
      }
    local allpos=" . "
    local allneg=" . "
    if "`criteria'" != "" {
      quietly canon (`varstr1' `varstr2' `varstr3' `varstr4' `varstr5' `varstr6' `varstr7' `varstr8' `varstr9' `varstr10') (`criteria')
      matrix slope = e(b)
      local allpos="Yes"
      local allneg="Yes"
      forvalues j=1/`size' {
        local check=slope[1,`j']
        if `check' < `minslope' {
          local allpos="No "
          }
        if `check' > -`minslope' {
          local allneg="No "
          }
        }
      }

    local k     =stor[`i',1]
    local alpha =stor[`i',2]
    if `alpha' == 0 {
      local alpha="."
      }
    local cov   =stor[`i',3]
    local ncases=stor[`i',4]
    local bicval=stor[`i',5]
    local sigp  =stor[`i',6]
    local preval=stor[`i',7]
    local nfacts=stor[`i',8]
    local allgood="`allpos'"
    if "`allneg'" == "Yes" {
      local allgood="Yes"
      }
    if `cov' > 9.999 {
      local covfmt="%6.3g"
      }
    else {
      local covfmt="%6.3f"
      }

    di as text  %3.0f real("`i'") as result  %3.0f real("`k'") %6.3f real("`alpha'")  `covfmt' real("`cov'") " `allgood'" _col(23) %6.0f real("`ncases'") %3.0f real("`nfacts'") " " _continue
    if "`pre'" == "pre" {
      di as result %6.3f `preval' _continue
      }
    if "`sig'" == "sig" {
      di as result %6.3f `sigp' " " _continue
      }
    if "`bic'" == "bic" {
      di as result %10.2f `bicval' _continue
      }
    di as text _col(`posn') as text "`varstr1' `varstr2' `varstr3' `varstr4' `varstr5' `varstr6' `varstr7' `varstr8' `varstr9' `varstr10'" 
    }
  mat drop stor
  }

end
