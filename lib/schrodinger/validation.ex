defmodule Schrodinger.Validation do
  @enforce_keys [:valid_states, :invalid_states, :struct]
  defstruct valid_states: [],
            invalid_states: [],
            struct: %{},
            valid_state_errors: %{},
            valid_state_matches: [],
            invalid_state_matches: []

  @type t :: %__MODULE__{
    invalid_state_matches: [atom],
          valid_states: [{atom, %{required(atom) => [{atom, any}]}}],
          invalid_states: [{atom, %{required(atom) => [{atom, any}]}}],
          struct: %{required(atom) => any},
          valid_state_errors: %{required(atom) => [{atom, String.t()}]},
          valid_state_matches: [atom],
        }
end
