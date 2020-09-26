import os, osproc, terminal, re, sequtils, strutils, times, unicode

var logpath* = ""
var max_size_name : int = 0
var max_size_mem : int = 0

proc bgRed*(s: string): string {.procvar.} = "\e[41m" & s & "\e[0m"
proc clearCmd*(line : bool) =
  if line == true:
    let errC = execCmd("clear")
    setStyle({styleBright})
    setForegroundColor(fgGreen)
    echo ">"
    resetAttributes()
  else:
    let errC = execCmd("clear")

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

proc logClear*() =
  logpath = getCurrentDir()
  var file = open( logpath & "/test.txt", fmWrite)
  file.writeLine("")
  file.close()

proc logInfo*(str : auto) =
  var file = open(logpath & "/test.txt", fmReadWriteExisting)
  discard file.readAll()
  file.writeLine(str)
  file.close()

proc logFileInfo(file : string) =
  logInfo(getFileInfo(file))

proc getDirs*() : seq[string] =
  var dirs : seq[string]
  for dir in walkDirs("*"):
    var dir = "[" & dir & "]"
    dirs.add(dir)
  result = dirs

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

proc fileData*(file: string): string =
  var time = getLastAccessTime(file)
  result = format(time,"dd-MM-yy HH:mm",local())

proc fileInfo*(file : string) : string =
  var size = fileSize(file).len
  var thissize = fileSize(file)
  var thisfile = file
  if file.runeLen < max_size_name:
    for k in countup(1, max_size_name-file.runeLen):
      thisfile = thisfile & " "
  if size < max_size_mem:
    for k in countup(1, max_size_mem-fileSize(file).len):
      thissize = thissize & " "
  var file = thisfile & " | " & thissize & " | " & $fileData(file)
  result = file

proc getFiles*() : seq[string] =
  max_size_name = 0
  max_size_mem = 0
  for file in walkFiles("*"):
    if file.len > max_size_name : max_size_name = file.len
  for file in walkFiles("*"):
    if fileSize(file).len > max_size_mem : max_size_mem = fileSize(file).len
  var files : seq[string]

  for file in walkFiles("*"):
    files.add(file)
  result = files
