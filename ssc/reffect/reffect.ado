program define reffect
*! version 1.0 - 
** Author: Michael W. Gruszczynski, University of Nebraska, Lincoln, NE, USA
**         (mikegruz@huskers.unl.edu)


version 9.0
  syntax anything
  if "`e(cmd)'" != "anova" {
    display as err "anova not found"
    exit
  }
  quietly test `anything'
  local dvar = e(depvar)
  local df   = r(df)
  local dfe  = r(df_r)
  local F    = r(F)
  local r    = sqrt((`df'*`F')/((`df'*`F')+`dfe'))
  
  display
  display as txt "anova effect size for " as res "`1'" as txt " with dep var = " as res "`dvar'"
  display
  display as txt "            r  = " as res `r'
  display
  display as txt "    Omnibus r  = " sqrt((e(df_m)*e(F))/((e(df_m)*e(F))+e(df_r)))
  
end

* Have a nice day.