defmodule TheLittleThinkersSpace.Email.Content do
  @moduledoc "The content for an email message"
  defstruct from_email: nil,
            to_email: nil,
            name: nil,
            subject: nil,
            message: nil,
            answer: nil,
            not_a_robot: nil

  @type t :: %__MODULE__{
          from_email: String.t(),
          to_email: String.t(),
          name: String.t(),
          subject: String.t(),
          message: String.t(),
          answer: String.t(),
          not_a_robot: String.t()
        }

  @spec types :: %{
          from_email: :string,
          message: :string,
          name: :string,
          to_email: :string,
          subject: :string,
          answer: :string,
          not_a_robot: :string
        }
  def types do
    %{
      from_email: :string,
      to_email: :string,
      name: :string,
      subject: :string,
      message: :string,
      answer: :string,
      not_a_robot: :string
    }
  end
end
