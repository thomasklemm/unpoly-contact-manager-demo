class Company < ApplicationRecord
  has_many :contacts

  validates :name, presence: true

  def to_s
    name
  end
end
