cap program drop fagani
*! version 2.00 June 14, 2009
*! Ben A. Dwamena: bdwamena@umich.edu 

program define fagani, rclass
version 9
syntax anything [if] [in], [ LEGENDopts(string) YSIZE(integer 6) XSIZE(integer 5) * ]

tempname prev lrp lrn sens spec
qui{

	tokenize "`anything'"
	scalar `prev' = `1'
	scalar `lrp' = `2'
	scalar `lrn' = `3'
	local prprob = logit(1-`prev')
	local postprob1 = logit(`prev') + log(`lrp')
	local postprob2 = logit(`prev') + log(`lrn')


foreach p in 0.1 0.2 0.3 0.5 0.7 1 2 3 5 7 10 ///
20 30 40 50 60 70 80 90 93 95 97 98 99  99.3 99.5 99.7 99.8 99.9 {   
         local ylab `"`ylab' `=ln(`p' / (100 - `p'))' "`p'" "'
}
foreach lr in 0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20  ///
               50 100 200 500 1000 {
         local lrpts `"`lrpts' `=-.5*ln(`lr')' 0 "`lr'" "'
}

	local priorprob = 100*`prev' 
	local postprobpos = 100*invlogit(`postprob1')
	local postprobneg = 100*invlogit(`postprob2')

	local notebb1: di "Prior Prob (%) = " %5.0f `priorprob' "
	local notebb2: di "LR_Positive = " %5.0f `lrp' "
	local notebb3: di "Post_Prob_Pos (%) =" %5.0f `postprobpos' "
	local notebb4: di "LR_Negative = " %5.2f `lrn' "
	local notebb5: di "Post_Prob_Neg (%) = " %5.0f `postprobneg' "

if "`legendopts'" != "off" {
	if "`legendopts'" == "" { // default legend options
		local legendopts `"pos(6) size(*.90) col(1) rowgap(2)"'
	}
	local legendopts `" order(5 "`notebb1'" 6 "`notebb2'" "`notebb3'" 7 "`notebb4'" "`notebb5'") `legendopts'"'
}


#delimit;
tw (scatteri 0 0, mcolor(none) yaxis(1) ylab(`ylab', angle(0) 
tpos(cross)) yscale(reverse axis(1)) ytitle("Pre-test Probability (%)", axis(1)))
(scatteri 0 0, mcolor(none) yaxis(2) ylab(`ylab', angle(0) tpos(cross) axis(2))
 ytitle("Post-test Probability (%)", axis(2)))
(scatteri `lrpts', msymbol(+) mcolor(black) mlabcolor(black) mlabsize(medsmall))
(pci -3.4538776 0 3.4538776 0, recast(pcspike) lcolor(black) 
xscale(range(-1 1)) plotregion(margin(zero)) xsize(4) ysize(6)
xscale(off) ylab(, nogrid) text(-4 0 "Likelihood Ratio", place(n)))
(scatteri `prprob' -1, msym(D) yaxis(2))(pcarrowi `prprob' -1 `postprob1' 1,
 yaxis(2) lpat(solid) lwidth(vthin))(pcarrowi `prprob' -1 `postprob2' 1, 
 yaxis(2) lpat(dash) lwidth(thin)), legend(`legendopts') `options'; 
#delimit cr 
}
end                                                                
               
