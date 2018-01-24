#!/usr/bin/env python3

import re
from filelist import *
from unittest import TestCase

class TestFilelist(TestCase):
  def test_detect_regex_exprs(self):
    self.assertEqual(
      detect_regex_exprs([
        'a',
        '#comment',
        '~b',
        '',
        'c',
      ]),
      (
        set(['a', 'c']),
        set([re.compile('b')]),
      ),
    )

  def test_match_in(self):
    S = ['/a/b/c/d', '/a/b/', '/', '/a/b/c/e']
    S_re = [re.compile('test$')]
    self.assertEqual(
      match_in(
        S, S_re, '/a/test',
      ), 1,
      'regex catch',
    )
    self.assertEqual(
      match_in(
        S, S_re, '/a/test2',
      ), 3,
      'parent is /',
    )
    self.assertEqual(
      match_in(
        S, S_re, '/a/b/c',
      ), 2,
      'parent is /a/b/',
    )
    self.assertEqual(
      match_in(
        S, S_re, '/a/b/c/d',
      ), 1,
      'appears in S',
    )
    self.assertEqual(
      match_in(
        S, S_re, 'a/b/c/d/e',
      ), 5,
      'No recursive parent',
    )
    self.assertEqual(
      match_in(
        S, S_re, '/a/b/c/e/f',
      ), 2,
      'Direct parent',
    )
    self.assertEqual(
      match_in(
        S, S_re, '/a/b/c/e/f/g',
      ), 5,
      'parent is /a/b',
    )
