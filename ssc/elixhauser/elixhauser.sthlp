{smcl}
{hline}
help for {hi:elixhauser } {right:(Adapted for Stata by V. Stagg,}
{right:under the direction of Dr. Robert Hilsden,}
{right:based on algorithms created by Dr. Hude Quan)}
{hline}

{title:Elixhauser comorbidity macro}

{p 8 16 2}
{cmd:elixhauser} {it:varlist} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{cmd:, index(}{it:string}{cmd:)}
[{cmd:idvar(}{it:varname}{cmd:)}
{cmd:diagprfx(}{it:string}{cmd:)}
{cmd:smelix cmorb noshow}]

{p 8 4 2}
{cmd:by} may be used with {cmd:elixhauser}; see help {help by}


{title:Description}

{p 4 4 2}
{cmd:elixhauser} summarizes a complete set of comorbidity measures from an input database containing Enhanced ICD-9-CM
 or ICD-10 diagnostic codes, optionally outputting indicators of each elixhauser comorbidity category along with the total number. The ICD ({cmd:index(}{it:string}{cmd:)}) version of the diagnostic codes in the input database must be specified (a required 
option).
The input data of diagnoses codes must be stored as strings, with numbers 1 to the maximum number of 
comorbidities recorded, forming the suffix. These comorbidity variables must
all begin with the same root(the prefix) and either form the {it:varlist} or be defined by the root string given
in the {cmd:diagprfx(}{it:string}{cmd:)} option.
The user has the choice of units: hospital visits or patients. The former is the
default, the latter will be implemented when a patient id variable is included in the options (see below).
If requested, {cmd:elixhauser} displays a frequency summary
of the sum of comorbidities.
The {cmd:elixhauser} command  also allows for the choice of presenting
the  frequency summaries for each of the individual diagnostic elixhauser comorbidities.


{title:Options}

{p 8 22 2}
{cmd:index}{cmd:(}{it:string}{cmd:)} is required to specify the version of diagnostic data being input.
Type within the brackets after {cmd:index}:

{p 8 22 2} Index {space 6} ICD Version {space 2} String value of index option{p_end}
	{hline 61}
{p 8 22 2} Enhanced {space 7} 9 {space 20} e{p_end}
{p 8 22 2} Quan {space 11} 10 {space 19} 10{p_end}

{p 4 8 2}
{cmd:idvar}{cmd:(}{it:varname}{cmd:)} is required when the input data could possibly 
contain multiple patient records, that is, comorbidity information from more than one hospital visit per patient. The unit
will then be patients rather than visits.

{p 4 8 2}
{cmd:diagprfx}{cmd:(}{it:string}{cmd:)} is required to provide the root of the diagnostic code variable
names when the variables are not
listed as the {it:varlist} immediately following the program name. 

{p 4 8 2}
{cmd:smelix} causes the frequencies of the sum of the Elixhauser comorbidities to be shown in the
display window, after the macro has finished running. The absence of this option causes these summaries not to be shown.

{p 4 8 2}
{cmd:cmorb} causes the frequency of each individual elixhauser comorbidity to be shown in the display window,
after the macro has finished running. The absence of this option implies that these frequncies be not shown.

{p 4 8 2}
{cmd:noshow} requests that the summary of selected options be not displayed in the results window,
at the start of the running of the program.


{title:Remarks}

{p 4 4 2}
If the patient id variable option is not specified then the data cannot be sorted by patient and multiple patient
records cannot be taken into account. Instead, every observation will be considered independent from every other, with each
observation representing a unique patient-visit, causing the unit to be visits. Please note that when the observational unit is patients, rather than visits, only the final visit input data will be retained, so it is
    advised that the data be sorted by patient and visit date prior to running the {cmd:elixhauser} command.




{title:Examples}

{p 8 8 2}
	{cmd:. elixhauser, index(10) idvar(ip_chart_no) diagprfx(ip_diag) smelix cmorb}
	
	{cmd:. elixhauser DX1-DX16, index(c) noshow}

	{cmd:. elixhauser DX? DX??, index(e) idvar(acb_numb) smelix}

	{cmd:. elixhauser ip_diag*, index(10) idvar(rec_id)}

	{cmd:. elixhauser, index(10) idvar(rec_id) diagprfx(dx_code_)}


{title:References}

{p 4 8 2}
Quan H, Sundararajan V, Halfon P, et al. Coding algorithms for defining elixhauserities in ICD-9-CM and
ICD-10 administrative data. {it:Medical Care} 2005 Nov; 43(11):1073-1077.

{p 4 8 2}
Quan H, Parsons GA, & Ghali WA. Validity of information on comorbidity derived from ICD-9-CM 
administrative data. {it:Medical Care} 2002 Aug; 40(8):675-685.

{p 4 8 2}
Elixhauser A, Steiner C, Harris DR, Coffey RM. Comorbidity measures for use with 
administrative data. {it:Medical Care} 1998 Jan; 36(1): 8-27.

{title:Authors}

		Vicki Stagg, Dr. Robert Hilsden and Dr. Hude Quan    University of Calgary, CANADA


