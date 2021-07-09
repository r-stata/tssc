*! -tmap_label-: Label maps                                                    
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

program tmap_label
version 8.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax varname [if] [in],        ///
		 Xcoord(varname numeric)   ///
		 Ycoord(varname numeric)   ///
		 Map(string)               ///
      [LColor(string)]           ///
      [LSize(real 1)]            ///
      [LLength(integer 12)]      ///
      [OColor(string)]           ///
      [OSize(string)]            ///
      [FColor(string)]           ///
      [BColor(string)]           ///
      [TITle(string)]            ///
      [SUBtitle(string)]         ///
      [NOTe(string)]             ///
      [CAPtion(string)]




*  ----------------------------------------------------------------------------
*  3. Check syntax                                                             
*  ----------------------------------------------------------------------------

/* Marksample */
marksample TOUSE, strok
markout `TOUSE' `xcoord' `ycoord'
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

/* Keep only relevant cases */
qui keep if `TOUSE'

/* Set default label color */
if `"`lcolor'"' == "" local lcolor "black"
local LC=subinstr(`"`lcolor'"',`"""',"",.)

/* Set default label size */
local LS=0.9*`lsize'

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

/* Set title, subtitle, note and caption options */
if `"`title'"' != "" local TITLE `"title(`title')"'
if `"`subtitle'"' != "" local SUBTITLE `"subtitle(`subtitle')"'
if `"`note'"' != "" local NOTE `"note(`note')"'
if `"`caption'"' != "" local CAPTION `"caption(`caption')"'

/* Keep only relevant variables */
keep `varlist' `xcoord' `ycoord'
cap rename `varlist' _label
cap rename `xcoord' _x
cap rename `ycoord' _y

/* Create label variable */
qui {
	local N = _N 
	local TYPE : type _label
	local TYPE = substr("`TYPE'",1,3)
	if "`TYPE'" != "str" {
		local VALLBL : value label _label
		if "`VALLBL'" == "" {
			tostring _label, replace force usedisplayformat
		}
		else {
			rename _label TEMP
			decode TEMP, gen(_label)
		}
	}
	replace _label = substr(_label,1,`llength')
}	




*  ----------------------------------------------------------------------------
*  5. Draw map                                                                 
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

/* Labels */
local LABELS "mlabel(_label) mlabcol("`LC'") mlabsize(*`LS') msymbol(i) mlabpos(0)"
local GRAPHS "`GRAPHS'(scatter _y _x, `LABELS') "

/* Draw graph */
cap noisily graph twoway `GRAPHS', ysize(`YS') xsize(`XS') aspect(`AR')   ///
    yscale(r(`ymin' `ymax') off) xscale(r(`xmin' `xmax') off)             ///
  	 ylabel(`ymin' `ymax') xlabel(`xmin' `xmax')                           ///
    ytitle("") xtitle("")                                                 ///
    `TITLE' `SUBTITLE' `NOTE' `CAPTION'                                   ///
    plotregion(style(none)) graphregion(color("`BC'"))                    ///
    scheme(s1mono) legend(off)

if _rc {
	di as err "{p}invalid syntax{p_end}"
	exit _rc
}




*  ----------------------------------------------------------------------------
*  6. End program                                                              
*  ----------------------------------------------------------------------------

restore
end

