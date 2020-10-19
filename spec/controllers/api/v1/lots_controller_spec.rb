require 'rails_helper'

RSpec.describe Api::V1::LotsController, type: :controller do
  fixtures :Lots, :Players, :Storages, :Items

  before(:all) do
    @purchase_request = {
      id: 1, secret_key: 2, amount: 5
    }

    @purchase_response = {
      'lot' => {
        'id' => nil,
        'item_id' => '1',
        'amount' => '5',
        'price' => '0',
        'status' => 'storage',
        'item' => {
          'id' => '1',
          'name' => 'Item1'
        }
      }
    }

    @lot_for_sale_request = {
      id: 2, secret_key: 1, amount: 5, price: 25
    }

    @lot_for_sale_response = {
      'lot' => {
        'id' => nil,
        'item_id' => '2',
        'amount' => '5',
        'price' => '25',
        'status' => 'on_market',
        'item' => {
          'id' => '2',
          'name' => 'Item2'
        }
      }
    }
    @recall_request = {
      id: 1, secret_key: 1
    }

    @recall_response = {
      'lot' => {
        'id' => nil,
        'item_id' => '1',
        'amount' => '5',
        'price' => '0',
        'status' => 'storage',
        'item' => {
          'id' => '1',
          'name' => 'Item1'
        }
      }
    }
  end

  describe 'Lot purchase: ' do
    it 'Player has to be able to buy lot' do
      @lot_price = Lots(:on_market_player1).price
      @player1 = Players(:player1)
      @player2 = Players(:player2)
      expected_player1_balance = @player1.currency_amount + @lot_price
      expected_player2_balance = @player2.currency_amount - @lot_price

      put :ship_to_player, params: @purchase_request

      player1_balance = Player.find_by(id: @player1.id).currency_amount
      player2_balance = Player.find_by(id: @player2.id).currency_amount
      (result = Hash.from_xml(response.body)) && (result['lot']['id'] = nil)

      expect(result).to eq(@purchase_response)
      expect(player1_balance).to eq(expected_player1_balance)
      expect(player2_balance).to eq(expected_player2_balance)
      expect(@player2.lots.count).to eq(3)
      expect(Lot.count).to eq(4)
    end
  end

  describe 'Lot for sale: ' do
    it 'Player has to be able to send lot on market' do
      put :for_sale, params: @lot_for_sale_request

      (result = Hash.from_xml(response.body)) && (result['lot']['id'] = nil)

      expect(result).to eq(@lot_for_sale_response)
      expect(Players(:player1).lots.count).to eq(2)
      expect(Lot.count).to eq(4)
    end
  end

  describe 'Lot recall: ' do
    it 'Player has to be able to recall lot' do
      put :recall, params: @recall_request

      (result = Hash.from_xml(response.body)) && (result['lot']['id'] = nil)

      expect(result).to eq(@recall_response)
      expect(Players(:player1).lots.count).to eq(2)
      expect(Lot.count).to eq(4)
    end
  end
end
