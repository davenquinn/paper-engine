--[[
  page-breaks.lua

  `\newpage` is meaningful only to LaTeX. This translates it for the other
  writers so a single source can produce a paginated docx or HTML preview.
]]

local BREAKS = {
  docx = pandoc.RawBlock("openxml",
    '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'),
  html = pandoc.RawBlock("html",
    '<div style="page-break-after: always;"></div>'),
}

function RawBlock(block)
  if not block.format:match("^tex") and not block.format:match("^latex") then
    return nil
  end
  if not block.text:match("^%s*\\newpage%s*$") then return nil end

  if FORMAT:match("^latex") or FORMAT:match("^beamer") then return nil end
  if FORMAT:match("docx") then return BREAKS.docx end
  if FORMAT:match("html") then return BREAKS.html end
  return {}
end
