*! extension of Stata Corp. simulate
*! Version 1.01 - 23.10.2019
*! by Jan Ditzen - www.jan.ditzen.net
/* changelog
To version 1.01
	- 21.10.2019: 	- bug in setting seed options fixed
*/


program simulate2
        version 16
        local version : di "version " string(_caller()) ", missing:"
		
		local startframe "`c(frame)'"
		
        // <my_stuff> : <command>
        _on_colon_parse `0'
		local 0 `"`s(after)'"'
        local before `"`s(before)'"'
		
		syntax [anything] , [parallel(string) *]
		
		if "`parallel'" != "" {
			psimulate2 `before' : `options'
			exit
		}
		
		local command `0'
		local 0 `before'
		syntax [anything(name=exp_list equalok)]        ///
                [fw iw pw aw] [if] [in] [,              ///
                        Reps(integer -1)                ///
                        SAving(string)                  ///
                        DOUBle                          /// not documented
                        noLegend                        ///
                        Verbose                         ///
                        SEED(string)                    /// not documented
                        TRace                           /// "prefix" options                       
						/// simulate2 options
						SEEDSave(string)				/// seed save option
						perindicator(string)			/// save every x-th file as indicator for progress
						/// rest
						 *                               ///
                ]
		_get_dots_option, `options'
        local dots `"`s(dotsopt)'"'
        local nodots `"`s(nodots)'"'
        local noisily `"`s(noisily)'"'
        local options `"`s(options)'"'

        if `"`options'"' != "" {
                local 0 `", `options'"'
                syntax [, NOTANOPTION]
                error 198       // [sic]
        }

        if "`weight'" != "" {
                local wgt [`weight'`exp']
        }

        // parse the command and check for conflicts
        `version' _prefix_command simulate `wgt' `if' `in' : `command'
		local version   `"`s(version)'"'
        local cmdname   `"`s(cmdname)'"'
        local command   `"`s(command)'"'

        local exclude simul simulate sem
        if `:list cmdname in exclude' {
                di as err "`cmdname' is not supported by simulate"
                exit 199
        }
        
        if "`trace'" != "" {
                local noisily   noisily
                local traceon   set trace on
                local traceoff  set trace off
        }

        local star = cond("`nodots'"=="nodots", "*", "_dots")
        local noi = cond("`noisily'"=="", "*", "noisily")

        // preliminary parse of <exp_list>
        _prefix_explist `exp_list', stub(_sim_)
        local eqlist    `"`s(eqlist)'"'
        local idlist    `"`s(idlist)'"'
        local explist   `"`s(explist)'"'
        local eexplist  `"`s(eexplist)'"'
		
		// indicator
		if `"`perindicator'"' != "" {
			local 0 `perindicator'
			syntax [anything], [performid(integer 1) perfomnums(integer 100) perindicpath(string)]
			local perfomnums = ceil(`reps'/`perfomnums')
			local perfomnumsi = `perfomnums'
			
			if "`perindicpath'" == "" {
				local perindicpath "`c(tmpdir)'"
			}
		}
		local 0 
		
		// set the seed
		/* seeds have to be set the following:
		set rng
		set stream
		set seed
		*/
		local seedtype = 0
        if "`seed'" != "" {
			local 0 `seed'
			syntax anything , [frame dta start(integer 1)]
			if wordcount("`frame' `dta'") == 2 {
				di as err "options frame and dta cannot be combined"
				exit 184
			}
			
			local seedstart = `start'
			
			if "`frame'`dta'" == "" {
				tokenize `anything'				
                
				if "`2'" != "" {
					set rng `2'
				}				
				if "`3'" != "" {
					set rngstream `3'
				}				
				if "`1'" != "."  {
					cap `version' set seed `1'
					cap `version' set rng `1'
				}				
				
				local rng `c(rng_current)'`version' set seed `1'
				local seed `c(rngstate)'
				local seedstream `c(rngstream)'
				
				local seedtype = 1
			}
			else {
				local seedtype = 2
				*** Assign variables and frame for seeds and seed stream
 				if "`frame'" != "" { 
					tokenize `anything'
					local seedframe `1'
					local seedvar `2'
					local seedrng `3'
					local seedstream `4'
					
				}
				else if "`dta'" != "" {
					local currentframe "`c(frame)'"
					tokenize `anything'
					local dta "`1'"
					local seedvar `2'
					local seedrng `3'
					local seedstream `4'
					
					tempname seedframe
					
					frame create `seedframe'
					frame change `currentframe'
					cap frame `seedframe' : use "`dta'"
					if _rc != 0 {
						noi disp "file `dta' not found."
						exit 601
					}			
				}
				*** check that number of seeds >= runs
				frame `seedframe': local numseeds = _N
				
				if `numseeds' < `=`reps'+`seedstart'-1' {
					di as error "Replications (`reps') larger than numbers of seeds (`numseeds') and starting seed (`seedstart')."
					exit
				}
				
				cap frame `seedframe' : confirm var `seedvar' 
				if "`seedvar'" == "" | _rc != 0 {
					di as error "no variable defined in frame `seedframe'."
					exit 111
				}
			
				frame `seedframe': local seedi =`seedvar'[`seedstart']
				
				cap frame `seedframe' : confirm var `seedstream' 
				if "`seedstream'" == "" | _rc != 0 {
					di "no seedstream defined, set to 1"
					local seedstreami = 1
				}
				else {
					frame `seedframe': local seedstreami =`seedstream'[`seedstart']
				}
				
				cap frame `seedframe' : confirm var `seedrng' 
				if "`seedrng'" == "" | _rc != 0 {
					local seedrngi default
				}
				else {
					frame `seedframe': local seedrngi =`seedrng'[`seedstart']
				}					
				
				local seed `seedi'
				
				** set mt64s for seedstreams
				qui{
					set rng `seedrngi'
					if "`rng'" == "mt64s" {
						** only set seed stream if mt64s is used
						set rngstream `seedstreami'
					}
					
									
					if "`seedrngi'" == "default" {
						local rngname rngstate
					}
					else {
						local rngname rngstate_`seedrngi'
					}
					set `rngname' `seedi'	
					
				}				
			}	
			
        }
        
		local framesavetype = 0
		if "`seedsave'" != "" {			 
			local currentframe "`c(frame)'"
		
			local 0 `seedsave'
			syntax anything , [frame seednumber(integer 1) append]
			
			local startsave = 1
			if "`frame'" != "" {
				if "`append'" != "" {					
					tempname framesave
					local framesavetype = 3
					local frametoappend `anything'	
					if `seednumber' ==  1 {
						frame `frametoappend' : local seednumber = _N + 1					
					}
				}
				else {
					local framesave `anything'				
					local framesavetype = 1	
				}
					
			}
			else {
				tempname framesave
				local framesavetype = 2
				local framesavepath "`anything'"				
			}
			
			cap frame drop `framesave'
			qui frame create `framesave' strL(seed rng) double(seedstream run)
			qui frame `framesave': set obs `reps'
			qui frame `framesave': replace seed = "`c(rngstate_`c(rng_current)')'" in `startsave'
			qui frame `framesave': replace seedstream = `c(rngstream)' in `startsave'
			qui frame `framesave': replace rng = "`c(rng_current)'" in `startsave'
			qui frame `framesave': replace run = `seednumber' in `startsave'
			frame change `currentframe'
		}	

        `noi' di as inp `". `command'"'

        // run the command using the entire dataset
        _prefix_clear, e r
        `traceon'
        capture noisily quietly `noisily'               ///
                `version' `command'
        `traceoff'
        local rc = c(rc)
        // error occurred while running on entire dataset
        if `rc' {
                _prefix_run_error `rc' simulate `cmdname'
        }
		
		** get macro names in r() and e()
		local rmacro : r(macros)
		local emacro : e(macros)		
		local K_macro = 0
		
		// determine default <exp_list>, or generate an error message
        if `"`exp_list'"' == "" {
                _prefix_explist, stub(_sim_) default
                local eqlist    `"`s(eqlist)'"'
                local idlist    `"`s(idlist)'"'
                local explist   `"`s(explist)'"'
                local eexplist  `"`s(eexplist)'"'
				
				*** add macros; if e() empty then add macros in r()				
				if "`emacro'" != "" {
					tokenize `emacro'
					while "`1'" != "" {
						local idlistmacro "`idlistmacro' `1'"
						local eexplistmacro "`explistmacro' (e(`1'))"
						local coleqmacro `"`coleqmacro' "_""'
						local ++K_macro
						macro shift
					}
				}
				else if "`rmacro'" != "" {
					tokenize `rmacro'
					while "`1'" != "" {
						local idlistmacro "`idlistmacro' `1'"
						local explistmacro "`explistmacro' (r(`1'))"
						local coleqmacro `"`coleqmacro' "_""'
						local ++K_macro
						macro shift
						
					}
				}
        }
		else {
			*** check that macro names are not part of explist
			foreach mac in `rmacro' {
				local macropr "`macropr' (r(`mac'))"
			}
			foreach mac in `emacro' {
				local macrope "`macrope' (e(`mac'))"
			}
			
			local macrop "`macropr' `macrope'"

			*** remove ids for macros from idlist			
			local explistmacro: list explist & macropr
			local eexplistmacro: list explist & macrope
			
			local allexp `explist' `eexplist'
			local idlistmacro
			local K_macro = 0
			
			foreach expi in `explistmacro' `eexplistmacro' {
				local pos: list posof "`expi'" in allexp
				local temp = word("`idlist'",`pos')
				local idlistmacro "`idlistmacro' `temp'"
				
				local coleqmacro `"`coleqmacro' "_""'
				local ++K_macro 
				
			}
			
			local idlist: list idlist - idlistmacro			
			local explist : list explist - macrop
			
		}

		// expand eexp's that may be in eexplist, and build a matrix of the
        // computed values from all expressions
		// explist can be empty
        tempname b
        _prefix_expand `b' `explist',           ///
                stub(_sim_)                     ///
                eexp(`eexplist')                ///
                colna(`idlist')                 ///
                coleq(`eqlist')                 ///
                // blank
			
		local k_eq      `s(k_eq)'
        local k_exp     `s(k_exp)'
        local k_eexp    `s(k_eexp)'
        local K = `k_exp' + `k_eexp' 
        local k_extra   `s(k_extra)'
        local names     `"`s(enames)' `s(names)'"'
        local express   `"`s(explist)'"'
        local coleq     `"`s(ecoleq)' `s(coleq)'"'
        local colna     `"`s(ecolna)' `s(colna)'"'

		forval i = 1/`K' {
                local exp`i' `"`s(exp`i')'"'
        }

		** add macros to exp, express, coleq as "_" and colna, do not add to names as differentiation necessary
		local colna `"`colna' `idlistmacro'"'
		local coleq `"`coleq' `coleqmacro'"'
		local express `"`express' `eexplistmacro' `explistmacro'"'

		forvalues i = `=`K'+1'/`=`K'+`K_macro'' {
			local exp`i' `"`=word("`eexplistmacro' `explistmacro'",`=`i'-`K'')'"'
		}
		
        local legopts   command(`command')      ///
                        egroup(`s(ecoleq)')     ///
                        enames(`s(ecolna)')     ///
                        group(`s(coleq)')       ///
                        names(`s(colna)')       ///
                        express(`express')      ///
                        `noisily' `verbose'

        // check options
        if `reps' < 1 {
                di as err "reps() is required, and must be a positive integer"
                exit 198
        }
        if `"`saving'"'=="" {
                tempfile saving
                local filetmp "yes"
        }
        else {
                prefix_saving_sim2 `saving'
                local saving    `"`s(filename)'"'
                if "`double'" == "" {
                        local double    `"`s(double)'"'
                }
                local every     `"`s(every)'"'
                local replace   `"`s(replace)'"'
				local saveframe `"`s(frame)'"'
				local saveappend `"`s(append)'"'
				if "`saveappend'" != "" {
					local replace replace
				}
        }

        // setup list of missings
        forvalues i = 1/`=`K'+`K_macro'' {
                local mis "`mis' (.)"
        }

        // temp variables for post
        forvalues i = 1/`=`K'+`K_macro'' {
                tempname x`i'
        }

        // this must be done before another command that saves in r() or e()
        // can be run
        forvalues i = 1/`K' {
                scalar `x`i'' = `b'[1,`i']
        }
		forvalues i = `=`K'+1'/`=`K'+`K_macro'' {
			local expi = word("`eexplistmacro' `explistmacro'",`=`i'-`K'')
			scalar `x`i'' = `expi'
		}
		
        local sims
        forvalues i = 1/`=`K'+`K_macro'' {
                local sims "`sims' (`x`i'')"
        }

        // check to see if final dataset will fit in memory
        if c(max_N_current)-20 < `reps' {
                di as err "insufficient memory (observations)"
                exit 901
        }

        if "`legend'" == "" {
                _prefix_legend simulate, `legopts'
        }

		local postnam simulate2_frame
		frame change default
		capture frame drop `postnam'
		frame create `postnam' double(`names') strL(`idlistmacro')
		frame post `postnam' `sims'		
      
        di
        if "`nodots'" == "" | "`noisily'" != "" {
                _dots 0, title(Simulations) reps(`reps') `nodots' `dots'
        }
		
		*** run first performance check
		if "1" == "`perfomnumsi'" {
			qui mata p2sim_performance = 1 , `reps'
			qui mata mata matsave "`perindicpath'/psim2_performance_`performid'" p2sim_performance , replace						 
			local perfomnumsi = `perfomnumsi' + `perfomnums'
		}
		
		
        `star' 1 0 , `dots'
        forvalues i = 2/`reps' {
				
				*** set seed
				if `seedtype' == 2 {
					local seedsj = `seedstart' - 1 + `i'
					frame `seedframe': local seedi  = `seedvar'[`seedsj']
					frame `seedframe': local seedstreami  = `seedstream'[`seedsj']
					frame `seedframe': local seedrngi  = `seedrng'[`seedsj']
					
					qui{
						if "`seedrng'" == "" {
							local seedrngi default
						} 
						set rngstream `seedstreami'
						set rng `seedrngi'
						
						if "`seedrngi'" == "default" {
							local rngname rngstate
						}
						else {
							local rngname rngstate_`seedrngi'
						}
						set `rngname' `seedi'	
					}					
				}
				
				if `framesavetype' > 0 {
					qui frame `framesave': replace seed = "`c(rngstate_`c(rng_current)')'" in `=`startsave'-1+`i''
					qui frame `framesave': replace seedstream = `c(rngstream)' in `=`startsave'-1+`i''
					qui frame `framesave': replace rng = "`c(rng_current)'" in `=`startsave'-1+`i''
					qui frame `framesave': replace run = `seednumber' - 1 + `i' in `=`startsave'-1+`i''
				}
				
                `noi' di as inp `". `command'"'
                `traceon'
                capture `noisily' `version' `command'
                `traceoff'
				if (c(rc) == 1) error 1
                local bad = c(rc) != 0
                if c(rc) {
                        `noi' di in smcl as error ///
`"{p 0 0 2}captured error running (`command'), posting missing values{p_end}"'
                        capture noisily frame post `postnam' `mis'
                        if (c(rc) == 1) error 1
                        local rc = c(rc)
                }
                else {
                        forvalues j = 1/`K' {
                                capture scalar `x`j'' = `exp`j''
                                if (c(rc) == 1) error 1
                                if c(rc) {
                                        local bad 1
                                        `noi' di in smcl as error ///
`"{p 0 0 2}captured error in `exp`j'', posting missing value{p_end}"'
                                        scalar `x`j'' = .
                                }
                                else if missing(`x`j'') {
                                        local bad 1
                                }
                        }
						 forvalues j = `=`K'+1'/`=`K'+`K_macro'' {
								capture scalar `x`j'' = `exp`j''
								if (c(rc) == 1) error 1
								if c(rc) {
										local bad 1
										`noi' di in smcl as error ///
	`"{p 0 0 2}captured error in `exp`j'', posting missing value{p_end}"'
										scalar `x`j'' = ""
								}
								else if missing(`x`j'') {
										local bad 1
								}
                        }
						capture noisily frame post `postnam' `sims'
                        local rc = c(rc)
                }
                if `rc' {
                        di as err ///
"this error is most likely due to {cmd:clear} being used within: `command'"
                        exit `rc'
                }
				
				if `"`perindicator'"' != "" {
					if `i' == `perfomnumsi' {
						qui mata p2sim_performance = `i', `reps'
						cap qui mata mata matsave `"`perindicpath'/psim2_performance_`performid'"' p2sim_performance , replace
						if _rc != 0 {
						sleep 50
							cap qui mata mata matsave `"`perindicpath'/psim2_performance_`performid'"' p2sim_performance , replace
						}
						local perfomnumsi = `perfomnumsi' + `perfomnums'
					}
				}				
				
                `star' `i' `bad' , `dots'
        }
        `star' `reps' , `dots'

        *postclose `postnam'
		clear	
		qui {
			frame change `postnam'
			frame drop `startframe'
			frame copy `postnam' `startframe', replace
			frame change `startframe'		
			frame drop `postnam'
		}
       * capture use `"`saving'"', clear
       * if c(rc) {
       *         if 900 <= c(rc) & c(rc) <= 903 {
        *                di as err ///
*"insufficient memory to load file with simulation results"
 *               }
  *              error c(rc)
   *     }

        label data `"simulate: `cmdname'"'
        char _dta[command] `"`command'"'
        if _caller() < 14 {
                char _dta[seed] `"`seed'"'
        }
        else {
                char _dta[rngstate] `"`seed'"'
        }

        // save labels to data set
        forvalues i = 1/`K' {
                local name : word `i' of `names'
                local label = usubstr(`"`exp`i''"',1,80)
                label variable `name' `"`label'"'
                char `name'[expression] `"`exp`i''"'
                if `"`coleq'"' != "" {
                        char `name'[colname]
                        local na : word `i' of `colna'
                        local eq : word `i' of `coleq'
                        char `name'[coleq] `eq'
                        char `name'[colname] `na'
                        if `i' <= `k_eexp' {
                                char `name'[is_eexp] 1
                        }
                }
        }
        if "`filetmp'"!="" {
                global S_FN
        }
        else {
                if "`saveframe'" == "" {
					if "`saveappend'" != "" {
						cap append using `"`saving'"', force
					}
					quietly save `"`saving'"', replace
				}
				else {
					if "`saveappend'" != "" {
						tempfile frameappend
						qui frame `saving': save `frameappend', replace
						append using `frameappend'
					}
					cap frame drop `saving'
					frame create  `saving'
					frame copy `c(frame)' `saving'	, replace				
				}
        }
		
		if `"`perindicator'"' != "" {
			qui mata p2sim_performance = `reps', `reps'
			qui mata p2sim_lastseed = "`c(rngstate)'" , "`c(rngseed_mt64s)'"
			qui mata p2sim_lastrng = "`c(rng_current)'"
			
			cap qui mata mata matsave "`perindicpath'/psim2_performance_`performid'" p2sim_performance p2sim_lastseed p2sim_lastrng, replace
			if _rc != 0 {
				local try = 0
				while _rc != 0 & `try' < 100 {
					cap qui mata mata matsave "`perindicpath'/psim2_performance_`performid'" p2sim_performance p2sim_lastseed p2sim_lastrng,  replace
					sleep 100
				}
			}
		}				
				
		if `framesavetype' == 2 {
			if "`append'" != "" {
				tempfile toappend
				frame `framesave' : save `toappend', replace
				frame create `toappend'
				frame `toappend': use  "`framesavepath'", replace
				frame `toappend': append using `toappend', force
				frame `toappend' : save "`framesavepath'", replace
			}
			else {
				frame `framesave' : save "`framesavepath'", replace
				frame drop `framesave'	
			}
		}
		else if `framesavetype' == 3 {
			tempfile toappend
			frame `framesave' : save `toappend', replace
			frame `frametoappend': append using `toappend', force		
		}
	
end


program prefix_saving_sim2, sclass
        version 16
        capture noisily                                 ///
        syntax anything(id="file name" name=fname) [,   ///
                DOUBle                                  ///
                EVery(integer 0)                        ///
                REPLACE                                 ///
				frame									///
				append									///
        ]
        local rc = `c(rc)'
        if !`rc' {
                if `every' < 0 {
                        di as err ///
"suboption every() of the saving() option requires a positive integer"
                        local rc 198
                }
                if "`replace'" == "" & "`append'" == "" & "`frame'" == "" {
                        local ss : subinstr local fname ".dta" ""
                        confirm new file `"`ss'.dta"'
                }
        }
        if `rc' {
                di as err "invalid saving() option"
                exit `rc'
        }
        sreturn local filename  `"`fname'"'
        sreturn local double    `"`double'"'
        sreturn local replace   `"`replace'"'
		sreturn local frame   `"`frame'"'
		sreturn local append `"`append'"'
        if `every' {
                sreturn local every every(`every')
        }
end
exit

