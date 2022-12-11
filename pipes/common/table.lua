table = table or {}

function table:new(o)
    o = o or {}   -- create object if user does not provide one
    return setmetatable(o, {
        __index = table
    })
end