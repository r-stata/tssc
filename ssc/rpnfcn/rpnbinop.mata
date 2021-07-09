*! version 1.0  25jun2007, Henrik Stovring
version 9.0

mata:

// function to add matrices

real matrix add(real matrix x, real matrix y)
{
  return(x :+ y)
}


// function to subtract matrices

real matrix subtract(real matrix x, real matrix y)
{
  return(x :- y)
}


// function to multiply matrices (element-wise)

real matrix product(real matrix x, real matrix y)
{
  return(x :* y)
}


// function to divide matrices (element-wise)

real matrix divide(real matrix x, real matrix y)
{
  return(x :/ y)
}

end


