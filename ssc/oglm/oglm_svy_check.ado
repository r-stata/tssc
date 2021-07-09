*! version 2.3.0 30aug2016  Richard Williams, rwilliam@nd.edu

program oglm_svy_check
         version 11.2
         syntax [, STOre(name) *]
         if "`store'" != ""  {
         	display as error "The store option does not work correctly with the svy: prefix."
         	display as error "store can be specified as a replay option, e.g."
         	display as error "oglm, store(m1)"
         	exit 198
         }
         
end
