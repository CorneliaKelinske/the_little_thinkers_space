defmodule TheLittleThinkersSpaceWeb.LittleThinkerView do
  use TheLittleThinkersSpaceWeb, :view
  alias TheLittleThinkersSpace.{Accounts, Accounts.Profile}

  def display_profile_link(little_thinker) do
    case Accounts.get_user_profile(little_thinker.id) do
      %Profile{} = profile ->
        profile_id = to_string(profile.id)
        link("Meet #{little_thinker.first_name}", to: "/profiles/" <> profile_id)

      _ ->
        content_tag(:a, "Future home of #{little_thinker.first_name}'s profile")
    end
  end

  def display_crew_or_lt_button(%{role: "The Little Thinker"}) do
    # link("SHOW", to: "/profiles/" <> profile_id)
    link("The Crew", to: "/crew")
  end

  def display_crew_or_lt_button(_user) do
    link("Choose another Little Thinker", to: "/little_thinkers")
  end
end
