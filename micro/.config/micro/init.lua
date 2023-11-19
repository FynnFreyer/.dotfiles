local config = import("micro/config")
local shell = import("micro/shell")

function init()
    -- true means overwrite any existing binding to Ctrl-r
    -- this will modify the bindings.json file
    config.TryBindKey("Ctrl-Alt-l", "lua:initlua.pyfmtlnt", true)
end

function pyfmtlnt(bp)
    local buf = bp.Buf
    if buf:FileType() == "python" then
        -- first bool decides whether to run in the foreground
        -- second bool false means send output to stdout (instead of returning it)
        -- shell.RunInteractiveShell("python -m black " .. buf.Path, false, false)
        shell.RunInteractiveShell("python -m black " .. buf.Path, false, true)
        buf.ReOpen(buf)
    end
end
