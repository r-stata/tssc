{smcl}
{right:version:  1.0}
{cmd:help fillmissing} {right:May 11, 2020}
{hline}

{vieweralsosee "other programs" "fillmissing##also"}{...}

{title:Title}

{p 4 8}{cmd:fillmissing}  -  Fills missing values in a variable based on a given 
criterion {p_end}


{title:Syntax}

{p 4 6 2}
[{help bysort} varlist]: {cmd:fillmissing}
{varname} {ifin}, {cmd:} 
{cmdab:[with(}{it:{help fillmissing##with:with_options}{cmd:)}}]


{title:Important note:}

{p 4 4 2}This program does not imply that filling missing values is justified 
by theory. Users should make their own decisions and follow appropriate theory
 while filling missing values.

{title:Description}

{p 4 4 2} {cmd: fillmissing} program provides the convenience of filling missing
values in numeric or string variables with the variable's previous value, forward
value, first or last value, or with some calculated values such as mean, median, 
minimum, maximum, etc. in numeric variables. The program can work with
or without the bysort prefix. Specifically, if filling the missing values is 
needed within a grouping variable, such as firms, years, etc, the bysort prefix can
be used. See examples below.{p_end}


{title:Options}
{marker with}{...}

{p 4 4 2}1. {opt with()}: Option with() is used to specify the source from where 
the missing values will be filled. It accepts the following arguments:{p_end}

{p2colset 4 20 22 2}{...}
{hline}
{p2col : {opt Argument}} {opt Purpose}{p_end}
{hline}

{p2col : {opt with(any)}} {opt with(any)} is an optional option and hence if not 
		specified, will automatically be invoked by the fillmissing program. 
		This option is best to fill missing values of a constant variable, 
		i.e. a variable that has all similar values, however, due to some 
		reason, some of the values are missing. Option {opt with(any)} will try 
		to fill the missing values from any available non-missing values 
		of the given variable.{p_end}

{p2col : {opt with(previous)}}	Option {opt with(previous)} is used to fill the current 
		missing value with the preceding or previous value of the same variable. 
		Please note that if the previous value is also missing, the current 
		value will remain missing. Further, this option does not sort the data, 
		so whatever the current sort of the data is, fillmissing will use that 
		sort and identify the current and the previous observation. {p_end}

{p2col : {opt with(next)}}	{opt with(next)}} works like {opt with(previous)}
		with the difference that it tries to fill the current 
		missing value with the following or next value of the same variable. 
		Please note again if the next value is also missing, the current 
		value will remain missing. Further, this option does not sort the data, 
		so whatever the current sort of the data is, fillmissing will use that 
		sort and identify the current and the next observation. {p_end}

{p2col : {opt  with(first)}} 	It will replace all missing values with the first
		value in the current sort or the first value of each group when used 
		with the bysort prefix.{p_end}

{p2col : {opt  with(last)}} 	It will replace all missing values with the last
		value in the current sort or the last value of each group when used 
		with the bysort prefix.{p_end}

{p2col : {opt with(mean)}} 	It will replace missing values with the mean value of non-missing values. This option can be used only with numeric variables. {p_end}

{p2col : {opt with(median)}} 	It will replace missing values with the median value of non-missing values. This option can be used only with numeric variables. {p_end}

{p2col : {opt with(min)}} 	It will replace missing values with the minimum value of non-missing values. This option can be used only with numeric variables. {p_end}

{p2col : {opt with(max)}} 	It will replace missing values with the maximum value of non-missing values. This option can be used only with numeric variables. {p_end}


{hline}

{marker bysort}{...}

{p 4 4 2}2. {opt bysort varlist}: The bysort varlist prefix can be used to
perform calculations over grouping variables. See examples below.{p_end}

{title:Examples}



{title:Example 1: Fill missing values with(any)}

{p 4 4 2}Let us first create a sample dataset of one variable having 10 observations. 
You can copy-paste the following code to Stata Do editor to generate the dataset

	clear all
	set obs 10
	gen symbol = "AABS"
	replace symbol = "" in 5
	replace symbol = "" in 8

{p 4 4 2}The above dataset has missing values on row 5 and 8. To fill the 
         missing values from any other available non-missing values, let 
		 us use the with(any) option.

{p 4 8 2}{stata "fillmissing symbol, with(any)" : fillmissing symbol, with(any)}{p_end}

{p 4 4 2}Since {opt with(any)} is the default option of the program, we could also write the above code as

{p 4 4 2}{stata "fillmissing symbol": fillmissing symbol}


{title:Example 2: Fill missing values with(previous)}

{p 4 4 2}Let’s create a dummy dataset first.

	clear all
	set obs 10
	gen symbol = "AABS" 
	replace symbol = "AKBL" in 1
	replace symbol = "" in 2  
 
{p 4 4 2}To fill the missing value in observation number 2 with AKBL, i.e. 
        from previous observation, we would type:

{p 4 8 2}{stata "fillmissing symbol, with(previous)" : fillmissing symbol, with(previous)}



 {title:Example 3: Fill missing values within groups} 
 
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 
 {p 4 8 2}Create some missing values and fill them within the grouping variable {opt company}{p_end}
 {p 4 8 2}{stata "replace kstock = . in 2":replace kstock = . in 2}{p_end}
 
 {p 4 8 2}{stata "replace kstock = . in 25":replace kstock = . in 25}{p_end}

 {p 4 8 2}{stata "bysort company: fillmissing kstock " :bysort company: fillmissing kstock)} {p_end}
 
 
 

 {marker online}
{title:Web Page}

{p 4 4 2} For more examples, comments, questions/answers, please visit this page{p_end}

{p 4 4 2}{browse "https://fintechprofessor.com/2019/12/20/fillmissing-fill-missing-values-in-stata/" : fillmissing: Fill Missing Values in Stata}{break}




{title:Author}


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: *
*                                                                   *
*            Dr. Attaullah Shah                                     *
*            Institute of Management Sciences, Peshawar, Pakistan   *
*            Email: attaullah.shah@imsciences.edu.pk                *
*           {browse "www.StataProfessor.com": www.StataProfessor.com}                                 *
*           {browse "www.OpenDoors.Pk": www.OpenDoors.Pk}                                       *
*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*


{marker also}{...}
{title:Also see}

{psee}
{stata "ssc desc asdoc": asdoc}, 
{stata "ssc desc astile":astile}, 
{stata "ssc desc ascol":ascol}, 
{stata "ssc desc asreg":asreg},
{browse "http://www.opendoors.pk/asm":asm},
{stata "ssc desc astx":astx},
{stata "ssc desc searchfor":searchfor}.


