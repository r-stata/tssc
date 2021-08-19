* Example file for inlist2 - version 1.1 10Mar2021  Matteo Pinna, matteo.pinna@gess.ethz.ch
sysuse auto, clear

* Want to summarize the price of the first 11 car models, sorted alphabetically. inlist() function only allows 10 strings.
inlist2 make, values(AMC Concord,AMC Pacer,AMC Spirit,Audi 5000,Audi Fox,BMW 320i,Buick Century,Buick Electra,Buick LeSabre,Buick Opel,Buick Regal)
sum price if inlist2==1

* The program overwrites the inlist2 variable every time it is executed, var can be saved with a specific name with the name() option
inlist2 make, values(AMC Concord,AMC Pacer,AMC Spirit,Audi 5000,Audi Fox,BMW 320i,Buick Century,Buick Electra,Buick LeSabre,Buick Opel,Buick Regal) name(first11)
sum price if first11==1

* Works similarly for reals
inlist2 rep78, values(3,2) name(repair_record23)
sum price if repair_record23==1
