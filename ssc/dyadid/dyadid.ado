version 11.0

mata:

real matrix function dyadid (string idvar, string dyadidvar, string genvar) {
  st_view(id = ., ., (idvar))
  st_view(dyadid = ., ., (dyadidvar))
  st_view(gen = ., ., (genvar))

  nobs = length(dyadid)

  altindex = asarray_create("real")
  for (i=1; i<=nobs; i++) {
    asarray(altindex,id[i],i)
  }
  for (i=1; i<=nobs; i++) {
    if (asarray_contains(altindex,dyadid[i])) {
      gen[i] = asarray(altindex,dyadid[i])
    }
    else {
      gen[i] = .
    }
  }
}

end

program dyadid
syntax varlist(min=2 max=2), gen(string)
tokenize `varlist'

/* // Check that alter-ID is unique if not missing */
/* preserve */
/* keep if !missing(`2') */
/* isid `2' */
/* restore */

qui gen `gen' = .
mata dyadid("`1'", "`2'", "`gen'")
end

/*

With dyadic data, given ID (not necessarily unique) and alter-ID
(unique, but potentially missing), where alter-ID is the ID of the
partner, generate an index variable which is the row number of the
partner's record

. dyadid id spid, gen(idx)
. gen spempstat = empstat[idx]

*/
