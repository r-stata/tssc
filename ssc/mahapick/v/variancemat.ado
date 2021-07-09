/*
ado\variancemat.ado  4-7-2003
David Kantor

This is to create a column-matrix of variances.

This was written for use by mahapick & mahascore.  But may have other uses
as well.

11-12-2003: added the weights.  I had no need for them, but it is easy to
program; might as well do it.
Also adding -common- option.

11-21-2003: a slight refinement to the coding of the use of -common-.

2-9-2006: fixing version.
*/
*! version 1.0.4 9feb2006


capture prog drop variancemat

prog def variancemat
version 8.2

syntax varlist [if] [in] [aw fw iw], matname(string) [common]


if "`common'" == "" {
 local novarlist "novarlist"
}
marksample touse, `novarlist'







local numvars = 0
foreach var of local varlist {
 local ++numvars
}

matrix `matname' = J(`numvars', 1, 0)
matrix rownames `matname' = `varlist'
matrix colnames `matname' = variance

foreach var of local varlist {
 local rownum = rownumb(matrix(`matname'), "`var'")
 qui sum `var' if `touse' [`weight' `exp']
 matrix `matname'[`rownum', 1] = r(Var)
}

end

