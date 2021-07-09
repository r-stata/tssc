*! version 1.0 June 15, 2006 @ 18:01:44
*! Group Sequences based on distance matrix from -sqom-

program sqclustermat
version 9.1

syntax [anything] [, name(string) * ]

quietly {

    // New names for Cluster-Variables?
    if "`name'" == "" capture drop _SQomcluster*
    else {
        gettoken  clustervarname : name, parse(",")
        if strpos("`name'","replace") > 0   ///
          capture drop `clustervarname'_id  ///
                       `clustervarname'_ord ///
                       `clustervarname'_hgt
        confirm new variable ///
          `clustervarname'_id     ///
          `clustervarname'_ord    ///
          `clustervarname'_hgt
    }
    local SQomcluster = cond("`name'"=="","_SQomcluster","`clustervarname'")

    // Default anything

    if `"`anything'"' == `""' {
        local anything `"wardslinkage"'
    }	

    // Match data to dimensions of SQdist
    sqclusterdat

    // User-Command
    clustermat `anything' SQdist, add name(`SQomcluster') `options'

    // Back to sequence data
    sqclusterdat, return

    noi di as text "Results of cluster analysis saved as " ///
            as res "`SQomcluster'_*"
}
end

