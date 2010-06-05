module SolrFlare::ActiveRecordExtentions
  def self.included(base)
    base.extend ClassMethods
    base.send(:include,InstanceMethods)
  end
  
  module ClassMethods
    def define_index(&block)
      SolrFlare.get_instance.define_index(self, block)
    end
    
    def have_defined_solr_methods?
      @have_defined_solr_methods ||= false
    end
      
    def have_defined_solr_methods(have)
      @have_defined_solr_methods = !!have
    end
  end
  
  module InstanceMethods
    def after_initialize
      puts 'inited'
      unless self.class.have_defined_solr_methods?
        self.class.have_defined_solr_methods(true)
        id = SolrFlare::Encryption.create_token
        solr_index_container = SolrFlare.get_instance
        self.class.after_save solr_index_container.update_index_proc
        self.class.before_destroy solr_index_container.before_destroy_closure(id)
        self.class.after_destroy solr_index_container.after_destroy_closure(id)
      end
    end
  end
end