*! 1.4.5 TJS 24 May 2001 
* based on hplot 1.4.4 NJC 23 May 2001 
program define mhplot
    version 6.0

    #delimit ;
    syntax varlist(numeric) [if] [in]
    [, BOrder SOrt(string) noXaxis noYaxis PEn(string) Symbol(string)
    T1title(string) T2title(string asis) TItle(str asis) TTIck VALLBL(varname) 
    XLAbel(numlist) XLIne(numlist) XSCale(str) XTIck(numlist) Axtol(int 600) 
    Blank flipt Format(string) FONTC(int 290) FONTR(int 570) FONTCB(int 444)
    FONTRB(int 923) GAPMag(real 1) GAPs(numlist int) GLegend(string)
    GLLJ GLPOS(int -1) t2m(int 0) Grid LAP Legend(string) LIne NIT2
    t1m(int 0) PTSize(int 275) Range RLegend(varname) rllj RLPos(int 31500) 
    TIM(int 0) Vat VATFmt(string) VATPos(int 31500) Cstart(int -1) 
    SAving(string) PENText(int 1) ] ;
    #delimit cr

    qui {
        tempvar touse order gleg gap dmin dmax dneg dpos z
        mark `touse' `if' `in'
        Markout2 `touse' `varlist'
        gen `order' = _n
        gsort - `touse' `sort' `order'
        count if `touse'
        local nuse = r(N)

        * legend on left
        if "`legend'" == "" {
            tempvar legend
            gen str1 `legend' = " "
            if "`blank'" == "" { replace `legend' = string(_n) if `touse' }
        }
        else {
            confirm variable `legend'
            capture confirm string variable `legend'
            if _rc == 7 {
                tempvar legend2
                capture decode `legend', gen(`legend2')
                if _rc {
                    gen str1 `legend2' = ""
                    replace `legend2' = string(`legend')
                }
                else { replace `legend2' = string(`legend') if missing(`legend2') }
                local legend "`legend2'"
            }
        }
        local leglen : type `legend'
        local leglen = substr("`leglen'", 4, .)
        if `cstart' == -1 {
            local cstart = 2000 + int(9000 * `leglen' / 25)
        }

   * legend on right                                 
        if "`rlegend'" != "" {                            
            capture confirm string variable `rlegend'     
            if _rc == 7 {                                 
                tempvar rleg2                             
                capture decode `rlegend', gen(`rleg2')      
                if _rc == 0 {                             
                    replace `rleg2' = string(`rlegend') if missing(`rleg2')                
                    local rlegend "`rleg2'"                 
                }                                         
       }                                              
   }                                       

        * axis scale
        if "`xscale'" != "" {
            tokenize "`xscale'", parse(",")
            if "`4'" != "" | "`2'" != "," {
                di in r "invalid xscale( ) option"
                exit 198
            }
            local xscmin `1'
            local xscmax `3'
        }

        if "`xscmin'" == "" { local min 0 }
        else local min `xscmin'
        if "`xscmax'" == "" { local max 0 }
        else local max `xscmax'

        * xlabel xtick xline might extend graph range beyond data range
        if "`xlabel'`xtick'`xline'" != "" {
            numlist "`xlabel' `xtick' `xline'", sort
            local nn : word count `r(numlist)'
            local xmin : word 1 of `r(numlist)'
            local xmax : word `nn' of `r(numlist)'
            local min = min(`min', `xmin')
            local max = max(`max', `xmax')
        }

        * gap legend?
        gen str1 `gleg' = " "
        local glj = cond("`gllj'" != "", -1, 1)
        if "`glegend'" != "" {
            tokenize "`glegend'", parse("!")
            local j 1
            while "`1'" != "" {
                if "`1'" != "!" {
                    if "`1'" == "." { local 1 " " }
                    local gleg`j' "`1'"
                    local j = `j' + 1
                }
                mac shift
            }
        }

        * gaps between lines?
        gen byte `gap' = 0
        if "`gaps'" != "" {
            local j 1
            numlist "`gaps'", int range(>=0)
            tokenize `r(numlist)'
            while "`1'" != "" {
                if "`1'" == "0" {
                    local gleg0 "`gleg`j''"
                    if "`gleg0'" == "" { local gleg0 " " }
                }
                else {
                    replace `gap' = 1 in `1' if `1' <= `nuse'
                    replace `gleg' = "`gleg`j''" in `1' if `1' <= `nuse'
                }
                local j = `j' + 1
                mac shift
            }
        }
        count if `gap'
        local ngaps = r(N) + ("`gleg0'" != "")

        * data range
        tokenize `varlist'
        local nvars : word count `varlist'
        gen `dmin' = `1'
        gen `dmax' = `1'
        if `nvars' >= 2 {
            local i 2
            while `i' <= `nvars' {
                replace `dmin' = min(`dmin', ``i'')
                replace `dmax' = max(`dmax', ``i'')
                local i = `i' + 1
            }
        }
        su `dmin' if `touse', meanonly
        local min = min(`min', r(min))
        su `dmax' if `touse', meanonly
        local max = max(`max', r(max))
        local drange = `max' - `min'
        local zero = cond(`min' >= 0, max(0, `min'), min(0, `max'))
        gen `z' = `zero'
        gen `dneg' = min(`dmin', `z')
        gen `dpos' = max(`dmax', `z')
    }

    * start of parameter block

    local t1start 1000       /* row for t1title */
    local t2start 1900       /* row for t2title */
    local ybeg 2400          /* start of y-axis */
    local ylength 17600

    * `axtol' is space at ends of y-axis
    * axtol too large => ystep negative FW
    if `axtol' > `ylength' / 2 {
         di in bl "axtol too large: reset to default 600"
         local axtol 600
    }

    * row where first line starts
    local ystart = `ybeg' + `axtol'

    * step between lines: one gap defaults to one line
    local ystep = (`ylength' - 2 * `axtol') / (`nuse' - 1 + `ngaps' *`gapmag')

    local yend = `ybeg' + `ylength'
    local ynudge = 200 * (`fontr' / 570)^2
                             /* text displaced downwards from lines */
    local ytick 400          /* tick length */
    local yleg 1000          /* labels down from axis */
    local yleg = `yend' + `yleg'
    local ytitle 1400        /* title down from labels */
    local ytitlef 900        /* title down from labels, flip titles */
    local xstart `cstart'    /* col where first line begins */
    local xgap 400           /* gap between left legend and body of plot */
    local xbeg = `xstart' - `xgap'
    if `glpos' == -1 { local glpos `xbeg' }
    local xlength = 30000 - `xstart'
                           /* horizontal extent of data region */
    local xend = `xbeg' + `xgap' + `xlength'
    local xz = `xbeg' + `xgap' + `xlength' * (`zero' - `min') / `drange'
    local mcent = (`cstart' + 30000) / 2 + `tim'
                           /* col where main title centred */
    local dotsp 150          /* spacing between dots */

    if "`format'" == "" { local format "%1.0f" }
    if "`vatfmt'" == "" { local vatfmt "%1.0f" }
    local ahl = 500 * `ptsize' / 275  /* arrowhead length */
    local aha = _pi / 6 /* arrowhead angle, between head and stem */
    local barht `ahl' /* bar height */

    if "`symbol'" == "" {
        if `nvars' < 6 { local symbol "46253" }
        else local symbol : di _dup(`nvars') "4"
    }
    else if length("`symbol'") == 1 & `nvars' > 1 {
        local symbol : di _dup(`nvars') "`symbol'"
    }
    Gphtrans `symbol'
    local symbol "`r(symbol)'"

    if "`pen'" == "" { local pen : di _dup(`nvars') "2" }
    else if length("`pen'") == 1 & `nvars' > 1 {
        local pen : di _dup(`nvars') "`pen'"
    }

    * end of parameter block

    * start gph
    if "`saving'" != "" { local saving ", saving(`saving')" }
    gph open `saving' /* FW */
    gph pen `pentext'
    gph font `fontr' `fontc'

    * y-axis
    if "`yaxis'" == "" { gph line `ybeg' `xstart' `yend' `xstart' }

    * ttick => top ticks
    local ttick = "`ttick'" == "ttick"
    * ttick should => border FW
    if `ttick' { local border "border" }

    * x-axis and labels
    if "`xaxis'" == "" {
        gph line `yend' `xstart' `yend' `xend'
        local ytick2 = `ybeg' - `ytick' / 2
        local ytick = `yend' + `ytick'
        if "`xlabel'" == "" {
            gph line `yend' `xstart' `ytick' `xstart'
            gph line `yend' `xend' `ytick' `xend'
            if `ttick' {
                gph line `ybeg' `xstart' `ytick2' `xstart'
                gph line `ybeg' `xend' `ytick2' `xend'   /* FW */
            }
            local text = cond("`lap'" == "lap", abs(`min'), `min')
            local text : di `format' `text'
            gph text `yleg' `xstart' 0 0 `text'
            local text = cond("`lap'" == "lap", abs(`max'), `max')
            local text : di `format' `text'
            gph text `yleg' `xend' 0 0 `text'
        }
        else {
            numlist "`xlabel'"
            tokenize `r(numlist)'
            if "`vallbl'" != "" { local vallbl : value label `vallbl' }                                      
            while "`1'" != "" {
                local xtickp = `xbeg' + `xgap' + `xlength' * (`1' - `min') / `drange'
                gph line `yend' `xtickp' `ytick' `xtickp'
                if `ttick' { gph line `ybeg' `xtickp' `ytick2' `xtickp' }
                local text = cond("`lap'" == "lap", abs(`1'), `1')
                if "`vallbl'" != "" {                          
                    local label : label `vallbl' `text'        
                    if "`label'" != "" { local text "`label'" }
                }                                              
                else local text : di `format' `text'             
                gph text `yleg' `xtickp' 0 0 `text'
                mac shift
            }
        }
    }

    * x-ticks
    if "`xtick'" != "" {
        numlist "`xtick'"
        tokenize `r(numlist)'
        while "`1'" != "" {
            local xtickp = `xbeg' + `xgap' + `xlength' * (`1' - `min') / `drange'
            gph line `yend' `xtickp' `ytick' `xtickp'
            if `ttick' { gph line `ybeg' `xtickp' `ytick2' `xtickp' }
            mac shift
        }
    }

    * x-lines
    if "`xline'" != "" {
        numlist "`xline'"
        tokenize `r(numlist)'
        while "`1'" != "" {
            local xli = `xbeg' + `xgap' + `xlength' * (`1' - `min') / `drange'
            gph line `yend' `xli' `ybeg' `xli'
            mac shift
        }
    }

    * border
    if "`border'" != "" {
        gph line `ybeg' `xstart' `ybeg' `xend'
        gph line `ybeg' `xend' `yend' `xend'
        if "`xaxis'" != "" { gph line `yend' `xstart' `yend' `xend' }
    }

    * gap legend above first data point
    if "`gleg0'" != "" {
        local y2 = `ystart' + (`gapmag' - 1) * `ystep' + `ynudge'
        gph text `y2' `glpos' 0 `glj' `gleg0'
    }

    * for each variable
    tokenize `varlist'
    local j 1
    while "`1'" != "" {

        local data "`1'"
        local sy = substr("`symbol'", `j', 1)
        local pe = substr("`pen'", `j', 1)
        local y `ystart'
        if "`gleg0'" != "" { local y = `y' + `ystep' * `gapmag' }

        * for each observation
        local i 1
        while `i' <= `nuse'  {

/* tjs code */  
            * dots and/or lines
            if `j' == 1 {

                local xmax = `xbeg' + `xgap' + /*
                   */ `xlength' * (`dmax'[`i'] - `min') / `drange'
                local xmin = `xbeg' + `xgap' + /*
                   */ `xlength' * (`dmin'[`i'] - `min') / `drange'

                if "`line'" == "line" { gph line  `y' `xmin'  `y' `xmax' }

                if "`line'`grid'" == "" {
                    if "`range'" == "range" {
                        local ndots = int(abs(`xmax' - `xmin') / `dotsp')
                        tempvar ys xs
                        if `ndots' > _N { qui set obs `ndots' }
                        qui gen `ys' = `y'
                        qui gen `xs' = _n
                        qui replace `xs' = `xmin' + (`xs' - 1) * `dotsp'
                        qui replace `xs' = . if  `xs' < `xmin' | `xs' > `xmax'
                        gph vpoint `ys' `xs', size(`ptsize') symbol(0)
                    }
                    else { 
                        local ndots = int(abs(`xmax' - `xz') / `dotsp')
                        tempvar ys xs
                        if `ndots' > _N { qui set obs `ndots' }
                        qui gen `ys' = `y'
                        qui gen `xs' = _n
                        qui replace `xs' = `xz' + (`xs' - 1) * `dotsp' * sign(`dpos'[`i'])
                        qui replace `xs' = . if `xs' < `xmin' | `xs' > `xmax'
                        gph vpoint `ys' `xs', size(`ptsize') symbol(0)

                        local ndots = int(abs(`xmin' - `xz') / `dotsp')
                        tempvar ys xs
                        if `ndots' > _N { qui set obs `ndots' }
                        qui gen `ys' = `y'
                        qui gen `xs' = _n
                        qui replace `xs' = `xz' + (`xs' - 1) * `dotsp' * sign(`dneg'[`i'])
                        qui replace `xs' = . if `xs' < `xmin' | `xs' > `xmax'
                        gph vpoint `ys' `xs', size(`ptsize') symbol(0)
                    }  
                }

                if "`grid'" != "" {
                    tempvar ys xs
                    local ndots = int(abs(`xstart' - `xend') / `dotsp')
                    if `ndots' > _N { qui set obs `ndots' }
                    qui gen `ys' = `y'
                    qui gen `xs' = _n
                    qui replace `xs' = `xstart' + (`xs' - 1) * `dotsp'
                    qui replace `xs' = . if `xs' > `xend'
                    gph vpoint `ys' `xs', size(`ptsize') symbol(0)
                }
            }
/* tjs code end */

            * data point
            gph pen `pe'
            local x = `xbeg' + `xgap' + `xlength' * (`data'[`i'] - `min') / `drange'
            if `data'[`i'] < . & "`sy'" != "i" {
                if "`sy'" == "a" {
                    if `j' == 1 { local sign 1 }
                    else local sign = sign(`data'[`i'] - `prev'[`i'])
                    Gphhah `y' `x' `sign' `ahl' `aha'
                }
                else if "`sy'" == ">" { Gphhah `y' `x'  1 `ahl' `aha' }
                else if "`sy'" == "<" { Gphhah `y' `x' -1 `ahl' `aha' }
                else Gphpt `sy' `y' `x' `barht' `ptsize'
            }

            * text
            gph pen `pentext'
            local y2 = `y' + `ynudge'
            if "`vat'" != "" & `nvars' == 1 {
                local text : di `vatfmt' `data'[`i']
                gph text `y2' `vatpos'  0 1 `text'
            }
            if `j' == 1 {
                local text = `legend'[`i']
                gph text `y2' `xbeg'  0 1 `text'
            }
            if `j' == 1 & "`rlegend'" != "" {            
                local text = `rlegend'[`i']              
                local rlj = cond("`rllj'" != "", -1, 1)  
                gph text `y2' `rlpos' 0 `rlj' `text'     
            }                                          

            * gap
            if `gap'[`i'] {
                local y = `y' + `ystep' * `gapmag'
                if `j' == 1 {
                    local text = `gleg'[`i']
                    local y2 = `y' + `ynudge'
                    gph text `y2' `glpos'  0 `glj' `text'
                }
            }

            local y = `y' + `ystep'
            local i = `i' + 1
        }
        * next observation

        local prev `1'
        local j = `j' + 1
        mac shift
    }
    * next variable

    * t2title, left justified (defaults to key for 2 or more variables)
    if "`t2title'" != "" & trim("`t2title'") == "" { local t2title }
    else if "`t2title'" != "" { gph text `t2start' `xstart' 0 -1 `t2title' }
    else if `nvars' >= 2 {
        local t2 = `t2start' - `ynudge'
        local xjump =  `xlength' / `nvars'
        local xjump2 = `xjump' / 50
        local x = `xstart' + `xjump2' + `t2m'
        local j 1
        while `j' <= `nvars' {
            local sy = substr("`symbol'", `j', 1)
            local pe = substr("`pen'", `j', 1)
            gph pen `pe'
            if "`sy'" == "a" {
                local ahv = index("`symbol'", "a")
                if `ahv' > 1 {
                    local this : word `ahv' of `varlist'
                    local ahvm1 = `ahv' - 1
                    local prev : word `ahvm1' of `varlist'
                    count if `this' >= `prev' & `touse'
                    local majsign = cond(r(N) > `nuse' / 2, 1, -1)
                }
                else local majsign 1
                local x3 = `x' + 0.6 * `ptsize' * `majsign'
                Gphhah `t2' `x3' `majsign' `ahl' `aha'
            }
            else if "`sy'" == ">" {
                local x3 = `x' + 0.6 * `ptsize'
                Gphhah `t2' `x3' 1 `ahl' `aha'
            }
            else if "`sy'" == "<" {
                local x3 = `x' - 0.6 * `ptsize'
                Gphhah `t2' `x3' -1 `ahl' `aha'
            }
            else if "`sy'" != "i" {
                Gphpt `sy' `t2' `x' `barht' `ptsize'
            }
            local x2 = `x' + `xjump2'
            local var : word `j' of `varlist'
            if "`nit2'" == "" {
                local text : variable label `var'
                if "`text'" == "" { local text "`var'" }
            }
            else local text "`var'"
            gph pen `pentext'
            gph text `t2start' `x2' 0 -1 `text'
            local x = `x' + `xjump'
            local j = `j' + 1
        }
    }

    * title and t1title
    if `"`title'"' == `""' & `nvars' == 1 {
        local title : variable label `data'
        if "`title'" == "" { local title "`data'" }
    }
    else if `"`title'"' != `""' { local title `title' }

    local xL = `xstart' + `t1m'
    if "`flipt'" == "" { /* default */
        * t1title, left justified
        gph text `t1start' `xL' 0 -1 `t1title'

        * main title at bottom, centred
        gph font `fontrb' `fontcb'
        local ytitle = `yleg' + `ytitle'
        gph text `ytitle' `mcent' 0 0 `title'
    }
    else { /* flip titles from default */
        * bottom title, centred (and closer to axis than default)
        local ytitle = `yleg' + `ytitlef'
        gph text `ytitle' `mcent' 0 0 `t1title'

        * main title at top, left justified
        gph font `fontrb' `fontcb'
        gph text `t1start' `xL' 0 -1 `title'
    }

    gph close
end

program define Gphhah /* horizontal arrow head */
* `1' y position of tip
* `2' x position of tip
* `3' sign determines direction: 1 = >, -1 = <
* `4' arrowhead length
* `5' arrowhead interior angle (between shaft and head)
* 1.0.1 NJC 18 February 1999
* 1.0.0 NJC 27 May 1997
    version 6.0
    local ah1y = `1' - `3' * `4' * sin(`5')
    local ah1x = `2' - `3' * `4' * cos(`5')
    local ah2y = `1' + `3' * `4' * sin(`5')
    local ah2x = `2' - `3' * `4' * cos(`5')
    gph line `ah1y' `ah1x' `1' `2'
    gph line `ah2y' `ah2x' `1' `2'
end

program define Gphbar /* vertical bar */
* Gphbar yposition xposition bar_height
* 1.0.1 NJC 18 February 1999
* 1.0.0 NJC 27 May 1997
    version 6.0
    local by1 = `1' - 0.5 * `3'
    local by2 = `1' + 0.5 * `3'
    gph line `by1' `2' `by2' `2'
end

program define Gphcross /* cross X */ /* FW */
* Gphcross yposition xposition bar_height
* 1.0.1 NJC 18 February 1999
* 1.0.0 NJC 6 October 1997
    version 6.0
    local Xy1 = `1' - 0.5 * `3'
    local Xy2 = `1' + 0.5 * `3'
    local Xx1 = `2' - 0.5 * `3'
    local Xx2 = `2' + 0.5 * `3'
    gph line `Xy1' `Xx1' `Xy2' `Xx2'
    gph line `Xy2' `Xx1' `Xy1' `Xx2'
end

program def Markout2 /* marks out obs with all missing values */
* 1.0.2 NJC 16 February 1999
* 1.0.1 NJC 25 March 1998
    version 6.0
    syntax varlist(min=1) [, Strok ]
    tokenize `varlist'
    local nvars : word count `varlist'
    if `nvars' == 1 { exit 0 }
    local nvars = `nvars' - 1
    local markvar `1'
    mac shift
    tempvar nmiss
    gen `nmiss' = 0
    qui {
        while "`1'" != "" {
            local type : type `1'
            if substr("`type'", 1, 3) == "str" {
                if "`strok'" != "" { replace `nmiss' = `nmiss' + (`1' == "") }
                else replace `nmiss' = `nmiss' + 1
           }
           else replace `nmiss' = `nmiss' + (`1' == .)
           mac shift
        }
        replace `nmiss' = `nmiss' == `nvars'
        replace `markvar' = 0 if `nmiss'
    }
end

program def Gphtrans, rclass /* transliterate ".OSTodp" -> "0123456" */
* 1.0.2 NJC 1 March 1999
* 1.0.0 NJC 31 March 1998
    version 6.0
    args argin
    local length = length("`argin'")

    local i 1
    while `i' <= `length' {
        local s = substr("`argin'", `i', 1)
        if      "`s'" == "." { local s 0 }
        else if "`s'" == "O" { local s 1 }
        else if "`s'" == "S" { local s 2 }
        else if "`s'" == "T" { local s 3 }
        else if "`s'" == "o" { local s 4 }
        else if "`s'" == "d" { local s 5 }
        else if "`s'" == "p" { local s 6 }
        local argout "`argout'`s'"
        local i = `i' + 1
    }

    return local symbol `argout'
end

program def Gphpt
* 1.2.2 NJC 24 February 1999 smaller big cross, bigger ,
* 1.2.1 NJC 18 February 1999
* 1.2.0 NJC 12 Jan 1999
* 1.1.0 NJC 24 Sept 1998
* 1.0.0 NJC 6 April 1998
    version 6.0
    args sy y x barht ptsize

    if      "`sy'" == "|" { Gphbar   `y' `x'       `barht' }
    else if "`sy'" == "," { Gphbar   `y' `x'   0.6*`barht' }
    else if "`sy'" == "X" { Gphcross `y' `x' 0.707*`barht' }
    else if "`sy'" == "x" { Gphcross `y' `x'   0.5*`barht' }
    else if "`sy'" == "-" { Gphhbar  `y' `x'   0.5*`barht' }
    else gph point `y' `x' `ptsize' `sy'
end

program define Gphhbar /* horizontal bar  */
* Gphhbar yposition xposition bar_length
* 1.0.1 NJC 18 February 1999
* 1.0.0 NJC 24 Sept 1998
    version 6.0
    local bx1 = `2' - 0.5 * `3'
    local bx2 = `2' + 0.5 * `3'
    gph line `1' `bx1' `1' `bx2'
end
