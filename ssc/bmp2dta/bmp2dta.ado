*! 1.1 26 Jul 2017 Austin Nichols <austinnichols@gmail.com> fixed check for 24-bit Windows file
*! bmp2dta 1.0 program to save a 24-bit Windows bitmap file as a Stata dataset
* 1.0 14 Jul 2017 Austin Nichols <austinnichols@gmail.com>
prog bmp2dta
version 11
syntax using/ , Picture(string) [stub(string) replace ]
tempname checkbm o p offset width height zero r g b
file open `p' using `picture', read binary
file read `p' %2s `checkbm'
if "``checkbm''"!="BM" {
 di as err "picture(file) must be a 24-bit Windows bitmap file"
 error 198
 }
file seek `p' 10
file read `p' %2bu `offset'
file seek `p' 18
file read `p' %2bu `width'
file seek `p' 22
file read `p' %2bu `height'
file seek `p' `=scalar(`offset')'
loc pad=ceil(`width'*3/4)*4-(`width'*3)
postfile `o' `stub'i `stub'j `stub'r `stub'g `stub'b using `using', `replace'
forv i=1/`=scalar(`height')' {
 forv j=1/`=scalar(`width')' {
  file read `p' %1bu `r'
  file read `p' %1bu `g'
  file read `p' %1bu `b'
  post `o' (`i') (`j') (`=scalar(`r')') (`=scalar(`g')') (`=scalar(`b')')
  }
 if `pad'>0 {
  forv q=1/`pad' {
   file read `p' %1bu `zero'
   }
  }
 }
postclose `o'
cap file close `p' 
end

