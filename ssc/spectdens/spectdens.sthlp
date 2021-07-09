{smcl}
{* *! version 1.0 09jan2016}{...}
{cmd:help spectdens}

{hline}

{title:Title}
{phang}

{bf:spectdens} {hline 2} Compute and graph periodogram and sample spectral density

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmd:spectdens} 
{varname} 
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

{synopt:{opt ci:nterval}} Compute and graph 95% confidence interval {p_end}

{synopt:{opt log}} Compute logarithmic sample spectral density{p_end}

{synopt:{opt out}} Create an output data set containing frequency, wavelength;
			periodogram, spectral density{p_end}

{synopt:{opt R:eplace}} Replace out.dta dataset if already exists
			
{synopt:{opt nograph}} No graphical output; 
      Default is to graph periodogram and spectral density {p_end}
{synoptline}

{marker description}{...}
{title:Description}
{pstd}
{cmd:spectdens} Computes sample spectral density (or the smoothed
periodogram) of {varlist}. varlist should 
contain single time series. Users may supply their weights as an option or 
choose one of the weighting schemes. Smoothing is directly applied to 
the periodogram ordinates and endpoints are adjusted cyclically. Periodogram
ordinate at the 0th frequency is not included in the smoothing, instead 1st 
periodogram ordinate is used. But its value is returned in the matrix r(P) and
in the output file. 

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
{opt cinterval} Compute and graph 95% confidence interval around the sample 
				spectral density. Uses equivalent degrees of freedom. Should be 
				interpreted frequency-wise. 
				
{phang}
{opt log} Compute logarithmic sample spectral density.  

{phang}
{opt out} Create an output dataset with the name provided in out(string). Out 
	data set contains frequency, wavelenth, sine transformation, cosine transformation,
	periodogram ordinates, sample spectral density

{phang}
{opt replace} Replace the out.dta dataset if it already exists.  

{phang} 
{opt nograph} Requests no graphical output. 
      Default is to plot sample spectral density ({it:graph}).

{marker examples}{...}
{title:Examples}

{phang}{stata "webuse sunspot" :. webuse sunspot}{p_end}
{phang}{stata "spectdens spot, weights(1 2 3 <4> 3 2 1) m" :. spectdens spot, weights(1 2 3 <4> 3 2 1) m}{p_end}
{phang}{stata "spectdens spot, weights(1 2 3 <4> 3 2 1) m ci" :. spectdens spot, weights(1 2 3 <4> 3 2 1) m ci}{p_end}
{phang}{stata "spectdens spot, conv(3 2) m" :. spectdens spot, conv(3 2) m}{p_end}
{phang}{stata "spectdens spot, weights(1 2 3 <4> 3 2 1) m out(sunspot_spdens)" :. spectdens spot, weights(1 2 3 <4> 3 2 1) m out(sunspot_spdens)}{p_end}
{phang}{stata "use sunspot_spdens" :. use sunspot_spdens}{p_end}
{phang}{stata "tw connected  Spectrum  Period if  Period<50" :. tw connected  Spectrum  Period if  Period<50}{p_end}



{marker savedresults}{...}
{title:Saved Results}

spectdens returns:


scalars:
                r(dof) =  equivalent degrees of freedom
                  r(N) =  number of observations
             r(halfbw) =  half bandwidth

macros:
             r(kernel) : kernel type

matrices:
                  r(W) :  weights
                 r(CI) :  95% confidence interval
                  r(P) :  floor(N/2)+1 x 3: FourierFreq  Period  Periodogram
                  r(S) :  floor(N/2)+1 x 2: naturalfreq  Spectrum


      

{marker references}{...}
{title:References}


{marker author}{...}
{title:Author}
Hüseyin Tastan (tastan@yildiz.edu.tr)
Yildiz Technical University 
Department of Economics 
Istanbul Turkey
