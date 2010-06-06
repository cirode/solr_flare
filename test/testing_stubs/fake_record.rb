class FakeRecord
  def initialize(first_level=true)
    @index = []
    @index2 = []
    if first_level
      @index += [FakeRecord.new(false)]
      @index2 += [FakeRecord.new(false), FakeRecord.new(false)]
    end
  end
  
  def index
    @index
  end
  
  def index2
    @index2
  end
  
  def data
    "This is the data"
  end
end