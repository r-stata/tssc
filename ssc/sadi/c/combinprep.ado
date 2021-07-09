capture program drop combinprep
program define combinprep, rclass
version 9.0
   syntax, STate(string) length(string) IDvar(varname) NSPells(string)
   tempvar spno l
   
   
   reshape long `state', i(`idvar') j(`l')

   qui su `state'
   return scalar nels = 1 + r(max) - r(min)
   
   gen `spno'=1
   by `idvar': replace `spno' = `spno'[_n-1]+(`state'!=`state'[_n-1]) if _n>1
   sort `idvar' `spno' `l'
   by `idvar' `spno': gen mark = _N==_n
   keep if mark
   drop if `state'==-1
   drop mark
   by `idvar': gen `nspells'=_N
   gen `length' = `l'
   by `idvar': replace `length' = `l' - `l'[_n-1] if _n>1
   drop `l'
   order `state' `length'
   reshape wide `state' `length', i(`idvar') j(`spno')
   sort `idvar'
   
   su `nspells'
   return scalar maxspells = r(max)

end
   

