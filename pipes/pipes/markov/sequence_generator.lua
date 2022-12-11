require "common.iterator"

local function SequenceGenerator ()

    local function hash (key)
        return key:concat("-")
    end

    --[[
            This needs to be paired with TableGenerator object
            N - number of elements in the state
    --]]
    local impl = function (object, n)
        local iter = iterator(object)

        local state = table.new{}

        repeat -- exhaust the whole iterating stream

            local key, value = iter()   -- expects key and value pairs here
                                        -- key is expected to be a table with N elements

            local index = hash(key)

            if not state[index] then
                state[index] = niled.new{}
            end
            state[index]:insert(value)

        until not value

        local current = niled.new{}

        for i = 1, n do
            current:insert(nil) -- start with empty words
        end

        repeat
            local list = state[hash(current)]

            local index = math.random(#list)
            local word = list[index]

            if word then
                coroutine.yield(word)
            end

            current:remove(1)
            current:insert(word)
        until not word
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

sequence_generator = SequenceGenerator()