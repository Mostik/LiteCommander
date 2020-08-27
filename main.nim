import os, osproc, terminal, re, sequtils
#=======================================
proc clearCmd(line : bool) =
  if line == true:
    let errC = execCmd("clear")
    echo ""
  else:
    let errC = execCmd("clear")

proc getFiles() : seq[string] =
  var files : seq[string]
  for file in walkFiles("*"):
    var file = file & " - " & $getFileSize(file)
    files.add(file)
  result = files

proc getDirs() : seq[string] =
  var dirs : seq[string]
  for dir in walkDirs("*"):
    var dir = "[" & dir & "]"
    dirs.add(dir)
  result = dirs

proc output_all() =
  echo getCurrentDir()
  for dir in getDirs():
    setForegroundColor(fgYellow)
    echo dirgetHomeDir()
    echo file

proc uppath(path : string) : string = 
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

proc command(input_command : string) =
  var tokenTWO = re"""[/]([A-Za-z~]+)\s+([A-Za-z~]+)"""
  var tokenONE = re"""[/]([A-Za-z~]+)"""
  if input_command =~ tokenTWO:
    if matches[0] == "this":
      try:
        echo "CurrentDir ", getCurrentDir()
        setCurrentDir(getCurrentDir() & '/' & matches[1])
      except:
        discard
    elif matches[0] == "~":
      setCurrentDir(getHomeDir())
    else:
      discard
  elif input_command =~ tokenONE:
    if matches[0] == "quit":
      clearCmd(false)
      quit(0)
    elif matches[0] == "~":
      setCurrentDir(getHomeDir())
    elif matches[0] == "up":
      setCurrentDir(uppath(getCurrentDir()))
    else:
      try:
        setCurrentDir(input_command)
      except:
        discard
  else:
    discard

#=======================================

while true:
  clearCmd(true)
  output_all()
  setCursorPos(0,0)
  var input_command = readLine(stdin)
  command(input_command)

  