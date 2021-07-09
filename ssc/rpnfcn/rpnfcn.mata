*! version 1.0  25jun2007, Henrik Stovring
version 9.0

mata:

// function of subfunctions using function map (RPN)

real matrix rpnfcn(pointer matrix fmap)
{
  real scalar i
  pointer vector opmat
  binop = (&add(), &subtract(), &product(), &divide(), &intres())
  pointer vector stack

  stack = J(1, rows(fmap), NULL)
  i=0

  for (j=1; j<=rows(fmap); j++)
    {
      if (anyeqpt(fmap[j,1],(&tostack())))
       {
          i++
            stack[i] = &((*fmap[j,1])(*fmap[j,2]))
        }
      else if (anyeqpt(fmap[j,1],(&enter())))
        {
          i++
            stack[i] = &((*fmap[j,1])(*stack[i-1]))
         }
      else if (anyeqpt(fmap[j,1],(&swapst())))
        {
          stack[(i-1)..i] = (*fmap[j,1])((stack[i-1],stack[i]))
        }
      else if (anyeqpt(fmap[j,1],(&rotst())))
        {
          stack[1..i] = (*fmap[j,1])((stack[1..i]))
        }
      else if (anyeqpt(fmap[j,1],binop))
        {
          stack[i-1] = &((*fmap[j,1])(*stack[i-1], *stack[i]))
          i--
          }
      else
        {
          stack[i] = &((*fmap[j,1])(*stack[i], *fmap[j,2]))
        }
    }
  if (i == 1)
    {
      return(*stack[1])
    }
  else
    {
      _error("stack has more than one element at end of algorithm")
    }
}


// Determine if two matrices share pointers

real scalar anyeqpt(pointer matrix x, pointer matrix y)
{
  pointer vector xvec
  pointer vector yvec
  xvec = vec(x)
  yvec = vec(y)
  real scalar res

  for (j=1; j<=length(xvec); j++)
    for (i=1; i<=length(yvec); i++)
      {
        res = (xvec[j] == yvec[i])
        if (res == 1) return(res)
      }
  return(res)
}

end
