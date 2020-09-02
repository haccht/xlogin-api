class Vendor < ApplicationRecord
  has_many :actions
  validates :name, presence: true, uniqueness: true

  before_save do
    self.name = name.scan(/\w+/).join('_').downcase
    self
  end

  after_initialize do
    factory = Xlogin.factory
    factory.set_template(name, template) unless factory.get_template(name)
  end

  def build_pool(**opts)
    factory = Xlogin.factory
    hostkey = opts[:host] || opts[:uri]

    hostinfo = factory.get_hostinfo(hostkey)
    unless hostinfo
      hostinfo = {
        pool: factory.build_pool(
          type:      hostkey,
          pool_size: pool_size,
          pool_idle: pool_idle,
          **opts
        )
      }
      factory.set_hostinfo(hostkey, **hostinfo)
    end

    hostinfo[:pool]
  end

  def to_param
    name.to_s.downcase
  end
end
