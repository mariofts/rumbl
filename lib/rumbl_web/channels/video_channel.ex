defmodule RumblWeb.Library.VideoChannel do
  use RumblWeb, :channel

  alias Rumbl.Accounts
  alias Rumbl.Library
  alias RumblWeb.Library.AnnotationView

  def join("videos:" <> video_id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    video_id = String.to_integer(video_id)
    video = Library.get_video!(video_id)
    annotations = Library.list_annotations_from_video(video, last_seen_id)

    resp = %{
      annotations: Phoenix.View.render_many(annotations, AnnotationView, "annotation.json")
    }

    {:ok, resp, assign(socket, :video_id, video_id)}
  end

  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    case Library.create_annotation(params, socket.assigns.video_id, user) do
      {:ok, annotation} ->
        broadcast!(socket, "new_annotation", %{
          id: annotation.id,
          user: RumblWeb.Accounts.UserView.render("user.json", %{user: user}),
          body: annotation.body,
          at: annotation.at
        })

        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
