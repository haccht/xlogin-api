class Vendor < ApplicationRecord
  has_many :actions
  validates :name, presence: true, uniqueness: true

  before_save do
    self.name = name.scan(/\w+/).join('_').downcase
    self
  end

  def to_param
    name.to_s.downcase
  end

  def session(**opts)
    factory = Xlogin.factory
    factory.set_template(name, template)
    factory.build(type: name, **opts)
  end

  def session_pool(**opts)
    factory = Xlogin.factory
    factory.set_template(name, template) unless factory.list_templates.include?(name)

    pool = factory.build_pool(type: name, **opts)
    pool.size = pool_size
    pool.idle = pool_idle
    pool
  end
end
