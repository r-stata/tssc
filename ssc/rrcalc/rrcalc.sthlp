{smcl}
{* 29oct2015}{...}
{viewerjumpto "Syntax" "rrcalc##syn"}{...}
{viewerjumpto "Description" "rrcalc##des"}{...}
{viewerjumpto "Ratelist" "rrcalc##rat"}{...}
{viewerjumpto "Stored results" "rrcalc##res"}{...}
{viewerjumpto "Examples" "rrcalc##exa"}{...}
{viewerjumpto "Notes" "rrcalc##not"}{...}
{viewerjumpto "References" "rrcalc##ref"}{...}
{viewerjumpto "Authors" "rrcalc##aut"}{...}
{viewerjumpto "Version" "rrcalc##ver"}{...}
{title:Title}

{p 4 4 2}{hi:rrcalc} {hline 2} Calculates AAPOR compliant outcome rates, such as response rates, refusal rates, cooperation rates and contact rates.

{marker syn}	
{title:Syntax}

{p 4 8 2}{cmd:rrcalc} {it:{help varname}} {cmd:using}
{it:{help filename}} [{it:{help if:if} exp}] [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt gen:erate(newvar)}}generates a variable containing the categorized information of the AAPOR compliant input variable{p_end}
{synopt :{opt r:ates(ratelist)}}display option{p_end}
{synopt :{opt replace}}overwrite existing file, may be combined with {cmd:using} {p_end}
{synoptline}

{marker des}
{title:Description}

{p 4 4 2} The {cmd:rrcalc} module calculates AAPOR compliant outcome rates, such as response rates, refusal rates, cooperation rates and contact rates based on a variable which contains the final dispositions of case codes from a survey. 
Values that are not compliant with the AAPOR code scheme are treated as missing and are displayed at the end of the output. 

{p 4 4 2} This command can produce a text file containing a suggested wording for reporting the AAPOR response rates RR1 and RR3. If filename is specified, it should be specified as *.txt or *.doc. 

{p 4 4 2} The command stores all rates and scalars in r().

{marker rat}
{title:Ratelist}

{synoptset 20 tabbed}{...}
{synopt:{cmd:all}}display all AAPOR rates{p_end}
{synopt:{cmd:rr}}display AAPOR response rates{p_end}
{synopt:{cmd:ref}}display AAPOR refusal rates{p_end}
{synopt:{cmd:coop}}display AAPOR cooperation rates{p_end}
{synopt:{cmd:con}}display AAPOR contact rates{p_end}
{p2colreset}{...}

{marker res}
{title:Stored results}

{p 4 4 2}rrcalc stores the following in r():

{synoptset 20 tabbed}{...}
{p2col 4 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}Number of observations{p_end}
{synopt:{cmd:r(I)}}Complete interview (1.1){p_end}
{synopt:{cmd:r(P)}}Partial interview (1.2){p_end}
{synopt:{cmd:r(R)}}Refusal and break-off (2.1){p_end}
{synopt:{cmd:r(NC)}}Non-contact (2.2){p_end}
{synopt:{cmd:r(O)}}Other (2.0, 2.3){p_end}
{synopt:{cmd:r(UH)}}Unknown if household/occupied HU (3.1){p_end}
{synopt:{cmd:r(UO)}}Unknown, other (3.2, 3.3, 3.4, 3.5, 3.9){p_end}
{synopt:{cmd:r(NE)}}Not eligible cases{p_end}
{synopt:{cmd:r(EE)}}Eligible cases{p_end}
{synopt:{cmd:r(E)}}E is the estimated proportion of cases of unknown eligibility that are eligible{p_end}

{synopt:{cmd:r(RR1)}}Response rate 1{p_end}
{synopt:{cmd:r(RR2)}}Response rate 2{p_end}
{synopt:{cmd:r(RR3)}}Response rate 3{p_end}
{synopt:{cmd:r(RR4)}}Response rate 4{p_end}
{synopt:{cmd:r(RR5)}}Response rate 5{p_end}
{synopt:{cmd:r(RR6)}}Response rate 6{p_end}

{synopt:{cmd:r(COOP1)}}Cooperation rate 1{p_end}
{synopt:{cmd:r(COOP2)}}Cooperation rate 2{p_end}
{synopt:{cmd:r(COOP3)}}Cooperation rate 3{p_end}
{synopt:{cmd:r(COOP4)}}Cooperation rate 4{p_end}

{synopt:{cmd:r(REF1)}}Refusal rate 1{p_end}
{synopt:{cmd:r(REF2)}}Refusal rate 2{p_end}
{synopt:{cmd:r(REF3)}}Refusal rate 3{p_end}

{synopt:{cmd:r(CON1)}}Contact rate 1{p_end}
{synopt:{cmd:r(CON2)}}Contact rate 2{p_end}
{synopt:{cmd:r(CON3)}}Contact rate 3{p_end}
{p2colreset}{...}

{marker exa}
{title:Examples}

{p 4 8 2}{com:. rrcalc dispositioncode, r(rr)}{p_end}
{p 4 8 2}{com:. rrcalc dispositioncode using report.txt, r(all)}{p_end}
{p 4 8 2}{com:. rrcalc dispositioncode, r(con coop) gen(dispositioncodeNew)}{p_end}

{marker not}
{title:Notes}

{p 4 4 2}Note on the treatment of the final dispostion codes 2.0, 3.0, 3.6, 3.7, 3.8:

{p 4 4 2}Using the codes 2.0 or 3.0 is not advised. Instead researchers might want to consider more appropriate subcategories. This command treats the disposition code 2.0 (20 - Eligible, non-interview) like 2.3 (23 - Other). 
Researchers might want to check whether this assumption is correct and recode the corresponding cases in a more appropriate subcategory. 
The disposition code 3.0 (30) is not used in the calculations because its proper use depends on further assumptions. 
Researchers need to make the decision to recode 3.0 into one of the available subcategories 3.1-3.5, or 3.9 in order to get correct calculations.
Similarly, because the codes 3.6-3.8 are not defined they are not used in the calculations.

{p 4 4 2}Note on the required format of {it:{help varname}}:

{p 4 4 2}The command expects that the final dispositions of case codes are numeric values and either in the format with commas (e.g., 1.1 for complete interview) or without commas (e.g, 11).

{marker ref}
{title:References}

{p 4 4 2}The American Association for Public Opinion Research. 2015. Standard Definitions: Final Dispositions of Case Codes and Outcome Rates for Surveys. 8th edition. AAPOR.
	
{marker aut}
{title:Authors}

{p 4 4 2} Kai Willem Weyandt, GESIS - Leibniz Institute for the Social Sciences, kai.weyandt@gesis.org

{p 4 4 2} Lars Kaczmirek, GESIS - Leibniz Institute for the Social Sciences, lars.kaczmirek@gesis.org

{marker ver}
{title:Version}

{p 4 4 2}Version 1.1 - 29th October 2015.

