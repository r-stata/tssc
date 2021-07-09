/*

   Sergiy Radyakin 12. Aug, 2007

Demonstration of -parea- capabilities.
Draw 10 patterned rectangles in a 2 by 5 formation

*/

#delimit ;

clear;
set obs 60;
gen x=. ;
gen y=. ;
gen p=. ;

forvalues i=1/10 { ;
  local sh_y=0 ;
  if `i'>5 local sh_y=1 ;
  quietly replace x=`i'-.2-`sh_y'*5  in `=`i'*6-5' ;
  quietly replace x=`i'-1 -`sh_y'*5  in `=`i'*6-4' ;
  quietly replace x=`i'-1 -`sh_y'*5  in `=`i'*6-3' ;
  quietly replace x=`i'-.2-`sh_y'*5  in `=`i'*6-2' ;
  quietly replace x=`i'-.2-`sh_y'*5  in `=`i'*6-1' ;

  quietly replace y=`sh_y'*0.55      in `=`i'*6-5' ;
  quietly replace y=`sh_y'*0.55      in `=`i'*6-4' ;
  quietly replace y=`sh_y'*0.55+.5   in `=`i'*6-3' ;
  quietly replace y=`sh_y'*0.55+.5   in `=`i'*6-2' ;
  quietly replace y=`sh_y'*0.55      in `=`i'*6-1' ;  

  quietly replace p=`i' in `=`i'*6-5'/`=`i'*6-1'   ;
  local labl `"`labl' label(`i' "pattern`i'")"'    ;
} ;

local GRAPHCMD="twoway " ;
forvalues i=1/10 { ;
  local GRAPHCMD `"`GRAPHCMD' parea y x if p==`i',lc(black) fc(black)
                           pattern(pattern`i') fi(100) nodropb `=cond(`i'<10,"||","")'"' ;
};

local GRAPHCMD `"`GRAPHCMD' graphregion(color(white) margin(zero))
                            plotregion(style(none) color(white))
                            xlabel(none) xscale(off r(0 4.5)) 
                            ylabel(none) yscale(off r(0 1.05))
			    legend(cols(5) `labl') scale(0.8)
                            title("twoway parea y x,...") subtitle("Sergiy Radyakin") "'  ;

`GRAPHCMD' ;

