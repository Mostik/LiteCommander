import os, osproc, terminal

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
  var all = getDirs() & getFiles()
  for oll in all:
    echo oll

while true:
  clearCmd(true)
  output_all()
  setCursorPos(0,0)
  var input_command = readLine(stdin)

  if input_command == "quit":
    clearCmd(false)
    quit(0)