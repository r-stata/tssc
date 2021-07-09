*! version 2.0.0   16 June 2008   DEM

program define mvsampsi
   version 5.0


   parse "`*'", parse(" ,")
   confirm number `1'

   local lambda `1'
   mac shift
   local dalpha = 1 - $S_level/100

   local options "NY(int 1) NX(int 1) NC(int 0) Alpha(string) Power(string) N(string)"

   parse "`*'"

   if `ny'<0 {
           di in red "ny() out of range"
           exit 198
   }
   if `nx'<0 {
           di in red "nx() out of range"
           exit 198
   }
   if `nc'<0 {
           di in red "nc() out of range"
           exit 198
   }
   if "`n'"=="" & "`power'"=="" {
           local power .9
   }
   if "`alpha'"=="" {
           local alpha = 1 - $S_level/100
   }

   parse "`alpha'", parse("-/ ")
   if "`2'"!="-" {
      local As 0
      parse "`alpha'", parse(", ")
      while "`1'"~="" {
         if "`1'" != "," {
            confirm number `1'
            if `1'<0 {
               di in red "alpha(`1') out of range"
               exit 198
            }
            local As = `As' + 1
            local a`As' `1'
         }
         macro shift
      }
   }
   else {
      confirm number `1'
      local astart `1'
      confirm number `3'
      local astop `3'
      if `astop' < `astart' {
         local astart `3'
         local astop `1'
      }
      parse "`alpha'", parse("/")
      if "`2'"=="/" {
         confirm number `3'
         local ainc = abs(`3')
      } else local ainc 1
   }

   parse "`power'", parse("-/ ")
   if "`2'"!="-" {
      local Ps 0
      parse "`power'", parse(", ")
      while "`1'"~="" {
         if "`1'" != "," {
            confirm number `1'
            if `1'<0 {
               di in red "power(`1') out of range"
               exit 198
            }
            local Ps = `Ps' + 1
            local p`Ps' `1'
         }
         macro shift
      }
   }
   else {
      confirm number `1'
      local pstart `1'
      confirm number `3'
      local pstop `3'
      if `pstop' < `pstart' {
         local pstart `3'
         local pstop `1'
      }
      parse "`power'", parse("/")
      if "`2'"=="/" {
         confirm number `3'
         local pinc = abs(`3')
      } else local pinc 1
   }
   
   parse "`n'", parse("-/ ")
   if "`2'"!="-" {
      local Ns 0
      parse "`n'", parse(", ")
      while "`1'"~="" {
         if "`1'" != "," {
            confirm number `1'
            if `1'<0 {
               di in red "n(`1') out of range"
               exit 198
            }
            local Ns = `Ns' + 1
            local n`Ns' `1'
         }
         macro shift
      }
   }
   else {
      set trace on
      confirm number `1'
      local nstart `1'
      confirm number `3'
      local nstop `3'
      if `nstop' < `nstart' {
         local nstart `3'
         local nstop `1'
      }
      parse "`n'", parse("/")
      if "`2'"=="/" {
         confirm number `3'
         local ninc = abs(`3')
      } else local ninc 1
   set trace off
   }

   display _newline _col(15) "MULTIVARIATE POWER ANALYSIS" _newline
   display _col(4) "N" _col(11) "Alpha" _col(23) "Power" _col(34) "Beta" _col(44) "Lambda" _col(54) "Eff. Size"

   if "`astart'"!="" {
      while float(`astart') <= float(`astop') {
         /*display "`astart'"*/
         if "`n'"=="" {
            if "`pstart'"!="" {
               local pbegin `pstart'
               while float(`pbegin') <= float(`pstop') {
                  /*display "`pbegin'"*/
                  mvsamps0 `lambda', ny(`ny') nx(`nx') nc(`nc') power(`pbegin') alpha(`astart')
                  local pbegin = `pbegin' + `pinc'
               }
            }
            else {
               local j 1
               while `j' <= `Ps' {
                  /*display "`p`j''"*/
                  mvsamps0 `lambda', ny(`ny') nx(`nx') nc(`nc') power(`p`j'') alpha(`astart')
                  local j = `j' + 1
               }
            }
         }
         else {
            if "`nstart'"!="" {
               local nbegin `nstart'
               while float(`nbegin') <= float(`nstop') {
                  /*display "`nbegin'"*/
                  mvsamps0 `lambda', ny(`ny') nx(`nx') nc(`nc') n(`nbegin') alpha(`astart')
                  local nbegin = int(`nbegin' + `ninc')
               }
            }
            else {
               local k 1
               while `k' <= `Ns' {
                  /*display "`n`k''"*/
                  mvsamps0 `lambda', ny(`ny') nx(`nx') nc(`nc') n(`n`k'') alpha(`astart')
                  local k = `k' + 1
               }
            }
         }
         local astart = `astart' + `ainc'
      }
   }
   else {
      local i 1
      while `i' <= `As' {
         /*display "a`i' = `a`i''"*/
         if "`n'"=="" {
            if "`pstart'"!="" {
               local pbegin `pstart'
               while float(`pbegin') <= float(`pstop') {
                  /*display "`pbegin'"*/
                  mvsamps0 `lambda', ny(`ny') nx(`nx') nc(`nc') power(`pbegin') alpha(`a`i'')
                  local pbegin = `pbegin' + `pinc'
               }
            }
            else {
               local j 1
               while `j' <= `Ps' {
                  /*display "`p`j''"*/
                  mvsamps0 `lambda', ny(`ny') nx(`nx') nc(`nc') power(`p`j'') alpha(`a`i'')
                  local j = `j' + 1
               }
            }
         }
         else {
            if "`nstart'"!="" {
               local nbegin `nstart'
               while float(`nbegin') <= float(`nstop') {
                  /*display "`nbegin'"*/
                  mvsamps0 `lambda', ny(`ny') nx(`nx') nc(`nc') n(`nbegin') alpha(`a`i'')
                  local nbegin = int(`nbegin' + `ninc')
               }
            }
            else {
               local k 1
               while `k' <= `Ns' {
                  /*display "`n`k''"*/
                  mvsamps0 `lambda', ny(`ny') nx(`nx') nc(`nc') n(`n`k'') alpha(`a`i'')
                  local k = `k' + 1
               }
            }
         }
         local i = `i' + 1
      }
   }
end

program define mvsamps0
   version 5.0

   quietly mvsamp1i `*'
   display _col(2) $S_1 _col(10) %6.4f $S_2 _col(22) %6.4f $S_3  _col(33) %6.4f 1-$S_3 _col(44) %6.4f $S_4 _col(55) round($S_5, .0001)

end
