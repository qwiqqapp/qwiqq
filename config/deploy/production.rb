set :branch, "master"
role :app, "app1.qwiqq.me", "app2.qwiqq.me"
role :worker, "worker1.qwiqq.me"
role :search, "worker2.qwiqq.me"
role :db, "app1.qwiqq.me", :primary => true

