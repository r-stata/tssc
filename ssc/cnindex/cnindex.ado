 * Authors:
 * lizhiyong ,Beijing Idata Education&Technology Co.,Ltd. (lizhiyong618@foxmail.com)
 * September 1, 2015
 * Program written by lizhiyong
 * Used to download index tradding data for ShangHai or ShenZhen
 * Original Data Source: www.163.com 
 * Please do not use this code for commerical purpose
 capture program drop cnindex

 program define cnindex,rclass
  
 version 12.0
  syntax anything(name=tickers),  [ path(string)]
   * path, folder to save the downloaded file 
  
  local address http://quotes.money.163.com/service/chddata.html
  local field TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;VOTURNOVER;VATURNOVER;TCAP;MCAP
  
        local start 19900101
                local end: disp %dCYND date("`c(current_date)'","DMY")    
        
        if "`path'"~="" {
          capture mkdir `path'
                       } 
                                   
        if "`path'"=="" {
          local path `c(pwd)'
                  disp "`path'"
                       }                            
   
   foreach name in `tickers' {
   
     /*
   if length("`name'")>6 {
           disp as error `"`name' is an invalid stock code"'
           exit 601
             } 


         while length("`name'")<6 {
           local name = "0"+"`name'"
             }
			 */

         
    if `name'<=1000 {
        tempname csvfile
        qui capture copy "`address'?code=0`name'&start=`start'&end=`end'&fields=`field'\\`name'.csv"  `csvfile'.csv, replace
                 if _rc~=0 {
                 disp as error `"`name' is an invalid stock code"'
             exit 601
                  }
        }
		
		
     else {
        qui capture copy "`address'?code=1`name'&start=`start'&end=`end'&fields=`field'\\`name'.csv"  `csvfile'.csv, replace
                 if _rc~=0 {
                 disp as error `"`name' is an invalid stock code"'
             exit 601
                  }
              }
                    
    insheet using `csvfile'.csv, clear
    capture gen date = date(v1, "YMD")
        * cntrade  issues an error message if the stock code is not existing
        if _rc != 0 {
        disp as error `"`name' is an invalid stock code"'
        exit 601
        }
    
	drop v1 
    format date %dCY_N_D
    label var date "Trading Date"
    rename v2 stkcd 
    capture destring stkcd, replace force ignor(')
    label var stkcd "Stock Code"
    rename v3 stknme
    label var stknme "Stock Name"
    rename v4 clsprc 
    label var clsprc "Closing Price"
    drop if clsprc==0
    rename v5 hiprc 
    label var hiprc  "Highest Price"
    rename v6 lowprc 
    label var lowprc "Lowest Price"
    rename v7 opnprc
    label var opnprc "Opening Price"
    gen rit=0.01*real(v10)
	label var rit "Daily Return"
    rename v11 volume
    label var volume "Trading Volume"
	rename v12 transaction
    label var transaction "Trading Amount in RMB"

    drop v8 v9 v13 v10 mcap*csv
	
	
    */
    sort date 
    save  `"`path'/`name'"', replace
        erase `csvfile'.csv
        
        
    }


 end 

          
 
