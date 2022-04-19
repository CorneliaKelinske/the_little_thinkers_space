defmodule TheLittleThinkersSpaceWeb.CrewView do
  use TheLittleThinkersSpaceWeb, :view

  alias TheLittleThinkersSpace.Accounts

  def display_profile_link(crew_id) do
    case Accounts.get_user_profile(crew_id) do
      %Accounts.Profile{} = profile ->
        profile_id = to_string(profile.id)
        link("SHOW", to: "/profiles/" <> profile_id)
     _ -> content_tag(:a, "NOTHING TO SEE YET")

   end
  end
end
