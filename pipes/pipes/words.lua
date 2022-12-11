
local function Words ()

    local impl = function (object)
        if not (object and cond.is_string(object)) then
            error("Invalid object provided!")
        end

        local current = 1

        repeat
            local s, e = string.find(object, "%w+", current)    -- match word with %w+ pattern
                                                                -- starting from `current` position
            if s and e then
                current = e + 1
                coroutine.yield(string.sub(object, s, e))
            end
        until not (s and e)
    end

    return {
        coroutine = function (object)
            return coroutine.create(function () impl(object) end)
        end,

        iterator = function (object)
            return coroutine.wrap(function () impl(object) end)
        end
    }
end

words = Words()
