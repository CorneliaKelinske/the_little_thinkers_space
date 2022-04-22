defmodule TheLittleThinkersSpace.ContentTest do
  use TheLittleThinkersSpace.DataCase, async: true
  import TheLittleThinkersSpace.AccountsFixtures
  import TheLittleThinkersSpace.ContentFixtures

  alias TheLittleThinkersSpace.{Content, Content.Upload}

  describe "uploads" do
    @valid_attrs %{
      description: "some description",
      file_type: "image/jpeg",
      title: "some title",
      orientation: "Landscape",
      path: "test/support/Lifting.jpg"
    }

    @update_attrs %{
      description: "some updated description",
      file_type: "image/png",
      title: "some updated title",
      orientation: "Landscape",
      path: "test/support/Lifting.jpg"
    }

    @invalid_attrs %{
      description: nil,
      path: nil,
      file_type: nil,
      title: nil,
      orientation: "Landscape"
    }

    setup [:user, :upload]

    test "list_uploads/0 returns all uploads", %{upload: upload} do
      assert Enum.map(Content.list_uploads(), &Map.put(&1, :user, nil)) == [
               Map.put(upload, :user, nil)
             ]
    end

    test "get_upload!/1 returns the upload with given id", %{upload: upload} do
      assert Map.put(Content.get_upload!(upload.id), :user, nil) == Map.put(upload, :user, nil)
    end

    test "create_upload/1 with valid data creates a upload", %{user: user} do
      assert {:ok, %Upload{} = upload} = Content.create_upload(user, @valid_attrs)
      assert upload.description == "some description"
      assert upload.path == "test/support/Lifting.jpg"
      assert upload.file_type == "image/jpeg"
      assert upload.title == "some title"
    end

    test "create_upload/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Content.create_upload(user, @invalid_attrs)
    end

    test "update_upload/2 with valid data updates the upload", %{upload: upload} do
      assert {:ok, %Upload{} = upload} = Content.update_upload(upload, @update_attrs)
      assert upload.description == "some updated description"
      assert upload.path == "test/support/Lifting.jpg"
      assert upload.file_type == "image/png"
      assert upload.title == "some updated title"
    end

    test "update_upload/2 with invalid data returns error changeset", %{upload: upload} do
      assert {:error, %Ecto.Changeset{}} = Content.update_upload(upload, @invalid_attrs)
      assert Map.put(Content.get_upload!(upload.id), :user, nil) == Map.put(upload, :user, nil)
    end

    test "delete_upload/1 deletes the upload", %{upload: upload} do
      target_path = setup_delete_file("test/support/Lifting.jpg")
      delete_path = setup_delete_path(target_path)
      upload = Map.put(upload, :path, delete_path)
      assert {:ok, %Upload{}} = Content.delete_upload(upload)
      assert_raise Ecto.NoResultsError, fn -> Content.get_upload!(upload.id) end
    end

    test "change_upload/1 returns a upload changeset", %{upload: upload} do
      assert %Ecto.Changeset{} = Content.change_upload(upload)
    end
  end

  defp setup_delete_file(path) do
    target_dir = set_target_dir("priv/static/uploads/test")
    file_name = Path.basename(path)
    target_path = "#{target_dir}/#{file_name}"
    File.copy(path, target_path)
    target_path
  end

  defp set_target_dir(path) do
    case File.mkdir_p(path) do
      :ok ->
        path

      {:error, :eexist} ->
        path

      {:error, error} ->
        raise "Could not create target dir for create video test: #{inspect(error)}"
    end
  end

  defp setup_delete_path(path) do
    case is_binary(path) do
      true ->
        delete_path = String.replace(path, "priv/static", "")
        delete_path

      _ ->
        {:error, :no_delete_path}
    end
  end
end
