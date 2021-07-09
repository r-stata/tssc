{smcl}
{* *! version 1.0.1 18February2017}{...}
{* *! version 1.0.0 2April2015}{...}

{title:Title}

{p2colset 5 20 30 2}{...}
{p2col:{hi:framingham} {hline 2}}Framingham 10-year Cardiovascular Disease Event Risk Prediction{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}
Framingham using data in memory

{p 8 17 2}
				{cmdab:framingham}
				{ifin}
				{cmd:,}
				{opt m:ale}({it:varname}) 
				{opt age:}({it:varname}) 
				{opt sbp:}({it:varname})  
				{opt tr:htn}({it:varname}) 
				{opt sm:oke}({it:varname}) 
				{opt diab:}({it:varname}) 
				{opt hdl:}({it:varname})  
				{opt chol:}({it:varname})  
				[ {opt opt:imal}
				{opt repl:ace} 
                {opt suff:ix}({it:string})
				]



{pstd}
Immediate form of Framingham

{p 8 17 2}
				{cmd:framinghami}
				{cmd:,} 
				{opt m:ale}({it:0/1}) 
				{cmdab:age:}({it:numlist}) 
				{cmdab:sbp:}({it:numlist})  
				{cmdab:tr:htn}({it:0/1}) 
				{cmdab:sm:oke}({it:0/1}) 
				{cmdab:diab:}({it:0/1}) 
				{cmdab:hdl:}({it:numlist})  
				{cmdab:chol:}({it:numlist})  
				[ {opt opt:imal}
				]


{synoptset 21 tabbed}{...}
{synopthdr:framingham options}
{synoptline}
{syntab:Required}
{synopt:{opt m:ale(varname)}}gender, where male = 1 and female = 0{p_end}
{synopt:{opt age:}(varname)}age in years{p_end}
{synopt:{opt sbp:}(varname)}systolic blood pressure (mmHg){p_end}
{synopt:{opt tr:htn}(varname)}treatment for hypertension antihypertensive medication{p_end}
{synopt:{opt sm:oke}(varname)}smoking status, where smoker = 1 and non-smoker = 0{p_end}
{synopt:{opt diab:}(varname)}diabetes status, where diabetic = 1 and non-diabetic = 0{p_end}
{synopt:{opt hdl:}(varname)}high density lipoprotein level (mg/dL){p_end}
{synopt:{opt chol:}(varname)}total cholesterol level (mg/dL){p_end}

{syntab:Optional}
{synopt:{opt repl:ace}}replaces variables created by {cmd:framingham} if they already exist{p_end}
{synopt:{opt suff:ix}(string)}adds a suffix to the names of variables created by {cmd:framingham}{p_end}
{synopt:{opt opt:imal}}adds a variable to the file representing the age/sex adjusted optimal risk (where sbp = 110, chol = 160, hdl = 60) {p_end}
{synoptline}
{p 4 6 2}

{synoptset 21 tabbed}{...}
{synopthdr:immediate options}
{synoptline}
{syntab:Required}
{synopt:{opt m:ale(integer)}}gender, where male = 1 and female = 0{p_end}
{synopt:{opt age:}(numlist)}age in years{p_end}
{synopt:{opt sbp:}(numlist)}systolic blood pressure (mmHg){p_end}
{synopt:{opt tr:htn}(integer)}treatment for hypertension with antihypertensive medication{p_end}
{synopt:{opt sm:oke}(integer)}smoking status, where smoker = 1 and non-smoker = 0{p_end}
{synopt:{opt diab:}(integer)}diabetes status, where diabetic = 1 and non-diabetic = 0{p_end}
{synopt:{opt hdl:}(numlist)}high density lipoprotein level (mg/dL){p_end}
{synopt:{opt chol:}(numlist)}total cholesterol level (mg/dL){p_end}

{syntab:Optional}
{synopt:{opt opt:imal}}provides an additional estimate of the age/sex adjusted optimal risk (where sbp = 110, chol = 160, hdl = 60) {p_end}
{synoptline}
{p2colreset}{...}


	
{title:Description}

{pstd}
{cmd:framingham} calculates the 10-year risk of having a cardiovascular disease event, based on the Framingham Heart Study 
(D'Agostino et al. 2008).

{pstd}
{opt framinghami} is the immediate form of {opt framingham}; see {help immed}.



{title:Examples}

    {hline}
    Setup
{phang2}{cmd:. use framingham}{p_end}

{pstd}Run {cmd:framingham} using data in memory{p_end}
{phang2}{cmd:. framingham , male(male) age(age) sbp(sbp) trhtn(trhtn) smoke(smoke) diab(diab) hdl(hdl) chol(chol)}

{pstd}Rerun command, specifying the optimal option, and replace existing estimates{p_end}
{phang2}{cmd:. framingham , male(male) age(age) sbp(sbp) trhtn(trhtn) smoke(smoke) diab(diab) hdl(hdl) chol(chol) replace optimal}

    {hline}
{pstd}Run {cmd:framinghami} for an individual case and specify the optimal option{p_end}
{phang2}{cmd:. framinghami , male(1) age(51) sbp(130) trhtn(0) smoke(0) diab(0) hdl(52) chol(151) optimal}{p_end}

    {hline}



{title:Stored results}

{pstd}
{cmd:framinghami} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(risk10)}}10-year risk estimate{p_end}
{synopt:{cmd:r(optrisk10)}}optimal 10-year risk estimate (if option {opt optimal} is specified){p_end}



{title:References}

{p 4 8 2}
D'Agostino RB, Vasan RS, Pencina MJ, Wolf PA, Cobain M, Massaro JM, Kannel WB.  
	General cardiovascular risk profile for use in primary care: the Framingham Heart Study. {it:Circulation} 2008;117(6)743-753.{p_end}

{p 4 8 2} 
see also: http://www.framinghamheartstudy.org/risk-functions/cardiovascular-disease/10-year-risk.php {p_end}



{marker citation}{title:Citation of {cmd:framingham}}

{p 4 8 2}{cmd:framingham} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2015). framingham: Stata module for calculating the Framingham 10-year Cardiovascular Disease Risk Prediction{p_end}



{title:Author}

{p 4 8 2}	Ariel Linden{p_end}
{p 4 8 2}	President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}	Ann Arbor, MI, USA{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
{p 4 8 2}{browse "http://www.lindenconsulting.org"}{p_end}

         
{title:Acknowledgments} 

{p 4 4 2} I would like to thank Nicholas J. Cox for his support while developing {cmd:framingham}



