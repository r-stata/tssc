{smcl}
{* *! version 1.0.0  4sept2020}{...}
{cmd:help spnorm} 
{hline}

{title:Title}

{p2colset 5 15 20 2}{...}
{p2col :{hi: spnorm} {hline 1}}Shaded Percentiles of Normal Distributions {p_end}
{p2colreset}{...}

{title:Syntax}


{p 8 17 2}
{cmd:spnorm}
[{it:mean#1 sd#1] [mean#2 sd#2] ... }
[ {cmd:,} {opt fc:olor(string)} {opt xt:itle(string)} {opt yt:itle(string)}  {opt t:itle(string)} {opt sav:ing(filename)} ] 

{title:Description}

{pstd}
{opt spnorm} graphs the probability density function of normal distributions upon specification of one or more sets of means and standard deviations. The command is taking advantage of the Stata 16/python interaction. The following packages need to be installed: matplotlib, numpy, scipy, statistics available at {browse "https://pypi.org/"}.

{title:Options}

{dlgtab:Options}

{phang}
{opt fc:olor(string)} specifies the color of the distribution. The default is blue. Otherwise, specify as many colours as the specified sets of means and standard deviations. Named colors are listed in {browse "https://matplotlib.org"}.

{phang}
{opt xt:itle(string)} specifies the title for the x-axis. Latex is allowed within dollar signs.

{phang}
{opt yt:itle(string)} specifies the title for the y-axis. Latex is allowed within dollar signs.

{phang}
{opt t:itle(string)} specifies the title for the figure. Latex is allowed within dollar signs.

{phang}
{opt sav:ing(filename)} saves the graph to disk. Supported formats: PNG (.png), JPEG (.jpg), PDF (.pdf), BMP (.bmp), TIFF (.tif), EPS (.eps), and KML (.kml).
The default file format is PNG (.png).  

{title:Examples}

{phang2}{bf:// Graph the probability density function of a standard normal distribution}

{phang2}{stata "spnorm"}{p_end}

{phang2}{bf:// Overlay two (theoretical) sampling distributions of a sample proportion (n=100) under two data generating mechanisms (theta=0.1 and theta=0.2)}

{phang2}{stata "spnorm .1 .03 .2 .04, fcolor(aqua lime)"}{p_end}

{phang2}{bf:// Add some explanations to the figure}

{phang2}{stata "spnorm .1 .03 .2 .04, fc(aqua lime) yt(Sampling distribution) xt(Sample proportions $\hat\theta$ under $\theta=[0.1, 0.2]$) t($ \hat \theta \sim \mathcal{N}(\theta,\, \sqrt{\frac{\theta(1-\theta)}{n}})$)"}{p_end}

{phang2}{bf:// Save the figure as pdf in the working directory}

{phang2}{stata "spnorm .1 .03 .2 .04, fc(aqua lime)  y(Sampling distribution)  xt(Sample proportions $\hat\theta$ under $\theta=[0.1, 0.2]$)  t($\hat\theta\sim\mathcal{N}(\theta,\, \sqrt{\frac{\theta(1-\theta)}{n}})$) sav(fig.pdf)"}{p_end}

{phang2}{bf:// Overlay 9 sampling distributions of a sample proportion (n=100) under a data generating mechanisms where theta = [.1, .2, ..., .9] }

{phang2}{stata "spnorm  .1 0.030  .2 0.040  .3 0.046  .4 0.049  .5 0.050  .6 0.049  .7 0.046  .8 0.040  .9 0.030, fc(navy blue darkviolet pink gold orange red sienna green)"}{p_end}

{title:Author}

{p 4 8 2}Nicola Orsini, Biostatistics Team,
Department of Global Public Health, Karolinska Institutet, Sweden{p_end}

{title:Support}

{p 4 8 2}{browse "http://www.stats4life.se"}{p_end}
{p 4 8 2}{browse "mailto:nicola.orsini@ki.se?subject=spnorm":nicola.orsini@ki.se}{p_end}

 
