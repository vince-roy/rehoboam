defmodule RehoboamGraphQl.Resolver.User do
  alias Potionx.Context.Service
  alias Rehoboam.Users.User
  alias Rehoboam.Users.UserService
  use Absinthe.Relay.Schema.Notation, :modern

  def collection(args, %{context: %Service{} = ctx}) do
    q = UserService.query(ctx)
    count = UserService.count(ctx)
    count_before = get_count_before(ctx, count)

    q
    |> Absinthe.Relay.Connection.from_query(
      &Rehoboam.Repo.all/1,
      ensure_first_page_is_full(args),
      count: count
    )
    |> case do
      {:ok, result} ->
        {
          :ok,
          Map.merge(
            result,
            %{
              count: count,
              count_before: count_before
            }
          )
        }

      err ->
        err
    end
  end

  def data do
    Dataloader.Ecto.new(Rehoboam.Repo, query: &UserService.query/2)
  end

  def delete(_, %{context: %Service{} = ctx}) do
    UserService.delete(ctx)
  end

  def ensure_first_page_is_full(args) do
    if Map.get(args, :before) do
      Absinthe.Relay.Connection.cursor_to_offset(args.before)
      |> elem(1)
      |> Kernel.<(args.last)
      |> if do
        %{
          first: args.last
        }
      else
        args
      end
    else
      args
    end
  end

  def get_count_before(ctx, count) do
    cond do
      not is_nil(ctx.pagination.after) ->
        Absinthe.Relay.Connection.cursor_to_offset(ctx.pagination.after)
        |> elem(1)

      not is_nil(ctx.pagination.before) ->
        Absinthe.Relay.Connection.cursor_to_offset(ctx.pagination.before)
        |> elem(1)
        |> Kernel.-(ctx.pagination.last)
        |> max(0)

      not is_nil(ctx.pagination.last) ->
        count - ctx.pagination.last

      true ->
        0
    end
  end

  def me(_, %{context: %Service{user: %User{id: id}}}) do
    {:ok, Rehoboam.Repo.get!(User, id)}
  end

  def me(_, _) do
    {:ok, nil}
  end

  def mutation(_, %{context: %Service{} = ctx}) do
    UserService.mutation(ctx)
    |> case do
      {:ok, %{user: res}} -> {:ok, res}
      {:error, _, err, _} -> {:error, err}
      res -> res
    end
  end

  def one(_, %{context: %Service{} = ctx}) do
    {:ok, UserService.one(ctx)}
  end
end
