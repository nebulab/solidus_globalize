# frozen_string_literal: true

require 'globalize'
require 'friendly_id/globalize'

module SolidusGlobalize
  class Engine < Rails::Engine
    engine_name 'solidus_globalize'

    def self.activate_decorators_directory(directory)
      base_path = File.join(root, "lib", engine_name, directory)

      Dir.glob(File.join(base_path, "*")) do |decorators_folder|
        Rails.autoloaders.main.push_dir(decorators_folder)
      end

      Dir.glob(File.join(base_path, "**/*.rb")) do |decorator_path|
        Rails.configuration.cache_classes ? require(decorator_path) : load(decorator_path)
      end
    end

    def self.activate
      activate_decorators_directory("decorators")

      if SolidusSupport.backend_available?
        activate_decorators_directory("backend/decorators")
        Rails.autoloaders.main.push_dir(File.join(root, "lib/solidus_globalize/backend/controllers"))
        paths["app/controllers"] << "lib/solidus_globalize/backend/controllers"
        paths["app/views"] << "lib/solidus_globalize/backend/views"
      end

      if SolidusSupport.frontend_available?
        activate_decorators_directory("frontend/decorators")
        Rails.autoloaders.main.push_dir(File.join(root, "lib/solidus_globalize/frontend/controllers"))
        paths["app/controllers"] << "lib/solidus_globalize/frontend/controllers"
        paths["app/views"] << "lib/solidus_globalize/frontend/views"
      end

      if SolidusSupport.api_available?
        activate_decorators_directory("api/decorators")
        Rails.autoloaders.main.push_dir(File.join(root, "lib/solidus_globalize/api/controllers"))
        paths["app/controllers"] << "lib/solidus_globalize/api/controllers"
        paths["app/views"] << "lib/solidus_globalize/api/views"
      end
    end

    config.to_prepare(&method(:activate).to_proc)

    initializer "solidus_globalize.environment", before: :load_config_initializers do |_app|
      SolidusGlobalize::Config = SolidusGlobalize::Configuration.new
    end

    initializer "solidus_globalize.permitted_attributes",
      before: :load_config_initializers do |_app|
      taxon_attributes = {
        translations_attributes: [
          :id,
          :locale,
          :name,
          :description,
          :permalink,
          :meta_description,
          :meta_keywords,
          :meta_title,
        ]
      }
      ::Spree::PermittedAttributes.taxon_attributes << taxon_attributes

      option_value_attributes = {
        translations_attributes: [
          :id,
          :locale,
          :name,
          :presentation,
        ]
      }
      ::Spree::PermittedAttributes.option_value_attributes << option_value_attributes

      store_attributes = {
        translations_attributes: [
          :id,
          :locale,
          :name,
          :meta_description,
          :meta_keywords,
          :seo_title,
        ]
      }
      ::Spree::PermittedAttributes.store_attributes << store_attributes
    end
  end
end
