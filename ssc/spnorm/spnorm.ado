*! v.1.0.0 Orsini N 2020sept4
capture program drop spnorm
program spnorm, rclass
version 16
syntax [anything] [ , FColor(string) XTitle(string) YTitle(string) Title(string) SAVing(string asis)  * ]

local nr : word count `anything'
local nc : word count `fcolor'

tempname mean sd 

local nrp = `nr'/2

python: import matplotlib.pyplot as plt
python: plt.close('all')
python: import __main__

if ("`ytitle'"=="") local ytitle "Distribution"

if ("`fcolor'" != "") & (`nr' != 0) {
	if (`nrp' != `nc') {
			di as err "specify a colour for each of the normal curve"
			exit 198
	} 
}

if mod(`nr',2) != 0 {
		di as err "specify an even sequence of mean and std deviation"
}

if (`nr' == 0)  {
	scalar `mean' = 0
	scalar `sd' = 1
	local nrp = 1
	if "`fcolor'" != "" local col : word 1 of `fcolor'
	else local col "b"
	quietly python: shaded_normal_pdf("`mean'", "`sd'", "`col'")
}

tokenize `anything'
if (`nr' != 0)  {
	local j = 1
	forv i = 1/`nrp' {
		scalar `mean' = ``j++''
		scalar `sd' = ``j++''
		return scalar mean`i' = `mean'
		return scalar mean`i' = `mean'
		return scalar sd`i' = `sd'
		if "`fcolor'" != "" local col : word `i' of `fcolor'
		else local col "b"
		quietly python: shaded_normal_pdf("`mean'", "`sd'", "`col'")
	}
}

quietly python: plt.show()
if "`saving'" != "" quietly python: plt.savefig("`saving'")
end

version 16
python:
from sfi import Scalar, Macro
import numpy as np
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings("ignore")
from scipy.stats import norm
from statistics import NormalDist
from matplotlib import colors as mcolor
plt.rcParams['figure.titlesize'] = 16
plt.rcParams['legend.fontsize'] = 12
plt.rcParams['axes.labelsize'] = 12
plt.rcParams['xtick.labelsize'] = 12
plt.rcParams['ytick.labelsize'] = 12

def shaded_normal_pdf(mean, sd, col):
  	mean = Scalar.getValue(mean)
	sd = Scalar.getValue(sd)
	s_ytitle = Macro.getLocal('ytitle')
	s_xtitle = Macro.getLocal('xtitle')
	s_title = Macro.getLocal('title')	
	min = mean-3*sd
	max = mean+3*sd	
	left_p = np.arange(5, 51, 5)
	right_p = np.arange(95, 49, -5)
	shade  = np.arange(.1, 1.1, (1-0)/len(left_p))
	xs = np.linspace(min, NormalDist(mean, sd).inv_cdf(5/100), num=10)
	fig = plt.figure(num=1, figsize=(6,5))
	ax = fig.add_subplot(111)
	ax.fill_between(xs, 0, norm.pdf(xs, loc=mean, scale=sd) , color=col, alpha=0.09, linewidth=0.0)

	for c, p in enumerate(left_p):
		a = NormalDist(mean, sd).inv_cdf(p/100)
		b = NormalDist(mean, sd).inv_cdf((p+5)/100)
		xs = np.linspace(a, b, num=10)
		ax.fill_between(xs, 0, norm.pdf(xs,loc=mean, scale=sd), color=col, alpha=shade[c], linewidth=0.0)

	for c, p in enumerate(right_p):
		a = NormalDist(mean, sd).inv_cdf(p/100)
		b = NormalDist(mean, sd).inv_cdf((p-5)/100)
		xs = np.linspace(a, b, num=10)
		ax.fill_between(xs, 0, norm.pdf(xs,loc=mean, scale=sd) , color=col, alpha=shade[c],linewidth=0.0)

	xs = np.linspace(NormalDist(mean, sd).inv_cdf(95/100), max, num=10)
	ax.fill_between(xs, 0, norm.pdf(xs,loc=mean, scale=sd) , color=col, alpha=0.09, linewidth=0.0)
	
	ax.set_ylabel(s_ytitle)
	ax.set_xlabel(s_xtitle)
	ax.set_title(s_title)
	ax.spines['top'].set_visible(False)
	ax.spines['right'].set_visible(False)
end


exit

local n = 100
local lm ""
local ln `""'
local lc "" 
tokenize "navy blue darkviolet purple gold orange red sienna brown "

forv i = 1/9 {
	local theta`i' = `i'/10
    local se_hat_theta`i' = sqrt(`theta`i''*(1-`theta`i'')/`n')
	local ln `"`ln' `: di `theta`i''  " " %4.3f `se_hat_theta`i'' " " '"'
	local lm "`lm' `theta`i''"
	local lc "`lc' ``i''"

	
}

di "`ln'" 
di "`lc'"
spnorm `ln' , fc(`lc') 
exit

spnorm .1 .03 .2 .04, fcolor(b r)  ytitle(Sampling distribution) xtitle(Sample proportion $ \hat \theta $)  title( $ \hat \theta \sim \mathcal{N}(\theta,\, \sqrt{\frac{\theta(1-\theta)}{n}}) $ )

exit

spnormal , fc(r) ///
title( $\frac{1}{\sigma \sqrt{2\pi}}  e^{\frac{(\theta)^2 }{ 2\sigma^2}}$ $ \sigma=\sqrt{\frac{\theta(1-\theta)}{n}}$  ) ///
 xtitle($ \hat \theta $)  
 exit

* Examples

spnorm .1 .03 .2 .04, fcolor(g r)  ytitle(Sampling distribution) xtitle($ \hat \theta $)  title( $ \hat \theta \sim \mathcal{N}(\theta,\, \sqrt{\frac{\theta(1-\theta)}{n}}) $ )



exit 

/// 
 ytitle("Sampling distribution of a proportion") ///
 xtitle($ \hat \theta $) 
 
 exit 


spnorm , ///
ytitle($ f(Z) = \frac{1}{{\sqrt {2\pi } }}e^{ - \frac{{Z^2 }}{2}} $) ///
xtitle($ Z $) ///
title("Standard Normal Distribution $\mu=0$  $\sigma=1$") ///
fcolor(aqua)

exit
spnorm,  xtitle($ X \sim \mathcal{N}(\mu,\,\sigma) $)

exit


* Examples 

spnormal , fc(r) ///
title( $\frac{1}{\sigma \sqrt{2\pi}}  e^{\frac{(\theta)^2 }{ 2\sigma^2}}$ $ \sigma=\sqrt{\frac{\theta(1-\theta)}{n}}$  ) ///
 xtitle($ \hat \theta $)  
exit


local theta1 = 0.1
local n = 100
local se_hat_theta1 = sqrt(`theta1'*(1-`theta1')/`n')

local theta2 = 0.2
local se_hat_theta2 = sqrt(`theta2'*(1-`theta2')/`n')

local theta3 = 0.3
local se_hat_theta3 = sqrt(`theta3'*(1-`theta3')/`n')

spnormal `theta1' `se_hat_theta1'  `theta2' `se_hat_theta2' `theta3' `se_hat_theta3' , fcolor(g w r) saving(figure1.png) /// 
 ytitle("Sampling distribution of a proportion") ///
 xtitle($ \hat \theta $) ///
title( $\frac{1}{\sigma \sqrt{2\pi}}  e^{\frac{(\hat \theta -\theta)^2 }{ 2\sigma^2}}$ $ \sigma=\sqrt{\frac{\theta(1-\theta)}{n}}$  )


