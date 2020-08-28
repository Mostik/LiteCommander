import os, osproc, terminal, re, sequtils, strutils
#=======================================
var str : string = ""

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
    echo dir
    resetAttributes()
  for file in getFiles():
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

proc thispath(path : string) : string = 
  var newpath : string
  newpath = replace(path, "./", getCurrentDir() & "/")
  result = newpath

proc getLine(): string =
  while true:
    var c = getch()
    if c == '\e':
      c = getch()
      if c == '[':
        case getch()
        of 'A':
          discard
        of 'D':
          discard
        of 'B':
          discard
        of 'C':
          discard
        else:
          write(stdout, c)
          str = str & c
      else: 
        write(stdout, c)
        str = str & c
    elif c == '\x7F':
      if str.len > 1:
        str.delete(str.len-1, str.len-1)
        clearCmd(true)
        output_all()
        setCursorPos(0,0)
        write(stdout, str)
      else:
        str = ""
        clearCmd(true)
        output_all()
        setCursorPos(0,0)
        write(stdout, str)
    elif c == '\c':
      var answer: string = str
      str = ""
      return answer
    else: 
      write(stdout, c)
      str = str & c


proc command(input_command : string) =
  var tokenTWO = re"""[#]([A-Za-z~]+)\s+([A-Za-z~]+)"""
  var tokenONE = re"""[#]([A-Za-z~]+)"""
  var cmdCommand = re"""[$](.*)"""
  if input_command =~ tokenTWO:
    discard
  elif input_command =~ tokenONE:
    if matches[0] == "quit":
      clearCmd(false)
      quit(0)
  elif input_command =~ cmdCommand:
    var errorcode : int = execCmd(matches[0])
  else:
    if input_command[0..1] == "./":
        try:
          setCurrentDir(thispath(input_command))
        except:
          discard
    elif input_command == "../" or input_command == "..":
      setCurrentDir(uppath(getCurrentDir()))
    elif input_command == "~":
      setCurrentDir(getHomeDir())
    else:
      discard

#=======================================

while true:
  clearCmd(true)
  output_all()
  setCursorPos(0,0)
  var input_command = getLine()
  command(input_command)

  