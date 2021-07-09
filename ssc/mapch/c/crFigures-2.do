*/to create Examples 1 to 11, paper Ward Vanlaar, entitled: A shortcut through /*
*/long loops: an illustration of two alternatives for looping over observations /*
*/The Stata Journal /*


*/to create Figure 1
use testfileSJ, clear
sort date
list old updated date

*/to create Figure 2
use testfileSJ, clear
sort date
generate link = updated
save testfile1, replace

use testfileSJ, clear
generate link = old
append using testfile1
sort link date
by link: generate test1=_N
by link: generate test2=_n
list old updated date link

*/To create Figure 3
drop if test1!=2
list old updated date link

*/To create Figure 4
generate str2 recent=""
by link: replace recent=updated[_N]
sort old date
list old updated date link recent

*/To create Figure 5
by old: generate test3=_N
by old: drop if updated!=recent & test3>1
save testfile2, replace
list old updated date link recent

*/To create Figure 6
use testfileSJ, clear
sort old
merge old using testfile2
replace recent=updated if recent==""
drop link test1 test2 test3 _merge
erase testfile1.dta
erase testfile2.dta
list old updated date recent

*/To create Figure 7
use testfileSJ, clear
mapch old updated date

*/To create Figure 8
list

*/To create Figure 9a
use testfileSJ, clear
keep in 1/5
generate clone=updated
list old updated clone

*/To create Figure 9b
use testfileSJ, clear
keep in 1/5
rename old clone
rename updated terminal
list clone terminal

*/To create figure 10
use testfileSJ, clear
keep in 1/5
generate clone=updated
generate str1 terminal = "C" in 1
replace terminal = "D" in 2
list old updated clone terminal

*/To create figure 11
use testfileSJ, clear
keep in 1/5
replace updated = "C" in 1
replace updated = "D" in 2
list old updated
