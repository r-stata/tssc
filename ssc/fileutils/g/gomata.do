** Mata code
mata:

   mata clear
   
   class Go {
      string scalar dir
      string scalar fstub
      class AssociativeArray scalar GoLookup

      void dirsetup()
      void fsetup()
      void AAsetup()

      void add()
      void drop()
      void list()
      void new()
      real scalar nonnull()
      string scalar setOuterQuotes ()
      void rename_or_copy()
      void setdo()
      void setup()
      void whereto()
      void write()
      }

   real scalar Go::nonnull() {
      if(GoLookup.firstval() != "") {
         return(1)
         }
      else {
         return(0)
         }
      }

   void Go::new() {
      dir = fstub = ""
      GoLookup.notfound("")
      }

   void Go::dirsetup(|string scalar newdir) {
      string scalar lastchar
      
      if(newdir!="") {
         // be sure that the directory ends in a (back)slash
         lastchar = usubstr(pathsubsysdir(newdir),-1,.)
         if(lastchar!="/" & lastchar!=c("dirsep")) { 
            newdir=newdir+"/"
            }
         dir=newdir
         }
      else {
         if(dir=="") {
            newdir=pathsubsysdir("PERSONAL")
            if(!direxists(newdir)) {
               errprintf("directory %s does not exist\n",newdir)
               exit(601)
               }
            dir=newdir
            }
         }
      }

   void Go::fsetup(|string scalar newstub) {
      if(newstub!="") {
         fstub=newstub
         }
      else {
         if(fstub=="") {
            fstub="golookup"
            }
         }
      }

   void Go::AAsetup(|string scalar newdir, string scalar newstub) {
      // dirsetup(newdir)
      // fsetup(newstub)
      // must be incredibly bad, because the object name is used in the do-file
      // stata("do" + newdir + newstub)
      //
      // null function?!
      }

   void Go::add(string scalar nickname, string scalar destination,| string scalar exist) {
      nickname=setOuterQuotes(nickname,0)
      // check if nickname exists
      if(GoLookup.exists(nickname)) {
         errprintf("nickname %s already exists; could not add\n",nickname)
         exit(666)
         }
      // check if destination exists (if necessary)
      destination=setOuterQuotes(destination,0)
      if (exist=="") {
         if (!direxists(destination)) {
            errprintf("directory %s not found\n",destination)
            exit(601)
            }
         }
      GoLookup.put(nickname,destination)
      }
   
   void Go::write() {
      real scalar fh
      string scalar tempfile
      string scalar aName
      string scalar aDir
      string scalar dofile
      
      tempfile=st_tempfilename()
      fh = fopen(tempfile, "w")
      for (aDir=GoLookup.firstval(); aDir!=GoLookup.notfound(); aDir=GoLookup.nextval()) {
         if(ustrtrim(aDir)!="") {
            aName = GoLookup.key()
            aName = setOuterQuotes(aName,1)
            aDir = setOuterQuotes(aDir,1)
            fput(fh,"go add " + aName + " using " + aDir + ", nowrite noexist")
            } // end check for blank dir
         } // end loop
      fclose(fh)

      setdo()
      stata("copy " + tempfile + `" ""' + st_local("dofile") + `"", replace"')
      }

   void Go::drop(string scalar aKey) {
      aKey = setOuterQuotes(aKey,0)
      if(GoLookup.exists(aKey)) {
         GoLookup.remove(aKey)
         }
      else {
         printf(`"Nickname %s doesn't exist, so no need to drop it"',aKey)
         st_local("write","nowrite")
         }
      }

   void Go::rename_or_copy(string scalar old, string scalar newx,| string scalar rename) {
      old=setOuterQuotes(old,0)
      newx=setOuterQuotes(newx,0)
      if(GoLookup.exists(old)) {
         GoLookup.put(newx,GoLookup.get(old))
         if(rename!="") {
            GoLookup.remove(old)
            }
         }
      else {
         errprintf("Nickname %s does not exist; cannot rename\n",old)
         exit(6)
         }
      }

   void Go::setup(|string scalar newdir, string scalar newfstub) {

      dirsetup(newdir)
      fsetup(newfstub)
      setdo()
      
      }

   void Go::setdo() {
      st_local("dofile",dir + fstub + "_" + c("os") + ".do")
      }

   string scalar Go::setOuterQuotes(string scalar fixme,real scalar quotes) {
      real scalar notdone
      notdone = 1
      while (notdone) {
         if(usubstr(fixme,1,1)==`"""' & usubstr(fixme,-1,1)==`"""') {
            fixme=usubstr(fixme,2,ustrlen(fixme)-2)
            }
         else {
            notdone = 0
            }
         }
      while(quotes > 0) {
         fixme=`"""' + fixme + `"""'
         quotes--
         }
      return(fixme)
      }

   void Go::whereto(string scalar nickname) {
      real scalar first
      string scalar subdir
      string scalar whereto

      subdir=""
      // strip quotes, turn \ into / because Stata understands /
      nickname=usubinstr(setOuterQuotes(nickname,0),"\","/",.)      
      first=ustrpos(nickname,"/")
      // see if there is a / or a \... it must directly follow the nickname
      if (first) {
         subdir = usubstr(nickname,first,.)
         nickname = usubstr(nickname,1,first-1)
         }
      whereto=GoLookup.get(nickname)
      if (whereto=="") {
         if (GoLookup.N()==0) {
            errprintf("No shortcuts defined\n")
            exit(111)
            }
         errprintf(`"Could not find shortcut %s\n"',nickname)
         displayas("result")
         printf("Available shortcuts are\n")
         GoLookup.keys()
         exit(111)
         }
      if (first) {
         if (usubstr(whereto,-1,1)=="/") {
            whereto = usubstr(whereto,1,ustrlen(whereto)-1)
            }
         }
      st_local("whereto",setOuterQuotes(whereto,0)+setOuterQuotes(subdir,0))
      }

   void Go::list(string scalar listme) {
      string matrix showme
      string matrix list_items
      string scalar aDir
      string scalar aKey
      string scalar widformat
      string scalar lq
      string scalar rq
      showme=J(0,2,"")
      lq="`"
      rq="'"
      if (listme=="") {
         for (aDir=GoLookup.firstval(); aDir!=GoLookup.notfound(); aDir=GoLookup.nextval()) {
            showme=showme\(setOuterQuotes(GoLookup.key(),0),setOuterQuotes(aDir,0))   
            } // end loop
         } // end check for blank list
      else {
         list_items = tokens(listme)
         for (index=1; index<=length(list_items); index++) {
            aKey=setOuterQuotes(list_items[index],0)
            aDir=setOuterQuotes(GoLookup.get(aKey),0)
            showme=showme\(aKey,aDir)
            }
         }
      if (rows(showme) > 0) {
         // showme // (terrible listing of matrix as all columns as wide as widest)

         widformat = strofreal(max(udstrlen(showme[.,1])))
         for (row=1; row<=rows(showme); row++) {
//            stata("display %-" + widformat + "s " + `"""' + showme[row,1] + `"""' + lq + `"""' + " -> {stata " + "pushd " + `"""' + showme[row,2] + `"""' + ":" + showme[row,2] + "}" + `"""' + rq)
            stata("display %-" + widformat + "s " + `"""' + showme[row,1] + `"""' + lq + `"""' + " -> {stata " + "go " + `"""' + showme[row,1] + `"""' + ":" + showme[row,2] + "}" + `"""' + rq)
            }
         }
      else {
         printf("No shortcuts defined!\n")
         }
      }


   mata mlib create lGo, replace
   mata mlib add lGo *()
   mata mlib index

end

