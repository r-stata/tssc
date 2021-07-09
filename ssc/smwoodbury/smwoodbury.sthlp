{smcl}
{* 30 Nov 2011}{...}
{cmd:help smwoodbury}
{hline}

{title:Syntax}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_lu(}real matrix {it:Ainv}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:Cinv}{cmd:,} real matrix {it:V}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_lu_solve(}real matrix {it:Ainv}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:Cinv}{cmd:,} real matrix {it:V}{cmd:,} real matrix {it:AinvB}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_qr(}real matrix {it:Ainv}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:Cinv}{cmd:,} real matrix {it:V}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_qr_solve(}real matrix {it:Ainv}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:Cinv}{cmd:,} real matrix {it:V}{cmd:,} real matrix {it:AinvB}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym1_lu(}real matrix {it:Ainv}{cmd:,} real matrix {it:U}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym1_lu_solve(}real matrix {it:Ainv}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:AinvB}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym1_qr(}real matrix {it:Ainv}{cmd:,} real matrix {it:U}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym1_qr_solve(}real matrix {it:Ainv}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:AinvB}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym1_posdef(}real matrix {it:Ainv}{cmd:,} real matrix {it:U}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym1_posdef_solve(}real matrix {it:Ainv}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:AinvB}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym2_lu(}real scalar {it:s}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:Cinv}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym2_lu_solve(}real scalar {it:s}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:Cinv}{cmd:,} real matrix {it:sB}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym2_qr(}real scalar {it:s}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:Cinv}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym2_qr_solve(}real scalar {it:s}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:Cinv}{cmd:,} real matrix {it:sB}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym2_posdef(}real scalar {it:s}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:Cinv}{cmd:)}

{p 8 12 2}
{it:real matrix}{bind:  }{cmd:smwoodbury_sym2_posdef_solve(}real scalar {it:s}{cmd:,} real matrix {it:U}{cmd:,} real matrix {it:Cinv}{cmd:,} real matrix {it:sB}{cmd:)}

{title:Description}

{p 4 4 2}
This package provides a set of Mata functions that implement the Sherman-Morrison-Woodbury formula for a rank-k update to a matrix inverse and that use the formula to efficiently solve matrix equations. The formula is:

{p 4 4 2}
inv(A+U*C*V) = inv(A) - inv(A)*U*inv(inv(C)+V*inv(A)*U)*V*inv(A)

{p 4 4 2}
where A is NxN, U is NxK, C is KxK, V is KxN. 
Use of this formula can save computation time when N is much larger than K and either inv(A) is easy to calculate or inv(A+U*C*V) must be calculated many times for different values of U, C and V. 
Such situations arise, for example, in Markov chain Monte Carlo estimation of mixed models.

{p 4 4 2}
Notice that the functions require as input Ainv and Cinv, the inverses of A and C, rather than A and C themselves.

{p 4 4 2}
{cmd:smwoodbury_lu()} and {cmd:smwoodbury_qr()} implement the full formula. 
The former uses lusolve() and thus assumes Cinv+V*Ainv*U has full rank. 
The latter uses qrsolve() and will work even when Cinv+V*Ainv*U does not have full rank (or is poorly conditioned), but is typically slower.

{p 4 4 2}
{cmd:smwoodbury_sym1_lu()} and {cmd:smwoodbury_sym1_qr()} implement the special case where C=I(K), V=U', and A is symmetric. 
The former uses lusolve() and thus assumes I(K)+U'*Ainv*U has full rank. This assumption generally holds but can fail for unusual values of A and U. 
The latter uses qrsolve() and will work even when I(K)+U'*Ainv*U does not have full rank (or is poorly conditioned), but is typically slower.
To maximize speed, {cmd:smwoodbury_sym1_lu()} and {cmd:smwoodbury_sym1_qr()} do not verify that Ainv is symmetric. 
You may get unexpected results if Ainv is not symmetric.

{p 4 4 2}
{cmd:smwoodbury_sym1_posdef()} implements the special case where C=I(K), V=U', A is symmetric, and I(K)+U'*Ainv*U is positive definite.
To maximize speed, the function does not verify that Ainv is symmetric or that I(K)+U'*Ainv*U is positive definite. You may get unexpected results if these conditions fail.

{p 4 4 2}
{cmd:smwoodbury_sym2_lu()} and {cmd:smwoodbury_sym2_qr()} implement the special case where V=U' and A=I(N)/s for a nonzero scalar s. 
The former uses lusolve() and thus assumes Cinv+s*U'*U has full rank. This assumption generally holds but can fail for unusual values of s and U. 
The latter uses qrsolve() and will work even when Cinv+s*U'*U does not have full rank (or is poorly conditioned), but is typically slower.

{p 4 4 2}
{cmd:smwoodbury_sym2_posdef()} implements the special case where V=U', A=I(N)/s for a nonzero scalar s, Cinv is symmetric, and Cinv+s*U'*U is positive definite.
To maximize speed, the function does not verify that Cinv is symmetric or that Cinv+s*U'*U is positive definite. You may get unexpected results if these conditions fail.

{p 4 4 2}
Functions {cmd:smwoodbury_*_solve()} are equivalent to the functions without {cmd:solve} in the name but are designed to efficiently solve the equation (A+U*C*V)X=B for X. These functions require as input either AinvB=inv(A)*B or sB=(s*I(N))*B.

{title:Author}

{p 4}Sam Schulhofer-Wohl{p_end}
{p 4}Federal Reserve Bank of Minneapolis{p_end}
{p 4}90 Hennepin Ave.{p_end}
{p 4}Minneapolis MN 55480-0291{p_end}
{p 4}wohls@minneapolisfed.org{p_end}

{p 4 4 2}The views expressed herein are those of the author and not necessarily those of the Federal Reserve Bank of Minneapolis or the Federal Reserve System.


