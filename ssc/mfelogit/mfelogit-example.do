
/* Use the quick method in DDL at last observed period */
use "https://www.stata-press.com/data/r17/union.dta", clear
mfelogit union age black if (year <=78), id("idcode") time("year") method("quick")

/* Use the sharp method in DDL at last observed period */
use "https://www.stata-press.com/data/r17/union.dta", clear
mfelogit union age black if (year <=78), id("idcode") time("year") method("sharp")

/* Use the quick method in DDL at all periods */
use "https://www.stata-press.com/data/r17/union.dta", clear
mfelogit union age black if (year <=78), id("idcode") time("year") method("quick") listT("all") 
