*! version 1.0  25jun2007, Henrik Stovring
version 9.0
mata:
  

// create integration nodes on interval (a; b)

real matrix MCatnode(real matrix x, real matrix ab)
{
  real scalar M
  real colvector delta
  real matrix xtr

  M = cols(x)
  delta = (ab[.,2] - ab[.,1]) :/ M
  xtr = J(rows(x), 2*M, .)
    for (j=1; j<=M; j++)
    {
      xtr[., j] = ab[.,1] + delta :* (j - 1) + x[.,j] :* delta
      xtr[., M+j] = ab[.,1] + delta :* (j - 1) + (- x[.,j] :+ 1) :* delta
    }
  return(xtr)
}


// create integration weights for MCatnode

real matrix MCatwt(real matrix x, real matrix ab)
{
  real scalar M

  M = cols(x)
  return((ab[.,2] - ab[.,1]) :/ (2 * M))
}


// create integration points on interval (exp(-infty), exp(-a)),
// ie. (0,exp(-a))

real matrix tlMCatnode(real matrix x, real colvector a)
{
  real scalar M
  real matrix xtr

  M = cols(x)
  xtr = J(rows(x), 2*M, .)
  for (j=1; j<=M; j++)
    {
      xtr[., j] = a - log((x[.,j] :+ (j - 1)) / M)
      xtr[., M+j] = a - log((-x[.,j] :+ j)  / M)
    }
  return(xtr)
}


// create integration weights for tlMCatnode

real matrix tlMCatwt(real matrix x, | real colvector a)
{
  pragma unused a
  real scalar M

  M = cols(x)
  uitr = J(rows(x), 2*M, .)
  
  for (j=1; j<=M; j++)
    {
      uitr[., j] = (x[.,j] :+ (j - 1)):^(-1) :/ 2
      uitr[., M+j] = (-x[.,j] :+ j):^(-1) :/ 2
    }
  return(uitr)
}


// create integration result from evaluated nodes and weights 

real colvector intres(real matrix fx, real matrix wt)
{
  return(quadrowsum(fx :* wt))
}

end
