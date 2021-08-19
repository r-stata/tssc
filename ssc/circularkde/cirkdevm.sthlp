{smcl}
{* *! v1.0.3 IHSalgado-Ugarte 30March2013}{...}
{cmd:help cirkdevm}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:cirkdevm} {hline 2}}Performs kernel density estimation for circular data with the von Mises weight function{p_end}
{p2colreset}{...}

{title:Syntax}

{p 5 14 2}
{cmd:cirkdevm} varname {ifin} [,{opt nu}(#) {opt np}oints(#) {opt numo}des {break}
 {opt mo}des {opt nuamo}des {opt amo}des {opt nog}raph {opt circg}ph {opt r}val(#) {opt f}r(#) {opt g}s(#) {break}
 {opt gen}(pdfvar degvar) {it:scatter_options}]


{title:Description}

{pstd}{cmd:cirkdevm} calculates kernel density estimation for circular variables with azimutal scale (0 to 360 degrees) by means of a discretized procedure (Cox, 1998) and draws the result.{break}
It uses the von Mises kernel function and it is possible to specify the smoothing parameter (nu), the number of estimation points (at least _N) and to employ a linear (default) or a circular graph.{break}
Additionally it provides modality (and anti-modality) information.

{title:Options}

{phang}{opt nu(#)} is the concentration parameter (nu) analog to h (smoothing parameter) in degrees but with inverse behaviour (large values produce noisy results and viceversa). The default is 30.{p_end}

{phang}{opt npoints(#)} specifies the number of equally spaced points in the range of the circular variable. At least must be equal to the number of observations (Default).{p_end}

{phang}{opt numodes} displays the number of modes (maxima) in the density estimation.{p_end}

{phang}{opt modes} lists the estimated values for each mode. The numodes option must
     be included first.{p_end}

{phang}{opt nuamodes} displays the number of antimodes (minima) in the density estimation.{p_end}

{phang}{opt amodes} lists the estimated values for each antimode. The nuamodes option must
     be included first.{p_end}

{phang}{opt circgph} draws a circular graph

{phang} Options with circgph

{phang}{opt rval} is a factor controlling the radius size of the circle used

{phang}{opt frval} is a factor applied to the density values in the cosine and sine transformation. It permits to stretch or compress the density values arround the unit circle.

{phang}{opt gsval} is a factor controlling the size of the graph. Large values give small graphics while less than unity figures produce bigger circle graphs.

{phang}Defaults are 1 in all the cases. It is possible for the graphs to depart from circle by using other values. This can be corrected by using the right combination (see last two examples below).

{phang}{opt gen(denvar degvar)} specifies the name of the new variables in which probability density estimates (denvar) and the equally spaced angles (degvar) are to be stored.

{phang}{opt graph_options} are any of the options allowed with twoway scatter; see help for graph.{p_end}

{phang}{opt nograph} suppresses the graph drawing


{title:Examples}

{phang}{stata "use circdat" : . use circdat}{p_end}
{phang}{stata "cirkdevm angles" : . cirkdevm angles}{p_end}
{phang}{stata "circbw angles" : . circbw angles}{p_end}
{phang}{stata "cirkdevm angles, h(11.27) numodes modes" : . cirkdevm angles, h(11.27) numodes modes}{p_end}
{phang}{stata "cirkdevm angles, h(23) nuamodes amodes gen(density deg)" : . cirkdevm angles, h(23) nuamodes amodes gen(density deg)}{p_end}
{phang}{stata "cirkdevm angles, circgph r(1) fr(1) gs(.1)" : . cirkdevm angles, circgph r(1) fr(1) gs(.1)}{p_end}
{phang}{stata "cirkdevm angles, circgph r(.5) fr(1) gs(.1)" : . cirkdevm angles, circgph r(.5) fr(1) gs(.1)}{p_end}


{title:Authors}

{phang}Isaías H. Salgado-Ugarte,
Laboratorio de Biometría y Biología Pesquera, FES Zaragoza, UNAM; 
Departamento de Biología UAM Iztapalapa{break}
ihsalgadougarte@gmail.com{break}{p_end}

{phang}Verónica Mitsui Saito-Quezada
Laboratorio de Biometría y Biología Pesquera, FES Zaragoza, UNAM.{break}
mitsuisaito@gmail.com{break}{p_end}

{phang}Marco Aurelio Pérez-Hernández, Departamento de Biología;
Universidad Autónoma Metropolitana Iztapalapa, México.{break}
maph@xanum.uam.mx{p_end}

{title:References}

{phang}Cox, N.J. 1997. Circular statistics in Stata. 3rd UK User Group meeting. June 5, 1997. London.{p_end}
{phang}Fisher, N.I. 1993. Statistical analysis of circular data. Cambridge University Press, Cambridge, 296p.{p_end}
{phang}Salgado-Ugarte, I.H. & M.A. Pérez-Hernández, 2017. estimación de densidad por núcleo (kernel) para datos circulares. In: Rodríguez-Yam, G.A., F.J. Araiza-Hernández, B.R. Pérez-Salvador & F. Ulín-Montejo (eds.). Aportaciones                 Recientes a la Estadística en México. INEGI, Mexico: 518-526. ISBN: 978-607-530-067-2.{p_end} 

{title:Also see}

{psee}
Manual: {manhelp kdensity R}
{psee}
Online: {hi:Help} for {help circbw}, {help circkden}, {help cirkdevm}, {help circgph}, {help circnpde} 

