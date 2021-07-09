{smcl}
{* *! version 1.1 8jun2015}{...}
{vieweralsosee "Main network help page" "network"}{...}
{viewerjumpto "Syntax" "network_convert##syntax"}{...}
{viewerjumpto "Description" "network_convert##description"}{...}
{viewerjumpto "Examples" "network_convert##examples"}{...}
{title:Title}

{phang}
{bf:network convert} {hline 2} Convert network data between formats


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:network convert}
{cmd:augmented}|{cmd:standard}|{cmd:pairs}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options available when converting to augmented format}
{synopt:{opt large(#)}}Value used for variance of contrasts with the reference treatment in trials without the reference treatment.
Default value is 100000.
If errors occur, it may be worth decreasing this parameter.
If discrepancies occur, for example between different formats, 
then it may be worth increasing this parameter.{p_end}
{synopt:{opt ref(trtcode)}}Changes the reference treatment. {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:network convert} converts between the 
three formats described in {help network##formats:help network}.


{title:Details of conversion to augmented format}

{pstd}For studies lacking a reference treatment arm,
conversion to augmented format requires an augmentation procedure which is different
from that performed by {cmd:network setup} 
(and which therefore gives a different augmented dataset, and very slightly different analysis results).
Suppose the reference treatment is A and we want to convert a BCD study from standard format.
We know the estimates, variances and covariance of the C-B and D-B contrasts, because B is the first treatment in this study.
Let L be the large number specified by the {cmd:large()} option.
We augment by assuming that the B-A contrast is zero with variance L and is uncorrelated with the B-C-D contrasts. 
This gives the following procedure:

{pmore}(1) the C-A contrast equals the B-A contrast;

{pmore}(2) the variance of the C-A contrast equals the variance of the C-B contrast plus L;

{pmore}(3) the covariance of the C-A and D-A contrasts equals the covariance of the C-B and D-B contrasts plus L.


{marker examples}{...}
{title:Examples}

{pin}. {stata network convert pairs}

{pin}. {stata network convert standard}

{pin}. {stata network convert augmented, large(1000) ref(C)}


{p}{helpb network: Return to main help page for network}


