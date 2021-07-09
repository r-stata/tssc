*! onespell 1.1.1  CFBaum  13jan2005
* 1.1.1: add preserve/restore

program onespell, rclass
version 8.2
syntax varlist [if] [in], Saving(string) [ REPLACE NOIsily]
* locate units with internal gaps in varlist and zap all but longest spell
preserve
qui tsset
local pv  "`r(panelvar)'"
local tv "`r(timevar)'"
su `pv', meanonly
local n1 = r(N)
tsfill
marksample touse
tempvar testgap spell seq end maxspell keepspell wantspell
* testgap is panelvar if obs is usable, 0 otherwise
local sss "qui"
if "`noisily'" == "noisily" {
	local sss "noi"
	}
`sss' {
g `testgap' = cond(`touse',`pv',.)
tsspell `testgap' if `testgap'<., spell(`spell') seq(`seq') end(`end')
drop if `spell'==0 | `touse'==0
* if `spell' > 1 for a unit, there are gaps in usable data
* calculate max length spell for each unit and identify
* that spell as the one to be retained
egen `maxspell'= max(`seq'), by(`pv')
bys `pv': g `keepspell' = cond(`seq'==`maxspell',`spell',0)
egen `wantspell' = max(`keepspell'), by(`pv')
* in case of ties, latest spell of max length is selected
l `pv' `tv' `spell' `seq' `maxspell' `keepspell' `wantspell', sepby(`pv') 
su `spell' `wantspell'
keep if `wantspell' == `spell'
su `pv', meanonly
local n2 = r(N)
drop __*
}
di _n "Observations removed: " `n1'-`n2'
save `saving',`replace'
restore
end
