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

    @pools[opts] = factory.build_pool(
      type:      vendor.name,
      pool_size: vendor.pool_size,
      pool_idle: vendor.pool_idle,
      **opts
    )
  end

  def to_param
    name.to_s.downcase
  end
end
