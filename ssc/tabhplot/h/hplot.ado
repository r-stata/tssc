*! 1.4.4 NJC 23 May 2001 
* 1.4.3 NJC 9 November 1999 
* 1.4.2 NJC 3 June 1999 
* 1.4.1 NJC 16 May 1999
* 1.4.0 NJC 19 March 1999
* Mike Bradburn unearthed bug marked `MB'
* 1.3.0 NJC 31 March 1998
* Fred Wolfe unearthed bugs and suggested features marked `FW'
* 1.2.0 NJC 17 June 1997
program define hplot
    version 6.0

    #delimit ;
    syntax varlist(numeric) [if] [in]
    [, BOrder SOrt(string) noXaxis noYaxis PEn(string) Symbol(string)
    T1title(string) T2title(string) TItle(str asis) TTIck VALLBL(varname) 
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
        loc nuse = r(N)

        * legend on left
        if "`legend'" == "" {
            tempvar legend
            g str1 `legend' = " "
            if "`blank'" == "" {
                replace `legend' = string(_n) if `touse'
            }
        }
        else {
            confirm variable `legend'
            capture confirm string variable `legend'
            if _rc == 7 {
                tempvar legend2
                capture decode `legend', g(`legend2')
                if _rc {
                    gen str1 `legend2' = ""
                    replace `legend2' = string(`legend')
                }
                else {
                    replace `legend2' = string(`legend') /*
                    */ if missing(`legend2')
                }
                loc legend "`legend2'"
            }
        }
        loc leglen : type `legend'
        loc leglen = substr("`leglen'",4,.)
        if `cstart' == -1 {
            loc cstart = 2000 + int(9000 * `leglen' / 25)
        }

	* legend on right                                 
        if "`rlegend'" != "" {                            
            capture confirm string variable `rlegend'     
            if _rc == 7 {                                 
                tempvar rleg2                             
                capture decode `rlegend', g(`rleg2')      
                if _rc == 0 {                             
                    replace `rleg2' = string(`rlegend') /*
                    */ if missing(`rleg2')                
                    loc rlegend "`rleg2'"                 
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
            loc xscmin `1'
            loc xscmax `3'
        }

        if "`xscmin'" == "" { loc min 0 }
        else loc min `xscmin'
        if "`xscmax'" == "" { loc max 0 }
        else loc max `xscmax'

        * xlabel xtick xline might extend graph range beyond data range
        if "`xlabel'`xtick'`xline'" != "" {
            numlist "`xlabel' `xtick' `xline'", sort
            loc nn : word count `r(numlist)'
            loc xmin : word 1 of `r(numlist)'
            loc xmax : word `nn' of `r(numlist)'
            loc min = min(`min', `xmin')
            loc max = max(`max', `xmax')
        }

        * gap legend?
        g str1 `gleg' = " "
        loc glj = cond("`gllj'" != "", -1, 1)
        if "`glegend'" != "" {
            tokenize "`glegend'", parse("!")
            loc j 1
            while "`1'" != "" {
                if "`1'" != "!" {
                    if "`1'" == "." { loc 1 " " }
                    loc gleg`j' "`1'"
                    loc j = `j' + 1
                }
                mac shift
            }
        }

        * gaps between lines?
        g byte `gap' = 0
        if "`gaps'" != "" {
            loc j 1
            numlist "`gaps'", int range(>=0)
            tokenize `r(numlist)'
            while "`1'" != "" {
                if "`1'" == "0" {
                    loc gleg0 "`gleg`j''"
                    if "`gleg0'" == "" { loc gleg0 " " }
                }
                else {
                    replace `gap' = 1 in `1' if `1' <= `nuse'
                    replace `gleg' = "`gleg`j''" in `1' if `1' <= `nuse'
                }
                loc j = `j' + 1
                mac shift
            }
        }
        count if `gap'
        loc ngaps = r(N) + ("`gleg0'" != "")

        * data range
        tokenize `varlist'
        loc nvars : word count `varlist'
        g `dmin' = `1'
        g `dmax' = `1'
        if `nvars' >= 2 {
            loc i 2
            while `i' <= `nvars' {
                replace `dmin' = min(`dmin', ``i'')
                replace `dmax' = max(`dmax', ``i'')
                loc i = `i' + 1
            }
        }
        su `dmin' if `touse', meanonly
        loc min = min(`min', r(min))
        su `dmax' if `touse', meanonly
        loc max = max(`max', r(max))
        loc drange = `max' - `min'
        loc zero = cond(`min' >= 0, max(0,`min'), min(0,`max'))
        g `z' = `zero'
        g `dneg' = min(`dmin', `z')
        g `dpos' = max(`dmax', `z')
    }

    * start of parameter block

    loc t1start 1000       /* row for t1title */
    loc t2start 1900       /* row for t2title */
    loc ybeg 2400          /* start of y-axis */
    loc ylength 17600

    * `axtol' is space at ends of y-axis
    * axtol too large => ystep negative FW
    if `axtol' > `ylength' / 2 {
         di in bl "axtol too large: reset to default 600"
         loc axtol 600
     }

    * row where first line starts
    loc ystart = `ybeg' + `axtol'

    * step between lines: one gap defaults to one line
    loc ystep = /*
     */ (`ylength' - 2 * `axtol')/(`nuse' - 1 + `ngaps' *`gapmag')

    loc yend = `ybeg' + `ylength'
    loc ynudge = 200 * (`fontr'/570)^2
                       /* text displaced downwards from lines */
    loc ytick 400          /* tick length */
    loc yleg 1000          /* labels down from axis */
    loc yleg = `yend' + `yleg'
    loc ytitle 1400        /* title down from labels */
    loc ytitlef 900        /* title down from labels, flip titles */
    loc xstart `cstart'    /* col where first line begins */
    loc xgap 400           /* gap between left legend and body of plot */
    loc xbeg = `xstart' - `xgap'
    if `glpos' == -1 { loc glpos `xbeg' }
    loc xlength = 30000 - `xstart'
                           /* horizontal extent of data region */
    loc xend = `xbeg' + `xgap' + `xlength'
    loc xz = /*
    */ `xbeg' + `xgap' + `xlength' * (`zero' - `min') / `drange'
    loc mcent = (`cstart' + 30000)/2 + `tim'
                           /* col where main title centred */
    loc dotsp 150          /* spacing between dots */

    if "`format'" == "" { loc format "%1.0f" }
    if "`vatfmt'" == "" { loc vatfmt "%1.0f" }
    loc ahl = 500 * `ptsize'/275  /* arrowhead length */
    loc aha = _pi/6 /* arrowhead angle, between head and stem */
    loc barht `ahl' /* bar height */

    if "`symbol'" == "" {
        if `nvars' < 6 { loc symbol "46253" }
        else loc symbol : di _dup(`nvars') "4"
    }
    else if length("`symbol'") == 1 & `nvars' > 1 {
        loc symbol : di _dup(`nvars') "`symbol'"
    }
    Gphtrans `symbol'
    loc symbol "`r(symbol)'"

    if "`pen'" == "" { loc pen : di _dup(`nvars') "2" }
    else if length("`pen'") == 1 & `nvars' > 1 {
        loc pen : di _dup(`nvars') "`pen'"
    }

    * end of parameter block

    * start gph
    if "`saving'" != "" { loc saving ", saving(`saving')" }
    gph open `saving' /* FW */
    gph pen `pentext'
    gph font `fontr' `fontc'

    * y-axis
    if "`yaxis'" == "" { gph line `ybeg' `xstart' `yend' `xstart' }

    * ttick => top ticks
    loc ttick = "`ttick'" == "ttick"
    * ttick should => border FW
    if `ttick' { loc border "border" }

    * x-axis and labels
    if "`xaxis'" == "" {
        gph line `yend' `xstart' `yend' `xend'
        loc ytick2 = `ybeg' - `ytick'/2
        loc ytick = `yend' + `ytick'
        if "`xlabel'" == "" {
            gph line `yend' `xstart' `ytick' `xstart'
            gph line `yend' `xend' `ytick' `xend'
            if `ttick' {
                gph line `ybeg' `xstart' `ytick2' `xstart'
                gph line `ybeg' `xend' `ytick2' `xend'   /* FW */
            }
            loc text = cond("`lap'" == "lap", abs(`min'), `min')
            loc text : di `format' `text'
            gph text `yleg' `xstart' 0 0 `text'
            loc text = cond("`lap'" == "lap", abs(`max'), `max')
            loc text : di `format' `text'
            gph text `yleg' `xend' 0 0 `text'
        }
        else {
            numlist "`xlabel'"
            tokenize `r(numlist)'
            if "`vallbl'" != "" {                             
        	local vallbl : value label `vallbl' 
            }	                                    
            while "`1'" != "" {
                loc xtickp = /*
                */ `xbeg' + `xgap' + `xlength' * (`1' - `min')/`drange'
                gph line `yend' `xtickp' `ytick' `xtickp'
                if `ttick' {
                    gph line `ybeg' `xtickp' `ytick2' `xtickp'
                }
                loc text = cond("`lap'" == "lap", abs(`1'), `1')
		if "`vallbl'" != "" {                          
		    local label : label `vallbl' `text'        
		    if "`label'" != "" { local text "`label'" }
		}                                              
                else loc text : di `format' `text'             
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
            loc xtickp = /*
            */ `xbeg' + `xgap' + `xlength' * (`1' - `min')/`drange'
            gph line `yend' `xtickp' `ytick' `xtickp'
            if `ttick' {
                gph line `ybeg' `xtickp' `ytick2' `xtickp'
            }
            mac shift
        }
    }

    * x-lines
    if "`xline'" != "" {
        numlist "`xline'"
        tokenize `r(numlist)'
        while "`1'" != "" {
            loc xli = /*
            */ `xbeg' + `xgap' + `xlength' * (`1' -  `min')/`drange'
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
        loc y2 = `ystart' + (`gapmag' - 1) * `ystep' + `ynudge'
        gph text `y2' `glpos' 0 `glj' `gleg0'
    }

    * for each variable
    tokenize `varlist'
    loc j 1
    while "`1'" != "" {

        loc data "`1'"
        loc sy = substr("`symbol'",`j',1)
        loc pe = substr("`pen'",`j',1)
        loc y `ystart'
        if "`gleg0'" != "" { loc y = `y' + `ystep' * `gapmag' }

        * for each observation
        loc i 1
        while `i' <= `nuse'  {

            * dots and/or lines
            if `j' == 1 {
                if "`range'" == "range" {
                    /* MB: next statement needed because largest value
                    could be negative, of course! */
                    loc xmax = `xbeg' + `xgap' + /*
                    */ `xlength' * (`dmax'[`i'] - `min') / `drange'
                    loc xmin = `xbeg' + `xgap' + /*
                    */ `xlength' * (`dmin'[`i'] - `min') / `drange'
                    loc xz `xmin'
                }
                else {
                    loc xmax = `xbeg' + `xgap' + /*
                    */ `xlength' * (`dpos'[`i'] - `min') / `drange'
                    loc xmin = `xbeg' + `xgap' + /*
                    */ `xlength' * (`dneg'[`i'] - `min') / `drange'
                }
                if "`line'" == "line" {
                    gph line  `y' `xmax'  `y' `xz'
                    gph line  `y' `xmin'  `y' `xz'
                }
                if "`line'`grid'" == "" {
                    loc xdot `xz'
                    loc ndots = int(abs(`xmax' - `xz') / `dotsp')
                    loc idot 1
                    while `idot' <= `ndots' {
                        gph point `y' `xdot' `ptsize' 0
                        if "`range'" == "range" {
                            loc xdot = `xdot' + `dotsp'
                        }
                        else loc xdot = /*
                        */ `xdot' + `dotsp' * sign(`dpos'[`i'])
                        loc idot = `idot' + 1
                    }
                    loc xdot `xz'
                    loc ndots = int(abs(`xmin' - `xz') / `dotsp')
                    loc idot 1
                    while `idot' <= `ndots' {
                        gph point `y' `xdot' `ptsize' 0
                        loc xdot = `xdot' + `dotsp' * sign(`dneg'[`i'])
                        loc idot = `idot' + 1
                    }
                }
                if "`grid'" != "" {
                    loc xdot `xstart'
                    while `xdot' < `xend' {
                        gph point `y' `xdot' `ptsize' 0
                        loc xdot = `xdot' + `dotsp'
                    }
                }
            }

            * data point
            gph pen `pe'
            loc x = `xbeg' + `xgap' + /*
            */ `xlength' * (`data'[`i'] - `min') / `drange'
            if `data'[`i'] < . & "`sy'" != "i" {
                if "`sy'" == "a" {
                    if `j' == 1 { loc sign 1 }
                    else loc sign = sign(`data'[`i'] - `prev'[`i'])
                    Gphhah `y' `x' `sign' `ahl' `aha'
                }
                else if "`sy'" == ">" { Gphhah `y' `x' 1 `ahl' `aha' }
                else if "`sy'" == "<" { Gphhah `y' `x' -1 `ahl' `aha' }
                else Gphpt `sy' `y' `x' `barht' `ptsize'
            }

            * text
            gph pen `pentext'
            loc y2 = `y' + `ynudge'
            if "`vat'" != "" & `nvars' == 1 {
                loc text : di `vatfmt' `data'[`i']
                gph text `y2' `vatpos'  0 1 `text'
            }
            if `j' == 1 {
                loc text = `legend'[`i']
                gph text `y2' `xbeg'  0 1 `text'
            }
	    if `j' == 1 & "`rlegend'" != "" {            
	    	local text = `rlegend'[`i']              
		local rlj = cond("`rllj'" != "", -1, 1)  
		gph text `y2' `rlpos' 0 `rlj' `text'     
	    }	                                         

            * gap
            if `gap'[`i'] {
                loc y = `y' + `ystep' * `gapmag'
                if `j' == 1 {
                    loc text = `gleg'[`i']
                    loc y2 = `y' + `ynudge'
                    gph text `y2' `glpos'  0 `glj' `text'
                }
            }

            loc y = `y' + `ystep'
            loc i = `i' + 1
        }
        * next observation

        loc prev `1'
        loc j = `j' + 1
        mac shift
    }
    * next variable

    * t2title, left justified (defaults to key for 2 or more variables)
    if "`t2title'" != "" & trim("`t2title'") == "" {
        loc t2title
    }
    else if "`t2title'" != "" {
        gph text `t2start' `xstart' 0 -1 `t2title'
    }
    else if `nvars' >= 2 {
        loc t2 = `t2start' - `ynudge'
        loc xjump =  `xlength' / `nvars'
        loc xjump2 = `xjump' / 50
        loc x = `xstart' + `xjump2' + `t2m'
        loc j 1
        while `j' <= `nvars' {
            loc sy = substr("`symbol'",`j',1)
            loc pe = substr("`pen'",`j',1)
            gph pen `pe'
            if "`sy'" == "a" {
                loc ahv = index("`symbol'","a")
                if `ahv' > 1 {
                    loc this : word `ahv' of `varlist'
                    loc ahvm1 = `ahv' - 1
                    local prev : word `ahvm1' of `varlist'
                    count if `this' >= `prev' & `touse'
                    loc majsign = cond(r(N) > `nuse'/2, 1, -1)
                }
                else loc majsign 1
                loc x3 = `x' + 0.6 * `ptsize' * `majsign'
                Gphhah `t2' `x3' `majsign' `ahl' `aha'
            }
            else if "`sy'" == ">" {
                loc x3 = `x' + 0.6 * `ptsize'
                Gphhah `t2' `x3' 1 `ahl' `aha'
            }
            else if "`sy'" == "<" {
                loc x3 = `x' - 0.6 * `ptsize'
                Gphhah `t2' `x3' -1 `ahl' `aha'
            }
            else if "`sy'" != "i" {
                Gphpt `sy' `t2' `x' `barht' `ptsize'
            }
            loc x2 = `x' + `xjump2'
            loc var : word `j' of `varlist'
            if "`nit2'" == "" {
                loc text : variable label `var'
                if "`text'" == "" { loc text "`var'" }
            }
            else loc text "`var'"
            gph pen `pentext'
            gph text `t2start' `x2' 0 -1 `text'
            loc x = `x' + `xjump'
            loc j = `j' + 1
        }
    }

    * title and t1title
    if `"`title'"' == `""' & `nvars' == 1 {
        loc title : variable label `data'
        if "`title'" == "" { loc title "`data'" }
    }
    else if `"`title'"' != `""' { loc title `title' }

    loc xL = `xstart' + `t1m'
    if "`flipt'" == "" { /* default */
        * t1title, left justified
        gph text `t1start' `xL' 0 -1 `t1title'

        * main title at bottom, centred
        gph font `fontrb' `fontcb'
        loc ytitle = `yleg' + `ytitle'
        gph text `ytitle' `mcent' 0 0 `title'
    }
    else { /* flip titles from default */
        * bottom title, centred (and closer to axis than default)
        loc ytitle = `yleg' + `ytitlef'
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
    loc ah1y = `1' - `3' * `4' * sin(`5')
    loc ah1x = `2' - `3' * `4' * cos(`5')
    loc ah2y = `1' + `3' * `4' * sin(`5')
    loc ah2x = `2' - `3' * `4' * cos(`5')
    gph line `ah1y' `ah1x' `1' `2'
    gph line `ah2y' `ah2x' `1' `2'
end

program define Gphbar /* vertical bar */
* Gphbar yposition xposition bar_height
* 1.0.1 NJC 18 February 1999
* 1.0.0 NJC 27 May 1997
    version 6.0
    loc by1 = `1' - 0.5 * `3'
    loc by2 = `1' + 0.5 * `3'
    gph line `by1' `2' `by2' `2'
end

program define Gphcross /* cross X */ /* FW */
* Gphcross yposition xposition bar_height
* 1.0.1 NJC 18 February 1999
* 1.0.0 NJC 6 October 1997
    version 6.0
    loc Xy1 = `1' - 0.5 * `3'
    loc Xy2 = `1' + 0.5 * `3'
    loc Xx1 = `2' - 0.5 * `3'
    loc Xx2 = `2' + 0.5 * `3'
    gph line `Xy1' `Xx1' `Xy2' `Xx2'
    gph line `Xy2' `Xx1' `Xy1' `Xx2'
end

program def Markout2 /* marks out obs with all missing values */
* 1.0.2 NJC 16 February 1999
* 1.0.1 NJC 25 March 1998
    version 6.0
    syntax varlist(min=1) [, Strok ]
    tokenize `varlist'
    loc nvars : word count `varlist'
    if `nvars' == 1 { exit 0 }
    loc nvars = `nvars' - 1
    loc markvar `1'
    mac shift
    tempvar nmiss
    gen `nmiss' = 0
    qui {
        while "`1'" != "" {
            loc type : type `1'
            if substr("`type'",1,3) == "str" {
                if "`strok'" != "" {
                    replace `nmiss' = `nmiss' + (`1' == "")
                }
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
    loc length = length("`argin'")

    loc i 1
    while `i' <= `length' {
        loc s = substr("`argin'", `i', 1)
        if "`s'" == "."      { loc s 0 }
        else if "`s'" == "O" { loc s 1 }
        else if "`s'" == "S" { loc s 2 }
        else if "`s'" == "T" { loc s 3 }
        else if "`s'" == "o" { loc s 4 }
        else if "`s'" == "d" { loc s 5 }
        else if "`s'" == "p" { loc s 6 }
        loc argout "`argout'`s'"
        loc i = `i' + 1
    }

    return loc symbol `argout'
end

program def Gphpt
* 1.2.2 NJC 24 February 1999 smaller big cross, bigger ,
* 1.2.1 NJC 18 February 1999
* 1.2.0 NJC 12 Jan 1999
* 1.1.0 NJC 24 Sept 1998
* 1.0.0 NJC 6 April 1998
    version 6.0
    args sy y x barht ptsize

    if "`sy'" == "|" { Gphbar `y' `x' `barht' }
    else if "`sy'" == "," { Gphbar `y' `x' 0.6*`barht' }
    else if "`sy'" == "X" { Gphcross `y' `x' 0.707*`barht' }
    else if "`sy'" == "x" { Gphcross `y' `x' 0.5*`barht' }
    else if "`sy'" == "-" { Gphhbar `y' `x' 0.5*`barht' }
    else gph point `y' `x' `ptsize' `sy'
end

program define Gphhbar /* horizontal bar */
* Gphhbar yposition xposition bar_length
* 1.0.1 NJC 18 February 1999
* 1.0.0 NJC 24 Sept 1998
    version 6.0
    loc bx1 = `2' - 0.5 * `3'
    loc bx2 = `2' + 0.5 * `3'
    gph line `1' `bx1' `1' `bx2'
end
