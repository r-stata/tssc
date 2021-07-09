{smcl}
{* *! version 1.1 8jun2015}{...}
{vieweralsosee "Main network help page" "network"}{...}
{viewerjumpto "Syntax" "network_sidesplit##syntax"}{...}
{viewerjumpto "Description" "network_sidesplit##description"}{...}
{viewerjumpto "What happens when there is no indirect evidence?" "network_sidesplit##no_indirect_evidence"}{...}
{viewerjumpto "Examples" "network_sidesplit##examples"}{...}
{viewerjumpto "Saved results" "network_sidesplit##savedresults"}{...}
{title:Title}

{phang}
{bf:network sidesplit} {hline 2} fit side-splitting model(s) to explore inconsistency


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:network sidesplit}
{it:trtcode1 trtcode2}|{cmd:all} {ifin}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt show}}Shows {help mvmeta} calculation and results.
Not applicable for {cmdab:network sidesplit all}.{p_end}
{synopt:{opt nosy:mmetric}}Uses the node-splitting model
as originally specified by {help network##Dias++10:Dias et al}.
In the presence of multi-arm studies, this can be asymmetrical:
that is, {cmd:network sidesplit A B} can give different results from {cmd:network 
sidesplit B A}.
The default is a new symmetrical version
which can be understood as being intermediate between these two alternatives.{p_end}
{synopt:{opt tau}}Additionally outputs tau, the standard deviation of the between-studies 
heterogeneity.{p_end}
{synopt:{opt mvmeta_options}}Options for {help mvmeta}.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:network sidesplit} fits the node-splitting model of
{help network##Dias++10:Dias et al (2010)}.
A node is a treatment contrast, for example B vs. A.
To split B vs A, different parameters are used for
the contrast of B vs. A in studies containing both A and B (the direct estimate)
and in other studies (the indirect estimate).
The direct and indirect treatment effects are estimated jointly.
The output reports the estimated direct and indirect treatment effects and 
their difference; the P-value for the difference is a test of consistency.

{pstd}Multi-arm studies complicate this procedure.
Suppose there is a trial of A vs. B vs. C, and the B vs. A contrast is allowed to differ
between the two groups of studies as above.
Then it follows that either the C vs. B contrast or the C vs. A contrast (or both)
must also differ between the two groups of studies, and it is unclear which should be 
done.
Dias et al assume that the C vs. A contrast is equal in the two groups of studies,
when A is the baseline treatment.
This is the behaviour if the {cmd:nosymmetric} option is used.

{pstd}
I propose a small change which treats A and C symmetrically.
This is the behaviour if the {cmd:nosymmetric} option is not used.
In this method, if the B vs. A contrast is omega units greater in the "direct" studies,
then the C vs. B contrast is omega/2 units smaller,
and the C vs. A contrast is omega/2 units greater,
in the "direct" studies
(all compared with the "indirect" studies).


{marker no_indirect_evidence}{...}
{title:What happens when there is no indirect evidence?}

{pstd}If there is no indirect evidence, then {cmd:network sidesplit} is fitting an 
unidentified model. 
This may lead to the model failing to fit, or (since the augmented format is used) it may 
lead to large standard errors. 

{pstd}{cmd:network sidesplit} checks whether there is any evidence in the "indirect" 
studies, and issues a warning if there isn't. If there are no multi-arm studies then this 
is equivalent to checking whether the sidesplitting model is identified. However, if 
there are multi-arm studies then the two checks are not equivalent: that is, there may be 
no evidence in the "indirect" studies and yet the sidesplitting model may be fully 
identified. I'll explain this in a simple example.

{pstd}Consider the network containing treatments A, B and C, where there are just ABC 
studies and BC studies. Let's suppose we are interested in the A-B contrast, so we 
explore whether we can sidesplit AB.
The "direct" studies are the ABC studies, and the "indirect" studies are the BC studies.
Clearly the indirect studies do not provide evidence about the A-B contrast, so 
{cmd:network sidesplit} will issue a warning. The three sidesplit models are

{pmore}1. {cmd:network sidesplit A B, nosymm}: this model is identified. It can be shown 
that the inconsistency parameter in this model is the difference between the B-C 
contrasts in the ABC and BC studies, and the indirect estimate in this model adds the A-C 
contrast from the ABC studies to the C-B contrast from the BC studies. 

{pmore}2. {cmd:network sidesplit B A, nosymm}: this model is unidentified. 

{pmore}3. The symmetrical version {cmd:network sidesplit A B}: this model is identified. 
It can be shown that the inconsistency parameter in this model is twice that in case 1 
above, and the "indirect estimate" is a very strange linear combination (it's that for 
case 1 above, plus the difference in B-C contrasts in the BC minus the ABC studies). 

{pstd}Something similar happens if we split A D in the thrombolytics data. 


{title:Limitations}

{pstd}{cmd:network sidesplit} currently only works with data in the {cmd:augmented} 
format.
See {help network convert}.

{pstd}{cmd:network sidesplit} sometimes fails when run on a subset of the data that was included in {cmd:network setup}. If this happens then re-run {help network setup} on the subset.


{marker examples}{...}
{title:Examples}

{pstd}Split one node:

{pin}. {stata "network sidesplit A B"}

{pstd}Split each node, one by one, showing the standard deviation of the between-studies heterogeneity for each model. This analysis can be slow because each split involves fitting 
a new model:

{pin}. {stata "network sidesplit all, tau"}


{title:Saved results}{marker savedresults}

{pstd}{cmd:network sidesplit} is an rclass command.
A single side-split saves the three estimates (direct, indirect, difference) in r(b), 
with variance in r(V).
{cmd:network sidesplit all} saves the same matrices, stacking the different split sides, 
and using row equation names to identify the split side.


{p}{helpb network: Return to main help page for network}


