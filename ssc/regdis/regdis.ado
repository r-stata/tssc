*! regdis version 1.0.0 19apr2010 roywada@hotmail.com
*! Control variables and decimals in regression displays

prog define regdis
version 9
cap _on_colon_parse `0'
if _rc==0 {
	local 0 `s(before)'
	qui `s(after)'
}
else {

}

cap syntax [varlist(default=none ts fv)] [, dec(int 3) fmt(str) drop(str) keep(str) NOHeader]
if _rc~=0 {
	* yes I know this is a workaround
	syntax [varlist(default=none ts)] [, dec(int 3) fmt(str) drop(str) keep(str) NOHeader]
}
else {
	syntax [varlist(default=none ts fv)] [, dec(int 3) fmt(str) drop(str) keep(str) NOHeader]
}

if `"`fmt'"'=="" {
	local fmt f
}

if `"`drop'"'~="" {
	_explicit `drop'
	local drop `_varlist'
}
if `"`keep'"'=="" & `"`varlist'"'~="" {
	local keep `varlist'
}
if `"`keep'"'~="" {
	_explicit `keep'
	local keep `_varlist'
}

_prefix_display2, dec(`dec') fmt(`fmt') drop(`drop') keep(`keep') `noheader'
*_coef_table

end


*! cloned 19apr2010 from _prefix_display version 1.1.1  27feb2006
program _prefix_display2, sortpreserve
        version 9
        is_svysum `e(cmd)'
        local is_sum = r(is_svysum)

        // only allow 'eform' options if NOT svy summary commands
        if ! `is_sum' {
                local regopts NEQ(integer -1) First PLus SHOWEQns
                local star "*"
        }
        else    local neq -1
        if "`e(cmd)'" == "logistic" {
                local is_logistic 1
                local altopt "COEF"
        }
        else    local is_logistic 0
        syntax [,                               ///
dec(int 3) fmt(str) drop(str) keep(str) ///
                Level(cilevel)                  ///
                noHeader                        ///
                noLegend                        ///
                Verbose                         ///
                TItle(passthru)                 ///
                notable                         /// not documented
                `regopts'                       /// _coef_table options
                SVY                             /// ignored
                noFOOTnote                      ///
                `altopt'                        ///
                `star'                          /// eform option
        ]

        if `is_sum' & "`e(novariance)'" != "" {
                exit
        }

        if "`first'" != "" & `"`showeqns'"' == "" {
                local neq 1
        }
        if `neq' > 0 {
                local neqopt neq(`neq')
        }
        else    local neq

        // verify only valid -eform- option specified
        _check_eformopt `e(cmd)', eformopts(`options') soptions

        // check for total number of equations
        local k_eq 0
        Chk4PosInt k_eq
        if `k_eq' == 0 {
                local k_eq : coleq e(b), quote
                local k_eq : list clean k_eq
                local k_eq : word count `k_eq'
        }
        // check for auxiliary parameters
        local k_aux 0
        Chk4PosInt k_aux
        // check for extra equations
        local k_extra 0
        Chk4PosInt k_extra

        local blank
        if "`header'" == "" {
                _coef_table_header
                if "`legend'" == "" {
                        if "`e(vce)'" != "" ///
                        & ("`e(cmd)'" != "`e(cmdname)'" | "`verbose'" != "") {
                                _prefix_legend `e(vce)', `verbose'
                                if "`e(vce)'" == "jackknife" ///
                                 & "`e(jkrweight)'" == "" ///
                                 & "`e(wtype)'" != "iweight" ///
                                 & ("`e(k_extra)'`verbose'" != "0" ///
                                 |  "`e(k_eexp)'" == "0") {
                                        _jk_nlegend `s(col1)' ///
                                                `"`e(nfunction)'"'
                                        local blank blank
                                }
                        }
                        if `is_sum' {
                                _svy_summarize_legend `blank'
                                local blank `s(blank)'
                        }
                }
        }

        // check to exit early
        if ("`table'" != "") exit

        if "`header'`blank'" == "" {
                di
        }

        // display the table of coefficients
        if inlist("`e(vce)'","jackknife","brr") {
                local nodiparm nodiparm
        }
        if `is_sum' {
                _sum_table, level(`level')
        }
        else {
                if `is_logistic' & "`coef'`options'" == "" {
                        local options or
                }
                _coef_table2, level(`level') `neqopt' `first' `plus' ///
                        `nodiparm' `showeqns' `options' ///
dec(`dec') fmt(`fmt') drop(`drop') keep(`keep')
        }
        if "`plus'`footnote'" == "" {
                _prefix_footnote
        }
end

program Chk4PosInt
        args ename
        if `"`e(`ename')'"' != "" {
                capture confirm integer number `e(`ename')'
                if !c(rc) {
                        if `e(`ename')' > 0 {
                                c_local `ename' `e(`ename')'
                        }
                }
        }
end





*! cloned 19apr2010 from _coef_table version 1.1.17  27feb2006
program _coef_table2
        version 8.2
        if "`e(cmd)'" == "" {
                error 301
        }
        syntax [,                               ///
dec(int 3) fmt(str) drop(str) keep(str) ///
                COEFTitle(string)               ///
                Level(cilevel)                  ///
                PLus                            ///
                NOFirst                         ///
                First                           ///
                SHOWEQns                        ///
                NEQ(integer -1)                 ///
                NODIPARM                        ///
                NOTEST                          ///
                SEParator(integer 0)            ///
                NOSKIP                          ///
                *                               /// -eform/diparm- opts
        ]
local bdec `dec'
local sdec `dec'
local cdec `dec'
local tdec `dec'
local pdec `dec'

local bfmt `fmt'
local sfmt `fmt'
local cfmt `fmt'
local tfmt `fmt'
local pfmt `fmt'

        if `: word count `first' `nofirst'' > 1 {
                di as err "options first and nofirst cannot be combined"
                exit 198
        }
        if `: word count `first' `showeqns'' > 1 {
                di as err "options first and showeqns cannot be combined"
                exit 198
        }
        if `"`showeqns'"' != "" {
                local nofirst nofirst
        }

        is_svysum `e(cmd)'
        local is_sum = r(is_svysum)

        // parse `options' for -eform()- and friends
        _get_eformopts , eformopts(`options') allowed(__all__) soptions
        local eform     `"`s(str)'"'
        local udiparm   `"`s(options)'"'
        local coeftitle = cond(`"`eform'"'==`""', `"`coeftitle'"', `"`eform'"')
        // `udiparm' should only contain -diparm()- options
        _get_diparmopts, diparmopts(`udiparm') level(`level')

        // ignore -diparm()- options; but checked for valid syntax anyway
        if "`nodiparm'" != "" {
                local udiparm
        }

        // get equation names for auxiliary parameters or extra equations
        local coleq : coleq e(b), quote
        local coleq : list uniq coleq

        Chk4Scalars k_eq k_aux k_eq_skip k_extra
        // check for total number of equations
        local k_eq 0
        Chk4PosInt k_eq
        if `k_eq' == 0 {
                local k_eq : list sizeof coleq
        }
        else if `k_eq' > `: list sizeof coleq' {
                di as err ///
"estimation command error: e(k_eq) is larger than the number of equations"
                exit 322
        }
        // check for auxiliary parameters
        local k_aux 0
        Chk4PosInt k_aux
        // check for equations to skip
        local k_eq_skip 0
        if "`noskip'" == "" {
                Chk4PosInt k_eq_skip
        }
        // check for extra equations
        local k_extra 0
        Chk4PosInt k_extra

        // check that the e(k_*) scalars add up correctly
        if `k_aux'`k_eq_skip'`k_extra' {
                if `:list sizeof coleq' != `k_eq' {
                        di as err ///
"estimation command error: e(k_eq) does not equal the number of equations"
                        exit 322
                }
        }

        // figure out how many equations -ereturn- is going to display
        if "`first'" != "" {
                local neq 1
        }
        if `neq' > 0 {
                // user only wants the `neq' equations
                local k_aux 0
                local k_eq_skip 0
                local k_extra 0
        }
        else if `neq' < 1 {
                // automatically determine neq
                local neq = `k_eq'-`k_aux'-`k_extra'-`k_eq_skip'
                if `neq' < 0 {
                        if `k_aux' {
                                local msg "e(k_aux)"
                                local plus " + "
                        }
                        if `k_eq_skip' {
                                local msg "`msg'`plus'e(k_eq_skip)"
                                local plus " + "
                        }
                        if `k_extra' {
                                local msg "`msg'`plus'e(k_extra)"
                                local plus " + "
                        }
                        di as err ///
"estimation command error: e(k_eq) is less than `msg'"
                        exit 322

                }
                if !`is_sum' & `neq' == 1 ///
                 & "`nofirst'" == "" & `k_extra' == 0 {
                        local first first
                }
        }

        local k_eform 0
        if `"`e(cmd)'"' == "mlogit" {
                local k_eform = `k_eq'-`k_extra'
        }
        else if `neq' {
                local k_eform 1
                Chk4NNInt k_eform
                if `k_eform' > `neq' {
                        local k_eform 1
                }
        }

        local copy `"`coleq'"'
        forval j = 1/`k_eform' {
                gettoken eq copy : copy, quotes
                local efcoleq `"`efcoleq' `eq'"'
        }
        forval j = `=`k_eform'+1'/`neq' {
                gettoken eq copy : copy, quotes
                local noefcoleq `"`noefcoleq' `eq'"'
        }

        // auxiliary parameters, and their transforms
        if `k_aux' {
                if "`notest'" != "" {
                        local prob noprob
                }
                local i1 = `neq' + `k_eq_skip' + 1
                local i2 = `neq' + `k_eq_skip' + `k_aux'
                local isep 0
                local COLON
                forval i = `i1'/`i2' {
                        if `isep' & mod(`isep',`separator') == 0 {
                                local COLON ":"
                                local diparm `"`diparm' `COLON' __sep__"'
                        }
                        local eq : word `i' of `coleq'
                        if `"`e(diparm_opt`i')'"' != "" {
                                local eq `"`eq', `prob' `e(diparm_opt`i')'"'
                        }
                        else if "`prob'" != "" {
                                local eq `"`eq', `prob'"'
                        }
                        local diparm `diparm' `COLON' `eq'
                        local ++isep
                        local COLON ":"
                }
                if `"`diparm'"' != "" {
                        local diparm diparm(`diparm')
                }
        }
        if "`nodiparm'" == "" & `"`e(diparm)'`e(diparm1)'`udiparm'"' != "" {
                GetEDiparm ediparm
                if `"`ediparm'"' != "" {
                        if `"`diparm'"' != "" {
                                local diparm `diparm' diparm(__sep__)
                        }
                        local diparm `diparm' `ediparm'
                }
                if `"`udiparm'"' != "" {
                        if `"`diparm'"' != "" {
                                local diparm `diparm' diparm(__sep__)
                        }
                        local diparm `"`diparm' `udiparm'"'
                }
        }
        // display extra equations
        if `k_extra' {
                local i1 = `neq' + `k_eq_skip' + `k_aux' + 1
                forval i = `i1'/`k_eq' {
                        local eq : word `i' of `coleq'
                        local extra `"`extra' "`eq'""'
                }
        }

        // display any constraints
        tempname cns error
        capture mat `cns' = get(Cns)
        if !c(rc) {
                matrix dispCns
        }

        local df_r .
        Chk4Int df_r

        local emats : e(matrices)
        if `:list posof "error" in emats' {
                matrix `error' = e(error)
                local erropt error(`error')
        }

        tempname z
        if missing(`df_r') {
                scalar `z' = invnorm((100+`level')/200)
        }
        else    scalar `z' = invttail(`df_r',(100-`level')/200)

        tempname Tab
        .`Tab' = ._tab.new, col(7) lmargin(0) ignore(.b)
        // column        1      2     3     4     5     6     7
        .`Tab'.width    13    |11    11     9     9    12    12
        .`Tab'.titlefmt  .   %11s  %12s   %7s     .  %24s     .
        .`Tab'.strfmt    .   %11s     .     .     .     .     .
        .`Tab'.pad       .      2     2     1     3     3     3
        .`Tab'.numfmt    .  %9.`bdec'`bfmt' %9.`sdec'`sfmt' %8.`tdec'`tfmt' %5.`pdec'`pfmt' %9.`cdec'`cfmt' %9.`cdec'`cfmt'
        .`Tab'.strcolor  . result    .     .     .     .     .
        // NOTE: Changing any of the above values should be reflected in
        // the ColumnTitles subroutine.  This may also affect
        // _coef_table_header.ado.

        if "`e(clustvar)'" != "" & !missing(e(N_clust)) {
                di as txt ///
"{ralign 78:(Std. Err. adjusted for {res:`e(N_clust)'} clusters in `e(clustvar)')}"
        }
        else if "`e(clustvar)'" != "" {
                di as txt ///
"{ralign 78:(Std. Err. adjusted for clustering on `e(clustvar)')}"
        }
        ColumnTitles `Tab' `level' `df_r' `"`coeftitle'"' `neq'

        if `"`efcoleq'"' != "" {
                DisplayEqns `efcoleq' :         ///
                        `Tab',  l(`level')      ///
                                df(`df_r')      ///
                                z(`z')          ///
                                ef(`eform')     ///
                                `first'         ///
                                `erropt'        ///
drop(`drop') keep(`keep') ///
                                // blank
        }
        if `"`noefcoleq'"' != "" {
                DisplayEqns `noefcoleq' : ///
                `Tab', l(`level') df(`df_r') z(`z') `erropt'
        }
        if `"`diparm'"' != "" {
                .`Tab'.sep
                _get_diparmopts, level(`level') diparmopts(`diparm') execute
        }
        if `"`extra'"' != "" {
                DisplayEqns `extra' : `Tab', l(`level') df(`df_r') z(`z')
        }
        if "`plus'" == "" {
                .`Tab'.sep, bottom
        }
        else    .`Tab'.sep

        if e(rc) == 504 & "`e(opt)'" == "ml" {
                di as err ///
"{p 0 0 2}variance matrix missing because `e(user)' failed" ///
"to compute scores or computed scores with missing values{p_end}"
                exit 504
        }
        if (!missing(e(rc)) & e(rc) != 0) error e(rc)
end

program ColumnTitles
        args Tab level df eform neq

        is_svysum `e(cmd)'
        local is_sum = r(is_svysum)

        local tsdvn 0           // number of depvar lines for time-series
                                // operators to display

        if `is_sum' {
                if "`e(over)'" != "" {
                        local depvar "Over"
                }
                local coef = proper("`e(cmd)'")
        }
        else {
                local coleq : coleq e(b)
                local dv `"`e(depvar)'"'
                local dv1 : word 1 of `dv'
                if `:word count `dv'' == 1 ///
                 & (`neq' <= 1 | !`:list dv in coleq') {
                        gettoken op vn : dv, parse(".")
                        if "`vn'" != "" & `:length local dv' > 12 {
                                local vn = substr("`vn'",2,.)
                                MLineTSop op_ depvar tsdvn : `op' `vn'
                        }
                        else    local depvar = abbrev("`dv'",12)
                }
                if "`eform'" != "" {
                        local coef "`eform'"
                }
                else    local coef "Coef."
        }
        if missing(`df') {
                local stat z
        }
        else    local stat t
        .`Tab'.sep, top
        if `"`e(vcetype)'"' != "" {
                local vcetype `"`e(vcetype)'"'
                if "`e(vcetype)'" == "Bootstrap" {
                        local obs "Observed"
                        local citype "Normal-based"
                }
                local ciwd : length local citype
                local vcewd : length local vcetype
                if `"`e(mse)'"' != "" {
                        capture which `e(vce)'_`e(mse)'.hlp
                        if !c(rc) {
                                local vcetype ///
                                "{help `e(vce)'_`e(mse)'##|_new:`vcetype'}"
                                local plus = `: length local vcetype' - `vcewd'
                                local plus "+`plus'"
                        }
                }
                if `vcewd' <= 12 {
                        // NOTE: see the width and pad definitions of .`Tab'
                        local vcewd = `vcewd'`plus' + ceil((12-`vcewd')/2+1)
                }
                if `ciwd' <= 27 {
                        // NOTE: see the width and pad definitions of .`Tab'
                        local ciwd = `ciwd' + ceil((27-`ciwd')/2)
                }
                // column        1       2             3   4  5          6  7
                .`Tab'.titlefmt  .       .     %`vcewd's   .  .   %`ciwd's  .
                .`Tab'.titles   "" "`obs'" `" `vcetype'"' "" "" "`citype'" ""
                .`Tab'.titlefmt  .       .          %12s   .  .       %24s  .
        }
        if `tsdvn' > 0 {
                .`Tab'.titlefmt  %-12s . . . . . .
                forval i = 1/`tsdvn' {
                        .`Tab'.titles "`op_`i''" "" "" "" "" "" ""
                }
                .`Tab'.titlefmt  %12s . . . . . .
        }
        .`Tab'.titles   "`depvar'"      /// 1
                        "`coef'"        /// 2
                        "Std. Err."     /// 3
                        "`stat'"        /// 4
                        "P>|`stat'|"                    /// 5
                        `"[`=strsubdp("`level'")'% Conf. Interval]"' "" //  6 7
end

program MLineTSop
        args c_op c_dv c_n COLON op vn

        local n 1

        // operator fits on a line by itself
        if `:length local op' < 12 {
                c_local `c_op'1 `"`op'."'
                local vn = abbrev(`"`vn'"',12)
                c_local `c_dv'  `"`vn'"'
                c_local `c_n'   `n'
                exit
        }

        c_local `c_op'`n' = substr(`"`op'"',1,12)
        local op = substr(`"`op'"',13,.)
        while `:length local op' >= 12 {
                local ++n
                c_local `c_op'`n' = substr(`"`op'"',1,12)
                local op = substr(`"`op'"',13,.)
        }
        if `"`op'"' == "" {
                local vn = abbrev(`"`vn'"', 12)
                c_local `c_dv' `"`vn'"'
        }
        else {
                local rest `"`op'.`vn'"'
                if `:length local rest' <= 12 {
                        c_local `c_dv' `"`rest'"'
                }
                else {
                        local ++n
                        c_local `c_op'`n' `"`op'."'
                        local vn = abbrev(`"`vn'"', 12)
                        c_local `c_dv' `"`vn'"'
                }
        }
        c_local `c_n' `n'
end

program DisplayEqns
        _on_colon_parse `0'
        local eqlist `"`s(before)'"'
        if (`: list sizeof eqlist' == 0) exit

        local 0 `s(after)'
        syntax name(name=Tab) [,        ///
drop(str) keep(str) ///
                First                   ///
                EForm(passthru)         ///
                ERRormat(name)          ///
                *                       ///
        ]

        local coleq : coleq e(b), quote
        local colna : colna e(b)
        local neq   : list sizeof coleq

if "`keep'"~="" {
	local keep `keep' _cons
	local missing: list colna - keep
	local colna: list keep - missing
	local neq: word count `colna'
}
if "`drop'"~="" {
	local colna: list colna - drop
	local neq: word count `colna'
}

        // index of first element
        local ucoleq : list uniq coleq
        gettoken word1 : eqlist
        local start : list posof `"`macval(word1)'"' in coleq

        // loop through the coefficients, displaying those that belong to the
        // specified equations

        local i `start'
        local oldeq // start fresh
        while `i' <= `neq' {
                local eq : word `i' of `coleq'
                local qeq `""`eq'""'
                // exit if the current equation is not in the list
                local break = (!`:list eq in eqlist' & !`:list qeq in eqlist')
                if (`break') continue, break
			
                local na : word `i' of `colna'
                local nna : word `=`i'+1' of `colna'

if `=_b[`na']'~=0 | `=_se[`na']'~=0 /*
	*/ & (index("`na'","o.")~=1 & index("`na'","0b.")~=1 & /*
	*/ index("`na'","1b.")~=1 & index("`na'","2b.")~=1 & index("`na'","3b.")~=1 & /*
	*/ index("`na'","4b.")~=1 & index("`na'","5b.")~=1 & index("`na'","6b.")~=1) {

                if `"`eq'"' != `"`oldeq'"' {

                        if "`offset'" != "" {
                                // display offset of previous equation
                                Offset `Tab' `"`offset'"' `"`offtyp'"'
                                local offset
                                local offtyp
                        }
                        .`Tab'.sep
                        if "`first'" == "" & `"`eq'"' != "_" {
                                local abeq = abbrev(`"`eq'"',12)
                                // columns           1   2  3  4  5  6  7
                                .`Tab'.strcolor result   .  .  .  .  .  .
                                .`Tab'.strfmt    %-12s   .  .  .  .  .  .
                                .`Tab'.row   `"`abeq'"' "" "" "" "" "" ""
                                .`Tab'.strcolor   text   .  .  .  .  .  .
                                .`Tab'.strfmt     %12s   .  .  .  .  .  .
                        }
                        local oldeq `"`eq'"'

                        // get offset of current equation
                        local ieq : list posof `"`eq'"' in ucoleq
                        _get_offopt `e(offset)'`e(offset`ieq')'
                        local offset `s(offvar)'
                        if "`s(offopt)'" == "offset(`offset')" {
                                local offtyp "(offset)"
                        }
                        else if "`s(offopt)'" != "" {
                                local offtyp "(exposure)"
                        }
                }
                if `"`eform'"' == "" | "`na'" != "_cons" {
                        gettoken op vn : na, parse(".")
                        gettoken nop nvn : nna, parse(".")
                        if "`nvn'" == ".`na'" | ".`oldvn'" == ".`na'" {
                                local nulltsop nulltsop
                                local vn ".`na'"
                        }
                        else    local nulltsop
                        if "`vn'" != "" & ".`oldvn'" != "`vn'" {
                                local vn = abbrev(substr("`vn'",2,.),12)
                                // columns           1  2  3  4  5  6  7
                                .`Tab'.row    `"`vn'"' "" "" "" "" "" ""
                                local oldvn `vn'
                        }
                        else if "`vn'" == "" {
                                local oldvn
                        }
                        if "`errormat'" != "" {
                                local erropt error(`=`errormat'[1,`i']')
                        }
                        Row `Tab' `"`qeq'"' "`na'", ///
                                `options' `eform' `erropt' `nulltsop'
                }
} /* if `=[`eq']_b[`na']'~=0 & `=[`eq']_se[`na']'~=0 */
                local ++i
        }
        if "`offset'" != "" {
                // display offset of last displayed equation
                Offset `Tab' `"`offset'"' `"`offtyp'"'
                local offset
                local offtyp
        }
end

program Offset
        args Tab offset offtyp
        local offset = abbrev("`offset'", 12)
        .`Tab'.strcolor           .         text   .  .  .  .  .
        .`Tab'.row      `"`offset'"' `"`offtyp'"' "" "" "" "" ""
        .`Tab'.strcolor           .       result   .  .  .  .  .
end

program Row
        syntax anything [,                      ///
                Level(cilevel)                  ///
                EForm(passthru)                 ///
                ERRor(integer 0)                ///
                df(real 0)                      ///
                z(name)                         ///
                NULLTSOP                        ///
        ]
        local 0 `anything'
        args Tab eq na
        local eq : list clean eq
        tempname b se t p ll ul
        if `"`eq'"' != "_" {
                scalar `b'  = [`eq']_b[`na']
                scalar `se' = [`eq']_se[`na']
        }
        else {
                scalar `b'  = _b[`na']
                scalar `se' = _se[`na']
        }
        if `se' == 0 & `"`e(census)'"' == "1" {
                scalar `t' = .
                scalar `p' = .
                scalar `ll' = .
                scalar `ul' = .
        }
        else {
                if `se' == 0 {
                        scalar `se' = .
                }
                scalar `t' = `b'/`se'
                if missing(`df') {
                        scalar `p' = 2*norm(-abs(`t'))
                }
                else    scalar `p' = 2*ttail(`df',abs(`t'))
                scalar `ll' = `b' - `se'*`z'
                scalar `ul' = `b' + `se'*`z'
                if "`eform'" != "" {
                        scalar `b'  = exp(`b')
                        scalar `se' = `b'*`se'
                        scalar `ll' = exp(`ll')
                        scalar `ul' = exp(`ul')
                }
        }

        if "`nulltsop'" != "" {
                local na "--.`na'"
        }
        gettoken op vn : na, parse(".")
        if "`vn'" != "" {
                if `:length local op' == 1 {
                        local op `op'1
                }
                local na `"`op'."'
                while `:length local na' > 12 {
                        .`Tab'.strfmt %11s . . . . . .
                        local n1 = substr("`na'",1,10)
                        .`Tab'.row "`n1'" "" "" "" "" "" ""
                        local na = substr("`na'",11,.)
                }
                .`Tab'.strfmt %12s . . . . . .
        }
        else    local na = abbrev("`na'",12)

        local error1 "  (no observations)"
        local error2 "  (stratum with 1 PSU detected)"
        local error3 "  (sum of weights equals zero)"
        local error4 "  (denominator estimate equals zero)"
        local error5 "  (dropped)"

        if `error' {
                .`Tab'.row "`na'" "`error`error''" "" "" "" "" ""
        }
        else if `b'== 0 & `se' >= . {
                .`Tab'.row "`na'" "`error5'" "" "" "" "" ""
        }
        else {
                .`Tab'.row "`na'" `b' `se' `t' `p' `ll' `ul'
        }
end

program GetEDiparm
        args c_diparm
        if `"`e(diparm)'`e(diparm1)'"' != "" {
                if `"`e(diparm)'"' != "" {
                        local i 0
                        local ediparmi `"`e(diparm)'"'
                }
                else if `"`e(diparm1)'"' != "" {
                        local i 1
                        local ediparmi `"`e(diparm1)'"'
                }
        }
        while `"`ediparmi'"' != "" {
                local diparm `diparm' diparm(`ediparmi')
                local ++i
                local ediparmi `"`e(diparm`i')'"'
        }
        c_local `c_diparm' `diparm'
end

program Chk4Scalars
        syntax namelist
        local nonscalars `: r(macros)' `: r(matrices)'
        local badmac : list nonscalars & namelist
        if "`badmac'" != "" {
                gettoken name : badmac
                di as err "type mismatch: e(`name') is not a scalar"
                exit 109
        }
end

/*
program Chk4PosInt
        args ename
        if `"`e(`ename')'"' != "" {
                capture confirm integer number `e(`ename')'
                if !c(rc) {
                        if `e(`ename')' > 0 {
                                c_local `ename' `e(`ename')'
                        }
                }
        }
end
*/

program Chk4NNInt
        args ename
        if `"`e(`ename')'"' != "" {
                capture confirm integer number `e(`ename')'
                if !c(rc) {
                        if `e(`ename')' >= 0 {
                                c_local `ename' `e(`ename')'
                        }
                }
        }
end

program Chk4Int
        args ename
        if `"`e(`ename')'"' != "" {
                capture confirm integer number `e(`ename')'
                if !c(rc) {
                        c_local `ename' `e(`ename')'
                }
        }
end


/*
NOTES:

-_coef_table- looks at the following scalars to determine which equations are
put in the table of results, and how they are put there:

        e(k_eq)         -- total number of equations, missing value implies 1
        e(k_aux)        -- number of ancillary parameters (each an equation)
        e(k_extra)      -- extra equations
        e(k_eform)      -- the first `e(k_eform)' equations' coefficients will
                           be exponentiated when an 'eform' type option is
                           specified; default is 1

*/


prog define _explicit
	cap syntax varlist(default=none ts fv)
	if _rc~=0 {
		* yes I know this is a workaround
		syntax varlist(default=none ts)
	}
	else {
		syntax varlist(default=none ts fv)
		_rmcoll `varlist'
	}
	c_local _varlist `varlist'
end

exit















