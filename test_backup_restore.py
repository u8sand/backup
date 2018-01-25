#!/usr/bin/env python3

from datetime import date
from unittest import TestCase
from testing_utils import ExtendedTestCase

class TestBackupRestore(ExtendedTestCase):
  def test_multiple_backup_restore(self):
    print('Creating test tree...')
    self.today = str(date.today())
    self.test_path = {
      'root': {
        'test': True,
        '.cache': True,
        'not-here': {
          '.cache': False,
          'test': False,
          'or-here': {
            '.cache': False,
            'test': False,
            'but-here': {
              '.cache': False,
              'test': True,
              'but-not-here': {
                '': False,
                '.cache': False,
                'test': False,
              },
            },
          },
        },
      },
    }
    self.add('backup.sh')
    self.add('restore.sh')
    self.add('filelist.py')
    self.recursive_touch(self.test_path)
    self.touch('whitelist.d/whitelist.txt', '''
root/
root/not-here/or-here/but-here
root/.cache''')
    self.touch('blacklist.d/blacklist.txt', '''#ignore me
root/not-here/
~\.cache$''')
    self.touch('hooks.d/before/dir.sh', '''#!/usr/bin/env bash
mkdir -p ${BACKUP_DIR}''')
    self.touch('config.sh', '''#!/usr/bin/env bash
export BACKUP_ROOT=.
export BACKUP_DIR=backup
export WHITELIST_DIR=whitelist.d
export BLACKLIST_DIR=blacklist.d
export HOOKS_DIR=hooks.d
export FILELIST_CMD=./filelist.py
export TODAY="%s"

handle_hook_dir() {
  DIR=$1
  if [ -d "${DIR}" ]; then
    find "${DIR}" -type f -regex ".*\.sh" -exec bash {} \;
  fi
}
''' % (self.today))

    print('Testing backup 1...')
    self.execute('backup.sh')
    self.assertPaths({'backup': { 'root': self.test_path }})
    self.rmdir('root')

    print('Testing restore...')
    self.execute('restore.sh')
    self.assertPaths(self.test_path)

    print('Modifying for backup 2...')
    self.touch('root/not-here/or-here/test') # should be ignored and stay in root
    self.touch('root/not-here/or-here/but-here/test', 'test2') # should get backed up and be ignored
    self.touch('blacklist.d/blacklist_2.txt', 'root/test') # should be removed and backed up
    self.test_path['root']['test'] = False

    print('Testing backup 2...')
    self.execute('backup.sh')
    self.assertPaths({
      'backup': {
        'root': self.test_path,
        'archives': {
          self.today: {
            'root': {
              'test': True,
              'not-here': {
                'or-here': {
                  'but-here': {
                    'test': True,
                  },
                },
              },
            },
          },
        },
      },
    })

    print('Modifying for restore 2...')
    self.test_path['root']['not-here']['or-here']['test'] = True # added this to root before
    self.test_path['root']['test'] = True # removed from backup but still in root
    self.touch('root/.cache', 'test2') # should get backed up
    self.remove('root/not-here/or-here/but-here/test') # should get restored

    print('Testing restore 2...')
    self.execute('restore.sh')
    self.assertPaths({
      'root': self.test_path['root'],
      'archives': {
        self.today: {
          'root': {
            '.cache': True,
          },
        },
      },
    })
