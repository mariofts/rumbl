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
        broadcast_annotation(socket, annotation)
        Task.start_link(fn -> compute_additional_info(annotation, socket) end)
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp broadcast_annotation(socket, annotation) do
    annotation = Library.load_user_from_annotation(annotation)

    rendered_annotation =
      Phoenix.View.render(AnnotationView, "annotation.json", %{
        annotation: annotation
      })

    broadcast!(socket, "new_annotation", rendered_annotation)
  end

  defp compute_additional_info(annotation, socket) do
    for result <- Rumbl.InfoSys.compute(annotation.body, limit: 1, timeout: 10_000) do
      attrs = %{url: result.url, body: result.text, at: annotation.at}
      user = Accounts.get_user_by(%{username: result.backend})

      case Library.create_annotation(attrs, annotation.video_id, user) do
        {:ok, info_ann} -> broadcast_annotation(socket, info_ann)
        {:error, _changeset} -> :ignore
      end
    end
  end
end
