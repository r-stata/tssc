/*
doubletofloat.ado
By David Kantor, 10-18-2004
*/
*! version 1.0.2;  10-20-2004

prog def doubletofloat
version 8

/*
By David Kantor, Institute for Policy Studies, Johns Hopkins University.

This is essentially -recast float varlist-, for vars that are double.

This is to complement -compress-, to change floats to long where possible.
This complements -compress-, which does not make this particular change.
(I think this ought to be an option on -compress-.)

The code is based on floattolong.ado.

*/

syntax [varlist]

local numvars "0"

foreach var of local varlist {
 local origtyp: type `var'
 if "`origtyp'" == "double" {
  local ++numvars
  recast float `var'
  local newtyp: type `var'
  if "`newtyp'" == "float" {
   disp as text "`var' changed to float"
  }
 }
}

if `numvars' == 0 {
 disp as text "(no double variables specified)"
}

end // doubletofloat





