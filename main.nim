import os, osproc, terminal, re, strutils
import procedures
#=======================================
var str : string = ""
logclear()
type
  move = enum
    no, up, down, left, right
  PageData = object
    items : seq[string]
    color_item : int
    begin_item : int
    dir : string
    height : int
    width : int

var pd = PageData(items: @[], color_item: 0, begin_item: 0, dir: getCurrentDir(), height : height(), width : width())

proc move_page(move : move): string {.discardable.}=
  if pd.items.len > 0:
    case move
    of no:
      pd.items[pd.color_item] = bgRed(pd.items[pd.color_item])
    of up:
      if pd.color_item > pd.begin_item:
        pd.items[pd.color_item - 1] = bgRed(pd.items[pd.color_item - 1])
        pd.color_item = pd.color_item - 1
      else:
        if pd.color_item > 0:
          pd.color_item = pd.color_item - 1
          pd.begin_item = pd.begin_item - 1
          pd.height = pd.height - 1
          pd.items[pd.color_item] = bgRed(pd.items[pd.color_item])
        else:
          pd.color_item = 0
          pd.items[pd.color_item] = bgRed(pd.items[pd.color_item])
    of down:
        if pd.color_item < pd.items.len-1:
          if pd.color_item < pd.height-1:
            pd.items[pd.color_item + 1] = bgRed(pd.items[pd.color_item + 1])
            pd.color_item = pd.color_item + 1
          else:
            pd.begin_item = pd.begin_item + 1
            pd.height = pd.height + 1
            pd.items[pd.color_item + 1] = bgRed(pd.items[pd.color_item + 1])
            pd.color_item = pd.color_item + 1
        else:
          pd.color_item = pd.items.len-1
          pd.items[pd.color_item] = bgRed(pd.items[pd.color_item])
    of right:
      if pd.items[pd.color_item] =~ re"""\[(.*)\]""":
        echo getCurrentDir() & "/" & matches[0]
        try:
          pd.color_item = 0
          var key = "./" & matches[0]
          return key
        except:
          discard
      else:
        discard
    of left:
      try:
        pd.color_item = 0
        var key = "../"
        return key
      except:
        discard
  else:
    if move == left:
      try:
        pd.color_item = 0
        var key = "../"
        return key
      except:
        discard

proc output_all(move: move): string {.discardable.}=
  pd.items = @[]

  if pd.dir != getCurrentDir():
    pd.begin_item = 0
    pd.height = height()-1
    pd.dir = getCurrentDir()
  echo getCurrentDir()
  for dir in getDirs():
    pd.items.add(dir)
  for file in getFiles():
    pd.items.add(file)

  if pd.items.len > height():
    result = move_page(move)
    for item in pd.items[pd.begin_item..pd.height-1]:
      echo item
  else:
    result = move_page(move)
    for item in pd.items:
      echo item

proc cloust(empty_line: bool, output_all_move: move, setcursorposX: int, setcursorposY: int ) =
  clearCmd(empty_line)
  output_all(output_all_move)
  setCursorPos(setcursorposX, setcursorposY)

proc getLine(): string =
  while true:
    setStyle({styleBright})
    setForegroundColor(fgYellow)
    var c = getch()
    if c == '\e':
      c = getch()
      if c == '[':
        case getch()
        of 'A':
          cloust(true, up, 1,0)
        of 'D':
          clearCmd(true)
          var newpath: string = output_all(left)
          return newpath
        of 'B':
          cloust(true, down, 1,0)
        of 'C':
          clearCmd(true)
          var newpath: string = output_all(right)
          return newpath
        else:
          setStyle({styleBright})
          setForegroundColor(fgYellow)
          write(stdout, c)
          str = str & c
      else: 
        setStyle({styleBright})
        setForegroundColor(fgYellow)
        write(stdout, c)
        str = str & c
    elif c == '\x7F':
      if str.len > 1:
        str.delete(str.len-1, str.len-1)
        cloust(true, no, 1,0)
        setStyle({styleBright})
        setForegroundColor(fgYellow)
        write(stdout, str)
      else:
        str = ""
        cloust(true, no, 1,0)
        setStyle({styleBright})
        setForegroundColor(fgYellow)
        write(stdout, str)
    elif c == '\c':
      var answer: string = str
      str = ""
      return answer
    else: 
      setStyle({styleBright})
      setForegroundColor(fgYellow)
      write(stdout, c)
      str = str & c

proc command(input_command : string) =
  if input_command =~ re"""[#]([A-Za-z~]+)\s+([A-Za-z~0-9]+)""":
    discard
  elif input_command =~ re"""[#]([A-Za-z~]+)""":
    if matches[0] == "quit":
      clearCmd(false)
      quit(0)
  elif input_command =~ re"""[$](.*)""":
    var errorcode : int = execCmd(matches[0])
    pd.begin_item = 0
    pd.height = height()-1
    pd.dir = getCurrentDir()
    pd.color_item = 0
  else:
    if input_command =~ re"""^./(.*)""":
      try:
        setCurrentDir(thispath(input_command))
        pd.color_item = 0
      except:
        discard
    elif input_command == "../" or input_command == "..":
      setCurrentDir(uppath(getCurrentDir()))
      pd.color_item = 0
    elif input_command == "~":
      setCurrentDir(getHomeDir())
      pd.color_item = 0
    else:
      discard
#=======================================

while true:
  cloust(true, no, 1,0)
  var input_command = getLine()
  command(input_command)
