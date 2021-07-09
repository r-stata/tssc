{smcl}
{* *! enforce v1.0 Thomas Blanchet 20apr2020}{...}
{title:Title}

{phang}
{bf:enforce} {hline 2} Force variables to satisfy a set of accounting identities

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:enforce} ({it:identity}) [({it:identity}) ...], {{opt rep:lace}|{opt suf:fix(string)}|{opt pre:fix(string)}}
[{cmd:}{it:options}]

{phang} where {it:identity} is:

{p 8 17 2}
[+|-] {{var}|0} [{+|-}{{var}|0} ...] = [+|-] {{var}|0} [{+|-}{{var}|0} ...]

{synoptset 50 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt rep:lace}}replace existing variables{p_end}
{p2coldent :* {opt suf:fix(string)}}create new variables using existing variables names and the suffix {it:string}{p_end}
{p2coldent :* {opt pre:fix(string)}}create new variables using existing variables names and the prefix {it:string}{p_end}
{synopt :{opth fix:edvars(varlist)}}variables to keep unchanged in the adjustment{p_end}
{synopt :{opt noch:eck}}do not check the feasibility of the adjustment{p_end}
{synopt :{opt nofill:missing}}do not attempt to use accounting identities to fill in missing values{p_end}
{synopt :{opt noenf:orce}}do not adjust the value of variables{p_end}
{synopt :{opt diag:nostic}}generate a variable indicating problematic observations{p_end}
{synopt :{opt force}}attempt to do the adjustment even if it is not feasible{p_end}
{synopt :{opt tol:erance(real)}}numerical tolerance parameter{p_end}
{synopt :{opt zero(real)}}absolute tolerance to edit results to zero{p_end}
{synoptline}
{pstd}* Either {opt rep:lace}, {opt suf:fix(string)} or {opt pre:fix(string)} is required.

{marker description}{...}
{title:Description}

{pstd}
{cmd:enforce} forces variables to satisfy an arbitrary set of accounting identities.
It also checks that the system of accounting identities is feasible and plausible, and
uses the identities to fill in missing values when possible.

{marker options}{...}
{title:Options}

{phang}
{opt rep:lace} replaces original variables in the identities by the new, adjusted ones.

{phang}
{opt suf:fix(string)} creates new variables containing adjusted values using the name of the
original variables with the suffix {it:string}.

{phang}
{opt pre:fix(string)} creates new variables containing adjusted values using the name of the
original variables with the prefix {it:string}.

{phang}
{opth fix:edvars(varlist)} specifies a set of variables whose value should not be changed.
Fixed variables can make the system of identities unsolvable, which the command will check.

{phang}
{opt noch:eck} asks not to check the feasibility or plausibility of the system of identities.

{phang}
{opt nofill:missing} asks not to try to fill in missing values using the identities.
Note that if you use that option, the final adjustment might be incomplete, i.e.there might
still be ways to arrange identities so that they contradict the results.

{phang}
{opt noenf:orce} asks not to perform the adjustment to the variables.

{phang}
{opt force} asks to perform the adjustment even if the system is found to be infeasible: see {help enforce##details:Details}.

{phang}
{opt tol:erance(real)} is a numerical tolerance parameter (amount by which the default tolerance is multiplied).

{phang}
{opt zero(real)} results below this value are edited to zero.
Default is 1e-7.

{marker details}{...}
{title:Details}

{pstd}
{it:Note: Stata does not allow good typesetting of math equation in help files. Visit {browse "https://github.com/thomasblanchet/enforce":the commands' GitHub page} for a better rendering of the text below.}

{pstd}
This Stata command is designed to enforce an arbitrary set of accounting identities intelligently, while performing a series of auxiliary checks and adjustments.
To understand the command, first assume an identity a=b+c.
The simplest, naïve way of enforcing it is to multiply both b and c by the same constant, a/(b+c).
The main problem with that approach is that it only works well with positive variables.
If a=0, it will set both b and c to zero, instead of enforcing the more general condition b=-c.
If b+c=0, then it will not work at all, and more generally if b+c≪a (because b<0 or c<0), it can easily lead to absurd adjustments.

{pstd}
One way to fix that first issue is to calculate the discrepancy ε=a-b-c, and redistribute it proportionally to the absolute value of b and c.
That is, we redefine b as b+λε and c as c+(1-λ)ε, where λ=|b|/(|b|+|c|).
If b and c are both positive, this is equivalent to the naïve approach, but otherwise it behaves much more reasonably.

{pstd}
But there are still other problems.
First, if forces us to define a reference variable (in this case a) that will remain unchanged, which may or may not be desirable.
Second, it is not clear how to generalize this adjustment to more complex settings.
In practice, we must simultaneously satisfy dozens of accounting identities, with variables presents in several of them, so that adjustments must be performed across several dimensions.
We formalize that problem as follows.
Assume that we have a vector X=(x_1,…,x_n)' of variables to be adjusted, and we seek an adjusted vector Y=(y_1,…,y_n)' that must satisfy a set of accounting identities.
We will minimize the sum of (y_i - x_i)^2/|x_i| for i from 1 to n, subject to the accounting identities.
The convex cost function (y_i - x_i)^2 at the numerator ensure that the differences between raw and adjusted variables are as low as possible, and that they are spread equitably across all the variables.
The |x_i| at the denominator ensures that adjustments are proportional to the initial value of the variable.
In simple cases, this is equivalent to the procedure explained above.

{pstd}
Assume that the set of accounting identities can be written as a linear system AX=B.
The problem can be written in matrix form as:

{pmore}
minimize  1/2 X'QX + C'X   subject to   AX=B

{pstd}
where Q=diag(1/|x_1|,…,1/|x_n|) and C=(sign(x_1),…,sign(x_n))'.
This is a standard, quadratic programming problem with equality constraints and a positive definite matrix Q.
(Variables that are set fixed or equal to zero are removed from the vector X and included in B.)
The result can be written as the solution of a standard linear system (see {browse "https://en.wikipedia.org/wiki/Quadratic_programming#Equality_constraints":Wikipedia for details}).

{pstd}
This problem is solved via QR decomposition, so it will return an optimal solution in the least-squares sense if the system of identities is technically infeasible.
The command checks wether this is the case, and stops by default if the system of equalities is found to be infeasible for some observations.
You can override this behavior with the {bf:force} option.
Note that variables initially equal to zero are implicitly fixed, so sometimes they can be the reason behind infeasibility.

{pstd}
This is the main task performed by the command enforce, although it also has several additional functionalities.
First, it takes advantage of accounting identities to fill in any missing value that can technically be calculated from nonmissing variables, even though it was initially absent from the raw data.

{pstd}
Second, it pays specific attention to the way constraints are defined to overcome missing value problems.
Indeed, assume for example that we have the constraints a=b+c, α=a+x, β=b+y, γ=c+z, and x=y+z.
Clearly, this implies that α=β+γ.
However, if the data were to only contain nonmissing values for α, β and γ, a naïve treatment of missing values would lead us to dismiss all the constraints as irrelevant to our data.
The command is designed to be aware of the fact that the system of identities implicitly imposes α=β+γ.

{pstd}
Third, the command analyzes the system of identities to find any implausibility (e.g. variable always equal to zero) or incompatibility with the data (in case of fixed variables).

{pstd}
Fourth, it provides extensive reporting on the magnitude of the discrepancies and the adjustments.

{title:Example}

        {cmd:set obs 100}
        {cmd:drawnorm a1 b1 c1 a2 b2 c2 x y z}
        {cmd:foreach v in a1 b1 c1 x y z {c -(}}
        {cmd:    // Create missing values at random}
        {cmd:    replace `v' = . if (uniform() < 0.1)}
        {cmd:}}
        {cmd:enforce (a1 = b1 + c1) (a2 = a1 + x) (b2 = b1 + y) (c2 = c1 + z) (x = y + z), fixed(a2) replace}

{title:Contact}

{pstd}
If you have comments, suggestions, or experience any problem with this command, please contact <thomas.blanchet@wid.world>.

