{smcl}
{* *! version 1.0.0 12/08/2020}{...}
{hline}
help for {hi:Silverman multimodality test} commands                              [STB-38: snp13]
{hline}

{title: Introduction}

The modality of a distribution is an important characteristic of numerical data.
This set of (updated) Stata programs allows to investigate the modality of a quantitative
variable by means of the Silverman (1981) smoothed bootstrap multimodality test.

{title:WARP Kernel Density Estimation}

{pstd}{help warpdenm1} estimates univariate density by means of the 
ASH-WARPing procedure (Scott, 1985, 1992, 2015; Härdle, 1991), draws the result
and provides modality information.

{title:Critical bandwidth search}

{pstd}{help critiband1} calculates the kde's and count the modes in order to
find the critical bandwidths in the specified range of bandwidths
for use with the Silverman multimodality smoothed bootstrap test. 
As in the previous {hi:silvtest.ado} program, to estimate the KDE it uses the WARPing 
procedure based on the algorithms described in Härdle (1991), Scott (1992; 2015),
Salgado-Ugarte & Saito-Quezada (2020). The program produces (optionally) density graphs and 
list in the {hi:Results} window the bandwidths with their corresponding number of modes 
in the specified bandwidths range. 

{title:Smoothed bootstrap samples generation}

{pstd}{help bootsamb} is used with Stata's {hi:boot} command to generate smoothed bootstrap
samples to be used by {cmd:silvtest1} to perform the multimodality test proposed by Silverman (1981). 

{title:Silverman multimodality test}

{pstd}{help silvtest1} estimates the significance of a specified number of modes in 
bootstrapped density estimates according to the procedure proposed by Silverman
(1981) as described in Izenman & Sommer (1988). 

{title:Additional utility programs}

{pstd}{help numodes} calculates the number of modes in a density estimation or a
frequency distribution and, if especified, lists their estimated values. The user
must include the variable with the density or frequency values (denvar) and the
corresponding midpoints (midvar). Useful for histogram or kernel density 
estimation modes determination.

{pstd}{help nuamodes} calculates the number of antimodes of a density estimation or a
frequency distribution and if especified lists their estimated values. The user
must include the variable with the density or frequency values (denvar) and the
corresponding midpoints (midvar). Useful for histogram or kernel density 
estimation antimodes determination.

{title:Authors}

{phang}Original versions:
Isaías Hazarmabeth Salgado-Ugarte, Makoto Shimizu and Toru Taniuchi
University of Tokyo, Faculty of Agriculture.{p_end}
{phang}Updated versions:
Isaías Hazarmabeth Salgado-Ugarte & Verónica Mitsui Saito-Quezada
Biometría y Biología Pesquera, FES Zaragoza UNAM
isalgado@unam.mx{p_end}

{title:Acknowledgements}

{pstd}To B. Silverman, D.W. Scott and W. Härdle, for having provided the basis for our algorithms.
