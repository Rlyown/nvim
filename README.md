# Neovim 模块化配置

面向 Neovim 0.12.4。默认 `minimal` 提供基础编辑、Snacks 搜索/文件树/终端、Git、Blink 补全、Tree-sitter 和 UI。`developer` 额外选择 C/C++、Go、Rust、Python。

```sh
./install.sh --profile minimal --dry-run
./install.sh --profile developer --features dap
```

共享入口是 `lua/config/user.lua`；机器配置写入被忽略的 `lua/config/local.lua`。功能修改后重启。`:ConfigInfo` 查看有效配置，`:ConfigInstall` 安装选择，`:checkhealth config` 检查依赖。

完整说明见 [配置与快捷键迁移](docs/modular-config.md)。AI、Copilot、LaTeX、数据库、远程开发、图像和公式转换默认关闭。

受控环境下的启动与首次调用测量见 [性能基线](docs/performance-baseline.md)。

## 独立轻量模式

`nvim -u /path/to/lite.lua` 使用零插件入口，适合临时服务器。验证：`bash tests/test_lite.sh`。

## 离线包

```sh
scripts/build-offline-bundle.sh --profile minimal --version minimal
scripts/build-offline-bundle.sh --profile developer --features dap --version developer-dap
bash tests/test_offline_bundle.sh dist/nvim-offline-linux-x86_64-minimal.tar.zst
```

解压后运行 `bin/nvim-offline`。默认禁止安装和更新，AI/Copilot 强制关闭。显式在线更新使用 `bin/nvim-offline-update --online`，更新前创建备份。

## 目录

- `lua/core/`：基础选项、键位、通用事件、Lazy 入口。
- `lua/config/`：配置解析、能力目录、插件组合、安装与健康检查。
- `lua/plugins/`：按功能组织的 Lazy 规格；语言专用规格在 `languages/`。
- `lua/modules/`：终端、文件树、LSP 等辅助逻辑。
- `scripts/`：共享解析器驱动的安装和离线分发。
- `tests/`：隔离运行时、配置、映射、终端、安全与离线验证。
