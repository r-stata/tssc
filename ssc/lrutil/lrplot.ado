program define lrplot
*! 1.0.0 6 June 2000 Jan Brogger

	syntax [, MATrix(string) LEGend XLab SAVing(string) REPlace GRopt(string) /*
		*/  maxytick(integer 5) maxxtick(integer 15) /*
		*/  ti_s(integer 100) ax_s(integer 100) leg_s(integer 100 )  /*
		*/ xlab_s(integer 100) t1(string) t2(string) debug]

	if "`matrix'"=="" {
		capture lrmatx
		if _rc ~= 0 {
			di in red "Error running lrmatx. Is it installed ?"
			error 999
		}
		tempname ormatx
		matrix `ormatx' =r(or),r(ci)
		local ormatx `ormatx' 
	}
	else {
		local ormatx `matrix' 
	}


	capture local exist=`ormatx'[1,1]
	if _rc ~= 0 {
		di in red "Cannot access matrix of coefficients & c.i."
		error 999
	}


	if "`debug'" ~=  "" {matrix list `ormatx'}

	local cols = colsof(`ormatx')
	local rows = rowsof(`ormatx')


	if `cols' ~= 3 | `rows'<1 {
		di in red "Matrix must have 3 columns and at least 1 row"
		error 999
	}

	preserve
	drop _all

	matname `ormatx' or cil ciu , col(1..3) explicit
	qui svmat float `ormatx' , names(col)

	if "`debug'" ~=  "" {list}

	qui gen str10 coeff =""
	qui gen coeff_n=_n
	if "`debug'" ~=  "" {list}


	local varnam : rowfullname `ormatx'

	if "`debug'" ~= "" { di `"varnam: -`varnam'-"' }
	
	tokenize "`varnam'"
	local i 1
	while "`1'" ~= "" {
		qui  replace coeff=`"`1'"' if _n==`i'
		local i = `i'+1
		macro shift 1
	}


	if "`debug'" ~=  "" {list }

	if `leg_s'< 100 { local leg_s=100 }

	if "`legend'"~="" {
		local fr = 570*(`ax_s'/100)
		local fc = 290*(`ax_s'/100)
		local bboxr=25000*(100/`leg_s')
		local bbox="0,0,23000,`bboxr',`fr',`fc',0"
	}
	else {
		local fr = 570*(`ax_s'/100)
		local fc = 290*(`ax_s'/100)
		local bbox="0,0,23000,32000,`fr',`fc',0"
		}

	/* decrease xticks if there are too many */
	egen xmax=max(coeff_n)
	egen xmin=min(coeff_n)

	local xmax = xmax[1]
	local xmin = xmin[1]


	local xtick=1
	numlist "`xmin' (`xtick') `xmax'"
	local ntick : word count `r(numlist)'


	while (`ntick'>`maxxtic') {
		local xtick=`xtick'+1
		numlist "`xmin'(`xtick')`xmax'"
		local ntick : word count `r(numlist)'
	}

	/* decrease yticks if there are too many */
	/*start at an okay value on the y axis */

	egen ormax=max(ciu)
	egen ormin=min(cil)

	local ymax = ormax[1]
	if "`debug'"~="" {di "ormax: `ymax'"}
	roundup `ymax' `debug'
	local ymax = `r(rndup)'


	local ymin = ormin[1]
	if "`debug'"~="" {di "ormin: `ymin'"}
	rounddn `ymin' `debug'
	local ymin = `r(rnddn)'

	local yticks=0.25
	local ylabels=0.5


	local yticks=0.25
	if  ((`ymax'-`ymin')/`yticks') > `maxytic' {
		local yticks=int((`ymax'-`ymin')/`maxytic'*100)/100
	}

	if ("`debug'" ~= "") {
		di "`ymin'(`yticks')`ymax'"
	}

	numlist "`ymin'(`yticks')`ymax'"
	local ntick : word count `r(numlist)'

	while (`ntick'>`maxytic') {
		local yticks=`yticks'+0.25
		numlist "`ymin' (`yticks') `ymax'"
		local ntick : word count `r(numlist)'
	}


	if `"`t1'"' == `""' {
		local t1 "Logistic regression coefficients"
	}
	if `"`t2'"' == `""' {
		local t2 "Odds ratios and confidence intervals"
	}

	sort coeff_n

	if "`debug'" ~= "" {
		di "xmin `xmin' xtick `xtick' xmax `xmax'"
		di "ymin `ymin' yticks `yticks' ymax `ymax'"
		list coeff_n coeff or ciu cil /*,noobs*/


		numlist "`xmin'(`xtick')`xmax'"
		di "xnumlist: `r(numlist)'"


		numlist "`ymin'(`yticks')`ymax'"
		di "ynumlist: `r(numlist)'"

		di "t1:" `"`t1'"'
		di "t2:" `"`t2'"'
		di "gropt:" `"`gropt'"'
		di "bbox:" `"`bbox'"'
	}



	capture gph close
	if "`saving'"=="" {
		gph open
	}
	else {
		if index(`"`saving'"',`"."')== 0 {local saving `"`saving'.gph"' }

		if `"`replace'"' ~= `""' {
			capture erase `"`saving'"'
			if _rc ~= 0 {
			di in blue "File does not exist"
			}
		}
		else {
			capture confirm new file `"`saving'"'
			if _rc ~= 0 {
				di in red "Save-file already exists"
				error 999
			}
		}
		gph open , saving(`"`saving'"') 
	}


	graph or ciu cil coeff_n , /*
	*/ ylog c(".II") symbol("Oii") ylin(1) bbox(`bbox') t1(" ") t2(" ") /*
	*/ xtick(`xmin'(`xtick')`xmax') xlab(`xmin'(`xtick')`xmax') /*
	*/ ylab(`ymin'(`yticks')`ymax') ytick(`ymin'(`yticks')`ymax') `gropt' 

	local ay = r(ay)
	local by = r(by)
	local ax = r(ax)
	local bx = r(bx)

	if ("`xlab'" ~= "") {
		local i = 1
		while `i' <= _N {
			local text=coeff[`i']
			local x=`i'+0.2
			addtx , x(`x') y(`ymin') t("`text'") ay(`ay') by(`by') ax(`ax') bx(`bx') textsz(`xlab_s')
			local i=`i'+1
		}
	}

	if ("`legend'" ~= "") {
		legend ,  ay(`ay') by(`by') ax(`ax') bx(`bx') textsz(`leg_s') 
	}

	if (`"`t1'"' ~= `""' | `"`t2'"' ~= `""') {
		title ,  t1(`"`t1'"') t2(`"`t2'"') size(`ti_s') ax_s(`ax_s') leg_s(`leg_s')
	}

	gph close

	restore
end

capture program drop addtx
program define addtx
	syntax , x(real) y(real) t(string) ay(real) by(real) ax(real) bx(real) textsz(integer)

	local r=`ay'*ln(`y')+`by'
	local c=`ax'*`x'+`bx'

	local vsize=`textsz'
	local hsize=`textsz'

	local fr=570*(`vsize'/100)
	local fc=290*(`hsize'/100)

	gph pen 1
	gph font `fr' `fc'
	gph text `r' `c' 1 -1 `t'
	*gph text `r' `c' 1 -1 `fr' : `fc'
end

capture program drop legend
program define legend
	syntax ,  ay(real) by(real) ax(real) bx(real)  textsz(integer)

	local x = (25000*(100/`textsz'))+(3500*(`textsz'/100))
	local y = 0

	local vsize=`textsz'
	local hsize=`textsz'

	gen clegend=`x'

	/* decrease distance between legend items to fit */
	if (_N*1000*(`textsz'/100))>22000 {
		local ystep=round(22000/_N,1)

		local vsize=round(`ystep'/1000*(`textsz'/100)*100,1)
		local hsize=round(`ystep'/1000*(`textsz'/100)*150,1)
	}
	else {
		local ystep=1000*(`textsz'/100)
	}
	qui gen rlegend=`y'+`ystep'*_n

	qui gen str15 text=""

	local i=1
	while `i'<=_N {
	{
		local t=coeff[`i']
		replace text="`i' `t'" if _n==`i'

		local i=`i'+1
	}

	local fr=570*(`vsize'/100)
	local fc=290*(`hsize'/100)


	gph pen 1
	gph font `fr' `fc'
	gph vtext rlegend clegend text
end

capture program drop title
program define title
	syntax ,  t1(string) t2(string) size(integer) ax_s(integer) leg_s(integer)

	local vsize=`size'
	local hsize=`size'

	local fr=570*(`vsize'/100)
	local fc=290*(`hsize'/100)

	gph pen 1
	gph font `fr' `fc'

	local x=3000*(`ax_s'/100)*(100/`leg_s')

	local y1=1000
	local y2=`y1'+(1000*(`size'/100))

	if `"`t1'"' ~= `""' { 
		gph text `y1' `x' 0 -1 `t1' 
	}
	if `"`t2'"' ~= `""' { 
		gph text `y2' `x' 0 -1 `t2' 
	}

end

capture program drop rounddn
program define rounddn, rclass

	local i=int(`1'*100)/100

	local rndi = round(`i',0.25)

	if (`rndi'>`i') {
		local rndi = `rndi'-0.25 
	}


	if (`rndi' <= 0) {
		local rndi = 0.15
	}

	if ("`2'" ~= "") {
		di "rnddn: `rndi'"
	}

	return local rnddn `rndi'
end

capture program drop roundup
program define roundup , rclass

	local i=int(`1'*100)/100

	local rndi = round(`i',0.25)

	if (`rndi'>`i') {
		local rndi = `rndi'+0.25 
	}


	if ("`2'" ~= "") {
		di "rndup: `rndi'"
	}

	return local rndup `rndi'
end
