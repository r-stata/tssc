{smcl}
{hline}
{cmd:help metaparm_resultssets}{right:(Roger Newson)}
{hline}


{title:Output datasets created by {helpb metaparm} and {helpb parmcip}}

{pstd}
The output datasets (or resultssets) created by {helpb metaparm} and {helpb parmcip} have one observation per parameter
and data on their estimation results. After {helpb parmcip} has executed successfully,
the dataset in memory will contain the following variables (and possibly others):

{p2colset 4 20 22 2}{...}
{p2col:Default name}Description{p_end}
{p2line}
{p2col:{hi:estimate}}Parameter estimate{p_end}
{p2col:{hi:stderr}}SE of parameter estimate{p_end}
{p2col:{hi:dof}}Degrees of freedom{p_end}
{p2col:{hi:t}}{it:t}-test statistic{p_end}
{p2col:{hi:z}}{it:z}-test statistic{p_end}
{p2col:{hi:p}}{it:P}-value{p_end}
{p2col:{hi:stars}}Stars for {it:P}-value{p_end}
{p2col:{hi:min}{it:yy}}Lower {it:xx}% confidence limit{p_end}
{p2col:{hi:max}{it:yy}}Upper {it:xx}% confidence limit{p_end}
{p2line}
{p2colreset}

{pstd}
These variables contain the same information, and have the same {help char:characteristics},
as the variables of the same names in the {help parmest_resultssets:parmest resultsset}.
The variables {hi:estimate}, {hi:stderr} and {hi:dof} are usually present before the
execution of {helpb parmcip}.
The others are added to the dataset by {helpb parmcip}.
The variable {hi:t} is created only if the {cmd:tdist} option is in force,
the variable {hi:z} is only present if the {cmd:notdist} option is in force,
and the variable {cmd:stars} is only present if the {cmd:stars()} option is specified.
All of these variables may have non-default names, which can be specified
by the options in {it:{help parmcip_opts}}.

{pstd}
The output dataset created by {helpb metaparm} contains all of these variables,
and may also contain the following additional variables:

{p2colset 4 24 26 2}{...}
{p2col:Default name}Description{p_end}
{p2line}
{p2col:{hi:idnum}}Numeric dataset ID{p_end}
{p2col:{hi:idstr}}String dataset ID{p_end}
{p2col:{it:by-variables}}Variables specified in the {cmd:by()} option{p_end}
{p2col:{it:sumvar-variables}}Variables specified in the {cmd:sumvar()} option{p_end}
{p2line}
{p2colreset}

{pstd}
The variables with default names {hi:idnum} and {hi:idstr} may have non-default names,
which can be specified using the {cmd:nidnum()} and {cmd:nidstr()} options, described in
{it:{help metaparm_content_opts}}.
The {it:by-variables} and {it:sumvar-variables} aare also described in
{it:{help metaparm_content_opts}}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {findalias frestimate}
{p_end}

{psee}
{space 2}Help:  {manhelp postest U:20 Estimation and postestimation commands}{break}
{helpb parmest}, {helpb parmby} {helpb parmcip}, {helpb metaparm},
{help metaparm_outdest_opts:{it:metaparm_outdest_opts}},
{help metaparm_content_opts:{it:metaparm_content_opts}}, {it:{help parmcip_opts}},
{help parmest_resultssets:{it:parmest_resultssets}}
{p_end}
