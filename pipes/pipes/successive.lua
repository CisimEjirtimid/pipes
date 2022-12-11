require "common.iterator"

--[[
        A coroutine/iterator that packs successive N elements into one
--]]
local function Successive ()

    local impl = function (object, n)
        local iter = iterator(object)

        local result = niled.new{}

        for i = 1, n do
            result:insert(iter())
        end

        repeat
            local value = iter()

            coroutine.yield(result:unpack())

            -- delete first and add next element
            result:remove(1)
            result:insert(value)

        until not value
    end

    return {
        coroutine = function (object, n)
            return coroutine.create(function () impl(object, n) end)
        end,

        iterator = function (object, n)
            return coroutine.wrap(function () impl(object, n) end)
        end
    }
end

successive = Successive()