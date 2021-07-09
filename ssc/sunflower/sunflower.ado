program define sunflower, rclass
*
*  This program was designed by William D. Dupont and W. Dale Plummer Jr.
*  It was written by W. Dale Plummer Jr.
*
*  It may be downloaded together with documentation from 
*  http://ideas.repec.org/c/boc/bocode/s430201.html
*
*  Address: Division of Biostatistics
*           S-2323 Medical Center North
*           Vanderbilt University School of Medicine
*           Nashville TN, 37232-2158
*
*  E-mail:  william.dupont@vanderbilt.edu
*           dale.plummer@vanderbilt.edu
*
*  URL:     http://www.mc.vanderbilt.edu/prevmed/biostatistics.htm
*
*  For additional information see
*
*  Dupont WD and Plummer WD Jr. (2002)  "Density Distribution Sunflower Plots" 
*  Journal of Statistical Software. URL pending.
*
*  The sunflower program is based, in part, on public domain code
*  found in the program flower authored by Thomas J. Steichen and
*  Nicholas J. Cox.  It may be downloaded at
*  http://ideas.repec.org/c/boc/bocode/s393001.html
*  We thank these authors for making their code available.
*
   version 7.0
*
*  Syntax command to parse command.
*
   syntax varlist(numeric min=2 max=2) [fw] [if] [in]              /*
       */  [, BInwidth(real -1) XCenter(real -1) YCenter(real -1)  /*
       */     LIght(int 3) DArk(int 13)                 /*
       */     PETalweight(int -1) POIntsize(real 100)   /*
       */     LIGHTSize(real 80) DARKSize(real 95)    /*
       */     DOtsize(real 70) BACkground(real 1)       /*
       */     Symbol(string)  Connect(string)           /*
       */     SAVing(passthru) XSize(passthru)          /*
       */     YSize(passthru) noTABle noKEy             /*
       */     PEN(string) PSIze(string) TRim(string)    /*
       */     BANds(string) Jitter(string) * ]
   
/*
 *  If xsize or ysize are not specified then get them
 *  from the defined graph window size.
 */
    qui gprefs query window
    if "`xsize'"=="" {
        local xsize="xsize(`r(xsize)')"
    }
    if "`ysize'"=="" {
        local ysize="ysize(`r(ysize)')"
    }
*
*  Disallow some options.
*
    if `"`jitter'"'!="" {
	display as error "jitter option not allowed"
	exit 198
    }
    if `"`bands'"'!="" {
	display as error "bands option not allowed"
	exit 198
    }
    if `"`trim'"'!="" {
	display as error "trim option not allowed"
	exit 198
    }
    if `"`psize'"'!="" {
	display as error "psize option not allowed"
	exit 198
    }
    if `"`pen'"'!="" {
	display as error "pen option not allowed"
	exit 198
    }
    if `"`symbol'"'!="" {
	display as error "symbol option not allowed"
	exit 198
    }
    if `"`connect'"'!="" {
	display as error "connect option not allowed"
	exit 198
    }
*
*  Keep the records to use in this run of the program.
*
   marksample touse
   preserve
   qui keep if `touse'
*
*  Handle the weight qualifier.
*
    if `"`weight'"'!="" {local w "[`weight' `exp']"}
*
*  Parse the variable list into `1', `2', etc.
*
   tokenize `varlist'
*
*  Assign the variable names to local macros.
*
   local y "`1'"
   local x "`2'"
*
*  Get range of data in the x direction.
*
   qui summarize `x'
   local xmin=r(min)
   local xmax=r(max)
*
*  In the absence of user supplied parameters, set defaults.
*
*  Set whether or not to write the summary table.
*
    local writetable=1
    if "`table'"=="notable" {local writetable=0}
*
*  Set whether or not to write the key at the top of the graph.
*
    local writekey=1
    if "`key'"=="nokey" {local writekey=0}
*
*  If not specified, set ycenter and xcenter to be the median of y and x
*  values.
*
    if `ycenter'==-1 {
        qui centile `y'
        local ycenter=r(c_1)
    }
    if `xcenter'==-1 {
        qui centile `x'
        local xcenter=r(c_1)
    }
*
*  Set default bin width so that we get about 40 bins in the x
*  direction.
*
    if `binwidth'==-1 {
        local binwidth=(`xmax'-`xmin')/40
    }
*
*  Light is the minimum bin count that causes a light sunflower to
*  be generated.  3 is a nice default.
*
    if `light'==-1 {
        local light=3
    }
*
*  Check legality of some parameters.
*
   if `background'<0 | `background'>1 {
      display as error "background must be between 0 and 1, inclusive"
      exit 411
   }
    if `binwidth'<=0 {
      display as error "binwidth must be greater than 0"
      exit 411
   }
   if `lightsize'<=0 {
      display as error "lightsize must be greater than 0"
      exit 411
   }
   if `darksize'<=0 {
      display as error "darksize must be greater than 0"
      exit 411
   }
   if `pointsize'<=0 {
      display as error "pointsize must be greater than 0"
      exit 411
   }  
   if `dotsize'<=0 {
      display as error "dotsize must be greater than 0"
      exit 411
   }  
   if `petalweight' ~= -1 & `petalweight'< 0 {
      display as error "petalweight must be greater than 0"
      exit 411
   }
*
*  Check legality of dark and light values.
*
   if `light'<=0 {
      display as error "light must be greater than 0"
      exit 411
      }
   if `dark' ~= -1 {
       if `dark' < 1 {
           display as error "if specified, dark must be greater than 0"
           exit 411
       }
       if `light'>=`dark' {
           display as error "dark must be greater than light"
           exit 411
       }
       if `light' == -1 {
           display as error "light must be specified when dark is specified"
           exit 411
       }
   }
*
*  Calculate the number of bins based on the bin width and the range
*  of the x data.
*
    local xbins=(`xmax'-`xmin')/`binwidth'
*
*  Bin the data.  Use hexagonal binning to transform the data.
*
    local asp_adj=1
    bindata `y' `x' `w', /*
    */    xcenter(`xcenter') ycenter(`ycenter') binwidth(`binwidth') xbins(`xbins') /*
    */    asp_adj(`asp_adj') `xsize' `ysize'                          /*
    */    writekey(`writekey') options(`options')
*
*  Get returned values.
*
    local K=r(K)
    local wt_pix=r(delta)
    local ht_pix=r(height)
    local rbinwidth=r(binwidth)
    local rbinheight=r(binheight)
*
*  Copy the label of the original variables to the binned variables
*  we are plotting.
*
    Copydesc `y' binnedy 
    Copydesc `x' binnedx 
*
*  Do the graph.  Note that while we are passing the names of the original
*  x and y, what we will be plotting is the binnedx and binnedy values.
*  binnedx and binnedy are already in the data set.
*
    makeplot `y' `x',                                                             /*
    */       pointsize(`pointsize') lightsize(`lightsize') darksize(`darksize')   /*
    */       petalweight(`petalweight') light(`light') dark(`dark')               /*
    */       xbins(`xbins') bwidth(`wt_pix') bigk(`K')                            /*
    */       bheight(`ht_pix') background(`background')                           /*
    */       dotsize(`dotsize') `saving' `xsize' `ysize' writetable(`writetable') /*
    */       writekey(`writekey') options(`options')
*
*  Set returns.
*
    ret scalar binwidth = `rbinwidth'
    ret scalar binheight = `rbinheight'

end
*
* -------- makeplot - produce the graphical output. -------------------------
*
program define makeplot
   version 7.0
    syntax varlist [, pointsize(real 1.0) lightsize(real 1.0) darksize(real 1.0) /*
    */        petalweight(int 1) light(int 1) dark(int 1)                       /*
    */        xbins(real 1.0) bwidth(real 1.0) bigk(real 1.0)                   /*
    */        bheight(real 1.0)                                                 /*
    */        background(real 1.0) dotsize(real 1.0)                            /*
    */        saving(passthru) xsize(passthru) ysize(passthru)                  /*
    */        writetable(int 1) writekey(int 1) options(string) ]
    
    tokenize "`varlist'"
    local y "`1'"
    local x "`2'"
*
*  Set the seed for the uniform random number generator
*  function.
*
    set seed 123456789
*
*  Set the size of the symbols used to represent the individual
*  points.  The default is 100.
*
*    local pointsize=100*(`pointsize'/100)
*
*  Set the size of the symbols used to represent the sunflower
*  centers.  The default is 100.
*    
*    local dotsize=100*(`dotsize'/100)
*
*  Colored bin backgrounds are drawn as circles because
*  it is difficult to draw shaded hexagons in Stata.  The
*  default diameter of these circles is set equal to the
*  greatest distance between any two vertices fo a bin.
*  In other words, this diameter is equal to bwidth/cos(pi/6).
*
    local r0=`bwidth'/2
    local r1=`r0'/cos(_pi/6)
    local bgsize=`r0'+(`background'*(`r1'-`r0'))
*
*  Sunflower sizes default to the bin width.  The light and dark
*  sunflower sizes are adjustable by the user as a percent of the
*  binwidth.
*
    local lightsize=`r0'*(`lightsize'/100)
    local darksize=`r0'*(`darksize'/100)
*
*  Get maximum number of points represented in a bin.
*
    qui summarize bintot
    local binmax=r(max)
*
*  If not specified, set default petalweight for dark sunflowers so that
*  we get no more than 14 petals for dark sunflowers.
*
    if `petalweight'==-1 {
        local petalweight=round(`binmax'/14,1)
        if `petalweight'<1 {
            local petalweight=1
        }
    }
*
*  If we think that 12 is the maximum number for dark sunflower
*  petals then 13 might be a good number for the transition
*  from light to dark sunflowers.
*
    if `dark'==-1 {
        local dark=13
    }
    
    display as text "Bins containing " as result `light' as text " or more points and less than " as result `dark' as text " points are represented by light sunflowers."
    display as text "Bins containing " as result `dark' as text " or more points are represented by dark sunflowers."
    display as text "Each petal of the dark sunflowers represents " as result `petalweight' as text " observations."
    display as text "The maximum number of points in a single bin is " as result `binmax' as text "."
*
*  Go into low-level graph mode.
*
    gph open, `saving' `xsize' `ysize'
*
*  Graph the binned data with invisible symbols.  We do this to
*  get the axes drawn and so we can have the return values from
*  the graph command.
*
   local keydark=" "
   local keylight=" "
   if `writekey'==1 {
	if `binmax' >= `dark' & `dark' ~= -1 {
	    local keydark="1 petal = `petalweight' obs"
	}
        local keylight="1 petal = 1 obs"
        graph `y' `x', `options' pen(0) key2(s(i) c(.) pen(1) "`keydark'") key4(s(i) c(.) pen(1) "`keylight'")
   }
   else {
       graph `y' `x', `options' pen(0) 
   }
   local ay  = r(ay)
   local by  = r(by)
   local ax  = r(ax)
   local bx  = r(bx)   
*
*  parse the returned dbox.
*  returned in r(dbox):  r(top)  ,  c(left)  ,  r(bottom)  ,  c(right), ...
*  tokens:                 1     2     3     4     5       6     7
*
   local dbox=r(dbox)
   tokenize "`dbox'" , parse(",")
   local dbrowtop=`1'      /* top row position  */
   local dbcolleft=`3'     /* leftmost column   */
   local dbrowbottom=`5'   /* bottom row        */
   local dbcolright=`7'    /* rightmost column  */
*
*  Parse the returned gbox.
*
   local gbox=r(gbox)
   tokenize "`gbox'" , parse(",")
   local gbrowtop=`1'      /* top row position  */
   local gbcolleft=`3'     /* leftmost column   */
   local gbrowbottom=`5'   /* bottom row        */
   local gbcolright=`7'    /* rightmost column  */
*
*  We only need the records that represent a bin summary record or
*  fall under the threshold for creating a light sunflower.
*  
    qui keep if bintot==bincnt | bintot < `light' | bintot==1
*
*  Plot the title sunflowers.
* ==========================================
*
*  theight is the space between the top of the data box and
*  the top of the graph box.
*
    local theight=`dbrowtop'-`gbrowtop'
*    display "t height " `theight'
* 
* Calculate darkrow and lightrow, the vertical 
* position of the dark and light key symbols
*
* gph pen 1
* gph line `dbrowtop' `dbcolleft' `dbrowtop' `dbcolright'
* gph line `gbrowtop' `dbcolleft' `gbrowtop' `dbcolright'
*
    if `theight' < 3269 {
	local mid = `gbrowtop' + .46*`theight'
    }
    else if `theight' < 4936 {
	local mid = `gbrowtop' + .62*`theight'
    }
    else if `theight' < 6476 {
	local mid = `gbrowtop' + .67*`theight'
    }
    else  {
	local mid = `gbrowtop' + .71*`theight'
    }
    local darktop = 50
    local darkrow = (`mid'-`darktop')*0.28 + `darktop'
*
*  tsfsize is the size of the sunflowers in the key.
*
    local tsfsize= 0.90*(`darkrow' - `darktop')
    local lighttop = (`mid'- `darktop')*0.62 + `darktop'
    local lightrow = `lighttop' + `tsfsize'
*
*  Calculate keysymcol, the column where the key symbols
*  are drawn.  The position is midcol + 15 percent of the
*  difference between the right col position and midcol.
*
    local midcol=`dbcolleft' + ((`dbcolright'-`dbcolleft')/2)
    local keysymcol=`midcol' + ((`dbcolright'-`midcol')*.15)
*
*  Output topmost key describing the dark sunflowers.
*  For dark sunflowers, the background is drawn with pen 6 and
*  the petals are drawn with pen 5.
*
    if `writekey'==1 {
	if `binmax' >= `dark' & `dark' ~= -1 {
	   drawbg `darkrow' `keysymcol' `tsfsize' 6
	   gph pen 5
	   drawsf `darkrow' `keysymcol' `tsfsize' 3 `bigk'
	}
*
*  Output the second key describing the light sunflowers.
*  For light sunflowers, the background is drawn with pen 4 and
*  the petals are drawn with pen 3.
*
	drawbg `lightrow' `keysymcol' `tsfsize' 4
	gph pen 3
	drawsf `lightrow' `keysymcol' `tsfsize' 3 `bigk'
    }
*
* ==========================================
*
*  Make three passes through the data: 
*    1.  make the light backgrounds
*    2.  make the dark backgrounds
*    3.  to plot the points and sunflowers.
*
*   ==== Make the light backgrounds. ====================
*
    local i=1
    while `i' <= _N {

        local f = bintot[`i']       
        if `f' > 1 & `f' >= `light' & (`f' < `dark' | `dark' == -1) {
*
*  Will be plotting a light sunflower.  A background is needed.
*
            local bg=1
            local bgpen=4
*
*  Draw a background if indicated.
*
            local r = binnedy[`i'] * `ay' + `by'
            local c = binnedx[`i'] * `ax' + `bx'
            drawbg `r' `c' `bgsize' `bgpen'
        }
    local i = `i' + 1
    }
*   ==== End of light background production. ===========
*
*   ==== Make the dark backgrounds. ====================
*
    local i=1
    while `i' <= _N {

        local f = bintot[`i']       
        if `f' >= `dark' & `dark' ~= -1 {
*
*  Will be plotting a dark sunflower.  A background is needed.
*
            local bg=1
            local bgpen=6
*
*  Draw the background.
*
            local r = binnedy[`i'] * `ay' + `by'
            local c = binnedx[`i'] * `ax' + `bx'
            drawbg `r' `c' `bgsize' `bgpen'
        }
    local i = `i' + 1
    }
*   ==== End of dark background production. =============
*
*  Loop through the records in the data set.  There is one record in
*  the data set for each bin summary record.  It is this record that we
*  use to describe a bin (bin center & count of points in the bin).
*
    qui gen npetal=0
    local i=1
    while `i' <= _N {
*
*  Get the number of points in this bin.
*
        local f = bintot[`i']       
*
*  If the number of points in a bin is below the number that calls
*  for a light sunflower then plot the points in their original location.
*
        if `f' < `light' | `f'==1 {
*
*  Indicate that we do not need to make a sunflower.
*
            local sf=0
            local npetal=0
*
*  Plot individual points in their original locations.
*
            local r = `y'[`i'] * `ay' + `by'
            local c = `x'[`i'] * `ax' + `bx'
            gph pen 2
            gph point `r' `c' `pointsize' 1
        }
*
*---- Need to plot light sunflowers.-----------------------
*
        if `f' > 1 & `f' >= `light' & (`f' < `dark' | `dark' == -1) {
*
*  Set pen for light sunflowers.
*
            local pen=3
*
*  Set number of petals to be actual number of subjects
*  represented in the bin.
*
            local npetal=`f'
*
*  Indicate that we do need to make a sunflower.
*
            local sf=1
*
*  Set sunflower size.
*
            local sfsize=`lightsize'
        }
*
*---- Need to plot dark sunflowers.-----------------------
*        
        if `f' >= `dark' & `dark' ~= -1 {
*
*  Set pen for dark sunflowers.
*
            local pen=5
*
*  Take into account the petalweight qualifier. 
*
            local npetal=round(`f'/`petalweight',1)
*
*  .5 always rounds up.  When this happens, reduce npetal by
*  1 about half the time.
*
            if (`npetal'-`f'/`petalweight')*2==1 {
                if uniform()<0.5 { local npetal=`npetal'-1 }
            }
*
*  Indicate that we do need to make a sunflower.
*
            local sf=1
*
*  Set sunflower size.
*
            local sfsize=`darksize'
        }
*
*  If called for, plot a sunflower.
*
        if `sf'==1 {
*
*  Determine the location of the center of the sunflower.
*
            local r = binnedy[`i'] * `ay' + `by'
            local c = binnedx[`i'] * `ax' + `bx'
*
*  Set the appropriate pen color for the sunflower petals (pen 3 for light
*  sunflowers and pen 5 for dark sunflowers).
*
            gph pen `pen'
*
*  Draw the point in the middle of the sunflower.
*
            gph arc `r' `c' `dotsize' 0 32767 4
*
*  Draw the petals of the sunflower.
*
            if `npetal' > 1 {
                drawsf `r' `c' `sfsize' `npetal' `bigk'
            }
*
*  Record the number of petals drawn.
*
            qui replace npetal=`npetal' if `i'==_n
        }
        local i = `i' + 1
    }

   gph close
*
*  Put some information in the data set so we can make
*  the summary table.
*
    qui gen light=`light'
    qui gen dark=`dark'
    qui gen ftype=0
    qui replace ftype=1 if bintot>=light & bintot>1
    qui replace ftype=2 if bintot>=dark
    qui gen petalweight=`petalweight'
    qui replace petalweight=0 if ftype==0
    qui replace petalweight=1 if ftype==1
    qui keep if bintot==bincnt
    qui gen estobs=petalweight*npetal
    qui replace estobs=bintot if ftype==0
    qui gen actobs=bintot
    qui gen fcount=1
    sort ftype petalweight npetal
    qui collapse (sum) fcount estobs actobs, by(ftype petalweight npetal)
    qui gen estsum=sum(estobs)
    qui gen actsum=sum(actobs)
*
*  Produce a summary table.
*
    if `writetable'==1 {
        display as text "{hline 65}"
        display as text "flower   petal    No. of   No. of     estimated        actual    "
        display as text "type*    weight   petals   flowers   observations**  observations"
        display as text "{hline 65}"
        local i=1
        while `i' <= _N {
          if ftype[`i']==0 {
            local sftype="none "
            display as text "`sftype'" "        " as result /*
*/          "          "               /*
*/          "          "               /*
*/          "      " %8.0g estobs[`i'] /*
*/          "        " %8.0g actobs[`i']
          }
          else {
            if ftype[`i']==1 {local sftype="light"}
            if ftype[`i']==2 {local sftype="dark "}
            display as text "`sftype'" as result %8.0g petalweight[`i'] /*
*/          "  " %8.0g npetal[`i'] /*
*/          "  " %8.0g fcount[`i'] /*
*/          "      " %8.0g estobs[`i'] /*
*/          "        " %8.0g actobs[`i']
          }
          local i=`i'+1
        }
        display as text "{hline 65}"
        display as text "total                                  " as result %8.0g estsum[_N] "        " %8.0g actsum[_N]
        display as text "{hline 65}"
        display as text "** estimated observations=petal weight * no. of petals * no. of flowers"
    }
end
*
* -------- bindata - use hexagonal binning to transform the data. ------------------
*
program define bindata, rclass
   version 7.0
   syntax varlist [fw], [xcenter(real 1.0) ycenter(real 1.0) binwidth(real 1.0) /*
   */   xbins(real 1.0) asp_adj(real 1.0) xsize(real 1.0)        /*
   */   ysize(real 1.0) writekey(int 1) options(string)]
   
    tokenize "`varlist'"
    local y "`1'"
    local x "`2'"

*
*  asp_adj is a parameter that adjusts the bin aspect ratio.
*  (we assume "square" pixels)
*       asp_adj=1 gives regular hexagonal bins
*       asp_adj>1 gives gives bins whose height is greater than their width
*       asp_adj<1 gives gives bins whose height is less than their width
*
*  Run a dummy graph to get the dimensions of the graphing space.  We
*  use the values returned in r(dbox).  tokenize is used to break out
*  the values.
*
   set graphics off
   if `writekey'==1 {
       graph `y' `x', xsize(`xsize') ysize(`ysize') `options' pen(0) key2(s(i) c(.) pen(1) " ") key4(s(i) c(.) pen(1) " ")
   }
   else {
       graph `y' `x', xsize(`xsize') ysize(`ysize') `options' pen(0) 
   }
   set graphics on
*   return list
*
*  Data to pixel conversion info is returned from the graph command.
*
   local ay  = r(ay)
   local by  = r(by)
   local ax  = r(ax)
   local bx  = r(bx)
*
*  parse the returned dbox.
*  returned in r(dbox):  r(top)  ,  c(left)  ,  r(bottom)  ,  c(right), ...
*  tokens:                 1     2     3     4     5       6     7
*
   local dbox=r(dbox)
   tokenize "`dbox'" , parse(",")
   local dbrowtop=`1'      /* top row position  */
   local dbcolleft=`3'     /* leftmost column   */
   local dbrowbottom=`5'   /* bottom row        */
   local dbcolright=`7'    /* rightmost column  */
*
*  Get physical dimension of the graph window.  xsize and ysize
*  are either set by the user or optained by querying the size
*  of the graph window.
*
    local wy=`ysize'
    local wx=`xsize'
*
*  K is the height to width ratio of an individual pixel.
*  
*  The dimension of the whole window is 22376 X 32000 and
*  32000/22376=1.43.
*
   local K=1.35*`wy'/`wx'   /* 1.35 determined emperically to look best. */
*
*  Save bin width in local macro d.  This preserves write
*  up notation.  d is expressed in terms of the data.
*
    local d=`binwidth'
    display as text "The width of the bins is " as result round(`binwidth',.001)
*
*  Calculate the bin width in pixels.
*
    local delta=`ax'*`d'
*
*  Calculate the bin height in pixels.
*
    local height=(`delta'*1.73205)/`K'
*
*  Convert height in pixels to height in terms of data.
*
    local H=`height'/`ay'
    local H=abs(`H')
    display as text "The height of the bins is " as result round(`H',.001)
*
*  Substitute H for d*sqrt(3) which was the height
*  value in the old notes.
*
*  Calculate some values we'll need. 
*
    local kdsqrt3=`asp_adj'*`H'
*
*  (sqrt(3)*d)/2
*
    local sq3dko2=`kdsqrt3'/2
*
*  d/2
*
    local dov2=`d'/2
*
*  Set the coordinates of the center of the reference cell.
*
    local ymedian="`ycenter'"
    local xmedian="`xcenter'"
*
*  (xnearev(i), ynearev(i)) is the even bin center nearest (x(i), y(i)).
*  deven is distance from (x(i), y(i)) to this center.
*
    gen xnearev=`xmedian'+ `d'*round((`x'-`xmedian')/`d',1)
    gen ynearev=`ymedian'+ `kdsqrt3'*round((`y'-`ymedian')/`kdsqrt3',1)   
    gen deven=sqrt((`x'-xnearev)^2 + (`y'-ynearev)^2)
*
*  (xnearodd(i), ynearodd(i)) is the odd bin center nearest (x(i), y(i)).
*  dodd is distance from (x(i), y(i)) to this center.
*    
    gen xnearodd=`xmedian' + `dov2' + `d'*round((`x'-`xmedian'-`dov2')/`d',1)
    gen ynearodd=`ymedian' + `sq3dko2' + `kdsqrt3'*round((`y'-`ymedian'-`sq3dko2')/`kdsqrt3',1)    
    gen dodd=sqrt((`x'-xnearodd)^2 + (`y'-ynearodd)^2)
*
*  Put the point in the bin it is nearest.
*
    gen binnedx=xnearev
    gen binnedy=ynearev
    qui replace binnedx=xnearodd if deven>dodd
    qui replace binnedy=ynearodd if deven>dodd
*
*  Sort by binned coordinates.
*
    sort binnedx binnedy
*
*  Get count of points in each bin.
*
    qui by binnedx binnedy: generate bincnt=_n
    qui by binnedx binnedy: generate bintot=_N    
*
*  Deal with weighting here ????
*
    if `"`weight'"'!="" {
        tokenize `exp'
        replace bincnt=bincnt*`2'
        replace bintot=bintot*`2'
    }
*
*  Return K, delta (bin width in pixels), and height (bin height in pixels).
*
    ret scalar K = `K'
    ret scalar delta = `delta'
    ret scalar height = `height'
    ret scalar binwidth = `binwidth'
    ret scalar binheight = `H'
end
program def Copydesc
*  copy description from source variable to destination variable
*  1.0.0 29Oct99 NJC
*  syntax: Copydesc src dst
   version 6.0
   syntax varlist(min=2 max=2)
   tokenize `varlist'
   args src dst
   local w : variable label `src'
   if `"`w'"' == "" { local w "`src'" }
   label variable `dst' `"`w'"'
   local srclab : value label `src'
   label val `dst' `srclab'
   local srcfmt : format `src'
   format `dst' `srcfmt'
end

program define drawbg
*  draw the sunflower background
*  1.0.0 21 March 2001 WDP
*  syntax: drawbg r c bgsize pen
    version 7.0
    local r="`1'"
    local c="`2'"
    local bgsize="`3'"
    local pen="`4'"
    local radius=`bgsize'
	
    gph pen `pen'
    
    capture gph arc `r' `c' `radius' 0 32767 4
    if _rc { gpherr "The selected bin width caused an attempt to draw outside the graphics area." }
end

program define drawsf
*  draw the sunflower
*  The sunflower is centered at
*  (r,c).  The sunflower diameter is sfsize.  For each petal, determine
*  a point on a circle about the center of the sunflower.
*  The circle is divided into npetal slices.  bigk is the ratio height/width.
*
*  Suppose we want to draw a line of length h
*  pixel widths from (0,0) making an angle theta
*  to the x axis.  Then the coordinates of the end
*  of this line is (a,b)=(h*cos(theta),h*sin(theta)),
*  measured in pixel widths.  K is the height/width
*  ratio.  Therefore, 
*  a is h*cos(theta) pixel widths to the right of 0 and
*  b is h*sin(theta)/K pixel heights above 0
*
*  1.0.0 19 April 2001 WDP
*  syntax drawsf r c sfsize npetal bigk

   version 7.0
   
   local r="`1'"
   local c="`2'"
   local sfsize="`3'"
   local npetal="`4'"
   local bigk="`5'"

    local j = 1
    while `j' <= `npetal' {
	local ang = _pi  * (2 * `j' / `npetal')
*
*  Adjust angle 90 degrees so that petals point how we like.
*
	local ang = `ang' - _pi/2
	local r1 = `r' + `sfsize' * sin(`ang') / `bigk'
	local c1 = `c' + `sfsize' * cos(`ang')
	capture gph line `r' `c' `r1' `c1'
	if _rc { gpherr "The selected bin width caused an attempt to draw outside the graphics area." }
	local j = `j' + 1
    }
end
program define gpherr
    version 7.0
*
*  Print an error message if the background routine or the
*  sunflower routine fail.  This can only happen if there is
*  an attempt to draw outside the graphic frame.
*
*  This method of capturing a gph error is adapted from
*  wntestb.ado, a program provided with the Stata software.
*
    local mesg "`1'"
    capture gph close
    noi di in red "`mesg'"
    window manage forward results
    exit 807
end



