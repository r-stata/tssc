{smcl}
{* *! version 2.0 June 12, 2012}{...}
{viewerjumpto "Syntax" "tmpm##syntax"}{...}
{viewerjumpto "Description" "tmpm##description"}{...}
{viewerjumpto "Requirements" "tmpm##requirements"}{...}
{viewerjumpto "Options" "tmpm##options"}{...}
{viewerjumpto "Remarks" "tmpm##remarks"}{...}
{viewerjumpto "Examples" "tmpm##examples"}{...}
{viewerjumpto "Authors" "tmpm##authors"}{...}
{viewerjumpto "References" "tmpm##references"}{...}
{title:Title}

{phang}
{bf:tmpm} {hline 2} Trauma Mortality Prediction Model using AIS, ICD-9 or ICD-10 codes
{p2colreset}{...} 


{marker syntax}{...}
{title:Syntax}

{phang}
{cmdab:tmpm,} 
[idvar(varname) aispfx(string) icd9pfx(string) icd10pfx(string) noreport]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt noreport}}supress report output{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:tmpm} calculates probability of death (p(death)) based on the Trauma 
Mortality Prediction Model created by Turner Osler, MD, MSc, and Laurent Glance, MD. 
The {cmd:tmpm} uses injuries recorded in one of three lexicons ( either AIS, ICD-9 
or ICD-10) and computes the probability of death (p(Death))for each patient in the 
dataset. {cmd:tmpm} will accommodate datasets arranged in wide format (one record 
per patient with many injuries per record), or the long format (many records per 
patient, with one injury/record). {cmd:tmpm} will calculate a probability of death 
(p(Death)) value for each observation expressed as a vartype float and add this new 
variable (named pDeathais, pDeathicd9, or pDeathicd10, as appropriate) to the user's 
otherwise unchanged dataset.


{marker requirements}{...}
{title:Requirements}

{phang}
1.) A unique identification is required for each patient. 

{phang}
2.) The variable name used to identify each patient (idvar) and the injury variable(s)
must not have the same prefix. 

{phang}
3.) The  -icd9pfx-, -icd10pfx-, and -aispfx- are the prefixes for variable names that 
identify column(s) containing the ICD-9, ICD-10 or AIS codes, respectively. 

{phang}
4.) The names of the variables containing the injury codes must begin with a common 
prefix ( e.g., inj1, inj2, ... inj{it:n}). 

{phang}
5.) {cmd:tmpm} and the accompanying {it:marc} tables (icd9marc2_table, aismarc_table, 
icd10marc_table) must be installed to the "C:\ado\personal" file.


{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt noreport}  suppresses the report output which describes the master dataset in the 
following terms:

{pmore} 
Proportion of invalid ICD-9 codes:

{pmore} 
Proportion of ICD-9 codes unrelated to trauma:

{pmore}
Proportion of codes matched with marc values:

{pmore}
Your data contain {it:n} unique AIS/ICD-9/ICD-10 codes

{pmore}
Your unmatched AIS/ICD-9/ICD-10 codes:


{marker remarks}{...}
{title:Remarks}

{phang}
1.) {cmd:tmpm} requires STATA 11.0 or higher. This command will not operate on any 
previous version of STATA.


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}

{phang}{cmd:. sysuse tmpm_ex.dta}

{phang}
Calculate the p(Death) using ICD-9 codes and display the report output {p_end}

{phang}
{cmd:. tmpm, idvar(ptid) icd9pfx(icd9inj)}{p_end}

{phang} 
Calculate the p(Death) using AIS codes and supress the report output {p_end}

{phang} 
{cmd:. tmpm, idvar(ptid) aispfx(injais) noreport} {p_end}


{marker authors}{...} 
{title:Authors}
{pstd}
Alan Cook, M.D. <adcookmd@gmail.com> {p_end}
{pstd}
Baylor University Medical Center, Dallas, TX, USA {p_end}

{pstd}
Turner Osler, M.D., MSc(Biostatistics) <tosler@uvm.edu> {p_end}
{pstd}
University of Vermont College of Medicine, Burlington, VT, USA {p_end}


{marker authors}{...}
{title:References:}

{pstd}
1.) Osler T, Glance L, Buzas JS, Mukamel D, Wagner J, Dick A. A trauma mortality 
prediction model based on the anatomic injury scale. Ann Surg 2008;247:1041-8.{p_end}
{pstd}
http://journals.lww.com/annalsofsurgery/Abstract/2008/06000/A_Trauma_Mortality_Prediction_Model_Based_on_the.19.aspx {p_end}

{pstd}
2.) Glance LG, Osler TM, Mukamel DB, Meredith W, Wagner J, Dick AW. TMPM-ICD9: 
a trauma mortality prediction model based on ICD-9-CM codes. Ann Surg 2009;249:1032-9.{p_end}
{pstd}
http://journals.lww.com/annalsofsurgery/Abstract/2009/06000/TMPM_ICD9__A_Trauma_Mortality_Prediction_Model.25.aspx {p_end}

{pstd}
3.) ICD-10 mapping references:
Overview:
http://library.ahima.org/xpedio/groups/public/documents/government/bok1_043820.pdf
General Equivalence Mappings and User’s Guides
http://www.cms.hhs.gov/ICD10/01m_2009_ICD10PCS.asp
http://www.cms.hhs.gov/ICD10/02m_2009_ICD_10_CM.asp




