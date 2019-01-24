defmodule ContractWrappers.ChallengerAccounts do
  @moduledoc """
  A wrapper around challenger_accounts smart contract
  """

  alias Ethereumex.HttpClient, as: Eth
  alias Blockchain.{Signature, Transaction}
  alias ContractWrappers.Deployer

  @address "8911B7Aa374b0E4c9002cD0532f847eD07454322"

  def create_challenger(address) do
    normalized_address = String.slice(address, 2..-1)

    ABI.encode("createChallenger(address)", [Base.decode16!(normalized_address, case: :mixed)])
    |> form_transaction()
  end

  defdelegate decode_gas_price, to: Deployer
  # defdelegate decode_gas_estimate(encoded_data), to: Deployer
  defdelegate decode_account_nonce, to: Deployer

  defp form_transaction(encoded_data) do
    encoded_transaction =
      %Transaction{
        to: encoded_address(),
        gas_limit: 100_000,
        data: encoded_data,
        gas_price: decode_gas_price(),
        nonce: decode_account_nonce()
      }
      |> Signature.sign_transaction(hex_pk())
      |> Transaction.serialize()
      |> ExRLP.encode()
      |> Base.encode16(case: :lower)

    Eth.eth_send_raw_transaction("0x" <> encoded_transaction)
  end

  def incrementActiveChallenges(address) do
    normalized_address = String.slice(address, 2..-1)

    encoded_transaction =
      %Transaction{
        to: encoded_address(),
        gas_limit: 50_000,
        data:
          ABI.encode("incrementActiveChallenges(address)", [
            Base.decode16!(normalized_address, case: :mixed)
          ]),
        gas_price: decode_gas_price(),
        nonce: decode_account_nonce()
      }
      |> Signature.sign_transaction(hex_pk())
      |> Transaction.serialize()
      |> ExRLP.encode()
      |> Base.encode16(case: :lower)

    Eth.eth_send_raw_transaction("0x" <> encoded_transaction)
  end

  def update_challenge_status(address, status) do
    normalized_address = String.slice(address, 2..-1)

    encoded_transaction =
      %Transaction{
        to: encoded_address(),
        gas_limit: 100_000,
        data:
          ABI.encode("updateChallengeStatus(address,bool)", [
            Base.decode16!(normalized_address, case: :mixed),
            status
          ]),
        gas_price: decode_gas_price(),
        nonce: decode_account_nonce()
      }
      |> Signature.sign_transaction(hex_pk())
      |> Transaction.serialize()
      |> ExRLP.encode()
      |> Base.encode16(case: :lower)

    Eth.eth_send_raw_transaction("0x" <> encoded_transaction)
  end

  def challenger_present?(address) do
    normalized_address = String.slice(address, 2..-1)

    abi =
      ABI.encode("challengerPresent(address)", [Base.decode16!(normalized_address, case: :mixed)])
      |> Base.encode16(case: :lower)

    Eth.eth_call(%{to: "0x" <> @address, data: "0x" <> abi})
    |> parse_int()
    |> (fn x -> x == 1 end).()
  end

  def verify_challenger(address) do
    case __MODULE__.challenger_present?(address) do
      true ->
        true

      _ ->
        __MODULE__.create_challenger(address)
        {:message, :confirming_challenger}
    end
  end

  def new_challenge_eligible?(address) do
    case __MODULE__.call("getAllowedCount", address) > __MODULE__.call("getActiveCount", address) do
      true -> true
      false -> {:error, :conflict}
    end
  end

  def call(type, address) when is_binary(type) do
    normalized_address = String.slice(address, 2..-1)

    abi =
      ABI.encode("#{type}(address)", [Base.decode16!(normalized_address, case: :mixed)])
      |> Base.encode16(case: :lower)

    Eth.eth_call(%{to: "0x" <> @address, data: "0x" <> abi})
    |> parse_int()
  end

  defp encoded_address() do
    Base.decode16!(@address, case: :mixed)
  end

  def hex_pk() do
    Application.get_env(:youchallenge, :seed)
    |> BitHelper.from_hex()
  end

  def parse_int({_, "0x"}), do: 0

  def parse_int({:ok, hex_value}) do
    String.slice(hex_value, 2..-1)
    |> Integer.parse(16)
    |> elem(0)
  end
end
