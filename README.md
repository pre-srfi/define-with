# SRFI nnn: Define with declarations

by Firstname Lastname, Another Person, Third Person

# Status

Early Draft

# Abstract

Extends Scheme's core `define` form so that a special `(with ...)`
expression can be written inside it. Every subexpression inside `(with
...)` becomes a declaration associated with that `define`.

The declaration mechanism is fully extensible to cover arbitrary
declarations. This SRFI specifies `doc` for documentation strings,
`deprecated` for interfaces being phased out, and `test` for simple
test cases.

# Issues

* Should we distinguish between required and optional declarations?

* Supporting `(with ...)` in nested `define`.

* Mixing `(with ...)` and `(cond-expand ...)` should be supported
  somehow.

* Is `(with doc ...)` a better syntax than `(with (doc ...))`?

# Rationale

As programming languages grow, there inevitably comes a need to
associate various inessential but nevertheless useful metadata with
procedures and variables. Many kinds of metadata are known:

* Documentation strings.
* Test cases.
* Optimization settings.
* ...

Since these declare things about the definition without actually
defining it by themselves, they are usefully called _declarations_.

## Survey of prior art

Common Lisp has a `(declare ...)` subexpression like this. Standard
declarations include `(declare (type ...))` and `(declare (optimize
...))`.

A great many programming languages support _forward declarations_ of
procedures and their type signatures.

## Documentation strings, and why they should be declarations

Many programming languages treat a string literal at the beginning of
a procedure definition as a _documentation string_ for that procedure.
For example, in Common Lisp:

```
(defun (hello)
  "Greet the user."
  (write-string "Hello, world!"))
```

This works well enough for one-line documentation strings, but trouble
starts with multi-line strings:

```
(defun (hello name)
  "Greet the user.

Known users are remembered."
  (write-string (if (known? name) "Welcome back, " "Hello, "))
  (write-string name))
```

To keep the documentations string's _value_ consistently indented, its
_written representation_ has to be inconsistently indented. That makes
the source code hard to read. This can be countered by removing
leading and trailing whitespace from the string, but there is no
really satisfactory algorithm to do that; the Ruby programming
language community has explored various workarounds quite extensively.

Another problem comes from adding markup to the documentation string.
Many language communities have done that for years. No consensus has
been reached on which markup language to use, nor is consensus likely
to arise. The languages having a consensus, such as Emacs Lisp, use
extremely simple (some would say impoverished) and improvised markup.

By treating the documentation string as a declaration, we can solve
both problems in a clean and extensible manner. Switching to Scheme:

```
(define (hello)
  (with (doc "Greet the user."))
  (write-string "Hello, world!"))
```

A multi-line docstring:

```
(define (hello name)
  (with (doc "Greet the user."
             ""
             "Known users are remembered."))
  (write-string "Hello, world!"))
```

Another way to write the multi-line docstring (assuming it's the
consumer's responsibility to reformat all the whitespace in it):

```
(define (hello name)
  (with (doc "Greet the user.

             Known users are remembered."))
  (write-string "Hello, world!"))
```

With an imaginary non-standard string literal syntax:

```
(define (hello name)
  (with (doc $ Greet the user.
             $
             $ Known users are remembered.
             ))
  (write-string "Hello, world!"))
```

With Markdown markup:

```
(define (hello name)
  (with (doc markdown
             "Greet the **user**."
             ""
             "Known _users_ are remembered."))
  (write-string "Hello, world!"))
```

With imaginary semantic S-expression-based markup:

```
(define (hello name)
  (with (doc fantastic-markup-language
             "Greet the " (arg user) "."
             ""
             "Known " (concept user "users") " are remembered."))
  (write-string "Hello, world!"))
```

# Specification

## The `with` identifier

A `with` identifier is added to Scheme syntax. It is an error to use
`with` or `(with ...)` except as detailed here.

## The extended `define` syntax

The standard syntax `(define name value)` is extended such that
`(define name value (with declarations ...))` is also supported.

The standard syntax `(define (name args ... . tail) body ...)` is
extended such that `(define (name args ... . tail) (with declarations
...) body ...)` is also supported.

The standard syntax `(define (name args ...) body ...)` is extended
such that `(define (name args ...) (with declarations ...) body ...)`
is also supported.

## Declaration parsing

### Subexpression syntax

A `(with declaration ...)` expression is parsed such that each
`declaration` represents one declaration.

Each `declaration` is either a symbol or a pair; it is an error to
give other types of objects. If a declaration is an identifier `foo`,
it is implicitly turned into an equivalent pair `(foo)`.

The `car` must be an identifier, and names the kind of declaration
this is. The `cdr` is the value of the declaration, and its
interpretation depends on the kind.

### Known declaration with incorrect syntax

The implementation is permitted, but not required, to treat a known
declaration with incorrect syntax in the `cdr` as an error.

### Unknown declaration

If the implementation does not recognize a particular declaration, it
**should** ignore the declaration, perhaps displaying a warning. It
**may** treat the situation as an error.

## Declarations

### The `doc` declaration

Sets the documentation for the enclosing definition.

If the first object in the value is an identifier, or a list whose car
is an identifier, then that identifier names the documentation syntax
to be used. If the first object is a list, its cdr gives settings for
that documentation syntax.

If the first object in the value is a string, then any and all
remaining objects have to be strings as well; it is an error if
non-strings follow the first string. A simple documentation string is
produced by concatenating all the strings with newlines in between, as
if by the SRFI 13 expression `(string-join strings "\n")`.

It is an error to have more than one `doc` declaration with the same
documentation syntax for the same definition.

### The `deprecated` declaration

The presence of this declaration says that the definition is
deprecated, and may cause the Scheme implementation to emit a warning
when the definition is being used.

If `deprecated` is followed by any objects, those construct a
human-readable message explaining why the definition is deprecated
and/or what to use instead. Details are as for the `doc` declaration.

### The `test` declaration

Adds a simple test case for the enclosing procedure definition.

The test case gives arguments to the procedure, followed an arrow
`=>`, followed by the expected return values. It is permitted to give
zero arguments and/or zero return values, but the arrow must always be
present.

For example, a reasonable test for `string-append` might be `(with
(test "aaa" "bbb" => "aaabbb"))`.

A test for `truncate/` might be `(with (test 15 2 => 7 1))`.

For R6RS and R7RS, the `=>` identifier is imported from the RnRS
standard library.

### Other declarations

Known declarations are tracked in the [Scheme
Registry](https://registry.scheme.org/).

# Examples

Variable:

```
(define scale (make-parameter 1)
  (with (doc "Scaling factor to use.")))
```

Procedure:

```
(define (scale-add a b)
  (with (doc "Add two numbers."
             ""
             "Takes the global scaling factor into account.")
        (test 1 2 => 3)
        inline
        (deprecated "Please scale your own numbers."))
  (* (scale) (+ a b)))
```

# Implementation

R7RS `syntax-rules` sample implementation attached.

# Acknowledgements

# References

# Copyright

Copyright (C) Firstname Lastname (20XY).

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
