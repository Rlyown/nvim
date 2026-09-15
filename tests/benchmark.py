"""Controlled measurements: disable automatic installation in the baseline copy to avoid network requests and updates."""
import io, json, os, pathlib, shutil, subprocess, tarfile, time
root = pathlib.Path(__file__).resolve().parents[1]
runtime = pathlib.Path(os.environ['TEST_RUNTIME'])
baseline = runtime/'baseline-config/nvim'
baseline.mkdir(parents=True, exist_ok=True)
archive = subprocess.check_output(['git','-C',str(root),'archive','main'])
with tarfile.open(fileobj=io.BytesIO(archive)) as t: t.extractall(baseline, filter='data')
p=baseline/'lua/core/lazy.lua'
s=p.read_text().replace('}\n)', '}, { install = { missing = false }, checker = { enabled = false } }\n)')
p.write_text(s)
p=baseline/'lua/plugins/treesitter.lua';p.write_text(p.read_text().replace('ensure_installed = filtered','ensure_installed = {}'))
p=baseline/'lua/plugins/lsp/init.lua';s=p.read_text().replace('ensure_installed = LSP_SERVERS','ensure_installed = {}').replace('"WhoIsSethDaniel/mason-tool-installer.nvim",','"WhoIsSethDaniel/mason-tool-installer.nvim",\n        init = function() end,').replace('opts = {\n            -- a list','opts = {\n            run_on_start = false,\n            -- a list');p.write_text(s)
(runtime/'benchmark.py').write_text("print('benchmark')\n")
results=[]
for version, config_home in [('baseline',runtime/'baseline-config'),('modular',runtime/'config')]:
    for scenario, args in [('empty',[]),('python',[str(runtime/'benchmark.py')])]:
        for repeat in range(3):
            env=os.environ.copy()
            for key in list(env):
                if key.startswith('NVIM_'): env.pop(key)
            env.update(XDG_CONFIG_HOME=str(config_home),XDG_DATA_HOME=str(runtime/'data'),XDG_STATE_HOME=str(runtime/('bench-state-'+version)),XDG_CACHE_HOME=str(runtime/('bench-cache-'+version)),NVIM_OFFLINE='1',NVIM_LOG_FILE=str(runtime/'benchmark.log'))
            log=runtime/f'{version}-{scenario}-{repeat}.startuptime'
            start=time.monotonic()
            result=subprocess.run(['nvim','--headless','-i','NONE','--startuptime',str(log),*args,'+qa'],env=env,capture_output=True,text=True,timeout=30)
            results.append({'version':version,'scenario':scenario,'repeat':repeat,'process_ms':round((time.monotonic()-start)*1000,2),'exit':result.returncode,'output':result.stdout+result.stderr})
(runtime/'benchmark-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2))
for r in results: print(r['version'],r['scenario'],r['repeat'],r['process_ms'],r['output'][:250])
