{smcl}
{* *! version 1.0.0 Aliaksandr Amialchuk 21oct2016}{...}

{title:Title}

{p2colset 5 20 30 2}{...}
{p2col:{hi:framingham30} {hline 1}}Framingham 30-year Cardiovascular Disease Event Risk Prediction{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{pstd}
Framingham30 using data in memory

{p 8 17 2}
				{cmdab:framingham30}
				{ifin}
				{cmd:,}
				{opt m:ale}({it:varname}) 
				{opt age:}({it:varname}) 
				{opt sbp:}({it:varname})  
				{opt tr:tbp}({it:varname}) 
				{opt sm:oke}({it:varname}) 
				{opt diab:}({it:varname}) 
				[{opt bmi:}({it:varname})] 
				[{opt tcl:}({it:varname})  
				{opt hdl:}({it:varname})]

{synoptset 21 tabbed}{...}
{synopthdr:framingham30 options}
{synoptline}
{syntab:Required}
{synopt:{opt m:ale(varname)}}gender (1 for male, 0 for female){p_end}
{synopt:{opt age:}(varname)}age in years{p_end}
{synopt:{opt sbp:}(varname)}systolic blood pressure (mmHg){p_end}
{synopt:{opt tr:tbp}(varname)}use of antihypertensive treatment (1 for yes, 0 for no){p_end}
{synopt:{opt sm:oke}(varname)}smoking status (1 for smoker, 0 for non-smoker){p_end}
{synopt:{opt diab:}(varname)}diabetes status (1 for diabetic, 0 for non-diabetic){p_end}

{syntab:Optional (you must specify either option {opt bmi:} or options {opt tcl:} and {opt hdl:})}
{synopt:{opt bmi:}(varname)}body mass index (BMI, kg/m2){p_end}
{synopt:{opt tcl:}(varname)}total cholesterol level (TCL, mg/dL){p_end}
{synopt:{opt hdl:}(varname)}high density lipoprotein level (HDL, mg/dL){p_end}
{synoptline}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:framingham30} calculates 30-year risk of "hard" and "full" cardiovascular disease (CVD), based on the Framingham Heart Study 
(Pencina, D'Agostino, Larson, Massaro, Vasan 2009). Hard CVD is defined as coronary death, myocardial infarction, fatal or non-fatal stroke. 						
Full CVD is defined as hard CVD or coronary insufficiency, angina pectoris, transient ischemic attack, intermittent claudication or congestive heart failure.
After running, 	{cmd:framingham30} creates the following variables:

{synoptset 21 tabbed}{...}
{synopthdr:created variables}
{synoptline}
{syntab:When option {opt bmi:} is specified:}
{synopt:{opt friskcvd30}} 30-year risk of full CVD (based on BMI){p_end}
{synopt:{opt friskcvd30opt}} Age/sex adjusted "optimal" 30-year risk of full CVD (based on BMI and assuming sbp=110, smoke=0, trtbp=0, bmi=22, diab=0){p_end}
{synopt:{opt friskcvd30nor}} Age/sex adjusted "normal" 30-year risk of full CVD (based on BMI and assuming sbp=125, smoke=0, trtbp=0, bmi=22.5, diab=0){p_end}

{synopt:{opt hriskcvd30}} 30-year risk of hard CVD (based on BMI){p_end}
{synopt:{opt hriskcvd30opt}} Age/sex adjusted "optimal" 30-year risk of hard CVD (based on BMI and assuming sbp=110, smoke=0, trtbp=0, bmi=22, diab=0){p_end}
{synopt:{opt hriskcvd30nor}} Age/sex adjusted "normal" 30-year risk of hard CVD (based on BMI and assuming sbp=125, smoke=0, trtbp=0, bmi=22.5, diab=0){p_end}

{syntab:When options {opt tcl:} and {opt hdl:} are specified:}
{synopt:{opt friskcvdl30}} 30-year risk of full CVD (based on lipids){p_end}
{synopt:{opt friskcvdl30opt}} Age/sex adjusted "optimal" 30-year risk of full CVD (based on lipids and assuming sbp=110, smoke=0, trtbp=0, bmi=22, diab=0){p_end}
{synopt:{opt friskcvdl30nor}} Age/sex adjusted "normal" 30-year risk of full CVD (based on lipids and assuming sbp=125, smoke=0, trtbp=0, bmi=22.5, diab=0){p_end}

{synopt:{opt hriskcvdl30}} 30-year risk of hard CVD (based on lipids){p_end}
{synopt:{opt hriskcvdl30opt}} Age/sex adjusted "optimal" 30-year risk of hard CVD (based on lipids and assuming sbp=110, smoke=0, trtbp=0, bmi=22, diab=0){p_end}
{synopt:{opt hriskcvdl30nor}} Age/sex adjusted "normal" 30-year risk of hard CVD (based on lipids and assuming sbp=125, smoke=0, trtbp=0, bmi=22.5, diab=0){p_end}
{synoptline}
{p2colreset}{...}

{title:Example}

    {hline}
    Setup (create sample dataset)
{phang2}{cmd:. set obs 20}{p_end}
{phang2}{cmd:. gen male=0}{p_end}
{phang2}{cmd:. gen age=37}{p_end}
{phang2}{cmd:. gen sbp=125}{p_end}
{phang2}{cmd:. gen smoke=1}{p_end}
{phang2}{cmd:. gen gtrtbp=0}{p_end}
{phang2}{cmd:. gen bmi=22.5}{p_end}
{phang2}{cmd:. gen diab=0}{p_end}
{phang2}{cmd:. replace male=1 if _n>10}{p_end}
{phang2}{cmd:. replace age=50 if _n>10}{p_end}
{phang2}{cmd:. replace sbp=240 if _n>10}{p_end}
{phang2}{cmd:. replace smoke=0 if _n>10}{p_end}
{phang2}{cmd:. replace gtrtbp=1 if _n>10}{p_end}
{phang2}{cmd:. replace bmi=. if _n>10}{p_end}
{phang2}{cmd:. replace diab=0 if _n>10}{p_end}
{phang2}{cmd:. gen tcl=160 if _n>10}{p_end}
{phang2}{cmd:. gen hdl=60 if _n>10}{p_end}

{pstd}Run {cmd:framingham30} using sample dataset{p_end}
{phang2}{cmd:. framingham30, male(male) age(age) sbp(sbp) smoke(smoke) trtbp(gtrtbp) diab(diab) bmi(bmi) tcl(tcl) hdl(hdl)}

    {hline}

{title:References}

{p 4 8 2}
Pencina, D'Agostino, Larson, Massaro, Vasan. 
	Predicting the 30-Year Risk of Cardiovascular Disease: The Framingham Heart Study.  {it:Circulation} 2009;119(24):3078-84.{p_end}

{p 4 8 2} 
see also: {browse "https://www.framinghamheartstudy.org/risk-functions/cardiovascular-disease/30-year-risk.php"}{p_end}

{marker citation}{title:Citation of {cmd:framingham}}

{p 4 8 2}{cmd:framingham30} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Amialchuk, Aliaksandr (2016). framingham30: Stata Module for Calculating the Framingham 30-year Cardiovascular Disease Risk Prediction.{p_end}

{title:Author}

{p 4 8 2}	Aliaksandr Amialchuk, University of Toledo{p_end}
{p 4 8 2}	Toledo, OH, USA{p_end}
{p 4 8 2}{browse "mailto:aamialc@utnet.utoledo.edu":aamialc@utnet.utoledo.edu}{p_end}
         
{title:Acknowledgment} 

{p 4 4 2} I would like to thank Monita Karmakar for her support while developing {cmd:framingham30}.



