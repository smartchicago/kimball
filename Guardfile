# This group allows to skip running RuboCop when RSpec failed.
group :red_green_refactor, halt_on_fail: true do
  guard :rspec, cmd: "bundle exec rspec --fail-fast" do
    require "guard/rspec/dsl"
    dsl = Guard::RSpec::Dsl.new(self)

    # Feel free to open issues for suggestions and improvements

    # RSpec files
    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)

    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)

    # Rails files
    rails = dsl.rails(view_extensions: %w(erb haml slim))
    dsl.watch_spec_files_for(rails.app_files)
    dsl.watch_spec_files_for(rails.views)

    watch(rails.controllers) do |m|
      [
        rspec.spec.("routing/#{m[1]}_routing"),
        rspec.spec.("controllers/#{m[1]}_controller"),
        rspec.spec.("acceptance/#{m[1]}")
      ]
    end

    # Rails config changes
    watch(rails.spec_helper)     { rspec.spec_dir }
    watch(rails.routes)          { "#{rspec.spec_dir}/routing" }
    watch(rails.app_controller)  { "#{rspec.spec_dir}/controllers" }

    # Capybara features specs
    watch(rails.view_dirs)     { |m| rspec.spec.("features/#{m[1]}") }
    watch(rails.layouts)       { |m| rspec.spec.("features/#{m[1]}") }

    watch('spec/features/people_registration_spec.rb')
    watch('app/controllers/public/people_controller.rb') { 'spec/features/people_registration_spec.rb' }
    watch('app/views/public/people/new.html.erb') { 'spec/features/people_registration_spec.rb' }
    watch('app/views/public/people/_form.html.erb') { 'spec/features/people_registration_spec.rb' }

    watch('app/models/v2/event.rb') { 'spec/features/invite_person_to_phone_call_spec.rb' }
    watch('app/models/v2/event_invitation.rb') { 'spec/features/invite_person_to_phone_call_spec.rb' }
    watch('app/models/v2/time_window.rb') { 'spec/features/invite_person_to_phone_call_spec.rb' }
    watch('app/models/v2/time_slot.rb') { 'spec/features/invite_person_to_phone_call_spec.rb' }
    watch('app/mailers/event_invitation_mailer.rb') { 'spec/features/invite_person_to_phone_call_spec.rb' }
    watch('app/controllers/v2/event_invitations_controller.rb') { 'spec/features/invite_person_to_phone_call_spec.rb' }
    watch('app/views/v2/event_invitations/new.html.erb') { 'spec/features/invite_person_to_phone_call_spec.rb' }
    watch('app/views/v2/event_invitations/_form.html.erb') { 'spec/features/invite_person_to_phone_call_spec.rb' }
    watch('app/views/event_invitation_mailer/invite.html.erb') { 'spec/features/invite_person_to_phone_call_spec.rb' }
    watch('app/views/event_invitation_mailer/invite.text.erb') { 'spec/features/invite_person_to_phone_call_spec.rb' }

    watch('spec/features/person_responds_to_interview_invitation_spec.rb')
    watch('app/views/event_invitation_mailer/invite.html.erb') { 'spec/features/person_responds_to_interview_invitation_spec.rb' }
    watch('app/views/event_invitation_mailer/invite.text.erb') { 'spec/features/person_responds_to_interview_invitation_spec.rb' }

    watch('app/mailers/event_invitation_mailer.rb') { 'spec/features/person_responds_to_interview_invitation_spec.rb' }
    watch('app/models/v2/reservation.rb') { 'spec/features/person_responds_to_interview_invitation_spec.rb' }
    watch('app/controllers/v2/reservations_controller.rb') { 'spec/features/person_responds_to_interview_invitation_spec.rb' }
    watch('app/views/v2/reservations/new.html.erb') { 'spec/features/person_responds_to_interview_invitation_spec.rb' }
    watch('app/views/v2/reservations/_form.html.erb') { 'spec/features/person_responds_to_interview_invitation_spec.rb' }
  end

  guard :minitest, test_folders: ['test']  do
    watch(%r{^test/(.*)\/?test_(.*)\.rb$})
    watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
    watch(%r{^test/test_helper\.rb$})      { 'test' }

    watch(%r{^app/controllers/application_controller\.rb$}) { 'test/controllers' }
    watch(%r{^app/controllers/(.+)_controller\.rb$})        { |m| "test/integration/#{m[1]}_test.rb" }
    watch(%r{^app/views/(.+)_mailer/.+})                   { |m| "test/mailers/#{m[1]}_mailer_test.rb" }
    watch(%r{^test/.+_test\.rb$})
    watch(%r{^test/test_helper\.rb$}) { 'test' }
    watch(%r{^app/models/(.*)\.rb$})      { |m| "test/models/#{m[1]}_test.rb" }
  end

  guard :rubocop do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end
