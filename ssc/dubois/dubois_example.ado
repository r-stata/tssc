
net install grc1leg

insheet using https://raw.githubusercontent.com/ajstarks/dubois-data-portraits/master/challenge/challenge02/data.csv, clear

replace population=upper(population)

graph set svg fontface Tahoma
graph set eps fontface Tahoma
graph set ps fontface Tahoma
set scheme dubois

quietly graph hbar single married divorcedandwidowed if age=="15-40", over(population,)  stack ///
ylabel(none) blabel(bar, format(%2.1fc) size(small) position(center)) ///
legend(label(1 "SINGLE") label(2 "MARRIED") label(3 "DIVORCED AND WIDOWED") ///
rows(2) order(1 3 2) pos(12)) title("AGE" "  "  "15-40", position(9) size(medium)) name(g1540,replace)

quietly graph hbar single married divorcedandwidowed if age=="40-60", over(population,)  stack ///
ylabel(none) blabel(bar, format(%2.1fc) size(small) position(center)) ///
 title("40-60", position(9) size(medium)) name(g4060,replace)

quietly graph hbar single married divorcedandwidowed if age=="40-60", over(population,)  stack ///
ylabel(none) blabel(bar, format(%2.1fc) size(small) position(center)) ///
 title("60" "  "  "AND" " "  "OVER", position(9) size(medium)) name(gover60,replace)

grc1leg g1540 g4060 gover60, col(1) pos(12) title({bf:CONJUGAL CONDITION})
