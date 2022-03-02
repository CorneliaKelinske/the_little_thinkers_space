defmodule TheLittleThinkersSpace.DataPath do
  @moduledoc """
  This module gets the data path from the corresponding config file.
  """
  def set_data_path do
    Application.get_env(:the_little_thinkers_space, :data_path)
  end
end
