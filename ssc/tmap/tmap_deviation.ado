*! -tmap_deviation-: Deviation maps                                            
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

program tmap_deviation
version 8.2




*  ----------------------------------------------------------------------------
*  2. Define syntax                                                            
*  ----------------------------------------------------------------------------

syntax varname(numeric) [if] [in],   ///
       Xcoord(varname numeric)       ///
		 Ycoord(varname numeric)       ///
		 Map(string)                   ///
		[Center(string)]               ///
      [SColor(string)]               ///
      [SSHape(string)]               ///
      [SSIze(real 1)]                ///
      [OColor(string)]               ///
      [OSize(string)]                ///
      [FColor(string)]               ///
      [BColor(string)]               ///
      [TITle(string)]                ///
      [SUBtitle(string)]             ///
      [NOTe(string)]                 ///
      [CAPtion(string)]


/*
Center(mean | median)
*/




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
	
/* Check option center() */
if "`center'" != "" {
	local LIST "mean median"
	local EXIST : list posof `"`center'"' in LIST
	if !`EXIST' {
		di as err "{p}option {bf:{ul:c}enter()} accepts only one of the following keywords: {bf:mean median}{p_end}"
		exit 198 
	}
}

/* Check option sshape() */
if "`sshape'"!="" {
	local LIST "O D T S o d t s"
	local EXIST : list posof `"`sshape'"' in LIST
	if !`EXIST' {
		di as err "{p}option {bf:{ul:ssh}ape()} accepts only solid symbol styles written in short form{p_end}"
		exit 198 
	}
}




*  ----------------------------------------------------------------------------
*  4. Define basic objects                                                     
*  ----------------------------------------------------------------------------

/* Preserve data */
preserve
	
/* Keep only relevant cases */
qui keep if `TOUSE'
	
/* Set default reference value */
if "`center'" == "" local center "mean"
else if "`center'" == "median" local center "p50"

/* Set default symbol color */
if `"`scolor'"' == "" local scolor "black"

/* Set default symbol shape */
if "`sshape'" == "" local sshape "O"

/* Set symbol size */
tempvar SIGN
qui { 
	su `varlist', detail
	replace `varlist' = `varlist' - r(`center')
	gen `SIGN' = 1 + (`varlist' >= 0) 
	replace `varlist' = abs(`varlist')
	su `varlist', meanonly
	replace `varlist' = ((`varlist' - r(min)) / r(max)) + (r(max) - r(min)) / 100
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

/* Set title, subtitle, note and caption options */
if `"`title'"' != "" local TITLE `"title(`title')"'
if `"`subtitle'"' != "" local SUBTITLE `"subtitle(`subtitle')"'
if `"`note'"' != "" local NOTE `"note(`note')"'
if `"`caption'"' != "" local CAPTION `"caption(`caption')"'

/* Keep only relevant variables */
keep `varlist' `xcoord' `ycoord' `SIGN'
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
local GRAPHS "`GRAPHS'(scatter _y _x [fw=_attribute] if `SIGN'==2, "
local GRAPHS "`GRAPHS'ms(`sshape') mc(`scolor') msize(*`ssize')) "
local GRAPHS "`GRAPHS'(scatter _y _x [fw=_attribute] if `SIGN'==1, "
local GRAPHS "`GRAPHS'ms(`sshape'h) mc(`scolor') msize(*`ssize')) "

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



