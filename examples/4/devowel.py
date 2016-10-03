#!/usr/local/bin/python3.5 -u
import fileinput
import re
for line in fileinput.input():
  line = line.rstrip()
  line = re.sub(r'[aeiou]','',line)
  print(("%s" % (line)))
