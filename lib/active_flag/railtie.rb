module ActiveFlag
  if defined? Rails::Railtie
    class Railtie < Rails::Railtie
      initializer 'active_flag.insert_into_active_record' do |app|
        ActiveSupport.on_load :active_record do
          include ActiveFlag
        end
      end
    end
  end
end
