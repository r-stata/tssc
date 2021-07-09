{smcl}
{* 11-03-2014}{...}
{cmd:help rocmic}  {right:Version 2.0 11-03-2014}

{hline}

{title:Title}

{p2colset 5 13 13 2}{...}
{p2col:{hi:rocmic} {hline 2}}Calculates the minimally important change (MIC) thresholds from continuous outcomes using ROC curves and an external reference criterion. {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:rocmic}
{it:refvar classvar, scale(minimum scale unit) [fast]}

{title:Descriptions}


{phang} {cmd:rocmic} estimates minimally important change (MIC) thresholds using three different methods. The first is the cut-point corresponding to a 45 degree tangent line intersection; this is mathematically equivalent to the point 
where sensitvity and specificity are closest together (Farrar et al, 2001). The second is the cut-point corresponding to the smallest sum of 1-sensitivity and 1-specificity; this methodology has been proposed by researchers from the EMGO 
Institute (de Vet et al, 2009). The third is the cut-point corresponding to the smallest sum of squares of 1-sensitivity and 1-specificity in accordance with Pythagoras' theorem, and as proposed by the authors Froud and Abel (2014).

{phang} The refvar should be the external criterion variable and must be either 0 or 1; 1 representing an improvement in health status. The classvar should be the change score variable 
(baseline minus follow-up). 

{phang} The program also calculates the ROC AUC with a 95% confidence interval in the same way as the command {cmd:roctab} and produces a graph of sensitivity and sensitivity 
and plots a ROC curve (although the latter function is suppressed when specifying the {hi:fast} option).


{title:Options}

{dlgtab:Main}

{phang} {hi:Important:} The minimal scale unit is the smallest increment measured by the instrument. In contrast to {cmd:roctab}, which when used with the option 
{cmd:detail}, presents sensitivity and specificity greater than or equal to each cut-point, this program naturally calculates sensitivity and specificity for values greater 
than a corresponding cut-point. Thus, to obtain the MIC, the scale's minimal increment value (NB for most patient-reported outcome measures this will be a value of 1) must 
be added and the quantity specified in scale is added by this program. If deterioration is required please modify the ado to subtract this quantity.

{phang}
The option {hi:fast} will suppress the rendering of the ROC curve for a faster processing time to allow use in conjunction with the {hi:bootstrap} command to generate confidence intervals.{p_end} 
The program stores the MIC estimate for the 45 degree tangent line method in r(mic), the EMGO MIC estimate is stored 
in r(emgo), and the estimate from the sum of squares method is stored in r(py).


{title:Examples}

{phang}{cmd:. rocmic ref change, scale(1)}

{phang}{cmd:. rocmicd ref change, scale(0.1)}

{phang}{cmd:. bootstrap MIC=(r(mic)): rocmic ref change, scale(1) fast}

{phang}{cmd:. bootstrap MIC=(r(py)), reps(1000): rocmic ref change, scale(1) fast}

{phang}{cmd:. bootstrap MICf=(r(mic)) MICs=(r(py): rocmic ref change, scale(1) fast}


{title:References}

{pstd}
R. Froud, G. Abel, Using ROC curves to choose minimally important change thresholds when sensitivity and specificity are valued equally: the forgotten lesson of Pythagoras. {it:PLOS ONE} {bf: 2014 IN PRESS}.

{pstd}
Farrar JT, Young JP, Jr., LaMoreaux L, Werth JL, Poole RM. Clinical importance of changes in chronic pain intensity measured on an 11-point numerical pain 
rating scale. {it:Pain} {bf:2001;94(2):149-58}.

{pstd}
de Vet H, Terluin B, Knol D, Roorda L, Mokkink B, Ostelo R, et al. There are three different ways to quantify the uncertainty when 'minimally important 
change' (MIC)  values are applied to individual patients. {it:J Clin Epidemiol} {bf:2010 Jan;63(1):37-45}.

{pstd}
R. Froud, S. Eldridge, R.Lall, M.Underwood, Estimating NNT from continuous outcomes in randomised controlled trials: Methodological challenges and worked example using data 
from the UK Back Pain Exercise and Manipulation (BEAM) trial ISRCTN32683578. {it:BMC Health Services Research} {bf: 2009, 9:35}.


{title:Authors}

{pstd}
Robert Froud (rob.froud@clinvivo.com) and Gary Abel (g.abel@ga302@medschl.cam.ac.uk)


{title:Also see}

{psee}
Manual:  {bf:[ST] bootstrap}
{bf:[ST] roctab}
{bf:[ST] logistic}
{bf:[ST] lsens}
{psee}
Online: www.robertfroud.info/software.html 

