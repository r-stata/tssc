{smcl}
{hline}
Help file for {hi:runmplus} (version 2.0 2013.05.26)
{hline}

{p 4 4 2}
Build a Mplus data file, command file, execute the command file 
and display Mplus log file in Stata results window. Parameter matrices, estimates,
standard errors, and model and fit statistics are stored as saved 
results. {cmd:runmplus} is a modification and extension of Michael Mitchell's 
{help stata2mplus} module (see {browse "http://www.ats.ucla.edu/stat/Stata/"}). The Mplus demo version is supported.

{p 4 4 2}
{cmd: runmplus} requires
{stata "ssc install lstrfun": lstrfun},
{stata "ssc install findname": findname}, and
{stata "ssc install strparse": strparse} to run. These can be obtained
from the ssc (click links to install).

{p 4 4 2}
Keep up-to-date on changes to runmplus, and  
{stata "net install runmplus , from(http://dl.dropboxusercontent.com/u/458793/RUNMPLUS) force": net install runmplus , from(http://dl.dropboxusercontent.com/u/458793/RUNMPLUS) force} (click to run). If
for whatever reason you'd like the old version of runmplus back, visit {browse "http://www.lvmworkshop.org/home/runmplus-stuff/old-runmplus":this web page}.

{hline}

{p 8 17 2}
{cmd: runmplus} varlist [if] [in] , 
 [ 
 {hi:SAVEINPutfile(}{it:string}{hi:)} 
 {hi:SAVELOGfile(}{it:string}{hi:)} 
 {hi:saveinputdatafile(}{it:string}{hi:)}
 {hi:log(}{it:string}{hi:)}
 {hi:TItle(}{it:string}{hi:)} 
 {hi:DATa(}{it:string}{hi:)} 
 {hi:VARiable(}{it:string}{hi:)} 
 {hi:DEFine(}{it:string}{hi:)} 
 {hi:ANalysis(}{it:string}{hi:)} 
 {hi:MOdel(}{it:string}{hi:)}
 {hi:OUTput(}{it:string}{hi:)} 
 {hi:savedata(}{it:string}{hi:)}
 {hi:PLOT(}{it:string}{hi:)}
 {hi:mc(}{it:string}{hi:)}
 {hi:montecarlo(}{it:string}{hi:)}
 {hi:population(}{it:string}{hi:)}
 {hi:TItle(}{it:string}{hi:)} 
 {hi:demo6} 
 {hi:demo7}
 {hi:{it:Mplus_command_option_shortcuts}}
 {hi:{it:Special_postestimation_commands_options}}
 ]

{p 15 15 2}
 {hi:{it:Mplus command option shortcuts:}}

{p 17 17 2}
 {cmd:missing(}{it:#}{hi:)}
 {hi:IDvariable(}{it:string}{hi:)} 
 {hi:NGroups(}{it:string}{hi:)} 
 {hi:CATegorical(}{it:string}{hi:)} 
 {hi:GROUPing(}{it:string}{hi:)} 
 {hi:wgt(}{it:string}{hi:)} 
 {hi:CLUSter(}{it:string}{hi:)} 
 {hi:within(}{it:string}{hi:)} 
 {hi:between(}{it:string}{hi:)} 
 {hi:tscores(}{it:string}{hi:)} 
 {hi:centering(}{it:string}{hi:)} 
 {hi:ttype(}{it:string}{hi:)}

{p 17 17 2}
 {hi:type(}{it:string}{hi:)} 
 {hi:ESTimator(}{it:string}{hi:)} 
 {hi:MATrix(}{it:string}{hi:)} 
 {hi:PARAMeterization(}{it:string}{hi:)}
 {hi:VARiance(}{it:string}{hi:)} 
 {hi:ITERations(}{it:string}{hi:)} 
 {hi:SDITERations(}{it:string}{hi:)} 
 {hi:H1ITERations(}{it:string}{hi:)}
 {hi:MITERations(}{it:string}{hi:)} 
 {hi:MCITERations(}{it:string}{hi:)} 
 {hi:MUITERations(}{it:string}{hi:)} 
 {hi:CONvergence(}{it:string}{hi:)}
 {hi:H1CONvergence(}{it:string}{hi:)} 
 {hi:COVERage(}{it:string}{hi:)} 
 {hi:logcriterion(}{it:string}{hi:)} 
 {hi:MCONVergence(}{it:string}{hi:)}
 {hi:MCCONVergence(}{it:string}{hi:)} 
 {hi:MUCONVergence(}{it:string}{hi:)} 
 {hi:mixc(}{it:string}{hi:)} 
 {hi:mixu(}{it:string}{hi:)}
 {hi:LOGHigh(}{it:string}{hi:)} 
 {hi:LOGLow(}{it:string}{hi:)} 
 {hi:UCELLsize(}{it:string}{hi:)} 
 {hi:ALGOrithm(}{it:string}{hi:)}

{p 17 17 2}
 {hi:SAMPStat} 
 {hi:MODindices(}{it:string}{hi:)} 
 {hi:STANDardized} 
 {hi:RESidual} 
 {hi:CINTerval} 
 {hi:NOCHIsquare}
 {hi:h1se} 
 {hi:H1TEch3} 
 {hi:PATterns} 
 {hi:FSCOEFficeint} 
 {hi:FSDETerminacy} 
 {hi:tech(}{it:string}{hi:)}
 {hi:population(}{it:string}{hi:)}
 {hi:loadresults}
 {hi:varnocheck}


{title:System Set-up}

{p 4 4 2}
Runmplus will try to identify where your Mplus executable is, regardless if you are using a full or demo version. However, a smart way to configure runmplus is to add a line to your profile.do that
identifies the full path, using the short file name, of your Mplus executable, for example:

{p 8 4 2}
{cmd: global mplus_path `"C:\Progra~1\Mplus\mplus.exe"'}

{p 4 4 2}
If you work in a Windows environment. If you work in a MacOS environment, and
have installed in default locations, runmplus will assume

{p 8 4 2}
{cmd: global mplus_path "/applications/mplus/mplus"}

{p 8 4 2}
See {browse "https://sites.google.com/site/ifarwf/home/your-profiledo":here} for more examples.

{p 4 4 2}
Read more about a profile.do files 
{browse "http://en.wikibooks.org/wiki/Stata/Settings#Profile.do":here}, 
{browse "http://www.stata.com/support/faqs/programming/profile-do-file/":here}, 
{browse "http://thedatamonkey.blogspot.com/2011/01/stata-profiledo.html":here}, and
{browse "http://macstata.blogspot.com/2007/11/step-2-setting-up-profiledo-file_28.html": here (for our friends on MacOS)}

{p 4 4 2}
Although programmed in a Windows environment, every attempt has been made
to have {cmd: runmplus} work in a MacOS environment. *Nix should work as 
well.


{title:Required commands}

{p 0 8 2}
{cmd:varlist} - Variables to be used in the Mplus model. This command
is not actually required. If it's left blank runmplus will assume
you want all of the variables, unless there is text in the {hi:MC} or 
{hi:montecarlo} commands. 

{p 8 8 2}
NOTE: This varlist can be a Stata abbreviated 
varlist. But, keep in mind that Mplus and Stata expand varlists differently, 
and what works in Stata may not work in Mplus. For example, the 
abbreviated list y1-x3 will identify to Stata all variables falling 
between and including y1 and x3, and will work as a varlist 
in this command. However, you couldn't use the option 
in a Mplus command (e.g., {hi: cat(y1-x3)}) because Mplus can't expand such a varlist.


{title:Options}

{p 0 8 2}
{cmd:demo6} and {cmd:demo7} - If you have both the demo 
version 6 or 7 and another version of Mplus, {cmd:demo6} 
will force a call to the Mplus demo version 6. 
If you only have the demo version, you do NOT need to 
specify this option. {hi:runmplus} will find the 
right executable so long as they are in the default install 
locations. Specify "demo6" if running the demo version 6 of Mplus. 

{p 0 8 2}
{cmd:missing} - Specify number for missing values, default -9999

{p 0 8 2}
{cmd:SAVEINPutfile(}{it:string}{hi:)} , 

{p 0 8 2}
{cmd:SAVELOGfile(}{it:string}{hi:)} and 

{p 0 8 2}
{cmd:saveinputdatafile(}{it:string}{hi:)} - {cmd:runmplus} 
uses temporary file names to store the Mplus command file 
and data file. By default, these are not saved. If the 
user wishes to have these files to review after execution 
of {hi:runmplus}, file names can be specified 
using the three save options. DOS shell copy 
commands are used and replacement of existing files 
will occur. 

{p 8 8 2}NOTE: do not include the 
suffexes (inp, out, dat).

{p 0 8 2}
{cmd:log(string)} - if "off" is specified, runmplus 
supresses the dump of the Mplus output file 
to the Stata results window. Any other entry will have
no influence on runmplus processing.  Can be used at the 
same time as {cmd:savelogfile}. 

{p 0 8 2}
{hi:{it:Mplus_command_file_options}} - See below and the 
Mplus Users Guide. The Mplus command file options are 
captured as strings and placed into a ascii file that 
is sent to the {it:Mplus} program. You can put anything 
you want in any of these options, but only options that 
make sense to {it: Mplus} will be useful. Modifications or 
special circumstances are addressed in the next section.


{title:Description}

{p 4 4 2}
{cmd:runmplus} brings the powerful latent variable analysis 
capabilities of {it:Mplus} (see www.statmodel.com) into the 
Stata enviroment. While {cmd:runmplus} does little more than 
data reformat and ascii file creation, it removes a lot of 
the hassle of estimating categorical and continuous latent 
variable models using Mplus. {cmd:runmplus} is a 
modification and extension of Michael Mitchell's 
{cmd:stata2mplus} module (see 
http://www.ats.ucla.edu/stat/Stata/). The {cmd:runmplus} 
module does a number of tasks:

{p 4 8 2}
(1) creates an ascii data file suitable for use with Mplus 
using code from stata2mplus, and also 

{p 4 8 2}
(2) creates a mplus command file using options specified, 

{p 4 8 2}
(3) executes the mplus command file using the dos shell 
command feature, and

{p 4 8 2}
(4) dumps the Mplus model results to the screen/log 
(unless directed not to by the user using {cmd:log(off)}), and

{p 4 8 2}
(5) extracts important and/or useful information out of 
the mplus ouput file and makes these available as returned
results (type {cmd: return list} after a {cmd: runmplus} 
command). 

{p 4 4 2}
{it:Mplus} is required to use this Stata module. If you
don't have Mplus, visit {browse "http://www.statmodel.com":www.statmodel.com}.
{cmd:runmplus} can't be used efficiently without an understanding of the Mplus 
command syntax.

{title:Known Bugs and Limitations}

{p 4 4 2}
Long variable names: Mplus does not support long variable names, so neither does {hi:runmplus}. 
Your runmplus/Mplus file will run with a long file name so long as the first 
eight characters are unique. It'd be better to make them short in Stata first.

{p 4 4 2}
{cmd:runmplus} allow you to put code in the Mplus PLOT command, but has no 
way of executing or extracting graphics or data prepared for graphics by Mplus.

{p 4 4 2}
{cmd:runmplus} may have trouble reading parameter estimates when more than 
one latent class variable is used. Use the {hi: saveinp} and {hi: saveinputdatafile }
options and run the model from Mplus.


{title:Examples}

{p 0 8 2}
Simple linear regression for a continuous dependent variable

{p 8 8 2}
. {hi:runmplus y1 x1 x3, model(y1 on x1 x3;)}


{p 0 8 2}
Logistic regression 

{p 8 8 2}
. {hi:runmplus y1 x1 x3, categorical(y1) type(logistic) model(y1 on x1 x3;)}


{p 0 8 2}
Path analysis with continuous dependent variables

{p 8 8 2}
. {hi:runmplus y1-y3 x1-x3, model(y1 y2 on x1 x2 x3; y3 on y1 y2 x2;)}


{p 0 8 2}
Path analysis with categorical dependent variables

{p 8 8 2}
. {hi:runmplus y1-y3 x1-x3, categorical(y1 y2 y3) model(y1 y2 on x1 x2 x3; y3 on y1 y2 x2;)}


{p 0 8 2}
Path analysis with a combination of continuous and categorical dependent variables

{p 8 8 2}
. {hi:runmplus y1-y3 x1-x3, categorical(y3) model(y1 y2 on x1 x2 x3; y3 on y1 y2 x2;)}


{p 0 8 2}
Exploratory factor analysis with continuous indicators

{p 8 8 2}
. {hi: runmplus y1-y12, type(efa 1 4)}


{p 0 8 2}
Exploratory factor analysis with categorical indicators

{p 8 8 2}
. {hi: runmplus y1-y12, type(efa 1 4) categorical(all)}


{p 0 8 2}
Exploratory factor analysis with a mixture of categorical and continuous indicators

{p 8 8 2}
. {hi: runmplus y1-y12, type(efa 1 4) categorical(y1 y3 y5 y7 y9 y11)}


{p 0 8 2}
Confirmatory factor analysis with continuous indicators

{p 8 8 2}
. {hi: runmplus y1-y6, model(f1 by y1-y3; f2 by y4-y6;)}

{p 0 0 2}
Confirmatory factor analysis with continuous indicators 
and equality constraints, using {hi:savedata} 
and {hi:savelogfile} options, and following up 
with {hi: runmplus_load_savedata} bringing the factor 
estimates back into the current data set

{p 8 14 0}
. {hi: runmplus y1-y6 id , idvariable(id) /// }{break}
  {hi: model(f by y1-y6 *1 (1); f@1; [y1-y6 *0] ; y1-y6 *1 (2) ;) /// }{break}
  {hi: savedata(save=fscores; file=c:\trash\trash.dat) /// }{break}
  {hi: savelogfile(c:\trash\trash) } // note no suffix on trash.out

{p 8 14 2}
. {hi: preserve }

{p 8 14 2}
. {hi: runmplus_load_savedata , ///}{break}
  {hi: out(c:/trash/trash.out) clear } // note with suffix on trash.out

{p 8 8 2}
. {hi: id f }{break}
. {hi: sort id }{break}
. {hi: tempfile f1 }{break}
. {hi: save `f1' }{break}
. {hi: restore }{break}
. {hi: merge id using `f1' , sort }{break}
. {hi: table _merge}{break}
. {hi: drop _merge }

{title:Mplus Program Options}

{p 0 8 2}
{hi:{it:Data Options not usually needed}} - The user should
not generally need to specify Mplus DATA "file", 
"format", "type", "nobservations" options. {cmd:runmplus} takes 
care of all of this for you. 

{p 0 8 2}
{hi:NGroups }- number of groups

{p 0 8 2}
{hi:{it:Variable Options not needed}} - Generally, the Mplus "names", 
"useobservations", "usevariables" will not be needed. Use 
the {hi:if} and {hi:in} statements to 
accomplish the same thing as "Useobservations", and you 
must specify a variable list so "Usevariables" is 
assumed to be all of the variables. 

{p 0 8 2}
{hi:categorical }- names of categorical dependent 
variables. Use a string Mplus will understand. 

{p 0 8 2}
{hi:Grouping }- name and label values of grouping variable.
Put text here just like you would after the GROUPING option
in Mplus. For example {hi:{it:grouping(gender(1=male 2=female))}}. 
In the model statement, refer to these groups as you would in Mplus
(eg., model(f by y1 y2; f on x; model male:; f on x; model 
female:; f on x;)). 

{p 8 8 2}
Note the semi-colon after model <group>: This helps runmplus 
parse the command line.

{p 8 8 2}
It is possible you'll get an error message or the grouping
statement won't be parsed correctly, particularly if you have a long
grouping statement. If this happens, try shortening the grouping
statement by using shorter group lablels.

{p 0 8 2}
{hi:DEFINE}- The whole 
point of this program is to allow you to do this kind 
of stuff in Stata. But, if you want it, you can specify
a Mplus option string within the {hi:DEFINE} option and
have Mplus make new variables. This might be useful
if you wanted a new variable in the Mplus analysis
but not as a part of the master data set.

{p 0 8 2}
{hi:type }- refers to "type" option in Mplus ANALYSIS 
command. The default is general. Other options include 
meanstructure, missing, H1, Mcohort, Mixture, Complex, 
Twolevel, EFA # #, Logistic.
      
{p 0 8 2}
{hi:estimator }- Mplus will recognize and implement ML, 
MLM, MLMV, GLS, WLS, WLSM, WLSMV, MLR, MLF, MLM, MLMV, 
ULS estimators if the model type can support it. If 
nothing is specified, the Mplus default estimators 
are used.

{p 0 8 2}
{hi:matrix }- matrix to be evaluated. You can put 
anything you want but Mplus will only 
allow "covariance" or "correlation"

{p 0 8 2}
{hi:tech(}{it:number list}{hi:)} - list in {it:number list} 
the technical output to be displayed (just list the numbers)

{p 2 8 2}
{hi:1 }- parameter specifications and starting values for 
all free parameters.

{p 2 8 2}
{hi:2 }- parameter derivatives.

{p 2 8 2}
{hi:3 }- estimated covariance and correlation matrices 
for the parameter estimates.

{p 2 8 2}
{hi:4 }- means and covariace and correlation matrices 
for the latent variables in the model.

{p 2 8 2}
{hi:5 }- optimization history.

{p 2 8 2}
{hi:6 }- optimization in estimating the sample statistics.

{p 2 8 2}
{hi:7 }- sample statistics for each class 
(when {hi:type(}{it:mixture}{hi:)} is used) using raw 
data weighted by the estimated class probabilities.

{p 2 8 2}
{hi:8 }- optimization history when 
{hi:type(}{it:mixture}{hi:)} is used).

{p 2 8 2}
{hi:9 }- available when MONTECARLO command is 
used when {hi:type(}{it:mixture}{hi:)} is also used, 
and produces error messages regarding convergence 
for each replication of the Monte Carlo study.

{p 2 8 2}
{hi:10 }- used in conjunction with TYPE=MIXTURE to
request univariate and bivariate model fit information 
for the categorical dependent variables in the model. 

{p 2 8 2}
{hi:11 }- used in conjunction with TYPE=MIXTURE request 
the Lo-Mendell-Rubin likelihood ratio test of model fit.

{p 2 8 2}
{hi:12 }- used in conjunction with TYPE=MIXTURE to
request residuals for observed versus model estimated means, 
variances, covariances, univariate skewness, and univariate 
kurtosis. 

{p 2 8 2}
{hi:13 }- used in conjunction with TYPE=MIXTURE to
request two-sided tests of model fit for univariate, 
bivariate, and multivariate skew and kurtosis (Mardia’s 
measure of multivariate kurtosis). 

{p 2 8 2}
{hi:14 }- used in conjunction with TYPE=MIXTURE to
request a parametric bootstrapped likelihood ratio test.


{title:Author/Curator}
{p 4 4 2}Many people have contributed to {cmd: runmplus} since it 
was first introduced, some knowingly like Frances M. Yang, Doug C. 
Tommet, Alden L. Gross, Adam Carle, George Leckie, Tor Neilands, 
Elan Cohen, Betsy Feldman, and others unknowingly (Michael 
Mitchell - thanks for {cmd: stata2mplus}). Also many users' 
comments and suggestions have greatly improved the software. 
To report bugs, request features, or ask questions about 
using runmplus, please feel free to contact me at:

{p 8 8 2}Richard N Jones, ScD{break}
Brown University{break}
{browse "mailto:richard_jones@brown.edu":richard_jones@brown.edu}

{title:News and Updates}
{p 8 8 2}Between SSC posts, updates to {cmd: runmplus} and other Stata+Mplus tools can be obtained from  
{browse "http://lvmworkshop.org/home/runmplus-stuff"} and/or by using the net install commands above.

{p 8 8 2}Users may also wish to subscribe to the runmplus 
mailing list and keep informed about software updates, and 
see/post tips and hints by sending email to 
{browse "mailto:runmplus+subscribe@googlegroups.com":runmplus+subscribe@googlegroups.com} 
and/or visit 
{browse "http://groups.google.com/forum/?fromgroups#!forum/runmplus":the runmplus Google group}.

{title:Also see}

{p 0 19}On-line: help for 
   {help stata2mplus}
   {help runmplus}
   {help runmplus_fits}
   {help read_parameterestimates_general}
   {help read_parameterestimates}
   {help read_convergence}
   {help lli}
   {p_end}
