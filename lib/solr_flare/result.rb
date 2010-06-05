class SolrFlare::Result < Array
  attr_accessor :num_found, :start, :per_page
  def initialize(xml)
    classes = []
    self.num_found = 0
    ObjectSpace.each_object(Class){|model| classes << model.to_s}
    if response = Nokogiri::XML(xml).try(:css,"result[name=response]")
      self.num_found = response.attribute('numFound').try(:value) ||0
      self.num_found = self.num_found.to_i
      self.start = response.attribute('start').try(:value) ||0
      self.start = self.start.to_i
      docs = response.css('doc')
      self.per_page = docs.size
      docs.each do |doc|
        model_name = doc.css("str[name=model_name]").text
        id = doc.css("str[name=id]").text
        if classes.include?(model_name)
          begin
            self << eval(model_name).find(id.to_i)
          rescue ActiveRecord::RecordNotFound => e
            puts "WARNING:: Unable to find instance #{doc.inspect}"
          end
        else
          puts "WARNING:: No such class #{doc.inspect}"
        end
      end
    end
  end
  
  def total_pages
    if per_page > 0
      total = num_found/per_page
      if num_found%per_page
        total+=1
      end
    else
      total = 0
    end
    total
  end
  
  def current_page
    per_page > 0 ? start/per_page : 0
  end
  
  def next_start_num
    start+per_page
  end
end