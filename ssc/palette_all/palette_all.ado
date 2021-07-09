*! Date        : 27 September 2006
*! Version     : 1.01
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*! Description : Graph colours

prog def palette_all
version 8.0

syntax [, Bg(string)] 
#delimit ;
local clist "
black olive dknavy gray teal navy edkblue emidblue 
blue midblue ltblue ebblue  cyan eltblue ebg  
ltbluishgray  bluishgray dimgray eggshell ltkhaki white emerald 
mint lime forest_green eltgreen 
dkgreen olive_teal green 
lavender purple magenta 
 midgreen maroon sienna erose cranberry 
dkorange orange orange_red pink red sand gold brown khaki stone sandb yellow 

"  ;
#delimit cr


if "`bg'"=="" local bg "gs12"

local width 5
local g "twoway "

local i 1
local j 1
foreach col in `clist' {
    if `"`g'"' ==`"twoway "' local g `"`g' ( scatteri `i' `j' "`col'",ms(S) mc(`col') msize(*4) mlabc(`col') )"'
    else local g `"`g' || (scatteri `i' `j' "`col'", ms(S) mc(`col') msize(*4) mlabc(`col')  )"'

    if `j'==`width' {
      local j 1 
      local i=`i'+1
    }
    else local j=`j'+1

}

`g', legend(off) xscale(range(0.5,`++width') off)  yscale(off) ylab(,nogrid) plotr(c(`bg')) graphr(c(`bg'))

end

