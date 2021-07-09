* Author: Martin Eckhoff Andresen
* This program is part of the mtefe package.

cap program drop mtefeplot

{
	program define mtefeplot
		version 13.0
		syntax [namelist], [ /* 
		*/ normalci /*
		*/ cropfigure(numlist) /*
		*/ folder(string) /*
		*/ names(string) /*
		*/ graph_opts(string) /*
		*/ legendtitle(string) /*
		*/ level(integer 95) /*
		*/ late /*
		*/ att /*
		*/ atut /*
		*/ prte /*
		*/ mprte1 /*
		*/ mprte2 /*
		*/ mprte3 /*
		*/ SEParate /*
		*/ MEMory /*
		*/ TRIMSupport(numlist ascending min=2 max=2) /*
		*/ points /*
		*/ ]


		qui {
			if "`points'"=="" {
				loc plottype line
				loc cmissing cmissing(n)
			}
			else {
				loc plottype scatter
				loc cmissing msymbol(circle_hollow)
			}
			local numEsts: word count `namelist'
			if "`memory'"!="" loc use restore
			else loc use use

			if "`folder'"!="" loc folder `folder'/

			if `numEsts'==0 {
				loc namelist base
				loc numEsts=1
			}

			if "`separate'"!=""{
				cap confirm matrix e(support1)
				if _rc!=0 {
					noi di in red "No potential outcomes found. These are not estimated with Local IV."
					exit
				}
			}

			if "`trimsupport'"!="" {
				tokenize `trimsupport'
				loc trimlow `1'
				loc trimhigh=`2'
			}

			if ("`prte'"!=""|"`late'"!=""|"`atut'"!=""|"`att'"!="")&`numEsts'>1 {
				di in red "Do not specify more than one MTE estimate when plotting weights."
				exit 301
			}

			if strpos("`graph_opts'","ytitle")==0 loc graph_opts ytitle("Treatment effect")

			if "`cropfigure'"!="" {
				numlist "`cropfigure'"
				local numcrop: word count `r(numlist)'
				if !inlist(`numcrop',0,2) {
					di in red "Assign only two values to cropfigure option"
					exit 301
				}

				loc counter=0
				foreach value in `cropfigure' {
					loc counter=`counter'+1
					loc crop`counter'=`value'
				}
			}


			preserve
			clear

			//Plot 1: Main MTE plot with ATE and ci bands OR Potential outcomes and MTE plots
			if `numEsts'==1&"`prte'"==""&"`late'"==""&"`atut'"==""&"`att'"=="" {
				if "`namelist'"!="base" estimates `use' `folder'`namelist'
				if "`e(cmd)'"!="mtefe" {
					if "`namelist'"=="base" di in red "Estimates in memory is not created by mtefe."
					else di in red "Stored estimates `namelist' estimate is not created by mtefe."
					exit 301
				}
				tempname sup mte V
				mat `mte'=e(mte)'
				svmat `mte'
				mat `sup'= e(support)
				svmat `sup'
				loc min=`sup'[1,1]
				loc max=`sup'[rowsof(`sup'),1]
				loc cols=0
				cap confirm matrix e(V)
				if _rc==0 {
					mat `V'=e(V)
					mat `V'=`V'["mte:","mte:"]
					if "`separate'"==""  {
						capture confirm scalar e(level)
						if _rc!=0 {
							qui ereturn display, level(`level')
							tempname r confint
							mat `r'=r(table)
							mat `confint'=`r'[rownumb(`r',"ll")..rownumb(`r',"ul"),colnumb(`r',"u`=`min'*100'")..colnumb(`r',"u`=`max'*100'")]
							mat `confint'=`confint''
							loc conflevel=r(level)
						}
						else {
							noi di _rc
							tempname confint
							loc conflevel=e(level)
							if "`normalci'"!="" mat `confint'=e(ci_normal)'
							else mat `confint'=e(ci_percentile)'
							mat `confint'=`confint'[rownumb(`confint',"u`=`min'*100'")..rownumb(`confint',"u`=`max'*100'"),1..2]
						}
					
					svmat `confint'
					if "`cropfigure'"!="" {
						replace `confint'1=`crop1' if `confint'1<`crop1'
						replace `confint'2=`crop2' if `confint'2>`crop2'
					}
					loc twoway (rarea `confint'1 `confint'2 `sup'1, `cmissing' color(gs13))
					loc labels label(1 "`conflevel'% CI")
					loc ++cols
					loc order order(2 1 3)
					}
				}
				loc twoway `twoway' (`plottype' `mte' `sup'1, lpattern(solid) `cmissing')
				loc ++cols
				loc labels `labels' label(`cols' "MTE")
				loc ++cols
				loc labels `labels' label(`=`cols'' "ATE")
				loc twoway `twoway' (function y=_b[effects:ate], range(`min' `max') lcolor(maroon) lpattern(dash))
				if "`separate'"!="" {
					tempname Y1 Y0 support1 support0
					tempfile plotdata
					forvalues i=0/1 {
						save `plotdata', replace
						clear
						mat `Y`i''=e(Y`i')
						svmat `Y`i'', names(`Y`i'')
						mat `support`i''=e(support`i')
						svmat `support`i'', names(`sup')
						merge 1:1 `sup'1 using `plotdata', nogen
						save `plotdata', replace
						loc ++cols
						loc labels `labels' label(`cols' "Y`i'")
					}
loc twoway `twoway' (`plottype' `Y0'1 `Y1'1 `sup'1, yaxis(2) lpattern(dash dot) `cmissing')
loc ytitle2 ytitle("Potential outcomes", axis(2))
}
loc labels `labels' cols(`cols')
}


//Plot 2: Multiple MTE plots together. No weights or ci intervals
if `numEsts'>1 {
if "`names'"!="" {
tokenize `names'
local numnames: word count `names'
}
else loc numnames=0
loc counter=0
foreach estimate in `namelist' {
loc counter=`counter'+1
if `counter'<=`numnames' loc labels `labels' label(`counter' "``counter''")
else loc labels `labels' label(`counter' "`estimate'")
if "`estimate'"!="base" estimates `use' `folder'`estimate'
if `counter'==1 {
tempname sup mainsupport
mat `sup'= e(support)
mat `mainsupport'=e(support)'
loc rowsmain=rowsof(`sup')
qui svmat `sup'
}
else {
mat `sup'=e(support)
if `rowsmain'==rowsof(`sup') loc test mreldif(`sup',`mainsupport')!=0
else loc test `rowsmain'!=rowsof(`sup')
if  `test' {
loc merge merge
tempname save
save `save', replace
clear
qui svmat `sup'
}
else loc merge
}

tempname mte
tempvar mte`estimate'
mat `mte'=e(mte)'
qui svmat `mte'
rename `mte'1 `mte`estimate''

if "`cropfigure'"!="" {
replace `mte`estimate''=. if `mte`estimate''<`crop1'
replace `mte`estimate''=. if `mte`estimate''>`crop2'
}

if "`merge'"=="merge" {
qui merge 1:1 `sup'1 using `save', nogen
}

loc twoway `twoway' (`plottype' `mte`estimate'' `sup'1, `cmissing')
}
loc labels `labels' cols(`numEsts')
}

//Plot 3: Treatment parameter weigths
if "`prte'"!=""|"`late'"!=""|"`atut'"!=""|"`att'"!=""|"`mprte1'"!=""|"`mprte2'"!=""|"`mprte3'"!="" {
local numParams: word count `prte' `late' `atut' `att' `mprte1' `mprte2' `mprte3'
if "`namelist'"!="base" est `use' `folder'`namelist'
tempname sup mte
mat `sup'= e(support)
qui svmat `sup'
loc min=`sup'[1,1]
loc max=`sup'[rowsof(`sup'),1]
mat `mte'=e(mte)'
svmat `mte'
loc twoway (`plottype' `mte' `sup', `cmissing' yaxis(1 3)) (function y=_b[effects:ate], range(`min' `max') yaxis(1 3) lpattern(dash))
loc labels label(1 "MTE at mean")
loc ylabelate ylabel(`=_b[effects:ate]' "ATE",  axis(3) angle(horizontal))
loc no=0
loc order1 1 "MTE"
if "`late'"!="" loc lateplus=1
else loc lateplus=0
foreach param in att atut prte late mprte1 mprte2 mprte3 {
if "``param''"=="" continue
loc no=`no'+1
cap confirm matrix e(mte`param')
if _rc!=0 {
di in red "No `param' estimate found in stored result."
exit 301
}
tempname mte`param' `param'weights
mat `mte`param''=e(mte`param')'
mat ``param'weights'=e(weights`param')
svmat `mte`param''
svmat ``param'weights'
if `no'==1 loc color maroon
if `no'==2 loc color navy
if `no'==3 loc color dkgreen
if `no'==4 loc color dkorange
loc twoway `twoway' (`plottype' `mte`param'' `sup', yaxis(1 3) `cmissing' lcolor(`color') lpattern(solid)) ///
(scatter ``param'weights' `sup', yaxis(2) mcolor(`color') msymbol(smx)) ///
(function y=_b[effects:`param'], yaxis(1 3) range(`min' `max') lcolor(`color') lpattern(dash))
loc ylabel`no' ylabel(`=_b[effects:`param']' "`=strupper("`param'")'", labcolor(`color') axis(3) add custom angle(horizontal))
loc order1 `order1' `=2*`no'+1' "MTE (`=strupper("`param'")')"
loc order2 `order2' `=(`numParams'+1)*2+`no'+`lateplus'' "`=strupper("`param'")' weights"
if "`param'"=="late" {
loc twoway `twoway' (function y=e(iv), yaxis(1 3) range(`min' `max') lcolor(black) lpattern(dot) )
loc order2 `=(`numParams'+1)*2+1' "2SLS" `order2'
}
}
if "`late'"=="" loc holes holes(`=`numParams'+2')
loc order order(`order1' `order2') `holes'
loc labels  cols(`=`no'+1') size(small)
loc yscale yscale(axis(2) alt) yscale(noline axis(3)) ylabel(, axis(3) noticks)
loc ytitle2 ytitle("Weights", axis(2)) 
loc ytitle `ytitle', axis(3)
}

//Plot the specified MTE graph
tempvar temp
gen `temp'=round(`sup'1*100)
qui tsset `temp'	
qui tsfill
qui replace `sup'1=`temp'/100 if `sup'1==.
qui replace `sup'1=round(`sup'1,0.01)
if "`trimsupport'"!="" drop if !inrange(`sup',`trimlow',`trimhigh')

qui sum `sup'1
loc min=`r(min)'
loc max=`r(max)'

twoway	`twoway' ///
, scheme(s2mono) graphregion(color(white)) plotregion(lcolor(black)) ///
`graph_opts' `ytitle2' xtitle("Unobserved resistance to treatment") title("Marginal Treatment Effects") ///
legend(`labels' title("`legendtitle'") `order') `yscale' `ylabelate' `ylabel1' `ylabel2' `ylabel3' `ylabel4' ///
xscale(range(`min' `max')) xlabel(`=round(`min',0.1)'(0.1)`=round(`max',0.1)') name(mtePlot, replace)

save tmp, replace
restore

}
end
}


