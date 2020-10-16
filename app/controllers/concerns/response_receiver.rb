module ResponseReceiver
  private

  def response_receiver(result)
    return [result.select_fields, 200] if result.try(:errors)&.none?

    message, code = result.try(:errors)&.any? ? [result.errors, 422] : result
    [{ error: message }, code]
  end
end
