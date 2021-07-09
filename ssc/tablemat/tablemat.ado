*!Amadou B. DIALLO
*!AFTPM, The World Bank, and CERDI, Univ. of Auvergne (France).
*!November 15, 2004
*!Updated July 15, 2005
*!Updated Dec. 02, 2005
*!Program to quickly display many results in a more readable, matricial format.

prog tablemat, byable(recall) sortpreserve rclass

version 8.2

syntax varlist [if] [in] [aweight fweight] , STat(string) [BYgroup(varlist) CLean(string) Format(string) Name(string) ///
OUTput(string) SHort Trim(real 32) ] 

cap matrix drop _all
tempname M N 

local Colname "All" 

// Marking observations

marksample touse, novar

if "`by'" ~= "" {
    markout `touse' `by' , strok
}

tokenize `bygroup'

while "`1'" ~= "" {

		    qui levels `1' if `touse'  , l(lev)

                    //Saving labels

                    local vall : value label `1'

                    //Dealing with special characters

                    if "`vall'"~="" { // The labels will serve to mark each line of the final matrice

                      foreach l of local lev {   // Dealing with some possible problematic characters 

                        local lab`l' : label `vall' `l'

                        if "`clean'"~="" { // If requested by user
                          foreach i of local clean {
                             cap local lab`l' = subinstr("`lab`l''","`i'","",.)
                          }
                        }

                        else { // Default behavior
                         local chara ". : - & % # @ $ ^ & * ? ~ ; , \ | < > { } [ ] ` "

                         foreach i of local chara {
                            cap local lab`l' = subinstr("`lab`l''","`i'","",.)
                         }
                        }

                        cap local lab`l' = subinstr("`lab`l''"," ","",.)
                        local len = length("`lab`l''")
                        if `len' > 32 {
                           if "`trim'" ~= "" {
                              local lab`l' = substr("`lab`l''", 1, `trim')
                           }
                           else {
                              local lab`l' = substr("`lab`l''", 1, 32)
                           }
                        }

                        if "`short'" ~= "" {
                           local lab`l' = substr("`lab`l''", 1, `trim')
                        }

                        local Colname " `Colname' `lab`l''" 

                      }
                    }

                    else { //Saving default names

                       qui levels `1' if `touse'  , l(lil)
                       foreach j of local lil {
                         local lab`j' "`1'_`j'"
                         local Colname "`Colname' `lab`j''"
                       }
                    }

                    mac shift
}


local rown = ""

// Checking statistics provided (only one at a time)

if "`stat'" ~= "" {
tokenize `stat'
local slist "`stat'"
  local nsts : list sizeof slist
  if `nsts' > 1 {
    di in re "Please provide only" in ye " one" in re " statistic at a time"
    exit
  }
}

if "`stat'" == "q" {
    di in re "q" in ye " not supported"
    exit
}

// Fillin matrice if options requested

tokenize `varlist'

if "`varlist'" ~= "" {
  di _n
  di in ye "You have specified variables." _n
  di in ye "In case you have categorical variables, make sure you create dummies for each category..." _n
}

while "`1'" ~= "" {

   local rown "`rown' `1'"

   quie tabstat `1' [`weight' `exp'] if `touse'  , stats(`stat') long save 

   cap mat drop `N'
   mat `N' = r(StatTot)

   foreach i of local bygroup {
              qui tab `i' if `touse'  
              local nn = r(r)

              quie tabstat `1' [`weight' `exp'] if `touse'  , stats(`stat' ) by(`i') long save 

              forval j = 1/`nn' {
                 mat `N' = `N' \ r(Stat`j')
                 }
              }

   mat `N' = `N''
   mat `M' = (nullmat(`M') \ `N')

   mac shift

}

mat colnames `M' = `Colname'
mat rownames `M' = `rown'
di _n(2)
di in gre _col(14) "Final output:" _n

if "`format'" ~= "" {
 mat li `M', noh format(`format')
 di _n
}
 
else {
   mat li `M', noh
   di _n
}

if "`output'" ~= "" {
  preserve
  scalar coln = colsof(`M')
  local coln = coln
  svmat `M'
  local toren ""
    forval i = 1/`coln' {
      local toren "`toren' __000000`i' "
      local v: word `i' of `toren'
      local w: word `i' of `Colname'
      cap ren `v' `w'
    }
    keep `Colname'
    qui outsheet using "`output'", replace
    restore
}

if "`name'" ~= "" {
   mat ren `M' `name'
   return matrix `name' = `name', copy
}

else {
  mat ren `M' M
  return matrix `M' = M, copy
}

di _newline

end
