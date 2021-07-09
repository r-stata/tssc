{smcl}
{* *! version 1.0 01apr2016}{...}
{cmd:help cospectdens}

{hline}

{title:Title}
{phang}

{bf:cospectdens} {hline 2} Compute and graph cross spectral measures between x and y

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmd:cospectdens} 
{varlist} 
{ifin} 
[{cmd:,} 
{it: options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt m:eanadj}} Compute deviation from sample mean default=no{p_end}
{synopt:{opt det:rend}} Detrend variable, default=no{p_end}
	  
{synopt:{opt w:eights}} Weights to be applied in smoothing periodogram; 
      for example: weights(1 2 3 <4> 3 2 1), the number of weights should be odd >1{p_end}

{synopt:{opt k:ernel}} Kernel function,  
		options: daniell, mdaniell, bartlett, parzen, tukey, qs {p_end}

{synopt:{opt b:andwidth}} one-sided lag length for the kernel function {p_end}

{synopt:{opt conv:daniell}} Use weights from the convolution of the uniform (Daniell) weights;
		for example conv(3 2) computes weights by repeated application of 
		uniform weights with lag lengths 3 and 2{p_end} 

{synopt:{opt out}} Create an output data set containing frequency, wavelength,
			periodograms, spectral density, cross-periodogram, cospectrum, coherency-squared,
			amplitude spectrum, phase spectrum, gain spectrum. {p_end}

{synopt:{opt R:eplace}} Replace out.dta dataset if already exists

{synopt:{opt nograph}} No graphical output; 
      Default is to graph coherency-squared {p_end}
{synoptline}

{marker description}{...}
{title:Description}
{pstd}
{cmd:cospectdens} Computes several quantities commonly used in bivariate spectral analysis such as 
cospectrum, coherency-squared, phase spectrum and gain spectrum. varlist accepts two time series: the first variable is 
treated as the output variable (y), and the second variable is treated as the input variable (x). 
Smoothing is directly applied to 
individual periodogram and cross-periodogram obtained from the FFT of variables. 
Endpoints are adjusted cyclically in the central moving average smoothing. 
Users may supply their weights as an option or 
choose one of the weighting schemes. Current version does not apply tapering. 
This command only graphs the coherency-squared which may be 
interpreted as the frequency-domain counterpart of the correlation coefficient. To graph other measures users 
may request them to be saved in an output file.  

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang} 
{opt meanadj} Request mean-adjustment before computing sample spectral
			  density, default = no mean adjustment

{phang} 
{opt detrend} Request detrending data. Residual vector from the regression 
			  of varlist on the linear trend is used in the computations. 
			  Note that data will also be mean-adjusted. Default = no detrend

{phang} 
{opt weights} Odd number of numlist in the form of weights(1 2 3 <4> 3 2 1)
			  Weights are rescaled to sum to 1. 

{phang} 
{opt kernel} String name of the kernel function. One of:
 
			 daniell (this is also known as uniform or truncated weights)
			 
			 mdaniell (modified daniell uses half the uniform weight at the endpoints)
			 
			 bartlett
			 
			 parzen
			 
			 tukey
			 
			 qs (quadratic spectral)

{phang}
{opt bandwidth} One-sided lag window to be used with the kernel function 
			 This option can be used with the kernel option. For example, 
			 when bandwidth(2) the window length is 5 with current periodogram
			 ordinate at the center. If kernel is specified but not the bandwidth 
			 default values are used. 
			 
{phang}
{opt convdaniell} Use weights from repeated application of daniell weights. 
				For example conv(3 3 2) implies repeated smoothing by daniell
				weights with lags 3, 3, and 2. 
	
{phang}
{opt out} Create an output dataset with the name provided in out(string). Out 
	data set contains frequency, wavelength, sine and cosine transformations of each variable, 
	periodogram ordinates of each variable, real and imaginary parts of cross-periodogram,
	cospectrum, quadrature spectrum, coherency-squared, amplitude, phase, and gain spectra. 

{phang}
{opt replace} Replace the out.dta dataset if it already exists.  

{phang} 
{opt nograph} Requests no graphical output. 
      Default is to plot coherency-squared ({it:graph}).

{marker examples}{...}
{title:Examples}

{phang}{stata "webuse lutkepohl" :. webuse lutkepohl}{p_end}
{phang}{stata "cospectdens dlincome dlconsumption, weights(1 2 3 <4> 3 2 1) m" :. cospectdens dlincome dlconsumption, weights(1 2 3 <4> 3 2 1) m}{p_end}
{phang}{stata "cospectdens dlincome dlconsumption, conv(3 2) m" :. cospectdens dlincome dlconsumption, conv(3 2) m}{p_end}
{phang}{stata "cospectdens dlincome dlinvestment, conv(3 2) m" :. cospectdens dlincome dlinvestment, conv(3 2) m}{p_end}


{marker savedresults}{...}
{title:Saved Results}

cospectdens returns:


scalars:
                r(dof) =  equivalent degrees of freedom
                  r(N) =  number of observations
             r(halfbw) =  half bandwidth

macros:
             r(kernel) : kernel type

matrices:
                  r(W) :  weights 
                  r(P) :  floor(N/2)+1 x 11 matrix containing spectral measures

    

{marker references}{...}
{title:References}

P. Bloomfield, Fourier Analysis of Time Series, Wiley, 2nd ed., 2000.
P.J. Brockwell and R.A. Davis, Time Series: Theory and Methods, Springer, 2nd ed., 2006.
J. Hamilton, Time Series Analysis, Princeton, 1st ed., 1994. 
R.H. Shumway and D.S. Stoffer, Time Series Analysis and Its Applications, Springer, 3rd ed., 2011. 

{marker author}{...}
{title:Author}
Hüseyin Tastan (tastan@yildiz.edu.tr)
Yildiz Technical University 
Department of Economics 
Istanbul Turkey
