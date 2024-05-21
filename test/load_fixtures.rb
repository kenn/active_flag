I18n.load_path << File.join(File.dirname(__FILE__), 'files/locales.yml')

ActiveRecord::Base.send(:include, ActiveFlag)

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Base.connection.create_table :profiles, force: true do |t|
  t.integer :languages, null: false, default: 0
  t.integer :features, null: false, default: 0
  t.integer :figures
end

module Features
  EMAILS = 'bronze.emails'
  STREAMING = 'silver.streaming'
  AUTOMATION = 'gold.automation'
end

class Profile < ActiveRecord::Base
  flag :languages, [:english, :spanish, :chinese, :french, :japanese]
  flag :others, [:thing]
  flag :figures, [:square, :circle]
  flag :features, [Features::EMAILS, Features::STREAMING, Features::AUTOMATION]
end

class SubProfile < Profile
end

class Other < ActiveRecord::Base
  flag :others, [:another]
end

Profile.create(languages: [:english], features: [Features::EMAILS])
Profile.create(languages: [:japanese], features: [Features::EMAILS, Features::STREAMING])
Profile.create(languages: [:english, :japanese])
