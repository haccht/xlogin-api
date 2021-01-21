class Pool < ApplicationRecord
  after_initialize do
    factory = Xlogin.factory
    factory.set_template(self.name, self.template) unless factory.get_template(self.name)
  end

  after_update do
    factory = Xlogin.factory
    factory.list_hostinfo("type:#{self.name}").each do |hostinfo|
      hostkey = hostinfo[:name]
      hostinfo = factory.get_hostinfo(hostkey)
      hostinfo[:pool].close
      factory.set_hostinfo(hostkey, pool: nil)
    end
  end

  def generate(**opts)
    factory = Xlogin.factory
    hostkey = opts.map { |k, v| "#{k}=#{v}" }.join('&')

    hostinfo = factory.get_hostinfo(hostkey)
    unless hostinfo && hostinfo[:pool]
      pool = factory.build_pool(type: self.name, **opts)
      pool.size = self.size
      pool.idle = self.idle

      hostinfo = {type: self.name, pool: pool}
      factory.set_hostinfo(hostkey, **hostinfo)
    end

    hostinfo[:pool]
  end
end
