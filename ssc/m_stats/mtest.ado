/* mtest - returns the observed M statistic and the p-value (Monte Carlo resampling) of M under the null hypothesis that Cases and Controls follow the same spatial distribution
Pietro Tebaldi , Harvard School of Public Health and Bocconi University
July 2010 */

program define mtest , rclass
version 10.1
syntax , x(varname) y(varname) g(varname) [ bins(integer 20) iter(integer 100) level(real 95) SCatter DENsity ] ///
		[scolor0(string asis)] 	///
		[scolor1(string asis)] 	///
		[smarker0(string)] 		///
		[smarker1(string)] 		///
		[ssize0(string asis)] 		///
		[ssize1(string asis)] 		///
		[slabel0(string)] 		///
		[slabel1(string)] 		///
		[stitle(string)] 		///
		[sytitle(string)] 		///
		[sxtitle(string)] 		///
		[dcolor0(string)] 		///
		[dcolor1(string)]		///
		[dpattern0(string)] 	///
		[dpattern1(string)] 	///
		[dwidth0(string)] 		///
		[dwidth1(string)]		///
		[dlabel0(string)]		///
		[dlabel1(string)]		///
		[dtitle(string)]
		
tempname Sinv d

capture count
local N = r(N)
forvalues i = 1/`N' {
if `g'[`i']!=1 & `g'[`i']!=0 {
display as error "The group variable g must be bivariate 0,1"
error
}
}

// SCATTER OPTIONS
if "`scatter'" == "scatter" {
// color
	foreach j in 0 1 {
		if "`scolor`j''" != "" {
			local scolor`j' = "`scolor`j''"
		}
		else {
			local scolor`j' = "black"
		}
	}
// marker
	if "`smarker0'" != "" {
		local smarker0 = "`smarker0'"
	}
	else {
		local smarker0 = "oh"
	}
	if "`smarker1'" != "" {
		local smarker1 = "`smarker1'"
	}
	else {
		local smarker1 = "x"
	}

// size
	foreach j in 0 1 {
		if "`ssize`j''" != "" {
			local ssize`j' = "`ssize`j''"
		}
		else {
			local ssize`j' = "medium"
		}
	}

// label
	foreach j in 0 1 {
		if "`slabel`j''" != "" {
			local slabel`j' = "`slabel`j''"
		}
		else {
			local slabel`j' = "Group `j'"
		}
	}

// title
	if "`stitle'" != "" {
		local stitle = "`stitle'"
	}
	else {
		local stitle = "Spatial Distribution of the two groups"
	}	

// axis title
	if "`sytitle'" != "" {
		local sytitle = "`sytitle'"
	}
	else {
		local sytitle = "`y'"
	}
	if "`sxtitle'" != "" {
		local sxtitle = "`sxtitle'"
	}
	else {
		local sxtitle = "`x'"
	}

	
	tempvar X1 X2 Y1 Y2
	quietly {
		gen `X1' = `x' if `g'==0
		gen `Y1' = `y' if `g'==0
		gen `X2' = `x' if `g'==1
		gen `Y2' = `y' if `g'==1
		label var `X1' "`slabel0'"
		label var `Y1' "`slabel0'"
		label var `X2' "`slabel1'"
		label var `Y2' "`slabel1'"
	}
	capture scatter `Y1' `X1'  , msymbol(`smarker0') mcolor(`scolor0') msize(`ssize0') ytitle(`sytitle') xtitle(`sxtitle') title(`stitle') || scatter `Y2' `X2' , msymbol(`smarker1') mcolor(`scolor1') msize(`ssize1') , nodraw saving(scatter)
}
// DENSITY OPTIONS
if "`density'" == "density" {

// color
	foreach j in 0 1 {
		if "`dcolor`j''" != "" {
			local dcolor`j' = "`dcolor`j''"
		}
		else {
			local dcolor`j' = "black"
		}
	}
	
// pattern
	if "`dpattern0'" != "" {
		local dpattern0 = "`dpattern0'"
	}
	else {
		local dpattern0 = "dash"
	}
	if "`dpattern1'" != "" {
		local dpattern1 = "`dpattern1'"
	}
	else {
		local dpattern1 = "solid"
	}

// width
	foreach j in 0 1 {
		if "`dwidth`j''" != "" {
			local dwidth`j' = "`dwidth`j''"
		}
		else {
			local dwidth`j' = "medium"
		}
	}

// label
	foreach j in 0 1 {
		if "`dlabel`j''" != "" {
			local dlabel`j' = "`dlabel`j''"
		}
		else {
			local dlabel`j' = "Group `j'"
		}
	}
	

// title
	if "`dtitle'" != "" {
		local dtitle = "`dtitle'"
	}
	else {
		local dtitle = "IDD Kernel Densities"
	}	
	
	
	preserve
	capture count
	local N = r(N)
	local Ndist = comb(`N',2)
	quietly {
		gen X1 = `x' if `g'==0
		gen Y1 = `y' if `g'==0
		drop if X1 == .
		eucldist X1 Y1
		mata: g0 = st_data(.,1)							
		clear
		restore
		preserve
		gen X2 = `x' if `g'==1
		gen Y2 = `y' if `g'==1
		drop if X2 == .
		eucldist X2 Y2
		mata: g1 = st_data(.,1)																
		clear
	}
	mata: Nca = rows(g1)
	mata: Nco = rows(g0)
	quietly {
		set obs `Ndist'
		mata: ca = st_addvar("float","dlabel1")
		mata: co = st_addvar("float","dlabel0")
		mata: st_store((1,Nca),ca,g1)
		mata: st_store((1,Nco),co,g0)
		label var dlabel1 "`dlabel1'"
		label var dlabel0 "`dlabel0'"
		kdensity dlabel1 , gen(x1 d1) nograph
		kdensity dlabel0 , gen(x2 d2) nograph
		line d2 x2 , lcolor(`dcolor1') lpattern(`dpattern1') lwidth(`dwidth1') ytitle("density") xtitle("interpoint distance") title(`dtitle') || line d1 x1 , lcolor(`dcolor0') lpattern(`dpattern0') lwidth(`dwidth0')  , nodraw saving(density)
		clear
		restore
	}
}
if "`scatter'" == "scatter" {
	graph use scatter.gph
	erase scatter.gph
}
if "`density'" == "density" {
	graph use density.gph
	erase density.gph
}

capture mstat , x(`x') y(`y') g(`g') bins(`bins')
matrix `d' = r(d)
matrix `Sinv' = r(Sinv)
tempname b c reps p se ci
capture permute `g' M=r(M) , reps(`iter') right level(`level') nodots nowarn noheader: Mst_iter , x(`x') y(`y') g(`g') sinv(`Sinv') d(`d')
capture return list
matrix `b' = r(b)
matrix `c' = r(c)
matrix `reps' = r(reps)
matrix `p' = r(p)
matrix `se' = r(se)
matrix `ci' = r(ci)
display "{txt}{hline 65}"
display as text "M statistic"
display as text "Monte Carlo permutation results"
display as text "H0: The two groups have the same spatial distribution"
display as text "Number of bins = `bins'"
display as text "Number of permutations = `iter'"

tempname Tab
	.`Tab' = ._tab.new, col(7) lmargin(0) ignore(.b)
	ret list
	// column           1      2     3     4     5     6     7   
	.`Tab'.width	12     |8     8     8     8    10    10
	.`Tab'.titlefmt  .     .     .     .     .  %20s     .
	.`Tab'.pad	     2     0     0     0     0     0     1
	.`Tab'.numfmt   %9.0g     .     . %7.4f %7.4f     .     .
// begin display
	.`Tab'.sep, top
	.`Tab'.titles "M(obs)" "c" "n" "p=c/n" "SE(p)" ///
		"[`level'% Conf. Interval]" ""
	.`Tab'.sep
	.`Tab'.row 	`b'[1,1] `c'[1,1] `reps'[1,1] `p'[1,1] `se'[1,1] `ci'[1,1]	`ci'[2,1]
    .`Tab'.sep, bottom
dis as text "note: c = #{M>=M(obs)}"
dis as text "note: exact binomial confindece interval with respect to p=c/n"
return matrix M = `b'
return matrix c = `c'
return scalar N = `N'
return matrix d = `d'
return matrix Sinv = `Sinv'
return matrix reps = `reps'
return matrix p = `p'
return matrix se = `se'
return matrix ci = `ci'

end

