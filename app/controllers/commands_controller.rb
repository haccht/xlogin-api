class CommandsController < ApplicationController
  skip_before_action :verify_authenticity_token

  DEFAULT_TIMEOUT = 10

  include ActionController::Live

  def show
    logger.info command_params

    respond_to do |format|
      format.html do
        @query = command_params
      end
      format.json do
        begin
          resp = StringIO.new
          execute { |c| resp.print(c) }
          render json: {success: true,  payload: resp.string.lines[1...-1]}
        rescue => e
          render json: {success: false, payload: resp.string.lines[1...-1], error: e.message }, status: :unprocessable_entity
        end
      end
      format.stream do
        begin
          response.set_header('Content-Type', 'text/event-stream')
          response.set_header('Last-Modified', Time.now.httpdate)
          execute { |c| response.stream.write("data: #{JSON.generate({chunk: c})}\n\n") }
        rescue => e
          logger.error(e.message)
          response.stream.write("data: #{JSON.generate({chunk: e.message})}\n\n")
        ensure
          response.stream.close
        end
      end
    end
  end

  private
  def command_params
    params.require(:q)
  end

  def userinfo_params
    ActionController::HttpAuthentication::Basic.decode_credentials(request)
  end

  def execute(&block)
    params = JSON.parse(command_params).deep_symbolize_keys
    params[:target].update(log: $stdout) if Rails.env.development?

    unless userinfo_params.empty?
      if params[:target][:userinfo]
        params[:userinfo] = userinfo_params
      end
      if params[:target][:uri]
        uri = Addressable::URI.parse(params[:target][:uri])
        uri.userinfo = userinfo_params
        params[:target][:uri] = uri.to_s
      end
    end

    timeout = params[:target].delete(:timeout) || DEFAULT_TIMEOUT
    command = params[:command]
    outputs = StringIO.new

    factory = Driver.find_by(name: params[:driver])
    raise "No such driver - #{params[:driver]}" unless factory

    factory.generate(**params[:target]).with do |s|
      begin
        s.cmd('') { |chunk| block.call(chunk) }

        command = [command] unless command.kind_of?(Array)
        command.each do |command_args|
          case command_args
          when String
            command_args = {'String' => command_args, 'Timeout' => timeout}
          when Hash
            command_args = {'Timeout' => timeout}.merge(command_args.transform_keys(&:to_s))
            command_args['Match'] = Regexp.new(command_args['Match']) if command_args['Match']
          else
            raise "Invalid argument - #{JSON.generate(command_args)}"
          end
          outputs.print s.cmd(command_args) { |chunk| block.call(chunk) }
        end
      rescue => e
        s.close if s
        raise e
      ensure
        outputs.string
      end
    end
  end
end
