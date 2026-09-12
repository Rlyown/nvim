# 模块化配置与迁移

共享配置入口为 `lua/config/user.lua`。机器差异写入被忽略的 `lua/config/local.lua`；修改后重启。

```lua
return {
    profile = "minimal",
    languages = { python = true, lua = true },
    features = { dap = true, ai = false, copilot = false },
}
```

`minimal` 默认提供编辑、搜索、Git、终端、文件树、补全、UI、会话和 Tree-sitter，不选择语言服务器。`developer` 在此基础上启用 C/C++、Go、Rust、Python。LaTeX、SQL、AI、Copilot、远程开发、图像和公式转换均需显式选择。

优先级为预设 → 共享用户配置 → 本地覆盖 → 环境变量；`NVIM_OFFLINE=1` 最后强制关闭 AI、Copilot 和远程开发。`NVIM_PROFILE` 选择预设，`NVIM_LANGUAGES` 替换语言集合，`NVIM_FEATURES=dap,ai,-images` 设置功能。旧 `NVIM_ENABLE_LANGS` / `NVIM_DISABLE_LANGS` 兼容一版，新变量优先。未知名称和值报错。

## 安装与更新

需要 Neovim 0.12.4。先查看安装计划：

```sh
./install.sh --profile minimal --dry-run
./install.sh --profile developer --features dap --dry-run
./install.sh --languages python,tex --features formulas
./install.sh --profile developer --no-plugin-sync
```

安装器使用同一 Lua 解析器汇总依赖，将选择保存到本地覆盖文件。字体、Kitty、公式转换按功能选择安装；安装默认恢复锁文件。`--no-plugin-sync` 仅安装系统依赖并保存选择。`--restore-lock` 保留兼容；`--disable-go` 等旧参数仍可使用。

日常启动不安装 Mason 工具、解析器或更新插件。全新运行时先询问是否安装插件；无界面的启动不自动确认。`:ConfigInstall` 明确确认后调用安装器。`:ConfigInfo` 显示有效配置与每项依赖的来源；`:checkhealth config` 报告缺少的插件、工具、解析器与回收站程序。

显式更新：`scripts/sync_plugins.sh --restore-lock=0`。离线包更新：`bin/nvim-offline-update --online`，先备份插件、Mason 数据和锁文件，再临时进入在线维护模式。

## 快捷键迁移

全局 leader 为逗号，localleader 为空格。插件功能关闭后不注册映射和分组。

| 旧入口 | 新入口 | 功能 |
| --- | --- | --- |
| `,w` / `,W` | `,fw` / `,fW` | 保存 / 管理员保存 |
| 旧文件树入口 | `,fe` | Snacks 文件树及当前文件定位 |
| Telescope 文件/文本搜索 | `,ff` / `,sg` | 文件 / 项目文本 |
| `,B…` | `,bb`、`,bn`、`,bp`、`,bd` | 选择、切换、关闭缓冲区 |
| `,L…` | `,cd`、`,cr`、`,ch`、`,cn`、`,ca`、`,cf` | 定义、引用、帮助、重命名、动作、格式化 |
| `,lg…` / `,lr…` / `,lt…` | 空格 `r/t/b/a/h` | 文件类型局部运行、测试、构建、动作、帮助 |
| `,P…` | `,pl`、`,ps`、`,pd`、`,pc` | 会话 |
| Hydra 调试步进 | `,di`、`,do`、`,dO` | 步入、步过、步出 |
| Telescope DAP 列表 | `,du` | DAP UI 栈、变量和断点 |
| SnipRun | `,tc`、可视模式 `,tl` / `,ts` | 发送当前行、选中整行、精确选区 |
| 终端布局 | `,th` / `,tv` / `,tf` / `,tt` | 横向 30%、纵向 40%、浮动、标签页 |
| 配置检查 | `,ui` / `,uh` | 有效配置 / 健康检查 |

终端前加计数选择 ID，例如 `2,th`。ID 在当前会话内稳定，首次创建的目录保持不变；切换布局复用相同终端 buffer 和进程。`,ta` 切换全部终端。发送代码时输入已存在的 ID，取消不发送；退出的进程不会隐式重启。

LSP 映射仅在客户端支持相应能力时出现，最后一个支持该能力的客户端分离后清理。格式化每种语言只有一个默认客户端：Python 使用 none-ls/Black，Go 使用 gopls，Rust 使用 rust-analyzer，C/C++ 使用 clangd。通过 `vim.g.config_autoformat = false` 关闭保存时格式化。

## 文件树交互

使用 Snacks 默认工作流：`a` 创建、`r` 重命名、`c` 复制到指定位置、`x` 剪切、`p` 粘贴、`y` 复制路径、`H` 隐藏文件、`I` 忽略文件、`<BS>` 上级目录、`.` 将选中目录作为树根。`Ctrl-x` 横向分屏、`Ctrl-v` 纵向分屏、`Ctrl-t` 标签页打开。

`d` 移入回收站，`D` 永久删除，均需明确确认。缺少 `trash` / `gio` 或程序执行失败时不会回退永久删除。剪切粘贴遇到目标已存在或跨设备重命名失败时保留源文件并提示。树根变化不修改全局工作目录；Snacks 的 `Ctrl-c` 是显式修改当前标签页目录的独立动作。

## 扩展能力

在 `lua/config/capabilities.lua` 的 `languages` 中添加语言，声明 `ft`、`servers`、Mason `tools`、`parsers`、`system`、`format`、`formatter` 和可选 `debug`。例如：

```lua
lua = {
    ft = { "lua" }, servers = { "lua_ls" },
    tools = { "lua-language-server", "stylua" }, parsers = { "lua", "luadoc" },
    formatter = "stylua", format = "null-ls",
},
```

专用插件放在 `lua/plugins/languages/` 并在 `config/specs.lua` 显式接入；辅助函数放 `lua/modules/`，不参与 Lazy 自动扫描。新增系统能力还需在 `scripts/system-packages.lua` 声明平台包名。快捷键直接由所属功能定义，which-key 仅展示。

已移除 nvim-tree、ToggleTerm、OpenCode、Portal、Harpoon、Grapple、Illuminate、Hydra、SnipRun，以及 Telescope 的 fzf、neoclip、DAP 扩展。Telescope 只作为远程包的私有依赖。Markdown 基础渲染保留；公式转换需 `formulas`。Sidekick 与 Copilot 独立，基础 Tab 补全不会加载 AI。旧导航收藏和剪贴板/宏历史入口不保留。

## 离线分发与测试

```sh
scripts/build-offline-bundle.sh --profile minimal --version minimal
scripts/build-offline-bundle.sh --profile developer --features dap --version developer-dap
bash tests/test_offline_bundle.sh dist/nvim-offline-linux-x86_64-minimal.tar.zst
```

离线包的 manifest 包含配置、插件提交和工具清单。目标是 Ubuntu 24.04 Linux x86_64；项目工具链仍需目标机具备。离线禁用 Crates 的在线索引查询。`lite.lua` 继续作为独立零插件入口。

本地测试使用 `tests/prepare_runtime.py` 从已有插件仓库的锁定提交生成临时运行时，不能把生产数据目录作为测试目录。`NVIM_LOCKFILE` 可以指定独立锁文件。配置解析、安全行为、键位冲突与终端测试见 `tests/test_config.lua`、`tests/test_safety.lua`、`tests/check_keymaps.lua`、`tests/test_runtime.lua`。
