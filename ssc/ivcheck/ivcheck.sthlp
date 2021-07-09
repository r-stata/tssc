{smcl}
{* 18nov2011}{...}
{hline}
{hi:help ivcheck}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col:{hi:ivcheck} {hline 2}}Choices between IV versus OLS{p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 4 2}Full syntax

{p 8 14 2}{cmd:ivcheck} {it:depvar} [{it:varlist1}]
{cmd:(}{it:varlist2}{cmd:=}{it:varlist_iv}{cmd:)}
{ifin}
{weight}
{bind:[{cmd:,} {cmd:SAVing(}{it:string}{cmd:)}}
{cmdab:LOW(}{it:#}{cmd:)}
{cmdab:HIgh(}{it:#}{cmd:)}
]

{p 4 4 2}All {it:varlist}s may contain time-series operators; 
see {it:{help varlist}}.

{p 4 4 2}{cmd:aweight}s, and {cmd:fweight}s are allowed; see {help weight}.


{title:Contents}

{pstd}{help ivcheck##s_description:Description}{p_end}
{pstd}{help ivcheck##s_options:Options summary}{p_end}
{pstd}{help ivcheck##s_macros:Saved results}{p_end}
{pstd}{help ivcheck##s_examples:Examples}{p_end}
{pstd}{help ivcheck##s_refs:References}{p_end}
{pstd}{help ivcheck##s_acknow:Acknowledgments}{p_end}
{pstd}{help ivcheck##s_citation:Authors}{p_end}
{pstd}{help ivcheck##s_citation:Citation}{p_end}


{marker s_description}{title:Description}

{p 4 4 2}{cmd:ivcheck} produces a phase diagram that can be used to assess the question 
whether the mean squared estimation error with IVs will be larger than that from OLS 
given the data at hand. Specifically, given a reasonable lower bound for the OLS bias, 
one can confirm whether the IV at hand can produce a better estimate (i.e. with lower bias) 
of the true effect parameter than the OLS, without knowing the true level of 
contamination in the IV


{marker s_options}{title:Options}

{p 4 8 2}{cmd:saving({it:string})} requests that the phase plot be saved using the path/filename 
specified in {it:string}.

{p 4 8 2}{low(#)} specifies the lower bound on the X-axis on the phase plot. Default in -1.

{p 4 8 2}{high(#)} specifies the higher bound on the X-axis on the phase plot. Default in 1.


{marker s_macros}{title:Saved results}

{pstd}{cmd:ivcheck} saves the following results in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(cuoff_rho_xe)}}the upper or lower bound of Corr(X,e) beyond which IV at hand is better({p_end}
{synopt:{cmd:e(rho_zy_x)}}partial Corr (Z,Y | X W){p_end}
{synopt:{cmd:e(rho_xz)}}Corr(X, Z){p_end}

{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}



{marker s_examples}{title:Examples}

{p 8 12 2}{stata "ivcheck y (x=z)" :. ivcheck y (x=z)}{p_end}
{p 8 12 2}{stata "ivcheck y w (x=z)" :. ivcheck y w (x=z)}{p_end}




{marker s_refs}{...}
{title:References}

{pstd} 4.	Basu A. Chan KCG. Can we make smart choices between OLS versus Contaminated IV estimators? Health Economics  2014; 23(4):462-72.


{marker s_acknow}{title:Acknowledgments}
{pstd} The author acknowledges support from the National Institute of Health Research Grants, RC4CA155809 and R01CA155329.


{title:Authors}

	Anirban Basu, University of Washington, USA
	basua@uw.edu


{marker s_citation}{title:Citation}

{pstd}{cmd:ivcheck} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}


{title:Also see}

{psee}Online:  {helpb ivregress}, {helpb newey};
{helpb overid}, {helpb ivendog}, {helpb ivhettest}, {helpb ivreset},
{helpb xtivcheck}, {helpb xtoverid}, {helpb ranktest},
{helpb condivreg} (if installed);
{help est}, {help postest};
{helpb regress}{p_end}
