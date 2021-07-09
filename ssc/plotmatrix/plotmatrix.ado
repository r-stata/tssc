*! Date        : 20 June 2018
*! Version     : 1.24
*! Author      : Adrian Mander
*! Email       : mandera@cardiff.ac.uk
*! Description : Plot matrices/Heat maps

/*
v1.15 24Nov2008  Bug -- had to specify a cmiss(n) option on the boxes and moved it to version 10.1 (not sure if this is necessary)
v1.16 20Oct2009  Bug - there is a problem with people using set dp comma added a check to stop the program
v1.17  6May2011  Add - allow frequencies to be plotted on screen
v1.18 21May2012  Add option to allow all colours to be specified using the allcolors() option.
v1.19  8Mar2013  Add a formatcells() option to alter the printing style of the matrix values
v1.20 24Apr2014  Bug? -- skipping allcolors if the graph is null is now removed
v1.21 20Apr2015  BUG -- when using lower the text doesn't appear to be lower
v1.22  5Jan2017  Add in user specified options on the area plots  blc and blw
v1.23  8May2018  Add in SE matrix to scale boxes
v1.24  20Jun2019 Add in different colours in upper, lower and diagonal
*/

/* START HELP FILE
title[Plot values of a matrix as different coloured blocks]
desc[
This command will display the values of a matrix using twoway area.  Each value of the matrix will be represented by a coloured rectangular block.  A
legend is automatically created using percentiles but the user can also specify how to split the data.

For genetic data there is an additional function to show the genomic distances between markers.  The genomic position is entered using the distance()
option.

]

opt[mat() specifies the name of the matrix to plot. Note that for matrices e(b) and e(V) the user must create a new matrix using the matrix command.]
opt[matse() specifies the name of the matrix to scale each square by. This could be the standard error of your main matrix.]
opt[split() specifies the cutpoints used in the legend. Note that if the matrix contains values outside the range of the number list then the values will not be plotted.  The default will be a number list containing the min, max and 10 other percentiles.]
opt[color(string) specifies the colour of the blocks used. The default colour is bluish gray. Note that RGB and CMYK colors are not accepted and colors should be specified by the word list in colorstyle e.g. brown.]
opt[allcolors() specifies the colours of the blocks used. Note you need to specify all the colours rather than a single colour used by the color() option.]
opt[nodiag() specifies that the diagonal of the matrix is not represented in the graph.]
opt[addbox() specifies that areas of the graph will be enclosed within a box.  The arguments of this option are groups of 4 numbers representing the (y,x) points of two extreme vertices of the box.]
opt[upper specifies that only the upper diagonal matrix be plotted.]
opt[lower specifies that only the lower diagonal matrix be plotted.]
opt[distance() specifies the physical distances between rows/columns in the matrix. This is mostly useful for plotting a pairwise LD matrix to include the genomic distances between markers.]
opt[dunit() specifies the units of the distances specified in the distance variable. The default is Megabases but can be any string.]
opt[maxticks() specifies the maximum number of ticks on both the y and x axes. The default is 8.]
opt[freq specifies that the matrix values are displayed within each coloured box.]
opt[formatcells() specifies the format of the displayed matrix values within each coloured box.]
opt[blc() specifies the color for the outline of each box.]
opt[blw() specifies the thickness of the line surrounding each box, the default is vvvthin.]
opt[uppercolor() specifies the colour used in the upper triangular part of the matrix.]
opt[lowercolor() specifies the colour used in the lower triangular part of the matrix.]
opt[diagcolor() specifies the colour used in the diagonal  part of the matrix.]
opt[* other twoway options.]
opt[save specifies that the stata data file created to plot the heatmap is saved.]
example[

Plotting the values of a variance covariance matrix


{stata sysuse auto} <--- click this first to load data

{stata  reg price mpg trunk weight length turn, nocons}

{stata  mat regmat = e(V)}

{stata  plotmatrix, m(regmat) c(green) ylabel(,angle(0))}

{stata plotmatrix, m(regmat) allcolors(green*1 green*0.8 green*0.6 green*0.4 red*0.4 red*0.6 red*0.8 red*1.0 ) ylabel(,angle(0))}

  To make the plot above more square use the aspect() option but you might want to make the text smaller in the legend so that the y-axis is closer to
the interior of the plot.

{stata  plotmatrix, m(regmat) allcolors(green*1 green*0.8 green*0.6 green*0.4 red*0.4 red*0.6 red*0.8 red*1.0 ) ylabel(,angle(0)) aspect(1) legend(size(*.4) symx(*.4))}

  Plotting the values of a correlation matrix of a given varlist

 {stata matrix accum R = price mpg trunk weight length turn , nocons dev}

{stata  matrix R = corr(R)}

{stata  plotmatrix, m(R) s(-1(0.25)1) c(red)}

By specifying the freq option the correlations are additional printed within each
coloured box. Negating the need for a legend. 
{stata  plotmatrix, m(R) s(-1(0.25)1) c(red) freq legend(off) plotmatrix, m(R) s(-1(0.25)1) c(red) freq aspect(1) legend(size(*.4) symx(*.4))}

With additional formatting on the cells
{stata plotmatrix, m(R) s(-1(0.25)1) c(red) freq formatcells(%5.2f) aspect(1) legend(size(*.4) symx(*.4))}

Genetic Examples

Plotting the values of a point-wise LD map (see command pwld), with boxes around two areas defined by variables 1-5 and variables 11-18.

  .pwld l1_1-l76_2, mat(grid)

  .plotmatrix, mat(grid) split( 0(0.1)1 ) c(gray) nodiag addbox(1 1 5 5 11 11 18 18)

Using the same data as above there were also map positions within the variable posn. Thus the genomic map could be displayed as a diagonal axis with the
following command

  .plotmatrix , mat(grid) split( 0(0.1)1 ) c(gray) nodiag save l distance(posn) dunit(Mb)



  ]

freetext[
Updating this command

To obtain the latest version click the following to uninstall the old version

{stata ssc uninstall plotmatrix}

And click here to install the new version

{stata ssc install plotmatrix}
]

author[Prof Adrian Mander]
institute[Cardiff University]
email[mandera@cardiff.ac.uk]

END HELP FILE */

prog def  plotmatrix
/* Allow use on earlier versions of stata that have not been fully tested */
 local version = _caller()
 local myversion = 15.1
 if `version' < `myversion' {
    di "{err}WARNING: Tested only for Stata version `myversion' and higher."
    di "{err}Your Stata version `version' is not officially supported."
 }
 else {
   version `myversion'
 }
 
syntax , Mat(name) [, MATSE(name) Split(numlist) Color(string) ///
UPPercolor(string) LOWercolor(string) DIAGcolor(string) ALLCOLORS(string) ///
NODIAG SAVE ADDBOX(numlist) Upper Lower Distance(varname) DUnit(string) MAXTicks(integer 8) ///
FREQ FORMATCELLS(string) BLC(string) BLW(string) *]

local twoway_opt "`options'"
if "`blc'"~="" local area_opt `"blc(`blc')"'
if "`blw'"~="" local area_opt `"`area_opt' blw(`blw')"'
set more off
preserve

if "`color'"=="" local color "emidblue"

/****************************************************************************
 * Check for the dp formatting statement 
 ****************************************************************************/
if c(dp)=="comma" {
  di "{error} This command can not be used in conjunction with the comma formatted numbers "
  di "Please use set dp period"
  exit(198)
}

/****************************************************************************
 * A single variable contains the map positions in ORDER
 * i.e. the dataset has to have rows in the order of the SNPs of the matrix
 ****************************************************************************/
if "`dunit'"=="" local dunit "Mb"
if "`distance'"~="" {
  local ny = rowsof(`mat')
  local nx = colsof(`mat')
  local lenx = `nx'/8

  /* Set up the coords of the genomic region line */
  local angle = _pi/2.5
  local y1 = -0.5+`lenx'*sin(`angle')
  local x1 = 2+`lenx'*cos(`angle')
  local y2 = -`ny'+0.5+`lenx'*sin(`angle')
  local x2 = `nx'+1+`lenx'*cos(`angle')

  qui keep `distance'
  qui save dist,replace

  qui su `distance'
  local mapmin = `r(min)'
  local mapmax = `r(max)'
  local mapspan : di %6.1f `mapmax'-`mapmin'
  qui gen line = _n
  qui expand 3
  sort line
  qui replace `distance' = . if mod(_n,3)==0
  qui gen disty = `distance'
  qui gen distx = `distance'
  qui by line: replace distx = line+1 if _n==1
  qui by line: replace disty = -line+1 if _n==1
  qui by line: replace disty  = `y1' + (`distance'-`mapmin')/(`mapmax'-`mapmin')*(`y2'-`y1')  if _n==2
  qui by line: replace distx = `x1' + (`distance'-`mapmin')/(`mapmax'-`mapmin')*(`x2'-`x1') if _n==2
  qui keep disty distx

  /* create the map axis */
  local obs = _N+3
  qui set obs `obs'
  local lineno = `obs'-2
  qui replace disty  = `y1' in `lineno'
  qui replace distx = `x1' in `lineno++'
  qui replace disty  = `y2' in `lineno'
  qui replace distx = `x2' in `lineno'
  qui save dist,replace

  local y = -0.3*`ny'
  local x= 0.7*`nx'
  di "`mapspan'"
  local xtratxt `"|| (line disty distx, cmissing(n) clw(*.2) text(`y' `x' "`mapspan' `dunit'", orient(horizontal))) "'
}

drop _all

/* Find matrix dimensions and col/row names */
local ny = rowsof(`mat')
local nx = colsof(`mat')
local ynames: rowfullnames `mat'
local xnames: colfullnames `mat'
if "`matse'"=="" {
 qui svmat `mat', names(matcol) 
 if "`split'" ~= "" _mkdata, s(`split') nc(`nx')
 else  _mkdata, nc(`nx')
}

if "`matse'"~="" {
  qui svmat `mat', names(matcol) 
  qui svmat `matse' 
  if "`split'" ~= "" _mkdata_matse, s(`split') nc(`nx')
  else  _mkdata_matse, nc(`nx')

} /* puts se matrix next to other matrix */




di "SPLIT `r(split)'"

if "`nodiag'"~="" {
  qui replace col1=. if _stack==y
  qui replace cb=. if _stack==y
}

/***************************************************** 
 * put the numlist of values in split macro 
 *****************************************************/
if "`split'"=="" local split "`r(split)'"

/*Go through the colour cutoffs to create the legend list?*/
local count 1
foreach num of numlist `split' {
  if `count' > 1 local lablist `"`lablist' "`prev'-`num'" "'
  local `count++'
  local prev `num'
}
local lablist `"`lablist' "`prev'" "' 

/*************************************************************************************** 
 * The colour list...get the levels and produce the colours 
 *  ncolleg is the number of columns in legend
 *  size is the number of colors
 *  colorlist is the list of colours
 *
 *  cb is created in the _mkdata command and it is _n per color level according to split
 *  BUT clevels will only see the observed values and groupings not used will be missed
 *
 * work out the number of specified colours and change intensities around them.. 
 * OR if you specify a colorlist
 * then you make the intensity of 1 
 ***************************************************************************************/

qui levelsof cb, local(clevels)

local colorlist ""
local ccc 1
local size:list sizeof clevels
local no_spec_cols: list sizeof color
local new_size = int(`size'/`no_spec_cols'+0.999)
local spcol 1

/*****************************************************
 * Work out the color levels 
 * this is where the set dp is problematic
 * also need color levels for upper, lower and diag
 *****************************************************/

foreach temp of local clevels {
  if `spcol'>`no_spec_cols' local spcol 1
  local cind`temp' `ccc'
  local cbak = `ccc++'-1
  local fact = int(255 -  200/`new_size'*`cbak')
  local fact2 = int( (255 -  200/`new_size'*`cbak')/2 )
  local fact3 = int( (255 -  200/`new_size'*`cbak')/3 )  
  if `spcol'==1 & `new_size'~=1 local intensity : di %4.2f (255/`new_size'*`cbak')/175+0.15
  if `spcol'==1 & `new_size'==1 local intensity : di %4.2f 1
  if `size'==1 local intensity "1"
  if "`color'"=="" local colorlist `" `colorlist' "`fact3' `fact2' `fact'" "'
  if "`color'"~="" {
    local scolor: word `spcol' of `color'
    local colorlist `" `colorlist' `scolor'*`intensity' "'
    local `spcol++'
  }
  if "`uppercolor'"~="" {
    local ucolorlist `" `ucolorlist' `uppercolor'*`intensity' "'
  }
  if "`lowercolor'"~="" {
    local lcolorlist `" `lcolorlist' `lowercolor'*`intensity' "'
  }
  if "`diagcolor'"~="" {
    local dcolorlist `" `dcolorlist' `diagcolor'*`intensity' "'
  }
}

local ncolleg = int(sqrt(`cbak')+1)
local txt ""
local i 1
local legi 1
/*************** This next part is OK if allcolors is empty*****************/
  if "`allcolors'"=="" {
    foreach c of local clevels { /* these are the levels specified */
 
      if "`uppercolor'"~="" &  "`lowercolor'"~="" & "`diagcolor'"~="" { /* need to check legends for the triangles*/
 	    qui count if  cb==`c' & y<_stack 
        if r(N)>0 {
          if "`ldone`c''" == "" {
            local clab: word `c' of `lablist'
            local clegord "`clegord' `legi'"
            local cleg `" `cleg' label(`legi' "`clab'")"'
            local lnumb`c' `legi'
          }
          local `legi++'
          local ldone`c' "done"
		}
 	    qui count if  cb==`c' & y>_stack 
        if r(N)>0 {
          if "`udone`c''" == "" {
            local clab: word `c' of `lablist'
            local clegord "`clegord' `legi'"
            local cleg `" `cleg' label(`legi' "`clab'")"'
            local unumb`c' `legi'
          }
          local `legi++'
          local udone`c' "done"
		}
 	    qui count if  cb==`c' & y==_stack 
        if r(N)>0 {
          if "`ddone`c''" == "" {
            local clab: word `c' of `lablist'
            local clegord "`clegord' `legi'"
            local cleg `" `cleg' label(`legi' "`clab'")"'
            local dnumb`c' `legi'
          }
          local `legi++'
          local ddone`c' "done"
		}
      }
	  else {
	    qui count if  cb==`c' /* need to check if something is drawn*/
        if r(N)>0 {
          if "`done`c''" == "" {
            local clab: word `c' of `lablist'
            local clegord "`clegord' `i'"
            local cleg `" `cleg' label(`i' "`clab'")"'
            local numb`c' `i'
          }
          local `i++'
          local done`c' "done"
		}
	  }
	  
      if "`allcolors'"~="" { /* this shouldn't happen as allcolors is empty*/
        local bc: word `cind`c'' of `allcolors'  /* ALL COLORS mention*/
      }
      else {
        local bc:word `cind`c'' of `colorlist'
        local ubc:word `cind`c'' of `ucolorlist'
        local lbc:word `cind`c'' of `lcolorlist'
        local dbc:word `cind`c'' of `dcolorlist'
      }
      local bc `""`bc'""'  /* not sure what this is for*/

      if "`upper'"~="" local xtraif " & y<=_stack"
      if "`lower'"~="" local xtraif " & y>=_stack"
 
      if "`uppercolor'"~="" &  "`lowercolor'"~="" & "`diagcolor'"~="" {	  
	    local utxt`c' `"(area yy xx if cb==`c' & col1~=. `xtraif' & y<_stack, cmiss(n) bfintensity(100) blw(vvvthin) bc(`ubc') nodropb `area_opt') "'
	    local ltxt`c' `"(area yy xx if cb==`c' & col1~=. `xtraif' & y>_stack, cmiss(n) bfintensity(100) blw(vvvthin) bc(`lbc') nodropb `area_opt')"'
	    local dtxt`c' `"(area yy xx if cb==`c' & col1~=. `xtraif' & y==_stack, cmiss(n) bfintensity(100) blw(vvvthin) bc(`dbc') nodropb `area_opt')"'
	  }
	  else local txt`c' `"(area yy xx if cb==`c' & col1~=. `xtraif', cmiss(n) bfintensity(100) blw(vvvthin) bc(`bc') nodropb `area_opt') "'

      if `"`txt'"'=="" local txt `"`txt`c''"'
      else local txt `"`txt'||`txt`c''"'
	  if `"`txt'"'=="" & `"`utxt`c''"'~="" {
	     local txt `"`utxt`c''|| `ltxt`c'' || `dtxt`c'' "'
	  }
	  if `"`txt'"'~="" & `"`utxt`c''"'~="" {
	     local txt `"`txt' ||  `utxt`c''  || `ltxt`c'' || `dtxt`c'' "'
	  }
	  
      local gsty "`gsty' p1area"
     
   }
  }
  /***** this if if allcolors is specified then we make sure missing graphs still abide by the allcolors list */
  else { 
    qui su cb
    local maxc "`r(max)'"
     forv c=1/`maxc' {
      qui count if  cb==`c'
      if r(N)>0 {
        if "`done`c''" == "" {
          local clab: word `c' of `lablist'
          local clegord "`clegord' `i'"
          local cleg `" `cleg' label(`i' "`clab'")"'
          local numb`c' `i'
        }
      local `i++'
      local done`c' "done"
      local bc: word `c' of `allcolors'  /* ALL COLORS mention*/
      local bc `""`bc'""'

      if "`upper'"~="" local xtraif " & y<=_stack"
      if "`lower'"~="" local xtraif " & y>=_stack"
 
      local txt`c' `"area yy xx if cb==`c' & col1~=. `xtraif', cmiss(n) bfintensity(100) blw(vvvthin) bc(`bc') nodropb `area_opt'"'

      if `"`txt'"'=="" local txt `"(`txt`c'')"'
      else {
        local txt `"`txt'||(`txt`c'')"'
      }
      local gsty "`gsty' p1area"
     }
   }

  }

/* Reconstruct the order of the legend */

 if "`uppercolor'"~="" &  "`lowercolor'"~="" & "`diagcolor'"~="" {	 
   foreach cord of local clevels {
     local corder "`corder' `lnumb`cord'' `unumb`cord'' `dnumb`cord'' "
   }
   di `"LEGEND order `corder'"'
 }
 else {
   foreach cord of local clevels {
     local corder "`corder'`numb`cord'' "
   }
 }
 
/* Create the labelling on the axes */
local nulab `maxticks'
local i 1
local nx:list sizeof xnames
local modx = int(`nx'/`nulab'+1)
foreach var of local xnames {
  if mod(`i',`modx')==1 local xlab `"`xlab'`i' "`var'" "'
  if `nx'<=`nulab' local xlab `"`xlab'`i' "`var'" "'
  local `i++'
}

local i 0
local ny:list sizeof ynames
local mody = int(`ny'/`nulab'+1)
foreach var of local ynames {
  if mod(`i',`mody')==0 local ylab `"`ylab'`i' "`var'" "'
  if `ny'<=`nulab' local ylab `"`ylab'`i' "`var'" "'
  local i=`i'-1
}

/**************************************************************** 
 * To add boxes around certain regions 
 * EACH option requires top left and bottom right coordinates
 ****************************************************************/
if "`addbox'"~="" {
  qui gen boxy=.
  qui g boxx=.
  local obs = 1
  tokenize `addbox'
  while "`1'"~="" {
    qui replace boxy = -1*(`1'-1.5) in `obs'
    qui replace boxx = `2'-0.5 in `obs++'
    qui replace boxy = -1*(`1'-1.5) in `obs'
    qui replace boxx = `4'+0.5 in `obs++'
    qui replace boxy = -1*(`3'-0.5) in `obs'
    qui replace boxx = `4'+0.5 in `obs++'
    qui replace boxy = -1*(`3'-0.5) in `obs'
    qui replace boxx = `2'-0.5 in `obs++'
    qui replace boxy=. in `obs'
    qui replace boxx=. in `obs++'
    mac shift 4
  }
  local txt `"`txt'|| (area boxy boxx, blw(medthick) bc(black) bfc(none) nodropb cmiss(n))"'
}

/********************************************************
 * The Freq option
 *  Want to display the values of the cells as the text 
 *  within each box
 *  ALSO the user can alter these formats
 ********************************************************/
if "`freq'"~="" {
  gen newy = -1*y+1
  if "`formatcells'"~="" format col1 `formatcells'
  if "`lower'"==""  local txt "`txt'||(scatter newy _stack, mlab(col1) mlabcolor(black) mlabposition(0) ms(i))"
  else local txt "`txt'||(scatter newy _stack if (abs(newy)+1 >= _stack), mlab(col1) mlabcolor(black) mlabposition(0) ms(i))" 
} 
/* Saving the dataset that makes plotmatrix */
if "`save'"~="" qui save plotmatrix,replace
if "`distance'"~=""  {
  append using dist
  local txt `"`txt' `xtratxt'"'
}
/* The graphing command */

qui twoway `txt', legend(on `cleg' order(`corder') cols(`ncolleg')) xlabel(`xlab') ylabel(`ylab', nogrid) xtitle("") ytitle("") graphregion( c(white) lp(blank)) `twoway_opt'

restore
end

/************************************************ 
 *
 * Make the dataset that will create the boxes 
 *
 *************************************************/

prog def _mkdata, rclass
syntax [varlist] [, Split(numlist) NC(integer 0) ]

/* 
Create percentiles if split is not specified
nc is the number of columns.. if there is only one column just do a rename otherwise stack the columns
*/

if `nc'==1 {
  rename `varlist' col1
  qui g _stack = 1
}
else qui stack `varlist', into(col1) clear

/*
 Split option here allows for the calculation of the legend, percentiles are 
 defaults
*/

qui su col1
local min: di %5.3f (`r(min)'-0.001)
local max: di %5.3f (`r(max)'+0.001)
if "`split'"=="" {
  di as text "Percentiles are used to create legend"
  qui _pctile col1, p( 1 5(10)95 99)
  local i 1
  local split "`min' "
  while r(r`i')~=. {
    local entry:di %5.3f `r(r`i++')'
    local split "`split'`entry' "
  }
  local split "`split' `max'"
}
return local split = "`split'"  

local diff 0.5
qui bysort _stack:g y=_n
qui expand 5
qui bysort _stack y: g yy=-1*cond(_n==1 | _n==2, y+`diff', cond( _n==3 | _n==4, y-`diff',.))+1
qui bysort _stack y: g xx=cond(_n==1 | _n==4, _stack+`diff', cond(_n==3 | _n==2, _stack-`diff',.))

qui g cb =.
qui g colorleg =""
local var "col1"
local pcent 0

foreach num of numlist `split' {
  if `pcent'~=0 {
    qui replace cb = cond( `var'<`num' & `var'>=`prev', `pcent',cb) 
    qui replace colorleg =  cond( `var'<`num' & `var'>=`prev', "`prev'-`num'",colorleg)
  }
  local prev = `num'
  local `pcent++'
}
qui replace cb= cond( `var'==`prev', `pcent',cb)  /* This is the extra very last value*/
qui replace colorleg =  cond( `var'==`prev' , "`prev'",colorleg)

end

prog def _mkdata_matse, rclass
syntax [varlist] [, Split(numlist) NC(integer 0) ]

/* 
Create percentiles if split is not specified
nc is the number of columns.. if there is only one column just do a rename otherwise stack the columns
*/

if `nc'==1 {
  rename `varlist' col1
  qui g _stack = 1
}
else qui stack `varlist', into(col1) clear  /* stacks everything into 1 column */
gen line = _stack > `nc'
gen obs = _n 
sort line obs
by line: gen obs2 = _n
drop  obs
qui reshape wide col1 _stack, i(obs2) j(line)  /* reshapes data into pairs */

rename _stack0 _stack  /* then use the _stack variable for the plot */
/*
 Split option here allows for the calculation of the legend, percentiles are 
 defaults
*/

qui su col11 /* summarise the SEs */
local max: di %5.3f (`r(max)'+0.001)
local min: di %5.3f (`r(min)'+0.001)
gen diffs = 0.5-0.4*(col11-`min')/(`max'-`min')


rename col10 col1
qui su col1
local min: di %5.3f (`r(min)'-0.001)
local max: di %5.3f (`r(max)'+0.001)
if "`split'"=="" {
  di as text "Percentiles are used to create legend"
  qui _pctile col1, p( 1 5(10)95 99)
  local i 1
  local split "`min' "
  while r(r`i')~=. {
    local entry:di %5.3f `r(r`i++')'
    local split "`split'`entry' "
  }
  local split "`split' `max'"
}
return local split = "`split'"  


local diff 0.5

qui bysort _stack:g y=_n
qui expand 5
qui bysort _stack y: g yy=-1*cond(_n==1 | _n==2, y+diffs, cond( _n==3 | _n==4, y-diffs,.))+1
qui bysort _stack y: g xx=cond(_n==1 | _n==4, _stack+diffs, cond(_n==3 | _n==2, _stack-diffs,.))

qui g cb =.
qui g colorleg =""
local var "col1"
local pcent 0

foreach num of numlist `split' {
  if `pcent'~=0 {
    qui replace cb = cond( `var'<`num' & `var'>=`prev', `pcent',cb) 
    qui replace colorleg =  cond( `var'<`num' & `var'>=`prev', "`prev'-`num'",colorleg)
  }
  local prev = `num'
  local `pcent++'
}
qui replace cb= cond( `var'==`prev', `pcent',cb)  /* This is the extra very last value*/
qui replace colorleg =  cond( `var'==`prev' , "`prev'",colorleg)

end


