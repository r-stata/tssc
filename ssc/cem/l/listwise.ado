/*
*  
* listwise.ado - drops observations from the data if any has missing values
* 
* Inputs: varlist: variables to use for listwise deletion
*
*/


program define listwise
version 10.1
syntax varlist

mata: st_dropobsif(rowmissing(st_data(.,tokens("`varlist'"))))

end
