"""在已有隔离运行时上检查配置组合和首次加载，不更新插件。"""
import os, pathlib, subprocess, json, time
root = pathlib.Path(__file__).resolve().parents[1]
runtime = pathlib.Path(os.environ['TEST_RUNTIME'])
env = os.environ.copy()
for key in list(env):
    if key.startswith('NVIM_'): env.pop(key)
for key, sub in [('XDG_CONFIG_HOME','config'),('XDG_DATA_HOME','data'),('XDG_STATE_HOME','state'),('XDG_CACHE_HOME','cache')]: env[key] = str(runtime / sub)
env['NVIM_LOG_FILE'] = str(runtime / 'matrix.log')
cases = [
    ('minimal', 'minimal', '', '', 'text'),
    ('cpp', 'minimal', 'cpp', '', 'cpp'), ('go', 'minimal', 'go', '', 'go'),
    ('rust', 'minimal', 'rust', '', 'rust'), ('python', 'minimal', 'python', '', 'python'),
    ('tex', 'minimal', 'tex', '', 'tex'), ('sql', 'minimal', 'sql', '', 'sql'),
    ('developer-dap', 'developer', None, 'dap', 'python'),
    ('ai', 'minimal', '', 'ai', 'text'),
    ('copilot', 'minimal', '', 'copilot', 'text'),
    ('offline-ai', 'developer', None, 'ai,copilot,dap', 'python'),
]
results = []
for name, profile, languages, features, ft in cases:
    case_env = env.copy(); case_env.update(NVIM_PROFILE=profile, NVIM_FEATURES=features)
    if languages is not None: case_env['NVIM_LANGUAGES'] = languages
    if name not in ('ai', 'copilot'): case_env['NVIM_OFFLINE'] = '1'
    script = runtime / 'matrix.lua'
    script.write_text('''local ok, err = xpcall(function()
local c = require("config")
local p = require("lazy.core.config").plugins
assert(not package.loaded.dap, "空启动加载 DAP")
assert(not package.loaded.sidekick, "空启动加载 AI")
vim.cmd.edit(vim.fn.tempname())
vim.bo.filetype = "'''+ft+'''"
assert(not package.loaded.dap, "首次文件打开提前加载 DAP")
require("lazy").load({plugins={"blink.cmp", "lualine.nvim"}})
assert(not package.loaded.sidekick, "补全或状态栏提前加载 AI")
if c.enabled("dap") then
    require("lazy").load({plugins={"nvim-dap"}})
    assert(require("dap").listeners.after.event_initialized.config)
else assert(not p["nvim-dap"]) end
if not c.enabled("ai") then assert(not p["sidekick.nvim"]) end
vim.bo.filetype = "text"
assert(vim.fn.maparg("<localleader>r", "n") == "")
end, debug.traceback)
if not ok then io.stderr:write(err); vim.cmd("cquit 1") else vim.cmd("qa!") end
''')
    started=time.monotonic()
    result=subprocess.run(['nvim','--headless','-i','NONE','+luafile '+str(script)],env=case_env,capture_output=True,text=True,timeout=30)
    output=result.stdout+result.stderr
    passed=result.returncode == 0 and not any(x in output for x in ['Error detected', 'Failed to run', 'stack traceback'])
    results.append({'case':name,'passed':passed,'process_ms':round((time.monotonic()-started)*1000,2),'output':output})
    print(name, 'PASS' if passed else 'FAIL', output[:1600])
(runtime/'matrix-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2))
raise SystemExit(0 if all(r['passed'] for r in results) else 1)
