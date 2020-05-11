defmodule Schrodinger do
  @moduledoc """
  # Schrodinger

  Check any struct against multiple valid and invalid state definitions

  See README for more information
  """
  defmacro __before_compile__(_env) do
    quote do
      def valid_states, do: @valid_state
      def invalid_states, do: @invalid_state
    end
  end

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :valid_state, accumulate: true, persist: false)
      Module.register_attribute(__MODULE__, :invalid_state, accumulate: true, persist: false)
      @before_compile Schrodinger

      alias Schrodinger.{InvalidStates, Validation, ValidationError, Validations, ValidStates}

      @type parent_struct :: __MODULE__.t()
      @type response_tuple :: {:ok, parent_struct} | {:error, Validation.t()}

      @spec valid?(parent_struct) :: boolean
      def valid?(%__MODULE__{} = struct) do
        case validate(struct) do
          {:ok, _struct} -> true
          {:error, _validation} -> false
        end
      end

      @spec valid?(parent_struct, atom | [atom]) :: boolean
      def valid?(%__MODULE__{} = struct, atoms) do
        case validate(struct, atoms) do
          {:ok, _struct} -> true
          {:error, _validation} -> false
        end
      end

      @spec invalid?(parent_struct) :: boolean
      def invalid?(%__MODULE__{} = struct), do: !valid?(struct)

      @spec validate(parent_struct) :: response_tuple
      def validate(%__MODULE__{} = struct) do
        case build_validation(struct) do
          %Validation{valid_state_matches: valid} = validation when valid == [] ->
            {:error, validation}

          %Validation{invalid_state_matches: invalid} when invalid == [] ->
            {:ok, struct}

          validation ->
            {:error, validation}
        end
      end

      @spec validate(parent_struct, atom | [atom]) :: response_tuple
      def validate(%__MODULE__{} = struct, atom) when is_atom(atom) do
        validate(struct, [atom])
      end

      def validate(%__MODULE__{} = struct, atoms) do
        validation = build_validation(struct)

        %Validation{valid_state_matches: valid_matches, invalid_state_matches: invalid_matches} =
          validation

        cond do
          Enum.any?(invalid_matches) -> {:error, validation}
          Enum.any?(atoms, fn atom -> atom in valid_matches end) -> {:ok, struct}
          true -> {:error, validation}
        end
      end

      @spec validate!(parent_struct) :: parent_struct
      def validate!(%__MODULE__{} = struct) do
        case validate(struct) do
          {:ok, struct} ->
            struct

          {:error, %Validation{valid_state_errors: errors, invalid_state_matches: matches}} ->
            raise ValidationError, """

            Invalid state matches: #{inspect(matches)}
            Valid state errors: #{inspect(errors)}
            """
        end
      end

      @spec build_validation(parent_struct) :: Validation.t()
      defp build_validation(%__MODULE__{} = struct) do
        %Validation{
          valid_states: valid_states(),
          invalid_states: invalid_states(),
          struct: struct
        }
        |> ValidStates.get_errors()
        |> InvalidStates.get_matches()
      end
    end
  end
end
