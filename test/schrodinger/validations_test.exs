defmodule Schrodinger.ValidationsTest do
  use ExUnit.Case

  alias Schrodinger.Validations
  @types [:animal, :vegetable, :mineral]
  @regex ~r/do/

  defmodule StructyStruct do
    defstruct name: nil
  end

  describe "check/3" do
    test "can verify presence" do
      assert Validations.check(%{}, :name, {:presence, true}) ==
               {:error, {:name, "is not present"}}

      assert Validations.check(%{name: nil}, :name, {:presence, true}) ==
               {:error, {:name, "is not present"}}

      assert Validations.check(%{name: "Bob"}, :name, {:presence, true}) == :ok
    end

    test "can verify absence" do
      assert Validations.check(%{name: "Bob"}, :name, {:presence, false}) ==
               {:error, {:name, "is present"}}

      assert Validations.check(%{name: nil}, :name, {:presence, false}) == :ok
      assert Validations.check(%{}, :name, {:presence, false}) == :ok
    end

    test "can verify inclusion" do
      assert Validations.check(%{type: :banana}, :type, {:inclusion, @types}) ==
               {:error, {:type, "is not a member of #{inspect(@types)}"}}

      assert Validations.check(%{type: nil}, :type, {:inclusion, @types}) ==
               {:error, {:type, "is not a member of #{inspect(@types)}"}}

      assert Validations.check(%{}, :type, {:inclusion, @types}) ==
               {:error, {:type, "is not a member of #{inspect(@types)}"}}

      assert Validations.check(%{type: :animal}, :type, {:inclusion, @types}) ==
               :ok
    end

    test "can verify exclusion" do
      assert Validations.check(%{type: :banana}, :type, {:exclusion, @types}) ==
               :ok

      assert Validations.check(%{type: nil}, :type, {:exclusion, @types}) ==
               :ok

      assert Validations.check(%{}, :type, {:exclusion, @types}) ==
               :ok

      assert Validations.check(%{type: :vegetable}, :type, {:exclusion, @types}) ==
               {:error, {:type, "is a member of #{inspect(@types)}"}}
    end

    test "can verify format" do
      assert Validations.check(%{}, :name, {:format, @regex}) ==
               {:error, {:name, "does not match format #{inspect(@regex)}"}}

      assert Validations.check(%{name: nil}, :name, {:format, @regex}) ==
               {:error, {:name, "does not match format #{inspect(@regex)}"}}

      assert Validations.check(%{name: "cat"}, :name, {:format, @regex}) ==
               {:error, {:name, "does not match format #{inspect(@regex)}"}}

      assert Validations.check(%{name: "dog"}, :name, {:format, @regex}) == :ok
    end

    test "can verify type is an atom" do
      assert Validations.check(%{fruit: nil}, :fruit, {:type, :atom}) ==
               {:error, {:fruit, "is not an atom"}}

      assert Validations.check(%{fruit: true}, :fruit, {:type, :atom}) ==
               {:error, {:fruit, "is not an atom"}}

      assert Validations.check(%{fruit: false}, :fruit, {:type, :atom}) ==
               {:error, {:fruit, "is not an atom"}}

      assert Validations.check(%{fruit: "apple"}, :fruit, {:type, :atom}) ==
               {:error, {:fruit, "is not an atom"}}

      assert Validations.check(%{}, :fruit, {:type, :atom}) ==
               {:error, {:fruit, "is not an atom"}}

      assert Validations.check(%{fruit: :jackfruit}, :fruit, {:type, :atom}) ==
               :ok
    end

    test "can verify type is a string" do
      assert Validations.check(%{fruit: nil}, :fruit, {:type, :string}) ==
               {:error, {:fruit, "is not a string"}}

      assert Validations.check(%{fruit: :jackfruit}, :fruit, {:type, :string}) ==
               {:error, {:fruit, "is not a string"}}

      assert Validations.check(%{fruit: ""}, :fruit, {:type, :string}) ==
               {:error, {:fruit, "is an empty string"}}

      assert Validations.check(%{}, :fruit, {:type, :string}) ==
               {:error, {:fruit, "is not a string"}}

      assert Validations.check(%{fruit: "apple"}, :fruit, {:type, :string}) ==
               :ok
    end

    test "can verify type is an integer" do
      assert Validations.check(%{quantity: nil}, :quantity, {:type, :integer}) ==
               {:error, {:quantity, "is not an integer"}}

      assert Validations.check(%{quantity: "bananas"}, :quantity, {:type, :integer}) ==
               {:error, {:quantity, "is not an integer"}}

      assert Validations.check(%{quantity: 20.3}, :quantity, {:type, :integer}) ==
               {:error, {:quantity, "is not an integer"}}

      assert Validations.check(%{quantity: 2}, :quantity, {:type, :integer}) == :ok
      assert Validations.check(%{quantity: -32}, :quantity, {:type, :integer}) == :ok
    end

    test "can verify type is a boolean" do
      assert Validations.check(%{awesome: nil}, :awesome, {:type, :boolean}) ==
               {:error, {:awesome, "is not a boolean"}}

      assert Validations.check(%{awesome: "bananas"}, :awesome, {:type, :boolean}) ==
               {:error, {:awesome, "is not a boolean"}}

      assert Validations.check(%{awesome: true}, :awesome, {:type, :boolean}) == :ok
      assert Validations.check(%{awesome: false}, :awesome, {:type, :boolean}) == :ok
    end

    test "can verify type is a list" do
      assert Validations.check(%{fruits: nil}, :fruit, {:type, :list}) ==
               {:error, {:fruit, "is not a list"}}

      assert Validations.check(%{}, :fruit, {:type, :list}) ==
               {:error, {:fruit, "is not a list"}}

      assert Validations.check(%{fruits: []}, :fruits, {:type, :list}) == :ok
      assert Validations.check(%{fruits: ["things"]}, :fruits, {:type, :list}) == :ok
    end

    test "can verify type is a map" do
      assert Validations.check(%{fruits: nil}, :fruits, {:type, :map}) ==
               {:error, {:fruits, "is not a map"}}

      assert Validations.check(%{fruits: []}, :fruits, {:type, :map}) ==
               {:error, {:fruits, "is not a map"}}

      assert Validations.check(%{fruits: "something"}, :fruits, {:type, :map}) ==
               {:error, {:fruits, "is not a map"}}

      assert Validations.check(%{}, :fruits, {:type, :map}) ==
               {:error, {:fruits, "is not a map"}}

      assert Validations.check(%{fruits: %{}}, :fruits, {:type, :map}) == :ok
      assert Validations.check(%{fruits: %{things: :stuff}}, :fruits, {:type, :map}) == :ok
      assert Validations.check(%{fruits: %{things: :stuff}}, :fruits, {:type, :map}) == :ok
    end
  end

  test "can verify type is a number" do
    assert Validations.check(%{weight: nil}, :weight, {:type, :number}) ==
             {:error, {:weight, "is not a number"}}

    assert Validations.check(%{}, :weight, {:type, :number}) ==
             {:error, {:weight, "is not a number"}}

    assert Validations.check(%{weight: []}, :weight, {:type, :number}) ==
             {:error, {:weight, "is not a number"}}

    assert Validations.check(%{weight: "bananas"}, :weight, {:type, :number}) ==
             {:error, {:weight, "is not a number"}}

    assert Validations.check(%{weight: %{}}, :weight, {:type, :number}) ==
             {:error, {:weight, "is not a number"}}

    assert Validations.check(%{weight: 20}, :weight, {:type, :number}) == :ok
    assert Validations.check(%{weight: 10.2}, :weight, {:type, :number}) == :ok
  end

  test "can verify type is a struct" do
    assert Validations.check(%{}, :user, {:type, :struct}) ==
             {:error, {:user, "is not a struct"}}

    assert Validations.check(%{user: nil}, :user, {:type, :struct}) ==
             {:error, {:user, "is not a struct"}}

    assert Validations.check(%{user: %{}}, :user, {:type, :struct}) ==
             {:error, {:user, "is not a struct"}}

    assert Validations.check(%{user: %{}}, :user, {:type, :struct}) ==
             {:error, {:user, "is not a struct"}}

    assert Validations.check(%{user: %StructyStruct{}}, :user, {:type, :struct}) == :ok
  end
end
