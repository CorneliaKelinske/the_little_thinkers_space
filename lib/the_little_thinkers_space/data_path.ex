defmodule TheLittleThinkersSpace.DataPath do
  def set_data_path do
    Application.get_env(:the_little_thinkers_space, :data_path)
  end
end
