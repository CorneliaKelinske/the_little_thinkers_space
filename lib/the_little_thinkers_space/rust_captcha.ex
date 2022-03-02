defmodule TheLittleThinkersSpace.RustCaptcha do
  @moduledoc """
  Uses Rust to generate a captcha in the form of a tuple consisting of
  a string and a base 64 encoded binary
  """
  use Rustler, otp_app: :the_little_thinkers_space, crate: "rustcaptcha"

  # When your NIF is loaded, it will override this function.
  def generate, do: :erlang.nif_error(:nif_not_loaded)
end
