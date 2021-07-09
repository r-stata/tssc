{smcl}
{* *! version 1.1 3Dec2010}{...}
{cmd:help simon2stage}
{hline}

{title:Title}

     {hi: Finding Simon two stage designs with extensions}

{title:Syntax}

{p 8 17 2}
{cmdab:simon2stage}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt p0:}(#)} specifies the null proportion, the default is 0.1. {p_end}
{synopt:{opt p1}(#)} specifies the alternative proportion, the default is 0.4.{p_end}
{synopt:{opt alpha}(#)} specifies the type I error, the default is 0.05.{p_end}
{synopt:{opt beta}(#)} specifies the type 2 error, the default is 0.2.{p_end}
{synopt:{opt minn}(#)} specifies the start sample size in the initial grid search, the default is 1.{p_end}
{synopt:{opt maxn}(#)} specifies the largest sample size in the initial grid search, the default is 35.{p_end}
{synopt:{opt optimal}} specifies that the interest is in the optimal design rather than the minimax.{p_end}
{synopt:{opt optp}(#)} specifies the true proportion to optimize the design for, the default is p0.{p_end}
{synopt:{opt eff}} specifies that the design can stop for efficacy as well as futility.{p_end}
{synopt:{opt deltaminimax}} specifies that the delta-minimax design is found.{p_end}
{synopt:{opt admiss}} specifies that the set of admissible designs should be found.{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
The Simon two stage design is a single arm study with an interim analysis. The main purpose of this design is to
investigate whether an intervention works or not and to stop the study early for futility. 
Under the null hypothesis the probability of a success is {hi:p0}, this is usually taken as the probability of success
 for the current standard treatment. 
The probability of a success in this study, {hi:p}, is tested using the null hypothesis
{hi:H0:p=p0} versus the alternative hypothesis {hi:H1:p>=p1}. The probability of success for the alternative
hypothesis is fixed to be a pre-specified value {hi:p1}, where {hi:p1>p0}.

{pstd}
The Simon two stage design consists of studying {hi:n1} participants in a first stage and the study stops if there
are {hi: r1} or fewer responders to the intervention. If there are more than {hi:r1} responders in the first
stage then the study continues until {hi:n} participants in total are studied. Then the null hypothesis is
not rejected if there are {hi:r} or fewer responders. Each design must satisfy the type 1 (alpha) and type 2 (beta)
errors.

{pstd}
The probability of not rejecting {hi:H0} can be calculated conditional on any {hi:p} and let this function be {hi:R(p)}.
The design must therefore satisfy the constraints {hi:R(p0)>=1-alpha} and {hi:R(p1)<=beta}. 
The minimax design is one that satisfies these
constraints with the smallest total sample size {hi:n} and the smallest expected sample size under {hi:H0}. 
The alternative is to find the "optimal" design which is
the design with the smallest expected sample size conditional on the true proportion being specified by the {hi:optp()} option.
The default is optimising the design under the null proportion {hi:p0} and this is the classical Simon two stage design, however
this command allows greater flexibility.

{pstd}
The Simon two stage design has been extended here to allow for stopping for efficacy. The design can be indexed
by 5 numbers {hi:(r1 r2/n1, r/n)}. Now the study stops for futility if there are {hi: r1} or fewer responders 
OR stops for efficacy if there are more than {hi:r2} responders in the first stage. If the study continues
to the second stage then the null hypothesis is no rejected if there are {hi:r} or fewer responders. Again
the type 1 and type 2 errors must be satisfied for a design to be considered.

{pstd}
There are two additional designs that are of interest firstly the delta-minimax design as described in Shuster 2002 
and secondly the set of admissible designs as described by Mander et al. (2010). The set of admissible designs
are displayed by using a novel figure to help with decision making.

{title:Latest Version}

{pstd}
The latest version is always kept on the SSC website. To install the latest version click
on the following link 

{pstd}
{stata ssc install simon2stage, replace}.

{title:Options}

{dlgtab:Main}

{phang}
{opt p0(#)} specifies the null proportion, the default is 0.1. {p_end}

{phang}
{opt p1(#)} specifies the alternative proportion, the default is 0.4.{p_end}

{phang}
{opt alpha(#)} specifies the type I error, the default is 0.05.{p_end}

{phang}
{opt beta(#)} specifies the type II error, the default is 0.2.{p_end}

{phang}
{opt minn(#)} specifies the start total sample size in the initial grid search, the default is 1.{p_end}

{phang}
{opt maxn(#)} specifies the largest total sample size in the initial grid search, the default is 35.{p_end}

{phang}
{opt optimal} specifies that the interest is in the optimal design rather than the minimax.{p_end}

{phang}
{opt optp(#)} specifies the true proportion to optimize the design for, the default is p0.{p_end}

{phang}
{opt eff} specifies that the design can stop for efficacy as well as futility.{p_end}

{phang}
{opt deltaminimax} specifies that the delta-minimax design is found.{p_end}

{phang}
{opt admiss} specifies that the set of admissible designs should be found.{p_end}

{title: Examples}

{pstd}
{space 2}{stata simon2stage}

{pstd}
The minimax design is {hi:{1/8 3/13}}, if there are no responders or one responder out of the first 8 participants 
then the study stops and the null hypothesis is not rejected. If the study proceeds to the second stage then
the null hypothesis is rejected if there are more than 3 responders. Under the null hypothesis there is a 0.813 
chance that the study stops at the first stage and hence the average sample size is 8*0.813+13*(1-0.813) = 8.934.

{pstd}
{space 2}{stata simon2stage, optimal}

{pstd}
The optimal design is {hi:{1/7 3/15}}, this is similar to the previous design but there is now a 0.85 chance that the
study finishes at stage 1 and the average sample size under the null hypothesis is 8.198 which is slightly smaller than the minimax
desgin.

{pstd}
{space 2}{stata simon2stage, optimal optp(0.2)}

{pstd}
The optimal design is still {hi:{1/7 3/15}} but the average sample size is much greater at 10.386 as a direct result of
a smaller chance 0.577 of early termination.

{pstd}
{space 2}{stata simon2stage, optimal optp(0.2) eff}

{pstd}
The optimal design is {hi:{(1 2)/7 3/15}} the expected sample size, 9.202, is smaller than the previous design
because of a greater chance of an early termination 0.725.

{pstd}
{space 2}{stata simon2stage,optimal eff deltaminimax}

{pstd}
The delta-minimax design is {hi:{(1 2)/7 3/15}} the expected sample size, 9.550, is larger than the previous designs
because this is the {hi:maximum} expected sample size.


{pstd}
{space 2}{stata simon2stage, optp(0.2)}

{pstd}
The minimax design optimised at a true response of {hi:0.2} is {hi:{1/8 3/13}}. The expected sample size, 10.483, 
much greater than when calculating the expected sample size at the null value. This has not altered the minimax
 design.

{pstd}
{space 2}{stata simon2stage,optimal eff admiss maxn(16)}

{pstd}
The set of admissible designs is plotted. Setting the maximum to be {hi:16} means that the set of admissible designs
are found by fixing the maximum sample size to be 16 or lower (this limits the designs to search through).
Interestingly the design {hi:{(1 2)/7 3/15}} is only good if there is little weight given to the overall
sample size.



{title:Author}

{pstd}
Adrian Mander, MRC Biostatistics Unit, Cambridge, UK.{p_end}
{pstd}
Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}

{title:References}

{pstd}
R.P.A'Hern (2001) Sample size tables for exact single-stage phase II designs. {it:Statistics in Medicine} {bf:20}:859-866.

{pstd}
T.R. Fleming (1982) One-sample multiple testing procedure for phase II clinical trials. {it:Biometrics} {bf:38}:143-151.

{pstd}
Richard Simon (1989) Optimal two-stage designs for phase II clinical trials. {it:Controlled Clinical Trials} {bf:10}:1-10.

{pstd}
A.P. Mander and S.G. Thompson (2010) Two-stage designs optimal under the alternative hypothesis for phase II cancer trials. {it:Contemporary Clinical Trials} {bf:31(6)}:572-578.

{pstd}
A.P. Mander, J.M. Wason, M.J. Sweeting and S.G. Thompson (2010) Admissible two-stage designs for phase II cancer clinical trials. {it:(Submitted)}

{title:Also see}

{pstd}
Related commands

{pstd}
HELP FILES {space 13}SSC installation links{space 4}Description

{pstd}
{help samplesize} (if installed){space 8}({stata ssc install samplesize}){space 8}Sample Size graphics{p_end}
{pstd}
{help sampsi_fleming} (if installed){space 4}({stata ssc install sampsi_fleming}){space 4}Sample Size for Fleming design{p_end}
{pstd}
{help sampsi_reg} (if installed){space 8}({stata ssc install sampsi_reg}){space 8}Sample Size for linear regression{p_end}
{pstd}
{help sampsi_mcc} (if installed){space 8}({stata ssc install sampsi_mcc}){space 8}Sample Size for matched case/control studies{p_end}
{pstd}
{help sampsi_rho} (if installed){space 8}({stata ssc install sampsi_rho}){space 8}Sample Size for Pearson correlation{p_end}


