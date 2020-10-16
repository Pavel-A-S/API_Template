class Api::V1::PlayersController < ApplicationController
  def show
    result = Player.find_by(id: params[:id]) || ["player wasn't found", 404]
    body, status = response_receiver(result)
    render(xml: body, root: :player, skip_types: true, status: status)
  end
end
