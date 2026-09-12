"""收集离线编辑器需要的系统运行时；项目编译工具链由目标机提供。"""
import os, pathlib, re, shutil, subprocess, sys
root = pathlib.Path(sys.argv[1])
bin_dir, lib_dir = root/'bin', root/'lib'
bin_dir.mkdir(exist_ok=True); lib_dir.mkdir(exist_ok=True)
executables = ['node', 'git', 'rg', 'fdfind', 'python3']
for name in executables:
    source = shutil.which(name)
    if not source: continue
    target = bin_dir / ('fd' if name == 'fdfind' else name)
    if pathlib.Path(source).resolve() != target.resolve():
        shutil.copy2(pathlib.Path(source).resolve(), target)
    output = subprocess.run(['ldd', str(target)], capture_output=True, text=True).stdout
    for path in re.findall(r'(?:=>\s+)(/\S+)', output):
        destination = lib_dir / pathlib.Path(path).name
        if pathlib.Path(path).resolve() != destination.resolve():
            shutil.copy2(pathlib.Path(path).resolve(), destination)
python_version = f'python{sys.version_info.major}.{sys.version_info.minor}'
shutil.copytree('/usr/lib/'+python_version, lib_dir/python_version, dirs_exist_ok=True)
# Mason 的 Python 虚拟环境入口通过相对路径定位本包的 Python。
for venv in (root/'data/nvim/mason/packages').glob('*/venv'):
    target = venv/'bin/python'
    if target.exists() or target.is_symlink(): target.unlink()
    relative = os.path.relpath(bin_dir/'python3', target.parent)
    target.write_text('#!/bin/sh\nexport PYTHONPATH="$(dirname "$0")/../lib/'+python_version+'/site-packages${PYTHONPATH:+:$PYTHONPATH}"\nexec "$(dirname "$0")/'+relative+'" "$@"\n')
    target.chmod(0o755)
    for script in (venv/'bin').iterdir():
        if script.name == 'python': continue
        if script.is_symlink() or not script.is_file(): continue
        data = script.read_bytes()
        if data.startswith(b'#!') and b'python' in data.split(b'\n', 1)[0]:
            original = script.with_name(script.name+'.py')
            script.rename(original)
            script.write_text('#!/bin/sh\nexec "$(dirname "$0")/python" "$(dirname "$0")/'+original.name+'" "$@"\n')
            script.chmod(0o755)
