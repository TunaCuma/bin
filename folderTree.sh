#! /bin/bash

find . -not -path '*/\.*' | python3 -c "import sys as s;s.a=[];[setattr(s,'a',list(filter(lambda p: c.startswith(p+'/'),s.a)))or (s.stdout.write('  '*len(s.a)+c[len(s.a[-1])+1 if s.a else 0:])or True) and s.a.append(c[:-1]) for c in s.stdin]"
