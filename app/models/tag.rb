class Tag < ApplicationRecord
  has_many :contact_tags, dependent: :destroy
  has_many :contacts, through: :contact_tags

  validates :name, presence: true
  validates :color, presence: true

  def to_s
    name
  end
end
