*! dmout version 5.1 2014-04-23
*! author: Michael Barker mdb96@georgetown.edu

/*******************************************************************************
v5.0 2014-01-30
v5.1 2014-04-23  Verify column names of results matrix and modify if necessary.
*******************************************************************************/

version 10

# delimit ;

program define dmout, rclass;
    syntax varlist [if] [in] [using/] [aweight fweight iweight pweight] , BY(varname) 
           [IV(varname) CTRLvars(varlist fv) VCE(passthru) 
           CSV TEX TXT REPLACE APPEND PREAMBle ENDdoc Decimal(integer 2)
           STat(string) Title(string) SUBTitle(string) CAPtion(string) NOTEs(string asis)
           LIST DEtail CW];
    marksample touse , novarlist;
    * markout `touse' `by' , strok;
    * casewise deletion of observations;
    if "`cw'"=="cw" {;
        markout `touse' `varlist' `ctrlvars';
        * if ("`iv'"!="") markout `touse' `iv' , strok;
    };

    *** Parse and Verify Options;

    * If no filename supplied, display output to results screen only;
    if "`using'"=="" {;
        if ("`csv'"=="csv" | "`tex'"=="tex" | "`txt'"=="txt") {;
            display as error "Must specify file name when using csv, tex, or txt option"; 
            error 198;
        };
        else {;
            tempfile tempfilename;
            local usingcsv "`tempfilename'"; 
            local list "list";
            local csv  "csv" ;
			local replace "replace" ;
        };
    };

	else local usingcsv "`using'";

    * If no output option, default to csv;
    if ("`csv'"=="" & "`tex'"=="" & "`txt'"=="") local csv "csv";

    * If list option is given, but csv is not, save csv as tempfile; 
    if "`list'"=="list" & "`csv'"=="" {;
        tempfile tempfilename;
        local usingcsv "`tempfilename'"; 
        local csv      "csv" ;
    };

	* Check decimal place option;
	if (`decimal'<0 | `decimal'>8) {;
		display as error "Decimal places must be between 0 and 8";
		error 198;
	};

    * Set default statistice (standard errors);
    if       "`stat'"=="" local stat "se";

    * Check stat option and set statname for table output;
    if       "`stat'"=="se"     local statname "Standard errors";
    else if  "`stat'"=="pval"   local statname "P-Values";
    else {;
        display as error "option stat(`stat') not allowed";
        error 198;
    };

	* Add notes for Statistic and Control Vars;
	if "`ctrlvars'"!="" local notes `" "Control Variables: `ctrlvars'" `notes' "';
	local notes `" "`statname' in parentheses" `notes' "';


	*** Check BY and IV variables and construct indicators for each;

    * foreach var in by iv {;
    foreach var in `by' `iv' {;
        capture: confirm numeric variable `var';
            * If by var is string, change to numeric version;
            if _rc {;
                tempvar new`var';
                encode `var' , gen(`new`var'');
                local var `new`var'';
            };

        quietly: tab `var' if `touse';    
        scalar nvals = r(r);
        if nvals!=2 {;
            display as error "BY and/or IV variables must take exactly two values"; 
            error 198;
        };
    };

    * Get value labels and create indicators for Assignment and Treatment variables;
    * Assignment;
    quietly: levelsof `by' if `touse' , local(vals);
    tokenize "`vals'";
    
    * Make sure there are sufficient observations in each category;
    foreach value of local vals {;
        _nobs `touse' if `by'==`value' , min(2);
    };

    * Get labels for each value;
    local a1 : label (`by') `1';
    local a2 : label (`by') `2';
	* Change labels to valid matrix column names;
	local a1 = strtoname(`"`a1'"',0);
	local a2 = strtoname(`"`a2'"',0);
    * Generate assignment indicator;
    tempname ind;
	qui: recode `by' (`1'=0 `"`a1'"') (`2'=1 `"`a2'"') (else=.) , gen(`ind');

	* Label assignment indicator;
	local bylabel : variable label `by';
	if `"`bylabel'"' == "" local bylabel "`by'";
	label variable `ind' `"`bylabel'"';


if "`iv'" != "" {;
    * Treatment;
    quietly: levelsof `iv' if `touse' , local(vals);
    tokenize "`vals'";

    * Make sure there are sufficient observations in each category;
    foreach value of local vals {;
        _nobs `touse' if `iv'==`value' , min(2);
    };

    * Get labels for each value;
    local t2 : label (`iv') `2';
    * Generate treatment indicator;
        * local trname = strtoname(`"`t2'"');
        * local trind : permname `trname';
    tempvar trind;
    gen `trind' = (`iv'==`2') if !missing(`iv');
    lab var `trind' `"`t2'"';
};


/*******************************************************************************
 Test each variable and save in table matrix
*******************************************************************************/
    * accumulate estimates in table matrix, T;
    tempname T;
    foreach var of varlist `varlist' {;
        * accumulate row estimates in row matrix, R;
        tempname r R;
        
        * Report Current Sample;
        if "`detail'"=="detail" {;

            local vname : variable label `var';
            if  "`vname'"=="" local vname "`var'";

            display as txt _n _n `"Outcome: "' as txt `"`vname'"';
            display as txt    _n "Treatment category: " as txt `"`a2'"';
            display as txt       "Baseline category: " as txt `"`a1'"';
        };


        if "`detail'"=="detail" display as txt _n `"Level of (`vname') for (`bylabel') == (`a1')"'; 
		dmtest reg              `var'                               if `touse'==1 & `ind'==0  [`weight'`exp']   , `vce' `detail'; 
			matrix `r' = r(R);
			matrix colnames `r'=level:`a1' ;
			matrix `R' = (nullmat(`R'),`r');  

        if "`detail'"=="detail" display as txt _n `"Level of (`vname') for (`bylabel') == (`a2')"'; 
		dmtest reg              `var'                               if `touse'==1 & `ind'==1   [`weight'`exp'] , `vce' `detail';
			matrix `r' = r(R);
			matrix colnames `r'=level:`a2' ;
			matrix `R' = (nullmat(`R'),`r');  

		if "`detail'"=="detail" display as txt _n `"Difference in (`vname') for (`a1') - (`a2')"'; 
		dmtest reg              `var'   `ind'                       if `touse'==1           [`weight'`exp']    , `vce' `detail';
			matrix `r' = r(R);
			matrix colnames `r'=diff:Diff;
			matrix `R' = (nullmat(`R'),`r');  
   
		if "`ctrlvars'"!="" {;
        	if "`detail'"=="detail" display as txt _n `"Difference with controls in (`vname') for (`a1') - (`a2')"'; 
			dmtest reg              `var'   `ind'       `ctrlvars'  if `touse'==1            [`weight'`exp']   , `vce' `detail';
				matrix `r' = r(R);
				matrix colnames `r'=diff:Controls;
				matrix `R' = (nullmat(`R'),`r');  
		};
		
		if "`iv'"!="" {;
        	if "`detail'"=="detail" display as txt _n `"IV difference in (`vname') for (`a1') - (`a2')"'; 
			dmtest ivregress 2sls   `var' (`trind'=`ind') if `touse'==1           [`weight'`exp']    , `vce' `detail';
				matrix `r' = r(R);
				matrix colnames `r'=diff:IV;
				matrix `R' = (nullmat(`R'),`r');  
		
			if "`ctrlvars'"!="" {;
        		if "`detail'"=="detail" display as txt _n `"IV difference with controls in (`vname') for (`a1') - (`a2')"'; 
				dmtest ivregress 2sls   `var' `ctrlvars' (`trind'=`ind') if `touse'==1           [`weight'`exp']    , `vce' `detail';
					matrix `r' = r(R);
					matrix colnames `r'=diff:IVcontrols;
					matrix `R' = (nullmat(`R'),`r');  
			};
		};

        matrix rownames `R' = coeff:`var' sterr:`var' pval:`var' N:`var';
        * Add row to table matrix;
        matrix `T' = (nullmat(`T') \ `R');

    }; /* end varlist loop */

    * Display estimate matrix;
    * matrix list `T';
    * return matrix results `T';

/*******************************************************************************
 Output Results Tables 
*******************************************************************************/

/*******************************************************************************
 LaTeX Output;
*******************************************************************************/

    if "`tex'"=="tex" {;
    tempname fhtex;

        local k = colsof(`T');
        local n = rowsof(`T')-1;
        local varnames  : rownames `T';
        local ctypelist : coleq `T';  
        tempname p;
        
        file open `fhtex' using "`using'.tex" , write text `replace' `append'; 

        if ("`preamble'"=="preamble") texheader `fhtex';

        file write `fhtex'  
            "\begin{table}[htpb]" _n
            "\begin{center}" _n
            "\begin{threeparttable}" _n ; 

        if `"`caption'"'!="" {;
            file write `fhtex' `"\caption{`caption'}"' _n; 
        };
        
        * Tabular preamble: always have variable name, mean1 and mean2;
        file write `fhtex' "\begin{tabular}{l";  
        * Then put as many d{3} columns as there are in the results matrix;
        forvalues j = 1/`k' {;
            local ctype : word `j' of `ctypelist';
            if      "`ctype'"=="level" file write `fhtex' " d{2}";
            else if "`ctype'"=="diff"  file write `fhtex' " d{3}";
        };
        file write `fhtex' "}" _n ;

        * title spans all columns of results matrix plus variable name column;
        local k = colsof(`T')+1;
        if `"`title'"'!="" {;
            file write `fhtex' `"\multicolumn{`k'}{c}{\large `title'} \\"' _n;
        };

        if `"`subtitle'"'!="" {;
            file write `fhtex' `"\multicolumn{`k'}{c}{`subtitle'} \\"' _n;
        };
       
        local cnames : colnames `T'; 
        local headings : subinstr local cnames " " "} & \multicolumn{1}{r}{" , all;
        * display "`headings'" ;
        * Write column headers ;
        file write `fhtex'  
            "\toprule" _n
            "\midrule" _n
            `"Variable & \multicolumn{1}{r}{`headings'} \\"' _n
            "\midrule" _n 
            ;

        writemat `T' `fhtex' tex `stat' `decimal'; 

        * Close Tex Doc;
        texfooter `fhtex' , statname(`statname') notes(`notes') `enddoc'; 
        file close `fhtex';
    
    }; /* end if tex==tex */ 

/*******************************************************************************
 Go through and mark areas that will be different for txt.
*******************************************************************************/

    if "`txt'"=="txt" {;
    tempname fhtxt;

        local varnames  : rownames `T';
        local ctypelist : coleq `T';  
        tempname p;
        
        file open `fhtxt' using "`using'.txt" , write text `replace' `append'; 

        if `"`caption'"'!="" {;
            file write `fhtxt' `"`caption'"' _n; 
        };
        
       * title ; 
        if `"`title'"'!="" {;
            file write `fhtxt' `"`title'"' _n;
        };

        if `"`subtitle'"'!="" {;
            file write `fhtxt' `"`subtitle'"' _n;
        };
      
        local cnames : colnames `T'; 
        local headings : subinstr local cnames " " `"" _tab ""' , all;
        * Write column headers ;
        file write `fhtxt'  
            "Variable " _tab " `headings'" _n
            "--------------------------------------------------------------------------------" _n 
            ;

        * Write estimate matrix;
        writemat `T' `fhtxt' txt `stat' `decimal'; 

        * Close Tex Doc;
        csvfooter `fhtxt' , statname(`statname') notes(`notes'); 
        file close `fhtxt';
    
    }; /* end if txt==txt */ 

    if "`csv'"=="csv" {;
    tempname fhcsv;

        local varnames  : rownames `T';
        local ctypelist : coleq `T';  
        tempname p;
        
        file open `fhcsv' using "`usingcsv'.csv" , write text `replace' `append'; 

        if `"`caption'"'!="" {;
            file write `fhcsv' `"`caption'"' _n; 
        };
        
       * title ; 
        if `"`title'"'!="" {;
            file write `fhcsv' `"`title'"' _n;
        };

        if `"`subtitle'"'!="" {;
            file write `fhcsv' `"`subtitle'"' _n;
        };
      
        local cnames : colnames `T'; 
        local headings : subinstr local cnames " " " , " , all;
        * Write column headers ;
        file write `fhcsv'  
            `"Variable , `headings'"' _n
            "--------------------------------------------------------------------------------" _n 
            ;

        * Write estimate matrix;
        writemat `T' `fhcsv' csv `stat' `decimal'; 

        * Close Tex Doc;
        csvfooter `fhcsv' , statname(`statname') notes(`notes'); 
        file close `fhcsv';
    
    }; /* end if csv==csv */ 

    if "`list'"=="list" {;
        preserve;
        qui: insheet using "`usingcsv'.csv" , clear comma;
		set linesize 255;
        list , string(20) clean noobs;  
        restore;
    };

end;


program writemat;
    args T fh type stat decimal; 

    tempname p;

	* Set display formats;

	local lfmt "%9.`decimal'f";
	local dfmt "%9.`++decimal'f";

    if "`type'"=="tex" {;
        local delim    "&";
        local close    "}";
        local super    "\textsuperscript{";
        local endl     "\\";
        local right    "\multicolumn{1}{r}{";
        local line     "\midrule" ;
		local statl    "(";
		local statr    ")";
    };

    else if "`type'"=="csv" {;
        local delim    ",";
        local close    "";
        local super    "";
        local endl     "";
        local right    "";
        local line     "--------------------------------------------------------------------------------" ;
		local statl    "[";
		local statr    "]";
    };

    else if "`type'"=="txt" {;
        local delim    `""_tab""';
        local close    "";
        local super    "";
        local endl     "";
        local right    "";
        local line     "--------------------------------------------------------------------------------" ;
		local statl    "[";
		local statr    "]";
    };


    local varnames  : rownames `T';
    local ctypelist : coleq `T';  
    local k = colsof(`T');
    local n = rowsof(`T')-1;
    forvalues i = 1(4)`n' {;
        * Write Variable Name;
        local var   : word `i' of `varnames';
        local vname : variable label `var';
        if "`vname'"=="" local vname "`var'";
        file write `fh' `"`vname' "';

        * Write Levels and Differences;
        forvalues j = 1/`k' {; 
            local ctype : word `j' of `ctypelist';
            if      "`ctype'"=="level" file write `fh' "`delim'" `lfmt' (`T'[`i',`j']) ;
            else if "`ctype'"=="diff"  {;
                * Identify Significant Differences (No stars on mean estimates);
                scalar `p' = `T'[`i'+2,`j']; 
                local sig;
                if      `p'<0.01 local sig "***";
                else if `p'<0.05 local sig "**";
                else if `p'<0.10 local sig "*";
                * Write coefficient and stars, if any; 
                    file write `fh' "`delim'" `dfmt' (`T'[`i',`j']) "`super'`sig'`close'" ;
            };
        };
        
        * Advance line;
            file write `fh' " `endl'" _n ; 

        * If St. Err., write stat from second row; 
        if "`stat'"=="se" {;
            local statname "Standard errors";
            local s=`i'+1;
        };
        * If pval, write stat from third row; 
        else if "`stat'"=="pval" {;   
            local statname "P-Values";
            local s=`i'+2;
        };

        * Write Stats;
        forvalues j = 1/`k' {; 
            local ctype : word `j' of `ctypelist';

            if "`ctype'"=="level" {;
                    local value : display `lfmt' `T'[`s',`j'];
                    local value = trim("`value'");
					file  write `fh' "`delim'`statl'`value'`statr'"  ;
            }; /* end level */

            else if "`ctype'"=="diff"  {;
                local value : display `dfmt' `T'[`s',`j'];
                local value = trim("`value'");
                    file write `fh' "`delim'`statl'`value'`statr'"  ;
            };
        }; /* end for loop */

        * Advance line;
            file write `fh' " `endl'" _n ; 

        * Advance row index to 4th row; 
        local i=`i'+3;
        
        * Write obs numbers if last row or if obs in next row are different;
        local bool = 0;
        * If last row in matrix;
        if (`i'==`n'+1) local bool = 1; 
        * Check equality of obs numbers;
        else {;
            local inext = `i'+4;
            forvalues j = 1/`k' {; 
                if (`T'[`i',`j'] != `T'[`inext',`j']) local bool = 1;
            };
        };
        * If either condition is true, write obs numbers;
        if (`bool') {;
            file write `fh' "N";
            forvalues j = 1/`k' {; 
                    file write `fh' " `delim' `right'" (`T'[`i',`j']) "`close'"  ;
            };
            // Advance line and write light line;
                file write `fh'" `endl' " _n "`line'" _n ;
        };        

    }; /* End Row Loop */

end;


/*******************************************************************************
 Regression Test
*******************************************************************************/
program define dmtest, rclass;
    syntax anything(everything equalok) [aweight fweight iweight pweight] , [VCE(passthru) DEtail];

    * Store estimation results in tempscalars: ; 
    tempname b V est se pval N R;

    * Separate command name and arguments;
    gettoken cmd args : anything;
    
    * Run Regression;
    capture: `cmd' `args' [`weight'`exp'] , `vce'; 


    if (_rc==0) {;
        * Replay regression results if requested;
        if "`detail'"=="detail" {;
            * display as txt `"Command: "' as result `"`cmd' `args' , `vce'"'; 
            `cmd';
        };

        matrix `b' = e(b);
        matrix `V' = e(V);

        * Return values; 
        scalar `est'  = `b'[1,1]        ;
        scalar `se'   = sqrt(`V'[1,1])  ;
        scalar `pval' = 2*ttail(e(N) , abs(`est' / `se'));
        scalar `N'    = e(N)            ;

        matrix `R' = (`est' \ `se' \ `pval' \ `N')     ;
    };

    else if (_rc!=0) {;
        display as txt `"Command: "' as result `"`cmd' `args' , `vce'"'; 
        display as error _n " Regression error: " _rc;  
        matrix `R' = ( . \ . \ . \ 0 )     ;
    };

    return matrix R = `R'           ;  

end;



program define texheader;
    syntax name(name=fh);    
    file write `fh'  
        "\documentclass[11pt]{article}" _n
        "\usepackage{geometry}" _n
        "\geometry{letterpaper}" _n
        "\geometry{margin=1.in}" _n
        "\usepackage{threeparttable}" _n
        "\def\TPTminimum{30em}" _n
        "\usepackage{booktabs}" _n
        "\usepackage{dcolumn}" _n
        "%" _n
        "\begin{document}"                     _n
        "\newcolumntype{d}[1]{D{.}{.}{#1}}"    _n
        ;
end;

program define texfooter;
    syntax name(name=fh) , statname(string) [NOTEs(string asis) enddoc]; 
    file write `fh'
        "\bottomrule" _n
        "\end{tabular}" _n 
        "\begin{tablenotes}" _n
        "\item [1] Significance levels:$ \quad ^{*}<10\% \quad ^{**}<5\% \quad ^{***}<1\%$ " _n
        ;
    local i=2;        
    gettoken note notes : notes; 
    while `"`note'"'!="" | `"`notes'"'!="" {;
        file write `fh' `"\item [`i++'] `note'"' _n;
        gettoken note notes : notes; 
    };
    file write `fh' 
        "\end{tablenotes}" _n
        "\end{threeparttable}" _n
        "\end{center}" _n
        "\end{table}" _n
        ;
    if "`enddoc'"=="enddoc" file write `fh' "\end{document}" _n ;
end; 

program define csvfooter;
    syntax name(name=fh) , statname(string) [NOTEs(string asis)]; 
    
    file write `fh'
        "Significance levels:    * < 10%    ** < 5%    *** < 1%  " _n
    ;

    while `"`notes'"'!="" {;
        gettoken note notes : notes; 
        file write `fh' `"`note'"' _n;
    };

	file write `fh' _n _n;

end;


