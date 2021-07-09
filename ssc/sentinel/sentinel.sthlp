{smcl}
{* *! version 1.0 7/1/2019}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "sentinel##syntax"}{...}
{viewerjumpto "Description" "sentinel##description"}{...}
{viewerjumpto "Remarks" "sentinel##remarks"}{...}
{viewerjumpto "Algorithm" "sentinel##Algorithm"}{...}
{viewerjumpto "Examples" "sentinel##examples"}{...}
{viewerjumpto "Reference" "sentinel##Reference"}{...}
{phang}
{bf:sentinel} {hline 2} Select sentinel genetic variants

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:sentinel}
{it:depvar} {it:indepvars}
[{help if}]
[{help in}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt del:ta(#)}}  a step size used to decrement the value of R-squared used in the sentinel program; default value is 0.025.{p_end}
{synopt:{opt r2values(#)}} number of different values of R-squared considered; r2values must be <= 1/delta; default value is 1/delta.{p_end}
{synopt:{opt p:value(#)}} p-value for inclusion in the sentinel model; default value is 0.01.{p_end}
{synopt:{opt ver:sion}} If present then the version of the sentinel program will be displayed.{p_end}
{synopt:{opt lis:tvariants}} If present then a list of the variants considered by the sentinel program will be displayed.{p_end}
{synopt:{opt showprog:ress}} If present then a report of the progress through the R**2 values will be displayed.{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}{it:depvar} is an indicator variable that designates case ({it:depvar} = 1) or control ({it:depvar} = 0) 
status of study subjects.
{p_end}
{p 4 6 2}{it:indepvars} are SNPs observed on each subject. Each SNP gives the number of variant alleles for each subject.
{p_end}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:sentinel} selects sentinel SNPs from the genetic variants in {it:indepvars}.  These are SNPs 
 that best detect independent risk-altering signals. In a multivariable multiplicative logistic 
 regression model that regresses {it:depvar} against the sentinel variants, each variant is significantly 
 associated with {it:depvar} and the absolute value of the correlation coefficient of each pair of variants is low.
 
{marker remarks}{...}
{title:Remarks}
{pstd}
Sentinel variants are those best detecting independent risk-altering signals. This program identifies sentinel variants 
using the RISSc algorithm of Dupont et al. 2020. It is based explicitly upon LD patterns 
and identifies variants that optimally detect the risk 
signal of a given LD bin, and those which detect independent risk signals across LD bins under mutual 
adjustment. Because any given set of variants may be sufficiently correlated that they are not significant 
under mutual adjustment, the algorithm judiciously employs LD patterns to ensure that variants optimally 
detecting independent risk signals are retained in the model, while others are removed. The algorithm 
works well with highly correlated variants. It seeks a multivariable model of sentinel variants with low 
pairwise correlation coefficients and high significance under mutual adjustment. 

{marker Algorithm}{...}
{title:Algorithm}
{pstd}The RISSc algorithm selects SNPs that are mutually significant in a multivariable model, and which have low pair-wise R-squared 
values. These are sentinel SNPs, optimally detecting the independent risk-altering association signals of the starting SNP 
set. In what follows, all regressions are logistic and use multiplicative (additive genetic) models; {it:depvar} 
is an indicator variable that identifies cases and controls. {it:d}, {it:#n} and {it:#p} are values passed to 
the program by the delta, r2values and pvalue options. The algorithm identifies bins of SNPs 
that are correlated with each other with diminishing R-squared thresholds. "Selected" means kept for 
possible consideration in the final sentinel model. A selected SNP is "marked" if its association with 
disease is sufficient to keep it from being deleted in the next step. Not all marked SNPs will make it 
into the final model. Once a SNP is deleted, however, it is permanently excluded from further 
consideration for inclusion in the final model.

{pstd}Step 1: 

{p 8 8 2}Set R2 = 1. Identify bins of SNPs that are perfectly correlated with each other (R-squared = 1). Select 
one SNP from each bin and delete all other SNPs in each bin from further consideration. Bins of size 1 
are allowed. Regress {it:depvar} against all selected SNPs in a multivariable logistic 
regression model. If this regression converges then mark all selected SNPs with 
P <= {it:#p} for further consideration and designate those of P > {it:#p} as unmarked. If 
the regression does not converge, then all selected SNPs are unmarked but remain as 
candidates for further evaluation. Set R2 = 1-{it:#d}. Proceed to Step 2 with the selected SNPs, each 
categorized as either marked or unmarked.

{pstd}Step {it:i}: {it:i} = 2 to {it:#n}: 

{p 8 8 2}Identify bins of selected SNPs from Step {it:i} - 1 whose squared correlation coefficient is >= R2. For each bin: 

{p 12 12 2}a) Identify the SNP with the greatest association with disease using simple logistic 
regression. This SNP is denoted {it:best-in-bin}. 

{p 12 12 2}b) Regress {it:depvar} against all of the SNPs in the bin. The {it:best-in-bin} SNP plus 
any SNP in the multivariable regression for this bin that has P <= {it:#p} are selected together with 
all SNPs that were marked in Step {it:i} - 1. Delete all SNPs in the bin that have not been selected 
from further consideration. 

{p 8 8 2}After the selections and deletions from each bin have been made, regress {it:depvar} against 
all of these remaining selected SNPs in a multivariable logistic regression model. If this regression 
converges, then mark all SNPs of P <= {it:#p} while designating those of P > {it:#p} as unmarked. Any 
SNP that was previously marked will become unmarked if it no longer meets this P-value threshold. If 
the model instead fails to converge, then retain the modeled SNPs but designate them as unmarked 
unless they were marked at the previous step. Subtract {it:#d} from R2 and increment {it:i} by 1. 
If {it:i} <= {it:#n} loop to repeat Step {it:i}.

{pstd}The final sentinel SNPs identified by this algorithm are those that were marked in 
Step {it:#n}. In the application of this algorithm to the 183 genome-wide significant 
variant set described in Dupont et al. 2020, the only multivariate model that actually 
failed to converge was at Step 1 (SNPs representing bins of R2 = 1).

{marker examples}{...}
{title:Examples}

{phang}{cmd:. use testSNPs.dta}{p_end}
{phang}{cmd:. sentinel  case_hpc snp8_128104117 rs6983267_T snp8_128191672}{p_end}
{phang}{cmd:. ds case_hpc, not}{p_end}
{phang}{cmd:. local snplist `r(varlist)'}{p_end}
{phang}{cmd:. * When the input list of SNPs is large it is less tedious}{p_end}
{phang}{cmd:. * to use a local macro to enter them into the sentinel program}{p_end}
{phang}{cmd:. sentinel  case_hpc `snplist', delta(.05)}{p_end}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(sentinel)}} local macro consisting of the names of the sentinel SNPs selected by this program {p_end}

{title:Author}

{pstd}William D. Dupont{p_end}
{pstd}Dale Plummer{p_end}
{pstd}Department of Biostatistics{p_end}
{pstd}Vanderbilt University School of Medicine{p_end}

{pstd}Jeffrey R. Smith{p_end}
{pstd}Division of Genetic Medicine{p_end}
{pstd}Vanderbilt University Medical Center{p_end}

{pstd}Email {browse "mailto:william.dupont@vumc.org":william.dupont@vumc.org}{p_end}
{pstd}Email {browse "mailto:dale.plummer@vumc.org":dale.plummer@vumc.org}{p_end}
{pstd}Email {browse "mailto:jeffrey.smith@vumc.org":jeffrey.smith@vumc.org}{p_end}

{marker Reference}{...}
{title:Reference}

{pstd}Dupont WD, Breyer JP, Plummer WD et al. 8q24 genetic variation and comprehensive haplotypes 
altering familial prostate cancer. {it:Nature Communications} {bf:11,} 1523 (2020). https://doi.org/10.1038/s41467-020-15122-1{p_end}
{pstd}(a pdf of this paper is posted at https://www.nature.com/articles/s41467-020-15122-1.pdf).{p_end}

