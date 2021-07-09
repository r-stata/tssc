cap program drop fagan
*! version 1.00 June 14, 2009
*! Ben A. Dwamena: bdwamena@umich.edu 

program define fagan, rclass 
version 10
syntax varlist(min=2 max=2) [if] [in], GRPvar(varname) [PRior(real 0.5) LEGENDopts(string asis) YSIZE(integer 6) XSIZE(integer 5) *]


tokenize `varlist'

local lrp `1'
local lrn `2'

foreach p in 0.1 0.2 0.3 0.5 0.7 1 2 3 5 7 10 ///
20 30 40 50 60 70 80 90 93 95 97 98 99  99.3 99.5 99.7 99.8 99.9 {   
         local ylab `"`ylab' `=ln(`p' / (100 - `p'))' "`p'" "'
}
foreach lr in 0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20  ///
        50 100 200 500 1000 {
        local lrpts `"`lrpts' `=-.5*ln(`lr')' 0 "`lr'" "'
}

tempvar id
gen `id'=_n
qui levelsof `id', local(slevels)
local l 5
local prprob = logit(1-`prior')
local note0: di  "PreProb:"%3.0f 100*`prior' "% "

foreach s of local slevels {
local id "`grpvar'[`s']"
local note: di `id'
local lrp`s' = `lrp'[`s']
local ppp`s' = logit(`prior') + log(`lrp'[`s'])
local note1: di "PostProb:"%5.1f 100*invlogit(`ppp`s'') "% "
local note2: di "LRP:"%5.2f `lrp`s'' "

local pppplot `"`pppplot' (pcarrowi `prprob' -1 `ppp`s'' 1, yaxis(2) lpatt(shortdash) barbsize(1) mlw(vvthin))"'
local legend1 `"`legend1' label(`l' "`note'(+)" "`note2'" "`note1'" )"'
local order "`order' `l++'"
}


foreach s of local slevels {
local id "`grpvar'[`s']"
local note: di `id'
local ppn`s' = logit(`prior') + log(`lrn'[`s'])
local lrn`s' = `lrn'[`s']
local note3: di "PostProb:"%5.1f 100*invlogit(`ppn`s'') "% "
local note4: di "LRN:"%5.2f `lrn`s'' "
local ppnplot `"`ppnplot' (pcarrowi `prprob' -1 `ppn`s'' 1, yaxis(2) lpatt(solid) barbsize(1) mlw(vvthin))"'
local legend2 `"`legend2' label(`l' "`note'(-)" "`note4'" "`note3'" )"'
local order "`order' `l++'"
}

if "`legendopts'" != "off" {
	if "`legendopts'" == "" { // default legend options
		local legendopts `"pos(2) size(*.550) symy(0.5) symx(5) cols(1) rowgap(2)"'
	}
	local legendopts `" order(4 "`note0'" `order') `legend1' `legend2' `legendopts'"'
}





#delimit;
tw (scatteri 0 0, mcolor(none) yaxis(1) ylab(`ylab', angle(0) 
tpos(cross)) yscale(reverse axis(1)) ytitle("Prior Probability (%)", size(*.75) axis(1)))
(scatteri 0 0, mcolor(none) yaxis(2) ylab(`ylab', angle(0) tpos(cross) axis(2))
 ytitle("Posterior Probability (%)", size(*.75) axis(2)))
(scatteri `lrpts', msymbol(+) mcolor(black) mlabcolor(black) mlabsize(medsmall))
(pci -3.4538776 0 3.4538776 0, msymbol(none) recast(pcspike) lcolor(black) 
xscale(range(-1 1)) plotregion(margin(zero)) xscale(off) ylab(, nogrid) text(-4 0 "Likelihood Ratio", place(n)))
`pppplot' `ppnplot', legend(`legendopts') subti(Fagan's nomogram) xsize(`xsize') ysize(`ysize') `options'; 
#delimit cr 

end



               

