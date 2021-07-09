{smcl}
{* *! version 1.0.0 06/08/2020}{...}
{hline}
{cmd:help silvtes1}                                                 [STB-38; snp13]
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:silvtest1} {hline 2}} Silverman test of multimodality (Updated version){p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmd:silvtest1} {bootvar repindex} {ifin} {cmd:,} {cmdab:cr:itbw(}{it:#}{cmd:)}
{cmdab:m:val(}{it:#}{cmd:)}
{cmdab:nurf:in(}{it:#}{cmd:)}
{cmdab:cnm:odes(}{it:#}{cmd:)}
[{cmdab:nuri:ni(}{it:#}{cmd:)}
{cmdab:nog:raph}
{cmd:graph_options}]


{title:Description}

{pstd}{cmd:silvtest1} estimates the significance of a specified number of modes in 
bootstrapped density estimates according to the procedure proposed by Silverman
(1981) as described in Izenman & Sommer (1988). 

{title:Options}

{phang}{opt critbw}({it:#}) is the critical bandwidth for the number of modes to be tested.

{phang}{opt mval}({it:#}) is the number of averaged shifted histograms used to calculate the
    required density estimations.

{phang}{opt nurfin}({it:#}) permits to specify the final number of replication. 

{phang}{opt cnmodes}({it:#}) refers to the critical number of modes, that is the number of modes to
    be tested.

{phang}{opt nurini}({it:#}) permits to specify the initial number of replication to begin. The 
    default is 1.

{phang}{opt nograph} suppresses the graph drawing

{phang}{opt graph_options} are any of the options allowed with ^graph, twoway^.


{title:Remarks}

{hi:cr}itbw, {hi:m}val, {hi:nurf}in, and {hi:cnm}odes, are not optional. If the user does not
provide them, the program halts and displays an error message on screen.

This program calculates a density estimation with a Gaussian kernel using the 
specified critical bandwidth for each of the bootstrapped samples in memory,
draw the density estimations, counts the modes and displays the estimate of the
significance of the specified number of modes by calculating the fraction of
estimations with more modes than the number tested in the total of samples.

Sometimes, if the memory is limited it would be necessary to apply the 
procedure by repetition ranges. In this case the {hi:nuri}ni-{hi:nurf}in combination
would be useful.

The number of midpoints depends on {hi:m}val and the critical bandwidth. As {hi:m}val
increases and the {hi:cr}itbw decreases more midpoints are used. It is recommended
to use a dense number of points. An initial suggestion is to employ at leas {hi:m}val = 40.

The command by default draws the density estimation and reports in the results
window the actual sample and its corresponding number of modes. As a final step
it reports the Pvalue as the quotient of the number of estimations with more
modes than the number tested divided by the total number of replications used.

The programe must be applied sequentially to several number of modes.


{title:Examples}

  
{phang}{stata "silvtest ysm _rep, cr(25.26) m(30) nurf(50) cnm(1)" :. silvtest ysm _rep, cr(25.26) m(30) nurf(50) cnm(1)}{p_end}

{pstd}Will display 50 Gaussian kernel density estimations, a list of the number of 
modes for each replication and finally the significance for one mode (P-value)
including the numbers used for its calculation.

{phang}{stata "silvtest ysm _rep, cr(3.19) m(30) nurf(50) cnm(5) nog" :. silvtest ysm _rep, cr(3.19) m(30) nurf(50) cnm(5) nog}{p_end} 

{pstd}Will display a list of the number of modes for each of the 50 bootstrapped
samples and the P-value for 5 modes (with no graphs).

{phang}{stata "silvtest ysm _rep, cr(3.93) m(30) nuri(10) nurf(30) nog" :. silvtest ysm _rep, cr(3.93) m(30) nuri(10) nurf(30) nog}{p_end}

{pstd}Will display a list of the number of modes from sample 10 to sample 30; no graphs.

{title:References}

   Izenman, A.J., and C. Sommer (1988) Philatelic mixtures and multimodal 
        densities. Journal of the American Statistical Association, 83(404):
        941-953.
   Haerdle, W. (1991) Smoothing Techniques with Implementation in S.
        Springer-Verlag Chapter 2: 43-84; Chapters 1-2: 1-84.
   Salgado-Ugarte, I.H. (2002) Suavización no paramétrica para análisis de
        datos. DGAPA and FES Zaragoza, UNAM. Mexico. 139 p.   
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
        and Visualization. John Wiley Chapter 6: 125-143; Chapters 3-6: 47-193.
   Silverman, B.W. (1981) Using kernel density estimates to investigate
        multimodality. Journal of the Royal Statistical Society, B, 43: 97-99. 
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
{phang}On-line: {hi:help} for {help warpdenm1}, {help kerneld}, {help bandw1}, {help l2cvwarpy}, {help bcvwarpy}, {help numodes}
{p_end}