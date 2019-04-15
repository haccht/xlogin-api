class Vendor < ApplicationRecord
  has_many :actions
  validates :name, presence: true, uniqueness: true

  before_save do
    self.name = name.scan(/\w+/).join('_').downcase
    self
  end

  def self.build_pool(vendor, **opts)
    @pools ||= {}
    return @pools[opts] if @pools[opts]

    factory = Xlogin.factory
    factory.set_template(vendor.name, vendor.template) unless factory.get_template(vendor.name)

    pool = factory.build_pool(type: vendor.name, **opts)
    pool.size = vendor.pool_size
    pool.idle = vendor.pool_idle

    @pools[opts] = pool
  end

  def to_param
    name.to_s.downcase
  end
end
