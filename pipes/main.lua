require "pipes.markov"
require "pipes.words"

for word in markov.iterator(words.coroutine(io.read()), 2) do
    io.write(word, " ")
end

print("Add breakpoint here!")