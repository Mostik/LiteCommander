import os

var files : seq[string]
for file in walkFiles("*"):
  var file = file & " - " & $getFileSize(file)
  files.add(file)
  #echo file
echo ""

var dirs : seq[string]
for dir in walkDirs("*"):
  var dir = "[" & dir & "]"
  dirs.add(dir)
  #echo dir
echo ""

var all = dirs & files

for oll in all:
  echo oll