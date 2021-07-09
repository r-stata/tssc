******************************************************
******************************************************
********   Examples for richness.ado     *************
******************************************************
********  				 *************
********  Reference:
********  Peichl, Andreas; Schaefer, Thilo and Christoph Scheicher (2006): 
********  Measuring Richness and Poverty - A micro data application to 
********  Germany and the EU-15, CPE discussion papers No. 06-11, University of Cologne.
********  				 *************
******************************************************
********  				 *************
********  Authors:
********  
********     Andreas Peichl & Thilo Schaefer
********     Cologne Center for Public Economics
********     University of Cologne, Germany
********     a.peichl@uni-koeln.de, schaefer@fifo-koeln.de
********     www.cpe-cologne.de
********  				 *************
******************************************************
******************************************************


****** create data *********
cap drop a b c d
input a b c d
5 5 5 5
5 5 5 5
5 5 5 5
11 100 11 1000
11 100 9989 9000
end

***** example 1
richness a
richness b, rline(10)

***** example 2
richness c
richness d, rval(median) rnumber(200)


***** example 3
richness a b c d
richness a b c d, rval(mean)
richness a b c d, rval(mean) rlfix

exit

