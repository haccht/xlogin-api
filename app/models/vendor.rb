class Vendor < ApplicationRecord
  has_many :actions

  XLOGIN_SESSION_POOL_SIZE = 3

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
