class Vendor < ApplicationRecord
  has_many :actions
  validates :name, presence: true, uniqueness: true

  XLOGIN_SESSION_POOL_SIZE = 3

  before_save do
    self.name = name.scan(/\w+/).join('_').downcase
    self
  end

  def to_param
    name
  end

  def session(**opts)
    factory = Xlogin.factory
    factory.set_template(name, template)
    factory.build(type: name, **opts)
  end

  def session_pool(**opts)
    factory = Xlogin.factory
    factory.set_template(name, template)
    factory.build_pool(type: name, pool_size: XLOGIN_SESSION_POOL_SIZE, **opts)
  end
end
