# Project TODO - Next Steps (from PRD)

- [x] Initialize Git repo with empty structure + `.gitignore`
- [x] Draft `shadow` CLI wrapper with `walk`, `--add`, `--dry-run`, and `--force` options (Note: `chezmoi apply` is now active)
- [x] Create initial profiles: `base`, `kde`, `hyprland`, `devtools`
- [x] Build out `bootstrap.sh` with profile detection and chezmoi integration (multi-distro package support and environment detection implemented)
- [ ] Test on clean Arch install with Archinstall `post_install` hook
- [x] Add documentation and optional CI (lint/test dotfiles)
