defmodule Dialekt.LearningTest do
  use Dialekt.DataCase, async: true

  alias Dialekt.Learning
  alias Dialekt.Learning.Config

  describe "list_configs/0" do
    test "returns all configs" do
      config1 = insert_config(%{name: "German Practice"})
      config2 = insert_config(%{name: "French Practice"})

      configs = Learning.list_configs()

      assert length(configs) == 2
      assert Enum.any?(configs, &(&1.id == config1.id))
      assert Enum.any?(configs, &(&1.id == config2.id))
    end

    test "returns empty list when no configs exist" do
      assert Learning.list_configs() == []
    end
  end

  describe "get_config!/1" do
    test "returns the config with given id" do
      config = insert_config(%{name: "Test Config"})
      fetched = Learning.get_config!(config.id)

      assert fetched.id == config.id
      assert fetched.name == "Test Config"
    end

    test "raises when config does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Learning.get_config!(99999)
      end
    end
  end

  describe "create_config/1" do
    test "creates config with valid attributes" do
      attrs = %{
        name: "German B1",
        native_language_code: "en",
        target_language_code: "de",
        cefr_level_code: "B1",
        register_code: "formal"
      }

      assert {:ok, %Config{} = config} = Learning.create_config(attrs)
      assert config.name == "German B1"
      assert config.native_language_code == "en"
      assert config.target_language_code == "de"
      assert config.cefr_level_code == "B1"
      assert config.register_code == "formal"
    end

    test "returns error with invalid attributes" do
      attrs = %{name: ""}

      assert {:error, %Ecto.Changeset{}} = Learning.create_config(attrs)
    end
  end

  describe "update_config/2" do
    test "updates config with valid attributes" do
      config = insert_config(%{name: "Original Name"})
      attrs = %{name: "Updated Name"}

      assert {:ok, %Config{} = updated} =
               Learning.update_config(config, attrs)

      assert updated.name == "Updated Name"
      assert updated.id == config.id
    end

    test "returns error with invalid attributes" do
      config = insert_config(%{name: "Valid Name"})
      attrs = %{name: ""}

      assert {:error, %Ecto.Changeset{}} =
               Learning.update_config(config, attrs)
    end
  end

  describe "delete_config/1" do
    test "deletes the config" do
      config = insert_config(%{name: "To Delete"})

      assert {:ok, %Config{}} = Learning.delete_config(config)

      assert_raise Ecto.NoResultsError, fn ->
        Learning.get_config!(config.id)
      end
    end
  end

  # Test helpers

  defp insert_config(attrs) do
    default_attrs = %{
      name: "Test Config",
      native_language_code: "en",
      target_language_code: "de",
      cefr_level_code: "B1",
      register_code: "formal"
    }

    %Config{}
    |> Config.changeset(Map.merge(default_attrs, attrs))
    |> Repo.insert!()
  end
end
