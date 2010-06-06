class SolrFlare::Result < Array
  attr_accessor :num_found, :start, :per_page
  def initialize(xml, per_page)
    self.per_page = per_page
    classes = []
    self.num_found = 0
    if response = Nokogiri::XML(xml).try(:css,"result[name=response]")
      self.num_found = response.attribute('numFound').try(:value) ||0
      self.num_found = self.num_found.to_i
      self.start = response.attribute('start').try(:value) ||0
      self.start = self.start.to_i
      docs = response.css('doc')
      docs.each do |doc|
        model_name = doc.css("str[name=model_name]").text
        id = doc.css("str[name=id]").text
        if instance = SolrFlare.get_model_instance(model_name)
          begin
            self << eval(model_name).find(id.to_i)
          rescue ActiveRecord::RecordNotFound => e
            Rails.logger.warn "WARNING:: Unable to find instance #{doc.inspect}"
          end
        else
          Rails.logger.warn "WARNING:: No such class #{doc.inspect}"
        end
      end
    end
  end
  
  def total_pages
    if per_page > 0
      total = num_found/per_page
      if num_found%per_page>0
        total+=1
      end
    else
      total = 0
    end
    total
  end
  
  def current_page
    per_page > 0 ? (start/per_page) +1: 0
  end
end