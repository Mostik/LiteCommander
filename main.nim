import os

var alls : seq[string]
for all in walkPattern("*"):
  alls.add(all)
echo alls
echo ""
var files : seq[string]
for file in walkFiles("*"):
  files.add(file)
  #echo file
echo ""

var dirs : seq[string]
for dir in walkDirs("*"):
  dirs.add(dir)
  #echo dir
echo ""

var all = dirs & files
echo all