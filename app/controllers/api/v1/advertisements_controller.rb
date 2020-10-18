class Api::V1::AdvertisementsController < ApplicationController
  def create
    @lot = Lot.find_by(id: params[:lot_id])
    @storage = Player.find_by(id: params[:secret_key])&.storage
    error = check_conditions
    result = error || @lot.build_advertisement(body: params[:body]).publish
    body, status = response_receiver(result)
    render(xml: body, root: :advertisement, skip_types: true, status: status)
  end

  def index
    @data = Advertisement.includes(:lot, :item).with_filter(filter_parameters)
    render(xml: @data, root: :advertisements, skip_types: true, status: 200)
  end

  private

  def check_conditions
    return ["lot wasn't found", 404] unless @lot

    (exception = ovnership_exceptions) && (return exception)
    return ['lot is not on market', 422] if @lot.storage?
    return ['lot already has an advertisement', 422] if @lot.advertisement
  end

  def ovnership_exceptions
    no_right = @lot.player.id != @storage&.player&.id
    return ['you have to own this lot', 422] if no_right
  end

  def filter_parameters
    filter = {}
    %i[amount name price].each do |p|
      filter[p] = params[p] unless params[p].nil?
    end
    filter
  end
end
