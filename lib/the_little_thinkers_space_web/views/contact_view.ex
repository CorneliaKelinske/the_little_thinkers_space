defmodule TheLittleThinkersSpaceWeb.ContactView do
  use TheLittleThinkersSpaceWeb, :view

  def display_captcha(captcha_image) do
    ~E"""
    <img src=data:image/png;base64,<%= captcha_image %>>
    """
  end
end
