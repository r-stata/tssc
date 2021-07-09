*! 1.4.4 NJC 8 November 1999 
* 1.4.2 NJC 3 June 1999 
* 1.4.1 NJC 30 April 1999
* 1.4.0 NJC 19 March 1999
* 1.3.0 NJC 24 February 1999
* 1.2.0 NJC 26 March 1998
* Fred Wolfe unearthed bugs and suggested features marked `FW'
* 1.1.0 NJC 17 June 1997
program define hbar
    version 6.0

    #delimit ;
    syntax varlist( numeric) [if] [in]
    [ , BOrder SOrt(str) noXaxis noYaxis PEn(str)
    SHading(str) T1title(str) T2title(str) TItle(str asis) TTIck VALLBL(varname)
    XLAbel(numlist) XLIne(numlist) XSCale(str) XTIck(numlist) Axtol(int 600)
    Barfrac(real 0.6) BLank flipt Format(str) FONTC(int 290) FONTR(int 570)
    FONTCB(int 444) FONTRB(int 923) GAPMag(real 1) GAPs(numlist int)
    GLegend(str) gllj GLPos(int -1) t2m(int 0) LAP Legend(varname) NIT2
    Openbar(str) RLegend(varname) rllj RLPos(int 31500) tim(int 0) 
    Vat(str) VATFmt(str) VATPos(int 31500) Cstart(int -1) SAving(str) VAP 
    t1m(int 0) PENText(int 1) SHOWZERO ] ;
    #delimit cr

    qui {
        tempvar touse order gleg gap dneg dpos dneg2 dpos2
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

        * gaps between bars?
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
        g `dneg' = 0
        g `dpos' = 0
        tokenize `varlist'
        while "`1'" != "" {
            replace `dneg' = `dneg' + `1' if `1' < 0
            replace `dpos' = `dpos' + `1' if `1' >= 0 & `1' < .
            mac shift
        }
        su `dneg' if `touse', meanonly
        loc dnegmin = r(min)
        loc dnegmax = r(max)
        su `dpos' if `touse', meanonly
        loc dposmax = r(max)
        loc dnegmin = cond(`dnegmin' == 0, r(min), `dnegmin')
        loc dposmax = cond(`dposmax' == 0, `dnegmax', `dposmax')
        loc min = min(`min', `dnegmin')
        loc max = max(`max', `dposmax')
        loc drange = `max' - `min'
        loc zero = cond(`min' >= 0, max(0,`min'), min(0,`max'))
        g `dpos2' = `zero'
        g `dneg2' = `dneg'  /* was `zero' before 1.2.0 */
        replace `dpos' = 0
    }

    * show zeros? 
    loc showz = "`showzero'" != "" 

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

    * row where first bar starts
    loc ystart = `ybeg' + `axtol'

    * step between bars: one gap defaults to one bar
    loc ystep = (`ylength' - 2 * `axtol')
    loc ystep = `ystep' / (`nuse' - 1 + `barfrac' + `ngaps' * `gapmag')

    loc yend = `ybeg' + `ylength'
    loc ynudge = 200 * (`fontr'/570)^2
                               /* text displaced downwards from bars */
    loc ytick 400          /* tick length */
    loc yleg 1000          /* labels down from axis */
    loc yleg = `yend' + `yleg'
    loc ytitle 1400        /* title down from labels */
    loc ytitlef 900        /* title down from labels, flip titles */
    loc xstart `cstart'    /* col where first bar begins */
    loc xgap 400           /* gap between left legend and body of plot */
    loc xbeg = `xstart' - `xgap'
    if `glpos' == -1 { loc glpos `xbeg' }
    loc xlength = 30000 - `xstart'
                               /* horizontal extent of data region */
    loc xend = `xbeg' + `xgap' + `xlength'
    loc xz = `xbeg' + `xgap' + `xlength' * (`zero' - `min') / `drange'
    loc mcent = (`cstart' + 30000)/2 + `tim'
                               /* col where main title centred */
    loc keyb1 300              /* dimensions of key box */
    loc keyb2 300

    if "`format'" == "" { loc format "%1.0f" }
    if "`vatfmt'" == "" { loc vatfmt "%1.0f" }

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
                gph line `ybeg' `xend' `ytick2' `xend' /* FW */
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
            loc xli = `xbeg' + `xgap' + `xlength' * (`1' - `min')/`drange'
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
        loc y2 = `ystart' - (1 - 0.5 * `barfrac') * `ystep' + `ynudge'
        gph text `y2' `glpos' 0 `glj' `gleg0'
    }

    tokenize `varlist'
    loc nvars : word count `varlist'
    loc nv = 1 + int(`nvars' / 5)

    if "`pen'" == "" { loc pen : di _dup(`nv') "23451" }
    if "`shading'" == "" { loc shading : di _dup(`nv') "01234" }
    else if length("`shading'") == 1 & `nvars' > 1 {
            loc shading : di _dup(`nvars') "`shading'"
    }
    if "`openbar'" == "" { loc openbar: di _dup(`nvars') "n" }
    if "`vat'" == "" { loc vat : di _dup(`nvars') "." }
    else if length("`vat'") == 1 & `nvars' > 1 {
            loc vat : di _dup(`nvars') "`vat'"
    }

    loc l = length("shading")
    loc nshow = `nvars'
    loc i 1
    while `i' <= `l' {
        loc char = substr("`shading'",`i',1)
        if "`char'" == "n" { loc nshow = `nshow' - 1 }
        loc i = `i' + 1
    }

    * for each variable
    loc j 1

    while "`1'" != "" {

        loc data "`1'"
        loc sh = substr("`shading'",`j',1)
        loc pe = substr("`pen'",`j',1)
        loc open = substr("`openbar'",`j',1)
        loc v = substr("`vat'",`j',1)
        loc y `ystart'
        if "`gleg0'" != "" { loc y = `y' + `ystep' * `gapmag' }
        qui replace `dneg' = `dneg' - `data' if `data' < 0
        qui replace `dpos' = `dpos' + `data' if `data' >= 0 & `data' < .

        * for each observation
        loc i 1
        while `i' <= `nuse'  {

            * bars
            gph pen `pe'
            loc y1 = `y' + `barfrac' * `ystep'
            loc y2 = `y' + 0.5 * `barfrac' * `ystep' + `ynudge'
            loc value = `data'[`i']
            if `value' >= 0 & `value' != . {
                loc x = `xbeg' + `xgap' + /*
                  */ `xlength' * (`dpos'[`i'] - `min') / `drange'
                loc x1 = `xbeg' + `xgap' + /*
                  */ `xlength' * (`dpos2'[`i'] - `min') / `drange'
            }
            else {
                loc x = `xbeg' + `xgap' + /*
                 */ `xlength' * (`dneg'[`i'] - `min') / `drange'
                loc x1 = `xbeg' + `xgap' + /*
                 */ `xlength' * (`dneg2'[`i'] - `min') / `drange'
            }
	    loc show = `showz' & `value' == 0 & "`sh'" != "n" 
	    loc show = `show' + (`value' != 0 & `value' != . & "`sh'" != "n") 
            if `show' {
                if "`sh'" == "." {
                    gph line  `y' `x' `y' `x1'
                    if "`open'" != "y" { gph line  `y' `x1' `y1' `x1' }
                    gph line  `y1' `x1' `y1' `x'
                    gph line  `y1' `x' `y' `x'
                }
                else if index("-rRlLbB","`sh'") {
                    loc ym = (`y' + `y1') / 2
                    gph line `ym' `x' `ym' `x1'
                    if index("rRlLbB", "`sh'") {
                        loc xmin = min(`x',`x1')
                        loc xmax = max(`x',`x1')
                        loc yu = (3 * `y' + `y1') / 4
                        loc yl = (3 * `y1' + `y') / 4
                        if index("rb", "`sh'") {
                            gph line `yu' `xmax' `yl' `xmax'
                        }
                        else if index("RB", "`sh'") {
                            gph line `y1' `xmax' `y' `xmax'
                        }
                        if index("lb", "`sh'") {
                            gph line `yu' `xmin' `yl' `xmin'
                        }
                        else if index("LB", "`sh'") {
                            gph line `y1' `xmin' `y' `xmin'
                        }
                    }
                }
                else gph box `y' `x' `y1' `x1' `sh'
            }

            * values as text
            gph pen `pentext'
            if "`v'" != "." & `value' != . {
                Hbar_v `value' `v' `x' `x1' `vatpos'
                loc vatpos $S_1
                loc jus $S_2
                if "`vap'" != "" { loc text = abs(`value') }
                else loc text = `value'
                loc text : di `vatfmt' `text'
                gph text `y2' `vatpos'  0 `jus' `text'
            }

            * legend
            if `j' == 1 {
                loc text = `legend'[`i']
                gph text `y2' `xbeg'  0 1 `text'
            }

	    * right legend 
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
                    loc y2 = `y' + 0.5 * `barfrac' * `ystep' + `ynudge'
                    gph text `y2' `glpos'  0 `glj' `text'
                }
            }
	    
            loc y = `y' + `ystep'
            loc i = `i' + 1
        }
        * next observation

        qui replace `dneg2' = `dneg'
        qui replace `dpos2' = `dpos'
        loc j = `j' + 1
        mac shift
    }
    * next variable

    * t2title, left justified (defaults to key for 2 or more variables)
    if "`t2title'" != "" & trim("`t2title'") == "" {
        loc t2title
    }
    else if "`t2title'" != "" {
        loc xl = `xstart' + `t2m'
        gph text `t2start' `xl' 0 -1 `t2title'
    }
    else if `nvars' >= 2 {
        loc t2l = `t2start' - `ynudge' + `keyb1'
        loc t2u = `t2start' - `ynudge' - `keyb2'
        loc xjump =  `xlength' / `nshow'
        loc xjump2 = `xjump' / 50
        loc xl = `xstart' + `t2m' + `xjump2' - `keyb1'
        loc xr = `xstart' + `t2m' + `xjump2' + `keyb2'
        loc j 1
        while `j' <= `nvars' {
            loc sh = substr("`shading'",`j',1)
            if "`sh'" == "n" {
                loc j = `j' + 1
                loc sh = substr("`shading'",`j',1)
            }
            loc pe = substr("`pen'",`j',1)
            gph pen `pe'
            if "`sh'" == "." {
                gph line  `t2l' `xl' `t2u' `xl'
                gph line  `t2u' `xl' `t2u' `xr'
                gph line  `t2u' `xr' `t2l' `xr'
                gph line  `t2l' `xr' `t2l' `xl'
            }
            else if index("01234","`sh'") {
                gph box `t2l' `xr' `t2u' `xl' `sh'
            }
            loc x2 = `xr' - `fontc'/2
            loc var : word `j' of `varlist'
            if "`nit2'" == "" {
                loc text : variable label `var'
                if "`text'" == "" { loc text "`var'" }
            }
            else loc text "`var'"
            gph pen `pentext'
            gph text `t2start' `x2' 0 -1 `text'
            loc xl = `xl' + `xjump'
            loc xr = `xr' + `xjump'
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

program def Hbar_v  /* values as text */
version 6.0
args val v x x1 vbp

if index("Lre","`v'") { loc jus 1 }
else if index("lR", "`v'") { loc jus -1 }
else if "`v'" == "m" { loc jus 0 }
else if index("Nf", "`v'") { loc jus = cond(`val' > 0, 1, -1) }
else if index("nF", "`v'") { loc jus = cond(`val' > 0, -1, 1) }
else loc jus 1

if index("rR", "`v'") { loc vp `x' }
else if index("lL", "`v'") { loc vp `x1' }
else if "`v'" == "m" { loc vp = (`x' + `x1')/2 }
else if index("Nn", "`v'") { loc vp = cond(`val' > 0, `x1', `x') }
else if index("Ff", "`v'") { loc vp = cond(`val' > 0, `x', `x1') }
else if "`v'" == "e" { loc vp `vbp' }

global S_1 `vp'
global S_2 `jus'

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

