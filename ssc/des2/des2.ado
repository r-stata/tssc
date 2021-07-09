*! version 3.2.0 05aug2014 Daniel Klein

pr des2
	vers 9.2
	
	// prefix
	cap _on_colon_parse `0'
	if !(_rc) {
		if mi(`"`s(after)'"') err 198
		loc 0 `s(before)'
		loc command `s(after)'
	}
	
	// des2 call
	syntax [ anything(id = "varlist" equalok everything) ] ///
	[ , View View2(str) * ]
	
	// view from file
	if (`"`view2'"' != "") {
		if (`"`options'"' != "") Des2OptNotAllowed
		m : mDes2ConfSmclFile(`"`view2'"', "view2")
		view `"`view2'"'
		e 0 // done
	}
	
	// get options
	Des2GetOpts ,`view' `options'
	
	// get varlist
	if (`"`anything'"' != "") {
		Des2GetVarlist `anything' ///
		,`lookfor' `has' `not' `insensitive'
	}
	
	// add varlist from command
	if (`"`command'"' != "") {
		qui `command'
		loc vars `r(varlist)'
		loc varlist : list varlist | vars
	}
	
	// viewer mode
	if ("`view'" != "") {
		tempname fh
		tempfile des2view
		file open `fh' using `des2view' ,w
		loc print file w `fh'
		loc newl _n
	}
	else loc print di
	
	// the output
	if ("`more'" != "") & mi("`view'") se more on
	
	if mi("`varlist'") {
		if (`"`anything'`command'`has'`not'"' != "") {
			if ("`view'" != "") file close `fh'
			e 0 // done
		}
		
			// header
		`print' _n `"{bind:{txt}File: {res}`c(filename)'}"' `newl'
		`print' `"{bind:{txt}Date: {res}`c(filedate)'}"' `newl'
		`print' `"{bind:{txt}obs:  {res}`c(N)'}"' `newl'
		`print' `"{bind:{txt}vars: {res}`c(k)'}"' `newl'
		if ("`short'" != "") | !(c(k)) e 0 // done
		unab varlist : _all
	}
	
		// header 2
	`print' _n "{bind:{txt}variable name}" ///
	"{col `tcol1'}{bind:{txt}type}" ///
	"{col `tcol2'}{bind:{txt}format}" ///
	"{col `tcol3'}{bind:{txt}value label}" ///
	"{col `tcol4'}{bind:{txt}variable label}" `newl'
	`print' "{hline}" `newl'
	
	foreach var of loc varlist {
		loc typ : t `var'
		loc fmt : f `var'
		loc lbn : val l `var'
		loc vlb : var l `var'
		
		m : st_local("var", substr(st_local("var"), 1, `varwidth'))
		m : st_local("lbn", substr(st_local("lbn"), 1, `valwidth'))
		m : st_local("vlb", substr(st_local("vlb"), `varlabelwidth'))
		
		if mi("`cmdbar'") {
			if (substr("`typ'", 1, 3) == "str") loc Cmd `"`strcmd'"'
			else {
				loc Cmd `"`cmd1'"'
				if (`tabvalues') {
					loc rr : char `var'[Des2_distinct]
					if mi("`rr'") {
						cap ta `var'
						loc rr = r(r)
					}
					if (`rr' <= `tabvalues') loc Cmd tabulate `var'
					if ("`char'" != "") {
						char `var'[Des2_distinct] "`rr'"
					}
				}
			}
			loc SmclVar `"{stata `"`Cmd'"':{bf}`var'}"'
			
			if mi("`lbn'") loc SmclLbn ""
			else loc SmclLbn `"{stata `"`lcmd1'"':`lbn'}"'
		}
		else {
			loc SmclVar "{res}`var'"
			
			if mi("`lbn'") {
				loc SmclLbn ""
				forv j = 1/9 {
					loc abc : word `j' of `c(ALPHA)'
					loc SmclDir`abc' "txt"
				}
			}
			else {
				loc SmclLbn "`lbn'"
				forv j = 1/9 {
					loc abc : word `j' of `c(ALPHA)'
					loc SmclDir`abc' `"stata `"`macval(lcmd`j')'"'"'
				}
			} 
		}
		
		`print' `"{bind:`SmclVar'}"' ///
		`"{col `tcol1'}{bind:{txt}`typ'}"' ///
		`"{col `tcol2'}{bind:{txt}`fmt'}"' ///
		`"{col `tcol3'}{bind:`SmclLbn'}"' ///
		`"{col `tcol4'}{bind:{res}`macval(vlb)'}"' `newl'
		
		if ("`cmdbar'" != "") {
			forv j = 1/`ncr' {
				if mi(`"`Cmdbar`j''"') continue
				`print' `"{bind:{txt}`Cmdbar`j''}"' `newl'
			}
		}
		
		if ("`vspace'" != "") `print' _n(`vspace') `newl'
	}
	
	if mi("`view'") e 0 // done
	
	file w `fh' _n
	file close `fh'
	
	if (`"`saving'"' != "") {
		copy `des2view' `"`saving'"' ,`replace'
		di as txt `"file `saving' saved"'
		view `"`saving'"'
	}
	else view `des2view' ,smcl
end


/*	CUSTOMIZE THE DEFAULT OPTIONS PERMANENTLY
**********************************************************************
	
	The program below (Des2Defaults) sets the defaults for options.
	
	Each line of code consists of 5 parts
	
		1. //				line is commented out
		2. c_local			a non-documented Stata command
		3. default_			part of local macro name
		4. option's name	the respective option's name
		5. <DEFAULT>		default for the option 
	
	To change the default value for an option
		
		1. find the line you wish to change (see 4. above)
		2. remove the double slash (//) in that line (if any)
		3. change <DEFAULT> to whatever default you wish
		4. save the changes you made to this file
		5. in Stata type -discard-
	
	DO NOT MAKE ANY OTHER CHANGES TO THE CODE
*/

pr Des2DefaultOpts

	// c_local default_view			<DEFAULT>
	
	// c_local default_nocmdbar		<DEFAULT>
	// c_local default_cmdbar		<DEFAULT>
	c_local default_cmdorder		1 2 3 L1 L2 \ 4 5 6 7 8

	// c_local default_lookfor		<DEFAULT>
	// c_local default_more			<DEFAULT>
	
	c_local default_vspace 			0
	c_local default_varwidth 		15
	c_local default_valwidth 		12
	c_local default_varlabelwidth	1, .
	
	c_local default_cmd1 			tabulate
	// c_local default_txt1			<DEFAULT>
	
	c_local default_cmd2			summarize
	// c_local default_txt2			<DEFAULT>
	
	c_local default_cmd3 			codebook
	// c_local default_txt3			<DEFAULT>
	
	// c_local default_cmd4			<DEFAULT>
	// c_local default_txt4			<DEFAULT>
	
	// c_local default_cmd5			<DEFAULT>
	// c_local default_txt5			<DEFAULT>
	
	// c_local default_cmd6			<DEFAULT>
	// c_local default_txt6			<DEFAULT>
	
	// c_local default_cmd7			<DEFAULT>
	// c_local default_txt7			<DEFAULT>
	
	// c_local default_cmd8			<DEFAULT>
	// c_local default_txt8			<DEFAULT>
	
	// c_local default_cmd9			<DEFAULT>
	// c_local default_txt9			<DEFAULT>
	
	c_local default_lcmd1			label list
	c_local default_ltxt1			"label list"
	
	c_local default_lcmd2			labelbook
	// c_local default_ltxt2		<DEFAULT>
	
	// c_local default_lcmd3 		<DEFAULT>
	// c_local default_ltxt3		<DEFAULT>
	
	// c_local default_lcmd4		<DEFAULT>
	// c_local default_ltxt4		<DEFAULT>
	
	// c_local default_lcmd5		<DEFAULT>
	// c_local default_ltxt5		<DEFAULT>
	
	// c_local default_lcmd6		<DEFAULT>
	// c_local default_ltxt6		<DEFAULT>
	
	// c_local default_lcmd7		<DEFAULT>
	// c_local default_ltxt7		<DEFAULT>
	
	// c_local default_lcmd8		<DEFAULT>
	// c_local default_ltxt8		<DEFAULT>
	
	// c_local default_lcmd9		<DEFAULT>
	// c_local default_ltxt9		<DEFAULT>
		
	c_local default_strcmd 			\`cmd1'
	
	c_local default_tabvalues 		0
	
	// c_local default_has			<DEFAULT>
	// c_local default_not			<DEFAULT>
	// c_local default_insensitive	<DEFAULT>
end

/*

	DO NOT MAKE ANY CHANGES TO THE CODE FOLLOWING
**********************************************************************
*/


pr Des2GetOpts
	
	forv j = 1/9 {
		loc CMDTXT `CMDTXT' ///
		CMD`j'(str asis) TXT`j'(str asis)
		
		// if (`j' > 2) continue
		loc LCMDTXT `LCMDTXT' LCMD`j'(str asis) 
		loc LCMDTXT `LCMDTXT' LTXT`j'(str asis)
	}
	
	syntax [ , ///
	View SAVING(str) ///
	NOCMDBar CMDBar CMDOrder(str) ///
	noLOOKfor ///
	VSPACE VSPACE2(numlist int max = 1 >=0) ///
	VARWidth(numlist int max = 1 >=14 <=32) ///
	VALWidth(numlist int max = 1 >=11 <=32) ///
	VARLabelwidth(numlist int max = 2 >= 0) ///
	VARLWidth(numlist int max = 2 >= 0) ///
	MORE ///
	`CMDTXT' `LCMDTXT' LAbelcmd(str asis) ///
	STRcmd(str asis) TABValues(str) ///
	SET SET2(str) RESET RESET2(str) ///
	HAS(passthru) NOT(passthru) INSEnsitive ///
	Short * ]
	
		// the limit is 70 options per command!
	
	// check options
	loc oldoptions `"`options'"'
	
	if ("`cmdbar'$Des2_Opt_Cmdbar" != "") ///
	& ("`nocmdbar'$Des2_Opt_Nocmdbar" != "") {
		Des2OptNotAllowed cmdbar nocmdbar
	}
	
	if (`"`saving'"' != "") {
		gettoken filename subopts : saving ,p(",")
		if mi(`"`filename'"') Des2InvOpt saving()
		loc 0 `subopts'
		syntax [ , REPLACE ]
		m : mDes2ConfSmclFile(`"`filename'"', "saving")
		if ("`replace'" != "") loc rcok ", 602"
		cap conf new file `saving'
		if !inlist(_rc, 0`rcok') conf new file `saving'
	}
	
	if ("`vspace2'" != "") loc vspace `vspace2'
	else if ("`vspace'" != "") loc vspace 1
	
	if ("`varlwidth'" != "") {
		if !inlist("`varlabelwidth'", "`varlwidth'", "") {
			Des2OptNotAllowed varlwidth
		}
		loc varlabelwidth `varlwidth'
	}
	loc nv_varlw : word count `varlabelwidth'
	if (`nv_varlw') {
		token `varlabelwidth'
		if (`nv_varlw' == 1) loc varlabelwidth 1, `1'
		else loc varlabelwidth `1', `2'
	}
	
	if (`"`labelcmd'"' != "") {
		if !inlist(`"`lcmd1'"', `"`labelcmd'"', "") {
			Des2InvOpt labelcmd()
		}
		loc lcmd1 `"`labelcmd'"'
	}
	
	forv j = 1/9 {
		foreach x in txt cmd ltxt lcmd {
			loc nx : word count ``x'`j''
			gettoken dmp : `x'`j' ,qed(q)
			if (`q') {
				if (`nx' > 1) Des2InvOpt `x'`j'()
				gettoken `x'`j' : `x'`j'
			}
			loc `x'`j'_usermiss = mi(`"``x'`j''"') & (`q')
		}
	}
	if (`cmd1_usermiss') Des2InvOpt cmd1()
	if (`lcmd1_usermiss') Des2Invopt lcmd1()
	
	loc nx : word count `strcmd'
	gettoken dmp : strcmd ,qed(q)
	if (`q') {
		if (`nx' > 1) Des2InvOpt strcmd()
		gettoken strcmd : strcmd
	}
	loc strcmd_usermiss = mi(`"`strcmd'"') & (`q')
	if (`strcmd_usermiss') Des2InvOpt strcmd()
	
	if (`"`oldoptions'"' != "") {
		loc cmd_spec = (`"`cmd1'"' != "")
		Des2Old `cmd_spec' ,opts(`"`oldoptions'"')
	}
	
	if (`"`cmdorder'"' != "") Des2CmdOrder `cmdorder'
	
	if (`"`tabvalues'"' != "") {
		loc 0 `tabvalues'
		syntax anything [ , CHAR SET_sub ]
		cap n numlist `"`anything'"' ,int max(1) r(>=0)
		if (_rc) Des2InvOpt tabvalues() `= (_rc)'
		loc tabvalues `r(numlist)'
		if ("`set_sub'" != "") loc char char
	}
	
		// all setable options
	loc rsopts view results nocmdbar cmdbar cmdorder ///
	lookfor vspace varwidth valwidth varlabelwidth more ///
	cmd1 txt1 cmd2 txt2 cmd3 txt3 cmd4 txt4 ///
	cmd5 txt5 cmd6 txt6 cmd7 txt7 cmd8 txt8 cmd9 txt9 ///
	lcmd1 ltxt1 lcmd2 ltxt2 lcmd3 ltxt3 lcmd4 ltxt4 ///
	lcmd5 ltxt5 lcmd6 ltxt6 lcmd7 ltxt7 lcmd8 ltxt8 ///
	lcmd9 ltxt9	strcmd tabvalues has not insensitive
	
	if ("`set'" != "") & mi(`"`set2'"') loc set2 `rsopts'
	else if (`"`set2'"' != "") {
		m : mDes2RSOpts(`"`set2'"', "set2", "`rsopts'")
	}
	if (`"`reset'"' != "") & mi(`"`reset2'"') loc reset2 `rsopts'
	else if (`"`reset2'"' != "") {
		m : mDes2RSOpts(`"`reset2'"', "reset2", "`rsopts'")
	}
	
	// set the options
	Des2DefaultOpts
	foreach opt of loc rsopts {
		loc Gopt = "Des2_Opt_" + strproper("`opt'")
		if (`: list posof "`opt'" in reset2') gl `Gopt'
		if mi(`"``opt''"') & ("``opt'_usermiss'" != "1") {
			loc `opt' `"$`Gopt'"'
		}
		if (`: list posof "`opt'" in set2') {
			if mi(`"``opt''"') & ("``opt'_usermiss'" == "1") {
				loc opt `""""'
			}
			if (`"``opt''"' != `"`default_`opt''"') {
				gl `Gopt' `"``opt''"'
			}
		}
		if mi(`"``opt''"') & ("``opt'_usermiss'" != "1") {
			loc `opt' `"`default_`opt''"'
		}
	}
	
		// implications
	if (`"`saving'"' != "") loc view view
	if ("`view'" != "") & mi("`nocmdbar'") loc cmdbar cmdbar
	
	if ("`cmdbar'" != "") & mi("`ncr'") {
		Des2CmdOrder `cmdorder'
	}
	
		// complete cmd#() and lcnd#(); build command bar
	forv j = 1/9 {
		loc C
		loc L
		
		if (`"`cmd`j''"' != "") {
			loc dmp : subinstr loc cmd`j' "@" "" ,all c(loc at)
			if !(`at') loc cmd`j' `"`cmd`j'' @"'
			loc cmd`j' : subinstr loc cmd`j' "@" "\`var'" ,all
			
			if ("`cmdbar'" != "") {
				if mi(`"`txt`j''"') & !(`txt`j'_usermiss') {
					gettoken txt`j' : cmd`j'
				}
				loc C ///
				`"{bind:[{stata `"`macval(cmd`j')'"':`txt`j''}]}"'
			}
		}
		
		if (`"`lcmd`j''"' != "") {
			loc dmp : subinstr loc lcmd`j' "@" "\`lbn'" ,all c(loc at)
			if !(`at') loc lcmd`j' `"`lcmd`j'' @"'
			loc lcmd`j' : subinstr loc lcmd`j' "@" "\`lbn'" ,all
			
			if ("`cmdbar'" != "") {
				if mi(`"`ltxt`j''"') & !(`ltxt`j'_usermiss') {
					gettoken ltxt`j' : lcmd`j'
				}
				loc L `"[{bind:{SmclDir:`ltxt`j''}}]"'
				loc abc : word `j' of `c(ALPHA)'
				loc L : subinstr loc L "SmclDir" "\`SmclDir`abc''"
			}
		}
		
		if ("`cmdbar'" != "") {
			forv k = 1/`ncr' {
				loc Cmdbar`k' : ///
				subinstr loc Cmdbar`k' "L`j'" `"`macval(L)'"' ,all
				loc Cmdbar`k' : ///
				subinstr loc Cmdbar`k' "`j'" `"`macval(C)'"' ,all
			}
		}
	}
	
	if (`"`strcmd'"' != "") {
		loc dmp : subinstr loc strcmd "@" "" ,all c(loc at)
		if !(`at') loc strcmd `"`strcmd' @"'
		loc strcmd : subinstr loc strcmd "@" "\`var'" ,all
	}
	
	loc vspace = max(`vspace', 0)
	if !(`vspace') loc vspace
	else loc vspace = max(0, min(`vspace', c(pagesize)) - 1)
	
	loc tcol1 = `varwidth' + 2
	loc tcol2 = `tcol1' + 8
	loc tcol3 = `tcol2' + 10
	loc tcol4 = `tcol3' + `valwidth' + 2
	
	// return locals to main
	c_local view `view'
	c_local saving `saving'
	c_local replace `replace'
	c_local cmdbar `cmdbar'
	if ("`cmdbar'" != "") {
		forv j = 1/`ncr' {
			c_local Cmdbar`j' `macval(Cmdbar`j')'
		}
		c_local ncr `ncr'
	}
	c_local lookfor `lookfor'
	c_local vspace `vspace'
	c_local varwidth `varwidth'
	c_local valwidth `valwidth'
	c_local varlabelwidth `varlabelwidth'
	forv j = 1/9 {
		c_local cmd`j' `macval(cmd`j')'
		c_local lcmd`j' `macval(lcmd`j')'
	}
	c_local strcmd `macval(strcmd)'
	c_local tabvalues `tabvalues'
	c_local more `more'
	c_local char `char'
	c_local has `has'
	c_local not `not'
	c_local insensitive `insensitive'
	c_local short `short'
	forv j = 1/4 {
		c_local tcol`j' `tcol`j''
	}
end

pr Des2GetVarlist
	syntax anything(equalok everything) ///
	[ , noLOOKfor HAS(passthru) NOT(passthru) INSEnsitive ]
	
	cap unab varlist : `anything'
	if (_rc) {
		if ("`lookfor'" != "") unab varslist : `anything'
		
		loc canything : list retok anything
		loc canything : subinstr loc canything "- " "-" ,all
		loc canything : subinstr loc canything " -" "-" ,all
		
		while (`"`canything'"' != "") {
			gettoken A canything : canything ,q
			cap unab vars : `A'
			if (_rc) {
				qui lookfor `A'
				loc vars `r(varlist)'
			}
			loc varlist : list varlist | vars
		}
	}
	
	if (`"`has'`not'"' != "") {
		qui ds ,`has' `not' `insensitive'
		loc vars `r(varlist)'
		loc varlist : list varlist | vars
	}
	
	c_local varlist `varlist'
end

pr Des2CmdOrder
	m : st_local("cmdorder", strupper(st_local("0")))
	forv k = 0/8 {
		loc l = `k' + 1
		loc cmdorder : subinstr loc cmdorder "L`l'" "1`k'" ,all
	}
	
	loc Rows 1
	while (`"`cmdorder'"' != "") {
		gettoken tok cmdorder : cmdorder ,p("\")
		if (`"`tok'"' != "\") {
			cap n numlist `"`tok'"' ,int r(>0 <18)
			if (_rc) Des2InvOpt cmdorder() `= (_rc)'
			loc tok `r(numlist)'
			loc Cmdbar`Rows' `Cmdbar`Rows'' `tok'
		}
		else loc ++Rows
		loc Cmdorder `Cmdorder' `tok'
	}
	
	c_local cmdorder `Cmdorder'
	c_local ncr `Rows'
	
	forv j = 1/`Rows' {
		forv k = 0/8 {
			loc l = `k' + 1
			loc Cmdbar`j' : subinstr loc Cmdbar`j' "1`k'" "L`l'" ,all
		}
		c_local Cmdbar`j' `Cmdbar`j''
	}
end

pr Des2Old
	syntax anything , OPTS(str asis)
	
	if (`anything') Des2OptNotAllowed `"`: word 1 of `opts''"'
	
	di as txt "(note: you are using old {cmd:des2} syntax;" ///
	" see {helpb des2} for new syntax)"
	
	c_local cmd1 `opts'
	c_local cmd1_usermiss 0
end

pr Des2InvOpt
	args opt rc
	if mi("`rc'") loc rc 198
	
	di as err `"invalid option `opt'"'
	e `rc'
end

pr Des2OptNotAllowed
	args opt1 opt2
	if mi(`"`opt1'`opt2'"') loc opts options
	else loc opts "option "
	
	if ("`opt2'" != "") {
		loc opt2 `" and `opt2'"'
		loc both " both"
	}
	
	di as err `"`opts'`opt1'`opt2' not`both' allowed"'
	e 198
end

vers 9.2
m :
void mDes2RSOpts(string rowvector usropts,
				string scalar lnam,
				string rowvector rsopts)
{
	string scalar optsok
	
	usropts = tokens(usropts)
	rsopts = tokens(rsopts)
	optsok = J(1, 1, "")
	
	for (i = 1; i <= cols(usropts); ++i) {
		opts = select(rsopts, strmatch(rsopts, usropts[1, i]))
		if (!cols(opts)) {
			errprintf("may not set option %s\n", usropts[1, i])
			exit(198)
		}
		for (k = 1; k <= cols(opts); ++k) {
			optsok = optsok + char(32) + opts[1, k]
		}
	}
	
	st_local(lnam, optsok)
}

void mDes2ConfSmclFile(string scalar fn, string scalar lnam)
{
	fn = strtrim(fn)
	if (pathsuffix(fn) == "") fn = fn + ".smcl"
	if (pathsuffix(fn) != ".smcl") {
		errprintf("%s files not allowed\n", pathsuffix(fn))
		exit(198)
	}
	
	st_local(lnam, fn)
}
end
e

3.2.0	05aug2014	new 'viewer' mode
					new option -cmdbar-
					up to 9 cmd#()
					up to 9 lcmd#()
					new options -[l]txt#()-
					new option -cmdorder-
					lookfor strings enclosed in quotes
					tabvalues can set variable chars
					new option -vspace-
					new option -varlabelwidth()-
					subroutines and Mata functions
3.1.0	29jul2014	include options from -ds-
					bug fix default -strcmd-
					never released on SSC
3.0.0	26jul2014	default cmd is -tabulate- (prefomance)
					new options -set-/-reset-
					new option -strcmd-
					new option -more-
					sent to SSC (but never available)
2.0.0	11mar2014	-lookfor- varname if varname not found
					new option -nolookfor-
					default -cmd- is -tabulate- or -summarize-
					new option -labelcmd-
					new option -tabvalues-
					never released on SSC
1.1.0	10mar2012	prefix for commands returning r(varlist)
1.0.1	14nov2011	fix bug variable labels containing quotes
1.0.0	15oct2011	first version
					sent to SSC
