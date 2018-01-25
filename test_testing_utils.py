#!/usr/bin/env python3

from testing_utils import ExtendedTestCase

class TestTestingUtils(ExtendedTestCase):
  def test_mkdir_rmdir(self):
    self.mkdir('test_dir/test_dir_2')
    self.assertIsDir('test_dir')
    self.assertIsDir('test_dir/test_dir_2')
    self.rmdir('test_dir')
    self.assertIsNotDir('test_dir')

  def test_touch_remove(self):
    self.touch('test_file_1')
    self.assertIsFile('test_file_1')
    self.touch('test_dir/test_file_2', 'Test')
    self.assertIsFile('test_dir/test_file_2')
    self.assertFileIs('test_dir/test_file_2', 'Test')
    self.remove('test_dir/test_file_2')
    self.assertIsNotFile('test_dir/test_file_2')

  def test_add_copy(self):
    self.add('test_testing_utils.py')
    self.assertIsFile('test_testing_utils.py')
    self.copy('test_testing_utils.py', 'test_testing_utils_2.py')
    self.assertIsFile('test_testing_utils_2.py')

  def test_execute(self):
    self.touch('test.sh', 'exit 0')
    self.execute('test.sh')

  def test_recursive_touch(self):
    pass # TODO

  def test_assert_paths(self):
    pass # TODO
