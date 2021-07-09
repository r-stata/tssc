version 16.0
mata:

real colvector tidottree(real colvector x, real colvector y, | real colvector weight, real colvector xcen, real colvector ycen)
{
/*
  Return weighted concordance-discordance difference counts
  between an X-variable and a Y-variable (both possibly censored),
  using a search tree algorithm
  (WHICH ASSUMES THE DATA ARE SORTED BY X).
  x is the X-variable.
  y is the Y-variable.
  weight contains the weights used to calculate tidot.
  xcen contains the censorship status of the X-variable
    (-1 for left-censored, 0 for uncensored, 1 for right-censored).
  ycen contains the censorship status of the Y-variable
    (-1 for left-censored, 0 for uncensored, 1 for right-censored).
*! Author: Roger Newson
*! Date: 15 September 2018
*/
real scalar narg, nobs, nxval, nyval, i1, i2, i2min, i2max, root,
  ycur, xcencur, ycencur, wtcur, llcur, lgcur, glcur, ggcur, nodecur, yvalcur
real matrix xpanel, ytree
real colvector tidot, yval, swlt, sweqlc, sweqnc, sweqrc, swgt

/*
  Set number of observations
*/
nobs=rows(x)


/*
  Initialise absent arguments.
*/
narg=args();
if (narg<3) {;weight=J(nobs,1,1);}
if (narg<4) {;xcen=J(nobs,1,0);}
if (narg<5) {;ycen=J(nobs,1,0);}


/*
  Return empty output in event of empty input.
*/
if(nobs<1) {
  return(J(0,1,0))
}


/*
  Initialize X-panel setup matrix and Y-value tree.
*/
xpanel=panelsetup(x,1)
nxval=rows(xpanel)
yval=uniqrows(y)
nyval=rows(yval)
ytree=blncdtree(nyval)
root=trunc((1+nyval)/2)

/*
  Initialize tidot and node sums of weights to zero.
*/
tidot=J(nobs,1,0)
swlt=J(nyval,1,0)
sweqlc=J(nyval,1,0)
sweqnc=J(nyval,1,0)
sweqrc=J(nyval,1,0)
swgt=J(nyval,1,0)


/*
  Iterate over X-values from the lowest to the highest,
  extracting lower subtotals llcur and lgcur from tree to update tidot
  and then updating lower tree node sums of weights using weight.
*/
for(i1=1;i1<=nxval;i1++) {
  /*
    Beginning of iteration for current X-value.
  */
  i2min=xpanel[i1,1]
  i2max=xpanel[i1,2]
  /*
    First observation loop for current X-value.
    Extract lower subtotals from tree and update tidot.
  */
  for(i2=i2min;i2<=i2max;i2++) {
    /*
      Beginning of iteration for current observation.
    */
    ycur=y[i2]
    xcencur=xcen[i2]
    ycencur=ycen[i2]
    if (xcencur>=0) {
      /*
        Extract left and right subtotals from tree
        and update tidot for current observation.
      */
      llcur=0
      lgcur=0
      nodecur=root
      while (nodecur>0) {
        yvalcur=yval[nodecur]
        if (ycur<yvalcur) {
          /* Enter left subtree */
          if (ycencur<=0) lgcur = quadsum((lgcur,swgt[nodecur],(sweqnc[nodecur]+sweqrc[nodecur])))
          nodecur=ytree[nodecur,1]
        }
        else if(ycur>yvalcur) {
          /* Enter right subtree */
          if (ycencur>=0) llcur = quadsum((llcur,swlt[nodecur],(sweqlc[nodecur]+sweqnc[nodecur])))
          nodecur=ytree[nodecur,2]
        }
        else {
          /* Current node has current Y-value */
          if (ycencur<=0) lgcur = quadsum((lgcur,swgt[nodecur]))
          if (ycencur>=0) llcur = quadsum((llcur,swlt[nodecur]))
          nodecur=0
        }
      }
      tidot[i2] = quadsum((tidot[i2],(llcur-lgcur)))
    }
    /*
      End of iteration for current observation.
    */
  }
  /*
    Second observation loop for current X-value.
    Update lower node sums of weights in tree
    with weights in weight.
  */
  for(i2=i2min;i2<=i2max;i2++) {
    /*
      Beginning of iteration for current observation.
    */
    wtcur=weight[i2]
    ycur=y[i2]
    xcencur=xcen[i2]
    ycencur=ycen[i2]
    if ((!missing(wtcur)) & (xcencur<=0)) {
      /*
        Update lower node sums of weights from tree
        with current observation.
      */
      nodecur=root
      while(nodecur>0) {
        yvalcur=yval[nodecur]
        if (ycur<yvalcur) {
          /* Enter left subtree */
          if (ycencur<=0) swlt[nodecur] = quadsum((swlt[nodecur],wtcur))
          nodecur=ytree[nodecur,1]
        }
        else if (ycur>yvalcur) {
          /* Enter right subtree */
          if (ycencur>=0) swgt[nodecur] = quadsum((swgt[nodecur],wtcur))
          nodecur=ytree[nodecur,2]
        }
        else {
          /* Current node has current Y-value */
          if(ycencur<0) sweqlc[nodecur] = quadsum((sweqlc[nodecur],wtcur))
          else if (ycencur>0) sweqrc[nodecur] = quadsum((sweqrc[nodecur],wtcur))
          else sweqnc[nodecur] = quadsum((sweqnc[nodecur],wtcur))
          nodecur=0
        }
      }
    /*
      End of iteration for current observation.
    */
    }
  }
  /*
    End of iteration for current X-value.
  */
}


/*
  Re-initialize node sums of weights to zero.
*/
swlt=J(nyval,1,0)
sweqlc=J(nyval,1,0)
sweqnc=J(nyval,1,0)
sweqrc=J(nyval,1,0)
swgt=J(nyval,1,0)


/*
  Iterate over X-values from the highest to the lowest,
  extracting upper subtotals glcur and ggcur from tree to update tidot
  and then updating upper tree node sums of weights using weight.
*/
for(i1=nxval;i1>=1;i1--) {
  /*
    Beginning of iteration for current X-value.
  */
  i2min=xpanel[i1,1]
  i2max=xpanel[i1,2]
  /*
    First observation loop for current X-value.
    Extract upper subtotals from tree and update tidot.
  */
  for(i2=i2max;i2>=i2min;i2--) {
    /*
      Beginning of iteration for current observation.
    */
    ycur=y[i2]
    xcencur=xcen[i2]
    ycencur=ycen[i2]
    if (xcencur<=0) {
      /*
        Extract left and right subtotals from tree
        and update tidot for current observation.
      */
      glcur=0
      ggcur=0
      nodecur=root
      while (nodecur>0) {
        yvalcur=yval[nodecur]
        if (ycur<yvalcur) {
          /* Enter left subtree */
          if (ycencur<=0) ggcur = quadsum((ggcur,swgt[nodecur],(sweqnc[nodecur]+sweqrc[nodecur])))
          nodecur=ytree[nodecur,1]
        }
        else if(ycur>yvalcur) {
          /* Enter right subtree */
          if (ycencur>=0) glcur = quadsum((glcur,swlt[nodecur],(sweqlc[nodecur]+sweqnc[nodecur])))
          nodecur=ytree[nodecur,2]
        }
        else {
          /* Current node has current Y-value */
          if (ycencur<=0) ggcur = quadsum((ggcur,swgt[nodecur]))
          if (ycencur>=0) glcur = quadsum((glcur,swlt[nodecur]))
          nodecur=0
        }
      }
      tidot[i2] = tidot[i2] + (ggcur-glcur)
    }
    /*
      End of iteration for current observation.
    */
  }
  /*
    Second observation loop for current X-value.
    Update lower node sums of weights in tree
    with weights in weight.
  */
  for(i2=i2max;i2>=i2min;i2--) {
    /*
      Beginning of iteration for current observation.
    */
    wtcur=weight[i2]
    ycur=y[i2]
    xcencur=xcen[i2]
    ycencur=ycen[i2]
    if ((!missing(wtcur)) & (xcencur>=0)) {
      /*
        Update upper node sums of weights from tree
        with current observation.
      */
      nodecur=root
      while(nodecur>0) {
        yvalcur=yval[nodecur]
        if (ycur<yvalcur) {
          /* Enter left subtree */
          if (ycencur<=0) swlt[nodecur] = quadsum((swlt[nodecur],wtcur))
          nodecur=ytree[nodecur,1]
        }
        else if (ycur>yvalcur) {
          /* Enter right subtree */
          if (ycencur>=0) swgt[nodecur] = quadsum((swgt[nodecur],wtcur))
          nodecur=ytree[nodecur,2]
        }
        else {
          /* Current node has current Y-value */
          if(ycencur<0) sweqlc[nodecur] = quadsum((sweqlc[nodecur],wtcur))
          else if (ycencur>0) sweqrc[nodecur] = quadsum((sweqrc[nodecur],wtcur))
          else sweqnc[nodecur] = quadsum((sweqnc[nodecur],wtcur))
          nodecur=0
        }
      }
    }
    /*
      End of iteration for current observation.
    */
  }
  /*
    End of iteration for current X-value.
  */
}


/*
  Return tidot as result
*/
return(tidot)

}
end
