defmodule TheLittleThinkersSpace.Email.AddCrewRequest do
  @moduledoc """
  Email to be sent to the Admin to request the addition of a new crew member
  """
  alias TheLittleThinkersSpace.Email.AddCrewRequestContent
  import Ecto.Changeset

  @request_attrs [
    :from_email,
    :subject,
    :little_thinker_first_name,
    :little_thinker_last_name,
    :new_crew_first_name,
    :new_crew_last_name,
    :new_crew_email,
    :message
  ]

  @doc "Ensure that data is valid before it is sent"
  def changeset(attrs) do
    {%AddCrewRequestContent{}, AddCrewRequestContent.types()}
    |> cast(attrs, @request_attrs)
    |> validate_required(@request_attrs,
      message: "This box must not be empty!"
    )
  end
end
