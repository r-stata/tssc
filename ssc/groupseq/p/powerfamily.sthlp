{smcl}
{* *! version 1.0  16 Apr 2015}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" “powerFamily##syntax"}{...}
{viewerjumpto "Description" "powerFamily##description"}{...}
{viewerjumpto "Options" "powerFamily##options"}{...}
{viewerjumpto "Remarks" "powerFamily##remarks"}{...}
{viewerjumpto "Examples" "powerFamily##examples"}{...}
{title:Title}
{phang}
{bf:innerWedge} {hline 2} Group Sequential Design with Power Family Boundaries

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:powerFamily}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt l(integer 3)}} The maximum number of allowed stages in the design. Must be an integer greater than or equal to 2.{p_end}
{synopt:{opt d:elta(real 0.2)}} The clinically relevant difference at which to power. Must be strictly positive.{p_end}
{synopt:{opt a:lpha(real 0.05)}} The desired type-I error rate. Must be strictly between 0 and 1.{p_end}
{synopt:{opt b:eta(real 0.2)}} The desired type-II error rate. Must be strictly between 0 and 1.{p_end}
{synopt:{opt s:igma(numlist)}} The standard deviation of the responses in the two arms. This can either be of length two, containing the assumed values of these responses, or of length one, implying the standard deviation in each arm is equal. All values must be strictly positive.{p_end}
{synopt:{opt r:atio(real 1)}} The desired ratio of the sample sizes between the two arms. Must be strictly positive.{p_end}
{synopt:{opt o:mega(real 0.25)}} The desired shape parameter of the boundaries. Must be less than 0.5.{p_end}
{synopt:{opt per:formance}} Specifies that the performance of the identified design, i.e. its expected sample size and power curves, should be determined and plotted.{p_end}
{synopt:{opt *}} Additional options to pass to twoway.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:powerFamily} determines the boundaries of, and sample size required by, a group sequential design with power family boundaries.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt l(integer 3)} The maximum number of allowed stages in the design. Must be an integer greater than or equal to 2.

{phang}
{opt d:elta(real 0.2)} The maximum number of allowed stages in the design. Must be an integer greater than or equal to 2.

{phang}
{opt a:lpha(real 0.05)} The desired type-I error rate. Must be strictly between 0 and 1.

{phang}
{opt b:eta(real 0.2)} The desired type-II error rate. Must be strictly between 0 and 1.

{phang}
{opt s:igma(numlist)} The standard deviation of the responses in the two arms. This can either be of length two, containing the assumed values of these responses, or of length one, implying the standard deviation in each arm is equal. All values must be strictly positive.

{phang}
{opt r:atio(real 1)} The desired ratio of the sample sizes between the two arms. Must be strictly positive.

{phang}
{opt o:mega(real 0.25)} The desired shape parameter of the boundaries. Must be less than 0.5.

{phang}
{opt per:formance} Specifies that the performance of the identified design, i.e. its expected sample size and power curves, should be determined and plotted.

{phang}
{opt *} Additional options to pass to twoway.

{marker examples}{...}
{title:Examples}

{phang} 
{stata powerFamily, sigma(1)}

{phang} 
{stata powerFamily, l(2) delta(0.25) alpha(0.1) beta(0.1) sigma(2, 3) ratio(2) per}

{title:Authors}
{p}

Michael J. Grayling & Adrian P. Mander,
MRC Biostatistics Unit, Cambridge, UK.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}

{title:See Also}

References:

Pampallona S, Tsiatis AA (1994) Group sequential designs
for one-sided and two-sided hypothesis testing with provision for
early stopping in favor of the null hypothesis. Journal of
Statistical Planning and Inference 42(1-2):19–35.
  
Related commands:

{help doubleTriangular} (if installed)
{help haybittlePeto} (if installed)
{help innerWedge} (if installed)
{help triangular} (if installed)
{help wangTsiatis} (if installed)
