class FakeDocument
  def initialize(id)
    @id = id
  end
  
  def id
    @id
  end
  
  def self.find(id)
    if (id % 2)==0
      return self.new(id)
    else
      raise ActiveRecord::RecordNotFound, "Unable to find it :)"
    end
  end
end