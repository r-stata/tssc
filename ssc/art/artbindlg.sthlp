{smcl}
{* 23dec2014}{...}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:artbindlg} {hline 2}}ART (Binary Outcomes) - Sample Size and Power dialog{p_end}
{p2colreset}{...}


{title:Definitions and usage}

{p 0 4}
{cmd:Number of groups} (default 2, max. 6) Number of arms in the clinical trial.
{p_end}

{p 0 4}
{cmd:Allocation ratios} By default, all groups are assumed of equal size, so
			the allocation ratios (more precisely, weights) are
			all equal to 1. You can very this, e.g. 1 2 2 would
			specify that groups 2 and 3 should have twice as many
			patients allocated as group 1.
{p_end}

{p 0 4}
{cmd:Proportions} These are the target event probabilities in the arms
			of the trial. Values must all be in the range (0,1).
{p_end}

{p 0 4}
{cmd:Trend} Allows a linear trend test across the groups, with
			scores 1, 2, 3,... attached to the groups. A trend
			test may be more powerful than a general comparison
			between the groups. See also ^dose^.
{p_end}

{p 0 4}
{cmd:Dose} A quantity assigned to each group which represents the
			dose of some medication or other intervention received
			by the subjects in that group. If you specify a dose
			level for any group, you must specify a level for
			every group.
{p_end}

{p 0 4}
{cmd:Alpha} (default 0.05 two-sided) Alpha is the Type I error probability.
{p_end}

{p 0 4}
{cmd:Power or N} Power is the power of the trial, N is the total
			sample size (all groups combined). The radio buttons
			allow you to choose whether the program will display
			the power for given N or the N for specified power.
{p_end}

{p 0 4}
{cmd:Local alternatives} Under local alternatives (the default option), the
			program uses the covariance matrix appropriate to the
			null hypothesis of no difference among the proportions
			under both the null and the alternative hypotheses.
			This approach is reasonable if the odds ratio(s)
			under the alternative hypothesis are between about
			0.5 and 2. For two-group studies, the sample sizes
			tend to be somewhat larger with local alternatives
			than with global (non-local) alternatives.
{p_end}

{p 0 4}
{cmd:Distant alternatives} Under non-local alternatives, different covariance
			matrices are assumed according to the proportions
			proposed under the alternative hypothesis.
{p_end}

{p 0 4}
{cmd:Unconditional test} The unconditional test (the default) with local
			alternatives (also the default, see above) is the
			usual Pearson chisquare test. For two-group studies,
			the sample sizes may be anywhere from slightly larger
			to considerably larger with the unconditional test
			than with the conditional test.
{p_end}

{p 0 4}
{cmd:Conditional test (Peto)} The test is conditional on the total number of
			observed events and is based on Peto's approximation
			to the log odds ratio. It is available with local
			alternatives only. It gives smaller sample sizes,
			but perhaps should not be used unless you are willing
			to analyse the results of the study using the same
			test.
{p_end}

{p 0 4}
{cmd:Non-inferiority design} In a non-inferiority design one wishes to test whether the effects of the
			control and experimental treatments differ by no more than a
			a prespecified amount. In the calculations the roles of the null
			and alternative (alternate) hypotheses are reversed. That is,
			the sample size is calculated with signficance level equal to
			1-power and power equal to 1-alpha. A side-effect of this reversal is that
			the program is not able to compute the power of a non-inferiority
			design for a given sample size. However, the power can still be determined
			by trial and error, by repeatedly entering alpha and power until the desired
			sample size is achieved.
{p_end}

{p 0 4}
{cmd:One-sided alpha} (default two-sided) With one-sided alpha the significance level
			used by the program is doubled, resulting in a larger power or
			smaller sample size. This option should be used with caution.
{p_end}


{title:Examples}

{hi:Example 1}

Number of groups	2		Allocation ratios	[Default]
Proportions		0.2 0.3
Trend			No		Dose
Alpha			0.05		Power or N		0.8
Specify power		Yes		Specify sample size	No
Local alternatives	Yes		Global (non-local) alt	No
Unconditional test	Yes		Conditional test	No
Non-inferiority design	No		One-sided alpha		No

{hi:Result}

. artbin, pr(0.2 0.3) ngroups(2) aratios(1 1) distant(0) alpha(0.05) power(0.8) onesided(0) ni(0)

ART - ANALYSIS OF RESOURCES FOR TRIALS (version 1.1.0 12feb2014)
------------------------------------------------------------------------------
A sample size program by Abdel Babiker, Patrick Royston & Friederike Barthel,
MRC Clinical Trials Unit at UCL, London WC2B 6NH, UK.
------------------------------------------------------------------------------
Type of trial                          Superiority - binary outcome
Statistical test assumed               Unconditional comparison of 2
                                        binomial proportions
Number of groups                       2
Allocation ratio                       Equal group sizes

Anticipated event probabilities        0.200, 0.300

Alpha                                  0.050 (two-sided)
Power (designed)                       0.800

Total sample size (calculated)         589
Expected total number of events        148
------------------------------------------------------------------------------

Machin & Campbell (Table 3.1, p. 24) give n = 294 per group.

{hi:Example 2}

Number of groups	4		Allocation ratios	[Default]
Proportions		0.1 0.2 0.3 0.4
Trend			No		Dose
Alpha			0.05		Power or N		0.9
Specify power		Yes		Specify sample size	No
Local alternatives	Yes		Global (non-local) alt	No
Unconditional test	Yes		Conditional test	No
Non-inferiority design	No		One-sided alpha		No

{hi:Result}

. artbin, pr(0.1 0.2 0.3 0.4) ngroups(2) distant(0) alpha(0.05) power(0.9) onesided(0) ni(0)

ART - ANALYSIS OF RESOURCES FOR TRIALS (version 1.1.0 12feb2014)
------------------------------------------------------------------------------
A sample size program by Abdel Babiker, Patrick Royston & Friederike Barthel,
MRC Clinical Trials Unit at UCL, London WC2B 6NH, UK.
------------------------------------------------------------------------------
Type of trial                          Superiority - binary outcome
Statistical test assumed               Unconditional comparison of 4
                                        binomial proportions
Number of groups                       4
Allocation ratio                       Equal group sizes

Anticipated event probabilities        0.100, 0.200, 0.300, 0.400

Alpha                                  0.050 (two-sided)
Power (designed)                       0.900

Total sample size (calculated)         213
Expected total number of events        54
------------------------------------------------------------------------------

{hi:Example 3}

As Example 2 but with Trend checked (doses unspecified)

. artbin, pr(0.1 0.2 0.3 0.4) ngroups(4) distant(0) alpha(0.05) power(0.9) trend onesided(0) ni(0)

ART - ANALYSIS OF RESOURCES FOR TRIALS (version 1.1.0 12feb2014)
------------------------------------------------------------------------------
A sample size program by Abdel Babiker, Patrick Royston & Friederike Barthel,
MRC Clinical Trials Unit at UCL, London WC2B 6NH, UK.
------------------------------------------------------------------------------
Type of trial                          Superiority - binary outcome
Statistical test assumed               Unconditional comparison of 4
                                        binomial proportions
Number of groups                       4
Allocation ratio                       Equal group sizes
Linear trend test: doses are           1,...,4

Anticipated event probabilities        0.100, 0.200, 0.300, 0.400

Alpha                                  0.050 (two-sided)
Power (designed)                       0.900

Total sample size (calculated)         158
Expected total number of events        40
------------------------------------------------------------------------------

{hi:Example 4}

As Example 1 but assuming a non-inferiority design

. artbin, pr(0.2 0.3) ngroups(2) distant(0) alpha(0.05) power(0.8) onesided(0) ni(1)

ART - ANALYSIS OF RESOURCES FOR TRIALS (version 1.1.0 12feb2014)
------------------------------------------------------------------------------
A sample size program by Abdel Babiker, Patrick Royston & Friederike Barthel,
MRC Clinical Trials Unit at UCL, London WC2B 6NH, UK.
------------------------------------------------------------------------------
Type of trial                          Non-inferiority - binary outcome
Statistical test assumed               Comparison of 2 binomial proportions
                                        P1 and P2.
Null hypothesis H0:                    P2-P1 = 0.100
Alternative hypothesis H1:             P2-P1 = 0.000
Null variance estimation method        Sample estimate
Number of groups                       2
Allocation ratio                       Equal group sizes

Anticipated event probabilities        0.200, 0.200

Alpha                                  0.050 (two-sided)
Power (designed)                       0.800

Total sample size (calculated)         504
Expected total number of events        101
------------------------------------------------------------------------------

{title:Authors}

{pstd}Abdel Babiker, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:a.babiker@ucl.ac.uk":Ab Babiker}

{pstd}Friederike Maria-Sophie Barthel, formerly MRC Clinical Trials Unit{break}
{browse "mailto:sophie@fm-sbarthel.de":Sophie Barthel}

{pstd}Babak Choodari-Oskooei, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:b.choodari-oskooei@ucl.ac.uk":Babak Oskooei}

{pstd}Patrick Royston, MRC Clinical Trials Unit at UCL{break}
{browse "mailto:j.royston@ucl.ac.uk":Patrick Royston}


{title:Also see}

{psee}
Manual:  {hi:[R] sampsi}

{psee}
Online:  help for {help artmenu}, {help artbin}, {help artbindlg}, {help artbindlg}
