defmodule Rehoboam.FileUploadLocal do
  @behaviour Rehoboam.FileUpload
  @files_directory Application.compile_env(:rehoboam, :files_directory)
  alias Rehoboam.FileUpload

  @spec file_name(map()) :: String.t()
  def file_name(%{uuid: uuid, title_safe: title_safe}) do
    Enum.join([uuid, title_safe], "/")
  end

  @spec get_path(map()) :: String.t()
  def get_path(%{type: type, title_safe: _, uuid: _} = ctx) do
    Enum.join([@files_directory, type, file_name(ctx)], "/")
  end

  @impl true
  def get_url(%{type: _, title_safe: _, uuid: _} = ctx, _) do
    Enum.join(
    [ctx.title_safe, ctx.uuid],
      "/"
    )
  end

  @impl true
  def upload(%FileUpload{path: path} = ctx) do
    File.write(
      get_path(ctx),
      File.read!(path)
    )
  end
end
