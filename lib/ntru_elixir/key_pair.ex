defmodule NtruElixir.KeyPair do
  @moduledoc """
  This module holds functions to generate | save | and converting
  NTRU public and private keys.
  """
  # @enforce_keys [:pub_key]

  alias NtruElixir.Base

  defstruct [:pub_key, :priv_key]

  @type t ::
    %__MODULE__{pub_key: binary(), priv_key: binary()}

  @doc """
  Generates an NTRU key pair with given strength

  For more information on strength please visit
  [libntru - Parameter Sets](https://github.com/tbuktu/libntru#parameter-sets)

  ## Parameters
    - strength: an atom representing the strngth of generated NTRU keypair.
  """
  @spec generate_key_pair(Base.ntru_params_t) :: %__MODULE__{}
  def generate_key_pair(strength \\ :NTRU_DEFAULT_PARAMS_128_BITS)
  def generate_key_pair(strength) do
    {:ok, pub_key, priv_key} = Base.gen_key_pair(strength, :default)
    new(pub_key, priv_key)
  end

  #
  # Helpers
  #

  defp new(pub_key, priv_key), do:
    {:ok, %__MODULE__{pub_key: pub_key, priv_key: priv_key}}
end
