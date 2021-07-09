{smcl}
{* *! version 1.7.0  19jun2017}{...}
{cmd:help ghk2()}
{hline}

{title:Title}

{p 4 23 2}
{hi:ghk2()} -- Geweke-Hajivassiliou-Keane (GHK) multivariate normal simulator using pre-generated points


{title:Syntax}

{p 19 25 2}
{it:P} {cmd:=}
{cmd:ghk2setup(}{it:real scalar n}{cmd:, }{it:real scalar m}{cmd:, }{it:real scalar d}{cmd:, }{it:string scalar type}{cmd:, }{break}{cmd:| }{it:real scalar pi}{cmd:, }{it:pointer (real colvector function) pfn}{cmd:)}

{p 8 25 2}
{it:real colvector }{cmd:ghk2(}{it:P}{cmd:, }{it:real matrix X}{cmd:, }{it:real matrix V}{cmd:, }{it:real scalar anti}{cmd:, }{it:real scalar start}{cmd:)}

{p 8 25 2}
{it:real colvector }{cmd:ghk2(}{it:P}{cmd:, }{it:real matrix Xl}{cmd:, }{it:real matrix Xu}{cmd:, }{it:real matrix V}{cmd:, }{it:real scalar anti}{cmd:, }{it:real scalar start}{cmd:)}

{p 8 25 2}
{it:real colvector }{cmd:ghk2(}{it:P}{cmd:, }{it:real matrix X}{cmd:, }{it:real matrix V}{cmd:, }{it:real scalar anti}{cmd:, }{it:real scalar start}{cmd:,}
{it:real matrix dfdx}{cmd:, }{it:real matrix dfdv}{cmd:)}

{p 8 25 2}
{it:real colvector }{cmd:ghk2(}{it:P}{cmd:, }{it:real matrix Xl}{cmd:, }{it:real matrix Xu}{cmd:, }{it:real matrix V}{cmd:, }{it:real scalar anti}{cmd:, }{it:real scalar start}{cmd:,}
{it:real matrix dfdxl}{cmd:, }{it:real matrix dfdxu}{cmd:, }{it:real matrix dfdv}{cmd:)}

{p 8 25 2}
{it:real colvector }{cmd:ghk2SqrtScrambler(}{it:real scalar p}{cmd:)}

{p 8 25 2}
{it:real colvector }{cmd:ghk2NegSqrtScrambler(}{it:real scalar p}{cmd:)}

{p 8 25 2}
{it:real colvector }{cmd:ghk2FLScrambler(}{it:real scalar p}{cmd:)}

{p 4 4 2}
where {it:P}, if it is declared, should be declared

		{cmd:transmorphic} {it:P}
		
{p 4 4 2}
where {it:pfn}, if it is passed, should point to a Mata function declared like ghk2SqrtScrambler(), ghk2NegSqrtScrambler(), or ghk2FLScrambler();

{pstd}
and where {it:dfdx}, {it:dfdxl}, {it:dfdxu}, and {it:dfdv} are outputs

		{it:real matrix dfdx}
		{it:real matrix dfdxl}
		{it:real matrix dfdxu}
		{it:real matrix dfdv}
 

{title:Input parameters}

{pin}{it:n}{bind:            }Number of observations for which to prepare draws{p_end}
{pin}{it:m}{bind:            }Draws per observation and simulated dimension{p_end}
{pin}{it:d}{bind:            }Dimension of cumulative integrals for which to be prepared to simulate{p_end}
{pin}{it:type}{bind:         }Sequence type{p_end}
{pin}{it:pi}{bind:           }Optional starting index of prime bases for Halton sequences (1->2, 2->3, 3->5, 4->7...) (default=1){p_end}
{pin}{it:pfn}{bind:          }Optional pointer to scrambling function such as ghk2SqrtScrambler(), ghk2NegSqrtScrambler(), ghk2FLScrambler(){p_end}
{pin}{it:P}{bind:            }Draws prepared by {cmd:ghk2setup()}{p_end}
{pin}{it:X}{bind:            }Upper bounds of integration{p_end}
{pin}{it:Xl, Xu}{bind:       }Lower and upper bounds of integration{p_end}
{pin}{it:V}{bind:            }Covariance matrix{p_end}
{pin}{it:anti}{bind:         }Optional dummy for inclusion of antithetics (default=0){p_end}
{pin}{it:start}{bind:        }Starting point to use in block of draws prepared by {cmd:ghk2setup()}{p_end}
{pin}{it:p}{bind:            }Number, normally prime, for which the vector (0, 1, ..., p-1)' should be scrambled{p_end}
                
{title:Output parameters}

{pin}{it:dfdx}{bind:         }Scores with respect to {it:X}{p_end}
{pin}{it:dfdxl, dfdxu}{bind: }Scores with respect to {it:Xl, Xu}{p_end}
{pin}{it:dfdv}{bind:         }Scores with respect to {it:V}, stored as vectorized lower-triangular matrices{p_end}


{title:Description}

{pstd}
{cmd:ghk2()} implements the Geweke-Hajivassiliou-Keane algorithm for simulating the cumulative multivariate normal distribution, 
optionally computing scores, and optionally accepting lower as well as upper bounds. (See 
Cappellari and Jenkins 2003, 2005; Gates 2006.) It is modeled on {browse "http://www.stata.com/help.cgi?mf_ghkfast":ghkfast()}, which
is included in Stata 10, and which see for more explanation. Like {cmd:ghkfast()}, its first argument is a pre-generated set of 
points on the unit interval, in this case produced by {cmd:ghk2setup()}, which has the same syntax and semantics as
{browse "http://www.stata.com/help.cgi?mf_ghkfast":ghkfastsetup()}. The two commands' point sets are not interchangeable. {cmd:ghk2()} differs from
{browse "http://www.stata.com/help.cgi?mf_ghkfast":ghkfast()} in the following ways:

{p 6 8 2}
* It accepts lower as well as upper bounds for integration (second and fourth syntaxes above). This allows efficient estimation 
of probabilities over bounded rectilinear regions such as {(x1, x2) | l1<=x1<=u1, l2<=x2<=u2}. Without this feature, the routine would need
to be called 2^d times, where d is the dimension of distribution. For example, the probability just mentioned would have to be
computed as Phi(u1, u2) - Phi(l1, u2) - Phi(u1, l2) + Phi(l1, l2), where Phi is a bivariate cumulative normal distribution with some
given covariance structure. Individual entries in the lower and upper 
bounds, {it:Xl} and {it:Xu}, may be missing ("."), and are interpreted as -infinity and +infinity, respectively. The fourth syntax differs
from the second in requesting score matrices for upper and lower bounds, as well as for the covariance matrix {it:V}.

{p 6 8 2}
* {cmd:ghk2()} does not "pivot" the bounds of integration (in {it:X}, {it:Xl}, or {it:Xu}). On the recommendation of Genz (1992), 
{help mf_ghk:ghk()} and {browse "http://www.stata.com/help.cgi?mf_ghkfast":ghkfast()} reorder each vector of bounds to
put the larger entries toward the end, which reduces the variability of the simulated probability. However, pivoting has the disadvantage of creating
discontinuities in results. Small changes in the bounds can produce relatively large ones
in the results when they trigger reorderings of the pivoted vector. Especially when the number of draws is low, these discontinuities can
stymie a search by {help ml:ml}. Thus {cmd:ghk2()} behaves very smoothly even at low draw counts, at the expense of more variability. (As of Stata 10.1,
{help mf_ghk:ghk()} and {browse "http://www.stata.com/help.cgi?mf_ghkfast":ghkfast()} also allow pivoting to be turned off.)

{p 6 8 2}
* {cmd:ghk2()} works in Stata 9. Stata 9 does ship with {help mf_ghk:ghk()}, but this does not use pre-generated points, and so is slower.

{p 6 8 2}
* {cmd:ghk2()} is generally faster than {browse "http://www.stata.com/help.cgi?mf_ghkfast":ghkfast()}, at least
in single-processor versions of Stata. It is optimized for contexts with a large number of observations relative to draws. In extreme
cases, such as 10,000 observations and 10 draws, it can perform an order of magnitude faster. But at the opposite extreme, with, say, 100
observations and 1,000 draws, it can run half as fast.{p_end}

{p 6 8 2}
* {cmd:ghk2()} accepts an optional scrambling function. Halton sequences based on large primes can have decidedly non-uniform coverage of the unit 
hypercube (Drukker and Gates 2006). "Scrambling" the sequences can increase uniformity (Kolenikov 2012). A scrambling function must accept
one argument, a prime number {it:p}, and return a colvector of the numbers 0..{it:p}-1 in some order. Three scramblers are built in: ghk2SqrtScrambler(), which
mutplies by floor(sqrt({it:p})), modulo {it:p}; ghk2NegSqrtScrambler(), which multiplies by the negation of that; and ghk2FLScrambler(), which multiplies
by a factor that is specific to each prime, following the recommendations of Faure and Lemieux (2009, Table II). {p_end}

{p 6 8 2}
* The {it:start} argument allows the user to shift the starting observation within the pre-computed block of draws. E.g., if the pre-computed block of
draws is for 200 observation rows, when calling {cmd:ghk2()} with a data matrix that has only 100 rows the {it:start} argument would allow rows 101-200 of the draws to be 
used rather than the usual 1-100.

{p 6 8 2}
* The {it:anti} argument, specifying whether to include antithetical draws, is required. Any non-zero value is interpreted as
requesting them.

{p 6 8 2}
* It does not take a {it:rank} argument.  ({help mf_ghk:ghk()} and {browse "http://www.stata.com/help.cgi?mf_ghkfast":ghkfast()} lost it in Stata 10.1 as well.)

{title:Remarks}

{p 4 4 2}
The {it:type} argument may be {cmd:"halton"}, {cmd:"hammersley"}, 
{cmd:"random"}, or {cmd:"ghalton"}. "Random" and generalized Halton 
sequences are influenced by the state of the random number generator just before
{cmd:ghk2setup()} is called. See {help mf_uniform:[M-5] uniform()}.

{p 4 4 2}
The {cmd:ghk2()} routine performs error checking and then calls one of four additional routines, whose syntaxes correspond to the four listed 
above: {cmd:_ghk2()}, {cmd:_ghk2_2()}, {cmd:_ghk2_d}, and {cmd:_ghk2_2d}. You can call these routines directly for a slight speed gain.

{p 4 4 2}
{cmd:ghk2SqrtScrambler(p)} scrambles the modulo-p numbers u=(0, 1, ... p-1}' with the formula mod(u * floor(sqrt(p)), p). {cmd:ghk2NegSqrtScrambler(p)} uses 
mod(u * ( -floor(sqrt(p))), p). The user may provide alternative functions with the same type of arguments and output; see Kolenikov (2012) for ideas.

{title:Examples (colored text is clickable)}

{phang}{cmd:* ghk() and ghkfast() syntax changed in Stata 10.1, but these examples are not updated yet.}{p_end}
{phang}. {stata version 9.0}{p_end}

{phang}{cmd:* Exact matches, using Halton sequence}{p_end}
{phang}{matacmd p = ghkfastsetup(10000, 5, 3, "halton")}{p_end}
{phang}{matacmd p2 = ghk2setup(10000, 5, 3, "halton")}{p_end}
{phang}{matacmd V = 1, .5, .4 \ .5, 1, .3 \ .4, .3, 1}{p_end}
{phang}{matacmd rank = dfdx = dfdv = .}{p_end}
{phang}{matacmd anti = 0}{p_end}
{phang}{matacmd start = .}{p_end}

{phang}{cmd:* Exact matches, using Halton sequence}{p_end}
{phang}{matacmd ghk((1,2,3), V, (1,5), rank)}{p_end}
{phang}{matacmd ghkfast(p, (1,2,3), V, rank)}{p_end}
{phang}{matacmd ghk2(p2, (1,2,3), V, anti, start)}{p_end}

{phang}{cmd:* Inexact matches because ghk() and ghkfast() pivot the data vector, ordering from low to high}{p_end}
{phang}{matacmd ghk((3,2,1), V, (1,5), rank)}{p_end}
{phang}{matacmd ghkfast(p, (3,2,1), V, rank)}{p_end}
{phang}{matacmd ghk2(p2, (3,2,1), V, anti, start)}{p_end}

{phang}{cmd:* Timing comparisons for many observations, few draws, with and without score computation}{p_end}
{phang}{matacmd X = J(10000,3,1)}{p_end}
{phang}{matacmd timer_clear()}{p_end}
{phang}{matacmd timer_on(1); mean(ghkfast(p, X, V, rank, ., anti)); timer_off(1)}{p_end}
{phang}{matacmd timer_on(2); mean(ghk2(p2, X, V, anti, start)); timer_off(2)}{p_end}
{phang}{matacmd timer()}{p_end}

{phang}{matacmd timer_clear()}{p_end}
{phang}{matacmd timer_on(1); mean(ghkfast(p, X, V, rank, ., anti, dfdx, dfdv)); timer_off(1)}{p_end}
{phang}{matacmd timer_on(2); mean(ghk2(p2, X, V, anti, start, dfdx, dfdv)); timer_off(2)}{p_end}
{phang}{matacmd timer()}{p_end}

{phang}{cmd:* Timing comparisons for fewer observations, many draws, including antithetical draws}{p_end}
{phang}{matacmd anti = 1}{p_end}
{phang}{matacmd p = ghkfastsetup(1000, 250, 3, "halton")}{p_end}
{phang}{matacmd p2 = ghk2setup(1000, 250, 3, "halton")}{p_end}
{phang}{matacmd X = J(1000,3,1)}{p_end}
{phang}{matacmd timer_clear()}{p_end}
{phang}{matacmd timer_on(1); mean(ghkfast(p, X, V, rank, ., anti)); timer_off(1)}{p_end}
{phang}{matacmd timer_on(2); mean(ghk2(p2, X, V, anti, start)); timer_off(2)}{p_end}
{phang}{matacmd timer()}{p_end}

{phang}{matacmd timer_clear()}{p_end}
{phang}{matacmd timer_on(1); mean(ghkfast(p, X, V, rank, ., anti, dfdx, dfdv)); timer_off(1)}{p_end}
{phang}{matacmd timer_on(2); mean(ghk2(p2, X, V, anti, start, dfdx, dfdv)); timer_off(2)}{p_end}
{phang}{matacmd timer()}{p_end}

{phang}{cmd:* Demonstration of using lower and upper bounds. The two versions agree asymptotically in the number of draws.}{p_end}
{phang}{cmd:* The first is 8 times faster than the last.}{p_end}
{phang}{matacmd l1=l2=l3=0; u1=1; u2=2; u3=3}{p_end}
{phang}{matacmd ghk2(p2, (l1,l2,l3), (u1,u2,u3), V, anti, start)}{p_end}
{phang}{matacmd ghk2(p2,(u1,u2,u3),V,1,.)-ghk2(p2,(l1,u2,u3),V,1,.)-ghk2(p2,(u1,l2,u3),V,1,.)-ghk2(p2,(u1,u2,l3),V,1,.)+ghk2(p2,(l1,l2,u3),V,1,.)+ghk2(p2,(u1,l2,l3),V,1,.)+ghk2(p2,(l1,u2,l3),V,1,.)-ghk2(p2,(l1,l2,l3),V,1,.)}{p_end}

{phang}{cmd:* Demonstration of scrambling. Square-root scrambling doesn't affect primes 2 and 3; negative square-root doesn't affect 2.}{p_end}
{phang}{matacmd "(0::1), ghk2SqrtScrambler(2), ghk2NegSqrtScrambler(2)"}{p_end}
{phang}{matacmd "(0::2), ghk2SqrtScrambler(3), ghk2NegSqrtScrambler(3)"}{p_end}
{phang}{matacmd "(0::4), ghk2SqrtScrambler(5), ghk2NegSqrtScrambler(5)"}{p_end}

{phang}{cmd:* Examples of scrambling in ghk2(): 4-dimensional problem uses primes 2, 3, 5.}{p_end}
{phang}{matacmd V = 1, .5, .5, .5 \  .5, 1, .5, .5 \ .5, .5, 1, .5 \ .5, .5, .5, 1}{p_end}
{phang}{matacmd p2 = ghk2setup(1, 5, 4, "halton", 1)}{p_end}
{phang}{matacmd ghk2(p2, (1,1,1,1), V, anti, start)}{p_end}
{phang}{matacmd p2 = ghk2setup(1, 5, 4, "halton", 1, &ghk2SqrtScrambler())}{p_end}
{phang}{matacmd ghk2(p2, (1,1,1,1), V, anti, start)}{p_end}
{phang}{matacmd p2 = ghk2setup(1, 5, 4, "halton", 1, &ghk2NegSqrtScrambler())}{p_end}
{phang}{matacmd ghk2(p2, (1,1,1,1), V, anti, start)}{p_end}



{title:Conformability}

    {cmd:ghk2setup(}{it:n}{cmd:, }{it:m}{cmd:, }{it:d}{cmd:,} {it:type}{cmd:, | }{it:pi}{cmd:)}:
                {it:n}:  1 {it:x} 1 
                {it:m}:  1 {it:x} 1
                {it:d}:  1 {it:x} 1 
             {it:type}:  1 {it:x} 1 
               {it:pi}:  1 {it:x} 1 
 	   {it:result}:  {it:transmorphic}

    {cmd:ghk2(}{it:P}{cmd:,} {it:X}{cmd:, }{it:V}{cmd:, }{it:anti}{cmd:, }{it:start}{cmd:)}:
        {it:input:}
                {it:P}:  {it:transmorphic}
                {it:X}:  {it:n x d} 
                {it:V}:  {it:d x d} (symmetric, positive definite)
             {it:anti}:  1 {it:x} 1
            {it:start}:  1 {it:x} 1
        {it:output:}
           {it:result}:  n {it:x} 1 

    {cmd:ghk2(}{it:P}{cmd:,} {it:Xl}{cmd:, }{it:Xu}{cmd:, }{it:V}{cmd:, }{it:anti}{cmd:, }{it:start}{cmd:)}:
        {it:input:}
                {it:P}:  {it:transmorphic}
               {it:Xl}:  {it:n x d} 
               {it:Xu}:  {it:n x d} 
                {it:V}:  {it:d x d} (symmetric, positive definite)
             {it:anti}:  1 {it:x} 1
            {it:start}:  1 {it:x} 1
        {it:output:}
           {it:result}:  n {it:x} 1 

    {cmd:ghk2(}{it:P}{cmd:,} {it:X}{cmd:, }{it:V}{cmd:, }{it:anti}{cmd:, }{it:start}{cmd:, }{it:dfdx}{cmd:, }{it:dfdv}{cmd:)}:
        {it:input:}
                {it:P}:  {it:transmorphic}
                {it:X}:  {it:n x d}
                {it:V}:  {it:d x d} (symmetric, positive definite)
             {it:anti}:  1 {it:x} 1
            {it:start}:  1 {it:x} 1
        {it:output:}
           {it:result}:  {it:n x} 1
             {it:dfdx}:  {it:n x d}
             {it:dfdv}:  {it:n x d}({it:d}+1)/2

    {cmd:ghk2(}{it:P}{cmd:,} {it:Xl}{cmd:, }{it:Xu}{cmd:, }{it:V}{cmd:, }{it:anti}{cmd:, }{it:start}{cmd:, }{it:dfdxl}{cmd:, }{it:dfdxu}{cmd:, }{it:dfdv}{cmd:)}:
        {it:input:}
                {it:P}:  {it:transmorphic}
               {it:Xl}:  {it:n x d}
               {it:Xu}:  {it:n x d}
                {it:V}:  {it:d x d} (symmetric, positive definite)
             {it:anti}:  1 {it:x} 1
            {it:start}:  1 {it:x} 1
        {it:output:}
           {it:result}:  {it:n x} 1
            {it:dfdxl}:  {it:n x d}
            {it:dfdxu}:  {it:n x d}
             {it:dfdv}:  {it:n x d}({it:d}+1)/2

    {cmd:ghk2SqrtScrambler(}{it:p}{cmd:)}:
        {it:input:}
                {it:p}:  {it:1 x} 1
        {it:output:}
           {it:result}:  {it:n x} 1

    {cmd:ghk2NegSqrtScrambler(}{it:p}{cmd:)}:
        {it:input:}
                {it:p}:  {it:1 x} 1
        {it:output:}
           {it:result}:  {it:n x} 1

    {cmd:ghk2FLScrambler(}{it:p}{cmd:)}:
        {it:input:}
                {it:p}:  {it:1 x} 1
        {it:output:}
           {it:result}:  {it:n x} 1

{title:Source code}

{p 4 4 2}
{view ghk2.mata, adopath asis:ghk2.mata}


{title:References}

{p 4 8 2}Cappellari, L., and S. Jenkins. 2003. Multivariate probit regression using simulated maximum likelihood.
{it:Stata Journal} 3(3): 278-94.{p_end}
{p 4 8 2}Cappellari, L., and S. Jenkins. 2006. Calculation of multivariate normal probabilities
by simulation, with applications to maximum simulated likelihood estimation. {it:Stata Journal} 6(2): 156-89.{p_end}
{p 4 8 2}Drukker, D., and R. Gates. 2006. Generating Halton sequences using Mata. {it:Stata Journal} 6(2): 214-28.{p_end}
{p 4 8 2}Faure, H., and C. Lemieux. 2009. Generating Halton sequences in 2008: A comparative study. {it:ACM Transactions on Modeling and Computer Simulation } 19(4), article 15.{p_end}
{p 4 8 2}Kolenikov, S. 2012. Scrambled Halton sequences in Mata. {it:Stata Journal} 12(1): 29-44.{p_end}
{p 4 8 2}Gates, R. 2006. A Mata Geweke-Hajivassiliou-Keane multivariate normal simulator. {it:Stata Journal} 6(2): 190-213.{p_end}
{p 4 8 2}Genz, A. 1992. Numerical computation of multivariate normal probabilities. {it:Journal of Computational and Graphical Statistics} 1: 141–149.{p_end}

{title:Author}

{p 4}David Roodman{p_end}
{p 4}Senior Fellow{p_end}
{p 4}Center for Global Development{p_end}
{p 4}Washington, DC{p_end}
{p 4}droodman@cgdev.org{p_end}


{title:Also see}

{p 4 13 2}
Online:   
{bf:{help mf_ghk:[M-5] ghk()}},
{bf:{help mf_ghkfast:[M-5] ghkfast()}},
{bf:{help mf_halton:[M-5] halton()}}
{p_end}
