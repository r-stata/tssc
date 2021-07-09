{smcl}
{* *! version 0.1.0  13.01.2014}{...}
{cmd:help surrog}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi:[R] surrog} {hline 2}}Surrogate Variables
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:surrog}



{title:Description}

{pstd}
{cmd:surrog} From the rotated loading matrix the program picks for each factor the surrogate variable, i.e. the variable with the highest absolute loading on the factor and displays the names of the selected variables afterwards. The program simplifys work and reduces errors if one for instance works with many variables or resulting factors.
Another use is given if one runs several factor analyses over comlumns of imputed data and wants check whether the set of same surrogate variables is chosen for each imputation. Please note that the program hitherto only works with rotated matrices. Although I guess that it's rarely done otherwise I might extent the program some day.


{title:Options}


{title:Examples}

{phang}{title: Factor analysis on auto data with varimax rotation}

{phang}{cmd:. webuse auto}

{phang}{cmd:. factor  price rep78 weight turn displacement gear_ratio}

{phang}{cmd:. rotate}

{phang}{cmd:. surrog}

{title:Author}

{phang}{browse "http://www.hwwi.org/en/about-us/team/research-team-member/malte-hoffmann/short-description.html":Malte Hoffmann}, Hamburgisches WeltWirtschaftsInstitut & University of Kiel, hoffmann@hwwi.org

{title:Version}

{phang}This is version 0.3 released Jan 19, 2014.
