{smcl}
{* *! version 2.9.0 22apr2014}{...}
{cmd:help orth_out}
{hline}

{title:Title}

    {hi:orth_out} {c -} automate and export summary stats/orthogonality tables 


{title:Syntax}

{p 8 17 2}
{cmd:orth_out} {it:varlist1}
[{opt using} {it:filename}]
[{opt if}]
{cmd:,} {opt by:(varlist2)} [{it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{help orth_out##output:Output}}
{synopt:{opt replace}}overwrite existing file{p_end}
{synopt:{opt vappend}}append table under the table in {cmd:using}{p_end}
{synopt:{opt happend}}append table to the right of the table in {cmd:using}{{p_end}
{synopt:{opt latex}}output with a latex table. {p_end}
{p2col 10 34 40 8:{cmdab:full}}output with full table. {p_end}
{synopt:{opt dta}}output with a dta table. {p_end}
{synopt:{opt sheet(textgrid)}}name the sheet in the workbook{p_end}
{p2col 10 34 40 8:{cmdab:sheetrep:lace}}replace the sheet specified in {cmd:sheet()}.{p_end}

{syntab:{help orth_out##statistics:Statistics}}
{synopt:{opt comp:are}}create columns for comparison between all treatment arms of {it:varlist2}{p_end}
{synopt:{opt pcomp:are}}create columns for p-value of comparison between all treatment arms of {it:varlist2}{p_end}
{synopt:{opt overall}}add a column for the overall mean {p_end}
{synopt:{opt count}}add a row at the bottom specifying the number of people in each treatment arm of {it:varlist2}{p_end}
{synopt:{opt prop:ortion}}add a row at the bottom specifying the proportion of people in each treatment arm if {it:varlist2}{p_end}
{synopt:{opt se}}include standard errors below the means, enclosed in parentheses {p_end}
{synopt:{opt test}}run a joint orthogonality test on the treatment arms, and add a column with the p-value associated with it {p_end}
{synopt:{opt vcount}}add a column for the overall N from the orthogonality test. {p_end}
{synopt:{opt covar:iates(textgrid)}}include covariates in any regressions run (e.g. F-test, comparison, etc.) {p_end}
{synopt:{opt interact:ion}}include interaction terms for all covariates. {p_end}
{synopt:{opt r:everse}}run a regression with the treatment variable as the dependent variable and produces a column with the coefficients and standard errors. {p_end}
{synopt:{opt reverseall}}same as {cmd:reverse}, but with all balance variables together instead of separately. {p_end}
{synopt:{opth vce(vcetype)}}add option for variance estimators from {cmd:regress}. {p_end}

{syntab:{help orth_out##table:Table Formatting}}
{synopt:{opt bd:ec(#)}}specify the number of significant digits. The default is 3. {p_end}
{synopt:{opt stars}}add stars of significance to the right of estimated coefficients {p_end}
{synopt:{opt nola:bel}}disable row and column labeling{p_end}
{synopt:{opt armla:bel(textgrid)}}specify column headings for the treatment arms{p_end}
{synopt:{opt varla:bel(textgrid)}}specify row headings for the balance variables{p_end}
{synopt:{opt numla:bel}}specify numeric headings for the treatment arms{p_end}
{synopt:{opt colnum}}specify numeric headings for all columns below the column names{p_end}
{synopt:{opt t:itle(textgrid)}}specify a title for the table{p_end}
{synopt:{opt note:s(textgrid)}}add notes to the bottom of the table{p_end}


{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:orth_out} exports a table of means of specified balance variables, with the option to compare treatment arms and run an orthogonality test across the arms.
{it:varlist1} is the list of balance variables to compare across, and {it:varlist2} is the treatment arms. 
{it:varlist2} can be either one variable that indicates each treatment group, or individual binary indicators for each treatment.
The order of columns is immutable: it will always be means:overall:compare:reverse:reverseall:test:vcount. 
{p_end}

{marker options}
{title:Options}
{marker output}
{dlgtab:Output}
{marker replace}{...}

{phang}
{opt replace} permits overwriting the existing file. {p_end}
{marker vappend}{...}

{phang}
{opt vappend} vertically appends the table generated to the one specified in using.
The master table will not appear in the output window, only in the excel sheet. {p_end}
{marker happend}{...}

{phang}
{opt happend} horizontally appends the table generated to the one specified in using.
The master table will not appear in the output window, only in the excel sheet. {p_end}
{marker latex}{...}

{phang}
{opt latex} exports a latex table in lieu of an excel one. 
{cmd:full} needs to be specified in order for the table to be directly inputted to Tex via \input{} and the like. 
Otherwise it will just give the statistics and row/column names without any table formatting, which depending on your objective may be better. {p_end}
{marker sheet}{...}

{phang}
{opt sheet(sheetname)} adds a sheet to the existing file specified. 
If the file does not exist, a new file will be created. 
{cmd:sheetreplace} must be specified to replace a sheet with the same name in an existing workbook.{p_end}

{marker statistics}
{dlgtab:Statistics}
{marker compare}{...}

{phang}
{opt compare} adds columns to the right of the columns for the treatment arms. 
These columns are the differences of the means of each variable of varlist1 across each treatment arm in varlist2. 
Mutually exclusive with {cmd:pcompare}. {p_end}
{marker pcompare}{...}

{phang}
{opt pcompare} adds columns to the right of the columns for the treatment arms. 
These columns are the p-values from a t-test of the differences of the means of each variable of varlist1 across each treatment arm in varlist2. 
Mutually exclusive with {cmd:compare}. {p_end}
{marker overall}{...}

{phang}
{opt overall} adds a column to the right of the columns for the treatment arms with the overall mean. {p_end}
{marker count}{...}

{phang}
{opt count} adds a row to the bottom of the table with the count of the number of observations in each treatment arm, with the label "N". {p_end}
{marker nolabel}{...}

{phang}
{opt proportion} adds a row to the bottom of the table with the proportion of the number of observations in each treatment arm, with the label "Proportion".{p_end}
{marker se}{...}

{phang}
{opt se} adds standard errors enclosed by parentheses under the means.{p_end}
{marker test}{...}

{phang}
{opt test} runs an F-test that the treatment arms do not predict the balance variable, giving the p-value for that test in the right-most column. 
Note that in the special case where there is one treatment arm, for large enough {it:n}, the difference between an F-test and a t-test is negligible. {p_end}
{marker vcount}{...}

{phang}
{opt vcount} adds a column with the combined observation count from the orthogonality test. {p_end}
{marker covariates}{...}

{phang}
{opt covariates(textgrid)} includes specified covariates to add to regressions, such as the reverse test or the F-test. {p_end}
{marker interaction}{...}

{phang}
{opt interaction} adds interaction terms between treatment for each of the covariates specified in {cmd:covariates()}.{p_end}
{marker reverse}{...}

{phang}
{opt reverse} adds a column of coefficients from a regression with each of the balance variables as independent variables and the treatment as the dependent variable. 
Only an option when treatment is binary. 
If treatment is not binary and {cmd:reverse} is specified, {cmd:orth_out} will assume that the first value is treatment, and everything else is control. {p_end}
{marker reverseall}{...}

{phang}
{opt reverseall} is the same as reverse, except instead of running each regression separately, all the balance variables are put into the regression together. {p_end}
{marker vce(vcetype)}{...}

{phang}
{opt vce} lets the user specify variance estimators for standard errors just like in {cmd:regress}. For more help, see {help regress} and {help vcetype}. {p_end}

{marker table}
{dlgtab:Table Formatting}
{marker bdec}{...}

{phang}
{opt bdec(#)} specifies the number of decimal places
reported for all estimates.  The default value for {cmd:bdec} is 3.{p_end}
{marker stars}{...}

{phang}
{opt stars} adds stars corresponding to levels of significance to the right of the coefficients that come from regressions/tests.
The star system follows the standard correspondence to alpha levels: *** = 0.01, ** = 0.05, * = 0.10. 
Only visible in the saved excel file. {p_end}
{marker nolabel}{...}

{phang}
{opt nolabel} specifies that column and rows should not be labeled with variable labels, and instead will be left as the default "r#" or "c#". {p_end}
{marker armlabel}{...}

{phang}
{opt armlabel(textgrid)} specifies column headers for the treatment arms. Headers with spaces in them should be enclosed with double quotes. 
If {cmd:compare} is specified, these will be automatically labeled with "(#) vs. (#)", where the #s correspond to the columns being compared. 
If not specified, the default is that the columns are labeled with the variable or value labels, depending on how many variables are specified in the by(). 
If missing, the columns will simply be labeled with numbers. {p_end}
{marker varlabel}{...}

{phang}
{opt varlabel(textgrid)} specifies row headers for the demographic variables. Headers with spaces in them should be enclosed with double quotes. 
If not specified, the default is that the rows are labeled with the variable labels (or if these are missing, variable names). {p_end}
{marker numlabel}{...}

{phang}
{opt numlabel} puts the column number in parentheses as the column header for each of the treatment arm columns (e.g. column 1 has a header of (1), etc.)
{marker title}{...}

{phang}
{opt title(textgrid)} specifies a title or titles above the regression table. 
Note that if your title contains double quotes, you must enclose your title with compound double quotes. {p_end}
{marker note}{...}

{phang}
{opt notes(textgrid)} specifies a note to be displayed below the {cmd:orth_out} table. Multiple lines of a note should be separated by commas. {p_end}

{title:Examples}
      {synoptline}
	Setup
	{com}. sysuse auto
	{txt}(1978 Automobile Data)

	Summary statistics
	{com}. orth_out price mpg, by(foreign) se

{txt}		                     Domestic:   Foreign:
{txt}		                            _          _
{txt}		        Price:mean   6072.423   6384.682
{txt}                		se    429.491    558.994
{txt}		Mileage (mpg):mean     19.827     24.773
{txt}		                se      0.658      1.410

	Export table to Excel
	{com}. orth_out price mpg using test, by(foreign) se
	{txt}file test.xls saved	
{txt}		                     Domestic:   Foreign:
{txt}		                            _          _
{txt}		        Price:mean   6072.423   6384.682
{txt}                		se    429.491    558.994
{txt}		Mileage (mpg):mean     19.827     24.773
{txt}		                se      0.658      1.410

	Orthogonality table testing if price and mpg are balanced between domestic and foreign cars (hint: they aren't)
	{com}. orth_out price mpg, by(foreign) se compare test count 

        	{txt}			Domestic:      Foreign:  (1) vs. (2):  p-value f~y:   
        	{txt}			       _             _             _             _  
        	{txt}	Price:mean      6072.423      6384.682      -312.259         0.680
        	{txt}           se       429.491       558.994       754.449             .
   	{txt}   Mileage (mpg):mean        19.827        24.773        -4.946         0.001
       		{txt}           se         0.658         1.410         1.362             .  
		{txt} 	       N:_        52.000        22.000        74.000             .

      {synoptline}
{title:Saved Results}

{phang}
{cmd:orth_out} saves the following in {cmd:r()}:{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Strings}{p_end}
{synopt:{cmd:r(title)}}table title{p_end}
{synopt:{cmd:r(cnames)}}list of column titles{p_end}
{synopt:{cmd:r(rnames)}}list of row titles{p_end}
{p2colreset}{...}
{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(matrix)}}table in matrix form{p_end}
{p2colreset}{...}
{title:Author}

{phang}
Joe Long{p_end}
{phang}
jlong@u.northwestern.edu
{p_end}

{title:Acknowledgments}

{phang}
Much thanks to Ellen Degnan for inspiration, Hideto Koizumi for contributions, and Matthew White for programming support. {p_end}

