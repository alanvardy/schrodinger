defmodule Schrodinger.Validations do
  @moduledoc "The individual validations that a field can have checked against it. 2 element tuples with check type and data"
  @type validation :: {atom, any}

  @spec check(struct, atom, validation) :: :ok | {:error, {atom, String.t()}}
  def check(struct, attribute, {:presence, true}) do
    case Map.get(struct, attribute) do
      nil -> {:error, {attribute, "is not present"}}
      _ -> :ok
    end
  end

  def check(struct, attribute, {:presence, false}) do
    case Map.get(struct, attribute) do
      nil -> :ok
      _ -> {:error, {attribute, "is present"}}
    end
  end

  def check(struct, attribute, {:inclusion, list}) when is_list(list) do
    value = Map.get(struct, attribute)

    if value in list do
      :ok
    else
      {:error, {attribute, "is not a member of #{inspect(list)}"}}
    end
  end

  def check(struct, attribute, {:exclusion, list}) when is_list(list) do
    value = Map.get(struct, attribute)

    if value in list do
      {:error, {attribute, "is a member of #{inspect(list)}"}}
    else
      :ok
    end
  end

  def check(struct, attribute, {:format, regex}) do
    with value <- Map.get(struct, attribute),
         true <- is_binary(value),
         true <- Regex.match?(regex, value) do
      :ok
    else
      _ -> {:error, {attribute, "does not match format #{inspect(regex)}"}}
    end
  end

  def check(struct, attribute, {:type, :atom}) do
    with value <- Map.get(struct, attribute),
         false <- value in [nil, true, false],
         true <- is_atom(value) do
      :ok
    else
      _ -> {:error, {attribute, "is not an atom"}}
    end
  end

  def check(struct, attribute, {:type, :string}) do
    with value <- Map.get(struct, attribute),
         true <- is_binary(value),
         false <- value == "" do
      :ok
    else
      false -> {:error, {attribute, "is not a string"}}
      true -> {:error, {attribute, "is an empty string"}}
    end
  end

  def check(struct, attribute, {:type, :integer}) do
    with value <- Map.get(struct, attribute),
         true <- is_integer(value) do
      :ok
    else
      _ -> {:error, {attribute, "is not an integer"}}
    end
  end

  def check(struct, attribute, {:type, :boolean}) do
    with value <- Map.get(struct, attribute),
         true <- value in [true, false] do
      :ok
    else
      _ -> {:error, {attribute, "is not a boolean"}}
    end
  end

  def check(struct, attribute, {:type, :list}) do
    with value <- Map.get(struct, attribute),
         true <- is_list(value) do
      :ok
    else
      _ -> {:error, {attribute, "is not a list"}}
    end
  end

  def check(struct, attribute, {:type, :map}) do
    with value <- Map.get(struct, attribute),
         true <- is_map(value) do
      :ok
    else
      _ -> {:error, {attribute, "is not a map"}}
    end
  end

  def check(struct, attribute, {:type, :number}) do
    with value <- Map.get(struct, attribute),
         true <- is_number(value) do
      :ok
    else
      _ -> {:error, {attribute, "is not a number"}}
    end
  end

  def check(struct, attribute, {:type, :struct}) do
    with value <- Map.get(struct, attribute),
         true <- is_map(value),
         field when field != nil <- Map.get(value, :__struct__) do
      :ok
    else
      _ -> {:error, {attribute, "is not a struct"}}
    end
  end
end
