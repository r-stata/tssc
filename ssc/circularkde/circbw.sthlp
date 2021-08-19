{smcl}
{* *! v1.0.0 IHSalgado-Ugarte 04July2012}{...}
{cmd:help circbw}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:circbw} {hline 2}}Calculate bandwidth selection rules for circular data{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:circbw} varname {ifin} [, kc(kernelcode)]


{title:Description}

{pstd}{cmd:circbw} calculates several data-based bandwidth rules for circular variables(with azimuthal scale from 0 to 360 degrees) density estimation and reports the results in a table.{break}
It gives the rule of thumb for von Mises kernel, the Fisher rule for quartic kernel and adapted (using circular deviation) rules (oversmoothed and two optimal) for linear (Euclidean) data (as a reference). 
It is possible to choose the kernel function, Quartic (Biweight) default. With duplicated orientation data it is necessary to employ only one half.

{title:Options}

{phang} {opt kc(kernelcode)}               set kernel (weight) function according to the following numerical codes; default is 4, Quartic(Biweight):{break}
1 = Uniform{break}
2 = Triangle{break}
3 = Epanechnikov{break}
4 = Quartic (Biweight){break}
5 = Triweight{break}
6 = Gaussian{break}
7 = Cosine{break}

{title:Remarks}

{pstd}{cmd:circbw} uses the supporting utilities {cmd:i0kappa}, {cmd:i1kappa} and {cmd:i2kappa} written by Cox (2004). They are required to do the calculations.

{title:Examples}

{phang}{stata "use circdat" : . use circdat}{p_end}
{phang}{stata "circbw angles" : . circbw angles}{p_end}
{phang}{stata "circbw angles, k(6)" : . circbw angles, k(6)}{p_end}
{phang}{stata "use fisherfeldes2" : . use fisherfeldes2}{p_end}
{phang}{stata "circbw laoriefeld if half==1" : . circbw laoriefeld if half==1}{p_end}

{title:Authors}

{phang}Isaías H. Salgado-Ugarte,
Laboratorio de Biometría y Biología Pesquera, FES Zaragoza, UNAM; 
Departamento de Biología UAM Iztapalapa{break}
ihsalgadougarte@gmail.com{break}{p_end}

{phang}Verónica Mitsui Saito-Quezada
Laboratorio de Biometría y Biología Pesquera, FES Zaragoza, UNAM.{break}
mitsuisaito@gmail.com{break}{p_end}

{phang}Marco A. Pérez-Hernández,
Departamento de Biología, UAM Iztapalapa.{break}
maph@xanum.uam.mx{break}{p_end}


{title:References}

{phang}Cox, N.J. 2004. Circular statistics in Stata, revisited. Proceedings of the 10th UK Users Group Meeting, London, UK: 4 p.{p_end}
{phang}Fisher, N.I. 1993. Statistical analysis of circular data. Cambridge University Press, Cambridge, 296p.{p_end}
{phang}Oliveira, M., R.M. Crujeiras and A. Rodríguez-Casal 2012. A plug-in rule for bandwidth selection in circular density estimation. Computational Statistics and Data Analysis 56(2012):3898-3908.{p_end}
{phang}Salgado-Ugarte, I.H. & M.A. Pérez-Hernández 2017. Estimación de densidad por núcleo (kernel) para datos circulares. In: Rodríguez-Yam, G.A., F.J. Araiza-Hernández, B.R. Pérez-Salvador & F. Ulín-Montejo (eds.). Aportaciones                 Recientes a la Estadística en Mexico. INEGI, Mexico: 518-526. ISBN: 978-607-530-067-2. {p_end}
{phang}Salgado-Ugarte, I.H., M. Shimizu & T. Taniuchi 1995. Practical rules for bandwidth selection in univariate density estimation. Stata Technical Bulletin, 27: 5-19.{p_end}
{phang}Taylor, C.C. 2008. Automatic bandwidth selection for circular density estimation. Computational Statistics and Data Analysis 52(7): 3493-3500.{p_end}

{title:Also see}

{psee}
Manual: {manhelp kdensity R}
{psee}
Online: {hi:Help} for {help circkden}, {help cirkdevm}, {help circnpde} 

