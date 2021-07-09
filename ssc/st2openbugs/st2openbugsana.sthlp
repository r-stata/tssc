{smcl}
{* *! version 1.1.1 27sep2013}{...}
{viewerjumpto "Syntax" "st2openbugsana##syntax"}{...}
{viewerjumpto "Description" "st2openbugsana##description"}{...}
{viewerjumpto "Options" "st2openbugsana##options"}{...}
{viewerjumpto "Remarks" "st2openbugsana##remarks"}{...}
{viewerjumpto "Examples" "st2openbugsana##examples"}{...}
{viewerjumpto "Stored results" "st2openbugsana##stored_results"}{...}
{viewerjumpto "Author" "st2openbugsana##author"}{...}
{viewerjumpto "References" "st2openbugsana##references"}{...}

{title:Title}

{p2colset 5 23 23 2}{...}
{p2col:{hi:st2openbugsana} {hline 2}}Analysis of OpenBUGS simulations processed
 by {help st2openbugs}{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 8 2}
{cmd:st2openbugsana} {varlist}{cmd:,} [{it:st2openbugsana_options}]

{synoptset 25 tabbed}{...}
{synopthdr:st2openbugsana_options}
{synoptline}
{synopt:{opt t:hin(#)}}Thinning of trace plots; default is {cmd:thin(1)}{p_end}
{synopt:{opt g:rbplot}}Gelman-Rubin-Brooks (GRB) plots{p_end}
{synopt:{opt n:bins(#)}}Number of bins for GRB plot; default is {cmd:nbins(10)}{p_end}
{synopt:{opt s:avegraphs}}Save graphs{p_end}
{synopt:{opt w:dpath(path)}}Path of the directory where graphs are saved and
 log file is located{p_end}
{synopt:{opth p:refix(literal)}}Prefix added to the name of dta and log files
 used and to the name of graphs to be saved.{p_end}
{synoptline}

{pstd}
{varlist} is a list of variables created by the {help st2openbugs} command.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:st2openbugsana} computes numerical summaries and draws plots from the CODA
 output produced by the MCMC simulation performed by OpenBUGS and processed by
 the {help st2openbugs}
 command.{p_end}
 
{marker options}{...}
{title:Options}

{phang}
{opt thin(#)} performs thinning of trace plots, {it:i.e.} for each chain the plot
 is drawn using only every #th value of the simulated sequence starting with the
 first. The default is {cmd:thin(1)}, which amounts to usign all the simulated 
 sequence.

{phang}
{opt grbplot} displays Gelman-Rubin-Brooks (GRB) plots. For details on this plot,
 useful for diagnosing convergence, see {help st2openbugsana##references:Brooks and Gelman (1998)}.

{phang}
{opt nbins(#)} sets the number of bins taken for computing the GRB plot, when
 the {opt grbplot} option has been used. The number of iterations by chain
 (discarding 'burn-in') must be a multiple of its value. The default is 10.

{phang}
{opt savegraphs} saves all the graphs plotted. 

{phang}
{opt wdpath(path)} specifies the path of the directory where the graphs will be 
 saved (if the option {cmd:savegraphs} has been used) and the log file is
 located. Note that (unlike {help st2openbugs}) the tilde (~) can be used to
 refer to the user's home directory.

{phang}
{opth prefix(literal)} specifies the common prefix added to the name of the
 'CODA.dta' and 'log.log' files used (the last one is needed for computing DIC),
 and to the name of the graphs saved if the option {cmd:savegraphs} is used; by
 default names have no prefix.

{marker remarks}{...}
{title:Remarks}

{pstd}
For each node of the {help varlist}, the following summary measures are
 computed from the simulations, and collected in a table: posterior mean and
 standard deviation, Monte Carlo standard error of the mean, 2.5th, 50th (median)
 and 97.5th posterior quantiles, and, if more than one chain has been simulated,
 the corrected scale reduction factor (CSRF). For details on CSRF see {help st2openbugsana##references:Brooks and Gelman (1998)}
 and {help st2openbugsana##references:Gelman and Rubin (1992)}.
 Also included in the ouput is a table with measures which are useful in model 
 comparison (see, for example, {help st2openbugsana##references:Carlin and Louis (2009)}:
 the posterior mean deviance (Dbar), the effective number of parameters (pD) and
 the Deviance Information Criterion (DIC). Actually, the three are read from the
 log file created by OpenBUGS when is called by the related command {cmd:st2openbugs}
 (see {help st2openbugs}).{p_end}
 {pstd}
 Some plots useful in diagnosing convergence are displayed (and optionally saved):
 trace and density plots for each node, and, as an option, Gelman-Rubin-Brooks
 plots. A warning must be given that, when a moderate to large number of nodes
 is monitored, the screen may rapidly become cluttered with plots. The
 functionality of the {help graph combine} command should be enough to permit
 the user to tailor them to his/her needs.{p_end}

{marker examples}{...}
{title:Examples} 

{pstd}
Suppose that the {help st2openbugs##examples:third example} of the help for the
 {help st2openbugs} command has been run. The result is that a) the 'RatsCODA.dta'
 file is saved in the disk and loaded in the memory; and b) the 'Ratslog.log' 
 file is saved (both files located in the default directory set by OpenBUGS).{p_end}
 
{pstd}
Summary tables, and trace and density plots for the first three nodes of 'alpha' 
 and for 'sigma':{p_end}
{pmore}
{stata st2openbugsana alpha_1-alpha_3 sigma, p(Rats): . st2openbugsana alpha_1-alpha_3 sigma, p(Rats)}{p_end}

{pstd}
A GRB plot for 'sigma', taking 20 bins; this and the default trace-density plot
 are saved:{p_end}
{pmore}
{stata st2openbugsana sigma, g n(20) s p(Rats): . st2openbugsana sigma, g n(20) s p(Rats)}{p_end}

{pstd}
Like the previous example, but the trace plot is 'thinned' by considering only
 the first of every 50 values of each chain:{p_end}
{pmore}
{stata st2openbugsana sigma, t(50) g n(20) s p(Rats): . st2openbugsana sigma, t(50) g n(20) s p(Rats)}{p_end}

{pstd}
If the {help st2openbugs##examples:fourth example} of the help for 
 {help st2openbugs} has been run previously, the {opt wdpath(path)} option must
 be used to give the path to the needed files. Also note that a) the
 {opt gbrplot} option cannot be used, because only one chain was simulated, b)
 the plots will be saved in the directory given by the path, and c) since the
 prefix 'Rats' was not added in that example, now it is not needed:{p_end}
{pmore}
{stata st2openbugsana sigma, t(50) s w(~/bugs) : . st2openbugsana sigma, t(50) s w(~/bugs)}{p_end}

{marker stored_results}{...}
{title:Stored results}

{cmd:st2openbugsana} stores the following in {cmd:r()}:

Scalars
{p2colset 5 22 25 2}{...}
{p2col:{cmd:r(nchain)}}number of chains{p_end}
{p2col:{cmd:r(nburnin)}}number of 'burn-in' iterations{p_end}
{p2col:{cmd:r(niteration)}}number of iterations by chain (discarding 'burn-in'){p_end}
	
Macros
{p2col:{cmd:r(varlist)}}nodes monitored{p_end}
	
Matrices
{p2col:{cmd:r(summarymat)}}matrix of summary measures by node, with columns:{p_end}
{p2colset 5 25 25 2}{...}
{p2col:}{it:mean}, mean{p_end}
{p2col:}{it:sd}, standard deviation{p_end}
{p2col:}{it:MC_error}, Monte Carlo standard error of the mean{p_end}
{p2col:}{it:2dot5%}, 2.5%th percentile{p_end}
{p2col:}{it:median}, 50%th percentile or median{p_end}
{p2col:}{it:97dot5%}, 97.5%th percentile{p_end}
{p2col:}{it:CSRF}, (omitted if there is 1 chain) corrected scale reduction factor (CSRF){p_end}
{p2colset 5 22 25 2}{...}	     	     
{p2col:{cmd:r(DIC)}}matrix of deviance-related measures (omitted when Openbugs
 cannot calculate DIC), with columns:{p_end}
{p2colset 5 25 25 2}{...}
{p2col:}{it:Dbar}, mean deviance{p_end}
{p2col:}{it:DIC}, deviance information criterion (DIC){p_end}
{p2col:}{it:pD}, effective number of parameters{p_end}
{p2colset 5 22 25 2}{...}
{p2col:{cmd:r(GRBmatplot)}}matrix (omitted when the {opt grbplot} option is not 
 used) with the information needed for drawing GRB plots; its columns are:{p_end}
{p2colset 5 25 25 2}{...}{p2col:}{it:node}, number coding the node by its position in r(varlist){p_end}
{p2col:}{it:nstart}, starting iteration for each bin{p_end}
{p2col:}{it:CSRF}, CSRF estimate{p_end}
{p2colreset}{...}

{marker author}{...}
{title:Author}

{pstd}Ignacio López de Ullibarri{p_end}
{pstd}Department of Mathematics{p_end}
{pstd}University of A Coruña, Spain{p_end}
{pstd}E-mail: {browse "mailto:ilu@udc.es":ilu@udc.es}{p_end}

{marker references}{...}
{title:References}

{phang}
Brooks SP and Gelman A (1998). General methods for monitoring convergence of
 iterative simulations, {it:Journal of Computational and Graphical Statistics}, 7: 434-455

{phang}
Carlin BP and Louis TA (2009). {it:Bayesian Methods for Data Analysis. 3rd
 Edition}. Boca Raton: Chapman & Hall/CRC

{phang}
Gelman A and Rubin DB (1992). Inference from iterative simulation using multiple
 sequences {it:Statistical Science}, 7:457-472
 
