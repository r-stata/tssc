{smcl}
{hline}
help for {hi:charlson } {right:(Adapted for Stata by V. Stagg,}
{right:under the direction of Dr. Robert Hilsden,}
{right:based on Deyo algorithm and those created by Dr. Hude Quan)}
{hline}

{title:Charlson comorbidity macro}

{p 8 16 2}
{cmd:charlson} {it:varlist} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{cmd:, index(}{it:string}{cmd:)}
[{cmd:idvar(}{it:varname}{cmd:)}
{cmd:diagprfx(}{it:string}{cmd:)}
{cmd:assign0 wtchrl cmorb noshow}]

{p 8 4 2}
{cmd:by} may be used with {cmd:charlson}; see help {help by}


{title:Description}

{p 4 4 2}
{cmd:charlson} calculates a comorbidity index from an input database containing ICD-9-CM or ICD-10 diagnostic codes. If the 
database contains ICD-9-CM diagnostic codes, then the user has the choice of calculating either the Deyo version of the 
Charlson comorbidities index or the Enhanced index. If the database contains ICD-10 diagnostic codes then the comorbidity
index developed by Quan et al is calculated.
The ICD ({cmd:index(}{it:string}{cmd:)}) version of the diagnostic codes in the input database must be specified (a required option).
The input data of diagnoses codes must be stored as strings, with numbers 1 to the maximum number of 
comorbidities recorded, forming the suffix. These comorbidity variables must
all begin with the same root(the prefix) and either form the {it:varlist} or be defined by the root string given
in the {cmd:diagprfx(}{it:string}{cmd:)} option.
The user has the choice of units: hospital visits or patients. The former is the
default, the latter will be implemented when a patient id variable is included in the options (see below).
If requested, {cmd:charlson} displays a frequency distribution of the Charlson Index score (i.e. summaries
of the sum of the weighted
scores) and a grouped version of the Charlson index.
The {cmd:charlson} command  also allows for the choice of presenting
the intermediate frequency summaries for each of the individual diagnostic comorbidity categories. 
Weighting of the scores in each category follows the optional
hierarchy adjustments, which ensure that only the more severe comorbidity of a type is counted, if desired.


{title:Options}

{p 8 22 2}
{cmd:index}{cmd:(}{it:string}{cmd:)} is required to specify the version of comorbidity data being input.
Type within the brackets after {cmd:index}:

{p 8 22 2} Index {space 6} ICD Version {space 2} String value of index option{p_end}
	{hline 61}
{p 8 22 2} Charlson {space 7} 9 {space 20} c{p_end}
{p 8 22 2} Enhanced {space 7} 9 {space 20} e{p_end}
{p 8 22 2} Quan {space 11} 10 {space 19} 10{p_end}

{p 4 8 2}
{cmd:idvar}{cmd:(}{it:varname}{cmd:)} is required when the input comorbidity data could possibly 
contain multiple patient records, that is, comorbidity information from more than one hospital visit per patient. The unit
will then be patients rather than visits.

{p 4 8 2}
{cmd:diagprfx}{cmd:(}{it:string}{cmd:)} is required to provide the root of the comorbidity variable
names when the comorbidity variables are not
listed as the {it:varlist} immediately following the program name. 

{p 4 8 2}
{cmd:assign0} indicates that a hierarchy of comorbities be applied. This means that, should a more severe form of 
a comorbidity be also present in a patient, then the more mild form will be assigned to 0 and thus not be counted as well.
This ensures that a type of comorbidity is not counted more than once in each patient. The absence of this option implies
that no hierarchy be applied.

{p 4 8 2}
{cmd:wtchrl} causes the summary of the Charlson index (the weighted comorbidity sums) and a grouped version of the Charlson index be shown in the
display window, after the macro has finished running. The absence of this option implies that these summaries be not shown.

{p 4 8 2}
{cmd:cmorb} causes the frequency of each individual comorbidity to be shown on the display window,
after the macro has finished running. The absence of this option implies that these frequncies be not shown.

{p 4 8 2}
{cmd:noshow} requests that the summary of selected options be not displayed in the results window,
at the start of the running of the program.


{title:Remarks}

{p 4 4 2}
If the patient id variable option is not specified then the data cannot be sorted by patient and multiple patient
records cannot be taken into account. Instead, every observation will be considered independent from every other, with each
observation representing a unique patient-visit, causing the unit to be visits. Please note that when the observational unit is patients, rather than visits, only the final visit input data will be retained, so
it is advised that the data be sorted by patient and visit date prior to running the {cmd:charlson} command.
 
{title:Examples}

{p 8 8 2}
	{cmd:. charlson, index(10) idvar(ip_chart_no) diagprfx(ip_diag) wtchrl cmorb}
	
	{cmd:. charlson DX1-DX16, index(c) assign0 noshow}

	{cmd:. charlson DX? DX??, index(e) idvar(acb_numb) assign0 wtchrl}

	{cmd:. charlson ip_diag*, index(10) idvar(rec_id)}

	{cmd:. charlson, index(10) idvar(rec_id) diagprfx(dx_code_)}


{title:References}

{p 4 8 2}
Quan H, Sundararajan V, Halfon P, et al. Coding algorithms for defining comorbidities in ICD-9-CM and
ICD-10 administrative data. {it:Medical Care} 2005 Nov; 43(11):1073-1077.

{p 4 8 2}
Quan H, Parsons GA, & Ghali WA. Validity of Information on Comorbidity Derived from ICD-9-CM 
Administrative Data. {it:Medical Care} 2002 Aug; 40(8):675-685.

{p 4 8 2}
Charlson ME, Pompei P, Ales KL, McKenzie CR. A new method of classifying prognostic comorbidity 
in longitudinal studies: development and validation. {it:J Chron Dis} 1987 May; 40(5): 373-383.

{title:Authors}

		Vicki Stagg, Dr. Robert Hilsden and Dr. Hude Quan   University of Calgary, CANADA


