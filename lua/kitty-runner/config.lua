--
-- KITTY RUNNER | CONFIG
--

local cmd = vim.cmd
local nvim_set_keymap = vim.keymap.set

-- get uuid
local function get_uuid()
  local uuid_handle = io.popen([[uuidgen]])
  local uuid = uuid_handle:read("*l")
  uuid_handle:close()
  return uuid
end

local uuid = get_uuid()
local prefix = "kitty-runner-"

-- default configulation values
local default_config = {
  kitty_executable = "kitty",
  runner_name = prefix .. uuid,
  send_key_cmd = { "--send-key", "--match=title:" .. prefix .. uuid, "--" },
  focus_cmd = { "focus-window", "--match=title:" .. prefix .. uuid },
  clear_command = { "scroll-window", "--match=title:" .. prefix .. uuid, "end" },
  kill_cmd = { "close-window", "--match=title:" .. prefix .. uuid },
  use_keymaps = true,
  kitty_port = "unix:/tmp/kitty",
  win_args = { "--class=kitty-runner", "--directory=" .. vim.fn.getcwd(), },
  kill_on_quit = true,
}

local M = vim.deepcopy(default_config)

-- configuration update function
M.update = function(opts)
  local newconf = vim.tbl_deep_extend("force", default_config, opts or {})
  for k, v in pairs(newconf) do
    M[k] = v
  end
end

-- define default commands
M.define_commands = function()
  cmd([[
    command! KittyReRunCommand lua require('kitty-runner').re_run_command()
    command! -range KittySendLines lua require('kitty-runner').run_command_from_region(vim.region(0, vim.fn.getpos("'<"), vim.fn.getpos("'>"), "l", false)[0])
    command! KittyRunCommand lua require('kitty-runner').prompt_run_command()
    command! KittyClearRunner lua require('kitty-runner').clear_runner()
    command! KittyOpenRunner lua require('kitty-runner').open_runner()
    command! KittyKillRunner lua require('kitty-runner').kill_runner()
    command! KittyFocusRunner lua require('kitty-runner').focus_runner()
  ]])
end

-- define default keymaps
M.define_keymaps = function()
  nvim_set_keymap(
    "n",
    "<Leader>tr",
    ":KittyRunCommand<cr>",
    { silent = true, desc = "Prompt for a command and send it to kitty" }
  )
  nvim_set_keymap(
    "x",
    "<Leader>ts",
    ":KittySendLines<cr>",
    { silent = true, desc = "Send the the current line or visual selection to kitty" }
  )
  nvim_set_keymap(
    "n",
    "<Leader>tc",
    ":KittyClearRunner<cr>",
    { silent = true, desc = "Clear the kitty runners screen" }
  )
  nvim_set_keymap(
    "n",
    "<Leader>tk",
    ":KittyKillRunner<cr>",
    { silent = true, desc = "Kill the kitty runner" }
  )
  nvim_set_keymap(
    "n",
    "<Leader>tl",
    ":KittyReRunCommand<cr>",
    { silent = true, desc = "Run the last kitty command again" }
  )
  nvim_set_keymap(
    "n",
    "<Leader>to",
    ":KittyOpenRunner<cr>",
    { silent = true, desc = "Open a new kitty runner" }
  )
  nvim_set_keymap(
    "n",
    "<Leader>tf",
    ":KittyFocusRunner<cr>",
    { silent = true, desc = "Focus the kitty runner window" }
  )
end

return M
