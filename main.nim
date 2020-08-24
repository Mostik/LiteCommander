import os, osproc, terminal

let errC = execCmd("clear")
echo ""

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
  let errC = execCmd("clear")
  echo ""
  output_all()
  setCursorPos(0,0)
  var input_command = readLine(stdin)