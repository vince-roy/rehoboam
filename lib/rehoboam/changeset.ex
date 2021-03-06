defmodule Rehoboam.Changeset do
  import Ecto.Changeset
  import Ecto.Query
  alias Rehoboam.Repo

  def ensure_field_uniqueness(%Ecto.Changeset{} = cs, query) do
    ensure_field_uniqueness(cs, query, %{
      field: :slug,
      separator: "-"
    })
  end

  def ensure_field_uniqueness(%Ecto.Changeset{valid?: false} = cs, _, _) do
    cs
  end

  def ensure_field_uniqueness(%Ecto.Changeset{} = cs, query, opts) do
    %{field: field, separator: sep} =
      Enum.into(opts, %{
        field: :slug,
        separator: "-"
      })

    case get_change(cs, field) do
      nil ->
        cs

      change ->
        change = Slugger.slugify_downcase(change, sep)

        from(m in query)
        |> select([q], %{
          original: count("*") |> filter(field(q, ^field) == ^change),
          deduplicated:
            count("*") |> filter(fragment("? ~ ?", field(q, ^field), ^"#{change}-[0-9]+"))
        })
        |> (fn res ->
              case get_field(cs, :id) do
                nil -> res
                id -> res |> where([p], p.id != ^id)
              end
            end).()
        |> Repo.one()
        |> case do
          %{original: 0} ->
            put_change(cs, field, change)

          %{deduplicated: d, original: o} ->
            num = d + 1 + o
            change = String.replace(change, Regex.compile!("\#{sep}[0-9}]$"), "")
            put_change(cs, field, change <> sep <> to_string(num))
        end
    end
  end

  def maybe_add_slug_if_new(changeset) do
    (get_change(changeset, :title) !== nil &&
       (get_field(changeset, :sync_slug_with_title) ||
          get_field(changeset, :slug) === nil))
    |> if do
      put_change(
        changeset,
        :slug,
        Slugger.slugify(get_field(changeset, :name))
      )
    else
      changeset
    end
  end

  @spec merge_localized_map(Ecto.Changeset.t(), atom(), map()) :: Ecto.Changeset.t()
  def merge_localized_map(cs, key, params) do
    if Map.has_key?(params, key) do
      Map.get(params, key)
      |> Enum.reduce(
        get_field(cs, key),
        fn {locale, value}, current_value ->
          Map.put(
            current_value,
            locale,
            Map.merge(
              Map.get(current_value, locale) || %{},
              value
            )
          )
        end
      )
      |> then(fn res ->
        put_change(cs, key, res)
      end)
    else
      cs
    end
  end

  @spec merge_localized_value(Ecto.Changeset.t(), atom(), map()) :: Ecto.Changeset.t()
  def merge_localized_value(cs, key, params) do
    value = Map.get(params, key)
    if value do
      current_value = get_field(cs, key) || %{}
      put_change(cs, key, Map.merge(current_value, value))
    else
      cs
    end
  end

  @spec slugify_slug(any) :: any
  def slugify_slug(%Ecto.Changeset{changes: %{slug: slug}} = cs) when not is_nil(slug) do
    put_change(cs, :slug, Slugger.slugify_downcase(slug))
  end

  def slugify_slug(cs), do: cs
end
