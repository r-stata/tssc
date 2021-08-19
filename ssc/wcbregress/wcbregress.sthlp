{smcl}
{hline}
{cmd:help wcbregress}{...} 

{hline}

{title:Title}

{pstd}
{hi:wcbregress} {hline 2}Estimating a Linear Regression Model and Carrying Accurate Inference with Clustered Errors Using the Wild Cluster Bootstrap Standard Errors Procedure and Bootstrap-T procedure. 
 
{title:Descriptions}

{pstd}
The command {hi:wcbregress} estimates a linear regression model with clustered errors and provides accurate inference either when cluster number is large or small, using the method proposed in 	Cameron, A. C., Gelbach, J. B., & Miller, D. L. (2008), "Bootstrap-based improvements for inference with clustered errors". The Review of Economics and Statistics.{p_end}

{pstd}
This command depends on the Stata in-built {hi:regress} command, hence, most of the options for {hi:regress} are compatible with {hi:wcbregress}. (e.g., options for the constant term, for allowing weights, for the level of confidence intervals, and for dialog box)
{p_end}

{pstd}
The output (panel A) of the command provides the results from OLS estimation and inferences using the wild cluster bootstrap standard error procedure discussed in section 3.2 of Colin et al(2008). The inference is valid under standard modelling assumptions. In most cases, it requires the cluster number to be large enough (i.e., greater than 30). 
For the data with fewer clusters, panel B provides a more accurate inference using the bootstrap-t procedure shown in section 3.3 of Colin et al.(2008). Please refer to Cameron, A. C., Gelbach, J. B., & Miller, D. L. (2008) for more details. {p_end}

{title:Syntax}

{phang2}
{cmd:wcbregress}
		{it:  depvar  varlist} 
		{ifin}  [weight]
		[{it:,  options}]

{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt group(varname)}}ID variable for groups within cluster(){p_end}
{synopt :{opt robust}}robust to misspecification{p_end}
{synopt :{opt vce(vcetype)}}vcetype could only be jackknife since cluster is considered during the procedure{p_end}
{synopt :{opt nocon:stant(varname)}}suppress constant term{p_end}
{synopt :{opt h:ascons}}has user-supplied constant{p_end}
{synopt :{opt tsscons}}compute total sum of squares with constant;seldom used{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level to #; default is level(95){p_end}
{synopt :{opt seed(#)}}set random-number seed to #{p_end}

{syntab:Other options}
{synopt :{opt det:ail}}displays intermediate command outputs{p_end}
{synopt :{opt rep(#)}}number of the bootstrap replications for calculating the standard errors or confidence interval; default is 500.{p_end}
{synoptline}

{marker examples}{...} 

{title:Examples} 

{pstd}Setup{p_end}
{p 4 8 2}{stata "clear all":. clear all}{p_end}
{p 4 8 2}{stata "sysuse auto,clear":. sysuse auto,clear}{p_end}

{pstd}Fit the model with the following specification: specify the cluster variable as rep78, set confidence level to 99.{p_end}
{p 4 8 2}{stata "wcbregress price mpg headroom trunk weight, group(rep78) level(99)":. wcbregress price mpg headroom trunk weight, group(rep78) level(99)}{p_end}

{pstd}Set replication times to 50.{p_end}
{p 4 8 2}{stata "wcbregress price mpg headroom trunk weight, group(rep78) rep(50) level(99)":. wcbregress price mpg headroom trunk weight, group(rep78) rep(50) level(99)}{p_end}
 
{pstd}Set random-number seed to 666.{p_end}
{p 4 8 2}{stata " wcbregress price mpg headroom trunk weight, group(rep78) rep(50) level(95) seed(666)":. wcbregress price mpg headroom trunk weight, group(rep78) rep(50) level(95) seed(666)}{p_end}
 
{pstd}Add robust option or noconstant option.{p_end}
{p 4 8 2}{stata " wcbregress price mpg headroom trunk weight, group(rep78) rep(50) level(90) seed(2333) robust":. wcbregress price mpg headroom trunk weight, group(rep78) rep(50) level(90) seed(2333) robust}{p_end}
{p 4 8 2}{stata " wcbregress price mpg headroom trunk weight, group(rep78) rep(80) level(90) seed(2333) noconstant":. wcbregress price mpg headroom trunk weight, group(rep78) rep(80) level(90) seed(2333) noconstant}{p_end}

{pstd}Use weights.{p_end}
{p 4 8 2}{stata " gen n_aweight = ceil(5 * uniform())":. gen n_aweight = ceil(5 * uniform())}{p_end}
{p 4 8 2}{stata " wcbregress price mpg headroom trunk weight [aweight=n_aweight], group(rep78) rep(50) level(95) seed(666)":. wcbregress price mpg headroom trunk weight [aweight=n_aweight], group(rep78) rep(50) level(95) seed(666)}{p_end}

{marker saved_results}{...}

{title:Stored results}

{pstd}{cmd:wcbregress} stores the following in {cmd:e()}:{p_end}
{synoptset 20 tabbed}{...} 
{syntab:Scalars}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(r2)}}R-squared{p_end}
{synopt:{cmd:e(r2_a)}}adjusted R-squared{p_end}
{synopt:{cmd:e(rmse)}}root mean squared error{p_end}

{syntab:Macros}
{synopt:{cmd:e(cmd)}}{hi:wcbregress}{p_end}
{synopt:{cmd:e(vcetype)}}"Wild Cluster Bootstrap SE"{p_end}
{synopt:{cmd:e(title)}}Wild cluster bootstrap SE and T-tests for the linear regression{p_end}
{synopt:{cmd:e(Brep)}}number of bootstrap replications{p_end}
{synopt:{cmd:e(properties)}}“b V”{p_end}

{syntab:Matrices}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance and covariance matrix of the estimator{p_end}
{synopt:{cmd:e(WCB_pvalue)}}p-value of t-test under wild cluster bootstrap{p_end}
{synopt:{cmd:e(WCB_V)}}Variance vector under wild cluster bootstrap{p_end}

{syntab:Functions}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end} 

{title:Authors}

	Zizhong Yan (code maintainer)
	Institute for  Economic  and  Social  Research,  Jinan  University,  Guangzhou,  China
	E-mail: helloyzz@gmail.com.

	Bingkun Lin
        Institute for  Economic  and  Social  Research,  Jinan  University,  Guangzhou,  China
	E-mail:linbingkun.iesr18u@foxmail.com 
	
	E-mail {browse "mailto:helloyzz@gmail.com":helloyzz@gmail.com} if you observe any problems.
 
{title:References}

{p 0 2}
Cameron, A. C., Gelbach, J. B., & Miller, D. L. (2008). Bootstrap-based improvements for inference with clustered errors. The Review of Economics and Statistics, 90(3), 414-427.
{p_end}



































 