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

    (exception = location_exceptions(location)) && (return exception)
    (exception = ovnership_exceptions) && (return exception)
    return ['not enough items', 422] if @lot.amount < params[:amount].to_i
  end

  def ovnership_exceptions
    no_ownership = @lot.player.id != @storage.player.id
    no_right_for_sale = no_ownership && @lot.storage?
    no_right_to_recall = no_ownership && action_name == 'recall'
    no_right = no_right_for_sale || no_right_to_recall
    return ['you have to own this lot', 422] if no_right
  end

  def location_exceptions(location)
    return unless @lot.send("#{location}?")
    return ['already on the market', 422] if @lot.on_market?
    return ['lot has to be on sale', 422] if @lot.storage?
  end

  def set_lot_and_storage
    @lot = Lot.find_by(id: params[:id])
    @storage = Player.find_by(id: params[:secret_key])&.storage
  end
end
