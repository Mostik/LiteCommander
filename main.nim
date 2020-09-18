import os, osproc, terminal, re, sequtils, strutils
import procedures
#=======================================
var str : string = ""
var color_item: int = 0

type
  move = enum
    no, up, down, left, right

proc output_all(move: move): string {.discardable.}=
  var items : seq[string]
  echo getCurrentDir()
  for dir in getDirs():
    setForegroundColor(fgYellow)
    items.add(dir)
    resetAttributes()
  for file in getFiles():
    items.add(file)

  if items.len > 0:
    if move == no:
      items[color_item] = bgRed(items[color_item])
    elif move == up:
      if true:
        if color_item > 0:
          items[color_item - 1] = bgRed(items[color_item - 1])
          color_item = color_item - 1
        else:
          items[color_item] = bgRed(items[color_item])
      else:
        discard
    elif move == down:
      if true:
        if color_item < items.len-1:
          items[color_item + 1] = bgRed(items[color_item + 1])
          color_item = color_item + 1
        else:
          items[color_item] = bgRed(items[color_item])
      else:
        discard
    elif move == right:
      if items[color_item] =~ re"""\[(.*)\]""":
        echo getCurrentDir() & "/" & matches[0]
        try:
          color_item = 0
          var key = "./" & matches[0]
          return key
        except:
          discard
      else:
        discard
    elif move == left:
      try:
        color_item = 0
        var key = "../"
        return key
      except:
        discard
    else:
      discard
  else:
    if move == left:
      try:
        color_item = 0
        var key = "../"
        return key
      except:
        discard

  for item in items:
    echo item

proc cloust(empty_line: bool, output_all_move: move, setcursorposX: int, setcursorposY: int ) =
  clearCmd(empty_line)
  output_all(output_all_move)
  setCursorPos(setcursorposX, setcursorposY)

proc getLine(): string =
  while true:
    var c = getch()
    if c == '\e':
      c = getch()
      if c == '[':
        case getch()
        of 'A':
          cloust(true, up, 0,0)
        of 'D':
          clearCmd(true)
          var newpath: string = output_all(left)
          return newpath
        of 'B':
          cloust(true, down, 0,0)
        of 'C':
          clearCmd(true)
          var newpath: string = output_all(right)
          return newpath
        else:
          write(stdout, c)
          str = str & c
      else: 
        write(stdout, c)
        str = str & c
    elif c == '\x7F':
      if str.len > 1:
        str.delete(str.len-1, str.len-1)
        cloust(true, no, 0,0)
        write(stdout, str)
      else:
        str = ""
        cloust(true, no, 0,0)
        write(stdout, str)
    elif c == '\c':
      var answer: string = str
      str = ""
      return answer
    else: 
      write(stdout, c)
      str = str & c

proc command(input_command : string) =
  if input_command =~ re"""[#]([A-Za-z~]+)\s+([A-Za-z~]+)""":
    discard
  elif input_command =~ re"""[#]([A-Za-z~]+)""":
    if matches[0] == "quit":
      clearCmd(false)
      quit(0)
  elif input_command =~ re"""[$](.*)""":
    var errorcode : int = execCmd(matches[0])
  else:
    if input_command =~ re"""^./(.*)""":
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
  cloust(true, no, 0,0)
  var input_command = getLine()
  command(input_command)
