def set_branch
  set :branch, ENV["BRANCH"] || prompt("Enter a branch to deploy", "master")
end

def set_host
  host = prompt("Enter a host to deploy to", "staging.qwiqq.me")
  role :app, host
  ENV["HOSTFILTER"] = host
end

# stubbed roles
role :worker, ""
role :search, ""
role :db, ""

set_branch
set_host

