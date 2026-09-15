"""Create an isolated runtime from installed repositories at locked revisions without modifying user plugins or the lockfile."""
import json, os, pathlib, subprocess, tarfile, io, shutil
root = pathlib.Path(__file__).resolve().parents[1]
target = pathlib.Path(os.environ['TEST_RUNTIME'])
config = target / 'config/nvim'
shutil.copytree(root, config, ignore=shutil.ignore_patterns('.git', 'dist', 'nvim.log'), dirs_exist_ok=True)
plugins = pathlib.Path.home() / '.local/share/nvim/lazy'
locks = json.loads((root / 'lazy-lock.json').read_text())
for name, lock in locks.items():
    source = plugins / name
    if not source.exists():
        print('MISSING', name)
        continue
    result = subprocess.run(['git', '-C', str(source), 'archive', lock['commit']], capture_output=True)
    if result.returncode:
        print('MISSING COMMIT', name)
        continue
    dest = target / 'data/nvim/lazy' / name
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(result.stdout)) as archive:
        archive.extractall(dest, filter='data')
print(target)
