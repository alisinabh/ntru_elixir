defmodule ExNtru.Base do
  @moduledoc """
  Base libntru nif interface
  """

  @on_load :load_nifs

  @doc false
  def load_nifs do
    path = :filename.join(:code.priv_dir(:ex_ntru), 'ntru_nif')
    :erlang.load_nif(path, 0)
  end

  def gen_key_pair(key_type \\ :NTRU_DEFAULT_PARAMS_128_BITS, rng \\ :NTRU_RNG_DEFAULT)
  def gen_key_pair(_, _) do
    raise "Function gen_key_pair is not implemented!"
  end
end
