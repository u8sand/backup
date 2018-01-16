# backup

My generic backup script--build rsync filter rule from generic scripts or lists.

`backup.sh` can be executed after constructing meaningful whitelists and blacklists. Some sane ones are included, but more useful ones can be found in my own `system` branch, in particular some arch-linux specific package magic.

We crawl the directories `blacklist.d` and `whitelist.d`--each `.sh` file is executed and each `.txt` file is taken as is. Duplicates are removed and full paths are constructed if needed and rsync filter rules are constructed. Note that whitelists will over prevail over blacklists.

Full system backups are created and compressed, future backups are decompressed, rsynced, and then recompressed.
