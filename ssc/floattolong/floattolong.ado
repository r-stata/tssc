/*
floattolong.ado
By David Kantor, 8-10-2004
*/
*! version 1.0.1;  8-13-2004

prog def floattolong
version 8

/*
By David Kantor, Institute for Policy Studies, Johns Hopkins University.

This is essentially -recast long varlist-, for vars that are float.

This is to complement -compress-, to change floats to long where possible.
Thus, it recasts to a more appropriate type, even though it is not shorter.
(I think this ought to be an option on -compress-.)

*/

syntax [varlist]

local numvars "0"

foreach var of local varlist {
 local origtyp: type `var'
 if "`origtyp'" == "float" {
  local ++numvars
  recast long `var'
  local newtyp: type `var'
  if "`newtyp'" == "long" {
   disp as text "`var' changed to long"
  }
 }
}

if `numvars' == 0 {
 disp as text "(no float variables specified)"
}

end // floattolong





