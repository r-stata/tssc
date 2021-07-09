{smcl}
{* *! version 1.0.0 19feb2019}{...}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col:{hi:bmi} {hline 2}} Body Mass Index  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}
Compute BMI using variables:

{p 8 14 2}
{cmd:bmi}
{it:{help newvarname}}
{cmd:,}
{opth h:t(varname:heightvar)}
{opth w:t(varname:weightvar)}
[
{opt m:etric}
{opth c:ategory(newvarname:newvarname)}
]


{pstd}
Immediate form for computing BMI:

{p 8 14 2}
{cmd:bmii}
{it:#ht #wt}
{cmd:,}
[
{opt m:etric}
{opt c:ategory}
]


{synoptset 22 tabbed}{...}
{marker bmi}{...}
{synopthdr:bmi}
{synoptline}
{p2coldent:* {opth h:t(varname:heightvar)}}variable defining height (in either inches or in meters){p_end}
{p2coldent:* {opth w:t(varname:weightvar)}}variable defining weight (in either pounds or in kilograms){p_end}
{synopt:{opt m:etric}}indicates that height and weight are in metric units (i.e. meters and kilograms, respectively); default is English standard units (inches and pounds){p_end}
{synopt:{opth c:ategory(newvarname:newvarname)}}generates a new variable containing BMI categories{p_end}
{synoptline}
{p 4 6 2}* {opt ht(heightvar)} and {opt wt(weightvar)} are required.{p_end}


{marker bmii}{...}
{synopthdr:bmii}
{synoptline}
{synopt:{opt m:etric}}indicates that height and weight are in metric units (i.e. meters and kilograms, respectively); default is English standard units (inches and pounds) {p_end}
{synopt:{opt c:ategory}}displays the BMI category corresponding to the computed BMI{p_end}
{synoptline}
{p2colreset}{...}



{marker description}{...}
{title:Description}

{pstd}
{opt bmi} computes body mass index (BMI) values for adults, which is defined as weight in kilograms divided by the square of height in meters (kg/m^2). When the 
{cmd: metric} option is not applied, {opt bmi} will convert the English standard measurements for height (inches) and weight (pounds) into their respective metric equivalents and 
then compute BMI. Additionally, {opt bmi} can provide categories (classification) of BMI values according to the World Health Organization 
(see: {browse "http://apps.who.int/bmi/index.jsp?introPage=intro_3.html"}).

{pstd}
{opt bmii} is the immediate form of {opt bmi}; see {help immed}.



{title:Options}

{p 4 8 2}
{cmd:metric} indicates that height and weight are in metric units. More specifically, height must be in meters and weight must be in kilograms. The default is that
height is in inches and weight is in pounds. 

{p 4 8 2}
{cmd:category(}{it:newvarname}{cmd:)} generates a new variable containing weight categories according to WHO classification criteria (see: {browse "http://apps.who.int/bmi/index.jsp?introPage=intro_3.html"}).



{title:Examples}

{pstd}
{opt 1) BMI using variables:}{p_end}

{pmore} load data {p_end}
{pmore2}{bf:{stata "use http://www.stata-press.com/data/r15/nhanes2.dta, clear": . use http://www.stata-press.com/data/r15/nhanes2.dta, clear}} {p_end}

{pmore} generate a variable converting height in centimeters to height in meters {p_end}
{pmore2}{bf:{stata "gen ht_m = height/100": . gen ht_m = height/100}} {p_end}

{pmore} compute BMI values from metric units in a new variable called BMI2 and generate a new variable for BMI categories{p_end}
{pmore2}{bf:{stata "bmi BMI2, wt(weight) ht(ht_m) metric cat(bmi_cat)": . bmi BMI2, wt(weight) ht(ht_m) metric cat(bmi_cat)}} {p_end}

{pmore} graph BMI categories using {helpb catplot} (downloadable from SSC){p_end}
{pmore2}{bf:{stata "catplot bmi_cat": . catplot bmi_cat}} {p_end}

{pmore} generate variables in which height is converted from centimeters to inches and weight is converted from kilograms to pounds {p_end}
{pmore2}{bf:{stata "gen ht_in = height / 2.5400013716": . gen ht_in = height / 2.5400013716}} {p_end}
{pmore2}{bf:{stata "gen wt_lbs = weight * 2.20462": . gen wt_lbs = weight * 2.20462}} {p_end}

{pmore} compute BMI values from standard units in a new variable called BMI3 and generate a new variable for BMI categories{p_end}
{pmore2}{bf:{stata "bmi BMI3, wt(wt_lbs) ht(ht_in) cat(BMI_CAT)": . bmi BMI3, wt(wt_lbs) ht(ht_in) cat(BMI_CAT)}} {p_end}

{pmore} graph BMI categories as percent of total{p_end}
{pmore2}{bf:{stata "catplot BMI_CAT, percent": . catplot BMI_CAT, percent}} {p_end}


{pstd}
{opt 2) BMI using immediate form:}{p_end}

{pmore} compute BMI for an individual who is 68 inches tall and weighs 180 pounds. Display category {p_end}
{pmore2}{bf:{stata "bmii 68 200, cat": . bmii 68 200, cat}} {p_end}

{pmore} compute BMI for an individual who is 1.75 meters tall and weighs 62.50 kilograms. Display category {p_end}
{pmore2}{bf:{stata "bmii 1.75 62.50, cat metric": . bmii 1.75 62.50, cat metric}} {p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:bmii} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(bmi)}}computed BMI value{p_end}
{p2colreset}{...}



{marker citation}{title:Citation of {cmd:bmi}}

{p 4 8 2}{cmd:bmi} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2019). BMI: Stata module for computing body mass index.



{title:Author}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb catplot} if installed, {helpb mibmi} if installed {p_end}


