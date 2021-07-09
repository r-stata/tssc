*! 1.2.4 NJC 27 January 2004 
*! 1.2.3 NJC 28 June 2000 
* 1.2.2 NJC 24 November 1999
* 1.2.1 NJC 28 March 1999
* 1.1.0 NJC 6 May 1998
program def triplot6
    version 6.0
    #delimit ;
    syntax varlist(min=3 max=3) [if] [in]
    [, Max(real 1) LAbel(numlist miss) Vertices(real 1) Y SAving(str) 
    Symbol(str) PTSize(int 275) PEn(str) FONTR(int 570) FONTC(int 290)
    Connect(str) Group(varname) AHL(int 300) 
    LText(str) RText(str) BText(str) BLText(str) BRText(str) TText(str)  
    TItle(str) T1title(str) Key(varname) KEYCol(int 24000) KEYRow(int 4000) 
    KEYText(varname) ] ;
    #delimit cr

    if "`connect'" != "" { 
    	if "`connect'" != "l" & "`connect'" != "a" { 
	    di in r "invalid connect( ) option" 
	    exit 198 
	}
    }	

    marksample touse
    qui count if `touse'
    local nuse = r(N)
    if `nuse' == 0 {
        di in r "no observations"
        exit 2000
    }

    tokenize `varlist'
    args a b c 
    loc i 1
    while `i' <= 3 {
        capture assert ``i'' >= 0 & ``i'' <= `max' if `touse'
        if _rc {
            di in r "``i'' has values outside [0, `max']"
            exit 198
        }
        loc i = `i' + 1
    }

    if "`symbol'" != "" {
	tokenize "`symbol'", parse("[] ") 
        local i = 1 
	while "`1'" != "" { 
	    if "`1'" == "[" {
		mac shift
		local sy`i' "`1'" 
		if "`1'" != "_n" { 
		    capture confirm variable `1' 
		    if _rc {
			di in r "symbol( ) invalid: `1' not variable" 
			exit 198
		    }	
		    * avoid confusion between variables named 
		    * i and invisible point symbol 
		    local varsy`i' `1' 
		    local sy`i' "var" 
		}
		local st`i' 1 
		local i = `i' + 1 
		mac shift 2 
            }
	    else if "`1'" == "]" { 
	        di in r "symbol( ) invalid"
		exit 198 
	    }
	    else {
		local l = length("`1'")
		local j = 1
		while `j' <= `l' {
		    local sy`i' = substr("`1'",`j',1)
		    Gphtrans `sy`i'' 
		    local sy`i' "$S_1"
		    local st`i' 0 
		    local i = `i' + 1 
		    local j = `j' + 1
		}
		mac shift
	    }  						
        } 	
	local nsy = `i' - 1 
    }
    else {
    	local sy1 "4" 
	local nsy = 1
	local st1 = 0 
    }	
    
    if `max' <= 0 {
        di in r "maximum must be positive"
        exit 198
    }

    if "`key'" != "" {
        local keylab : value label `key'
        local keyvar 1
    }
    else local keyvar 0

    if "`group'" == "" { 
        tempvar group 
	gen byte `group' = 1
    }	
    
    tempvar order Key first left right bot 

    qui {
        gen long `order' = _n 
        sort `touse' `key' `group' `order' 
        by `touse' `key' : gen byte `Key' = _n == 1 if `touse'
        gen byte `first' = `Key'
        replace `Key' = sum(`Key')
        loc nkey = `Key'[_N]
        sort `touse' `group' `key' `order'  
    }
    
    if `nkey' > `nsy' {
        if `nsy' == 1 { 
	    local i = 2 
	    while `i' <= `nkey' {
	    	local st`i' = `st1'
		local sy`i' "`sy1'" 
		local i = `i' + 1
	    }	
	}
        else {
            di in r "insufficient symbols specified"
            exit 198
        }
    }

    if "`pen'" == "" { loc pen "2" }
    loc len = length("`pen'")
    if `nkey' > `len' {
        if `len' == 1 { loc pen : di _dup(`nkey') "`pen'" }
        else {
            di in r "insufficient pens specified"
            exit 198
        }
    }

    qui { 
        gen `left' = `a'
        gen `right' = `b'
	
        if `max' != 1 {
            replace `left' = `left' / `max' 
            replace `right' = `right' / `max' 
        }
    }

    loc htfact = sqrt(3)/2                    /* sin _pi/3 = 60 deg */
    loc xL 6000                               /* triangle coordinates */
    loc xR 26000
    loc xT = (`xL' + `xR') / 2
    loc width = `xR' - `xL'
    loc height = `width' * `htfact'
    loc yT 2000
    loc yB = `yT' + `height'
    loc yM = `yT' + `height' / 2             /* position of var text */
    loc xltext = `xT' - 0.35 * `width'
    loc xrtext = `xT' + 0.35 * `width' - 100
    loc ybtext = `yB' + 1800
    loc yt1 = `yT' - 1200                    /* position of titles */
    loc ytitle = `yB' + 2800
    local yBtext = `yB' + 800
    local yTtext = `yT' - 300
    loc yblab = `yB' + 800                   /* position of labels */
    loc xllab = `xL' - 200
    loc xrlab = `xT' - 100
    loc xkeysy `keycol'                      /* key position */
    loc xkeysy2 = `keycol' - 200
    loc xkeytxt = `xkeysy' + 500
    loc ykey `keyrow'
    loc ykeytxt = `ykey' + 200
    loc ykeyst = 1000 + (`ptsize' - 200) * (`ptsize' > 275)
    loc dotsp 150                            /* spacing between dots */
             
    if `"`saving'"' != "" { loc saving `", saving(`saving')"' }
    gph open `saving'

    if `vertices' == 1 {
        gph line `yB' `xL' `yT' `xT'
        gph line `yT' `xT' `yB' `xR'
        gph line `yB' `xR' `yB' `xL'
    }
    else {
        local v = `vertices' / 2
        local yV = `yT' + (1 - `v') * (`yB' - `yT')
        local xV = `xL' + `v' * `width' / 2
        gph line `yB' `xL' `yV' `xV'
        local xV = `xL' + `v' * `width'
        gph line `yB' `xL' `yB' `xV'
        local xV = `xL' + (1 - `v') * `width'
        gph line `yB' `xR' `yB' `xV'
        local xV = `xR' - `v' * `width' / 2
        gph line `yB' `xR' `yV' `xV'
        local xV = `xL' + (1 - `v') * `width' / 2
        local yV = `yT' + `v' * (`yB' - `yT')
        gph line `yT' `xT' `yV' `xV'
        local xV = `xR' - (1 - `v') * `width' / 2
        gph line `yT' `xT' `yV' `xV'
    }

    if "`y'" == "y" {
        local xY1 = (`xL' + `xR') / 2
        local yY1 = `yB' - (`yB' - `yT') / 3
        local ndots = 1 + (`yB' - `yY1') / `dotsp'
        loc idot 1
        loc ydot `yB'
        while `idot' <= `ndots' {
            gph point `ydot' `xY1' `ptsize' 0
            loc ydot = `ydot' - `dotsp'
            loc idot = `idot' + 1
        }
        local xY2 = (`xL' + `xT') / 2
        local yY2 = (`yB' + `yT') / 2
        local dist = sqrt((`xY2' - `xY1')^2 + (`yY2' - `yY1')^2)
        local ndots = 1 + `dist' / `dotsp'
        local idot 1
        local ydot `yY1'
        local xdot `xY1'
        while `idot' <= `ndots' {
            gph point `ydot' `xdot' `ptsize' 0
            local ydot = `ydot' - `dotsp' / 2
            local xdot = `xdot' - `dotsp' * `htfact' 
            local idot = `idot' + 1
        }
        local idot 1
        local ydot `yY1'
        local xdot `xY1'
        while `idot' <= `ndots' {
            gph point `ydot' `xdot' `ptsize' 0
            local ydot = `ydot' - `dotsp' / 2
            local xdot = `xdot' + `dotsp' * `htfact'
            local idot = `idot' + 1
        }
    }

    if "`ltext'" != " " {
        if "`ltext'" == "" {
            loc ltext : variable label `a'
            if "`ltext'" == "" { loc ltext "`a'" }
        }
        gph text `yM' `xltext' 0 1 `ltext'
    }

    if "`rtext'" != " " {
        if "`rtext'" == "" {
            loc rtext : variable label `b'
            if "`rtext'" == "" { loc rtext "`b'" }
        }
        gph text `yM' `xrtext' 0 -1 `rtext'
    }

    if "`btext'" != " " {
        if "`btext'" == "" {
            loc btext : variable label `c'
            if "`btext'" == "" { loc btext "`c'" }
        }
        gph text `ybtext' `xT' 0 0 `btext'
    }

    if trim("`ttext'") != ""  { gph text `yTtext' `xT' 0 0 `ttext' }
    if trim("`bltext'") != "" { gph text `yBtext' `xL' 0 0 `bltext' }
    if trim("`brtext'") != "" { gph text `yBtext' `xR' 0 0 `brtext' }

    if "`title'" != "" { gph text `ytitle' `xT' 0 0 `title' }
    if "`t1title'" != "" { gph text `yt1' `xT' 0 0 `t1title' }

    if "`label'" == "" {
        if `max' == 100 { loc label "0 20 40 60 80 100" }
        else loc label "0 .2 .4 .6 .8 1"
    }
    numlist "`label'", miss
    tokenize `r(numlist)'
    
   if "`1'" != "." {
        while "`1'" != "" {
            loc text "`1'"
            loc 1 = `1' / `max'

            loc x = `xllab' + (`width' / 2) * `1'
            loc y = `yT' + `height' * (1 - `1')
            gph text `y' `x' 0 1 `text'

            if `1' != 0 & `1' != 1 {
                loc xdot = `xL' + (`width' / 2) * `1'
                loc xdot2 = `xT' + (`width' / 2) * (1 - `1')
                loc ndots = 1 + (`xdot2' - `xdot') / `dotsp'
                loc idot 1
                loc ydot `y'
                while `idot' <= `ndots' {
                    gph point `ydot' `xdot' `ptsize' 0
                    loc xdot = `xdot' + `dotsp'
                    loc idot = `idot' + 1
                }
            }

            loc x = `xrlab' + (`width' / 2) * `1'
            loc y = `yT' + `height' * `1'
            gph text `y' `x' 0 -1 `text'

            if `1' != 0 & `1' != 1 {
                loc xdot = `xT' +  (`width' / 2) * `1'
                loc xdot2 = `xL' + `width' * `1'
                loc dist = sqrt((`xdot2' - `xdot')^2 + (`y' - `yB')^2)
                loc ndots = 1 + `dist' / `dotsp'
                loc idot 1
                loc ydot `y'
                while `idot' <= `ndots' {
                    gph point `ydot' `xdot' `ptsize' 0
                    loc xdot = `xdot' - `dotsp' / 2
                    loc ydot = `ydot' + `dotsp' * `htfact'
                    loc idot = `idot' + 1
                }
            }

            loc x = `xR' - `width' * `1'
            gph text `yblab' `x' 0 0 `text'

            if `1' != 0 & `1' != 1 {
                loc xdot = `xR' - `width' * `1'
                loc xdot2 = `xL' + (`width' / 2) * (1 - `1')
                loc ydot2 = `yT' + `height' * `1'
                loc dist = /*
                 */ sqrt((`xdot2' - `xdot')^2 + (`ydot2' - `yB')^2)
                loc ndots = 1 + `dist' / `dotsp'
                loc idot 1
                loc ydot `yB'
                while `idot' <= `ndots' {
                    gph point `ydot' `xdot' `ptsize' 0
                    loc xdot = `xdot' - `dotsp' / 2
                    loc ydot = `ydot' - `dotsp' * `htfact'
                    loc idot = `idot' + 1
                }
            }

            mac shift
        }
    }

    loc i = _N - `nuse' + 1
    local cg = "`connect'" != ""
    while `i' <= _N {        
        local k = `Key'[`i']
	loc x = `xL' + `width' * (`right'[`i'] + `left'[`i'] / 2)
        loc y = `yT' + `height' * (1 - `left'[`i'])
        loc pe = substr("`pen'", `k', 1)
        gph pen `pe'
        gph font `fontr' `fontc'
	if "`sy`k''" != "i" { 
            if `st`k'' {
	        if "`sy`k''" == "_n" { local text = `i' } 
	        else local text = `varsy`k''[`i']
                gph text `y' `x' 0 0 `text'
            }
            else gph point `y' `x' `ptsize' `sy`k'' 
	}     

        if `cg' & ("`prevy'" != "") & (`group'[`i'] == `group'[`i'-1]) {
            gph line `y' `x' `prevy' `prevx'
            if "`connect'" == "a" {
                local sine = `x' - `prevx'
                local cosine = `prevy' - `y' 
                Atan2  `sine' `cosine'
                local angle = $S_1
                * arrow heads `ahl' long
                * angle between heads = _pi/3 = 60 deg
                local ah1y = `y' - `ahl' * cos(`angle' + 5 * _pi / 6)
                local ah1x = `x' + `ahl' * sin(`angle' + 5 * _pi / 6)
                local ah2y = `y' - `ahl' * cos(`angle' + 7 * _pi / 6)
                local ah2x = `x' + `ahl' * sin(`angle' + 7 * _pi / 6)
                gph line `ah1y' `ah1x' `y' `x'
                gph line `ah2y' `ah2x' `y' `x'
            }
        }

        if `keyvar' & `first'[`i'] == 1 & `nkey' > 1 & `nkey' < 13 {
            gph pen `pe'
	    if "`sy`k''" != "i" { 
                if `st`k'' { 
	    	    if "`sy`k''" == "_n" { 
                        gph text `ykeytxt' `xkeysy2' 0 1 `text' 
		    }
		    else gph text `ykeytxt' `xkeysy2' 0 -1 `text' 
            	}
            	else {
                    gph point `ykey' `xkeysy' `ptsize' `sy`k''
                }
	        gph pen 1
                if "`keytext'" != "" { loc keyval = `keytext'[`i'] }
                else {
                    loc keyval = `key'[`i']
                    if "`keylab'" != "" {
                        loc keyval : label `keylab' `keyval'
                    }
                }
                gph text `ykeytxt' `xkeytxt' 0 -1 `keyval'
                loc ykey = `ykey' + `ykeyst'
                loc ykeytxt = `ykeytxt' + `ykeyst'
	    }	
        }
        local prevy `y'
        local prevx `x'
        loc i = `i' + 1
    }

    gph close
end

program def Gphtrans /* transliterate ".OSTodp" -> "0123456" */
* 1.0.0 NJC 31 March 1998

loc argin `1'
loc length = length("`argin'")

loc i 1
while `i' <= `length' {
    loc `i' = substr("`argin'", `i', 1)
    if "``i''" == "."      { loc `i' 0 }
    else if "``i''" == "O" { loc `i' 1 }
    else if "``i''" == "S" { loc `i' 2 }
    else if "``i''" == "T" { loc `i' 3 }
    else if "``i''" == "o" { loc `i' 4 }
    else if "``i''" == "d" { loc `i' 5 }
    else if "``i''" == "p" { loc `i' 6 }
    loc argout "`argout'``i''"
    loc i = `i' + 1
}

global S_1 `argout'
end

program define Atan2
* 1.2.1 NJC 25 March 1999
    version 6.0
    tempname at

    local sign1 = sign(`1')
    local sign2 = sign(`2')

    if (`sign1' == 1 & `sign2' == 1) | ((`sign1' == 0) & `sign2' == 1) {
        scalar `at' = atan(`1'/`2')
    }
    else if `sign1' == 1 & `sign2' == 0 {
        scalar `at' = _pi / 2
    }
    else if `sign1' == -1 & `sign2' == 0 {
        scalar `at' = 3 * _pi / 2
    }
    else if `sign2' ==  -1 {
        scalar `at' = _pi + atan(`1'/`2')
    }
    else if `sign1' == -1 & `sign2' == 1 {
        scalar `at' = 2 * _pi + atan(`1'/`2')
    }

    global S_1 = `at'
end

