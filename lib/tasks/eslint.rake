desc 'Runs ESlint with Yarn'
task eslint: :environment do
  puts 'Running ESlint...'
  system 'yarn lint'

  exit(1) unless $CHILD_STATUS.success?
end
