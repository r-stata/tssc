// Apr  2 2012 14:03:51
// Calculate the correlation between two distance matrices
// Correlation is between the lower half (including diagonal) values

mata:
   real vector rankorder(real vector dv) {
      real vector l1, l2
      real matrix workspace
      l1 = (1::rows(dv))
      workspace = (dv, l1)
      l2 = workspace[order(workspace,(1,2)),(2,1)]
      return(l1[order(l2,1),])
      }

// invorder(order(x,1)) == rankorder(x)

   real corrsqm(string v1, string v2, scalar sp) {
      real matrix m1, m2, cpair
      m1 = st_matrix(v1)
      m2 = st_matrix(v2)
      if (!issymmetric(m1) | !issymmetric(m2)) {
         return(-1)
         } else {
         m1 = vech(m1)
         m2 = vech(m2)
         if (sp) {
            m1 = rankorder(m1)
            m2 = rankorder(m2)
            m1 == m2
            }
         cpair = correlation((m1, m2), 1)
         return(cpair[1,2])
         }
    }

   real corrsqmnodiag(string v1, string v2, scalar sp) {
      real matrix m1, m2, cpair
      m1 = st_matrix(v1)
      m2 = st_matrix(v2)
      if (!issymmetric(m1) | !issymmetric(m2)) {
         return(-1)
         } else {
         nr = rows(m1)
         m1 = m1[2..nr,1..(nr-1)]
         m2 = m2[2..nr,1..(nr-1)]
         m1 = vech(m1)
         m2 = vech(m2)
        // m1
        // m2

         if (sp) {
            m1 = rankorder(m1)
            m2 = rankorder(m2)
            m1 == m2
            }
         cpair = correlation((m1, m2), 1)
         return(cpair[1,2])
         }
      }
end

capture program drop corrsqm
program define corrsqm, rclass
   syntax namelist, [SPEarman NODiag]
   local mat1 : word 1 of `namelist'
   local mat2 : word 2 of `namelist'
   local sp 0
   if ("`spearman'" != "") local sp 1
   if (rowsof(`mat1') != rowsof(`mat2')) {
      di in red "Matrices are not the same size"
      exit
      }
   else {
     tempname retval
     if ("`nodiag'" == "") {
       mata: st_numscalar("`retval'",corrsqm("`mat1'", "`mat2'",`sp'))
     }
     else {
       mata: st_numscalar("`retval'",corrsqmnodiag("`mat1'", "`mat2'",`sp'))
     }
     
     if (`retval' == -1) {
       di in red "At least one matrix not symmetric"
     }
     else {
       di "VECH correlation between `mat1' and `mat2': " %6.4f `retval'
     }
     if ("`nodiag'" != "") {
       di "Diagonal suppressed"
     }
     return scalar rho = `retval'
   }
end
