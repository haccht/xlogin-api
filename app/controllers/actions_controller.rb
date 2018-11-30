class ActionsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    @vendor = Vendor.find_by(name: params[:vendor_name])
    request = action_params.to_h.deep_symbolize_keys

    begin
      raise "Invalid vendor name: #{params[:vendor_name]}" unless @vendor
      raise "Missing parameter: 'command'" unless request[:command]
      response = service_call(request)

      action = @vendor.actions.build(
        request:  JSON.generate(filter_password(request.deep_dup)),
        response: JSON.generate(response)
      )
      action.save!

      render json: { ok: true,  request: request, response: response }
    rescue => e
      render json: { ok: false, request: request, error: e.message }
    end
  end

  private
  def action_params
    params.permit({xlogin: {}, captures: [:regexp, :type]}, :command, :command_echo, :command_prompt)
  end

  def service_call(request)
    response = {start_time: Time.now}

    session_pool = @vendor.session_pool(**request[:xlogin])
    session_pool.with do |session|
      body = session.cmd(request[:command])

      response[:body] = body.lines
      response[:body].shift if request[:command_echo]   == false
      response[:body].pop   if request[:command_prompt] == false

      if request[:captures]
        response[:captured] = request[:captures].each_with_bject({}) do |capture, hash|
          match = body.match(Regexp.new(capture[:regexp]))
          next hash unless match

          captured = match.named_captures.transform_values do |v|
            case capture[:type]
            when /string/i  then v.to_s
            when /numeric/i then v.to_f
            when /boolean/i then !!v
            else v
            end
          end

          hash.update(captured)
        end
      end
    end

    response[:finish_time] = Time.now
    response
  end

  def filter_password(request)
    if request[:xlogin][:uri]
      uri = Addressable::URI.parse(request[:xlogin][:uri])
      uri.userinfo = uri.userinfo.gsub(/:(.+)$/, ':[FILTERED]')
      request[:xlogin][:uri] = uri.to_s
    end

    if request[:xlogin][:userinfo]
      userinfo = request[:xlogin][:userinfo]
      request[:xlogin][:userinfo] = userinfo.gsub(/:(.+)$/, ':[FILTERED]')
    end

    if request[:xlogin][:password]
      request[:xlogin][:password] = '[FILTERED]'
    end

    request
  end

end
