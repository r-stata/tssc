program def metamiss2_corr_example

mat C=J(9,9,0.5)+0.5*I(9)
forvalues i=4/8{
mat C[`i',`=`i'+1']=0.2
mat C[`=`i'+1',`i']=0.2
}
mat li C

end
