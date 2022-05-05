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
    |> html_body("""
        <p>Little Thinker:#{little_thinker_first_name} #{little_thinker_last_name}</p>
        <p> Please add: #{new_crew_first_name} #{new_crew_last_name}</p>
        <p> Their email address is #{new_crew_email}</p>
        <p> #{message}
    """)
    |> text_body("""
    Little Thinker: #{little_thinker_first_name} #{little_thinker_last_name}
    Please add: #{new_crew_first_name} #{new_crew_last_name}
    Their email address is #{new_crew_email}
    #{message}\n
    """)
  end

  def create_remove_crew_request(%{
        from_email: from_email,
        little_thinker_first_name: little_thinker_first_name,
        little_thinker_last_name: little_thinker_last_name,
        remove_crew_first_name: remove_crew_first_name,
        remove_crew_last_name: remove_crew_last_name,
        message: message
      }) do
    new()
    |> to({"Cornelia", "corneliakelinske@gmail.com"})
    |> from(from_email)
    |> subject("Remove Crew Member")
    |> html_body("""
        <p>Little Thinker:#{little_thinker_first_name} #{little_thinker_last_name}</p>
        <p> Please remove: #{remove_crew_first_name} #{remove_crew_last_name}</p>
        <p> #{message}
    """)
    |> text_body("""
    Little Thinker: #{little_thinker_first_name} #{little_thinker_last_name}
    Please remove: #{remove_crew_first_name} #{remove_crew_last_name}
    #{message}\n
    """)
  end
end
