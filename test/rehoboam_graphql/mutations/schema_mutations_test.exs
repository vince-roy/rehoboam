defmodule RehoboamGraphQl.Schema.SchemaMutationTest do
  use Rehoboam.DataCase
  alias Rehoboam.Schemas.SchemaMock
  alias Rehoboam.Schemas.SchemaService
  import Ecto.Query

  describe "schema delete" do
    setup do
      ctx =
        %Potionx.Context.Service{
          changes: SchemaMock.run()
        }
        |> prepare_ctx

      {:ok, entry} = SchemaService.mutation(ctx)
      {:ok, ctx: ctx, entry: entry}
    end

    test "deletes schema", %{ctx: ctx, entry: entry} do
      Elixir.File.read!("shared/src/models/Schemas/Schema/schemaDelete.gql")
      |> Absinthe.run(
        RehoboamGraphQl.Schema,
        context: ctx,
        variables: %{"filters" => %{"id" => entry.id}}
      )
      |> (fn {:ok, res} ->
            assert res.data["schemaDelete"]["node"]["id"] ===
                     Absinthe.Relay.Node.to_global_id(
                       :schema,
                       entry.id,
                       RehoboamGraphQl.Schema
                     )
          end).()
    end
  end

  describe "schema new mutation" do
    setup do
      ctx =
        %Potionx.Context.Service{
          changes: SchemaMock.run() |> Map.delete(:id)
        }
        |> prepare_ctx

      {:ok, ctx: ctx}
    end

    test "creates schema", %{ctx: ctx} do
      Elixir.File.read!("shared/src/models/Schemas/Schema/schemaMutation.gql")
      |> Absinthe.run(
        RehoboamGraphQl.Schema,
        context: ctx,
        variables: %{
          "changes" => %{
            "handle" => "test",
            "titleI18n" => "test"
          }
        }
      )
      |> (fn {:ok, res} ->
            assert res.data["schemaMutation"]["node"]["id"]
            assert res.data["schemaMutation"]["node"]["titleI18n"] === "test"
            assert Rehoboam.Repo.all(from(f in Rehoboam.Schemas.Field)) |> Enum.count() === 4
          end).()
    end
  end

  describe "schema patch mutation/2" do
    setup do
      ctx =
        %Potionx.Context.Service{
          changes: SchemaMock.run()
        }
        |> prepare_ctx

      {:ok, entry} = SchemaService.mutation(ctx)
      {:ok, ctx: ctx, entry: entry}
    end

    test "patches schema", %{ctx: ctx, entry: entry} do
      Elixir.File.read!("shared/src/models/Schemas/Schema/schemaMutation.gql")
      |> Absinthe.run(
        RehoboamGraphQl.Schema,
        context: ctx,
        variables: %{
          "changes" => %{"private" => true},
          "filters" => %{
            "id" =>
              Absinthe.Relay.Node.to_global_id(
                :schema,
                entry.id,
                RehoboamGraphQl.Schema
              )
          }
        }
      )
      |> (fn {:ok, res} ->
            assert res.data["schemaMutation"]["node"]["internalId"] === "#{entry.id}"
            assert res.data["schemaMutation"]["node"]["private"]
          end).()
    end
  end
end
