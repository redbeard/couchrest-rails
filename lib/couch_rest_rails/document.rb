module CouchRestRails
  class Document < CouchRest::ExtendedDocument

    include Validatable

    def self.use_database(db)
      db = [COUCHDB_CONFIG[:db_prefix], db.to_s, COUCHDB_CONFIG[:db_suffix]].join
      self.database = COUCHDB_SERVER.database(db)
    end
    
    def self.unadorned_database_name
      database.name.sub(/^#{COUCHDB_CONFIG[:db_prefix]}/, '').sub(/#{COUCHDB_CONFIG[:db_suffix]}$/, '')
    end
    
    def self.has_many(of_model, override_options = {})
      foreign_class = class_for(of_model)
      default_options = {
        :foreign_key => "#{self.to_s.underscore}_id",
        :association_id => "#{of_model.to_s}", 
      }

      options = default_options.merge(override_options)

      install_foreign_view(foreign_class, options)
      install_association_getter(foreign_class, options)
    end

  private

    def self.install_association_getter(foreign_class, options)
      view_getter_code = <<VIEW_GETTER_CODE
        def #{options[:association_id].to_s}(*opts)
          #{foreign_class}.by_#{options[:foreign_key]}(self.id, *opts)
        end 
VIEW_GETTER_CODE

      self.module_eval(view_getter_code)
    end

    def self.install_foreign_view(foreign_class, options)
      foreign_code_block = <<VIEW_BY_CODE
        view_by :#{options[:foreign_key]}
VIEW_BY_CODE

      foreign_class.module_eval(foreign_code_block)

    end

    def self.class_for(plural)
      plural.to_s.classify.constantize
    end
  end
end
