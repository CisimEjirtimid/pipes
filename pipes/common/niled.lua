require "common.cond"
require "common.table"

-- weak table for representing proxied storage tables.
local data = setmetatable({}, {
    __mode = 'k'
})

local function exists(t, k)
  local d = data[t]
  return (d and d[k]) ~= nil
end

-- nil placeholder.
-- Note: this value is not exposed outside this module, so
-- there's typically no possibility that a user could attempt
-- to store a "nil placeholder" in a table, leading to the
-- same problem as storing nils in tables.
local NIL = setmetatable({}, {
    __tostring = function()
        return "nil"
    end
})

local meta = {
    __index = function (t, k)

        local cond_fn = function (value)
            return k == value
        end

        if cond.any_of(cond_fn, "insert", "pack", "unpack") then
            return table[k]
        end

        if cond.any_of(cond_fn, "new", "remove", "concat", "array") then
            return niled[k]
        end

        local d = data[t]
        local v = d and d[k]

        if v == NIL then
            v = nil
        end

        return v
    end,

    __newindex = function (t, k, v)
        if v == nil then
            v = NIL
        end

        local d = data[t]
        if not d then
            d = {}
            data[t] = d
        end

        d[k] = v
    end,

    __len = function (t)
        local d = data[t]
        return d and #d or 0
    end,

    -- pairs replacement that handles nil values in tables.
    __pairs = function (t)
        local function pairs_iter(t, k)
            local d = data[t]
            if not d then
                return
            end
            k = next(d, k)
            return k
        end

        return pairs_iter, t, nil
    end,

    __gc = function (t)
        data[t] = d
    end
}

niled = {
    new = function (o)
        o = o or {} -- create object if user does not provide one
        return setmetatable(o, meta)
    end,

    remove = function (t, k)
        local d = data[t]
        if d then
            return table.remove(d, k)
        end
    end,

    concat = function (t, separator)
        local d = data[t]
        if d then
            local values = table.new{}

            for i = 1, #d do
                values:insert(tostring(d[i]))
            end

            return table.concat(values, separator)
        end
    end,

    -- array constructor replacement. used since {...} discards nils.
    array = function (...)
        local n = select('#', ...)
        local d = {...}
        local t = setmetatable({}, meta)

        for i=1, n do
            if d[i] == nil then
                d[i] = NIL
            end
        end

        data[t] = d

        return t
    end
}

---- table constructor replacement. used since {...} discards nils.
--function niled.map(self, ...)
--  -- possibly more optimally implemented in C.
--  local n = select('#', ...)
--  local tmp = {...} -- it would be nice to avoid this
--  local t = setmetatable({}, meta)
--  for i=1,n,2 do t[tmp[i]] = tmp[i+1] end
--  return t
--end