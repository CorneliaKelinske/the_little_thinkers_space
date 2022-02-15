defmodule TheLittleThinkersSpace.ContentTest do
  use TheLittleThinkersSpace.DataCase

  alias TheLittleThinkersSpace.Content

  describe "uploads" do
    alias TheLittleThinkersSpace.Content.Upload

    import TheLittleThinkersSpace.ContentFixtures
    import TheLittleThinkersSpace.AccountsFixtures

    @valid_attrs %{
      description: "some description",
      file: "some file",
      file_type: "image/jpeg",
      title: "some title",
      orientation: "Landscape"
    }

    @update_attrs %{
      description: "some updated description",
      file: "some updated file",
      file_type: "image/png",
      title: "some updated title",
      orientation: "Landscape"
    }

    @invalid_attrs %{
      description: nil,
      file: nil,
      file_type: nil,
      title: nil,
      orientation: "Landscape"
    }

    setup do
      %{user: user_fixture()}
    end

    test "list_uploads/0 returns all uploads" do
      upload = upload_fixture()

      assert Enum.map(Content.list_uploads(), &Map.put(&1, :user, nil)) == [
               Map.put(upload, :user, nil)
             ]
    end

    test "get_upload!/1 returns the upload with given id" do
      upload = upload_fixture()
      assert Map.put(Content.get_upload!(upload.id), :user, nil) == Map.put(upload, :user, nil)
    end

    test "create_upload/1 with valid data creates a upload", %{user: user} do
      assert {:ok, %Upload{} = upload} = Content.create_upload(user, @valid_attrs)
      assert upload.description == "some description"
      assert upload.file == "some file"
      assert upload.file_type == "image/jpeg"
      assert upload.title == "some title"
    end

    test "create_upload/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Content.create_upload(user, @invalid_attrs)
    end

    test "update_upload/2 with valid data updates the upload" do
      upload = upload_fixture()

      assert {:ok, %Upload{} = upload} = Content.update_upload(upload, @update_attrs)
      assert upload.description == "some updated description"
      assert upload.file == "some updated file"
      assert upload.file_type == "image/png"
      assert upload.title == "some updated title"
    end

    test "update_upload/2 with invalid data returns error changeset" do
      upload = upload_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_upload(upload, @invalid_attrs)
      assert Map.put(Content.get_upload!(upload.id), :user, nil) == Map.put(upload, :user, nil)
    end

    test "delete_upload/1 deletes the upload" do
      upload = upload_fixture()
      assert {:ok, %Upload{}} = Content.delete_upload(upload)
      assert_raise Ecto.NoResultsError, fn -> Content.get_upload!(upload.id) end
    end

    test "change_upload/1 returns a upload changeset" do
      upload = upload_fixture()
      assert %Ecto.Changeset{} = Content.change_upload(upload)
    end
  end
end
