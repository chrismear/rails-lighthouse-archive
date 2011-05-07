#!/bin/bash
changed_files=( 
associations/belongs_to_associations 
associations/callbacks 
associations/cascaded_eager_loading
associations/has_and_belongs_to_many_associations
associations
finder
method_scoping
persistence
query_cache
relations
transaction_callbacks
validations/i18n_generate_message_validation
validations
xml_serialization
)

for file in "${changed_files[@]}" 
do
  rake test_postgresql TEST="test/cases/${file}_test.rb"
done
