
.-
help for ^reshape3^                                             
.-

An enhancement of reshape
-------------------------

        ^reshape3 wide varilist, i(varlist) j(varlist) [string]^
        ^reshape3 wide (varlist) ... (varlist), i(varlist) j(varlist) [string]^
        ^reshape3 long varlist, i(varlist) j(newvarlist) [string]^
        ^reshape3 long (varlist) ... (varlist), i(varlist) j(newvarlist) [string]^
     


Description
-----------

^reshape3^ converts data from wide to long and vice-versa. It can be use to manipulate the data
that contains more than 2 levels.

^reshape long^ converts data to long format.  

^reshape wide^ converts data to wide format.


Example 1
---------


    t   id1 id2 id3 y     t   y111    y211    y121    y221    y112    y212    y122    y222
    -----------------     ----------------------------------------------------------------
    1   1   1   1   1     1      1       5       3       7       2       6       4       8
    1   1   1   2   2     2      9      13      11      15      10      14      12      16
    1   1   2   1   3                                           
    1   1   2   2   4                                           
    1   2   1   1   5                                           
    1   2   1   2   6                                           
    1   2   2   1   7                                           
    1   2   2   2   8                                           
    2   1   1   1   9                                           
    2   1   1   2   10                                          
    2   1   2   1   11                                          
    2   1   2   2   12                                          
    2   2   1   1   13                                          
    2   2   1   2   14                                          
    2   2   2   1   15                                          
    2   2   2   2   16  


    . clear
    . set obs 2
    . gen t=_n
    . expand 2, gen(id1)
    . replace id1=id1+1
    . expand 2
    . bys t id1: gen id2=_n
    . expand 2
    . bys t id1 id2: gen id3=_n
    . gen y=_n
    . reshape3 wide y, i(t) j(id1 id2 id3) // [left --> right] 
    . local z1 y11 y12 y21 y22 
    . local z2 y1 y2
    . local z3 y
    . reshape3 long `z1', i(t) j(id3 id2 id1) // [right -->left] 
    .  * This is equivalent to 
    .  * reshape3 long (`z1') (`z2') (`z3'), i(t) j(id3 id2 id1)
    . order t id1 id2 id3
    . sort y


Example 2
---------

    t      x1      x2      y8     y9      t   id1  id2      x       y
    ---------------------------------     ----------------------------
    1   0.872   0.902   0.279   0.980     1     1    8   0.872   0.279
    2   0.755   0.213   0.623   0.346     1     1    9   0.872   0.980
                                          1     2    8   0.902   0.279
                                          1     2    9   0.902   0.980
                                          2     1    8   0.755   0.623
                                          2     1    9   0.755   0.346
                                          2     2    8   0.213   0.623
                                          2     2    9   0.213   0.346


    . clear
    . set obs 2
    . set seed 222
    . gen t=_n
    . gen x1=uniform()
    . gen x2=uniform()
    . gen y8=uniform()
    . gen y9=uniform()
    . format x* y* %6.3f
    . reshape3 long (x) (y), i(t) j(id1 id2)   // [left --> right] 
    . reshape3 wide (x) (y), i(t) j(id1 id2)   // [right -->left] 
    . order t x*




Author
------

       Kerry Du
       Shandong University
       China 
       email: kerrydu@@sdu.edu.cn

Also see
--------

On-line:  help for @reshape@, @reshape2@ (if installed), @stack@
