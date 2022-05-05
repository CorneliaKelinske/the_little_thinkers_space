defmodule TheLittleThinkersSpace.Email.RemoveCrewRequestContent do
  @moduledoc "The content for a request form for adding a crew member"
  defstruct from_email: nil,
            to_email: nil,
            subject: nil,
            little_thinker_first_name: nil,
            little_thinker_last_name: nil,
            remove_crew_first_name: nil,
            remove_crew_last_name: nil,
            message: nil

  @type t :: %__MODULE__{
          from_email: String.t(),
          to_email: String.t(),
          subject: String.t(),
          little_thinker_first_name: String.t(),
          little_thinker_last_name: String.t(),
          remove_crew_first_name: String.t(),
          remove_crew_last_name: String.t(),
          message: String.t()
        }

  @spec types :: %{
          from_email: :string,
          to_email: :string,
          subject: :string,
          little_thinker_first_name: :string,
          little_thinker_last_name: :string,
          remove_crew_first_name: :string,
          remove_crew_last_name: :string,
          message: :string
        }
  def types do
    %{
      from_email: :string,
      to_email: :string,
      subject: :string,
      little_thinker_first_name: :string,
      little_thinker_last_name: :string,
      remove_crew_first_name: :string,
      remove_crew_last_name: :string,
      message: :string
    }
  end
end
