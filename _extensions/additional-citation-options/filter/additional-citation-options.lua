-- One full-document citation pass, followed by bounded presentation changes.
local here = pandoc.path.directory(PANDOC_SCRIPT_FILE)
local parentheses = dofile(pandoc.path.join({here, 'parentheses.lua'}))

local function mode(span)
  local no_paren, remove_paren = false, false
  for _, class in ipairs(span.classes) do
    no_paren = no_paren or class == 'no-paren'
    remove_paren = remove_paren or class == 'remove-paren'
  end
  if no_paren and remove_paren then return 'conflict' end
  if no_paren then return 'no-paren' end
  if remove_paren then return 'remove-paren' end
end

local function has_markers(doc)
  local found = false
  doc:walk({Span = function(span) found = found or mode(span) ~= nil end})
  return found
end

-- Deliberately narrow: default Chicago author-date, or the historical Harvard
-- Manchester fixture pinned in CITE-0. A filename/style title proves no semantics.
local function supported_style(meta)
  if not meta.csl then return true end
  local file = io.open(pandoc.utils.stringify(meta.csl), 'rb')
  if not file then return false end
  local text = file:read('*a')
  file:close()
  text = text:gsub('^\239\187\191', ''):gsub('\r\n', '\n'):match('^%s*(.-)%s*$')
  return pandoc.utils.sha1(text) == '9448498c3f14eee61d08ac5907525b28a0e7e592'
end

local function process(doc)
  local warned = {}
  local warning_count, suppressed_count = 0, 0
  local function warn(code, message, location)
    location = location or 'document'
    local key = code .. ':' .. location
    if warned[key] then return end
    warned[key] = true
    if warning_count >= 20 then
      suppressed_count = suppressed_count + 1
      return
    end
    warning_count = warning_count + 1
    quarto.log.warning('additional-citation-options [' .. code .. ']: ' .. location .. ': ' .. message)
  end
  local marked = has_markers(doc)
  local method = quarto.doc.cite_method()
  local writer_method = PANDOC_WRITER_OPTIONS.cite_method
  if method == 'natbib' or method == 'biblatex'
      or writer_method == 'natbib' or writer_method == 'biblatex'
      or quarto.doc.is_format('typst') then
    if marked then warn('processor', 'Presentation classes are unsupported for this citation processor/output. Remove these classes and use its native citation syntax; citations are left to its native pipeline.') end
    return doc
  end
  if method ~= nil then
    if marked then warn('activation', 'Set citeproc: false when activating this extension. Presentation is unchanged; the configured processor remains responsible for citations.') end
    return doc
  end
  if not doc.meta.bibliography and not doc.meta.references then
    if marked then warn('bibliography', 'Supply bibliography or inline references to render marked citations. Presentation is unchanged.') end
    return doc
  end

  -- Unmarked documents still need their normal full-document citation pass,
  -- but no style fingerprint or second metadata-marker traversal.
  if not marked then return pandoc.utils.citeproc(doc) end

  local style_ok = supported_style(doc.meta)
  -- Metadata citations receive normal full-document processing, but no custom
  -- presentation. Walking this metadata-only document avoids touching the body.
  if has_markers(pandoc.Pandoc({}, doc.meta)) then
    warn('metadata', 'Presentation classes in metadata are unsupported. Remove the classes there or move the citation into the body; normal citation rendering is retained.', 'metadata')
  end
  local output = pandoc.utils.citeproc(doc)
  if not style_ok then
    warn('style', 'This CSL style is outside the tested style contract. Use a supported style or remove the presentation classes; normal citation rendering is retained.')
    return output
  end

  local reason_codes = {
    ['nested parentheses are ambiguous'] = 'parentheses-nested',
    ['multiple parenthesized segments are ambiguous'] = 'parentheses-multiple',
    ['unbalanced parentheses'] = 'parentheses-unbalanced',
    ['no round-parenthesized segment'] = 'parentheses-absent',
    ['parentheses in an unsupported inline structure'] = 'parentheses-structure',
    ['an unsupported inline structure occurs inside the parentheses'] = 'parentheses-structure',
  }
  local span_count = 0
  local function metadata_warning()
    warn('metadata', 'Presentation classes in metadata are unsupported. Remove the classes there or move the citation into the body; normal citation rendering is retained.', 'metadata')
  end
  local function transform_span(span)
    -- Quarto HTML carries metadata through hidden body envelopes for its final
    -- HTML pass. These are metadata copies, not authored body presentation.
    for _, class in ipairs(span.classes) do
      if class == 'quarto-markdown-envelope-contents' then
        if has_markers(pandoc.Pandoc({pandoc.Plain({span})})) then metadata_warning() end
        return span, false
      end
    end
    local selected = mode(span)
    if not selected then return nil end
    span_count = span_count + 1
    local label = selected == 'conflict' and '.no-paren + .remove-paren' or '.' .. selected
    local location = 'body marked span ' .. span_count .. ' (' .. label .. ')'
    local nested = false
    span.content:walk({Span = function(child) nested = nested or mode(child) ~= nil end})
    if selected == 'conflict' or nested then
      warn('conflict', 'Use one presentation class without nested marked spans. This entire marked span is unchanged.', location)
      return span, false
    end
    local count = 0
    span.content = span.content:walk({Cite = function(cite)
      count = count + 1
      local changed, reason = parentheses.transform(cite, selected)
      if changed then return changed end
      warn(reason_codes[reason] or 'parentheses', 'A citation has ' .. reason .. '. Remove its presentation class or simplify the citation; normal presentation is retained.', location .. ', citation ' .. count)
    end})
    if count == 0 then
      warn('empty', 'A marked span contains no citation. Remove the presentation class or add a citation; the span is unchanged.', location)
    end
    return span, false
  end
  -- Top-down traversal plus stop-descent ensures each marked subtree is handled
  -- once, including conflicts. Unmarked wrappers inside it retain their structure.
  output.blocks = output.blocks:walk({
    traverse = 'topdown',
    Div = function(div)
      if div.identifier == 'quarto-meta-markdown' then
        if has_markers(pandoc.Pandoc({div})) then metadata_warning() end
        return div, false
      end
    end,
    Span = transform_span,
  })
  if suppressed_count > 0 then
    quarto.log.warning('additional-citation-options [diagnostics-limit]: ' .. suppressed_count .. ' further diagnostics omitted after the first 20. Fix the reported spans and render again to locate remaining cases.')
  end
  return output
end

return {{Pandoc = process}}
