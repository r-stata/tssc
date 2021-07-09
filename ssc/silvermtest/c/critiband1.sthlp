{smcl}
{* *! version 1.0.0 24/jul2020}{...}
{hline}
{cmd:help critiband1}                                     [Salgado-Ugarte, I.H. 2002]
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:critiband1} {hline 2}} Critical bandwidth search for WARPing density estimation (Updated version){p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmd:critiband1} {varname} {ifin} {cmd:,} {cmdab:bwh:igh(}{it:#}{cmd:)}
{cmdab:bwl:ow(}{it:#}{cmd:)}
{cmdab:st:size(}{it:#}{cmd:)}
{cmdab:m:val(}{it:#}{cmd:)}
[{cmdab:nog:raph}
{cmd:graph_options}]

{title:Description}

{pstd}{cmd:critiband1} calculates the kde's and count the modes in order to
find the critical bandwidths in the specified range of bandwidths
for use with the Silverman multimodality smoothed bootstrapped test. 
As in the silvtest.ado program, to estimate the KDE it uses the WARPing 
procedure based on the algorithms described in Haerdle (1991), Scott (1992; 2016),
Salgado-Ugarte & Saito-Quezada (2020). The program produces a graph and a text 
in the Results window with the bandwidths and number of modes in the analyzed 
range.

{title:Options}


{phang}{opt bwhigh}({it:#}) is the high value for the range of smoother parameter h 
        (bandwidth for kernel density estimators).

{phang}{opt bwlow}({it:#}) is the low value for the range of smoother parameter h  

{phang}{opt stsize}({it:#}) specifies size of the step for the specified bandwidth range 

{phang}{opt mval}({it:#}) is the number of histograms to average for the kde estimation

{phang}{opt nograph} suppresses the graph drawing.

{phang}{opt graph_options} are any of the options allowed with {cmd:graph, twoway}
        except top label options.


{title:Remarks}


{hi:bwhigh}, {hi:bwlow}, {hi:stsize} and {hi:mval}, are not optional. If the user does not
provide them, the program halts and displays an error message on screen.

As the warpdenm.ado program, this program is an all Stata command. Due to the 
requirement of larger precision, a value of at least 40  for the number of histograms
to average ({opt mval) is necessary.

The kde graphics display the effect of varying the bandwidth: "smooth" results 
being gradualy becoming noisy estimations, with the corresponding increment in 
the number of modes.

Because this program is intended to use in combination with the silvtest.ado 
program (Silverman's multimodality smoothed bootstrap test) only the Gaussian 
kernel is implemented.

The number of KDEs calculated is round(({hi:bwhigh} - {hi:bwlow})/{hi:stsize}) + 1. If this 
number is large, it is recommended to divide the total range of interest in several 
shorter intervals in order to fit the size of the Results window.

This procedure permit to observe the gradual increment of the modes and to 
locate the last bandwidth value compatible with a given number of modes.
The graphics give and animated presentation of the increasing number of 
modes with the bandwidth decreasing, procedure very instructive and 
recommended by Izenman and Sommer (1988).

{title:Examples}

{phang}{stata "use silica" :. use silica}{p_end}
  
{phang}{stata "critiband1 silica, bwhigh(2.5) bwlow(.5) stsize(0.01) mval(40)" :. critiband1 silica, bwhigh(2.5) bwlow(.5) stsize(0.01) mval(40)}{p_end} 

{pstd}Will display the KDEs for {hi:silica} using bandwidths from 2.5 to 0.5 in steps 
of 0.01 and a text report of the bandwidths and the corresponding number of 
modes

{phang}{stata "critiband1 silica, bwh(2.5) bwl(.5) st(.01) m(40) nog" :. critiband1 silica, bwh(2.5) bwl(.5) st(.01) m(40) nog}{p_end}

{pstd}Will display only the text of bandwidth and number of modes on the "Results" 
window for the {hi:silica} variable.



{title:References}

   Haerdle, W. (1991) Smoothing Techniques with Implementation in S.
        Springer-Verlag Chapter 2: 43-84; Chapters 1-2: 1-84.
   Izenman, A.J. and C. Sommer (1988) Philatelic mixtures and multimodal 
        densities. Journal of the American Statistical Association,
        83(404): 941-953.
   Salgado-Ugarte, I.H. (2002) Suavización no paramétrica para análisis de
        datos. DGAPA and FES Zaragoza, UNAM. Mexico. 139 p.
   Salgado-Ugarte, I.H., M. Shimizu, and T. Taniuchi (1993) snp6: Exploring
        the shape of univariate data using kernel density estimators. Stata 
        Technical Bulletin 16: 8-19.
   Salgado-Ugarte, I.H., M. Shimizu, and T. Taniuchi (1995a) snp6.1: ASH,
        WARPing, and kernel density estimation for univariate data. Stata
        Technical Bulletin 26: 23-31.
   Salgado-Ugarte, I.H., M. Shimizu, and T. Taniuchi (1995b) snp6.2: Practical
        Rules for bandwidth selection in univariate density estimation. Stata
        Technical Bulletin 27: 5-19.
   Salgado-Ugarte, I.H., M. Shimizu, and T. Taniuchi (1997) snp13: 
        Nonparametric assessment of multimodality for univariate data. Stata
        Technical Bulletin 38: 27-35.
   Scott, D.W. (1992) Multivariate Density Estimation: Theory, Practice,
        and Visualization. John Wiley, Chapter 9: 256-257.
   Scott, D.W. (2016) Multivariate Density Estimation: Theory, Practice, and
        Visualization. 2nd. ed. John Wiley, Hoboken, NJ, USA: Chapter 9: 275-276
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
    STB: snp6 (STB-16); snp6.1 (STB-26); snp6.2 (STB-27); snp6.4 (STB-38)
{phang}On-line: {hi:help} for {help warpdenm1}, {help kerneld}, {help bandw1}, {help l2cvwarpy}, {help bcvwarpy}, {help kernrpy}, {help numode}
{p_end}