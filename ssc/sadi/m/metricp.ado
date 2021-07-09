   // $Id: metricp.ado,v 1.6 2014/03/30 22:46:33 brendan Exp $
   // $Log: metricp.ado,v $
   // Revision 1.6  2014/03/30 22:46:33  brendan
   // Summary: Made even quieter
   //
   // * metricp.ado: Summary: Reduced and
   // improved output
   //
   // Revision 1.5  2014/03/30 21:44:54  brendan
   // Summary: Reduced and improved output
   //
   // Revision 1.4  2012/06/28 23:04:04  brendan
   // Put log and id in header
   //
   // Test the triangle inequality in a square symmetric matrix of pairwise distances

mata:

   function metricp (real matrix dist, real scalar limit, real scalar fast)
   { real scalar i,j,k,dim,tolerance;
      
      
      dim=rows(dist);

      tolerance = 0.000001
      
      matmet = 1;
      count = 0;
      for (i=1; i<=dim; i++) {
//         printf("Processing: dist[%5.0f, .. ]\n",i);
         for (j=i+1; j<=dim; j++) {
            if (fast) {
               if ( dist[i,j]> tolerance + min(dist[i,] :+ dist[j,]) ) {
                  matmet=0;
                  printf("Shorter route exists between seq %3.0f and seq %3.0f -- %5.3f > %5.3f\n",i,j, dist[i,j], min(dist[i,] :+ dist[j,]));
                  count++;
                  if (count>=limit) break;
                  }
               }
               else {
                  for (k=1; k<=dim; k++) {
                     if (k~=i && k~=j) {
                        if (dist[i,j] - (dist[i,k]+dist[j,k]) > 0.000001) {
                           matmet = 0;
                           count++;
                           printf("%3.0f %3.0f %3.0f: %6.3f > %6.3f = %6.3f + %6.3f\n",
                              i, j, k, dist[i,j], dist[i,k]+dist[j,k], dist[i,k], dist[j,k]);
                           if (count>=limit) break;
                           }
                        }
                     }
                  }
               if (count>=limit) break;
               }
             if (count>=limit) break;
            }
      if (dim == 0) {
         printf("Not a matrix");
         /* } else { */
         /* if (matmet == 1) { */
         /*    printf("Matrix is consistent with a metric space\n"); */
         /*    } else { */
         /*    printf("Matrix is NOT consistent with a metric space\n"); */
         /*    } */
         }
      return(matmet);
      }

end
   
   capture program drop metricp


   program define metricp, rclass
      syntax namelist(min=1 max=1) [, COUntlimit(int 10) DETailed]
      tempname retval
      
      if ("`detailed'"=="") {
         local fast 1
         }
      else {
         local fast 0
         }
      if (`countlimit'==0) local countlimit = _N*_N
      mata:  st_numscalar("`retval'",metricp(st_matrix("`namelist'"),`countlimit',`fast'))
      if (`retval'==1) {
        di "Matrix `namelist' is consistent with a metric space"
      }
      else {
        di "Matrix `namelist' is NOT consistent with a metric space"
      }
      return scalar ismetric = `retval'
   end
