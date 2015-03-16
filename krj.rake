SPEC_SUITES = [
  {id: :pci, title: 'pci compliance', files: %w(spec/controllers/**/pci_spec.rb), dirs: "", tag: ""}
]

def recent_specs(touched_since)
  recent_specs = Dir['app/**/*'].map do |path|
    if File.mtime(path) > touched_since
      spec = File.join('spec', File.dirname(path).split("/")[1..-1].join('/'),
                       "#{File.basename(path, ".*")}_spec.rb")
      spec if File.exists?(spec)
    end
  end.compact

  recent_specs += Dir['spec/**/*_spec.rb'].select do |path|
    File.mtime(path) > touched_since
  end.uniq
end

namespace :spec do
  namespace :suite do
    desc "Run all specs in #{suite[:title]} spec suite"
    Spec::Rake::SpecTask.new(suite[:id]) do |t|
      spec_files = []
      suite[:files].each{|glob| spec_files += Dir[glob]} if suite[:files]
      suite[:dirs].each{|glob| spec_files += Dir[glob]} if suite[:dirs]
      t.rspec_opts = "--tag #{suite[:tag]}"
      t.pattern = spec_files
    end
  end
  desc 'Run all recent specs in spec directory touched in last 1 hour'
  Spec::Rake::SpecTask.new(:recent) do |t|
    t.pattern = recent_specs(Time.now - 60.minutes)
  end
end
