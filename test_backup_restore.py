#!/usr/bin/env python3

import os
import shutil
from subprocess import Popen
from unittest import TestCase

test_root = 'test'

def mkdir(D):
  d = D.split('/')
  for i in range(1, len(d)+1):
    p = '/'.join(d[:i])
    if not os.path.exists(p):
      os.mkdir(p)

def touch(f, c=None):
  mkdir(os.path.dirname(f))
  with open(f, 'a') as fout:
    if c:
      print(c, file=fout)

class TestBackup(TestCase):
  def setUp(self):
    print('Setting up test...')
    touch(test_root + '/root/.cache')
    touch(test_root + '/root/test')
    touch(test_root + '/root/not-here/.cache')
    touch(test_root + '/root/not-here/test')
    touch(test_root + '/root/not-here/or-here//.cache')
    touch(test_root + '/root/not-here/or-here/test')
    touch(test_root + '/root/not-here/or-here/but-here/.cache')
    touch(test_root + '/root/not-here/or-here/but-here/test')
    touch(test_root + '/root/not-here/or-here/but-here/but-not-here/.cache')
    touch(test_root + '/root/not-here/or-here/but-here/but-not-here/test')
    touch(test_root + '/whitelist.d/whitelist.txt', '''
root/
root/not-here/or-here/but-here
root/.cache''')
    touch(test_root + '/blacklist.d/blacklist.txt', '''#ignore me
root/not-here/
~\.cache$''')
    touch(test_root + '/hooks.d/before/dir.sh', '''#!/usr/bin/env bash
mkdir -p ${BACKUP_DIR}''')
    shutil.copy('backup.sh', test_root + '/backup.sh')
    shutil.copy('restore.sh', test_root + '/restore.sh')
    shutil.copy('filelist.py', test_root + '/filelist.py')
    touch(test_root + '/config.sh', '''#!/usr/bin/env bash
export BACKUP_ROOT=.
export BACKUP_DIR=backup
export WHITELIST_DIR=whitelist.d
export BLACKLIST_DIR=blacklist.d
export HOOKS_DIR=hooks.d
export FILELIST_CMD=./filelist.py

handle_hook_dir() {
  DIR=$1
  if [ -d "${DIR}" ]; then
    find "${DIR}" -type f -regex ".*\.sh" -exec bash {} \;
  fi
}
''')

  def test_backup_restore(self):
    print('Testing backup...')
    self.assertEqual(Popen(['bash', test_root + '/backup.sh']).wait(), 0)
    self.assertTrue(os.path.isdir(test_root + '/backup'))
    self.assertTrue(os.path.isdir(test_root + '/backup/root'))
    self.assertTrue(os.path.isfile(test_root + '/backup/root/root/test'))
    self.assertTrue(os.path.isfile(test_root + '/backup/root/root/.cache'))
    self.assertFalse(os.path.isfile(test_root + '/backup/root/root/not-here/.cache'))
    self.assertFalse(os.path.isfile(test_root + '/backup/root/root/not-here/test'))
    self.assertTrue(os.path.isdir(test_root + '/backup/root/root/not-here/or-here/'))
    self.assertFalse(os.path.isfile(test_root + '/backup/root/root/not-here/or-here/.cache'))
    self.assertFalse(os.path.isfile(test_root + '/backup/root/root/not-here/or-here/test'))
    self.assertTrue(os.path.isdir(test_root + '/backup/root/root/not-here/or-here/but-here/'))
    self.assertTrue(os.path.isfile(test_root + '/backup/root/root/not-here/or-here/but-here/test'))
    self.assertFalse(os.path.isfile(test_root + '/backup/root/root/not-here/or-here/but-here/.cache'))
    self.assertFalse(os.path.isdir(test_root + '/backup/root/root/not-here/or-here/but-here/but-not-here/'))

    print('Testing restore...')
    shutil.rmtree(test_root + '/root')
    self.assertEqual(Popen(['bash', test_root + '/restore.sh']).wait(), 0)
    self.assertTrue(os.path.isdir(test_root + '/root'))
    self.assertTrue(os.path.isfile(test_root + '/root/test'))
    self.assertTrue(os.path.isfile(test_root + '/root/.cache'))
    self.assertFalse(os.path.isfile(test_root + '/root/not-here/.cache'))
    self.assertFalse(os.path.isfile(test_root + '/root/not-here/test'))
    self.assertTrue(os.path.isdir(test_root + '/root/not-here/or-here/'))
    self.assertFalse(os.path.isfile(test_root + '/root/not-here/or-here/.cache'))
    self.assertFalse(os.path.isfile(test_root + '/root/not-here/or-here/test'))
    self.assertTrue(os.path.isdir(test_root + '/root/not-here/or-here/but-here/'))
    self.assertTrue(os.path.isfile(test_root + '/root/not-here/or-here/but-here/test'))
    self.assertFalse(os.path.isfile(test_root + '/root/not-here/or-here/but-here/.cache'))
    self.assertFalse(os.path.isdir(test_root + '/root/not-here/or-here/but-here/but-not-here/'))

  def tearDown(self):
    print('Cleaning up test...')
    shutil.rmtree('test')
