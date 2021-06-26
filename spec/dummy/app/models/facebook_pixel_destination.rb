class FacebookPixelDestination < Segmentation::Destination
  def fields_from_request(request)
    {}.tap do |fields|
      if request
        fields[:ip] = request.remote_ip
        fields[:userAgent] = request.user_agent

        fields[:fbc] = request.cookies["_fbc"] if request.cookies["_fbc"].present?
        fields[:fbp] = request.cookies["_fbp"] if request.cookies["_fbp"].present?
      end
    end
  end

  def context_from_fields(fields)
    {
      ip: fields[:ip],
      userAgent: fields[:userAgent]
    }.compact
  end

  def properties_from_fields(fields)
    {
      fbc: fields[:fbc],
      fbp: fields[:fbp]
    }.compact
  end
end
