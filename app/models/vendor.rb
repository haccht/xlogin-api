class Vendor < ApplicationRecord
  has_many :actions
  validates :name, presence: true, uniqueness: true

  before_save do
    self.name = self.name.scan(/\w+/).join('_').downcase
    self
  end

  after_update do
    factory = Xlogin.factory
    factory.list_hostinfo("type:#{self.name}").each do |hostinfo|
      hostkey = hostinfo[:name]
      factory.set_hostinfo(hostkey, pool: nil)
    end
  end

  after_initialize do
    factory = Xlogin.factory
    factory.set_template(self.name, self.template) unless factory.get_template(self.name)
  end

  def session_pool(**opts)
    factory = Xlogin.factory
    hostkey = opts[:host] || opts[:uri]

    hostinfo = factory.get_hostinfo(hostkey)
    unless hostinfo && hostinfo[:pool]
      pool = factory.build_pool(type: self.name, **opts)
      pool.size = self.pool_size
      pool.idle = self.pool_idle

      hostinfo = {type: self.name, pool: pool}
      factory.set_hostinfo(hostkey, **hostinfo)
    end

    hostinfo[:pool]
  end

  def to_param
    name.to_s.downcase
  end
end
