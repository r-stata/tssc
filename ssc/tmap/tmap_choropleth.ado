*! -tmap_choropleth-: Choropleth maps                                          
*! Version 2.0 - 4 January 2004 (beta)                                         
*! Version 1.2 - 23 July 2004                                                  
*! Version 1.1 - 14 July 2004 (reviewed by NJC)                                
*! Version 1.0 - 24 January 2004                                               
*! Author: Maurizio Pisati                                                     
*! Department of Sociology and Social Research                                 
*! University of Milano Bicocca (Italy)                                        
*! maurizio.pisati@unimib.it                                                   




*  ----------------------------------------------------------------------------
*  1. Define program                                                           
*  ----------------------------------------------------------------------------

program tmap_choropleth
version 8.2



	
*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax varname(numeric) [if] [in],                 ///
       Id(varname numeric)                         ///
       Map(string)                                 ///
      [CLMethod(string)]                           ///
      [CLNumber(integer 4)]                        ///
      [CLBreaks(numlist min=3 max=10 ascending)]   ///
      [EIRange(numlist min=2 max=2 ascending)]     ///
      [Palette(string)]                            ///
      [Colors(string)]                             ///
      [OColor(string)]                             ///
      [OSize(string)]                              ///
      [BColor(string)]                             ///
      [TITle(string)]                              ///
      [SUBtitle(string)]                           ///
      [NOTe(string)]                               ///
      [CAPtion(string)]                            ///
      [LEGPos(integer 7)]                          ///
      [LEGCOLor(string)]                           ///
      [LEGSize(real 1)]                            ///
      [LEGFormat(string)]                          ///
      [LEGTitle(string)]                           ///
      [LEGBox(string)]                             ///
      [LEGCount]                                   ///
      [noLEGend]                                   ///
      [ADDplot(string)]


/*
CLMethod(quantile | eqint | stdev | custom | unique)
CLNumber(min=2 max=9)
Palette(Blues | BrBG | Greens | Greys | Paired | PuRd |
        Purples | RdBu | RdGy | Reds | Set1 | Set3 |
        YlOrBr | Custom)
        Defaults: Greys  if CLMethod(quantile | eqint | custom)
                  RdBu   if CLMethod(stdev)
                  Paired if CLMethod(unique)
*/




*  ----------------------------------------------------------------------------
*  3. Check syntax                                                             
*  ----------------------------------------------------------------------------

/* Marksample */
marksample TOUSE
markout `TOUSE' `id'
qui count if `TOUSE' 
if r(N) == 0 error 2000 

/* Check option map() */
capture confirm file `"`map'"'
if _rc {
	di as err "{p}file `map' specified in option {bf:{ul:m}ap()} does not exist{p_end}"
	exit 498
}

/* Check option clmethod() */
if "`clmethod'" != "" {
	local LIST "quantile eqint stdev custom unique"
	local EXIST : list posof `"`clmethod'"' in LIST
	if !`EXIST' {
		di as err "{p}option {bf:{ul:clm}ethod()} accepts only one of the following keywords: {bf:`LIST'}{p_end}"
		exit 198 
	}
}

/* Check option clmethod() */
if "`clmethod'" == "unique" {
	qui tab `varlist' if `TOUSE' 
	if r(r) < 2 {
		di as err "variable `varlist' has too few values"
		exit 498 
	}
	else if r(r) > 9 {
		di as err "variable `varlist' has too many values"
		exit 498 
	}
}

/* Check option clnumber() */
if !inrange(`clnumber', 2, 9) {
	di as err "{p}option {bf:{ul:cln}umber()} accepts only values between 2 and 9{p_end}"
	exit 198 
}

/* Check option clbreaks() */
if "`clmethod'" == "custom" & "`clbreaks'" == "" {
	di as err "{p}if you specify option {bf:{ul:clm}ethod(custom)} you must " _c
	di as err "specify also option {bf:{ul:clb}reaks()}{p_end}"
	exit 198 
}

/* Check option palette() */
if "`palette'"!="" {
	local LIST "Blues BrBG Greens Greys Paired PuRd Purples"
	local LIST "`LIST' RdBu RdGy Reds Set1 Set3 YlOrBr Custom"
	local EXIST : list posof `"`palette'"' in LIST
	if !`EXIST' {
		di as err "{p}option {bf:{ul:p}alette()} accepts only one of the " _c
		di as err "following keywords: {bf:`LIST'}{p_end}"
		exit 198 
	}
}

/* Check option colors() */
if "`palette'" == "Custom" & `"`colors'"' == "" {
	di as err "{p}if you specify option {bf:{ul:p}alette(Custom)} you must " _c
	di as err "specify also option {bf:{ul:c}olors()}{p_end}"
	exit 198 
}

/* Check option colors() */
if "`palette'" == "Custom" & inlist("`clmethod'","quantile","eqint","stdev") {
	local NCOLORS : word count `colors'
	if `clnumber' != `NCOLORS' {
		di as err "you must specify `clnumber' different colors in option {bf:{ul:c}olors()}"
		exit 198 
	}
}

/* Check option colors() */
if "`palette'" == "Custom" & "`clmethod'" == "custom" {
	local NCLASSES : word count `clbreaks'
	local NCLASSES = `NCLASSES' - 1
	local NCOLORS : word count `colors'
	if `NCLASSES' != `NCOLORS' {
		di as err "you must specify `NCLASSES' different colors in option {bf:{ul:c}olors()}"
		exit 198 
	}
}

/* Check option colors() */
if "`palette'" == "Custom" & "`clmethod'" == "unique" {
	qui tab `varlist' if `TOUSE'
	local NCLASSES = r(r)
	local NCOLORS : word count `colors'
	if `NCLASSES' != `NCOLORS' {
		di as err "{p}you must specify `NCLASSES' different colors in option {bf:{ul:c}olors()}{p_end}"
		exit 198 
	}
}

/* Check option legpos() */
if `legpos' < 1 | `legpos' > 12 {
	di as err "{p}option {bf:{ul:legp}os()} accepts only values between 1 and 12{p_end}"
	exit 198 
}

/* Check option legformat() */
if "`legformat'"!="" {
	capture qui format `varlist' `legformat'
	if _rc {
		di as err "{p}`legformat' in option {bf:{ul:legf}ormat()} is not a valid format{p_end}"
		exit 198 
	} 
}




*  ----------------------------------------------------------------------------
*  4. Parse option ADDPlot                                                     
*  ----------------------------------------------------------------------------

if `"`addplot'"'!="" {
	local addplot `"t_`addplot'"'
	preserve
	cap qui `addplot'
	if _rc {
		di as err "{p}option {bf:{ul:add}plot()} specified uncorrectly{p_end}"
		exit 198 
	} 
	local ADDPLOT "`r(gc)'"
	restore
}




*  ----------------------------------------------------------------------------
*  5. Define basic objects                                                     
*  ----------------------------------------------------------------------------

/* Preserve data */
preserve

/* Set default classification method */
if "`clmethod'" == "" local clmethod "quantile"

/* Set default color palettes */
if "`palette'" == "" {
	if "`clmethod'" == "quantile"    local palette "Greys"
	else if "`clmethod'" == "eqint"  local palette "Greys"
	else if "`clmethod'" == "custom" local palette "Greys"
	else if "`clmethod'" == "stdev"  local palette "RdBu"
	else if "`clmethod'" == "unique" local palette "Paired"
}

/* Set default outline color */
if `"`ocolor'"' == "" local ocolor "black"
local ocolor=subinstr(`"`ocolor'"',`"""',"",.)

/* Set default map outline thickness */
if "`osize'" == "" local osize "thin"
local OS "`osize'"

/* Set default graph background color */
if `"`bcolor'"' == "" local bcolor "white"
local BC=subinstr(`"`bcolor'"',`"""',"",.)

/* Set default legend size */
local legsize=`legsize'*0.6

/* Set default legend format */
if "`legformat'" == "" local legformat "%8.2f"

/* Set title, subtitle, note and caption options */
if `"`title'"' != "" local TITLE `"title(`title')"'
if `"`subtitle'"' != "" local SUBTITLE `"subtitle(`subtitle')"'
if `"`note'"' != "" local NOTE `"note(`note')"'
if `"`caption'"' != "" local CAPTION `"caption(`caption')"'

/* Keep only relevant cases */
qui keep if `TOUSE' 

/* Keep only relevant variables */
keep `id' `varlist'
cap rename `id' _ID
cap rename `varlist' _attribute

/* Define attribute range */
if "`clmethod'" != "eqint" {
	su _attribute, meanonly 
	local VMIN = r(min)
	local VMAX = r(max)
}
else if "`clmethod'" == "eqint" { 
	if "`eirange'" == "" {
		su _attribute, meanonly 
		local VMIN = r(min)
		local VMAX = r(max)
	}
	else { 
		local VMIN : word 1 of `eirange'
		local VMAX : word 2 of `eirange'
	}
}	




*  ----------------------------------------------------------------------------
*  6. Create class variable                                                    
*  ----------------------------------------------------------------------------

/* Set number of classes */
local NC = `clnumber'
if "`clmethod'" == "custom" {
	local NC : word count `clbreaks'
	local NC = `NC' - 1
}
else if "`clmethod'" == "unique" {
	qui tab _attribute
	local NC = r(r)
}

/* Quantile method */
if "`clmethod'" == "quantile" {
	qui pctile _cutpoints = _attribute, nq(`NC')
	qui xtile _class = _attribute, cutpoints(_cutpoints)
	local CBREAKS "`VMIN'"
	forval i = 1/`=`NC'-1' {
		local CB = _cutpoints[`i']
		local CBREAKS "`CBREAKS' `CB'"
	}
	local CBREAKS "`CBREAKS' `VMAX'"
}

/* Equal interval method */
if "`clmethod'" == "eqint" {
	local INTERVAL = (`VMAX' - `VMIN') / `NC'
	local CBREAKS "`VMIN'"
	forval i = 1 / `=`NC'-1' {
		local CB = `: word `i' of `CBREAKS'' + `INTERVAL'
		local CBREAKS "`CBREAKS' `CB'"
	}
	local CBREAKS "`CBREAKS' `VMAX'"
	qui gen _class = .
	local LOWER : word 1 of `CBREAKS'
	local UPPER : word 2 of `CBREAKS'
	qui replace _class = 1 if inrange(float(_attribute), float(`LOWER'), float(`UPPER'))
	forval ii = 3 /`= `NC' + 1' {
		local i = `ii' - 1
		local LOWER : word `i' of `CBREAKS'
		local UPPER : word `ii' of `CBREAKS'
		qui replace _class = `i' if float(_attribute)>float(`LOWER') & float(_attribute)<=float(`UPPER')
	}
}

/* Standard deviation method */
if "`clmethod'"=="stdev" {
	qui su _attribute
	local VMEAN = r(mean)
	local VSD   = r(sd)
	if `NC' == 2 local CBLIST "`VMIN' `VMEAN' `VMAX'"
	if `NC' > 2 {
		local LIM  "0.6 1.0 1.2 1.6 2.0 1.8 2.1"
		local WID "1.2 1.0 0.8 0.8 0.8 0.6 0.6"
		local K=`NC'-2
		local L : word `K' of `LIM'
		local W : word `K' of `WID'
		numlist "-`L'(`W')`L'"
		local NLIST "`r(numlist)'"
		local CBLIST "`VMIN'"
		forval i = 1/`=`NC'-1' {
			local CB = `: word `i' of `NLIST''*`VSD'+`VMEAN'
			local CBLIST "`CBLIST' `CB'"
		}
		local CBLIST "`CBLIST' `VMAX'"
	}
	qui gen _class = .
	local LOWER : word 1 of `CBLIST'
	local UPPER : word 2 of `CBLIST'
	qui replace _class = 1 if inrange(float(_attribute), float(`LOWER'), float(`UPPER'))
	forval ii = 3 / `= `NC' + 1' {
		local i = `ii' - 1
		local LOWER : word `i' of `CBLIST'
		local UPPER : word `ii' of `CBLIST'
		qui replace _class = `i' if float(_attribute)>float(`LOWER') & float(_attribute)<=float(`UPPER')
	}
	local CBREAKS ""
	forval i = 1/`=`NC'+1' {
		local CB : word `i' of `CBLIST'
		if `CB' < `VMIN' local CB = `VMIN'
		if `CB' > `VMAX' local CB = `VMAX'
		local CBREAKS "`CBREAKS'`CB' "
	}
}

/* Custom class breaks */
if "`clmethod'" == "custom" {
	local CBREAKS "`clbreaks'"
	qui gen _class = .
	local LOWER : word 1 of `CBREAKS'
	local UPPER : word 2 of `CBREAKS'
	qui replace _class = 1 if inrange(float(_attribute), float(`LOWER'), float(`UPPER'))
	forval ii = 3 / `= `NC' + 1' {
		local i = `ii' - 1
		local LOWER : word `i' of `CBREAKS'
		local UPPER : word `ii' of `CBREAKS'
		qui replace _class = `i' if float(_attribute)>float(`LOWER') & float(_attribute)<=float(`UPPER')
	}
}

/* Unique values */
if "`clmethod'" == "unique" {
	qui egen _class = group(_attribute), label lname(_class)
}

/* Drop cases with missing class */
qui drop if missing(_class)




*  ----------------------------------------------------------------------------
*  7. Set colors                                                               
*  ----------------------------------------------------------------------------

if "`palette'" != "Custom" {
	tempname RGB
	matrix `RGB' = J(`NC',3,0)
	get_palette "`palette'" "`RGB'" `NC'
	forval i=1 / `NC' {
		local R = `RGB'[`i',1]
		local G = `RGB'[`i',2]
		local B = `RGB'[`i',3]
		local COLORS `"`COLORS' "`R' `G' `B'""'
	}
}
else if "`palette'" == "Custom" local COLORS `"`colors'"'




*  ----------------------------------------------------------------------------
*  8. Make up legend                                                           
*  ----------------------------------------------------------------------------

/* Legend off */
if "`legend'" != "" local LEGEND "legend(off)"

/* Legend on */
if "`legend'" == "" {

	forval ii = 2 / `= `NC' + 1' {
		local i = `ii' - 1
		if "`clmethod'" != "unique" {
			local LOWER : word `i' of `CBREAKS'
			local UPPER : word `ii' of `CBREAKS'
			local LOWER = string(`LOWER', "`legformat'")
			local UPPER = string(`UPPER', "`legformat'")
			if `i' == 1 {
				if "`legcount'"!="" {
					qui count if _class==`i'
					local COUNT=r(N)
					local COUNT " (`COUNT')"
					local RANGE `"`RANGE'`"[`LOWER',`UPPER']`COUNT'"' "'
				}
				else {
					local RANGE `"`RANGE'`"[`LOWER',`UPPER']"' "'
				}
			}
			else if `i' > 1 {
				if "`legcount'"!="" {
					qui count if _class==`i'
					local COUNT=r(N)
					local COUNT " (`COUNT')"
					local RANGE `"`RANGE'`"(`LOWER',`UPPER']`COUNT'"' "'
				}
				else {
					local RANGE `"`RANGE'`"(`LOWER',`UPPER']"' "'
				}
			}
		}
		else if "`clmethod'"=="unique" {
			local LBL : label (_class) `i'
			if "`legcount'"!="" {
				qui count if _class==`i'
				local COUNT=r(N)
				local COUNT " (`COUNT')"
			}
			local RANGE `"`RANGE'"`LBL'`COUNT'" "'	
		}
	}

	forval i = 1 / `NC' {
		local R : word `i' of `RANGE'
		local LABEL `"`LABEL'lab(`i' `"`R'"') "'
		local KEYS `"`KEYS'`i' "'
	}

	if `"`legcolor'"'!="" {
		local LEGCOL=subinstr(`"`legcolor'"',`"""',"",.)
		local LEGCOLOR `"color("`LEGCOL'")"'
	}

	local LEGSIZE `"size(*`legsize')"'

	if `"`legtitle'"'!="" local LEGTITLE `"subtitle(`legtitle')"'

	if `"`legbox'"'=="" {
		local LEGREGION `"region(lc("none") fc(none))"'
	}
	else {
		local LEGREGION `"region(`legbox')"'
	}

	local LEGEND `"legend( cols(1) order(`KEYS') `LABEL'"'
	local LEGEND `"`LEGEND' `LEGCOLOR' `LEGSIZE' `LEGTITLE' `LEGREGION'"'
	local LEGEND `"`LEGEND' symy(1.7) symx(3) keygap(1) rowgap(0.5)"'
	local LEGEND `"`LEGEND' ring(0) position(`legpos') )"'

}




*  ----------------------------------------------------------------------------
*  9. Draw map                                                                 
*  ----------------------------------------------------------------------------

/* Merge relevant info */
tempfile IDFILE
keep _ID _class
sort _ID
qui save `IDFILE'
qui use `"`map'"', clear
qui merge _ID using `IDFILE'
qui drop _merge
qui keep if _class != .

/* Calculate plot region */
qui su _Y, meanonly 
local ymin = r(min)
local ymax = r(max)
qui su _X, meanonly 
local xmin = r(min)
local xmax = r(max)
local JY = (`ymax' - `ymin') * 0.03
local JX = (`xmax'-`xmin') * 0.03
local ymin = `ymin' - `JY'
local ymax = `ymax' + `JY'
local xmin = `xmin' - `JX'
local xmax = `xmax' + `JX'
local RATIO = (`ymax' - `ymin') / (`xmax'-`xmin')
local YS = 4
local XS = 4 / `RATIO'
local AR = `YS'/`XS'

/* Base map */
forval i = 1/`NC' {
	local FC : word `i' of `COLORS'
	local OC `"`ocolor'"'
   if `"`ocolor'"' == "none" local OC "`FC'*0.8"
   local GRAPHS "`GRAPHS'(area _Y _X if _class==`i', nodropbase blc("`OC'") blw(`OS') bfc("`FC'")) "
}

/* Additional plot */
if `"`addplot'"'!="" {
	qui merge using "_TEMP_TMAP_.dta"
   local GRAPHS "`GRAPHS'`ADDPLOT'"
}

/* Draw graph */
cap noisily graph twoway `GRAPHS', ysize(`YS') xsize(`XS') aspect(`AR')   ///
    yscale(r(`ymin' `ymax') off) xscale(r(`xmin' `xmax') off)             ///
	 ylabel(`ymin' `ymax') xlabel(`xmin' `xmax')                           ///
    ytitle("") xtitle("")                                                 ///
    `LEGEND' `TITLE' `SUBTITLE' `NOTE' `CAPTION'                          ///
    plotregion(style(none)) graphregion(color("`BC'"))                    ///
    scheme(s1mono)

if _rc {
	di as err "{p}invalid syntax{p_end}"
	exit _rc 
}

if `"`addplot'"'!="" {
	qui erase "_TEMP_TMAP_.dta"
}




*  ----------------------------------------------------------------------------
*  10. End program                                                             
*  ----------------------------------------------------------------------------

restore
end








*  ----------------------------------------------------------------------------
*  A1. Subprogram -get_palette-                                                
*  ----------------------------------------------------------------------------

program get_palette
version 8.2
args PALETTE RGB NC


preserve
qui { 
	cap findfile "ColorSchemes.dta"
	use `"`r(fn)'"', clear
	keep if scheme == "`PALETTE'" & classnum == `NC'
	mkmat rgb*, matrix(`RGB')
} 	
restore


end




*  ----------------------------------------------------------------------------
*  A2. Subprogram -t_propsymbol-                                               
*  ----------------------------------------------------------------------------

/* Define program */
program t_propsymbol, rclass
version 8.2

/* Define syntax */
syntax varname(numeric) [if] [in],   ///
		 Xcoord(varname numeric)       ///
		 Ycoord(varname numeric)       ///
      [SColor(string)]               ///
      [SSHape(string)]               ///
      [SSIze(real 1)]                ///
      [SOutline]

/* Mark sample */
marksample TOUSE
markout `TOUSE' `xcoord' `ycoord'
qui count if `TOUSE' 
if r(N) == 0 error 2000 

/* Keep only relevant cases */
qui keep if `TOUSE' 

/* Define basic objects */
qui clonevar _ADDVAR_=`varlist'
su _ADDVAR_, meanonly
qui replace _ADDVAR_ = ((_ADDVAR_ -  r(min)) / r(max)) + (r(max) - r(min))/100
qui clonevar _XCOORD_=`xcoord'
qui clonevar _YCOORD_=`ycoord'
if `"`scolor'"' == "" local scolor "black"
if "`sshape'" == "" local sshape "Oh"

/* Keep only relevant variables */
qui keep _ADDVAR_ _XCOORD_ _YCOORD_

/* Save temporary file */
qui save "_TEMP_TMAP_.dta", replace

/* Draw symbols */
if "`soutline'" != "" local SO "mlc(black) mlw(thin)"
local GRAPHS "(scatter _YCOORD_ _XCOORD_ [fw=_ADDVAR_], ms(`sshape') mc(`scolor') "
local GRAPHS "`GRAPHS'`SO' msize(*`ssize')) "

/* Return info of interest */
return local gc `"`GRAPHS'"'

/* End program */
end




*  ----------------------------------------------------------------------------
*  A3. Subprogram -t_deviation-                                                
*  ----------------------------------------------------------------------------

/* Define program */
program t_deviation, rclass
version 8.2

/* Define syntax */
syntax varname(numeric) [if] [in],   ///
       Xcoord(varname numeric)       ///
		 Ycoord(varname numeric)       ///
		[Center(string)]               ///
      [SColor(string)]               ///
      [SSHape(string)]               ///
      [SSIze(real 1)]

/* Mark sample */
marksample TOUSE
markout `TOUSE' `xcoord' `ycoord'
qui count if `TOUSE' 
if r(N) == 0 error 2000 

/* Check option center() */
if "`center'" != "" {
	local LIST "mean median"
	local EXIST : list posof `"`center'"' in LIST
	if !`EXIST' {
		exit 198 
	}
}

/* Check option sshape() */
if "`sshape'"!="" {
	local LIST "O D T S o d t s"
	local EXIST : list posof `"`sshape'"' in LIST
	if !`EXIST' {
		exit 198 
	}
}

/* Keep only relevant cases */
qui keep if `TOUSE' 
	
/* Set default reference value */
if "`center'" == "" local center "mean"
else if "`center'" == "median" local center "p50"

/* Set default symbol color and shape */
if `"`scolor'"' == "" local scolor "black"
if "`sshape'" == "" local sshape "O"

/* Create relevant variables */
qui { 
	su `varlist', detail
	replace `varlist' = `varlist' - r(`center')
	gen _SIGN_ = 1 + (`varlist' >= 0)
	replace `varlist' = abs(`varlist')
	su `varlist', meanonly
	replace `varlist' = ((`varlist' - r(min)) / r(max)) + (r(max) - r(min)) / 100
	clonevar _ADDVAR_=`varlist'
	clonevar _XCOORD_=`xcoord'
	clonevar _YCOORD_=`ycoord'
}

/* Keep only relevant variables */
qui keep _SIGN_ _ADDVAR_ _XCOORD_ _YCOORD_

/* Save temporary file */
qui save "_TEMP_TMAP_.dta", replace

/* Draw symbols */
local GRAPHS "`GRAPHS'(scatter _YCOORD_ _XCOORD_ [fw=_ADDVAR_] if _SIGN_==2, "
local GRAPHS "`GRAPHS'ms(`sshape') mc(`scolor') msize(*`ssize')) "
local GRAPHS "`GRAPHS'(scatter _YCOORD_ _XCOORD_ [fw=_ADDVAR_] if _SIGN_==1, "
local GRAPHS "`GRAPHS'ms(`sshape'h) mc(`scolor') msize(*`ssize')) "

/* Return info of interest */
return local gc `"`GRAPHS'"'

/* End program */
end




*  ----------------------------------------------------------------------------
*  A4. Subprogram -t_dot-                                                      
*  ----------------------------------------------------------------------------

/* Define program */
program t_dot, rclass
version 8.2

/* Define syntax */
syntax [if] [in], Xcoord(varname numeric)     ///
			         Ycoord(varname numeric)     ///
			        [BY(varname)]                ///
			        [MARker(string)]             /// REVISED v2.0
                 [SColor(string)]             ///
                 [SSHape(string)]             ///
                 [SSIze(real 1)]              ///
                 [SOutline]

/* Mark sample */
marksample TOUSE
markout `TOUSE' `xcoord' `ycoord'
if "`by'"!="" { 
	markout `TOUSE' `by', strok 
} 	
qui count if `TOUSE' 
if r(N) == 0 error 2000 

/* Keep only relevant cases */
qui keep if `TOUSE' 
	
/* Set default marker */
if "`marker'" == "" local marker "color"

/* Set default symbol color list and single shape when -marker(color)- */
if "`marker'" == "color" {
	if `"`scolor'"' == "" local SCLIST "black red blue green orange ltblue lime sienna yellow"
	else local SCLIST `"`scolor'"'
	if "`sshape'" == "" local SHP "o"
	else local SHP : word 1 of `sshape'
}

/* Set default symbol shape list and single color when -marker(shape)- */
if "`marker'" == "shape" {
 	if "`sshape'" == "" local SSLIST "o oh s sh t th d dh x"
	else local SSLIST "`sshape'"
	if `"`scolor'"' == "" local COL "black"
	else local COL : word 1 of `scolor'
}

/* Set default symbol color list and symbol shape list when -marker(both)- */
if "`marker'" == "both" {
	if `"`scolor'"' == "" local SCLIST "black red blue green orange ltblue lime sienna yellow"
	else local SCLIST `"`scolor'"'
 	if "`sshape'" == "" local SSLIST "o oh s sh t th d dh x"
	else local SSLIST "`sshape'"
}

/* Create relevant variables */
if "`by'" == ""  { 
	gen _ADDVAR_ = 1
	local NC=1
}
else {
	egen _ADDVAR_ = group(`by'), label lname(_ADDVAR_)
	qui tab _ADDVAR_
	local NC=r(r)
}
qui drop if missing(_ADDVAR_)
qui clonevar _XCOORD_=`xcoord'
qui clonevar _YCOORD_=`ycoord'

/* Keep only relevant variables */
qui keep _ADDVAR_ _XCOORD_ _YCOORD_

/* Save temporary file */
qui save "_TEMP_TMAP_.dta", replace

/* Draw dots */
forval i = 1/`NC' {
	if "`marker'" == "color" {
		local COL : word `i' of `SCLIST'
	}
	if "`marker'" == "shape" {
		local SHP : word `i' of `SSLIST'
	}
	if "`marker'" == "both" {
		local COL : word `i' of `SCLIST'
		local SHP : word `i' of `SSLIST'
	}
	if "`soutline'"!="" local SO "mlc(black) mlw(thin)"
	local GRAPHS "`GRAPHS'(scatter _YCOORD_ _XCOORD_ if _ADDVAR_ == `i', "
	local GRAPHS "`GRAPHS'ms(`SHP') mc("`COL'") msize(*`ssize') mlw(thin) `SO') "
}

/* Return info of interest */
return local gc `"`GRAPHS'"'

/* End program */
end




*  ----------------------------------------------------------------------------
*  A5. Subprogram -t_label-                                                    
*  ----------------------------------------------------------------------------

/* Define program */
program t_label, rclass
version 8.2

/* Define syntax */
syntax varname [if] [in],        ///
		 Xcoord(varname numeric)   ///
		 Ycoord(varname numeric)   ///
      [LColor(string)]           ///
      [LSize(real 1)]            ///
      [LLength(integer 12)]

/* Mark sample */
marksample TOUSE, strok
markout `TOUSE' `xcoord' `ycoord'
qui count if `TOUSE'
if r(N) == 0 error 2000 

/* Keep only relevant cases */
qui keep if `TOUSE' 
	
/* Set default label color and size*/
if `"`lcolor'"' == "" local lcolor "black"
local LC=subinstr(`"`lcolor'"',`"""',"",.)
local LS=0.9*`lsize'

/* Create relevant variables */
qui {
	clonevar _ADDVAR_=`varlist'
	local N = _N 
	local TYPE : type _ADDVAR_
	local TYPE = substr("`TYPE'",1,3)
	if "`TYPE'" != "str" {
		local VALLBL : value label _ADDVAR_
		if "`VALLBL'" == "" {
			tostring _ADDVAR_, replace force usedisplayformat
		}
		else {
			rename _ADDVAR_ TEMP
			decode TEMP, gen(_ADDVAR_)
		}
	}
	replace _ADDVAR_ = substr(_ADDVAR_,1,`llength')
	clonevar _XCOORD_=`xcoord'
	clonevar _YCOORD_=`ycoord'
}

/* Keep only relevant variables */
qui keep _ADDVAR_ _XCOORD_ _YCOORD_

/* Save temporary file */
qui save "_TEMP_TMAP_.dta", replace

/* Draw labels */
local LABELS "mlabel(_ADDVAR_) mlabcol("`LC'") mlabsize(*`LS') msymbol(i) mlabpos(0)"
local GRAPHS "`GRAPHS'(scatter _YCOORD_ _XCOORD_, `LABELS') "

/* Return info of interest */
return local gc `"`GRAPHS'"'

/* End program */
end



