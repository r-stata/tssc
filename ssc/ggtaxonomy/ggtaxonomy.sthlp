{smcl}
{* *! version 0.96 14sep2017}{...}
{cmd:help ggtaxonomy}
{hline}

{title:Title}

{phang}
{bf:ggtaxonomy} {hline 2} Command for identifying your most suitable GG family model


{title:Syntax}

{p 8 17 2}
{cmd:ggtaxonomy}

{phang} {cmd:ggtaxonomy} is a postestimation command, see {manhelp postestimation_commands D} for help.


{title:Description}

{pstd}{cmd:ggtaxonomy} creates a graph for an easy interpretation of the shape and scale parameters of a
parametric survival regression with gamma distribution (see {manhelp streg D}).

{pstd}
When {cmd:ggtaxonomy} is ran after {bf:streg {it:varlist}, distribution(gamma)} it takes the shape and scale
parameters of the model and plots them with their corresponding confidence ellipse
in the taxonomic map of hazard functions for the generalized gamma (GG) distribution (Cox, Schneider and Mu�oz; 2007).
Each point in the map represents a different possible hazard function of the GG family.

{pstd}Reference lines are traced for the nested hazard functions of the GG family.
Ammag and Gamma reference lines divide the half-plane in four regions:

{phang}- Above Ammag and above Gamma (12 o'clock) the hazard function is bathtub-shaped.{p_end}
{phang}- Above Ammag and under Gamma (3 o'clock) the hazard function is decreasing.{p_end}
{phang}- Under Ammag and under Gamma (6 o'clock) the hazard function is arc-shaped.{p_end}
{phang}- Under Ammag and above Gamma (9 o'clock) the hazard function is increasing.{p_end}

{pstd}From the graph it can be easily ascertained which member of the GG familiy suits most:

{phang}- The model is GG if the confidence ellipse does not cross any reference line.{p_end}
{phang}- The model is standard Gamma, inverse Gamma, Ammag of inverse Ammag if the confidence ellipse crosses with their respective reference lines{p_end}
{phang}- The model is Weibull or inverse Weibull if  the (vertical axis of the) confidence ellipse crosses with their respective reference lines{p_end}
{phang}- The model is Lognormal if the (vertical axis of the) confidence ellipse crosses the Lognormal reference line (shape==0){p_end}
{phang}- If the circle lies in the intersection of Gamma and Ammag, the model is exponential{p_end}

{pstd}As far as version 13.1, Stata can parametrize the Lognormal, Exponential and Weibull functions of the GG family,
as well as the generalized Gamma model itself.

{pstd}If no gamma model is run before {cmd:ggtaxonomy}, it ends with an error.


{title:Reference}

{pstd}
Cox C, Chu H, Schneider MF, Muñoz A. Parametric survival analysis and taxonomy of hazard functions for the generalized gamma distribution.
Statistics in medicine. 2007 Oct 15;26(23):4352-74.


{title:Examples}

    {bf:sysuse cancer}
    {bf:stset studytime, failure(died)}
    {bf:streg i.drug age, distribution(gamma)}
    {bf:ggtaxonomy}
    
    {bf:use http://www.stata-press.com/data/cggm3/hip2, clear}
    {bf:streg protect age, distribution(gamma)}
    {bf:ggtaxonomy}


{title:Acknowledgements}

{pstd}
This command is a tribute to Professor Alvaro Muñoz, in gratitude to his visit to Bogota.


{title:Authors}

{phang}Andres Gonzalez Rangel{p_end}
{phang}MD, MSc Clinical Epidemiology{p_end}
{phang}Instituto para la Evaluacion de la Calidad y Atencion en Salud - IECAS{p_end}
{phang}andres.gonzalez@iecas.org{p_end}

{phang}(Updated Version){p_end}
{phang}Usama Bilal{p_end}
{phang}MD, MPH, PhD{p_end}
{phang}Johns Hopkins Bloomberg School of Public Health{p_end}
{phang}ubilal@jhmi.edu{p_end}
