{smcl}
{* *! v1.0.0 IHSalgado-Ugarte 04July2012}{...}
{cmd:help circkde}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:circkde} {hline 2}}Performs kernel density estimation for circular data{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:circkde} varname {ifin} [, kc(kernelcode) h(#) genpdf(pdfvar) gendeg(degvar) graph_options]


{title:Description}

{pstd}{cmd:circkde} calculates kernel density estimation for circular variables with azimutal scale (0 to 360 degrees) by means of a discretized procedure (Cox, 1998) and draws the result.{break}
It is possible to choose the kernel function and to specify the smoothing parameter (half-width). Additionally it provides modality (and anti-modality) information.

{title:Options}

{phang} {opt kc(kernelcode)}               set kernel (weight) function according to the following numerical codes (default is 6, Gaussian):{break}
1 = Uniform{break}
2 = Triangle{break}
3 = Epanechnikov{break}
4 = Quartic (Biweight){break}
5 = Triweight{break}
6 = Gaussian{break}
7 = Cosine{break}

{phang}{opt h(#)} is the smoothness parameter (half-width) in degrees. The default is 30.{p_end}

{phang}{opt numodes} display the number of modes (maxima) in the density estimation.{p_end}

{phang}{opt modes} lists the estimated values for each mode. The numodes option must
     be included first.{p_end}

{phang}{opt nuamodes} display the number of antimodes (minima) in the density estimation.{p_end}

{phang}{opt amodes} lists the estimated values for each antimode. The nuamodes option must
     be included first.{p_end}

{phang}{opt genpdf(pdfvar)} specifies the name of a new variable in which probability density estimates are to be stored.

{phang}{opt gendeg(degvar)} specifies the name of a new variable in which equally spaced angles are to be stored.

{phang}{opt graph_options} are any of the options allowed with graph, twoway; see help for graph.{p_end}


{title:Examples}

{phang}{stata "use circdat" : . use circdat}{p_end}
{phang}{stata "circkde angles" : . circkde angles}{p_end}
{phang}{stata "circbw angles, k(4)" : . circbw angles, k(4)}{p_end}
{phang}{stata "circkde angles, h(38) k(4) numodes modes" : . circkde angles, h(38) k(4) numodes modes}{p_end}
{phang}{stata "circkde angles, h(14.5) nuamodes amodes genpdf(density) gendeg(deg)" : . circkde angles, h(14.5) nuamodes amodes genpdf(density) gendeg(deg)}{p_end}

{title:Authors}

{phang}Isaías H. Salgado-Ugarte,
Laboratorio de Biometría y Biología Pesquera, FES Zaragoza, UNAM; 
Departamento de Biología UAM Iztapalapa{break}
ihsalgadougarte@gmail.com{break}{p_end}


{title:References}

{phang}Cox, N.J. 1998. Circular statistics in Stata. 3rd UK User Group meeting. June 5, 1997. London.{p_end}
{phang}Fisher, N.I. 1993. Statistical analysis of circular data. Cambridge University Press, Cambridge, 296p.{p_end}
{phang}Salgado-Ugarte, I.H. & M.A. Pérez-Hernández, 2017. estimación de densidad por núcleo (kernel) para datos circulares. In: Rodríguez-Yam, G.A., F.J. Araiza-Hernández, B.R. Pérez-Salvador & F. Ulín-Montejo (eds.). Aportaciones                Recientes a la Estadística en México. INEGI, Mexico: 518-526. ISBN: 978-607-530-067-2.{p_end} 

{title:Also see}

{psee}
Online: {manhelp kdensity R}
{psee}
{space 2}Help: {hi:Help} for {help circbw}, {help circnpde} 

