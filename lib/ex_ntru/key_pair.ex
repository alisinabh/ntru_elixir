defmodule ExNtru.KeyPair do
  @moduledoc """
  This module holds functions to generate | save | and converting
  NTRU public and private keys.
  """
  # @enforce_keys [:pub_key]
  defstruct [:pub_key, :priv_key]

  @type t ::
    %__MODULE__{pub_key: binary(), priv_key: binary()}

  alias ExNtru.Base

  @typedoc """
  These are NTRU key strengths. It is recommended to Use one of:

    - `:NTRU_DEFAULT_PARAMS_112_BITS`
    - `:NTRU_DEFAULT_PARAMS_128_BITS`
    - `:NTRU_DEFAULT_PARAMS_192_BITS`
    - `:NTRU_DEFAULT_PARAMS_256_BITS`

  as your key strength on generation. its all dependent on your security messures.

  For more information please visit:
  [libntru - Parameter Sets](https://github.com/tbuktu/libntru#parameter-sets)
  """
  @type ntru_strength :: :EES401EP1 | :EES541EP1 | :EES659EP1 |
   :NTRU_DEFAULT_PARAMS_112_BITS | :EES449EP1 | :EES613EP1 | :EES761EP1 |
   :EES439EP1 | :EES443EP1 | :NTRU_DEFAULT_PARAMS_128_BITS | :EES677EP1 |
   :EES887EP1 | :EES1087EP1 | :EES593EP1 | :EES587EP1 |
   :NTRU_DEFAULT_PARAMS_192_BITS | :EES1087EP2 | :EES1171EP1 | :EES1499EP1 |
   :EES743EP1 | :NTRU_DEFAULT_PARAMS_256_BITS

  @doc """
  Generates an NTRU key pair with given strength

  For more information on strength please visit
  [libntru - Parameter Sets](https://github.com/tbuktu/libntru#parameter-sets)

  ## Parameters
    - strength: an atom representing the strngth of generated NTRU keypair.
  """
  @spec generate_key_pair(ntru_strength) :: %__MODULE__{}
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
