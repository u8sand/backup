#!/usr/bin/env python3

import os
import uuid
import shutil
from subprocess import Popen
from unittest import TestCase

class ExtendedTestCase(TestCase):
  '''
  Add file/path manipulation tools for seemlessly creating
   files and directories under a test_root.
  '''
  def setUp(self):
    self.test_root = os.environ.get('TEST_DIR', 'test.%s' % (uuid.uuid4()))
    print('Creating test directory %s...' % (self.test_root))
    os.mkdir(self.test_root)

  def mkdir(self, D):
    d = [self.test_root, *D.split('/')]
    for i in range(1, len(d) + 1):
      p = '/'.join(d[:i])
      if not os.path.exists(p):
        os.mkdir(p)

  def rmdir(self, D):
    shutil.rmtree(os.path.join(self.test_root, D))
  
  def copy(self, src, dst):
    shutil.copy(os.path.join(self.test_root, src), os.path.join(self.test_root, dst))

  def remove(self, f):
    os.remove(os.path.join(self.test_root, f))

  def add(self, src, dst=None):
    if dst is None:
      dst = src
    shutil.copy(src, os.path.join(self.test_root, dst))

  def touch(self, f, c=None):
    self.mkdir(os.path.dirname(f))
    with open(os.path.join(self.test_root, f), 'a') as fout:
      if c:
        print(c, file=fout)
  
  def execute(self, func):
    self.assertEqual(Popen(['bash', os.path.join(self.test_root, func)]).wait(), 0)

  def recursive_touch(self, P, K=''):
    for k, v in P.items():
      Kk = os.path.join(K, k)
      if type(v) == dict:
        self.recursive_touch(v, Kk)
      elif type(v) == bool:
        if k != '':
          self.touch(Kk)
      else:
        assert False, 'recursive_touch not constructed properly'

  def assertIsDir(self, D):
    self.assertTrue(os.path.isdir(os.path.join(self.test_root, D)), '%s is dir?' % (D))

  def assertIsNotDir(self, D):
    self.assertFalse(os.path.isdir(os.path.join(self.test_root, D)), '%s is not dir?' % (D))

  def assertIsFile(self, F):
    self.assertTrue(os.path.isfile(os.path.join(self.test_root, F)), '%s is file?' % (F))

  def assertIsNotFile(self, F):
    self.assertFalse(os.path.isfile(os.path.join(self.test_root, F)), '%s is not file?' % (F))

  def assertFileIs(self, F, C):
    self.assertEqual(open(os.path.join(self.test_root, F), 'r').read().strip(), C)

  def assertPaths(self, P, K=''):
    for k, v in P.items():
      Kk = os.path.join(K, k)
      if type(v) == dict:
        dir_exists = v.get('', True)
        if dir_exists:
          self.assertIsDir(Kk)
        else:
          self.assertIsNotDir(Kk)
        if dir_exists:
          self.assertPaths(v, Kk)
      elif type(v) == bool:
        if v:
          self.assertIsFile(Kk)
        else:
          self.assertIsNotFile(Kk)
      else:
        self.fail('assertPaths not constructed properly')

  def tearDown(self):
    print('Cleaning up test...')
    shutil.rmtree(self.test_root)
