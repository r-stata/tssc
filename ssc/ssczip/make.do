// Generating Stata Help Files
markdoc "ssczip.ado", mini export(sthlp) replace

// build the package installation
make ssczip, replace toc pkg  version(1.1)                                          ///
     license("MIT")                                                                 ///
     author("E. F. Haghish")                                                        ///
     affiliation("University of Göttingen")                                         ///
     email("haghish@med.uni-goettingen.de")                                         ///
     url("https://github.com/haghish/github")                                       ///
     title("github package manager")                                                ///
     description("Package and download Stata packages from SSC as a zip file")      ///
     install("ssczip.ado;ssczip.sthlp;")                                            ///
     ancillary("")                                                  
     
