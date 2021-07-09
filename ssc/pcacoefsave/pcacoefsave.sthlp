{smcl}
{* 27nov2014/29may2015}{...}
{hline}
help for {hi:pcacoefsave}
{hline}

{title:Save coefficients and other results of PCA to new dataset}

{p 8 17 2}
{cmd:pcacoefsave using} 
{it:{help filename}} 
[ 
{cmd:, replace} 
{cmdab:rot:ated} 
{cmd:comment(}{it:string}{cmd:)} 
] 


{title:Description}

{p 4 4 2}{cmd:pcacoefsave} saves coefficients and other results from a
principal component analysis (PCA) to a new Stata dataset. It is
essential that results from a previous application of {help pca} be in
memory. The extension {cmd:.dta} will be added to the filename if not
specified. 

{p 4 4 2} 
New variables are (for {it:p} variables and {it:m} <= {it:p} components
from the PCA): 

{p2colset 8 20 20 2}
{p2col:{cmd:varname}}1 to {it:p}, labelled with original variable name

{p2col:{cmd:varlabel}}1 to {it:p}, labelled with original variable label{p_end}
{p2col:}(labelled with original variable name if label is not defined) 

{p2col:{cmd:PC}}1 to {it:m} 

{p2col:{cmd:corr}}correlation between {cmd:PC} and {cmd:variable} 

{p2col:{cmd:loading}}coefficient or loading between {cmd:PC} and {cmd:variable} 

{p2col:{cmd:eigenvalue}}eigenvalue by {cmd:PC} 

{p2col:{cmd:mean}}mean by {cmd:variable} 

{p2col:{cmd:SD}}SD by {cmd:variable} 

{p 4 8 2}
Other than {cmd:corr} and {cmd:loading} the values of variables are
necessarily repeated by {cmd:variable} or {cmd:PC}, as each definition
requires. 

{p 4 8 2}
The values of {cmd:corr} and {cmd:loading} are undefined (i.e. missing)
whenever components are not returned, i.e. whenever {it:m} < {it:p}. 


{title:Remarks} 

{p 4 4 2}The purpose of {cmd:pcacoefsave} is to ease reporting
(including graphics) of PCA results. See {help pca postestimation} for
documentation of what is already readily available. 

{p 4 4 2}Devotees of factor analysis should feel free to write their own
command or seek support elsewhere. 


{title:Options} 

{p 4 8 2}{cmd:replace} specifies that an existing file with the same
name be replaced. 

{p 4 8 2}{cmd:rotated} specifies use of rotated results. 

{p 4 8 2}{cmd:comment()} adds a string variable {cmd:comment} with
stated contents. This is in support of the following goal: You intend to
run various applications of {cmd:pca} and seek to compare results. You
can specify {cmd:pcacoefsave} with comment identifying the nature of
each run before applying {help append}. 


{title:Examples}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. pca headroom trunk weight length displacement}{p_end}
{p 4 8 2}{cmd:. pcacoefsave using pca_results}{p_end}
{p 4 8 2}{cmd:. use pca_results}{p_end}
{p 4 8 2}{cmd:. tabdisp varname PC, cell(corr) format(%4.3f)}{p_end}
{p 4 8 2}{cmd:. xtset PC varname}{p_end}
{p 4 8 2}{cmd:. xtline loading, overlay xla(, valuelabel) recast(connected) legend(pos(3) col(1)) yla(, ang(h))} 

{p 4 8 2}(data from www.statisticalsleuth.com, case1701.csv){p_end}
{p 4 8 2}{cmd:. pca l*, cov}{p_end}
{p 4 8 2}{cmd:. pcacoefsave using pca_results}{p_end}
{p 4 8 2}{cmd:. use pca_results}{p_end}
{p 4 8 2}{cmd:. local opts ms(none) mla(PC) mlabpos(0) mlabsize(*1.5)}{p_end}
{p 4 8 2}{cmd:. twoway connected loading varn if PC == 1, `opts' || connected loading varn if PC == 2, `opts' || connected loading varn if PC == 3, `opts' legend(off) xla(1/11)} 


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:Also see}

{p 4 13 2}Online:  
help for {help pca}, 
help for {help pca postestimation}, 
help for {help eofplot} (if installed from SSC)  

