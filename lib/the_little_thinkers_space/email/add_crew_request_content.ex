defmodule TheLittleThinkersSpace.Email.AddCrewRequestContent do
  @moduledoc "The content for a request form for adding a crew member"
  defstruct from_email: nil,
            to_email: nil,
            subject: nil,
            little_thinker_first_name: nil,
            little_thinker_last_name: nil,
            new_crew_first_name: nil,
            new_crew_last_name: nil,
            new_crew_email: nil,
            message: nil

  @type t :: %__MODULE__{
          from_email: String.t(),
          to_email: String.t(),
          subject: String.t(),
          little_thinker_first_name: String.t(),
          little_thinker_last_name: String.t(),
          new_crew_first_name: String.t(),
          new_crew_last_name: String.t(),
          new_crew_email: String.t(),
          message: String.t()
        }

  @spec types :: %{
          from_email: :string,
          to_email: :string,
          subject: :string,
          little_thinker_first_name: :string,
          little_thinker_last_name: :string,
          new_crew_first_name: :string,
          new_crew_last_name: :string,
          new_crew_email: :string,
          message: :string
        }
  def types do
    %{
      from_email: :string,
      to_email: :string,
      subject: :string,
      little_thinker_first_name: :string,
      little_thinker_last_name: :string,
      new_crew_first_name: :string,
      new_crew_last_name: :string,
      new_crew_email: :string,
      message: :string
    }
  end
end
