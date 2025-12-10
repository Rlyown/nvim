return {
    -- TODO: support sidekick.nvim
    {
        "folke/sidekick.nvim",
        opts = {
            -- add any options here
            cli = {
                mux = {
                    backend = "tmux",
                    enabled = true,
                },
            },
        },
        keys = {
            -- {
            --     "<tab>",
            --     function()
            --         -- if there is a next edit, jump to it, otherwise apply it if any
            --         if not require("sidekick").nes_jump_or_apply() then
            --             return "<Tab>" -- fallback to normal tab
            --         end
            --     end,
            --     expr = true,
            --     desc = "Goto/Apply Next Edit Suggestion",
            -- },
            {
                "<c-.>",
                function() require("sidekick.cli").toggle() end,
                desc = "Sidekick Toggle",
                mode = { "n", "t", "i", "x" },
            },
            {
                "<leader>aa",
                function() require("sidekick.cli").toggle() end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<leader>as",
                function() require("sidekick.cli").select() end,
                -- Or to select only installed tools:
                -- require("sidekick.cli").select({ filter = { installed = true } })
                desc = "Select CLI",
            },
            {
                "<leader>ad",
                function() require("sidekick.cli").close() end,
                desc = "Detach a CLI Session",
            },
            {
                "<leader>at",
                function() require("sidekick.cli").send({ msg = "{this}" }) end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<leader>af",
                function() require("sidekick.cli").send({ msg = "{file}" }) end,
                desc = "Send File",
            },
            {
                "<leader>av",
                function() require("sidekick.cli").send({ msg = "{selection}" }) end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ap",
                function() require("sidekick.cli").prompt() end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
            -- Example of a keybinding to open Claude directly
            {
                "<leader>ac",
                function() require("sidekick.cli").toggle({ name = "codex", focus = true }) end,
                desc = "Sidekick Toggle Codex",
            },
        },
    },
    -- {
    --     "yetone/avante.nvim", -- AI IDE
    --     event = "VeryLazy",
    --     lazy = false,
    --     version = false, -- set this to "*" if you want to always pull the latest change, false to update on release
    --     opts = {
    --         provider = os.getenv("AVANTE_PROVIDER") or "openai",
    --         ---@alias Mode "agentic" | "legacy"
    --         ---@type Mode
    --         mode = "legacy", -- The default mode for interaction. "agentic" uses tools to automatically generate code, "legacy" uses the old planning method to generate code.
    --         -- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
    --         -- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
    --         -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
    --         auto_suggestions_provider = os.getenv("AVANTE_PROVIDER") or "openai",
    --         providers = {
    --             openai = {
    --                 endpoint = os.getenv("AVANTE_OPENAI_ENDPOINT") or "https://api.openai-proxy.org/v1",
    --                 model = os.getenv("AVANTE_OPENAI_MODEL") or "gpt-3.5-turbo",
    --                 extra_request_body = {
    --                     temperature = 1,
    --                     -- max_tokens = 20480,
    --                 },
    --             },
    --             copilot = {
    --                 proxy = "localhost:7890",
    --                 model = os.getenv("AVANTE_COPILOT_MODEL") or "gpt-4.1",
    --                 disabled_tools = {
    --                     "list_files",
    --                     "search_files",
    --                     "read_file",
    --                     "create_file",
    --                     "rename_file",
    --                     "delete_file",
    --                     "create_dir",
    --                     "rename_dir",
    --                     "delete_dir",
    --                     "bash",
    --                 },
    --             },
    --         },
    --         -- other config
    --         -- The system_prompt type supports both a string and a function that returns a string. Using a function here allows dynamically updating the prompt with mcphub
    --         system_prompt = function()
    --             local hub = require("mcphub").get_hub_instance()
    --             return hub:get_active_servers_prompt()
    --         end,
    --         -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
    --         custom_tools = function()
    --             return {
    --                 require("mcphub.extensions.avante").mcp_tool(),
    --             }
    --         end,
    --     },
    --     -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    --     build = "make",
    --     -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",
    --         "MunifTanjim/nui.nvim",
    --         'MeanderingProgrammer/render-markdown.nvim',
    --     },
    -- },
    -- {
    --     "ravitemer/mcphub.nvim",
    --     dependencies = {
    --         "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
    --     },
    --     -- uncomment the following line to load hub lazily
    --     --cmd = "MCPHub",  -- lazy load
    --     build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
    --     -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    --     -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    --     opts = {
    --         auto_approve = false,
    --         extensions = {
    --             avante = {
    --                 make_slash_commands = true, -- make /slash commands from MCP server prompts
    --             }
    --         },
    --         -- Debug mode to help diagnose issues
    --         debug = false
    --     },
    -- }
}
