function BlockQuote(el)
  if #el.content >= 1 and el.content[1].t == "Para" then
    local p = el.content[1]
    if #p.content >= 1 and p.content[1].t == "Str" then
      -- Match letters, numbers, hyphens. Ignore Obsidian's trailing + or -
      local alert_type = p.content[1].text:match("^%[%!([%w%-]+)%][%+%-]?$")
      
      if alert_type then
        p.content:remove(1)
        
        -- Remove the immediate space/break after the marker
        if #p.content >= 1 and (p.content[1].t == "Space" or p.content[1].t == "SoftBreak") then
          p.content:remove(1)
        end
        
        -- Remove the paragraph if it's empty (no title provided)
        if #p.content == 0 then
          el.content:remove(1)
        end
        
        return pandoc.Div(el.content, pandoc.Attr("", {alert_type:lower()}))
      end
    end
  end
end
