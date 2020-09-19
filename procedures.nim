import os, osproc, terminal, re, sequtils, strutils
proc bgRed*(s: string): string {.procvar.} = "\e[41m" & s & "\e[0m"

proc clearCmd*(line : bool) =
  if line == true:
    let errC = execCmd("clear")
    echo ""
  else:
    let errC = execCmd("clear")

proc fileSize*(file: string): string =
  var filesize: BiggestInt = getFileSize(file)
  if (int(filesize) / int(1024) >= 1):
    if (int(filesize) / int(1024*1024) >= 1):
      if (int(filesize) / int(1024*1024*1024) >= 1):
        return $(int(int(filesize) / int(1024*1024*1024))) & "Gb"
      else:
        return $(int(int(filesize) / int(1024*1024))) & "Mb"
    else:
      return $(int((int(filesize) / int(1024)))) & "Kb"
  else:
    return $filesize & "B"

proc getFiles*() : seq[string] =
  var files : seq[string]
  for file in walkFiles("*"):
    var file = file & " - " & fileSize(file)
    files.add(file)
  result = files

proc getDirs*() : seq[string] =
  var dirs : seq[string]
  for dir in walkDirs("*"):
    var dir = "[" & dir & "]"
    dirs.add(dir)
  result = dirs

proc thispath*(path : string) : string = 
  var newpath : string
  newpath = replace(path, "./", getCurrentDir() & "/")
  result = newpath

proc uppath*(path : string) : string = 
  var arr, newarr: seq[string]
  var newpath : string
  for word in split(path, re"[/]+"):
    arr.add(word)

  newarr = arr.filterIt(it != "")
  if newarr.len > 0:
    newarr.delete(newarr.len-1, newarr.len-1)
  else:
    newarr.delete(newarr.len, newarr.len)

  for word in newarr:
    newpath = newpath & "/" & word
  
  newpath = newpath & "/"
  result = newpath

proc height*(): int  =
  result = terminalHeight()-3
proc width*(): int  =
  result = terminalWidth()

var logpath* = ""

proc logclear*() =
  logpath = getCurrentDir()
  var file = open( logpath & "/test.txt", fmWrite)
  file.writeLine("")
  file.close()

proc loginfo*(str : auto) =
  var file = open(logpath & "/test.txt", fmReadWriteExisting)
  discard file.readAll()
  file.writeLine(str)
  file.close()
