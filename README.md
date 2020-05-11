# Schrodinger

Check any struct against multiple valid and invalid state definitions.

This library is a lightweight alternative to using Ecto Changesets or other more involved libraries, when all you want is to validate whether a struct is within acceptable parameters, and keep the definition of "what is acceptable" in the same place where the struct is defined.

I originally envisioned this as being a quick way to define an API for a bounded context within an app, to validate what is passed in from other contexts.

## Usage

Add `use Schrodinger` to any module defining a struct below the `defstruct` or `schema` blocks. This is necessary for the library to be able to read the struct definition.

```elixir
defmodule Parameters do
  defstruct [:name, :email, :content]
  # This could also be an Ecto Schema
  
  use Schrodinger
end
```

Next, add at least one `@valid_state` module attribute, and zero or more `@invalid_state` module attributes to that same module. It is a tuple where the first parameter is an atom identifying the name of the state and the second is a map of the parameter validations.

```elixir
@email_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
@valid_state {:contact_form, %{email: [presence: true, format: @email_regex], content: [presence: true, type: :string]}}
@valid_state {:anonymous_comment, %{content: [presence: true, type: :string]}}
@invalid_state {:name_without_email, %{name: [presence: true], email: [presence: false]}}
```

And then you can query if the struct is valid

```bash
iex(1)> Parameters.valid?(%Parameters{email: "test@test.com", content: "THIS IS CONTENT"})
true
```

For a struct to be valid, it must match _at least one_ valid state and match none of the invalid states.

## Public API:

- `valid?/1` returns true / false
- `valid?/2` returns true / false, the second argument is an atom or list of atoms which define which valid states can be checked. There is no filtering of invalid states. This "tightens" the rules.
- `validate/1` returns `{:ok, struct}` or `{:error, Schrodinger.Validation{}}` 
- `validate/2` has the same return values and can be passed a state atom or a list of states just like `valid?/2`
- `validate!/1` returns `struct` or raises a `Schrodinger.ValidationError{}` 
- `validate!/2` has same arguments as `valid?/2`

## Validation Options

Validation options are keyword lists, the following options are available:

- `presence: BOOLEAN`
  - BOOLEAN can be true or false. Only a nil value or missing key is considered 'absent'
- `inclusion: [LIST OF ITEMS]`
- `exclusion: [LIST OF ITEMS]`
- `format: [REGEX]`
  - This will also check that the value is present and that it is a string
- `type: TYPE`
  - TYPE can be one of :atom, :string, :integer, :boolean, :list, :map, :number, :struct
  - atoms do not include true, false, and nil
  - a struct is a map, but a map is not a struct

## Installation

This library can be installed by adding `schrodinger` to your list of dependencies in `mix.exs`. It has no dependencies.

```elixir
def deps do
  [
    {:schrodinger, "~> 0.1.0"}
  ]
end
```
