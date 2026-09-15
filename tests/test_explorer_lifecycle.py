"""Verify explorer lifecycle in separate Neovim processes using an isolated runtime."""
import os
import pathlib
import subprocess
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
runtime = pathlib.Path(os.environ["TEST_RUNTIME"])
env = {key: value for key, value in os.environ.items() if not key.startswith("NVIM_")}
for key, directory in [("XDG_CONFIG_HOME", "config"), ("XDG_DATA_HOME", "data"),
                       ("XDG_STATE_HOME", "state"), ("XDG_CACHE_HOME", "cache")]:
    env[key] = str(runtime / directory)
env.update(NVIM_PROFILE="minimal", NVIM_LANGUAGES="", NVIM_OFFLINE="1",
           NVIM_LOG_FILE=str(runtime / "explorer-lifecycle.log"))
with tempfile.TemporaryDirectory(prefix="explorer-fixture-", dir=runtime) as directory:
    fixture = pathlib.Path(directory)
    (fixture / "sample.txt").write_text("Sample content\n")
    for scenario in ["file", "directory", "modified", "other-tab"]:
        case_env = dict(env, EXPLORER_SCENARIO=scenario, EXPLORER_FIXTURE=directory)
        target = fixture if scenario == "directory" else fixture / "sample.txt"
        result = subprocess.run(
            ["nvim", "--headless", "-i", "NONE", str(target),
             "+luafile " + str(root / "tests/test_explorer_lifecycle.lua")],
            env=case_env, text=True, capture_output=True, timeout=15,
        )
        output = result.stdout + result.stderr
        expected = "READY_FOR_AUTO_EXIT" if scenario == "file" else "EXPLORER_LIFECYCLE_PASS " + scenario
        assert result.returncode == 0 and expected in output, scenario + ": " + output
        assert "Error detected" not in output and "stack traceback" not in output, output
        print(scenario, "PASS")
