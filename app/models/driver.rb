class Driver < ApplicationRecord
  after_initialize do
    factory = Xlogin.factory
    factory.set_template(self.name, self.template) unless factory.get_template(self.name)
  end

  after_update do
    factory = Xlogin.factory
    factory.list_hostinfo("type:#{self.name}").each do |hostinfo|
      hostkey = hostinfo[:name]
      hostinfo = factory.get_hostinfo(hostkey)
      hostinfo[:driver].close
      factory.set_hostinfo(hostkey, driver: nil)
    end
  end

  def generate(**opts)
    factory = Xlogin.factory
    hostkey = opts.map { |k, v| "#{k}=#{v}" }.join('&')

    hostinfo = factory.get_hostinfo(hostkey)
    unless hostinfo && hostinfo[:driver]
      driver = factory.build_driver(type: self.name, **opts)
      driver.size = self.size
      driver.idle = self.idle

      hostinfo = {type: self.name, driver: driver}
      factory.set_hostinfo(hostkey, **hostinfo)
    end

    hostinfo[:driver]
  end
end
