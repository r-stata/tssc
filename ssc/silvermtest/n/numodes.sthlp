{smcl}
{* *! version 1.0.0 06/08/2020}{...}
{hline}
{cmd:help numodes}                                                 [STB-38; snp13]
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:numodes} {hline 2}} Counting and estimation of modes in density/frequency data (Updated version){p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmd:numodes} {denvar midvar} {ifin} [{cmd:,} {cmdab:mo:des(}{it:#}{cmd:)}]

{title:Description}

{pstd}{cmd:numodes} calculates the number of modes in a density estimation or a
frequency distribution and, if especified, lists their estimated values. The user
must include the variable with the density or frequency values (denvar) and the
corresponding midpoints (midvar). Useful for histogram or kernel density 
estimation modes determination.

{title:Options}

{phang}{opt {hi:mo}des} lists the estimated values for each mode.


{title:Examples}
  
{phang}{stata "use bufsnow" :. use bufsnow}{p_end}

{pstd}With no data in memory

{phang}{stata "bandw1 snow" :. bandw1 snow}{p_end}

{pstd}To obtain the kde bandwidth rules as a guide

{phang}{stata "warpdenm1 snow, b(5) m(10) k(6) gen(den5 mid5)" :. warpdenm1 snow, b(5) m(10) k(6) gen(den5 mid5)}{p_end}

{pstd}Generating density and midpoint values with aprox. 1/2 of "optimal" Gaussian bw

{phang}{stata "numodes den5 mid5, modes" :. numodes den5 mid5, modes}{p_end}

{pstd}Will display the number of modes and their estimated values


{title:References}

   Haerdle, W. (1991) Smoothing Techniques with Implementation in S.
        Springer-Verlag Chapter 2: 43-84; Chapters 1-2: 1-84.
   Salgado-Ugarte, I.H., M. Shimizu, and T. Taniuchi (1993) snp6: Exploring
        the shape of univariate data using kernel density estimators. Stata 
        Technical Bulletin 16: 8-19.
   Salgado-Ugarte, I.H., M. Shimizu, and T. Taniuchi (1995) snp6.1: ASH,
        WARPing, and kernel density estimation for univariate data. Stata
        Technical Bulletin 26: 23-31.
   Salgado-Ugarte, I.H., M. Shimizu, and T. Taniuchi (1995) snp6.2: Practical
        Rules for bandwidth selection in univariate density estimation. Stata
        Technical Bulletin 27: 5-19.
   Salgado-Ugarte, I.H., M. Shimizu, and T. Taniuchi (1997) snp13: 
        Nonparametric assessment of multimodality for univariate data. Stata
        Technical Bulletin 38: 27-35.
   Scott, D.W. (1992) Multivariate Density Estimation: Theory, Practice,
        and Visualization. John Wiley, New York, USA: 317 p.
   Scott, D.W. (2015) Multivariate Density Estimation: Theory, Practice, and
        Visualization. 2nd. ed. John Wiley, Hoboken, NJ, USA: 350 p.
   Silverman, B.W. (1986) Density Estimation for Statistics and Data 
        Analysis. Chapman and Hall.


{title:Authors}

Original version:
Isaias H. Salgado-Ugarte, Makoto Shimizu and Toru Taniuchi
University of Tokyo, Faculty of Agriculture,
Department of Fisheries, Yayoi 1-1-1, Bunkyo-ku
Tokyo 113, Japan.(Fax 81-3-3812-0529)
Updated version:
Isaías H. Salgado-Ugarte & V. Mitsui Saito-Quezada
Laboratorio de Biometría y Biología Pesquera
Facultad de Estudios Superiores Zaragoza
Universidad Nacional Autónoma de México
isalgado@unam.mx

{title:Also see}

{psee}
    STB: snp6 (STB-16); snp6.1 (STB-26); snp6.2 (STB-27), snp13 (STB-38)
{phang}On-line: {hi:help} for {help warpdenm1}, {help kerneld}, {help bandw1}, {help l2cvwarpy}, {help bcvwarpy}, {help nuamodes}
{p_end}