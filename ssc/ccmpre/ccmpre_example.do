clear
input id Q1 Q2 Q3 Q4 Q5
1 1 1 1 1 2
2 3 1 1 1 1
3 1 3 3 1 1
4 1 1 1 1 3
end
cd "C:/Dropbox/cultcons/"
//
// Key and competence scores for this data were obtained from another 
// program, but are defined here in order to illustrate the program.
mat mykey = ///
(0.94299027, 0.01967328, 0.03733645) \ ///  
(0.9863283,  0.00790639, 0.0057653)  \ ///  
(0.9863283,  0.00790639, 0.0057653)  \ ///  
(0.97848712, 0.01075644, 0.01075644) \ ///  
(0.0786337,  0.46068315, 0.46068315)
//
mat compscore = 0.83530275 \ 0.48237045 \ 0.13254426 \ 0.83530275
mat list compscore
ccmpre Q*, key(mykey) comp(compscore) base(U)
mat list r(E1Item)
mat list r(E2Item)
ccmpre Q*, key(kp) comp(D) 





