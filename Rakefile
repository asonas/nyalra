namespace :ridgepole do
  desc 'Export schema definition'
  task :export do
    sh 'ridgepole', '--config', 'config/database.yml', '--env', 'production', '--export', '--split', '--output', 'schemata/Schemafile'
  end

  desc 'Show difference between schema definition and actual schema'
  task :'dry-run' do
    sh 'ridgepole', '--config', 'config/database.yml', '--env', 'production', '--apply', '--dry-run', '--file', 'schemata/Schemafile'
  end

  desc 'Apply schema definition'
  task :apply do
    sh 'ridgepole', '--config', 'config/database.yml', '--env', 'production', '--apply', '--file', 'schemata/Schemafile'
  end
end
