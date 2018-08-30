defmodule RumblWeb.Library.WatchController do
  use RumblWeb, :controller

  alias Rumbl.Library
  alias Rumbl.Library.Video

  def show(conn, %{"id" => id}) do
    video = Library.get_video!(id)
    render(conn, "show.html", video: video)
  end
end
