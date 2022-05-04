defmodule TheLittleThinkersSpaceWeb.CrewController do
  @moduledoc """
  This controller handles the users with the role Crew in relation to The Little Thinker
  """
  use TheLittleThinkersSpaceWeb, :controller
  alias TheLittleThinkersSpace.{Accounts, Accounts.Relationship}

  action_fallback TheLittleThinkersSpaceWeb.FallbackController

  def index(conn, %{"little_thinker_id" => little_thinker_id}) do
    user = conn.assigns.current_user
    little_thinker_id = String.to_integer(little_thinker_id)
    little_thinker = Accounts.get_user!(little_thinker_id)

    relationship_type =
      conn.assigns
      |> Map.get(:relationship_type, nil)
      |> case do
        nil -> Accounts.get_relationship_type(little_thinker_id, user.id)
        relationship_type -> relationship_type
      end

    with :ok <- Bodyguard.permit(Relationship, :index, user, {little_thinker, relationship_type}) do
      case user.id === little_thinker_id do
        true ->
          render(conn, "index.html",
            little_thinker: little_thinker,
            crews: user.crews,
            relationship_type: relationship_type
          )

        _ ->
          %{crews: crews} = Accounts.get_little_thinker_crew(little_thinker)

          render(conn, "index.html",
            little_thinker: little_thinker,
            crews: crews,
            relationship_type: relationship_type
          )
      end
    end
  end
end
