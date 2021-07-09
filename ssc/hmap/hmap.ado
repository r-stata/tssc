*! hmap version 1.0 16mar2010
*! by Austin Nichols <austinnichols@gmail.com>
program define hmap
 version 8.2
 syntax varlist(min=3 max=3) [if] [in] [, XLabel(passthru) YLabel(passthru) REVerse MONochrome noSCatter * ]
 marksample touse
 tokenize `varlist'
 xunits `1' `touse'
 loc xdist=r(units)
 xunits `2' `touse'
 loc ydist=r(units)
 if (`"`xlabel'"'=="") {
  su `1', mean
  local xlabel `"xlabel(`r(min)'(`xdist')`r(max)', val angle(90) nogrid)"'
  }
 if (`"`ylabel'"'=="") {
  su `2', mean
  local ylabel `"ylabel(`r(min)'(`ydist')`r(max)', val angle(0) nogrid)"'
  }
 tempvar y0 y1
 g `y1'=`2'+`ydist'/2
 la val `y1' `:val lab `2''
 g `y0'=`2'-`ydist'/2
 qui levelsof `3' if `touse', loc(lev)
 su `3' if `touse', mean
 loc minlev=r(min)
 loc maxlev=r(max)
 if `maxlev'==`minlev' {
  di as err "variable `3' does not vary; graph would be a solid color"
  err 198
  }
 *Use p3md 21,22,23 palette:
 *0.00-0.33 red goes 0-1
 *0.33-0.67 green goes 0-1
 *0.67-1.00 blue catches up
 loc gcom
 foreach x of loc lev {
  loc zlev=(`x'-`minlev')/(`maxlev'-`minlev')
  if ("`reverse'"!="") {
   local zlev=1-`zlev'
   }
  if ("`monochrome'"!="") {
   loc R=int(255*`zlev')
   loc G=int(255*`zlev')
   loc B=int(255*`zlev')
   }
  else {
   loc R=int(255*min(1,3*(`zlev')))
   loc G=int(255*min(1,3*max(0,(`zlev'-1/3))))
   loc B=int(255*min(1,3*max(0,(`zlev'-2/3))))
   }
  loc gcom `"`gcom'||rbar `y1' `y0' `1' if (`3'==`x')&(`touse'), barw(`xdist') col("`R' `G' `B'") fi(inten100) lw(none)"'
  }
 if "`scatter'"=="" loc sc `"sc `2' `1', mlab(`3') mlabpos(0) msy(i) `scopt'"'
 local gcom `"`gcom' leg(off) xsize(3) ysize(3) yscale(reverse) aspect(1) `ylabel' `xlabel'  xtitle("") ytitle("")"'
 tw `gcom' plotr(fc(gray) m(zero)) `options' ||`sc'
end
program xunits, rclass 
 args v touse
 qui summ `v' if `touse', mean
 loc p = 1
 capture assert float(`v') == float(round(`v',1)) if `touse'
 if _rc == 0 {
  while _rc == 0 {
   loc p=`p'*10
   capture assert float(`v') == float(round(`v',`p')) if `touse'
   }
  loc p=`p'/10
  }
 else {
  while _rc {
   loc p=`p'/10
   capture assert float(`v') == float(round(`v',`p')) if `touse'
   }
  }
 return scalar units = `p'
end
