{smcl}
{hline}
help for {hi:anythingtodate}
{hline}

{title:Convert all types of date variables to Stata date variables}

{p 4 8 2}
{cmdab:anythingtodate}
{it:varlist}
[{cmd:,}
  {opt Keepvarlists}
  {opt Format(string asis)}
  {opt Reference(integer 19000000)}
]       

{title:Description}

{pstd}

The command {cmd:anythingtodate} converts date variables entered as strings or long number to Stata date variables. Change dates recognized as numbers in Stata to date format.

{title:Options}

{phang}
{opt Keepvarlists} If you don't want to rewrite the original variables, it is an option to copy and save the original variables.

{phang}
{Format(string asis)} By specifying the date format here, you can specify the display format after conversion of the Stata dates.

{phang}
{opt Reference(integer 19000000)} The default is 19000000, but this number can be changed. If the variable has a number that is greater than the specified number, this date variable is considered to be displayed as a long number.

{title:Examples}
    Set up
    {inp: . clear all}
    Enter various types of data data into Stata
    {inp: . input str8 typestr long typelnum noformatdate}
    {inp: 1. "20170101" 20170101 20820}
    {inp: 2. "20180320" 20180320 21263}
    {inp: 3. "20200202" 20200202 21947}
    {inp: 4. end}

{inp: list}
{inp: des}
{inp: anythingtodate typestr typelnum noformatdate, k}

{inp: list}
{inp: des}

{inp: anythingtodate typestr_original, f(%tdMonth_nn,_CCYY)}
{inp: list}
{inp: des}

{title:Author}

{p 4 4 2}
Nobuaki Michihata, Department of Health Services Research, Graduate School of Medicine

{p 4 4 2}
The University of Tokyo

{p 4 4 2}
Please email {browse "mailto:gha10771+stata@gmail.com":gha10771+stata@gmail.com} if you encounter problems with this program

