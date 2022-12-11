require "common.iterator"

local function TableGenerator ()

    --[[
            Similar to successive, only with N + 1 values in succession + padding:
                - starts with N nilword elements
                - ends with 1 nilword element
                returns N values (key) + 1 value
    --]]
    local impl = function (object, n)
        local iter = iterator(object)

        local key = niled.new{}

        for i = 1, n do
            key:insert(nil)
        end

        repeat
            local value = iter()

            coroutine.yield(key, value)

            -- delete first and add next element
            key:remove(1)
            key:insert(value)

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

table_generator = TableGenerator()