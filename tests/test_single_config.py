"""Verify the single-file configuration in a temporary directory."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
NVIM = shutil.which("nvim")
assert NVIM, "Neovim 0.12.4+ is required"

with tempfile.TemporaryDirectory(prefix="single-config-") as directory:
    temp = Path(directory).resolve()
    config = temp / "single-config.lua"
    shutil.copyfile(ROOT / "single-config.lua", config)
    env = dict(os.environ)
    for name in ("CONFIG", "DATA", "STATE", "CACHE"):
        env[f"XDG_{name}_HOME"] = str(temp / name.lower())
    env["XDG_CONFIG_DIRS"] = str(temp / "config-dirs")
    env["XDG_DATA_DIRS"] = str(temp / "data-dirs")
    env["NVIM_LOG_FILE"] = str(temp / "nvim.log")
    env["GOCACHE"] = str(temp / "go-cache")
    env["GOPLSCACHE"] = str(temp / "gopls-cache")
    env["GOMODCACHE"] = str(temp / "go-mod-cache")
    env["GOTELEMETRY"] = "off"
    project = temp / "project with spaces"
    project.mkdir()
    (project / "CMakeLists.txt").write_text("# test project\n")
    (project / "unicode $(touch SHOULD_NOT_EXIST) ' file.txt").write_text("first\nNeedle [x]\nlast\n")
    (project / "other.txt").write_text("needle [x]\n")
    (project / "binary.bin").write_bytes(b"\0needle [x]\n")
    (project / "large.txt").write_text("needle [x]\n" + "x" * (1024 * 1024 + 1))
    (project / "build").mkdir()
    (project / "build" / "ignored.txt").write_text("needle [x]\n")
    (project / "cycle").symlink_to(project, target_is_directory=True)
    env["SINGLE_FIXTURE"] = str(project)
    # Simulate an existing user configuration and automatically loaded plugin.
    for path in (
        temp / "config/nvim/init.lua",
        temp / "config/nvim/plugin/rogue.lua",
        temp / "data/nvim/site/pack/test/start/rogue/plugin/rogue.lua",
        temp / "config/nvim/after/plugin/rogue.lua",
    ):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('error("SHOULD_NOT_LOAD")\n')
    (project / ".nvim.lua").write_text('error("SHOULD_NOT_LOAD")\n')

    def run_case(name, source, no_tools=False, extra_env=None):
        script = temp / f"test_{name}.lua"
        script.write_text(
            "local ok, err = xpcall(function()\n"
            + source
            + '\nend, debug.traceback)\nif not ok then print(err); vim.cmd("cquit 1") end\n'
            + f'print("SINGLE_PASS {name}")\nvim.cmd("qa!")\n'
        )
        current_env = dict(env)
        if no_tools:
            empty = temp / "empty-bin"
            empty.mkdir(exist_ok=True)
            current_env["PATH"] = str(empty)
        current_env.update(extra_env or {})
        result = subprocess.run(
            [NVIM, "--headless", "-i", "NONE", "-u", str(config), "-l", str(script)],
            env=current_env, cwd=project, text=True, capture_output=True, timeout=30,
        )
        output = result.stdout + result.stderr
        if result.returncode != 0:
            log = temp / "state/nvim/lsp.log"
            if log.exists():
                output += "\nLSP log:\n" + log.read_text()[-8000:]
        assert result.returncode == 0 and f"SINGLE_PASS {name}" in output, output
        for marker in ("Error detected", "Error in", "stack traceback", "SHOULD_NOT_LOAD"):
            assert marker not in output, output
        print(name, "PASS")

    run_case("isolation", r'''
local S = assert(SingleConfig)
assert(vim.g.mapleader == ",")
assert(not vim.o.loadplugins and not vim.o.exrc)
assert(not package.loaded.lazy and not package.loaded["core.options"])
for _, path in ipairs(vim.opt.runtimepath:get()) do
    local prefix = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.env.VIMRUNTIME)))
    assert(path:sub(1, #vim.env.VIMRUNTIME) == vim.env.VIMRUNTIME or path == prefix .. "/lib/nvim" or path == prefix .. "/lib64/nvim", path)
end
assert(vim.fn.exists(":Explore") == 2)
assert(vim.fn.maparg("gc", "n") ~= "")
for _, name in ipairs({"Files", "Grep", "Help", "Health", "Run", "Build", "Test", "SessionSave", "SessionLoad", "SessionDelete"}) do
    assert(vim.fn.exists(":Single" .. name) == 2, name)
end
local seen = {}
for _, action in ipairs(S.actions) do
    local modes = type(action.mode) == "table" and action.mode or {action.mode}
    for _, mode in ipairs(modes) do
        local key = mode .. action.lhs
        assert(not seen[key], "duplicate keymap " .. key)
        seen[key] = true
    end
end
assert(vim.fn.maparg(",lr", "n", false, true).desc == "Language task: run")
assert(vim.fn.maparg(",ln", "n", false, true).desc == "Rename symbol")
vim.cmd("SingleHealth")
assert(vim.bo.buftype == "nofile")
vim.cmd("close")
vim.cmd("SingleHelp")
assert(vim.api.nvim_buf_line_count(0) > 30)
vim.cmd("close")
vim.cmd("Explore " .. vim.fn.fnameescape(vim.env.SINGLE_FIXTURE))
assert(vim.bo.filetype == "netrw")
''', no_tools=True)

    run_case("fallback_search", r'''
local S = SingleConfig
local root = vim.env.SINGLE_FIXTURE
local function search(query)
    local result
    S.grep(query, root, function(items) result = items end)
    assert(vim.wait(5000, function() return result ~= nil end), "search did not finish")
    return result
end
local items = search("needle [x]")
assert(#items == 2, vim.inspect(items))
assert(#search("Needle [x]") == 1)
assert(#search("missing") == 0)
assert(vim.fn.filereadable("SHOULD_NOT_EXIST") == 0)
local called = false
S.grep("needle", root, function() called = true end)
S.cancel_search()
vim.wait(100)
assert(not called)
S.settings.max_matches = 1
assert(#search("needle") == 1)
S.settings.max_matches = 5000
S.files()
assert(vim.wait(5000, function() return S.picker and #S.picker.items > 0 end))
for _, item in ipairs(S.picker.items) do
    assert(not item.filename:find("/build/", 1, true))
    assert(not item.filename:find("/cycle/", 1, true))
end
S.picker.close()
local before = #vim.api.nvim_list_wins()
local p = S.pick("Test", {{label="alpha"}, {label="unicode"}})
vim.api.nvim_buf_set_lines(p.input, 0, -1, false, {"unicode"})
p.refresh()
assert(#p.filtered == 1 and p.filtered[1].label == "unicode")
p.close()
assert(#vim.api.nvim_list_wins() == before)
local q = S.pick("Cancel", {})
vim.api.nvim_win_close(0, true)
vim.wait(50)
assert(not q.alive and S.picker == nil)
local filename = root .. "/unicode $(touch SHOULD_NOT_EXIST) ' file.txt"
local chooser = S.pick("Open path", {{ label=filename, filename=filename, lnum=2 }})
vim.fn.maparg("<CR>", "n", false, true).callback()
assert(vim.wait(1000, function() return vim.api.nvim_buf_get_name(0) == filename end))
assert(vim.api.nvim_win_get_cursor(0)[1] == 2)
S.grep("needle [x]", root)
assert(vim.wait(5000, function() return S.search == nil end))
assert(#vim.fn.getqflist() == 2)
''', no_tools=True)

    run_case("state_and_large_file", r'''
local S = SingleConfig
local root = vim.env.SINGLE_FIXTURE
vim.cmd.edit(vim.fn.fnameescape(root .. "/other.txt"))
vim.api.nvim_buf_set_lines(0, 0, 1, false, {"needle [x] changed"})
vim.cmd("write")
assert(vim.fn.filereadable(vim.fn.undofile(vim.api.nvim_buf_get_name(0))) == 1)
S.session("save")
local path = S.session_path()
assert(vim.fn.filereadable(path) == 1)
vim.cmd("enew")
S.session("load")
assert(vim.api.nvim_buf_get_name(0) == root .. "/other.txt")
local old_select = vim.ui.select
vim.ui.select = function(_, _, callback) callback("Delete") end
S.session("delete")
vim.ui.select = old_select
assert(vim.fn.filereadable(path) == 0)
vim.cmd.edit(vim.fn.fnameescape(root .. "/large.txt"))
assert(vim.b.single_large and not vim.bo.undofile)
''', no_tools=True)

    run_case("terminal", r'''
local S = SingleConfig
vim.o.shell = "/bin/sh"
local term = S.terminal(1, "horizontal", false)
assert(term.job and term.job > 0)
local buf, job = term.buf, term.job
S.send(1, "printf 'single-terminal-ok\\n'")
assert(vim.wait(3000, function()
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"):find("single-terminal-ok", 1, true)
end))
for _, layout in ipairs({"vertical", "float", "tab", "horizontal"}) do
    S.terminal(1, layout, true)
    term = S.terminal(1, layout, false)
    assert(term.buf == buf and term.job == job)
end
S.terminal(1, "horizontal", true)
local second = S.terminal(2, "horizontal", false)
assert(second.buf ~= buf and second.job ~= job)
vim.fn.jobstop(job)
vim.fn.jobstop(second.job)
assert(vim.wait(3000, function() return vim.fn.jobwait({job}, 0)[1] ~= -1 end))
S.terminal(2, "horizontal", true)
term = S.terminal(1, "horizontal", false)
assert(term.job ~= job)
vim.fn.jobstop(term.job)
''')

    run_case("editing_and_selection", r'''
local api, fn, S = vim.api, vim.fn, SingleConfig
vim.cmd("enew")
vim.bo.filetype = "lua"
api.nvim_buf_set_lines(0, 0, -1, false, {""})
local opening = fn.maparg("(", "i", false, true).callback()
assert(opening == "()<Left>", opening)
api.nvim_buf_set_lines(0, 0, -1, false, {"abc"})
api.nvim_win_set_cursor(0, {1, 0})
vim.cmd("normal! vll")
local input = vim.ui.input
vim.ui.input = function(_, callback) callback("(") end
fn.maparg(",lz", "x", false, true).callback()
vim.ui.input = input
assert(api.nvim_get_current_line() == "(abc)", api.nvim_get_current_line())
vim.cmd("normal! <Esc>")
vim.cmd("enew!")
vim.bo.filetype = "lua"
fn.maparg(",li", "n", false, true).callback()
assert(S.picker and #S.picker.items == 1)
fn.maparg("<CR>", "n", false, true).callback()
assert(vim.wait(1000, function() return vim.snippet.active() end))
assert(api.nvim_buf_get_lines(0, 0, 1, false)[1]:find("local function", 1, true))
assert(fn.maparg("<Tab>", "i", false, true).callback():find("vim.snippet.jump", 1, true))
vim.snippet.stop()
vim.cmd("stopinsert")
fn.maparg(",sk", "n", false, true).callback()
api.nvim_buf_set_lines(S.picker.input, 0, 1, false, {"Rename"})
S.picker.refresh()
assert(#S.picker.filtered == 1)
S.picker.close()
''', no_tools=True)

    run_case("replacement", r'''
local fn, api = vim.fn, vim.api
local directory = vim.env.SINGLE_FIXTURE .. "/replace-fixture"
fn.mkdir(directory, "p")
fn.writefile({"match / [x] & match / [x]"}, directory .. "/file.txt")
vim.cmd.cd(fn.fnameescape(directory))
vim.cmd("enew")
local old_input = vim.ui.input
local answers = {"match / [x]", "new / & text"}
vim.ui.input = function(_, callback) callback(table.remove(answers, 1)) end
-- Use native :substitute confirmation instead of simulating replacement.
api.nvim_feedkeys("a", "t", false)
fn.maparg(",sr", "n", false, true).callback()
vim.ui.input = old_input
assert(vim.wait(3000, function() return SingleConfig.search == nil end))
local buf = fn.bufnr(directory .. "/file.txt")
assert(buf > 0)
assert(api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "new / & text & new / & text")
assert(vim.bo[buf].modified)
assert(fn.readfile(directory .. "/file.txt")[1] == "match / [x] & match / [x]")
api.nvim_set_current_buf(buf)
vim.cmd("undo")
assert(api.nvim_get_current_line() == "match / [x] & match / [x]")
''', no_tools=True)

    run_case("missing_parser_and_empty_directory", r'''
local S = SingleConfig
vim.opt.runtimepath = { vim.env.VIMRUNTIME }
vim.cmd("enew")
vim.bo.filetype = "lua"
assert(vim.bo.syntax == "lua")
vim.cmd("enew!")
local path = vim.env.SINGLE_FIXTURE .. "/empty"
vim.fn.mkdir(path, "p")
vim.cmd.cd(vim.fn.fnameescape(path))
S.files()
vim.wait(100)
assert(S.picker.alive and #S.picker.items == 0)
S.picker.close()
local done = false
S.grep("anything", path, function(items) assert(#items == 0); done = true end)
assert(vim.wait(1000, function() return done end))
''', no_tools=True)

    for language, tool, file, content in (
        ("cpp", "clangd", "sample.cpp", "int main(){return 0;}\n"),
        ("go", "gopls", "sample.go", "package main\nfunc main(){println(1)}\n"),
    ):
        if not shutil.which(tool):
            print(language, "LSP SKIP (tool is not installed)")
            continue
        (project / file).write_text(content)
        if language == "go":
            (project / "go.mod").write_text("module example.invalid/single\n\ngo 1.20\n")
        run_case("lsp_" + language, r'''
local S = SingleConfig
vim.cmd.edit(vim.fn.fnameescape(vim.env.SINGLE_FIXTURE .. "/" .. vim.env.SINGLE_LSP_FILE))
assert(vim.wait(15000, function()
    return #vim.lsp.get_clients({bufnr=0, method="textDocument/formatting"}) > 0
end), "LSP initialization did not finish")
local client = vim.lsp.get_clients({bufnr=0})[1]
assert(client.name == vim.env.SINGLE_LSP_NAME)
assert(client.config.root_dir == vim.env.SINGLE_FIXTURE)
assert(client:supports_method("textDocument/completion", 0))
local original = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
S.format()
assert(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") ~= original)
client:stop(true)
''', extra_env={"SINGLE_LSP_FILE": file, "SINGLE_LSP_NAME": "single_clangd" if language == "cpp" else "single_gopls"})

    if shutil.which("rg"):
        run_case("rg_search", r'''
local S = SingleConfig
local result
S.grep("needle [x]", vim.env.SINGLE_FIXTURE, function(items) result = items end)
assert(vim.wait(5000, function() return result ~= nil end))
assert(#result == 2, vim.inspect(result))
S.files()
assert(vim.wait(5000, function() return S.picker and #S.picker.items > 0 end))
S.picker.close()
S.settings.max_search_output_bytes = 10
local result2
S.grep("needle", vim.env.SINGLE_FIXTURE, function(items) result2 = items end)
assert(vim.wait(3000, function() return result2 ~= nil end))
assert(#result2 == 0)
''')

    if shutil.which("git"):
        subprocess.run(["git", "init", "-q", str(project)], check=True, capture_output=True)
        subprocess.run(["git", "-C", str(project), "add", "other.txt"], check=True, capture_output=True)
        subprocess.run(["git", "-C", str(project), "-c", "user.name=Test", "-c", "user.email=test@example.invalid",
                        "commit", "-qm", "test commit"], check=True, capture_output=True)
        run_case("git", r'''
local S = SingleConfig
local path = vim.env.SINGLE_FIXTURE .. "/other.txt"
vim.cmd.edit(vim.fn.fnameescape(path))
S.git("status")
assert(vim.wait(5000, function() return vim.api.nvim_buf_get_name(0):find("single://git-status", 1, true) ~= nil end))
vim.cmd("close")
vim.api.nvim_buf_set_lines(0, 0, 1, false, {"unsaved git difference"})
S.git("diff")
assert(vim.wait(5000, function() return vim.api.nvim_buf_get_name(0):find("single://HEAD", 1, true) ~= nil end))
assert(vim.wo.diff and vim.bo.buftype == "nofile" and not vim.bo.modifiable)
assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "needle [x] changed")
vim.cmd("tabclose")
assert(vim.bo.modified)
''')

    # Use a regular file as the state path to simulate an unwritable state directory.
    bad_state = temp / "bad-state"
    bad_state.write_text("not a directory")
    run_case("unwritable_state", r'''
assert(not vim.o.undofile and vim.o.shadafile == "NONE")
vim.cmd("SingleHealth")
assert(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find("not writable", 1, true))
''', no_tools=True, extra_env={"XDG_STATE_HOME": str(bad_state)})

print("All single-file configuration tests passed")
