import os, osproc, terminal, re, sequtils, strutils
#=======================================
var str : string = ""
var color_item: int = 0
proc bgRed(s: string): string {.procvar.} = "\e[41m" & s & "\e[0m"

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

proc thispath(path : string) : string = 
  var newpath : string
  newpath = replace(path, "./", getCurrentDir() & "/")
  result = newpath

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

proc output_all(move: int): string {.discardable.}=
  var items : seq[string]
  echo getCurrentDir()
  for dir in getDirs():
    setForegroundColor(fgYellow)
    items.add(dir)
    resetAttributes()
  for file in getFiles():
    items.add(file)
  if items.len > 0:
    if move == 0:
      items[color_item] = bgRed(items[color_item])
    elif move == 1:
      if true:
        if color_item > 0:
          items[color_item] = items[color_item]
          items[color_item - 1] = bgRed(items[color_item - 1])
          color_item = color_item - 1
        else:
          items[color_item] = bgRed(items[color_item])
      else:
        discard
    elif move == 2:
      if true:
        if color_item < items.len-1:
          items[color_item] = items[color_item]
          items[color_item + 1] = bgRed(items[color_item + 1])
          color_item = color_item + 1
        else:
          items[color_item] = bgRed(items[color_item])
      else:
        discard
    elif move == 3:
      if items[color_item] =~ re"""\[(.*)\]""":
        echo getCurrentDir() & "/" & matches[0]
        try:
          #command("./" & matches[0])
          color_item = 0
          var key = "./" & matches[0]
          return key
        except:
          discard
      else:
        discard
    elif move == 4:
      try:
        color_item = 0
        var key = "../"
        return key
      except:
        discard
    else:
      discard
  else:
    if move == 4:
      try:
        color_item = 0
        var key = "../"
        return key
      except:
        discard

 
  for item in items:
    echo item

proc getLine(): string =
  while true:
    var c = getch()
    if c == '\e':
      c = getch()
      if c == '[':
        case getch()
        of 'A':
          clearCmd(true)
          output_all(1)
          setCursorPos(0,0)
        of 'D':
          clearCmd(true)
          var newpath: string = output_all(4)
          return newpath
        of 'B':
          clearCmd(true)
          output_all(2)
          setCursorPos(0,0)
        of 'C':
          clearCmd(true)
          var newpath: string = output_all(3)
          return newpath
          #setCursorPos(0,0)
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
        output_all(0)
        setCursorPos(0,0)
        write(stdout, str)
      else:
        str = ""
        clearCmd(true)
        output_all(0)
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
          color_item = 0
        except:
          discard
    elif input_command == "../" or input_command == "..":
      setCurrentDir(uppath(getCurrentDir()))
      color_item = 0
    elif input_command == "~":
      setCurrentDir(getHomeDir())
      color_item = 0
    else:
      discard
#=======================================

while true:
  clearCmd(true)
  output_all(0)
  setCursorPos(0,0)
  var input_command = getLine()
  command(input_command)

  