defmodule Schrodinger.InvalidStates do
  @moduledoc "Checks if the struct matches in of the invalid states defined in `@invalid_state`"
  alias Schrodinger.{Validation, Validations}

  @spec get_matches(Validation.t()) :: Validation.t()
  def get_matches(validation) do
    %Validation{invalid_states: invalid_states, struct: struct} = validation

    invalid_state_matches =
      invalid_states
      |> Enum.map(&matches_for_state(struct, &1))
      |> List.flatten()

    %Validation{validation | invalid_state_matches: invalid_state_matches}
  end

  defp matches_for_state(struct, {name, valid_state}) do
    valid_state
    |> Enum.flat_map(&check_attribute(struct, &1))
    |> Enum.reject(&(&1 == :ok))
    |> case do
      [] -> name
      _errors -> []
    end
  end

  defp check_attribute(struct, {attribute, checks}) do
    Enum.map(checks, &Validations.check(struct, attribute, &1))
  end
end
