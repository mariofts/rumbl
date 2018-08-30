defmodule RumblWeb.Library.AnnotationView do
  use RumblWeb, :view

  def render("annotation.json", %{annotation: ann}) do
    %{
      id: ann.id,
      body: ann.body,
      at: ann.at,
      user: render_one(ann.user, RumblWeb.Accounts.UserView, "user.json")
    }
  end
end
