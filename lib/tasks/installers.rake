installers = {
  "Angular": :angular,
  "Elm": :elm,
  "React": :react,
  "Vue": :vue,
  "Erb": :erb,
  "Coffee": :coffee,
  "Typescript": :typescript,
  "Svelte": :svelte,
  "Stimulus": :stimulus
}.freeze

dependencies = {
  "Angular": [:typescript]
}

bin_path = ENV["BUNDLE_BIN"] || "./bin"

namespace :webpacker do
  namespace :install do
    installers.each do |name, task_name|
      desc "Install everything needed for #{name}"
      task task_name => ["webpacker:verify_install"] do
        template = File.expand_path("../install/#{task_name}.rb", __dir__)
        base_path =
          if Rails::VERSION::MAJOR >= 5
            "#{RbConfig.ruby} #{bin_path}/rails app:template"
          else
            "#{RbConfig.ruby} #{bin_path}/rake rails:template"
          end

        dependencies[name] ||= []
        dependencies[name].each do |dependency|
          dependency_template = File.expand_path("../install/#{dependency}.rb", __dir__)
          if Rails::VERSION::MAJOR >= 5
            system "#{base_path} LOCATION=#{dependency_template}"
          else
            ENV["LOCATION"] = dependency_template
            Rake::Task["rails:template"].execute
          end
        end

        if Rails::VERSION::MAJOR >= 5
          exec "#{base_path} LOCATION=#{template}"
        else
          ENV["LOCATION"] = template
          Rake::Task["rails:template"].execute
        end
      end
    end
  end
end
