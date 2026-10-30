-- Candidate only: explicit, finite metadata presentation contexts.
-- This module neither runs citeproc nor changes body/Quarto envelope copies.
local M = {}

function M.selected(meta)
  local option = meta['additional-citation-options']
  if option == nil then return {} end
  if pandoc.utils.type(option) ~= 'table' then return {}, 'Expected additional-citation-options: {metadata: [abstract]}.' end
  for key in pairs(option) do
    if key ~= 'metadata' then return {}, 'Unknown Additional Citation Options setting; only metadata: [abstract] is available in this candidate.' end
  end
  local values = option.metadata
  if values == nil then return {} end
  if pandoc.utils.type(values) ~= 'List' or #values > 1 then return {}, 'metadata must be an empty list or [abstract].' end
  for key in pairs(values) do
    if key ~= 1 then return {}, 'metadata must be an empty list or [abstract].' end
  end
  if #values == 0 then return {} end
  if pandoc.utils.stringify(values[1]) ~= 'abstract' then return {}, 'Only the explicit abstract metadata context is available in this candidate.' end
  return {abstract = true}
end

function M.has_unselected_markers(meta, selected, has_markers)
  local unselected = {}
  for key, value in pairs(meta) do
    if not selected[key] then unselected[key] = value end
  end
  return has_markers(pandoc.Pandoc({}, unselected))
end

-- Use the same already-rendered citation presentation function as the body.
-- A metadata-only document retains the original native MetaBlocks/MetaInlines.
function M.transform_abstract(meta, selected, transform_span)
  if not selected.abstract or meta.abstract == nil then return meta end
  local abstract = pandoc.Pandoc({}, {abstract = meta.abstract})
  abstract = abstract:walk({traverse = 'topdown', Span = transform_span})
  meta.abstract = abstract.meta.abstract
  return meta
end

return M
