*!Power function calculations for Second Generation P-Values
*!Author: Sven-Kristjan Bormann
*Based on the R-code for sgpower.R  from the sgpv-package from https://github.com/weltybiostat/sgpv
*!Version 1.01  14.05.2020 : Changed type of returned results from macro to scalar to be more inline with standard practise
*Version 1.00  : Initial SSC release, no changes compared to the last Github version.
*Version 0.92	: Fixed some issues in the documentation, changed the renamed the returned results to be the same as in the original R-code.
*Version 0.91 	: Removed dependency on user-provided integrate-command. 
*Version 0.90 	: Initial Github Release
*Works only on one interval and one true value at the moment; 
*The standard error has to be a number and cannot be an expression like in the R-code
*Not possible to plot directly the power function yet, an example how to plot the power function is located in the file sgpower_plot_example.do
*The displayed results could be labeled better and explain more but for now they are the same as in the original R-code.

capture program drop sgpower
program define sgpower, rclass
version 12.0
syntax , true(real)  nulllo(real)  nullhi(real)  INTType(string)   INTLevel(string) [STDerr(real 1)  Bonus]

if !inlist("`inttype'", "confidence","likelihood"){
	disp as err "Option 'inttype' must be one of the following: confidence or likelihood "
	exit 198
}
local intlevel = `intlevel'
	
if "`inttype'"=="confidence"{
	local z = invnorm(1- `intlevel'/2)
}

if "`inttype'"=="likelihood"{
	local z = invnorm(1- 2*normal(-sqrt(2*log(1/`intlevel')))/2)
}

**P(SGPV=0 | true ) (see Blume et al. (2018) eq.(S4) for CI/LSI)
local power0 = normal(`nulllo'/`stderr' - `true'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `true'/`stderr' - `z')

**P(SGPV=1 | true ) (see Blume et al. (2018) eq.(S7) for CI/LSI)
* -> only for symmetric null hypothesis
if (`nullhi'-`nulllo')>= 2*`z'*`stderr' {
	local power1 = normal(`nullhi'/`stderr' - `true'/`stderr' - `z') - normal(`nulllo'/`stderr' - `true'/`stderr' + `z')
}
if (`nullhi'-`nulllo') < 2*`z'*`stderr'{
	local power1 = 0
}

 ** P(0<SGPV<1 | true)   (see Blume et al. (2018) eq.(S8, S9) for CI/LSI)
  * -> only for symmetric null hypothesis
if (`nullhi'-`nulllo')<= 2*`z'*`stderr' {
	local powerinc = 1 - normal(`nulllo'/`stderr' - `true'/`stderr' -`z') - normal(-`nullhi'/`stderr' + `true'/`stderr' - `z')
}

if (`nullhi'-`nulllo') > 2*`z'*`stderr'{
	local powerinc = 1 - (normal(`nulllo'/`stderr' - `true'/`stderr' -`z')  + normal(-`nullhi'/`stderr' + `true'/`stderr' - `z')) - (normal(`nullhi'/`stderr' - `z') - normal(`nulllo'/`stderr' - `true'/`stderr' + `z'))
}


if round(`power0'+ `powerinc'+`power1',0.0000001)!=1{
disp as error "power.0+power.inc+power.1 != 1 for indices "

}

**Returned values
disp "power.alt: " round(`power0',0.0001) _skip(10)  "power.inc: " round(`powerinc',0.0001) _skip(20) "power.null: " round(`power1',0.0001) 

if "`bonus'"!=""{
**bonus type I error summaries
  *local pow0 normal(`nulllo'/`stderr' - `x'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `x'/`stderr' - `z')
  local x (`nulllo'+`nullhi')/2
  local minI = normal(`nulllo'/`stderr' - `x'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `x'/`stderr' - `z')
  local x `nulllo'
  local maxI = normal(`nulllo'/`stderr' - `x'/`stderr' -`z') + normal(-`nullhi'/`stderr' + `x'/`stderr' - `z')
  
  
  *Use Stata's internal numerical integration command 
  preserve
  quietly{ 
	  range x `nulllo' `nullhi' 1000 //Arbitrary number of integration points could be made dependent on the distance between upper and lower limit
	  gen y = normal(`nulllo'/`stderr' - x/`stderr' -`z') + normal(-`nullhi'/`stderr' + x/`stderr' - `z')
	  integ y x
	  local intres `r(integral)'
  }
  restore

  local avgI = 1/(`nullhi'-`nulllo')*`intres'
  local pow00 = normal(`nulllo'/`stderr' - 0/`stderr' -`z') + normal(-`nullhi'/`stderr' + 0/`stderr' - `z')
  disp "type I error summaries"
  if `nulllo>0' & `nullhi'>0{
  disp "Min: " round(`minI',0.000001) _skip(10) "Max: " round(`maxI',0.000001) _skip(10) "Mean :" round(`avgI',0.000001)
  }
  else if `nulllo'<=0 & `nullhi'<=0 {
	  disp "at 0: " round(`pow00',0.000001) _skip(10) "Min: " round(`minI',0.000001) _skip(10) "Max: " round(`maxI',0.000001) _skip(10) "Mean :" round(`avgI',0.000001)

  }
}

return scalar poweralt = `power0'
return scalar powernull = `power1'
return scalar powerinc = `powerinc'
if "`bonus'"!=""{
return scalar minI = `minI'
return scalar maxI = `maxI'
return scalar avgI = `avgI'
}
end
