* pull an element from col1 of matrix
cap program drop eme
program define eme , rclass
version 10.0
syntax anything [, COLumn(integer 1) Fmt(string) MATrix(string) SIGDigits(string)]

local requestedformat = "`fmt'"

if "`sigdigits'"~="" & inlist("`sigdigits'","2","o","t","h","m")~=1 {
  di in red "Sorry the only allowable values in the sigdigits option are o, t, h, m or 2." _n ///
  "making that change for you (making it a 2) ." _n
  local sigdigits "2"
}

* sort out command
if "`matrix'"=="" {
   local W: word count `anything'
   forvalues i=1/`W' {
      if "``i''" ~= "" {
         cap confirm matrix ``i''
         if _rc==0 {
            local matis "``i''"
         }
      }
   }
   if "`matis'"=="" {
      cap confirm matrix E
      if _rc==0 {
         local matis "E"
      }
   }
   if "`matis'"=="" {
      di in red "I can't figure out what matrix you want to extract from"
      di in red "try adding the matrix name as part of the command"
      exit
   }
   else {
      local matrix "`matis'"
   }
}


local rn : rownames `matrix'
foreach element in `ele' {
   cap macro drop _test1
   *lstrfun test1 , strpos(`"`rn'"', "`ele'")
   local test1 : list & ele
   local test1sizeof : list sizeof test1
   if "`test1sizeof'"~="1" {
      di in red "`ele' not found or ambiguous in matrix `mat' "
      di in green  "rownames are `rn'"
      exit
   }
}

if "`column'"=="" {
   local column "1"
}

local r=0
foreach element in `anything' {

   if "`requestedformat'"=="" & "`sigdigits'"~="" {
      * sigdigit 5-6-2015
      cap macro drop _thud
      local thud : di %10.3f `matrix'[rownumb(matrix(`matrix'),"`element'"),`column']
      local thud : di %10.3f abs(`thud')
      local thud = trim("`thud'")
      if (substr("`thud'",1,1)~=".") & (substr("`thud'",2,1)~=".") {
         local fmt = "%5.1f"  /* this should really be 5.0 to be consistent */
      }
      if (substr("`thud'",2,1)==".") & (substr("`thud'",1,1)~="0") {
         local fmt = "%5.1f"
      }
      if substr("`thud'",1,2)=="0." {
         local fmt = "%5.2f"
      }
      if substr("`thud'",1,3)=="0.0" {
         local fmt = "%5.3f"
      }
   }
   
   if "`sigdigits'"=="o" {
      local fmt "%10.0f"
   }
   if "`sigdigits'"=="t" {
      local fmt "%8.1f"
   }
   if "`sigdigits'"=="h" {
      local fmt "%7.2f"
   }
   if "`sigdigits'"=="m" {
      local fmt "%6.3f"
   }
    
   if "`fmt'"=="" {
      local fmt "%5.3f"
   }
   if "`requestedformat'"~="" {
      local fmt "`requestedformat'"
   }
   
   
   local foo`++r' : di `fmt' `matrix'[rownumb(matrix(`matrix'),"`element'"),`column']
   di "matrix `mat' element `element' column `column' is -> " `fmt' `foo`r'' " (returned as r(r`r'))"
   return local r`r' "`foo`r''"
   if regexm("`element'","$") {
      local element = subinstr("`element'","$","t",.)
   }
   c_local `element' "`foo`r''"
   macro drop _fmt
}

end
