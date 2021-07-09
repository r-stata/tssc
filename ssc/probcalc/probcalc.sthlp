{smcl}
{cmd:help probcalc} 
{hline}

{marker syntax}{title:Title:}

{bf: probcalc: Probability Calculator for Binomial, Poisson, and Normal Distributions}

{marker syntax}{title:Syntax}
{phang}

{cmd: probcalc} {dist param1 param2 param3}{cmd:,} {opt param4 param5} 


{title:Description:}

{p 2 2 2} probcalc calculates the probability mass function for the discrete binomial and Poisson distributions and the probability density function for the continuous normal distribution. 
Output is written to the display in a format useful for learning probability calculations.  {p_end}

{p 2 2 2} The algorithm can handle probability questions pertaining to, for example, "exactly 5 events," "at most 120 events," and "at least 7 events."  {p_end}

    {hline}


{title:Commands for the Binomial Distribution:}

{pstd}Probability of observing exactly x events, P(X=x){p_end}

    {phang2}{cmd: probcalc b} #n #p {cmd: exactly} #x} (Note: bold represents commands and #param represents actual numeric input value){p_end}

{pstd}The probability distribution based on n and p, densities only shown for pmf>0.01{p_end}

	{phang2}{cmd: probcalc b} #n #p {cmd: dist}{p_end}

{pstd}Probability of observing at most x events, P(X<=x){p_end}

    {phang2}{cmd: probcalc b} #n #p {cmd: atmost} #x{p_end}

{pstd}Probability of observing at least x events, P(X>=x){p_end}

	{phang2}{cmd: probcalc b} #n #p {cmd: atleast} #x{p_end}


{title:Commands for the Poisson Distribution:}

{pstd}Probability of observing exactly x events, P(X=x){p_end}

    {phang2}{cmd: probcalc p} #mu {cmd: exactly} #x{p_end}

{pstd}The probability distribution based on mu, densities only shown for pmf>0.01{p_end}

	{phang2}{cmd: probcalc p} #mu {cmd: dist}{p_end}

{pstd}Probability of observing at most x events, P(X<=x){p_end}

    {phang2}{cmd: probcalc p} #mu {cmd: atmost} #x{p_end}

{pstd}Probability of observing at least x events, P(X>=x){p_end}

	{phang2}{cmd: probcalc p} #mu {cmd: atleast} #x{p_end}


{title:Commands for the Normal Distribution:}

{pstd}Probability of observing a value of X between a and b, P(a<=X<b){p_end}

    {phang2}{cmd: probcalc n} #mean #sigma {cmd: between} #a #b{p_end}

{pstd}The probability density within plus-minus 4 standard deviations of a mean (30 bins){p_end}

	{phang2}{cmd: probcalc n} #mean #sigma {cmd: dist}{p_end}

{pstd}Probability of observing an X-value that is at most x, P(X<=x){p_end}

    {phang2}{cmd: probcalc n} #mean #sigma {cmd: atmost} #x{p_end}

{pstd}Probability of observing an X-value that is at least x, P(X>=x){p_end}

	{phang2}{cmd: probcalc n} #mean #sigma {cmd: atleast} #x{p_end}
	



{title:Examples:}


{pstd}A set of measurements for a particular variable follow the binomial distribution with parameters n=15 and p=0.15. What is the probability of occurrence of exactly 5 events, P(X=5)? {p_end}

    {phang2}{cmd: .probcalc b 15 0.15 exactly 5}{p_end}

{pstd}Generate the distribution of binomial variates based on the parameter values n=30 and p=0.35. What is the probability distribution, showing only variates for which pmf>0.01? {p_end}

	{phang2}{cmd: .probcalc b 30 0.35 dist}{p_end}

{pstd}A variable was observed to follow the binomial distribution with n=100 and p=0.17. What is the probability of observing at most 16 events, P(X<=16)?  (16 and less --> left tail){p_end}

    {phang2}{cmd: .probcalc b 100 0.17 atmost 16}{p_end}

{pstd}Quark-gluon collisions were tabulated for a number of identical collider experiments and were found to follow a binomial distribution with n=1500 and p=0.25. What is the chance that at least 375 
collisions would have been observed, P(X>=375)?  (375 and greater --> right tail){p_end}

	{phang2}{cmd: .probcalc b 1500 0.25 atleast 375}{p_end}
	
{pstd}An event occurs at a rate of mu=15 times per day on average. What is the probability of exactly 5 events occuring on any given day, P(X=5)? {p_end}

	{phang2}{cmd: .probcalc p 15 exactly 5}{p_end}
	
{pstd}What is the Poisson probability distribution when mu=10? (Note: only variates for which pmf>0.01 are shown) {p_end} 

	{phang2}{cmd: .probcalc p 10 dist}{p_end}

{pstd}An event occurs on average mu=100 per millisecond. What is the probability of at most 93 events will be observed in a millisecond, P(X<=93)?   (93 and less -> left tail){p_end}

	{phang2}{cmd: .probcalc p 100 atmost 93}{p_end}
	
{pstd}The number of ions that interact within a square centimeter of target material is mu=14.  What is the probability that at least 12 ions will interact in a square centimeter of area, P(X>=12)?  (12 and greater --> right tail){p_end}

	{phang2}{cmd: .probcalc p 14 atleast 12}{p_end}

{pstd}Daily caloric intake among a set of low-fat diet participants was found to be normally distributed with mean 1987 
(calories) and s.d.=52. What proportion of participants would be expected to have daily caloric intake values 
between 1930 and 2040 calories, P(1930<X<=2040)? {p_end} 	

	{phang2}{cmd: .probcalc n 1987 52 between 1930 2040}{p_end}

{pstd}Patient weight measurements indicate a mean of 150 and s.d. of 20.  What is the normal probability density between plus-minus 4 standard deviations of the mean? {p_end} 

	{phang2}{cmd: .probcalc n 150 20 dist}{p_end}

{pstd}Weight of high school students was determined to be normally distributed with mean=128 (lbs) and s.d.=25 (i.e., s.d.). 
 What proportion of students are likely to weigh less than 120 lbs, P(X<=120)?{p_end}

	{phang2}{cmd: .probcalc n 128 25 atmost 120}{p_end}

{pstd}Daily temperature in Houston was determined to be normally distributed with mean=68 and s.d.=16.  What is the 
chance of the temperature being 90F or greater, P(X>=90)? {p_end}

	{phang2}{cmd: .probcalc n 68 16 atleast 90}{p_end}


{pstd}During run-time, output results merely displayed to the screen, for cutting and pasting.   {p_end}


{marker author}{title:Author:}

  {hi:Leif E. Peterson}
  {hi:Associate Professor of Public Health}
  {hi:Weill Cornell Medical College, Cornell University}
  {hi:Center for Biostatistics, The Methodist Hospital Research Institute (TMHRI)}
  {hi:Email: {browse "mailto:lepeterson.tmhs.org":lepeterson@tmhs.org}}


{title:Also see}

{p 4 12 2}Online: {helpb binomialp}, {helpb binomial}, {helpb poissonp}, {helpb poisson}, {helpb normal}.{p_end}

{psee}
{p_end}