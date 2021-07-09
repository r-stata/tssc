//! version 1.3 31DEC2018  DIME Analytics bbdaniels@gmail.com

// txt2qr - Stata module to produce QR codes containing plain text.

cap prog drop txt2qr
prog def txt2qr

version 9.0

syntax anything using/ , [save] [replace]

local anything = subinstr("`anything'"," ","%20",.)

copy `"http://chart.apis.google.com/chart?cht=qr&chs=400x400&chl=`anything'&chld=H|0"' `using' , `s' `replace'

end
