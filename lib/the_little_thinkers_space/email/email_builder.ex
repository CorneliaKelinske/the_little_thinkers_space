defmodule TheLittleThinkersSpace.Email.EmailBuilder do
  @moduledoc """
  Uses Swoosh to create an email from the data entered into the contact form
  """
  import Swoosh.Email

  def create_email(%{from_email: from_email, name: name, subject: subject, message: message}) do
    new()
    |> to({"Cornelia", "corneliakelinske@gmail.com"})
    |> from({name, from_email})
    |> subject(subject)
    |> html_body("<h1>#{message}</h1>")
    |> text_body("#{message}\n")
  end
end
