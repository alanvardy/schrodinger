defmodule Schrodinger.ValidStates do
  @moduledoc "Makes sure that struct matches at least one of the valid states, returns a list of matches and a map of errors"
  alias Schrodinger.{Validation, Validations}

  @spec get_errors(Validation.t()) :: Validation.t()
  def get_errors(validation) do
    %Validation{valid_states: valid_states, struct: struct} = validation

    validations = Enum.map(valid_states, &validate_states(struct, &1))

    errors =
      validations
      |> Enum.reject(fn {_k, v} -> v == :ok end)
      |> Enum.into(%{})

    matches =
      validations
      |> Enum.filter(fn {_k, v} -> v == :ok end)
      |> Enum.map(fn {k, _v} -> k end)

    %Validation{validation | valid_state_errors: errors, valid_state_matches: matches}
  end

  defp validate_states(struct, {name, valid_state}) do
    valid_state
    |> Enum.flat_map(&check_attribute(struct, &1))
    |> Enum.reject(&(&1 == :ok))
    |> case do
      [] -> {name, :ok}
      errors -> {name, Enum.map(errors, &elem(&1, 1))}
    end
  end

  defp check_attribute(struct, {attribute, checks}) do
    Enum.map(checks, &Validations.check(struct, attribute, &1))
  end
end
