{smcl}
{* *! version 1.0.0 14may2010 Philip M Jones pjones8@uwo.ca}{...}
{cmd:help ssi}
{hline}

{title:Title}

{p 4 11 2}
{bf:ssi} {hline 2} Sample size and power calculation for balanced two-group randomized controlled
trials (including non-inferiority and equivalence trials){p_end}

{title:Syntax}

{p 8 17 2}
{cmd:ssi} #1 #2 [, {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt sd:1(#)}}standard deviation of sample 1{p_end}
{synopt:{opt sd2(#)}}standard deviation of sample 2{p_end}

{syntab:Options}
{synopt:{opt a:lpha(#)}}significance level of test; default is {bf:alpha(0.05)}{p_end}
{synopt:{opt p:ower(#)}}power of test; default is {bf:power(0.80)}{p_end}
{synopt:{opt n(#)}}number of patients in each group (used when calculating power){p_end}
{synopt:{opt l:oss(#)}}percentage of total sample expected to be lost to follow-up{p_end}
{synopt:{opt c1(#)}}percentage of sample 1 expected to crossover to sample 2{p_end}
{synopt:{opt c2(#)}}percentage of sample 2 expected to crossover to sample 1{p_end}
{synopt:{opt non:inferiority}}use if trial design is non-inferiority{p_end}
{synopt:{opt equ:ivalence}}use if trial design is equivalence{p_end}
{synoptline}

{title:Description}

{pstd}
{opt ssi} is meant to be used by investigators needing sample size estimation for
prospective randomized controlled trials (RCTs). Although Stata ships with a sample size estimation
command ({dialog sampsi:sampsi}), it is not designed to estimate trial sizes for
non-inferiority or equivalence trials.

{pstd}
{opt ssi} allows the estimation of sample size for two {it:balanced} (i.e. the same sample
size for each group) groups for trials whose primary outcomes are either proportions or means.

{pstd}
If {opt sd:1(#)} (with or without {opt sd2(#)}) is specified, {opt ssi} assumes a comparison of
means; otherwise, it assumes a comparison of proportions. {opt ssi} is an immediate
command, and all of its arguments are numbers; see {help immed}.


{title:Details on Syntax}

{pstd}{ul on}{bf:Proportions}{ul off}{p_end}
{phang}1. Two-sample comparison of proportions{p_end}
{pmore}{bf:For sample size calculation}: The {it:postulated} values of the two proportions are {it:#1} and {it:#2}.{p_end}
{pmore}{bf:For power calculation}: The {it:observed} values of the two proportions are {it:#1} and {it:#2}, and the
per-group sample size is entered as {it:n(#)}.{p_end}

{phang}2. Non-inferiority & equivalence trial design (see {help ssi##remarks:remarks}){p_end}
{pmore}{bf:For sample size calculation}: The overall percentage of successes to be expected if the treatments are
equivalent (or non-inferior) is {it:#1}, and the "delta" (minimal important difference to detect)
is {it:#2}. Option {opt non:inferiority} or {opt equ:ivalence} must also be used.{p_end}
{pmore}{bf:For power calculation}: The observed proportion of successes in the comparator group is {it:#1}, the desired
minimal important clinical difference (delta) is {it:#2}, and the per-group sample size is entered as {it:n(#)}.
Option {opt non:inferiority} or {opt equ:ivalence} must also be used.{p_end}

{pstd}{ul on}{bf:Means}{ul off}{p_end}
{phang}1. Two-sample comparison of means{p_end}
{pmore}{bf:For sample size calculation}: The {it:postulated} values of the means are {it:#1} and {it:#2}, and the
postulated standard deviations are {cmd:sd1(#)} and, optionally, {cmd:sd2(#)}.{p_end}
{pmore}{bf:For power calculation}: The {it:observed} values of the means are {it:#1} and {it:#2}, the
{it:actual} standard deviations are {cmd:sd1(#)} and {cmd:sd2(#)}, and the per-group sample size is
entered as {it:n(#)}.{p_end}

{phang}2. Non-inferiority or equivalence trial design (see {help ssi##remarks:remarks}){p_end}
{pmore}{bf:For sample size calculation}: The {it:postulated} values of the means in the two groups are {it:#1} and {it:#2},
(i.e. the minimal important detectable difference [delta] is the difference between the two postulated
means) and the postulated standard deviation (assumed to be the same for each group) is entered as {cmd:sd1(#)}.
Option {opt non:inferiority} or {opt equ:ivalence} must also be used.{p_end}
{pmore}{bf:For power calculation}: The value of the observed mean in the comparator group is entered as {it:#1},
the mean of the other group that reflects the desired minimal important clinical difference (delta)
is entered as {it:#2} (i.e. the difference between #1 and #2 is the desired delta), the standard
deviation of the groups is entered as {cmd:sd1(#)} (enter an average value if the two SDs are not the same),
and the per-group sample size is entered as {it:n(#)}. Option {opt non:inferiority} or {opt equ:ivalence}
must also be used.{p_end}

{title:Options}

{dlgtab:Main}

{phang}
{opt sd1(#)} and {opt sd2(#)} are the standard deviations of population 1 and
population 2, respectively. One or both must be specified when doing a
comparison of means. If only {opt sd1(#)} is specified, {opt ssi} assumes that {opt sd2(#)} = {opt sd1(#)}.
If neither {opt sd1(#)} nor {opt sd2(#)} is specified, {opt ssi} assumes a test of proportions.

{dlgtab:Options}

{phang}
{opt a:lpha(#)} is the significance level of the test.
The default is {cmd:alpha(0.05)}.

{phang}
{opt p:ower(#)} is the power of the test (= 1 - beta). The default is {cmd:power(0.80)}.{p_end}
{pmore}(Note that the default value of 0.80 constitutes a difference from the Stata {cmd:sampsi} command.{p_end}

{phang}
{opt n(#)} is used to calculate power (i.e. if any {opt n} is specified, sample size will
not be calculated, and the {opt power(#)} parameter is ignored). {opt n} is the number of patients in each group.
{opt n} in each group must be equal. (If they are not equal, enter the average size of each group as {opt n}.)

{phang}
{opt l:oss(#)} is the percentage of patients of in the total sample who are
expected to be lost to follow-up. For example, if 15% of patients in a trial
are lost to follow-up, the total sample size needs to be increased to accommodate
the reduction in power that occurs with the loss to follow-up. e.g. {cmd:loss(15)}
{p_end}

{phang}
{opt c1(#)} is the percentage of patients of sample 1 expected to crossover to
sample 2 during the trial. For example, if 5% of patients in one arm of a trial
crossed over to the other group, the total sample size needs to be increased to
accommodate the reduction in power that occurs with the crossover. e.g. {cmd:c1(5)}{p_end}

{phang}
{opt c2(#)} is the percentage of patients of sample 2 expected to crossover to
sample 1 during the trial. See {cmd:c1(#)} above for details.
{p_end}

{phang}
{opt non:inferiority} indicates that you wish to calculate a sample size or power for a
non-inferiority trial. (see {help ssi##remarks:remarks}).
{p_end}

{phang}
{opt equ:ivalence} indicates that you wish to calculate a sample size or power for an equivalence trial. (see {help ssi##remarks:remarks}).
{p_end}

{marker remarks}{...}
{title:Remarks and Background Information}

{dlgtab:Equivalence Trials}

{pstd}
Normally, the null hypothesis for a test statistic is that the two groups tested
represent different samples from the same population (i.e. there is no significant
difference between the groups). However, with equivalence and non-inferiority trial
designs, the null hypothesis is the opposite: that the two groups {bf:are} in fact
different.

{pstd}
The graph below, adapted from Jones B (see {help ssi##references:References}),
demonstrates the confidence interval approach to equivalence testing. Once a
{bf:delta} has been pre-selected, the CI of the difference between treatments is
visualized along the horizontal axis. In an infinitely large trial with infinitely
narrow CIs, if the two treatments are really equivalent, then the difference will
be 0.

{pstd}
If the CI of the difference between treatments lies completely within [-delta to
+delta], then the proposed treatment can be considered to be equivalent to the
comparator. However, as stated by Jones B,

{p 15 15 15 90}
"It is important to emphasise that absolute equivalence can never be demonstrated:
it is possible only to assert that the true difference is unlikely to be outside a
range which depends on the size of the trial, the results of the trial, and the
specified probabilities of error. If we have predefined a range of equivalence as
an interval from -delta to +delta we can then simply check whether the confidence
interval centred on the observed difference lies entirely between -delta and
+delta. If it does, equivalence is demonstrated; if it does not, there is still
room for doubt." (see {help ssi##references:References}).

{pstd}({bf:Note: if the graph below looks strange, re-size your Viewer window so it is wider.}}

{asis}

             |                   |		     |			|    Not equivalent
   	     |			 |		     |			|  <<------------->>
	     |                   |		     |		  Uncertain
   	     |			 |		     |	      <<--------+------->>
	     |			 |		     |	  Equivalent	|
   	     |			 |		     | <<------------>> |
	     |			 |		 Equivalent		|
  	     |			 | 	    <<-------+--------->>	|
	     |   		 |     Equivalent    |			|
   	     |			 |  <<------------>> |			|
	     |		     Uncertain		     |			|
   	     |		<<-------+-------->>	     |	                |
	     |	 Not equivalent	 |		     |			|
   	     + <<------------->> |		     |			|
	     |			 |		 Uncertain		|
    	     +      <<-----------+-------------------+------------------+----------->>
	     |			 |		     |			|
             |                   |		     |                  |                         
             |                   |                   |                  |
             +-------------------+-------------------+------------------+------------------+
			     - delta		     0		    + delta
					Observed treatment difference
{smcl}


{dlgtab:Non-Inferiority Trials}

{pstd}
If we are only interested in ensuring that a proposed treatment (say, a new antibiotic) is
{bf:not worse} than a certain comparator, we can use a non-inferiority approach, where we are
only interested in a one-sided difference. The approach is to first pre-define the smallest
level of inferiority of the proposed treatment (delta), which, if surpassed, would be a
clinically unacceptable difference. If the CI of the difference between treatments lies
completely on one side of delta (in the more favourable direction for the new treatment), then
the proposed treatment can be considered to be non-inferior to the comparator. Examples are
found in the graph below.

{pstd}({bf:Note: if the graph below looks strange, re-size your Viewer window so it is wider.}}

{pstd}
Note: text on graph refers to how the new treatment fares compared to the standard treatment.
Example 1 is clearly worse, as its CI lies completely to the "bad" side of delta. Examples 2 and
8 are uncertain, since their CIs cross both delta and zero. Examples 3 and 4 meet the criteria
for non-inferiority. Examples 5, 6, and 7 meet the criteria, and they also are {bf:superior} to
the comparator, since their CIs exclude no treatment effect in a favourable direction.
{asis}

  1                              		     |			|        Worse
   	     			 		     |			|  <<------------->>
  2	                        		     |		   Uncertain
   	     			 		     |	      <<--------+------->>
  3	     			 		     |	 Non-inferior	|
   	     			 		     | <<------------>> |
  4	     			 		 Non-inferior		|
  	     			  	    <<-------+--------->>	|
  5	        		      Non-inferior   |			|
   	     			   <<------------>>  |			|
  6	     		     Non-inferior	     |			|
   	     		<<--------------->>	     |	                |
  7	     	 Non-inferior	 		     |			|
   	      <<------------->> 		     |			|
  8	     			 		 Uncertain		|
    	             <<------------------------------+------------------+----------->>
	     			 		     |			|
                                		     |                  |                         
                                                     |                  |
             +---------+---------+---------+---------+--------+---------+---------+--------+
			     			     0		      delta
			New treatment better			New treatment worse
					Observed treatment difference
{smcl}


{title:Examples}

{dlgtab:Proportions}

{phang}1. {bf:Two-sample comparison of proportions.} The post-operative myocardial
infarction rate as a baseline is 5.4% (0.054 as a proportion), and a new treatment is
hypothesized to reduce mortality by half to 2.7% (0.027). Calculate the required sample size
with a power of 80% and an alpha of 5%.{p_end}

{phang2}{cmd:. ssi 0.054 0.027}{p_end}

{phang}2. {bf:Non-inferiority trial design.} A new antibiotic was tested against
penicillin for erysipelas. The primary outcome was the clinical cure rate. For the sample size
calculation, the investigators assumed the proportion cured in both arms would be 85%
(pi = 0.85). They considered that a difference in cure rate as large as 10% {it: in favour of penicillin}
would still allow the new antibiotic to be non-inferior (delta = 0.1). Calculate the
sample size based on 90% power to confirm non-inferiority and a one-sided confidence level of
97.5%.{p_end}

{phang2}{cmd:. ssi 0.85 0.10, alpha(0.025) power(0.9) noninferiority}{p_end}

{phang}3. {bf:Equivalence trial design.} Using the same example as above, the investigators
thought that the new antibiotic could also be {it:better} than penicillin, but they were not
sure, therefore they wanted to allow for a two-sided test. Therefore, performing an equivalence
trial allows them to calculate two-sided confidence intervals. They relax their significance
assumption to a more conventional alpha of 0.05.{p_end}

{phang2}{cmd:. ssi 0.85 0.1, p(0.9) equivalence}{p_end}

{phang}4. {bf:Power Analysis.} You read a paper comparing candesartan to ramipril for hypertensive
patients that compared mortality rates at one year. In the candesartan group 2% of people died
by one year, and in the ramipril group 4% died by one year. 400 patients were studied in each group.
What power did the authors have to state that there was no difference between groups?{p_end}

{phang2}{cmd:. ssi 0.04 0.02, n(400)}{p_end}

{dlgtab:Means}

{phang}1. {bf:Two-sample comparison of means.} Serum troponin T in the medication
arm was 2.55 (SD=2.12) while in the cardiac surgery arm troponin T was 3.94 (SD=2.8). Calculate
the required sample size with a power of 80%, alpha of 5%, and an expected loss of followup of
5% of the total sample.

{phang2}{cmd:. ssi 2.55 3.94, sd1(2.12) sd2(2.8) loss(5)}{p_end}

{phang}2. {bf:Same as #1}, except no loss to followup occurred, but 2% of each group crossed
over into the other group, thereby reducing power.

{phang2}{cmd:. ssi 2.55 3.94, sd1(2.12) sd2(2.8) c1(2) c2(2)}{p_end}

{phang}3. {bf:Non-inferiority trial design.} A new inhaler for asthma will be
considered non-inferior to the standard treatment if it does not reduce the morning peak
expiratory flow rate by more than 25 l/min (from a baseline of 450 l/min to 425 l/min). Previous
data suggests that the SD in the trial population will be approximately 40 l/min. Calculate the
required sample size with a power of 80% using a significance level of 2.5% (alpha = 0.025).
(Keep in mind that the absolute values of the baseline and changed measurements do not matter:
only the change and SD are important. This example could just have easily used the range
250 l/min to 225 l/min and obtained exactly the same result.)

{phang2}{cmd:. ssi 450 425, sd1(40) a(0.025) non}{p_end}

{phang}4. {bf:Equivalence trial design.} Using the same values as the previous
example, except this time, we are interested to know if the new inhaler is {it:equivalent}. We
say the new inhaler will be deemed to be equivalent if the morning peak expiratory flow rate is
within +/- 25 l/min of the standard inhaler. Since the absolute values do not matter, we will
use 25 and 0 as our values for {opt #1} and {opt #2} (their order also does not matter). The expected
SD is the same (40 l/min). Significance of 5% and power of 80%.{p_end}

{phang2}{cmd:. ssi 25 0, sd(40) equ}{p_end}

{phang}5. {bf:Power Analysis.} A new anaesthetic is thought to have superior pharmacologic
preconditioning efficacy than the old anaesthetic. The average peak postoperative serum troponin T
was 2.32 (SD=2.01) in the group anaesthetized with the old anaesthetic, while those patients
anaesthetized with the new anaesthetic had an average peak postoperative troponin T of 1.75 (SD=1.52).
100 patients were studied in each group. What power did the researchers have to state that there was no
difference between the two anaesthetics in terms of peak postoperative troponin T levels?{p_end}

{phang2}{cmd:. ssi 2.32 1.75, sd1(2.01) sd2(1.52) n(100)}{p_end}

{marker references}{...}

{title:References:}

{pstd}
1) Jones B, Jarvis P, Lewis JA, Ebbutt AF. Trials to assess equivalence: the importance of
rigorous methods. BMJ 1996;313:36-9.
(i: {browse "http://www.bmj.com/cgi/content/extract/313/7048/36":British Medical Journal link}, ii: {browse "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2351444/pdf/bmj00549-0040.pdf":PDF})


{title:Saved results}

{pstd}
{cmd:ssi} saves the following in {cmd:r()} (some values are not presented when power is calculated):

{synoptset 20 tabbed}{...}
{p2col 5 25 25 2: Scalars}{p_end}

{synopt:{cmd:r(power)}}entered or calculated power{p_end}
{synopt:{cmd:r(adj_ss)}}adjusted sample size (for loss of follow-up and/or crossovers){p_end}
{synopt:{cmd:r(per_group_size)}}sample size for each of the two groups{p_end}
{synopt:{cmd:r(ss)}}total sample size{p_end}
{p2colreset}{...}


{title:Author Information:}

{phang}Philip M Jones, MD FRCPC{p_end}
{phang}Department of Anesthesiology & Perioperative Medicine{p_end}
{phang}Faculty of Medicine & Dentistry{p_end}
{phang}University of Western Ontario{p_end}
{phang}London, Ontario, Canada{p_end}
{phang}pjones8@uwo.ca{p_end}

{title:Change Log:}

{phang}{bf:14 May 2010} - Version 1.0.0{p_end}

{phang2}Initial version published.{p_end}

{title:Also see}

{psee}
Manual:  {manlink R sampsi}

{psee}
{space 2}Help:  {help sampsi:sampsi}
{p_end}
