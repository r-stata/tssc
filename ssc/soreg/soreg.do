log using soreg, replace
use nausea, clear
* @begin{ex1}
soreg nausea treat
* @end{ex1}

use backpain, clear
* @begin{ex2}
soreg pain x1 x2 x3
* @end{ex2}

use pneum, clear
* @begin{ex3}
constraint define 1 phi11 = 0
constraint define 2 phi21 = 1
soreg pneum lyears, c(1 2)
* @end{ex3}

use nausea, clear
* @begin{ex4}
constraint define 1 phi11 = phi21
constraint define 2 phi11 = phi31
constraint define 3 phi41 = phi51
constraint define 4 phi41 = phi61
constraint define 5 phi11 = 1
constraint define 6 phi61 = 0
* @end{ex4}

* @begin{ex5}
soreg nausea treat, c(1/6)
* @end{ex5}

log close

