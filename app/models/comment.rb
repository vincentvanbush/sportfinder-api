class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :event
  belongs_to :user

  field :content, type: String

  validates_presence_of :event
  validates_presence_of :user
  validates :content, presence: true, length: { maximum: 300 }

  validate :last_comment_user

  def last_comment_user
    previous_comment = self.event.comments.reverse[1]
    if previous_comment.present?
      last_user = previous_comment.user
      errors.add(:user_id, 'cannot add another comment after his own one') if last_user == self.user
    end
  end

  scope :after, ->(timestamp) {
    datetime = DateTime.strptime(timestamp.to_s, '%s')
    where(:created_at.gt => datetime)
  }
end
