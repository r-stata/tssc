*! version 2.0.3 17dec2019 MJC

/*
History
MJC 17dec2019: version 2.0.3 - bug: from(), apstartvalues(), restartvalues() and zeros options were not passed to merlin; now fixed
MJC 22aug2019: version 2.0.2 - help file edits
MJC 26jul2019: version 2.0.1 - post-est help file edits
MJC 30jun2019: version 2.0.0 - now parses to merlin
							 - now needs version 14.2
MJC 02jun2014: version 1.0.1 - ln_gamma changed to ln_p when Weibull model fitted
							 - random effects table variable labels were incorrect when random covariate effects were specified, now fixed
							 - likelihoods in stmixed now made comparable to streg exp/weib/gomp models and stpm2
							 - help file description improved
							 - warning added when only 1 random effect detected -> assumes identity
MJC 23may2014: version 1.0.0
*/

program stmixed, eclass sortpreserve properties(st)
	version 14.2
	if replay() {
		if (`"`e(cmd2)'"'!="stmixed") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Estimate, eclass
	st_is 2 analysis
	
	cap which merlin
	if _rc {
		di as error "stmixed requires merlin, type: ssc install merlin"
		exit 198
	}
	
	// model opts
		local modelopts `"Distribution(string)"'
		local modelopts `"`modelopts' BHazard(passthru)"'
		local modelopts `"`modelopts' COVariance(passthru)"'
		local modelopts `"`modelopts' DF(passthru)"'
		local modelopts `"`modelopts' KNOTS(passthru)"'
		local modelopts `"`modelopts' TVC(varlist)"'
		local modelopts `"`modelopts' DFTvc(string)"'
		local modelopts `"`modelopts' KNOTSTvc(string)"'
		local modelopts `"`modelopts' NOORTHog"'
		
		
		local modelopts `"`modelopts' LLFunction(passthru)"'
		local modelopts `"`modelopts' LOGHFunction(passthru)"'
		local modelopts `"`modelopts' HFunction(passthru)"'
		local modelopts `"`modelopts' CHFunction(passthru)"'
		local modelopts `"`modelopts' NAP(passthru)"'
		
	//Max opts
		local modelopts `"`modelopts' INTPoints(passthru)"'
		local modelopts `"`modelopts' INTMethod(passthru)"'	
		local modelopts `"`modelopts' FROM(passthru)"'				
		local modelopts `"`modelopts' RESTARTVALues(passthru)"'
		local modelopts `"`modelopts' APSTARTValues(passthru)"'
		local modelopts `"`modelopts' ZEROS"'
		local modelopts `"`modelopts' ADAPTopts(passthru)"'
		
	// mlopts
        local mlopts `"NONRTOLerance NRTOLerance(string)"'
        local mlopts `"`mlopts' TRace GRADient HESSian showstep"'
        local mlopts `"`mlopts' TECHnique(string) SHOWNRtolerance"'
        local mlopts `"`mlopts' ITERate(string) TOLerance(string)"'
        local mlopts `"`mlopts' LTOLerance(string) GTOLerance(string)"'
        local mlopts `"`mlopts' DIFficult dots depsilon(passthru) showh"'
	
	//Display opts
		local modelopts `"`modelopts' Level(passthru)"'
		local modelopts `"`modelopts' NOLOG"'
		local modelopts `"`modelopts' SHOWMERLIN"'
			
	//Undocumented for use by predict and parsing check
		local modelopts `"`modelopts' debug"'
		
		local globallow `"`modelopts' `mlopts'"'
		local cmdline `0'
		
	//parse
	
		_parse expand cmd glob : 0 , common(`globallow')
		
        forvalues k = 1/`cmd_n' {              
			local cmds `"`cmds' `"`cmd_`k''"'"'
        }
        _mixed_parseifin stmixed `=`cmd_n'+1' `cmds' `"`glob_if' `glob_in'"'

		local ifin if _st==1 
		if "`glob_if'"!="" local ifin `ifin' & `glob_if'
		if "`glob_in'"!="" local ifin `ifin' & `glob_in'
		
	//global options are in glob_op 
	//parse model options

		local 0 `", `glob_op'"'
        syntax [ , `modelopts' *]

		//family
		
			//delayed entry
			qui su _t0 `merlinif', meanonly
			if `r(max)'>0 {
				local ltruncated ltruncated(_t0)
				di as text "note; a delayed entry model is being fitted"
			}
			
			if "`distribution'"=="user" {
				local userfunc `llfunction'`loghfunction'`hfunction' `chfunction'
			}
			
			//final family
			local family family(`distribution', failure(_d) `userfunc' `bhazard' `ltruncated' `df' `knots' `noorthog')
		
		//parse mlopts
		mlopts mlopts , `options'
							
							
	//==================================================================================================================================//
	// build complex predictor
		
		local Mind = 1
		
		//level 1 can be parsed straight off
		fvexpand `cmd_1'							//handles var1-var15 etc
		local merlincp `r(varlist)'
		
		//tvcs
		if "`tvc'"!="" {
			
			if "`dftvc'"=="" & "`knotstvc'"=="" {
				di as error "dftvc() or knotstvc() required"
				exit 198
			}
			
			if "`dftvc'"!="" 	local tvck df(`dftvc')
			else 				local tvck knots(`knotstvc')
			
			foreach var in `tvc' {
				local merlincp `merlincp' `var'#rcs(_t, `tvck' log orthog)
			}
		
			local timevar timevar(_t)
		}
		
		//random effects
		forval lev=2/`cmd_n' {
		
			//extract level var
			gettoken levvar rest : cmd_`lev', parse(":")
			gettoken colon rest : rest 		, parse(":")
			if `"`colon'"' == `":"' {
				local lev = trim("`levvar'")
				if "`levvar'" != "_all" {
					confirm variable `levvar'
				}
				else {
					di as error "_all not supported"
					exit 198
				}
			}
			else {
				di as err "{p 0 6 2}invalid random-effects "
				di as err "specification; perhaps you omitted the "
				di as err "colon after the level "
				di as err "variable{p_end}"
				exit 198
			}
		
			local levelvars `levelvars' `levvar'
			local lev`lev' = subinstr("`levelvars'"," ",">",.)
			
			//random effects
			local 0 `rest'
			syntax [varlist(numeric default=none)] [, NOConstant]

			if ("`noconstant'"!="" & "`varlist'"=="") {
				di as error "No random effects have been specified at level `levvar':"
				exit 198
			}
			if "`noconstant'"=="" {
				local merlincp `merlincp' M`Mind'[`lev`lev'']@1
				di as text "Random effect M`Mind': Intercept at level `levvar'"
				local Mind = `Mind' + 1
			}
			
			local Nvars : word count of `varlist'
			foreach var in `varlist' {
				local merlincp `merlincp' `var'#M`Mind'[`lev`lev'']@1
				di as text "Random effect M`Mind': `var' at level `levvar'"
				local Mind = `Mind' + 1
			}
			
		}

	//==============================================================================================================================================//
	// merlin
			
		if "`debug'"!="" {
			di "`merlincp'"
			di "`family'"
		}
		
		if "`showmerlin'"!="" {
			di "merlin 	(_t	`merlincp', `family' `timevar') `merlinif' , `mlopts' `covariance' `intmethod' `intpoints' `from' `debug' `restartvalues'	`nolog'	`adaptopts'	`level'"
		}
		di "`restartvalues'"
		merlin 	(_t	`merlincp', `family' `timevar')		///
				 `ifin' ,	 							///
				 excalibur								///
				`mlopts'								///
				`covariance' `intmethod' 				///
				`intpoints' `from' `debug'				///
				`restartvalues'	`nolog'	`adaptopts'		///
				`level' `zeros' `restartvalues' 		///
				`apstartvalues'			

		ereturn local cmd2 stmixed
		ereturn local cmdline2 stmixed `cmdline'

end

program Replay
	merlin `0'
end
