ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(TheLittleThinkersSpace.Repo, :manual)
File.rm_rf!("priv/static/uploads/test/")
File.mkdir!("priv/static/uploads/test/")
