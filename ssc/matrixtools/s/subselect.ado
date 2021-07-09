*! Part of package matrixtools v. 0.24
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk
* 2018-08-21 > Created
program define subselect
	syntax varname [if] [in], GENerate(name)
	
	mata: nhb_sae_subselect(`"`varlist'"', `"`generate'"', `"`if'"', `"`in'"')
end
