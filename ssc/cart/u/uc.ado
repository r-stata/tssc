*!uc.ado  BvdH/WvP, 09/10/02
*!first version: 13/02/1997
*!last version:16/5/2006
*! authors: BvdH/WvP
*!Use file with clear and automatic setting of sufficient memory - if needed
*!WvP 2/10/02 Changed: preserve, clear and restore commands not required and removed. 
*!Clear would also drop macro's, programs and other things from memory, which is undesirable!
* 
program define uc
  version 7.0
  local file `1'
  local factor 1
  if "`2'"!="" {local factor max(1 , real("`2'")) }
  cap use `file',clear
  if _rc>=901&_rc<=903 {
      *   WvP: changed after tip on Stata Users Meeting:
      qui describe using `file'
      local memory =int(r(N)*r(width)*0.0012*`factor')
      qui drop _all
      qui set memory `memory'
      qui use `file',clear 
      local label: data label
      display `"`file': `label' "'
  }
  else if _rc>0 {
      local rr = _rc
      display as error _n "Note: error _rc=`rr' after: uc `file'; memory is cleared  -- type error `rr' " 
      display as error "----  program continues after uc `file'  command " _n 
      * error _rc   veranderd 10/5/2006 programma gaat nu door, maar maakt wel memory schoon
      clear
      exit
  }    
  else {
      local label: data label
      display `"`file': `label' "'
  }
  di _n(0)
end
