{smcl}
{hline}
help for {hi:slist}
{hline}

{title:Smart listing of variables}

{p 8 15}
{cmd:slist} [{it:varlist}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
[{cmd:,} 
    {cmdab:d:ecimal(}{it:number}{cmd:)}
    {cmdab:i:d(}{it:varlist}{cmd:)}
    {cmdab:noo:bs}
    {cmdab:l:abel}]

{p}{hi:by ...:} may {hi:not} be used with {hi:slist}.

{p}{it:varlist} may contain any variable types; see help {help varlist}.


{title:Description}

{p}
{cmd:slist} displays compact lists fitting the current width of the Results window. 
If more than one line is needed, a new block of variables is created.
The current version 3.0 is Unicode-aware.
It has been tested with Stata version 11 and version 16.


{title:Options}

{p 0 4}
{cmd:decimal(}{it:number}{cmd:)} lets you select the number of decimals for floating point
numbers. If omitted, {cmd:slist} uses general format.

{p 0 4}
{cmd:id(}{it:varlist}{cmd:)} ensures that one or more id variables are displayed at the
beginning of each line.

{p 0 4}
{cmd:noobs} omits observation numbers. Frequently used in combination with
{cmd:id(}{it:varlist}{cmd:)}.

{p 0 4}
{cmd:label} lists value labels instead of numerical codes for variables having value
labels. Value labels ar omitted by default.


{title:Remarks}

{p}
The {help list} command is clumsy in displaying lists with more than a few variables.
{cmd:slist} displays compact lists with numeric codes, value labels being shown 
only when explicitly requested. 

{p}
{cmd:slist} compresses the data in memory and finds the most economic formats. This may
take some time with large uncompressed data sets, and it is recommended to keep your
data in compressed form, for this and other reasons; see {help compress}.


{title:Examples}

     {inp:. slist}
     {inp:. slist v1-v27}
     {inp:. slist , decimal(2)}
     {inp:. slist v1-v27 in 1/20 if sex == 1}
     {inp:. slist v1-v27 , noobs id(idno)}
     {inp:. slist , label} 

{inp:. slist in 3/4 , d(2) id(idno)}

     idno  sex  age  wt   ht  smoke  cigaret  cheroot  pipe  agegr
  3.    7    1   49  85  190      1       10        2     0      2
  4.   11    2   71  85  166      2        0        0     0      3

     idno  tobacco    bmi  bmigr
  3.    7       14  23.55     20
  4.   11        0  30.85     30


{title:Authors}
{browse "mailto:sj@ph.au.dk":Svend Juul}, Department of Public Health, Aarhus University, Denmark.
(A prior version (2003) was co-authored by Jens M. Lauritsen and John Luke Gallup)
