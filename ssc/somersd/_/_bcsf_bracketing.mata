version 16.0
mata:

real scalar _bcsf_bracketing(pointer (real scalar function) scalar yfun,
  real scalar y, real scalar yfarleft, real scalar yfarright,
  real scalar mbracket, real scalar scalefactor,
  real matrix bracketmat, real scalar leftindex, real scalar rightindex)
{
/*
  Bracketing a y-value for a bounded monotonic step function yfun(x),
    extending the bracket matrix if necessary.
  The returned result is a return code,
    equal to zero if the bracket matrix was updated without error.
  yfun() is a pointer to the function yfun(x) to be used in bracketing.
  y is the input y-value to be bracketed.
  yfarleft is the input left limiting value of yfun(x) as x thends to infinity.
  yfarright is the input right limiting value of yfun(x) as x tends to minus infinity.
  mbracket is the input maximum number of brackets in the bracket matrix.
  scalefactor is the factor to scale existing extreme x-brackets
    to produce candidates for additional extreme x-brackets.
  bracketmat is the bracket matrix to be searched (and updated if necessary),
    with the ordered x-brackets in column 1
    and the corresponding y-brackets in column 2
    and at least 2 rows,
    of which the first and the last should contain opposite-signed x-brackets
    in the first column.
  leftindex is the output left bracket index.
  rightindex is the output right bracket index.
*! Author: Roger Newson.
*! Date: 23 April 2006.
*/
real scalar farsign, newsign, xnew, ynew
/*
  farsign stores the sign of the difference
    between a limiting y-value and an extreme y-bracket.
  newsign stores the sign of the difference
    between a new y-value and  an extreme y-bracket.
  xnew stores a new x-value.
  ynew stores a new y-value.
*/


/*
  Conformability, missingness and consistency checks
*/
if(cols(bracketmat)!=2 | rows(bracketmat)<2 | rows(bracketmat)>mbracket){
  return(1)
}
if(missing(bracketmat) | missing(y) | missing(yfarleft) | missing(yfarright) | missing(mbracket) | missing(scalefactor)){
  return(2)
}
if(sign(bracketmat[1,1]) :* sign(bracketmat[rows(bracketmat),1]) != -1){
  return(3)
}
if(scalefactor<=1){
  return(4)
}

 
/*
  Left-extend bracket matrix if necessary
*/
xnew=bracketmat[1,1]
ynew=bracketmat[1,2]
farsign=sign(yfarleft-ynew)
newsign=sign(y-ynew)
if(missing(farsign) | missing(newsign)){
  return(5)
}
while(farsign!=-newsign & farsign!=0){
  if(rows(bracketmat)>=mbracket){
    return(5)
  }
  xnew=scalefactor*xnew
  if(missing(xnew)){
    return(5)
  }
  ynew=(*yfun)(xnew)
  if(missing(ynew)){
    return(5)
  }
  farsign=sign(yfarleft-ynew)
  newsign=sign(y-ynew)
  if(missing(farsign) | missing(newsign)){
    return(5)
  }
  bracketmat = (xnew,ynew) \ bracketmat
}


/*
  Right-extend bracket matrix if necessary
*/
xnew=bracketmat[rows(bracketmat),1]
ynew=bracketmat[rows(bracketmat),2]
farsign=sign(yfarright-ynew)
newsign=sign(y-ynew)
if(missing(farsign) | missing(newsign)){
  return(6)
}
while(farsign!=-newsign & farsign!=0){
  if(rows(bracketmat)>=mbracket){
    return(6)
  }
  xnew=scalefactor*xnew
  if(missing(xnew)){
    return(6)
  }
  ynew=(*yfun)(xnew)
  if(missing(ynew)){
    return(6)
  }
  farsign=sign(yfarright-ynew)
  newsign=sign(y-ynew)
  if(missing(farsign) | missing(newsign)){
    return(6)
  }
  bracketmat = bracketmat \ (xnew,ynew)
}


/*
  Locate left bracket index
*/
leftindex=rows(bracketmat)
ynew=bracketmat[leftindex,2]
farsign=sign(yfarleft-ynew)
newsign=sign(y-ynew)
if(missing(farsign) | missing(newsign)){
  return(7)
}
while(farsign!=-newsign & farsign!=0){
  leftindex--
  if(leftindex<1){
    return(7)
  }
  ynew=bracketmat[leftindex,2]
  farsign=sign(yfarleft-ynew)
  newsign=sign(y-ynew)
  if(missing(farsign) | missing(newsign)){
    return(7)
  }
}


/*
  Locate right bracket index
*/
rightindex=1
ynew=bracketmat[rightindex,2]
farsign=sign(yfarright-ynew)
newsign=sign(y-ynew)
if(missing(farsign) | missing(newsign)){
  return(8)
}
while(farsign!=-newsign & farsign!=0){
  rightindex++
  if(rightindex>rows(bracketmat)){
    return(8)
  }
  ynew=bracketmat[rightindex,2]
  farsign=sign(yfarright-ynew)
  newsign=sign(y-ynew)
  if(missing(farsign) | missing(newsign)){
    return(8)
  }
}


return(0)


}

end
