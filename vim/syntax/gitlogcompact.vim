" Vim syntax file
" Last Change: 28 May 2012
" Maintainer: Andrew Bettison <andrewb@zip.com.au>
" Author: Andrew Bettison <andrewb@zip.com.au>
" Copyright: 2012 Andrew Bettison
" License: GPL2

" Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

syn match	gitclGraph	"^\X*"						nextgroup=gitclHash contains=gitclGraphStar
syn match	gitclGraphStar	"\*"						contained
syn match	gitclHash	"\x\+"						nextgroup=gitclSep2 contained
syn match	gitclSep2	"|"						nextgroup=gitclDate contained
syn match	gitclDate	"\d\d\d\d-\d\d-\d\d \d\d:\d\d\(:\d\d\)\?\( [+-]\d\d\d\d\)"	nextgroup=gitclSep3 contained
syn match	gitclSep3	"|"						nextgroup=gitclAuthor contained
syn match	gitclAuthor	"[^|]*"						nextgroup=gitclSep4 contained
syn match	gitclSep4	"|"						nextgroup=gitclSubject contained
syn match	gitclSubject	".*$"						contained

" The default highlighting.
hi def link gitclGraph		Constant
hi def link gitclGraphStar	Statement
hi def link gitclHash		Identifier
hi def link gitclDate		Special
hi def link gitclAuthor		Type
hi def link gitclSubject	Comment

let b:current_syntax = "gitlogcompact"

" vim: et sts=2 sw=2
