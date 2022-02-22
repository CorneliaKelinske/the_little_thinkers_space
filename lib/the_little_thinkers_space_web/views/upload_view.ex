defmodule TheLittleThinkersSpaceWeb.UploadView do
  use TheLittleThinkersSpaceWeb, :view
  alias TheLittleThinkersSpace.Content.Upload

  def display_image(%Upload{file: file, file_type: file_type}) do
    ~E"""
    <img class="object-cover overflow-hidden rounded-lg" src=data:<%= file_type %>;base64,<%= Base.encode64(file) %>>
    """
  end

  def display_video(%Upload{file: file}) do
    ~E"""
    <video class="object-cover overflow-hidden rounded-lg" autoplay controls>
      <source src="data:video/mp4;base64,<%= Base.encode64(file) %>" />
    </video>
    """
  end

  def display_image_thumbnail(%Upload{file: file, file_type: file_type}) do
    ~E"""
    <img class="w-[320px] h-[180px] object-cover rounded-lg" src="data:<%= file_type %>;base64,<%= Base.encode64(file)%>">
    """
  end

  def display_video_thumbnail(%Upload{file: file}) do
    ~E"""
    <video class="w-[320px] h-[180px] object-cover rounded-lg" controls>
      <source src="data:video/mp4;base64,<%= Base.encode64(file)%>" />
    </video>
    """
  end
end
