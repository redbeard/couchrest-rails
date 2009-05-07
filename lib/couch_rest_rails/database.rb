module CouchRestRails
  module Database
  
    extend self

    def create
      res = CouchRest.get(COUCHDB_SERVER[:instance]) rescue nil
      if res && res['db_name'] && res['db_name'] == COUCHDB_SERVER[:database]
        return "The CouchDB database '#{COUCHDB_SERVER[:database]}' already exists"
      else
        CouchRest.database! COUCHDB_SERVER[:instance]
        return "Created CouchDB database '#{COUCHDB_SERVER[:database]}'"
      end
    end

    def delete
      res = CouchRest.get(COUCHDB_SERVER[:instance]) rescue nil
      if res && res['db_name'] && res['db_name'] == COUCHDB_SERVER[:database]
        CouchRest.delete COUCHDB_SERVER[:instance]
        return "Dropped CouchDB database '#{COUCHDB_SERVER[:database]}'"
      else
        return "The CouchDB database '#{COUCHDB_SERVER[:database]}' does not exist"
      end
    end
    
  end
end