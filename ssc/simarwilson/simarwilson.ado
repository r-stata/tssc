********************************************************************************************************************************
** SIMAR & WILSON (2007) TWO-STAGE EFFICIENCY ANALYSIS *************************************************************************
********************************************************************************************************************************
*! version 2.20 2018-11-06 ht
*! version 2.19 2018-04-20 ht
*! version 2.18 2018-04-07 ht
*! version 2.17 2018-03-24 ht
*! version 2.16 2018-03-13 ht
*! version 2.15 2018-01-05 ht
*! version 2.14 2017-11-27 ht
*! version 2.13 2017-09-19 ht
*! version 2.12 2017-09-15 ht
*! version 2.11 2017-09-07 ht
*! version 2.10 2017-08-06 ht
*! version 2.9 2017-07-22 ht
*! version 2.8 2017-06-30 ht
*! version 2.7 2017-06-19 ht
*! version 2.6 2017-06-14 ht
*! version 2.5 2017-06-08 ht
*! version 2.4 2017-06-01 ht
*! version 2.3 2017-04-13 ht
*! version 2.2 2017-01-17 ht
*! authors Harald Tauchmann & Oleg Badunenko
*! Simar & Wilson two-stage Efficiency Analysis

capture program drop simarwilson
program simarwilson, eclass
** CHECK VERSION (For Handling Unicode Variables) **
if `c(stata_version)' < 14.2 {
    local str "str"
    local substr "substr"
    local ustr ""
    local subinstr "subinstr"
    version 12
}
else {
    local str "ustr"
    local substr "usubstr"
    local ustr "ustr"
    local subinstr "usubinstr"
    version 14.2
}
if !replay() {
		quietly {
            ** SET DEFAULTS FOR # OF REPETITIONS **
            local defaultbcreps = 100
            local defaultreps = 1000
            ** STORE COMMANDLINE ENTRY **
			local cmd "simarwilson"
			local cmdline "`cmd' `*'"
            ** SYNTAX DEFINITION **
            syntax anything(equalok) [if] [in] [pweight iweight], /*
            */ [REPS(integer `defaultreps')] [noUNIT] [noTWOsided] [LEVel(real `c(level)')] [DOTs] [SAVEAll(name)] [CINormal] [BBOOTstrap] [noCONStant] [noRTNorm] [OFFset(varname)] [DIFficult] [COLlinear] [CONSTraints(passthru)] [TECHnique(passthru)] [ITERate(passthru)] [TOLerance(passthru)] [LTOLerance(passthru)] [NRTOLerance(passthru)] [NONRTOLerance(passthru)] [FROM(passthru)] [CFORMAT(string asis)] [PFORMAT(string asis)] [SFORMAT(string asis)] [VSQUISH] [noOMITted] [BASELevels] [TRNoisily]/*
            */ [ALGorithm(integer 1)] [INVert] [LOGscore] [noPRInt] [noDEAPrint] [Rts(string)] [Base(string)] [BCReps(integer `defaultbcreps')] [REFerence(name)] [TEname(name)] [TEBC(name)] [BIASte(name)] [BCSAVEAll(name)] [EXTOLerance(real 37.5)]
            ** TEMPORARY FILES, MATRICES, and VARIABLES **
            ** TEMPVARS **
			tempvar __tempid __tempwgh __rnn __yoff __iyy __truncfit __ntruncfit __yboot __esamp __deascore __indepnomis __deamark __reference __creference
            ** TEMPNAMES **
			tempname __borg __coef __sig __cov __bbm __bbias __rank  __Cns __BB __VB __BM __cip __ndeao __nmdeao __ndearefo __cnps
            ** TEMPNAMES FOR PLUGIN **
            tempname __yobs __xobs __nO __nI __nobs __yref __xref __nref __rt __ba __ifqh __intovar __teB __MatStar __ystar __xstar __DEAB __DEABC __DEABIAS
            ** TEMPFILES **
			tempfile __resufile
            ** HANDLE MORE **
            local moreold `c(more)'
            set more off
            ** DISPLAY-FORMAT for WARNINGS **
    		local ls   = c(linesize)-7
    		local lshl = c(linesize)-7-3
            ** PARSEING ANYTHING **
            gettoken deasyntax varlist : anything, parse(")") match(paren) bind
            if "`paren'" == "" {
                local varlist "`deasyntax'"
                local deasyntax ""
            }
            else {
                gettoken left right : deasyntax, parse("(")
                if "`right'" != "" {
                    display as error "{p 0 2 2 `ls'}invalid syntax{p_end}"
    				exit 198
                }
            }
            ** CHECK VARLIST FOR MISPLACED CHACRACTERS **
            local mpcv = 0
            foreach cc in = "[" "]" "!" "+" "\" "&" "%" "}" "{" {
                local mpc = `str'pos("`varlist'","`cc'")
                local mpcv = `mpcv' + `mpc'
            }
            if `mpcv' > 0 {
				display as error "{p 0 2 2 `ls'}invalid syntax or invalid names in {bf:`varlist'}{p_end}"
                exit 198
            }
            ** CHECK FOR EMPTY VARLIST **
            if "`varlist'" == "" {
                local vlempty = 1
                if "`constant'" == "noconstant" {
    				display as error "{p 0 2 2 `ls'}neither indepvars nor constant specified{p_end}"
                    exit 198
                }
            }
            if "`deasyntax'" == "" & wordcount("`varlist'") == 1 & "`constant'" == "noconstant" {
    				display as error "{p 0 2 2 `ls'}neither indepvars. nor constant specified{p_end}"
                    exit 198
            }
            ** PARSE DEA-SYNTAX **
            local deasyntax : list retokenize local(deasyntax)
            if "`deasyntax'" != "" & "`deasyntax'" != " " {
                gettoken oispec refspec : deasyntax, parse("(") match(paren) bind
                if "`oispec'" == "" & "`refspec'" != "" {
                    local oispec "`refspec'"
                    local refspec ""
                }
                if "`refspec'" != "" {
                    display as error "{p 0 2 2 `ls'}option (ref_outputs = ref_inputs) not allowed; `refspec' ignored{p_end}"
                }
                gettoken outps inps : oispec, parse("=")
                gettoken left inps : inps, parse("=")
                local outps : list uniq local(outps)
                local inps : list uniq local(inps)
            	local nO  = `ustr'wordcount("`outps'")
            	local nI  = `ustr'wordcount("`inps'")
                ** CHECK FOR OUTPUTS AND INPUTS BEEING MUTUALLY EXCLUSUVE **
                local oiintersec : list local(outps) & local(inps)
                if "`oiintersec'" != "" {
                    display as error "{p 0 2 2 `ls'}lists of outputs and inputs must be mutually exclusive{p_end}"
                    exit 198
                }
                ** CHECK FOR OUTPUT- AND INPUT-VARIABLES BEEING DEFINED AND NUMERIC OR SYNTAX BEING INVALID **
                cap confirm numeric variable `outps' `inps'
                if _rc != 0 {
                    display as error "{p 0 2 2 `ls'}invalid syntax or not defined or non-numeric variable(s) in {bf:(`oispec')}{p_end}"
                    exit _rc
                }
                ** CHECK FOR EMPTY INPUT- OR OUTPUT-LIST **
                if `nO' <= 0 | `nI' <= 0 {
    				display as error "{p 0 2 2 `ls'}at least one input and one output required{p_end}"
                    exit 198
                }
            }
            ** HANDLE OPT. ALGORITHM **
            if `algorithm' != 1 & `algorithm' != 2 {
				display as error "{p 0 2 2 `ls'}invalid value for option alg() specified; only 1 or 2 is allowed{p_end}"
				exit 198					
            }
            if `algorithm' == 2 & "`deasyntax'" == "" {
				display as error "{p 0 2 2 `ls'}algorithm #2 requires (outputs = inputs){p_end}"
				exit 198					
            }
            if `algorithm' == 1 {
                local alg2opt ""
                if `bcreps' != 100 {
                    local alg2opt "`alg2opt' bcreps(`bcreps')"
                }
                if "`tebc'" != "" {
                    local alg2opt "`alg2opt' tebc(`tebc')"
                }
                if "`biaste'" != "" {
                    local alg2opt "`alg2opt' biaste(`biaste')"
                }
                if "`bcsaveall'" != "" {
                    local alg2opt "`alg2opt' bcsaveall(`bcsaveall')"
                }
                if "`alg2opt'" != "" & "`print'" != "noprint" {
				    display as error "{p 0 2 2 `ls'}warning: no bias-correction with alg. #1;`alg2opt' ignored{p_end}"	
                }				
            }
            ** HANDLE VARIABLES TO GENERATE **
            if "`tename'" != "" & "`deasyntax'" != "" {
                confirm new variable `tename'
            }
            if "`tebc'" != "" & "`deasyntax'" != "" & "`algorithm'" == "2" {
                confirm new variable `tebc'
            }
            if "`biaste'" != "" & "`deasyntax'" != "" & "`algorithm'" == "2" {
                confirm new variable `biaste'
            }
            ** HANDLE TERADIAL OPTIONS IF NOT USED **
            if "`deasyntax'" == "" {
                local deaopt ""
                if "`rts'" != "" {
                    local deaopt "`deaopt' rts(`rts')"
                }
                if "`base'" != "" {
                    local deaopt "`deaopt' base(`base')"
                }
                if "`reference'" != "" {
                    local deaopt "`deaopt' reference(`reference')"
                }
                if "`tename'" != "" {
                    local deaopt "`deaopt' tename(`tename')"
                }
                if "`deaopt'" != "" & "`print'" != "noprint" {
                    display as error "{p 0 2 2 `ls'}warning: external dea scores used;`deaopt' ignored{p_end}"
                }
            }
            ** HANDLE TERADIAL OPTIONS **
            if "`deasyntax'" != "" {
                if "`rts'" == "" {
                    local rts "CRS"
                }
                if upper(substr("`rts'",1,1)) == "C" {
                    local rts "CRS"
                }
                if upper(substr("`rts'",1,1)) == "N" {
                    local rts "NIRS"
                }
                if upper(substr("`rts'",1,1)) == "V" {
                    local rts "VRS"
                }
                if "`base'" == "" {
                    local base "output"
                }
                if upper(substr("`base'",1,1)) == "O" {
                    local base "output"
                }
                if upper(substr("`base'",1,1)) == "I" {
                    local base "input"
                }
                if "`base'" == "output" {
                    if "`invert'" == "" {
                        local unit "nounit"
                    }
                    else {
                        local unit ""
                    }
                }
                if "`base'" == "input" {
                    if "`invert'" == "" {
                        local unit ""
                    }
                    else {
                        local unit "nounit"
                    }
                }
    			if `bcreps' < 1 {
    				display as error "{p 0 2 2 `ls'}bcreps(`bcreps') too small for bias correction{p_end}"
                    exit 498
    			}
    			if `bcreps' < 100 & "`print'" != "noprint" & "`algorithm'" == "2" {
    				display as error "{p 0 2 2 `ls'}warning: bcreps(`bcreps') too small for meaningful bias correction{p_end}"
    			}
            }
            ** HANDLE OPTION INVERT **
            if "`deasyntax'" != "" {
                if "`invert'" == "" {
                    local expinvert = 1
                    local printinvert "Farrell "
                }
                else {
                    local expinvert = -1
                    local printinvert "Shephard "
                }
            }
            else {
                if "`invert'" != "" & "`print'" != "noprint" {
                    display as error "{p 0 2 2 `ls'}warning: opt. invert has no effect with externally estimated scores; invert left-hand-side variable manually to switch from Farrell to Shephard efficiency{p_end}"
                }
            }
            ** HANDLE OPTION TRNOISILY **
            if "`trnoisily'" != "" {
                local trn "noisily"
            }
			** DE-FACTOR-VARIABLERIZE VARLIST **
            if "`vlempty'" != "1" {
                local varlist : list uniq local(varlist)
                defvar `varlist'
                local varlist2 "`r(dfvl)'"
            }
            ** CHECK FOR NON-NUMERIC VARIABLES *
            cap confirm numeric variable `varlist2'
            if _rc != 0 & "`varlist2'" != "" {
                display as error "{p 0 2 2 `ls'}non-numeric variable(s) in varlist {bf:`varlist2'}{p_end}"
                exit _rc
            }
            ** HANDLE OPTION TENAME **
            if "`tename'" != "" {
                  local savete "`tename'"
            }
            ** HANDLE OPTION LOGSCORE **
            if "`logscore'" != "logscore" {
                local trlim = 1
                local trlefte ""
            }
            else {
                local trlim = 0
                local trlefte "exp"
            }
			** HANDLE OPTION NOTWOSIDED **
            if ("`twosided'" == "notwosided") & (`algorithm' == 2) & ("`unit'" == "") & ("`print'" != "noprint") {
                display as error "{p 0 2 2 `ls'}warning: opt. notwosided not recommendable with alg. #2; in step 3.1 (alg. #2) sampling is from the twosided-truncated normal distribution{p_end}"
            }
            ** CHECK FOR EXCESSIVE NUMBER OF INPUTS AND OUTPUTS **
            if "`deasyntax'" != "" {
                mark `__deamark'
                markout `__deamark' `outps' `inps' `varlist2' `offset'
                if "`if'" == "" {
                    local iffill "if"
                }
                else {
                    local iffill "`if' &"
                }
                count `in' `iffill' `__deamark'==1
                if `nO' + `nI' >= r(N) {
                    noi display as error  "{p 0 2 2 `ls'}number of DMUs (`r(N)') must be larger than sum of number of outputs (`nO') and inputs (`nI'){p_end}"
                    exit 409
                }
            }
            ** HANDLE OPTION REFERENCE **
            if "`deasyntax'" == "" {
                gen `__reference' = 1
            }
            else {
                if "`reference'" == "" {
                    gen `__reference' = 1
                }
                else {
                    cap egen `__creference' = group(`reference')
                    if _rc == 111 {
                        display as error "{p 0 2 2 `ls'}invalid reference spec.; {bf:`reference'} not found{p_end}"
                        exit 111
                    }
                    replace `__creference' = `__creference' -1
                    cap tab `__creference'
                    if r(r) > 2 | _rc == 134 {
                        display as error "{p 0 2 2 `ls'}invalid reference spec.; {bf:`reference'} not binary{p_end}"
                        exit 198
                    }
                    if r(r) < 2 {
                        display as error "{p 0 2 2 `ls'}no variation in {bf:`reference'}; opt. reference ignored{p_end}"
                        gen `__reference' = 1
                    }
                    else {
                        ** CHECK WETHER REFERENCE SET INCLUDES DMUs EXLUDED by IF or IN **
                        count `in' `iffill' (`__creference' == 1 & `__deamark'==1)
                        local nrefs = r(N)
                        count `in' `iffill' (`__creference' == 0 & `__deamark'==1)
                        local nrefs0 = r(N)
                        count if (`__creference' == 1 & `__deamark'==1)
                        local nrefa = r(N)
                        if `nrefa' > `nrefs' & "`print'" != "noprint" {
                            display as error "{p 0 2 2 `ls'}warning: simarwilson does not allow for ref. DMUs that are not included in the estimation sample{p_end}"
                        }
                        if `nrefs' == 0 & `nrefs0' > 0 {
                            display as error "{p 0 2 2 `ls'}reference set empty; opt. reference ignored{p_end}"
                            gen `__reference' = 1
                        }
                        else {
                            if `nrefs' <= (`nO' + `nI') {
                                display as error "{p 0 2 2 `ls'}number of reference DMUs (`nrefs') must be larger than sum of number of outputs (`nO') and inputs(`nI'); opt. reference ignored{p_end}"
                                gen `__reference' = 1
                            }
                            else {
                                gen `__reference' = `__creference'
                            }
                        }
                    }
                }
            }
			** HANDLE LEVEL **
			if `level' >= 10 & `level' <= 99.99 {
                local level = round(`level',0.01)
                local level = substr("`level'",1,5)
			}
			else {
                if "`print'" != "noprint" {
                    noisily display as error "{p 0 2 2 `ls'}warning: level(`level') not allowed, outside [10,99.99] interval{p_end}"
                }
				local level = `c(level)'			
			}
            ** CHECK NUMBER of REPS **
            if `reps' < 2 {
                display as error "{p 0 2 2 `ls'}reps(`reps') too small for computing standard errors{p_end}"
				exit 498
            }
			if ("`cinormal'" != "cinormal" & `reps' < `defaultreps') & "`print'" != "noprint" {
				display as error "{p 0 2 2 `ls'}warning: reps(`reps') too small for meaningful percentile CIs{p_end}"
			}
			** HANDLE WEIGHT **
			if "`weight'" != "" {
				gen double `__tempwgh' `exp'
				local weight2 = substr("`weight'",1,2)
			}
			else {
				gen `__tempwgh' = 1
				local weight2 "pw"
			}
			local exp2 "`__tempwgh'"
			** HANDLE TRUNCREG OPTIONS **
			local opttrunc "`constraints' `collinear' `noomitted' `difficult' `technique' `tolerance' `ltolerance' `ntolerance' `nonrtolerance' `from'"
            local itetrunc "`iterate'"
			** TOKENIZE VARLIST **
            if "`deasyntax'" == "" {
    			tokenize `varlist'
    			local yy "`1'"
    			local xx : list local(varlist) - local(yy)
            }
			** HANDLE DEPENDENT VARIABLE **
            if "`deasyntax'" == "" {
    			foreach fo in "##" "#" "." {
    				local check = `str'pos("`yy'","`fo'")
    				if `check' != 0 {
    					if "`fo'" == "##" | "`fo'" == "#" {
    						display as error "{p 0 2 2 `ls'}depvar may not be an interaction{p_end}"
    						exit 198					
    					}
    					else {
    						display as error "{p 0 2 2 `ls'}depvar may not be a factor variable{p_end}"
    						exit 198										
    					}
    				}
    			}
            }
			** HANDLE OFFSET VARIABLE **
			foreach fo in "##" "#" "." {
				local check = `str'pos("`offset'","`fo'")
				if `check' != 0 {
					if "`fo'" == "##" | "`fo'" == "#" {
						display as error "{p 0 2 2 `ls'}interactions not allowed in option offset(){p_end}"
						exit 101					
					}
					else {
						display as error "{p 0 2 2 `ls'}factor variable not allowed in option offset(){p_end}"
						exit 101										
					}
				}
			}
			** DE-FACTOR-VARIABLERIZE VARLIST **
            if "`vlempty'" != "1" {
                defvar `varlist'
                local varlist2 "`r(dfvl)'"
            }
			** SELECT ESTIMATION SAMPLE **
			gen `__tempid' = _n
			preserve
			if "`if'" != "" {
				keep `if'
			}
			if "`in'" != "" {
				keep `in'
			}
			keep `__tempid' `__tempwgh' `varlist2' `offset' `outps' `inps' `__reference'
			** DROP MISSINGS **
            cap drop `__deamark'
            mark `__deamark'
            markout `__deamark' `outps' `inps' `varlist2' `offset' `__reference'
            keep if `__deamark' == 1
            sort `__reference' `__tempid'
            ** EXECUTE TERADIAL to OBTAIN UN-CORRECTED DEA-SCORES **
            if "`deasyntax'" != "" {
                teradial `outps' = `inps', rts(`rts') base(`base') tename(`__deascore') reference(`__reference')
                mata : st_numscalar("`__nmdeao'", colmissing(st_data(.,"`__deascore'")))
                mata : st_numscalar("`__ndeao'", colnonmissing(st_data(.,"`__deascore'")))
                if `__ndeao' <= 0 {
                    di as error "{p 0 2 2 `ls'}data envelopment analysis failed{p_end}"
                    restore
                    exit 498
                }
                if `__nmdeao' > 0 & "`print'" != "noprint" {
                    local mnmdeao = `__nmdeao'
                    di as error "{p 0 2 2 `ls'}warning: estimation of scores failed for `mnmdeao' DMUs{p_end}"
                }
                mata : st_numscalar("`__ndearefo'", colnonmissing((st_data(.,"`__deascore'"):/(st_data(.,"`__reference'")))))
                replace `__deascore' = (`__deascore')^(`expinvert')
                keep if `__deascore' <.
                if "`savete'" != "" {
                    ** SAVE DEA SCORE PERMANANTELY **
                    gen double `savete' = `__deascore'
                    label variable `savete' "`printinvert'`base'-oriented efficiency score under `rts'"
                }
                ** FEED-IN DEA-SCORES **
                local yy "`__deascore'"
                local varlist : list local(__deascore) | local(varlist)
                local xx : list local(varlist) - local(yy)
            }
			** CHECK DEPENDENT VARIABLE **
            if "`deasyntax'" == "" & "`print'" != "noprint" {
                count if `yy' == 100
                local ny100 = r(N)
                count if `yy' > 25 & `yy' <= 100
                local sylarge = r(N)
                count if `yy' <.
                local sylarge = floor(100*`sylarge'/r(N))
            }
			sum `yy' if `yy' <.
			if r(min)<= 0 {
                if "`deasyntax'" == "" {
				    display as error "{p 0 2 2 `ls'}nonpositive efficiency scores in {bf:`yy'}{p_end}"
                }
                else if "`savete'" != "" {
                    display as error "{p 0 2 2 `ls'}nonpositive efficiency scores in {bf:`savete'}{p_end}"
                }
                else {
                    display as error "{p 0 2 2 `ls'}nonpositive efficiency scores found{p_end}"
                }
				restore
				exit 482
			}
            if "`deasyntax'" == "" & "`print'" != "noprint" {
                if (r(min) > 0 & r(max) == 100 | `ny100' > 0 | `sylarge' > 50) {
                    display as error "{p 0 2 2 `ls'}warning: for `ny100' obs {bf:`yy'} = 100, for `sylarge'% of obs {bf:`yy'} > 25; check whether efficiency is inappropriately measured in percent; if so rescale var. {bf:`yy'}{p_end}"
                }
            }
			if r(min) < 1 & r(max) > 1 {
				if "`unit'" == "" & "`print'" != "noprint" {
                    if "`deasyntax'" == "" {
					   display as error "{p 0 2 2 `ls'}warning: values of {bf:`yy'} not bounded to unit interval{p_end}"
                    }
                    else if "`savete'" != "" {
                        display as error "{p 0 2 2 `ls'}warning: values of {bf:`savete'} not bounded to unit interval{p_end}"
                    }
                    else {
					   display as error "{p 0 2 2 `ls'}warning: efficiency scores not bounded to unit interval{p_end}"
                    }
				}
				if "`unit'" == "nounit" & "`print'" != "noprint" {
                    if "`deasyntax'" == "" {
    					display as error "{p 0 2 2 `ls'}warning: values of {bf:`yy'} not bounded to [1,+inf) interval{p_end}"
                    }
                    else if "`savete'" != "" {
                        display as error "{p 0 2 2 `ls'}warning: values of {bf:`savete'} not bounded to [1,+inf) interval{p_end}"
                    }
                    else {
                        display as error "{p 0 2 2 `ls'}warning: efficiency scores not bounded to [1,+inf) interval{p_end}"
                    }
				}
			}
			if r(min) >= 0 & r(max) <= 1 & "`unit'" == "nounit" {
				local unit ""
			}
			if (r(min) >= 1 & "`unit'" == "") {
				local unit "nounit"
			}
            ** TAKE LOG IF OPTION LOGSCORE **
            if "`logscore'" == "logscore" {
                replace `yy' = log(`yy')
            }
			** RUN PRECEDING OLS REGRESSION **
			if "`offset'" != "" {
				gen double `__yoff' = `yy' - `offset'
			}
			else {
				gen double `__yoff' = `yy'
			}
			cap reg `__yoff' `xx' [`weight2' = `exp2']
            ** DETERMINE SAMPLESIZE **
            sum `exp2' if e(sample)
            local wsall = r(sum)
            local nnall = r(N)
            sum `exp2' if e(sample) & `yy' == `trlim'
            local wslim = r(sum)
            local nnlim = r(N)
			if "`unit'" == "nounit" {	
                sum `exp2' if e(sample) & `yy' < `trlim'
                local wsirreg = r(sum)
                local nnirreg = r(N)
            }
            else {	
                sum `exp2' if e(sample) & `yy' > `trlim' & `yy' <.
                local wsirreg = r(sum)
                local nnirreg = r(N)
            }
			** RUN INITIAL TRUNCATED REGRESSION **
			if "`unit'" == "" {
                if ("`twosided'" == "notwosided") | ("`logscore'" == "logscore") {				
    			    cap `trn' truncreg `yy' `xx' [`weight2' = `exp2'], ul(`trlim') `constant' offset(`offset') `opttrunc' `itetrunc'
                }
                else {
                    cap `trn' truncreg `yy' `xx' [`weight2' = `exp2'], ll(0) ul(1) `constant' offset(`offset') `opttrunc' `itetrunc'
                }
			}
			else {				
				cap `trn' truncreg `yy' `xx' [`weight2' = `exp2'], ll(`trlim') `constant' offset(`offset') `opttrunc' `itetrunc'
			}
			if _rc != 0 | e(converged) != 1 {
                if e(converged) != 1 {
				    display as error "{p 0 2 2 `ls'}convergence not achieved in truncated regression{p_end}"
                }
                else {
                    display as error "{p 0 2 2 `ls'}truncated regression failed{p_end}"
                }
				ereturn clear
				restore
                if _rc != 0 {
                    exit _rc
                }
                else {
				    exit 430
                }
			}
            gen `__esamp' = 1 if e(sample)
			local sig = e(sigma)
			predict `__truncfit', xb
			gen double `__ntruncfit' = `trlim'-`__truncfit'
			matrix `__borg' = e(b)
            ** RECALCULATE SAMPLESIZE **
			sum `exp2' if e(sample)
            local wgtsum = r(sum)
			local tsamps = r(N)
            ** CHECK FOR EXTREMEY LARGE VALUES OF PREDICTED EFFICIENCY VALUES **
            if `algorithm' == 1 {
                local nolimdmu "& `yy' != `trlim'"
            }
            if "`unit'" != "nounit" & ("`twosided'" != "notwosided" | `algorithm' ==2) & "`logscore'" != "logscore" {
                count if max(abs(`__ntruncfit'),abs(`__ntruncfit'-1)) >= `extolerance'*`sig' & `__ntruncfit' <. `nolimdmu'
                local diextval "max(abs((1-xb)/sigma),abs((-xb)/sigma))"
            }
            else {
                count if abs(`__ntruncfit') >= `extolerance'*`sig' & `__ntruncfit' <. `nolimdmu'
                local diextval "abs((`trlim'-xb)/sigma)"
            }
            if r(N) > 0 {
				display as error "{p 0 2 2 `ls'}extreme values for fitted efficiency encountered: `diextval' > `extolerance' for at least one DMU; bootstrap likely to fail; consider changing specification and check for possible outlier(s){p_end}"
				ereturn clear
				restore
				exit 498
            }
			** EXTRACT "EX-POST" VARLIST **
			local cn : colnames e(b)
            local xx2 : subinstr local cn "_cons" "", all word
            local xx2 : list retokenize xx2
            if "`algorithm'" == "1" {
    			** TRANSFER RESULTS **
                local ic = e(ic)
                local k_eq = e(k_eq)
                local converged = e(converged)
                local rc = e(rc)
    			local ll = e(ll)
                local df_m = e(df_m)
                local k_aux = e(k_aux)
                ** CHECK for CONSTRAINTS **
                if "`e(Cns)'" != "" {
                    matrix `__Cns' = e(Cns)
                    local iconstr "iconstr"
                }
            }
			** RUN SIMAR & WILSON BOOTSTRAPP **
            local floop = 3-`algorithm'
            ** EXECUTE LOOP DEPENDING ON CHOICE of ALGORITHM ONE or TWO TIMES **
            forvalues loop = `floop'/2 {
                if `loop' == 2 {
                    ** PREVENT EXCESSIVE # of ITERATIONS in BOOTSTRAP
                    local ic2 = max(3*`ic',25)
                    if "`itetrunc'" == "" {
                        local itetrunc "iterate(`ic2')"
                    }
                    else {
                        local striter "`itetrunc'"
                        local striter = regexr("`striter'","iterate","")
                        local striter = `striter'
                        if `striter' > `ic2' {
                            local itetrunc "iterate(`ic2')"
                        }
                    }
                }
                ** ACCOUNT FOR DIFFERENT NUMB. OF REPS. **
                if `loop' == 1 {
                    local repsloop = `bcreps'
                    local loopmark " (bias correction)"
                }
                else {
                    local repsloop = `reps'
                    if `algorithm' == 2 {
                        local loopmark " (conf. intervals)"
                    }
                    else {
                        local loopmark ""
                    }
                }
                ** DISPLAY ITERATION HEADER **
				if "`dots'" == "dots" {
    				noisily: display _newline as text "Bootstrap`loopmark' replications (" as result "`repsloop'" as text ")"
                    noisily: display as text "{hline 4}{c +}{hline 3} 1 {hline 3}{c +}{hline 3} 2 {hline 3}{c +}{hline 3} 3 {hline 3}{c +}{hline 3} 4 {hline 3}{c +}{hline 3} 5"
                }
                ** START BOOSTRAP ITERATIONS **
                local bb = 1
                local cc = 0
    			while `bb' <= `repsloop' {
                    local cc = `cc'+1
                    ** ABORT BOOTSTRAP if MANY FAILURES **
    				if `cc'-`bb' > `repsloop' {
                        noi display as text " `cc'"
                        noi display as error "{p 0 2 2 `ls'}excessive # of failed bootstr. reps; bootstr. aborted{p_end}"
                        local repsloop = `bb'
                        local nbstrf = `cc'-`bb'
                        if `bb' <= 2 {
                            foreach mmat in `__BB' `__BM' `__MatStar' `__DEABC' `__DEABIAS' `__DEAB' {
                                cap mata : mata drop `mmat'
                            }
                            ereturn clear
				            restore
                            exit 498
                        }
                        else {
    					   continue, break
                        }
    				}
    				cap drop `__rnn'
                    ** DRAW FROM TRUNCATED NORMAL DISTRIBUTION **
    				if "`unit'" == "" {
    					if ("`twosided'" == "notwosided" & `loop' == 2) | ("`logscore'" == "logscore") {
    					   gen double `__rnn' = invnormal(runiform()*(normal(`__ntruncfit'/`sig')))*`sig'
    					}
    					else {
    					   gen double `__rnn' = invnormal(normal((`__ntruncfit'-1)/`sig')+runiform()*(normal(`__ntruncfit'/`sig')-normal((`__ntruncfit'-1)/`sig')))*`sig'
    					}
                    }
    				else {
    					gen double `__rnn' = -invnormal((1-runiform())*normal(-`__ntruncfit'/`sig'))*`sig'
                    }
                    ** CHECK FOR FAILURE IN GENERATING PSEUDO ERRORS **
                    count if `__rnn' >=. & `__ntruncfit' <.
                    local simfail = r(N)
                    ** SWITCH TAIL if FAILURE IN GENERATING PSEUDO ERROR **
                    if `simfail' > 0 {
        				if "`unit'" == "" {
        					if ("`twosided'" == "notwosided" & `loop' == 2) | ("`logscore'" == "logscore") {
        					   replace `__rnn' = -invnormal(1-(runiform()*(normal(`__ntruncfit'/`sig'))))*`sig' if (`__rnn' >=. & `__ntruncfit' <.)
        					}
        					else {
        					   replace `__rnn' = -invnormal(1-(normal((`__ntruncfit'-1)/`sig')+runiform()*(normal(`__ntruncfit'/`sig')-normal((`__ntruncfit'-1)/`sig'))))*`sig' if (`__rnn' >=. & `__ntruncfit' <.)
        					}
                        }
        				else {
        					replace `__rnn' = invnormal(1-((1-runiform())*normal(-`__ntruncfit'/`sig')))*`sig' if (`__rnn' >=. & `__ntruncfit' <.)
                        }
                        ** CHECK AGAIN FOR FAILURES IN GENERATING PSEUDO ERRORS **
                        count if `__rnn' >=. & `__ntruncfit' <.
                        local simfail = r(N)
                    }
                    ** CONTINUE IF FAILURE IN GENERATING PSEUDO ERRORS (Loop 2) **
                    if `simfail' > 0 & `loop' != 1 {
                    ** DISPLAY ITERATION DOTS **
    					if "`dots'" == "dots" {
    						if `cc'/50 == round(`cc'/50) {
    							noisily: display as error "x" as text " `cc'"
    						}
    						else {
    							noisily: display as error "x" _continue
    						}
    					}
                        continue
                    }
    				cap drop `__yboot'
                    ** GENERATE BOOTSTRAP EFFICIENCY SCORES **
    				gen double `__yboot' = `__truncfit'+ `__rnn'
                    ** LOOP 1: ESTIMATE BIAS-CORRECTED DEA-SCORES **
                    if `loop' == 1 {
                        ** HANDLE PLUGIN te_radial **
                        if `cc' == 1 {
                            handleplugin
                            ** CREATE MATRIZES FOR PLUGIN **                   	
                        	mkmat `outps', matrix(`__yobs') nomissing
                        	mkmat `inps', matrix(`__xobs') nomissing
                            mkmat `outps' if `__reference' == 1, matrix(`__yref') nomissing
                            mkmat `inps'  if `__reference' == 1, matrix(`__xref') nomissing
                            scalar `__nO' = colsof(`__yobs')
                            scalar `__nI' = colsof(`__xobs')
                            scalar `__nobs' = rowsof(`__yobs')
                            scalar `__nref' = rowsof(`__yref')
                            scalar `__ifqh' = 1
                            scalar `__intovar' = 0
                            matrix `__teB' = J(`__nobs', 1, .)
                            matrix `__ystar' = `__yref'
                            matrix `__xstar' = `__xref'
                            ** HANDLE RTS within PLUGIN **
                        	if "`rts'" == "CRS" {
                        		scalar `__rt' = 3
                        	}
                        	else if "`rts'" == "NIRS" {
                        			scalar `__rt' = 2
                        	}
                    		else if "`rts'" == "VRS" {
                    				scalar `__rt' = 1
                    		}
                			else {
                				display as error "{p 0 2 2 `ls'}invalid returns to scale{p_end}"
                				exit 198
                			}
                            ** HANDLE BASE within PLUGIN **
                            if "`base'" == "output" {
                                scalar `__ba' = 2
                            }
                            else if "`base'" == "input" {
                                scalar `__ba' = 1
                            }
                            else {
                                display as error "{p 0 2 2 `ls'}invalid base{p_end}"
                                exit 198
                            }
                        }
                        ** CONTINUE IF FAILURE IN GENERATING PSEUDO ERRORS (LOOP 1) **
                        if `simfail' > 0 {
                        ** DISPLAY ITERATION DOTS **
        					if "`dots'" == "dots" {
        						if `cc'/50 == round(`cc'/50) {
        							noisily: display as error "x" as text " `cc'"
        						}
        						else {
        							noisily: display as error "x" _continue
        						}
        					}
                            continue
                        }
                        ** DETERMINE OBSERVATION-RANGE for REFERENCE  **
                        local fref = `__nobs'-`__nref'+1
                        local lref = `__nobs'
                        ** RESCALE VARS IN REFERENCE SET **
                        if `__ba' == 1 {
                            ** CONSIDER LOGS IF OPTION LOGSCORE
                            if "`logscore'" != "logscore" {
                                mata : `__MatStar' = st_matrix("`__xref'") :* (st_data((`fref',`lref'), "`yy'") :/ st_data((`fref',`lref'),"`__yboot'")) :^(`expinvert')
                            }
                            else {
                                mata : `__MatStar' = st_matrix("`__xref'") :* exp((st_data((`fref',`lref'), "`yy'") - st_data((`fref',`lref'),"`__yboot'"))) :^(`expinvert')
                            }
                            mata : st_matrix("`__xstar'",`__MatStar')
                        }
                        if `__ba' == 2  {
                            ** CONSIDER LOGS IF OPTION LOGSCORE
                            if "`logscore'" != "logscore" {
                               mata : `__MatStar' = st_matrix("`__yref'") :* (st_data((`fref',`lref'), "`yy'") :/ st_data((`fref',`lref'),"`__yboot'")) :^(`expinvert')
                            }
                            else {
                                mata : `__MatStar' = st_matrix("`__yref'") :* exp((st_data((`fref',`lref'), "`yy'") - st_data((`fref',`lref'),"`__yboot'"))) :^(`expinvert')
                            }
                            mata : st_matrix("`__ystar'",`__MatStar')
                        }
                        ** CALL PLUGIN TO PERFORM DEA **
                        plugin call te_radial, `__yobs' `__xobs' `__nO' `__nI' `__nobs' `__ystar' `__xstar' `__nref' `__rt' `__ba' `__ifqh' `__intovar' `__teB'
                        ** CONTINUE IF FAILED **
        				if matmissing(`__teB') == 1 | rowsof(`__teB') != `__nobs' {
                            ** DISPLAY ITERATION DOTS **
        					if "`dots'" == "dots" {
        						if `cc'/50 == round(`cc'/50) {
        							noisily: display as error "x" as text " `cc'"
        						}
        						else {
        							noisily: display as error "x" _continue
        						}
        					}
                            continue
        				}
                        ** DISPLAY ITERATION DOTS **
        				if "`dots'" == "dots"  {
        					if `cc'/50 == round(`cc'/50) | `bb' == `repsloop' {
        						noisily: display as text ". `cc'"
        					}
        					else {
        						noisily: display as text "." _continue
        					}
        				}
                        ** COLLECT BOOTSTRAP DEA-SCORES **
                        if "`bcsaveall'" == "" {
            				if `bb' == 1 {
                                mata : `__DEAB' = st_matrix("`__teB'") :^(`expinvert')
            				}
            				else {
                                mata : `__DEAB' = `__DEAB' + st_matrix("`__teB'") :^(`expinvert')
            				}
                        }
                        else {
            				if `bb' == 1 {
                                mata : `__DEAB' = st_matrix("`__teB'") :^(`expinvert')
            				}
            				else {
                                mata : `__DEAB' = (`__DEAB', st_matrix("`__teB'") :^(`expinvert'))
            				}
                        }
                    }
                    ** LOOP 2: TRUNCTED REGRESSION **
                    if `loop' == 2 {
                        ** RUN TRUNCREG for BOOTRSTRAP SAMPLE **
        				if "`unit'" == "" {	
        					if ("`twosided'" == "notwosided") | ("`logscore'" == "logscore") {
                                cap truncreg `__yboot' `xx2' [`weight2' = `exp2'] if `yy' < `trlim', ul(`trlim') `constant' offset(`offset') `opttrunc' `itetrunc'
                            }
                            else {
                                cap truncreg `__yboot' `xx2' [`weight2' = `exp2'] if `yy' < 1 & `yy' > 0, ll(0) ul(1) `constant' offset(`offset') `opttrunc' `itetrunc'
                            }
        				}
        				else {	
        					cap truncreg `__yboot' `xx2' [`weight2' = `exp2'] if `yy' > `trlim', ll(`trlim') `constant' offset(`offset') `opttrunc' `itetrunc'
        				}
                        ** CONTINUE IF FAILED **
        				if _rc != 0 | e(converged) != 1 {
                            ** DISPLAY ITERATION DOTS **
        					if "`dots'" == "dots" {
        						if `cc'/50 == round(`cc'/50) {
        							noisily: display as error "x" as text " `cc'"
        						}
        						else {
        							noisily: display as error "x" _continue
        						}
        					}
                            continue
        				}
                        ** DISPLAY ITERATION DOTS **
        				if "`dots'" == "dots"  {
        					if `cc'/50 == round(`cc'/50) | `bb' == `repsloop' {
        						noisily: display as text ". `cc'"
        					}
        					else {
        						noisily: display as text "." _continue
        					}
        				}
                        ** COLLECT BOOTSTRAP COEFFICIENT ESTIMATES **
        				if `bb' == 1 {
        					mata : `__BB' = st_matrix("e(b)")
        				}
        				else {
        					mata : `__BB' = (`__BB' \ st_matrix("e(b)"))
        				}
                    }
                    ** STOP BOOTSTRAP IF NUMB. of REQUESTED REPLICATIONS is REALIZED **
    				local bb = `bb'+ 1
    				if `bb' == `repsloop'+1 {
                        local nbstrf = `cc'-(`bb'-1)
    					continue, break
    				}
    			}
                if `loop' == 1 {
                    if "`biaste'" != "" {
                        ** CALCULATE BIAS in DEA SCORES **
                        if "`bcsaveall'" == "" {
                            mata : `__DEABIAS' = `__DEAB'/(`bb'-1) - `trlefte'(st_data(., "`yy'"))
                        }
                        else {
                            mata : `__DEABIAS' = (mean(`__DEAB''))' - `trlefte'(st_data(., "`yy'"))
                        }
                        ** SAVE BIAS in DEA SCORE PERMANATELY **
                        gen double `biaste' =.
                        mata : st_store(.,"`biaste'",`__DEABIAS')
                        label variable `biaste' "bootstrap bias estimate for `printinvert'`base'-oriented efficiency score under `rts'"
                    }
                    ** CALCULATE BIAS CORRECTED DEA-SCORES **
                    if "`bcsaveall'" == "" {
                        mata : `__DEABC' = `trlefte'(st_data(., "`yy'")) - (`__DEAB'/(`bb'-1) - `trlefte'(st_data(., "`yy'")))
                    }
                    else {
                        mata : `__DEABC' = `trlefte'(st_data(., "`yy'")) - ((mean(`__DEAB''))' - `trlefte'(st_data(., "`yy'")))
                    }
                    ** CHECK FOR NON-POSITIVE BC-SCORES AND ISSUE WARNING **
                    mata : st_numscalar("`__cnps'", min(`__DEABC'))
                    if `__cnps' < 0 & "`print'" != "noprint" {
                        if "`base'" == "input" {
                            display as error "{p 0 2 2 `ls'}warning: bias-correction yields at least one negative score; consider specifying opt. invert or switching to base(output){p_end}"
                        }
                        else {
                            display as error "{p 0 2 2 `ls'}warning: bias-correction yields at least one negative score; consider dropping opt. invert or switching to base(input){p_end}"
                        }
                    }
                    ** WRITE BIAS CORRECTED SCORES TO DATA **
                    mata : st_store(.,"`yy'",`__DEABC')
                    if "`tebc'" != "" {
                        ** SAVE BIAS CORRECTED DEA SCORE PERMANATELY **
                        gen double `tebc' = `yy'
                        label variable `tebc' "`printinvert'bias-corrected `base'-oriented efficiency score under `rts'"
                    }
                    ** COUNT NEGATIVE SCORES **
                    if `__cnps' < 0 {
                        count if `yy' < 0
                        local nnneg = r(N)
                    }
                    ** RE-COUNT LIMIT-SCORES (Count will be zero unless some error occurs) **
                    sum `exp2' if `yy' == 1
                    local wslim = r(sum)
                    local nnlim = r(N)
                    ** RE-COUNT IRREGULAR SCORES **
                    if "`unit'" == "nounit" {
                        sum `exp2' if `yy' < 1
                        local wsirreg = r(sum)
                        local nnirreg = r(N)
                    }
                    else {
                        sum `exp2' if `yy' > 1 & `yy' <.
                        local wsirreg = r(sum)
                        local nnirreg = r(N)
                    }
                    ** TAKE LOGS IF OPTION LOGSCORE **
                    if "`logscore'" == "logscore" {
                        replace `yy' = log(`yy')
                    }
                    ** RE-RUN INITIAL TRUNCATED REGRESSION **
        			if "`unit'" == "" {
                        if ("`twosided'" == "notwosided") | ("`logscore'" == "logscore") {				
            			    cap `trn' truncreg `yy' `xx' [`weight2' = `exp2'], ul(`trlim') `constant' offset(`offset') `opttrunc' `itetrunc'
                        }
                        else {
                            cap `trn' truncreg `yy' `xx' [`weight2' = `exp2'], ll(0) ul(1) `constant' offset(`offset') `opttrunc' `itetrunc'
                        }
        			}
        			else {				
        				cap `trn' truncreg `yy' `xx' [`weight2' = `exp2'], ll(`trlim') `constant' offset(`offset') `opttrunc' `itetrunc'
        			}
        			if _rc != 0 | e(converged) != 1 {
                        if e(converged) != 1 {
        				    display as error "{p 0 2 2 `ls'}convergence not achieved in truncated regression{p_end}"
                        }
                        else {
                            display as error "{p 0 2 2 `ls'}truncated regression failed{p_end}"
                        }
        				ereturn clear
                        mata : mata drop `__DEAB' `__DEABC' `__MatStar'
                        if "`biaste'" != "" {
                            mata : mata drop `__DEABIAS'
                        }
        				restore
        				if _rc != 0 {
                            exit _rc
                        }
                        else {
        				    exit 430
                        }
        			}
        			local sig = e(sigma)
                    cap drop `__truncfit' `__ntruncfit'
        			predict double `__truncfit', xb
        			gen double `__ntruncfit' = `trlim'-`__truncfit'
        			matrix `__borg' = e(b)
                    ** RE-CALCULATE SAMPLESIZE **
        			sum `exp2' if e(sample)
                    local wgtsum = r(sum)
        			local tsamps = r(N)
                    ** CHECK FOR EXTREMELY LARGE VALUES OF PREDICTED EFFICIENCY VALUES **
                    if "`unit'" != "nounit" & "`twosided'" != "notwosided" & "`logscore'" != "logscore" {
                        count if max(abs(`__ntruncfit'),abs(`__ntruncfit'-1)) >= `extolerance'*`sig' & `__ntruncfit' <.
                    }
                    else {
                        count if abs(`__ntruncfit') >= `extolerance'*`sig' & `__ntruncfit' <.
                    }
                    if r(N) > 0 {
        				display as error "{p 0 2 2 `ls'}extreme values for fitted efficiency encountered: `diextval' > `extolerance' for at least one DMU; bootstrap likely to fail; consider changing specification and check for possible outlier(s){p_end}"
				        ereturn clear
                        mata : mata drop `__DEAB' `__DEABC' `__MatStar'
                        if "`biaste'" != "" {
                            mata : mata drop `__DEABIAS'
                        }
        				restore
        				exit 430
                    }
        			** TRANSFER RESULTS **
                    local ic = e(ic)
                    local k_eq = e(k_eq)
                    local converged = e(converged)
                    local rc = e(rc)
        			local ll = e(ll)
                    local df_m = e(df_m)
                    local k_aux = e(k_aux)
                    ** CHECK for CONSTRAINTS **
                    if "`e(Cns)'" != "" {
                        matrix `__Cns' = e(Cns)
                        local iconstr "iconstr"
                    }
                    cap drop `__esamp'
			        gen `__esamp' = 1 if e(sample)
                }
                if `loop' == 2 {
        			** CALCULATE BOOTSTRAP MEAN & BIAS **
        			mata : `__BM' = mean(`__BB')
        			mata : st_matrix("`__bbm'",`__BM')
        			local colsob = colsof(`__borg')
        			local colsbb = colsof(`__bbm')
                    if `colsob' != `colsbb' {
                        foreach mmat in `__BB' `__BM' `__MatStar' `__DEABC' `__DEABIAS' `__DEAB' {
                            cap mata : mata drop `mmat'
                        }
                        ereturn clear
				        restore
                        di as error "{p 0 2 2 `ls'}conformability error; bias correction failed{p_end}"
                        exit 503
                    }
                    else {
            			mat `__bbias' =  `__bbm' - `__borg'
            			** CALCULATE COVARIANCE-MATRIX **
                        mata : `__VB' = quadvariance(`__BB')
                        mata : st_matrix("`__cov'",`__VB')
            			** CALCULATE PERCENTILE CONFIDENCE INTERVALS **
                        cipsimarwilson `level' `__BB' `__cip'
                    }
                }
            }
            ** CLEAR MATA **
            if "`algorithm'" == "2" {
                mata : mata drop `__MatStar' `__DEABC'
                if "`biaste'" != "" {
                    mata : mata drop `__DEABIAS'
                }
                if "`bcsaveall'" != "" {
                    mata : `__DEAB' = `__DEAB''
                    capture mata : mata drop `bcsaveall'
                    mata : mata rename `__DEAB' `bcsaveall'
                }
                else {
                    mata : mata drop `__DEAB'
                }
            }
            if "`saveall'" == "" {
                mata : mata drop `__BB' `__VB' `__BM'
            }
            else {
                mata : mata drop `__VB' `__BM'
                capture mata : mata drop `saveall'
                mata : mata rename `__BB' `saveall'
            }
			** RENAME RESULTS **
            if "`algorithm'" == "1" {
                local scoretype "score"
            }
            else {
                local scoretype "bcscore"
            }
			local nc = colsof(`__borg')-1
			local psig = 1+`nc'
			mat `__coef' = `__borg'[1...,1..`nc']
			mat `__sig' = `__borg'[1...,`psig'..`psig']
            ** RENAME COLUMNS FOR e(b) AND e(V) **
            if `c(stata_version)' < 15 {
                mat coleq `__sig' = sigma
                mat colname `__sig' = _cons
            }
            else if `c(userversion)' < 15 {
                mat coleq `__sig' = sigma
                mat colname `__sig' = _cons
            }
            else {
                mat coleq `__sig' = /
                mat colname `__sig' = sigma
            }
            if "`deasyntax'" != "" & "`algorithm'" == "1" {
                if "`tename'" == "" {
                    mat coleq `__coef' = `scoretype'
                    local yynew "`scoretype'"
                }
                else {
                    mat coleq `__coef' = `tename'
                    local yynew "`tename'"
                }
            }
            else if "`deasyntax'" != "" & "`algorithm'" == "2" {
                if "`tebc'" == "" {
                    mat coleq `__coef' = `scoretype'
                    local yynew "`scoretype'"
                }
                else {
                    mat coleq `__coef' = `tebc'
                    local yynew "`tebc'"
                }
            }
            else {
                mat coleq `__coef' = `yy'
                local yynew "`yy'"
            }
			mat `__borg' = (`__coef',`__sig')
			local cn : colfullnames `__borg'
			matrix colnames `__cov' = `cn'
			matrix rownames `__cov' = `cn'
			matrix rownames `__cip' = `cn'
			matrix colnames `__cip' = cip`level':ll cip`level':ul
			matrix `__cip' = `__cip''
			matrix colnames `__bbias' = `cn'
            matrix colnames `__bbm' = `cn'
           	** RESTORE ORIGNIAL SAMPLE **
            if "`deasyntax'" == "" | ("`algorithm'" == "1" & "`tename'" == "") {
                keep `__tempid' `__esamp'
            }
            if "`deasyntax'" != "" & "`algorithm'" == "1" & "`tename'" != "" {
                keep `__tempid' `__esamp' `savete'
            }
            if "`algorithm'" == "2" {
                local keepvar "`__tempid' `__esamp'"
                if "`savete'" != "" {
                    local keepvar "`keepvar' `savete'"
                }
                if "`tebc'" != "" {
                    local keepvar "`keepvar' `tebc'"
                }
                if "`biaste'" != "" {
                    local keepvar "`keepvar' `biaste'"
                }
                keep `keepvar'
            }
            sort `__tempid'
			save `__resufile'
            restore
            merge 1:1 `__tempid' using `__resufile', nogenerate update replace force
            replace `__esamp' = 0 if `__esamp' != 1
            ** CALCULATE NUMBERS OF OBSERVATIONS **
            if "`weight2'" == "iw" {
                local samps = round(`wgtsum')
                local N_lim = round(`wslim')
                local N_all = round(`wsall')
                local N_irreg = round(`wsirreg')
            }
	        else {
                local samps = `tsamps'
                local N_lim = `nnlim'
                local N_all = `nnall'
                local N_irreg = `nnirreg'
	        }
            ** POST RESULTS TO e() **
			ereturn clear
            if "`iconstr'" == "iconstr" {
                ereturn post `__borg' `__cov' `__Cns', properties(b V) obs(`samps') esample(`__esamp') findomitted
            }
            else {
			    ereturn post `__borg' `__cov', properties(b V) obs(`samps') esample(`__esamp') findomitted
            }
			** WALD TEST of NULL-MODEL **
			if `df_m' > 0 {
				test [`yynew']
				local wchi2 = `r(chi2)'
				local wp = `r(p)'
			}
			else {
				local wchi2 = .
				local wp = .			
			}
			** RANK OF e(V) **
			mata : st_matrix("`__rank'",rank(st_matrix("e(V)")))
			** SCALARS **
            ereturn scalar N = `samps'
            ereturn scalar N_lim = `N_lim'
            ereturn scalar N_all = `N_all'
            ereturn scalar N_irreg = `N_irreg'
            if "`weight'" != "" {
                ereturn scalar wgtsum = `wgtsum'
            }
            ereturn scalar sigma = `sig'
            ereturn scalar ll = `ll'
            ereturn scalar ic = `ic'
            ereturn scalar converged = `converged'
            ereturn scalar rc =  `rc'
            ereturn scalar rank = `__rank'[1,1]
            ereturn scalar k_eq = `k_eq'
            ereturn scalar df_m = `df_m'
            ereturn scalar k_aux = `k_aux'
            ereturn scalar chi2 = `wchi2'
            ereturn scalar p = `wp'
			ereturn scalar N_reps = `reps'
            ereturn scalar N_misreps = `nbstrf'
            ereturn scalar level = `level'
            ereturn scalar algorithm = `algorithm'
            ** SCALARS (DEA) **
            if "`deasyntax'" != "" {
                if "`algorithm'" == "2" {
                    ereturn scalar N_dea = `__nobs'
                    if "`nnneg'" != "" {
                        ereturn scalar N_deaneg = `nnneg'
                    }
                    else {
                        ereturn scalar N_deaneg = 0
                    }
                    ereturn scalar N_dearef = `__nref'
                    ereturn scalar N_bc  = `bcreps'
                }
                else {
                    ereturn scalar N_dea = `__ndeao'
                    ereturn scalar N_dearef = `__ndearefo'
                }
                ereturn scalar ninps  = `nI'
                ereturn scalar noutps = `nO'
            }
			** MATRICES **
			ereturn matrix ci_percentile = `__cip'
			ereturn matrix bias_bstr = `__bbias'
            ereturn matrix b_bstr = `__bbm'
            ** MACROS (DEA) **
            if "`deasyntax'" != "" {
                ereturn local outputs "`outps'"
                ereturn local inputs "`inps'"
                ereturn local base "`base'"
                ereturn local rts "`rts'"
                if "`tename'" != "" {
                    ereturn local tename "`tename'"
                }
                if "`tebc'" != "" {
                    ereturn local tebc "`tebc'"
                }
                if "`biaste'" != "" {
                    ereturn local biaste "`biaste'"
                }
            }
            ereturn local bcsaveall `bcsaveall'
            ereturn local saveall `saveall'
			ereturn local offset `offset'
            ereturn local cinormal `cinormal'
            ereturn local bbootstrap `bbootstrap'
            if "`deasyntax'" == "" {
                ereturn local depvarname "`yy'"
            }
            if "`deasyntax'" != "" & "`tename'" != "" & "`algorithm'" == "1" {
                ereturn local depvarname "`tename'"
            }
            if "`deasyntax'" != "" & "`tebc'" != "" & "`algorithm'" == "2" {
                ereturn local depvarname "`tebc'"
            }
            if "`deasyntax'" != "" {
                ereturn local deatype "internal"
            }
            else {
                ereturn local deatype "external"
            }
            ereturn local scoretype "`scoretype'"
            ** MACROS (else) **
            ereturn local predict "truncr_p"
            ereturn local marginsok "default XB E(passthru)"
            if "`unit'" == "nounit" {
                ereturn local marginsdefault "predict(e(`trlim',.))"
            }
            else if ("`twosided'" == "notwosided") | "`logscore'" == "logscore" {
                ereturn local marginsdefault "predict(e(.,`trlim'))"
            }
            else {
                ereturn local marginsdefault "predict(e(0,1))"
            }
			if "`weight'" != "" {			
                ereturn local wexp  "`exp'"
                ereturn local wtype "`weight'"
			}
			if "`unit'" == "" {
				ereturn local unit "unit"
			}
			else {
				ereturn local unit `unit'
			}
            if "`e(unit)'" == "unit" {
                ereturn local depvar "efficiency"
            }
            else {
                ereturn local depvar "inefficiency"
            }
            if "`invert'" == "invert" {
                ereturn local invert "Shephard"
            }
            else {
                ereturn local invert "Farrell"
            }
			if ("`twosided'" == "notwosided") | ("`unit'" == "nounit") | ("`logscore'" == "logscore") {
				ereturn local truncation "onesided"
			}
			else {
				ereturn local truncation "twosided"
			}
            if "`logscore'" == "logscore" {
                ereturn local logscore `logscore'
            }
            ereturn local cmd `cmd'
            ereturn local cmdline `cmdline'
            ereturn local shorttitle "Simar & Wilson (2007) eff. analysis"
            ereturn local title "Simar & Wilson (2007) two-stage efficiency analysis"
	   }
	   set more `moreold'
	}
    else {
        ** HANDLE RE-DISPLAY OF RESULTS **
        if "`e(cmd)'" != "simarwilson" {
			error 301
		}
		else {
			syntax, [LEVel(real `e(level)')] [CINormal] [BBOOTstrap] [CFORMAT(string asis)] [PFORMAT(string asis)] [SFORMAT(string asis)] [VSQUISH] [noPRINT] [noDEAPrint] [noOMITted] [BASELevels]
            ** GENERATE TEMPORARY MATRIX FOR PERCENTILE CIs **
            tempname __cip
			** HANDLE LEVEL **
			if `level' >= 10 & `level' <= 99.99 {
                local level = round(`level',0.01)
                local level = substr("`level'",1,5)
			}
			else {
                if "`print'" != "noprint" {
                    noisily display as error "{p 0 2 2 `ls'}warning: level() outside [10,99.99] interval not allowed{p_end}"
                }
				local level = `e(level)'			
			}
            /*
            if "`e(cinormal)'" == "cinormal" {
                local cinormal "cinormal"
            }
            */
		}
    }
    ** DISPLAY RESULTS **
	** SET DISPLAY-OPTIONS (Deactivated!) **
	if "`cformat'" == "" | "`cformat'" != "" {
        if "`cformat'" != "" & "`cformat'" != "%9.0g" & "`print'" != "noprint" {
            di as text "{p 0 2 2 `ls'}sorry, spec. cformat(`cformat') ignored{p_end}"
        }
		local cformat "%9.0g"
	}
	if "`pformat'" == "" | "`pformat'" != "" {
        if "`pformat'" != "" & "`pformat'" != "%5.3f" & "`print'" != "noprint" {
            di as text "{p 0 2 2 `ls'}sorry, spec. pformat(`pformat') ignored{p_end}"
        }
		local pformat "%5.3f"
	}
	if "`sformat'" == "" | "`sformat'" != "" {
        if "`sformat'" != "" & "`sformat'" != "%8.2f" & "`print'" != "noprint" {
            di as text "{p 0 2 2 `ls'}sorry, spec. sformat(`sformat') ignored{p_end}"
        }
		local sformat "%8.2f"
	}
    ** SET DEFAULT DEPVARNAME (IF NOT SAVED TO e()) **
    if "`e(depvarname)'" != "" {
        if "`e(logscore)'" != "logscore" {
            local edepvarname "`e(depvarname)'"
        }
        else {
            local edepvarname "ln(`e(depvarname)')"
        }
    }
    else {
        if "`e(logscore)'" != "logscore" {
            local edepvarname "`e(scoretype)'"
        }
        else {
            local edepvarname "ln(`e(scoretype)')"
        }
    }
	** SET PARAMETERS FOR SKIPPING (determine values for _skip()) **
	if "`e(unit)'" == "unit" {
		local inq "<"
	}
	else {
		local inq ">"
	}
    if "`e(logscore)'" != "logscore" {
		local trlim = 1
	}
	else {
		local trlim = 0
	}
    ** ABBREVIATE TOO-LONG DEPVARNAME **
    local shortdvn = abbrev("`edepvarname'",20)
	local inei "inefficient if `shortdvn'"
	if "`e(df_m)'" != "" {
    	if `e(df_m)' > 0 {
    		local fskip = 1+floor(log10(`e(df_m)'))
    	}
    	else {
    		local fskip = 1
    	}
	}
	else {
		local fskip = 1
	}
	local tabwidth = 78
	local statwidth = 37
	local statwidth2 = 12
    local statwidthtext = 27
    local statwidthval = 10
	local statskip = `tabwidth'-`statwidth'
    local ciskip  = 7 - strlen("`level'")
    local ciskip2 = 7 - strlen("`e(level)'")
	local rr = 0
    ** LOOP OVER STATISTICS TO BE DISPLAYED **
	foreach disp in "Number of obs" "Number of efficient DMUs" "Number of bootstr. reps" "Wald chi2(" "Prob > chi2(" "Number of super-eff. DMUs" {
	    local rr = `rr'+1
		if `rr' == 1 {
			local statskip`rr' = `statskip' - `str'len("`e(shorttitle)'")
		}
		local disp`rr' "`disp'"
		local ldisp`rr'= strlen("`disp'")
		local skip`rr' = `statwidth' - `statwidth2' - `ldisp`rr''
		if `rr' == 2 {
			local statskip`rr' = `statskip' - `str'len("(algorithm #`e(algorithm)')")
		}
		if `rr' == 4 | `rr' == 5 {
			local skip`rr' = `statwidth' - `ldisp`rr'' - `fskip' - 1 - `statwidth2'
		}
		if `rr' == 4 {
			local statskip`rr' = `statskip' - `str'len("`inei'") - 4
		}
		if `rr' == 5 {
			local statskip`rr' = `statskip' - strlen("`e(truncation)'") - 11
		}
	}
	** DISPLAY RESULTS on SCREEN **
    if "`e(wtype)'" != "" {
       di as text "(sum of wgt is" as text %10.7e `e(wgtsum)' as text ")"
    }
	display _newline as text "`e(shorttitle)'" _skip(`statskip1') as text "`disp1'" _skip(`skip1') as text " =  " as result %8.0f `e(N)'
    display as text "(algorithm #" as result "`e(algorithm)'" as text ")" _skip(`statskip2') as text "`disp2'" _skip(`skip2') as text " =  " as result %8.0f `e(N_lim)'
	**display _skip(`statskip') as text "`disp2'" _skip(`skip2') as text " =  " as result %8.0f `e(N_lim)'
    if `e(N_irreg)' > 0 & `e(N_irreg)' <. {
        display _skip(`statskip') as text "`disp6'" _skip(`skip6') as text " =  " as result %8.0f `e(N_irreg)'
    }
    display _skip(`statskip') as text "`disp3'" _skip(`skip3') as text " =  " as result %8.0f `e(N_reps)'
    if ("`e(unit)'" == "nounit") | ("`e(logscore)'" == "logscore") {
    	display _skip(`statskip') as text "`disp4'" as result %`fskip'.0f `e(df_m)' as text ")" _skip(`skip4') as text " =  " as result %8.2f `e(chi2)'
        display as text "`inei'" as result " `inq' " as text "`trlim'" _skip(`statskip4') as text "`disp5'" as result %`fskip'.0f `e(df_m)' as text ")" _skip(`skip5') as text " =  " as result %8.4f `e(p)' _newline
    }
    else {
    	display as text "`inei'" as result " `inq' " as text "`trlim'" _skip(`statskip4') as text "`disp4'" as result %`fskip'.0f `e(df_m)' as text ")" _skip(`skip4') as text " =  " as result %8.2f `e(chi2)'
    	display as text "`e(truncation)' truncation" _skip(`statskip5') as text "`disp5'" as result %`fskip'.0f `e(df_m)' as text ")" _skip(`skip5') as text " =  " as result %8.4f `e(p)' _newline
    }
    ** DISPLAY DEA RESULTS on SCREEN **
    if "`deaprint'" == "" {
        display as text "{hline `tabwidth'}"
        local deatitleprint "Data Envelopment Analysis:"
        display as text "Data Envelopment Analysis:" _continue
        if "`e(noutps)'" == "" & "`e(ninps)'" == "" {
            local exdeaprint "externally estimated scores"
            local exdeaskip = `tabwidth' - `str'len("`deatitleprint'") - `str'len("`exdeaprint'")
            display _skip(`exdeaskip') as text "`exdeaprint'" _newline
        }
        else {

            ** DISPLAY ORINENTATION **
            local ortprint "`e(base)' oriented (`e(invert)')"
            local ortskip = `str'len("`ortprint'")
            ** DISPLAY RETURNS TO SCALE **
            if "`e(rts)'" == "VRS" {
                local rtsprint "variable returns to scale"
            }
            if "`e(rts)'" == "NIRS" {
                local rtsprint "nonincreasing returns to scale"
            }
            if "`e(rts)'" == "CRS" {
                local rtsprint "constant returns to scale"
            }
            local rtsskip = `str'len("`rtsprint'")
            ** DISPLAY BIAS CORRECTION **
            if "`e(N_bc)'" != "" {
                local ibcprint "bias corrected efficiency measure"
            }
            else {
                local ibcprint "no bias correction"
            }
            local ibcskip = `str'len("`ibcprint'")
            ** DISPLAY NUMBER of DMUs **
            local dmuprint "Number of DMUs"
            local dmuskip1 = `tabwidth' - `statwidth' - `str'len("`deatitleprint'")
            local dmuskip2 = `statwidthtext' - `str'len("`dmuprint'") -1
            local dmuskip3 = `statwidthval' - `str'len("`e(N_dea)'")
            display _skip(`dmuskip1') as text "`dmuprint'" _skip(`dmuskip2') as text "=" _skip(`dmuskip3') as result "`e(N_dea)'"
            ** DISPLAY NUMBER of REFERENCE DMUs **
            local refprint "Number of ref. DMUs"
            local refskip2 = `statwidthtext' - `str'len("`refprint'") -1
            local refskip3 = `statwidthval' - `str'len("`e(N_dearef)'")
            if "`e(N_bc)'" != "" {
                local refskip1 = `tabwidth' - `statwidth'
                display _skip(`refskip1') as text "`refprint'" _skip(`refskip2') as text "=" _skip(`refskip3') as result "`e(N_dearef)'"
            }
            else {
                local refskip1 = `tabwidth' - `statwidth' - `ortskip'
                display as text "`ortprint'" _skip(`refskip1') as text "`refprint'" _skip(`refskip2') as text "=" _skip(`refskip3') as result "`e(N_dearef)'"
            }
            ** DISPLAY NUMBER of OUTPUTs **
            local outpsprint "Number of outputs"
            local outpsskip2 = `statwidthtext' - `str'len("`outpsprint'") -1
            local outpsskip3 = `statwidthval' - `str'len("`e(noutps)'")
            if "`e(N_bc)'" != "" {
                local outpsskip1 = `tabwidth' - `statwidth' - `ortskip'
                display as text "`ortprint'" _skip(`outpsskip1') as text "`outpsprint'" _skip(`outpsskip2') as text "=" _skip(`outpsskip3') as result "`e(noutps)'"
            }
            else {
                local outpsskip1 = `tabwidth' - `statwidth' - `rtsskip'
                display as text "`rtsprint'" _skip(`outpsskip1') as text "`outpsprint'" _skip(`outpsskip2') as text "=" _skip(`outpsskip3') as result "`e(noutps)'"
            }
            ** DISPLAY NUMBER of INPUTs **
            local inpsprint "Number of inputs"
            local inpsskip2 = `statwidthtext' - `str'len("`inpsprint'") -1
            local inpsskip3 = `statwidthval' - `str'len("`e(ninps)'")
            if "`e(N_bc)'" != "" {
                local inpsskip1 = `tabwidth' - `statwidth' - `rtsskip'
                display  as text "`rtsprint'" _skip(`inpsskip1') as text "`inpsprint'" _skip(`inpsskip2') as text "=" _skip(`inpsskip3') as result "`e(ninps)'"
            }
            else {
                local inpsskip1 = `tabwidth' - `statwidth' - `ibcskip'
                display  as text "`ibcprint'" _skip(`inpsskip1') as text "`inpsprint'" _skip(`inpsskip2') as text "=" _skip(`inpsskip3') as result "`e(ninps)'" _newline
            }
            if "`e(N_bc)'" != "" {
                ** DISPLAY NUMBER of REPS (BIAS CORRECTION) **
                local bcprint "Number of reps (bc)"
                local bcskip1 = `tabwidth' - `statwidth' - `ibcskip'
                local bcskip2 = `statwidthtext' - `str'len("`bcprint'") -1
                local bcskip3 = `statwidthval' - `str'len("`e(N_bc)'")
                display as text "`ibcprint'" _skip(`bcskip1') as text "`bcprint'" _skip(`bcskip2') as text "=" _skip(`bcskip3') as result "`e(N_bc)'" _newline
            }
        }
    }
	if "`cinormal'" == "cinormal" {
        ** DISPLAY REGRESSION TABLE WITH NORMAL-APPROX-CIs **
        local ccn = abbrev("`e(depvar)'",12)
        local colsk = 13 - `str'len("`ccn'")
        display as text "{hline 13}{c TT}{hline 64}"
        if "`bbootstrap'" == "" {
            display _column(13) as text " {c |}  Observed" _skip(3) "Bootstrap" _skip(25) "Normal approx."
        }
        else {
            display _column(13) as text " {c |} Bootstrap" _skip(3) "Bootstrap" _skip(25) "Normal approx."
        }
        display _column(`colsk') as text "`ccn' {c |}" _skip(6)  "Coef." _skip(3) "Std. Err." _skip(6) "z" _skip(4) "P>|z|" _skip(`ciskip') "[" as result `level' as text "% Conf. Interval]"
        display as text "{hline 13}{c +}{hline 64}"
        local ccn = `substr'(abbrev("`edepvarname'",12),1,12)
        local colsk = 13 - `str'len("`ccn'")
        display as result "`ccn'" as text _skip(`colsk') "{c |}"
        ** GEN TEMPORARY MATRICES FOR DISPLAY
        tempname __dima __dima2 __dima3 __dima4 __bt
        if "`bbootstrap'" == "" {
            matrix `__bt' = e(b)'
        }
        else {
            matrix `__bt' = e(b_bstr)'
        }
        mata : st_matrix("`__dima2'" , diagonal(st_matrix("e(V)")):^0.5)
        mata : st_matrix("`__dima3'" , st_matrix("`__bt'"):/st_matrix("`__dima2'"))
        mata : st_matrix("`__dima4'", 2*normal(-1*abs(st_matrix("`__dima3'"))))
        matrix `__dima' = (`__bt',`__dima2', `__dima3', `__dima4',`__bt'+ invnormal((1-0.01*`level')/2)*`__dima2',`__bt'- invnormal((1-0.01*`level')/2)*`__dima2')
    }
    else {
        ** DISPLAY REGRESSION TABLE WITH PERCENTILE-CIs **
        ** RECALCULATE PERCENTILE CIs if REQUIRED **
        if "`e(level)'" != "`level'" & "`e(saveall)'" != "" {
            cipsimarwilson `level' `e(saveall)' `__cip'
            local nlevel "`level'"
            mat scip = `__cip'
        }
        else {
            mat `__cip' = e(ci_percentile)'
            local nlevel "`e(level)'"
        }
        local ccn = abbrev("`e(depvar)'",12)
        local colsk = 13 - `str'len("`ccn'")
        display as text "{hline 13}{c TT}{hline 64}"
        if "`bbootstrap'" == "" {
            display _column(13) as text " {c |}  Observed" _skip(3) "Bootstrap" _skip(27) "Percentile"
        }
        else {
            display _column(13) as text " {c |} Bootstrap" _skip(3) "Bootstrap" _skip(27) "Percentile"
        }
        display _column(`colsk') as text "`ccn' {c |}" _skip(6)  "Coef." _skip(3) "Std. Err." _skip(6) "z" _skip(4) "P>|z|" _skip(`ciskip') "[" as result `nlevel' as text "% Conf. Interval]"
        display as text "{hline 13}{c +}{hline 64}"
        local ccn = `substr'(abbrev("`edepvarname'",12),1,12)
        local colsk = 13 - `str'len("`ccn'")
        display as result "`ccn'" as text _skip(`colsk') "{c |}"
        tempname __dima __dima2 __dima3 __dima4 __bt
        if "`bbootstrap'" == "" {
            matrix `__bt' = e(b)'
        }
        else {
            matrix `__bt' = e(b_bstr)'
        }
        mata : st_matrix("`__dima2'" , diagonal(st_matrix("e(V)")):^0.5)
        mata : st_matrix("`__dima3'" , st_matrix("`__bt'"):/st_matrix("`__dima2'"))
        mata : st_matrix("`__dima4'", 2*normal(-1*abs(st_matrix("`__dima3'"))))
        matrix `__dima' = (`__bt',`__dima2',`__dima3',`__dima4',`__cip')
    }
    local cn = rowsof(`__dima')
    local cns : rownames `__dima'
    tokenize `cns'
    forvalues cc = 1(1)`cn' {
        if `cc' == `cn' {
            local ccn "/sigma"
        }
        else {
            local ccn = abbrev("``cc''",12)
        }
        local colsk = 13 - `str'len("`ccn'")
        if ("`omitted'" == "" | `substr'("`ccn'",1,2) != "o.") & ("`baselevels'" == "baselevels" | `str'pos("`ccn'","b.") == 0) {
            display _column(`colsk') as text "`ccn' {c |}" /*
            */ _skip(2) as result `cformat' `__dima'[`cc',1] /*
            */ _skip(2) as result `cformat' `__dima'[`cc',2] /*
        	*/ _skip(1) as result `sformat' `__dima'[`cc',3] /*
        	*/ _skip(3) as result `pformat' `__dima'[`cc',4] /*
        	*/ _skip(4) as result `cformat' `__dima'[`cc',5] /*
        	*/ _skip(3) as result `cformat' `__dima'[`cc',6]
        }
        if `cc' == `cn'-1 {
            if "`e(offset)'" != "" {
                local ccn = abbrev("`e(offset)'",12)
                local colsk = 13 - `str'len("`ccn'")
                display _column(`colsk') as text "`ccn' {c |}" _skip(2) as result `cformat' 1 _skip(2) as text "(offset)"
            }
            display as text "{hline 13}{c +}{hline 64}"
        }
        if `cc' == `cn' {
            display as text "{hline 13}{c BT}{hline 64}"
        }
    }
    ** DISPLAY WARNING if CHANGE in LEVEL for PECENTILE CIs is REQUESTED WITHOUT SPCIFYING SAVEALL() **
    if replay() & "`e(level)'" != "`level'" & "`cinormal'" != "cinormal" & "`e(saveall)'" == "" {
        noisily display as error "{p 0 2 2 `ls'}saveall() not previously specified; cannot change level for percentile CIs; use opt. cinormal{p_end}"
    }
    ** SAVE SOME RESULTS IN r() **
    putr `__dima' `level'
end

**************************************************************************************************************
** PERCENTILE CONFIDENCE INTERVALLS **************************************************************************
**************************************************************************************************************
capture program drop cipsimarwilson
program cipsimarwilson, nclass
version 12
	args level BB cip
	** TEMPORARY NAMES **
    tempname __CIB __CIBI __cc __rr
    mata : st_numscalar("`__cc'",cols(`BB'))
    mata : st_numscalar("`__rr'",rows(`BB'))
    local nb = `__cc'
	local llo = 1+floor(`__rr'*((100-`level')/200))
	local ulo =    ceil(`__rr'-`__rr'*((100-`level')/200))
    local cw = min(max(((1-`level'/100)*`__rr'-((`__rr'-`ulo')+(`llo'-1))),0),2)
	forvalues cc = 1(1)`nb' {
        mata : `BB' = sort(`BB',`cc')
        if `llo' > 1 & `ulo' < `__rr' {
        mata : `__CIBI' = (0.5+0.25*`cw')*(`BB'[`llo',`cc'],`BB'[`ulo',`cc'])+ (0.5-0.25*`cw')*(`BB'[`llo'-1,`cc'],`BB'[`ulo'+1,`cc'])
        }
        else {
            mata : `__CIBI' = (`BB'[`llo',`cc'],`BB'[`ulo',`cc'])
        }
		if `cc' == 1 {
			mata : `__CIB' = `__CIBI'
		}
		else {
			mata : `__CIB' = (`__CIB' \ `__CIBI')
		}
	}
	mata : st_matrix("`cip'", `__CIB')
    mata : mata drop `__CIB' `__CIBI'
end

**************************************************************************************************************
** DE-FACTOR-VARIABLERIZE VARLIST ****************************************************************************
**************************************************************************************************************
capture program drop defvar
program defvar, rclass
    syntax varlist(fv)
    local fvl "`varlist'"
	local dfvl ""
    foreach fo in "##" "#" {
    	local fvl : subinstr local fvl "`fo'" " ", all
    }
	while "`fvl'" != "" {
		gettoken fi fvl : fvl, parse(" ") bind
		gettoken ll rr : fi, parse(".") bind
		if `c(stata_version)' < 14.2 {
			local str "str"
		}
		else {
			local str "ustr"
		}
		if `str'len("`rr'") != 0 {
			local dfvl "`dfvl' `rr'"
		}
		else {
			local dfvl "`dfvl' `fi'"			
		}
	}
	local dfvl : subinstr local dfvl "(" "", all
    local dfvl : subinstr local dfvl ")" "", all
    local dfvl : subinstr local dfvl "." "", all
    local dfvl : list uniq dfvl
    return local dfvl "`dfvl'"
end
*************************************************************************************************************
** HANDLE PLUGIN te_radial **********************************************************************************
*************************************************************************************************************
capture program drop handleplugin
program handleplugin, nclass
    local os "upper(substr("`c(os)'",1,3))"	
    local vers = c(stata_version)
    if `vers' >= 12 {
    	local bit = c(bit)
    	*display `bit'
    }
    if `os' == "MAC" {
        cap findfile te_radial.plugin
    }
    else if `os' == "UNI" {
    	local mach "upper(substr("`c(machine_type)'",1,3))"
    	if `mach' == "MAC" {
    		cap findfile te_radial.plugin
    	}
    	else {
    		cap findfile te_radial_ubuntu.plugin
    	}
    }
    else if `os' == "WIN" {
    	if `vers' >= 12 {
    		if `bit' == 64 {
    			cap findfile te_radial_windows.plugin
    		}
    		else {
    			cap findfile te_radial_windows32.plugin
    		}
    	}
    	else {
    		cap findfile te_radial_windows32.plugin
    	}
    }
    else {
    	display as error "{p 0 2 2 `ls'}plugin to solve linear programming problem is not available for your system; contact developers{p_end}"
    	exit 199
    }
    if _rc == 0 {
        capture program te_radial, plugin using ("`r(fn)'")
    }
    else {
    	display as error "{p 0 2 2 `ls'}plugin to solve linear programming problem not found; check if teradial and the associated plugins are installed on your machine{p_end}"
        exit 199
    }
end
**********************************************************************************************
** RETURN RESULTS IN r() *********************************************************************
**********************************************************************************************
capture program drop putr
program putr, rclass
    args tabout levelout
    mat `tabout' = `tabout''
    mat rownames `tabout' = be se t pvalue ll ul
    return clear
    return matrix table = `tabout'
    return scalar level = `levelout'
end
