defmodule TheLittleThinkersSpace.Email.EmailBuilder do
  @moduledoc """
  Uses Swoosh to create an email from the data entered into the contact form
  """
  import Swoosh.Email

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

  def create_email(%{from_email: from_email, name: name, subject: subject, message: message}) do
    new()
    |> to({"Cornelia", "corneliakelinske@gmail.com"})
    |> from({name, from_email})
    |> subject(subject)
    |> html_body("<h1>#{message}</h1>")
    |> text_body("#{message}\n")
  end

  def create_add_crew_request(%{
        from_email: from_email,
        little_thinker_first_name: little_thinker_first_name,
        little_thinker_last_name: little_thinker_last_name,
        new_crew_first_name: new_crew_first_name,
        new_crew_last_name: new_crew_last_name,
        new_crew_email: new_crew_email,
        message: message
      }) do
    new()
    |> to({"Cornelia", "corneliakelinske@gmail.com"})
    |> from(from_email)
    |> subject("Add New Crew Member")
    |> html_body("<p>Little Thinker:#{little_thinker_first_name} #{little_thinker_last_name}</p>
      <p> Please add: #{new_crew_first_name} #{new_crew_last_name}</p>
      <p> Their email address is #{new_crew_email}</p>
      <p> #{message}")
    |> text_body("Little Thinker:#{little_thinker_first_name} #{little_thinker_last_name}\n
      Please add: #{new_crew_first_name} #{new_crew_last_name}\n
      Their email address is #{new_crew_email}\n
      #{message}\n")
  end
end
