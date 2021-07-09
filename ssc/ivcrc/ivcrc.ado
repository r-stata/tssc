

program ivcrc, eclass
	version 8
	syntax [anything] [if] [in]  			///
	[,NOConstant					///
	AVErage(string)					///				  
	Ranks(integer 50)				///
	Kernel(string)					///
	GENerate(string)				///
	BANDwidth(string)				///
	BOOTstrap(string)				///
   	DENDOG(varlist fv ts)				///
	USERANK(varlist) 				///
	SAVECOEF(string)				/// 
	VARCOEF(string)  *]
			
if (regexm("`0'","boot")==0 & regexm("`0'","bootstrap")==0) {
	
	capture ereturn clear
	display in gr "(default settings do not compute standard errors, see {bf:bootstrap()} option)"
	_ivcrc_estimator `0'
	ivcrc_display , varcoef(`varcoef')
	
}		
else {

	if "`generate'" != "" & "`bootstrap'" != "" display in gr "({bf:generate()} option ignored while bootstrapping...)"
	bootstrap , `bootstrap' notable noheader: _ivcrc_estimator `0'
	ivcrc_display, boot(bs_table) 
				
}

		
end
		


		
		
	

program ivcrc_display

	syntax [,  boot(string) varcoef(string) ]
	
tempname ivcrctab z pval ll ul empty cimat
if "`boot'"=="" {
	_coef_table_header, title(IVCRC)
	local level = 95
}	
else if "`boot'"=="bs_table" {
	_bs_display, title(IVCRC) notable
	matrix `cimat' = e(ci_normal)
	local level = e(level)
}
.`ivcrctab' = ._tab.new, col(7) lmargin(0)
.`ivcrctab'.width    13   |12    11    9     10    11     11 
.`ivcrctab'.titlefmt  .   %10s    .   %5s    %7s   %22s    .
.`ivcrctab'.pad       .     2     .     .      .     2     2
.`ivcrctab'.numfmt    . %9.0g %9.0g %7.2f %7.3f %9.0g %9.0g
local vnamelist : colname e(b)
local eqnamelist : coleq e(b)
local k : word count `vnamelist'
.`ivcrctab'.sep, top
local depvar "`e(depvar)'"
.`ivcrctab'.titles "`depvar'"                      /// 1
		"Coef."                            /// 2
		"Std. Err."                        /// 3
		"z"                        	   /// 4
		"P>|z|"                    	   /// 5
		"[`level'% Conf. Interval]" ""     //  6 7
.`ivcrctab'.sep
forvalues i = 1/`k' {
	local vname      : word `i' of `vnamelist'
	local disvname = trim(abbrev("`vname'",12))
	local eqname     : word `i' of `eqnamelist'
	local nexteqname : word `=`i'+1' of `eqnamelist'
	local beq "[`eqname']"
	if "`boot'"=="" {
		scalar `empty' = .
		.`ivcrctab'.row    "`disvname'"         ///
			`beq'_b[`vname']  	      	///
			`empty'      	      		///
			`empty'                         ///
			`empty'                         ///
			`empty' `empty'
	}
	else if "`boot'"=="bs_table" {
		scalar `z' = `beq'_b[`vname']/`beq'_se[`vname']		                    
		scalar `pval' = 2 * normal( - abs(`beq'_b[`vname']/`beq'_se[`vname']) )
		scalar `ll' = `cimat'[1,`i']
		scalar `ul' = `cimat'[2,`i']
		.`ivcrctab'.row    "`disvname'"          ///
			`beq'_b[`vname']  	  	 ///
			`beq'_se[`vname']     	         ///
			`z'                   		 ///
			`pval'                        	 ///
			`ll' `ul'
	}
	if "`eqname'"!="`nexteqname'" {
		.`ivcrctab'.sep, bottom
		tokenize "`eqname'", parse("_")
		if substr("`eqname'",1,4)!="samv" & trim("`varcoef'")=="" display "Note: Average coefficients over {bf:R = [`3',`5']} rank subset; {bf:Bandwidth = `7'}"              
		else if substr("`eqname'",1,4)!="samv" & trim("`varcoef'")!="" display "Note: Average coefficients over {bf:$varcoefmod = [`3',`5']}; {bf:Bandwidth = `7'}"              
		else if substr("`eqname'",1,4)=="samv" & "`nsubsets'"=="1" & trim("`varcoef'")!="" "Note: Average coefficients over {bf:R = [`3',`5']} rank subsets; {bf:Bandwidth = `7'}"              
		else display "Note: {bf:Bandwidth = `7'}"              
		if "`nexteqname'"!="" .`ivcrctab'.sep, top
	}	
}	     
end




