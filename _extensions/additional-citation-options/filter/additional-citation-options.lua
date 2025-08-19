-- CitationEnhance.lua
quarto.log.info('Loading additional-citation-options filter')

-- Process Citation
---@param cite pandoc.Cite The Cite that needs to be processed.
local function ProcessParen(cite)
  quarto.log.info("Processing citation")
  quarto.log.debug(cite.content)
  local remove_paren_output = cite:clone()
  local no_paren_output = cite:clone()

  local bracketCount = 0
  local remove_paren_inlines = pandoc.Inlines("")
  local no_paren_inlines = pandoc.Inlines("")

  ---@param inline pandoc.Str|pandoc.Space Inline that needs to be processed.
  local function separateBrackets(inline)
    if bracketCount == 0 then
      if inline.t == "Str" and inline.text:match("%([^%)]+%)") then
        prefix, field = inline.text:match("^(.*)%(([^%)]*)%)$")
        if prefix and #prefix > 0 then
          remove_paren_inlines:insert(prefix)
          no_paren_inlines:insert(prefix)
        end
        if field and #field > 0 and prefix and #prefix > 0 then
          no_paren_inlines:insert(pandoc.Space())
        end
        if field and #field > 0 then
          no_paren_inlines:insert(field)
        end
        bracketCount = 1
      elseif inline.t == "Str" and inline.text:match("%(") then
        prefix, field = inline.text:match("^(.*)%((.*)$")
        if prefix and #prefix > 0 then
          remove_paren_inlines:insert(prefix)
          no_paren_inlines:insert(prefix)
        end
        if field and #field > 0 and prefix and #prefix > 0 then
          no_paren_inlines:insert(pandoc.Space())
        end
        if field and #field > 0 then
          no_paren_inlines:insert(field)
        end
        bracketCount = 1
      else
        remove_paren_inlines:insert(inline)
        no_paren_inlines:insert(inline)
      end
    elseif bracketCount == 1 then
      if inline.t == "Str" and inline.text:match("%)") then
        field, suffix = inline.text:match("^(.*)%)(.*)$")
        if field and #field > 0 then
          no_paren_inlines:insert(field)
        end
        if field and #field > 0 and suffix and #suffix > 0 then
          no_paren_inlines:insert(pandoc.Space())
        end
        if suffix and #suffix > 0 then
          if remove_paren_inlines:at(-1).t == "Str" then
            remove_paren_inlines:insert(pandoc.Space())
          end
          remove_paren_inlines:insert(suffix)
          no_paren_inlines:insert(suffix)
        end
        bracketCount = 2
      else
        no_paren_inlines:insert(inline)
      end
    else
      remove_paren_inlines:insert(inline)
      no_paren_inlines:insert(inline)
    end
  end

  cite.content:walk({
    Str = separateBrackets,
    Space = separateBrackets
  })

  remove_paren_output.content = remove_paren_inlines
  no_paren_output.content = no_paren_inlines

  output = {
    remove_paren = remove_paren_output,
    no_paren = no_paren_output
  }

  quarto.log.debug("Processed output for additional-citation-options filter:")
  quarto.log.debug(output)
  return output
end

---@param span pandoc.Span The Span that needs to be processed.
local function ProcessSpan(span)
  quarto.log.info("Processing span for additional-citation-options filter")
  local output_span = span
  quarto.log.debug(output_span.content)

  local classes = span.classes
  quarto.log.debug("Span classes: " .. table.concat(classes, ", "))
  local remove_paren = false
  local no_paren = false

  -- Check for no-paren and remove-paren classes
  for _, class in ipairs(classes) do
    if class == "remove-paren" then
      remove_paren = true
      quarto.log.debug("- Remove parentheses")
    elseif class == "no-paren" then
      no_paren = true
      quarto.log.debug("- No parentheses")
    end
  end

  -- Apply no-paren or remove-paren processing
  if (remove_paren or no_paren) and span.content[1].t == "Cite" then
    quarto.log.info("- Processing Cite for additional-citation-options filter")
    quarto.log.debug(span.content[1])
    output = ProcessParen(span.content[1])
    if remove_paren then
      quarto.log.debug("- Processed remove_paren output for Cite:")
      quarto.log.debug(output.remove_paren)
      span.content[1] = output.remove_paren
    else
      quarto.log.debug("- Processed no_paren output for Cite:")
      quarto.log.debug(output.no_paren)
      span.content[1] = output.no_paren
    end
  end

  return output_span
end

-- Walk only blocks in body after citeproc
function Pandoc(doc)
  local output = pandoc.utils.citeproc(doc)
  
  for i, block in ipairs(output.blocks) do
    output.blocks[i] = pandoc.walk_block(block, {
        Span = ProcessSpan
    })
  end
  
  return output
end

return {
  { Pandoc = Pandoc }
}