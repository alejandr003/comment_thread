defmodule CommentThread.Repo do
  use Ecto.Repo,
    otp_app: :comment_thread,
    adapter: Ecto.Adapters.Postgres
end
