defmodule TheLittleThinkersSpaceWeb.LittleThinkerView do
  use TheLittleThinkersSpaceWeb, :view
  alias TheLittleThinkersSpace.{Accounts, Accounts.Profile}

  def display_profile_link(little_thinker_id) do
    case Accounts.get_user_profile(little_thinker_id) do
      %Profile{} = profile ->
        profile_id = to_string(profile.id)
        link("SHOW", to: "/profiles/" <> profile_id)

      _ ->
        content_tag(:a, "NOTHING TO SEE YET")
    end
  end
end
