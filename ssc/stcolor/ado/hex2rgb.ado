* 把16进制的颜色代码转为RGB颜色代码
* rgb2hex 244 199 195, p
* hex2rgb #F4C7C3, p
cap prog drop hex2rgb
prog def hex2rgb, rclass
  version 14.0
  syntax anything [, Play]
  local r1 = substr("`anything'", 2, 1)
  local r2 = substr("`anything'", 3, 1)
  local g1 = substr("`anything'", 4, 1)
  local g2 = substr("`anything'", 5, 1)
  local b1 = substr("`anything'", 6, 1)
  local b2 = substr("`anything'", 7, 1)
  foreach n in "r1" "r2" "g1" "g2" "b1" "b2"{
      if "``n''" == "A" local `n' = 10
      else if "``n''" == "B" local `n' = 11
      else if "``n''" == "C" local `n' = 12
      else if "``n''" == "D" local `n' = 13
      else if "``n''" == "E" local `n' = 14
      else if "``n''" == "F" local `n' = 15
      else if "``n''" == "a" local `n' = 10
      else if "``n''" == "b" local `n' = 11
      else if "``n''" == "c" local `n' = 12
      else if "``n''" == "d" local `n' = 13
      else if "``n''" == "e" local `n' = 14
      else if "``n''" == "f" local `n' = 15
  }
  local r = `r1' * 16 + `r2'
  local g = `g1' * 16 + `g2'
  local b = `b1' * 16 + `b2'
  local rm = 255 - `r'
  local gm = 255 - `g'
  local bm = 255 - `b'
  di in green "`r' `g' `b'"
  ret local rgb = "`r' `g' `b'"
  if "`play'" != "" tw scatteri 0 0 , ysc(off) xsc(off) ms(i) plotr(fc(`r' `g' `b')) text(0 0 "RGB(`r' `g' `b')" "`anything'", size(*4) color(rgb(`rm' `gm' `bm')))
end

