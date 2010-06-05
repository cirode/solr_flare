require 'digest'
class SolrFlare::Encryption
  def self.create_token
    return Digest::SHA2.hexdigest("#{Time.now.to_s}--#{Process.pid}")
  end
  
  def self.encrypt(password, salt)
    return Digest::SHA2.hexdigest("#{password}--#{salt}")    
  end
end