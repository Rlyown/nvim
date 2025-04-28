return {
    {
        "yetone/avante.nvim", -- AI IDE
        event = "VeryLazy",
        lazy = false,
        version = false, -- set this to "*" if you want to always pull the latest change, false to update on release
        opts = {
            provider = "copilot",
            auto_suggestions_provider = "copilot",
            copilot = {
                proxy = "localhost:7890",
                model = "claude-3.7-sonnet",
                disable_tools = {
                    disabled_tools = {
                        "list_files",
                        "search_files",
                        "read_file",
                        "create_file",
                        "rename_file",
                        "delete_file",
                        "create_dir",
                        "rename_dir",
                        "delete_dir",
                        "bash",
                    },
                }
            },
            -- other config
            -- The system_prompt type supports both a string and a function that returns a string. Using a function here allows dynamically updating the prompt with mcphub
            system_prompt = function()
                local hub = require("mcphub").get_hub_instance()
                return hub:get_active_servers_prompt()
            end,
            -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
            custom_tools = function()
                return {
                    require("mcphub.extensions.avante").mcp_tool(),
                }
            end,
            -- file_selector = {
            --     --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string | fun(params: avante.file_selector.IParams|nil): nil
            --     provider = "telescope",
            --     -- Options override for custom providers
            --     provider_opts = {},
            -- }

        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        use_absolute_path = false,
                    },
                },
                keys = {
                    {
                        "<leader>p",
                        function()
                            local telescope = require("telescope.builtin")
                            local actions = require("telescope.actions")
                            local action_state = require("telescope.actions.state")

                            telescope.find_files({
                                attach_mappings = function(_, map)
                                    local function embed_image(prompt_bufnr)
                                        local entry = action_state.get_selected_entry()
                                        local filepath = entry[1]
                                        actions.close(prompt_bufnr)

                                        local img_clip = require("img-clip")
                                        img_clip.paste_image(nil, filepath)
                                    end

                                    map("i", "<CR>", embed_image)
                                    map("n", "<CR>", embed_image)

                                    return true
                                end,
                            })
                        end,
                        desc = "Select image to paste"
                    },
                }
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },
    {
        "ravitemer/mcphub.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
        },
        -- uncomment the following line to load hub lazily
        --cmd = "MCPHub",  -- lazy load
        build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
        -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
        -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
        opts = {
            extensions = {
                avante = {
                    make_slash_commands = true, -- make /slash commands from MCP server prompts
                }
            }
        },
    }
}
