*! version 1.0  25jun2007, Henrik Stovring
version 9.0

mata:

// put x into stack

real matrix tostack(real matrix x)
{
  return(x)
}


// put copy of current stack element on top of stack

real matrix enter(real matrix x)
{
  real matrix newx
  newx = x
  return(newx)
}


// swap two elements currently on top of stack

pointer vector swapst(pointer vector stvec)
{
  return((stvec[2],stvec[1]))
}


// rotate stack: put element 1 on top, push other elements one down

pointer vector rotst(pointer vector stvec)
{
  return(stvec[(2..length(stvec), 1)])
}

end
