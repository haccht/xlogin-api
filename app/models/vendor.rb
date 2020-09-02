class Vendor < ApplicationRecord
  has_many :actions
  validates :name, presence: true, uniqueness: true

  after_initialize :load_template
  def load_template
    factory = Xlogin.factory
    factory.set_template(self.name, self.template) unless factory.get_template(self.name)
  end

  before_save do
    self.name = self.name.scan(/\w+/).join('_').downcase
    self
  end

  def to_param
    name.to_s.downcase
  end
end
