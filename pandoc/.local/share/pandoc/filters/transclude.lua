--- include-files.lua – filter to include Markdown files
---
--- Copyright: © 2019–2021 Albert Krewinkel
--- License:   MIT – see LICENSE file for details

-- Module pandoc.path is required and was added in version 2.12
PANDOC_VERSION:must_be_at_least '2.12'

local List = require 'pandoc.List'
local path = require 'pandoc.path'
local system = require 'pandoc.system'

--- Get include auto mode
local include_auto = false
function get_vars (meta)
  if meta['include-auto'] then
    include_auto = true
  end
end

--- Keep last heading level found
local last_heading_level = 0
function update_last_level(header)
  last_heading_level = header.level
end

--- Update contents of included file
local function update_contents(blocks, shift_by, include_path)
  local update_contents_filter = {
    -- Shift headings in block list by given number
    Header = function (header)
      if shift_by then
        header.level = header.level + shift_by
      end
      return header
    end,
    -- If image paths are relative then prepend include file path
    Image = function (image)
      if path.is_relative(image.src) then
        image.src = path.normalize(path.join({include_path, image.src}))
      end
      return image
    end,
    -- Update path for include-code-files.lua filter style CodeBlocks
    CodeBlock = function (img)
      if img.attributes.include and path.is_relative(img.attributes.include) then
        img.attributes.include =
          path.normalize(path.join({include_path, img.attributes.include}))
        end
      return img
    end
  }

  return pandoc.walk_block(pandoc.Div(blocks), update_contents_filter).content
end

--- Filter function for code blocks
local transclude
function transclude (img)
  -- Markdown is used if this is nil.
  -- local format = img.attributes['format']
  if not img.src:match '.md$' then
    return
  end
  -- TODO look at file suffix to determine
  local format = nil

  -- Auto shift headings
  shift_heading_level_by = last_heading_level

  --- keep track of level before recusion
  local buffer_last_heading_level = last_heading_level

  local blocks = List:new()
  local fh = io.open(img.src)
  if not fh then
    io.stderr:write("Cannot open file " .. img.src .. " | Skipping includes\n")
  else
    -- read file as the given format with global reader options
    local contents = pandoc.read(
      fh:read '*a',
      format,
      PANDOC_READER_OPTIONS
    ).blocks
    last_heading_level = 0
    -- recursive transclusion
    contents = system.with_working_directory(
        path.directory(img.src),
        function ()
          return pandoc.walk_block(
            pandoc.Div(contents),
            { Header = update_last_level, Image = transclude }
          )
        end).content
    --- reset to level before recursion
    last_heading_level = buffer_last_heading_level
    contents = update_contents(contents, shift_heading_level_by, path.directory(img.src))
    io.stderr:write("TEST\n")
    fh:close()
  end
  return contents
end

return {
  { Meta = get_vars },
  { Header = update_last_level, Image = transclude }
}