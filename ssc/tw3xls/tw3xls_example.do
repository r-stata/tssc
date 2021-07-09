/* that's a supplementary code for -tw3xls-
it reproduces files example1.xlsx and example2.xlsx */

* create and set a working directory
cap mkdir "C:/tw3xls/"
cd "C:/tw3xls/"

* load the dataset
sysuse auto, clear

* convert encoded variable into string
decode foreign, gen(foreign_str)

* write output tables to example1.xlsx
** use encoded variable "foreign" - column names contain numbers. 
** The output is written to "Data" worksheet (defailt name)
tw3xls mpg rep78 foreign using example1, stub(ms) missing(.) show
** use decoded variable "foreign_str" - column names contain associated string values. 
** The output is written to "Data2" worksheet
tw3xls mpg rep78 foreign_str using example1, by(headroom) stub(ms) mi(.) show sheet(Data2) modify

* write output tables to example2.xlsx
** format Excel table - draw bordes, set alignment, merge table header text
tw3xls mpg rep78 foreign_str using example2, by(headroom) stub(ms) mi(0) show format
** format and merge supercolumn names, save the data onto "Data merge" worksheet
tw3xls mpg rep78 foreign_str using example2, by(headroom) stub(ms) mi(0) show format mergecells sheet("Data merge") modify 
