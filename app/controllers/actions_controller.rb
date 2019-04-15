class ActionsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    @vendor = Vendor.find_by(name: params[:vendor_name])

    begin
      req = action_params.to_h.deep_symbolize_keys
      raise "Invalid vendor name: #{params[:vendor_name]}" unless @vendor
      raise "Missing parameter: 'command'" unless req[:command]
      logger.debug("API Request: #{req}")

      resp = service_call(req)
      hash = { ok: true,  request: req, response: resp }
      #logger.debug("API Response: #{hash}")
      render json: hash
    rescue => e
      hash = { ok: false, request: req, error: { message: e.to_s, trace: e.backtrace.to_s } }
      #logger.debug("API Response: #{hash}")
      render json: hash
    end
  end

  private
  def action_params
    params.permit({xlogin: {}, captures: [:regexp, :type]}, :command, :command_echo, :command_prompt)
  end

  def service_call(req)
    resp = {start_time: Time.now}

    session_pool = Vendor.build_pool(@vendor, **req[:xlogin])
    session_pool.with do |session|
      body = req[:command].lines.map { |commandline| session.cmd(commandline) }.join

      resp[:body] = body.lines
      resp[:body].shift if req[:command_echo]   == false
      resp[:body].pop   if req[:command_prompt] == false

      if req[:captures]
        resp[:captured] = req[:captures].each_with_object({}) do |capture, hash|
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

    resp[:finish_time] = Time.now
    resp
  end

  def filter_password(req)
    if req[:xlogin][:uri]
      uri = Addressable::URI.parse(req[:xlogin][:uri])
      uri.userinfo = uri.userinfo.gsub(/:(.+)$/, ':[FILTERED]')
      req[:xlogin][:uri] = uri.to_s
    end

    if req[:xlogin][:userinfo]
      userinfo = req[:xlogin][:userinfo]
      req[:xlogin][:userinfo] = userinfo.gsub(/:(.+)$/, ':[FILTERED]')
    end

    if req[:xlogin][:password]
      req[:xlogin][:password] = '[FILTERED]'
    end

    req
  end

end
