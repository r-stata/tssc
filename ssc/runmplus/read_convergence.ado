* Read in Mplus output file and determine if the model converged.
* edited 20131116
* Mplus does not always report "THE MODEL ESTIMATION TERMINATED NORMALLY"

version 10.0

capture program drop read_convergence
program define read_convergence , rclass


syntax , out(string) 

tempname fh
local linenum = 0
file open `fh' using `"`out'"', read
file read `fh' line
while r(eof)==0 { 
   local linenum = `linenum' + 1 //     THE MODEL ESTIMATION TERMINATED NORMALLY
   if regexm(lower(`"`macval(line)'"'),"the model estimation terminated normally")==1 {
      local normal=1
   }
   if regexm(lower(`"`macval(line)'"'),"the model estimation terminated normally but with errors")==1 {
      local normal=0.5
   }
   if regexm(lower(`"`macval(line)'"'),"model command with final estimates used as starting values")==1 {
      if "`normal'"~="1" { // because if already normal then you got here b/c of svalues option
         local normal=0
      }
   }
   file read `fh' line
}
file close `fh'


if "`normal'"=="0.5" {
   di as error "THE MODEL ESTIMATION TERMINATED NORMALLY BUT WITH ERRORS"
   local stop = 0 // changed 20131116
   local termination = "normal with errors"
}

if "`normal'"=="0" {
   di as error "THE MODEL ESTIMATION DID NOT TERMINATE NORMALLY"
   local stop = 1 // changed 20131116
   local termination = "not normal"
}

if "`normal'"=="1" {
   di in green "THE MODEL ESTIMATION TERMINATED NORMALLY"
   local stop=0
   local termination = "normal"
}

if "`normal'"~="0" & "`normal'"~="0.5" & "`normal'"~="1" {
   local stop=0
   local termination = "normal-ambiguous"
}
   

return local stop = `stop'
return local termination = "`termination'"

end

