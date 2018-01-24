# backup

My generic backup script--build rules from generic scripts or lists. With intelligent more-specific-prioritization, support for regular expression and more (see **Blacklist and Whitelists** section for more), backups were never easier.

`backup.sh` can be executed after constructing meaningful whitelists and blacklists. Some sane ones are included, but more useful ones can be found in my own `system` branch, in particular some arch-linux specific package magic that removes unmodified files owned by pacman packages.

## Dependencies

The primary dependencies are `bash`, `rsync`, and `python3`.
No external `python3` dependencies are required except for `nose` when testing.
If using compression, `tar` along with your compression algorithm library (e.g. `gzip`) is required.

## Blacklist and Whitelists

We crawl the directories `blacklist.d` and `whitelist.d`--each `.sh` file is executed and each `.txt` file is taken as is. Directories ending in `/` will be recursively walked. Empty lines and those beginning with `#` are ignored (comments). Lines beginning with ~ are treated as regular expressions (where the expression starts right after the `~`, no space). Other then regular expressions which will always be valued more, more specific rules will always prevail, if both rules are equally specific, whitelist will prevail.

Take the following situation for example:

```
# whitelist.d/whitelist.txt
/a/b/
/a/b/c/d
/a/b/c/e/f/
/a/b/g.obj

# blacklist.d/blacklist.txt
/a/b/c/
~\.obj$
```

We'll blacklist files below `/a/b/c/` but above `/a/b/c/e/f/` except for the specific file or directory `/a/b/c/d`. All files that match the regular expression `~\.obj$` will be ignored regardless of the location except for `/a/b/g.obj` which will be included.

## Hooks

We crawl `hooks.d` specific subdirectories before and after each script and execute each script. Environment variables are passed on. In particular the following directories are traversed:
- `hooks.d/before/*.sh`
- `hooks.d/before-backup/*.sh`
- `hooks.d/after-backup/*.sh`
- `hooks.d/before-restore/*.sh`
- `hooks.d/after-restore/*.sh`
- `hooks.d/after/*.sh`

Custom environmental variables and functions can be put in `config.sh` as this is sourced by `backup.sh` and `restore.sh` those variables and functions will be available in any of the hook scripts.

Backup compression has been implemented as a hook.
