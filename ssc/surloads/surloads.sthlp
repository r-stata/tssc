{smcl}
{* *! version 0.2.0  25.02.2014}{...}
{cmd:help surloads}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi:[R] surloads} {hline 2}} Surloads - Calculation of simple scores
{p2colreset}{...}


{title:Syntax for surloads}

{p 8 16 2}
{cmd:surloads} {stub*|{help newvarlist}}


{title:Description}

{pstd}
{cmd:surloads} The program provides an alternative to calculating factor scores by the regression or Bartlett's method 
 if the researcher is not interested in the uniqueness factor of a variable.
 Given the rotated loading matrix of a factor analysis, the surloads calculates simple scores and saves them as variables.
 For each factor, the respective simple score is calculated as the sum of the products between a variable and its corresponding 
 loading on the factor. 

{title:Options}


{title:Examples}

{phang}{title: Factor analysis on auto data with varimax rotation}

{phang}{cmd:. webuse auto}

{phang}{cmd:. factor  price rep78 weight turn displacement gear_ratio}

{phang}{cmd:. rotate}

{phang}{cmd:. surloads score1-score2}

Surload requires rotated loadings
Factor 1 generated - saved in score1.
Factor 2 generated - saved in score2.


{title:Author}

{phang}{browse "http://www.hwwi.org/en/about-us/team/research-team-member/malte-hoffmann/short-description.html":Malte Hoffmann}, Hamburgisches WeltWirtschaftsInstitut & University of Kiel, hoffmann@hwwi.org

{title:Version}

{phang}This is version 0.2 released Jan 25, 2014.
