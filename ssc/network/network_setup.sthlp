{smcl}
{* *! 6apr018 - limit on treatment name length}{...}
{* *! version 1.4.1 4apr018 - more on maxvar}{...}
{* *! version 1.2.5 13mar2017}{...}
{vieweralsosee "Main network help page" "network"}{...}
{viewerjumpto "Syntax" "network_setup##syntax"}{...}
{viewerjumpto "Description" "network_setup##description"}{...}
{viewerjumpto "Input data formats" "network_setup##formats"}{...}
{viewerjumpto "Networks with large numbers of treatments" "network_setup##manytrts"}{...}
{viewerjumpto "Standardised mean difference" "network_setup##smd"}{...}
{viewerjumpto "Network connectedness" "network_setup##connect"}{...}
{viewerjumpto "Examples" "network_setup##examples"}{...}
{title:Title}

{phang}
{bf:network setup} {hline 2} Prepare data for network meta-analysis


{marker syntax}{...}
{title:Syntax}

Count data:

{p 8 17 2}
{cmdab:network setup}
{it:eventvar} {it:nvar}
{ifin}
{cmd:,}
{opt stud:yvar(varname)}
[{cmd:or|rr|rd|hr}
{cmd:zeroadd(#)}
{it:common_options}]

Quantitative data:

{p 8 17 2}
{cmdab:network setup}
{it:meanvar} {it:sdvar} {it:nvar}
{ifin}i
{cmd:,}
{opt stud:yvar(varname)}
[{cmd:md|smd}
{it:common_options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Describe data}
{synopt:{opt stud:yvar(varname)}}Study identifier (required){p_end}
{synopt:{opt trt:var(varname)}}Treatment identifier 
(implies long {help network_setup##formats:input data format}){p_end}
{synopt:{opt armv:ars(drop | keep [varlist])}}(only with long {help network_setup##formats:input data format})
Specifies how extra arm-level variables 
(that is, variables other than those required in the syntax)
should be handled: whether they should all be dropped, all kept, or specified ones kept and the others dropped.
Otherwise, extra arm-level variables cause an error.{p_end}

{syntab:How treatments are coded}
{synopt:{opt trtl:ist(string)}}List of names of treatments to be used 
- useful if you want to omit some treatments e.g. for a sensitivity analysis. 
Also useful to specify how the treatments will be coded (first treatment will be A, etc.).
The default is to use all treatments found in alphabetical order
(but in numerical order when {cmd:trtvar} is numeric).{p_end}
{synopt:{opt alpha}}Forces treatments to be coded in alphabetical order. 
This is the default except with long {help network_setup##formats:input data format} when {cmd:trtvar} is numeric with value labels.{p_end}
{synopt:{opt num:codes}}
Codes treatments as numbers 1, 2, 3 ... or (if more than 9 treatments) 01, 02, 03... 
The default is to code treatments as letters A, B, C...{p_end}
{synopt:{opt noco:des}}
Uses current treatment names as treatment codes.
Treatment names are modified only if this is needed to make them valid Stata names.
This option becomes increasingly awkward as treatment names become longer.{p_end}

{syntab:How to set up}
{synopt:{opt format(augmented|standard|pairs)}}The (output) data format required. 
See {help network##formats:Data formats}.{p_end}
{synopt:{opt or}}The treatment effect is measured by the log odds ratio.{p_end}
{synopt:{opt rr}}The treatment effect is measured by the log risk ratio.{p_end}
{synopt:{opt rd}}The treatment effect is measured by the risk difference.{p_end}
{synopt:{opt hr}}The treatment effect is measured by the log hazard ratio.
In this case {it:nvar} must be the total person-time at risk, not the number of individuals.
(This treatment effect is usually called the log rate ratio; 
the term hazard ratio is used to avoid confusion with the risk ratio, 
and because the rate ratio equals the hazard ratio under an exponential model.){p_end}
{synopt:{opt zeroadd(#)}}With count data, the number of successes and 
(except with the {cmd:hr} option) failures added
to all arms of any study which contains a zero cell in any arm. Default is 0.5.{p_end}
{synopt:{opt md}}The treatment effect is measured by the mean difference. 
The variances are calculated using the pooled standard deviation across all trial arms.
{p_end}
{synopt:{opt smd}}The treatment effect is measured by the standardised mean difference. 
For details see {help network_setup##smd:standardised mean difference} below.{p_end}
{synopt:{opt sdpool(on|off)}}With quantitative data, this specifies whether the standard deviation 
is pooled across arms in computing variances. 
The default, which follows {help metan}, is 
{opt sdpool(off)} with {cmd:md}
and
{opt sdpool(on)} with {cmd:smd}.
For multi-arm studies, {opt sdpool(on)} pools across all arms.{p_end}

{syntab:Augment options}
{synopt:{opt ref(string)}}Name of reference treatment.
Different choices should give the same results, but numerical stability may be greater
when the reference treatment is fairly central  in  the network 
(e.g. it is one of the better connected treatments).{p_end}
{synopt:{opt augment(exp)}}Number of individuals to use to augment missing reference treatment arms.
Default is 0.00001.
If errors occur, it may be worth increasing this parameter.
If discrepancies occur, for example between different formats, 
then it may be worth decreasing this parameter.{p_end}
{synopt:{opt augmean(exp)}}Mean outcome to use to augment missing reference treatment arms.
Default is for each augmented study to use the weighted average of its
arm-specific means.{p_end}
{synopt:{opt augsd(exp)}}(only for quantitative data) Standard deviation 
to use to augment missing reference treatment arms.
Default is for each augmented study to use the weighted average of its
arm-specific standard deviations.{p_end}
{synopt:{opt aug:overall}}Changes default behaviour for {cmd:augmean} and {cmd:augsd} 
to use the overall mean and SD across all studies.{p_end}

{syntab:Naming the output variables}
{synopt:{opt genp:refix(string)}}Prefix to be used before default variable names (e.g. y for treatment contrasts){p_end}
{synopt:{opt gens:uffix(string)}}Suffix to be used after default variable names{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}



{marker description}{...}
{title:Description}

{pstd}
{cmd:network setup} prepares data from a set of studies reporting 
count data (events, total number) 
or
quantitative data (mean, sd, total number) 
for two or more treatments.  
The data may be in long input format (one record per treatment per study) 
or in wide input format (one record per study) - see {help network_setup##formats:Input data formats} below.

{pstd}{cmd:network} uses a code and a name for each variable. 
The treatments are coded A, B, C etc., 
unless the {cmd:numcodes} option is used, when the codes are 1, 2, 3,... 
Handling of large numbers of treatments is described below in {help network_setup##manytrts:Networks with large numbers of treatments}.

{pstd}Treatment codes are usually assigned in alphabetical order of the treatment names. 
The exceptions are
(1) if {cmd:trtlist()} is specified, then this order is followed;
(2) if the data are in long input format, and {cmd:trtvar} is a numeric variable, 
and the {cmd:alpha} option is not specified, then
the numerical order of {cmd:trtvar} is followed even if {cmd:trtvar} has value labels.

{pstd}The data are returned sorted by the study identifier.

{pstd}{cmd:network setup} performs a check that the network is connected: 
see {help network_setup##connect:Network connectedness}.


{marker formats}{...}
{title:Input data formats}

{pstd}For data in long input format, {it:events} {it:total} or {it:mean} {it:sd} {it:total} are variable names.
{cmd:trtvar()} may be a string variable or a numeric variable.
The treatment names are the levels of this variable (or their value labels, if any).
For example, the first 4 studies of the smoking data might be stored in long input format as follows:

        study                      trt    d     n  
            1               No contact    9   140  
            1   Individual counselling   23   140  
            1        Group counselling   10   138  
            2                Self help   11    78  
            2   Individual counselling   12    85  
            2        Group counselling   29   170  
            3               No contact   79   702  
            3                Self help   77   694  
            4               No contact   18   671  
            4                Self help   21   535  

{pstd}and would be loaded by {cmd:network setup d n, studyvar(study) trtvar(trt)}.

{pstd}For data in wide input format, {it:events} {it:total} or {it:mean} {it:sd} {it:total} are variable stubs:
that is, the variable names comprise these variable stubs followed by a suffix which is a treatment name.
The treatment names are these suffixes.
For example, the same studies of the smoking data might be stored in wide input format as follows:

        study   dA    nA   dB    nB   dC    nC   dD    nD  
            1    9   140    .     .   23   140   10   138  
            2    .     .   11    78   12    85   29   170  
            3   79   702   77   694    .     .    .     .  
            4   18   671   21   535    .     .    .     .  

{pstd}and would be loaded by {cmd:network setup d n, studyvar(study)}.

{pstd}You might have the same data in a more compact wide input format, 
in which the variables refer to the 1st, 2nd etc. study arms, as follows:

        study   d1    n1   trt1   d2    n2   trt2   d3    n3   trt3  
            1    9   140      A   23   140      C   10   138      D  
            2   11    78      B   12    85      C   29   170      D  
            3   79   702      A   77   694      B    .     .         
            4   18   671      A   21   535      B    .     .         

{pstd}You would load these data by first converting to long input format:

        {cmd:reshape long d n trt, i(study) j(arm)}
        {cmd:drop if missing(trt)}
        {cmd:drop arm}
        {cmd:network setup d n, studyvar(study) trtvar(trt)}

{pstd}Treatment names may not exceed 32 characters in length in any format.


{marker manytrts}{...}
{title:Networks with large numbers of treatments}

{pstd}
{cmd:network setup} can accommodate networks with large numbers of treatments.
When treatments are coded alphabetically, up to 26 treatments are coded A, B, C,... and more than 26 treatments are coded AA, AB, AC, ...
When treatments are coded numerically, up to 9 treatments are coded 1, 2, 3,... 
and more than 9 treatments are coded 01, 02, 03, ... (or 001, 002, 003, ... if necessary).

{pstd}
With large numbers of treatments, however, the number of variables required by the augmented format may exceed Stata's permitted numbers of variables.
If you are running Stata/IC, then this limit is about 45 treatments, and cannot be changed. 
If you are running Stata/MP or Stata/SE, then the default limit is about 70 treatments, 
and can be increased by increasing {help memory:maxvar} to at least the square of the number of treatments;
you may also need to increase {help matsize}.

{pstd}
Technical  note: it is not possible at present to circumvent these restrictions by using other formats, because the augmented format is always used as an intermediary.


{marker smd}{...}
{title:Standardised mean difference}

{pstd}
The formulae for Hedges' g in {help network##WhiteThomas05:White and Thomas (2005)} are used. 
These are unbiased estimators and involve corrections for small numbers of degrees of freedom.

{pstd}In detail, equation (9) is used for the point estimate and (14) is used for the estimated variance. 
The covariance between SMD1 and SMD2 is taken as 1/N0 + SMD1*SMD2*K(nu)
where nu is the degrees of freedom used to estimate the pooled standard deviation, N0 is the sample size 
in the common reference group, and K(nu) is defined in 
{help network##WhiteThomas05:White and Thomas (2005)}.
If {cmd:sdpool(off)} is specified then 1/N1+1/N2 in these formulae is replaced by 
(sigma1^2/N1+sigma2^2/N2)/sigma^2 where sigma is the pooled SD.


{marker connect}{...}
{title:Network connectedness}

{pstd}{cmd:network setup} performs a check that the network is connected, and prints a warning if it is not.
It also computes four useful matrices which describe the geometry of the network of T treatments:

{p 8 12 2}
    {cmd:network_adjacency} is a T x T matrix, the "adjacency matrix", 
    which is 1 if the two treatments are directly compared and 0 otherwise.
	Diagonal values are 0 by convention.

{p 8 12 2}
    {cmd:network_indirect_connection} is a T x T matrix, the "indirect connection matrix", 
    which is 1 if there is a "walk" in the graph between the two treatments (that is, if they can be indirectly compared) 
	and 0 otherwise.
	Diagonal values are 1 by convention.

{p 8 12 2}
    {cmd:network_distance} is a T x T matrix, the "distance matrix", 
    which is the length of the shortest walk through the network between the two treatments.
    For example, in a network consisting only of AB trials, BC trials and CD trials, 
    the distance from A to B is 1 but the distance from A to D is 3.
	The distance between unconnected treatments is 0 by convention.
	Diagonal values are also 0 by convention.

{p 8 12 2}
	{cmd:network_components} is a T x C matrix which identifies which treatments lie in which components,
	where C is the number of components.
	For a connected network, it is a T x 1 matrix of 1s.

{pstd}You can view the geometry of the network using {help network map} 
and you can see the above matrices using {stata matrix list network_components} etc.


{marker examples}{...}
{title:Examples}

{pstd}Starting with the smoking data in long input format.
study and trt are the identifiers, 
d containing number of events, and n contains the total number of individuals.
The following command produces a data set ready for {cmd:mvmeta}:

{pin}. {stata "use smoking, clear"}

{pin}. {stata "network setup d n, studyvar(study) trtvar(trt)"}

{pstd}If instead we wanted to use the risk difference:

{pin}. {stata "network setup d n, studyvar(study) trtvar(trt) rd"}

{pstd}Coding treatments as 1-4:

{pin}. {stata "network setup d n, studyvar(study) trtvar(trt) numcodes"}

{pstd}The same starting with data in wide input format.
Variables dA-dD contain numbers of events and nA-nD contain total numbers of individuals:

{pin}. {stata "network setup d n, studyvar(study)"}


{p}{helpb network: Return to main help page for network}

