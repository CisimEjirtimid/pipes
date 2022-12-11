require "common.iterator"

local function Zip ()

    local impl = function (object1, object2)

        local iter = iterator(object1, object2)

        local res1, res2 = iter()

        while res1 and res2 do
            coroutine.yield(res1, res2)

            res1, res2 = iter()
        end
    end

    return {
        coroutine = function (object1, object2)
            return coroutine.create(function () impl(object1, object2) end)
        end,

        iterator = function (object1, object2)
            return coroutine.wrap(function () impl(object1, object2) end)
        end
    }
end

zip = Zip()