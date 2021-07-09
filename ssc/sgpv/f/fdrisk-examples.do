*!fdrisk-examples
*Allow easier execution of the examples for fdrisk
version 12.0
args argument
*False discovery risk with 95% confidence level:
if "`argument'"=="example1"{
	fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)  nullweights("Uniform")  nullspace(log(1/1.1) log(1.1)) /// 
		altweights("Uniform") altspace("2-1*invnorm(1-0.05/2)*0.8" "2+1*invnorm(1-0.05/2)*0.8") inttype("confidence")  intlevel(0.05) 
	}
	
	*False discovery risk with 1/8 likelihood support level:
if "`argument'"=="example2a"{	
	fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)   nullweights("Point")  nullspace(0) /// 
		altweights("Uniform") altspace("2-1*invnorm(1-0.041/2)*0.8" "2+1*invnorm(1-0.041/2)*0.8")  inttype("likelihood")  intlevel(1/8) 
	}
	
	*with truncated normal weighting distribution:
if "`argument'"=="example2b"{
	fdrisk, sgpval(0)  nulllo(log(1/1.1)) nullhi(log(1.1))  stderr(0.8)   nullweights("Point")  nullspace(0)  altweights("TruncNormal") ///
		altspace("2-1*invnorm(1-0.041/2)*0.8" "2+1*invnorm(1-0.041/2)*0.8")  inttype("likelihood")  intlevel(1/8)
}

*False discovery risk with LSI and wider null hypothesis:
if "`argument'"=="example3"{
	fdrisk, sgpval(0)  nulllo(log(1/1.5)) nullhi(log(1.5))  stderr(0.8)   nullweights("Point")  nullspace(0)  altweights("Uniform") ///
		altspace("2.5-1*invnorm(1-0.041/2)*0.8" "2.5+1*invnorm(1-0.041/2)*0.8")  inttype("likelihood")  intlevel(1/8)
}
*False confirmation risk example:
if "`argument'"=="example4"{
	fdrisk, sgpval(1)  nulllo(log(1/1.5)) nullhi(log(1.5))  stderr(0.15)   nullweights("Uniform") nullspace("0.01 - 1*invnorm(1-0.041/2)*0.15" "0.01 + 1*invnorm(1-0.041/2)*0.15") ///
		altweights("Uniform")  altspace(log(1.5) 1.25*log(1.5))  inttype("likelihood")  intlevel(1/8) 
	}
		