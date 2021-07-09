* version 1.0 2008-01-22
*! version 1.01 2008-02-07
*   Different symbols for AR and MA roots in plot
*! Sune.Karlsson@oru.se
*
*! Roots of ARMA AR- and MA-polynomials
*


program define armaroots
version 9

syntax [, noGraph]

if "`e(cmd)'" == "arima" {
  // ARIMA, get AR and MA polynoimals

  local plotnum = 2
  tempname poly spoly respoly arpoints
  
  GetPoly "ar" `poly' `spoly'
  mata: char_roots( "`poly'", "`spoly'", "`respoly'" )
  local nc = colsof(`respoly')
  if ( `nc' > 0 ) {
    PrintRes "Characteristic roots of AR-polynomial" `respoly'
    GetPoints `respoly'
    local arscat `"(scatteri `r(points)' msymbol(S))"'
    local plotnum = `plotnum' + 1
    local arlegend `"`plotnum' "AR roots""'
  }
  
  GetPoly "ma" `poly' `spoly'
  mata: char_roots( "`poly'", "`spoly'", "`respoly'" )
  local nc = colsof(`respoly')
  if ( `nc' > 0 ) {
    PrintRes "Characteristic roots of MA-polynomial" `respoly'
    GetPoints `respoly'
    local mascat `"(scatteri `r(points)', msymbol(T))"'
    local plotnum = `plotnum' + 1
    local malegend `"`plotnum' "MA roots""'
  }
  
  if "`graph'" == "" & `plotnum' > 2 { 
    twoway (function y = sqrt(1-x*x), range(-1 1) lstyle(refline)     ///
             )                                                        ///
           (function y = -1*sqrt(1-x*x), range(-1 1) lstyle(refline)  ///
            )                                                         ///
           `arscat'  `mascat'  ,                                      ///
           xlabel(-1 -.5 0 .5 1, nogrid) xtic( 0, grid )              ///
           xtitle("Real") ylabel(-1 -.5 0 .5 1, nogrid)               ///
           ytic( 0, grid ) ytitle("Imaginary") aspect(1)              ///
           title("Characteristic roots")                              ///
           legend(order(`arlegend' `malegend') pos(3) col(1))
  }
  else if `plotnum' == 2 {
    di as text "No AR or MA parameters in model"
  }
  
} 
else {

  di as err "armaroots can only be run after {help arima}"
  exit 198

}

end

program define GetPoly

  args type poly spoly
  
  local nterm = 0
  local nsterm = 0
  local maxlag = 0
  local smaxlag = 0
  local period = 0
  
  local parnames : colfullnames e(b)
  // count occurrences of ARMA terms in parameter list
  foreach name of local parnames {
    if regexm( "`name'", "^ARMA([0-9]+):L([0-9]*)\.`type'$" ) { 
      local period = regexs(1)
      local slag = regexs(2)
      if "`slag'" == "" local slag = 1
      if `slag' > `smaxlag' {
        local smaxlag = `slag'
      }
      local nsterm = `nsterm' + 1
    }
    else if regexm( "`name'", "^ARMA:L([0-9]*)\.`type'$" ) { 
      local lag = regexs(1)
      if "`lag'" == "" local lag = 1
      if `lag' > `maxlag' {
        local maxlag = `lag'
      }
      local nterm = `nterm' + 1
    }
  }

  tempname parmat
  matrix `poly' = J(1,`maxlag'+1,0)
  matrix `poly'[1,1] = 1
  matrix `spoly' = J(1,`period'*`smaxlag'+1,0)
  matrix `spoly'[1,1] = 1
  matrix `parmat' = e(b)
  if "`type'" == "ar" {
    local mult = -1.0
  }
  else {
    local mult = 1.0
  }
  
  if `nterm' > 0 {
    foreach name of local parnames {
      if regexm( "`name'", "^ARMA:L([0-9]*)\.`type'$" ) { 
        local lag = regexs(1)
        if "`lag'" == "" local lag = 1
        matrix `poly'[1,`lag'+1] = `mult'*`parmat'[1,`"`name'"']
      }
    }

  }
    
  if `nsterm' > 0 {
    foreach name of local parnames {
      if regexm( "`name'", "^ARMA([0-9]+):L([0-9]*)\.`type'$" ) { 
        local lag = regexs(2)
        if "`lag'" == "" local lag = 1
        matrix `spoly'[1,`period'*`lag'+1] = `mult'*`parmat'[1,`"`name'"']
      }
    }

  }

end

program define GetPoints, rclass

  args results

  local dim = colsof(`results')
  local pts ""
  
  forvalues i=1(1)`dim' {

    local x = `results'[1,`i']
    local y = `results'[2,`i']
    local pts `"`pts' `y' `x' "'
    
  }

  return local points `"`pts'"'
  
end

program define PrintRes 

  args title results

  tempname table1 table2
  .`table1' = ._tab.new, col(3) 
  .`table1'.width |26|13|12| 


  .`table2' = ._tab.new, col(4)
  .`table2'.width |12 14|13|12|
  
  .`table2'.strcolor . yellow . .
  .`table2'.numcolor  yellow  . yellow .
  .`table2'.numfmt %10.7g .  %8.7g  %6.3g
  .`table2'.pad 1 . 2 3


  di _n as text "{col 4}`title'
  .`table1'.sep, top
  .`table1'.titles  "Characteristic roots " "Modulus  " "Period  "
  .`table1'.sep, mid
  
  local dim = colsof(`results')

  forvalues i=1(1)`dim' {

    if `results'[2,`i'] == 0 {
      .`table2'.row `results'[1,`i'] ///
          ""    ///
          `results'[3,`i']  "" 
    }
    else {
      if  `results'[2,`i'] < 0 {
        local c_el : display "-" %10.7g  -1*`results'[2,`i'] "{it:i}"  
      }
      else {
        local c_el : display "+" %10.7g  `results'[2,`i'] "{it:i}"  
      } 
      .`table2'.row `results'[1,`i'] ///
          "`c_el'"  ///
          `results'[3,`i']  `results'[4,`i'] 
    }

  } 
  .`table1'.sep, bot

end

**********************************

mata:

mata set matastrict on

void char_roots( string scalar poly1, poly2, polyres )
{
// Calculate characteristic roots and other interesting stuff

real rowvector poly_a, poly_b, polytot
real matrix results
complex roots

poly_a = st_matrix( poly1 )
poly_b = st_matrix( poly2 )

// reverse orders since we want characteristic polynomial
poly_a = poly_a[(cols(poly_a)::1)]
poly_b = poly_b[(cols(poly_b)::1)]

// get roots
roots = polyroots( polymult( poly_a, poly_b ) )

results = Re(roots) \ Im(roots) \ abs(roots)
results = results \ 2*pi():/acos( results[1,] :/ results[3,.] )


for ( i=1; i<=cols(results); i++ ) {
  if ( abs(results[2,i]) < 1e-8 ) {
    results[2,i] = 0
    results[4,i] = .
  }
}

results = results'
results = sort( results, (-3,-1,-2) )'

st_matrix( polyres, results )

}

end
