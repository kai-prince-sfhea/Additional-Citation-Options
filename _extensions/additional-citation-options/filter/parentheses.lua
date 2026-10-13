-- Edit rendered citation punctuation without reconstructing its inline tree.
local M = {}

local containers = {
  Emph = true,
  Underline = true,
  Strong = true,
  Strikeout = true,
  Superscript = true,
  Subscript = true,
  SmallCaps = true,
  Quoted = true,
  Link = true,
  Span = true,
}

local breaks = { Space = true, SoftBreak = true, LineBreak = true }

-- A numeric stream keeps one value per byte or opaque inline. Negative values
-- cannot collide with UTF-8 bytes; ASCII is the only punctuation we interpret.
local opaque, unsafe = -1, -2

local function whitespace(unit)
  return unit == 32 or unit == 9 or unit == 13 or unit == 10
end

local function opaque_text(inline)
  -- stringify omits some raw content, so inspect the text field as well.
  local ok, text = pcall(pandoc.utils.stringify, inline)
  if not ok then
    return nil
  end
  if inline.t == "Code" or inline.t == "Math" or inline.t == "RawInline" then
    text = text .. inline.text
  end
  return text
end

-- Positions are bytes within Str nodes, never reconstructed Unicode characters.
-- Only ASCII delimiters/whitespace are edited; non-breaking spaces stay intact.
local function scan(inlines, units)
  for _, inline in ipairs(inlines) do
    if inline.t == "Str" then
      local text = inline.text
      for position = 1, #text do
        units[#units + 1] = text:byte(position)
      end
    elseif breaks[inline.t] then
      units[#units + 1] = 32
    elseif containers[inline.t] then
      scan(inline.content, units)
    else
      local text = opaque_text(inline)
      units[#units + 1] = (text == nil or text:find("[()]") ~= nil) and unsafe or opaque
    end
  end
end

local function find_pair(units)
  local opening, closing
  for position, unit in ipairs(units) do
    if unit == unsafe then
      return nil, nil, "parentheses in an unsupported inline structure"
    elseif unit == 40 then
      if opening and not closing then
        return nil, nil, "nested parentheses are ambiguous"
      elseif closing then
        return nil, nil, "multiple parenthesized segments are ambiguous"
      end
      opening = position
    elseif unit == 41 then
      if not opening or closing then
        return nil, nil, "unbalanced parentheses"
      end
      closing = position
    end
  end
  if opening and not closing then
    return nil, nil, "unbalanced parentheses"
  elseif not opening then
    return nil, nil, "no round-parenthesized segment"
  end
  for position = opening + 1, closing - 1 do
    if units[position] == opaque then
      return nil, nil, "an unsupported inline structure occurs inside the parentheses"
    end
  end
  return opening, closing
end

local function has_content(units, first, last)
  for position = first, last do
    if not whitespace(units[position]) then
      return true
    end
  end
  return false
end

local function trim_before(units, erased, position)
  while position >= 1 and whitespace(units[position]) do
    erased[position] = true
    position = position - 1
  end
end

local function trim_after(units, erased, position)
  while position <= #units and whitespace(units[position]) do
    erased[position] = true
    position = position + 1
  end
end

-- This walk owns the already cloned tree. Copy each kept run of a Str once,
-- rather than allocating a substring per byte or cloning its ancestors again.
local function edit(inlines, erased, cursor)
  local result = pandoc.Inlines({})
  for _, inline in ipairs(inlines) do
    if inline.t == "Str" then
      local kept, first = nil, 1
      local text = inline.text
      for position = 1, #text do
        cursor.position = cursor.position + 1
        if erased[cursor.position] then
          kept = kept or {}
          if first < position then
            kept[#kept + 1] = text:sub(first, position - 1)
          end
          first = position + 1
        end
      end
      if not kept then
        result:insert(inline)
      elseif first <= #text then
        kept[#kept + 1] = text:sub(first)
      end
      if kept and #kept > 0 then
        inline.text = table.concat(kept)
        result:insert(inline)
      end
    elseif containers[inline.t] then
      local was_empty = #inline.content == 0
      inline.content = edit(inline.content, erased, cursor)
      -- Drop a wrapper only when all of its original content was removed.
      if #inline.content > 0 or was_empty then
        result:insert(inline)
      end
    else
      cursor.position = cursor.position + 1
      if not erased[cursor.position] then
        result:insert(inline)
      end
    end
  end
  return result
end

-- Return a cloned Cite on success, or nil and a bounded unsupported-case reason.
function M.transform(cite, mode)
  if mode ~= "no-paren" and mode ~= "remove-paren" then
    return nil, "unknown punctuation transformation"
  elseif not cite or cite.t ~= "Cite" then
    return nil, "expected a Cite inline"
  end

  local units = {}
  scan(cite.content, units)
  local opening, closing, reason = find_pair(units)
  if not opening then
    return nil, reason
  end

  local erased = {}
  if mode == "no-paren" then
    erased[opening], erased[closing] = true, true
  else
    for position = opening, closing do
      erased[position] = true
    end
    local prefix = has_content(units, 1, opening - 1)
    local suffix = has_content(units, closing + 1, #units)
    if not suffix then
      trim_before(units, erased, opening - 1)
    end
    if not prefix then
      trim_after(units, erased, closing + 1)
    elseif suffix and whitespace(units[opening - 1]) and whitespace(units[closing + 1]) then
      -- Join existing whitespace runs once; never manufacture a separator.
      trim_after(units, erased, closing + 1)
    end
  end

  local copy = cite:clone()
  copy.content = edit(copy.content, erased, { position = 0 })
  return copy
end

return M
