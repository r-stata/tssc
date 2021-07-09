{smcl}
{hline}
help for {cmd:dta2ddi}
{right:Minh Cong Nguyen}
{hline}

{title:{cmd:dta2ddi} - DDI maker from Stata}

{p 8 17}
{cmdab:dta2ddi},
[{cmd:using}{cmd:(}{it:string}{cmd:)}
{cmd:save}{cmd:(}{it:string}{cmd:)}
{cmd:append}{cmd:(}{it:string}{cmd:)}
{cmd:id}{cmd:(}{it:string}{cmd:)}
{cmd:stats}{cmd:(}{it:string}{cmd:)}
{cmd:replace}
{cmd:xxx}{cmd:(}{it:string}{cmd:)}
{cmd:yyy}{cmd:(}{it:string}{cmd:)}
{cmd:zzz}{cmd:(}{it:string}{cmd:)}
{cmd:aaa}{cmd:(}{it:string}{cmd:)}
{cmd:bbb}{cmd:(}{it:string}{cmd:)}
{cmd:ccc}{cmd:(}{it:string}{cmd:)}
{cmd:ddd}{cmd:(}{it:string}{cmd:)}
{cmd:eee}{cmd:(}{it:string}{cmd:)}
{cmd:fff}{cmd:(}{it:string}{cmd:)}
{cmd:ggg}{cmd:(}{it:string}{cmd:)}
{cmd:hhh}{cmd:(}{it:string}{cmd:)}
{cmd:iii}{cmd:(}{it:string}{cmd:)}
{cmd:jjj}{cmd:(}{it:string}{cmd:)}
{cmd:kkk}{cmd:(}{it:string}{cmd:)}
{cmd:lll}{cmd:(}{it:string}{cmd:)}
{cmd:mmm}{cmd:(}{it:string}{cmd:)}
{cmd:nnn}{cmd:(}{it:string}{cmd:)}
{cmd:ooo}{cmd:(}{it:string}{cmd:)}
{cmd:ppp}{cmd:(}{it:string}{cmd:)}
{cmd:qqq}{cmd:(}{it:string}{cmd:)}
{cmd:rrr}{cmd:(}{it:string}{cmd:)}
{cmd:sss}{cmd:(}{it:string}{cmd:)}
{cmd:ttt}{cmd:(}{it:string}{cmd:)}
{cmd:uuu}{cmd:(}{it:string}{cmd:)}
{cmd:vvv}{cmd:(}{it:string}{cmd:)}]
{p_end}
	
{title:Description}

{p 4 4 2}{cmdab:dta2ddi} is a tool to convert Stata data into DDI standards. The current DDI standard is 1.12 
and it will also incorporate the other standards (2.5 and 3.x) when they are used widely in practice.
{p_end} 

{p 4 4 2}The tool will create an XML-based file, which is compatiable with any DDI software such as Nesstar Publisher. The main purpose of the tool is to
create a large number of DDI files in a semi-automatic manner for the new or revised database. The parts from the database are
file descriptions, variable descriptions. Document and study descriptions are entered externally, either from an existing DDI file or other sources.
{p_end}

{title:Thanks for citing dta2ddi as follows}

{p 4 4 2}Minh Cong Nguyen (2014) DDI maker from Stata. World Bank. (mimeo){p_end}

{title:Where}

{p 4 4 2}{it:using} is the files or the folder name which contains several data files.{p_end}

{p 4 4 2}{it:save} is the link for saving the DDI file.{p_end}

{p 4 4 2}{cmd:append} is the link to the file where it will append the information with the new DDI file.{p_end}

{p 4 4 2}{cmd:id} is the name of the DDI (optional).{p_end}

{p 4 4 2}{cmd:stats} is the statistics you can add to the DDI (min, max, mean, stdev).{p_end}

{title:Options}

{p 4 4 2}{cmd:xxx} is the information you can modify in the appended file (append option). In the append file, you can refer it to ;XXX; in the template/appened DDI.{p_end}

{p 4 4 2}...{p_end}

{p 4 4 2}{cmd:vvv} is the information you can modify in the appended file (append option). In the append file, you can refer it to ;VVV; in the template/appened DDI.{p_end}

{title:Saved Results}

{cmd:dta2ddi} returns results in {hi:r()} format. 
By typing {helpb return list}, the following results are reported:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(cmdline)}}the code line used in the session {p_end}

{title:Examples}

	tempfile filename
	import excel using "DDI_folders.xlsx", clear firstrow  
	save "$ddiout/`filename'", replace
	local N = _N
	forv i = 1(1)`N'{  
	use "$ddiout/`filename'", clear}
{p 8 12}{inp:.		dta2ddi, using(`=path[`i']') save($ddiout\\`=folder[`i']'.xml) append($append) id(`=folder[`i']') xxx(`=ctry[`i']') yyy(`=year[`i']') zzz(`=folder[`i']') aaa(`=code[`i']') bbb(`=datadate[`i']') ccc(`=veralt[`i']') ddd(July 2014)}{p_end}
	}
	
{p 8 12}{inp:.dta2ddi, using("c:\DDI\UKR_2012_HLCS_v01_M_v01_A_ECAPOV") save("c:\DDI\UKR_2012_HLCS_v01_M_v01_A_ECAPOV.xml") replace append("c:\DDI\ALB_2012_LSMS_v01_M_v01_A_ECAPOV.xml")}{p_end}

{title:References}

{p 4 4 2} Data Documentation Initiative (website)
{browse "http://www.ddialliance.org/" : (link to publication)}{p_end}

{p 4 4 2} Micro Data Library (website)
{browse "http://microdata.worldbank.org/index.php/home" : (link to publication)}{p_end}

{title:Authors}
	{p 4 4 2}Minh Cong Nguyen, congminh6@gmail.com or mnguyen3@worldbank.org{p_end}
		
{title:Acknowledgements}
    {p 4 4 2}The author would like to thank Joao Pedro Azevedo, Matthew John Welch, Mehmood Asghar, Julia Dukhno for their valuable suggestions.{p_end} 
    {p 4 4 2}All errors and ommissions are of exclusive responsability of the author.{p_end}	
	
	

{title:Also see}

{p 2 4 2}Online:  help for {help apoverty}; {help ainequal};  {help wbopendata}; {help frcount}; {help xtsur}; {help adecomp} (if installed){p_end} 


