class Vendor < ApplicationRecord
  def session(**opts)
    factory = Xlogin.factory
    factory.set_template(name, template)
    factory.build(type: name, **opts)
  end

  def session_pool(**opts)
    factory = Xlogin.factory
    factory.set_template(name, template)
    factory.build_pool(type: name, pool_size: 3, **opts)
  end
end
