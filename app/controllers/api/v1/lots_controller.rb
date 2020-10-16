class Api::V1::LotsController < ApplicationController
  before_action :set_lot_and_storage, only: %i[for_sale ship_to_player recall]

  def for_sale
    error = deal_conditions(:on_market)
    price = params[:price].to_i
    amount = params[:amount].to_i
    result = error || @lot.send_to(:on_market, amount, @storage.id, price)
    body, status = response_receiver(result)
    render(xml: body, root: :lot, skip_types: true, status: status)
  end

  def ship_to_player
    error = deal_conditions(:storage)
    result = error || @lot.send_to(:storage, params[:amount].to_i, @storage.id)
    body, status = response_receiver(result)
    render(xml: body, root: :lot, skip_types: true, status: status)
  end

  def recall
    error = deal_conditions(:storage)
    result = error || @lot.send_to(:storage, @lot.amount, @storage.id)
    body, status = response_receiver(result)
    render(xml: body, root: :lot, skip_types: true, status: status)
  end

  private

  def deal_conditions(location)
    return ["lot wasn't found", 404] unless @lot
    return ["storage wasn't found", 422] unless @storage
    return extra_conditions(location) if extra_conditions(location)
    return ['not enough items', 422] if @lot.amount < params[:amount].to_i
  end

  def extra_conditions(location)
    return unless @lot.send("#{location}?")
    return ['already on the market', 422] if @lot.on_market?
    return ['lot has to be on sale', 422] if @lot.storage?
  end

  def set_lot_and_storage
    @lot = Lot.find_by(id: params[:id])
    @storage = Player.find_by(id: params[:secret_key])&.storage
  end
end
