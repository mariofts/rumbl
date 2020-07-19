defmodule Rumbl.Library.Video do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Rumbl.Permalink, autogenerate: true}

  schema "videos" do
    field(:description, :string)
    field(:title, :string)
    field(:url, :string)
    field(:slug, :string)
    belongs_to(:user, Rumbl.Accounts.User)
    belongs_to(:category, Rumbl.Library.Category)
    has_many(:annotations, Rumbl.Library.Annotation)

    timestamps()
  end

  defimpl Phoenix.Param, for: Rumbl.Library.Video do
    def to_param(%{slug: slug, id: id}) do
      "#{id}-#{slug}"
    end
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:url, :title, :description, :category_id])
    |> validate_required([:url, :title, :description, :category_id])
    |> slugify_title()
    |> assoc_constraint(:category)
  end

  defp slugify_title(changeset) do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end