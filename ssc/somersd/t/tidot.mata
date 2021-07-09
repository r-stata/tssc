version 16.0
mata:

real colvector tidot(real colvector x, real colvector y, | real colvector weight, real colvector xcen, real colvector ycen)
{
/*
  Return weighted concordance-discordance difference counts
  between an X-variable and a Y-variable (both possibly censored).
  x is the X-variable
  y is the Y-variable
  weight contains the weights used to calculate tidot
  xcen contains the censorship status of the X-variable
    (-1 for left-censored, 0 for uncensored, 1 for right-censored).
  ycen contains the censorship status of the Y-variable
    (-1 for left-censored, 0 for uncensored, 1 for right-censored).
*! Author: Roger Newson
*! Date: 11 August 2005
*/
real scalar narg, nobs, i1, i2, x1, x2, y1, y2, xcen1, xcen2, ycen1, ycen2, xsign, ysign, tij, wtcur
real colvector tidot

nobs=rows(x)

/*
  Initialise absent arguments
*/
narg=args();
if (narg<3) {;weight=J(nobs,1,1);}
if (narg<4) {;xcen=J(nobs,1,0);}
if (narg<5) {;ycen=J(nobs,1,0);}

/*
 Initialise and create concordance-discordance counts
*/
tidot=J(nobs,1,.);
for (i1=1;i1<=nobs;i1++) {
  tidot[i1]=0
  x1=x[i1]
  y1=y[i1]
  xcen1=xcen[i1]
  ycen1=ycen[i1]
  for (i2=1;i2<i1;i2++) {
    x2=x[i2]
    y2=y[i2]
    xcen2=xcen[i2]
    ycen2=ycen[i2]
    xsign=((x1<x2) & (xcen1<=0) & (xcen2>=0)) - ((x2<x1) & (xcen2<=0) & (xcen1>=0))
    ysign=((y1<y2) & (ycen1<=0) & (ycen2>=0)) - ((y2<y1) & (ycen2<=0) & (ycen1>=0))
    tij=xsign*ysign
    wtcur=weight[i2]
    if(!missing(wtcur)) {;tidot[i1]=tidot[i1]+tij*wtcur;}
    wtcur=weight[i1]
    if(!missing(wtcur)) {;tidot[i2]=tidot[i2]+tij*wtcur;}
  }
}

return(tidot)

}
end
