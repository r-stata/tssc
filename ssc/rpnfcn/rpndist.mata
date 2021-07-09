* Version 1.0 Henrik Støvring, March 19, 2007
version 9.0
mata:

// Exponential density w/ parameter log(lambda) = theta

real matrix fexp (real matrix x, real matrix theta)
{
  return(exp( - (exp(theta[.,1]) :* x) :+ theta[.,1]))
}


// Exponential survivor function w/ parameter log(lambda) = theta

real matrix Sexp (real matrix x, real matrix theta)
{
  return(exp( - (exp(theta[.,1]) :* x)))
}


// Weibull density w/ parameters
// (log(lambda), log(alpha)) = (theta[.,1], theta[.,2])

real matrix fwei (real matrix x, real matrix theta)
{
  return(exp( - (exp(theta[.,1]) :* x):^exp(theta[.,2])
             :+ theta[.,2] :+ theta[.,1]) :*
             (exp(theta[.,1]) :* x ) :^ (exp(theta[.,2]) :- 1 ) )
}


// Weibull survivor function w/ parameters
// (log(lambda), log(alpha)) = (theta[.,1], theta[.,2])

real matrix Swei (real matrix x, real matrix theta)
{
  return(exp( - ((exp(theta[.,1]) :* x) :^ exp(theta[.,2]))))
}

end
