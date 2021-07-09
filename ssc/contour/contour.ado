*! Date        : 3 Mar 2006
*! Version     : 2.01
*! Author      : Adrian Mander
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*! Description : Producing a contour plot

program define contour
version 9.1
preserve
syntax [varlist] [,Split(numlist) Values *]
local gopt "`options'"


/* Stack all the data into one column */
qui stack `varlist', into(d) clear
qui su d,de
qui gen order=_n
qui sort _stack order
qui by _stack: gen line=_n
local mean = `r(mean)'
local lower = `r(p25)'
local upper = `r(p75)'
qui drop order
rename line y
rename _stack x

if "`split'"=="" local split "`lower' `mean' `upper'"

tempfile master temp
qui save "`master'"

local graphtax ""
local graphleg ""

local i 1
foreach cutp in `split' {
  local cutlab : di %6.2f `cutp'
  di as text "Calculating contours at " as res `cutp'
  if `i'>1 qui use "`master'",replace
  _cutcontour, cut(`cutp')
  qui stack x y d colx coly x y d colxx colyy, into(x y d cont`i'x cont`i'y) clear
  if `i'==1 qui save "`temp'",replace
  else {
    qui append using "`temp'"
    qui save "`temp'",replace
  }
  local graphleg `"`graphleg' label(`i' "`cutlab'")"'
  local graphtax "`graphtax' (line cont`i'y cont`i'x,cmiss(n))"
  local `i++'
}

lab var cont1x "Varlist"
lab var cont1y "Observation number"

if "`values'"~="" local add "(scatter y x,mlabel(d))"
twoway `graphtax' `add', legend(`graphleg') `gopt'

 
restore
end

pr _cutcontour
syntax [varlist] [, CUT(real 0) CONT(integer 1)]

/* Find out whether values are bridging the cut point and then create 3 records i.e a line 
  Coly  are the horizontal lines
  colxx are the vertical lines

  Sort x y
  generate lines for constant x
  replace  lines for constant x  NEED both because order of d is different
*/
/* Set up the following structure around the value d the point I need to decide things about the line
dlt   dt  drt
dl    d   dr
dlb   db  drb
*/
sort x y
qui by x: gen db = d[_n-1] 
qui by x: gen dt = d[_n+1] 
sort y x
qui by y: gen dr = d[_n+1] 
qui by y: gen dl = d[_n-1] 
sort x y
qui by x: gen drt = dr[_n+1] 
qui by x: gen drb = dr[_n-1]
qui by x: gen dlt = dl[_n+1] 
qui by x: gen dlb = dl[_n-1]


/* coly will contain a 4 whenever there is a horizontal line needed 0 otherwise */

sort x y
qui gen coly =  4*(d[_n+1]>=`cut' & d[_n]<`cut') * (x[_n+1]==x)  
qui replace coly =  cond(coly==0,4*(d[_n+1]<`cut' & d[_n]>=`cut')* (x[_n+1]==x) ,coly)
sort y x
qui gen colxx =  4*(d[_n+1]>=`cut' & d[_n]<`cut') * (y[_n+1]==y)  
qui replace colxx =  cond(colxx==0,4*(d[_n+1]<`cut' & d[_n]>=`cut')* (y[_n+1]==y) ,colxx)

/*
 Expand the 4 records and then create the line 

 Now create coordinates always end with a dot to end line
*/

qui expand coly
qui sort x y d
qui by x y d : replace coly= . if _n==4            /* End the line with missing */
/*
 This minimises the number of expansions
 Make sure for the last value that the second expansion is there
*/
qui by x y d : replace colxx= . if _N==4 & _n<4    
qui replace coly =. if coly==0                      /* the 0 values do nothing so get rid of them */
qui replace colxx =. if colxx==0
qui gen colx=coly                                /* create the x coordinates of the horizontal points */
qui replace coly=y if coly~=.                    /* the y-coords are just y */
qui replace colx=x if colx~=.                    /* the x-coords are just x */
sort x y coly                                    /* Keep the order to draw that line */
/* this is the business end of creating the x-coords */
qui by x y: replace colx= cond(colx~=., colx+_n/2-1,.)  /* the x-coords are  x-.5, x, x+.5 */
/* Decide the direction of the second half of the horizontal line */
qui by x y: replace coly= cond(drt>=`cut' & dr >=`cut' & d<`cut' & dr~=., coly, coly)     if _n==3
qui by x y: replace coly= cond(drt>=`cut' & dr >=`cut' & d>=`cut' & dr~=., coly+1, coly)   if _n==3
qui by x y: replace coly= cond(drt>=`cut' & dr <`cut' & d<`cut' & dr~=., coly+0.5, coly) if _n==3 /* correct way */
qui by x y: replace coly= cond(drt>=`cut' & dr <`cut' & d>=`cut' & dr~=., coly, coly)     if _n==3 /* correct way */
qui by x y: replace coly= cond(drt<`cut' & dr <`cut' & d<`cut' & dr~=., coly+1, coly)   if _n==3 /* correct way */
qui by x y: replace coly= cond(drt<`cut' & dr <`cut' & d>=`cut' & dr~=., coly, coly)     if _n==3 /* correct way */
qui by x y: replace coly= cond(drt<`cut' & dr >=`cut' & d<`cut' & dr~=., coly, coly)     if _n==3 /* correct way */
qui by x y: replace coly= cond(drt<`cut' & dr >=`cut' & d>=`cut' & dr~=., coly+0.5, coly) if _n==3 /* correct way */
qui by x y: replace coly= cond(dr==. & drt==. , coly+0.5, coly) if _n==3
/* the middle of the line*/
qui by x y: replace coly= cond(1,coly+0.5,coly) if _n==2
/* The first half of the line */
qui by x y: replace coly= cond(dl==. & dlt==. , coly+0.5,coly) if _n==1   /* make the edges horizontal not slanting */
qui by x y: replace coly= cond(dl>=`cut' & dlt>=`cut' & d>=`cut' & dl~=., coly+1,coly) if _n==1
qui by x y: replace coly= cond(dl>=`cut' & dlt>=`cut' & d<`cut' & dl~=., coly,coly)   if _n==1
qui by x y: replace coly= cond(dl<`cut' & dlt>=`cut' & d>=`cut' & dl~=. ,coly+1,coly) if _n==1
qui by x y: replace coly= cond(dl<`cut' & dlt>=`cut' & d<`cut' & dl~=. ,coly+0.5,coly) if _n==1
qui by x y: replace coly= cond(dl<`cut' & dlt<`cut' & d<`cut' & dl~=.,coly+1,coly) if _n==1
qui by x y: replace coly= cond(dl<`cut' & dlt<`cut' & d>=`cut' & dl~=.,coly,coly) if _n==1
qui by x y: replace coly= cond(dl>=`cut' & dlt<`cut' & d>=`cut' & dl~=.,coly+.5,coly) if _n==1
qui by x y: replace coly= cond(dl>=`cut' & dlt<`cut' & d<`cut' & dl~=.,coly+1,coly) if _n==1

/* Now do it for the vertical lines */
qui expand colxx
qui sort x y d coly
qui by x y d: replace colxx=. if _n==1             /* make sure we have some missing values to end lines */
qui by x y d: replace colxx=. if _n==4 & _N==7     /* this is for the points with horizontal lines */
qui gen colyy=colxx
qui replace colyy=y if colyy~=.                    /* Make sure we have the coordinates in the variables */
qui replace colxx=x if colxx~=.

/* Calculating the vertical line coordinates */
sort y x colyy
qui by y x: replace colyy= cond(colyy~=., colyy+_n/2-1,.)  /* the y-coords are  y-.5, y, y+.5 */
/* Lower half of vertical line */
qui by y x: replace colxx= cond(db==. & drb==., colxx+.5,colxx) if _n==1
qui by y x: replace colxx= cond(db>=`cut' & drb<`cut' & d>=`cut' & db~=., colxx+.5,colxx) if _n==1
qui by y x: replace colxx= cond(db>=`cut' & drb<`cut' & d<`cut' & db~=., colxx+1,colxx) if _n==1
qui by y x: replace colxx= cond(db>=`cut' & drb>=`cut' & d>=`cut' & db~=., colxx+1,colxx) if _n==1
qui by y x: replace colxx= cond(db>=`cut' & drb>=`cut' & d<`cut' & db~=., colxx,colxx) if _n==1
qui by y x: replace colxx= cond(db<`cut' & drb>=`cut' & d>=`cut' & db~=., colxx+1,colxx) if _n==1
qui by y x: replace colxx= cond(db<`cut' & drb>=`cut' & d<`cut' & db~=., colxx+.5,colxx) if _n==1
qui by y x: replace colxx= cond(db<`cut' & drb<`cut' & d>=`cut' & db~=., colxx,colxx) if _n==1
qui by y x: replace colxx= cond(db<`cut' & drb<`cut' & d<`cut' & db~=., colxx+1,colxx) if _n==1
/* The middle point */
qui by y x: replace colxx= cond(1, colxx+.5,colxx) if _n==2
/* upper half of line */
qui by y x: replace colxx= cond(dt==. & drt==., colxx+.5,colxx) if _n==3
qui by y x: replace colxx= cond(dt>=`cut' & drt<`cut' & d>=`cut' & dt~=., colxx+.5,colxx) if _n==3
qui by y x: replace colxx= cond(dt>=`cut' & drt<`cut' & d<`cut' & dt~=., colxx,colxx) if _n==3
qui by y x: replace colxx= cond(dt>=`cut' & drt>=`cut' & d>=`cut' & dt~=., colxx+1,colxx) if _n==3
qui by y x: replace colxx= cond(dt>=`cut' & drt>=`cut' & d<`cut' & dt~=., colxx,colxx) if _n==3
qui by y x: replace colxx= cond(dt<`cut' & drt>=`cut' & d>=`cut' & dt~=., colxx,colxx) if _n==3
qui by y x: replace colxx= cond(dt<`cut' & drt>=`cut' & d<`cut' & dt~=., colxx+.5,colxx) if _n==3
qui by y x: replace colxx= cond(dt<`cut' & drt<`cut' & d>=`cut' & dt~=., colxx,colxx) if _n==3
qui by y x: replace colxx= cond(dt<`cut' & drt<`cut' & d<`cut' & dt~=., colxx+1,colxx) if _n==3

sort x y colx colyy


end


