*! 1.1.1 NJC 1 October 2014 
* 1.1.1 NJC 22 September 2014 
* 1.1.0 NJC 28 August 2014 
* 1.0.0 NJC 22 August 2014 
program subsetplot 
	version 8.2 
	gettoken command 0 : 0 
	syntax varlist(numeric min=2) [if] [in] , by(varname) ///
	[ SUBSET(str) COMBINE(str) BACKDROP(str)              ///
        SEQuence(str) seqopts(str asis)                       ///  
	ENDS ENDS2(str asis) EXTremes EXTremes2(str asis)  * ] 

	quietly { 
		marksample touse 
		markout `touse' `by', strok 
		count if `touse' 
		if r(N) == 0 error 2000 

		local nvars : word count `varlist' 
		local y : word 1 of `varlist' 
		local x : word `nvars' of `varlist' 

		tempvar group 
		egen `group' = group(`by') if `touse', label 
		su `group', meanonly 
		local ng = r(max)

		if inlist("`command'", "line", "connect") { 
			local lopts1 "connect(L) lcolor(gs12) mcolor(gs12)"
			local lopts2 "lcolor(orange) lw(thick) mcolor(orange)" 
		}  

		if "`backdrop'" == "" local backdrop "`command'" 

		if `"`ends'`ends2'"' != "" { 
			tempvar xmin xmax 
			egen `xmin' = min(`x'), by(`group')
			egen `xmax' = max(`x'), by(`group')
			local end = 1 
		} 
		else local end = 0 

		if `"`extremes'`extremes2'"' != "" { 
			tempvar ymin ymax 
			egen `ymin' = min(`y'), by(`group')
			egen `ymax' = max(`y'), by(`group')
			local ext = 1 
		} 
		else local ext = 0 

		tokenize "`sequence'" 
		local s = 0 

		forval i = 1/`ng' { 
			tempname g 

			local which : label (`group') `i'

			if "`sequence'" != "" { 
				local ++s 
				local slabel ///
				caption("``s''", pos(11) size(large)) `seqopts'
			} 

			if `ext' { 
				local extcall ///
				scatter `ymin' `x' if `group' == `i' & `y' == `ymin', ///
				ms(O) mc(blue) msize(*1.2) mla(`y') mlabpos(12) `extremes2'
				|| scatter `ymax' `x' if `group' == `i' & `y' == `ymax', ///
				ms(O) mc(blue) msize(*1.2) mla(`y') mlabpos(6) `extremes2'
			}
			
			if `end' { 
				local endcall ///
				scatter `y' `xmin' if `group' == `i' & `x' == `xmin', ///
				ms(O) mc(blue) msize(*1.2) mla(`y') mlabpos(9) mlabcolor(blue) `ends2' ///
				|| scatter `y' `xmax' if `group' == `i' & `x' == `xmax', ///
				ms(O) mc(blue) msize(*1.2) mla(`y') mlabpos(3) mlabcolor(blue) `ends2'

			}

			twoway `backdrop' `varlist' if `touse' & `group' != `i', ///
			ms(Oh) mcolor(orange) `lopts1' `slabel' `options' ||     ///    
			`command' `varlist' if `group' == `i', ///
			ms(O) mcolor(blue) subtitle(`"`which'"')    ///
			legend(off) nodraw `lopts2' `subset' name(`g') ///
			|| `extcall' || `endcall' 
	
			local G `G' `g' 
		} 
	} 
			
	graph combine `G', ycommon xcommon `combine' 
end

// {cmdab:seq:uence(}{it:words_in_sequence}{cmd:)} 
// {cmd:seqopts(}{it:option}{cmd:)}

//{p 4 8 2} 
//{cmd:sequence()} specifies text to appear in sequence to act as captions
//for each plot. For example, {cmd:seq(a b c d)} specifies that successive
//graphs will be labelled {cmd:a}, {cmd:b}, {cmd:c} and {cmd:d}.  The
//precise syntax is that successive {it:word}s of the argument will be
//shown using the option 
//{cmd:caption("}{it:word}{cmd:", pos(11) size(large))}. As usual in
//Stata, binding in double quotes {cmd:" "} is stronger than separation by
//spaces, so syntax such as 
//{cmd:seq("first caption" "second caption" "third caption" "fourth caption")} 
//would show text with embedded spaces. 
//
//{p 4 8 2} 
//{cmd:seqopts()} specifies modification of the default display for
//{cmd:sequence()}. For example, {cmd:seqopts(caption(, color(red))}
//changes the text colour to red. Note that substantial changes are likely
//to require use of the Graph Editor or your own syntax. 

