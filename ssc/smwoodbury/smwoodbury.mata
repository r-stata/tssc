/* rank-k update of a matrix inverse using the
   sherman-morrison-woodbury formula */
/* sam schulhofer-wohl, federal reserve bank of minneapolis,
   sschulh1.work@gmail.com, 12/19/2011 */

/*
formula:
inv(A+U*C*V) = inv(A) - inv(A)*U*inv(inv(C)+V*inv(A)*U)*V*inv(A)

assumptions:
Ainv is NxN
U is NxK
C is KxK and full rank
V is KxN
*/

version 12.0
mata:

mata set matastrict on
mata set matafavor speed

/* general case using lusolve */
real matrix smwoodbury_lu(real matrix Ainv, real matrix U, real matrix Cinv, 
  real matrix V)
  {
  real matrix work
  work=V*Ainv
  return(Ainv-Ainv*U*lusolve(Cinv+work*U,work))
  }

real matrix smwoodbury_lu_solve(real matrix Ainv, real matrix U, real matrix Cinv, 
  real matrix V, real matrix AinvB)
  {
  real matrix work
  work=Ainv*U
  return(AinvB-work*lusolve(Cinv+V*work,V*AinvB))
  }

/* general case using qrsolve */
real matrix smwoodbury_qr(real matrix Ainv, real matrix U, real matrix Cinv, 
  real matrix V)
  {
  real matrix work
  work=V*Ainv
  return(Ainv-Ainv*U*qrsolve(Cinv+work*U,work))
  }

real matrix smwoodbury_qr_solve(real matrix Ainv, real matrix U, real matrix Cinv, 
  real matrix V, real matrix AinvB)
  {
  real matrix work
  work=Ainv*U
  return(AinvB-work*qrsolve(Cinv+V*work,V*AinvB))
  }

/* special case C=I(K), V=U', Ainv symmetric; using lusolve */
real matrix smwoodbury_sym1_lu(real matrix Ainv, real matrix U)
  {
  real matrix work
  work=Ainv*U
  return(Ainv-work*lusolve(I(cols(U))+U'*work,work'))
  }

real matrix smwoodbury_sym1_lu_solve(real matrix Ainv, real matrix U, real matrix AinvB)
  {
  real matrix work
  work=Ainv*U
  return(AinvB-work*lusolve(I(cols(U))+U'*work,U'*AinvB))
  }

/* special case C=I(K), V=U', Ainv symmetric; using qrsolve */
real matrix smwoodbury_sym1_qr(real matrix Ainv, real matrix U)
  {
  real matrix work
  work=Ainv*U
  return(Ainv-work*qrsolve(I(cols(U))+U'*work,work'))
  }

real matrix smwoodbury_sym1_qr_solve(real matrix Ainv, real matrix U, real matrix AinvB)
  {
  real matrix work
  work=Ainv*U
  return(AinvB-work*qrsolve(I(cols(U))+U'*work,U'*AinvB))
  }

/* special case C=I(K), V=U', Ainv symmetric and positive definite; using cholsolve */
real matrix smwoodbury_sym1_posdef(real matrix Ainv, real matrix U)
  {
  real matrix work
  work=Ainv*U
  return(Ainv-work*cholsolve(I(cols(U))+U'*work,work'))
  }

real matrix smwoodbury_sym1_posdef_solve(real matrix Ainv, real matrix U, real matrix AinvB)
  {
  real matrix work
  work=Ainv*U
  return(AinvB-work*cholsolve(I(cols(U))+U'*work,U'*AinvB))
  }

/* special case V=U', A=I(N)/s; using lusolve */
real matrix smwoodbury_sym2_lu(real scalar s, real matrix U, real matrix Cinv)
  {
  real matrix work
  work=s:*U
  return(s*I(rows(U))-work*lusolve(Cinv+U'*work,work'))
  }

real matrix smwoodbury_sym2_lu_solve(real scalar s, real matrix U, real matrix Cinv, real matrix sB)
  {
  real matrix work
  work=s:*U
  return(sB-work*lusolve(Cinv+U'*work,U'*sB))
  }

/* special case V=U', A=I(N)/s; using qrsolve */
real matrix smwoodbury_sym2_qr(real scalar s, real matrix U, real matrix Cinv)
  {
  real matrix work
  work=s:*U
  return(s*I(rows(U))-work*qrsolve(Cinv+U'*work,work'))
  }

real matrix smwoodbury_sym2_qr_solve(real scalar s, real matrix U, real matrix Cinv, real matrix sB)
  {
  real matrix work
  work=s:*U
  return(sB-work*qrsolve(Cinv+U'*work,U'*sB))
  }

/* special case C symmetric and positive definite, V=U', A=I(N)/s; using cholsolve */
real matrix smwoodbury_sym2_posdef(real scalar s, real matrix U, real matrix Cinv)
  {
  real matrix work
  work=s:*U
  return(s*I(rows(U))-work*cholsolve(Cinv+U'*work,work'))
  }

real matrix smwoodbury_sym2_posdef_solve(real scalar s, real matrix U, real matrix Cinv, real matrix sB)
  {
  real matrix work
  work=s:*U
  return(sB-work*cholsolve(Cinv+U'*work,U'*sB))
  }

mata mlib create lsmwoodbury, replace
mata mlib add lsmwoodbury smwoodbury_*()
mata mlib index

end
