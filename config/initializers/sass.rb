# fix for retarded activerecord default leaking into rest of app
Sass::Plugin.options[:never_update] = true