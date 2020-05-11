defmodule SchrodingerTest do
  use ExUnit.Case

  alias Schrodinger.{Validation, ValidationError}

  defmodule User do
    defstruct name: nil, age: nil, phone_number: nil
    use Schrodinger

    @valid_state {:base, %{name: [presence: true]}}
    @valid_state {:contact, %{phone_number: [presence: true]}}
    @invalid_state {:has_age, %{age: [presence: true]}}
  end

  describe "valid?/1" do
    test "Can assert that a struct is valid" do
      assert User.valid?(%User{name: "Monty"})
    end

    test "Can assert that a struct is invalid" do
      refute User.valid?(%User{name: "Monty", age: 18})
    end
  end

  describe "valid?/2" do
    test "Can assert that a struct is valid and a member of the defined state" do
      assert User.valid?(%User{name: "Monty"}, :base)
    end
  end

  describe "invalid?/1" do
    test "Can assert that a struct is valid" do
      refute User.invalid?(%User{name: "Monty"})
    end

    test "Can assert that a struct is invalid" do
      assert User.invalid?(%User{name: "Monty", age: 18})
    end
  end

  describe "validate/1" do
    test "returns {:ok, struct} when is valid" do
      user = %User{name: "Monty"}
      assert {:ok, ^user} = User.validate(user)
    end

    test "returns error tuple when matches an invalid state" do
      user = %User{name: "Bernard", age: 3}
      assert {:error, %Validation{invalid_state_matches: [:has_age]}} = User.validate(user)
    end

    test "returns error tuple when cannot match a valid state" do
      user = %User{name: nil, age: nil}

      assert {:error, %Validation{valid_state_errors: %{base: [name: "is not present"]}}} =
               User.validate(user)
    end
  end

  describe "validate/2" do
    test "can assert that a struct is valid and of a state" do
      user = %User{name: "Monty"}
      assert {:ok, ^user} = User.validate(user, :base)
    end

    test "can play nice with lists" do
      user = %User{name: "Monty"}
      assert {:ok, ^user} = User.validate(user, [:base, :contact])
    end

    test "fails when it does not match a specified state" do
      user = %User{name: "Monty"}
      assert {:error, %Validation{}} = User.validate(user, [:contact])
    end

    test "fails when it matches an invalid state" do
      user = %User{phone_number: "12345678", age: 22}
      assert {:error, %Validation{}} = User.validate(user, [:contact])
    end
  end

  describe "validate!/1" do
    test "returns struct when is valid" do
      user = %User{name: "Monty"}
      assert ^user = User.validate!(user)
    end

    test "Raises an exception when invalid" do
      user = %User{name: "Bernard", age: 3}

      assert_raise ValidationError, fn ->
        User.validate!(user)
      end
    end

    test "raises an exception when cannot match a valid state" do
      user = %User{name: nil, age: nil}

      assert_raise ValidationError, fn ->
        User.validate!(user)
      end
    end
  end
end
