defmodule Rumbl.Library do
  @moduledoc """
  The Library context.
  """
  import Ecto, only: [assoc: 2, build_assoc: 3]
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Rumbl.Repo

  alias Rumbl.Library.Video
  alias Rumbl.Library.Annotation
  alias Rumbl.Library.Category
  alias Rumbl.Accounts.User

  def list_categories do
    Category
    |> Category.alphabetical()
    |> Category.names_and_id()
    |> Repo.all()
  end

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Video{}, ...]

  """
  def list_videos(%User{} = user) do
    user
    |> user_videos()
    |> Repo.all()
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(123)
      %Video{}

      iex> get_video!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(id, %User{} = user) do
    user
    |> user_videos()
    |> Repo.get!(id)
  end

  def get_video!(id) do
    Repo.get!(Video, id)
  end

  @doc """
  Creates a video.

  ## Examples

      iex> create_video(%{field: value})
      {:ok, %Video{}}

      iex> create_video(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video(attrs \\ %{}, user) do
    %Video{}
    |> Video.changeset(attrs)
    |> put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a video.

  ## Examples

      iex> update_video(video, %{field: new_value})
      {:ok, %Video{}}

      iex> update_video(video, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Video.

  ## Examples

      iex> delete_video(video)
      {:ok, %Video{}}

      iex> delete_video(video)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video(%Video{:id => id}, %User{} = user) do
    id
    |> get_video!(user)
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(video)
      %Ecto.Changeset{source: %Video{}}

  """
  def change_video(%Video{} = video) do
    Video.changeset(video, %{})
  end

  def create_annotation(attrs \\ %{}, video_id, user) do
    user
    |> build_assoc(:annotations, video_id: video_id)
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  def list_annotations_from_video(video, last_seen_id) do
    Repo.all(
      from(
        a in assoc(video, :annotations),
        where: a.id > ^last_seen_id,
        order_by: [asc: a.at, asc: a.id],
        limit: 200,
        preload: [:user]
      )
    )
  end

  def load_user_from_annotation(annotation) do
    Repo.preload(annotation, :user)
  end

  defp user_videos(%User{} = user) do
    assoc(user, :videos)
  end
end
