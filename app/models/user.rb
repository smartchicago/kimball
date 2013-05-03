class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :encryptable, :rememberable, :trackable, :stretches => 10
end
