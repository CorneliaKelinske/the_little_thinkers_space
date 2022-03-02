defmodule TheLittleThinkersSpace.MailerTest do
  use TheLittleThinkersSpace.DataCase
  alias TheLittleThinkersSpace.{Email.EmailBuilder, Mailer}
  import Swoosh.TestAssertions

  @valid_params %{
    from_email: "tester@test.com",
    name: "testy McTestface",
    subject: "Testing, testing",
    message: "Hello, this is a test"
  }

  test "deliver/1 delivers an email from a user to a mailbox" do
    response =
      @valid_params
      |> EmailBuilder.create_email()
      |> Mailer.deliver()

    assert {:ok, %{}} = response
    assert_email_sent()
  end
end
