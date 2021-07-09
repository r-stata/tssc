{smcl}
{* 23dec2014}{...}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:artsurvdlg} {hline 2}}ART (Survival Outcomes) - Sample Size and Power dialog{p_end}
{p2colreset}{...}


{title:General remarks}

{p 4 4}
This dialog acts as an easy-to-use "front end" to the Stata program {cmd:artsurv}.
You should be aware, 
however, that {cmd:artsurv} can do more than the dialog offers. For example, there is
a facility to save survival probabilities and hazard ratios to a new file for plotting,
and there are some additional options that are not accessible from the dialog. All of
these are described in the help file on {help artsurv}. It is easy to use the dialog
to create the equivalent {cmd:artsurv} command and then edit the command and re-run
it. This allows the creation of command files (through logging of output), and also
gives access to the extra options just mentioned.


{title:Panel 1: Basic set-up and options}

{p 0 4}
{cmd:Number of periods} (default 1) The number of notional time periods of equal 
			length over which the trial is to be run, i.e. the duration of
			the trial in unspecified units. The default is 1.
			Typically the length of the trial may exceed the
			duration of recruitment. Patients may be followed up
			after recruitment is complete and before definitive
			analysis of the data. Then more than one period is
			needed, e.g. recuitment for one year and follow-up for
			two further years would require you to specify the
			number of periods to be at least 3. This option also
			allows specification of details such as hazard ratios
			which vary with time and other advanced features.
			The choice of how long in real time one period lasts is
			up to you and will be chosen in line with the
			anticipated characteristics of the study.

{p 4 4}
			It may be wise to select a finer time-scale than the one that
			appears natural at first sight. For example, most cancer trials
			are planned on a scale of years, but a scale of quarters
			or even months may have advantages; for example, it allows
			greater detail on the projected survival
			curves in each group (given in the output from {cmd:artsurv}).
			It may be useful later in projections of patients, power
			and events in "what if?" calculations (see for example
			help on {help artpep}). See {cmd:Time unit} for further
			details of available time-scales.

{p 4 4}
			Note that once you have selected a time-scale and number of
			periods, several items in the design depend on the choices, and
			changing the time-scale must be done with care since it is easy
			inadvertently to introduce errors. It is better to plan
			with a finer time-scale in the first place.
{p_end}

{p 0 4}
{cmd:Number of groups} (default 2, max. 6) Number of arms in the clinical trial.
{p_end}

{p 0 4}
{cmd:Time unit} (default 1) The unit of time representing one period. The options
			are given in the list box (default one year). The time unit
			selected does not alter the calculations but is used
			to label the output.
{p_end}

{p 0 4}
{cmd:Alpha} (default 0.05, two-sided) The Type 1 error probability for the trial. One-sided
			alpha values may be imposed by checking the "One-sided alpha" box.
			With one-sided alpha the significance level
			used by the program is doubled, resulting in a larger power or
			smaller sample size. This option should be used with caution.
{p_end}

{p 0 4}
{cmd:Median survival time} Checking this box allows you to enter the time for 50%
			of patients in group 1 to have experienced an event. Time
			is in the same units as the periods (see "Time unit" above).
			Non-integer times are allowed. Checking this box
			prevents data on cumulative survival or failure probabilities
			being entered. These probabilities are calculated from the 
			supplied median survival time, assuming an exponential survival
			distribution in group 1.{break}

{p 4 4}
			Note that if you know the median survival time in group 2 (or 3, or 4, ...), you
			can calculate the hazard ratio (HR) as HR = (median in group 1)/ 
			(median in group 2) and enter this value in panel 2. 
			The calculation assumes exponential survival distributions in each
			group and must be done manually. There is currently no facility
			for entering median survival times for groups other than group 1.
{p_end}

{p 0 4}
{cmd:Power or N} (default power 0.8) The program can be used to calculate the sample size
			for a given power (the default), or the power for a given sample size
			(specified by checking the radio button "Specify sample size" in the "Options" area).
{p_end}

{p 0 4}
{cmd:Baseline survival or failure probabilities} The baseline cumulative probability
			of survival or of failure at the end of each period,
			with "period" as just 
			defined. Typically, this will be the distribution in
			the control arm of the trial. In the simplest case,
			you give just one value, which is taken as the 
			cumulative survival or failure probability at the end of the
			trial. To specify values e.g. for periods 1 and 2, say
			of 0.8 and 0.5 respectively, enter as {cmd:1 2} in
			{cmd:At the end of period(s)}. Values for any subset of periods may be specified.
			The radio buttons in the "Options" area allow you to specify
			whether the values you have entered are survival
			probabilities (the default) or failure probabilities.
{p_end}

{p 0 4}
{cmd:Non-inferiority design} In a non-inferiority design one wishes to test whether the effects of the
			experimental treatment is not inferior to the control treatment by more than a
			a prespecified amount. In the calculations the roles of the null
			and alternative (alternate) hypotheses are reversed. That is,
			the sample size is calculated with signficance level equal to
			1-power and power equal to 1-alpha. By default, a two-sided alpha
			is used. In many cases the preferred approach is to set a one-sided
			alpha level, and then the {cmd:One-sided alpha} box should be ticked.
			A side-effect of the reversal of power and alpha is that
			the program is not able to compute the power of a non-inferiority
			design for a given sample size. However, the power can still be determined
			by trial and error, by repeatedly entering alpha and power until the desired
			sample size is achieved.
{p_end}

{p 0 4}
{cmd:One-sided alpha} (default two-sided) See {cmd:Alpha} above.
{p_end}


{title:Panel 2:Hazard ratios and allocation ratios}

{p 0 4}
{cmd:Choose treatment group} This listbox selects the group for entry of Hazard ratios, Allocation
			ratios and (where the Trend option is selected) Doses.
			Defaults are provided for group 1 and for allocation ratios.
			Values of hazard ratios must be entered for all groups other
			than 1.
{p_end}

{p 0 4}
{cmd:Hazard ratios} In the simplest case, you specify a single hazard
			ratio (HR) for failure for each group, with the default HR=1 for
			group 1 (the control group). If desired, you may
			specify as many hazard ratios as there are periods;
			this allows you to design a trial in which non-proportional
			hazards are expected. If for a given group
			you enter fewer HRs than the number of periods, the
			remaining HRs are taken as the last specified HR.
			If you do not specify an HR for a particular group,
			its value in a given period is
			taken to be the geometric mean of the HRs specified for the
			same period across all the groups for which you have
			entered a value.
{p_end}

{p 0 4}
{cmd:Allocation ratios} By default, all groups are assumed of equal size, so
			the allocation ratios (more precisely, weights) are
			all equal to 1. You can vary this, e.g. assigning 
			allocation ratio 1 to group 1 and 2 to group 2 would
			specify that group 2 should have twice as many
			patients allocated as group 1.
{p_end}

{p 0 4}
{cmd:Trend} Implements a design assuming a linear trend test across the groups, with
			scores 1, 2, 3,... attached to the groups. A trend
			test may be more powerful than a general comparison
			between the groups. See also {cmd:Dose}, which allows you to change
			the scores or doses.
{p_end}

{p 0 4}
{cmd:Dose} Dose is a quantity assigned to each group which represents the
			dose of some medication or other intervention received
			by the subjects in that group. If you specify a dose
			level for any group, you must specify a level for
			every group. If you ask for a trend design (see {cmd:Trend})
			and do not specify dose levels, the latter are taken
			to be the numbers 1, 2, 3, ... and represent the doses for
			groups 1, 2, 3, ... respectively. The assigned doses depend
			on the specific design and need to be chosen
			carefully.
{p_end}


{title:Panel 3:Patient recruitment and Model options}

{p 0 4}
{cmd:Duration} (default 0 periods) specifies the duration of recruitment.
			The maximum duration of recruitment is the number of
			periods specified in {cmd:Number of periods} (panel 1). The minimum
			duration is 0, in which case recruitment
			is assumed to be complete at the start of the trial.
			When the duration>0 is specified, recruitment is assumed
			to occur at a uniform rate for the number of periods
			specified, and then stop.
{p_end}

{p 0 4}
{cmd:Proportion recruited at start} (default 0) Sometimes you may have
			patients already available for randomization
			at the start of the trial. The proportion of the total
			sample size represented by this group of patients may be specified here.
			The default of 0 assumes that all patients are recruited
			in a "staggered entry" pattern - the usual situation.
{p_end}

{p 0 4}
{cmd:Unequal weights} (default Equal weights over periods) If you check this radio button,
			you may then enter values which represent the relative numbers of
			patients recruited in each period (the so-called "period weights").
			This is a powerful option important for prospective and
			retrospective calculations. For example, you may expect to recruit
			say half as many patients in the first year (period) than in subsequent
			years; you would specify {cmd:Unequal weights} as {cmd:0.5 1}
			(or equivalently, as {cmd:1 2}, and so on). Or, you may want to
			enter the actual number of patients recruited so far, to perform
			"what if?" calculations. If you put fewer values than there are
			periods, the remainder are assumed equal to the last value you 
			entered.
{p_end}

{p 0 4}
{cmd:Exponential accrual} (default uniform accrual) The shape of the recruitment 
			distribution can be altered to negative exponential by checking this
			button. You then enter the rate in each period.
{p_end}

{p 0 4}
{cmd:Local and distant alternatives} (default local). This is a rarely used setting which
			determines the way the program calculates under the alternative hypothesis.
			It usually affects the resulting power or sample size very little.
			You are only likely to wish to specify distant alternatives
			if the target hazard ratio(s) are very far from 1, e.g. < 0.4.
{p_end}

{p 0 4}
{cmd:Method of sample size calculation} (default unweighted logrank test) This refers to the
			statistical model used in the computations. It is unusual that
			you would depart from the default logrank test.
			There are four additional options. Alternatives to the standard
			logrank test are the Tarone-Ware test, which is logrank with weights
			proportional to the square root of the total number at risk at event times,
			Harrington-Fleming, which is logrank with weights proportional to S^I, where
			S is the estimated pooled survival function at event times and I is
			the index for Harrington-Fleming weights (see option index()),
			a binomial test conditional on the proportion of failures at the end of
			the study, using Peto's approximation to the log odds ratio, and an
			unconditional binomial test.
			Note that values other than 1 of the index I for the Harrington-Fleming test
			are available only through the {cmd:index()} option of {help artsurv}
			and must be invoked by issuing a {cmd:artsurv} command.
{p_end}

{p 0 4}
{cmd:Additional details in output} provides event-rate and other information calculated by the program.

{p 0 4}
{cmd:Save using filename} allows certain results to be saved to a Stata file for plotting etc.
			Details are given under {it:Remarks} in {help artsurv}.
{p_end}

{title:Advanced options}

{p 0 4}
{cmd:Loss to follow-up} The cumulative distribution function of time to loss
			to follow-up. You may enter the cumulative proportion
			of patients lost to to follow-up by the end of each
			period. In the simplest case, you give just one value,
			which is taken as the cumulative probability of loss
			to follow-up at the end of the last period. To specify
			values e.g. for periods 1 and 2, say of 0.05 and 0.1
			respectively, enter as {cmd:1 2} in {cmd:At the end of period(s)}. 
			Values for any subset of periods may be specified. 
{p_end}

{p 0 4}
{cmd:Withdrawal from allocated treatment} The cumulative distribution function of time to 
			withdrawal from allocated treatment (cross-over). You
			enter values in the same way as for loss to follow-up.
			The failure time distribution after cross-over is
			specified by either the post-withdrawal hazard ratio
			function or the target group upon cross-over. The
			radio buttons allow you to choose which you wish to
			enter. 
{p_end}

{p 0 4}
{cmd:Hazard ratios post-withdrawal} For each arm subject to cross-over, you enter the
			post-withdrawal hazard ratio function (relative to the
			hazard of the baseline (control) failure time
			distribution). You may enter as many values as there
			are periods. If the number of values entered is less
			than the number of periods, then the last HR value
			applies to the remaining periods.  
{p_end}

{p 0 4}
{cmd:Target group on cross-over} For each arm subject to cross-over, enter the target
			group number. By default, group 1 crosses over to
			group 2 and all other groups cross over to group 1.  
{p_end}


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

    Manual:  {hi:[R] sampsi},  {hi:[R] stpower}

{p 4 13 2}
Online:  help for {help artbin}, {help artsurv}, {help artmenu}, {help artpep}
