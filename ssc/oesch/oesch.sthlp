{smcl}
{.-}
help for {cmd:oesch}
{.-}

{title:Package}

{p 4 4 2}
The {cmd:oesch} package consists of two programs to recode 4-digit ISCO {it:(International Classification of Occupations)} codes into the class scheme proposed by Oesch (2006). The third command ({cmd:oesch}) allows to shrink existing Oesch class 
variables into their condensed versions.

{p 8 12 2}
{help iskooesch} makes the transformation into the Oesch scale based on ISCO-88 codes.

{p 8 12 2}
{help iscooesch} makes the transformation into the Oesch scale based on ISCO-08 codes.

{p 4 4 2}
These programs are adaptations of the scripts by Amal Tawfik, which are available at
{browse "http://people.unil.ch/danieloesch/scripts/"}. Syntax and behavior are modeled to be more or less analogous to the {cmd:isko} and {cmd:isco} packages by John Hendrickx.


{title:oesch}
  
{p 8 15 2}
{cmd:oesch} {it:newvarname}, {cmd:oesch(}{it:varname}{cmd:)}
  [{cmd:eight} {cmd:five} {cmd:replace}]
  
{title:Description}

{p 4 4 2}
This command recodes a given 16-class Oesch variable into the 8- and 5-class 
versions.

{p 4 4 2}
The {it:newvarname} argument can be any string.
The program combines it with a class scheme indicator to create the names of the generated variables (see options {cmd:eight}, {cmd:five}).

{title:Options}

{p 4 8 2}
{cmd:oesch} specifies the variable to be recoded. This must be an integer with 
values from 1 to 16 (16-class version).

{p 4 8 2}
{cmd:eight}, {cmd:five} specify which versions of the Oesch class scheme (8-class, 5-class) are generated. If no option is specified, the 8-class version is 
generated.
The resulting variables are named oesch8_{it:newvarname}, oesch5_{it:newvarname} respectively.

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
  {help isko}, {help isco}
{p_end}

