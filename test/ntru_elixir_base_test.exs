defmodule NtruElixirTest.BaseTest do
  use ExUnit.Case

  alias NtruElixir.Base, as: NtruBase

  require Logger

  @all_ntru_params [:EES401EP1,
    :EES541EP1,
    :EES659EP1,
    :NTRU_DEFAULT_PARAMS_112_BITS,
    :EES449EP1,
    :EES613EP1,
    :EES761EP1,
    :EES439EP1,
    :EES443EP1,
    :NTRU_DEFAULT_PARAMS_128_BITS,
    :EES677EP1,
    :EES887EP1,
    :EES1087EP1,
    :EES593EP1,
    :EES587EP1,
    :NTRU_DEFAULT_PARAMS_192_BITS,
    :EES1087EP2,
    :EES1171EP1,
    :EES1499EP1,
    :EES743EP1,
    :NTRU_DEFAULT_PARAMS_256_BITS]

  @sample_input "This is a message from alice to bob."

  test "Create a new keypair" do
    assert :ok = test_gen_keypair(@all_ntru_params)
  end

  test "Generate a new pub key for a given private key" do
    assert :ok = test_gen_pub_key(@all_ntru_params)
  end

  test "Create a milti pub_key key pair" do
    assert :ok = test_gen_multi_pub_pair(@all_ntru_params)
  end

  test "A successful encryption" do
    assert :ok = test_success_encryption(@all_ntru_params)
  end

  defp test_success_encryption([ntru_params | tail]) do
    {:ok, pub_key, priv_key} = NtruBase.gen_key_pair(ntru_params)
    {:ok, enc_bin} = NtruBase.encrypt(pub_key, @sample_input, ntru_params)
    dec_result = NtruBase.decrypt(pub_key, priv_key, enc_bin, ntru_params)

    case dec_result do
      {:ok, @sample_input} ->
        test_success_encryption(tail)
      {:ok, other_bin} ->
        Logger.error("Decryption of '#{@sample_input}' resulted in wrong"
                <> " decryption '#{other_bin}'")
        {:error, :wrong_decryption}
      {:error, reason} ->
        {:error, reason}
      error ->
        {:error, inspect(error)}
    end
  end
  defp test_success_encryption([]), do: :ok

  defp test_gen_multi_pub_pair([ntru_params | tail]) do
    pub_count = Enum.random(1..15)
    {:ok, pub_keys, _priv_key} = NtruElixir.Base.gen_key_pair_multi(pub_count, ntru_params)
    case Enum.count pub_keys do
      ^pub_count when is_list(pub_keys) ->
        test_gen_multi_pub_pair(tail)
      count ->
        {:error, :wrong_key_count}
    end
  end
  defp test_gen_multi_pub_pair([]), do: :ok

  defp test_gen_pub_key([ntru_params | tail]) do
    {:ok, pub, priv} = NtruBase.gen_key_pair(ntru_params)
    case NtruBase.gen_pub_key(priv, ntru_params) do
      {:ok, new_pub} ->
        if new_pub == pub do
          {:error, :same_key}
        else
          test_gen_pub_key(tail)
        end
      {:error, reason} ->
        {:error, reason}
      error ->
        {:error, inspect(error)}
    end
  end
  defp test_gen_pub_key([]), do: :ok

  defp test_gen_keypair([ntru_params | tail]) do
    case NtruBase.gen_key_pair(ntru_params) do
      {:ok, _key, _priv_key} ->
        test_gen_keypair(tail)
      {:error, reason} ->
        {:error, reason}
      error ->
        {:error, inspect(error)}
    end
  end
  defp test_gen_keypair([]), do: :ok

end
