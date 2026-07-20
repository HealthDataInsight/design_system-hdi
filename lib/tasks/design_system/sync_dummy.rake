# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require 'design_system/version'

# Keeps `test/dummy` in sync with the design_system gem's own dummy application.
#
# HDI mirrors the gem's NHS/GOVUK demo app and layers its own in-house (HDI)
# brand on top, so this performs an *overlay* copy: every git-tracked file under
# the gem's `test/dummy` is copied in (adding new files and updating shared
# ones), while files that only exist in HDI are left untouched. Files listed in
# +PRESERVE+ hold HDI-specific branding and are never overwritten.
#
# The copy is deliberately mechanical — after running it, review
# `git diff test/dummy` to re-apply or keep any HDI branding in shared files.
module SyncDummyHelpers
  REPO_ROOT = File.expand_path('../../..', __dir__)
  DEST_DUMMY = File.join(REPO_ROOT, 'test', 'dummy')
  GIT_URL = 'https://github.com/HealthDataInsight/design_system.git'

  # Shared files HDI intentionally owns (brand customisation). These are never
  # overwritten by the sync; edit this list as ownership changes.
  PRESERVE = [
    'app/controllers/application_controller.rb',
    # HDI builds its own brand stylesheet and pins dartsass-rails 0.5.1, whose
    # runner needs build_options as an Array (the gem's dummy uses a String).
    'config/initializers/dartsass.rb',
    # HDI's own (internal-facing) landing page copy, not the gem's guide.
    'app/views/pages/index.html.erb'
  ].freeze

  # Returns [source_dir, temp_dir]. temp_dir is non-nil only when we cloned the
  # repo (so the task knows to clean it up afterwards).
  def self.resolve_source(explicit)
    path = explicit || ENV.fetch('DESIGN_SYSTEM_PATH', nil)

    if path.present?
      full = File.expand_path(path)
      unless File.directory?(File.join(full, 'test', 'dummy'))
        raise "No test/dummy found in design_system source at #{full}"
      end

      return [full, nil]
    end

    clone_source
  end

  # Clone the gem's repo at the tag matching the installed version, falling back
  # to main. Used when no local checkout is supplied.
  def self.clone_source
    tmp = Dir.mktmpdir('design_system-src')

    ["v#{DesignSystem::VERSION}", 'main'].each do |ref|
      if system('git', 'clone', '--depth', '1', '--branch', ref, GIT_URL, tmp,
                out: File::NULL, err: File::NULL)
        return [tmp, tmp]
      end
    end

    FileUtils.remove_entry_secure(tmp)
    raise "Could not clone #{GIT_URL} at v#{DesignSystem::VERSION} or main"
  end

  # git-tracked paths under test/dummy in the source, relative to test/dummy.
  def self.tracked_dummy_files(source)
    Dir.chdir(source) do
      `git ls-files test/dummy`.split("\n").map { |p| p.sub(%r{\Atest/dummy/}, '') }
    end
  end
end

desc 'Sync test/dummy from the design_system gem (optionally pass a source path)'
task :sync_dummy, [:source] do |_t, args|
  source, tmp = SyncDummyHelpers.resolve_source(args[:source])
  added = []
  updated = []

  begin
    files = SyncDummyHelpers.tracked_dummy_files(source)
    raise "No dummy files found in #{source}" if files.empty?

    files.each do |rel|
      next if SyncDummyHelpers::PRESERVE.include?(rel)

      src_file = File.join(source, 'test', 'dummy', rel)
      dest_file = File.join(SyncDummyHelpers::DEST_DUMMY, rel)
      existed = File.exist?(dest_file)
      next if existed && FileUtils.identical?(src_file, dest_file)

      FileUtils.mkdir_p(File.dirname(dest_file))
      FileUtils.cp(src_file, dest_file)
      (existed ? updated : added) << rel
    end

    origin = tmp ? "#{SyncDummyHelpers::GIT_URL} (v#{DesignSystem::VERSION})" : source
    puts "Synced test/dummy from #{origin}"
    puts "  added:   #{added.size} file(s)"
    puts "  updated: #{updated.size} file(s)"
    puts "  kept:    #{SyncDummyHelpers::PRESERVE.size} preserved HDI file(s)"
    puts
    puts 'Review `git diff test/dummy` and re-apply HDI branding where needed.'
  ensure
    FileUtils.remove_entry_secure(tmp) if tmp
  end
end
