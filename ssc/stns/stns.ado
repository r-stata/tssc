*! version 1.4.4 15may2014
program  stns 
version 11, missing
        if replay() {
          Playback `0'
        }
        else {
          next_stns `0'
        }
end

program  next_stns, eclass sort
st_is 2 analysis
local cmdline `0'
gettoken cmd : 0, parse(" ,")
local subcmd `cmd'
if `"`cmd'"'=="," | "`cmd'"=="" {
  local cmd list
}
else	gettoken cmd 0 : 0, parse(" ,")
local l = length("`cmd'")
if substr("sum",1,`l')==`"`cmd'"' {
  Summary `0'
}
if substr("list",1,`l')==`"`cmd'"' {
  List `0'
}
else if substr("graph",1,`l')=="`cmd'" {
  Graph `0'
}
else if substr("generate",1,`l')=="`cmd'" {
  Gen `0'
}
else if substr("test",1,`l')=="`cmd'" {
  Test `0'
}
else if "`cmd'"=="if" | "`cmd'"=="in" {
  List `cmd' `0'
}
else {
  di in red "unknown stns subcommand `cmd'"
  exit 198
}
ereturn local cmd `"stns"'
ereturn local cmdline `"stns `0'"'
ereturn local subcmd `"`subcmd'"'
end

program define Playback
if "`e(cmd)'" != "stns" {
  error 301
}
List `0'
end


program define Graph
	.__stsutil = .sts_graph_util.new
	.__stsutil.setOriginalArgs `"`0'"'

	capture noisily Graph_wrk `0'
	local rc = _rc
	if ! `rc' {
	    capture noisily {
		if `.__stsutil.doPostGraphAdjustments, dryrun' {
			if `.__stsutil.getNoDraw' {
				version 10 : display as error		///
					"{opt nodraw} may not be "	///
					"combined with options that "	///
					"cause title auto alignment"
				exit 198
			}
			version 10 : .`.__stsutil.getGraphName'.drawgraph, ///
				nomaybedraw `.__stsutil.getSizeOpts'
			.__stsutil.doPostGraphAdjustments
		}
		if ! `.__stsutil.getNoDraw' {
			version 10 : gr display `.__stsutil.getGraphName', ///
				`.__stsutil.getSizeOpts'
		}
	    }
	    local rc = _rc
	}
	classutil drop .__stsutil
	exit `rc'
end

program define Graph_wrk
if replay(){
  Do_Graph `0'
}
else {
  Estimate `0' /* same estimate as fo list */
/* get graph options */
   syntax using/ [if] [in] [, age(string) period(string)        ///
                            STrata(string asis) 		/// e
                            rate(name)                            ///
                            TYpe(string)        		/// e
                            interpolate(integer 1)     /// e
                            interpage(integer 1) interpdate(integer 1) /// e
                            strictage strictdate       /// e
                            END_followup(string)    /// e
                            AT(string asis)			/// re
                            noSHow					///	rg
                            noDETail					///	rg
                            BEGINtime(string) 			/// re
                            * ]    /* for graph options, ... */

  Do_Graph , `options' noshow
}

end

program Do_Graph
	syntax  ,  [				///
		SURvival 				///	rc the default
		Failure					///	rc abbrev. (backward compatibility)
		Hazard 					///	rc
		CUMHaz					///	rc synonym for na
		NA						///	rc deprecated synonym for cumhaz
		CI						///	rc
		Gwood					///   synonym for ci
		CIHazard 				///   ci for hazard
		CNA						///   ci for cumhazard
        CITYpe(string) 	        /// rcg    
		Level(cilevel)			///	rcg		
		CENsored(string)		///	rg
		CENSOpts(string asis)	///	rg
		END_followup(string)    /// e
		ATRisk					///	rg		
		noORIgin				///	rg
		noSHow					///	rg
		LOst					///	rg
        BY(varlist)				/// 
		SEParate				///	rg
		TMIn(real -1)			///	rg
		TMAx(real -1)			///	rg
		TRim(integer 32)		///	rg
		per(real 1.0)			///	rg
		YLOg					///	rg
///*		YLABel(string)          ///	rg
		YMIn(real -1)			///	rg
		YMAx(real -1)			///	rg
		Kernel(string)          ///	rg
		width(string)			///	rg
		noBoundary				///	rg
		OUTfile(string)			///	rg undocumented
		LEFTBOUNDARY(real -1)	///	rg undocumented
		NAME(passthru)			///	rg
		NODRAW					///	rg
		XAXis(passthru)			///	rg
		XSIZe(passthru)			///	rg
		YSIZe(passthru)			///	rg
		ASPECTratio(passthru)	///	rg
		*						///	rg
	]

/* enter not inmplemanted
		Enter					///	rg 
*/

        local enter
        if `"`by'"' != "" & (`"`by'"' != `"`e(by)'"' ) {
		display as error		///
			"option by() is not the same as e(by)"
		exit 198
	}
        if `"`by'"' == "" & (`"`e(by)'"' != "") {
          local by `e(by)'
	}


	_gs_byopts_combine byopts options : `"`options'"'

	.__stsutil.setNoDraw `nodraw'
	
	if `.__stsutil.getItteration' == 1 {
		.__stsutil.setSizeOpts `xsize' `ysize'
		
		if `"`name'"' != "" {
			local gname `.__stsutil.parseGraphName, `name''
		}
		else {
			local gname Graph
		}		
		.__stsutil.setGraphName `gname'
	}
	
	if `.__stsutil.getItteration' == 2 {
		if `"`name'"' != "" {
			local name `"name(`.__stsutil.getGraphName', replace)"'
		}
	}

/* parsing */
	local w  : char _dta[st_w]
	local wt : char _dta[st_wt]

	if `"`cumhaz'"' != "" & `"`na'"' != "" {
		// cumhaz and na are synonyms but only one or the other should be used.
		display as error	///
			"options cumhaz and na may not be combined"
		exit 198
	}
	else if `"`na'"' != "" {
	local cumhaz cumhaz
	local na 
	}

	if `"`by'"' == "" & "`separate'" != "" {
		display as error	///
			"option separate requires  by() in stns list command"
		exit 198
	}
	if `"`by'"' == "" & `"`byopts'"' != "" {
		display as error	///
			"option byopts() requires by() in stns list command"
		exit 198
	}
	
	// mutually exclusive functions
	local exclus `"`survival' `failure' `hazard' `cumhaz' `na'"' 
	local optcnt : word count `exclus' 
	if `optcnt' > 1 {
		display as error	///
			"options `:word 1 of `exclus'' "	///
			"and `:word 2 of `exclus'' may not be combined"
		exit 198
	}
	else if `optcnt' ==0 {
		local survival survival
	}

	// mutually exclusive confidence intervals
	local exclus `"`ci' `gwood' `cna' `cihazard'"'
	local optcnt : word count `exclus'
	if `optcnt' > 1 {
		display as error					///
			"options `:word 1 of `exclus''"	///
			"and `:word 2 of `exclus'' may mot be combined"
		exit 198
	}

	// implied survival option
	if `"`survival'`failure'`hazard'`cumhaz'`na'"' == "" {
		// only allow deprecated gwood with default survival
		if `"`cihazard'`cna'"' != "" {
			display as error	///
				"option `cihazard'`cna' may not be "	///
				"used with the default survival function"
			exit 198
		}
		// set the default; 
		// surviva needs to be defined for compatibility 
		// with version 6 (macros have max len of 7 characters)
		local surviva survival
	}

	// only allow deprecated gwood with survival or failure
	local exclus `"`survival' `failure' `cna' `cihazard'"' 
	local optcnt : word count `exclus' 
	if `optcnt' > 1 {
		display as error	///
			"options `:word 1 of `exclus'' "	///
			"and `:word 2 of `exclus'' may not be combined"
		exit 198
	}
	
	// only allow deprecated cna with cumhaz or deprecated na
	local exclus `"`na' `cumhaz' `gwood' `cihazard'"' 
	local optcnt : word count `exclus' 
	if `optcnt' > 1 {
		display as error	///
			"options `:word 1 of `exclus'' "	///
			"and `:word 2 of `exclus'' may not be combined"
		exit 198
	}

	// only allow deprecated cihazard with hazard
	local exclus `"`hazard' `gwood' `cna'"' 
	local optcnt : word count `exclus' 
	if `optcnt' > 1 {
		display as error	///
			"options `:word 1 of `exclus'' "	///
			"and `:word 2 of `exclus'' may not be combined"
		exit 198
	}

	if `"`cumhaz'"' != "" {
		// stick with -na- for backward compatibility
		local na na 
	}

	// handle ci backwards compatibility
	if `"`survival'`failure'"' != "" & `"`ci'"' != "" {
		local gwood gwood
	}
	if `"`cumhaz'`na'"' != "" & `"`ci'"' != "" {
		local cna cna
	}
	if `"`hazard'"' != "" & `"`ci'"' != "" {
		local cihazard cihazard
	}

	if `"`separate'"' != "" {
		local separat set
	}
	else {
		local separat
	}
	
	/* .sts_graph_util.parseRiskTable should be called on both passes
	 * because it performs tasks that are unique each time.
	 * ... non risk table options can be extracted each after pass, but
	 * options for creating the risk table are only available after calling
	 * .sts_graph_util.parseRiskTable during the second pass.
	 */

	.__stsutil.parseRiskTable  , `options'
	local gropts `.__stsutil.getNotRiskTableOpts'

	if `"`separat'"' != "" & `.__stsutil.hasRiskTable' {
		display as error	///
			"options separate and risktable may not be combined"
		exit 198
	}
	if `"`atrisk'"' != "" & `.__stsutil.hasRiskTable' {
		display as error	///
			"options atrisk and risktable may not be combined"
		exit 198
	}

	if `"`lost'"' != "" & `.__stsutil.hasRiskTable' {
		display as error	///
			"options lost and risktable may not be combined"
		exit 198
	}
	if `"`enter'"' != "" & `.__stsutil.hasRiskTable' {
		display as error	///
			"options enter and risktable may not be combined"
		exit 198
	}

	if `"`aspectr'"' != "" & `.__stsutil.hasRiskTable' {
		display as error	///
			"options aspectratio and risktable may not be combined"
		exit 198
	}	
	
	if `.__stsutil.hasRiskTable' & `.__stsutil.getItteration' == 1 	///
		& "`nodraw'" == "" 					///
	{
		// never draw the first pass
		local rNoDraw nodraw
	}

	local name2 `.__stsutil.parseGraphName , `name''
	_get_gropts , graphopts(`gropts')	///
		grbyable			///
		getallowed(			///
			CIOPts			///
			ATRISKOPts		///
			LOSTOPts		///
			plot			///
			addplot			///
			YSCale			///
		)
	local options `"`s(graphopts)'"'
	local ciopts `"`s(ciopts)'"'
	local atopts `"`s(atriskopts)'"'
	local lstopts `"`s(lostopts)'"'
	local plot `"`s(plot)'"'
	local addplot `"`s(addplot)'"'
	local yscale `"`s(yscale)'"'
	_check4gropts ciopts, opt(`ciopts')

	ParseByOpts , `byopts'
	local bylgnd `"`s(bylgnd)'"'
	local byttl `"`s(byttl)'"'
	local byopts `"`s(byopts)'"'

	if `"`atopts'"' != "" {
		local atrisk atrisk
	}
	if `"`lstopts'"' != "" {
		local lost lost
	}

* get horizontal end veritcal range range 
	ChkYScale4Log , `ylog' `yscale'
	local ylog `s(log)'

/* default ylabel */
        if  `"`ylabel'"' == "" { 
          if "`na'" == "" & "`hazard'"== ""  & "`hratio'"== ""  & "`chratio'" == "" {
            // survival
            // get range in yscale
            ChkYScale4range , `yscale'
            if (`s(nval)' > 0) {
              if (`s(nval)' >=2) {
                local min `s(r1)'
                local max `s(r2)'
              }
              else {
                /// only one value, check if min or max
                if ( `s(r1)' > 1*`per' ){
                  if "`ylog'"!="" {
                    local min 0.01
                  }
                  else {
                    local min 0
                  }
                  local max `s(r1)'
                }
                else {
                  local min `s(r1)'
                  local max 1
                }
              }
              if ("`ylog'"!="") {
                local ylab 
                foreach x of numlist .01 .05 .10 .25 .50 .75 1  {
                  if ( `x'*`per' >= `min' &  `x'*`per' <= `max' ){
                    local xper =  `x'*`per' 
                    local ylab `ylab' `xper' 
                  }
                }
              }
              else {
                local min = ceil(`min'/.25/`per')*.25*`per'
                local max = floor(`max'/.25/`per')*.25*`per'
                local yfact= .25*`per'
                local ylab "`min'(`yfact')`max'" 				
              }
            }
            else {
              if ("`ylog'"!="") {
                local ylab 
                foreach x of numlist .01 .05 .10 .25 .50 .75 1  {
                    local xper =  `x'*`per' 
                    local ylab  `ylab' `xper' 
                }
              }
              else {
                local yfact= .25*`per'
                local ylab "0(`yfact')`per'" 				
              }
            }
            local ylabopt ylabel(\`ylab', grid)
          }
        }
        else {
            local ylabopt
        }

/* put yscale() back in options */
	if `"`yscale'"' != "" & `"`yscale'"' != " " {
		local options `"yscale(`yscale') `options'"'
	}


	if "`hazard'"!=""  {
		display as error	///
	    "options hazard not implemented"
		exit 198

		if `per' != 1.0 {
			di in red "option hazard not allowed with per()"
			exit 198
		}
		foreach x in na cna enter failure gwood ///
			lost atrisk {
			ForbidOpt ``x''
		}
		if `.__stsutil.hasRiskTable' {
			display as error	///
			    "options hazard and risktable may not be combined"
			exit 198
		}
		if `"`censored'"'!="" {
			display as error	///
			    "options censored() and hazard may not be combined"
			exit 198
		}
		local origin noorigin
		local conopt connect(l ...)
	}
	else {
		local conopt connect(J ...)
*		local ylabopt ylabel(\`ylab', grid)
	}

	
	local w  : char _dta[st_w]
	if "`enter'"!="" & "`lost'"=="" {
		local lost="lost"
	}	
	if `level'<10 | `level'>=100 { 
		di in red "level() invalid"
		exit 198
	}
	if `"`kernel'"' != "" {
		if "`hazard'" == "" {
			display as error 	///
				"option kernel() only allowed with hazard"
			exit 198
		}
	}
	if `"`width'"' != "" {
		if "`hazard'" == "" {
			display as error 	///
				"option width() only allowed with hazard"
			exit 198
		}
	}
	if `"`boundary'"' != "" {
		if "`hazard'" == "" {
			display as error 	///
				"option noboundary only allowed with hazard"
			exit 198
		}
	}
	if "`cumhaz'" != "" & `per' != 1.0 {
		display as error	///
			"options cumhaz and per() may not be combined"
		exit 198
	}
	if "`na'"!="" & `per' != 1.0 {
		display as error	///
			"options na and per() may not be combined"
		exit 198
	}
	if "`gwood'"!="" {
		if "`_dta[st_wt]'"=="pweight" { 
			di in red "option ci not allowed with pweighted data"
			exit 198
		}
		if `per' != 1.0 {
			di in red "option ci not allowed with per()"
			exit 198
		}
	}
	if "`cna'"!="" {
		if `per' != 1.0 {
			di in red "option ci not allowed with per()"
			exit 198
		}
		if "`_dta[st_wt]'"=="pweight" { 
			di in red "option ci not allowed with pweighted data"
			exit 198
		}
	}
	if `per' != 1.0 {
		if "`atrisk'"!="" {
			di in red "option atrisk not allowed with per()"
			exit 198
		}
		if "`lost'"!="" {
		di in red "options lost and enter not allowed with per()"
			exit 198
		}
	}
*	if "`ylog'"!="" & `per' != 1.0 {
*		di in red "option ylog not allowed with per()"
*		exit 198
*	}
	if "`na'"!="" {
		local origin "noorigin"
		local ttlpos 5
	}
	else {
		local ttlpos 1
	}

	
	
	
	local sb "`by'"
	if "`sb'" != "" {
		local n : word count `sb'
		if `n' > 1 & "`hazard'" != "" {
			di in red "may not specify " _c
			di in red "hazard" _c
			di in red " with more than one by/strata variable;"
			di in red /* 
			*/ "use " _quote "egen ... = group(`by')" _quote /*
			*/ " to make a single variable"
			exit 198
		}
	}

	if  "`censored'"!="" & ("`lost'"!="" | "`enter'"!="" | "`atrisk'"!="") {
		di in red /*
		*/ "censored() not possible with lost, enter, or atrisk" 
		exit 198
	}
	if "`censored'"~="" {
		local l = length("`censored'")
		if substr("numbered",1,max(1,`l')) == "`censored'" {
			local censt= "numbered"
		}
		else if substr("single",1,max(1,`l')) == "`censored'" {
			local censt= "single"
		}
		else if substr("multiple",1,max(1,`l')) == "`censored'" {
			local censt= "multiple"
		}
		else {
			di in red "invalid option censored(`censored')"
			exit 198
		}
	}

	if `"`censt'"' == "multiple" & `.__stsutil.hasRiskTable' {
		display as error	///
		  "options censored(multiple) and risktable may not be combined"
		exit 198
	}	
	if  "`enter'"!="" & "`atrisk'"!="" {
		display as error	///
		  "atrisk and enter not possible at the same time"
		exit 198
	}

	

if !(`.__stsutil.hasRiskTable' & `.__stsutil.getItteration' == 2) {
  // only show on the 1st pass when graphing twice for risktable
  st_show `show'
}

    /* get netsurvival from mata object in stata memory  */
    preserve
    mata: `e(mata_netsurv)'.netsurv2dta()


/* recomputes confidence limits if different level or citype */
    CheckCI , citype(`citype') level(`level')

tempname type ttltype
    
local `type' : char _dta[type]
local `ttltype' `"``type''-type estimate"'


tempname mark t n d cens ent yvar yvarlb yvarub s ch se lb ub aal saalen uba lba ch_lb ch_ub h Sh /* hold ttl */                    
quietly {

		local `t' 	  time
		local `n' 	  n_risk
        local `d'     n_event
        local `cens'  n_censor
        local `ent'
        local `s'     survival
        local `ch'    cum_hazard
        local `se'    std_err
        local `lb'    lower_bound
        local `ub'    upper_bound             
        local `ch_lb' ch_lower_bound
        local `ch_ub' ch_upper_bound 
        local `aal' 
        local `saalen'
        local `uba'
        local `lba'
        local `h' dLw
        local `Sh' dstderr

		tempvar ub1 lb1 Vh
                gen `Vh' = ``Sh''*``Sh''

	/* default is survival function */
		local  `yvar'   ``s''
		local  `yvarlb' ``lb''
		local  `yvarub' ``ub''
		label var ``yvar'' "Survival function"
		
		
		
	if "`failure'" != "" {
		replace ``s'' =1-``s''
        replace ``lb''=1-``lb''
        replace ``ub''=1-``ub''
        label var ``s'' "Failure function"
	}
	
		
	if "`hazard'" != "" {
/*		keep if ``d''
		sort `sb' ``t'' 
		by `sb' ``t'': keep if _n==1
		tempvar ub1 lb1
	*/
/*
if "`h'"=="" {
				tempvar h 
			}

			gen double `h' = cond(``n''==0,0,``d''/``n'')
*/
			sort `by' ``t''
				if "`by'" != "" {
					local byp "by `by':"
				}
/*
if "`Vh'" == "" {
					tempvar Vh
				}
			gen double `Vh' = cond(``n''==0,0,``d''/(``n''*``n''))
*/

		SmoothHazard  ``t'' ``h'' `Vh' "`kernel'" `"`width'"' `tmin' `tmax' ///
			`"`sb'"' `"`ub1'"' `"`lb1'"' `level' `leftboundary' `boundary'
			sort `sb' ``t'' 
			local  `yvar'    _sh
/*
			local  `yvar'    ``h''
*/
			local  `yvarub'  `ub1'
			local  `yvarlb'  `lb1'
			replace ``s'' = ``h''
			replace ``ub'' = `ub1'
			replace ``lb'' = `lb1'
			label var ``h'' "Smoothed hazard function"
              }

	 if "`cumhaz'" != "" {
		  local  `yvar'   ``ch''
          local  `yvarlb' ``ch_lb''
          local  `yvarub' ``ch_ub''
		  replace ``s'' = ``ch''
		  replace ``ub'' = ``ch_ub''
		  replace ``lb'' = ``ch_lb''
          label var ``yvar'' "Cumulative hazard" /* (fleming-harrington-nelson-aalen)"*/
	}

	cap confirm var ``yvar''
	cap confirm var ``yvarlb''

	if !_rc {
		label var ``yvarlb'' `"`=strsubdp("`level'")'% CI"'
		label var ``yvarub'' `"`=strsubdp("`level'")'% CI"'
	}

	if !`.__stsutil.hasRiskTable' {
		// postpone dropping data until risktable has built labels
		if `tmin' != -1 {
			drop if ``t''<`tmin'
		}
		if `tmax' != -1 { 
			drop if ``t''>`tmax'
		}
		qui count 
		if r(N)<1 { 
			di in red "tmin must be smaller than tmax"
			exit 2000
		}
	}
		
        /* à ce niveau, les variables à grapher sont yvar yvarlb yvarub  */ 
          
          //  ***** trim values
                if `ymin' != -1 {
                  quietly replace ``yvar'' = `ymin'  if ``yvar''<`ymin' 
                  quietly replace ``yvarub'' = `ymin'  if ``yvarub''<`ymin' 
                  quietly replace ``yvarlb'' = `ymin'  if ``yvarlb''<`ymin' 
                }
                if `ymax' != -1 { 
                  quietly replace ``yvar'' = `ymax'  if ``yvar''> `ymax' 
                  quietly replace ``yvarub'' = `ymax'  if ``yvarub''>`ymax' 
                  quietly replace ``yvarlb'' = `ymax'  if ``yvarlb''>`ymax' 
                }
                
	/* s2 is the position of the number of lost (censored)*/
    /* s3 is the position of the number of atrisk or number of entry at t */

*		qui summ ``s''
		qui summ ``yvar''
		local eps = max( (r(max)-r(min))/30, .0)
			if ("`atrisk'"!=""  | "`enter'"!="")  	{
				tempvar  s3 
                gen `s3' = ``yvar''-`eps' 
                sum `s3', mean
                if r(N) > 0 {
                    label var `s3' "Number entered"      
                    if ("`atrisk'"!="")    	{
                      local s3l ``n''
                    }
                    else {
						if ( "`enter'"!="")  	{
							local s3l ``ent''
						}
					}
                }
            }
		    else {
				local s3
			}
	
		if "`lost'"!=""	{
                  tempvar  s2 
                  gen `s2' = ``yvar''+`eps' if ``cens'' > 0
                  replace ``cens'' =  . if ``cens'' ==0 
                  sum `s2', mean
					if r(N) > 0 {
						label var `s2' "Number lost"
						local s2l ``cens''
					}
					else {
						local s2
					}
			}

		if `"`s2'"' != "" {
			local mgraph			///
			(scatter `s2' ``t'',	///
				sort				///
				connect(none)		///
				msymbol(none)		///
				mlabel(`s2l')		///
				mlabposition(0)		///
				pstyle(p1)			///
				\`ysca'				/// yet to exist
				`lstopts'			///
			)						///
			// blank
		}
		if `"`s3'"' != "" {
			local mgraph			///
			`mgraph'				///
			(scatter `s3' ``t'',	///
				sort				///
				connect(none)		///
				msymbol(none)		///
				mlabel(`s3l')		///
				mlabposition(0)		///
				pstyle(p1)			///
				\`ysca'				/// yet to exist
				`atopts'			///
			)						///
			// blank
		}

	local lorder
	local lcnt = 0	
	local insave `in'
	local ifsave `if'
	
	/* determine if legend(cols()) is specified */
	local opsave `options'
	local 0, `options'
	local hasCols = 0
	syntax [, legend(string asis) * ]
	while `"`legend'"' != "" {
		local 0, `legend'
		local holdops `options'
		
		syntax [, cols(string) * ]
		if `"`cols'"' != "" {
			local hasCols = 1
		}
		local 0 `", `holdops'"'
		syntax [, legend(string asis) * ]
	}
	local options `opsave'
	/* end legend(cols()) logic */

	if "`separat'" != "" | "`sb'" == "" {
		// by graph or single plot


		local svars "``yvar''"
		local opsave `options'
		if "`gwood'" != "" | "`cna'" != "" | "`cihazard'" != "" {
			if "`cihazard'" != "" {
				local cicon direct
			}
			else {
				local cicon stairstep
			}
			local 0, `ciopts'
			syntax [, recast(passthru) * ]
			if `"`recast'"' == "" {
				/* rarea is handled differently with this 
				 * command so that the line options refer 
				 * to the overlaid line instead of the 
				 * border of the area
				 */
				local 0, `options'
				syntax [, 	COLor(string) 		///
						FColor(string)	 	///
						LColor(string)		///
						LPattern(passthru) 	///
						LWidth(passthru) 	///
						PSTYle(string)		///
					* ]

				if `"`pstyle'"' != "" {
					local color scheme `pstyle'
				}
				local basecol `color'
				if `"`color'"' == "" {
					local color scheme p1
					local basecol `color'
					local color `color'*.15
				}
				if `"`lcolor'"' == "" {
					local lcolor `basecol'*.5
				}
				if `"`fcolor'"' != "" {
					local color `fcolor'
				}

				local cigraph `cigraph'			///
				(rarea ``yvarlb'' ``yvarub'' ``t'' , 			///
					sort				///
					connect(`cicon')		///
					color("`color'") 		///
					fcolor("`fcolor'")		///
					fintensity(100)			///
					pstyle("`pstyle'")		///
					`recast'			///
					\`ysca'			/// yet to exist
					`options'			///
				)
				local lcnt = `lcnt' + 1
				local lorder `lorder' `lcnt'
				// overlay rline over rarea border
				local cigraph `cigraph'			///
				(rline ``yvarlb'' ``yvarub'' ``t'',			///
					sort				///
					connect(`cicon')		///
					color("`color'")		///
					fcolor("`fcolor'")		///
					lcolor("`lcolor'")		///
					pstyle("`pstyle'")		///
					`lpattern'			///
					`lwidth'			///
					\`ysca'			/// yet to exist
					`options'			///
				)
				local lcnt = `lcnt' + 1
			}
			else {
				local cigraph `cigraph'			///
				(rarea ``yvarlb'' ``yvarub'' ``t'' , 			///
					sort				///
					connect(`cicon')		///
					`recast'			///
					pstyle(ci)			///
					\`ysca'			/// yet to exist
					`options'			///
				)
				local lcnt = `lcnt' + 1
				local lorder `lorder' `lcnt'
			}
		}
		local options `opsave'		
/* end 	if "`separat'" != "" | "`sb'" == ""  */
              }
	else {
		// overlaid plot
		tempvar grp id
		quietly by `sb': gen int `grp' = 1 if _n==1
		quietly replace `grp' = sum(`grp')
		quietly gen `id' = _n
		local ng = `grp'[_N]
		local i 1
		local j 1
		local ci_0 `ciopts'

		while `i' <= `ng' {
			tempvar x
			quietly gen float `x' = ``yvar'' * `per' if `grp'==`i'
			local svars "`svars' `x'"
			GetGroupLabel `sb' if `grp'==`i', id(`id')
			label var `x' `"`r(label)'"'
 
            if "`gwood'" != "" | "`cna'" != "" | "`cihazard'" != "" {
				if "`cihazard'" != "" {
					local cicon direct
				}
				else {
					local cicon stairstep
				}			
				// **** parse out ci`i'opts	
				local 0 , `options'
				syntax [, CI`i'opts(string asis) * ]
				local ciopts `ci`i'opts'
				while `"`ci`i'opts'"' != "" {
					local 0 `", `options'"'
					syntax [, CI`i'opts(string asis) * ]
					if `"`ci`i'opts'"' != "" {
					   local ciopts `"`ciopts' `ci`i'opts'"'
					}
				}
				// ****

				local ciopts `ci_0' `ciopts'
			    	local opsave `options'
				local 0, `ciopts'
				syntax [, recast(passthru) * ]
				if `"`recast'"' == "" {
					/* rarea is handled differently with 
					 * this command so that the line 
					 * options refer to the overlaid line
					 * instead of the border of the area
				     */
					local 0, `options'
					syntax [, 	COLor(string)  ///
							FColor(string)	   ///
							LColor(string)	   ///
							LPattern(passthru) ///
							LWidth(passthru)   ///
							PSTYle(string)	   ///
						* ]

					local basecol `color'
					if `"`pstyle'"' != "" {
						local color scheme `pstyle'
					}
					if `"`color'"' == "" {
						local color scheme p`=`i''
						local basecol `color'
						local color `color'*.15
					}
					if `"`lcolor'"' == "" {
						local lcolor `basecol'*.5
					}
					if `"`fcolor'"' != "" {
						local color `fcolor'
					}
					local cigraph `cigraph'	///
					(rarea ``yvarlb'' ``yvarub'' ``t'' if `grp' == `i', ///
						sort				///
						connect(`cicon')	///
						color("`color'")	///
						fcolor("`fcolor'")	///
						fintensity(100)		///
						pstyle("`pstyle'")	///
						`recast'			///
						\`ysca'				/// yet to exist
						`options'			///
					)
					local lcnt = `lcnt' + 1
					local lorder `lorder' `lcnt'
					// overlay rline over rarea border
					local cigraph `cigraph'	///
					(rline ``yvarlb'' ``yvarub'' ``t'' if `grp' == `i', ///
						sort				///
						connect(`cicon')	///
						color("`color'")	///
						fcolor("`fcolor'")	///
						lcolor("`lcolor'") 	///
						pstyle("`pstyle'")	///
						`lpattern'			///
						`lwidth'			///
						\`ysca'				/// yet to exist
						`options'			///
					)
					local lcnt = `lcnt' + 1
				}
				else {
					local 0, `options'
					syntax [, LColor(string) * ]
					if `"`lcolor'"' == "" {
						local lcolor scheme p`=`i''
						local lcolor `lcolor'*.5
					}
					local cigraph `cigraph'	///
					(rarea ``yvarlb'' ``yvarub'' ``t'' if `grp' == `i', ///
						sort				///
						connect(`cicon')	///
						lcolor("`lcolor'")	///
						`recast'			///
						\`ysca'				/// yet to exist
						`options'			///
					)
					local lcnt = `lcnt' + 1
					local lorder `lorder' `lcnt'					
				}
				local options `opsave'
                               /* end gwood */
			}
			local i = `i' + 1
                        /* next group,  while `i' <= `ng' */
		}
		local if `ifsave'
		local in `insave'
/* end overlaid plot */
	}

	// format the first var to be graphed, this makes the yaxis lables
	// look nice

	if "`sb'"!="" {
          local ttlby `"s"'
        }
        if `per' != 1 {
          local ttlper `" (per `per')"'
        }


	if "`hazard'"=="" {
		local fvar : word 1 of `svars'
		format `fvar' %9.2f
	}

	
	if "`na'"!="" {
			local ttl `"Cumulative hazard function`ttlby': ``ttltype''"'
	}
	else if "`hazard'"!="" {
		local ttl "Smoothed hazard estimate`ttlby'"
	}
	else if "`failure'"=="" {
		local ttl `"Survival function`ttlby'`ttlper': ``ttltype''"'
	}
	else {
		local ttl `"Failure function`ttlby'`ttlper': ``ttltype''"'
	}

	if "`ylog'" != "" {
       	local varcnt: word count `svars'
		local i 1
		while `i' <= `varcnt' {
			local varn: word `i' of `svars' 
			qui replace `varn'=. if `varn'<=0 
			local i=`i'+1
		}
	}

  	/*** new by mac *****/
	if "`origin'"=="" {
		tempvar last flg
		local N = _N
		if "`by'" == "" {
			 gen `last'=2 if _n==_N
			 expand `last'
			 gen `flg'=1 if _n>`N'
			 *replace ``t''=0 if `flg'==1
			if "`failure'" == "" {
				 replace ``yvar''=1 if `flg'==1
			}
			else  replace ``yvar''=0 if `flg'==1
		}
		else {
			sort `by'
			 by `by' :  gen `last'=2 if _n==_N
			 expand `last'
			 gen `flg'=1 if _n>`N'
			 *replace ``t''=0 if `flg'==1
			local varcnt: word count `svars'
			local i 1
			while `i' <= `varcnt' {
				local varn: word `i' of `svars' 
				if "`failure'" == "" {
					 replace `varn'=1*`per' if ``t''==0 
				}
				else  replace `varn'=0 if ``t''==0
				local i=`i'+1
			}
		}

		if "`gwood'"!="" {
			 quietly replace  ``yvarlb''=. if `flg'==1
			 quietly replace  ``yvarub''=. if `flg'==1
		}
		if "`notreal'"=="" {
			if "`lost'" !="" | "`enter'" !=""  {
				tempvar tempce
				 gen str8 `tempce' = string(``cens'')
				 replace `tempce'="" if `flg'==1	
				 drop ``cens''
				 rename `tempce' ``cens''
				 replace ``cens''=trim(``cens'')
			}
		}
	}
} ///quietly 

        	if "`na'"~="" | "`origin'"~="" { 
		tempvar flg
		qui gen int `flg'=.
	}
	if `"`censt'"'== "numbered" | `"`censt'"'=="single" {
		tempvar tmvars expw tu nextt mins
		qui gen double `mins'=1-``yvar'' 
		sort `sb' `mins' ``t''
		if "`sb'" != "" {
			qui by `sb': gen double `nextt'=``t''[_n+1]
		}
		else {
			qui gen double `nextt'=``t''[_n+1]
		}
		qui by `sb' `mins' (``t''): replace `nextt'=`nextt'[_N]
		qui sum ``t'', meanonly
		local adjd=(r(max)-r(min))/450
		qui gen int `expw'=2  if ``cens''>0 & ``cens''<. & `flg'>=.
		local N=_N
		qui expand `expw'
		qui replace `expw'=cond(_n>`N',2,.)
		sort `sb'  ``t'' ``yvar'' `expw'
		qui by `sb' ``t'': replace ``t''=``t''+`adjd' if `expw'==2 & _n==1 & /*
		*/ ``t''+`adjd'<`nextt'
		qui gen double `tmvars'=``yvar'' if `expw'==2
		format `tmvars' %9.2f
		label var `tmvars' "Censored"
		if "`na'"=="" & "`cna'"=="" {
			qui gen `tu'=`tmvars'+.02 if `expw'==2
		}
		else {
			noi sum ``yvar'', meanonly
			qui gen `tu'=`tmvars'+ (r(max)-r(min))/45 if `expw'==2
		}
		label var `tu' "Censored"
		local tmvars="`tmvars' `tu'"

		if  `"`censt'"'=="numbered" {
			tempvar expw1
			qui gen `expw1' = `expw'
			local N=_N
			qui expand `expw'
			qui replace `expw'=cond(_n>`N',2,.)
			qui replace ``yvar''=.  if `expw'==2
			qui replace ``cens''=. if `expw'~=2 
				// not sure why this is necessary
			local ctgraph			///
			(scatter `tu' ``t'' if `expw' == 2, ///
				connect(none)		///
				msymbol(none)		///
				mlabel(``cens'')		///
				mlabpos(12)		///
				mlabcolor(black)	///
				`ysca'			///
				`censopts'		///
			)
		}
		local ctgraph				///
		(rspike `tmvars' ``t'' if `expw' == 2,	///
			lstyle(tick)			///
			`ysca'				///
			`censopts'			///
		)					///
		`ctgraph'				///
		// blank

        	}
	else if  `"`censt'"'=="multiple" {

		tempvar tmvars expw tu nextt mins
		qui gen double `mins'=1-``yvar'' 
		sort `sb' `mins' ``t''
		if "`sb'" != "" {
			qui by `sb': gen double `nextt'=``t''[_n+1]
		}
		else {
			qui gen double `nextt'=``t''[_n+1]
		}
		qui by `sb' `mins' (``t''): replace `nextt'=`nextt'[_N]
	

		qui sum ``t'', meanonly
		local adjd=(r(max)-r(min))/350
		qui gen int `expw'=``cens''+1  if ``cens''>0 & ``cens''<. & `flg'>=.
		local N=_N
		qui expand `expw'
		qui replace `expw'=cond(_n>`N',2,.)
		qui gen double `tmvars'=``yvar'' if `expw'==2
		sort `sb' ``t'' ``yvar'' `expw'
		tempvar move ttime 
		qui by `sb' ``t'': gen int `move'=1 if ``t''+`adjd'*_n<=`nextt' /*
		*/ & `expw'==2
		qui by `sb' ``t'': replace `move'=2 if `move'>=. & /*
		*/ ``t''-`adjd'*_n>=``t''[1] & `expw'==2
		qui by `sb' ``t'': gen double `ttime'= ``t''+`adjd'*_n if `move'==1
		qui by `sb' ``t'': replace `ttime'= ``t''-`adjd'*_n if `move'==2
		qui replace ``t''= `ttime' if `ttime'<.
		drop `ttime' `move' 


		sort  ``yvar'' ``t'' `expw'
		format `tmvars' %9.2f
		if "`na'"=="" & "`cna'"=="" {
			qui gen `tu'=`tmvars'+.02 if `expw'==2
		}
		else {
			noi sum ``yvar'', meanonly
			qui gen `tu'=`tmvars'+ (r(max)-r(min))/45 if `expw'==2
		}
		label var `tmvars' "Censored"
		local tmvars="`tmvars' `tu'"
		label var `tu' "Censored"

		local ctgraph				///
		(rspike `tmvars' ``t'',			///
			lstyle(tick)			///
			`ysca'	`censopts'		///
		)					///
		// blank
	}

	local nv : word count `svars'
	if `nv' > 1 | `lcnt' >= 1 {
		forvalues i = 1/`nv' {
			local lcnt = `lcnt' + 1
			local lorder `lorder' `lcnt'
		}
		if `nv' > 1 & `"`cigraph'"' != "" & `hasCols' == 0 {
			local lrows rows(2)
		}
		local legend legend(`lrows' order(`lorder'))
	}
	else if `"`plot'`addplot'"' == "" {
		local legend legend(nodraw)
		if `"`bylgnd'"' == "" {
			local bylgnd `legend'
		}
	}

	if `"`separat'"' != "" {
		if `"`byttl'"' == "" {
			local byttl `"title(`"`ttl'"' `"`ttl2'"')"'
		}
		local byopt `"by(`sb' , `bylgnd' `byttl' `byopts')"'
	}
	else {
		local title `"title(`"`ttl'"' `"`ttl2'"')"'
	}

	if `"`plot'`addplot'"' != "" {
		local draw nodraw
	}

	local nvars : word count `svars'

	local nvars = min(`nvars',15)
	forval i = 1/`nvars' {
		local pseries `"`pseries' p`i'line"'
	}
	quietly replace ``yvar'' = ``yvar''*`per'
	
	local ver `c(version)'
	version 10
	if `.__stsutil.hasRiskTable' & `.__stsutil.getItteration' == 2 {
		tempfile abab
		qui save `abab', replace
		capture keep if `expw'==.
		capture keep if `expw1' == .
		gen _t=``t'' 		
			
		.__stsutil.getRiskTableOpts, timevar(``t'')	/// 
				riskvar(``n'') failvar(``d'')		///
				groups(`svars')	by(`by')			///
				axis1(10) 							// special axes start at 10
			local xaxisOp `"`s(xaxisOps)'"'
		qui use `abab',clear
	}

	if `"`tmin'"' != "" {
		foreach svar of local svars {
			qui replace `svar' = . if ``t'' < `tmin'
		}
	}
	
	local toDraw
	if `"`draw'`nodraw'`rNoDraw'"' != "" {
		local toDraw nodraw
	}
	
	if "`separat'" != "" | "`sb'" == "" {
		// **** parse out plotopts	
		local 0 , `options'
		syntax [, PLOTOpts(string asis) * ]
		local plops `plotopts'
		while `"`plotopts'"' != "" {
			local 0 `", `options'"'
			syntax [, PLOTOpts(string asis) * ]
			if `"`plotopts'"' != "" {
			    local plops `"`plops' `plotopts'"'
			}
		}
		// ****		
		local plots `cigraph'			///
		(line `svars' ``t'',			///
			sort						///
			`conopt'					///
			`ylabopt'       			///
			ytitle(`""')				///
			`ysca'						///
			xtitle(`"analysis time"')	///
			pstyle(`pseries')			///
			`title'						///
			`legend'					///
			`byopt'						///
			`plops'						///
			`xaxisOp'					///
			`xaxis'						///
		)								///
			`mgraph'					/// labels censored, lost
			`ctgraph'					/// censor ticks
		, `xsize' `ysize' `aspectr' nodraw `options' `name'
	}
	else {
		// **** parse out plotopts	
		local 0 , `options'
		syntax [, PLOTOpts(string asis) * ]
		local plops `plotopts'
		while `"`plotopts'"' != "" {
			local 0 `", `options'"'
			syntax [, PLOTOpts(string asis) * ]
			if `"`plotopts'"' != "" {
			    local plops `"`plops' `plotopts'"'
			}
		}
		// ****	

		// overlaid plots
		local i = 0
		foreach var of local svars {
			local `++i'
			// **** parse out plot`i'opts	
			local 0 , `options'
			syntax [, PLOT`i'opts(string asis) * ]
			local plotops `plot`i'opts'
			while `"`plot`i'opts'"' != "" {
				local 0 `", `options'"'
				syntax [, PLOT`i'opts(string asis) * ]
				if `"`plot`i'opts'"' != "" {
				    local plotops `"`plotops' `plot`i'opts'"'
				}
			}
			// ****
			local plots `plots' 				///
				(line `var' ``t'', sort 		///
					pstyle(p`i'line)			///
					`conopt' `xaxisOp' `xaxis'	///
					`plops' `plotops'			///
				)
			local xaxisOp 
			local plotops
		}
		local plots `cigraph' `plots'	///
			`mgraph'					/// labels censored, lost
			`ctgraph'					/// censor ticks
			,  `ysca'			///
			xtitle(analysis time) 		///
			`title' `legend' `ylabopt' `options' `name' `xsize' `ysize' `aspectr' nodraw  
	}
	if `.__stsutil.hasRiskTable' {
		quietly {
			if `tmin' != -1 {
				drop if ``t''<`tmin' & ``t'' != 0
			}
			if `tmax' != -1 { 
				drop if ``t''>`tmax'
			}
			qui count 
			if r(N)<1 { 
				di in red "no observations"
				exit 2000
			}
		}
	}

	graph twoway `plots'

	if `"`plot'`addplot'"' != "" {
		restore, preserve
		local name1 name(`.__stsutil.getGraphName', replace)
		graph addplot `plot' || `addplot' || , 	///
			norescaling nodraw `name1'
	}
	version `ver'
	
	if `.__stsutil.hasRiskTable' & `.__stsutil.getItteration' == 1 {
		restore, preserve
		.__stsutil.setItteration 2
		
		if `"`censored'"' != "" {
			// -censored- is not allowed with -enter-, however
			// preexisting code sets -enter- after that error 
			// condition has been tested. -enter- is reset here
			// so that the error condition will be tested on the
			// second pass as it was on the first pass. After
			// that happens the preexisting code will set -enter-
			// again.
			local enter
		}
		local passops		///
			 `failure' `na' `gwood' `cna' `enter' `lost' `atrisk'
		if `"`tmin'"' != "" {
			local passops `passops' tmin(`tmin')
		}
		if `"`tmax'"' != "" { 
			local passops `passops' tmax(`tmax')
		}
		if `"`per'"' != "" {
			local passops `passops' per(`per')
		}
		if `"`censored'"' != "" {
			local passops `passops' censored(`censored')
		}
		if `"`level'"' != "" {
			local passops `passops' level(`level')
		}
		if `"`origin'"' != "" {
			local passops `passops' noorigin
		}
		Graph_wrk `ifsave' `insave', `passops' by(`by') ///
			`.__stsutil.getNotRiskTableOpts' `name' `nodraw'
	}
	if "`outfile'"~="" {
		keep `sb' ``t'' ``yvar'' `Vh' 
		order `sb' ``t'' ``yvar'' `Vh' 
		format %10.0g ``yvar'' `Vh'
		local name `survival'`failure'`hazard'`cumhaz'
		if `"`name'"' == "" {
			local name survival
		}
		cap rename ``yvar'' `name'
		cap rename `Vh' V`name'
		tokenize "`outfile'", parse(",")
		// trim any trailing spaces in the filename
		local 1 `1'
		qui save "`1'" `2' `3' 
	}
end

program define ParseByOpts, sclass
	syntax [, LEGend(passthru) TItle(passthru) MISSing total * ]

	if "`total'" != "" {
		display as error		 ///
			"byopts(total) not allowed with sts graph"
		exit 191
	}

	if "`missing'" != "" {
		display as error		 ///
			"byopts(missing) not allowed with sts graph"
		exit 191
	}

	sreturn local bylgnd `"`legend'"'
	sreturn local byttl `"`title'"'
	sreturn local byopts `"`options'"'
end


program define KeepDead /* strata */
	args strata

	local d : char _dta[st_d]
	if `"`_dta[st_d]'"'!="" {
		/* keep if `_dta[st_d]' */
		drop `_dta[st_d]'
	}
	sort `strata' ``t''
	by `strata' ``t'': keep if _n==1
end

program define MarkPt /* t strata s -> ttl s2 */
	args t strata s ARROW ttl s2

quietly {

	tempvar mark marksum ls

	summarize ``t'', mean
	local tval = r(min) + (r(max)-r(min))*2/3

	gen byte `mark' = cond(``t''<`tval', 1, 0)
	by `strata': replace `mark'=0 if `mark'[_n+1]==1
	by `strata': gen byte `marksum' = sum(`mark')
	by `strata': replace `mark'=1 if _n==_N & `marksum'==0
	drop `marksum'

	summarize ``yvar'', mean
	local eps = 0 // this use to be "= max( (r(max)-r(min))/20, 0)"
	gen float `ls' = ``yvar''
	by `strata': replace `ls' = `ls'[_n-1] if `ls'>=.
	gen float `s2' = `ls'+`eps' if `mark'
	replace `s2' = `ls'[_n-1]+`eps' if `mark' & `strata'==`strata'[_n-1]

	summarize `s2', mean

	capture confirm string variable `strata'
	if _rc {
		gen str20 `ttl' = "`strata' " + trim(string(`strata')) if `mark'
		local lab : value label `strata'
		if "`lab'" != "" {
			tempvar delab
			decode `strata', gen(`delab') maxlen(20)
			replace `ttl' = `delab' if `mark'
		}
	}
	else	gen str20 `ttl' = trim(`strata') if `mark'
	compress `ttl'

} // quietly

end



program define GetGroupLabel, rclass
	syntax varlist [if] , id(varname)

	qui sum `id' `if', mean
	local n = r(min)
	foreach var of local varlist {
		cap confirm numeric var `var'
		if _rc {		// string variable
			local ll = substr(`var'[`n'],1,20)
		}
		else {			// numeric variable
			qui sum `var' `if', mean
			local ll `"`var' = `: label (`var') `=r(min)''"'
		}
		local lab `"`lab'`sep'`ll'"'
		local sep "/"
	}
	return local label `"`lab'"'
end



program define SmoothHazard
	args time deltah deltaVh kernel width tmin tmax sb ub lb level leftbnd nobnd
	local by `"`sb'"'
	if `"`by'"' != "" {
		local byLabel : value label `by'
		local varLab : variable label `by'
	}

	drop if `deltah' == 0 | `deltah' == .
	tempvar tvar group id
	if `"`width'"' != "" {
		foreach j of local width {
			if "`j'"!="." {
				confirm number `j'
			}
		}
	}

	if "`by'" != "" {
		qui egen `group' = group(`by')
		qui summarize `group', meanonly
		local ngroup = r(max)
		qui gen `id' = _n
	}
	else {
		qui gen `group' = ``time''<.		
		local ngroup = 1
			}
	if _N < 950 {
		set obs 950
	}
	qui summarize ``time''
	
	if `tmin' == -1 {
		if `leftbnd' == -1 {
			local tmin = r(min)
		}
		else {
			local tmin = `leftbnd'
		}
	}
	if `tmax' == -1 {
		local tmax = r(max)
	}
	qui gen `tvar' = `tmin' + (_n-1)/950*(`tmax'-`tmin') in 1/950
	if "`nobnd'" == "" {
		if `"`kernel'"'=="epan2" | ///
		   substr(`"`kernel'"',1,2) == "bi" | ///
		   substr(`"`kernel'"',1,3) == "rec" {
			if  substr(`"`kernel'"',1,2) == "bi" {
				local kernel biweight
			}
			if  substr(`"`kernel'"',1,3) == "rec" {
				local kernel rectangle
			}
			local dobndk = 1
		}
		else {
			local dobndk = 0
		}
	}
 
	forvalues i = 1/`ngroup' {
		local w : word `i' of `width'
		if `"`w'"' != "" {
			if `"`w'"' == "." {
				local wopt 
			}
			else {
				local wopt width(`w')
			}
		}
		else {
			local wopt
		}
		local t time

		version 8: qui kdensity `t' [iw=`deltah'] ///
			if `group'==`i', ///
			`kernel' `wopt' ///
			gen(__y`i') at(`tvar') ///
			nograph
		if "`nobnd'" == "" {
			// correct for boundary effects
			tempvar bnd
			local wwidth = r(width)
			qui summ `t' if `group'==`i'
			if `leftbnd' == -1 {
				local lbnd = r(min) + `wwidth'
			}
			else {
				local lbnd = `leftbnd' + `wwidth'
			}
			local rbnd = r(max) - `wwidth'
			if `lbnd' >= `rbnd' {
				di as err "left and right boundary regions overlap;"
				di as err "specify smaller bandwidth(s) in width()"
				exit 198
			}
			qui gen `bnd' = ((`tvar'<`lbnd')|(`tvar'>`rbnd')) ///
					   &(`tvar'<.)
			// use boundary kernels or restrict range to 
			// [tmin+h,tmax-h]
			if `dobndk' == 1 {
				// do not recompute at interior points
				tempvar atbnd bndkern touse
				qui gen `touse' = (`t'<.)*(`deltah'<.)* ///
						  (`group'==`i')
				qui gen `bndkern' = .
				qui gen `atbnd' = `tvar' if `bnd' == 1
				qui count if `tvar'<=`rbnd'
				local indrb = r(N) + 1
				mata: _sts_bndkdensity( "`t'", "`atbnd'", ///
					"`deltah'", "`bndkern'", "`touse'",  ///
					"`bnd'", 1, `indrb', `wwidth',       ///
					`lbnd', `rbnd', &`kernel'(), 0)
				qui replace __y`i' = `bndkern' if `bnd'==1
			}
			else {
				qui replace __y`i' = . if `bnd' == 1
			}
		}
		// truncate negative estimates to zero
 		qui replace __y`i' = 0 if __y`i'<0
		// restrict the plotting range to [t_min_i, t_max_i]
		qui summ `t' if `group'==`i'
		if `leftbnd' == -1 {
			qui replace __y`i'=. if `tvar'<r(min) | `tvar'>r(max)
		}
		else {
			qui replace __y`i'=. if `tvar'<`leftbnd' | `tvar'>r(max)
		}
		qui gen __yy`i' = .
		if `"`wopt'"' == "" {
			quietly summ `t' if `group'==`i', detail
			local wid2 = min(r(sd), (r(p75)-r(p25))/1.349)
			if `wid2' <= 0.0 {
				local wid2 = r(sd)
			}
			local wid2 = 0.9*`wid2'/(r(N)^.20)
			local wopt width(`wid2')
		}
		
		
		_KDE2 `t' [iw=`deltaVh'] if `group'==`i', `kernel' at(`tvar') kde(__yy`i') `wopt'
		if "`dobndk'" == "1" {
			tempvar bndse
			// do not recompute at interior points
			qui replace `touse' = (`t'<.)*(`deltaVh'<.)* (`group'==`i')
			qui gen `bndse' = .
			mata: _sts_bndkdensity( "`t'", "`atbnd'", "`deltaVh'", "`bndse'", "`touse'",  ///
					"`bnd'", 1, `indrb', `wwidth', `lbnd', `rbnd', &`kernel'(), 1)
			qui replace __yy`i' = `bndse' if `bnd'==1
		}
		if "`by'"!="" {
			sort `group' `t' `tvar'
			qui summ `id' if `group'==`i'
			local index r(min)
			version 8: qui gen __by`i' = `by'[`index'] in 1/950
		}
		local z = invnorm(1-(1-`level'/100)/2)
		quietly generate   __lb`i'= __y`i'* 		///
				exp(-`z'*sqrt(__yy`i')/__y`i') if __y`i'<.
		quietly generate   __ub`i' = __y`i'* 		///
				exp(`z'*sqrt(__yy`i')/__y`i')  if __y`i'<.
	}
	keep in 1/950
	if "`by'"!="" {
		qui replace `id' = _n
		qui reshape long __y __yy __ub __lb __by, i(`id')
	}
	drop `t' `deltah' `deltaVh' 
	if "`by'"!="" {
		drop `by'
		rename __y `deltah'
		rename __yy `deltaVh'
		rename __by `by'
		rename __ub `ub'
		rename __lb `lb'
		qui label variable `by' `"`varLab'"'
		cap confirm numeric variable `by'
		if _rc==0 {
			qui label values `by' `byLabel'
		}
	}
	else {
		rename __y1 `deltah'
		rename __yy1 `deltaVh'
		rename __ub1 `ub'
		rename __lb1 `lb'
	}
	rename `tvar' `t'
/* end SmoothHazard   */
end  


program define ForbidOpt
	if `"`1'"'!="" {
		di in red `"options `1' and hazard may not be combined"'
		exit 198
	}
end


program define ChkYScale4Log, sclass
	syntax [, YLOg LOG * ]

	sreturn clear
	if "`ylog'`log'" != "" {
		sreturn local log log
	}
	sreturn local options `"`s(log)' `options'"'
end


program define ChkYScale4range, sclass
        syntax [, Range(numlist max=2) * ]
	sreturn clear
        sreturn local nval : word count `range'
        if (`s(nval)' > 0 ) {
          sreturn local range `range'
           forvalues i = 1/`s(nval)' {
	      sreturn local r`i' : word `i' of `range'  
           }
       }
end







program define List
if replay(){
  Do_Print `0'
}
else {
  Estimate `0'
/* get print options */
   syntax using/ [if] [in], age(string) period(string)  [							///
                                                         STrata(string asis) 		/// e
                                                         rate(name) 				/// e
                                                         BY(varlist)				/// re
                                                         interpolate(integer 1)     /// e
                                                         END_followup(string)    /// e
                                                         SURvival 					/// re the default
                                                         Failure					/// re abbr. (backward compatib.)
                                                         CUMHaz						/// re synonym for na
                                                         NA							/// re deprecated syn. for cumhaz
                                                         AT(string asis)			/// re
                                                         Compare 					/// re
                                                         noSHow						/// re 
                                                         noDETail					/// re 
                                                         CITYpe(string) 			/// re
                                                         Level(cilevel) 			/// re 
                                                         SAVing(string asis) 		/// re
                                                         * ]                        /* for graph options, ... */



  Do_Print, `survival' `failure' `cumhaz' `na' by(`by') at(`at') `compare' citype(`citype') level(`level') saving(`saving') noshow `detail'
}

end


program define Estimate, eclass
   syntax using/ [if] [in], age(string) period(string)  rate(name) 				/// e
                                                         [							///
                                                         STrata(string asis) 		/// e
                                                         BY(varlist)				/// re
                                                         interpolate(integer 1)   	/// e
                                                         interpage(integer 1) interpdate(integer 1) /// e
                                                         strictage strictdate       /// e
                                                         END_followup(string)    /// e
                                                         SURvival 					/// re the default
                                                         Failure					/// re abbr. (backward compatib.)
                                                         CUMHaz						/// re synonym for na
                                                         NA							/// re deprecated syn. for cumhaz
                                                         Compare 					/// re
                                                         noSHow						/// re 
                                                         TYpe(string)        		/// e
                                                         CITYpe(string) 			/// re
                                                         Level(cilevel) 			/// re 
                                                         BEGINtime(string) 			/// re
                                                         SAVing(string asis) 		/// re
                                                         * ]                       /* for graph options, ... */

/*
age    : age at entry (_t0) (in year)
year   : date of entry  (_t0) (in days since 01jan1960
rate   : name of the rate variable in the rate table
         rate() is required in this distribtion
by     : stratifying variables for computation
*/


if "`end_followup'"==""  {
	local end_followup 0
} 
else {
	capture local newend = `end_followup'
    local rc _rc

	if `rc' != 0 {
       display as error "incorrect value in end_followup() option"
       exit `rc'
     }
	
	local end_followup = `newend'
} 
 

local w  : char _dta[st_w]
local wt : char _dta[st_wt]

if `"`strictage'"' == "" {
  local strictage = "nostrictage"
}

if `"`strictdate'"' == "" {
  local strictdate = "nostrictdate"
}


/* get age */
  manage_strata `age'
	if r(nstrata)>1 | _rc != 0 {
		display as error "error in age()"
		exit 1000
	}
  local age `r(strata)'
  local tableage `r(tablestrata)'


/* get period */
  manage_strata `period'
	if r(nstrata)>1 | _rc != 0 {
		display  as error "error in period()"
		exit 1000
	}
  local period `r(strata)'
  local tableperiod `r(tablestrata)'


/* get strata */
  capture noisily manage_strata `strata'
  local strata `r(strata)'
  local tablestrata `r(tablestrata)'
      if _rc!=0 {
        display as error "(error in option strata())"
        exit _rc
      }   

/* set type of estimate */

  WhichType `type'
  local type `r(type)'

/* set type of confidence limits */
  WhichCiType , `citype'
  local citype `r(citype)'

/* check if enter-time is specified in stset */
  capture assert _t0 ==0
  if _rc ==0 {
    /* no enter-time !=0 */
    local doenter
  }
  else {
    /* enter-time is needed */
/* set beginig time of the weight S(time) = exp(-CumHaz(begintime, time)) */
     local doenter doenter
     WhichBeginTime  `begintime'
     local begintime `r(begintime)'
  }


if `"`show'"' != "noshow" {
	di in yellow `"type of estimate: `type'"'
}

if `"`cumhaz'"' != "" & `"`na'"' != "" {
	// cumhaz and na are synonyms, but only one or the other should be used.
	display as error	///
		"options cumhaz and na may not be combined"
		exit 198
	}


		/* affichage de survival, failure OU cumhaz ********* PAS TOUS ENSEMBLE !!! */	
			// mutually exclusive functions
			local exclus `"`survival' `failure' `cumhaz' `na'"' 
			local optcnt : word count `exclus' 
			if `optcnt' > 1 {
				display as error	///
					"options `:word 1 of `exclus'' "	///
					"and `:word 2 of `exclus'' may not be combined"
				exit 198
			}
			
		// implied survival option
			if `"`survival' `failure' `cumhaz' `na'"' == "" {		// set the default
				local survival survival
			}
			if `"`cumhaz'"' != "" {
				// stick with -na- for backward compatibility
				local na na 
			}
			
/* for compatibility with sts  */
			local sb "`by'"
			if "`compare'" != "" {
				if "`at'" == "" { 
					local at "10"
				}
				if "`sb'"=="" {
					if "`na'"!="" {
						di in red "compare requires by()"
						exit 198
					}
					di in red "compare requires by() or strata()"
					exit 198
				}
			} 

tempvar touse mark n d cens ent s se lb ub aal saalen uba lba ch ch_lb ch_ub
st_smpl `touse' `"`if'"' "`in'" "`sb'"

preserve

/* deals with end_followup option */
qui st_endfollowup if `touse' , end_followup(`end_followup')


qui keep if `touse'

st_show `show'
	

/* initiate ereturns */
ereturn post ,  properties("")

*capture noisily {
 /* computes net survival ... and put the estimates in the memory */
  st_netsurv  using `using', age(`age') period(`period') strata(`strata')              		    ///
    tableage(`tableage') tableperiod(`tableperiod') rate(`rate') tablestrata(`tablestrata')    	///
    by(`by')                                                									///
    interpolate(`interpolate')                                                                  ///
  interpage(`interpage') interpdate(`interpdate') ///
  `strictage' `strictdate' ///
  end_followup(`end_followup')											///
    type(`type') citype(`citype') level(`level') begintime(`begintime') `doenter' saving(`saving')

restore
ereturn repost , esample(`touse') 
*} // quietly

end



/***************************************************************************************/
/***************************************************************************************/
/*                            print results                                            */
/***************************************************************************************/
/***************************************************************************************/


program define Do_Print

   syntax  [ , SURvival 		/// the default	 
               Failure			/// abbr. (backward compatib.)
               CUMHaz			/// synonym for na
               NA				/// deprecated syn. for cumhaz
               AT(string asis)	///
               BY(varlist)		///
               Compare 			///
               CITYpe(string) 	///
               Level(cilevel) 	///
               SAVing(string asis) 	///
               noSHow			///
               noDETail			///
               ]


if `"`by'"' != "" & (`"`by'"' != `"`e(by)'"' ) {
display as error	///
  "option by() is not the same as e(by)"
exit 198
}
if `"`by'"' == "" & (`"`e(by)'"' != "") {
local by `e(by)'
}

/***************************************************************************************/
/*                            parse syntax                                             */
/***************************************************************************************/


if `"`cumhaz'"' != "" & `"`na'"' != "" {
		// cumhaz and na are synonyms, 
		//	but only one or the other should be used.
		display as error	///
			"options cumhaz and na may not be combined"
		exit 198
	}


		/* affichage de survival, failure OU cumhaz ********* PAS TOUS ENSEMBLE !!! */	
			// mutually exclusive functions
			local exclus `"`survival' `failure' `cumhaz' `na'"' 
			local optcnt : word count `exclus' 
			if `optcnt' > 1 {
				display as error	///
					"options `:word 1 of `exclus'' "	///
					"and `:word 2 of `exclus'' may not be combined"
				exit 198
			}
			
		// implied survival option
			if `"`survival' `failure' `cumhaz' `na'"' == "" {		// set the default
				local survival survival
			}
			if `"`cumhaz'"' != "" {
				// stick with -na- for backward compatibility
				local na na 
			}
			


/* for compatibility with sts  */
			local sb "`by'"
			if "`compare'" != "" {
				if "`at'" == "" { 
					local at "10"
				}
				if "`sb'"=="" {
					di in red "compare requires by()"
					exit 198
				}
			} 


if "`detail'"!="nodetail" {
/* net survival is output if option nodetail not given  */
/***************************************************************************************/
/*                                 reload results                                      */
/***************************************************************************************/
quietly {
  
    /* get netsurvival from mata object in stata memory  */
	preserve
st_show `show'

 /* read the computed net survival */
      mata: `e(mata_netsurv)'.netsurv2dta()
      local type : char _dta[type]
	  
quietly {

 if "`at'" != "" {
   /* compute/select at times */ 



  Procat `at' 
  local at `"`s(at)'"'
  local printed_at `"`s(at_output)'"'
  local nat `"`s(nat)'"'
  local at_factor `"`s(at_scalefactor)'"'
  local at_unit `"`s(at_unit)'"'
  local at_method `"`s(at_method)'"'

   /* select output times  */
   SelectTime `at' , by(`by') atoutput(`printed_at') scalefactor(`at_factor') unitname(`at_unit') method("`at_method'") type(`type')
   
}
 else { /* no at time, output all */
  local printed_at `at'
  local at_unit 
  local at_factor 1
  local nat 
    }      
}  // quietly

	/* recomputes confidence limits if different level or citype */
	CheckCI , citype(`citype') level(`level')
} // quietly



/***************************************************************************************/
/*                                 print results                                       */
/***************************************************************************************/
		tempname   t n d cens ent s cumhaz se lb ub ch_lb ch_ub ttl             
					   local ttl "Surv." 
					   local `t' time
                       local `n' n_risk
                       local `d' n_event
                       local `cens' n_censor
                       local `ent'  
                       local `s'   survival
                       local `cumhaz'  cum_hazard
					   local `se'  std_err
                       local `lb'  lower_bound
                       local `ub'  upper_bound             
				       local `ch_lb'  ch_lower_bound
                       local `ch_ub'  ch_upper_bound                         					

	if "`sb'"!="" {
		quietly {
			tempvar grp
			by `sb': gen `grp'=1 if _n==1
			sum
			replace `grp' = sum(`grp')
		}
	}

	if "`failure'"!="" { 
		replace ``s''=1-``s''
		replace ``lb''=1-``lb''
		replace ``ub''=1-``ub''
		local ttl "Failure"
		local blnk " "
		local attl "Failure Function"
	}
		
/*  print results  */
qui drop if time==0
local ettl "     "
local liste 0
local net "Net"

local cil `=string(`level')'
local cil `=length("`cil'")'
if `cil' == 2 {
  local spaces "     "
}
else if `cil' == 4 {
  local spaces "   "
}
else {
  local spaces "  "
}

if "`at'" == "" {
local eventlbl1 
local attimelbl 
local atunitlbl
local atad
}
else {
  local fmtat 10
  local atad  + `fmtat' +  1
  local fmtunitat = `fmtat' - 2
  local colevent  = 4 `atad'
  local eventlbl1 _col(`colevent') "Event" 
  local attimelbl %`fmtat's "Time"
  if `"`at_unit'"' != "" {
    local atunitlbl = abbrev("`at_unit'",`fmtunitat')
    local atunitlbl  %`fmtat's "(`atunitlbl')"
  }
  else {
    local atunitlbl
  }
}

local coltime  =4 `atad'
local colbeg   =13 `atad'
local colnet   =32 `atad'
local colNet   =47 `atad'
local colcumhaz=46 `atad'
local colfcn   =48 `atad'
local colstd   =58 `atad'


if "`wt'"!="pweight" {
	if "`na'"=="" {
		if "`failure'"!="" {
			di in gr _n `attimelbl'  `eventlbl1' _col(`colbeg') "Beg." _col(`colnet') "`net'" /*
			*/ _col(`colNet') "Net " "`ttl'"  _n /*
			*/  `atunitlbl' _col(`coltime') "Time     Total    Fail     Lost `ettl'" /*
			*/ _col(`colfcn') /*
			*/ `"Function`spaces'[`=strsubdp("`level'")'% Conf. Int.]"'
			local dupcnt= 76 `atad'
		}
		else {
			di in gr _n `attimelbl'  `eventlbl1' _col(`colbeg') "Beg." _col(`colnet') "`net'" /*
			*/ _col( `colNet') " Net " "`ttl'"  _n /*
			*/ `atunitlbl' _col(`coltime') "Time     Total    Fail     Lost `ettl'" /*
			*/ _col(`colfcn') /*
			*/ `"Function`spaces'[`=strsubdp("`level'")'% Conf. Int.]"'
			local dupcnt = 76 `atad'
		}
	}
	else {
			di in gr _n `attimelbl'  `eventlbl1' _col(`colbeg') "Beg." _col(`colnet') "`net'"  /*
			*/ _col(`colNet') " Net "   _col(`colstd') " Std." _n /*
			*/ `atunitlbl' _col(`coltime') "Time     Total    Fail     Lost  `ettl'" /*
			*/ _col(`colcumhaz') /*
			*/ `"Cum.Haz     Error`spaces'[`=strsubdp("`level'")'% Conf. Int.]"'
			local dupcnt = 83 `atad'
	}
}

di in smcl in gr "{hline `dupcnt'}"


local i 1
	while `i' <= _N {
		if "`sb'" != "" {
			if `grp'[`i'] != `grp'[`i'-1] {
				sts_sh `grp' "`grp'[`i']" "`sb'"
				di in gr "$S_3"
			}
		}
                         if "`at'" != "" {
                           	di in gr %`fmtat'.0g attimeoutput[`i'] " " _c 
                              }
		di in gr %7.0g ``t''[`i'] " " in ye /*
			*/ %8.0g ``n''[`i'] " " /*
			*/ %8.0g ``d''[`i'] " "/*
			*/ %8.0g ``cens''[`i'] " "  _c 
		if `liste' {
			di in ye %8.0g ``ent''[`i'] _c
		}
		else	di _skip(8) _c
		if "`wt'"!="pweight" {
			if "`na'"=="" {
				if "`failure'"!="" {
					di in ye " "  %11.4f ``s''[`i'] " " _c
					di in ye /* 
					*/ %10.4f ``ub''[`i'] /* lower cb */ " " /*
					*/ %9.4f ``lb''[`i'] /* upper cb */  " " 
				}	
				else {
					di in ye " "  %11.4f ``s''[`i'] " " _c
					di in ye /* 
					*/ %10.4f ``lb''[`i'] /* lower cb */ " " /*
					*/ %9.4f ``ub''[`i'] /* upper cb */  " " 
				}
			}	
			else {
					di in ye /* 
					*/ %9.4f  ``cumhaz''[`i'] /* cum hazard */ " " /*
					*/ %9.4f  ``se''[`i'] /* standard error */ " " /*
					*/ %10.4f ``ch_lb''[`i'] /* cum_haz lower cb */ " " /*
					*/ %9.4f ``ch_ub''[`i'] /* cum_haz upper cb */  " " 
			}
	}
	else di
		local i = `i'+1    
	}
	
	di in smcl in gr "{hline `dupcnt'}"


	restore
	/*  error c(rc) */
	if c(rc) {
		if inrange(c(rc),900,903) {
			di as err ///
			"insufficient memory to load file with results"
		}

	}
}
end



program define st_netsurv, eclass

syntax using/  , age(varname)                                                  			///
  period(varname) [                             										///
                   strata(varlist)                                            			///
                   tableage(name) tableperiod(name) rate(name) tablestrata(namelist)	///
                   BY(varlist)		                                        		 	///
                   interpolate(integer 1)                                            	///
				   interpage(integer 1) interpdate(integer 1) 							///
				   strictage strictdate 				///
                   END_followup(integer 0)                                           	///
                   SAVing(string asis) 							/// 
                   TYpe(string)                                                      	///
                   CITYpe(string)                                                    	///
                   Level(cilevel)                                                    	///
                   BEGINtime(string)                                                    ///
                   DOENTER                                                               ///
                   *] 

/*
    computes the net survival at each unique _t in each by group
    change the data in memory to contain
       by variables
       _t
    result variables (net survival/cumhazard, net rate , std, ci) 
*/
  if `"`strictage'"' == "" {
  local strictage = "nostrictage"
}

if `"`strictdate'"' == "" {
  local strictdate = "nostrictdate"
}


  /* managing the rate table to build a ratetable object */
  /* local with the name of the mata object that will contain the ratetable */
  tempname ratetable
local ratetable r`ratetable'


  if "`rate'" == "" {
/* no rate specified, `using' should be a mata ratetable object */
/* first tries to find the ratetable in memory                  */
*    capture is_ratetable `using'
*    if (r(found)==1){
    /* the rate table is a ratetable class object in memory */
*      mata: class ratetable scalar `ratetable'
*      set matastrict off
*      mata: `ratetable' = ratetable()
*      mata: `ratetable' = `using'.copy()
*      mata:  _copyratetable(`using',`ratetable' )
*    }
*    else {
      /* try to load a ratetable object in the file `name' */
	  
      capture loadratetable using `using', replace name(`ratetable')
       local rc _rc
*    }

*  exit  `rc'
  }
  else {
    /* the rate table is in a dta file défined by tableage(varname) tableperiod(varname) rate(name) */
    /* check consitency of rate table specifications  not implemented */
    /* not yet implemented */
*    capture checkratetable using `using', age(`tableage') period(`tableperiod') rate(`rate')  ///
*        strata(`tablestrata') interpolate(`interpolate')  ///
*        interpage(`interpage') interpdate(`interpdate') ///
*        `strictage' `strictdate' name(`ratetable') 

    capture noisily loadratetable using `using', age(`tableage') period(`tableperiod') rate(`rate')  ///
        strata(`tablestrata') interpolate(`interpolate')  ///
        interpage(`interpage') interpdate(`interpdate') ///
        `strictage' `strictdate' name(`ratetable') 
       local rc = _rc
  }
  if `rc' != 0 {
       di "ratetable  `using' not found"
       exit `rc'
     }

/* transform at in a vector */
  local atvector = "(0)"
  if (`"`at'"' != "") {
    numlist "`at'" 
    local at `r(numlist)'
    local atvector : subinstr local at " " ",", all
    local atvector  (`atvector')
    if (`"`atmethod'"' == "") {
     local atmethod t-wheighted mean
    }
  }

if `"`saving'"' != "" {
  ParseSaving `saving'
  local replace  "`s(replace)'"
  * put saving in the macro newfile 
  mata : GetZipFileName()
  tempfile tmpsave
}
/* caller to mata */
/* create a net_survival_function object */
tempname NETSURV ATNETSURV
*quietly {

	mata: `ATNETSURV' =  net_survival_function()
	if("`doenter'" == "") {
/*  no enter computation */
		mata: `NETSURV' = netsurv("`age'", "`period'", `ratetable', `end_followup', "`strata'", "`tablestrata'", "`by'",`atvector',"`atmethod'", `ATNETSURV', "`type'", "`citype'", `level')
	}
	else {
/*  with enter time computation */
		mata: `NETSURV' = netsurve("`age'", "`period'", `ratetable', `end_followup', "`strata'", "`tablestrata'", "`by'",`atvector',"`atmethod'", `ATNETSURV', "`type'", "`citype'", `level', "`begintime'")
	}
	/* put results in dta memory */
	mata: `NETSURV'.netsurv2dta(`"`newfile'"', `"`replace'"')

	if (`"`at'"' != ""){
			*mata: `ATNETSURV'.netsurv2dta(`"at_`newfile'"', `"`replace'"')
			ereturn local mata_atnetsurv `ATNETSURV'
			ereturn local atsaved_dta at_`newfile'
	}


	ereturn local mata_netsurv `NETSURV'
	ereturn local saved_dta `newfile'

	/* CI info */
		ereturn local type "`type'"
		ereturn local citype "`citype'"
		ereturn local cilevel `level'
	/* by info */
		ereturn local by `by'
	/* strata info */
		ereturn local age `age'
		ereturn local period `period'
		ereturn local strata `strata'
		ereturn local tablestrata `tablestrata'
	/*rate table info */
		ereturn local ratetable `ratetable' 
		mata: `ratetable'.ereturninfo()

        /* clear the ratetable in mata memory */
          mata: mata drop `ratetable'

*} // quietly

end



program define sts_sh /* grp g# <byvars> */
	args grp g by

	tokenize "`by'"
	global S_3
	while "`1'" != "" {
		GetVal `grp' `g' `1' 20
		global S_3 "$S_3$S_2$S_1 "
		* di in gr "$S_2$S_1 " _c
		mac shift
	}
end


program define GetVal /* grpvar g# var maxlen */
	args grp g v maxlen
	tempvar obs newv
	quietly {
		gen long `obs' = _n if `grp'==`g'
		summ `obs', mean
		local j = r(min)
		local typ : type `v'
		local val = `v'[`j']
		global S_2
		if substr("`typ'",1,3)!="str" {
			local lbl : value label `v'
			if "`lbl'" != "" {
				local val : label `lbl' `val'
			}
			else {
				global S_2 "`v'="
				local val=string(`val')
			}
		}
		global S_1 = substr(trim("`val'"),1,`maxlen')
	}
end


program define Reat /* t <processed at-list> */, sclass
	sret clear
	if "`2'"!="reat" {
		exit
	}
	quietly { 
		local t "`1'"
		local n = `3'
		local n = cond(`n'-2<1, 1, `n'-2)
		qui summ _t if _t!=0
		local tmin = r(min)
		local tmax = r(max)
		local dt = (`tmax' -`tmin')/`n'
		if `dt'>=1 {
			local dt = int(`dt')
		}
		local v = int(`tmin')
		/* s(at) contains nothing right now */
		while `v' < `tmax' {
			sret local at "`s(at)' `v'"
			local v = `v' + `dt'
		}
		sret local at "`s(at)' `v'"
	}
end


program define Procat , sclass
/*
syntax
      at(numlist , SCALEfactor(real 1) UNITname(string) *)
   ou at(num     , SCALEfactor(real 1) UNITname(string) *)
           * is for other options for numlist

*/
syntax anything(id="numlist" name=at) [, SCALEfactor(real 1) UNITname(string) round(real 1) timevar(varname numeric) METHod(string) * ]
  sreturn clear
/*
1 if at is a single value, at is the number of _t values regularely spaced
  along the follow-up by step (end-beg)/at. scale is irrelevant
2 if at is a numlist, _t times are obtained by mulitplying by scalefactor.

Unitname is the name of the unit of time of the output list of times, given in at
Wil be used in output

*/

local before "step"
local mean "lin"


if `"`method'"' == "" {
  local method `"`before'"'
}
else if `"`method'"' != `"`before'"' & `"`method'"' != `"`mean'"' {
   di in red `"at suboption method must be method(`before') or method(`mean')"'
        exit 198
}
 

numlist "`at'", `options'
local at "`r(numlist)'"
local nat : word count `at'



if `nat'==1 {
  /* at(num, *) : get `num' values in _t */
  capture confirm integer numb `at'
  if _rc == 0 { 
    capture assert `at' >=1
  }
  if _rc {
     di in red `"at(`at') invalid"'
     exit 198
  }
  else {
    if  `scalefactor' != 1 {
       di in red `"scalefactor(`scalefactore') ignored in  at() option"'
    }
    if `round' <= 0 {
      di in red `"round(`round') invalid in at() option"'
      exit 198 
    }
    if `"`timevar'"'=="" {
      local _dta : char _dta[_dta]
      if `"`_dta'"' == "st" {
        local timevar : char _dta[st_t]
      }
      else if `"`_dta'"' == "netsurv" {
        local timevar : char _dta[time]
      }
      else {
        di in red "error in sub program Procat of stns"
        exit 198
      }
    }
    local nat `at'
    qui summ `timevar' if `timevar'!=0
    local tmin = r(min)
    local tmax = r(max)
    local dt = `tmax'/`nat'
    local at 
    forvalues i = 1/`nat' {
      /*local v = `round' * int( `i' * `dt' / `round')*/
      local v =  round( `i' * `dt' , `round')
      local at `"`at' `v'"'
    }
  local nat=`nat'+1
  local atoutput `at'
  }
}
else {
  local atoutput `at'
  local at
  forvalues i = 1/`nat' {
    local iat : word `i' of `atoutput'
    local iat = `scalefactor' * `iat'
    local at `at' `iat'
  }
}

sreturn local at "`at'"
sreturn local at_output "`atoutput'"
sreturn local nat "`nat'"
sreturn local at_scalefactor "`scalefactor'"
sreturn local at_unit "`unitname'"
sreturn local at_method "`method'"


end




program define SelectTime , sclass
syntax  anything(id="numlist" name=at) [, by(varlist) atoutput(numlist) SCALEfactor(real 1) UNITname(string) METHod(string) type(string) ]


 local before "step" 
 local mean "lin" 
  

if `"`by'"' != "" {
  local doby `"by `by' : "'
}

if `"`type'"' == "" {
  local type : char _dta[type]
} 
if `"`type'"' == "" {
  local type "kaplan-meier"
} 


if `"`method'"' == "" {
  local method `"`before'"'
}
local _dta : char _dta[_dta]

 if `"`_dta'"' != "netsurv" {
   di in red "error in sub program SelectTime of stns"
        exit 198
 }

*char list
   local timevar   : char _dta[time]
   local nevent    : char _dta[nevent]
   local natrisk   : char _dta[natrisk]
   local ncensored : char _dta[ncensored]

tempvar wat ww
  gen `wat' = 0
  gen `ww' = 0
  gen attimeoutput=.
  
  local nat : word count `at'


tempvar v vv vvv ne na nc
egen `vv' = cut(`timevar') ,  at(0 `at') icode
egen `vvv' = cut(`timevar') ,  at(0 `at')
replace `vv'=`vv'+1 if `timevar'!=`vvv'

gen `v' = .
local iv
foreach av of local at {
local  iv = `iv'+1
 replace `v' = `av' if  `vv' == `iv' 
}

local iv
foreach av of local atoutput {
local  iv = `iv'+1
 replace attimeoutput = `av' if  `vv' == `iv' 
}

 bysort `by' `v' : egen attime = max (`timevar') if `v' != .
capture table attime
  if _rc != 0 { 
    di in red "option at() incorrectly specified"
    exit _rc
  }


bysort  `by' `v' : egen  `ne' = total(`nevent')
bysort  `by' `v' : egen  `nc' = total(`ncensored')
bysort  `by' `v' : gen   `na' = `natrisk'[1]


sort `by' `timevar'
 bysort  `by' `v' : keep if _n == _N | _n ==1


replace `nevent'=`ne'
replace `ncensored' = `nc'
replace `natrisk' = `na'

/* my be useless  */
/* remove last row by `by' out of attime*/
/*
`doby' drop if attime ==. & _n==_N 
*/
/* remove first row by `by', unless first attime has only one raw */
/*
  `doby' drop if _n==1  & `v'[_n] == `v'[_n+1]
*/

if `"`method'"' == `"`mean'"' {

/* wat is computed at last row by `by' attime */
`doby' replace `wat'= (`v' - `timevar')/(`timevar'[_n+1]-`timevar') if `v' != `v'[_n+1] & _n < _N 

  if("`type'"=="kaplan-meier"){
    `doby' gen atsurv = `wat' * survival + (1-`wat') * survival[_n+1] if `v' != `v'[_n+1] & _n < _N 
    `doby' replace atsurv = survival  if   _N == _n
    gen atcumhaz= -log(atsurv)
  }
  else {
/* fleming-harrington / nelson -alen   */
    `doby' gen  atcumhaz = `wat' * cum_hazard + (1-`wat') * cum_hazard[_n+1] if `v' != `v'[_n+1] & _n < _N
    `doby' replace atcumhaz = cum_hazard  if   _N == _n 
    gen  atsurv  = exp(-atcumhaz)
  }

`doby' gen  atstderr = sqrt(`wat' * std_err^2 + (1-`wat') * std_err[_n+1]^2) if `v' != `v'[_n+1] & _n < _N
    `doby' replace atstderr = std_err  if   _N == _n 
}
else if `"`method'"' == `"`before'"' {
  gen atsurv = survival
  gen atcumhaz= cum_hazard
  gen atstderr = std_err
}

 drop if  attime == .


 bysort `by'  attime : keep if _n == _N

drop survival cum_hazard std_err
rename atsurv survival
rename atcumhaz cum_hazard
rename atstderr std_err

/* to force recomputation of CI */
char _dta[cilevel]  -1

end





program define ParseSaving, sclass
        * fn[,replace]

        sreturn clear
        if `"`0'"' == "" {
                exit
        }
        gettoken fn      0 : 0, parse(",")
        gettoken comma   0 : 0
        if length("`comma'") > 1 {
		local 0 = substr("`comma'",2,.) + "`0'"
 		local comma = substr("`comma'", 1,1)
	}
        gettoken replace 0 : 0
	
	local fn = trim(`"`fn'"')
        local 0 = trim(`"`0'"')
        if `"`fn'"'!="" & `"`0'"'=="" {
                if `"`comma'"'=="" | (`"`comma'"'=="," & `"`replace'"'=="") {
                        sreturn local fn `"`fn'"'
                        exit
                }
                if `"`comma'"'=="," & `"`replace'"'=="replace" {
                        sreturn local fn `"`fn'"'
                        sreturn local replace "replace"
                        exit
                }
        }
        di as err "option saving() misspecified"
        exit 198
end


version 10.0
mata:

void GetZipFileName()
{
        string scalar Tok, ReverseTok, FileName, Path

        Tok = st_global("s(fn)")
        Tok = subinstr(Tok, "\", "/")
        if (strpos(Tok, "/")) {
                ReverseTok = strreverse(Tok)
                FileName = ///
                strreverse(substr(ReverseTok, 1, strpos(ReverseTok, "/")-1))
                Path = ///
                strreverse(substr(ReverseTok, strpos(ReverseTok, "/"), .))

                if(strpos(FileName, ".") == 0) {
                        FileName = FileName + ".dta"
                        Tok = Path + FileName
                        st_local("newfile", Tok)
                }
                else {
                        st_local("newfile", Tok)
                }
        }
        else {
                if(strpos(Tok, ".") == 0) {
                        Tok = Tok + ".dta"
                        st_local("newfile", Tok)
                }
                else {
                        st_local("newfile", Tok)
                }
        }
}
end


program define ByStrata, sclass
	args by strata 

	sreturn clear

	if !("`by'"=="" & "`strata'"=="") {
		if "`by'"!="" & "`strata'"!="" {
			di in red /*
			*/ "options by() and strata() may not be combined"
			exit 198
			// this is no longer allowed (as of version 10) 
			// sreturn local sb "`by' `strata'"
		}
		else if "`by'"!="" { 
			sreturn local sb "`by'" 
		}
		else sreturn local sb "`strata'"
	}
end



program st_endfollowup
syntax  [if/]  [, end_followup(string)]
	local endf : char _dta[endf] 
		if (`end_followup' > 0){
			if (`"`if'"' =="") {
				replace _d = 0              if (_t > `end_followup')
				replace _t = `end_followup' if (_t > `end_followup')
				replace _t0 = `end_followup' if (_t0 > `end_followup')
			}
			else {
				replace _d = 0              if `if' & (_t > `end_followup')
				replace _t = `end_followup' if `if' & (_t > `end_followup')
				replace _t0 = `end_followup' if `if' & (_t0 > `end_followup')
			}
		}
end



program define WhichType, rclass
	args type 
/* type of estimate */

  if `"`type'"' == "" {
    local type "kaplan-meier"
  }
  else {
    local type = lower(`"`type'"')
    if index(`"`type'"', "ka") {
      /* assuming  kaplan-meier  */
      local type "kaplan-meier"
    }
    else if index(`"`type'"', "fl") {
      /* assuming  "fleming-harrington-nelson aalen"  */
      local type "fleming-harrington-nelson-aalen"
    }
    else {
       display as error `"unrecognised type() : `type'"'
       /*display as error `"use  KAplan[-MEier] or NElson[-AAlen-FLeming-HArrington]"'*/
       display as error `"use  KAplan[-meier] or FLeming-[harrington-nelson-aalen]"'
       exit 1000
 
    }
  }
    return local type `"`type'"'
   
end
   

program define WhichBeginTime, rclass
	args begintime 
/* type of estimate */

  if `"`begintime'"' == "" {
    local begintime "origin"
  }
  else {
    local begintime = lower(`"`begintime'"')
    if index(`"`begintime'"', "ori") {
      /* assuming  origin */
      local begintime "origin"
    }
    else if index(`"`begintime'"', "ent") {
      /* assuming  "enter"  */
      local begintime "enter"
    }
    else {
       display as error `"unrecognised begintime() : `begintime'"'
       /*display as error `"use  ORIgin or ENTer"'*/
       display as error `"use   begintime(ORIgin) or  begintime(ENTer)"'
       exit 1000

    }
  }
    return local begintime `"`begintime'"'
    
end
    




program define WhichCiType, rclass
	syntax , [ plain log loglog * ]

 
/* type of confidence limites */

  if `"`options'"' != "" {
    display as error	///
    `"options citype should be "plain", "log" or "loglog""'
    exit 198
  }
  else if `"`plain'"' != "" {
    local citype "plain"
  }
  else   if `"`log'"' != "" {
    local citype "log"
  }
  else   if `"`loglog'"' != "" {
    local citype "log-log"
  }
  else {
    local citype "plain"
  }

return local citype `"`citype'"'
    
end
    

/* check if conf limits should be recomputed and recompute if necessary */
program define CheckCI, rclass
syntax  , [ CITYpe(string) Level(string ) ]   		

/* set type of confidence limits */
local oldcitype :  char _dta[citype] 
local oldcilevel :  char _dta[cilevel] 

if `"`citype'"' == "" {
local citype `oldcitype'
}
else {
  WhichCiType , `citype'
  local citype `r(citype)'
}

if `"`level'"' == "" {
  local level `oldcilevel'
}
else syntax  ,  Level(cilevel)[ * ] 

if ( `"`citype'"' != `"`oldcitype'"')  | (`"`level'"' !=  `"`oldcilevel'"') {
  scalar se_fac= sqrt(invchi2(1,`level'/100))
  if(`"`citype'"'=="plain"){
      qui replace lower_bound = survival *(1 - std_err * se_fac)
      qui replace upper_bound = survival *(1 + std_err * se_fac)
      qui replace ch_lower_bound = cum_hazard  - std_err * se_fac
      qui replace ch_upper_bound = cum_hazard  + std_err * se_fac
    }
    else if(`"`citype'"'=="log"){
      qui replace lower_bound = survival/exp( std_err * se_fac)
      qui replace upper_bound = survival*exp( std_err * se_fac)
      qui replace ch_lower_bound = cum_hazard - std_err * se_fac
      qui replace ch_upper_bound = cum_hazard + std_err * se_fac
    }
    else if(`"`citype'"'=="log-log"){
      qui replace lower_bound = survival^exp(-std_err/log(survival) * se_fac)
      qui replace upper_bound = survival^exp( std_err/log(survival) * se_fac)
      qui replace ch_lower_bound = cum_hazard - std_err * se_fac
      qui replace ch_upper_bound = cum_hazard + std_err * se_fac
    }
  char _dta[citype] `citype'
  char _dta[cilevel]  `level'
  scalar drop se_fac
}
else {
}

end


program manage_strata, rclass

/* 
// parse input for strata in ratetable

// parse off specifications till comma
// multiple specs are necessarily parenthesized.
//
// -anything- cannot be used due to possible syntax of test
//   test exp=exp                                                 */

  local strata
  local tablestrata
  local nstrata = 0
  while `"`0'"' != "" {
    /* extract next stratum  */
    gettoken part 0 : 0, parse(" ,") match(paren) bind quotes
    local stratum
    while `"`part'"' != ","  & `"`part'"' != "" {
      local stratum `"`stratum' `part'"'
      gettoken part 0 : 0, parse(" ,") quotes
    }

    local nstrata = `nstrata'+1

    
    /* parse the stratum */
    /* stratum should be  varname or varname = varname  */
    tokenize  `"`stratum'"' , parse(" =")  
    if  "`4'" != "" {
      display as error "invalid syntaxe for strata(), see help"
      display as error "strata should be separated by a "," (comma)"'
      exit
    }
    if "`2'" == "=" {
      capture confirm variable `1'
      if _rc!=0 {
        display as error "variable `1' not found"
        exit _rc
      }
      local strata `"`strata' `1'"'
      capture confirm names `3'
      local rc = _rc
      if _rc!=0 {
        error `rc'
        display as error "`3' invalide name"
        exit _rc
      }   
      local tablestrata `"`tablestrata' `3'"'
    }
    else {
      if "`2'" != "" {
        /* more than one variable */
        foreach vv of local  stratum {
          capture confirm variable `vv'
          if _rc!=0 {
            display as error "variable `vv' not found"
            exit _rc
          }
          local strata `"`strata' `vv'"'
          local tablestrata `"`tablestrata' `vv'"'
        }
      }
      else {
        capture confirm variable `1'
        if _rc!=0 {
          display as error "variable `1' not found"
          exit _rc
        }
        local strata `"`strata' `1'"'
        local tablestrata `"`tablestrata' `1'"'
      }
    }
}      

return local strata `"`strata'"'
return local tablestrata `"`tablestrata'"'
return scalar nstrata = `nstrata'

end

