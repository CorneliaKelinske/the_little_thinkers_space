defmodule TheLittleThinkersSpaceWeb.LittleThinkerView do
  use TheLittleThinkersSpaceWeb, :view
  alias TheLittleThinkersSpace.{Accounts, Accounts.Profile}

  def display_profile_link(little_thinker) do
    case Accounts.get_user_profile(little_thinker.id) do
      %Profile{} = profile ->
        profile_id = to_string(profile.id)

        link("Meet #{little_thinker.first_name}",
          to: "/profiles/" <> profile_id,
          class: "btn-index"
        )

      _ ->
        content_tag(:a, "Future home of #{little_thinker.first_name}'s profile")
    end
  end
end
