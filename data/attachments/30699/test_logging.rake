task :test_logging => :environment do
  RAILS_DEFAULT_LOGGER.info "This should, but won't, show up in the production.log file."
end
