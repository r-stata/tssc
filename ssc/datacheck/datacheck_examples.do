
/*Example 1*/
use drug, clear
datacheck drug=="aspirin" if arm==1, varshow(id drug arm) message(Wrong drug) 

/*Example 2*/
use visits, clear
datacheck date>date[_n-1] if _n>1, varshow(visit date) message(Dates do not follow) prev 

/*Example 3*/
use scores, clear
sort id time
datacheck time==0 if _n==1, by(id) varshow(id time) message(Patient's first record is not at time 0) 

