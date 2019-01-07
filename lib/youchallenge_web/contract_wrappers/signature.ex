defmodule Blockchain.Signature do
  @secp256k1n 115_792_089_237_316_195_423_570_985_008_687_907_852_837_564_279_074_904_382_605_163_141_518_161_494_337
  @secp256k1n_2 round(:math.floor(@secp256k1n / 2))
  @base_recovery_id 27
  @base_recovery_id_eip_155 35

  def get_public_key(private_key) do
    case :libsecp256k1.ec_pubkey_create(private_key, :uncompressed) do
      {:ok, public_key} -> {:ok, public_key}
      {:error, reason} -> {:error, to_string(reason)}
    end
  end

  def sign_hash(hash, private_key, chain_id \\ nil) do
    {:ok, <<r::size(256), s::size(256)>>, recovery_id} =
      :libsecp256k1.ecdsa_sign_compact(hash, private_key, :default, <<>>)

    # Fork Ψ EIP-155
    recovery_id =
      if chain_id do
        chain_id * 2 + @base_recovery_id_eip_155 + recovery_id
      else
        @base_recovery_id + recovery_id
      end

    {recovery_id, r, s}
  end

  def recover_public(hash, v, r, s, chain_id \\ nil) do
    signature =
      BitHelper.pad(:binary.encode_unsigned(r), 32) <>
        BitHelper.pad(:binary.encode_unsigned(s), 32)

    # Fork Ψ EIP-155
    recovery_id =
      if not is_nil(chain_id) and uses_chain_id?(v) do
        v - chain_id * 2 - @base_recovery_id_eip_155
      else
        v - @base_recovery_id
      end

    case :libsecp256k1.ecdsa_recover_compact(hash, signature, :uncompressed, recovery_id) do
      {:ok, <<_byte::8, public_key::binary()>>} -> {:ok, public_key}
      {:error, reason} -> {:error, to_string(reason)}
    end
  end

  def is_signature_valid?(is_homestead, r, s, v) do
    r > 0 and r < @secp256k1n and s > 0 and
      if(is_homestead, do: s < @secp256k1n_2, else: s < @secp256k1n) and (v == 27 || v == 28)
  end

  def transaction_hash(trx, chain_id \\ nil) do
    Blockchain.Transaction.serialize(trx, false)
    # See EIP-155
    |> Kernel.++(if chain_id, do: [chain_id |> :binary.encode_unsigned(), <<>>, <<>>], else: [])
    |> ExRLP.encode()
    |> BitHelper.kec()
  end

  def sign_transaction(trx, private_key, chain_id \\ nil) do
    {v, r, s} =
      trx
      |> transaction_hash(chain_id)
      |> sign_hash(private_key, chain_id)

    %{trx | v: v, r: r, s: s}
  end

  def address_from_private(private_key) do
    {:ok, public_key} = get_public_key(private_key)

    address_from_public(public_key)
  end

  def address_from_public(public_key) do
    public_key
    |> BitHelper.kec()
    |> BitHelper.mask_bitstring(20 * 8)
  end

  def sender(trx, chain_id \\ nil) do
    # Ignore chain_id if transaction has a `v` value before EIP-155 minimum
    chain_id = if not uses_chain_id?(trx.v), do: nil, else: chain_id

    with {:ok, public_key} <-
           recover_public(transaction_hash(trx, chain_id), trx.v, trx.r, trx.s, chain_id) do
      {:ok, address_from_public(public_key)}
    end
  end

  defp uses_chain_id?(v) do
    v >= @base_recovery_id_eip_155
  end
end
