# Startup and First-Use Measurements

These are reproducible measurements from the refactor, not general performance guarantees. Each scenario ran three times on the same machine using Neovim 0.12.5 and isolated XDG data, state, and cache directories. The baseline was an exported copy of `main` with automatic installation disabled so network requests and installation were excluded from startup timing.

| Configuration | Scenario | Three process durations (ms) |
| --- | --- | --- |
| main baseline | Empty startup | 188.15, 132.79, 155.01 |
| main baseline | Open a Python file directly | 334.71, 188.75, 176.36 |
| Modular minimal | Empty startup | 47.06, 36.59, 36.89 |
| Modular minimal | Open a Python file directly | 74.18, 56.07, 69.10 |

A separate first-use measurement recorded 4.70 ms to open a Python file and 10.97 ms to create the first terminal. These values apply only to that controlled run. Plugin revisions, filesystem caches, CPU scheduling, and project size affect results.

To repeat the measurements:

```sh
TEST_RUNTIME=/private/tmp/nvim-modular-test python3 tests/benchmark.py
```

The script writes complete raw results to `benchmark-results.json` in the isolated runtime. It does not modify the repository lockfile or the user's Neovim data directory.
