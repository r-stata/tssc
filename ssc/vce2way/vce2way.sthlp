{smcl}
{* 23June2019/}{...}
{cmd:help vce2way}
{hline}

{title:Title}

{p2colset 8 18 20 2}{...}
{p2col :{hi: vce2way} {hline 2} A one-stop solution for robust inference with two-way clustering}{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:vce2way}
{it:cmdline_main}
{cmd: ,}
{opt cl:uster(varname1 varname2)}
[{it:cmdline_options}]

{title:Description}

{pstd}{it:Notes:} As of June 2019, {cmd:vce2way} has been superseded by {search vcemway:{bf:vcemway}} that allows for robust inference with m-way clustering, where m is 2 or larger.

{pstd}{cmd:vce2way} is a module to adjust an existing Stata estimation command's standard errors for two-way clustering in {it: varname1} and {it:varname2}. 
The module works with any Stata command which allows one-way clustering in each dimension separately via built-in {cmd:vce(cluster } {it:varname}{cmd:)} option. 
The results are compatible with the underlying command's postestimation tools that make use of {cmd: ereturn} matrix {cmd:e(V)} including {helpb test}, {helpb nlcom}, {helpb margins} to name a few.    
 
{pstd} In the required option {opt cl:uster(varname1 varname2)}, {it: varname1} and {it:varname2} are the names of variables identifying two clustering dimensions. 
In the remaining syntax diagram, {it:cmdline_main} ({it:cmdline_options}) is the non-optional (optional) component of the command line to execute a command 
for which two-way clustering is requested. For specific examples, see below. 

{pstd} Perhaps the easiest way to understand {cmd: vce2way}'s syntax diagram is by posing the following question. 
If Stata had built-in {opt cl:uster(varname1 varname2)} option to request two-way clustering, what command line would the researcher specify? Prefixing the answer to this question by {cmd: vce2way} satisfies the syntax requirements. 

{pstd} As Cameron et al. (2011) show, two-way clustered variance-covariance matrix V_twoway can be derived as:

{phang2} {it:V_twoway} = {it:V_1} + {it:V_2} - {it:V_12}

{pstd} where {it:V_1}, {it:V_2} and {it:V_12} are variance-covariance matrices adjusted for one-way clustering in {it: varname1}, {it:varname2} and their intersection respectively. 
Two-way clustered standard errors are the square roots of the diagonal elements of {it:V_twoway}. 

{pstd} To obtain {it:V_1}, {it:V_2} and {it:V_12}, {cmd:vce2way} repeats the relevant estimation run (i.e. {it:cmdline_main} [{cmd:,} {it:cmdline_options}]) three times. 
The resulting {it:V_twoway} is saved in {cmd:e(V)}. 
For commands which can be executed within a few seconds, this repeated estimation approach is unlikely to be an issue. 
For commands which require numerical optimization of advanced non-linear models, for example {helpb asroprobit}, this can be a source of major inconvenience if not practical infeasibility. 
If needed, the researcher may save computer run time by using {cmd:from()} or {cmd: init()} option in conjunction with {cmd:vce2way}, to start the three estimation runs from   
an optimal solution computed prior to executing {cmd:vce2way}. See the {helpb clogit} example below.  

{pstd} Cameron et al. (2011) point out that in some applications, {it:V_twoway} may not be positive semi-definite. 
As a solution, they suggest that the researcher may replace negative eigenvalues of {it:V_twoway} with 0s, and reconstruct the variance-covariance matrix 
using the updated eigenvalues and the original eigenvectors. Where applicable, {cmd:vce2way} applies this method and displays an appropriate notice. 

{pstd} In terms of small sample bias corrections to the variance-covariance matrices, {cmd:vce2way} is like {cmd:cgmreg} of Gelbach and Miller (2009). 
Specifically, {cmd: vce2way} applies the first correction method of Cameron et al. (2011, p.241) which adjusts each of the three one-way clustered matrices separately 
according to the number of clusters affecting that matrix. As Baum et al. (2010) point out, their {helpb ivreg2} applies the second method of Cameron et al. (2011, p.241) 
which adjusts all three matrices by a common factor based on the number of clusters in either {it:varname1} or {it:varname2}, depending on which is smaller. 
This potential variation in bias correction methods should be kept in mind when comparing the output of {cmd:vce2way} with that of other user-written commands 
which implement two-way clustering. 

{title: Examples}

{pstd} In all examples below, there is only a small number of clusters in the second dimension, {cmd:year}. 
As Baum et al. (2010) point out in the context of their {help ivreg2}, the results should be interpreted with caution: {it:V_twoway}  is consistent when 
the sizes of clusters in both {it:varname1} and {it:varname2} become arbitrarily large. 

{pstd} OLS regression with two-way clustering:

{phang2}{cmd:. webuse nlswork, clear} {p_end}

{phang2}{cmd:. vce2way regress ln_wage age grade, cluster(idcode year)} {p_end}

{pstd} Random-effects GLS regression with two-way clustering:

{phang2}{cmd:. webuse nlswork, clear} {p_end}

{phang2}{cmd:. vce2way xtreg ln_wage age grade, cluster(idcode year) re nonest} {p_end}

{pstd} Probit with two-way clustering. By default, iteration logs are suppressed. Use {helpb noisily} to display them.

{phang2}{cmd:. webuse union, clear} {p_end}

{phang2}{cmd:. vce2way probit union age grade, cluster(idcode year)} {p_end}

{phang2}{cmd:. vce2way noisily probit union age grade, cluster(idcode year)} {p_end}

{pstd} Fixed-effects logit with two-way clustering and user-supplied starting values to save run time:

{phang2}{cmd:. webuse union, clear} {p_end}

{phang2}{cmd:. clogit union age grade not_smsa, group(idcode)} {p_end}

{phang2}{cmd:. matrix start = e(b)} {p_end}

{phang2}{cmd:. vce2way clogit union age grade not_smsa, cluster(idcode year) group(idcode) nonest from(start)} {p_end}

{title:Stored results}

{pstd}{cmd:vce2way} adds the following to {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N_clust1)}}number of clusters in {it:varname1}{p_end}
{synopt:{cmd:e(N_clust2)}}number of clusters in {it:varname2}{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(vce2way)}}yes{p_end}
{synopt:{cmd:e(clustvar1)}}{it:varname1}{p_end}
{synopt:{cmd:e(clustvar2)}}{it:varname2}{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(V_raw)}}initial non-psd {it:V_twoway} in case its negative eigenvalues have been replaced to construct final {cmd:e(V)}{p_end} 

{p2colreset}{...}

{title:References}

{phang}
Baum, C.F., M.E. Schaffer, and S. Stillman. 2010. ivreg2: Stata module for extended instrumental variables/2SLS, GMM and AC/HAC, LIML and k-class regression. http://ideas.repec.org/c/boc/bocode/s425401.html.

{phang}
Cameron, A. C., J.B. Gelbach, and D.L. Miller. 2011. Robust Inference With Multiway Clustering. {it:Jorunal of Business and Economic Statistics} 29(2): 238-249.

{phang}
Gelbach, J.B., and D.L. Miller. 2009. Multi-way clustering with OLS. http://faculty.econ.ucdavis.edu/faculty/dlmiller/statafiles/.

{title:Author}

{pstd}Dr. Hong Il Yoo{p_end}
{pstd}Durham University Business School{p_end}
{pstd}Durham University{p_end}
{pstd}Durham, UK{p_end}
{pstd}h.i.yoo@durham.ac.uk{p_end}

{title:Also see}

{p 7 14 2}
Help:  {helpb ivreg2} (if installed), {helpb vce_option}
{p_end}
