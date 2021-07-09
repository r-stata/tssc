program define latab

*! 1.1.1 Ian Watson 20jan2002 (Minor changes to display plus updated help file)
*  1.1 Ian Watson 16dec2002 (File output option added)
*  1.0.2 Ian Watson 9dec2002 (Fixed indents in multicolumns)
*  1.0.2 Ian Watson 5dec2002 (Fixed footnote to span columns)
*  1.0.1 Ian Watson 27nov2002 (Support for tabularx included)
*  1.0.0 Ian Watson 25nov2002
    version 7.0
    syntax varlist(max=2) [if] [in] [fweight aweight iweight] [,tf(string) Replace APPend ncom dec(string) row col tx(string)]
    
    tokenize `varlist'

    tempvar touse 
    tempname hh 
    
    mark `touse' `if' `in'

    local totper="100"
    local nvars : word count `varlist'
    
     if "`ncom'" ~=""{        
                   local tail="f" 
                   }
                   else {
                   local tail="fc"
                   }
    
     if "`dec'" ~=""{
                   local head="`dec'" 
                   }
                   else {
                   local head="0"
                   }

     if "`tx'" ~=""{
                     if "`tx'"=="0" {
                     local wide="\linewidth" 
                     }
                     else {
                     local wide="`tx'cm"
                     }
                    } 

     

    local form="%9.`head'`tail'"

   if "`row'"~= "row" & "`col'"~="col"{
         local perc="" 
         }
         else {
           if "`row'"=="row"{
             local perc="row"
             }
             else if "`col'"=="col"{
             local perc="col"
             }
         }


    if `nvars'==2 {
     qui{
        tabulate `1' `2' [`weight' `exp'] if `touse', /*
        */ matrow(rowname) matcol(colname) matcell(cells)
       } 
    mat rtots=rowname
    mat ctots=colname
    local grandtot=r(N) 
    local rowvarlbl: variable label `1'
    local colvarlbl: variable label `2'
    local rowvallbl : value label `1'
    local colvallbl : value label `2'
    if "`colvallbl'"=="" | "`rowvallbl'"==""{
      di
      di in red "Variable(s) are not labelled! Cannot proceed."
      di in red "Define/attach labels for variable(s), then re-run."
      exit
    }
    local i=r(r)
    local j=r(c)
    local m=1
    local n=1
      while `m'<=`i' {
        local n=1
        mat rtots[`m',1]=0
        while `n'<=`j'{
            mat rtots[`m',1]=rtots[`m',1]+cells[`m',`n']
            local n=`n'+1
        }
        local m=`m'+1
      }           
      local m=1
      local n=1
      while `n'<=`j' {
        local m=1
        mat ctots[1,`n']=0
        while `m'<=`i'{
            mat ctots[1,`n']=ctots[1,`n']+cells[`m',`n']
            local m=`m'+1
        }
        local n=`n'+1
      }  
    local m=1
    local n=1
    di
    di in green "\begin{table}[htbp]\centering"
    if "`tx'"~=""{
    di "\newcolumntype{Y}{>{\raggedleft\arraybackslash}X}"
    di "\parbox{`wide'} {"
    }
    di "\caption{\label{`1'_by_`2'} "
    di _c "\textbf{`rowvarlbl' by " lower("`colvarlbl'") 
    if "`perc'"~="" {
      di _c "~(\%)}}" 
      }
      else {
      di _c "}}" 
      }
    if "`tx'"~="" {
    di "}"
    di _c "\begin{tabularx} {`wide'} {@{} l"
    }
    else {
    di
    di _c "\begin{tabular} {@{} l"
    }
    local p=1
    while `p'<=`j' {
      if "`tx'"~="" {
        di _c " Y "
        }
        else {
        di _c " r "
        }
      local p=`p'+1
      }
      if "`tx'"~="" {
        di _c "Y @{}} \\\ \hline"
        }
        else {
        di _c "r @{}} \\\ \hline"
        }
     di
     di "& \multicolumn{" `j'+1 "}{@{} c @{}}{\textbf{`colvarlbl'}} \\\"
     di "\textbf{`rowvarlbl'} & "
     local p=1
     while `p'<=`j' {
       local colnum=colname[1,`p']
       local colabel: label `colvallbl' `colnum'
       di _c "`colabel' &"
       local p=`p'+1
       }
     di "Total \\\  \hline"  
    while `m'<=`i' {
      local n=1
      local rownum=rowname[`m',1]
      local rowlabel: label `rowvallbl' `rownum'
      di _c in yellow "`rowlabel'"  
      di _c "&"
      while `n'<=`j' {
        if "`perc'"=="" {
          di _c `form' cells[`m',`n']
          }
          else if "`perc'"=="row"{
          di _c `form' (cells[`m',`n']/rtots[`m',1])*100
          }
          else if "`perc'"=="col"{
          di _c `form' (cells[`m',`n']/ctots[1,`n'])*100
          }
          di _c "&"
          local n=`n'+1
      }  
      if "`perc'"=="" {
        di _c `form' rtots[`m',1]
        }
        else if "`perc'"=="row"{
        di _c `form' `totper'
        }
        else if "`perc'"=="col" {
        di _c `form' (rtots[`m',1]/`grandtot')*100
        }
      di _c "\\\"
      di
      local m=`m'+1
      }
      di _c "Total"
      local f=1
      while `f'<=`j' {
        di _c "&"
        if "`perc'"=="" {
          di _c  `form' ctots[1,`f']
          }
          else if "`perc'"=="row"{
          di _c  `form' (ctots[1,`f']/`grandtot')*100
          }
          else if "`perc'"=="col" {
          di _c  `form' `totper'
          }
        local f=`f'+1
        } 
        di _c "&"
        if "`perc'"=="" {
          di _c `form' `grandtot'
          }
          else {
          di _c  `form' `totper'
          }
      di _c "\\\"
      di in green "\hline "     
      di _c  "\multicolumn{" `j'+2 "}{@{}l}{"
      di  "\footnotesize{\emph{Source:} $S_FN}}"
    if "`tx'"~=""{
      di "\end{tabularx}"
      }
      else {
      di "\end{tabular}"      
      }
      di "\end{table}"
      di          
      di
      di in white "This table can be cross-referenced in the body of your text"
      di in white "with the name: `1'_by_`2'"
      di
    }  * end if 2 vars
     else if `nvars'==1{
     qui {
        tabulate `1' [`weight' `exp'] if `touse', matrow(rowname) matcell(cells)
        }  
      local varlbl : variable label `1'
      local vallbl : value label `1'
      local grandtot=r(N)
      local i=r(r)
      local m=1 
      if "`vallbl'"==""{
      di
      di in red "Variable is not labelled! Cannot proceed."
      di in red "Define/attach labels for variable, then re-run."
      exit
      }
      di
      di in green "\begin{table}[htbp]\centering
      di "\caption{\label{freq_`1'} "
      di "\textbf{`varlbl'}}"
      di _c "\begin{tabular} {@{} l r r @{}} \\\ "
      di "\hline"
      di "Item& Number & Per cent \\\"
      di "\hline"
      while `m'<=`i' {                 
        local num=rowname[`m',1]
        local rowlabel: label `vallbl' `num'
        di _c in yellow "`rowlabel'"
        di _c "&"
        di _c  `form' cells[`m',1]       
        di _c "&"
        di _c  `form' (cells[`m',1]/`grandtot')*100
        local m=`m'+1
        di _c "\\\"
        di
        }
      di _c "Total"
      di _c  "&" 
      di _c `form' `grandtot'
      di _c "&"
      di _c `form' `totper'
      di _c "\\\"
      di 
      di in green "\hline"
      di _c  "\multicolumn{3}{@{}l}{"
      di "\footnotesize{\emph{Source:} $S_FN}}"
      di "\end{tabular}"
      di "\end{table}"
      di          
      di
      di in white "This table can be cross-referenced in the body of your text"
      di in white "with the name: freq_`1'"
      di
       
    } * end if one var
         

     if "`tf'" ~="" {
       if "`replace'" == "replace" {local opt "replace"}
       if "`append'" == "append" {local opt "append"}
       file open `hh' using"`tf'.tex", write `opt'
       if `nvars'==2 {
         file write `hh' _n 
         file write `hh' "\begin{table}[htbp]\centering" _n
         if "`tx'"~=""{
           file write `hh' "\newcolumntype{Y}{>{\raggedleft\arraybackslash}X}" _n
           file write `hh' "\parbox{`wide'} {" _n
           }
         file write `hh' "\caption{\label{`1'_by_`2'} " _n
         file write `hh'  "\textbf{`rowvarlbl' by `colvarlbl'" 
         if "`perc'"~="" {
           file write `hh' "~(\%)}}" 
           }
           else {
           file write `hh' "}}" 
           }
         if "`tx'"~="" {
           file write `hh' "}" _n
           file write `hh' "\begin{tabularx} {`wide'} {@{} l"
           }
           else {
           file write `hh'  _n
           file write `hh' "\begin{tabular} {@{} l"
           }
         local p=1
         while `p'<=`j' {
           if "`tx'"~="" {
             file write `hh' " Y "
             }
             else {
             file write `hh' " r "
             }
           local p=`p'+1
           }  * while loop
         if "`tx'"~="" {
           file write `hh' "Y @{}} \\\ \hline"
           }
           else {
           file write `hh' "r @{}} \\\ \hline"
           }
         file write `hh' _n 
         file write `hh' "& \multicolumn{" (`j'+1) "}{@{} c @{}}{\textbf{`colvarlbl'}} \\\" _n
         file write `hh' "\textbf{`rowvarlbl'} & " _n
         local p=1
         while `p'<=`j' {
           local colnum=colname[1,`p']
           local colabel: label `colvallbl' `colnum'
           file write `hh' "`colabel' &"
           local p=`p'+1
           } * while loop
         file write `hh' "Total \\\  \hline" _n
         local m=1
         while `m'<=`i' {
           local n=1
           local rownum=rowname[`m',1]
           local rowlabel: label `rowvallbl' `rownum'
           file write `hh' "`rowlabel'"  
           file write `hh' "&"
           while `n'<=`j' {
             if "`perc'"=="" {
               file write `hh' `form' (cells[`m',`n'])
               }
               else if "`perc'"=="row"{
               file write `hh' `form' (cells[`m',`n']/rtots[`m',1])*100
               }
               else if "`perc'"=="col"{
               file write `hh' `form' (cells[`m',`n']/ctots[1,`n'])*100
               }
             file write `hh' "&"
             local n=`n'+1
             } * inner while loop  
           if "`perc'"=="" {
             file write `hh'  `form' (rtots[`m',1])
             }
             else if "`perc'"=="row"{
             file write `hh' `form' (`totper')
             }
             else if "`perc'"=="col" {
             file write `hh' `form' (rtots[`m',1]/`grandtot')*100
             } * end if
           file write `hh' "\\\"
           file write `hh' _n 
           local m=`m'+1
           } * outer while loop
         file write `hh' "Total"
         local f=1
         while `f'<=`j' {
           file write `hh' "&"
           if "`perc'"=="" {
             file write `hh'  `form' (ctots[1,`f'])
             }
             else if "`perc'"=="row"{
             file write `hh'  `form' (ctots[1,`f']/`grandtot')*100
             }
             else if "`perc'"=="col" {
             file write `hh'  `form' (`totper')
             }
           local f=`f'+1
           } * while loop 
           file write `hh' "&"
           if "`perc'"=="" {
             file write `hh'  `form' (`grandtot')
             }
             else {
             file write `hh'  `form' (`totper')
             }
         file write `hh' "\\\"
         file write `hh' "\hline " _n
         file write `hh' "\multicolumn{" (`j'+2) "}{@{}l}{"
         file write `hh'  "\footnotesize{\emph{Source:} $S_FN}}" _n
         if "`tx'"~=""{
           file write `hh' "\end{tabularx}" _n
           }
           else {
           file write `hh' "\end{tabular}"  _n
           }
         file write `hh' "\end{table}" _n
         file write `hh' _n
         file write `hh' _n 
         di
         di in white "The table has been written to the file:`tf'.tex"
         file write `hh' _n 
         file close `hh'
       }  * end if 2 vars
       else if `nvars'==1{
         file write `hh' _n 
         file write `hh' "\begin{table}[htbp]\centering " _n
         file write `hh' "\caption{\label{freq_`1'} " _n
         file write `hh' "\textbf{`varlbl'}}" _n
         file write `hh' "\begin{tabular} {@{} l r r @{}} \\\ "
         file write `hh' "\hline" _n
         file write `hh' "Item& Number & Per cent \\\" _n
         file write `hh' "\hline" _n
         local m=1
         while `m'<=`i' {                 
           local num=rowname[`m',1]
           local rowlabel: label `vallbl' `num'
           file write `hh' "`rowlabel'"
           file write `hh' "&"
           file write `hh'  `form' (cells[`m',1])
           file write `hh' "&"
           file write `hh'  `form' (cells[`m',1]/`grandtot')*100
           local m=`m'+1
           file write `hh' "\\\"
           file write `hh' _n 
           } * while loop
         file write `hh' "Total"
         file write `hh'  "&" 
         file write `hh' `form' (`grandtot')
         file write `hh' "&"
         file write `hh' `form' (`totper')
         file write `hh' "\\\"
         file write `hh' _n
         file write `hh' "\hline" _n
         file write `hh' "\multicolumn{3}{@{}l}{"
         file write `hh' "\footnotesize{\emph{Source:} $S_FN}}" _n
         file write `hh' "\end{tabular}" _n
         file write `hh' "\end{table}" _n
         file write `hh' _n
         file write `hh' _n 
         di
         di in white "The table has been written to the file: `tf'.tex"
         file write `hh' _n 
         file close `hh' 
       } * end if one var
    } * end if tex file option


end
