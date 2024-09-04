I18n.load_path << File.join(File.dirname(__FILE__), 'files/locales.yml')

ActiveRecord::Base.send(:include, ActiveFlag)

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Base.connection.create_table :profiles, force: true do |t|
  t.integer :languages, null: false, default: 0
  t.integer :figures
end

ActiveRecord::Base.connection.create_table :users, force: true do |t|
  t.string :name, null: false
  t.string :languages # to require table-specificity in SQL queries
  t.integer :profile_id, null: false
end

class Profile < ActiveRecord::Base
  has_many :users

  flag :languages, [:english, :spanish, :chinese, :french, :japanese]
  flag :others, [:thing]
  flag :figures, [:square, :circle]
end

class User < ActiveRecord::Base
  belongs_to :profile
end

class SubProfile < Profile
end

class Other < ActiveRecord::Base
  flag :others, [:another]
end

english_profile = Profile.create(languages: [:english])
japanese_profile = Profile.create(languages: [:japanese])
Profile.create(languages: [:english, :japanese])

User.create(name: 'Prince Harry', profile: english_profile)
User.create(name: 'Queen Elizabeth', profile: english_profile)
User.create(name: 'Shigeru Myamoto', profile: japanese_profile)
