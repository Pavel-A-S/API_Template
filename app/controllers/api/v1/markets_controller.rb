class Api::V1::MarketsController < ApplicationController
  def show
    result = Storage.find_by(id: params[:id]) || ["market wasn't found", 404]
    body, status = response_receiver(result)
    render(xml: body, root: :market, skip_types: true, status: status)
  end
end
