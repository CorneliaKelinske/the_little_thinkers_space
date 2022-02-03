defmodule TheLittleThinkersSpaceWeb.UserView do
  use TheLittleThinkersSpaceWeb, :view

  def render("user.json", %{user: user}) do
    %{id: user.id, name: user.name}
  end
end
