class Api::V1::AdvertisementsController < ApplicationController
  def create
    @lot = Lot.find_by(id: params[:lot_id])
    result = check_conditions || @lot.create_advertisement(body: params[:body])
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
    return ['lot is not on market', 422] if @lot.storage?
    return ['lot already has an advertisement', 422] if @lot.advertisement
  end

  def filter_parameters
    filter = {}
    %i[amount name price].each do |p|
      filter[p] = params[p] unless params[p].nil?
    end
    filter
  end
end
