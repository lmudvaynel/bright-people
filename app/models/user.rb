class User < ActiveRecord::Base
  devise :omniauthable, :registerable, :rememberable, :trackable, :validatable,
                        :database_authenticatable

  belongs_to :role

  has_many :activity_votes
  has_many :contest_votes
  has_many :contest_memberships
  has_many :favourites
  has_many :comments
  has_many :comment_notifies, class_name: 'UserCommentNotify', through: :comments
  has_many :articles, foreign_key: :author_id
  has_many :activity_approvals
  has_many :approved_activities, through: :activity_approvals, source: :activity
  has_many :photos, class_name: 'GalleryPhoto', dependent: :destroy

  belongs_to :activity

  has_attached_file :avatar, styles: { medium: "300x300^#", thumb: "125x125^#", comment: "84x84^#", approval: "32x32^#" },
                             path: ":rails_root/public/system/users/:attachment/:id/:style/:filename",
                             url: "/system/users/:attachment/:id/:style/:filename",
                             default_style: :thumb, default_url: 'loading.gif'

  attr_accessible :email, :remember_me, :password, :password_confirmation, :avatar, :description, :about,
                  :role_id, :name, :activity_id, :position

  validates :role, presence: true

  # Callbacks
  before_validation(on: :create) do
    self.role = Role.user if role.blank?
  end

  # OPTIMIZE: it's not cool, we should do this in client
  # side, but today I am lazy
  before_save do
    self.activity = nil unless self.manager?
  end

  attr_accessible :email, :name, :password, :remember_me
  attr_accessible :vkontakte_id, :facebook_id, :odnoklassniki_id

  scope :usuals, where(role_id: 1)
  scope :experts, where(role_id: 4)
  scope :managers, where(role_id: 5)
  scope :authors, where(role_id: 6)
  scope :photographers, where(role_id: [7,8])
  scope :junior_photographers, where(role_id: 7)

  scope :authors_with_photos, authors.where('avatar_file_size IS NOT NULL OR avatar_file_size != 0')

  # Show all experts and authors with photos
  scope :experts_authors, where('role_id in (?) AND (avatar_file_size IS NOT NULL OR avatar_file_size != 0)', [4,6])

  # Sphinx should indexing only roles experts
  define_index do
    indexes :name
    where "role_id in (4)"
  end

  def manager?
    role == Role.manager
  end

  def photographer?
    role == Role.main_photographer || Role.photographer
  end

  def main_photographer?
    role == Role.main_photographer
  end

  def notifications
    UserCommentNotify.where(user_id: self.id)
  end

  def ensure_external_avatar!(external_avatar_url)
    file = Tempfile.new('avatar')
    file.binmode
    file << open(external_avatar_url).read
    file.close
    file.open
    self.avatar = file
    self.save!
  end

  def approvals_count
    activity_approvals.count
  end

  def prev_expert
    User.experts.split(self).first.last
  end

  def next_expert
    User.experts.split(self).last.first
  end

  def mentions
    comments.map(&:relation)
      .select {|r| r.class.name.in? Comment.possible_relations }
      .uniq
  end

  def self.find_or_create_for_vkontakte(data)
    user_id = data.extra.raw_info.uid.to_s
    user = find_by_vkontakte_id(user_id)
    if user
      user
    else
      user = self.create! vkontakte_id: user_id,
      password: Devise.friendly_token[0,8],
      name: data.info.name
      photo_url = data.extra.raw_info.photo_big
      user.delay.ensure_external_avatar!(photo_url) if photo_url
      user
    end
  end

  def self.find_or_create_for_facebook(data)
    user_id = data.extra.raw_info.id.to_s
    email = data.extra.raw_info.email
    user = find_by_facebook_id(user_id)
    if user
      user
    else
      user = self.create! facebook_id: user_id,
      email: email,
      password: Devise.friendly_token[0,8],
      name: data.info.name
      photo_url = data.info.image
      user.delay.ensure_external_avatar!(photo_url) if photo_url
      user
    end
  end

  def self.find_or_create_for_odnoklassniki(data)
    user_id = data.extra.raw_info.uid.to_s
    user = find_by_odnoklassniki_id(user_id)
    if user
      user
    else
      user = self.create! odnoklassniki_id: user_id,
      password: Devise.friendly_token[0,8],
      name: data.extra.raw_info.name
      photo_url = data.extra.raw_info.pic_2
      user.delay.ensure_external_avatar!(photo_url) if photo_url
      user
    end
  end

  def email_required?
    false
  end

  # User already voted for this activity
  def already_vote?(object)
    case object
    when Activity
      activity_votes.where(activity_id: object.id).any?
    when ContestMembership
      contest_votes.where(membership_id: object.id).any?
    end
  end

  def author!
    update_attribute(:role, Role.author)
  end

  def first_name
    name.split(' ').first
  end

  def last_name
    name.split(' ').last
  end

  class << self
    def experts_for_main
      User.experts.random(5)
    end
  end
end
