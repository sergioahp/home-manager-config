# CJK Font Fallback Analysis

## TL;DR - Quick Summary

**Observation:** CJK text renders differently after the 2026-08-22 update
(`~/nixos` 7c57cb3, nixpkgs 2026-05-10 -> 2026-08-22).

**Confirmed:** it is different. Han characters used to resolve to
**Noto Sans CJK JP**; they now resolve to **Noto Sans CJK KR**. Same glyphs
where the variants agree, different glyphs where they do not (送 is a clear
case: one-dot shinnyou before, two-dot after).

**Root cause:** fontconfig 2.17.1 -> 2.18.2. The new `40-nonlatin.conf` and
`65-nonlatin.conf` shipped by fontconfig added `Noto Sans CJK KR`,
`Noto Serif CJK KR` and `Noto Sans Mono CJK KR` to the generic prefer lists.
Upstream picked the KR family as the single representative of the Noto CJK
set. Nothing in this repo or in `~/nixos` asked for that.

**Why nothing here shielded us:** `fonts.fontconfig.defaultFonts.sansSerif`
lists `"noto-fonts-cjk"`, which is the nixpkgs attribute name, not a
fontconfig family. It has never matched anything, so the CJK slot has always
been decided by fontconfig's own defaults. The latent bug was already
documented as a code comment in the dendritic port
(`~/code/nix/dendritic-cli/modules/home/graphical/fonts.nix`); the update is
what made it bite.

**Secondary change:** `fonts.enableDefaultPackages` now installs
`noto-fonts-cjk-sans` and `noto-fonts-cjk-serif` system-wide. Noto Serif CJK
did not exist on this machine before, so serif CJK used to fall back to the
sans face and now renders as an actual Mincho/Batang serif.

---

## Evidence

### Character-level fallback, before vs after

Reproduced by replaying the pre-update rule set (fontconfig 2.17.1 conf.d plus
the pre-update system font dirs, from `/nix/var/nix/profiles/system-34-link`)
against the same query. `送` is U+9001.

```
sans-serif  BEFORE: NotoSansCJK-VF.otf.ttc:     "Noto Sans CJK JP"
sans-serif  AFTER : NotoSansCJK-VF.otf.ttc:     "Noto Sans CJK KR"
serif       BEFORE: NotoSansCJK-VF.otf.ttc:     "Noto Sans CJK JP"
serif       AFTER : NotoSerifCJK-VF.otf.ttc:    "Noto Serif CJK KR"
monospace   BEFORE: NotoSansCJK-VF.otf.ttc:     "Noto Sans CJK JP"
monospace   AFTER : NotoSansMonoCJK-VF.otf.ttc: "Noto Sans Mono CJK KR"
```

All three generics moved, so the change is visible in GTK apps, kitty and
zathura alike.

### Which file did it

Ablation over the live conf.d, one file reverted at a time:

```
live rules, 40/65-nonlatin.conf reverted to 2.17.1  -> Noto Sans CJK JP
live rules, 48-guessfamily.conf removed             -> Noto Sans CJK KR
2.18.2 binary + 2.17.1 rules                        -> Noto Sans CJK JP
2.17.1 rules + post-update font dirs                -> Noto Sans CJK JP
2.18.2 rules + pre-update font dirs                 -> Noto Sans CJK KR
```

So it is the two nonlatin conf files, not the library's scoring, not the new
`48-guessfamily.conf`, and not the extra system font packages.

The diff between the two fontconfig releases:

```
65-nonlatin.conf
+ <family>Noto Serif CJK KR</family>     <!-- hangul (ko) -->   (serif)
+ <family>Noto Sans CJK KR</family>      <!-- hangul (ko) -->   (sans-serif)
+ <family>Noto Sans Mono CJK KR</family> <!-- hangul (ko) -->   (monospace)
- UnBatang / Baekmuk Batang / UnDotum / Baekmuk Dotum / Baekmuk Gulim
```

`40-nonlatin.conf` gained the matching `<alias><family>Noto Sans CJK KR</family>
<default>sans-serif</default></alias>` entries; it had no Noto CJK entries at
all in 2.17.1.

### The same rules explain the GTK regression already fixed

a8211fe pinned `org/gnome/desktop/interface font-name` because the unset key
made the portal serve `Adwaita Sans 11`, an uninstalled family that resolved to
Noto Sans CJK KR. That resolution comes from the same two files:

```
live rules                                -> "Adwaita Sans" = Noto Sans CJK KR
40/65-nonlatin.conf reverted to 2.17.1    -> "Adwaita Sans" = DejaVu Sans
```

Before the update an unknown family fell through to DejaVu Sans, which is why
the portal becoming reachable had no visible effect until now. The dconf pin
fixes that one symptom; the underlying "unknown family lands on Noto Sans CJK
KR" behaviour is still live for any other missing family.

### System font packages

`fonts.enableDefaultPackages` is on (implied by the graphical stack) and its
package list changed upstream:

```
nixos/modules/config/fonts/packages.nix, before:
  dejavu_fonts freefont_ttf gyre-fonts liberation_ttf unifont
  noto-fonts-color-emoji

after:
  dejavu_fonts freefont_ttf gyre-fonts liberation_ttf unifont
  noto-fonts-cjk-sans noto-fonts-cjk-serif noto-fonts-color-emoji
```

Consequences:

- `noto-fonts-cjk-serif` is new on this machine. Serif CJK now has a real
  serif face instead of borrowing the sans one.
- `noto-fonts-cjk-sans` is now installed twice: once by the system
  (`0q117kf...`, from the `~/nixos` nixpkgs) and once by `home.packages`
  (`338507z...`, from this repo's nixpkgs). Both are 2.004 and the `.ttc`
  files are byte-identical, so this is redundancy rather than a conflict, but
  fontconfig does scan and cache both.

## Latent config bug

`home.nix` and the dendritic port both carry:

```nix
sansSerif = [ "DejaVu Sans" "noto-fonts-cjk" "emoji" ];
```

Generated into `~/.config/fontconfig/conf.d/52-hm-default-fonts.conf` verbatim.
`noto-fonts-cjk` is a nixpkgs attribute, not a fontconfig family, so the entry
is inert; fontconfig skips it and the CJK slot is filled by whatever
`65-nonlatin.conf` happens to prefer. That is exactly the hook the update
pulled on. `serif` and `monospace` never had a CJK entry at all.

## Fix options

1. **Name the family you want.** Replace the dead entry with a real family in
   all three generics, so upstream's choice stops mattering:

   ```nix
   sansSerif = [ "DejaVu Sans" "Noto Sans CJK JP" "emoji" ];
   serif     = [ "DejaVu Serif" "Noto Serif CJK JP" "emoji" ];
   ```

   JP restores the pre-update rendering. SC would be the choice if the
   priority is simplified Chinese instead.

2. **monospace needs care.** `Noto Sans Mono CJK *` also covers box drawing
   and a slice of the symbol blocks, so inserting it ahead of the existing
   `Noto Sans Symbols 2` entry would undo the monochrome-symbol behaviour that
   entry exists to protect. If added, it belongs after Symbols 2.

3. **Drop `pkgs.noto-fonts-cjk-sans` from `home.packages`** now that the
   system installs it. Optional; only removes the duplicate scan. Keep it if
   the standalone (non-NixOS) home configurations still need to work on their
   own.

Whether to act at all is a preference call: KR and JP differ only in Han
variant selection, and neither is wrong for a machine whose CJK usage is
incidental.

## Reproduction

`tmp/fontconfig-preupdate/` holds the harness: `fonts.conf` replays the
pre-update rule set, `fonts-ablate-*.conf` revert one file at a time, and
`cjk-*.png` are the rendered before/after glyph pairs. All of it is
gitignored.
