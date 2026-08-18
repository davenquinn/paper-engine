--[[
  task-labels.lua

  Reproduces the LaTeX `tasklist` environment's numbering for non-LaTeX
  writers (principally docx).

  In the LaTeX build, `\Begin{tasklist}` ... `\End{tasklist}` renumbers
  subsections as T1, T2, ... and subsubsections as T1a, T1b, ..., and
  `[@task:some-id]` is rewritten to `[\ref{task:some-id}]`.

  This filter does the same thing on the AST:
    - headings inside the tasklist region get a "T1"/"T1a" prefix, and are
      marked `unnumbered` so the label replaces any section number
    - `[@task:some-id]` cites become a bracketed link to that heading
    - the raw `\Begin{tasklist}` / `\End{tasklist}` blocks are dropped

  Counters follow LaTeX: level-3 counters reset at each level-2 heading,
  and *every* heading in the region advances the counter, whether or not
  it carries a `task:` identifier.

  Must run before --citeproc, which would otherwise treat `@task:...` as a
  missing bibliography entry.
]]

local TASK_PREFIX = "task:"

local labels = {}     -- identifier -> label, e.g. "task:web-editor" -> "T1b"
local warned = {}

local function is_marker(block, which)
  return block.t == "RawBlock"
    and block.text:match("\\" .. which .. "%s*{%s*tasklist%s*}") ~= nil
end

-- 1 -> "a", 2 -> "b", ... 27 -> "aa" (LaTeX \alph breaks past 26; we don't)
local function alph(n)
  local s = ""
  while n > 0 do
    local r = (n - 1) % 26
    s = string.char(97 + r) .. s
    n = (n - 1 - r) / 26
  end
  return s
end

--- Number the tasks. Pandoc walks sibling blocks in document order, so a
--- stateful filter tracks the tasklist region correctly.
local function number_tasks(doc)
  local in_tasklist = false
  local task, subtask = 0, 0

  return doc:walk {
    traverse = "topdown",

    -- Drop the environment delimiters; they mean nothing outside LaTeX.
    RawBlock = function(block)
      if is_marker(block, "Begin") then
        in_tasklist = true
        task, subtask = 0, 0
        return {}
      elseif is_marker(block, "End") then
        in_tasklist = false
        return {}
      end
    end,

    Header = function(head)
      if not in_tasklist then return nil end

      local label
      if head.level == 2 then
        task = task + 1
        subtask = 0
        label = "T" .. task
      elseif head.level == 3 and task > 0 then
        subtask = subtask + 1
        label = "T" .. task .. alph(subtask)
      end
      if not label then return nil end

      if head.identifier:sub(1, #TASK_PREFIX) == TASK_PREFIX then
        labels[head.identifier] = label
      end

      -- The T-label stands in for the section number, so suppress the
      -- writer's own numbering (matters for --number-sections output).
      if not head.classes:includes("unnumbered") then
        head.classes:insert("unnumbered")
      end

      head.content:insert(1, pandoc.Space())
      head.content:insert(1, pandoc.Str(label .. "."))
      return head
    end,
  }
end

--- `[@task:foo]` -> `[T1a]`, linked back to the task heading.
local function resolve_references(doc)
  return doc:walk {
    Cite = function(cite)
      if #cite.citations ~= 1 then return nil end
      local id = cite.citations[1].id
      if id:sub(1, #TASK_PREFIX) ~= TASK_PREFIX then return nil end

      local label = labels[id]
      if not label then
        if not warned[id] then
          warned[id] = true
          io.stderr:write("task-labels: no task heading found for '" .. id .. "'\n")
        end
        return pandoc.Str("[" .. id .. "?]")
      end

      return {
        pandoc.Str("["),
        pandoc.Link(pandoc.Str(label), "#" .. id),
        pandoc.Str("]"),
      }
    end,
  }
end

function Pandoc(doc)
  return resolve_references(number_tasks(doc))
end
