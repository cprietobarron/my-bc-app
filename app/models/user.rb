# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id           :bigint           not null, primary key
#  access_token :string
#  email        :string           not null
#  scope        :string
#  store_hash   :string           not null
#  uid          :string
#  username     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  store_id     :integer
#
# Indexes
#
#  index_users_on_store_hash            (store_hash)
#  index_users_on_store_hash_and_email  (store_hash,email) UNIQUE
#
class User < ApplicationRecord
  encrypts :access_token

  has_one :channel, dependent: :destroy

  validates :store_hash, :email, presence: true
end
