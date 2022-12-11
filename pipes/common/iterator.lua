require "common.cond"
require "common.niled"

iterator = {}

function iterator.tables (...)
    local i = 0
    local args = ...

    return function ()
        i = i + 1

        local result = niled.new{}

        for _, object in ipairs{ args } do
            result:insert(object[i])
        end

        return result:unpack()
    end
end

function iterator.functions (...)
    local args = ...

    return function ()
        local result = niled.new{}

        for _, object in ipairs{ args } do
            for _, value in ipairs{ object() } do
                result:insert(value)
            end
        end

        return result:unpack()
    end
end

function iterator.coroutines (...)
    local args = ...

    return function ()
        local result = niled.new{}

        for _, object in ipairs{ args } do
            local values = niled.array(coroutine.resume(object))
            local error = values:remove(1) -- pops boolean error value

            for _, value in ipairs(values) do -- unpack values into result
                result:insert(value)
            end
        end

        return result:unpack()
    end
end

function iterator.mixed (...)
    local callable = table:new{}

    for _, object in ipairs{ ... } do
        if cond.is_table(object) then
            callable:insert(iterator.tables(object)) -- calling the function here initializes the index
        elseif cond.is_function(object) then
            callable:insert(iterator.fuctions(object))
        elseif cond.is_coroutine(object) then
            callable:insert(iterator.coroutines(object))
        end
    end

    setmetatable(callable, {
        __call = function (self)
            local result = niled.new{}

            for _, iter in ipairs(self) do
                result:insert(iter())
            end

            return result:unpack()
        end
    })

    return callable
end

setmetatable(iterator, {
    __call = function (self, ...)
        if cond.all_of(cond.is_table, ...) then
            return iterator.tables(...)
        elseif cond.all_of(cond.is_function, ...) then
            return iterator.functions(...)
        elseif cond.all_of(cond.is_coroutine, ...) then
            return iterator.coroutines(...)
        else
            return iterator.mixed(...)
        end
    end
})