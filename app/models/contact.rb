class Contact < ApplicationRecord
  belongs_to :company, optional: true
  has_many :contact_tags, dependent: :destroy
  has_many :tags, through: :contact_tags
  has_many :activities, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email" },
                    uniqueness: { case_sensitive: false }

  scope :active, -> { where(archived_at: nil) }
  scope :starred, -> { where(starred: true, archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def archived?
    archived_at.present?
  end
end
