# Project TODO - Next Steps (from PRD)

- [x] Initialize Git repo with empty structure + `.gitignore`
- [x] Draft `shadow` CLI wrapper with `walk`, `--add`, `--dry-run`, and `--force` options (Note: `chezmoi apply` is currently simulated in the script)
- [x] Create initial profiles: `base`, `kde`, `hyprland`, `devtools`
- [ ] Build out `bootstrap.sh` with profile detection and chezmoi integration (Note: Package installation is simulated; environment detection for shell/DE/hostname is pending)
- [ ] Test on clean Arch install with Archinstall `post_install` hook
- [ ] Add documentation and optional CI (lint/test dotfiles)
