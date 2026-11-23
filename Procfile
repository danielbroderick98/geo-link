# Prepare the database before Heroku starts the new release.
release: bundle exec rails db:prepare
# Single-mode Puma loads Rails before the job supervisor and keeps memory use down.
web: env WEB_CONCURRENCY=0 SOLID_QUEUE_IN_PUMA=true bundle exec puma -C config/puma.rb
