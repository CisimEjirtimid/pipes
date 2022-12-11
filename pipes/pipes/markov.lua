require "pipes.markov.table_generator"
require "pipes.markov.sequence_generator"

--[[
        A coroutine/iterator that generates new sequence based on Markov Chain algorithm
        - Uses TableGeneraor and SequenceGenerator objects
--]]
local function Markov ()

    local impl = function (object, n)
        local t_coro = table_generator.coroutine(object, n)
        local s_coro = sequence_generator.coroutine(t_coro, n)
        local iter = iterator(s_coro)

        local word = iter()

        while word do
            coroutine.yield(word) -- sends next word
            word = iter()
        end
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

markov = Markov()