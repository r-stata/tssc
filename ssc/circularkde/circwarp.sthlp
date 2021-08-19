{smcl}
{* *! v1.0.3 IHSalgado-Ugarte 26March2016}{...}
{cmd:help for circwarp}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:circwarp} {hline 2}}Performs ASH-WARP kernel density estimation for circular data{p_end}
{p2colreset}{...}

{title:Syntax}

{p 5 14 2}
{cmd:circwarp} varname {ifin} [, {opt h}width(#) {opt m}val(number of averaged shifted histograms) {opt k}ercode(#) {op gt}ype(#) {break}
 {opt numo}des {opt mo}des {opt nuamo}des {opt amo}des {opt nog}raph {opt circg}ph {opt r}val(#) {opt f}r(#) {opt g}s(#) {break}
 {opt gen}(denvar degvar) {it:scatter_options}]


{title:Description}

{pstd}{cmd:circwarp} calculates kernel density estimators for circular variables with azimutal scale (0 to 360 degrees) by means of the ASH-WARPing procedure (Scott, 1985, 1992; Haerdle, 1991; Salgado-Ugarte, et al. 1995) and draws the result.
It is possible to choose the kernel function, to specify the smoothing parameter (half-width), the number of averaged histograms (10 suggested) and to employ a linear (default) or a circular graph. 
Additionally it provides modality (and anti-modality) information. It saves significative calculation time with big data sets. {break}

{title:Options}

{phang}{opt h}width(#) is the smoothness parameter (half-width) in degrees. The default is 30.{p_end}

{phang}{opt m}val(#) specifies the number of averaged shifted histograms used to calculate the density estimations. A number of 10 (default) is suggested.{p_end}

{phang} {opt k}ercode(#)               set kernel (weight) function according to the following numerical codes (default is 4):{break}
1 = Uniform{break}
2 = Triangle{break}
3 = Epanechnikov{break}
4 = Quartic (Biweight){break}
5 = Triweight{break}
6 = Gaussian{break}

{phang}{opt gt}ype permits to chose the resulting graphical display according to the following numerical codes (defalut is 1):{break}
1 = Polygon{break}
2 = Step (histogram like){break}
3 = Circular{break}

{phang}{opt numo}des displays the number of modes (maxima) in the density estimation.{p_end}

{phang}{opt mo}des lists the estimated values for each mode. The numodes option must
     be included first.{p_end}

{phang}{opt nuamo}des displays the number of antimodes (minima) in the density estimation.{p_end}

{phang}{opt amo}des lists the estimated values for each antimode. The nuamodes option must
     be included first.{p_end}

{phang}{opt nog}raph(nograph) suppresses the graph drawing.{p_end}

{phang}{opt gen(denvar degvar)} specifies the name of the new variables in which probability density estimates (denvar) and the equally spaced angles (degvar) are to be stored.{p_end}

{phang}{opt graph_options} are any of the options allowed with graph, twoway; see help for graph.{p_end}

{phang} Options for graph type 3 (circular){p_end}

{phang}{opt r}val is a factor controlling the radius size of the circle used.{p_end}

{phang}{opt fr}val is a factor applied to the density values in the cosine and sine transformation. It permits to stretch or compress the density values arround the circle.{p_end}

{phang}{opt gs}val is a factor controlling the size of the graph. Large values give small graphics while less than unity figures produce bigger circular graphs.{p_end}

{phang}{Defaults are 1 in all cases. It is possible for the graphs to depart from circle by using other values. This can be corrected by using the right combination.{p_end}


{title:Examples}

{phang}{stata "use meteorofeszcor6" : . use meteorofeszcor6}{p_end}
{phang}{stata "circkden wnd if dias>334 & dias < 366" : . circkden wnd if dias>334 & dias < 366}{p_end}
{phang}{stata "circbw wnd if dias>334 & dias < 366" : . circbw wnd if dias>334 & dias < 366}{p_end}
{phang}{stata "circwarp wnd if dias>334 & dias < 366, h(18) m(10) k(4) numodes modes" : . circwarp wnd if dias>334 & dias < 366, h(18) m(10) k(4) numodes modes}{p_end}
{phang}{stata "circwarp wnd if dias>334 & dias < 366, h(18) m(5) k(3) gt(2)" : . circwarp wnd if dias>334 & dias < 366, h(18) m(10) k(3) gt(2)}{p_end}
{phang}{stata "circwarp wnd if dias>334 & dias < 366, h(18) m(10) k(4) numodes modes gt(3)" : . circwarp wnd if dias>334 & dias < 366, h(38) m(10) k(4) numodes modes gt(3)}{p_end}
{phang}{stata "circwarp wnd if dias>334 & dias < 366, h(18) nuamodes amodes gen(density deg)" : . circwarp wnd if dias>334 & dias < 366, h(14.5) nuamodes amodes gen(density deg)}{p_end}

{title:Authors}

{phang}Isaías Hazarmabeth Salgado-Ugarte,
Laboratorio de Biometría y Biología Pesquera, FES Zaragoza, UNAM.{break}
isalgado@unam.mx{break}{p_end}

{phang}Verónica Mitsui Saito-Quezada
Laboratorio de Biometría y Biología Pesquera, FES Zaragoza, UNAM.{break}
mitsuisaito@gmail.com{break}{p_end}

{phang}Marco A. Pérez-Hernández,
Departamento de Biología, UAM Iztapalapa.{break}
maph@xanum.uam.mx{break}{p_end}

{title:References}

{phang}Cox, N.J. 1998. Circular statistics in Stata. 3rd UK User Group meeting. June 5, 1997. London.{p_end}
{phang}Fisher, N.I. 1993. Statistical analysis of circular data. Cambridge University Press, Cambridge, 296p.{p_end}
{phang}Härdle, W. 1991. Smoothing Techniques with Implementation in S. Springer-Verlag.{p_end}
{phang}Salgado-Ugarte, I.H., V.M. Saito-Quezada & M.A. Pérez-Hernández, 2018. Averaged shifted histograms (ASH) or Weighted Averaging of Rounded Points (WARP), Efficient Methods to Calculate Kernel Density Estimators for Circular Data. Memorias del      del XXXI Foro Internacional de Estadística y del XXXII Foro Nacional de Estadística. Asociación Mexicana de Estadística, INEGI, Mexico: 89-96.{p_end}
{phang}Salgado-Ugarte, I.H., M. Shimizu & T. Taniuchi, 1995. ASH, WARPing, and kernel density estimation for univariate data. Stata Technical Bulletin 26: 23-31.{p_end}
{phang}Scott, D.W. 1985. Averaged shifted histograms: effective nonparametric density estimators in several dimensions. Annals of Statistics, 13: 1024-1040.{p_end}
{phang}Scott, D.W. 1992. Multivariate Density Estimation: Theory, Practice and Visualization. John Wiley.{p_end}

{title:Also see}

{psee}
Manual: {manhelp kdensity R}
{psee}
Online: {hi:Help} for {help circbw}, {help circkden}, {help cirkdevm}, {help circgph}, {help circnpde} 

