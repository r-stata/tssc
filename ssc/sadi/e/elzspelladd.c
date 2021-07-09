
/* 

Oct 13 2008 23:18:56
Add subsequence lengths together instead of multiply in the first stage

Copyright 2007 Brendan Halpin brendan.halpin@ul.ie
Distribution is permitted under the terms of the GNU General Public Licence
*/
/* Dec 23 2006 17:11:09
   Variant of hashplugin.c to generate spell version

   Main principle of both versions is to enumerate all tuples
   individually in a first pass (O(N) ignoring length of
   sequences). This is done for each case using a recursive
   function to identify tuples and to record their count in a hash
   structure. The data is then transferred into a sparse-matrix
   equivalent structure consisting of two matrices and a vector
   (i.e. for each case two vectors and a scalar) recording the the
   number of distinct tuples observed, and the index number and
   count of each observed tuple. A hash is used because the number
   of distinct tuples possible can be enormous (e.g. 1e12) while
   the number actually observed will be manageable (e.g. <1e5). The
   hashed data is transferred into the vector/vector/scalar
   structure for ease of use. (It may be possible to avoid doing so
   by using a vector of hash tables (i.e. one per case rather than
   re-using the same one), and comparing pairs of hash tables in
   the following step.)

   This structure then allows a very rapid pairwise comparison: the
   vectors of tuple indices (which are in sort order) are compared
   and where common tuples are observed, the corresponding pair of
   counts are used in calculating the pairwise similarity score,
   \frac{Sxy}{\sqrt Sxx Syy}. 
*/

#include "stplugin.h"
#include <stdio.h>   /* gets */
#include <stddef.h>   /* size_t */
#include <stdlib.h>  /* atoi, malloc */
#include <string.h>  /* strcpy */
#include <math.h>
#include "uthash.h"

/* Critical maxima
   1 longest sequence 
   2 max distinct tuples allowed per sequence (a harder limit than 1)
   3 max number of cases 
*/
#define MAXLENGTH 100
#define MAXTUPLES 40000
#define MAXCASES  5500

int increment_tuple_spell(unsigned long int tuple_id, unsigned long int duration);


int nstates;
int show_work;


struct my_struct {
  unsigned long int id;     /* key */
  unsigned long int count;
  UT_hash_handle hh;             /* makes this structure hashable */
};

struct my_struct *tupleshash = NULL;

int enumeratetuples_spell (int start, 
                          int finish,
                          unsigned long int offset,
                          int *seqs,
                          int *seql, 
                          unsigned long int cumdur) {
  int mti;
  unsigned long int tuple1, tuple2;
  char buf[80];


  tuple1 = offset*nstates;
  for (mti=start; mti<=finish; mti++) {
    if ((seqs[mti]>nstates) | (seqs[mti]<1)) {
      return(999);
    }
    tuple2=tuple1+seqs[mti];                        /* state */

    if (show_work) {
      snprintf(buf,80,"Enum tup: %lu %lu %d\n",
               offset, tuple2, seql[mti]);
      SF_display(buf);
    }

    increment_tuple_spell(tuple2,cumdur+seql[mti]); /* duration */


    enumeratetuples_spell(mti+1,finish,tuple2,seqs,seql,cumdur+seql[mti]);
  }
  return(0);
}


int increment_tuple_spell(unsigned long int tuple_id, unsigned long int duration) {
  struct my_struct *s;
  char buf[80];

  HASH_FIND(hh, tupleshash, &tuple_id, sizeof(unsigned long int), s );
  if (s) {
    s->count+=duration;
  }
  else {
    s = malloc(sizeof(struct my_struct));  
    if (s == NULL) {
      snprintf(buf,80,"Hash malloc problem----------------------------------------------------------\n");
      SF_error(buf);
      return(-1);
    }
    s->id = tuple_id;
    s->count = duration;
    HASH_ADD(hh, tupleshash, id, sizeof(unsigned long int), s );
  }
  return(1);
}

int id_sort(struct my_struct *a, struct my_struct *b) {
  return((a->id > b->id ? 1 : (a->id == b->id ? 0 : -1) ));
}

void sort_by_id() {
    HASH_SORT(tupleshash, id_sort);
}

/* /\* Suggested at http://www.gnu.org/software/libc/manual/html_node/Malloc-Examples.html *\/ */
/* void * xmalloc (size_t size) { */
/*   register void *value = malloc (size); */
/*   if (value == 0) */
/*     fatal ("virtual memory exhausted"); */
/*   return value; */
/* } */


STDLL stata_call(int argc, char *argv[]) 
{
  char buf[80];

  int resulttype;
  int i, j;
  int nobs,length;
  double x1;
  int seqs[MAXLENGTH];
  int seql[MAXLENGTH];
  long nobstuples;
  double sxx;
  ST_retcode rc;
  double sxy, similarity, distance;
  unsigned long int k1, k2, maxcases, maxtuples;

  /* FILE *debugfile; */
  /* debugfile = fopen("debugfile","w+"); */

  nstates = atoi(argv[1]);
  if (argc>1) { 
    show_work = atoi(argv[2]);
  } else {
    show_work = 0;
  }
  if (argc>2) { 
    resulttype = atoi(argv[3]);
  } else {
    resulttype = 1;
  }
  if (argc>3) { 
    maxcases = atoi(argv[4]) + 1; /* needs to be 1 bigger than _N because SF_vdata does for(i=1;i<=nobs...) */
  } else {
    maxcases = 1000;
  }
  if (argc>4) { 
    maxtuples = atoi(argv[5]) + 1;
  } else {
    maxtuples = 40000;
  }

  double t_sxx[maxcases];
  /* double *t_sxx = malloc(maxcases*sizeof(double *));  */
  /* move here to see if fixes 2nd run problem Oct 17 2011 23:56:56 */


  size_t st = maxcases*sizeof(long *);

  long int **t_index = malloc(st);
  long int **t_count = malloc(st);

  for (i=0; i<maxcases; i++ ) {
    t_index[i] = malloc(maxtuples*sizeof(long *));
    t_count[i] = malloc(maxtuples*sizeof(long *));
    if (t_count[i] == NULL) {
      /* fprintf(debugfile,"t_ malloc failed: %d----------------------------------------------------------\n",i); */
      /* fflush(debugfile); */
      return(-1);
    }
  }
    /* fprintf(debugfile,"entup0\n"); */
    /* fflush(debugfile); */
  

  /* Initiallise these arrays, seem to be a source of error otherwise
     Oct 18 2011 00:21:55 */
  for (i=0; i<maxcases; i++) {
    /* fprintf(debugfile,"t_ malloc: %d\n",i); */
    /* fflush(debugfile); */
    for (j=0; j<maxtuples; j++) {
      t_index[i][j]=0;
      t_count[i][j]=0;
    }
  }
    /* fprintf(debugfile,"initialise t_\n"); */
    /* fflush(debugfile); */

  struct my_struct *s;

    /* fprintf(debugfile,"entup xxx\n"); */
    /* fflush(debugfile); */

  nobs = SF_nobs();
  if (nobs>maxcases) {
    snprintf(buf, 80, "Error 3: n-cases (%5d) exceeds maximum (%lu)\n", nobs, maxcases);
    SF_display(buf);
    return(100);
  }

    /* fprintf(debugfile,"entup1\n"); */
    /* fflush(debugfile); */
  snprintf(buf,80,"Reading data and enumerating tuples\n");
  SF_display(buf);
  for (i=1;i<=nobs;i++) {
    SF_vdata(2, i, &x1);
    length = (int)x1;
    for (j=1; j<=length; j++) {
      rc = SF_vdata((j-1)*2+3, i, &x1);
      if (rc) {return(rc);}
      if (x1<1 || x1>nstates) {
        snprintf(buf,80,"Error: case %d state out of range: %5.2f\n",j,x1);
        SF_display(buf);
        return(1);
      }
      seqs[j]=(int)x1;                /* state */
      rc = SF_vdata((j-1)*2+4, i, &x1);
      if (x1<1) {
        snprintf(buf,80,"Error: case %d duration out of range: %5.2f\n",j,x1);
        SF_display(buf);
        return(1);
      }
      if (rc) {return(rc);}
      seql[j]=(int)x1;                /* duration */
    }

    /* fprintf(debugfile,"entup2\n"); */
    /* fflush(debugfile); */

    tupleshash = NULL;

    if (show_work) {
      snprintf(buf,80,"I: %d\n",
               i);
      SF_display(buf);
    }

    enumeratetuples_spell(1,length,0,seqs,seql,0); /* Was 1, should start cum duration at 0? Nov 10 2011 21:46:22 */
    sort_by_id();

    nobstuples = 0;
    sxx = 0;
    for(s=tupleshash; s != NULL; s=s->hh.next) {
      nobstuples++;
      if (show_work) {
        snprintf(buf,80,"TPH: %d %lu %lu\n",
                 i, s->id,s->count);
        SF_display(buf);
      }

      t_index[i][nobstuples]=s->id;
      t_count[i][nobstuples]=s->count;

      sxx+= (double)s->count*(double)s->count;
      HASH_DEL(tupleshash, s);
      free(s);
    }
    if (nobstuples>=maxtuples) {
      snprintf(buf, 80, "Error 2: case%5d: tuples observed %lu\n", i, nobstuples);
      SF_display(buf);
      return(100);
    }
    t_sxx[i]=sxx;
  }

  /* Pairwise processing */

  snprintf(buf,80,"Pairwise processing\n");
  SF_display(buf);
  for (i=1; i<=nobs; i++) {
    
    switch (resulttype) {
    case 1: 
      SF_mat_store(argv[0],i,i,1.0); /* Diagonal of 1s for similarity matrix */
      break;
    case 2: 
      SF_mat_store(argv[0],i,i,0.0); /* Diagonal of 0s for distance matrix */
      break;
    case 3: 
      SF_mat_store(argv[0],i,i,(double)t_sxx[i]); /* Diagonal of SXX for SXY matrix */
      break;
    default: 
      snprintf(buf,80,"Error: result type not legitimate\n");
      SF_display(buf);
      return(1);
      break;
    }
    
    for (j=i+1; j<=nobs; j++) {
      sxy=0;
      k1=1;
      k2=1;
      while ((t_index[i][k1]>0) & (t_index[j][k2]>0)) {
        if (t_index[i][k1]==t_index[j][k2]) { 
          sxy = sxy + (double)t_count[i][k1]*(double)t_count[j][k2];
          if (show_work) {
            /* snprintf(buf,80,"STUFF: %d %d %ld %Lf %Lf %Lf\n", */
            /*          i, j,  */
            /*          t_index[i][k1], */
            /*          (double)t_count[i][k1], */
            /*          (double)t_count[j][k2], */
            /*          (double)sxy ); */
            snprintf(buf,80,"STUFF: %d %d %g\n",
                     i,j,sxy );
            SF_display(buf);
          }
          k1++;
          k2++;
        }
        if (t_index[i][k1]<t_index[j][k2]) { 
          k1++;
        }
        if (t_index[i][k1]>t_index[j][k2]) { 
          k2++;
        }
      }
      similarity = sxy/sqrt((double)t_sxx[i]*(double)t_sxx[j]);
      if (similarity>1.0) {
        snprintf(buf,80,"Faulty similarity value: %d %d %5.3f\n",
                 i, j, similarity);
        SF_display(buf);
      }
      distance = sqrt( (double)t_sxx[i] + (double)t_sxx[j] - 2*sxy ) ;
      if (distance < 0.0) {
        snprintf(buf,80,"Faulty distance value: %d %d %5.3f\n",
                 i, j, distance);
        SF_display(buf);
      }
    switch (resulttype) {
    case 1: 
      SF_mat_store(argv[0],i,j,similarity);
      SF_mat_store(argv[0],j,i,similarity);
      break;
    case 2: 
      SF_mat_store(argv[0],i,j,distance);
      SF_mat_store(argv[0],j,i,distance);
      break;
    case 3: 
      SF_mat_store(argv[0],i,j,sxy);
      SF_mat_store(argv[0],j,i,sxy);
      break;
      /* result type checked already */
    }
    }
  }


  for (i=0; i < maxcases; i++) {
    free((void *)t_index[i]);
    free((void *)t_count[i]);
  }
  free((void *)t_index);
  free((void *)t_count);
  /* free((void *)t_sxx); */


return(0);
}
