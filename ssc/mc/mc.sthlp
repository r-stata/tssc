{smcl}
{* *! version 1.0 Chao Wang 21/07/2017}{...}
{cmd:help mc}
{hline}

{title:Title}

{pstd}{hi:mc} {hline 2} Calculate the matched concordance index

{title:Syntax}

{pstd}{cmd:mc} {depvar} {indepvars} {ifin} [{cmd:,} {it:options}]

{pstd}{cmd:by} is allowed

{title:Description}

{pstd}{cmd:mc} calculates the matched concordance index (mC) proposed by Brentnall et al. [1].

{title:Options}

{pstd}{opt group(varname)} specifies the grouping variable. {opt brep:s(integar)} 
specifies the number of bootstrap replications for calculating confidence intervals; 
the default is 1000. {opt noboot:strap} requests bootstrap not to be performed.

{title:Stored Results}

{pstd}The mC is stored as a r-class object. Confidence intervals from bootstrap
are saved as e-class objects.

{title:Examples}

{phang}{stata "webuse lowbirth2, clear": . webuse lowbirth2, clear}{p_end}
{phang}{stata "clogit low lwt smoke ptd ht ui i.race, group(pairid)": . clogit low lwt smoke ptd ht ui i.race, group(pairid)}{p_end}
{phang}{stata "predict phat": . predict phat}{p_end}
{phang}{stata "mc low phat, group(pairid)": . mc low phat, group(pairid)}{p_end}
{phang}{stata "roctab low phat": . roctab low phat}{p_end}

{title:Acknowledgement}

{pstd} This command is based on ARB's R code.

{title:Reference}

{pstd} [1] A. R. Brentnall, J. Cuzick, J. Field, and S. W. Duffy, "A concordance index for matched case-control studies with applications in cancer risk," Statistics in Medicine, vol. 34, pp. 396-405, Feb 10 2015.

{title:Author}

{pstd}Chao Wang, BEng MSc DIC PhD, Statistician, Queen Mary University of London,
excelwang@gmail.com.
