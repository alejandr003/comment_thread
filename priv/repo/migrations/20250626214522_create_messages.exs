defmodule CommentThread.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text

      timestamps(type: :utc_datetime)
    end
  end
end
