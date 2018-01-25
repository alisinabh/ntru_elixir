defmodule NtruElixirTest.KeyPairTest do
  use ExUnit.Case
  doctest NtruElixir.KeyPair

  alias NtruElixir.KeyPair

  test "All paramteres sent to key pair are added to it" do
    pub_key = "public_key_test"
    priv_key = "private_key_test"
    ntru_params = :EES593EP1
    assert {:ok, key} = KeyPair.new(pub_key, ntru_params, priv_key)
    assert %{pub_key: ^pub_key, priv_key: ^priv_key, ntru_params: ^ntru_params} = key
  end

  test "Add a private key less key" do
    pub_key = "public_key_test"
    ntru_params = :EES593EP1
    assert {:ok, key} = KeyPair.new(pub_key, ntru_params)
    assert %{pub_key: ^pub_key, priv_key: nil, ntru_params: ^ntru_params} = key
  end

  test "Only binary public key is accepted" do
    pub_key = ["public_key_test"]
    priv_key = "private_key_test"
    ntru_params = :EES593EP1
    assert {:error, :bad_public_key} = KeyPair.new(pub_key, ntru_params, priv_key)
  end

  test "Only binary private key is accepted" do
    pub_key = "public_key_test"
    priv_key = 1234
    ntru_params = :EES593EP1
    assert {:error, :bad_private_key} = KeyPair.new(pub_key, ntru_params, priv_key)
  end

  test "Ntru params filteration" do
    pub_key = "public_key_test"
    priv_key = "priv_key_test"
    ntru_params = "junk"
    assert {:error, :bad_ntru_params} = KeyPair.new(pub_key, ntru_params, priv_key)
  end
end
