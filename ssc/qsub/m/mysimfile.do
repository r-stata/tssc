postfile results sim cons cons_se x x_se using _output/results`1'.dta, replace

    use _data/design.dta , replace
    set rngstream `1'
    set seed 1
    gen e =15*invnorm(uniform())
    gen yobs = y + e

	reg yobs x 
	
post results (`1') (_b[_cons]) (_se[_cons]) (_b[x]) (_se[x])
postclose results




