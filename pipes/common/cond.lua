cond = {}

function cond.is_string (object)
    return type(object) == "string"
end

function cond.is_table (object)
    return type(object) == "table"
end

function cond.is_function (object)
    return type(object) == "function"
end

function cond.is_coroutine (object)
    return type(object) == "thread"
end

function cond.all_of (cond_fn, ...)
    local result = true

    for _, v in pairs{ ... } do
        result = result and cond_fn(v)
    end

    return result
end

function cond.any_of (cond_fn, ...)
    local result = false

    for _, v in pairs{ ... } do
        result = result or cond_fn(v)
    end

    return result
end