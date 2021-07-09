*! version 0.3 January 18, 2012 @ 19:10:00 DE
*! Create SPSS syntax for reading Stata file

program define dta2sav
version 10.1
   tempname n_valv
   tempfile sps_file stata_file
   syntax [ varlist ] [if] [in], [ noDot Verbose name(string) replace ]
   if length("`varlist'")==0 local varlist = _all
   local datafile = c(filename)
   local fdate = c(filedate)
   local ck = c(k)
   local cN = c(N)
   local fchange = c(changed)
   local nvars : word count `varlist'
   local dl : data label

   // create filenames:
   if length(`"`name'"') > 0 {
      _getfilename `"`name'"'
      local sfname = r(filename)
      local path = reverse(subinstr(reverse(`"`name'"'),reverse(`"`sfname'"'),"",1)) // path before sfname
      if strpos(`"`sfname'"',".") > 0 {
         di as err `"name datafile may not contain extension:"'
         err 198
      }
   }
   if length(`"`path'"') == 0 {
      _getfilename `"`datafile'"'
      local fname = r(filename)
      local path = reverse(subinstr(reverse(`"`datafile'"'),reverse(`"`fname'"'),"",1)) // path before fname
   }
   if length(`"`name'"') > 0 local fname = `"`sfname'"'
   if strpos(`"`fname'"',".") > 0 {
      local extens = substr(reverse(`"`fname'"'),1,strpos(reverse(`"`fname'"'),".")-1) // extension of fname after "."
      local prename = reverse(subinstr(reverse(`"`fname'"'),`"`extens'"',"",1)) // prename of fname until "."
      local prename = substr(`"`prename'"',1,length(`"`prename'"')-1) // drop last character (".")
      local extens = reverse(`"`extens'"')
   }
   else local prename = `"`fname'"'
   local fname_dts = `"`prename'"'+".dts"
   local fname_sps = `"`prename'"'+".sps"
   local fname_sav = `"`prename'"'+".sav"
   local name_dts = `"`path'"'+`"`fname_dts'"'
   local name_sps = `"`path'"'+`"`fname_sps'"'
   local name_sav = `"`path'"'+`"`fname_sav'"'

   // check path:
   if length(`"`path'"') > 0 local chkpath : dir `"`path'"' dirs `"`path'"'

   // check .dts-file:
   cap findfile `"`fname_dts'"', path(`"`path'"')
   if _rc == 0 & length("`replace'") == 0 {
      di as err `"Stata data file "`name_dts'":"'
      err 602
   }

   // check .dta-file:
   cap findfile `"`fname_sps'"', path(`"`path'"')
   if _rc == 0 & length("`replace'") == 0 {
      di as err `"SPSS syntax file "`name_sps'":"'
      err 602
   }

   preserve
      marksample touse, novarlist
      qui keep if `touse'
      qui count
      local ncases = r(N)
      qui save `stata_file', replace

      qui drop _all
      qui set obs 11
      qui gen str244 comment = ""
      qui replace comment = "/* ------------------------------------------------------------------ */" if _n == 1
      qui replace comment = "/* "+`"`dl'"'+" */" if _n == 2
      qui replace comment = `"/* Filename: '`datafile'' */"' if _n == 3
      if `fchange' == 0 {
         qui replace comment = `"/* File not changed since `fdate' */"' if _n == 4
      }
      else qui replace comment = `"/* File changed since `fdate' */"' if _n == 4
      qui replace comment = `"/* Cases: `cN' (exported `ncases'), variables: `ck' (exported `nvars') */"' if _n == 5
      qui replace comment = `"/* Exported from Stata: `c(current_date)' `c(current_time)' */"' if _n == 6
      qui replace comment = "/* ------------------------------------------------------------------ */" if _n == 7
      qui replace comment = "" if _n == 8
      qui replace comment = `"GET STATA FILE='`name_dts''."' if _n == 9
      qui replace comment = `"FILE LABEL `dl'."' if _n == 10
      qui replace comment = "" if _n == 11
      qui save `sps_file', replace

      qui use `stata_file', clear
      local ms = ".a .b .c .d .e .f .g .h .i .j .k .l .m .n .o .p .q .r .s .t .u .v .w .x .y .z"
      foreach var of varlist `varlist' {
         if "`dot'" != "nodot" di "." _c
         local strvar : type `var'
         if substr("`strvar'",1,3)!="str" {
            qui sum `var'
            local maxv = r(max)
            local val_lab : value label `var'
            cap label list `val_lab'
            if _rc == 0 & length("`val_lab'") > 0 {
               local maxv = max(`maxv',`r(max)')
               mata: nvallab("`val_lab'",`r(min)',`r(max)')
               local n_missv = `r(k)'-`n_valv'
               if `n_missv' > 0 {
                  local dec = ceil(log10(`maxv'))
                  if round(10^`dec'-`n_missv') > `maxv' {
                     local maxmi : di round(10^`dec'-1)
                  }
                  else local maxmi : di round(10^(`dec'+1)-1)

                  uselabel `val_lab', clear
                  qui gen str4 mvalstr = ""
                  qui gen str5 labdstr = ""
                  qui gen n = _n
                  qui drop if n <= `n_valv'
                  qui replace n = _n
                  qui gen mval = `maxmi'- n + 1
                  foreach m of local ms {
                     qui replace mvalstr = "`m'=" if value==`m'
                     qui replace labdstr = `"`m' "" "' if value==`m'
                  }
                  local mven = mvalstr[1] + string(round(mval[1]))
                  local labd = labdstr[1] + string(round(mval[1])) + `" ""' + label[1] + `"""'
                  forvalues m=2/`n_missv' {
                     local mven = `"`mven'"' + " \ " + mvalstr[`m'] + string(round(mval[`m']))
                     local labd = `"`labd'"' + " " + labdstr[`m'] + string(round(mval[`m'])) + `" ""' + label[`m'] + `"""'
                  }
                  if `n_missv' > 1 {
                     qui sum mval
                     local minmi = r(min)
                     local spss = "MISSING VALUES `var' (`minmi' THRU `maxmi')."
                  }
                  else local spss = "MISSING VALUES `var' (`maxmi')."

                  qui use `sps_file', clear
                  local n = _N+1
                  qui set obs `n'
                  qui replace comment = "`spss'" if _n==`n'
                  qui save `sps_file', replace

                  qui use `stata_file', clear
                  qui mvencode `var', mv(`mven')
                  qui label define `val_lab' `labd', modify
                  qui save `stata_file', replace
               }
            }
         }
      }
      if "`dot'" != "nodot" di _n
      qui keep `varlist'
      if length("`replace'") == 0 {
         saveold `"`name_dts'"'
      }
      else saveold `"`name_dts'"', replace

      qui use `sps_file', clear
      local n = _N+2
      qui set obs `n'
      qui replace comment = "" if _n==`n'-1
      qui replace comment = `"SAVE OUTFILE = '`name_sav''."' if _n==`n'
      format comment %-244s
      if length("`verbose'") == 0 {
         di _n as res "SPSS syntax (MISSING VALUES commands not shown):"
         list if _n <= 11 | _n == _N, sep(0) noo noh
      }
      else {
         di _n as res "SPSS syntax:"
         list, sep(0) noo noh
      }
      cap findfile `"`fname_sav'"', path(`"`path'"')
      if _rc == 0 di as err `"WARNING: SPSS data file "`name_sav'" exists already!"' _n
      if length("`replace'") == 0 {
         outfile using `"`name_sps'"', noq
      }
      else outfile using `"`name_sps'"', noq replace
   restore
end

mata:
   mata clear
   mata set matastrict on
   void nvallab (string scalar vn, real scalar miv, real scalar mav) {
      st_numscalar(st_local("n_valv"), rows(select(strlen(st_vlmap(vn,(miv..mav))'),strlen(st_vlmap(vn,(miv..mav))')[.,1]:>0)))
   }
end
