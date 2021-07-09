*! -tmap_propsymbol-: Proportional symbol maps                                 
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

program tmap_propsymbol
version 8.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax varname(numeric) [if] [in],   ///
		 Xcoord(varname numeric)       ///
		 Ycoord(varname numeric)       ///
		 Map(string)                   ///
      [SColor(string)]               ///
      [SSHape(string)]               ///
      [SSIze(real 1)]                ///
      [SOutline]                     ///
      [OColor(string)]               ///
      [OSize(string)]                ///
      [FColor(string)]               ///
      [BColor(string)]               ///
      [TITle(string)]                ///
      [SUBtitle(string)]             ///
      [NOTe(string)]                 ///
      [CAPtion(string)]
		



*  ----------------------------------------------------------------------------
*  3. Check syntax                                                             
*  ----------------------------------------------------------------------------

/* Marksample */
marksample TOUSE
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

/* Set default symbol color */
if `"`scolor'"' == "" local scolor "black"

/* Set default symbol shape */
if "`sshape'" == "" local sshape "Oh"

/* Set symbol size */
su `varlist', meanonly
qui replace `varlist' = ((`varlist' -  r(min)) / r(max)) + (r(max) - r(min))/100

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
qui keep `varlist' `xcoord' `ycoord'
cap rename `varlist' _attribute
cap rename `xcoord' _x
cap rename `ycoord' _y




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

/* Symbols */
if "`soutline'" != "" local SO "mlc(black) mlw(thin)"
local GRAPHS "`GRAPHS'(scatter _y _x [fw=_attribute], ms(`sshape') mc(`scolor') `SO' "
local GRAPHS "`GRAPHS'msize(*`ssize')) "

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



