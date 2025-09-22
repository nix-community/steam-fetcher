find-nix := "find -not -path './npins/*' -name '*.nix'"

[private]
@default:
  just --list

[group('lint')]
shellcheck:
    shellcheck **/*.sh

[group('lint')]
shfmt-check:
    shfmt --diff **/*.sh

[group('lint')]
nixfmt-check:
    {{find-nix}} -exec nixfmt --check '{}' \+

[group('format')]
shfmt:
    shfmt --write **/*.sh

[group('format')]
nixfmt:
    {{find-nix}} -exec nixfmt '{}' \+
