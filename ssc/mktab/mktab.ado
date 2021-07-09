	*! mktab Version 3.3 Nick Winter 30jun2005
*! Program to print tables of estimates
program define mktab
	version 8				// this is horrible; but I use some version 8 stuff below
	version 7				// but also don't want to break the stuff that relies on v.7

	if replay() {
		di in r "Can't replay this command"
		error 198
	} 

* Parse the equations ([eqname:] y1 [y2 y3 =] x1 x2 x3)

	gettoken arg : 0 , parse(" ,")
	if `"`arg'"'=="wrapper" {
		MakeWrap `0'
		exit
	}
	

	local n_eq = 0
	gettoken fulleq 0 : 0, parse(" ,[") match(paren)
	IsStop `fulleq'
	while `s(stop)' == 0 { 
		if "`paren'" != "(" {		/* must be eq */
			eq ?? `fulleq' 
			local fulleq "`r(eqname)': `r(eq)'"
		} 
		parseEqn `fulleq'

		foreach v of varlist `depvars' {
			local n_eq = `n_eq' + 1
			local y`n_eq' `v'
			local rhs`n_eq' `indvars'
			local rhs `rhs' `indvars'
			local cons`n_eq' `constant'
		}

		gettoken fulleq 0 : 0, parse(" ,[") match(paren)
		IsStop `fulleq'
	}

	local 0 `"`fulleq' `0'"'			/* fulleq will be comma at this point */

	if `n_eq' < 1 {
		di in red "equation(s) required" 
		exit 198
	}

	DropDup rhs : "`rhs'"          /* kill duplicates in full RHS list */

	syntax [if] [fw aw pw iw], ///
		[ LOG(string) CMD(string) ///
		Est(string) Aux(string) 		///
		Tag(string) Flag(string) ///
		Noisily Continue ///
		XLabel YLabel ///
		T1title(string) T2title(string) B1title(string) B2title(string) ///
		NOTEs(string asis) ///
		BFmt(string) SFmt(string) EFmt(string) PFmt(string) ///
		noTITle noBTITle Delimit(string) ONEtail ///
		SCreen VSPace(integer 20) CONnect noTAGS Print(varlist) noSPLIT ///
		PLevels  noSE OR ONETitle ///
		MIF(string) MIFLabel(string asis)  ///
		HTML ///
		LATex DOLatex(string) noCAPtion ///
		* ]

**********************************************************************
*Check the options
	
	if "`screen'"=="screen" { local connect }

	local dispif `"`if'"'
	
	if "`cmd'"=="" {                     /* default to regression */
		local cmd "regress"
	}

	if "`or'"=="" {
		local or 0
	}
	else {
		if "`cmd'"=="svylogit" | substr("`cmd'",1,4)=="logi" {
			local or 1
		}
		else {
			di as err "option or invalid except with cmd(logit) or cmd(svylogit)"
			error 198
		}
	}


	if "`noisily'"=="noisily" {
		local shhh "noisily"
	}
	if "`weight'"!="" {
		local weight "[`weight'`exp']"
	}

	if "`delimit'"=="" {
		local ps "{c 9}"
		local da1 "{c 9}"
		local db1 "{c 9}"
	}
	else {
		local ps "`delimit'"
		local da1 "`delimit'"
		local db1 "`delimit'"
	}
	
	if "`onetitle'"=="onetitle" {
		forval i=2/`n_eq' {
			if "`y1'"!="`y`i''" {
				di
				di as error "DVs must all be same when onetitle is specified"
				exit 198
			}
		}
	}
	
	
	
	if "`screen'"=="screen" {
		local da1 "{res}{ralign 9:"
		local da2 "}"
		local db1 "{text}{lalign 3:"
		local db2 "}"
		local dz1 {text}{lalign `vspace':
		local dz2 `"}"'
		local ps
		local normal 0
	}
	else {
		local dz1 "{text}"
		local normal 1
		local vspace 80
	}
	
	if "`html'"=="html" {
		local dz1 "{text}<TR ALIGN=center><TH ALIGN=left>"
		local dz2 
		local da1 "<TD>"
		local da2
		local db1 "<TD>"		/* not actually used I think, because connect is set */
		local db2
		local ps "<TH>"
		local normal 1
		local cap1 "<CAPTION>"
		local cap2 "</CAPTION>"
		local htmlbr "<BR>"
		
		local colspan=(`n_eq' * 2)+1
		local foot1 "<TR ALIGN=left><TD COLSPAN=`colspan'><SMALL>"
		local foot2 "</SMALL>"

		local htmlex1 "<TR ALIGN=left><TH COLSPAN=`colspan'><SMALL>"	/* surround descriptive stuff at top and bottom */
		local htmlex2 "</SMALL>"


		local tags "notags"
		local connect connect
		local split "nosplit"
	}

	if "`connect'"=="connect" {
		local db1 ""
		local db2 ""
	}


	if "`onetitle'"=="onetitle" {
		local split nosplit
	}


	if "`print'"!="" {
		foreach v of local print {
			foreach v2 of local rhs {
				if ("`v'"=="`v2'") {
					local plist "`plist' `v'"
				}
			}
		}
		local rhs `plist'
	}
	
	local n_rhs : word count `rhs'

	if "`bfmt'"=="" { local bfmt "%4.3f" }
	if "`sfmt'"=="" { local sfmt "`bfmt'" }
	if "`efmt'"=="" { local efmt "%3.2f" }
	if "`pfmt'"=="" { local pfmt "%5.4f" }

	tempname x			/* check that formats are valid */
	gen `x'=0
	format `x' `bfmt'
	format `x' `sfmt'
	format `x' `efmt'
	format `x' `pfmt'

	local n_mif=0
	if `"`mif'"'!="" {
		local n_allif=index(`"`mif'"',":")
		if index(`"`mif'"',":") > 0 {
			gettoken allif mif : mif , p(":")
			gettoken junk  mif : mif , p(":")			/* throw away colon */
		}
		
		if index(`"`mif'"',"\") > 0 {
			local i 1
			while `"`mif'"'!="" {
				gettoken mif`i' mif : mif , p("\")
				gettoken junk   mif : mif , p("\")			/* throw away backslash */
				local i=`i'+1
			}
			local i=`i'-1
		}
		else {
			numlist `"`mif'"'
			local nl `r(numlist)'
			local i : word count `nl'
			forval x=1(1)`i' {
				local mif`x' : word `x' of `nl'
			}
		}

		local n_mif=`i'
		local mif "mif"
		if "`onetitle'"=="" {
			if "`latex'"=="latex" {
				Fix4LaTeX pallif `"`allif'"'
			}
			else {
				local pallif `allif'
			}
			local mifline `"`dz1'Among `pallif'`dz2'"'
		}
		else {
			local mifline `"`dz1'`dz2'"'
		}
		if `"`if'"'==`""' {
			local if `"if `allif'"'
		}
		else {
			local if `"`if' & `allif'"'
		}
		
		if `"`miflabel'"'!="" {
			tokenize `"`miflabel'"'
			local i 1
			while `"``i''"'!="" {
				local miflab`i' ``i''
				local ++i
			}
			if (`i'-1)!=`n_mif' {
				di as error `i'-1 " miflabel() and `n_mif' mif()"
				exit 198
			}
		}
		else {
			forval i=1/`n_mif' {
				local miflab`i' `mif`i''
			}
		}
	}
	else {
		local mif 
	}

	if `n_eq'==1 & `n_mif'>1 {
		forval j=1(1)`n_mif' {
			local y`j' `y1'
			local rhs`j' `rhs1'
			local cons`j' `cons1'
		}
		local n_eq `n_mif'
	}

	if (`n_mif'!=0) & (`n_mif' != `n_eq') {
		local s1=cond(`n_eq'>1,"s","")
		local s2=cond(`n_mif'>1,"s","")
		di in red "`n_eq' equation`s1' and `n_mif' mif() condition`s2'"
		error 198
	}

	*****************************************
	* LaTeX setup
	* Down here because need to know n_eq
	
	if "`latex'"=="latex" {
		local dz0 "<_DBS_> \addlinespace{c 10}"
		local dz1	"<_DBS_> {c 10}" 			// pre/post first cell in column (varname)
		local dz2
				
		local da1 "&" 					// delimiter for coefficients
		local da2 
		
		local db1 ""					// delimiter for significance stars (blank for connect)
		local db2 ""
		
		local dc1_a "&\raisebox{.7ex}[0pt]{\scriptsize "					// delimiter for std error
		local dc2 "}"

		local dc1 "{c 10}`dc1_a' "

		if "`onetitle'"=="" {
			local ps "& " 					// between titles
			local psc ""
		}
		else {
			local ps "&"
		}
		
		local normal 1				// ????
		
		local cccc : di _dup(`n_eq') " r@{}l"
		
		if "`caption'"!="nocaption" {
			local caption "\caption{{\em `t1title'}}{c 10}"
		}
		else {
			local caption
		}
		
*		local t1title "\begin{table}[ht] \begin{center}{c 10}\caption{`t1title'} \begin{tabular}{@{\extracolsep{\fill}} l | `cccc' }"
		local t1title "\begin{table}[ht]{c 10}\begin{center}{c 10}\begin{threeparttable}{c 10}`caption'\begin{tabular}{ l `cccc' }{c 10}"

		local t2title "\toprule"
		local b1title "<_DBS_>{c 10}\bottomrule" 						// "\hline"
		local b2title "\end{tabular}{c 10}\begin{tablenotes}[flushleft]"

		local colspan=(`n_eq' * 2)+1
		local foot1 				// beginning of footer: <TR ALIGN=left><TD COLSPAN=`colspan'><SMALL>
		local foot2 				// end of footer        </SMALL>
		
		local tags notags
		local connect connect
		*local split nosplit
	}
	else {
		local dx1 = "`dz1'"
		local dx2 = "`dz2'"
	}
	
	if "`dc1'"=="" {
		local dc1 "`da1'"
	}
	if "`dc2'"=="" {
		local dc2 "`da2'"
	}


*Set up significance levels
	if "`onetail'"!="" {
		local sigsuff "one-tailed (coefficients); two-tailed (auxiliaries)"
	}
	else {
		local sigsuff "two tailed"
	}
	if "`flag'"!="" {                      /* user-set sig. levels */
		tokenize "`flag'", parse(",")
		local j 1
		while "`1'"!="" {
			if "`1'"!="," {                           /* skip commas */
				local equal=index("`1'","=")
				if `equal'==0 {
					di in r "must indicate symbols for user-set signif. levels"
					error 198
				}
				else {
					local sig`j'=substr("`1'",1,`equal'-1)       /* get level */
					local sig`j'=(`sig`j''/100)
					if (`sig`j''<0 | `sig`j''>1) {
						di in red "Significance `sig`j'' out of range"
						error 198
					}
					if (`j'>1) {
						local x=`j'-1
						if (`sig`j''<=`sig`x'') {
							di in r "significance flags must be " _c
							di in r "in ascending order"
							error 198
						}
					}
					local sym`j'=trim(substr("`1'",`equal'+1,.))
					if (`sig`j'')>0 {
						local sigline "`sigline'`sym`j'' p<0`sig`j''; "
					}
				}
				local j=`j'+1
			}
			mac shift
		} /* while */
		local n_sig=`j'-1
		local sigline "`sigline' `sigsuff'"
	}
	else {                         /* no user-set significance levels */
		local sig1 0.01
		local sig2 0.05
		local sig3 0.10
		local sym1 "**"
		local sym2 "*"
		local sym3 "^"
		local sigline "`sym1' p<0.01; `sym2' p<0.05; `sym3' p<0.10 `sigsuff'"
		if "`latex'"=="latex" {
			local sym1 "$^{**}$"
			local sym2 "$^{c -(}*{c )-}$"
			*local sym3 "$^o$"
			local sym3  "\raisebox{.7ex}[0pt]{\tiny $\wedge$}"				// small, raised caret!
			local sigline "`sym1' p$<$`sig1'; `sym2' p$<$`sig2'; `sym3' p$<$`sig3' `sigsuff'"
		}
		local n_sig 3
	}

*Initalize strings 
*tline
	local tline1 `"`dx1' `dx2'"' /* title lines */
	local tline2 `"`dz1' `dz2'"'
	local tline3 `"`dz1' `dz2'"'
	local tline4 `"`dz1' `dz2'"'
	local tline5 `"`dz1' `dz2'"'
	local tline6 `"`dz1' `dz2'"'
	local tline7 `"`dz1' `dz2'"'			// in case LateX uses all size plus extra for linebreak

*blines (coefficients) and slines (std errors)
	local j 1
	while `j'<=`n_rhs' {
		local vname : word `j' of `rhs'
		if "`ylabel'"=="ylabel" {
			local vlab : var lab `vname'
			if "`vlab'"!="" {
				local vname "`vlab'"
			}
		}
		if "`latex'"=="latex" {
			Fix4LaTeX vname `"`vname'"'
		}

		if "`screen'"=="screen" {
			local Vn1=substr("`vname'",1,`vspace')
			local Vn2=substr("`vname'",`vspace'+1,`vspace')
		}
		else {
			local Vn1 `vname'
			local Vn2
		}

		if `j'==1 {
			local delim x
		}
		else {
			local delim z
		}

		local bline`j' `"`d`delim'1'`Vn1'`d`delim'2'"'
		local sline`j' `"`dz1'`Vn2'`dz2' "'

		local j=`j'+1
	}

*alines (auxiliary estimates) and Alines (aux std. errors)
	local auxlist "`aux'"
	local aux 
	local j 1
	parse "`auxlist'", parse(",")
	while "`1'"!="" {
		if "`1'"!="," {
			local equal=index("`1'","=")
			if `equal'==0  {
				local auxx "`1'"
				local aname  "`1'"
			}
			else {
				local auxx=substr("`1'",1,`equal'-1)
				local aname =substr("`1'",`equal'+1,.)
			}
			local aux "`aux' `auxx'"     /* reassemble aux list w/o names */
			
			if "`screen'"=="screen" {
				local An1=substr("`aname'",1,`vspace')
				local An2=substr("`aname'",`vspace'+1,2*`vspace')
			}
			else {
				local An1 `aname'
				local An2
			}

			local aline`j' `"`dz1'`An1'`dz2'"'
			local Aline`j' `"`dz1'`An2'`dz2' "'
			
			local j=`j'+1
		}
		mac shift
	}
	local n_aux : word count `aux'

*elines (--estimates returned--)
	local estlist "`est'"
	local est 
	local j 1
	parse "`estlist'", parse(",")
	while "`1'"!="" {
		if "`1'"!="," {
			local equal=index("`1'","=")
			if `equal'==0  {
				local estx "e(`1')"   /* current estimate to get */
				local ename  "`1'"         
			}
			else {
				local estx=substr("`1'",1,`equal'-1)
				local estx="e(`estx')"
				local ename=substr("`1'",`equal'+1,.)
			}
			local est "`est' `estx'"     /* assemble res list w/o names */



			if "`screen'"=="screen" {
				local En1=substr("`ename'",1,`vspace')
			}
			else {
				local En1 `ename'
			}

			if "`latex'"=="latex" & `j'==1 {			// yucky insertion of extra space
					local eline`j' `"`dz0'`En1'`dz2'"'
			}
			else {
				local eline`j' `"`dz1'`En1'`dz2'"'
			}

			local j=`j'+1
		}
		mac shift
	}
	local n_est : word count `est'

*IF Line: iline
	if `"`if'"'!="" {
		local In 1
		local Is 1
		local Ie `vspace'
		local iline1=substr(`"`if'"',`Is',`Ie')
		while "`iline`In''"!="" {
			local In=`In'+1
			local Is=`Is'+`vspace'
			local iline`In'=substr(`"`if'"',`Is',`Ie')
		}
	}
	else {
		local In 0
	}

*Run command for one LHS variable and grab results
	local lhmax 1								/* start assuming only one title line */
	local i 1                                         /* `i' is DV number */
	while `i' <= `n_eq' {
		cap `shhh' di `"{cmd}- `cmd' `y`i'' `rhs`i'' `weight' `if' `mif`i'' , `cons`i'' `options' -"'
		cap `shhh' `cmd' `y`i'' `rhs`i'' `weight' `if' `mif`i'' , `cons`i'' `options' 
		if _rc {
			if _rc==2000 {
				di as text "{hi}Note: no observations for equation `i'"
				est clear
			}
			else {   /* some other error */
				di
				di as error "Problem running equation `i':"
				di "{p 5 5 5}{hi}-`cmd' `y`i'' `rhs`i'' `weight' `if' `mif`i'' , `cons`i'' `options'-"
				error _rc
			}
		}

		local lhname "`y`i''"
		if "`xlabel'"=="xlabel" {
			local lhname : var lab `y`i''
			if "`lhname'"=="" {
				local lhname "`y`i''"
			}
		}
		if "`latex'"=="latex" {
			Fix4LaTeX lhname `"`lhname'"'
		}

		if "`split'"!="nosplit" {
			local k 1										/* break up title */
			while `k'<=6 {
				if `normal' {
					local lhn`k' : piece `k' 13 of "`lhname'"
					if length("`lhn`k''")>0 {
						local max `k'
					}
					local k=`k'+1
				}
				else {
					local lhn`k' : piece `k' 8 of "`lhname'"
					if length("`lhn`k''")>0 {
						local max `k'
					}
					local k=`k'+1
				}
			}
			if `max'>`lhmax' {								/* set max number of title rows */
				local lhmax `max'
			}
		}
		else {
			local lhn1 "`lhname'"
			local lhmax 1
		}



		if "`latex'"=="" {
			local psc=cond("`connect'"=="","`ps'","")
		}
		
		if "`onetitle'"=="" {
			local k 1
			while `k'<=6 {
				if `normal' {
					if "`latex'"=="latex" {
						local tline`k' "`tline`k''`ps'\multicolumn{2}{c}{{\em `lhn`k''}}`psc'"     /* add LH part to title line */
					}
					else{
						local tline`k' "`tline`k''`ps'`lhn`k''`psc'"     /* add LH part to title line */
					}
					local k=`k'+1
				}
				else {
					local nextpart : di %~12s "`lhn`k''"
					local tline`k' "`tline`k''{txt}`nextpart'"     /* add LH part to title line */
					local k=`k'+1
				}
			}
		}
		else if `i'==1 {									/* only add title first time through */
			if "`latex'"=="latex" {
				local tline1 "`tline1'`ps'\multicolumn{`=`n_eq'*2'}{c}{{\em `lhn1'}}"
			}
			else {
				local tline1 "`tline1'`ps'`lhn1'"			
			}
		}
		
		if "`mif'"!="" {
			if "`latex'"=="" {
				local mifline "`mifline'`da1'`miflab`i''`da2'`db1'`db2'"
			}
			else {
				Fix4LaTeX mif`i' `"`mif`i''"'
				local mifline "`mifline'`da1'\multicolumn{2}{c}{{\em `miflab`i''}}`da2'`db1'`db2'"
			}
		}

		local dof = e(df_r)                  /* dof for signif calc */
		if "`dof'"=="." {                    /* figure type of stat */
			local stat "z"                  /* z stat */
		}
		else { 
			local stat "t"                  /* t stat */
		}

*now loop through RHS vars to do b's and s's for this equation
		local j 1                                   /* `j' is RHS var number */
		while `j' <= `n_rhs' {
			local curvar : word `j' of `rhs'
			cap local b = _b[`curvar']
			if _rc {							/* not in this equation */
				local b "--"
				local s 
				local sig 
				local p 
			}
			else {
				local s = _se[`curvar']

				local t = abs((`b')/(`s'))	    				/* ratio - positive */

				if `or' & !(`b'==0 & `s'==0) {		/* transform to odds if not dropped */
					local b = exp(`b')
					local s=`s'*`b'
				}
				
				if "`stat'"=="z" {
					if "`onetail'"=="" {
						local p = (2*(norm(-(`t'))))   			/* calculate 2-tail p */
					}
					else {
						local p = (norm(-(`t'))) 		  		/* calculate 1-tail p */
					}
				}
				else {
					if "`onetail'"=="" {
						local p = ttail(`dof',abs(`t'))*2					/* 2-tail */
					}
					else {
						local p = ttail(`dof',abs(`t'))					/* 1-tail */
					}
				}

				local sig                           /* label significance */
				local x `n_sig'
				while `x'>=1 {
					if `p'<(`sig`x'') {
						local sig "`sym`x''"
					}
					local x=`x'-1
				}
				if ((`b')==0 & (`s')==0) {         /* if dropped */
					local b "--"
					local s 
					local sig 
					local p 
				}
				else {                                       /* otherwise round */
					local b : di `bfmt' `b'
					local s : di "(" `sfmt' `s' ")"
					local p : di "[" `pfmt' `p' "]"
				}

			}
			if "`plevels'"!="" {
				local s `"`p'"'
			}


			if "`html'"!="html" {
				if "`latex'"=="latex" {
					FixBTab b "`b'" "`da2'" "`da1'" 
					FixBTab s "`s'" "`dc2'" "`dc1_a'"
				}
				local bline`j' "`bline`j''`da1'`b'`da2'`db1'`sig'`db2'"   /* add this beta */
				local sline`j' "`sline`j''`dc1'`s'`dc2'`db1'`db2'"
				
			}
			else { /* IS HTML */
				local bline`j' "`bline`j''`da1'`b'`sig'<BR><SMALL>`s'</SMALL>`da2'"
				local sline`j'		/* blank them out */
			}

			
			local j=`j'+1
		}

* do auxilaries for this EQ
		local j 1                                  /* j is aux number */
		while `j'<=`n_aux' {
			local aname : word `j' of `aux'
			cap local b = _b[`aname']         
			if _rc!=0 {                                 /* if unsuccessful */
				local b "--"
				local s 
				local sig 
				local p 
			}
			else {                                  /* if successful */
				local s=_se[`aname']
				
				local t = abs((`b')/(`s'))

				if `or' & !(`b'==0 & `s'==0) {	/* transform to odds-ratio if not droped */
					local b=exp(`b')
					local s=`b'*`s'
				}

				if "`stat'"=="z" {
					local p = 2*(norm(-(`t')))                /* calculate 2-tail p */
				}
				else {
					local p = 2*ttail(`dof',`t')
				}

				local sig 
				local x `n_sig'

				while `x'>=1 {
					if `p'<(`sig`x'') {
						local sig "`sym`x''"
					}
					local x=`x'-1
				}

				local b : di `bfmt' `b'
				local s : di "(" `sfmt' `s' ")"
				local p : di "[" `pfmt' `p' "]"
			}
			
			if "`plevels'"!="" {
				local s `"`p'"'
			}

			if "`html'"!="html" {
				if "`latex'"=="latex" {
					FixBTab b "`b'" "`da2'" "`da1'" 
					FixBTab s "`s'" "`dc2'" "`dc1_a'"
				}
				local aline`j' "`aline`j''`da1'`b'`da2'`db1'`sig'`db2'"
				local Aline`j' "`Aline`j''`dc1'`s'`dc2'`db1'`db2'"        /* aux se line */
			}
			else {   /* IS HTML */
				local aline`j' "`aline`j''`da1'`b'`sig'<BR><SMALL>`s'</SMALL>`da2'"
				local Aline`j'    /* blank out */
			}

			local j=`j'+1
		}



*estimates returned for this EQ
		local j 1
		while `j'<=`n_est' {
			local ename : word `j' of `est'
			local e=`ename'
			if int(`e')!=(`e') {            /* don't reformat integers! */
				local e : di `efmt' `e'
			}
			else {
				local e : di %9.0gc `e'
				local e=trim("`e'")
			}

			if "`latex'"=="latex" {
				local e : subinstr local e "-" "--"
				local e "\multicolumn{2}{c}{`e'}"
			}
			local eline`j' "`eline`j''`da1'`e'`da2'`db1'`db2'"

			local j=`j'+1
		}

*Now loop back to next Eq . . .
		local i=`i'+1
	}
	
	if "`latex'"=="latex" {
		local lhmax = `lhmax'+1
		
		if "`mifline'"!="" {
			local mifline `"`mifline' <_DBS_> {c 10} \cmidrule(lr){2-`=`n_eq'*2+1'}{c 10}"'		// annoying!!!
			local tline`lhmax' "<_DBS_> "
		}
		else {
			local tline`lhmax' `"<_DBS_> {c 10} \cmidrule(lr){2-`=`n_eq'*2+1'}{c 10}"'
		}
	}

*Now Print out the whole shebang:

	qui log
	if `"`r(filename}'"'!="" & "`log'"!="" {     /* close open log if necessary */
		local logfile `"`r(filename)'"'
		qui log close
	}
	if "`continue'"=="continue" {
		local linen=($S_rnum+1)
	}
	else {
		local linen 1
	}
	local lls : set  linesize
	set linesize 255

	if "`log'"!="" {
		qui log
		if "`r(status)'"!="" {
			local oldlog `"`r(filename)'"'
			local oldstat `r(status)'
			local oldtype `r(type)'
			qui log close
		}
		if index(`"`log'"',",") {
			qui log using `log' text
		}
		else {
			qui log using `log', text
		}
	}

	if "`screen'"=="screen" | "`tags'"=="notags" {
		local dotag 0
	}
	else {
		local dotag 1
	}
	if "`screen'"=="screen" {
		local screendi "di"
	}
***
***KLUDGE:
***
	if "`html'"=="html" {
		di "<TABLE BORDER=1>"
	}
		
***
***
***

	`screendi'

********
	if "`t1title'"=="" & "`t2title'"=="" & "`title'"!="notitle" {

		if "`tag'"~="" {
			local space " "
		}
		if !`or' {
			DoDisp `dotag' `linen' "`tag'" 0 "`ps'" `"{txt}`cap1'`tag'`space'Estimates (using $S_E_cmd)`cap2'"'
		}
		else {
			DoDisp `dotag' `linen' "`tag'" 0 "`ps'" `"{txt}`cap1'`tag'`space'Estimates-Odds Ratios (using $S_E_cmd)`cap2'"'
		}
		local linen=`linen'+1
	}
	else {
		if "`t1title'"!="" {
			DoDisp `dotag' `linen' "`tag'" 0 "`ps'" `"{txt}`cap1'`t1title'`htmlbr'"'
			local linen=`linen'+1
		}
		if "`t2title'"!="" {
			DoDisp `dotag' `linen' "`tag'" 0 "`ps'" `"{txt}`t2title'`cap2'"'
			local linen=`linen'+1
		}
	}

	if `"`dispif'"'!="" {
		if "`onetitle'"=="" {
			local diif = substr(`"`dispif'"',4,.)
		}
		else {
			local diif
		}
		`screendi'
		DoDisp `dotag' `linen' "`tag'" 1 "`ps'" `"{text}`htmlex1'`ifxxx'`htmlex2'"'
		local linen=`linen'+1
	}

	if "`title'"~="notitle" {
		`screendi'
		forval i=1(1)`lhmax' {
			DoDisp `dotag' `linen' "`tag'" 1 "`ps'" `"`tline`i''"'
			local linen=`linen'+1
		}
	}

	if "`mif'"!="" {
		`screendi'
		DoDisp `dotag' `linen' "`tag'" 1 "`ps'" `"`mifline'"'
		local linen=`linen'+1
	}


	forval j=1(1)`n_rhs' {                               /* coefficient lines */
		if "`se'"!="nose" {
			`screendi'
		}
		DoDisp `dotag' `linen' "`tag'" 2 "`ps'" `"`bline`j''"'
		local linen=`linen'+1
		
		if "`se'"!="nose" {
			DoDisp `dotag' `linen' "`tag'" 3 "`ps'" `"`sline`j''"'
			local linen=`linen'+1
		}
	}

	forval j=1(1)`n_aux' {                               /* aux lines */
		`screendi'
		DoDisp `dotag' `linen' "`tag'" 2 "`ps'" `"`aline`j''"'
		local linen=`linen'+1
		
		DoDisp `dotag' `linen' "`tag'" 3 "`ps'" `"`Aline`j''"'
		local linen=`linen'+1
	}

	forval j=1(1)`n_est' {                               /* aux lines */
		if !(`j'-1) { `screendi' }
		DoDisp `dotag' `linen' "`tag'" 4 "`ps'" `"`eline`j''"'
		local linen=`linen'+1
	}

	if "`b1title'"!="" {                              /* bottom stuff */
		DoDisp `dotag' `linen' "`tag'" 5 "`ps'" `"`foot1'`b1title'`foot2'"'
		local linen=`linen'+1
	}
	if "`b2title'"!="" {
		DoDisp `dotag' `linen' "`tag'" 5 "`ps'" `"`foot1'`b2title'`foot2'"'
		local linen=`linen'+1
	}

	if "`latex'"=="latex" {
		local foot1 "\item \hspace{-0.2em}"
	}

	if `"`notes'"'!="" {
		tokenize `"`notes'"'
		while `"`1'"'!="" {
			DoDisp `dotag' `linen' "`tag'" 6 "`ps'" `"{text}`foot1'`1'`foot2'"'
			macro shift
		}
	}

	if "`sigline'"!="" & ("`btitle'"!="nobtitle") {
		DoDisp `dotag' `linen' "`tag'" 6 "`ps'" `"{text}`foot1'`sigline'`foot2'"'
		local linen=`linen'+1
	}

	if "`plevels'"!="" {
		DoDisp `dotag' `linen' "`tag'" 6 "`ps'" `"{text}`foot1'P-levels displayed below coefficients`foot2'"'
		local linen=`linen'+1
	}

	if "`weight'"!="" & "`btitle'"!="nobtitle" {
		DoDisp `dotag' `linen' "`tag'" 6 "`ps'" `"{text}`foot1'Weighted estimation: `weight'`foot2'"'
		local linen=`linen'+1
	}

	DoDisp `dotag' `linen' "`tag'" 7 "`ps'" `""'

	if "`latex'"=="latex" {
		di "\end{tablenotes}"
		di "\end{threeparttable}"
		di "\end{center}"
		di "\end{table}"
		di "\clearpage"
	}
	if "`html'"=="html" {
		di "</TABLE>"
	}

	if "`log'"!="" {								    /* if log specified, close */
		qui log close
	}
	
	set linesize `lls'   	                        /* reset log linesize */

	if "`oldlog'"!=""  {        	       /* reopen user log if nec. */
		qui log using `"`oldlog'"', append `oldtype'
		if "`oldstat'"=="off" {
			qui log off
		}
	}



	global S_rnum `linen'                       	     /* for continue option...*/

	if "`dolatex'"!="" {
		! latex `dolatex'
	}


end program   /* mktab */

/*	Display a line of output, with or without tag as appropriate */
program define DoDisp
	args dotag linen tag type d theline

	* Fix up double backslash for LaTeX:
	local theline : subinstr local theline `"<_DBS_>"' `"{c 92}{c 92}"' , all


	if `dotag' {
		di as res `"`linen'`d'`type'`d'`tag'`d'`theline'"'
	}
	else {	
		di `"`theline'"'
	}

end program



/*  Sets the local macros containing equation information in the caller 
 *  Equations may take the form:  
 *
 *           [eqname:] y1 [y2 y3 =] x1 x2 x3 [, noconstant] 
 *
 *  Sets the caller's local macros:  eqname, depvars, indvars and constant  */ 

program define parseEqn        

	/* see if we have an equation name */
	gettoken token uu : 0, parse(" =:")   /* rare, pull twice if found */
	gettoken token2 : uu, parse(" =:")     /* rare, pull twice if found */
	if index("`token2'", ":") != 0 {
		gettoken token  0 : 0, parse(" =:")      /* sic, to set 0 (get rid of eqname:) */
		gettoken token2 0 : 0, parse(" =:")      /* sic, to set 0                      */
		c_local eqname  `token'
	} 
	else c_local eqname 

	/* search just for "=" */
	gettoken token 0 : 0, parse(" =")
	while "`token'" != "=" & "`token'" != "" {
		local depvars `depvars' `token'
		gettoken token 0 : 0, parse(" =")
	}

	if "`token'" == "=" {
		tsunab depvars : `depvars'
		syntax [varlist(ts)] [ , noConstant ]		/* 0 now contains the RHS */
	} 
	else {				/* assume single depvar */
		local 0 `depvars'							/* put them all back */
		syntax varlist(ts) [ , noConstant ]
		gettoken depvars varlist : varlist			/* pull off the one DV */
	}

	c_local depvars `depvars'
	c_local indvars `varlist'
	c_local constant `constant'
end


program define IsStop, sclass
	if 	     `"`0'"' == "[" /*
		*/ | `"`0'"' == "," /*
		*/ | `"`0'"' == "if" /*
		*/ | `"`0'"' == "in" /*
		*/ | `"`0'"' == "" {
		sret local stop 1
	}
	else	sret local stop 0
end


/*  Drop all duplicate tokens from list */

program define DropDup   /* <newlist> : <list> */
	args	    newlist	/*  name of macro to store new list
		*/  colon	/*  ":"
		*/  list	/*  list with possible duplicates */

	gettoken token list : list
	while "`token'" != "" {
		local fixlist `fixlist' `token'
		local list : subinstr local list "`token'" "", word all
		gettoken token list : list
	}

	c_local `newlist' `fixlist'
end


/*  Remove all tokens in dirt from full */
 *  Returns "cleaned" full list in cleaned */

program define Subtract   /* <cleaned> : <full> <dirt> */
	args	cleaned	/*  macro name to hold cleaned list
		*/  colon	/*  ":"
		*/  full	/*  list to be cleaned 
		*/  dirt	/*  tokens to be cleaned from full */
	
	tokenize `dirt'
	local i 1
	while "``i''" != "" {
		local full : subinstr local full "``i''" "", word all
		local i = `i' + 1
	}

	c_local `cleaned' `full'       /* cleans up extra spaces */
end



program Fix4LaTeX
	args name string
	local string : subinstr local string "\" "\textbackslash " , all 
	local string : subinstr local string "{" "\{" , all 
	local string : subinstr local string "}" "\}" , all 
	local string : subinstr local string "$" "{c 92}$" , all 			// to deal with Stata's escaping!
	local string : subinstr local string "~" "$\sim$" , all 
	local string : subinstr local string "^" "$\wedge$" , all 
	local string : subinstr local string "&" "\&" , all 
	local string : subinstr local string "%" "\%" , all 
	local string : subinstr local string "#" "\#" , all 
	local string : subinstr local string "_" "\_" , all 
	local string : subinstr local string ">" "$>$" , all 
	local string : subinstr local string "<" "$<$" , all 
	c_local `name' `"`string'"'
end

program FixBTab
	args name b d1 d2 

	if index("`b'","--") {
		local b "`d1'`d2'`b'"
	}
	else if "`b'"=="" {
		local b "`d1'`d2'"
	}
	else {
		local b : subinstr local b "-" "--" 
		local b : subinstr local b "." ".`d1'`d2'"
	}
	c_local `name' `"`b'"'
end



program MakeWrap
	
	syntax anything , LOGfile(string) [ replace ]

	if !index(`"`logfile'"',".tex") {
		local logfile `logfile'.tex
	}

	capture confirm file "`logfile'"
	if _rc {
		di `"{txt}Warning:{res} `logfile'{txt} doesn't exist"'
	}

	local logfile : subinstr local logfile "\" "/"


	tempname hdl
	qui file open `hdl' using _`logfile' , text write `replace'
	file write `hdl' "\documentclass[8pt]{extarticle}" _n
	file write `hdl' "  \usepackage{threeparttable,booktabs}" _n

	file write `hdl' _n
	file write `hdl' "  \oddsidemargin  0.0in" _n
	file write `hdl' "  \evensidemargin 0.0in" _n
	file write `hdl' "  \textwidth      6.5in" _n
	file write `hdl' "  \topmargin      0.5in" _n
	file write `hdl' "  \textheight     9.0in" _n
	file write `hdl' _n


	file write `hdl' "\begin{document}" _n

	file write `hdl' _n
	file write `hdl' "  \input{`logfile'}" _n
	file write `hdl' _n


	file write `hdl' "\end{document}" _n

	file close `hdl'
	di `"{txt}File _`logfile' created as wrapper for `logfile'"'
	
end


*end& of file
