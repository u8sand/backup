#!/usr/bin/env python3

import re
import os
import sys

def detect_regex_exprs(L):
  '''
  Parse whitelist/blacklist file lists empty lines
   or lines that begin with # as comments, lines
   that begin with ~ as regular expressions, and
   the rest of the lines as file/directory rules.
  '''
  S = set()
  S_re = set()
  for e in L:
    if e == '' or e.startswith('#'):
      continue
    elif e.startswith('~'):
      S_re.add(re.compile(e[1:]))
    else:
      S.add(e)
  return S, S_re

def match_in(S, S_re, obj):
  '''
  Directories that end in slash can be detected
  recursively upwards though closer matches result in
  smaller values giving those precedence. Directories that
  don't end in slash can be used for non-recursive directory
  functionality--only direct decendents will be matched but
  regular expressions and direct object matching will still
  take precedence.
  '''
  # Search for object
  if obj in S:
    return 1
  # Regex search
  for e in S_re:
    if e.search(obj):
      return 1
  P = obj.split(os.path.sep)
  P_len = len(P)
  # Search for direct parent
  if os.path.sep.join(P[:-1]) in S:
    return 2
  # Search parent recursive directories
  for i in range(P_len, 0, -1):
    if (os.path.sep.join(P[:i]) + os.path.sep) in S:
      return (P_len - i) + 1
  # Nothing found
  return P_len

def main(whitelist, blacklist):
  whitelist, whitelist_re = detect_regex_exprs(whitelist)
  blacklist, blacklist_re = detect_regex_exprs(blacklist)
  filelist = set()

  for f in whitelist:
    if os.path.isdir(f):
      for root, dirs, files in os.walk(f):
        for ff in files:
          p = os.path.join(root, ff)
          whitelist_m = match_in(whitelist, whitelist_re, p)
          blacklist_m = match_in(blacklist, blacklist_re, p)
          print('inclusion check %s... %d <= %d' % (p, whitelist_m, blacklist_m), file=sys.stderr)
          if whitelist_m <= blacklist_m:
            filelist.add(p)
          else:
            pass # TODO: add to rsync exclusion
        if f.endswith(os.path.sep):
          for dd in dirs:
            p = os.path.join(root, dd)
            blacklist_m = match_in(blacklist, blacklist_re, p)
            whitelist_m = match_in(whitelist, whitelist_re, p)
            print('exclusion check %s... %d > %d' % (p, whitelist_m, blacklist_m), file=sys.stderr)
            if whitelist_m > blacklist_m:
              dirs.remove(dd)
              # TODO: add to rsync exclusion
        else: # Recurse only into directories that end in /
          dirs.clear()
          # TODO: add to rsync exclusion
    else:
      print('including %s...' % (f), file=sys.stderr)
      filelist.add(f)

  print('\n'.join(sorted(filelist)), file=sys.stderr)
  return filelist

if __name__ == '__main__':
  if len(sys.argv) < 2:
    print('Usage: filelist.py <whitelist_file> <blacklist_file>')
    exit(1)

  print(
    '\n'.join(
      sorted(
        main(
          open(sys.argv[1], 'r').read().splitlines(),
          open(sys.argv[2], 'r').read().splitlines(),
        )
      )
    )
  )
