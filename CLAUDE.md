# Build Commands

## Desktop (nixd)
```bash
home-manager switch --flake '.?submodules=1#nixd'
```

## Laptop
```bash
home-manager switch --flake '.?submodules=1#laptop'
```

## Notes
- The `?submodules=1` parameter is required to include the private git submodule (modules/private)
- Without it, the private notification configurations won't be loaded
- The configuration will still build without the submodule parameter for users who don't have access to the private repo
