{smcl}
{* *! version 1.0  16 Apr 2015}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "triangular##syntax"}{...}
{viewerjumpto "Description" "triangular##description"}{...}
{viewerjumpto "Options" "triangular##options"}{...}
{viewerjumpto "Remarks" "triangular##remarks"}{...}
{viewerjumpto "Examples" "triangular##examples"}{...}
{title:Title}
{phang}
{bf:triangular} {hline 2} Triangular Test

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:triangular}
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
{synopt:{opt per:formance}} Specifies that the performance of the identified design, i.e. its expected sample size and power curves, should be determined and plotted.{p_end}
{synopt:{opt *}} Additional options to pass to twoway.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:triangular} determines the boundaries of, and sample size required by, a triangular test.

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
{opt per:formance} Specifies that the performance of the identified design, i.e. its expected sample size and power curves, should be determined and plotted.

{phang}
{opt *} Additional options to pass to twoway.

{marker examples}{...}
{title:Examples}

{phang} 
{stata triangular, sigma(1)}

{phang} 
{stata triangular, l(2) delta(0.25) alpha(0.1) beta(0.1) sigma(2, 3) ratio(2) per}

{title:Authors}
{p}

Michael J. Grayling & Adrian P. Mander,
MRC Biostatistics Unit, Cambridge, UK.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}

{title:See Also}

References:

Whitehead J, Stratton I (1983) Group Sequential Clinical Trials with
  Triangular Continuation Regions. Biometrics 39(1):227-236.
  
Related commands:

{help doubleTriangular} (if installed)
{help haybittlePeto} (if installed)
{help innerWedge} (if installed)
{help powerFamily} (if installed)
{help wangTsiatis} (if installed)
