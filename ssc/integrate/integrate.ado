*! Date    : 8 Aug 2018
*! Version : 1.09
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk
*! A numerical integration command

/*
v 1.00  1 Mar 12 The command is born
v 1.01 12 Mar 12 Altering the temporary files is this the latest?
v 1.02  9 Jul 12 Changed some error checking
v 1.03  9 Jul 12 Altered return_code local to return_code scalar
v 1.04 26 Apr 13 Allow the mata installation via this function and improve integration accuracy
v 1.05 10 Jun 13 fix bug in installmata
v 1.06 20 May 15 Tidying up code ready for SJ article
v 1.07 22 Mar 17 Removed the LaGuerre and Hermite quadaruture parts
v 1.08 17 Jul 18 added the help file parts
v 1.09  8 Aug 18 added in up to 10 arguments to integrate
*/

/*
START HELP FILE

title[Numerical integration for one dimensional functions]

desc[
{cmd:integrate} is an implementation of Gaussian quadrature. 
The current command does not attempt to look at numerical errors but the user can alter the number of
quadrature points to inspect any numerical instabilities.
Indefinite integrals are handled using transformation within this function.

    This command has been primarily written in the MATA language but is a Stata
    command. The function can be any single line expression and the integration is
    with respect to x. The text from the option function() will be used to create a
    new function in Mata which is then passed to the integration algorithm.

    The number of quadrature points can be chosen to be any number above 1 but the
    larger this number the slower the algorithm.  There is no upper limit because the
    quadrature points are chosen by calculating the eigenvalues and eigenvectors of a
    companion matrix.
    

{ul:Updating this command using SSC}

To obtain the latest version click the following to install the new version

{stata ssc install integrate,replace}

]

opt[function() specifies the function to be integrated, this must be a function of x.]
opt[lower() specifies the lower limit of the integral.]
opt[upper() specifies the upper limit of the integral.]
opt[quadpts() specifies the number of quadrature points.]
opt[vectorise() specifies the function needs to be vectorised.]
opt[installmata() specifies that the mata code be installed in your personal directory.]

opt2[function() specifies the function to be integrated. This function needs to
        be defined in terms of x. If the function contains any other unknowns then it
        will crash. The command is much quicker if this function is written in terms
        of vector operations. If the function is written without vector operations
        then the vectorise option needs to be specified and another function is
        constructed that is the vector equivalent of the function (this is slower
        given the extra calculations).
]

opt2[lower(#) specifies the lower limit of the integral. To specify
        that the lower limit is -infinity just specify the missing value . in this
        option.]
opt2[upper specifies the upper limit of the integral; the default is +1. To specify
        that the upper limit is +infinity just specify the missing value . in this
        option.]
opt2[quadpts() specifies the number of quadrature points to use in the numerical
        integration; the default is 100. The numerical integration function can allow
        any number of quadrature points but if too many are specified then the
        program will become slow.
]
opt2[vectorise() specifies that the function specified in the function() option is not
        defined in terms of vector operators.  The code will generate an additional
        step of creating a new function that allows x as a vector. This involves
        looping over the elements of the rowvector x so will be considerably slower
        but does allow flexibility in the specification of the function.
]
opt2[installmata specifies that the mata code be installed in your personal directory.]

example[
To install the mata code permanently click the following command

 {stata   integrate, installmata}

The distribution functions in Mata already accept vectors as arguments so can be used in the function 
directly. The following examples are all standard results that can be obtained using the cumulative distribution functions.

{stata integrate, f(normalden(x)) l(-1) u(1)}

{stata integrate, f(normalden(x)) l(-1.96) u(1.96)}

{stata integrate, f(normalden(x)) l(-1.96) u(.)}

{stata integrate, f(normalden(x)) l(.) u(.)}

An example of a user-defined function would be the polynomial x+x^2+x^3
note that because this function is not defined by the appropriate vector operations
then the option vectorise needs to be used.{p_end}

{stata integrate, f(x+x^2+x^3) v l(-10) u(10)}

A quicker implementation of the same function would be

{stata integrate, f(x+x^2+x^3) l(-10) u(10) v :integrate, f(x:+x:^2+x:^3) l(-10) u(10) } 

]

return[integral The value of the integral]

author[Dr Adrian Mander]
institute[MRC Biostatistics Unit, University of Cambridge]
email[adrian.mander@mrc-bsu.cam.ac.uk]

seealso[
{help integrate_aq} (if installed), install by 
clicking {stata ssc install integrate_aq}

The MATA help file for integrate() {help mf_integrate}.
]

END HELP FILE
*/

pr integrate,rclass
version 12.0
syntax [, INSTALLmata Lower(real -1) Upper(real 1) Function(string) Quadpts(int 80) Vectorise]

if "`installmata'"=="" {
  /* The default function */
  if "`function'"=="" {
    local function "x:^2"
    di "{err}WARNING: the integrand was not specified in function() option so will be x^2"
    di
  }
  if `quadpts' <2 {
    di "{err}ERROR: quadrature points need to be 2 or more"
    exit(198)
  }

  /* Drop old code in mata */
  di "{txt}Note: removing the functions myfunction() and tefunction() from Mata"
  cap mata: mata drop myfunction()
  cap mata: mata drop tefunction()

  /* Write a MATA function */
  tempname fh
  tempfile tefile
  file open `fh' using "`tefile'.do", write replace
  file write `fh' "mata" _n
  if "`vectorise'"=="" {
    file write `fh' "rowvector myfunction(rowvector x)" _n
    file write `fh' "{" _n
    file write `fh' "return(`function')" _n
    file write `fh' "}" _n
  }
  else {
    file write `fh' "real tefunction(real x)" _n
    file write `fh' "{" _n
    file write `fh' "return(`function')" _n
    file write `fh' "}" _n _n
    file write `fh' "mata mosave tefunction(), dir(PERSONAL) replace" _n
    file write `fh' "rowvector myfunction(rowvector x)" _n
    file write `fh' "{" _n
    file write `fh' "  for (j=1; j<=cols(x); j++) {" _n
    file write `fh' "    if(j==1) vec = tefunction(x[j])" _n
    file write `fh' "    else vec = vec, tefunction(x[j])" _n
    file write `fh' "  }" _n
    file write `fh' "return(vec)" _n
    file write `fh' "}" _n
  }
  file write `fh' "mata mosave myfunction(), dir(PERSONAL) replace" _n
  file write `fh' "end" _n
  file close `fh'
  di
  di `"{pstd}{txt}Note: The function to be integrated will be compiled using Mata and stored in your personal directory {res}`c(sysdir_personal)' {txt}(make sure this is writeable){p_end}"'
  di
  qui do "`tefile'.do"

  /***************************************************************************************
   * The next part runs the mata code
   *  note that if you integrate a to b but a is bigger than b you get a negative answer!
   ***************************************************************************************/

  mata: st_numscalar("r(integral)",integrate(&myfunction(), `lower', `upper', `quadpts'))
  di "{txt}The integral = {res}" r(integral)
  di
  return scalar integral= `r(integral)'
} /* the else on the install mata part */
/*Install mata functions*/
if "`installmata'"~="" {
  di
  di `"{pstd}{txt}Creating the library for integrate the Mata function and is being stored in your personal directory {res}`c(sysdir_personal)' {txt}(make sure this is writeable!){p_end}"'
  di
  
/* Write the whole mata stuff in a do-file and create a library file */
tempname fh
tempfile tefile2
file open `fh' using "`tefile2'.do", write replace
file write `fh' "mata:" _n
file write `fh' "mata clear" _n

file write `fh' "real scalar integrate(pointer scalar integrand, real scalar lower, real scalar upper, | real scalar quadpts, transmorphic xarg1 /*" _n
file write `fh' "*/, transmorphic xarg2, transmorphic xarg3, transmorphic xarg4, transmorphic xarg5, transmorphic xarg6, transmorphic xarg7, transmorphic xarg8 /*" _n
file write `fh' "*/, transmorphic xarg9, transmorphic xarg10)" _n
file write `fh' "{" _n
file write `fh' "  if (quadpts==.) quadpts=60" _n
file write `fh' "  if (args()<5) { /* this is for single dimensional functions without arguments */" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts)) )" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==5) { /*there is an argument to be handled */" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1)) )" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==6) { /*there is an argument to be handled then repeat for 10 arguments */" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2)) )" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==7) {" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3)) )" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==8) {" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4)) )" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==9) {" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5)) )" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==10) {" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5, xarg6)) )" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==11) {" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5, xarg6, xarg7)) )" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==12) {" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5, xarg6, xarg7, xarg8)) )" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==13) {" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5, xarg6, xarg7, xarg8, xarg9)) )" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==14) {" _n
file write `fh' "     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5, xarg6, xarg7, xarg8, xarg9, xarg10)) )" _n
file write `fh' "  }" _n
file write `fh' "}/* end of integrate*/" _n
file write `fh' "matrix integrate_main(pointer scalar integrand, real lower, real upper, real quadpts, | transmorphic xarg1,transmorphic xarg2,/*" _n
file write `fh' "*/transmorphic xarg3,transmorphic xarg4,transmorphic xarg5,transmorphic xarg6,transmorphic xarg7,transmorphic xarg8,transmorphic xarg9,transmorphic xarg10)" _n
file write `fh' "{" _n
file write `fh' "  rw = legendreRW(quadpts)" _n
file write `fh' "  if (args()<5) { /* This means not containing additional arguments */" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ) )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   )) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ))  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  )) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==5) {" _n
file write `fh' "    /*  This is the definite integral 	*/" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1 )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1)  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re( upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==6) {" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2 )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2)  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==7) {" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3 )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3)  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==8){" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4 )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4)  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==9) {" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5 )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5)  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==10){" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6 )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6)  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5,xarg6) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "  else if (args()==11){" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7 )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7)  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5,xarg6,xarg7) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "    else if (args()==12){" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8 )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8)  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "	}" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5,xarg6,xarg7,xarg8) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "   else if (args()==13){" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9 )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9)  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "   else if (args()==14){" _n
file write `fh' "    if (lower~=. & upper~=.) {" _n
file write `fh' "      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9,xarg10 )" _n
file write `fh' "      return((upper-lower)/2*quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if ( lower==. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9,xarg10) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 " _n
file write `fh' "      return(quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower~=. & upper==.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9,xarg10)  :/ (1:-(rw[1,]:/2:+0.5)):^2 " _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "    else if( lower==. & upper~=.) {" _n
file write `fh' "      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9,xarg10) :/ (rw[1,]:/2:+0.5):^2" _n
file write `fh' "      return(0.5 * quadrowsum(sum))" _n
file write `fh' "    }" _n
file write `fh' "  }" _n
file write `fh' "} " _n

file write `fh' "matrix legendreRW(real scalar quadpts)" _n
file write `fh' "{" _n
file write `fh' "  i = (1..quadpts-1)" _n
file write `fh' "  b = i:/sqrt(4:*i:^2:-1) " _n
file write `fh' "  z1 = J(1,quadpts,0)" _n
file write `fh' "  z2 = J(1,quadpts-1,0)" _n
file write `fh' "  CM = ((z2',diag(b))\z1) + (z1\(diag(b),z2'))" _n
file write `fh' "  V=." _n
file write `fh' "  L=." _n
file write `fh' "  symeigensystem(CM, V, L)" _n
file write `fh' "  w = (2:* V':^2)[,1]" _n
file write `fh' "  return( L \ w') " _n
file write `fh' "}" _n



file write `fh' "  mata mlib create lintegrate, dir(PERSONAL) replace" _n
file write `fh' "  mata mlib add lintegrate legendreRW() integrate() integrate_main()" _n
file write `fh' "  mata mlib index" _n
file write `fh' "end " _n
file close `fh'
do `tefile2'.do
}
end

/****************************
 * Start of MATA
 ****************************/
mata:

/***********************************************************
 * The main part of the integrate function
 *    will need to check whether this is a definite or 
 *    infinite integral by using missing data
 ***********************************************************/ 

real scalar integrate(pointer scalar integrand, real scalar lower, real scalar upper, | real scalar quadpts, transmorphic xarg1 /*
*/, transmorphic xarg2, transmorphic xarg3, transmorphic xarg4, transmorphic xarg5, transmorphic xarg6, transmorphic xarg7, transmorphic xarg8 /*
*/, transmorphic xarg9, transmorphic xarg10)
{
  if (quadpts==.) quadpts=60
  if (args()<5) { /* this is for single dimensional functions without arguments */
     return( Re(integrate_main(integrand, lower, upper, quadpts)) )
  }
  else if (args()==5) { /*there is an argument to be handled */
     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1)) )
  }
  else if (args()==6) { /*there is an argument to be handled then repeat for 10 arguments */
     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2)) )
  }
  else if (args()==7) {
     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3)) )
  }
  else if (args()==8) {
     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4)) )
  }
  else if (args()==9) {
     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5)) )
  }
  else if (args()==10) {
     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5, xarg6)) )
  }
  else if (args()==11) {
     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5, xarg6, xarg7)) )
  }
  else if (args()==12) {
     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5, xarg6, xarg7, xarg8)) )
  }
  else if (args()==13) {
     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5, xarg6, xarg7, xarg8, xarg9)) )
  }
  else if (args()==14) {
     return( Re(integrate_main(integrand, lower, upper, quadpts, xarg1, xarg2, xarg3, xarg4, xarg5, xarg6, xarg7, xarg8, xarg9, xarg10)) )
  }
  
}/* end of integrate*/

/*******************************************************************************
 * This is the main algorithm for doing a single integral 
 * with standard limits
 *******************************************************************************/
matrix integrate_main(pointer scalar integrand, real lower, real upper, real quadpts, | transmorphic xarg1,transmorphic xarg2,/*
*/transmorphic xarg3,transmorphic xarg4,transmorphic xarg5,transmorphic xarg6,transmorphic xarg7,transmorphic xarg8,transmorphic xarg9,transmorphic xarg10)
{
  rw = legendreRW(quadpts)

  if (args()<5) { /* This means not containing additional arguments */
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ) )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   )) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ))  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
    }
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  )) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
  else if (args()==5) {
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1)  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
    }
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
  else if (args()==6) {
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2)  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
    }
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
  else if (args()==7) {
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3)  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
    }
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
  else if (args()==8){
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4)  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
    }
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
  else if (args()==9) {
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5)  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
    }
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
  else if (args()==10){
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6)  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
    }
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5,xarg6) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
  else if (args()==11){
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7)  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
    }
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5,xarg6,xarg7) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
  else if (args()==12){
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8)  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
	}
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5,xarg6,xarg7,xarg8) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
   else if (args()==13){
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9)  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
    }
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
   else if (args()==14){
    /*  This is the definite integral 	*/
    if (lower~=. & upper~=.) {
      sum = rw[2,]:* (*integrand)( Re( (upper:-lower):/2:*rw[1,]:+(upper:+lower):/2 ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9,xarg10 )
      return((upper-lower)/2*quadrowsum(sum))
    }
    /* This is the indefinite integral inf to inf */
    else if ( lower==. & upper==.) {
      sum = rw[2,] :*  (*integrand)(Re(    rw[1,]:/(1:-rw[1,]:^2)   ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9,xarg10) :*   (1:+rw[1,]:^2):/(1:-rw[1,]:^2):^2 
      return(quadrowsum(sum))
    }
    /* This is the indefinite integral a to inf */ 
    else if( lower~=. & upper==.) {
      sum = rw[2,] :* (*integrand)( Re(  lower :+ (rw[1,]:/2:+0.5) :/ (1:- (rw[1,]:/2:+0.5))  ), xarg1, xarg2, xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9,xarg10)  :/ (1:-(rw[1,]:/2:+0.5)):^2 
      return(0.5 * quadrowsum(sum))
    }
    /* This is the indefinite integral inf to a */ 
    else if( lower==. & upper~=.) {
      sum = rw[2,] :* (*integrand)(Re(  upper :- (1:- (rw[1,]:/2:+0.5)):/ (rw[1,]:/2:+0.5)  ), xarg1, xarg2,xarg3,xarg4,xarg5,xarg6,xarg7,xarg8,xarg9,xarg10) :/ (rw[1,]:/2:+0.5):^2
      return(0.5 * quadrowsum(sum))
    }
  }
  
} /*end integrate_main*/

/***************************************************************
 *  Legendre roots/weights
 * This is the clever code to get the roots and weights without 
 * having to use the polyroots() function which starts breaking 
 * down at n=20
 * L contains the roots and w are the weights
 ***************************************************************/
matrix legendreRW(real scalar quadpts)
{
  i = (1..quadpts-1)
  b = i:/sqrt(4:*i:^2:-1) 
  z1 = J(1,quadpts,0)
  z2 = J(1,quadpts-1,0)
  CM = ((z2',diag(b))\z1) + (z1\(diag(b),z2'))
  V=.
  L=.
  symeigensystem(CM, V, L)
  w = (2:* V':^2)[,1]
  return( L \ w') 
} /* end of legendreRW */

end /*end of MATA*/
