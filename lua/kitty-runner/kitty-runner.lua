--
-- KITTY RUNNER
--

local config = require("kitty-runner.config")
local fn = vim.fn
local Job = require 'plenary.job'

local M = {}

local whole_command
local runner_is_open = false

local function send_kitty_command(cmd_args, command, empty_args)
  local args
  if empty_args == nil then
    args = { "@", "--to=" .. config["kitty_port"] }
  else
    args = {}
  end

  for _, v in pairs(cmd_args) do
    table.insert(args, v)
  end

  table.insert(args, command)

  Job:new({
    command = config["kitty_executable"],
    args = args,
  }):start()
end

local function open_and_or_send(command)
  if runner_is_open then
    send_kitty_command(config["clear_command"], nil)
    send_kitty_command(config["run_cmd"], command)
  else
    M.open_runner()
    -- TODO: fix this hack
    os.execute("sleep .3")
    send_kitty_command(config["run_cmd"], command)
  end
end

local function prepare_command(region)
  local lines
  if region[1] == 0 then
    lines = vim.api.nvim_buf_get_lines(
      0,
      vim.api.nvim_win_get_cursor(0)[1] - 1,
      vim.api.nvim_win_get_cursor(0)[1],
      true
    )
  else
    lines = vim.api.nvim_buf_get_lines(0, region[1] - 1, region[2], true)
  end
  local command = table.concat(lines, "\r") .. "\r"
  return command
end

function M.open_runner()
  if runner_is_open == false then
    local args = {
      "--override", "env=IS_RUNNER=true",
      "--override", "allow_remote_control=true",
      "--listen-on=" .. config["kitty_port"],
      -- "--title=" .. config["runner_name"],
    }

    for _, v in pairs(config["win_args"]) do
      table.insert(args, v)
    end

    table.insert(args, "--")

    send_kitty_command(args, nil, true)
    runner_is_open = true
  end
end

function M.run_command(command)
  open_and_or_send(command .. "\n")
end

function M.send_key(key)
  if runner_is_open == true then
    send_kitty_command(config["send_key_cmd"], key)
  end
end

function M.run_command_from_region(region)
  whole_command = prepare_command(region)
  -- delete visual selection marks
  vim.cmd([[delm <>]])
  open_and_or_send(whole_command)
end

function M.re_run_command()
  if whole_command then
    open_and_or_send(whole_command)
  end
end

function M.prompt_run_command()
  fn.inputsave()
  local command = fn.input("Command: ")
  fn.inputrestore()
  whole_command = command .. "\r"
  open_and_or_send(whole_command)
end

function M.kill_runner()
  if runner_is_open == true then
    send_kitty_command(config["kill_cmd"], nil)
    runner_is_open = false
  end
end

function M.clear_runner()
  if runner_is_open == true then
    send_kitty_command(config["clear_command"], nil)
    send_kitty_command(config["run_cmd"], "clear\r")
  end
end

function M.focus_runner()
  if runner_is_open == true then
    local args = config["focus_cmd"]

    send_kitty_command(args, nil)
  end
end

return M
