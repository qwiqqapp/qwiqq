Sass::Plugin.options[:template_location] = File.join(Rails.root.to_s, 'app/stylesheets')
Sass::Plugin.options[:css_location] = File.join(Rails.root.to_s, 'public/stylesheets')
Sass::Plugin.options[:always_update] = true
Sass::Plugin.options[:style] = Rails.env == "production" ? :compressed : :nested
