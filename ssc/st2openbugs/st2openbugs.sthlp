{smcl}
{* *! version 1.1.1 27sep2013}{...}
{viewerjumpto "Syntax" "st2openbugs##syntax"}{...}
{viewerjumpto "Description" "st2openbugs##description"}{...}
{viewerjumpto "Options" "st2openbugs##options"}{...}
{viewerjumpto "Remarks" "st2openbugs##remarks"}{...}
{viewerjumpto "Examples" "st2openbugs##examples"}{...}
{viewerjumpto "Author" "st2openbugs##author"}{...}
{viewerjumpto "References" "st2openbugs##references"}{...}

{title:Title}

{p2colset 5 20 20 2}{...}
{p2col:{hi:st2openbugs} {hline 2}}A simple Interface between Stata and OpenBUGS on Linux{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 6 8 2}
{cmd:st2openbugs}{cmd:,} {it:st2openbugs_required_options} [{it:st2openbugs_other_options}]

{synoptset 28 tabbed}{...}
{synopthdr:st2openbugs_required_options}
{synoptline}
{synopt:{opth m:odel(filename)}}Name of the text file with the OpenBUGS model{p_end}
{synopt:{opth d:ata(filename)}}Name of the text file with the data{p_end}
{synopt:{opt n:chains(#)}}Number of chains to be run{p_end}
{synopt:{opt i:nits(filenamelist)}}Name list of text file(s) with initial values
 of the chain(s){p_end}
{synopt:{opt s:avepars(parlist)}}List of parameters to be saved{p_end}
{synoptline}

{synoptset 28 tabbed}{...}
{synopthdr:st2openbugs_other_options}
{synoptline}
{synopt:{opt w:dpath(path)}}Path of working directory; by default the path set
 by OpenBUGS{p_end}
{synopt:{opt nb:urn(#)}}Number of 'burn-in' iterations; default is
 {cmd:nburn(5000)}{p_end}
{synopt:{opt nu:pdate(#)}}Number of updates after 'burn-in'; default is {cmd:nupdate(20000)}{p_end}
{synopt:{opt p:refix(literal)}}Prefix to be added to files created when running
 the command{p_end}
{synopt:{opth sc:riptname(filename)}}Name of the BUGS script; default is
 'script.txt'{p_end}
{synopt:{opt de:lcodafiles}}Delete auxiliary CODA files needed for creating dta
 file{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:st2openbugs} implements a simple interface between Stata and OpenBUGS 
 ({help st2openbugs##references:Lunn {it:et al.}, 2009}) on Linux. OpenBUGS is
 called with a BUGS script written from within a Stata session. The CODA output
 produced by the MCMC simulation performed by OpenBUGS is reformatted and saved
 as a Stata dta file (note that names of parameters or nodes may result changed
 to conform to Stata syntax; especifically, forbidden characters like '.' or '[' 
 are replaced with underscores, '_'). This allows the use of Stata's capabilities
 to further process the output (see the companion {help st2openbugsana} command).{p_end}
 
{marker options}{...}
{title:Options}

{phang}
{opth model(filename)} specifies the name of the ASCII file containing the
 OpenBUGS model. The model must be defined using BUGS code. A required option.

{phang}
{opth data(filename)} specifies the name of the ASCII file containing the data. 
 The data must be in BUGS format. A required option.

{phang}
{opt nchains(#)} sets the number of chains that will be simulated. A required
 option.

{phang}
{opt inits(filenamelist)} specifies the name list of the ASCII file(s)
 containing the initial values of the chain(s). The file(s) must be in BUGS
 format. A required option.

{phang}
{opt savepars(parlist)} specifies the parameters for which the values of the
 simulated chain(s) will be saved. The 'deviance' node is always saved by default.
 A required option.

{phang}
{opt wdpath(path)} specifies the path of the directory in which a) the model,
 data and initial values are located, b) OpenBUGS will be executed and c) all
 the output files will be saved; if not set, it is the path set by OpenBUGS by
 default (normally the path of the user's home directory). Due to OpenBUGS
 syntax, the path must be fully specified, avoiding the use of the tilde (~) to 
 refer to the home directory. 

{phang}
{opt nburn(#)} sets the number of 'burn-in' iterations discarded at the
 beginning of each chain. The default is {cmd:nburn(5000)}.

{phang}
{opt nupdate(#)} sets the number of MCMC iterations by chain (excluding 
'burn-in'). The default is {cmd:nupdate(20000)}.

{phang}
{opt prefix(literal)} specifies the literal string that will be added as a 
 prefix a) to the name of the OpenBUGS script written, if it is not specified by
 the {cmd: scriptname} option, b) to the name of the CODA and log files created
 by OpenBUGS and c) to the Stata dta file saved, 'CODA.dta'. By default no
 prefix is added.

{phang}
{opth scriptname(filename)} specifies the name of the BUGS script to be written
 and subsequently executed by OpenBUGS. The default name is 'script.txt'.

{phang}
{opt delcodafiles} deletes auxiliary CODA files needed for creating the dta
 file, but not needed for further analysis within Stata.

{marker remarks}{...}
{title:Remarks}

{pstd}
The code is written for OpenBUGS version 3.2.2. This command does not provide any
 facilities for writing model, data, or initialization ASCII files from within
 Stata. To this end, the interested user may find useful some of the Stata
 commands written by {help st2openbugs##references:Thompson {it:et al.} (2006)}.
 The whole set of commands is installed executing in Stata: {cmd:net from website},
 where 'website' is {browse "http://www2.le.ac.uk/departments/health-sciences/research/ships/genetic-epidemiology/software-programs-examples-datasets-and-downloads/winbugsfromstata"}{p_end}

{marker examples}{...}
{title:Examples} 

{pstd}
The files used in these examples are taken from the /doc/Examples directory of
 the OpenBUGS distribution (they can also be copied from {browse "http://www.openbugs.info/Examples/Rats.html"},
 where the data is documented, but note that a typo in line 7 of the model,
 where reads 'culmative' instead of 'cumulative', should be corrected). It is 
 assumed that the BUGS model is saved in 'Ratsmodel.txt', the data in 
 'Ratsdata.txt' and the two files with initial values are 'Ratsinits.txt' and 
 'Ratsinits1.txt'.{p_end}

{pstd}
A MCMC simulation with only one chain, setting the initial values from the
 'Ratsinits.txt' file, and saving parameters 'alpha', 'alpha0' and 'sigma' (note
 that 'alpha' expands to 30 nodes, one for each rat). Files 'Ratsmodel.txt', 
 'Ratsdata.txt' and 'Ratsinits.txt' must be located on the default working
 directory of OpenBUGS, which normally is the user's home directory, {it:e.g.}
 /home/myname:{p_end}
{pmore}
{stata st2openbugs, m(Ratsmodel.txt) d(Ratsdata.txt) n(1) i(Ratsinits.txt) s(alpha alpha0 sigma):. st2openbugs, m(Ratsmodel.txt) d(Ratsdata.txt) n(1) i(Ratsinits.txt) s(alpha alpha0 sigma)}{p_end}

{pstd}
The same, but setting the number of 'burn-in' iterations to 1000 and the number
 of update iterations to 10000:{p_end}
{pmore}
{stata st2openbugs, m(Ratsmodel.txt) d(Ratsdata.txt) n(1) i(Ratsinits.txt) s(alpha alpha0 sigma) nb(1000) nu(10000):. st2openbugs, m(Ratsmodel.txt) d(Ratsdata.txt) n(1) i(Ratsinits.txt) s(alpha alpha0 sigma) nb(1000) nu(10000)}{p_end}

{pstd}
Like the first example, but with 2 chains, whose respective initial values are
 saved in the 'Ratsinits.txt' and 'Ratsinits1.txt' files. Besides, the
 simulations corresponding to the 'alpha0' parameter are not saved, and the
 prefix 'Rats' is added to the name of every file saved:{p_end}
{pmore}
{stata st2openbugs, m(Ratsmodel.txt) d(Ratsdata.txt) n(2) i(Ratsinits.txt Ratsinits1.txt) s(alpha sigma) p(Rats):. st2openbugs, m(Ratsmodel.txt) d(Ratsdata.txt) n(2) i(Ratsinits.txt Ratsinits1.txt) s(alpha sigma) p(Rats)}{p_end}

{pstd}
Like the first example, but the working directory is set to /home/myname/bugs.
 The 'Ratsmodel.txt', 'Ratsdata.txt' and 'Ratsinits.txt' files must be located
 on that directory:{p_end}
{pmore}
{stata st2openbugs, m(Ratsmodel.txt) d(Ratsdata.txt) n(1) i(Ratsinits.txt) s(alpha alpha0 sigma) w(/home/myname/bugs) :. st2openbugs, m(Ratsmodel.txt) d(Ratsdata.txt) n(1) i(Ratsinits.txt) s(alpha alpha0 sigma) w(/home/myname/bugs)}{p_end}

{marker author}{...}
{title:Author}

{pstd}Ignacio López de Ullibarri{p_end}
{pstd}Department of Mathematics{p_end}
{pstd}University of A Coruña, Spain{p_end}
{pstd}E-mail: {browse "mailto:ilu@udc.es":ilu@udc.es}{p_end}

{marker references}{...}
{title:References}

{phang}
Lunn D, Spiegelhalter D, Thomas A and Best N (2009). The BUGS project: Evolution,
 critique, and future directions, {it:Statistics in Medicine}, 28: 3049-3067

{phang}
Thompson J, Palmer T and Moreno S (2006). Bayesian analysis in Stata
 with WinBUGS, {it:The Stata Journal}, 6:530-549
 
