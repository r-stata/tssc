{smcl}
{* 10aug2020/13aug2020}{...}
{hline}
help for {hi:mycolours} 
{hline}

{title:Set a palette of colours through local macros}

{p 8 17 2}
{cmd:mycolours}
[
{cmd:,}
{cmd:show} 
]

{p 8 17 2}
{cmd:mycolors}
[
{cmd:,}
{cmd:show} 
]


{title:Description}

{p 4 4 2}
{cmd:mycolours} or {cmd:mycolors} defines a series of local macros
containing RGB triples which define a colour palette suggested by Okabe
and Ito (2008).  The idea is that it should be easier to (recall and)
type the local macro names than to (recall and) type the RGB triples.

{p 4 4 2} 
The following local macros are defined. Defining each colour using two
macro names is not a matter of principle. 

	OK1 230 159 0 
	ora 230 159 0
	OK2 86 180 233 
	sky 86 180 233	
	OK3 0 158 115
	bgr 0 158 115
	OK4 240 228 66 
	yel 240 228 66 
	OK5 0 114 178 
	blu 0 114 178 
	OK6 213 94 0 
	ver 213 94 0 
	OK7 204 121 167 
	rpu 204 121 167 
	OK8 0 0 0 
	bla 0 0 0

{p 4 4 2}The following longer names may be helpful:  

	ora means orange 
	sky means sky blue 
	bgr means bluish green 
	yel means yellow 
	blu means blue
	ver means vermilion 
	rpu means reddish purple 
	bla means black 

{p 4 4 2}When using the local macros, double quotation marks {cmd:" "}
should be added. See the Examples below. Some readers will wonder why
such quotation marks are not included as a part of each definition. The
explanation is that this would frustrate the application of transparency
(added in Stata 15).


{title:Remarks} 

{p 4 4 2} 
People preferring or accustomed to the American spelling "colors" may
type that in the command name {cmd:mycolors}. They should feel free to
substitute that mentally when reading this help or in extreme cases to
edit this file to their taste for personal or local use. Once you edit
any file in this package, the package becomes yours and you are
responsible for any problems. 

{p 4 4 2} 
This is an example command, indicative and not definitive. The command
as written for SSC defines a series of local macros for a series of
colours as suggested by Okabe and Ito (2008) and publicised in many
places since, for example by Wong (2011) (without attribution) and by
Wilke (2019) (with full attribution). In practice these colours are
friendly to many people who have some difficulty distinguishing colours.
Such difficulties are often informally if imprecisely and insensitively
called "colour-blindness". The most common and most widely discussed
challenge is distinguishing red and green. The colours in this palette
often work well together, especially for bar charts or other displays
where large patches of strong primary colours may seem unsubtle or even
aggressive. 

{p 4 4 2}In the terminology of Brewer (2016) (see also or instead 
{browse "https://colorbrewer2.org":https://colorbrewer2.org}) 
this colour scheme is qualitative, not sequential (to encode values that run
from low to high) or diverging (to encode values that run from strong negative
to strong positive). Sequential and diverging schemes are much easier to think
up on the fly (which shouldn't discourage and doesn't disparage code to
pre-define them). See, however, comments on rainbow or spectral schemes such as
those of Light and Bartlein (2004). 

{p 4 4 2}
Similar ideas are used by others. For example, Hastie, Tibshirani and
Friedman (2009) and Knaflic (2015) emphasise that blue and orange can go
well together. 

{p 4 4 2}
This is not in competition with the deeper and wider idea that you may
encapsulate your colour and other graph style preferences in a defined
graph scheme. 

{p 4 4 2}
The use of local macros calls forth the following comments. 

{p 8 8 2}
1. This command may be reissued at any time to allow users to remind
themselves of the local names. 

{p 8 8 2}
2. As the command overwrites any local macros with the same names you
will lose any definitions in the same namespace with different meanings. 

{p 8 8 2}
3. Given the nature of local macros, you not only can but must reissue
this command if working in a different namespace. In particular, a
do-file or program you use or write will not be able to see the local
macros defined in another place, such as a main interactive session or
another do-file or program. This is a standard feature of local macros,
and indeed why they are, as named, local in scope. If desired, see a
longer story at Cox (2020). 

{p 8 8 2}
If #2 sounds like a problem, #3 is the solution. Local macro definitions
are constructive and destructive only within the same namespace.
Alternatively, if you are in habit of (say) using local macro names like
{cmd:OK1} but find this command helpful, you may be well advised to edit
the files to do something different. 

{p 8 8 2}
4. Stata programmers may wish to note within the program code the use of
the non-documented command {cmd:c_local}. 


{title:Options}

{p 4 8 2}
{cmd:show} draws a sample bar chart showing the colours defined. Any
data in memory are {cmd:preserve}d and {cmd:restore}d. 


{title:Examples}

{p 4 4 2}You need to run {cmd:mycolours} first so that local macros are defined. 

{p 4 8 2}{cmd:. mycolours}{p_end}
{p 4 8 2}{cmd:. mycolours, show}{p_end}
{p 4 8 2}{cmd:. macro list}{p_end} 

{p 4 4 2}Now you can invoke those macros in graph commands. 
 
{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. scatter mpg weight, mc("`ora'")}{p_end}
{p 4 8 2}{cmd:. scatter mpg weight if foreign, mc("`OK1'") || scatter mpg weight if !foreign, mc("`OK2'") legend(order(1 "Foreign" 2 "Domestic"))}{p_end}
{p 4 8 2}{cmd:. scatter mpg weight if foreign, mc("`OK1'%50") || scatter mpg weight if !foreign, mc("`OK2'%50") legend(order(1 "Foreign" 2 "Domestic"))}{p_end}


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University{break} 
         n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}Eric Melse made helpful comments on this help. 


{title:References}

{p 4 8 2}
Brewer, C.A. 2016. 
{it:Designing Better Maps: A Guide for GIS Users.} 
Redlands, CA: Esri Press. 

{p 4 8 2}
Cox, N.J. 2020. Stata tip 138: Local macros have local scope. 
{it:Stata Journal} 20: 499{c -}503.      

{p 4 8 2}
Hastie, T.J., R.J. Tibshirani and J.H. Friedman. 2009.  
{it:The Elements of Statistical Learning: Data Mining, Inference, and Prediction.}  
New York: Springer.

{p 4 8 2} 
Knaflic, C.N. 2015. 
{it:Storytelling with Data: A Data Visualization Guide for Business Professionals.} 
Hoboken, NJ: John Wiley. 

{p 4 8 2}
Light, A. and P.J. Bartlein. 2004. 
The end of the rainbow? Color schemes for improved data graphics. 
{it:Eos} 85(40): 385 and 391. 
{browse "https://agupubs.onlinelibrary.wiley.com/doi/epdf/10.1029/2004EO400002":https://agupubs.onlinelibrary.wiley.com/doi/epdf/10.1029/2004EO400002}

{p 4 8 2}
Okabe, M. and K. Ito. 2008. 
Color Universal Design (CUD): How to make figures and presentations that are friendly to colorblind people. 
{browse "http://jfly.iam.u-tokyo.ac.jp/color":http://jfly.iam.u-tokyo.ac.jp/color}
or 
{browse "http://jfly.uni-koeln.de/color/":http://jfly.uni-koeln.de/color/}

{p 4 8 2}
Wilke, C.O. 2019. 
{it:Fundamentals of Data Visualization: A Primer on Making Informative and Compelling Figures.} 
Sebastopol, CA: O'Reilly. 

{p 4 8 2}
Wong, B. 2010. Color coding. {it:Nature Methods} 7: 573. 
{browse "https://www.nature.com/articles/nmeth0810-573.pdf":https://www.nature.com/articles/nmeth0810-573.pdf} 
  
{p 4 8 2}
Wong, B. 2011. Color blindness. {it:Nature Methods} 8: 441. 
{browse "https://www.nature.com/articles/nmeth.1618.pdf":https://www.nature.com/articles/nmeth.1618.pdf}


