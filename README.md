# backup

My generic backup script--build rsync filter rule from generic scripts or lists.

`backup.sh` can be executed after constructing meaningful whitelists and blacklists. Some sane ones are included, but more useful ones can be found in my own `system` branch, in particular some arch-linux specific package magic.

We crawl the directories `blacklist.d` and `whitelist.d`--each `.sh` file is executed and each `.txt` file is taken as is. Duplicates are removed and full paths are constructed if needed and rsync filter rules are constructed. Note that whitelists will over prevail over blacklists.

We crawl `hooks.d` specific subdirectories before and after each script and execute each script. Environment variables in backup and restore are passed on. In particular the following directories are traversed:
- `hooks.d/before/*.sh`
- `hooks.d/before-backup/*.sh`
- `hooks.d/after-backup/*.sh`
- `hooks.d/before-restore/*.sh`
- `hooks.d/after-restore/*.sh`
- `hooks.d/after/*.sh`

Backup compression has been implemented as a hook.
