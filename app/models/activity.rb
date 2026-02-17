class Activity < ApplicationRecord
  belongs_to :contact

  KINDS = %w[note call email].freeze

  validates :kind, inclusion: { in: KINDS }
  validates :body, presence: true

  def kind_icon
    case kind
    when "call"  then "📞"
    when "email" then "✉️"
    else              "📝"
    end
  end
end
