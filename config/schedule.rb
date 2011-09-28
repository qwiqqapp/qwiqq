job_type :rake, "cd :path && PATH=/usr/local/bin:$PATH RAILS_ENV=:environment bundle exec rake :task :output"

every 2.minutes do
  rake "thinking_sphinx:index"
end

every 1.day, :at => "1:00 am" do 
  rake "db:backup"
end
