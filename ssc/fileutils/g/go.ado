*** need to check extra quotes around keys!
*! version 1.1.0 August 26, 2018 @ 19:42:23
*! uses a nickname to go to a directory
program define go
version 14.2

   // for simpler maintenance
   local subcmds to add list replace drop rename copy write setup 


   // scummed from -ci-
   _parse comma lhs rhs : 0
	gettoken subcmd lhs : lhs

   if `"`subcmd'"'=="" {
      local subcmd "list"
      }

   local oksub 0
   foreach ok of local subcmds {
      if `"`ok'"'=="`subcmd'" {
         local oksub 1
         continue, break
         }
      }
   if !`oksub' { // assume that go nickname is being used
      local lhs `"`subcmd'`lhs'"'
      local subcmd to
      }

   // unless calling go setup explicitly, try to set up GoObject
   // NO other subcommand should check existence of GoObject
   if `"`subcmd'"'!="setup" {
      capture mata orgtype(GoObject)
      if _rc {
         mata: GoObject = Go()
         go_setup
         }
      }

   go_`subcmd' `lhs' `rhs'

end

program define go_to

   syntax [anything(name=nickname id="directory shortcut")] [, nopush]

   // push or cd
   local cdpush "pushd"
   if `"`push'"'=="nopush" {
      local cdpush "cd"
      }
   else {
      capture which pushd
      if _rc {
         local cdpush "cd"
         }
      }
/*
   // check if GoLookup object exists
   capture mata orgtype(GoObject)
   if _rc {
      go_setup
      }
*/
   // side effect of setting path to change to
   mata: GoObject.whereto(`"`nickname'"')

   `cdpush' `"`whereto'"'
   
end

program define go_list

   // for now it lists everything
   syntax [anything(name=nickname id="nickname(s)")]
   // if name is empty, it will list all
   mata: GoObject.list(st_local("nickname"))

end


program define go_add

   syntax anything(name=nickname id="directory shortcut") [ using/ ] ///
     [, nowrite noexist ]

   if `"`using'"' == "" {
      local using `"`c(pwd)'"'
      }

   mata: GoObject.add(st_local("nickname"),st_local("using"),st_local("exist"))

   go list `"`nickname'"'

   if `"`write'"'=="" { // reversed due to -no-
      go write
      }
   
end

program define go_replace

   // works fine if the original nickname doesn't exist
   syntax anything(name=nickname id="directory shortcut") [using] ///
     [, nowrite]

   if `"`using'"'=="" {
      local using `"using `c(pwd)'"'
      }

   quietly go_drop `nickname', nowrite
   go_add `nickname' `using', `write'

end

program define go_drop

   syntax anything(name=nickname id="directory shortcut") ///
     [, nowrite]

   mata: GoObject.drop(st_local("nickname"))

   display `"Dropped nickname `nickname'"'
   
   if `"`write'"'=="" { // reversed because of -no-
      go write
      }
   
end

program define go_rename_or_copy

   syntax anything(name=items id="two items") [, nowrite rename]

   gettoken old new : items
   gettoken new leftover : new

   if `"`old'"'=="" | `"`new'"'=="" | `"`leftover'"'!="" {
      display as error `"need to specify old and new nicknames; you specified `items'"'
      exit 198
      }

   mata: GoObject.rename_or_copy(st_local("old"),st_local("new"),st_local("rename"))

   if `"`rename'"'!="" {
      go list `"`new'"'
      }
   else {
      go list `"`old'"' `"`new'"'
      }
   
   if `"`write'"'=="" { // reversed because of -no-
      go write
      }
  
end

program define go_copy
   go_rename_or_copy `0'
end

program define go_rename
   capture go_rename_or_copy `0', rename
   if _rc {
      go_rename_or_copy `0' rename
      }
end

program define go_check

   // !!

end

program define go_write

   capture mata orgtype(GoObject)
   if _rc {
      display as error "No GoObject defined yet, so no need to write"
      exit 198
      }

   mata: GoObject.write()

end

program define go_setup

   syntax [anything(name=filestub id="file stub")] [using/] [, replace]

   // initialize GoObject if needed
   capture mata orgtype(GoObject)
   if _rc {
      mata: GoObject = Go()
      local replace
      }
   else {
      if "`replace'"!="" {
         mata: TmpGoObject = GoObject
         mata: mata drop GoObject
         }
      }

   local rc 0
   mata: GoObject.setup(st_local("using"),st_local("filestub"))
   capture confirm file `"`dofile'"'
   if _rc {
      display as result "Could not find lookup do-file: "
      display as result `"  `dofile'"'
      if "`replace'"!="" {
         mata: GoObject = TmpGoObject
         mata: mata drop TmpGoObject
         display as text "Shortcuts not replaced"
         }
      else {
         display as result "No shortcuts defined, yet."
         }
      }
   else {
      capture noisily {
         quietly do `"`dofile'"' // contains the -go add- commands
         }
      local rc = _rc
      if `rc' {
         display as error `"initialization do-file `dofile' failed"'
         }
      }
   // split out in case of other cases for dropping object
   if `rc' {
      if "`replace'"!="" {
         mata: GoObject = TmpGoObject
         mata: mata drop TmpGoObject
         display as text "Shortcuts not replaced"
         }
      else {
         capture mata: mata drop GoObject
         }
      exit `rc'
      }
end
