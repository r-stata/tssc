/* 
Copyright 2007-2012 Brendan Halpin brendan.halpin@ul.ie
Distribution is permitted under the terms of the GNU General Public Licence

$Id: omamatv3.c,v 1.19 2014/04/08 23:40:52 brendan Exp $
$Log: omamatv3.c,v $
Revision 1.19  2014/04/08 23:40:52  brendan
Summary: Made a number of changes to avoid warnings, seem to make no
other difference

Revision 1.18  2012/07/06 09:40:58  brendan
Replaced assertions with better error-trapping, concerning sequences
with states out of range, and over-long sequences

Revision 1.17  2012/07/06 09:17:03  brendan
Suppressed nrefs message if nrefs==0

Revision 1.16  2012/06/28 23:08:13  brendan
Improved workspace output formatting, log and id in header

*/

#include "stplugin.h"
#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define MAXLENGTH 1024

/* syntactic sugar: define a pseudo-function to return substitutioncost instead of subscripting subsmat */
#define SUBSCOST(a,b) (subsmat[(a)-1][(b)-1])

int adj_rep(int *seq, int *rseq, int length);

int nstates;
double indelcost;
int adjdur;
int show_workspace;
double exponent;
double twedlambda;
double twednu;
double hol_x;
double hol_y;
int norm;
double wmax;

/* Extension of oma to treat indels (as deletions) and
   substitutions differently where the action constitutes a
   deletion of one of a sequence of observations in the same state.

   An indel can be viewed as an insertion in one sequence or a
   deletion in the other. Here we treat it as a deletion and look
   at the relevant sequence for repeated observations.

   A substitution is equivalently 
    (i) a deletion of s1[i] in s1 plus an insertion of s2[j] in s1, 
    (ii) a deletion of s2[j] in s2 with an insertion of s1[i]
    (iii) a deletion in both s1 and s2 and 
    (iv) an insertion in both s1 and s2.

  We can therefore think of substitutions as simultaneous
  deletions, with a lower cost because of their simultaneity.

  If there are no contiguous runs, then the total cost is
  subs[s1[i],s2[j]], the conventional pair-specific substitution
  cost, with a ceiling of 2*indelcost (i.e. if the substution cost
  is high it will be cheaper to do a conventional double indel).
  Where either s1[i] or s2[j] is part of a contiguous run, we can
  reduce the substitution cost accordingly.

  In this implementation the substitution cost is reduced by the
  geometric mean of the reduction factor for s1[i] and s2[j]. That
  is, if s1[i] is unique, and s2[j] is part of a run of two, the
  divisor is sqrt(1*sqrt(2)); if s1[i] is one of three and s2[j] one
  of two, it is sqrt(sqrt(3)*sqrt(2)).

*/



/* The general OMAV distance */
double omav2(int *s1, int *s2, int length1, int length2, int adjdur, double **subsmat, int show_workspace, int norm) {
  int i, j;
  int rs1[length1];
  int rs2[length2];
  double A[length1+1];
  double B[length2+1];
  double C[length1+1][length2+1];
  double D[length1+1][length2+1];
  double denom;
  char buf[80];
  
  adj_rep(s1,rs1,length1);
  adj_rep(s2,rs2,length2);
    
  A[0]=0;
  B[0]=0;
  for (i=1;i<=length1;i++){ 
    if (adjdur) {
      denom = (float)rs1[i-1];
      A[i]=indelcost/pow(denom,exponent);
    } else {
      A[i]=indelcost;
    }
  }


  for (i=1;i<=length2;i++){ 
    if (adjdur) {
      denom = (float)rs2[i-1];
      B[i]=indelcost/pow(denom,exponent); 
    } else {
      B[i]=indelcost;
    }
  }

  C[0][0]=0.0;
  D[0][0]=0.0;
  for (i = 1; i<= length1; i++ ) {
    C[i][0]=0.0;
    for (j = 1; j<= length2; j++ ) {
      denom = (float)A[i];
      /* Substitution cost is scaled according to the longer of the two runs Apr 21 2007 17:45:13 */
      if (A[i]>B[j]) {
        denom = (float)B[j];
      }
      C[i][j]  =  SUBSCOST(s1[i-1], s2[j-1])*denom/indelcost; /* indelcost comes in because it is already in definition of A and B */
    }
  }
  for (j = 1; j<= length2; j++ ) {
    C[0][j]=0.0;
  }

  for (i = 1; i<= length1; i++ ) {
    D[i][0]  =  D[i - 1][0]  +  A[i];
  }

  for (j = 1; j<= length2; j++ ) {
    D[0][j]  =  D[0][j - 1]  +  B[j];
  }

  for (i = 1; i<= length1; i++ ) {
    for (j = 1; j<= length2; j++ ) {
      D[i][j]  =  D[i-1][j  ]  +  A[i];

      if (D[i][j]>D[i  ][j-1]  +  B[j]) {
        D[i][j] = D[i  ][j-1]  +  B[j];
      }
      if (D[i][j]>D[i-1][j-1]  +  C[i][j]) {
        D[i][j] = D[i-1][j-1]  +  C[i][j];
      }
    }
  }


  if (show_workspace==1) {
    snprintf(buf, 80, "Seq 1: ");
    SF_display(buf);
    for (i=0;i<length1;i++) {
      snprintf(buf, 80, " %3d", s1[i]);
      SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
    snprintf(buf, 80, "Seq 2: ");
    SF_display(buf);
    for (i=0;i<length2;i++) {
      snprintf(buf, 80, " %3d", s2[i]);
      SF_display(buf);
    }
    snprintf(buf, 80, "\n\n");
    SF_display(buf);
    snprintf(buf, 80, "Substitution costs:\n     ");
    SF_display(buf);

    for (i=0;i<=length1;i++) {
      if (i==0) {
        for (j=0;j<=length2;j++) {
          snprintf(buf, 80, " %5.0d", s2[j]);
          SF_display(buf);
        }
      } else {
        for (j=0;j<=length2;j++) {
          if (j==0) {
            snprintf(buf, 80, " %5.0d", s1[i-1]);
          } else {
            snprintf(buf, 80, " %5.2f", C[i][j]);
          }
          SF_display(buf);
        }
      }
      snprintf(buf, 80, "\n");
      SF_display(buf);
    }
    snprintf(buf, 80, "\nWorking space:\n");
    SF_display(buf);
    for (i=0;i<=length1;i++) {
      if (i==1) {
          snprintf(buf, 80, "  -----+");
          SF_display(buf);
          for (j=1;j<=length2;j++) {
            snprintf(buf, 80, "------");
            SF_display(buf);
          }
          snprintf(buf, 80, "\n");
          SF_display(buf);
      }
      for (j=0;j<=length2;j++) {
        snprintf(buf, 80, " %5.2f", D[i][j]);
        SF_display(buf);
        if (j==0) {
          snprintf(buf, 80, " |");
          SF_display(buf);
        }
      }
      snprintf(buf, 80, "\n");
      SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
  }

  if (norm == 1) {
    return(D[length1][length2] / (length1>length2 ? length1 : length2));
  } else {
    return(D[length1][length2]);
  }
}


/* Helper function to identify spells within sequences for omav() */
int adj_rep(int *seq, int *rseq, int length) {
  int start, count, i,j;
  
  i = 0;
  while (i<length) {
    start  =  i;
    count  =  1;
    if (i<length) {
      while (seq[i] == seq[i + 1]) {
        count++ ;
        i++ ;
        if (i>= length) break;
      }
    for (j = start; j<start + count; j++ ) {
      rseq[j] = count;
    }
    }
    i++ ;
  }
  if (i == length) rseq[i] = 1;
  return(0);

}

/* May 23 2010
Working version of Matissa Hollister's "localized" OM. Is non-metric
*/
double oma_hollister(int *s1, int *s2, int length1, int length2, double x, double y, double w, double **subsmat, int show_workspace, int norm) {
  // x by subs_max + y by mean of subs[i,z] and subs[j,z]
  int i, j;
  double A[length1+1][length2+1]; // insert S2z between S1i and S1j
  double B[length1+1][length2+1]; // insert S1z between S2i and S2j
  double C[length1+1][length2+1]; // substitution cost
  double D[length1+1][length2+1]; // final distance
  double xwmax;
  char buf[80];
  
  xwmax = x * w;

  A[0][0]=0;
  B[0][0]=0;

  // Set left col of A to high number
  for (i=1;i<=length1;i++){ 
    A[i][0]= 999;
  }
  // Set top row of A to xmax + subs(S1_1,S2_j)
  for (j=1;j<=length2;j++){ 
    A[0][j]= xwmax + y*SUBSCOST(s1[0],s2[j-1]);
  }

  // Set left col of B to  xmax + subs(S1_i,S2_1)
  for (i=1;i<=length1;i++){ 
    B[i][0]= xwmax + y*SUBSCOST(s1[i-1],s2[0]);
  }
  // Set top row of B to high number
  for (j=1;j<=length2;j++){ 
    B[0][j]= 999;
  }

  // Fill body of A
  for (i=1;i< length1;i++){ 
    for (j=1;j<=length2;j++){ 
      A[i][j] = xwmax + y*0.5*(SUBSCOST(s1[i-1],s2[j-1]) + 
                               SUBSCOST(s1[i  ],s2[j-1])); 
    }
  }
  // treating the last row differently
  for (j=1;j<=length2;j++){ 
    A[length1][j] = xwmax + y*(SUBSCOST(s1[length1-1],s2[j-1]));
  }



  // Fill body of B
  for (i=1;i<=length1;i++){ 
    for (j=1;j<length2;j++){ 
      B[i][j] = xwmax + y*0.5*(SUBSCOST(s1[i-1],s2[j-1]) + 
                               SUBSCOST(s1[i-1],s2[j  ])); 
    }
    B[i][length2] = xwmax + y*(SUBSCOST(s1[i-1],s2[length2-1]));
  }

  C[0][0]=0.0;
  D[0][0]=0.0;
  for (i = 1; i<= length1; i++ ) {
    C[i][0]=0.0;
    for (j = 1; j<= length2; j++ ) {
      C[i][j]  =  SUBSCOST(s1[i-1],s2[j-1]);
    }
  }
  for (j = 1; j<= length2; j++ ) {
    C[0][j]=0.0;
  }

  for (i = 1; i<= length1; i++ ) {
    D[i][0]  =  D[i - 1][0]  +  B[i][0];
  }

  for (j = 1; j<= length2; j++ ) {
    D[0][j]  =  D[0][j - 1]  +  A[0][j];
  }

  for (i = 1; i<= length1; i++ ) {
    for (j = 1; j<= length2; j++ ) {
      D[i][j]  =  D[i-1][j  ] + B[i][j];
      if (D[i][j] > D[i  ][j-1] + A[i][j]) {
        D[i][j] = D[i  ][j-1] + A[i][j];
        // Oct 20 2011 12:46:34
        // Switched A and B above, while experimenting with Hollister's own code.
        // Seems to make my workspace agree with hers, but is still non-metric 
        // with larger tests.
      }
      if (D[i][j] > D[i-1][j-1] + C[i][j]) {
        D[i][j] = D[i-1][j-1] + C[i][j];
      }
    }
  }
  

  if (show_workspace==1) {
    snprintf(buf, 80, "Seq 1: ");
    SF_display(buf);
    for (i=0;i<length1;i++) {
      snprintf(buf, 80, " %3d", s1[i]);
      SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
    snprintf(buf, 80, "Seq 2: ");
    SF_display(buf);
    for (i=0;i<length2;i++) {
      snprintf(buf, 80, " %3d", s2[i]);
      SF_display(buf);
    }
    snprintf(buf, 80, "\n\n");
    SF_display(buf);
    snprintf(buf, 80, "Substitution costs:\n");
    SF_display(buf);

    for (i=0;i<=length1;i++) {
      for (j=0;j<=length2;j++) {
        snprintf(buf, 80, " %6.2f", C[i][j]);
        SF_display(buf);
      }
      snprintf(buf, 80, "\n");
      SF_display(buf);
    }

    snprintf(buf, 80, "\n\n");
    SF_display(buf);
    snprintf(buf, 80, "A insertion costs:\n");
    SF_display(buf);

    for (i=0;i<=length1;i++) {
      for (j=0;j<=length2;j++) {
        snprintf(buf, 80, " %6.2f", A[i][j]);
        SF_display(buf);
      }
      snprintf(buf, 80, "\n");
      SF_display(buf);
    }

    snprintf(buf, 80, "\n\n");
    SF_display(buf);
    snprintf(buf, 80, "B insertion costs:\n");
    SF_display(buf);

    for (i=0;i<=length1;i++) {
      for (j=0;j<=length2;j++) {
        snprintf(buf, 80, " %6.2f", B[i][j]);
        SF_display(buf);
      }
      snprintf(buf, 80, "\n");
      SF_display(buf);
    }

    snprintf(buf, 80, "\nWorking space:\n");
    SF_display(buf);
    for (i=0;i<=length1;i++) {
      for (j=0;j<=length2;j++) {
        snprintf(buf, 80, " %6.2f", D[i][j]);
        SF_display(buf);
      }
      snprintf(buf, 80, "\n");
      SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
  }

  if (norm == 1) {
    return(D[length1][length2] / (length1>length2 ? length1 : length2));
  } else {
    return(D[length1][length2]);
  }
}

/* One of the timewarp set */
double timewarp(int *s1, int *s2, 
                int length1, 
                int length2, 
                double **subsmat, 
                double warp_penalty, 
                int show_workspace, int norm) {
  int i, j;
  double A[length1+1];
  double B[length2+1];
  double C[length1+1][length2+1];
  double D[length1+1][length2+1];
  char buf[80];
  
    
  A[0]=0;
  B[0]=0;
  for (i=1;i<=length1;i++){ 
    A[i]=warp_penalty;
  }
  
  
  for (i=1;i<=length2;i++){ 
    B[i]=warp_penalty;
  }

  C[0][0]=0.0;
  D[0][0]=0.0;
  for (i = 1; i<= length1; i++ ) {
    C[i][0]=0.0;
    for (j = 1; j<= length2; j++ ) {
      C[i][j]  =  SUBSCOST(s1[i-1],s2[j-1]);
    }
  }
  for (j = 1; j<= length2; j++ ) {
    C[0][j]=0.0;
  }

  for (i = 1; i<= length1; i++ ) {
    D[i][0]  =  D[i - 1][0]  +  A[i];
  }

  for (j = 1; j<= length2; j++ ) {
    D[0][j]  =  D[0][j - 1]  +  B[j];
  }

  for (i = 1; i<= length1; i++ ) {
    for (j = 1; j<= length2; j++ ) {
      D[i][j]  =  D[i-1][j  ]  +  0.5*C[i][j];

      if (D[i][j]>D[i  ][j-1]  +  0.5*C[i][j]) {
        D[i][j] = D[i  ][j-1]  +  0.5*C[i][j];
      }
      if (D[i][j]>D[i-1][j-1]  +  C[i][j]) {
        D[i][j] = D[i-1][j-1]  +  C[i][j];
      }
    }
  }

  if (show_workspace==1) {
    for (i=0;i<=length1;i++) {
      for (j=0;j<=length2;j++) {
        snprintf(buf, 80, " %4.1f", C[i][j]);
        SF_display(buf);
      }
      snprintf(buf, 80, "\n");
      SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
    for (i=0;i<=length1;i++) {
      for (j=0;j<=length2;j++) {
        snprintf(buf, 80, " %4.1f", D[i][j]);
        SF_display(buf);
      }
      snprintf(buf, 80, "\n");
      SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
  }

  if (norm == 1) {
    return(D[length1][length2] / (length1>length2 ? length1 : length2));
  } else {
    return(D[length1][length2]);
  }
}

double twed(int *s1, int *s2, 
            int length1, 
            int length2, 
            double **subsmat, 
            double lambda,
            double nu,
            int show_workspace, int norm) {
  int i, j;
  int A[length1+1];
  int B[length2+1];
  double TWED[length1+1][length2+1];
  double ins, del, mat;
  char buf[80];

  float infinish = 99999.0;
  
  A[0] = 1; /* Putting 0 here makes it attempt to look at subsmat[i,-1] */
  B[0] = 1;

  for (i=1; i<=length1; i++) {
    A[i]=s1[i-1];
  }
  for (i=1; i<=length2; i++) {
    B[i]=s2[i-1];
  }

  /* for (i=1;i<=length1;i++){  */
  /*   A[i]=warp_penalty; */
  /* } */
  
  /* for (i=1;i<=length2;i++){  */
  /*   B[i]=warp_penalty; */
  /* } */

  TWED[0][0]=0.0;


  /* Margins: \sum d(a'_k,a'_{k-1}) 
     Let =0 for i==1, else lag + d(a'_k,a'_{k-1})
*/
  for (i=1;i<=length2;i++){ 
    TWED[0][i] = infinish;
  }
  
  for (i=1;i<=length1;i++){ 
    TWED[i][0] = infinish;
  }
  
  for (i = 1; i<= length1; i++ ) {
    for (j = 1; j<= length2; j++ ) {
      // insertion (delete from sequence A)
      ins = TWED[i-1][j] + SUBSCOST(A[i-1],A[i]) + nu + lambda;
      
      // deletion (delete from sequence B)
      del = TWED[i][j-1] + SUBSCOST(B[j-1],B[j]) + nu + lambda;
      
      // match or substitution
      mat = TWED[i-1][j-1] + 
        SUBSCOST(A[i],   B[j]  ) + 
        SUBSCOST(A[i-1], B[j-1]) + 2*nu*abs(i-j);
      /* as per TWED2 */
      
      if (show_workspace==1) {
        snprintf(buf, 80, "%3d %3d %5.2f %5.2f %5.2f %5.2f %5.2f\n", i,j, ins, del, mat, nu, lambda);
        SF_display(buf);
      }
      
      TWED[i][j] = ins;
      if (del < TWED[i][j]) {
        TWED[i][j] = del;
      }
      if (mat < TWED[i][j]) {
        TWED[i][j] = mat;
      }
    }
  }

  if (show_workspace==1) {
    for (i=0;i<length1;i++) {
        snprintf(buf, 80, " %3.d", s1[i]);
        SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
    for (i=0;i<length2;i++) {
        snprintf(buf, 80, " %3.d", s2[i]);
        SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
    for (i=0;i<=length1;i++) {
      for (j=0;j<=length2;j++) {
        snprintf(buf, 80, " %7.3f", TWED[i][j]);
        SF_display(buf);
      }
      snprintf(buf, 80, "\n");
      SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
  }

  if (norm == 1) {
    return(TWED[length1][length2] / (length1>length2 ? length1 : length2));
  } else {
    return(TWED[length1][length2]);
  }
}

double twed_original(int *s1, int *s2, 
            int length1, 
            int length2, 
            double **subsmat, 
            double lambda,
            double nu,
            int show_workspace) {
  int i, j;
  double tsA[length1+1];
  double tsB[length2+1];
  double TWED[length1+1][length2+1];
  double ins, del, mat;
  char buf[80];

  float infinish = 99999.0;
  
  tsA[0] = 0;
  tsB[0] = 0;


  /* for (i=1;i<=length1;i++){  */
  /*   A[i]=warp_penalty; */
  /* } */
  
  /* for (i=1;i<=length2;i++){  */
  /*   B[i]=warp_penalty; */
  /* } */

  TWED[0][0]=0.0;

  for (i=1;i<=length2;i++){ 
             TWED[0][i] = infinish;
             tsB[i]=i;
  }

  for (i=1;i<=length1;i++){ 
             TWED[i][0] = infinish;
             tsA[i]=i;
  }

  for (i = 1; i<= length1; i++ ) {
    for (j = 1; j<= length2; j++ ) {
      // insertion
      if (i>1) { 
        ins = TWED[i-1][j] + 
          /* C[i-1][i] */ SUBSCOST(s1[i-2], s1[i-1])     /* C[A[i-1], A[i]]  */
          + nu*(tsA[i] - tsA[i-1]) + lambda;
      }
      else {
        ins = TWED[i-1][j] + 0
          + nu*(tsA[i] - tsA[i-1]) + lambda;
      };

      if (j>1) { 
        del = TWED[i][j-1] + 
          /* C[j-1][j] */ SUBSCOST(s2[j-2],s2[j-1])         /* C[B[j-1], B[j]] */ 
          + nu*(tsB[j] - tsB[j-1]) + lambda;
      } else { 
        del = TWED[i][j-1] + 0 
          + nu*(tsB[j] - tsB[j-1]) + lambda;
      };

      mat = TWED[i-1][j-1] + 
        /* C[i][j] */ subsmat [ s1[i-1]-1 ][ s2[j-1]-1 ]    /* C[A[i],B[j]] */
        + nu*abs(tsA[i] - tsB[j]);

      TWED[i][j] = ins;
      if (del < TWED[i][j]) {
        TWED[i][j] = del;
      }
      if (mat < TWED[i][j]) {
        TWED[i][j] = mat;
      }
    }
  }

  if (show_workspace==1) {
    for (i=0;i<length1;i++) {
        snprintf(buf, 80, " %3.d", s1[i]);
        SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
    for (i=0;i<length2;i++) {
        snprintf(buf, 80, " %3.d", s2[i]);
        SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
    for (i=0;i<=length1;i++) {
      for (j=0;j<=length2;j++) {
        snprintf(buf, 80, " %7.1f", TWED[i][j]);
        SF_display(buf);
      }
      snprintf(buf, 80, "\n");
      SF_display(buf);
    }
    snprintf(buf, 80, "\n");
    SF_display(buf);
  }

  return(TWED[length1][length2] / (length1>length2 ? length1 : length2)); /* Standardise on length */

}


/* Core procedure to calculate the appropriate pairwise distances for
   the n(n-1)/2 pairs, using the appropriate distance measure */
double process_seq_pair (int first, int second, double **subsmat, int distance_measure, int norm)
{
  /* Process a pair of sequences and get oma-distance, return a double 
     Sequences are indexed by observation number, use SF_vdata to access the data
*/
  double x1, x2;
  int s1[MAXLENGTH+1], s2[MAXLENGTH+1], length1, length2; /* MAXLENTGH+1 or MAXLENGTH? */
  int i;
  char buf[80];


  for (i=0;i<=MAXLENGTH;i++) {
    s1[i]=0;
    s2[i]=0;
  }

/*   Second variable is actual length */
  SF_vdata(2, first, &x1);
  SF_vdata(2, second, &x2);
  length1 = (int)x1;
  length2 = (int)x2;

  if ( (length1>MAXLENGTH) | (length2>MAXLENGTH) )  {
      snprintf(buf, 80, "One or both sequences too long: %d or %d  > %d\n", length1, length2, MAXLENGTH );
      SF_display(buf);
      return(-1);
    }

  for (i=1; i<=length1; i++) {
    SF_vdata(i+2, first, &x1);
    s1[i-1]=(int)x1;
    if ( (s1[i-1]<1) | (s1[i-1]>nstates)) {
      snprintf(buf, 80, "State out of range, sequence %1d, element %1d: %5d\n", first, i, s1[i-1]);
      SF_display(buf);
      snprintf(buf, 80, "Must be between 1 and %1d\n", nstates);
      SF_display(buf);
      return(-1);
    };
  }

  for (i=1; i<=length2; i++) {
    SF_vdata(i+2, second, &x2);
    s2[i-1]=(int)x2;
    if ( (s2[i-1]<1) | (s2[i-1]>nstates)) {
      snprintf(buf, 80, "State out of range, sequence %1d, element %1d: %5d\n", second, i, s2[i-1]);
      SF_display(buf);
      snprintf(buf, 80, "Must be between 1 and %1d\n", nstates);
      SF_display(buf);
      return(-1);
    };
  }

  
  switch (distance_measure) 
    {
      // OM or OMv
    case 1: 
      return(omav2(s1,s2,length1,length2,adjdur,subsmat,show_workspace,norm));
      // Timewarp
    case 2: 
      return(timewarp(s1,s2,length1,length2,subsmat,indelcost,show_workspace,norm));
      // Timewarp TWED
    case 3: 
      return(twed(s1,s2,length1,length2,subsmat,twedlambda,twednu,show_workspace,norm));
      // Hollister
    case 4: 
      return(oma_hollister(s1,s2,length1,length2, hol_x, hol_y, wmax, subsmat,show_workspace,norm));
    default: return(omav2(s1,s2,length1,length2,adjdur,subsmat,show_workspace,norm));
    }
}



/* Variables passed from Stata are: */
/* id length x1-xn */
STDLL stata_call(int argc, char *argv[])
 {
  ST_int nobs;
  int i,j,distmeasure,nrefs;
  double distance;
  ST_double z;
  char   buf[80] ;


  /* Fourth argument is whether to adjust for duration */
  adjdur = atoi(argv[4]);
  
  /* Optional fifth argument is whether to show workspace */
  show_workspace = 0;
  if (argc>4) {
    show_workspace = atoi(argv[5]);
  }
 
  exponent = 0.5;
  if (argc>5) {
    exponent = (float)atof(argv[6]);
  }
  distmeasure = 1; // Default to OMv, 1 is OMv, 2 is timewarp
  if (argc>6) {
    distmeasure = (int)atoi(argv[7]);
  }
  twedlambda = 0.0; 
  if (argc>7) {
    twedlambda = (float)atof(argv[8]);
  }
  twednu = 0.5; 
  if (argc>8) {
    twednu = (float)atof(argv[9]);
  }
  nrefs = 0;
  if (argc>9) {
    nrefs = (int)atoi(argv[10]);
  }
  hol_x = 1.0;
  if (argc>10) {
    hol_x = (float)atof(argv[11]);
  }
  hol_y = 1.0;
  if (argc>11) {
    hol_y = (float)atof(argv[12]);
  }
  norm = 1;
  if (argc>12) {
    norm = (int)atoi(argv[13]);
  }

  /* Read in the nstates */
  SF_scal_use(argv[2],&z);
  nstates=(double)z;
  
  // Allocate subsmat dynamically. C is awkward about multi-dim arrays...!
  double **subsmat = malloc(nstates*sizeof(double *));
  if (!subsmat) return -1;

  for (i=0; i<nstates; i++) {
    subsmat[i] = malloc(nstates * sizeof(double));
  if (!subsmat[i]) return -1;
  }
  
  /* Read in the substitution matrix */
  // calculate wmax at the same time
  wmax = 0.0;
  for (i=0;i<nstates;i++) {
    for (j=0;j<nstates;j++) {
      SF_mat_el(argv[0],i+1,j+1,&z);
      subsmat[i][j]=(double)z;
      if (wmax<(double)z) { 
        wmax = (double)z; 
      }
    }
  }
  
  /* Read in the indel cost */
  SF_scal_use(argv[1],&z);
  indelcost=(double)z;

  nobs = SF_nobs();

  if (nrefs > 0) {
    snprintf(buf, 80, "nrefs: %5d\n", nrefs);
    SF_display(buf);
  }
  
  if (nrefs == 0) { nrefs = nobs;
  } else {nrefs++;}


  for (i=1;i<nrefs;i++) {
    for (j=i+1;j<=nobs;j++) {

      distance = process_seq_pair(i,j,subsmat,distmeasure,norm);
      if (distance<0) {
        return(-1);
      }
/*       snprintf(buf, 80, "%3d %3d %5.2f\n", i, j, distance); */
/*       SF_display(buf); */
      SF_mat_store(argv[3],i,j,distance);
      SF_mat_store(argv[3],j,i,distance);
    }
  }

  for (i = 0; i < nstates; i++)
    free((void *)subsmat[i]);
  free((void *)subsmat);


  return(0) ;
}
