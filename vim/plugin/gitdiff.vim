" Git vim diff mode functions.
" vim: et ts=8 sts=2 sw=2
"
" Last Change: 28 May 2012
" Maintainer: Andrew Bettison <andrewb@zip.com.au>
" Author: Andrew Bettison <andrewb@zip.com.au>
" Copyright: 2012 Andrew Bettison
" License: GPL2

" This should be integrated into the Vim help system.
"
"" \l   Log             Open a new window showing the log of all changes to the current file (see below for key bindings available in the log window)
"" \L                   Close the log window opened with \l
"" \x   Close revision  Close all diff windows opened with the <Enter> command in the log window (see below)
"" \w   Working copy    Open a new diff window showing the working copy (latest save)
"" \W                   Close the diff window opened with \w
"" \h   Head            Open a new diff window showing the HEAD (latest commit on current branch)
"" \H                   Close the diff window opened with \h
"" \b   Merge branch    Open a new diff window showing merge target branch (stage 2)
"" \B                   Close the diff window opened with \m
"" \m   Merge head      Open a new diff window showing incoming merge head (stage 3)
"" \M                   Close the diff window opened with \m
"" \a   Merge ancestor  Open a new diff window showing common merge ancestor (stage 1)
"" \A                   Close the diff window opened with \a
"" \1   Stage 1         Toggle a diff window showing stage number 1 (common ancestor during merge)
"" \2   Stage 2         Toggle a diff window showing stage number 2 (from merge target branch)
"" \3   Stage 3         Toggle a diff window showing stage number 3 (from branch being merged in)
"" \\   Close diffs     Close all diff windows opened with the above commands
"" \-   Close diff      Close current diff window
"" \=   Close all       Equivalent to \\ followed by \L
"" \|   Toggle main     Toggle the diff mode of the main file window. This is useful when two diff windows are open, to see only the changes between them.

" ------------------------------------------------------------------------------
" Exit if this app has already been loaded or in vi compatible mode.
if exists("g:loaded_GitDiffPlugin") || &cp
  finish
endif
let g:loaded_GitDiffPlugin = 1

" Standard Vim plugin boilerplate.
let s:keepcpo = &cpo
set cpo&vim

" ------------------------------------------------------------------------------
" PUBLIC INTERFACE

" Default key bindings, only set where no binding already has been defined.
if !exists('no_plugin_maps')
  if !hasmapto('<Plug>CloseAll')
    nmap <unique> <Leader>= <Plug>CloseAll
  endif
  if !hasmapto('<Plug>DiffsCloseAll')
    nmap <unique> <Leader>\ <Plug>DiffsCloseAll
  endif
  if !hasmapto('<Plug>DiffsCloseWindow')
    nmap <unique> <Leader>- <Plug>DiffsCloseWindow
  endif
  if !hasmapto('<Plug>DiffsOpenWorking')
    nmap <unique> <Leader>w <Plug>DiffsOpenWorking
  endif
  if !hasmapto('<Plug>DiffsCloseWorking')
    nmap <unique> <Leader>W <Plug>DiffsCloseWorking
  endif
  if !hasmapto('<Plug>DiffsOpenHead')
    nmap <unique> <Leader>h <Plug>DiffsOpenHead
  endif
  if !hasmapto('<Plug>DiffsCloseHead')
    nmap <unique> <Leader>H <Plug>DiffsCloseHead
  endif
  if !hasmapto('<Plug>DiffsToggleStage0')
    nmap <unique> <Leader>0 <Plug>DiffsToggleStage0
  endif
  if !hasmapto('<Plug>DiffsToggleStage1')
    nmap <unique> <Leader>1 <Plug>DiffsToggleStage1
  endif
  if !hasmapto('<Plug>DiffsToggleStage2')
    nmap <unique> <Leader>2 <Plug>DiffsToggleStage2
  endif
  if !hasmapto('<Plug>DiffsToggleStage3')
    nmap <unique> <Leader>3 <Plug>DiffsToggleStage3
  endif
  if !hasmapto('<Plug>DiffsOpenMergeAncestor')
    nmap <unique> <Leader>a <Plug>DiffsOpenMergeAncestor
  endif
  if !hasmapto('<Plug>DiffsCloseMergeAncestor')
    nmap <unique> <Leader>A <Plug>DiffsCloseMergeAncestor
  endif
  if !hasmapto('<Plug>DiffsOpenMergeBranch')
    nmap <unique> <Leader>b <Plug>DiffsOpenMergeBranch
  endif
  if !hasmapto('<Plug>DiffsCloseMergeBranch')
    nmap <unique> <Leader>B <Plug>DiffsCloseMergeBranch
  endif
  if !hasmapto('<Plug>DiffsOpenMergeHead')
    nmap <unique> <Leader>m <Plug>DiffsOpenMergeHead
  endif
  if !hasmapto('<Plug>DiffsCloseMergeHead')
    nmap <unique> <Leader>M <Plug>DiffsCloseMergeHead
  endif
  if !hasmapto('<Plug>DiffsCloseLogRevisions')
    nmap <unique> <Leader>x <Plug>DiffsCloseLogRevisions
  endif
  if !hasmapto('<Plug>DiffsToggleOrigBuffer')
    nmap <unique> <Leader>| <Plug>DiffsToggleOrigBuffer
  endif
  if !hasmapto('<Plug>LogOpen')
    nmap <unique> <Leader>l <Plug>LogOpen
  endif
  if !hasmapto('<Plug>LogClose')
    nmap <unique> <Leader>L <Plug>LogClose
  endif
  if !hasmapto('<Plug>Help')
    nmap <unique> <Leader>? <Plug>Help
  endif
endif

" Default commands, will not replace existing commands with same name.
if !exists(':GitDiff')
  command -nargs=1 GitDiff call <SID>openRevisionDiff(<q-args>)
endif

" Global maps, available for your own key bindings.
noremap <silent> <unique> <Plug>CloseAll :call <SID>closeAll()<CR>
noremap <silent> <unique> <Plug>DiffsCloseAll :call <SID>closeAllDiffs()<CR>
noremap <silent> <unique> <Plug>DiffsCloseWindow :call <SID>closeCurrentDiff()<CR>
noremap <silent> <unique> <Plug>DiffsToggleWorking :call <SID>toggleWorkingDiff()<CR>
noremap <silent> <unique> <Plug>DiffsOpenWorking :call <SID>openWorkingDiff()<CR>
noremap <silent> <unique> <Plug>DiffsCloseWorking :call <SID>closeWorkingDiff()<CR>
noremap <silent> <unique> <Plug>DiffsToggleHead :call <SID>toggleHeadDiff()<CR>
noremap <silent> <unique> <Plug>DiffsOpenHead :call <SID>openHeadDiff()<CR>
noremap <silent> <unique> <Plug>DiffsCloseHead :call <SID>closeHeadDiff()<CR>
noremap <silent> <unique> <Plug>DiffsToggleStage0 :call <SID>toggleStageDiff(0)<CR>
noremap <silent> <unique> <Plug>DiffsOpenStage0 :call <SID>openStageDiff(0)<CR>
noremap <silent> <unique> <Plug>DiffsCloseStage0 :call <SID>closeStageDiff(0)<CR>
noremap <silent> <unique> <Plug>DiffsToggleStage1 :call <SID>toggleStageDiff(1)<CR>
noremap <silent> <unique> <Plug>DiffsOpenStage1 :call <SID>openStageDiff(1)<CR>
noremap <silent> <unique> <Plug>DiffsCloseStage1 :call <SID>closeStageDiff(1)<CR>
noremap <silent> <unique> <Plug>DiffsToggleStage2 :call <SID>toggleStageDiff(2)<CR>
noremap <silent> <unique> <Plug>DiffsOpenStage2 :call <SID>openStageDiff(2)<CR>
noremap <silent> <unique> <Plug>DiffsCloseStage2 :call <SID>closeStageDiff(2)<CR>
noremap <silent> <unique> <Plug>DiffsToggleStage3 :call <SID>toggleStageDiff(3)<CR>
noremap <silent> <unique> <Plug>DiffsOpenStage3 :call <SID>openStageDiff(3)<CR>
noremap <silent> <unique> <Plug>DiffsCloseStage3 :call <SID>closeStageDiff(3)<CR>
noremap <silent> <unique> <Plug>DiffsToggleMergeAncestor :call <SID>toggleMergeAncestorDiff()<CR>
noremap <silent> <unique> <Plug>DiffsOpenMergeAncestor :call <SID>openMergeAncestorDiff()<CR>
noremap <silent> <unique> <Plug>DiffsCloseMergeAncestor :call <SID>closeMergeAncestorDiff()<CR>
noremap <silent> <unique> <Plug>DiffsToggleMergeBranch :call <SID>toggleMergeBranchDiff()<CR>
noremap <silent> <unique> <Plug>DiffsOpenMergeBranch :call <SID>openMergeBranchDiff()<CR>
noremap <silent> <unique> <Plug>DiffsCloseMergeBranch :call <SID>closeMergeBranchDiff()<CR>
noremap <silent> <unique> <Plug>DiffsToggleMergeHead :call <SID>toggleMergeHeadDiff()<CR>
noremap <silent> <unique> <Plug>DiffsOpenMergeHead :call <SID>openMergeHeadDiff()<CR>
noremap <silent> <unique> <Plug>DiffsCloseMergeHead :call <SID>closeMergeHeadDiff()<CR>
noremap <silent> <unique> <Plug>DiffsCloseLogRevisions :call <SID>closeLogRevisionDiffs()<CR>
noremap <silent> <unique> <Plug>DiffsToggleOrigBuffer :call <SID>toggleOrigBufferDiffMode()<CR>
noremap <silent> <unique> <Plug>LogOpen :call <SID>openLog()<CR>
noremap <silent> <unique> <Plug>LogClose :call <SID>closeLog()<CR>
"noremap <silent> <unique> <Plug>Help :call <SID>help()<CR>

" Whenever any buffer window goes away, if there are no more diff windows
" remaining, then turn off diff mode in the principal buffer.
autocmd BufHidden * call s:cleanUp()

" ------------------------------------------------------------------------------
" APPLICATION FUNCTIONS

let s:allDiffNames = ['working', 'head', 'stage0', 'stage1', 'stage2', 'stage3', 'mergeAncestor', 'mergeBranch', 'mergeHead', 'revision1', 'revision2']

" Close all diff windows and the log window.  This operation should leave no
" windows visible that were created by any mappings or functions in this plugin.
func s:closeAll()
  call s:closeAllDiffs()
  call s:closeLog()
endfunc

" Close all diff windows, but leave any other special windows, eg, the log
" window, open.
func s:closeAllDiffs()
  for diffname in s:allDiffNames
    call s:closeDiff(diffname)
  endfor
endfunc

" Close the current diff window.
func s:closeCurrentDiff()
  let curbuf = bufnr("%")
  for diffname in s:allDiffNames
    let varname = "t:".diffname."DiffBuffer"
    if exists(varname) && eval(varname) == curbuf
      call s:closeDiff(diffname)
    endif
  endfor
endfunc

" After any buffer is hidden, check if any diff buffers are still visible.  If
" not, then turn off diff mode, restore wrap mode, and clean up variables.
func s:cleanUp()
  if exists('t:turnOffDiff') && t:turnOffDiff == bufnr('%')
    " This is a kludge, to work around a bug that the :diffoff! below does not turn
    " off diff mode in the buffer that is being left.
    diffoff
    unlet t:turnOffDiff
    call s:restoreWrapMode()
  endif
  if s:countDiffs() == 0
    "echo 'exists("t:origDiffBuffer") = ' . exists('t:origDiffBuffer') . ', bufnr("%") = ' . bufnr('%')
    diffoff!
    call s:restoreWrapMode()
    set noequalalways
    if exists('t:origDiffBuffer')
      let t:turnOffDiff = t:origDiffBuffer
      if !s:testLogExists()
        unlet! t:origDiffBuffer
      endif
    endif
  endif
  if !s:testLogExists()
    unlet! t:gitLogBuffer
  endif
endfunc

func s:openRevisionDiff(rev)
  if a:rev != ''
    try
      call s:openGitDiff('revision1', a:rev, a:rev)
    endtry
  endif
endfunc
func s:closeRevisionDiff(rev)
  call s:closeDiff('revision1')
endfunc

func s:toggleWorkingDiff()
  if s:isDiffOpen('working')
    try
      call s:closeWorkingDiff()
    endtry
  else
    try
      call s:openWorkingDiff()
    endtry
  endif
endfunc
func s:openWorkingDiff()
  try
    call s:openDiff('working', fnameescape(expand('%')), '', '', '')
  endtry
endfunc
func s:closeWorkingDiff()
  call s:closeDiff('working')
endfunc

func s:toggleHeadDiff()
  if s:isDiffOpen('head')
    try
      call s:closeHeadDiff()
    endtry
  else
    try
      call s:openHeadDiff()
    endtry
  endif
endfunc
func s:openHeadDiff()
  try
    call s:openGitDiff('head', 'HEAD', '')
  endtry
endfunc
func s:closeHeadDiff()
  call s:closeDiff('head')
endfunc

func s:toggleStageDiff(stage)
  let diffname = 'stage'.a:stage
  if s:isDiffOpen(diffname)
    try
      call s:closeStageDiff(a:stage)
    endtry
  else
    try
      call s:openStageDiff(a:stage)
    endtry
  endif
endfunc
func s:openStageDiff(stage)
  let diffname = 'stage'.a:stage
  try
    call s:openGitDiff(diffname, ':'.a:stage, '')
  endtry
endfunc
func s:closeStageDiff(stage)
  let diffname = 'stage'.a:stage
  call s:closeDiff(diffname)
endfunc

func s:toggleMergeAncestorDiff()
  if s:isDiffOpen('mergeAncestor')
    try
      call s:closeMergeAncestorDiff()
    endtry
  else
    try
      call s:openMergeAncestorDiff()
    endtry
  endif
endfunc
func s:openMergeAncestorDiff()
  try
    call s:openGitDiff('mergeAncestor', ':1', '')
  endtry
endfunc
func s:closeMergeAncestorDiff()
  call s:closeDiff('mergeAncestor')
endfunc

func s:toggleMergeBranchDiff()
  if s:isDiffOpen('mergeBranch')
    try
      call s:closeMergeBranchDiff()
    endtry
  else
    try
      call s:openMergeBranchDiff()
    endtry
  endif
endfunc
func s:openMergeBranchDiff()
  try
    call s:openGitDiff('mergeBranch', ':2', '')
  endtry
endfunc
func s:closeMergeBranchDiff()
  call s:closeDiff('mergeBranch')
endfunc

func s:toggleMergeHeadDiff()
  if s:isDiffOpen('mergeHead')
    try
      call s:closeMergeHeadDiff()
    endtry
  else
    try
      call s:openMergeHeadDiff()
    endtry
  endif
endfunc
func s:openMergeHeadDiff()
  try
    call s:openGitDiff('mergeHead', ':3', '')
  endtry
endfunc
func s:closeMergeHeadDiff()
  call s:closeDiff('mergeHead')
endfunc

" ------------------------------------------------------------------------------
" PRIVATE FUNCTIONS

" If the given Git output lines contain any error message, or the command
" itself returned an error exit status, then display an error message and quote
" any error message from Git, then return 1 to indicate an error
" condition.  Otherwise return 0.
func s:displayGitError(message, lines)
  let errorlines = filter(copy(a:lines), 'v:val =~ "^fatal:"')
  "let errorlines = a:lines
  if v:shell_error || len(errorlines)
    echohl ErrorMsg
    echomsg a:message
    echohl None
    if len(errorlines)
      echohl WarningMsg
      echomsg join(errorlines, "\n")
      echohl None
    endif
    return 1
  endif
  return 0
endfunc

" Return much information about a specific commit.
func s:getGitRevisionInfo(refspec)
  let info = {}
  let lines = split(system('cd '.shellescape(expand('%:h')).' >/dev/null && git log -1 --format="%h%n%H%n%ai%n%an%n%ae%nSUMMARY%n%s%nBODY%n%b" '.shellescape(a:refspec)), "\n")
  if !s:displayGitError('Could not get information for refspec "'.a:refspec.'"', lines)
    if len(lines) == 0
      echohl ErrorMsg
      echomsg 'Revision "'.a:refspec.'" does not exist'
      echohl None
    elseif len(lines) < 7 || lines[5] != 'SUMMARY' || lines[7] != 'BODY'
      echohl ErrorMsg
      echomsg 'Malformed output from "git log":'
      echohl None
      for line in lines
        echomsg line
      endfor
    else
      let info.ahash = remove(lines, 0)
      let info.hash = remove(lines, 0)
      let info.date = remove(lines, 0)
      let info.author = remove(lines, 0)
      let info.email = remove(lines, 0)
      call remove(lines, 0) " SUMMARY
      let info.summary = remove(lines, 0)
      call remove(lines, 0) " BODY
      let info.body = join(lines, "\n")
    endif
  endif
  return info
endfunc

func s:getGitStageHash(stage)
  let lines = split(system('cd '.shellescape(expand('%:h')).' >/dev/null && git ls-files --unmerged -- '.shellescape('./'.expand('%:t'))), "\n")
  if !s:displayGitError('Could not list unmerged files', lines)
    for line in lines
      let parts = split(line, "\t")
      let words = split(parts[0], ' ')
      if len(words) != 3
        echohl ErrorMsg
        echomsg 'Malformed line from "git ls-files --unmerged":'
        echohl None
        echomsg line
      elseif words[2] == a:stage
        return words[1]
      endif
    endfor
  endif
  return ''
endfunc

" Open a new diff window containing the given Git commit.
"
" Param: diffname The symbolic name of the new diff buffer
" Param: refspec The Git commit to fetch
" Param: label If set, replaces diffName as the displayed label
"
func s:openGitDiff(diffname, refspec, label)
  let ref = a:refspec.':./'.expand('%:t')
  let lines = split(system('cd '.shellescape(expand('%:h')).' >/dev/null && git show '.shellescape(ref).' 2>&1 1>/dev/null'), "\n")
  if !s:displayGitError('Could not show "'.ref.'"', lines)
    if len(lines) != 0
      echohl ErrorMsg
      echomsg 'Errors from "git show":'
      echohl None
      for line in lines
        echomsg line
      endfor
    else
      let annotation = a:refspec.':'
      let hash = ""
      if a:refspec[0] != ':'
        let info = s:getGitRevisionInfo(a:refspec)
        if len(info)
          let annotation = info.ahash.' '.info.date
          let hash = info.hash
        endif
      endif
      try
        call s:openDiff(a:diffname, '!cd '.shellescape(expand('%:h')).' >/dev/null && git show '.shellescape(ref), hash, annotation, a:label)
      endtry
    endif
  endif
endfunc

" Open a new diff window containing the contents of the given file, which is
" fetched using the :read command, so can be specified using '!' notation to
" capture the output of a command.
"
" Param: diffname The symbolic name of the new diff buffer
" Param: readArg The argument passed to :read to fill the new buffer
" Param: commit Stored in the buffer's b:commit variable
" Param: annotation Extra information appended the buffer's label
" Param: label If set, replaces diffName as the displayed label
"
func s:openDiff(diffname, readArg, commit, annotation, label)
  "echo "openDiff(".string(a:diffname).', '.string(a:readArg).', '.string(a:commit).', '.string(a:annotation).', '.string(a:label).')'
  if count(s:allDiffNames, a:diffname) == 0
    echoerr 'Invalid diffname: '.a:diffname
  else
    let varname = "t:".a:diffname."DiffBuffer"
    if exists(varname)
      diffupdate
      call s:setBufferWrapMode()
    else
      if s:countDiffs() == 4
        echoerr "Cannot have more than four diffs at once"
      endif
      " put focus in the window containing the original file
      call s:gotoOrigWindow()
      " only proceed for normal buffers
      if &buftype == ''
        let t:origDiffBuffer = bufnr("%")
        " if there are no diff buffers in existence, save the wrap mode of the
        " original file buffer and the global wrap mode too, so that we can restore
        " them after :diffoff
        call s:recordWrapMode()
        " turn off wrap mode in the original file buffer
        call s:setBufferWrapMode(0)
        let ft = &filetype
        let filename = expand("%")
        let filedir = expand('%:h')
        set equalalways
        set eadirection=hor
        vnew
        let b:fileDir = filedir
        let b:commit = a:commit
        " turn off wrap mode in the new diff buffer
        call s:setBufferWrapMode(0)
        exe 'let' varname "=" bufnr("%")
        let displayName = filename
        if a:annotation != ''
          let displayName .= ' '.a:annotation
        endif
        let displayName .= ' ' . ((a:label != '') ? a:label : a:diffname)
        silent exe 'file' fnameescape(displayName)
        silent exe '1read' a:readArg
        1d
        let &l:filetype = ft
        setlocal buftype=nofile
        setlocal nomodifiable
        setlocal noswapfile
        setlocal bufhidden=delete
        setlocal scrollbind
        try
          diffthis
        catch /Vim(diffthis):E96:.*/ " Diffing more than 4 buffers
          exe 'unlet' varname
          if s:countDiffs() == 0
            unlet t:origDiffBuffer
          endif
          wincmd c
          call s:restoreWrapMode()
          echoerr substitute(v:exception, '^Vim(\a\+):', '', '')
        endtry
        augroup GitDiff
          exe 'autocmd BufDelete <buffer> call s:cleanUpDiff('.string(a:diffname).')'
        augroup END
        wincmd x
        setlocal scrollbind
        diffthis
        augroup GitDiff
          autocmd BufWinLeave <buffer> nested call s:closeAll()
          autocmd BufWinEnter <buffer> call s:cleanUp()
        augroup END
        diffupdate
      endif
    endif
  endif
endfunc

" Put the focus in the original diff file window and return 1 if it exists.
" Otherwise return 0.
func s:gotoOrigWindow()
  if exists('t:origDiffBuffer')
    exe bufwinnr(t:origDiffBuffer) 'wincmd w'
    return 1
  endif
  return 0
endfunc

func s:setOrigBufferDiffMode(flag)
  if s:gotoOrigWindow()
    if a:flag
      diffthis
    else
      diffoff
      setlocal scrollbind
    endif
    call s:setBufferWrapMode(0)
    wincmd p
  endif
endfunc

func s:toggleOrigBufferDiffMode()
  echo "wah"
  if exists('t:origDiffBuffer')
    let diff = getwinvar(bufwinnr(t:origDiffBuffer), '&diff')
    if diff
      call s:setOrigBufferDiffMode(0)
    elseif s:countDiffs() != 0
      call s:setOrigBufferDiffMode(1)
    endif
  endif
endfunc

func s:closeDiff(diffname)
  let varname = 't:'.a:diffname.'DiffBuffer'
  if exists(varname)
    " delete the buffer and let the BufDelete autocmd do the clean-up
    exe 'exe' varname '"bdelete"'
  endif
endfunc

func s:isDiffOpen(diffname)
  let varname = 't:'.a:diffname.'DiffBuffer'
  return exists(varname)
endfunc

func s:cleanUpDiff(diffname)
  let varname = 't:'.a:diffname.'DiffBuffer'
  exe 'unlet!' varname
  call s:cleanUp()
endfunc

func s:countDiffs()
  let n = 0
  for diffname in s:allDiffNames
    let varname = 't:'.diffname.'DiffBuffer'
    if exists(varname)
      let n += 1
    endif
  endfor
  " If any diffs are present, count the original file window too.
  if n != 0
    let n += 1
  endif
  return n
endfunc

" Return the current working directory in which commands relating to the
" current buffer's file should be executed.
func s:getFileCwd()
  if exists('b:fileDir')
    return b:fileDir
  else
    return expand('%:h')
  endif
endfunc

" ------------------------------------------------------------------------------
" Git log navigation.

func s:openLog()
  " close the log window if it already exists
  call s:closeLog()
  " first switch to the original diff buffer, if there is one, otherwise operate
  " on the current buffer
  if exists("t:origDiffBuffer")
    exe t:origDiffBuffer 'buffer'
  endif
  " only proceed for normal buffers
  if &buftype == ''
    " figure out the file name and number of the current buffer
    let t:origDiffBuffer = bufnr("%")
    let filepath = expand('%')
    let filedir = expand('%:h')
    " save the current wrap modes to restore them later
    call s:recordWrapMode()
    " open the log navigation window
    botright 10 new
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=delete
    let t:gitLogBuffer = bufnr('%')
    let b:fileDir = filedir
    " give the buffer a helpful name
    silent exe 'file' fnameescape('log '.filepath)
    " read the Git log into it -- all ancestors of the current working revision
    silent exe "$read !git log --graph --date-order --format='format:\\%h|\\%ai|\\%an|\\%s' -- ".shellescape(filepath)
    if s:displayGitError('Cannot read Git log', getline(1,'$'))
      call s:closeLog()
      return
    endif
    1d
    " justify the first column (graph number)
    let w = max([4, max(map(getline(1,'$'), "len(substitute(v:val, '\\x.*$', '', ''))"))])
    silent g/\x\{6,\}|/s/^\X*/\=submatch(0).repeat(' ', w-len(submatch(0)))/
    " remove seconds from the date column
    silent g/^\(\X*\x\{6,\}|\)\(\d\d\d\d-\d\d-\d\d \d\d:\d\d\):\d\d/s//\1\2/
    " remove timezone from the date column
    "silent g/^\(\%([^|]*|\)\{1\}\)\([^|]*\) +\d\d\d\d|/s//\1\2|/
    " justify/truncate the username column
    silent g/^\(\X*\x\{6,\}|[^|]*|\)\([^|]*\)/s//\=submatch(1).strpart(submatch(2),0,16).repeat(' ', 16-len(submatch(2)))/
    " go the first line (most recent revision)
    1
    " set the buffer properties
    call s:setBufferWrapMode(0)
    setlocal nomodifiable
    setlocal filetype=gitlogcompact
    set syntax=gitlogcompact
    setlocal winfixheight
    " Set up some useful key mappings.
    " The crap after the <CR> is a kludge to force Vim to synchronise the
    " scrolling of the diff windows, which it does not do correctly
    nnoremap <buffer> <silent> <CR> 10_:call <SID>openLogRevisionDiffs(0)<CR>0kj
    vnoremap <buffer> <silent> <CR> 10_:<C-U>call <SID>openLogRevisionDiffs(1)<CR>0kj
    nnoremap <buffer> <silent> - 5-
    nnoremap <buffer> <silent> + 5+
    nnoremap <buffer> <silent> _ _
    nnoremap <buffer> <silent> = 10_
    nnoremap <buffer> <silent> m :call <SID>gotoOrigWindow()<CR>
    nnoremap <buffer> <silent> q :call <SID>closeLog()<CR>
    " housekeeping for buffer close
    augroup GitDiff
      autocmd BufDelete <buffer> call s:cleanUp()
    augroup END
  endif
endfunc

" Return 1 if the current working directory is a merge (has any staged files).
func s:isWorkingMerge()
  let nfiles = system('cd '.shellescape(expand('%:h'))." >/dev/null && git ls-files --stage | awk 'BEGIN { nfiles = 0} $3 != 0 { ++nfiles } END { print nfiles }'")
  if v:shell_error
    echohl ErrorMsg
    echomsg 'Could not count Git staged files'
    echohl None
    return 0
  endif
  if str2nr(nfiles) != 0
    return 1
  endif
  return 0
endfunc

" Return 1 if the log buffer exists.
func s:testLogExists()
  return exists('t:gitLogBuffer') && buflisted(t:gitLogBuffer)
endfunc

" Put the focus in the log buffer window and return 1 if it exists.  Otherwise
" return 0.
func s:gotoLogWindow()
  if exists('t:gitLogBuffer')
    exe bufwinnr(t:gitLogBuffer) 'wincmd w'
    return 1
  endif
  return 0
endfunc

func s:closeLog()
  if s:testLogExists()
    " delete the buffer and let the BufDelete autocmd do the clean-up
    exe t:gitLogBuffer 'bdelete'
  endif
  unlet! t:gitLogBuffer
endfunc

func s:help()
  echomsg "Not implemented"
endfunc

func s:openLogRevisionDiffs(visual)
  call s:closeLogRevisionDiff(1)
  call s:closeLogRevisionDiff(2)
  if a:visual
    let rev1 = matchstr(getline(line("'>")), '\x\{6,\}').'^' " earliest
    let rev2 = matchstr(getline(line("'<")), '\x\{6,\}') " latest
    try
      call s:openLogRevisionDiff(1, rev1)
      call s:openLogRevisionDiff(2, rev2)
    endtry
  else
    let rev = matchstr(getline('.'), '\x\{6,\}')
    try
      call s:openLogRevisionDiff(1, rev)
    endtry
  endif
endfunc

func s:openLogRevisionDiff(n, rev)
  let bufname = 'revision'.a:n
  if a:rev != '' && exists('t:origDiffBuffer')
    try
      call s:gotoOrigWindow()
      call s:openGitDiff(bufname, a:rev, a:rev)
    finally
      " return the focus to the log window
      if s:gotoLogWindow()
        call s:setBufferWrapMode(0)
      endif
    endtry
  endif
endfunc

func s:closeLogRevisionDiff(n)
  let bufname = 'revision'.a:n
  call s:closeDiff(bufname)
endfunc

func s:closeLogRevisionDiffs()
  call s:closeLogRevisionDiff(1)
  call s:closeLogRevisionDiff(2)
endfunc

" Record the global wrap mode and the wrap mode of the current buffer.
func s:recordWrapMode()
  if !exists('g:preDiffWrapMode')
    let g:preDiffWrapMode = &g:wrap
  endif
  if !exists('b:preDiffWrapMode')
    let b:preDiffWrapMode = &l:wrap
  endif
endfunc

" Restore the global wrap mode and the wrap mode of the current buffer.
" Does not touch other buffers, because this can be called in a BufUnload
" or BufDelete autocmd, in which changing the current buffer is lethal.
func s:restoreWrapMode()
  if exists('g:preDiffWrapMode')
    call s:setGlobalWrapMode(g:preDiffWrapMode)
    unlet g:preDiffWrapMode
  else
    call s:setGlobalWrapMode()
  endif
  if exists('b:preDiffWrapMode')
    call s:setBufferWrapMode(b:preDiffWrapMode)
    unlet b:preDiffWrapMode
  else
    call s:setBufferWrapMode()
  endif
endfunc

" Use this function instead of :setglobal [no]wrap.  There are three use cases:
"       :call s:setGlobalWrapMode(0) equivalent to :setglobal nowrap
"       :call s:setGlobalWrapMode(1) equivalent to :setglobal wrap
"       :call s:setGlobalWrapMode() equivalent to most recent of the above
func s:setGlobalWrapMode(...)
  if a:0
    let t:wrapMode = a:1
  endif
  if exists('g:wrapMode')
    let &g:wrap = t:wrapMode
  endif
endfunc

" Use this function instead of :setlocal [no]wrap.  There are three use cases:
"       :call s:setBufferWrapMode(0) equivalent to :setlocal nowrap
"       :call s:setBufferWrapMode(1) equivalent to :setlocal wrap
"       :call s:setBufferWrapMode() equivalent to most recent of the above
func s:setBufferWrapMode(...)
  if a:0
    let b:wrapMode = a:1
  endif
  if exists('b:wrapMode')
    let &l:wrap = b:wrapMode
  endif
endfunc

" ------------------------------------------------------------------------------
" Standard Vim plugin boilerplate.
let &cpo= s:keepcpo
unlet s:keepcpo
