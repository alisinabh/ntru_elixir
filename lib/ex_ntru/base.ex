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

  def gen_key_pair(ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS, rng \\ :NTRU_RNG_DEFAULT)
  def gen_key_pair(_, _) do
    raise "Function gen_key_pair is not implemented!"
  end

  def encrypt(pub_key, data_bin, ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS)
  def encrypt(_, _, _) do
    raise "Function encrypt is not implemented!"
  end

  def decrypt(pub_key, priv_key, enc_bin, ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS)
  def decrypt(_, _, _, _) do
    raise "Function decrypt is not implemented!"
  end
end
