# desc "Explaining what the task does"
# task :solr_flare do
#   # Task goes here
# end

namespace :solr_flare do
  task :setup do
    config_dir = "#{RAILS_ROOT}/config/solr_flare"
    unless File.exists?(config_dir)
      puts "Creating Config Directory"
      Dir.mkdir(config_dir)
    end
    config_dest = "#{config_dir}/solr_flare.yml"
    unless File.exists?(config_dest)
      puts "Copying solr_flare.yml config file to #{config_dest}"
      File.open("#{File.dirname(__FILE__)}/../config/default.yml", 'r') do |file|
        File.open(config_dest, 'w') { |f| f.write(file.read) }
      end
    end
    
    worker_dir = "#{RAILS_ROOT}/lib/workers"
    unless File.exists?(worker_dir)
      puts "Creating Worker Directory"
      Dir.mkdir(worker_dir)
    end
    
    worker_dest = "#{worker_dir}/solr_flare_worker.rb"
    unless File.exists?(worker_dest)
      puts "Copying solr_flare_worker.rb config file to #{config_dest}"
      File.open("#{File.dirname(__FILE__)}/../workers/solr_flare_worker.rb", 'r') do |file|
        File.open(worker_dest, 'w') { |f| f.write(file.read) }
      end
    end
  end
end