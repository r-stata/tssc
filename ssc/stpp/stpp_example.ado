program define stpp_example
  version 16.0
  syntax [, EGNUMBER(integer 1)]
  
  if `egnumber' == 1 {
 
display ///
`". stpp R_pp1 using "https://pclambert.net/data/popmort.dta" , ///"' _newline ///
"                  agediag(age) datediag(dx)                    ///" _newline  ///
"                  pmother(sex) list(1 5 10)" _newline  
 
stpp R_pp1 using "https://pclambert.net/data/popmort.dta", ///
                  agediag(age) datediag(dx)                  ///
                  pmother(sex) list(1 5 10) 
display ///                  
". twoway  (rarea R_pp1_lci R_pp1_uci _t, color(red%30) connect(stairstep)) ///" _newline ///
"        (line R_pp1 _t, lcolor(red) connect(stairstep))                    ///" _newline ///
"        ,legend(off)                                                       ///" _newline ///
"        xtitle(Years from diagnosis)                                       ///" _newline ///
"        ytitle(Marginal relative survival)                                 ///" _newline ///
"        name(R_pp1, replace)"   

twoway  (rarea R_pp1_lci R_pp1_uci _t, color(red%30) connect(stairstep)) ///
        (line R_pp1 _t, lcolor(red) connect(stairstep))                  ///
        ,legend(off)                                                     ///
        xtitle(Years from diagnosis)                                     ///
        ytitle(Marginal relative survival)                               ///
        name(R_pp1, replace)                   
  }
  else if `egnumber' == 2 {
  	
display ///
`". stpp R_pp2 using "https://pclambert.net/data/popmort.dta" , ///"' _newline ///
"                  agediag(age) datediag(dx)                    ///" _newline  ///
"                  pmother(sex) list(1 5 10)                    ///" _newline  ///
"                  by(sex)                                      ///"
 
stpp R_pp2 using "https://pclambert.net/data/popmort.dta", ///
                  agediag(age) datediag(dx)                ///
                  pmother(sex) list(1 5 10)                ///
                  by(sex)
                  
display ///                  
". twoway  (rarea R_pp2_lci R_pp2_uci _t if sex==1, color(red%30) connect(stairstep)) ///" _newline ///
"        (line R_pp1 _t if sex==1, lcolor(red) connect(stairstep))                    ///" _newline ///
"        (rarea R_pp2_lci R_pp2_uci _t if sex==2, color(red%30) connect(stairstep))   ///" _newline ///
"        (line R_pp2 _t if sex==2, lcolor(red) connect(stairstep))                    ///" _newline ///
"        ,legend(off)                                                                 ///" _newline ///
"        xtitle(Years from diagnosis)                                                 ///" _newline ///
"        ytitle(Marginal relative survival)                                           ///" _newline ///
"        name(R_pp1, replace)"   

twoway  (rarea R_pp2_lci R_pp2_uci _t if sex==1, color(red%30) connect(stairstep))  ///
        (line R_pp2 _t if sex==1, lcolor(red) connect(stairstep))                   ///
        (rarea R_pp2_lci R_pp2_uci _t if sex==2, color(blue%30) connect(stairstep)) ///
        (line R_pp2 _t if sex==2, lcolor(blue) connect(stairstep))                  ///
        ,legend(order(2 "males" 4 "females") ring(0) pos(1))                        ///
        xtitle(Years from diagnosis)                                                ///
        ytitle(Marginal relative survival)                                          ///
        name(R_pp2, replace)      
    
    
  }
  else if `egnumber' == 3 {

display ///
". recode age (min/44=1) (45/54=2) (55/64=3) (65/74=4) (75/max=5), gen(ICSSagegrp)" _newline ///
`". stpp R_pp3 using "https://pclambert.net/data/popmort.dta" , ///"' _newline ///
"                  agediag(age) datediag(dx)                    ///" _newline  ///
"                  pmother(sex) list(1 5 10)                    ///" _newline  ///
"                  by(sex)                                      ///" _newline  ///
"                  standstrata(ICSSagegrp)                      ///" _newline  ///
"                  standweight(0.07 0.12 0.23 0.29 0.29)        ///" 
 
recode age (min/44=1) (45/54=2) (55/64=3) (65/74=4) (75/max=5), gen(ICSSagegrp)
stpp R_pp3 using "https://pclambert.net/data/popmort.dta", ///
                  agediag(age) datediag(dx)                ///
                  pmother(sex) list(1 5 10)                ///
                  by(sex)                                  ///
                  standstrata(ICSSagegrp)                  ///
                  standweight(0.07 0.12 0.23 0.29 0.29)   
                  
display ///                  
". twoway  (rarea R_pp3_lci R_pp3_uci _t if sex==1, color(red%30) connect(stairstep)) ///" _newline ///
"        (line R_pp3 _t if sex==1, lcolor(red) connect(stairstep))                    ///" _newline ///
"        (rarea R_pp3_lci R_pp3_uci _t if sex==2, color(red%30) connect(stairstep))   ///" _newline ///
"        (line R_pp3 _t if sex==2, lcolor(red) connect(stairstep))                    ///" _newline ///
"        ,legend(off)                                                                 ///" _newline ///
"        xtitle(Years from diagnosis)                                                 ///" _newline ///
"        ytitle(Marginal relative survival)                                           ///" _newline ///
"        name(R_pp3, replace)"   

twoway  (rarea R_pp3_lci R_pp3_uci _t if sex==1, color(red%30) connect(stairstep))  ///
        (line R_pp3 _t if sex==1, lcolor(red) connect(stairstep))                   ///
        (rarea R_pp3_lci R_pp3_uci _t if sex==2, color(blue%30) connect(stairstep)) ///
        (line R_pp3 _t if sex==2, lcolor(blue) connect(stairstep))                  ///
        ,legend(order(2 "males" 4 "females") ring(0) pos(1))                        ///
        xtitle(Years from diagnosis)                                                ///
        ytitle(Marginal relative survival)                                          ///
        name(R_pp3, replace)      
      
    
  }
  else if `egnumber' == 4 {
  	
display ///
"recode ICSSagegrp (1=0.28) (2=0.17) (3=0.21) (4=0.20) (5=0.14), gen(ICSSwt)" _newline ///
"bysort sex: gen sextotal= _N"                                             _newline    ///
"bysort ICSSagegrp sex:gen a_age = _N/sextotal"                       _newline         ///
"gen double wt_age = ICSSwt/a_age"	                                _newline           ///
`". stpp R_pp4 using "https://pclambert.net/data/popmort.dta" , ///"' _newline ///
"                  agediag(age) datediag(dx)                    ///" _newline  ///
"                  pmother(sex) list(1 5 10)                    ///" _newline  ///
"                  by(sex)                                      ///" _newline  ///
"                  indweights(wt_age)"                     

 
recode ICSSagegrp (1=0.07) (2=0.12) (3=0.23) (4=0.29) (5=0.29), gen(ICSSwt)
bysort sex: gen sextotal= _N
bysort ICSSagegrp sex:gen a_age = _N/sextotal
gen double wt_age = ICSSwt/a_age	
stpp R_pp4 using "https://pclambert.net/data/popmort.dta", ///
                  agediag(age) datediag(dx)                ///
                  pmother(sex) list(1 5 10)                ///
                  by(sex)                                  ///
                  indweights(wt_age)                       

                  
display ///                  
". twoway  (rarea R_pp4_lci R_pp4_uci _t if sex==1, color(red%30) connect(stairstep)) ///" _newline ///
"        (line R_pp4 _t if sex==1, lcolor(red) connect(stairstep))                    ///" _newline ///
"        (rarea R_pp4_lci R_pp4_uci _t if sex==2, color(red%30) connect(stairstep))   ///" _newline ///
"        (line R_pp4 _t if sex==2, lcolor(red) connect(stairstep))                    ///" _newline ///
"        ,legend(off)                                                                 ///" _newline ///
"        xtitle(Years from diagnosis)                                                 ///" _newline ///
"        ytitle(Marginal relative survival)                                           ///" _newline ///
"        name(R_pp4, replace)"   

twoway  (rarea R_pp4_lci R_pp4_uci _t if sex==1, color(red%30) connect(stairstep))  ///
        (line R_pp4 _t if sex==1, lcolor(red) connect(stairstep))                   ///
        (rarea R_pp4_lci R_pp4_uci _t if sex==2, color(blue%30) connect(stairstep)) ///
        (line R_pp4 _t if sex==2, lcolor(blue) connect(stairstep))                  ///
        ,legend(order(2 "males" 4 "females") ring(0) pos(1))                        ///
        xtitle(Years from diagnosis)                                                ///
        ytitle(Marginal relative survival)                                          ///
        name(R_pp4, replace)      
          
  }  
  
end   