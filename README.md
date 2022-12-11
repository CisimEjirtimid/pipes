# Pipes - Lua implementation of streaming primitives

Implements a couple of algorithms through use of iterators and coroutines 

* Words - reads an input string word by word
* Zip - zips two or more inputs into a single one
* Successive - reads N number of successive elements and return as one
* Markov - implements Markov Chain algorithm (with N elements in state) on words input stream