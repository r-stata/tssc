
mata

struct strbib {
	transmorphic        scalar    bibdb
	transmorphic        scalar    style
	string              colvector keys
	string              scalar    and
	string              scalar    authorstyle 
	string              scalar    stylefile
	string              scalar    bibfile
	real                scalar    bibslide
	string              colvector refs
	string              scalar    write
}

struct strtoc {
	string              scalar    link
	string              scalar    title
	string              scalar    itemize
	string              scalar    subtitlepos
	string              scalar    subtitlebf
	string              scalar    subtitleit
	string              scalar    subtitlethline
	string              scalar    subtitlebhline
	string              scalar    subtitle
	string              scalar    anc
	string              scalar    secthline
	string              scalar    secbhline
	string              scalar    secbf
	string              scalar    secit
	string              scalar    subsecbf
	string              scalar    subsecit
	string              scalar    subsubsecbf
	string              scalar    subsubsecit
	string              scalar    subsubsubsecbf
	string              scalar    subsubsubsecit
	string              scalar    nodigr
}
struct strtocfiles {
	string              scalar    on        
	string              scalar    name      
	string              scalar    where  
	string              scalar    exname
	string              matrix    markname
	string              scalar    doedit
    string              scalar    view
	string              scalar    gruse     
	string              scalar    euse      
	string              scalar    use       
	string              scalar    p2        
}
struct strdigress {
	string              scalar    name  
	string              scalar    prefix
}
struct strexample {
	string              scalar    name
}
struct strtopbar {
	string              scalar    on          
	string              scalar    thline      
	string              scalar    bhline      
	string              scalar    subsec      
	string              scalar    secbf       
	string              scalar    secit       
	string              scalar    subsecbf    
	string              scalar    subsecit    
	string              scalar    sep         	
}
struct strbottombar {
	string              scalar    thline   
	string              scalar    bhline   
	string              scalar    arrow    
	string              scalar    index    
	string              scalar    nextname 
	string              scalar    next     
	string              scalar    tpage    
	string              scalar    toc
}
struct strtitle {
	string              scalar    thline    
	string              scalar    bhline    
	string              scalar    pos       
	string              scalar    bold      
	string              scalar    italic    
}
struct strother {
	real                rowvector regslides
	real                rowvector allslides
	string              scalar    index
	real                scalar    titlepage
	string              scalar    stub
	string              scalar    source
	string              scalar    sourcedir
	string              scalar    destdir
	string              scalar    olddir
	string              scalar    replace
	string              scalar    l1
	string              scalar    l2
	string              scalar    l3
	string              scalar    l4
	real                scalar    tab
}
struct strsettings {
	struct strtoc       scalar    toc
	struct strtocfiles  scalar    tocfiles
	struct strdigress   scalar    digress
	struct strexample   scalar    example
	struct strtopbar    scalar    topbar
	struct strbottombar scalar    bottombar
	struct strtitle     scalar    title
	struct strother     scalar    other
}

struct strslide {
	string              scalar    type 
	string              scalar    title
	string              scalar    section
	string              scalar    subsection
	string              scalar    label
	real                scalar    prev
	real                scalar    forw         
}
struct strpres {
	struct strsettings  scalar    settings
	struct strslide     colvector slide
	struct strslide     scalar    tocslide
	struct strslide     scalar    titleslide
	struct strbib       scalar    bib
	transmorphic        scalar    files
	
}

struct strpres scalar sp_presinit() {
	struct strpres scalar pres
	
	pres.settings.toc.link           = "section"
	pres.settings.toc.title          = "notitle"
	pres.settings.toc.itemize        = "noitemize"
	pres.settings.toc.subtitlepos    = "center"
	pres.settings.toc.subtitlebf     = "bold"
	pres.settings.toc.subtitleit     = "regular"
	pres.settings.toc.subtitlethline = "hline"
	pres.settings.toc.subtitlebhline = "hline"
	pres.settings.toc.subtitle       = "Slide table of contents"
	pres.settings.toc.anc            = "ancillary"
	pres.settings.toc.secthline      = "nohline" 
	pres.settings.toc.secbhline      = "nohline"
	pres.settings.toc.secbf          = "regular"
	pres.settings.toc.secit          = "regular"
	pres.settings.toc.subsecbf       = "regular"
	pres.settings.toc.subsecit       = "regular"
	pres.settings.toc.subsubsecbf    = "regular"
	pres.settings.toc.subsubsecit    = "regular"
	pres.settings.toc.subsubsubsecbf = "regular"
	pres.settings.toc.subsubsubsecit = "regular"
	pres.settings.toc.nodigr         = "digr"

	pres.settings.tocfiles.on        = "off"
	pres.settings.tocfiles.name      = "Supporting materials"
	pres.settings.tocfiles.exname    = "example "
	pres.settings.tocfiles.where     = "; on slide "
	pres.settings.tocfiles.markname  = "ex"    ,"Examples" \
	                                   "do"    ,"Do files"  \
	                                   "ado"   ,"Ado files" \
	                                   "data"  ,"Datasets" \
	                                   "class" ,"Classes" \
	                                   "style" ,"Styles" \
	                                   "graph" ,"Graphs" \
	                                   "grec"  ,"Graph editor recordings" \
	                                   "irf"   ,"Impulse-response function datasets" \
	                                   "mata"  ,"Mata files" \
	                                   "bc"    ,"Business calendars" \
	                                   "ster"  ,"Saved estimates" \
	                                   "trace" ,"Parameter-trace files" \
	                                   "sem"   ,"SEM builder files" \
	                                   "swm"   ,"Spatial weighting matrices"
	pres.settings.tocfiles.doedit    = "do ado dct class scheme style"
	pres.settings.tocfiles.view      = "smcl log hlp sthlp"
	pres.settings.tocfiles.gruse     = "gph"
	pres.settings.tocfiles.euse      = "ster"
	pres.settings.tocfiles.use       = "dta"
	pres.settings.tocfiles.p2        = "5 25 26 0"	
	
	pres.settings.digress.name       = "digression"
	pres.settings.digress.prefix     = ">> "
	
    pres.settings.example.name       = "{it:click to run}"
	
	pres.settings.topbar.on          = "on"
	pres.settings.topbar.thline      = "hline"
	pres.settings.topbar.bhline      = "hline"
	pres.settings.topbar.subsec      = "subsec"
	pres.settings.topbar.secbf       = "bold"
	pres.settings.topbar.secit       = "regular"
	pres.settings.topbar.subsecbf    = "regular"
	pres.settings.topbar.subsecit    = "regular"
	pres.settings.topbar.sep         = " {hline 2} "	
	
	pres.settings.bottombar.thline   = "hline"
	pres.settings.bottombar.bhline   = "hline"
	pres.settings.bottombar.arrow    = "arrow"
	pres.settings.bottombar.index    = "index"
	pres.settings.bottombar.nextname = "next"
	pres.settings.bottombar.next     = "right"
	pres.settings.bottombar.tpage    = "titlepage"
	
	pres.settings.title.thline       = "nohline"
	pres.settings.title.bhline       = "nohline"
	pres.settings.title.pos          = "center"
	pres.settings.title.bold         = "bold"
	pres.settings.title.italic       = "regular"
	
	pres.settings.other.titlepage    = 0
	pres.settings.other.tab          = 4
	
	pres.bib.bibdb                   = asarray_create("string",2)
	
	pres.files                       = asarray_create("real")
	asarray_notfound(pres.bib.bibdb, "")
	pres.bib.style                   = asarray_create()
	pres.bib.keys                    = J(0,1,"")
	pres.bib.and                     = "and"
	pres.bib.authorstyle             = "first last"
	pres.bib.refs                    = J(0,1,"")
	pres.bib.write                   = "cited"
	
	return(pres)
}

end
