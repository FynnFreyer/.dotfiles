function BlockQuote(el)
  if #el.content >= 1 and el.content[1].t == "Para" then
    local p = el.content[1]
    if #p.content >= 1 and p.content[1].t == "Str" then
      local alert_type = p.content[1].text:match("^%[%!(%a+)%]$")
      
      if alert_type then
        p.content:remove(1)
        
        if #p.content >= 1 and (p.content[1].t == "Space" or p.content[1].t == "SoftBreak") then
          p.content:remove(1)
        end
        
        if #p.content == 0 then
          el.content:remove(1)
        end
        
        return pandoc.Div(el.content, pandoc.Attr("", {alert_type:lower()}))
      end
    end
  end
end
