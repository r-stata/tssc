program preliminary_changes
	version 12
	args year quarter
	qui {
	
	***************************
	* Poverty line definition *
	***************************
	
	g year_t1 =.
	replace year_t1=`year'+1
	g trim_t1 =.
	replace trim_t1=`quarter'
	
	g Lp=.
	replace Lp=57.4739 if year_t1==2007 & trim_t1==1
	replace Lp=57.5408 if year_t1==2007 & trim_t1==2
	replace Lp=58.0476 if year_t1==2007 & trim_t1==3
	replace Lp=58.8298 if year_t1==2007 & trim_t1==4
	replace Lp=60.4065 if year_t1==2008 & trim_t1==1
	replace Lp=62.8837 if year_t1==2008 & trim_t1==2
	replace Lp=63.8647 if year_t1==2008 & trim_t1==3
	replace Lp=64.2028 if year_t1==2008 & trim_t1==4
	replace Lp=65.1486 if year_t1==2009 & trim_t1==1
	replace Lp=66.2850 if year_t1==2009 & trim_t1==2
	replace Lp=65.9892 if year_t1==2009 & trim_t1==3
	replace Lp=66.7828 if year_t1==2009 & trim_t1==4
	replace Lp=67.9559 if year_t1==2010 & trim_t1==1
	replace Lp=68.4302 if year_t1==2010 & trim_t1==2
	replace Lp=68.5102 if year_t1==2010 & trim_t1==3
	replace Lp=69.0473 if year_t1==2010 & trim_t1==4
	replace Lp=70.2616 if year_t1==2011 & trim_t1==1
	replace Lp=71.3222 if year_t1==2011 & trim_t1==2
	replace Lp=71.8234 if year_t1==2011 & trim_t1==3
	replace Lp=72.8667 if year_t1==2011 & trim_t1==4
	replace Lp=74.1436 if year_t1==2012 & trim_t1==1
	replace Lp=74.7844 if year_t1==2012 & trim_t1==2
	replace Lp=75.3279 if year_t1==2012 & trim_t1==3
	replace Lp=76.3447 if year_t1==2012 & trim_t1==4
	replace Lp=76.7275 if year_t1==2013 & trim_t1==1
	replace Lp=77.0336 if year_t1==2013 & trim_t1==2
	replace Lp=77.0412 if year_t1==2013 & trim_t1==3
	replace Lp=78.1017 if year_t1==2013 & trim_t1==4
	replace Lp=78.9121 if year_t1==2014 & trim_t1==1
	replace Lp=79.6635 if year_t1==2014 & trim_t1==2
	replace Lp=80.2358 if year_t1==2014 & trim_t1==3
	replace Lp=81.0377 if year_t1==2014 & trim_t1==4
	replace Lp=82.1095 if year_t1==2015 & trim_t1==1
	replace Lp=83.2870 if year_t1==2015 & trim_t1==2
	replace Lp=83.5589 if year_t1==2015 & trim_t1==3
	replace Lp=83.7939 if year_t1==2015 & trim_t1==4
	replace Lp=84.2476 if year_t1==2016 & trim_t1==1
	replace Lp=84.6486 if year_t1==2016 & trim_t1==2
	replace Lp=84.7416 if year_t1==2016 & trim_t1==3
	replace Lp=84.8009 if year_t1==2016 & trim_t1==4
	replace Lp=85.05496 if year_t1==2017 & trim_t1==1
	replace Lp=85.58148 if year_t1==2017 & trim_t1==2
	replace Lp=84.97825 if year_t1==2017 & trim_t1==3
	replace Lp=84.49375 if year_t1==2017 & trim_t1==4
	replace Lp=84.93656 if year_t1==2018 & trim_t1==1
	replace Lp=85.69883335 if year_t1==2018 & trim_t1==2
	replace Lp=85.88480456 if year_t1==2018 & trim_t1==3
	replace Lp=86.42369828 if year_t1==2018 & trim_t1==4
	replace Lp=87.25565564 if year_t1==2019 & trim_t1==1
	replace Lp=88.28330497 if year_t1==2019 & trim_t1==2
	replace Lp=88.46927618 if year_t1==2019 & trim_t1==3
	replace Lp=89.00816989 if year_t1==2019 & trim_t1==4



	g Lpe=.
	replace Lpe=32.3900 if year_t1==2007 & trim_t1==1
	replace Lpe=32.4277 if year_t1==2007 & trim_t1==2
	replace Lpe=32.7133 if year_t1==2007 & trim_t1==3
	replace Lpe=33.1541 if year_t1==2007 & trim_t1==4
	replace Lpe=34.0426 if year_t1==2008 & trim_t1==1
	replace Lpe=35.4387 if year_t1==2008 & trim_t1==2
	replace Lpe=35.9916 if year_t1==2008 & trim_t1==3
	replace Lpe=36.1821 if year_t1==2008 & trim_t1==4
	replace Lpe=36.7151 if year_t1==2009 & trim_t1==1
	replace Lpe=37.3555 if year_t1==2009 & trim_t1==2
	replace Lpe=37.1888 if year_t1==2009 & trim_t1==3
	replace Lpe=37.6361 if year_t1==2009 & trim_t1==4
	replace Lpe=38.2972 if year_t1==2010 & trim_t1==1
	replace Lpe=38.5645 if year_t1==2010 & trim_t1==2
	replace Lpe=38.6095 if year_t1==2010 & trim_t1==3
	replace Lpe=38.9123 if year_t1==2010 & trim_t1==4
	replace Lpe=39.5966 if year_t1==2011 & trim_t1==1
	replace Lpe=40.1943 if year_t1==2011 & trim_t1==2
	replace Lpe=40.4767 if year_t1==2011 & trim_t1==3
	replace Lpe=41.0647 if year_t1==2011 & trim_t1==4
	replace Lpe=41.7843 if year_t1==2012 & trim_t1==1
	replace Lpe=42.1454 if year_t1==2012 & trim_t1==2
	replace Lpe=42.4517 if year_t1==2012 & trim_t1==3
	replace Lpe=43.0248 if year_t1==2012 & trim_t1==4
	replace Lpe=43.2405 if year_t1==2013 & trim_t1==1
	replace Lpe=43.4130 if year_t1==2013 & trim_t1==2
	replace Lpe=43.4173 if year_t1==2013 & trim_t1==3
	replace Lpe=44.0149 if year_t1==2013 & trim_t1==4
	replace Lpe=44.4716 if year_t1==2014 & trim_t1==1
	replace Lpe=44.8951 if year_t1==2014 & trim_t1==2
	replace Lpe=45.2176 if year_t1==2014 & trim_t1==3
	replace Lpe=45.6696 if year_t1==2014 & trim_t1==4
	replace Lpe=46.2736 if year_t1==2015 & trim_t1==1
	replace Lpe=46.9372 if year_t1==2015 & trim_t1==2
	replace Lpe=47.0904 if year_t1==2015 & trim_t1==3
	replace Lpe=47.2229 if year_t1==2015 & trim_t1==4
	replace Lpe=47.4786 if year_t1==2016 & trim_t1==1
	replace Lpe=47.7045 if year_t1==2016 & trim_t1==2
	replace Lpe=47.7569 if year_t1==2016 & trim_t1==3
	replace Lpe=47.72093501 if year_t1==2016 & trim_t1==4
	replace Lpe=47.93351302 if year_t1==2017 & trim_t1==1
	replace Lpe=48.23024122 if year_t1==2017 & trim_t1==2
	replace Lpe=47.89028494 if year_t1==2017 & trim_t1==3
	replace Lpe=47.61724179 if year_t1==2017 & trim_t1==4
	replace Lpe=47.86679207 if year_t1==2018 & trim_t1==1
	replace Lpe=48.29637642 if year_t1==2018 & trim_t1==2
	replace Lpe=48.40118223 if year_t1==2018 & trim_t1==3
	replace Lpe=48.70488081 if year_t1==2018 & trim_t1==4
	replace Lpe=49.17373813 if year_t1==2019 & trim_t1==1
	replace Lpe=49.7528795 if year_t1==2019 & trim_t1==2
	replace Lpe=49.85768531 if year_t1==2019 & trim_t1==3
	replace Lpe=50.16138388 if year_t1==2019 & trim_t1==4
	
	************************
	* Population estimates *
	************************
	* National estimation
	g pob_t=.
	replace pob_t = 13451227 if year_t1==2007
	replace pob_t = 13878704 if year_t1==2008
	replace pob_t = 14081060 if year_t1==2009
	replace pob_t = 15012228 if year_t1==2010
	replace pob_t = 15266431 if year_t1==2011
	replace pob_t = 15520973 if year_t1==2012
	replace pob_t = 15774749 if year_t1==2013
	replace pob_t = 15931516 if year_t1==2014
	replace pob_t = 16045290 if year_t1==2015 & trim_t1==1
	replace pob_t = 16045290 if year_t1==2015 & trim_t1==2
	replace pob_t = 16312205 if year_t1==2015 & trim_t1==3
	replace pob_t = 16404531 if year_t1==2015 & trim_t1==4
	replace pob_t = 16330166 if year_t1==2016
	replace pob_t = 16528730 if year_t1==2016 & trim_t1==4
	replace pob_t = 16776977 if year_t1==2017
	replace pob_t = 17023408 if year_t1==2018
	replace pob_t = 17267986 if year_t1==2019
	replace pob_t = 17510643 if year_t1==2020
	
	global poblacion_t1 =pob_t
	
	***************************
	* Estimating poverty in t *
	***************************

	cap ren fexp FEXP
	svyset sector [pweight=FEXP]
	sum pobreza [aweight=FEXP]
	global pobreza_t =round(`r(mean)'*100,.01)
	
	sum epobreza [aweight=FEXP]
	global extrema_t =round(`r(mean)'*100,.01)
		
	***********************
	* PRELIMINARY CHANGES *
	***********************
		
		cap ren PEIN pei
	* A partir del 2016 es necesario crear la variable inadecuado
		* Se constituye de subempleo, otro inadecuado y no remunerado
		cap gen inadec=.
		cap replace inadec=1 if sub==1
		cap replace inadec=1 if oinad==1
		cap replace inadec=1 if nr==1

	* Generar la variable de identificación de otro tipo de empleo *
		cap gen otros=0
		replace otros=1 if nc==1
		replace otros=1 if pei==1
		replace petn=0 if petn==.
		replace otros=1 if petn==0
		replace otros=. if otros==0
	
	* Número de personas en cada hogar
		sort ciudad zona sector panelm vivienda hogar p01
		cap egen idhogar=group(ciudad zona sector panelm vivienda hogar)

		cap clonevar sexo=p02
		cap egen npersona=count(sexo), by(idhogar)
		drop sexo

	* Identificador de persona *
		cap gen id=(_n)
		sum id
		scalar define total=`r(max)'
		global N_total =total
	
	* NÃºmero de familias *
		sum idhogar
		scalar define familias =`r(max)'
		global familia =familias
	
	*****************************
	* Generar datos de ingresos *
	*****************************

	* Ingresos no laborales *
		gen ingrnl=0
		replace ingrnl=ingrnl+p71b if (p71a==1 & p71b<999999)
		replace ingrnl=ingrnl+p72b if (p72a==1 & p72b<999999)
		replace ingrnl=ingrnl+p73b if (p73a==1 & p73b<999999)
		replace ingrnl=ingrnl+p74b if (p74a==1 & p74b<999999)
		replace ingrnl=ingrnl+p76 if  (p75==1 & p76<999999)
		replace ingrnl=-1 if ingrnl<0
		replace ingrnl=. if (p71b==. & p72b==. & p73b==. & p74b==. & p76==.)

	* Ingresos totales (por construcción) *
		replace ingrl=. if ingrl>=999999
		gen ingrtl=ingrnl+ingrl
		replace ingrtl=ingrl if ingrnl==. & ingrl>=0
		replace ingrtl=ingrnl if ingrl==. & ingrnl>=0
		replace ingrtl=-1 if ingrl==-1
		replace ingrnl=-1 if ingrtl==-1
		sort id
		}
end
