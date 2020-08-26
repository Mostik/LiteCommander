import os, osproc, terminal, re
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
  var all = getCurrentDir() & getDirs() & getFiles()
  for oll in all:
    echo oll

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
    else:
      try:
        setCurrentDir(input_command)
      except:
        discard
  else:
    echo "Error)"
    sleep(3000)

#=======================================

while true:
  clearCmd(true)
  output_all()
  setCursorPos(0,0)
  var input_command = readLine(stdin)
  command(input_command)

  