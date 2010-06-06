class SolrFlareWorker < BackgrounDRb::MetaWorker
  set_worker_name :solr_flare_worker
  pool_size 2
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def reindex_document(arguments={})
    #move this back into the actual plugin and add a :commitWithin clause
    SolrFlare.action_reindex(arguments[:id], arguments[:model_name])
    persistent_job.finish!
  end
end
