#!/usr/local/bin/python3.5 -u
count = 0
i = 2
while i < 100:
  k = i/2
  j = 2
  while j <= k:
    k = i%j
    if k == 0:
      count = count-1
      break
    k = i/2
    j = j+1
  count = count+1
  i = i+1
print(("%s" % (count)))
