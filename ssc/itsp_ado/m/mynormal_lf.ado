

*! mynormal_lf v1.0.1  CFBaum 11aug2008
program mynormal_lf
  version 10.1
  args lnf mu lnsigma
  quietly replace `lnf' = ln( normalden( $ML_y1,  `mu', exp(`lnsigma') ) )
end
