defmodule ContractWrappers.ChallengeContract do
  @moduledoc """
  A wrapper around challenge contract
  """

  alias Ethereumex.HttpClient, as: Eth
  alias Blockchain.{Signature, Transaction}
  alias ContractWrappers.{ChallengerAccounts, Deployer}

  defdelegate decode_gas_price(), to: Deployer
  defdelegate decode_account_nonce(), to: Deployer
  defdelegate parse_int(tuple), to: ChallengerAccounts
  defdelegate hex_pk(), to: ChallengerAccounts

  def extend_expiration(address, days, hours, minutes) do
    normalized_address = String.slice(address, 2..-1)

    encoded_transaction =
      %Transaction{
        to: Base.decode16!(normalized_address, case: :mixed),
        gas_limit: 100_000,
        data: ABI.encode("extendExpiration(uint,uint,uint)", [days, hours, minutes]),
        gas_price: decode_gas_price(),
        nonce: decode_account_nonce()
      }
      |> Signature.sign_transaction(hex_pk())
      |> Transaction.serialize()
      |> ExRLP.encode()
      |> Base.encode16(case: :lower)

    Eth.eth_send_raw_transaction("0x" <> encoded_transaction)
    |> parse_int()
    |> (fn x -> x == 1 end).()
  end

  def extended?(address) do
    normalized_address = String.slice(address, 2..-1)

    abi =
      ABI.encode("extended()", [])
      |> Base.encode16(case: :lower)

    Eth.eth_call(%{to: "0x" <> normalized_address, data: "0x" <> abi})
    |> parse_int()
    |> (fn x -> x == 1 end).()
  end

  def complete(address) do
    normalized_address = String.slice(address, 2..-1)

    encoded_transaction =
      %Transaction{
        to: Base.decode16!(normalized_address, case: :mixed),
        gas_limit: 100_000,
        data: ABI.encode("complete()", []),
        gas_price: decode_gas_price(),
        nonce: decode_account_nonce()
      }
      |> Signature.sign_transaction(hex_pk())
      |> Transaction.serialize()
      |> ExRLP.encode()
      |> Base.encode16(case: :lower)

    Eth.eth_send_raw_transaction("0x" <> encoded_transaction)
    |> parse_int()
    |> (fn x -> x == 1 end).()
  end

  def challenge_balance(contract_address, challenger) do
    normalized_contract_address = String.slice(contract_address, 2..-1)
    normalized_challenger = String.slice(challenger, 2..-1)

    abi =
      ABI.encode("challengeBalance(address)", [
        Base.decode16!(normalized_challenger, case: :mixed)
      ])
      |> Base.encode16(case: :lower)

    Eth.eth_call(%{to: "0x" <> normalized_contract_address, data: "0x" <> abi})
    |> parse_int()
  end

  def expired?(address) do
    normalized_address = String.slice(address, 2..-1)

    abi =
      ABI.encode("expired()", [])
      |> Base.encode16(case: :lower)

    Eth.eth_call(%{to: "0x" <> normalized_address, data: "0x" <> abi})
    |> parse_int()
    |> (fn x -> x == 1 end).()
  end

  def completed?(address) do
    normalized_address = String.slice(address, 2..-1)

    abi =
      ABI.encode("completed()", [])
      |> Base.encode16(case: :lower)

    Eth.eth_call(%{to: "0x" <> normalized_address, data: "0x" <> abi})
    |> parse_int()
    |> (fn x -> x == 1 end).()
  end

  def expiration_date(address) do
    normalized_address = String.slice(address, 2..-1)

    abi =
      ABI.encode("getExpirationDate()", [])
      |> Base.encode16(case: :lower)

    Eth.eth_call(%{to: "0x" <> normalized_address, data: "0x" <> abi})
    |> parse_int()
    |> DateTime.from_unix()
    |> elem(1)
    |> DateTime.to_string()
  end

  def description(address) do
    normalized_address = String.slice(address, 2..-1)

    abi =
      ABI.encode("getDescription()", [])
      |> Base.encode16(case: :lower)

    Eth.eth_call(%{to: "0x" <> normalized_address, data: "0x" <> abi})
    |> elem(1)
    |> String.slice(130..-1)
    |> String.replace_trailing("0", "")
    |> Base.decode16!(case: :lower)
  end

  def challenger(address) do
    address_call("initiator", address)
  end

  def contender(address) do
    address_call("contender", address)
  end

  def flush_balance(address) do
    normalized_address = String.slice(address, 2..-1)

    encoded_transaction =
      %Transaction{
        to: Base.decode16!(normalized_address, case: :mixed),
        gas_limit: 100_000,
        data: ABI.encode("flushBalance()", []),
        gas_price: decode_gas_price(),
        nonce: decode_account_nonce()
      }
      |> Signature.sign_transaction(hex_pk())
      |> Transaction.serialize()
      |> ExRLP.encode()
      |> Base.encode16(case: :lower)

    Eth.eth_send_raw_transaction("0x" <> encoded_transaction)
    |> parse_int()
    |> (fn x -> x == 1 end).()
  end

  def switch_pause(address) do
    normalized_address = String.slice(address, 2..-1)

    encoded_transaction =
      %Transaction{
        to: Base.decode16!(normalized_address, case: :mixed),
        gas_limit: 100_000,
        data: ABI.encode("switchPause()", []),
        gas_price: decode_gas_price(),
        nonce: decode_account_nonce()
      }
      |> Signature.sign_transaction(hex_pk())
      |> Transaction.serialize()
      |> ExRLP.encode()
      |> Base.encode16(case: :lower)

    Eth.eth_send_raw_transaction("0x" <> encoded_transaction)
    |> parse_int()
    |> (fn x -> x == 1 end).()
  end

  def paused?(address) do
    normalized_address = String.slice(address, 2..-1)

    abi =
      ABI.encode("paused()", [])
      |> Base.encode16(case: :lower)

    Eth.eth_call(%{to: "0x" <> normalized_address, data: "0x" <> abi})
    |> parse_int()
    |> (fn x -> x == 1 end).()
  end

  defp address_call(type, address) do
    normalized_address = String.slice(address, 2..-1)

    abi =
      ABI.encode("get#{String.capitalize(type)}()", [])
      |> Base.encode16(case: :lower)

    Eth.eth_call(%{to: "0x" <> normalized_address, data: "0x" <> abi})
    |> elem(1)
    |> String.slice(2..-1)
    |> String.replace_leading("0", "")
    |> (fn str -> "0x" <> str end).()
  end
end
