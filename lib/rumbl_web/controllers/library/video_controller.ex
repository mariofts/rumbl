defmodule RumblWeb.Library.VideoController do
  use RumblWeb, :controller

  alias Rumbl.Library
  alias Rumbl.Library.Video
  alias Rumbl.Library.Category

  plug(:load_categories when action in [:new, :create, :edit, :update])

  def index(conn, _params, user) do
    videos = Library.list_videos(user)
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, _user) do
    changeset = Library.change_video(%Video{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, user) do
    case Library.create_video(video_params, user) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: library_video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    video = Library.get_video!(id, user)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    video = Library.get_video!(id, user)
    changeset = Library.change_video(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    video = Library.get_video!(id, user)

    case Library.update_video(video, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: library_video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    video = Library.get_video!(id, user)
    {:ok, _video} = Library.delete_video(video, user)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: library_video_path(conn, :index))
  end

  defp load_categories(conn, _) do
    categories = Library.list_categories()
    assign(conn, :categories, categories)
  end

  @doc """
  Overwrite the default parameters on all methods on this controller, 
  adding the current_user as a third parameter
  """
  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end
end
