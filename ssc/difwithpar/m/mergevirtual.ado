*! mergevirtual.ado 		v 1.0.1, 	March 25, 2009

*merges final virtual items back into original data set
*syntax: mergevirtual original_data original_id

version 7.0
set more off

capture program drop mergevirtual
program define mergevirtual

clear
use "itemdata"
sort parscaleid
save "itemdata", replace
clear
use "`1'"						/*original data*/
capture drop _merge parscaleid

local DB_id `2'					/*original ID*/
local idtype: type `DB_id'
if substr("`idtype'",1,3)=="str" {
	encode `DB_id', gen(numid)
	gen long parscaleid = numid +1000000000	
	drop numid
	}
else	{
	capture assert `DB_id' < 1000000000	
	gen long parscaleid = `DB_id' +1000000000	
	}

sort parscaleid

merge parscaleid using "itemdata"
assert _merge==3  | _merge==1
save "`1'",replace
capture erase "itemdata.dta"
end

* by Laura Gibbons
* Copyright 2005, University of Washington.

