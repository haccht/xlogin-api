class ActionsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    @vendor = Vendor.find_by(name: params[:vendor_name])
    request = action_params.to_h.deep_symbolize_keys

    begin
      raise "Invalid vendor name: #{params[:vendor_name]}" unless @vendor

      pool = @vendor.session_pool(**request[:xlogin])
      response = action_execute(pool, request)

      hash = { ok: true,  request: request, response: response }
      render json: hash
    rescue => e
      hash = { ok: false, request: request, error: { message: e.to_s, trace: e.backtrace.to_s } }
      render json: hash
    end
  end

  private
  def action_params
    params.permit(:command, xlogin: {}, captures: [:regexp, :type])
  end

  def action_execute(pool, request)
    resp = {start_time: Time.now}

    pool.with do |session|
      resp[:body] = request[:command].lines.flat_map { |e| session.cmd(e).lines }

      if request[:captures]
        resp[:captured] = request[:captures].each_with_object({}) do |capture, hash|
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

  def filter_password(request)
    if request[:xlogin][:uri]
      uri = Addressable::URI.parse(request[:xlogin][:uri])
      uri.userinfo = uri.userinfo.gsub(/:(.+)$/, ':[FILTERED]')
      request[:xlogin][:uri] = uri.to_s
    elsif request[:xlogin][:userinfo]
      userinfo = request[:xlogin][:userinfo]
      request[:xlogin][:userinfo] = userinfo.gsub(/:(.+)$/, ':[FILTERED]')
    elsif request[:xlogin][:password]
      request[:xlogin][:password] = '[FILTERED]'
    end

    request
  end

end
