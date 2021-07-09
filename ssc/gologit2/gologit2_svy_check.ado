*! version 3.2.5 17may2019 Richard Williams, rwilliam@nd.edu

program gologit2_svy_check
         version 11.2
         syntax [, AUTOfit AUTOfit2(string) STOre(name) Gamma Gamma2(name) svy gsvy *]
         if "`autofit'"!="" | "`autofit2'"!="" {
                display as error /// 
          	     	"When using autofit with survey data, you must use the gsvy: prefix."
                display as error "See the help for gologit2."
                exit 198
         }
         else if "`svy'" !="" {
         	display as error "The svy option is no longer supported."
         	display as error "Use svy: or gsvy: instead, or else use gologit29."
         	display as error "See the help for gologit2."
         	exit 198
         }
         else if ("`store'" != "" | "`gamma'" !="" | "`gamma2'" != "") & "`gsvy'" == "" {
         	display as error "The store and gamma options do not work correctly with the svy: prefix."
         	display as error "They can be specified as replay options, e.g."
         	display as error "gologit2, store(m1) gamma"
         	display as error "See the help for gologit2."
         	exit 198
         }
         
end
