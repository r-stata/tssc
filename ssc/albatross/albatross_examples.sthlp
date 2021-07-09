{smcl}
{* 13jan2017}
{* 13jun2017}{...}
{cmd:help albatross_examples}
{hline}

{title:Albatross Examples}

{phang}
{bf:albatross examples} {hline 2} The code used to simulate {cmd: albatross} examples (see {help albatross})

{title:Mean}

{p 4 4 2}
Basic albatross plot

	. {stata clear}
	. {stata set obs 20}
	. {stata set seed 100}
	. {stata gen n = 10+490*runiform()}
	. {stata gen mean_dif = 0.2*runiform()}
	. {stata gen sd = 1+4*runiform()}
	. {stata gen se = sd/sqrt(n)}
	. {stata gen p = 2*normal(-abs(mean_dif/se))}
	. {stata albatross n p mean_dif, type(mean) sd(sd)}
		
{p 4 4 2}
Use the standard deviation to adjust to the effective sample size

	. {stata albatross n p mean_dif, type(mean) sd(sd) adjust}

{title:Proportion}

{p 4 4 2}
Basic albatross plot

	. {stata clear}
	. {stata set obs 20}
	. {stata set seed 100}
	. {stata gen n = 10+490*runiform()}
	. {stata gen prop_dif = 0.1+0.1*runiform()}
	. {stata gen se = sqrt(prop_dif*(1-prop_dif)/n)}
	. {stata gen p = 2*normal(-abs(prop_dif/se))}
	. {stata albatross n p prop_dif, type(proportion)}

{p 4 4 2}
Plot specifying the proportion to be 0.15 in all contours

	. {stata albatross n p prop_dif, type(proportion) spro(0.15)}

{title:Correlation coefficient} – equivalently, {title:beta}

{p 4 4 2}
Basic albatross plot

	. {stata clear}
	. {stata set obs 20}
	. {stata set seed 100}
	. {stata gen n = 10+490*runiform()}
	. {stata gen corr = 0.2*runiform()}
	. {stata gen se = sqrt((1-corr^2)/n)}
	. {stata gen p = 2*normal(-abs(corr/se))}
	. {stata gen by = "Large"}
	. {stata replace by = "Small" if corr<0.1}
	. {stata albatross n p corr, type(correlation)}

{p 4 4 2}
Plot split by “large” and “small” in color

	. {stata albatross n p corr, type(correlation) by(by) color}

{title:Mean difference}

{p 4 4 2}
Basic albatross plot, assuming only the mean difference and standard deviation are known

	. {stata clear}
	. {stata set obs 20}
	. {stata set seed 100}
	. {stata gen n = 10+490*runiform()}
	. {stata gen sd1 = 0.5+0.5*runiform()}
	. {stata gen sd2 = 0.5+0.5*runiform()}
	. {stata gen r = 1+3*runiform()}
	. {stata gen n1 = r*n/(1+r)}
	. {stata gen n2 = n/(1+r)}
	. {stata gen sd = sqrt((sd1^2*n1+sd2^2*n2)/n)}
	. {stata gen md = 0.1+0.1*rnormal()}
	. {stata gen se = sqrt(sd1^2/n1 + sd2^2/n2)}
	. {stata gen p = 2*normal(-abs(md/se))}
	. {stata albatross n p md, type(md) sd(sd)}

{p 4 4 2}
Use the standard deviation of both groups and proportion of cases to controls to estimate the effective sample sizes

	. {stata albatross n p md, type(md) sd1(sd1) sd2(sd2) r(r) adjust}

{p 4 4 2}
Define the contours better

	. {stata albatross n p md, type(md) sd1(sd1) sd2(sd2) r(r) adjust contours(0.2 0.4 0.6)}	

{title:Standardised mean difference}

{p 4 4 2}
Basic albatross plot

	. {stata clear}
	. {stata set obs 20}
	. {stata set seed 100}
	. {stata gen n = 10+490*runiform()}
	. {stata gen smd = -0.5+0.25*runiform()}
	. {stata gen r = 1+3*runiform()}
	. {stata gen se = sqrt((2*(r+1)^2+r*smd^2)/(2*r*n))}
	. {stata gen p = 2*normal(-abs(smd/se))}
	. {stata gen range = 1 if p >0.1}
	. {stata replace p = 0.1 if p > 0.1}
	. {stata albatross n p smd, type(smd)}

{p 4 4 2}
Plot with range specified, so lines are produced for studies with P > 0.1

	. {stata albatross n p smd, type(smd) range(range)}

{p 4 4 2}
Plot with titles, range, two contours specified

	. {stata albatross n p smd, type(smd) contours(0.25 0.5) range(range) title("When P values are inexact, data simulated", size(medium))}
	
{p 4 4 2}
Plot with titles, range and restricted to n > 250 in the first 10 studies	
	
	. {stata albatross n p smd if n > 250 in 1/10, type(smd) contours(0.25 0.5 1) range(range) title("When P values are inexact (restricted), data simulated", size(small))}
	
{p 4 4 2}
No plot, but display Fisher's and Stouffer's combined P values	
	
	. {stata albatross n p smd, type(smd) nograph fishers stouffers}	

{title:Relative risks and odds ratios}

{p 4 4 2}
Basic albatross plot

	. {stata clear}
	. {stata set obs 20}
	. {stata set seed 100}
	. {stata gen a = 300+200*runiform()}
	. {stata gen b = a*1.5}
	. {stata gen c = 300+200*runiform()}
	. {stata gen d = 300+200*runiform()}
	. {stata gen n = a+b+c+d}
	. {stata gen rr = a*(c+d)/(c*(a+b))}
	. {stata gen or = a*d/(b*c)}
	. {stata gen n1 = a+b}
	. {stata gen n2 = c+d}
	. {stata gen baseline = c/(c+d)}
	. {stata gen r = n1/n2}
	. {stata gen se_rr = sqrt(1/a+1/c-1/n1-1/n2)}
	. {stata gen se_or = sqrt(1/a+1/b+1/c+1/d)}
	. {stata gen p_rr = 2*normal(-abs(ln(rr)/se_rr))}
	. {stata gen p_or = 2*normal(-abs(ln(or)/se_or))}
	. {stata replace p_or = 10^-30 if p_or == 0}
	. {stata gen e = 1 if ln(rr) >= 0}
	. {stata replace e = -1 if e == .}
	. {stata gen by = 1 if a > 400}
	. {stata replace by = 0 if a <= 400}
	. {stata albatross n p_rr e, type(rr) baseline(baseline)}
	. {stata albatross n p_or e, type(or) baseline(baseline)}
	
{p 4 4 2}
Fully specified plot with estimated effective sample size
	
	. {stata albatross n p_rr e, type(rr) baseline(baseline) r(r) adjust}
	. {stata albatross n p_or e, type(or) baseline(baseline) r(r) adjust}
	
{p 4 4 2}
Fully specified plot with estimated effective sample size, with standardised r and baseline specified, split into two variables and in color

	. {stata albatross n p_rr e, type(rr) baseline(baseline) r(r) adjust sr(2) sbaseline(0.5) by(by) color}
	. {stata albatross n p_or e, type(or) baseline(baseline) r(r) adjust sr(2) sbaseline(0.5) by(by) color}

{title:Authors}

{p 4 4 2}
Sean Harrison ({browse "mailto:sean.harrison@bristol.ac.uk":sean.harrison@bristol.ac.uk}). School of Social and Community Medicine, University of Bristol, Canynge Hall, Whiteladies Road, Bristol BS8 2PS, UK

{title:References}

{p 4 4 2}
Harrison, S., Jones, H.E., Martin, R.M., Lewis, S., Higgins, J.P.T.
The albatross plot: a novel graphical tool for presenting results of diversely reported studies in a systematic review. 
{it:Harrison S, Jones HE, Martin RM, Lewis SJ, Higgins JP. The albatross plot: a novel graphical tool for presenting results of diversely reported studies in a systematic review. Res Synth Methods. 2017}.

{p 4 4 2}
Harrison, S., Jones, H.E., Martin, R.M., Lewis, S., Higgins, J.P.T. 2017. 
The albatross plot program: a novel graphical tool for presenting results of diversely reported studies in a systematic review in Stata. 
{it:Currently Unpublished}.
