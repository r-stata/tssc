{smcl}
{.-}
help for {cmd:iskooesch}
{.-}

{title:iskooesch}

{p 8 15 2}
{cmd:iskooesch} {it:newvarname}, {cmd:isko(}{it:varname}{cmd:)}
  {cmd:emplrel(}{it:varname}{cmd:)} {cmd:emplno(}{it:varname}{cmd:)} [{cmd:sixteen} {cmd:eight} {cmd:five} {cmd:replace}]
  

{title:Description}

{p 4 4 2}
This command converts 4 digit ISCO-88 {it:(International Classification of Occupations)} codes into the class scheme proposed by Oesch (2006).

{p 4 4 2}
The {it:newvarname} argument for the {cmd:iskooesch} command can be any string. The program combines it with a class scheme indicator to create the names of the generated variables (see options {cmd:sixteen}, {cmd:eight}, {cmd:five}).

{p 8 12 2}
{help iscooesch} makes the transformation into the Oesch scale based on ISCO-08 codes.


{title:Options}

{p 4 8 2}
{cmd:isko} specifies the variable to be recoded.
This must be a 4 digit integer containing ISCO-88 occupational codes.

{p 4 8 2}
{cmd:emplrel} specifies a categorical variable indicating the employment relation. Relevant values are: 1 = employee, 2 = self-employed, [3 = working for family business, optional]. All other values are ignored.

{p 4 8 2}
{cmd:emplno} specifies a numerical variable indicating the absolute number of employees supervised. The relevant intervals for placement in the respective Oesch categories are 0, 1/9, and 10/max.

{p 4 8 2}
{cmd:sixteen}, {cmd:eight}, {cmd:five} specify which versions of the Oesch class scheme (16-class, 8-class, 5-class) are generated. If no option is given, the 16-class scheme is generated.
The resulting variables are named oesch16_{it:newvarname}, oesch8_{it:newvarname}, oesch5_{it:newvarname} respectively.

{p 4 8 2}
{cmd:replace} permits to overwrite existing variables.

{title:References}

{p 4 8 2}
Hendrickx, J. 2002. "{browse "https://ideas.repec.org/c/boc/bocode/s425802.html":ISKO: Stata module to recode 4 digit ISCO-88 occupational codes}" {browse "https://ideas.repec.org/s/boc/bocode.html":Statistical Software Components S425802},
Boston College Department of Economics, revised 20 Oct 2004.

{p 4 8 2}
Oesch, D. 2006a. "Coming to grips with a changing class structure" International Sociology 21 (2): 263-288.

{p 4 8 2}
Oesch, D. 2006b. "Redrawing the Class Map. Stratification and Institutions in Britain, Germany, Sweden and Switzerland" Basingstoke: Palgrave Macmillan.

{p 4 8 2}
Tawfik, A. 2014. Various scripts for creating Oesch class variables. {browse "http://people.unil.ch/danieloesch/scripts/"}


{title:Author}

{p 4 4 2}
Simon Kaiser, Institute of Sociology, University of Bern, simon.kaiser@soz.unibe.ch

{p 4 4 2}
Thanks for citing this software as follows:

{p 8 8 2}
Kaiser, S. (2018). oesch: Stata module to create Oesch class schemes. Available from 
{browse "https://ideas.repec.org/c/boc/bocode/s458490.html"}.


{title:Also see}

{p 4 4 2}
{browse "https://github.com/sikaiser/oesch"} for most 
up-to-date version and to report issues or feature requests.


{p 0 21}
On-line: help for
  {help oesch}, {help iscooesch}, {help isko}, {help isco}
{p_end}

