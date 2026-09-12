local M = {}
function M.install()
    assert(not require("config").get().offline, "离线模式禁止安装")
    assert(vim.env.NVIM_MAINTENANCE == "1", "请通过 install.sh 安装，或明确设置 NVIM_MAINTENANCE=1")
    require("lazy").restore({ wait = true })
    for name, plugin in pairs(require("lazy.core.config").plugins) do
        for _, task in ipairs(plugin._.tasks or {}) do assert(not task:has_errors(), "插件安装失败: " .. name) end
        assert(vim.uv.fs_stat(plugin.dir), "插件缺失: " .. name)
    end
    local plan = require("config").plan()
    if #plan.tools > 0 then
        vim.cmd("MasonToolsInstallSync")
        for _, tool in ipairs(plan.tools) do
            assert(require("mason-registry").get_package(tool):is_installed(), "工具安装失败: " .. tool)
        end
    end
    if #plan.parsers > 0 then
        require("nvim-treesitter").install(plan.parsers):wait(300000)
        local installed = require("nvim-treesitter").get_installed()
        for _, parser in ipairs(plan.parsers) do assert(vim.tbl_contains(installed, parser), "解析器安装失败: " .. parser) end
    end
end
function M.setup()
    vim.api.nvim_create_user_command("ConfigInfo", function()
        vim.print({ config = require("config").get(), dependencies = require("config").plan() })
    end, {})
    vim.api.nvim_create_user_command("ConfigInstall", function()
        if require("config").get().offline then vim.notify("离线模式禁止安装", vim.log.levels.ERROR); return end
        if vim.env.NVIM_MAINTENANCE == "1" then M.install(); return end
        vim.ui.select({ "取消", "安装当前选择" }, { prompt = "安装插件和工具（需要联网）" }, function(choice)
            if choice ~= "安装当前选择" then return end
            vim.system({ "bash", vim.fn.stdpath("config") .. "/install.sh" }, { text = true }, function(result)
                vim.schedule(function() vim.notify(result.stdout .. result.stderr, result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR) end)
            end)
        end)
    end, {})
end
return M
