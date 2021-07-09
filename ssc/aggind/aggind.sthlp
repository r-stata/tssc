{smcl}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col : aggind {hline 2}}aggregate indicators among units within a specified radius {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:aggind} id_unit {varlist} {cmd:using} {it:{help filename}}, metr() rad() [sum crcl] 


{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:required options}
{synopt : {cmdab:metr()}} metric of proximity {p_end}
{synopt : {cmdab:rad()}} radius of aggregation {p_end}

{syntab: additional options}
{synopt : {cmdab:sum}} aggregate indicators as sum (default: average) {p_end}
{synopt : {cmdab:crcl}} exclude the origin from the aggregation {p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}


{title:Description}

{pstd}
For every regional unit in the data {cmd:aggind} aggregates metric indicators among neighbouring regional units that are located within a specified radius. 
The operation requires a distance matrix, addressed with {it:{help filename}}. Distance matrix has to be in .dta format. 

{pstd}	
Distance matrix contains the information about the proximity of the regional units to each other. The three columns of the distance matrix contain the id of the origin unit, 
the id of the target unit, and the distance between the two units. To obtain meaningful results it is important that the distance matrix is {break}
a) complete, meaning that it contains all pairs of regional units, {break}
b) the distance between one unit and itself is specified as zero, {break}
c) variables are in the following order: id of the origin unit, id of the target unit, distance. {break}
The distance can be physical distance, travelling time etc. Non-spatial proximity definitions can also be used.

{pstd}
IDs in the master dataset (id_unit) and id_origin as well as id_target in the distance matrix dataset have to follow the same classification system 
though identical naming is not required. {break} 
Id_unit is allowed to repeat in the master data, for example if individual-level data is used where cases are clustered within regional units.

{pstd}	
To run the command the options {cmdab:metr()} and {cmdab:rad()} have to be specified;

{pstd}	
metr() specifies the mode of how the proximity between the units is measured. There is a selection between metr(dist) and metr(kn): {break}
metr(dist) uses continuous distances to aggregate indicators within a distance radius, {break}
metr(kn) identifies the k-nearest neighbours and aggregates the indicators among specified k-nearest units. 

{pstd}	
rad() specifies the radius within which indicators are aggregated: {break}
If metr(dist) is used the radius has to be specified in the metric of the distance variable in the distance matrix, {break}
If metr(kn) is used rad() has to contain the number of the k-nearest units of interest.{break}

{pstd}
The command aggregates indicators as average among neighbouring units. Option {cmdab:sum} will additionally add aggregated 
sums of the indicators among neighbouring units.

{pstd}
Option {cmdab:crcl} will additionally add indicators aggregated as average among neigbouring units with the deduction of the starting unit.

{pstd}
After the run the data will be sorted by id_unit. 


{title:Example}

{input: aggind id_unit VAR1 using matrix.dta, metr(dist) rad(6500)}

         
         {cmd:master data}          {cmd:+}           {cmd:distance matrix}          {cmd:-->}             {cmd:output data}


       id_unit  VAR1   VAR2        id_origin  id_target distance        id_unit  VAR1 VAR2 VAR1_6500_mean

{tab} 1{tab} 3{tab}4{tab}{tab}1{tab} 1{tab}   0 {tab}{tab}   1{tab}  3{tab}4{tab}4.67     
{tab} 2{tab} 4{tab}2{tab}{tab}1{tab} 2{tab}   5000 {tab}   2{tab}  4{tab}2{tab}3.5
{tab} 3{tab} 7{tab}1{tab}{tab}1{tab} 3{tab}   6500 {tab}   3{tab}  7{tab}1{tab}3.33
		                            
{tab}{tab}{tab}{tab}{tab}2{tab} 1{tab}   5000    
{tab}{tab}{tab}{tab}{tab}2{tab} 2{tab}   0       
{tab}{tab}{tab}{tab}{tab}2{tab} 3{tab}   7500    
                                      
{tab}{tab}{tab}{tab}{tab}3{tab} 1{tab}   6500    
{tab}{tab}{tab}{tab}{tab}3{tab} 2{tab}   7500    
{tab}{tab}{tab}{tab}{tab}3{tab} 3{tab}   0   
   
   
{title:Note}

{pstd}
The simple aggregating average proportions neglects different sizes or weights of the units. For this reason work with absolute numbers or use weighted values.

 
{title:Author}

{pstd}
Andreas Hartung 2017, Department of Sociology, University of Tuebingen
	
