*! -tmap_dot-: Dot maps                                                        
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

program tmap_dot
version 8.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax [if] [in], Xcoord(varname numeric)     ///
			         Ycoord(varname numeric)     ///
			         Map(string)                 ///
			        [BY(varname)]                ///
			        [MARker(string)]             ///
                 [SColor(string)]             ///
                 [SSHape(string)]             ///
                 [SSIze(real 1)]              ///
                 [SOutline]                   ///
                 [OColor(string)]             ///
                 [OSize(string)]              ///
                 [FColor(string)]             ///
                 [BColor(string)]             ///
                 [TITle(string)]              ///
                 [SUBtitle(string)]           ///
                 [NOTe(string)]               ///
                 [CAPtion(string)]            ///
                 [LEGPos(integer 7)]          ///
                 [LEGCOLor(string)]           ///
                 [LEGSize(real 1)]            ///
                 [LEGTitle(string)]           ///
                 [LEGBox(string)]             ///
                 [LEGCount]                   ///
                 [noLEGend]


/*
MARker(color | shape | both)
*/




*  ----------------------------------------------------------------------------
*  3. Check syntax                                                             
*  ----------------------------------------------------------------------------

/* Marksample */
marksample TOUSE
markout `TOUSE' `xcoord' `ycoord'
if "`by'"!="" { 
	markout `TOUSE' `by', strok 
} 	
qui count if `TOUSE' 
if r(N) == 0 error 2000 

/* Check option map() */
capture confirm file `"`map'"'
if _rc {
	di as err "{p}file `map' specified in option {bf:{ul:m}ap()} does not exist{p_end}"
	exit 498 
}




*  ----------------------------------------------------------------------------
*  4. Define basic objects                                                     
*  ----------------------------------------------------------------------------

/* Preserve data */
preserve

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

/* Set default map fill color */
if `"`fcolor'"' == "" local fcolor "white"
local FC=subinstr(`"`fcolor'"',`"""',"",.)

/* Set default map outline color */
if `"`ocolor'"' == "" local ocolor "black"
local OC=subinstr(`"`ocolor'"',`"""',"",.)
if `"`OC'"' == "none" local OC `"`FC'*0.8"'

/* Set default map outline thickness */
if "`osize'" == "" local osize "thin"
local OS "`osize'"

/* Set default graph background color */
if `"`bcolor'"' == "" local bcolor "white"
local BC=subinstr(`"`bcolor'"',`"""',"",.)

/* Set default legend size */
local legsize=`legsize'*0.6

/* Set title, subtitle, note and caption options */
if `"`title'"' != "" local TITLE `"title(`title')"'
if `"`subtitle'"' != "" local SUBTITLE `"subtitle(`subtitle')"'
if `"`note'"' != "" local NOTE `"note(`note')"'
if `"`caption'"' != "" local CAPTION `"caption(`caption')"'

/* Keep only relevant cases */
qui keep if `TOUSE'

/* Keep only relevant variables */
qui keep `xcoord' `ycoord' `by'
cap rename `xcoord' _x
cap rename `ycoord' _y
if "`by'" == ""  { 
	gen _class = 1
	local NC=1
}
else { 
	egen _class = group(`by'), label lname(_class)
	qui tab _class
	local NC=r(r)
	qui drop `by'
}
qui drop if missing(_class)




*  ----------------------------------------------------------------------------
*  5. Make up legend                                                           
*  ----------------------------------------------------------------------------

/* Legend off */
if `NC' == 1 | "`legend'" != "" local LEGEND "legend(off)"


/* Legend on */
if `NC' > 1 & "`legend'" == "" {

	forval i = 1/`NC' {
		local X = `i' + 1
		local KEYS "`KEYS'`X' "
	}
		
	forval i = 1/`NC' {
		local LBL : label (_class) `i'
		if "`legcount'"!="" {
			qui count if _class==`i'
			local COUNT=r(N)
			local COUNT " (`COUNT')"
		}
		local RANGE `"`RANGE'"`LBL'`COUNT'" "'	
	}

	forval i = 1/`NC' {
		local K = `i' + 1
		local R : word `i' of `RANGE'
		local LABEL `"`LABEL'lab(`K' "`R'") "'
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
*  6. Draw map                                                                 
*  ----------------------------------------------------------------------------

/* Calculate plot region */
qui merge using `"`map'"'
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
local GRAPHS " (area _Y _X, nodropbase blc("`OC'") blw(`OS') bfc("`FC'")) "

/* Dots */
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
	if "`soutline'"!="" local SO "mlc(black) mlw(thin)"  /* NEW v2.0 */
	local GRAPHS "`GRAPHS'(scatter _y _x if _class == `i', "
	local GRAPHS "`GRAPHS'ms(`SHP') mc("`COL'") msize(*`ssize') mlw(thin) `SO') "
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




*  ----------------------------------------------------------------------------
*  7. End program                                                              
*  ----------------------------------------------------------------------------

restore
end



